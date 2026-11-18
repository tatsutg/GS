------
-- summoner.Choreo.Components.DragonFirePillar
--
-- 竜種の共有ギミック「火柱」: spine イベント setFire で、ボスの前方5パターンの
-- いずれかに多段ヒットの火柱オービットを設置する。
-- 出典: enemy/2004542.lua（樹木マヴロスギア）の setFire。マヴロスギア各個体のほか
--   竜種20体以上（デグルマグナ・フォスラディウス系など）が同一実装。
--
-- ⚠ spine 側の前提: アニメに runScript-setFire（マヴロスギア spine 500155513 は skill1 に3回）。
-- ⚠ 原作4体はいずれも `if not self.isRage then return end` の直後で isRage が false 固定のため
--    火柱が発生しない状態だった。本 Component はガードを持たず常に発生する。
-- ⚠ 設置位置の抽選は端末ローカル（原作準拠。見た目のばらけのみで当たり判定の位置は各端末同一ではない）。
--
-- 設定:
--   anim      string  火柱オービットのアニメ名（既定 "firePiller"）
--   endAnim   string  終了アニメ名（既定 "fireEnd"）
--   orbitType number  addOrbitSystem の type（既定 2）
--   skill     number  ダメージ計算に使う ActiveSkill 番号（省略時は設定しない＝原作どおり）
--   hits      number  最大ヒット数（既定 999＝多段）
--   spots     table   設置位置の候補 {{x=,y=}, ...}（既定は原作の5パターン）
--   zOffset   number  AutoZOrder 時の ZOrder オフセット（既定 -5000＝背面）
--
-- @example
--     boss:add(DragonFirePillar{})
--     boss:add(DragonFirePillar{ hits = 999, spots = { {x=300,y=0}, {x=600,y=100} } })
------
local _NAME = 'summoner.Choreo.Components.DragonFirePillar'
local _G = _G

local Events = require('summoner.Choreo.Events')

-- 原作 2004542 の math.random(5) 相当（x=300/350/400/500/600 と y のずらし）
local DEFAULT_SPOTS = {
    { x = 300, y = 0 },
    { x = 350, y = -100 },
    { x = 400, y = 50 },
    { x = 500, y = 0 },
    { x = 600, y = 100 },
}

local function DragonFirePillar(config)
    config = config or {}
    local anim = config.anim or 'firePiller'
    local endAnim = config.endAnim or 'fireEnd'
    local orbitType = config.orbitType or 2
    local hits = config.hits or 999
    local spots = config.spots or DEFAULT_SPOTS
    local zOffset = config.zOffset or -5000

    local component = { name = 'DragonFirePillar' }

    local function place(self, event)
        local unit = event.unit
        local shot = unit:addOrbitSystem(anim, orbitType)
        shot:setHitCountMax(hits)
        shot:setEndAnimationName(endAnim)
        if config.skill ~= nil then
            shot:setActiveSkill(config.skill)
        end
        local spot = spots[LuaUtilities.rand(1, #spots)] or spots[1]
        shot:setPosition(unit:getPositionX() + (spot.x or 0), unit:getPositionY() + (spot.y or 0))
        shot:setAutoZOrder(true)
        shot:setZOderOffset(zOffset)
    end

    local function onRun(self, event)
        if event.spineEvent == 'setFire' then
            place(self, event)
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnTimeline, onRun)
    end

    return component
end

_G.package.loaded[_NAME] = DragonFirePillar
return DragonFirePillar
