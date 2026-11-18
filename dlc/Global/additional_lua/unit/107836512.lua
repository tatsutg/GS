local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒_魔王リムル", version=1.3, id=107836512});
class:inheritFromUnit("107837512");

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function class:takeSkill(event)
    return 1
end

class:publish();

return class;