local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ミーナス", version=2.0, id=104076112});
class:inheritFromUnit("104077112");

function class:iconUpdate(unit)
    local count = 0
    count = self:getParamCount(unit,"407_WeaponType4")
    if count < 1 then
        self:execAddBuff(unit,self.BUFF_BOX_LIST[3])
    else
        unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[3].ID)
    end
    count = self:getParamCount(unit,"407_WeaponType3")
    if count < 2 then
        self:execAddBuff(unit,self.BUFF_BOX_LIST[2])
    else
        unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[2].ID)
    end
end

class:publish();

return class;