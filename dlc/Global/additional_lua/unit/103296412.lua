local class = summoner.Bootstrap.createUnitClass({label="ミランダ", version=1.3, id=103296412});

class.BUFF_ID_LIST = {20329500,20329600,20329700}
class.ADD_VALUE = 50
class.ADD_VALUE_FANTASY_EVOLUTION = 100
class.RIVIVE_RATIO = 0.5
class.LEVEL = 80
class.BUFF_BOX = {
    ID = -1,
    BUFF_ID = 17,   -- 魔法ダメージ
    VALUE = 30,
    DURATION = 30,
    ICON = 29,
    SCRIPT = {
        SCRIPT_ID = 5
    }
}
class.RINASCITA_BUFF = {
    ID = 1032964121,
    BUFF_ID = 0, -- 自然蘇生
    VALUE = 0,
    DURATION = 999999,
    ICON = 37
}
class.BARRIER_BUFF_2 = {
    ID = 1032964122,
    BUFF_ID = 98, -- 被ダメ無効
    VALUE = 15000,
    DURATION = 20,
    ICON = 24,
    EFFECT = 1,
    GROUP_ID = 1031,
    PRIORITY = 100
}
class.CHECK_BUFF_2 = {
    ID = 1032964124,
    BUFF_ID = 0, -- 確認用
    VALUE = 0,
    DURATION = 20,
    ICON = 0,
    GROUP_ID = 103296412,
    PRIORITY = 100
}
class.BARRIER_BUFF_3 = {
    ID = 1032964123,
    BUFF_ID = 98, -- 被ダメ無効
    VALUE = 30000,
    DURATION = 30,
    ICON = 24,
    EFFECT = 1,
    GROUP_ID = 1031,
    PRIORITY = 100
}
class.CHECK_BUFF_3 = {
    ID = 1032964125,
    BUFF_ID = 0, -- 確認用
    VALUE = 0,
    DURATION = 30,
    ICON = 0,
    GROUP_ID = 103296412,
    PRIORITY = 100
}

function class:start(event)
    self.gameUnit = event.unit
    if self.gameUnit:getLevel() >= self.LEVEL then
        self:setRinascita(event.unit)
    end
    return 1
end

function class:startWave(event)
    megast.Battle:getInstance():updateConditionView()
    return 1
end

function class:setRinascita(unit)
    local param = unit:getParameter("isRinascita")
    if param == "" or param == "FALSE" then
        unit:setParameter("isRinascita","FALSE")
        self:execAddBuff(unit,self.RINASCITA_BUFF)
    end
end

function class:takeDamageValue(event)
    if event.value >= 1 then
        return self:checkBuff(event.unit,event.value)
    end
    return event.value
end

function class:checkBuff(unit,value)
    local buff = unit:getTeamUnitCondition():findConditionWithID(self.CHECK_BUFF_2.ID)
    local buff2 = unit:getTeamUnitCondition():findConditionWithID(self.CHECK_BUFF_3.ID)
    local allBarrierValue = self:getAllBarrierBuff(unit)
    if buff ~= nil or buff2 ~= nil then
        if value >= allBarrierValue then
            self:removeBarrierBuff(unit)
            self:removeCondition(unit,self.CHECK_BUFF_2.ID)
            self:removeCondition(unit,self.CHECK_BUFF_3.ID)
            if unit:getFantasyEvolutionType() == 4 then
                unit:addSPWithPvpCorrection(self.ADD_VALUE_FANTASY_EVOLUTION)
            else
                unit:addSPWithPvpCorrection(self.ADD_VALUE)
            end
        end
    end
    return value
end

function class:getAllBarrierBuff(unit)
    local val = 0
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end

    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil and cond:getConditionTypeAsInt() == 98 then
            val = val + cond:getValue()
        end
    end

    return val
end

function class:removeBarrierBuff(unit)
    for _,id in pairs(self.BUFF_ID_LIST) do
        for i = 0,6 do
            local target = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i);
            if target ~= nil then
                self:removeCondition(target,id)
            end
        end
    end
end

function class:takeSkill(event)
    if event.index == 2 then
        self:execAddBuff(event.unit,self.BARRIER_BUFF_2);
        self:execAddBuff(event.unit,self.CHECK_BUFF_2)
    end
    if event.index == 3 then
        self:execAddBuff(event.unit,self.BARRIER_BUFF_3);
        self:execAddBuff(event.unit,self.CHECK_BUFF_3)
        for i = 0,6 do
            local target = megast.Battle:getInstance():getTeam(event.unit:getisPlayer()):getTeamUnit(i);
            if target ~= nil then
                self:execAddBuff(target,self.BUFF_BOX);
            end
        end
    end
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

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

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end
end

---- 自然蘇生関係 ----
function class:excuteAction(event)
    return self:checkRinascita(event.unit)
end

function class:run(event)
    if event.spineEvent == "mirandaRinascita" and self.gameUnit:getLevel() >= self.LEVEL then
        self:checkRinascitaTarget(event.unit);
    end
    return 1
end

function class:checkRinascita(unit)
    if unit:getParameter("isRinascita") == "FALSE" and self.gameUnit:getLevel() >= self.LEVEL then
        for i = 0,3 do
            local teamUnit = unit:getTeam():getTeamUnit(i,true);
            if teamUnit ~= nil and teamUnit:getHP() <= 0 and teamUnit ~= unit then
                unit:takeAnimation(0,"rinascita",false);
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
    teamUnit:setHP(targetHP);
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

class:publish();

return class;