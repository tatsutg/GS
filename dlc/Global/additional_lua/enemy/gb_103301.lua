local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="GBグロヴォーグ", version=1.3, id="gb_103301"});
class:inheritFromEnemy("gbBossBase");

class.METEOR_POS_LIST = {
    [1] = {
        x = 60,
        y = -20
    },
    [2] = {
        x = -50,
        y = 0
    },
    [3] = {
        x = 50,
        y = 50
    },
    [4] = {
        x = 0,
        y = -40
    },
    [5] = {
        x = -100,
        y = 50
    },
    [6] = {
        x = 100,
        y = -50
    },
    [7] = {
        x = -50,
        y = -50
    },
    [8] = {
        x = 0,
        y = 0
    },
    [9] = {
        x = 0,
        y = 0
    }
}

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    local number = 0
    if string.find(event.spineEvent,"meteorFinal") ~= nil then
        number = 9
    elseif string.find(event.spineEvent,"meteor") ~= nil then
        local strN = string.sub(event.spineEvent,7)
        number = tonumber(strN)
        if number > 0 and number < 10 then
            self:meteor(event.unit,number)
        end
    end
    return 1;
end

function class:meteor(unit,number)
    local meteor = nil
    if number < 9 then
        meteor = unit:addOrbitSystem("Meteor")
    else
        meteor = unit:addOrbitSystem("MeteorFinal");
    end
    local tgt = unit:getTargetUnit();
    if tgt ~= nil then
        local x = self.METEOR_POS_LIST[number].x
        local y = self.METEOR_POS_LIST[number].y
        meteor:setPosition(tgt:getPositionX()+x, tgt:getPositionY()+y);
    end
    return 1;
end

class:publish();

return class;