local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="まどマギコラボ_鹿目まどか", version=2.5, id=108287412});
--class:inheritFromUnit("000");

class.RIVIVE_RATIO = 1.0
class.RIVIVE_ADDSP = 200
class.RINASCITA_BUFF = {
    ID = 10828741201,
    BUFF_ID = 0, -- 自然蘇生
    VALUE = 0,
    DURATION = 999999,
    ICON = 37
}

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self:setRinascita(event.unit)
    return 1
end

---- 自然蘇生関係 ----
function class:setRinascita(unit)
    local param = unit:getParameter("isRinascita")
    if param == "" or param == "FALSE" then
        unit:setParameter("isRinascita","FALSE")
        self:execAddBuff(unit,self.RINASCITA_BUFF)
    end
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    megast.Battle:getInstance():updateConditionView()
    return 1
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    return 1
end

---------------------------------------------------------------------------------
-- excuteAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    return self:checkRinascita(event.unit)
end

function class:checkRinascita(unit)
    if unit:getParameter("isRinascita") == "FALSE" then
        for i = 0,3 do
            local teamUnit = unit:getTeam():getTeamUnit(i,true);
            if teamUnit ~= nil and teamUnit:getHP() <= 0 and teamUnit ~= unit then
                unit:takeAnimation(0,"cast",false);
                self:checkRinascitaTarget(unit);
                unit:setUnitState(kUnitState_skill);
                unit:setBurstState(kBurstState_active);
                return 0;
            end
        end
    end
    return 1;
end

function class:checkRinascitaTarget(unit)
    if not self:getIsControll(unit) then
        return;
    end
    if unit:getParameter("isRinascita") == "FALSE" then
        for i = 0,3 do
            local teamUnit = unit:getTeam():getTeamUnit(i,true);
            if teamUnit ~= nil and teamUnit:getHP() <= 0 and teamUnit ~= unit then
                self:excuteRinascita(unit,teamUnit:getIndex());
                megast.Battle:getInstance():sendEventToLua(self.scriptID,2,teamUnit:getIndex());
                return;
            end
        end
    end
end

function class:excuteRinascita(unit,index)
    local teamUnit = unit:getTeam():getTeamUnit(index,true);
    if teamUnit == nil then return end

    unit:setParameter("isRinascita","TRUE")
    self:removeCondition(unit,self.RINASCITA_BUFF.ID)
    if not self:getIsControll(teamUnit) and not megast.Battle:getInstance():isPvp() then
        return;
    end
    unit:getTeam():reviveUnit(teamUnit:getIndex())
    local targetHP = teamUnit:getCalcHPMAX() * self.RIVIVE_RATIO >= 1 and teamUnit:getCalcHPMAX() * self.RIVIVE_RATIO or 1;
    teamUnit:setReviveHP(targetHP);
    teamUnit:addSPWithPvpCorrection(self.RIVIVE_ADDSP);
end

function class:getIsControll(unit)
    return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

-- バフ削除
function class:removeCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
        unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
    end
end

function class:receive2(args)
    self:excuteRinascita(self.gameUnit,args.arg);
    return 1;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    return 1
end


---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    return 1
end


---------------------------------------------------------------------------------
-- takeBreake
---------------------------------------------------------------------------------
function class:takeBreake(event)
    return 1
end


---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    --if event.spineEvent == "Library_skill3" then
    --    event.unit:addOrbitSystem("ex",0);
    --end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > buffBox.MAX then
                count = buffBox.MAX
            end
        end
    end

    ---グループID関係1
    local targetCond = nil
    if buffBox.GROUP_ID ~= nil then
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getGroupID() == buffBox.GROUP_ID and not cond:getIsPassive() then
                    targetCond = cond
                end
            end
            ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
            if targetCond ~= nil then
                if targetCond:getPriority() <= buffBox.PRIORITY then
                    ---アビリティではない同グループID、優先度が自身以下のバフを見つけた場合
                    unit:getTeamUnitCondition():removeCondition(targetCond)
                else
                    ---アビリティではない同グループID、優先度が自身以上のバフを見つけた場合
                    return
                end
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    ---グループID関係2
    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
    return buff
end

---状態異常監視
function class:findBuff(unit)
    local buffFlg = false
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                buffFlg = true
                return buffFlg
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1
            if count > 100 then
                break
            end
        end
    end
    return buffFlg
end

class:publish();

return class;