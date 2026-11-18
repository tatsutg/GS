local class = summoner.Bootstrap.createUnitClass({label="ベル", version=1.3, id=102695312});

--真奥義バフ内容
class.BUFF_ARGS = {
    [0] = {
       ID = 1026953121,
       BUFF_ID = 103,
       VALUE =80,
       DURATION = 15,
       ICON = 60,
       GROUP_ID = 3072,
       PRIORITY = 80
   },
   [1] = {
       ID = 1026953122,
       BUFF_ID = 54,
       VALUE =80,
       DURATION = 15,
       ICON = 0,
       GROUP_ID = 3072,
       PRIORITY = 80,
       EXCEPTION = 1026953121 --例外的にこのIDのバフとは重複関係を持たない
   }
}


function class:run(event)
   if event.spineEvent == "addBuff" then
      for i = 0,7 do
         local teamUnit = event.unit:getTeam():getTeamUnit(i)
         if teamUnit ~= nil then
            self:execAddBuff(teamUnit,self.BUFF_ARGS[0]);
            self:execAddBuff(teamUnit,self.BUFF_ARGS[1]);
         end
      end
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

class:publish();

return class;