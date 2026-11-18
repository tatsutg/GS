------
-- summoner.Choreo.Components.HateTarget
--
-- ターゲットを1体選び、その相手に**バフ／フォーカス表示を常時維持**するギミック。
-- 選出ルールは `rule` で切り替える:
--   `rule = 'hate'`   … 既定。takeDamageValue のたびに **攻撃してきたユニットごとにダメージ量を
--                        Lua 側で加算**し、累計が最大の相手をターゲットとする
--                        （engine のヘイト機構には依存しない）。
--   `rule = 'leader'` … **リーダーユニット**をターゲットとする（決闘法廷型）。
--                        リーダーが戦闘不能なら「生存している中で一番左」＝最小 index、
--                        蘇生すればリーダーへ戻る（`Targeting{ pick='leader' }` と同じ規約）。
--
-- targetBuff / othersBuff を指定すると「ターゲットに◯◯・それ以外に△△」を**常時維持**する
-- （累計の首位が入れ替わったら自動で貼り替える）。単発の AttachBuff と違い入れ替わりに追従するのが本機能。
--
-- `mode` を指定すると、`Mode` Component の状態がそのいずれかの間だけ稼働する（決闘法廷を HP70% 以降に限る等）。
-- 状態を外れたら全枠のバフを剥がしてフォーカスも外し（休止）、戻れば再び貼る。
-- ⚠ `mode` を指定しないと**ボスの登場直後から**稼働する（途中から出したいギミックでは必ず指定する）。
--
-- ⚠ update / takeDamageValue を使うため boss version >= 1.1。
--
-- @example リーダーをターゲットにしてフォーカス表示（決闘法廷）。バフ無し＝マーカーだけでもよい。
--     boss:add(HateTarget{ rule = 'leader', icon = 14 })
--     -- マーカー＋「ターゲットにアイコンを出す」なら見た目だけのバフを併用する（group=-1 必須）:
--     boss:add(HateTarget{ rule = 'leader', icon = 14,
--                          targetBuff = { id = 2084xxxx31, type = 0, icon = 177, group = -1 } })
--     -- HP70% 以降（Mode が lord の間）だけ出す。Phases 等で SetMode{'lord'} したときに貼られる:
--     boss:add(HateTarget{ rule = 'leader', icon = 14, mode = 'lord' })
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
-- @example 累計ダメージ最大のユニットをターゲットにするだけ（バフ無し）。icon でフォーカス表示が有効になり、
--          首位の判定・engine のヘイトターゲット（攻撃対象）・ゲストへの配信がバフ有りと同じく動く。
--     boss:add(HateTarget{ icon = 14 })
--     -- 奥義3でターゲットを封圧状態にし、ターゲットの累計だけリセット（2番手が次のターゲットになる）:
--     boss:add(Smash{ sets={{3},{4}}, onUse = { [3] = {
--         AttachBuff{ target = Targeting{ pick="hate" }, id = …, type = 92, time = 3, icon = 303 },
--         ResetHate{ scope = 'target' },
--     } } })
--
-- 設定:
--   targetBuff  table   ターゲット本人へ常時付与するバフ。省略で無効。
--   othersBuff  table   ターゲット以外の味方へ常時付与するバフ。省略で無効。
--     バフのキー: id(必須・除去に使う固定ID) / type(必須・condition type。与ダメージ割合=17)
--                 value / icon / effect / group / priority / time（既定 99999＝常時）
--     yaml では type に用語名も使える（`type: 与ダメージ` → 17）。
--   rule        string  ターゲット選出ルール `'hate'`（既定）/ `'leader'`
--   damageRate  number  ダメージ→累計への換算率（既定1）※`rule='hate'` 専用
--   resetOnDeath bool   死亡した味方の累計をクリアする（既定 false＝保持）。※`rule='hate'` 専用
--                       false: 死亡中は首位候補から外れるだけ。蘇生すると元の累計で復帰しうる。
--                       true : 死亡時点で累計を破棄。蘇生後は 0 から数え直し
--                              （実績実装 enemy/2072890.lua の targetUnitReset 相当）。
--                       ※ 判定は getTeamUnit(i) == nil なので、交代・リザーブで枠から外れた
--                          場合も同様にクリアされる（仕様として許容）。
--   icon        number  ヘイトターゲットアイコンID。**指定するとフォーカス表示が有効になる**
--                       （バフ指定が無くても icon だけで稼働する。rule='hate' も 'leader' も同じ）
--   focus       bool    フォーカス表示の明示指定（icon 省略時に既定14で出したいなら true、
--                       icon を指定しつつ表示を切りたいなら false）
--   mode        string|table  稼働させる `Mode` の状態名、またはその配列（`Defense` の `rule.mode` と同じ書式）。
--                       省略時は常時稼働（従来どおり）。指定時はその状態の間だけバフ／フォーカスを出し、
--                       外れたら全枠のバフを剥がしてフォーカスも外す（休止）。戻れば再び貼る。
--                       ⚠ `Mode` を宣言していないボスで指定すると一度も稼働しない（`Defense` と同じ）。
--
-- ⚠ focus=true にする場合、engine のヘイト機構は **一式そろえて呼ぶ**こと（実績実装
--    enemy/2072890.lua に準拠）。load 時に setEnableHate(true)/visibleHateTarget(true) を行い、
--    ターゲット変更時は setHateTarget() の直後に必ず updateHateTarget() を呼ぶ。
--    部分的に呼ぶと実機でクラッシュする（signal 11 を確認）。
--    ターゲットの可視化はバフのアイコンでも代替できるため、既定は false（engine 非連携）。
--
-- ⚠ `rule='leader'` のマルチ同期: **Sync を使わない**。`getIsLeader()` はマルチだと engine 側で
--    `index==0` 固定になり（`TeamUnit.cpp` の isMultiPlay 分岐）、単機でもデッキのリーダーで確定するため
--    **全端末が同じ1体を選ぶ＝決定的**。各端末が自分で判定して貼るほうが取りこぼしが無い。
--    仕様上は「リーダー＝チーム枠0（ホストの1体目）」になり、ゲストのリーダーは対象にならない
--    （2026-09-15 企画確認済み・意図どおり）。
-- ⚠ `rule='leader'` は **update 契機**で判定する（`takeDamageValue` の最中ではない）。
--    ボスが殴られなくてもリーダーは死亡/蘇生しうるため、被弾契機では追従できない。
--    コンディション操作が takeDamageValue の外なので鉄則1（hostDecide 経由の付け外し禁止）にも抵触しない。
--
-- ⚠ `mode` の休止: フォーカスは `setHateTarget(nil)` の直後に `updateHateTarget()` を呼んで外す
--    （「setHateTarget と updateHateTarget は必ず対で呼ぶ」の手順どおり）。ターゲット無しの updateHateTarget は
--    全員のフォーカスを隠すだけで、ヘイト値も onLoad でレート0にしてあり積まれないため、engine が勝手に
--    別の相手を選ぶことも無い（`TeamUnit::updateHateTarget`）。マルチでは engine が HATETARGET(-1) を配り、
--    受信側も `setHateTarget(NULL)`＋非表示になる（`Battle.event.cpp`）。
--    剥がすのは**外れた瞬間の1回だけ**で、休止中は engine に触らない。戦闘不能で消えたバフも休止中は貼り直さない。
-- ⚠ `mode` の同期: `rule='leader'` は各端末が自分の Mode を見て休止/再開する（Mode 遷移は全端末で同じ）。
--    `rule='hate'` は**ホストだけ**が Mode を見て、休止を index の代わりに `OFF`(-2) として配る
--    （ゲストは従来どおり受信値に従うだけ）。mode 外でも累計は加算し続け、再開後は次の被弾で首位を判定する
--    （開幕と同じ。mode 外の被弾も累計に入る）。
--
-- ⚠ `rule='hate'` のマルチ同期: 累計はダメージ計算のタイミング差で端末ごとにブレうるため、**ホストのみ**が
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
local OFF = -2               -- mode 外で休止中（全枠バフ無し・フォーカス無し）。NO_TARGET（稼働中だが相手不在）とは別
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
    local rule = config.rule or 'hate'
    assert(rule == 'hate' or rule == 'leader',
        'Choreo.HateTarget: rule は "hate"（既定）か "leader"')
    local isLeaderRule = (rule == 'leader')
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
    -- 稼働させる Mode の状態（`Defense` の `rule.mode` と同じ書式＝状態名か、その配列）。
    -- nil（既定）は常時稼働＝従来どおり。
    local modes = config.mode
    if type(modes) == 'string' then modes = { modes } end
    if modes ~= nil then
        assert(type(modes) == 'table' and #modes > 0,
            'Choreo.HateTarget: mode は Mode の状態名（文字列）か、その配列')
        for i = 1, #modes do
            assert(type(modes[i]) == 'string', 'Choreo.HateTarget: mode の要素は Mode の状態名（文字列）')
        end
    end
    local useBuffs = (targetBuff ~= nil) or (othersBuff ~= nil)
    -- 稼働条件。バフ指定があるか、フォーカス表示（icon / focus）があれば動かす。
    -- フォーカスだけ（バフ無し）も正当な使い方: leader は決闘法廷のマーカー、hate は
    -- 「累計ダメージ最大のユニットをターゲットにする」だけのボス（engine のヘイトターゲット＝攻撃対象と
    -- Targeting{ pick='hate' } の相手がこれで決まる）。
    local active = useBuffs or focus

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

    -- 今の Mode 状態が稼働対象か（mode 未指定なら常に true）。
    -- 現在状態は dispatcher._mode（Mode Component が持つ）。Mode 未使用なら nil＝常に不成立（Defense と同じ）。
    local function inMode(self)
        if modes == nil then return true end
        local now = self._mode
        for i = 1, #modes do
            if now == modes[i] then return true end
        end
        return false
    end


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

    -- 全枠のバフを「あるべき状態」へ寄せる。**冪等**（差分のある枠だけ addCondition する）ので
    -- 毎 update 呼んでもよい。蘇生した枠（applied を忘れた枠）はここで貼り直る。
    local function refreshBuffs(targetIndex)
        local team = megast.Battle:getInstance():getTeam(true)
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
    end

    -- engine 側のヘイトターゲット（フォーカス表示）を追従させる（focus 有効時のみ）。
    -- ⚠ setHateTarget と updateHateTarget は必ずセットで呼ぶ（実績実装 enemy/2072890.lua に準拠）。
    --    updateHateTarget が showHateFocus + updateConditionView まで面倒を見るため、
    --    **バフの付け外しより後**に呼ぶ（コンディション表示の再構築でアイコンが消えないように）。
    -- ⚠ 表示の再構築を伴うので**ターゲットが変わったときだけ**呼ぶ（毎フレーム呼ばない）。
    local function applyFocus(self, targetIndex)
        if not focus then return end
        local team = megast.Battle:getInstance():getTeam(true)
        local target = (targetIndex ~= NO_TARGET) and team:getTeamUnit(targetIndex) or nil
        if target ~= nil and self.unit then
            self.unit:setHateTarget(target)
            self.unit:updateHateTarget()
        end
    end

    -- 休止（mode を外れたとき）: 全枠のバフを剥がし、engine フォーカスも外す。
    -- ⚠ フォーカスは setHateTarget(nil) の直後に updateHateTarget()（必ず対で呼ぶ）。
    --    ターゲット無しの updateHateTarget は全員のフォーカスを隠すだけ（ヘッダの ⚠ 参照）。
    local function suspend(self)
        local team = megast.Battle:getInstance():getTeam(true)
        for i = 0, MAX_INDEX do
            local u = team:getTeamUnit(i)   -- 死亡ユニットは nil（バフは engine が死亡時に消している）
            if u ~= nil then
                if targetBuff ~= nil then detachBuff(u, targetBuff.id) end
                if othersBuff ~= nil then detachBuff(u, othersBuff.id) end
            end
            applied[i] = nil                -- 再開時は「不明」扱いで貼り直す
        end
        if focus and self.unit then
            self.unit:setHateTarget(nil)
            self.unit:updateHateTarget()
        end
    end

    -- ターゲット index を受けて全枠を貼り替える（ホストは判定時 / ゲストは受信時）。OFF は休止。
    local function applyByTargetIndex(self, targetIndex)
        if targetIndex == OFF then
            suspend(self)
            return
        end
        refreshBuffs(targetIndex)
        applyFocus(self, targetIndex)
    end

    -- リーダーの枠を返す。リーダーが戦闘不能（枠が nil）なら「生存している中で一番左」＝最小 index。
    -- ⚠ `Targeting.lua` の `pick == 'leader'` と**同じ規約**（engine の `Team::getLeader()` 準拠）。
    --    片方だけ直すと決闘法廷の「マーカーの相手」と「強化される相手」がズレるので、必ず両方直すこと。
    local function leaderIndex()
        local team = megast.Battle:getInstance():getTeam(true)
        local first = NO_TARGET
        for i = 0, MAX_INDEX do
            local u = team:getTeamUnit(i)
            if u ~= nil then
                if u:getIsLeader() then return i end
                if first == NO_TARGET then first = i end
            end
        end
        return first
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
        if modes ~= nil then
            -- mode 指定時は「休止中」から始める（開幕が mode 外なら何も貼らず、何も剥がさない）
            self._hateTargetIndex = OFF
            self._hateSentIndex = OFF
        end
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
        if not active then return end

        -- 首位の判定はホストのみ。変わったらその場で貼り替え、ゲストへは index を配信する。
        -- ⚠ hostDecide（handler 経由）ではなく **直接適用 + broadcast** にする。
        --    実機で動作実績のある手順（被弾中にその場で addCondition する）と同一の呼び出し形にするため。
        if self.isHostPlayer then
            local top = topIndex(self)
            -- mode 外は休止中＝判定結果を使わない（休止の配信は onUpdate が行う）。
            -- topIndex は resetOnDeath の死亡観測を兼ねるので、mode 外でも先に呼んでおく。
            if not inMode(self) then return end
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
        if not active then return end
        if not inMode(self) then
            -- mode を外れた: ホストが休止（OFF）を自分に適用し、ゲストへ配る（ゲストは受信で休止する）
            if self.isHostPlayer and self._hateSentIndex ~= OFF then
                self._hateSentIndex = OFF
                self._hateTargetIndex = OFF
                applyByTargetIndex(self, OFF)
                self:broadcast(CHANNEL, OFF)
            end
            return
        end
        -- 初回の判定（被弾）までは何もしない。mode に入り直した直後も同じく次の被弾で判定する
        if self._hateTargetIndex == nil or self._hateTargetIndex == OFF then return end
        if not self.isHostPlayer then return end
        local top = topIndex(self)
        if top ~= self._hateSentIndex then
            self._hateSentIndex = top
            self._hateTargetIndex = top
            applyByTargetIndex(self, top)
            self:broadcast(CHANNEL, top)
        end
    end

    -- rule='leader': 毎 update でリーダーを引き直す。
    --   ・バフは冪等な refreshBuffs で毎回寄せる（蘇生した枠にも貼り直る）
    --   ・engine フォーカスは**ターゲットが変わったときだけ**更新する（表示再構築が重いため）
    --   ・選出が全端末で決定的なので host 分岐も broadcast も無し（ヘッダの ⚠ 参照）
    --   ・mode 指定時、mode 外では休止（外れた瞬間に1回だけ剥がし、以降は engine に触らない）
    local function onUpdateLeader(self, event)
        if not active then return end
        if not inMode(self) then
            -- mode 外（開幕の待機中／mode を外れた後）: 休止。外れた瞬間に1回だけ剥がす
            if self._hateTargetIndex ~= OFF then
                self._hateTargetIndex = OFF
                suspend(self)
            end
            return
        end
        local idx = leaderIndex()
        refreshBuffs(idx)
        if idx ~= self._hateTargetIndex then
            self._hateTargetIndex = idx
            applyFocus(self, idx)
        end
    end

    function component.initialize(dispatcher)
        dispatcher._hateTotals = {}
        if isLeaderRule then
            -- Sync チャンネルも takeDamageValue も要らない（決定的・update 契機）
            dispatcher:addEventListener(Events.OnLoad, onLoad)
            dispatcher:addEventListener(Events.OnUpdate, onUpdateLeader)
            return
        end
        if active then
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
