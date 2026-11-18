local class = summoner.Bootstrap.createEnemyClass({label="雑魚モルドーラ", version=1.3, id="mine_1038"});

function class:start(event)
    local floor = megast.Battle:getInstance():getCurrentMineFloor()
    local hp = self:setHp(floor,1)
    event.unit:setBaseHP(hp);
    event.unit:setHP(hp);
    event.unit:setBasePower(148*floor-400);
    event.unit:setBaseDefence(100);
    event.unit:setBaseBreakCapacity(120000)
    event.unit:getSkeleton():setScaleX(1);

    self.BUFF_TABLE =
    {
        U_ID = 10380 + event.unit:getIndex(),
        BUFF_ID = 17, --与ダメUP
        VALUE = 15,
        DURATION = 99999,
        ICON = 26
    }

    self:setBuffs(event.unit,floor)
    self.bossId = self:checkBossID()
    self:findUnit(true,self.bossId)
    return 1
end



function class:setBuffs(unit,floor)
    local buffs = {53,60,102,109}
    for i = 1,4 do
        local BUFF_TABLE = {
            ID = 50131 + i,
            BUFF_ID = buffs[i], --耐性
            VALUE = math.atan(floor*0.013)*2/math.pi*220+6,
            DURATION = 99999,
            ICON = 0
        }
        self:execAddBuff(unit,BUFF_TABLE)
    end
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end
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
    local hp2 = 128*floor-400
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

function class:update(event)
    event.unit:getSkeleton():setScaleX(-1);
    return 1
end

--特定のユニットを探しバフ
function class:findUnitBuff(teamunit,unitID)
    if teamunit:getBaseID3() == unitID then
        teamunit:getTeamUnitCondition():addCondition(self.BUFF_TABLE.U_ID,self.BUFF_TABLE.BUFF_ID,self.BUFF_TABLE.VALUE,self.BUFF_TABLE.DURATION,self.BUFF_TABLE.ICON);
    end
end

function class:takeDamageValue(event)
    if self:isEffect(event.unit) then
        return event.value
    end
    return 0
end

function class:isEffect(unit)
    if unit:getTeamUnitCondition():findConditionWithType(90) ~= nil or unit:getTeamUnitCondition():findConditionWithType(97) ~= nil then
        return true
    end
    return false
end

function class:dead(event)
    self:findUnit(false,self.bossId)
    return 1
end

function class:findUnitBuffOut(unit,unitID)
    if unit:getBaseID3() == unitID then
        local RemoveCon = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_TABLE.U_ID)
        if RemoveCon ~= nil then
            unit:getTeamUnitCondition():removeCondition(RemoveCon)
        end
    end
end



class:publish();

return class;