local class = summoner.Bootstrap.createUnitClass({label="リオン", version=1.3, id=101256412});


class.BUFF_ARGS = {
    [0] = {
       ID = 101254512,
       BUFF_ID = 13,
       VALUE = -10,
       DURATION = 20,
       ICON = 4,
       GROUP_ID = 3235,
       PRIORITY = 10,
       EXCEPTION = 101254513
   },
   [1] = {
       ID = 101254513,
       BUFF_ID = 15,
       VALUE = -10,
       DURATION = 20,
       ICON = 6,
       GROUP_ID = 3235,
       PRIORITY = 10,
       EXCEPTION = 101254512
   }
}

function class:start(event)
   self.isSkill2 = false;
   self.hitList = {};
   self.gameUnit = event.unit;

   return 1
end

function class:takeSkill(event)
   self.isSkill2 = false;
   self.hitList = {};
   if event.index == 2 then
      self.isSkill2 = true;
   end
   return 1;
end

function class:takeAttack(event)
   self.isSkill2 = false;
   self.hitList = {};
   return 1;
end

function class:attackDamageValue(event)
   if not self:isControllTarget(event.unit) then
      return event.value;
   end
   local targetIndex = event.enemy:getIndex();
   if self.isSkill2 and self.hitList[targetIndex] == nil then
      self:debuff(targetIndex);
      self.hitList[targetIndex] = true;
      megast.Battle:getInstance():sendEventToLua(self.scriptID,1,targetIndex);
   end
   return event.value;
end

function class:debuff(index)
   local unit = megast.Battle:getInstance():getTeam(not self.gameUnit:getisPlayer()):getTeamUnit(index);
   if unit ~= nil then
      self:execAddBuff(unit,self.BUFF_ARGS[0]);
      self:execAddBuff(unit,self.BUFF_ARGS[1]);
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
            if cond:getPriority() == buffBox.PRIORITY and cond:getTime() > buffBox.DURATION and not (buffBox.EXCEPTION == nil or cond:getID() ~= buffBox.EXCEPTION) then
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

function class:receive1(args)
   self:debuff(args.arg);
   return 1;
end

function class:isControllTarget(unit)
    if unit:isMyunit() then
        return true;
    end
    if not unit:getisPlayer() then
        return megast.Battle:getInstance():isHost();
    end

end

class:publish();

return class;