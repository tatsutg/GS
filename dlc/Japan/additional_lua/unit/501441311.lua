local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="モキュオン", version=1.3, id=501441311});
class:inheritFromUnit("unitBossBase");

class.SPEED = 4.5
class.LIMIT_X = 300
class.KAGEN_X = -300
class.ATTACK_INTERVAL = 5
class.MAX_ADD_HASTE_VALUE = 2

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 70,
    ATTACK2 = 30
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
   SKILL2 = 100
} 

class.ACTIVE_SKILLS = {
    ATTACK1 = 0,
    SKILL1 = 1,
    SKILL2 = 2,
    SKILL3 = 3
}

-- 速度上昇(割合)
function class:SETUP_HASTE()
  self.HASTE_LIST = {
    [0] = {
      timing = 10,
      value = 1.2,
      used = false
    },
    [1] = {
      timing = 30,
      value = 1.5,
      used = false
    }
  }
end

function class:setupMessage()


  self.WAVE1_MESSAGE_LIST = {
    [1] = {
      MESSAGE = self.TEXT.WAVE1_MESSAGE1 or "モキュオン:物理ダメージ無効",
      COLOR = Color.yellow,
      DURATION = 5
    },
    [2] = {
      MESSAGE = self.TEXT.WAVE1_MESSAGE2 or "かばうキラー",
      COLOR = Color.yellow,
      DURATION = 5
    },
    [3] = {
      MESSAGE = self.TEXT.WAVE1_MESSAGE3 or "最大ダメージ9999",
      COLOR = Color.yellow,
      DURATION = 5
    }

  }

 self.WAVE2_MESSAGE_LIST = {
    [1] = {
      MESSAGE = self.TEXT.WAVE2_MESSAGE1 or "アルマ:魔法ダメージ無効",
      COLOR = Color.yellow,
      DURATION = 5
    },
    [2] = {
      MESSAGE = self.TEXT.WAVE2_MESSAGE2 or "モキュオン:物理ダメージ無効",
      COLOR = Color.yellow,
      DURATION = 5
    },
    [3] = {
      MESSAGE = self.TEXT.WAVE2_MESSAGE3 or "かばうキラー",
      COLOR = Color.yellow,
      DURATION = 5
    },
    [4] = {
      MESSAGE = self.TEXT.WAVE2_MESSAGE4 or "最大ダメージ9999",
      COLOR = Color.yellow,
      DURATION = 5
    }

  }

end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
  event.unit:getSkeleton():setScale(2.2);
  event.unit:setHPBarHeightOffset(10000);
  event.unit.m_IgnoreHitStopTime = 999999;
  -- event.unit:setSPGainValue(0);
  -- event.unit:setSkillInvocationWeight(0);
  event.unit:setAttackDelay(999999);
  event.unit:setAutoZoder(false);
  event.unit:setLocalZOrder(9000 + event.unit:getIndex());
  
  self.attackTimer = 0
  self.currentTime = 0
  self.posX = 0
  self.movePosX = 0
  self.haste_index = 0
  self.defaultPosX = event.unit:getPositionX()
  self.speed_mod_random = math.random(50) / 10
  self.first = true
  -- self:calcHP(event.unit);
  self:SETUP_HASTE()
  self.spValue = 20
  self.BUFF_BOX_LIST = {
    [1] = {
       ID = 501441311,
       BUFF_ID = 21, -- 物理ダメージ無効
       VALUE = -1000,
       DURATION = 999999,
       ICON = 21,
       SCRIPT = {
        SCRIPT_ID = 4
       }
    }
  }
  self:addBuff(event.unit,self.BUFF_BOX_LIST)
  self:setupMessage()
  return 1
end

-- function class:calcHP(unit)
--   local lv = unit:getLevel();

--   local HP = math.pow(lv,3) * 250 + 10000;
--   unit:setBaseHP(HP);
--   unit:setHP(HP); 
-- end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.unit:getIndex() == self:findUnit(event.unit,40144) then
       if event.waves == 2 then
          self:showMessage(self.WAVE2_MESSAGE_LIST)
       else
          self:showMessage(self.WAVE1_MESSAGE_LIST)
       end
   end
   return 1
end

function class:findUnit(unit,unitID)
   for i = 0, 7 do
      local localUnit = unit:getTeam():getTeamUnit(i)
      if localUnit ~= nil then
        if localUnit:getBaseID3() == unitID then
           return localUnit:getIndex()
        end
     end
  end
end

---------------------------------------------------------------------------------
-- executeAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
  if self:isStop(event.unit) then
    return 0
  end

  event.unit.m_IgnoreHitStopTime = 999999;
  event.unit:takeFront();
  event.unit:setUnitState(kUnitState_none);
  return 0;
end

function class:isStop(unit)
  local stun = unit:getTeamUnitCondition():findConditionValue(89);
  local para = unit:getTeamUnitCondition():findConditionValue(91);
  local freeze = unit:getTeamUnitCondition():findConditionValue(96);

  if stun > 0 or para > 0 or freeze > 0 then
    return true;
  end
  return false
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  event.unit:setLocalZOrder(9000 + event.unit:getIndex());
  event.unit:setSize(3);
  event.unit:getSkeleton():setPosition(0,0);

  --行動不能時はカウントを進めない
  if event.unit:getUnitState() == kUnitState_damage or self:isStop(event.unit) then
    event.unit:setPositionX(self.posX);
    -- self:elapsed(event.unit,event.deltaTime)
    return 1;
  end

  self:attackManager(event)
  self:positionManager(event.unit,event.deltaTime)
  return 1
end

function class:attackManager(event)
  if self.attackTimer < self.ATTACK_INTERVAL then
    self.attackTimer = self.attackTimer + event.deltaTime
  else
    event.unit:takeAttack(1)
    -- event.unit:setActiveSkill(1)
    self.attackTimer = self.attackTimer - self.ATTACK_INTERVAL
  end
end

function class:positionManager(unit,deltaTime)
  --移動の処理
  if self.posX == 0 and self.first then
    self.posX = unit:getPositionX();
    self.first = false
    self.movePosX = 0
  end
  if unit:getUnitState() == kUnitState_none and self.posX < self.LIMIT_X then
    self.posX = self.posX + ((self.SPEED + self.speed_mod_random) * deltaTime);
    self.movePosX = self.posX - self.defaultPosX
  end

  unit:setPositionX(self.posX)
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
  event.unit:setSize(1);
  -- 魔法かつクリティカルだったら多めに後退
  if self:checkDamageAttribute(event.unit,2) and self.posX > self.KAGEN_X then
     if event.unit:getTeamUnitCondition():getDamageAffectInfo().critical then
        self.posX = self.posX - 2.4
      else
        self.posX = self.posX - 2
     end
  end
  return event.value > 9999 and 9999 or event.value;
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
  return event.value + self:correctionAdd(event.unit,self.movePosX)
end

-- とりあえず乗算してみる
function class:correctionPow(unit,value)
   value = self:filter(value)
   local lv = unit:getLevel();
   return math.pow(value,lv/12)
end

class.ADD_LIST = {
  [0] = 0.1,
  [1] = 0.1,
  [2] = 1,
  [3] = 2,
  [4] = 2,
  [5] = 2,
  [6] = 2,
  [7] = 2,
  [8] = 2,
  [9] = 5,
  [10] = 5,
  [11] = 6,
  [12] = 6,
  [13] = 6,
  [14] = 6,
  [15] = 6,
  [16] = 6
}
--加算のパターンを作ってみる
function class:correctionAdd(unit,value)
    value = self:filter(value)
    local lv = unit:getLevel();
    local index = math.ceil(lv / 10)
    return value * self.ADD_LIST[index]
end

-- 共通処理外だし
function class:filter(value)
   if value == 0 then
      value = 1
   elseif value < 0 then
      value = value * -1
   end 
   return value
end
---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
-- function class:takeDamage(event)
--   -- 魔法かつクリティカルだったら多めに後退
--   if self:checkDamageAttribute(event.unit,2) and event.unit:getTeamUnitCondition():getDamageAffectInfo().critical then
--     self.posX = self.posX - 3.6
--   else
--     self.posX = self.posX - 30
--   end
--   return 1
-- end

-- 受けた攻撃の属性をチェック
function class:checkDamageAttribute(unit,attributeIndex)
  if unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute == attributeIndex then
    return true
  end
  return false
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
   if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
      self.attackCheckFlg = true;
      return self:attackReroll(event.unit);
   end
   self.attackCheckFlg = false;
   if not megast.Battle:getInstance():isHost() and not self.fromHost then
      event.unit:takeIdle();
      return 0;
   end

   self.fromHost = false;
   self:attackActiveSkillSetter(event.unit,event.index);
   self:addSP(event.unit);
   return 1
end

function class:attackReroll(unit)
   local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
   local attackIndex = string.gsub(attackStr,"ATTACK","");

   if tonumber(attackIndex) == 1 then
      unit:takeAttack(tonumber(attackIndex));
   else
      self.skillCheckFlg = true;
      unit:takeSkill(1);
      megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
      return 0;
   end
   megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
   return 0;
end

function class:addSP(unit)  
   unit:addSP(self.spValue);
   return 1;
end


---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
   if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
      self.skillCheckFlg = true;
      return self:skillReroll(event.unit);
   end

   if not megast.Battle:getInstance():isHost() and not self.fromHost then
      event.unit:takeIdle();
   return 0;
   end

   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   self:skillActiveSkillSetter(event.unit,event.index);
   return 1
end


function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
   if index == nil then 
      self:showMessageAll(messageBoxList)
   return
   end
   self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
   for i,messageBox in ipairs(messageBoxList) do
      self:execShowMessage(messageBox)
   end
end

function class:showMessageRange(messageBoxList,start,finish)
   for i = start,finish do
      self:execShowMessage(messageBoxList[i])
   end
end

function class:execShowMessage(messageBox)
   if messageBox.isPlayer then
      summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   else
      summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   end
end

--===================================================================================================================
-- バフ関係
--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit,buffBoxList,index)
    if index == nil then 
        self:addBuffAll(unit,buffBoxList)
        return
    end
    self:execAddBuff(unit,buffBoxList[index])
end

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit,buffBoxList,start,finish)
    for i = start,finish do
        self:execAddBuff(unit,buffBoxList[i])
    end
end

function class:addBuffAll(unit,buffBoxList)
   for i,buffBox in ipairs(buffBoxList) do
      self:execAddBuff(unit,buffBox)
   end
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
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
end

class:publish();

return class;