local class = summoner.Bootstrap.createEnemyClass({label="雑魚ラグベロス", version=1.3, id="mine_1039"});

function class:start(event)
    local floor = megast.Battle:getInstance():getCurrentMineFloor()
    local hp = self:setHp(floor,1)
    event.unit:setBaseHP(hp);
    event.unit:setHP(hp);
    event.unit:setBasePower(128*floor-400);
    event.unit:setBaseDefence(128*floor-400);
    event.unit:setBaseBreakCapacity(120000)

    self.BUFF_TABLE =
    {
        U_ID = 103900 + (event.unit:getIndex() * 10),
        BUFF_ID = 0, --属性耐性
        VALUE = 20,
        DURATION = 99999,
        ICON = 20
    }
    self.elements = {61,62,63,64,65}
    self.bossId = self:checkBossID()
    self:findUnit(true,self.bossId)

    return 1
end

function class:checkBossID()
    for i = 0,6 do
        local teamUnit = megast.Battle:getInstance():getTeam(false):getTeamUnit(i);
        if teamUnit ~= nil and teamUnit:getParameter("type") == "normal" then
            return 40019
        end
    end
    return 40168
end

function class:setHp(floor,threshold)
    local hp =  5000 * (floor ^ 2) + 1500000
    local hp2 = 291400*floor^0.5-60000
    return hp < threshold and hp or hp2
end

function class:findUnit(isAlive,unitId)
    for i = 0,6 do
        local teamUnit = megast.Battle:getInstance():getTeam(false):getTeamUnit(i);
        if teamUnit ~= nil then
            if isAlive then
                self:findUnitBuff(teamUnit,unitId)
            else
                self:findUnitBuffOut(teamUnit,unitId)
            end
        end
    end
end

--特定のユニットを探しバフ
function class:findUnitBuff(teamunit,unitID)
    if teamunit:getBaseID3() == unitID then
        for i = 1,5 do
            teamunit:getTeamUnitCondition():addCondition(self.BUFF_TABLE.U_ID + i,self.elements[i],self.BUFF_TABLE.VALUE,self.BUFF_TABLE.DURATION,i == 1 and self.BUFF_TABLE.ICON or 0);
        end
    end
end

function class:dead(event)
    self:findUnit(false,self.bossId)
    return 1
end

function class:findUnitBuffOut(unit,unitID)
    if unit:getBaseID3() == unitID then
        for i = 1 , 5 do
            local RemoveCon = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_TABLE.U_ID + i)
            if RemoveCon ~= nil then
                unit:getTeamUnitCondition():removeCondition(RemoveCon)
            end
        end
    end
end

class:publish();

return class;