local Bootstrap = summoner.import("Bootstrap")
local class = Bootstrap.createUnitClass({label="覚醒ゼクシア", version=1.3, id=101276412});

class.SKILL3_DATA = {
    ID = 1012764121,
    BUFF_ID = 10, -- 奥義ゲージ
    VALUE = 5,
    DURATION = 25,
    ICON = 36,
    GROUP_ID = 1034,
    PRIORITY = 0
}
class.SKILL3_DATA.PRIORITY = class.SKILL3_DATA.VALUE*class.SKILL3_DATA.DURATION

function class:takeSkill(event)
    if event.index == 3 then
        local unit = event.unit
        local data = self.SKILL3_DATA
        local oldBuff = unit:getTeamUnitCondition():findConditionWithGroupID(data.GROUP_ID)
        if oldBuff == nil or data.PRIORITY >= oldBuff:getPriority() then
            if oldBuff ~= nil then
                unit:getTeamUnitCondition():removeCondition(oldBuff)
            end
            local newBuff = unit:getTeamUnitCondition():addCondition(data.ID, data.BUFF_ID, data.VALUE, data.DURATION, data.ICON)
            newBuff:setGroupID(data.GROUP_ID)
            newBuff:setPriority(data.PRIORITY)
        end
    end
    return 1
end

class:publish()
return class
