------
-- summoner.Choreo.Components.Selector
--
-- 行動抽選 Component の共通基底（Attack / Smash が利用する内部モジュール）。
-- 実ボスの「二段発火」フローを Sync で同期しつつ隠蔽する:
--
--   pass1: C++ が takeAttack/takeSkill を発火
--     - ホスト: 抽選で index を決定 → hostDecide(channel, index)（自分で再生 + 全端末配信）→ この発火は prevent(中断)
--     - ゲスト: takeIdle して待機 → prevent
--   再生(replay): index を決めた側が unit:takeAttack/takeSkill(index) を再発火
--   pass2: その再発火で index 付きイベントが来る → setActiveSkill(index) を確定（+ onExecute）
--
-- 書き手は isHost / sendEventToLua / receiveN / fromHost を一切書かない。
--
-- @param opts table
--     name        string   Component 名（'Attack' / 'Smash'）
--     event       string   購読イベント（Events.OnAttack / OnSmash）
--     channel     string   Sync チャンネル名（'attack' / 'skill'）
--     animBase    string   C++ 既定アニメ名の接頭辞（'attack' / 'skill'）。AnimVariant 適用時に
--                          anim 未指定の index のアニメ名を組み立てるのに使う
--     trigger     function function(unit, index)  index 付きで C++ 行動を再発火
--     onExecute   function (任意) function(dispatcher, unit, index)  実行時の追加処理（例: Burst）
--     config      table    boss が渡した設定（weights | sets, activeSkills, skillInvocationWeight 等）
--
-- ⚠ 開幕(start)にエンジン自動スキル発動を停止する（setSkillInvocationWeight(0)。マスタの
--   skill_invocation_weight を無効化）。変えたい場合のみ config.skillInvocationWeight を数値指定。
------
local _NAME = 'summoner.Choreo.Components.Selector'
local _M = {}
local _G = _G

local Events = require('summoner.Choreo.Events')
local Sync = require('summoner.Choreo.Components.Sync')
local Action = require('summoner.Choreo.Action')
local Random = require('summoner.Random')

------
-- 設定済み Component（vendor）を生成する
------
function _M.makeComponent(opts)
    local config = opts.config or {}
    local weights = config.weights
    local sets = config.sets
    local activeSkills = config.activeSkills
    local cutin = config.cutin            -- index => カットイン種別(BurstType)。Smash で使用
    local onUse = config.onUse            -- index => Action|list。そのスキル/奥義 使用時に実行
    local every = config.every            -- { skill=, interval=, first= }: N回ごとに skill を強制（周期ローテ）
    local byHP = config.byHP              -- { {above=, skill=}, ..., {skill=} }: HP帯で index を切替
    local byMode = config.byMode          -- { <mode> = { sets= | weights= | skill= } }: Mode 状態別の行動
    local anim = config.anim              -- index => 本体アニメ名("attack1"/"skill3" 等。Spine=<unit_id>.json）。あれば setNextAnimationName で明示上書き（効果スロット index とは独立。enemy/1404016.lua 方式）。指定なし=既定(unitBossBase 互換)
    local animeff = config.animeff        -- index => エフェクトアニメ名(Spine=<baseID>ef.json の "1-skill3" 等)。未指定なら anim から "<stage>-<anim>" を算出
    local noVariant = config.noVariant    -- index => true。AnimVariant のサフィックスを乗せない index（バリアントを持たない共用アニメ用）
    local skillInvocationWeight = config.skillInvocationWeight
    -- ↑ エンジン自動スキル発動の重み。既定 nil = 開幕に 0 をセット（マスタ skill_invocation_weight を無効化し
    --   行動選択を Lua が完全掌握。旧ボスが start で必ず setSkillInvocationWeight(0) していた定型の宣言化）。
    --   数値指定時のみその値をセット。Attack/Smash 両搭載で片方だけ指定した場合は指定側が勝つ（宣言順に依存しない）

    -- 抽選ソースが1つも無いと pickIndex が Random.sampleWeighted(nil) でクラッシュ → 構築時に弾く
    assert(sets or weights or byMode or byHP,
           'Choreo: ' .. opts.name .. ' は sets / weights / byMode / byHP のいずれかが必要')

    -- Attack/Smash で衝突しないよう、状態キーを Component 名で分ける
    local stepKey = '_' .. opts.name .. 'Step'
    local decidedKey = '_' .. opts.name .. 'Decided'
    local forcedKey = '_' .. opts.name .. 'Forced'   -- 強制 index（UseSkill 用。あれば抽選より優先）
    local everyKey = '_' .. opts.name .. 'Every'      -- 周期カウンタ（every 用）
    local cutinOnceKey = '_' .. opts.name .. 'CutinOnce'   -- 1回限りのカットイン上書き（UseSkill{cutin=} 用）

    -- 次の行動 index を抽選する（ホストのみ実行）
    local function pickIndex(self)
        -- 強制スロットがあれば最優先（1回限り）
        if self[forcedKey] ~= nil then
            local index = self[forcedKey]
            self[forcedKey] = nil
            return index
        end
        -- HP帯で index 切替（上から評価。above 条件を満たす最初。above なし=既定）
        if byHP ~= nil then
            local u = self.unit
            local hpRate = u:getHP() / u:getCalcHPMAX() * 100
            for i = 1, #byHP do
                local band = byHP[i]
                if band.above == nil or hpRate >= band.above then
                    if band.skill ~= nil then return band.skill end
                    break
                end
            end
        end
        -- Mode 状態別の行動（self._mode で sets/weights/skill を切替）
        if byMode ~= nil and self._mode ~= nil then
            local m = byMode[self._mode]
            if m ~= nil then
                if m.skill ~= nil then
                    return m.skill
                elseif m.sets ~= nil then
                    local step = m.sets[self[stepKey]]
                    if step == nil then self[stepKey] = 1; step = m.sets[1] end
                    local index = step[Random.range(0, #step) + 1]
                    self[stepKey] = self[stepKey] + 1
                    if self[stepKey] > #m.sets then self[stepKey] = 1 end
                    return index
                elseif m.weights ~= nil then
                    return Random.sampleWeighted(m.weights)
                end
            end
        end
        -- N回ごとに skill を強制（周期ローテ。残りは下の通常抽選で「強制skill以外」を引く）
        if every ~= nil and every.interval ~= nil and every.skill ~= nil then
            local count = self[everyKey] or 0
            local pos = count % every.interval
            self[everyKey] = count + 1
            local first = every.first ~= false              -- 既定 true（最初に強制）
            local forced = (first and pos == 0) or ((not first) and pos == (every.interval - 1))
            if forced then
                return every.skill
            end
        end
        if sets then
            if self[stepKey] == nil or self[stepKey] > #sets then  -- byMode 切替等で stepKey が範囲外 → 巻き戻し（行動不能を防ぐ）
                self[stepKey] = 1
            end
            local step = sets[self[stepKey]]
            local index = step[Random.range(0, #step) + 1]   -- ステップ内の候補から一様抽選
            self[stepKey] = self[stepKey] + 1
            if self[stepKey] > #sets then
                self[stepKey] = 1                              -- ローテーションを巡回
            end
            return index
        end
        if weights ~= nil then
            return Random.sampleWeighted(weights)             -- 重みは index => weight（キーが数値）
        end
        return 1   -- 抽選ソースに到達できない（byMode のみ構成で未定義 mode へ遷移時等）→ sampleWeighted(nil) クラッシュ回避の既定 index
    end

    -- 実行: index から ActiveSkill を確定（+ 追加処理）
    local function setActive(self, unit, index)
        local skill = index
        if activeSkills ~= nil and activeSkills[index] ~= nil then
            skill = activeSkills[index]
        end
        -- アニメ明示指定があれば上書き（効果スロット index とは独立。takeAttack/takeSkill 既定アニメより優先）
        -- 本体=setNextAnimationName(anim)、エフェクト=setNextAnimationEffectName(animeff or <stage>-<anim>)
        local a = anim ~= nil and anim[index] or nil
        local aeff = animeff ~= nil and animeff[index] or nil
        if aeff == nil and a ~= nil then
            aeff = tostring(unit:getEvolutionStage()) .. '-' .. a   -- 未指定は anim(サフィックス前)から算出
        end
        -- AnimVariant のバリアントサフィックスは **本体アニメだけ**に後置する（エフェクト spine は
        -- バリアントを持たないのが通例。必要なら animeff で明示）。anim 未指定でもバリアント適用中は
        -- C++ 既定名(attack<N>/skill<N>)にはサフィックスが付かないため、ここで組み立てて後置する。
        local suffix = self._animSuffix
        if suffix ~= nil and suffix ~= '' and not (noVariant ~= nil and noVariant[index]) then
            a = (a or (opts.animBase .. tostring(index))) .. suffix
        end
        if a ~= nil then
            unit:setNextAnimationName(a)
        end
        if aeff ~= nil then
            unit:setNextAnimationEffectName(aeff)
        end
        unit:setActiveSkill(skill)
        if opts.onExecute ~= nil then
            opts.onExecute(self, unit, index)
        end
        -- スキル/奥義 使用フック（例: 奥義3/4 使用ごとに全プレイヤーへスタックデバフ）
        if onUse ~= nil and onUse[index] ~= nil then
            Action.runActions(self, { unit = unit, name = 'OnUse', index = index }, onUse[index])
        end
    end

    -- 再生: index を決めた側（ホスト即時 / ゲスト受信時）が呼ぶ
    local function replay(self, index)
        self[decidedKey] = true
        -- カットイン種別: 1回限りの上書き（UseSkill{cutin=}。全端末が各自セット済みの値を消費）が
        -- あれば優先、無ければ index 紐付け（config.cutin。全端末で一致）
        local ct = self[cutinOnceKey]
        if ct ~= nil then
            self[cutinOnceKey] = nil
        else
            ct = cutin ~= nil and cutin[index] or nil
        end
        opts.trigger(self.unit, index, ct)                -- C++ 行動を index 付きで再発火 → pass2 を誘発
    end

    -- イベントハンドラ（pass1 / pass2 兼用）
    local function onEvent(self, event)
        local unit = event.unit
        if self[decidedKey] then
            -- pass2: 決定済み index で実行
            self[decidedKey] = false
            setActive(self, unit, event.index)
            return
        end
        -- pass1: 未決定
        if self.isHostPlayer then
            local index = pickIndex(self)
            self:hostDecide(opts.channel, index)   -- 自分で replay + 全端末へ配信
            event:prevent()                         -- この発火は中断（return 0）
        else
            unit:takeIdle()                          -- ゲストはホスト決定待ち
            event:prevent()
        end
    end

    -- start: インスタンス毎の状態を初期化
    local function onLoad(self, event)
        self[stepKey] = 1
        self[decidedKey] = false
        self[everyKey] = 0
        self[cutinOnceKey] = nil   -- 毎戦闘リセット（リトライで前回の1回限り上書きを持ち越さない。規約 §6-3）
        -- エンジン自動スキル発動を停止（既定0。決定的セットなので host 分岐不要＝各端末で同値）
        local unit = event.unit or self.unit
        if skillInvocationWeight ~= nil then
            unit:setSkillInvocationWeight(skillInvocationWeight)
            self._skillInvocationWeightSet = true   -- 明示指定あり: 他方の Selector の既定0で上書きさせない
        elseif not self._skillInvocationWeightSet then
            unit:setSkillInvocationWeight(0)
        end
    end

    local component = { name = opts.name }

    -- 強制スロットをセットするメソッド（例: self:forceSmash(index, cutinOnce)）。
    -- 次に pickIndex が走ったとき（ホスト）この index が抽選より優先される。
    -- cutinOnce: この強制発動だけのカットイン種別（任意。通常発動の cutin[index] には影響しない）。
    component['force' .. opts.name] = function(self, index, cutinOnce)
        self[forcedKey] = index
        if cutinOnce ~= nil then
            self[cutinOnceKey] = cutinOnce
        end
    end

    function component.initialize(dispatcher)
        -- 同名 Selector(Attack/Smash) の2重 add は状態キー(_<name>Step 等)衝突で破綻する → 早期 assert。
        -- byMode / onUse / every / byHP は1つの Attack/Smash にまとめること。
        local cnt = 0
        for _, n in ipairs(dispatcher.components) do
            if n == opts.name then cnt = cnt + 1 end
        end
        assert(cnt <= 1, 'Choreo: ' .. opts.name .. ' を2回 add しています（byMode/onUse/every は1つにまとめる）')
        if not dispatcher:hasComponent('Sync') then
            dispatcher:add(Sync.create())
        end
        dispatcher:openChannel(opts.channel, replay)
        -- onUse 内の Chance を宣言順(index 昇順=両端末で同一)で静的 pre-open（per-instance/port 決定性）
        if onUse ~= nil then
            local idxs = {}
            for idx in pairs(onUse) do idxs[#idxs + 1] = idx end
            table.sort(idxs)
            for _, idx in ipairs(idxs) do
                Action.preregisterChances(dispatcher, onUse[idx])
            end
        end
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(opts.event, onEvent)
    end

    return component
end

_G.package.loaded[_NAME] = _M
return _M
