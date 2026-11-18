------
-- summoner.Choreo.Components.HateTarget
--
-- 「累計ダメージが最大のユニット」をターゲットにするギミック。
-- takeDamageValue のたびに **攻撃してきたユニットごとにダメージ量を Lua 側で加算**し、
-- 累計が最大の相手をターゲットとする（engine のヘイト機構には依存しない）。
--
-- targetBuff / othersBuff を指定すると「ターゲットに◯◯・それ以外に△△」を**常時維持**する
-- （累計の首位が入れ替わったら自動で貼り替える）。単発の AttachBuff と違い入れ替わりに追従するのが本機能。
--
-- ⚠ update / takeDamageValue を使うため boss version >= 1.1。
--
-- @example
--     -- 累計ダメ最大をターゲット → ターゲットの与ダメ100%ダウン / それ以外の与ダメ50%アップ:
--     boss:add(HateTarget{
--         targetBuff = { id = 90210001, type = 17, value = -100, icon = 23 },
--         othersBuff = { id = 90210002, type = 17, value =   50, icon = 22 },
--     })
--
--     -- 奥義5使用時に「現ターゲットにクリ率100%UP」＋累計リセット:
--     boss:add(Smash{ sets={{5},{7}}, onUse = { [5] = {
--         AttachBuff{ target = Targeting{ pick="hate" }, type = Choreo.BuffType.None, value = 100, icon = 22 },
--         ResetHate{},
--     } } })
--
-- 設定:
--   targetBuff  table   ターゲット本人へ常時付与するバフ。省略で無効。
--   othersBuff  table   ターゲット以外の味方へ常時付与するバフ。省略で無効。
--     バフのキー: id(必須・除去に使う固定ID) / type(必須・condition type。与ダメージ割合=17)
--                 value / icon / effect / group / priority / time（既定 99999＝常時）
--     yaml では type に用語名も使える（`type: 与ダメージ` → 17）。
--   damageRate  number  ダメージ→累計への換算率（既定1）
--   resetOnDeath bool   死亡した味方の累計をクリアする（既定 false＝保持）。
--                       false: 死亡中は首位候補から外れるだけ。蘇生すると元の累計で復帰しうる。
--                       true : 死亡時点で累計を破棄。蘇生後は 0 から数え直し
--                              （実績実装 enemy/2072890.lua の targetUnitReset 相当）。
--                       ※ 判定は getTeamUnit(i) == nil なので、交代・リザーブで枠から外れた
--                          場合も同様にクリアされる（仕様として許容）。
--   icon        number  ヘイトターゲットアイコンID。**指定するとフォーカス表示が有効になる**
--   focus       bool    フォーカス表示の明示指定（icon 省略時に既定14で出したいなら true、
--                       icon を指定しつつ表示を切りたいなら false）
--
-- ⚠ focus=true にする場合、engine のヘイト機構は **一式そろえて呼ぶ**こと（実績実装
--    enemy/2072890.lua に準拠）。load 時に setEnableHate(true)/visibleHateTarget(true) を行い、
--    ターゲット変更時は setHateTarget() の直後に必ず updateHateTarget() を呼ぶ。
--    部分的に呼ぶと実機でクラッシュする（signal 11 を確認）。
--    ターゲットの可視化はバフのアイコンでも代替できるため、既定は false（engine 非連携）。
--
-- ⚠ マルチ同期: 累計はダメージ計算のタイミング差で端末ごとにブレうるため、**ホストのみ**が
--    首位を判定し、その team index を Sync で全端末へ配信する。
--    ホストは判定したその場で自分のバフを貼り替え、`broadcast` は **ゲストへの配信専用**に使う。
--    ゲストは自分では判定せず、受け取った index に対して貼り替える。
--
-- ⚠ ホスト側で `hostDecide`（チャンネル handler 経由で適用）を使ってはいけない。
--    takeDamageValue の最中に handler 経由でコンディションを付け外しすると実機でクラッシュした
--    （EXC_BAD_ACCESS / lj_vmeta_callt → lj_BC_TGETS）。直接適用 + broadcast なら安全（実機PASS）。
--
-- ⚠ バフの付け外しは Buff モジュールや Utility を経由せず、addCondition / removeCondition を
--    直接呼ぶ（実績実装 enemy/2072890.lua の execAddBuff と同じ形）。
------
local _NAME = 'summoner.Choreo.Components.HateTarget'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Sync = require('summoner.Choreo.Components.Sync')

local MAX_INDEX = 7          -- チーム枠 0..7
local NO_TARGET = -1         -- ターゲット無し（Sync は数値のみ運ぶため -1 で表現）
local CHANNEL = 'hateBuff'   -- ターゲット team index を配信するチャンネル

-- 攻撃してきたユニットの team index を得る（オービット等の子は親を見る）
local function attackerIndex(attacker)
    if attacker == nil then return nil end
    local parent = attacker.getParentTeamUnit and attacker:getParentTeamUnit() or nil
    if parent ~= nil then return parent:getIndex() end
    return attacker:getIndex()
end

-- バフを剥がす（findConditionWithID → removeCondition を直接呼ぶ）。
-- ⚠ summoner.Utility 等のモジュール関数は経由しない（実績実装と同じくインラインで呼ぶ）。
local function detachBuff(unit, id)
    local cond = unit:getTeamUnitCondition()
    local old = cond:findConditionWithID(id)
    if old ~= nil then cond:removeCondition(old) end
end

-- バフを付与する（addCondition を直接呼ぶ）。
-- ⚠ Choreo の Buff モジュール（Buff{...}）は使わない。
--    Buff は __call メタメソッド付きテーブルで、takeDamageValue の最中に呼ぶと
--    実機で LuaJIT がクラッシュした（lj_vmeta_callt → lj_BC_TGETS で EXC_BAD_ACCESS）。
--    実績実装 enemy/2072890.lua の execAddBuff と同じく生の addCondition を使う。
local function attachBuff(unit, cfg)
    local cond = unit:getTeamUnitCondition()
    local c = cond:addCondition(cfg.id, cfg.type, cfg.value or 0, cfg.time or 99999, cfg.icon or 0)
    if c ~= nil then
        c:setGroupID(cfg.group or cfg.type)          -- 同種は同グループ（既定＝効果タイプ）
        c:setPriority(cfg.priority or cfg.value or 0)
    end
    return c
end

local function HateTarget(config)
    config = config or {}
    local targetBuff = config.targetBuff
    local othersBuff = config.othersBuff
    local damageRate = config.damageRate or 1
    -- engine のヘイトターゲット表示（フォーカス枠）と連携するか。
    -- icon を指定したら表示したい意図とみなして自動で有効化する（focus で明示指定も可）。
    -- 有効時は実績実装 enemy/2072890.lua と同じ手順を踏む（load 時の enable/visible とセット）。
    local focus = (config.focus ~= false) and (config.focus == true or config.icon ~= nil)
    local focusIcon = config.icon or 14
    -- 死亡した味方の累計をクリアするか（既定 false＝保持）。
    -- true にすると蘇生してもその枠は 0 から数え直しになる。
    local resetOnDeath = config.resetOnDeath == true
    local useBuffs = (targetBuff ~= nil) or (othersBuff ~= nil)

    if targetBuff ~= nil then
        assert(type(targetBuff.id) == 'number' and type(targetBuff.type) == 'number',
            'Choreo.HateTarget: targetBuff は id と type（数値）が必須（id は貼り替え時の除去に使う）')
    end
    if othersBuff ~= nil then
        assert(type(othersBuff.id) == 'number' and type(othersBuff.type) == 'number',
            'Choreo.HateTarget: othersBuff は id と type（数値）が必須（id は貼り替え時の除去に使う）')
    end
    assert(targetBuff == nil or othersBuff == nil or targetBuff.id ~= othersBuff.id,
        'Choreo.HateTarget: targetBuff.id と othersBuff.id は別 ID にすること（同一だと除去で取り違える）')

    local component = { name = 'HateTarget' }

    -- 味方 index -> 現在その枠へ貼っている種別（'target' / 'others' / nil=不明）
    local applied = {}


    -- 1枠を「あるべき状態」へ寄せる（既に同じなら何もしない＝毎フレームの addCondition 連打を防ぐ）
    local function applyTo(unit, index, want)
        local now = applied[index]
        if now == want then return end
        -- now == nil は「不明」（初回 / 死亡で忘れた後の蘇生）。取り違えを避けるため両方剥がしてから貼る。
        if now == nil then
            if targetBuff ~= nil then detachBuff(unit, targetBuff.id) end
            if othersBuff ~= nil then detachBuff(unit, othersBuff.id) end
        elseif now == 'target' and targetBuff ~= nil then
            detachBuff(unit, targetBuff.id)
        elseif now == 'others' and othersBuff ~= nil then
            detachBuff(unit, othersBuff.id)
        end
        if want == 'target' and targetBuff ~= nil then
            attachBuff(unit, targetBuff)
        elseif want == 'others' and othersBuff ~= nil then
            attachBuff(unit, othersBuff)
        end
        applied[index] = want
    end

    -- ターゲット index を受けて全枠を貼り替える（ホストは判定時 / ゲストは受信時）
    local function applyByTargetIndex(self, targetIndex)
        local team = megast.Battle:getInstance():getTeam(true)
        local target = (targetIndex ~= NO_TARGET) and team:getTeamUnit(targetIndex) or nil

        for i = 0, MAX_INDEX do
            local u = team:getTeamUnit(i)   -- 死亡ユニットは nil（engine 仕様）
            if u == nil then
                applied[i] = nil            -- 枠が空いた → 状態を忘れる（蘇生時に貼り直す）
            elseif i == targetIndex then
                applyTo(u, i, 'target')
            else
                applyTo(u, i, 'others')
            end
        end

        -- engine 側のヘイトターゲット（フォーカス表示）を追従させる（focus 有効時のみ）。
        -- ⚠ setHateTarget と updateHateTarget は必ずセットで呼ぶ（実績実装 enemy/2072890.lua に準拠）。
        --    updateHateTarget が showHateFocus + updateConditionView まで面倒を見るため、
        --    **バフの付け外しより後**に呼ぶ（コンディション表示の再構築でアイコンが消えないように）。
        if focus and target ~= nil and self.unit then
            self.unit:setHateTarget(target)
            self.unit:updateHateTarget()
        end
    end

    -- 累計最大の枠を返す（生存ユニットのみ。同値は index の小さい方＝両端末で同じ結果）
    -- ⚠ engine の getTeamUnit は死亡ユニットに nil を返すので、
    --    「累計を持っている枠が nil」＝その枠が死亡（または離脱）したと判定できる。
    --    resetOnDeath 有効時はこのタイミングで累計を捨てる（同じループで処理してコストを増やさない）。
    local function topIndex(self)
        local team = megast.Battle:getInstance():getTeam(true)
        local best, bestVal = NO_TARGET, 0
        for i = 0, MAX_INDEX do
            local v = self._hateTotals[i]
            if v ~= nil then
                if team:getTeamUnit(i) == nil then
                    -- 死亡枠。首位候補から外す（resetOnDeath なら累計自体を破棄）
                    if resetOnDeath then self._hateTotals[i] = nil end
                elseif v > bestVal then
                    best, bestVal = i, v
                end
            end
        end
        return best
    end

    local function onLoad(self, event)
        self._hateTotals = {}
        if focus then
            -- 実績実装 enemy/2072890.lua の load 手順をそのまま踏む。
            -- 自動ヘイトは使わない（累計は Lua 側で持つ）ので rate は 0 にする。
            local unit = event.unit
            unit:setHateRate_Heal(0)
            unit:setHateRate_Damage(0)
            BattleControl:get():visibleHateTarget(true)
            BattleControl:get():setHateTargetIcon(focusIcon)
            unit:setEnableHate(true)
            unit:updateHateTarget()
        end
    end

    -- 被弾のたびに「誰が何ダメージ与えたか」を加算し、その場で首位を判定・反映する。
    -- （実績実装 enemy/2072890.lua と同じ契機。update 毎ではなく被弾毎に行う）
    -- 値は変えない＝加算と観測のみ。
    local function onDamage(self, event)
        local idx = attackerIndex(event.enemy)
        if idx ~= nil then
            local add = (event.value or 0) * damageRate
            if add > 0 then
                self._hateTotals[idx] = (self._hateTotals[idx] or 0) + add
            end
        end
        if not useBuffs then return end

        -- 首位の判定はホストのみ。変わったらその場で貼り替え、ゲストへは index を配信する。
        -- ⚠ hostDecide（handler 経由）ではなく **直接適用 + broadcast** にする。
        --    実機で動作実績のある手順（被弾中にその場で addCondition する）と同一の呼び出し形にするため。
        if self.isHostPlayer then
            local top = topIndex(self)
            if top ~= self._hateSentIndex then
                self._hateSentIndex = top
                self._hateTargetIndex = top
                applyByTargetIndex(self, top)     -- ホストはその場で適用
                self:broadcast(CHANNEL, top)      -- ゲストへは index のみ配信（ソロでは no-op）
            end
        end
    end

    -- ⚠ バフの管理は takeDamageValue のみで行う（実績実装 enemy/2072890.lua と同じ）。
    --    update ではバフを触らない。ここでは「死亡で首位が変わった」場合の再判定のみ行い、
    --    実際の貼り替えは hostDecide → handler 経由に任せる。
    local function onUpdate(self, event)
        if not useBuffs then return end
        if self._hateTargetIndex == nil then return end
        if not self.isHostPlayer then return end
        local top = topIndex(self)
        if top ~= self._hateSentIndex then
            self._hateSentIndex = top
            self._hateTargetIndex = top
            applyByTargetIndex(self, top)
            self:broadcast(CHANNEL, top)
        end
    end

    function component.initialize(dispatcher)
        dispatcher._hateTotals = {}
        if useBuffs then
            if not dispatcher:hasComponent('Sync') then
                dispatcher:add(Sync.create())
            end
            dispatcher:openChannel(CHANNEL, function(self, value)
                -- ホストは hostDecide 時、ゲストは受信時にここへ来る（同じ値＝同じ相手）
                self._hateTargetIndex = value
                applyByTargetIndex(self, value)
            end)
        end
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.takeDamageValue, onDamage)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = HateTarget
return HateTarget
