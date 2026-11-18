local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒オーヴェル・D・クランベルジュ", version=2.0, id=104067412});

function class:firstIn(event)
    event.unit:setNextAnimationName("in2")
    event.unit:setNextAnimationEffectName("empty")
    return 0;
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.AURA_INTERVAL = event.unit:getTransEquipmentBaseTime()
    self.WD_FLG = false
    self.WD_Delay = 0.5
    self.WD_Timer = 0
    self.isAura = false
    self.timer = 0
    --event.unit:setUseTransEquipmentExec(true)
    event.unit:setSuperArtsCutInBorder(event.unit:getElementType(),1);
    return 1
end

function class:startWave(event)
    self.AURA_INTERVAL = event.unit:getTransEquipmentBaseTime()
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 5 then
        self.WD_FLG = true
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:auraPosition(event.unit)
    self:auraTimer(event.deltaTime,event.unit)
    if self.WD_FLG then
        self.WD_Timer = self.WD_Timer + event.deltaTime
        if self.WD_Timer > self.WD_Delay then
            self.WD_Timer = 0
            self.WD_FLG = false
            self:setAura(event.unit)
        end
    end
    return 1
end

function class:auraPosition(unit)
    if self.aura == nil then
        return
    end
    local vec = unit:getisPlayer() and 1 or -1
    local targetX = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
    local targetY = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetX,targetY);
    self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
    self.aura:setZOrder(unit:getZOrder() + 1)
end

function class:auraTimer(deltaTime,unit)
    if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if not unit:getIsTransEquipmentNow() then
            self.isAura = false
            self.timer = 0
            if self.aura ~= nil then
                self.aura:takeAnimation(0,"empty",true);
            end
        end
    end
end

function class:setAura(unit)
    self.isAura = true
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"WD_loop",true);
        return
    end
    self.aura = unit:addOrbitSystemWithFile("WD_Auver","WD_loop");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"WD_loop",true);
    self:auraPosition(unit)
end


class:publish();

return class;