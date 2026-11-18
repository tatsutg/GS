local class = summoner.Bootstrap.createUnitClass({label="ミリム", version=1.3, id=107166112});

--真奥義バフ内容
class.BUFF_ARGS = {
    [0] = {
       ID = 107176112,
       BUFF_ID = 22,
       VALUE =100,
       DURATION = 20,
       ICON = 11,
       GROUP_ID = 1024,
       PRIORITY = 100
   }
}

function class:run(event)
   if event.spineEvent == "addBuff" then
      self:execAddBuff(event.unit,self.BUFF_ARGS[0]);
   end
   return 1;
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

function class:attackDamageValue(event)
    local myTeam = megast.Battle:getInstance():getTeam(false);
    if megast.Battle:getInstance():isPvp() then
        local cond = event.unit:getTeamUnitCondition():findConditionWithType(84);
        if cond ~= nil then
            if event.enemy:getHP() < 1 then
                event.enemy:setHP(1)
            end
            --enemy:setInvincibleTime(0.5)
            local hp = event.enemy:getHP() - event.value
            if hp < 1 then
                event.value = event.enemy:getHP() - 1
            end
        end
    end
    return event.value;
end

class:publish();

return class;