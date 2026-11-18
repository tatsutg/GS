local class = summoner.Bootstrap.createUnitClass({label="ヴィクトワール", version=1.3, id=103096412});

class.DEBUFF = {
    [1] = {
        ID = 103096412,
        BUFF_ID = 28,
        VALUE = -20,
        DURATION = 10,
        ICON = 8
    }
}

class.SP_VALUE = 30;

function class:start(event)
    self.gameUnit = event.unit;
    self.comboCounter = 0;
    return 1;
end

function class:takeSkill(event)
    if event.index == 1 then
        if self.comboCounter % 3 ~= 0 then
            event.unit:setNextAnimationName("skill1_"..(self.comboCounter % 3 + 1));
        end

        self:addPTBuff(event.unit,self.comboCounter + 1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.comboCounter + 1);
        
        if self.comboCounter >= 2 then

            self.comboCounter = 0;
        else
            self.comboCounter = self.comboCounter + 1;
        end
    end
    return 1;
end

function class:addPTBuff(unit,rank)

    for i=0,7 do
        local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
        if uni ~= nil then

            
            if rank >= 3 then
                self:addBuffs(uni,self.DEBUFF);
            end
        end
    end
end

function class:receive1(args)
    self:addPTBuff(self.gameUnit,args.arg);
    return 1;
end

--============================================================================================
--バフかけ周り（テンプレ）
--============================================================================================

function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:execAddBuff(unit,v);
    end
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil then
            if cond:getPriority() > buffBox.PRIORITY then
                return;
            end
            --同一優先度で自分のバフよりも長時間持続するものには手を触れない
            if cond:getPriority() == buffBox.PRIORITY and cond:getTime() > buffBox.DURATION then
                return;
            end
            if buffBox.EXCEPTION == nil or cond:getID() ~= buffBox.EXCEPTION then
                unit:getTeamUnitCondition():removeCondition(cond);
            end
        end
        self:addConditionWithGroup(unit,buffBox);
        return;
    end

    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end
end

--グループIDつきバフ
function class:addConditionWithGroup(unit,buffBox)
  
    local newCond = nil;
    if buffBox.EFFECT ~= nil then
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    newCond:setGroupID(buffBox.GROUP_ID);
    newCond:setPriority(buffBox.PRIORITY);
    if buffBox.SCRIPT ~= nil then
       newCond:setScriptID(buffBox.SCRIPT)
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.NUMBER ~= nil then
        if buffBox.NUMBER >= buffBox.MAX then
            buffBox.NUMBER = 10;
        end
        buff:setNumber(buffBox.NUMBER);
        megast.Battle:getInstance():updateConditionView()
    end
end

class:publish();

return class;