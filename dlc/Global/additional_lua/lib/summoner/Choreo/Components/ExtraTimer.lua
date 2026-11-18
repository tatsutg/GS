------
-- summoner.Choreo.Components.ExtraTimer
--
-- engine の ExtraTimer（Battle 側の可視タイマー）を宣言的に扱うマネージャ Component と Action 群。
-- 一定間隔アクション（extraTimerOneRound）＋速度制御（停止/遅延/加速）を提供する。
--
-- ⚠ extraTimerOneRound イベントを使うため boss の version は 2.5 以上が必要（[01]）。
--
-- 構成:
--   - ExtraTimer()        … マネージャ（key→index 管理 + extraTimerOneRound ルーティング）。1度 add する。
--   - ExtraTimer{spec}     … マネージャ + start で1本 auto 生成（常駐タイマー向け）
--   - Action: ExtraTimer.Create / .Remove / .SetSpeed … 任意のトリガーから動的制御（複数/登場/消滅）
--
-- @example
--     boss:add(ExtraTimer())                                  -- マネージャだけ（動的生成は Action で）
--     boss:add(Phases{ { at=50, actions = {
--         ExtraTimer.Create{ key="A", maxTime=30, loopLimit=3, icon={12,0},
--                            slot=1, of=2, onRound = { SpawnOrbit{...} } },
--         ExtraTimer.Create{ key="B", maxTime=30, loopLimit=3, icon={13,0}, slot=2, of=2 },
--     } } })
--     -- 状態異常で停止 / 解除で再開（任意トリガーから）
--     ExtraTimer.SetSpeed{ key="A", speed=0 }               -- 0=停止 / <1=遅延 / 1=通常 / >1=加速（恒久）
--     ExtraTimer.SetSpeed{ key="A", speed=0.5, duration=2 } -- 2秒間だけ 1/2（経過後に自動復帰）
--     ExtraTimer.Remove{ key="A" }
--
-- speedRules（状態連動速度。spec に指定すると update で自動制御・解除で自動復帰）:
--     boss:add(ExtraTimer{ key="power", maxTime=15, loopLimit=999,
--         onRound = { StackBuff{ id=X, type=13, value=20, icon=4 } },
--         speedRules = {                                     -- 上から評価・最初にマッチした speed（既定1）
--             { when = { invincible = true }, speed = 0 },   -- 無敵中は停止
--             { when = { breaking = true },   speed = 0 },   -- ブレイク中は停止（isBreak）
--             { when = { smashing = true },   speed = 0 },   -- 奥義中は停止（getUnitState==kUnitState_skill）
--             { when = { status = {89,91,96} }, speed = 0 }, -- 気絶/麻痺/氷結中は停止（いずれか）
--             { when = { status = {90} }, speed = 0.333 },   -- 毒中は 1/3
--         } })
--     出典: 実ボス慣用（2000694: update で isBreak をエッジ検出し setExtraTimerSpeed stop/start /
--           2004556 extraTimerOperation2: 状態異常・奥義中(kUnitState_skill)・ブレイク中・無敵中で速度を切替）。
--     when の複数キーは AND、status はリストのいずれか。speed の適用は変化時のみ（毎フレーム再設定しない）。
--     ⚠ speedRules は update を使う（version は ExtraTimer 自体が 2.5 以上なので追加要件なし）。
--
-- 時限オーバーライド（duration 付き SetSpeed）と speedRules の合成:
--     実効速度 = 「speedRules の結果」と「時限オーバーライド」の**遅い方**（min）。
--     → 遅延中にブレイク/奥義が入れば停止(0)が勝ち、明けたら遅延の残り時間に戻る。
--     残り時間は**実時間**で減る（停止中も減る。出典 2004556 の decelerationMaxTime は update で無条件加算）。
--     同じ key への再適用は**残り時間の上書き**（重複しない＝出典 2004556 の decelerationMaxTime=0 リセット）。
--     @example 被クリティカルで2秒間 1/2（重複なし・再クリで2秒に上書き）
--         boss:add(OnTakeCritical{ actions = { ExtraTimer.SetSpeed{ key="T", speed=0.5, duration=2 } } })
--
-- 位置（β: 総数指定で中央寄せ）:
--     pos = {x,y}            … 個別指定（最優先・getDefaultPosition からのオフセット）
--     slot=k, of=N           … N本中 k本目を中央寄せ配置: x = (k-(N+1)/2)*spacing, y=spec.y
--     spacing                … 既定 100（2本なら ±50 = 実ボス慣用）
------
local _NAME = 'summoner.Choreo.Components.ExtraTimer'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

------
-- 位置計算（β: 総数指定で中央寄せ / pos 個別指定が最優先）
------
local function computePos(spec)
    if spec.pos ~= nil then
        return spec.pos[1] or spec.pos.x or 0, spec.pos[2] or spec.pos.y or 0
    end
    local spacing = spec.spacing or 100
    local slot = spec.slot or 1
    local of = spec.of or 1
    local x = (slot - (of + 1) / 2) * spacing
    return x, spec.y or 0
end

------
-- dispatcher に合流するメソッド群（self = dispatcher インスタンス）
------
local function ensureState(self)
    self._extraTimers = self._extraTimers or {}
    return self._extraTimers
end

local function extraTimerCreate(self, spec)
    local timers = ensureState(self)
    local x, y = computePos(spec)
    local icon = spec.icon or {}
    local index = megast.Battle:getInstance():createExtraTimer(
        spec.maxTime or 30, spec.loopLimit or 1,
        icon[1] or 0, icon[2] or 0, x, y, spec.scale or 1)
    timers[spec.key] = { index = index, onRound = spec.onRound, speedRules = spec.speedRules }
    return index
end

local function extraTimerRemove(self, key, opts)
    local timers = ensureState(self)
    local t = timers[key]
    if t == nil then return end
    opts = opts or {}
    local fade = opts.fadeTime or 0.25
    local delay = opts.delayTime or 0
    local anim = opts.isAnimation ~= false
    megast.Battle:getInstance():removeExtraTimer(t.index, fade, delay, anim)
    timers[key] = nil
end

------
-- speedRules の評価（when の複数キーは AND・status はいずれか1つで真）
------
local function ruleMatches(unit, when)
    if when.invincible ~= nil and (((unit:getInvincibleTime() or 0) > 0) ~= when.invincible) then
        return false
    end
    if when.breaking ~= nil and (unit:isBreak() ~= when.breaking) then
        return false
    end
    -- 奥義中（出典 2004556 extraTimerOperation2:「奥義中か確認」= getUnitState() == kUnitState_skill）
    if when.smashing ~= nil and ((unit:getUnitState() == kUnitState_skill) ~= when.smashing) then
        return false
    end
    if when.status ~= nil then
        local cond = unit:getTeamUnitCondition()
        local hit = false
        for i = 1, #when.status do
            if cond:findConditionWithType(when.status[i]) ~= nil then
                hit = true
                break
            end
        end
        if not hit then return false end
    end
    return true
end

------
-- 実効速度の決定: 恒久速度（speedRules の結果 / 無ければ baseSpeed・既定1）と
-- 時限オーバーライド（duration 付き SetSpeed）の**遅い方**（min）。
-- → 遅延中でもブレイク/奥義中の停止(0)が勝ち、明けたら遅延の残りに戻る。
------
local function desiredSpeed(t, unit)
    local base = t.baseSpeed or 1
    if t.speedRules ~= nil and unit ~= nil then
        base = 1
        for i = 1, #t.speedRules do
            local r = t.speedRules[i]
            if ruleMatches(unit, r.when or {}) then
                base = r.speed or 1
                break
            end
        end
    end
    if t.tempLeft ~= nil and t.tempLeft > 0 then
        local temp = t.tempSpeed or 1
        if temp < base then return temp end
    end
    return base
end

------
-- engine へ反映（変化時のみ。出典 2004556「経過時間速度がセット内容と異なったら更新する」＝毎フレーム set しない）
------
local function syncSpeed(t, unit)
    local speed = desiredSpeed(t, unit)
    if t._speed ~= speed then
        t._speed = speed
        megast.Battle:getInstance():setExtraTimerSpeed(t.index, speed)
    end
end

------
-- 速度セット。duration 省略=恒久 / duration 指定=その秒数だけのオーバーライド。
-- 同じ key への再適用は残り時間の上書き（重複しない。出典 2004556 の decelerationMaxTime=0 リセット）。
------
local function extraTimerSpeed(self, key, speed, duration, unit)
    local timers = ensureState(self)
    local t = timers[key]
    if t == nil then return end
    speed = speed or 0
    if duration ~= nil and duration > 0 then
        t.tempSpeed = speed
        t.tempLeft = duration
    else
        t.baseSpeed = speed
    end
    syncSpeed(t, unit)
end

------
-- ExtraTimer 本体: 呼び出し可能なテーブル（ExtraTimer() でマネージャ生成 / .Create 等の Action も保持）
------
local makeManager   -- 前方宣言（下で定義）

local ExtraTimer = setmetatable({}, {
    __call = function(_, autoSpec) return makeManager(autoSpec) end
})

------
-- マネージャ Component（任意で start に1本 auto 生成する spec を受ける）
------
function makeManager(autoSpec)
    local component = { name = 'ExtraTimer' }
    component.extraTimerCreate = extraTimerCreate
    component.extraTimerRemove = extraTimerRemove
    component.extraTimerSpeed = extraTimerSpeed

    -- extraTimerOneRound を key の onRound へルーティング
    local function onRound(self, event)
        local timers = ensureState(self)
        for _, t in pairs(timers) do
            if t.index == event.index and t.onRound ~= nil then
                Action.runActions(self, event, t.onRound)
            end
        end
        -- 戻り値は event.count（RETURNS_VALUE で count。generate が返す）
    end

    local function onLoad(self, event)
        self._extraTimers = {}   -- 毎戦闘リセット（リトライ/2戦目で前回の key→index 残留＝誤ルーティングを防ぐ。規約 §6-3）
        ensureState(self)
        -- マネージャ専用の ExtraTimer{} は autoSpec={}(空) で来る。空テーブルを auto生成しようとすると
        -- spec.key=nil で timers[nil] が「table index is nil」になるため、中身のある spec のみ auto生成する。
        if autoSpec ~= nil and next(autoSpec) ~= nil then
            self:extraTimerCreate(autoSpec)
        end
    end

    -- speedRules: 状態（無敵/ブレイク/奥義中/状態異常）から速度を再計算し、変化時のみ setExtraTimerSpeed。
    -- 時限オーバーライド（duration 付き SetSpeed）の残り時間もここで実時間で減らし、切れたら復帰する。
    -- 状態は engine が同期するため全クライアントで同じ速度に収束する（2000694 同様 host 分岐なし）。
    local function onUpdate(self, event)
        local timers = self._extraTimers
        if timers == nil then return end
        local unit = event.unit or self.unit
        local deltaTime = event.deltaTime or 0
        for _, t in pairs(timers) do
            if t.tempLeft ~= nil then
                t.tempLeft = t.tempLeft - deltaTime
                if t.tempLeft <= 0 then
                    t.tempLeft = nil     -- 期限切れ → 恒久速度（speedRules / baseSpeed）へ復帰
                    t.tempSpeed = nil
                end
            end
            -- 速度を管理する対象＝ルール持ち / 時限中 / 一度でも速度を設定した（切れた直後の復帰を含む）タイマー。
            -- どれでもないタイマーには一切 engine を触らない（従来どおり）。
            if t.speedRules ~= nil or t.tempLeft ~= nil or t._speed ~= nil then
                syncSpeed(t, unit)
            end
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.extraTimerOneRound, onRound)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

------
-- Action 群（任意のトリガーから動的制御）。マネージャの methods を呼ぶ。
------
ExtraTimer.Create = Action.define('CreateExtraTimer', function(a, d, e)
    extraTimerCreate(d, a)
end)

ExtraTimer.Remove = Action.define('RemoveExtraTimer', function(a, d, e)
    extraTimerRemove(d, a.key, a)
end)

-- speed: 0=停止 / <1=遅延 / 1=通常 / >1=加速。duration 指定でその秒数だけ（重複せず残り時間を上書き）。
ExtraTimer.SetSpeed = Action.define('SetExtraTimerSpeed', function(a, d, e)
    extraTimerSpeed(d, a.key, a.speed or a[1], a.duration, (e ~= nil and e.unit) or d.unit)
end)

_G.package.loaded[_NAME] = ExtraTimer
return ExtraTimer
