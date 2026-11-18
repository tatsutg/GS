local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ポーラ", version=2.6, id=101246312});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self:setAnimationName();
    return 1
end

function class:setAnimationName()
    self.animationName = "2_attack_1_TAMA";
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "shot" then
        self:shot(event.unit)
    end
    return 1
end

function class:shot(unit)
    print("玉打ちますよ");
    local shot = unit:addOrbitSystemInsightRotation(self.animationName,"empty",1,-150,0,180,0);
    shot:setDamageRateOffset(3.21)
    return 1
end

---------------------------------------------------------------------------------
-- runAddOrbitSystem
---------------------------------------------------------------------------------
function class:runAddOrbitSystem(event)
    if event.animation == " bg" then
        event.orbit:setOrbitType(4)
    end
    return 1
end

class:publish();

return class;