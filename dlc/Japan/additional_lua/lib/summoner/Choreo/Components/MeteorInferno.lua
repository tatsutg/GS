------
-- summoner.Choreo.Components.MeteorInferno
--
-- メテオヘイズ種のギミック「炎の場」（インフェルノヴィジョン）: spine イベント skill3_orbit で
-- 炎の場オービット（Lazer）を出し、出ている炎の場の数を数える。炎の場はアニメ末尾の orbitNil で消える。
-- 出典: enemy/600000133.lua（spine 502021160 幻炎竜メテオヘイズ）の run の skill3_orbit / orbitNil。
--
-- ⚠ spine 502021160 の本体 skill3 には当たり判定が無い。インフェルノヴィジョンのダメージ・ブレイクは
--    全部この炎の場が払う（生成時の親の奥義を引き継ぐ）。宣言しないと skill3 はダメージ0。
-- ⚠ 炎の場は本体アニメより長く残る（skill3 4.933秒の 4.667秒目に生成 → skill3_orbit は 10.667秒、
--    skill3_orbit_long は 19.967秒）。奥義の state を抜けた後も当たり続ける。
--    「炎が消えるまで」を撃ち終わりにするなら SkillFinishWatch の hold に _meteorInfernoAlive を渡す。
-- ⚠ orbitNil は炎の場のオービットから届く run イベント（event.unit はボスではなくオービット）。
-- ⚠ オービットの参照は持たない（自然に消えたオービットを Lua から触らないため）。数だけ数える。
--    orbitNil が届かなかったときに数が残り続けないよう、生成から limit 秒で数から外す。
-- ⚠ limit の計時に update を使うため version >= 1.1。
--
-- 設定:
--   anim       string  炎の場のアニメ名（既定 "skill3_orbit"。長い版は "skill3_orbit_long"）
--   event      string  炎の場を出す spine イベント（既定 "skill3_orbit"）
--   endEvent   string  炎の場が消える spine イベント（既定 "orbitNil"）
--   orbitType  number  addOrbitSystem の type（既定 0 = Lazer。アニメを最後まで再生してから消える）
--   limit      number  orbitNil が届かなかったときに数から外すまでの秒数（既定 30）
--
-- 状態（dispatcher フィールド）:
--   _meteorInfernoAlive  number  出ている炎の場の数
--
-- @example
--     boss:add(MeteorInferno{})
--     boss:add(SkillFinishWatch{ onSkill = { 8 }, hold = '_meteorInfernoAlive', onFinish = { SetHP{ 0 } } })
------
local _NAME = 'summoner.Choreo.Components.MeteorInferno'
local _G = _G

local Events = require('summoner.Choreo.Events')

local function MeteorInferno(config)
    config = config or {}
    local anim = config.anim or 'skill3_orbit'
    local spawnEvent = config.event or 'skill3_orbit'
    local endEvent = config.endEvent or 'orbitNil'
    local orbitType = config.orbitType or 0
    local limit = config.limit or 30

    local component = { name = 'MeteorInferno' }

    -- 炎の場ごとの残り秒数（生成順）。数は _meteorInfernoAlive に写す
    local function onLoad(self, event)
        self._meteorInfernoTimers = {}
        self._meteorInfernoAlive = 0
    end

    local function onRun(self, event)
        local timers = self._meteorInfernoTimers
        if event.spineEvent == spawnEvent then
            if self.unit:addOrbitSystem(anim, orbitType) ~= nil then
                timers[#timers + 1] = limit
            end
        elseif event.spineEvent == endEvent then
            -- どの炎の場が消えたかは区別しない。同じアニメなら先に出たものから消える
            if #timers > 0 then
                table.remove(timers, 1)
            end
        else
            return
        end
        self._meteorInfernoAlive = #timers
    end

    local function onUpdate(self, event)
        local timers = self._meteorInfernoTimers
        if #timers == 0 then
            return
        end
        local dt = event.deltaTime or 0
        for i = #timers, 1, -1 do
            timers[i] = timers[i] - dt
            if timers[i] <= 0 then
                table.remove(timers, i)
            end
        end
        self._meteorInfernoAlive = #timers
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnTimeline, onRun)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = MeteorInferno
return MeteorInferno
