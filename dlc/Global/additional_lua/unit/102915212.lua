local class = summoner.Bootstrap.createUnitClass({label="アデル", version=1.3, id=102915212});

class.BUFF_ARGS = {
    {
        ID = 102911,
        EFID = 21,         --ダメージカット
        VALUE = -50,        --効果量
        DURATION = 10,
        ICON = 20,
        EFFECT = 1
    }
}

class.START_BUFF_ARGS = {
    {
        ID = 102912,
        EFID = 0,         --見た目だけ
        VALUE = 1,        --効果量
        DURATION = 999,
        ICON = 137
    }
}

function class:start(event)
  self.gameUnit = event.unit;
  self.BASE_HEAL_PROP = 0.05;
  self.isInit = false;
  return 1;
end

function class:update(event)
  if not self.isInit then
    self.isInit = true;
    if not self:getHealFlag(event.unit) and event.unit:getLevel() >= 70 then
      self:addBuffs(event.unit,self.START_BUFF_ARGS);
    end
  end
  return 1;
end

function class:dead(event)
    if megast.Battle:getInstance():isPvp() and not megast.Battle:getInstance():isPvpHost() then
        self:setHealFlag(event.unit);
    end
    if self:isHost() then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
        self:healAllUnits(event.unit);
    end
    return 1;
end

function class:run(event)
  if event.spineEvent == "takeHeal" then
    if self:isHost() then
      local targetIndex = self:selectTargetUnit(event.unit);
      megast.Battle:getInstance():sendEventToLua(self.scriptID,2,targetIndex);
      self:healTarget(event.unit,targetIndex);
    end
  end 
  return 1;
end

function class:takeSkill(event)
  
  return 1;
end


function class:healAllUnits(unit)
  if self:getHealFlag(unit) or unit:getLevel() < 70 or unit:getHP() > 0 then
    return;
  end
  local buff = unit:getTeamUnitCondition():findConditionWithID(self.START_BUFF_ARGS[1].ID);
  if buff ~= nil then
    unit:getTeamUnitCondition():removeCondition(buff);
  end
  for i = 0,7 do
    local _unit = unit:getTeam():getTeamUnit(i)
    if _unit ~= nil and _unit ~= unit then
      local rate = (100 + _unit:getTeamUnitCondition():findConditionValue(126) 
          + _unit:getTeamUnitCondition():findConditionValue(110))/100
      local rate2 = (100 + unit:getTeamUnitCondition():findConditionValue(115))/100
      self:addBuffs(_unit,self.BUFF_ARGS);
      _unit:takeHeal(_unit:getCalcHPMAX() * rate * rate2,self.gameUnit);
    end
  end
  self:setHealFlag(unit);
end

-- 行き先設定
function class:selectTargetUnit(unit)
  local health = 100
  local currentUnitPosition = 0
  for i = 0,7 do
    local _unit = unit:getTeam():getTeamUnit(i)
    if _unit ~= nil and _unit ~= unit then
      local targetHP = self:currentHP(_unit)
       if health > targetHP then
         health = targetHP
         currentUnitPosition = i
      end
    end
  end

  -- 全員のHPが満タンの時は自分自身を指定する
  if health == 100 then
    currentUnitPosition = unit:getIndex()
  end

  return currentUnitPosition
end

function class:currentHP(unit)
  return (unit:getHP() / unit:getCalcHPMAX()) * 100
end

function class:healTarget(unit,index)
  local targetUnit = unit:getTeam():getTeamUnit(index)

  if targetUnit == nil or targetUnit == unit then
    return;
  end

  local healProp = self.BASE_HEAL_PROP;
  local rate = (100 + targetUnit:getTeamUnitCondition():findConditionValue(126) 
      + targetUnit:getTeamUnitCondition():findConditionValue(110))/100

  if unit:getTeamUnitCondition():findConditionWithID(50223900) ~= nil then
    healProp = healProp + 0.05;
  end
  local rate2 = (100 + unit:getTeamUnitCondition():findConditionValue(115))/100
  local healValue = (targetUnit:getCalcHPMAX() * healProp) * rate * rate2;

  targetUnit:takeHeal(healValue,self.gameUnit);
end

function class:isHost()
    local bool = false
    if megast.Battle:getInstance():isHost() or megast.Battle:getInstance():isPvpHost() then
        bool = true
    end
    return bool
end

function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end


function class:addBuff(unit,args)
    local buff  = nil;
    if args.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
    if args.SCRIPT ~= nil then
        buff:setScriptID(args.SCRIPT);
    end
    if args.SCRIPTVALUE1 ~= nil then
        buff:setValue1(args.SCRIPTVALUE1);
    end

end

function class:setHealFlag(unit)
  unit:setParameter("AdelHealFlg","true"); 
end

function class:getHealFlag(unit)
  local flg = unit:getParameter("AdelHealFlg");
  if flg ~= nil and flg ~= "" and flg ~= "false" then
    return true;
  end
  return false;
end

function class:receive1(args)
  self:healAllUnits(self.gameUnit);
    return 1;
end

function class:receive2(args)
  self:healTarget(self.gameUnit,args.arg);
  return 1;
end

class:publish();

return class;