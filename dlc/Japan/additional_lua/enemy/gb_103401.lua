local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="GB暗黒魔導オグナード", version=1.3, id="gb_103401"});
class:inheritFromEnemy("gbBossBase");

---------------------------------------------------------------------------------
-- GB_start
---------------------------------------------------------------------------------
function class:GB_start(event)
    self.orbitNames = { magic = "3skill2magic", sword = "3skill2sword", attackStart = "3attack1sword", attackFinish = "3attack1explode" }
    -- 敵座標キャッシュ用テーブル
    self.targetUnitPos = { x = nil, y = nil }
    return;
end

function class:swordAttack(unit)
    local orbit = unit:addOrbitSystem(self.orbitNames.attackStart, 1)
    orbit:setHitCountMax(1)
    orbit:setEndAnimationName(self.orbitNames.attackFinish)
    local posX = unit:getPositionX()
    local posY = unit:getPositionY()
    orbit:setPosition(posX, posY)
    return 1;
end

function class:addOrbit(unit, orbitName)
    local addObj = nil
    local setZOrder = 0

    if orbitName == self.orbitNames.magic then
        addObj = unit:addOrbitSystem(self.orbitNames.magic, 0)
        setZOrder = -1
    elseif orbitName == self.orbitNames.sword then
        addObj = unit:addOrbitSystem(self.orbitNames.sword, 0)
        setZOrder = 1
    end

    local targetUnit = unit:getTargetUnit()

    if targetUnit ~= nil  and addObj ~= nil then
        local tagetUnitZOrder = targetUnit:getZOrder()
        local inited = self.targetUnitPos.x or self.targetUnitPos.y or false
        if inited == false then
            local targetPosX = targetUnit:getPositionX()
            local targetPosY = targetUnit:getPositionY()
            self.targetUnitPos.x = targetPosX
            self.targetUnitPos.y = targetPosY
        end
        addObj.autoZorder = false
        addObj:setZOrder(tagetUnitZOrder + setZOrder)
        addObj:setPosition(self.targetUnitPos.x, self.targetUnitPos.y)
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    local  arg = nil
    arg = string.match(event.spineEvent, "addOrbit(%w+)")
    if arg ~= nil then
        return  self:addOrbit(event.unit, arg)
    end
    arg = string.match(event.spineEvent, "swordAttack")
    if arg ~= nil then
        return self:swordAttack(event.unit)
    end
    return 1;
end

---------------------------------------------------------------------------------
-- GB_takeSkill
---------------------------------------------------------------------------------
function class:GB_takeSkill(event)
    if event.index == 2 then
        self.targetUnitPos.x = nil
        self.targetUnitPos.y = nil
    end
    return;
end

class:publish();

return class;