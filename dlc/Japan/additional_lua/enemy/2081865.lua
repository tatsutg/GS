local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="EX1_スケルトン", version=2.8, id=2081865});
class:inheritFromEnemy("2081875");


---EX1_竜牙兵の召喚用(2081860.Lua)

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    event.unit:setReduceHitStop(100,1,true);---ヒットストップ無効or時止め無効
    return 1;
end



class:publish();

return class;