local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="紋章級 グラーシーザ(赤)", version=1.3, id=4002104});
class:inheritFromUnit("501921150");

function class:start2(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        freezeDamageValue = 4.0
    })
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    local freeze = event.unit:getTeamUnitCondition():findConditionValue(96);
    if freeze > 0 then
        event.value = event.value * self.GD.freezeDamageValue
    end
    return event.value
end

class:publish();

return class;