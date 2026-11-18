local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒 遠坂凛＆ルヴィア", version=1.3, id=107767112});

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 107767112,
            BUFF_ID = 17, -- 与ダメージ
            VALUE = 30,
            DURATION = 99999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 286,
                VALUE1 = 7,
                VALUE2 = 0,
                VALUE3 = 1
            },
            GROUP_ID = 3669
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.gameUnit = event.unit
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "shot_red" then
        local orbit = event.unit:addOrbitSystemInsightRotation("shot_red","hit1",1,-60,58,0,0)
        orbit:setDamageRateOffset(1/3)
        orbit:setBreakRate(1/3)
    end

    if event.spineEvent == "shot_yellow" then
        local orbit = event.unit:addOrbitSystemInsightRotation("shot_yellow","hit2",1,-60,58,0,0)
        orbit:setDamageRateOffset(1/3)
        orbit:setBreakRate(1/3)
    end

    if event.spineEvent == "shot_green" then
        local orbit = event.unit:addOrbitSystemInsightRotation("shot_green","hit3",1,-60,58,0,0)
        orbit:setDamageRateOffset(1/3)
        orbit:setBreakRate(1/3)
    end

    if event.spineEvent == "323" and event.unit:getLevel() >= 1  then
        self:teamAddBuff286(event.unit,self.BUFF_BOX_LIST[1])
    end
    return 1
end

function class:teamAddBuff286(unit,buffBox)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff286(myTeamUnit,buffBox)
        end
    end
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    return 1
end

-- バフ処理実行
function class:execAddBuff286(unit,buffBox)
    local countMax = 10
    local buff  = nil;
    local count = 0
    local slotIndex = 40000
    local skill = self.gameUnit:getActiveBattleSkill();
    if skill ~= nil then
        slotIndex = slotIndex + (skill:getIndex() * 10000)
    end
    ---ユニットの位置
    local unitIndex = self.gameUnit:getIndex() * 1000000
    local min = (2861 + slotIndex + unitIndex) * -1
    local max = (2860 + countMax + slotIndex + unitIndex) * -1
    for i = min,max,-1 do
        ---フラグの個数だけカウント
        count = count + 1
        local buff = unit:getTeamUnitCondition():findConditionWithID(i);
        if buff == nil then
            ---フラグ付与
            unit:getTeamUnitCondition():addCondition(i,0,0,99999,0)
            break
        end
    end

    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.VALUE * count then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.VALUE * count then
            return;
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end
    ---番号など
    buff:setMaxConditionIconNumber(countMax);
    buff:setNumber(count);
    buff:setGroupID(buffBox.GROUP_ID);
    local priority = buffBox.VALUE
    if priority < 0 then
        priority = priority * -1
    end
    buff:setPriority(priority * count)
    megast.Battle:getInstance():updateConditionView();

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end
end

class:publish();

return class;