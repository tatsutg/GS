local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="プリズマイリヤ２後編_EX1_水着イリヤ", version=2.0, id=2060060});
class:inheritFromEnemy("2060065");


function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "せーの、海だーーーッッ！！", COLOR = Color.cyan})
    }
    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "来た来たキターッ！　夏休みだー！", COLOR = Color.cyan})
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "わーい、ばいおれんす…", COLOR = Color.cyan})
    }
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_orbit_skill5" then
        event.unit:addOrbitSystem("orbit_skill5",0)
    end
    return 1
end


class:publish();

return class;