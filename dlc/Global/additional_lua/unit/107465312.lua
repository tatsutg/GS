local class = summoner.Bootstrap.createUnitClass({label="桜ミク", version=1.9, id=107465312});

function class:takeSkill(event)
    if event.index == 2 then
        self:checkParty(event.unit)
    end
    return 1
end

function class:checkParty(unit)
    for i = 0,6 do
        local teamUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i)
        if teamUnit ~= nil then
            if self:checkCondition(teamUnit) then
                teamUnit:addSPWithPvpCorrection(50)
            end
        end
    end
end

function class:checkCondition(unit)
    local isChecked = false
    local buffList = {[93] = 1,[94] = 1,[96] = 1}
    local removeBuffList = {}

    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then
        return false
    end

    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if buffList[cond:getConditionTypeAsInt()] == 1 then
            table.insert(removeBuffList,cond)
        end
    end
    for _,cond in ipairs(removeBuffList) do
        isChecked = true
        unit:getTeamUnitCondition():removeCondition(cond)
    end
    return isChecked
end

class:publish();

return class;
