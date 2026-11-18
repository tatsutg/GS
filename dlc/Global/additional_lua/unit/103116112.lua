local class = summoner.Bootstrap.createUnitClass({label="スミレ", version=1.3, id=103116112});


class.BUFF_ARGS = {
    [0] = {
       ID = 103116112,
       BUFF_ID = 32,
       VALUE =1,          --値はめっちゃ書き換える
       DURATION = 9999,
       ICON = 198
   }
}

class.ARTS_BUFF_ARGS = {
    [0] = {
       ID = 1031161121,
       BUFF_ID = 17,
       VALUE =1,          --値はめっちゃ書き換える
       DURATION = 10,
       ICON = 29,
       SCRIPT = 5,
       GROUP_ID = 1008,
       PRIORITY = 1 --優先度もめっちゃ書き換える
   }
}



class.FOX_SOUL_MAX = 10;
class.BUFF_RATE = 5;
class.ARTS_BUFF_RATE = 5;
class.ARTS_BUFF_BASE = 10;
class.TRUE_ARTS_SP_VALUE = 100;
class.SOUL_PAYMENT = 5;

function class:start(event)
  self.gameUnit = event.unit;
  self.buffStage = 0;
  self.foxSoulCount = 0;
    self.gameUnit:setParameter("311_foxSoul",""..self.foxSoulCount)
  self.isCheckBuff = false;
  return 1
end

function class:run(event)
  if event.spineEvent == "addArtsBuff" then
    self:addArtsBuff(event.unit);
  end
  if event.spineEvent == "checkFoxCount" then
    self:addSPAll(event.unit);
  end
  return 1
end

function class:takeSkill(event)
  if event.index == 1 then
    self:addFoxSoul(event.unit);
  end
  return 1;
end

function class:addFoxSoul(unit)
  if self.foxSoulCount < self.FOX_SOUL_MAX then
    self.foxSoulCount = self.foxSoulCount + 1;
      self.gameUnit:setParameter("311_foxSoul",""..self.foxSoulCount)
  end

  if not self:getIsControll(unit) then
    return;
  end

  self:changeFoxSoulCnt(unit,self.foxSoulCount);
  megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.foxSoulCount);
  return 1;
end

function class:changeFoxSoulCnt(unit,cnt)
  if not self.isCheckBuff then
    self:execAddBuff(unit,self.BUFF_ARGS[0]);
    self.isCheckBuff = true;
  end

  self:conditionUpdate(unit,self.BUFF_ARGS[0].ID,cnt);
end


function class:conditionUpdate(unit,id,cnt)
  local condition = unit:getTeamUnitCondition():findConditionWithID(id);

  local value = self.BUFF_RATE * cnt;
  

  if cnt > self.FOX_SOUL_MAX then
      cnt = self.FOX_SOUL_MAX;
  end

  condition:setNumber(cnt);
  condition:setValue(value);

  megast.Battle:getInstance():updateConditionView();
end

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


function class:addArtsBuff(unit)
    if self:getIsControll(unit) then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,self.foxSoulCount);
        self:innerAddArtsBuff(unit,self.foxSoulCount);
    end
end

function class:innerAddArtsBuff(unit,cnt)
  self.ARTS_BUFF_ARGS[0].VALUE = self.ARTS_BUFF_BASE + cnt * self.ARTS_BUFF_RATE;
  self.ARTS_BUFF_ARGS[0].PRIORITY = self.ARTS_BUFF_BASE + cnt * self.ARTS_BUFF_RATE;
    for i = 0,7 do
        local teamUnit = unit:getTeam():getTeamUnit(i);
        if teamUnit ~= nil then
            --バフかけ
            self:addBuffs(teamUnit,self.ARTS_BUFF_ARGS);
        end
    end
end

function class:addSPAll(unit)
  if self:getIsControll(unit) then
    if self.foxSoulCount >= self.FOX_SOUL_MAX then
      
      megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
      self:innerAddSPAll(unit);
      self.foxSoulCount = self.foxSoulCount - self.SOUL_PAYMENT;
        self.gameUnit:setParameter("311_foxSoul",""..self.foxSoulCount)
      self:changeFoxSoulCnt(unit,self.foxSoulCount);
      megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.foxSoulCount);

    end
  end
end

function class:innerAddSPAll(unit)  
    for i = 0,7 do
        local teamUnit = unit:getTeam():getTeamUnit(i);
        if teamUnit ~= nil then
            --バフかけ
            teamUnit:addSPWithPvpCorrection(self.TRUE_ARTS_SP_VALUE);
        end
    end
end



function class:getIsControll(unit)
     return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

function class:receive1(args)
  self.foxSoulCount = args.arg;
    self.gameUnit:setParameter("311_foxSoul",""..self.foxSoulCount)
   self:changeFoxSoulCnt(self.gameUnit,args.arg);
   return 1;
end

function class:receive2(args)
    self:innerAddArtsBuff(self.gameUnit,args.arg);
    return 1;
end

function class:receive3(args)
    self:innerAddSPAll(self.gameUnit);
    return 1;
end


class:publish();

return class;