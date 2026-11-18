local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒軍神フェン", version=1.3, id=103617312});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.abilityTime = 45
    event.unit:setSuperArtsCutInBorder(3,5);
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 103617312,
            BUFF_ID = 21,
            VALUE = -30,
            DURATION = self.abilityTime,
            ICON = 20
        },
        [2] = {
            ID = -103617312,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 5 then
        local buff = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
        buff:setRemoveOnResetState(true);
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getIsLeader() and event.unit:getLevel() >= 100 then
        if BattleControl:get():getTime() < self.abilityTime then
            self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1],true)
        else
            self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1],false)
        end
    end
    return 1
end

function class:teamAddBuff(unit,buffBox,flg)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
            if flg then
                if cond == nil then
                    buffBox.DURATION = self.abilityTime - BattleControl:get():getTime()
                    local buff = self:execAddBuff(myTeamUnit,buffBox)
                    if buff ~= nil then
                        buff:setCaster(unit)
                    end
                end
            else
                if cond ~= nil then
                    myTeamUnit:getTeamUnitCondition():removeConditionWithID(buffBox.ID)
                end
            end
        end
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
    return buff
end

class:publish();

return class;