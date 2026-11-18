local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒アデル", version=2.6, id=102916212});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 102912,
            BUFF_ID = 0,
            VALUE = 1,
            DURATION = 999,
            ICON = 137
        }
    }
end

function class:start(event)
  self.gameUnit = event.unit;
  self:setBuffBoxList()
  self.BASE_HEAL_PROP = 0.05;
  return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.waves == 1 and event.unit:getLevel() >= 70 then
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1]);
    end
    return 1
end

---------------------------------------------------------------------------------
-- changeIn
---------------------------------------------------------------------------------
function class:changeIn(event)
    if event.unit:getLevel() >= 70 then
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1]);
    end
    return 1;
end

--[[
---------------------------------------------------------------------------------
-- avoidDead
---------------------------------------------------------------------------------
function class:avoidDead(event)
    local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
    if buff ~= nil then
        event.unit:getTeamUnitCondition():removeCondition(buff);
    end
    return 1
end
]]--

---ターゲット回復
function class:run(event)
    if event.spineEvent == "takeHeal" then
        if self:isHost() then
            local targetIndex = self:selectTargetUnit(event.unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,targetIndex);
            self:healTarget(event.unit,targetIndex);
        end
    end
    return 1;
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
  local targetUnit = unit:getTeam():getTeamUnit(index);
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

function class:receive1(args)
    self:healTarget(self.gameUnit,args.arg);
    return 1;
end

function class:execAddBuff(unit,buffBox)
    local buff;
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
end

class:publish();

return class;