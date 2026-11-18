local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="GB雷弓士ファル", version=1.3, id="gb_101301"});
class:inheritFromEnemy("gbBossBase");

class.ARROW_POS_LIST = {
    [1] = {
        x = 50,
        y = 0
    },
    [2] = {
        x = 200,
        y = -90
    },
    [3] = {
        x = -100,
        y = 90
    },
    [4] = {
        x = -250,
        y = -120
    },
    [5] = {
        x = 250,
        y = 0
    },
    [6] = {
        x = -10,
        y = 0
    }
}

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    local number = 0
    if string.find(event.spineEvent,"ExecutionEx") ~= nil then
        local strN = string.sub(event.spineEvent,12)
        --summoner.Utility.messageByEnemy("EX"..strN)
        number = tonumber(strN)
        number = number + 4
    elseif string.find(event.spineEvent,"Execution") ~= nil then
        local strN = string.sub(event.spineEvent,10)
        --summoner.Utility.messageByEnemy(strN)
        number = tonumber(strN)
        if number > 4 then
            return 1;
        end
    end
    if number > 0 and number < 7 then
        self:arrow(event.unit,number)
    end
    return 1;
end

function class:arrow(unit,number)
    local arrow = unit:addOrbitSystem("HevnPanish")
    local x = self.ARROW_POS_LIST[number].x
    local y = self.ARROW_POS_LIST[number].y
    arrow:setPosition(x,y);
    arrow:setDamageRateOffset(1/4);
    arrow:setBreakRate(1/4);
    return 1;
end

class:publish();

return class;