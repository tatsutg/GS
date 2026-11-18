local class = summoner.Bootstrap.createUnitClass({label="ヴァイド", version=1.3, id=100636312});


class.BUFF_ARGS = {
    [0] = {
       ID = 100636312,
       BUFF_ID = 21,
       VALUE = 10,
       DURATION = 9,
       ICON = 185,
       SCRIPT = 2,
       GROUP_ID = 2067,
       PRIORITY = 10
   }
}

function class:start(event)
   self.isSkill1 = false;
   self.hitList = {};
   self.gameUnit = event.unit;

   return 1
end

function class:takeSkill(event)
   self.isSkill1 = false;
   self.hitList = {};
   if event.index == 1 then
      self.isSkill1 = true;
   end
   return 1;
end

function class:takeAttack(event)
   self.isSkill1 = false;
   self.hitList = {};
   return 1;
end

function class:attackDamageValue(event)
   if not self:isControllTarget(event.unit) then
      return event.value;
   end
   local targetIndex = event.enemy:getIndex();
   if self.isSkill1 and self.hitList[targetIndex] == nil then
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
        unit:getTeamUnitCondition():removeCondition(cond);
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