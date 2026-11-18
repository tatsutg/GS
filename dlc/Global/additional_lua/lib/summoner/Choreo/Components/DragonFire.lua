------
-- summoner.Choreo.Components.DragonFire
--
-- 竜種の共有ギミック「火球」: spine イベント fire で口のボーンから火球オービットを撃つ。
-- 着弾で終了アニメ（explosion）に切り替わり、そこで消える。
-- 出典: enemy/2004542.lua（樹木マヴロスギア）の fire。マヴロスギア各個体だけでなく
--   デグルマグナ（2034442 等）・フォスラディウス（gb_501601 等）など竜種20体以上が同一実装。
--
-- ⚠ spine 側の前提: 攻撃アニメに runScript-fire（マヴロスギア spine 500155513 は attack1 に有り）。
-- ⚠ ボーン名・発射角は竜ごとに異なりうるので、spine に合わせて bone / neckAngle を指定する。
-- ⚠ 発射角は原作どおり固定値（-neckAngle）。ターゲット方向へは向かない。
--
-- 設定:
--   anim      string  火球オービットのアニメ名（既定 "fireball"）
--   endAnim   string  着弾時のアニメ名（既定 "explosion"）
--   orbitType number  addOrbitSystem の type（既定 1）
--   skill     number  ダメージ計算に使う ActiveSkill 番号（既定 1）
--   hits      number  最大ヒット数（既定 1）
--   bone      string  発射位置に使うボーン名（既定 "EF_fire_mouth"）
--   neckAngle number  発射角（既定 321。setRotation に -neckAngle を渡す）
--
-- @example
--     boss:add(DragonFire{})
--     boss:add(DragonFire{ skill = 1, hits = 1 })
------
local _NAME = 'summoner.Choreo.Components.DragonFire'
local _G = _G

local Events = require('summoner.Choreo.Events')

local function DragonFire(config)
    config = config or {}
    local anim = config.anim or 'fireball'
    local endAnim = config.endAnim or 'explosion'
    local orbitType = config.orbitType or 1
    local skill = config.skill or 1
    local hits = config.hits or 1
    local bone = config.bone or 'EF_fire_mouth'
    local neckAngle = config.neckAngle or 321

    local component = { name = 'DragonFire' }

    local function shoot(self, event)
        local unit = event.unit
        local shot = unit:addOrbitSystem(anim, orbitType)
        shot:setActiveSkill(skill)
        shot:setHitCountMax(hits)
        shot:setEndAnimationName(endAnim)
        local skeleton = unit:getSkeleton()
        shot:setPosition(
            unit:getPositionX() + skeleton:getBoneWorldPositionX(bone),
            unit:getPositionY() + skeleton:getBoneWorldPositionY(bone))
        shot:setRotation(-neckAngle)
        shot:setZOrder(unit:getZOrder() - 1)
    end

    local function onRun(self, event)
        if event.spineEvent == 'fire' then
            shoot(self, event)
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnTimeline, onRun)
    end

    return component
end

_G.package.loaded[_NAME] = DragonFire
return DragonFire
