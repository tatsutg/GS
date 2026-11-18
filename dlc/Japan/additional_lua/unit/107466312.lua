local class = summoner.Bootstrap.createUnitClass({label="桜ミク", version=1.9, id=107466312});

function class:run(event)
    if event.spineEvent == "BG" then
        local orbit = event.unit:addOrbitSystemWithFile("10746ef","BG")
        orbit:setZOrder(1)
    end
    if event.spineEvent == "skill2" then
        self:checkParty(event.unit)
    end
    if event.spineEvent == "BGM" then
		-- BGM再生
		BattleControl:get():playBGMOneShot("MIKU_SHORT_SENBONZAKURA")
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

function class:start(event)
    self.isSkill3 = false
    return 1
end

function class:update(event)
    if self.isSkill3 then
        event.unit:setReduceHitStop(2,1)
    end
    return 1
end

function class:excuteAction(event)
    self.isSkill3 = false
    return 1
end

function class:takeAttack(event)
    self.isSkill3 = false
    return 1
end

function class:takeSkill(event)
    self.isSkill3 = false
    if event.index == 3 then
        self.isSkill3 = true
    end
    return 1
end


class:publish();

return class;
