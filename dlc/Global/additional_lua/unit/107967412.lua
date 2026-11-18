local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒蛇崩乃音", version=1.3, id=107967412});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.skillFlg = false
    self:define()
    return 1
end

function class:define()
    self.skill1SpValue = 20
    self.startDashSpValue = 25
end

function class:checkParameter(unit,paramName)
    return unit:getParameter(paramName) == "TRUE";
end

function class:startDash(unit)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        local paramStr = ""
        paramStr = "796_race_wave"..megast.Battle:getInstance():getWaveNum()
        if myTeamUnit ~= nil then
            if myTeamUnit:getRaceType() == 1 and not self:checkParameter(myTeamUnit,paramStr) then
                myTeamUnit:addSPWithPvpCorrection(self.startDashSpValue);
                myTeamUnit:setParameter(paramStr,"TRUE");
            end
            paramStr = "796_element_wave"..megast.Battle:getInstance():getWaveNum()
            if myTeamUnit:getElementType() == 4 and not self:checkParameter(myTeamUnit,paramStr) then
                myTeamUnit:addSPWithPvpCorrection(self.startDashSpValue);
                myTeamUnit:setParameter(paramStr,"TRUE");
            end
        end
    end
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.skillFlg = false
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        self.skillFlg = true
    else
        self.skillFlg = false
    end
    return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.skillFlg and event.enemy:getIsBoss() then
        self.skillFlg = false
        event.unit:addSPWithPvpCorrection(self.skill1SpValue)
    end
    return event.value
end

class:publish();

return class;