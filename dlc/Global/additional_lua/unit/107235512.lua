local class = summoner.Bootstrap.createUnitClass({label="ガロウ", version=1.3, id=107235512});

--人間怪人　バフ内容
class.BUFF_ARGS = {
    [0] = {
       ID = 107236112,
       BUFF_ID = 13,
       VALUE =10,
       DURATION = 9999,
       ICON = 193
   },
   [1] = {
       ID = 1072361122,
       BUFF_ID = 15,
       VALUE =10,
       DURATION = 9999,
       ICON = 0
   }
}

function class:start(event)
  self.offset = 10;
  self.buffStage = 0;
  self.rate = 1.5;
  self.buffUpdateTimer = 1;
  self.isCheckBuff = false;
   return 1
end

function class:startWave(event)
  
   return 1
end

function class:update(event)
  if event.unit:getLevel() >= 70 and not self.isCheckBuff then
    self:execAddBuff(event.unit,self.BUFF_ARGS[0]);
    self:execAddBuff(event.unit,self.BUFF_ARGS[1]);
    self.isCheckBuff = true;
  end
  self.buffUpdateTimer = self.buffUpdateTimer + event.deltaTime;
  if self.buffUpdateTimer > 1 and event.unit:getLevel() >= 70 then
    self.buffUpdateTimer = self.buffUpdateTimer - 1;
    self:conditionUpdate(event.unit,self.BUFF_ARGS[0].ID);
    self:conditionUpdate(event.unit,self.BUFF_ARGS[1].ID);
  end

  return 1;
end

function class:conditionUpdate(unit,id)
  local condition = unit:getTeamUnitCondition():findConditionWithID(id);
  local time = BattleControl:get():getTime();
    if time > 60 then
        time = 60;
    end
    local value = self.offset + self.rate * time;
    local stage = 1 + math.floor(4 * time/60);

    if stage > 5 then
        stage = 5;
    end
    if stage == 5 then
        condition:setNumber(10);
        condition:setValue(100);
    else
        condition:setNumber(stage);
        condition:setValue(math.floor(value));
    end
    
    megast.Battle:getInstance():updateConditionView();
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

class:publish();

return class;