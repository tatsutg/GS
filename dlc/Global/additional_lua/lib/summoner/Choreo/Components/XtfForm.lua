------
-- summoner.Choreo.Components.XtfForm
--
-- CODE XTF 系の形態: 盾モード／攻撃モードと属性色で、再生するアニメ名を切り替える。
--   1. モード別の基本アニメ: takeIdle / takeBack / takeDamage / takeOut で再生する名前、待機中のエフェクト、
--      セットアップアニメ（本体／エフェクト）を、今のモードの表から当てる。
--   2. 切替演出: モードが変わった次の行動の頭で、切替アニメ（本体 enter／エフェクト enterEffect）を流し、
--      ポップテキストを出して、その行動を取り消す。切替アニメの再生が終わると C++ が次の行動へ進む。
--      セットアップアニメは切替アニメを流した後に新しいモードのものへ替える（次の再生から効く）。
--   3. 属性色: 色が付いている間は、色違いのあるアニメ（colored / coloredEffects に並べた名前）に
--      接頭辞（既定 zclone<色>）を付ける。通常攻撃・奥義は行動の成立時（@commit）に本体・エフェクトの名前へ付ける。
-- モードは Choreo 共通の self._mode（Mode / SetMode / Attack・Smash の byMode / Defense の mode と同じもの）。
-- Mode を宣言していなければ initial（既定 "shield"）から始まり、SetMode アクションで切り替わる。
-- 色は SetXtfColor アクションで切り替える（色名。"none" / false で色なし）。
-- 出典: unit/500161013.lua の takeIdle / takeBack / takeDamage / excuteAction（モード切替）/
--   takeAttack・takeSkill（zclone<色> の付け方）/ startWave（setUpBarrier）/ receive3。
--
-- ⚠ takeOut を使うため boss version >= 2.3。
-- ⚠ modes の名前・colored / coloredEffects は spine に実在する名前にする（無い名前は再生が完了せず行動が止まりうる）。
--    既定値は spine 500161013（本体）/ 50016ef（エフェクト）の実在名。
-- ⚠ 通常攻撃・奥義のローテはモードでは切り替わらない。Attack / Smash の byMode（shield / attack）で書く。
-- ⚠ AnimVariant と併用しない（同じ生イベントで名前を当て合い、後から宣言した方が勝つ）。
-- ⚠ 弾（オービット）から来る生イベントは無視する（ボス本体のときだけ名前を当てる）。
--
-- 設定:
--   initial        string  Mode を宣言していないときの初期モード（既定 "shield"）
--   lock           string  形態をこのモードに固定する（modes にあるモード名）。self._mode を見ないので、
--                          ボス側の Mode（通常／待機 など）を形態と関係なく使える。切替演出もしない
--                          （XtfTransform で lock 先を変えたときだけ変形する）。
--                          XtfFunnel の summonMode / saberMode もこのモードで判定する
--   entry          string  登場時の見た目のモード（modes にあるモード名）。開幕はこのモードのセットアップを当て、
--                          今のモード（lock / Mode）と違えば最初の行動の頭で切替アニメを流して変形する。
--                          spine の登場アニメ in は盾モードの見た目で終わるので、攻撃モードで始めるボスは entry = "shield" にすると
--                          パッと切り替わらずに barrier_off で変形する（既定なし＝開幕は今のモードのセットアップを演出なしで当てる）
--   modes          table   モード名 => { idle, back, damage, out, outEffect, effectIdle, setup, setupEffect,
--                          enter, enterEffect, pop, popKey }。既定は shield / attack（DEFAULT_MODES）。
--                          書いたキーだけ既定を上書きする。false はそのモードではその処理をしない
--                            idle / back / damage / out  takeIdle / takeBack / takeDamage / takeOut で再生する本体アニメ
--                            outEffect                  takeOut で再生するエフェクト（既定なし＝C++ の既定 "out"）
--                            effectIdle                 待機中に流すエフェクト（ループ）
--                            setup / setupEffect        セットアップアニメ（本体 / エフェクト。"" で通常のセットアップに戻す）
--                            enter / enterEffect        そのモードへ切り替わるときの切替アニメ（本体 / エフェクト）
--                            pop / popKey               切替時のポップテキスト。popKey はユニット文言（textUnit）のキーで、
--                                                       無ければ pop の文字列。pop = false で出さない
--   colors         table   色名 => 接頭辞（既定 red / blue / green / light / dark => zclone<色>）
--   colored        table   色違いがある本体アニメ名の一覧
--   coloredEffects table   色違いがあるエフェクトアニメ名の一覧
--   initialColor   string  開幕の色（既定なし＝色なし）
--   textUnit       number  ポップテキストを引くユニット文言の unit_id（既定 500161013）
--
-- Action: SetXtfColor（属性色）／XtfTransform（形態を変え、変形を終えてから actions を実行。下の定義を参照）
--
-- @example
--     boss:add(XtfForm{})                                              -- 盾モードから。SetMode{"attack"} で攻撃モードへ
--     boss:add(XtfForm{ modes = { attack = { idle = "idle3" } } })      -- 攻撃モードの待機だけ差し替え
--     boss:add(XtfForm{ lock = "attack" })                              -- 常に攻撃モード（Mode は別の用途に使える）
--     boss:add(XtfForm{ lock = "attack", entry = "shield" })            -- 盾の見た目で登場し、最初の行動の頭で変形して攻撃モード
--     -- HP50% で攻撃モードへ変形してから奥義9（グラバト EX 型）:
--     boss:add(Phases{ { at = 50, actions = { XtfTransform{ "attack", actions = { UseSkill{ index = 9 } } } } } })
--     boss:add(Attack{ byMode = { shield = { sets = { {1}, {2}, {3} } }, attack = { sets = { {4}, {5}, {6} } } },
--                      onUse = { [3] = { SetXtfColor{ "red" }, SetMode{ "attack" } } } })
------
local _NAME = 'summoner.Choreo.Components.XtfForm'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')
local Mode = require('summoner.Choreo.Components.Mode')

-- モード別の基本アニメ（spine 500161013 / 50016ef の実在名）
local DEFAULT_MODES = {
    shield = {
        idle = 'idle', back = 'back1', damage = 'damage_B', out = 'out', effectIdle = 'idle1',
        setup = 'setUp1', setupEffect = 'setUpBarrier', enter = 'barrier_in', enterEffect = 'barrier_in',
        pop = 'バリアモード', popKey = 'text2',
    },
    attack = {
        idle = 'idle2', back = 'back2', damage = 'damage_S', out = 'out2', effectIdle = false,
        setup = 'setUp2', setupEffect = '', enter = 'barrier_off', enterEffect = 'barrier_off',
        pop = '攻撃モード', popKey = 'text1',
    },
}

local DEFAULT_COLORS = {
    red = 'zclonered', blue = 'zcloneblue', green = 'zclonegreen', light = 'zclonelight', dark = 'zclonedark',
}

-- 色違い（zclone<色>）がある本体アニメ。skill3 / out / out2 / in / idle3 等には色違いが無い
local DEFAULT_COLORED = {
    'attack1', 'attack2', 'attack3', 'attack3break', 'attack4', 'attack5', 'attack6',
    'back1', 'back2', 'barrier_in', 'barrier_off', 'break', 'break2', 'damage_B', 'damage_S',
    'idle', 'idle2', 'skill1', 'skill2', 'skill4', 'skill5',
}

-- 色違いがあるエフェクトアニメ。1-attack4/5/6 や 1-skill3 には色違いが無い
local DEFAULT_COLORED_EFFECTS = {
    '1-attack1', '1-attack3', '1-skill1', '1-skill2', '1-skill4', '1-skill5', '1-skill6',
    'barrier_damage', 'barrier_in', 'barrier_off', 'idle1',
}

local function toSet(list)
    local set = {}
    for _, name in ipairs(list) do
        set[name] = true
    end
    return set
end

-- 既定の表に、書いたキーだけを重ねる（モード名ごと。新しいモード名も足せる）
local function mergeModes(user)
    assert(user == nil or type(user) == 'table', 'Choreo.XtfForm: modes はモード名 => 表 のテーブル')
    local merged = {}
    for name, t in pairs(DEFAULT_MODES) do
        local m = {}
        for k, v in pairs(t) do
            m[k] = v
        end
        merged[name] = m
    end
    for name, t in pairs(user or {}) do
        assert(type(t) == 'table', 'Choreo.XtfForm: modes.' .. tostring(name) .. ' はテーブル')
        local m = merged[name] or {}
        for k, v in pairs(t) do
            m[k] = v
        end
        merged[name] = m
    end
    return merged
end

-- false はその処理をしない
local function value(v)
    if v == false then
        return nil
    end
    return v
end

local makeXtfForm

local XtfForm = setmetatable({}, {
    __call = function(_, config) return makeXtfForm(config) end
})

function makeXtfForm(config)
    config = config or {}
    local initial = config.initial or 'shield'
    local modes = mergeModes(config.modes)
    local colors = config.colors or DEFAULT_COLORS
    local colored = toSet(config.colored or DEFAULT_COLORED)
    local coloredEffects = toSet(config.coloredEffects or DEFAULT_COLORED_EFFECTS)
    local initialColor = config.initialColor
    assert(initialColor == nil or initialColor == false or colors[initialColor] ~= nil,
        'Choreo.XtfForm: initialColor は colors にある色名')
    local lock = config.lock
    assert(lock == nil or (type(lock) == 'string' and modes[lock] ~= nil),
        'Choreo.XtfForm: lock は modes にあるモード名（既定は shield / attack）')
    local entry = config.entry
    assert(entry == nil or (type(entry) == 'string' and modes[entry] ~= nil),
        'Choreo.XtfForm: entry は modes にあるモード名（既定は shield / attack）')
    local textUnit = config.textUnit or 500161013

    local component = { name = 'XtfForm' }

    local function prefix(self)
        local c = self._xtfColor
        if c == nil then
            return nil
        end
        return colors[c]
    end

    local function bodyName(self, base)
        local p = prefix(self)
        if p ~= nil and colored[base] then
            return p .. base
        end
        return base
    end

    local function effectName(self, base)
        local p = prefix(self)
        if p ~= nil and coloredEffects[base] then
            return p .. base
        end
        return base
    end

    -- 名前を当てるときのモード: 切替演出を済ませたモード（演出前は前のモードのまま）。開幕前は lock / 今のモード
    local function formMode(self)
        return self._xtfFormMode or self._xtfFormLock or self._mode or initial
    end

    local function popText(self, m)
        if m.pop == false then
            return nil
        end
        local key = m.popKey
        if key ~= nil then
            if self.TEXT ~= nil and self.TEXT[key] ~= nil then
                return self.TEXT[key]
            end
            local texts = summoner ~= nil and summoner.Text ~= nil and summoner.Text:fetchByUnitID(textUnit) or nil
            if texts ~= nil and texts[key] ~= nil then
                return texts[key]
            end
        end
        return m.pop
    end

    local function applySetup(unit, m)
        local s = value(m.setup)
        if s ~= nil then
            unit:setSetupAnimationName(s)
        end
        local se = value(m.setupEffect)
        if se ~= nil then
            unit:setSetupAnimationNameEffect(se)
        end
    end

    -- モードの反映。初回（開幕）は登場時の見た目（entry。無ければ今のモード）のセットアップだけ当てる。
    -- 行動の頭（canTransition）でモードが変わっていたら切替アニメを流してセットアップを替え、
    -- 切替アニメを流したら true を返す（その行動を取り消す）。entry と今のモードが違えば最初の行動の頭で変形する
    local function syncMode(self, unit, canTransition)
        local mode = self._xtfFormLock or self._mode or initial
        if self._xtfFormMode == nil then
            local start = entry or mode
            self._xtfFormMode = start
            applySetup(unit, modes[start] or {})
        end
        if self._xtfFormMode == mode or not canTransition then
            return false
        end
        self._xtfFormMode = mode
        local m = modes[mode] or {}
        local enter = value(m.enter)
        if enter ~= nil then
            enter = bodyName(self, enter)
            unit:takeAnimation(0, enter, false)
            self._xtfFormAnim = enter
        end
        local enterEffect = value(m.enterEffect)
        if enterEffect ~= nil then
            unit:takeAnimationEffect(0, effectName(self, enterEffect), false)
        end
        local text = popText(self, m)
        if text ~= nil then
            unit:showPopText(text)
        end
        applySetup(unit, m)
        return enter ~= nil
    end

    -- ボス本体の生イベントだけ扱う（弾から来た生イベントは無視）
    local function bossOf(self, event)
        local unit = self.unit
        if unit == nil or unit == false then
            return nil
        end
        if event.unit ~= nil and event.unit ~= unit then
            return nil
        end
        return unit
    end

    local function onLoad(self, event)
        if initialColor == false then
            self._xtfColor = nil
        else
            self._xtfColor = initialColor
        end
        self._xtfFormMode = nil
        self._xtfFormAnim = nil
        self._xtfFormLock = lock          -- XtfFunnel の summonMode / saberMode もこれで判定する（XtfTransform で変わる）
        self._xtfFormAfter = nil          -- XtfTransform の予約（変形を終えた次の行動の頭で actions）
        if lock == nil and self._mode == nil then
            self._mode = initial
        end
    end

    local function onIdle(self, event)
        local unit = bossOf(self, event)
        if unit == nil then
            return
        end
        syncMode(self, unit, false)
        local m = modes[formMode(self)] or {}
        local idle = value(m.idle)
        if idle ~= nil then
            idle = bodyName(self, idle)
            unit:setNextAnimationName(idle)
            self._xtfFormAnim = idle
        end
        local eff = value(m.effectIdle)
        if eff ~= nil then
            unit:takeAnimationEffect(0, effectName(self, eff), true)
        end
    end

    -- takeBack / takeDamage / takeOut: 今のモードの名前（色違いがあれば色付き）を次に再生させる
    local function replacer(key)
        return function(self, event)
            local unit = bossOf(self, event)
            if unit == nil then
                return
            end
            local m = modes[formMode(self)] or {}
            local name = value(m[key])
            if name ~= nil then
                name = bodyName(self, name)
                unit:setNextAnimationName(name)
                self._xtfFormAnim = name
            end
            if key == 'out' then
                local oe = value(m.outEffect)
                if oe ~= nil then
                    unit:setNextAnimationEffectName(effectName(self, oe))
                end
            end
        end
    end

    -- 通常攻撃・奥義の成立時: Attack / Smash が決めた名前に色の接頭辞を付ける
    local function onCommit(self, event)
        local unit = bossOf(self, event)
        if unit == nil then
            return
        end
        local name = unit:getNextAnimationName()
        local p = prefix(self)
        if p ~= nil then
            if colored[name] then
                name = p .. name
                unit:setNextAnimationName(name)
            end
            local eff = unit:getNextAnimationEffectName()
            if coloredEffects[eff] then
                unit:setNextAnimationEffectName(p .. eff)
            end
        end
        self._xtfFormAnim = name
    end

    -- XtfTransform の予約を実行し、攻撃後の待ちを消す（gb_901070012 の excuteAction と同じ）
    local function runAfter(self, unit, after, event)
        self._xtfFormAfter = nil
        if after.actions ~= nil then
            Action.runActions(self, after.event or event, after.actions)
            unit:setAttackTimer(0)
        end
    end

    local function onExecute(self, event)
        local unit = bossOf(self, event)
        if unit == nil then
            return
        end
        local after = self._xtfFormAfter
        if after ~= nil and after.entered then
            runAfter(self, unit, after, event)   -- 変形（切替アニメ）を終えた次の行動の頭
            return
        end
        if syncMode(self, unit, true) then
            if after ~= nil then
                after.entered = true             -- 切替アニメを流した。終わった次の行動の頭で actions
            end
            event:prevent()
            return
        end
        if after ~= nil then
            runAfter(self, unit, after, event)   -- 切替アニメが無い（enter = false）か、すでにそのモード
        end
    end

    function component.initialize(dispatcher)
        local declared = 0
        for _, name in ipairs(dispatcher.components) do
            if name == 'XtfForm' then
                declared = declared + 1
            end
        end
        assert(declared <= 1, 'Choreo: XtfForm が2回宣言されています。'
            .. 'KindSeeker と併用するなら KindSeeker{ form = {...} } で設定してください')
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.takeIdle, onIdle)
        dispatcher:addEventListener(Events.takeBack, replacer('back'))
        dispatcher:addEventListener(Events.takeDamage, replacer('damage'))
        dispatcher:addEventListener(Events.takeOut, replacer('out'))
        dispatcher:addEventListener(Events.OnAttackCommit, onCommit)
        dispatcher:addEventListener(Events.OnSmashCommit, onCommit)
        dispatcher:addEventListener(Events.excuteAction, onExecute)
    end

    return component
end

------
-- SetXtfColor Action: 属性色を切り替える
--   色名（位置引数。XtfForm の colors のキー）。"none" / false で色なし。colors に無い名前は色なしと同じ見た目になる
--   element  number  指定するとボスの奥義カウンターの色とボスの属性も変える（setBossCounterElement。1炎 2水 3樹 4光 5闇 0無）
-- 決定的な処理なので同期しない（全端末で走る文脈から呼ぶ）。新しい色は次に再生するアニメから効く。
------
XtfForm.SetColor = Action.define('SetXtfColor', function(a, d, e)
    local name = a[1]
    if name == false or name == 'none' then
        d._xtfColor = nil
    elseif name ~= nil then
        d._xtfColor = name
    end
    if a.element ~= nil then
        megast.Battle:getInstance():setBossCounterElement(a.element)
    end
end)

------
-- XtfTransform Action: 形態を mode に変え、変形（切替アニメ）を終えてから actions を実行する
--   （グラバト EX の HP50%「攻撃モードへ変形 → 続けて奥義」）
--   mode       string  切り替える先のモード（modes にある名前。位置引数可）
--   actions    list    変形を終えた次の行動の頭で実行する Action（UseSkill 等）。実行したら攻撃後の待ちを消す（setAttackTimer(0)）
--   holdGauge  bool    既定 true。今の奥義ゲージを退避して 0 にし、変形の前に奥義が出ないようにする
--                      （ボスはゲージが満タンだと行動の途中でも奥義を出すため）。退避したゲージは次の奥義を撃ち終えたら戻る
--                      （Smash の keepGauge と同じ仕組み。Smash が無いボスでは何もしない）
-- 出典: enemy/gb_901070012.lua の hp50（hpSkillStart(nil)＝ゲージを退避して0・transformReserve）と excuteAction
--   （次の行動の頭で barrier_off を流して行動を取り消し、終えた次の行動の頭で addSP(100)＋setAttackTimer(0)）。
-- ⚠ XtfForm が必要。lock している場合は lock 先を mode に変える（Mode の状態は変えない）。
--    lock していなければ SetMode と同じ（Mode の onExit / onEnter も走る）。
-- ⚠ actions の UseSkill に keepGauge は書かない（ゲージは holdGauge で退避済み。書くと 0 を退避し直してゲージが消える）。
-- ⚠ 変形は「次の行動の頭」なので、呼んでから変形が始まるまで最大で attack_delay ぶん待つ（原典と同じ）。
-- 全端末で走る文脈（Phases / onUse 等）から呼ぶ。ゲージを 0 にするのはホストだけ（engine が同期する）。
------
XtfForm.Transform = Action.define('XtfTransform', function(a, d, e)
    local mode = a.mode or a[1]
    if a.holdGauge ~= false and d.armSmashGauge ~= nil then
        d:armSmashGauge()                    -- 今のゲージを退避（次の奥義を撃ち終えたら戻る）
        if d.isHostPlayer and d.unit ~= nil then
            d.unit:setBurstPoint(0)          -- 変形の前に奥義が出ないように空にする
        end
    end
    if d._xtfFormLock ~= nil then
        d._xtfFormLock = mode
    else
        Action.runActions(d, e, { Mode.Set{ mode } })
    end
    d._xtfFormAfter = { actions = a.actions, event = e, entered = false }
end)

_G.package.loaded[_NAME] = XtfForm
return XtfForm
