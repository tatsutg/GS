--@additionalEnemy,4000743,4000746
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="UnitName", version=1.7, id=4000747});
class:inheritFromUnit("unitBossBase")

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 50,
    SKILL2 = 50
}

class.ACTIVE_SKILLS = {
  ATTACK1 = 1,
  ATTACK2 = 2,
  ATTACK3 = 3,
  ATTACK4 = 4,
  ATTACK5 = 5,
  SKILL1 = 6,
  SKILL2 = 7,
  SKILL3 = 3
}

-- wave1 ガウル
class.SUMMON_GAURU_01 = 4000743
-- wave2 ガウル
class.SUMMON_GAURU_02 = 4000746
-- コロック
class.SUMMON_02 = 4000744
-- ガウルの沸きスパン(秒)
class.SPAN_INTERVAL = 10
-- ヒットストップ
class.HITSTOP = 1

function class:setMessageBoxList()
  self.MESSAGE_BOX_LIST = {
    [0] = {
      MESSAGE = self.TEXT.START_MESSAGE1 or "ブレイク耐性",
      COLOR = Color.red,
      DURATION = 5
    },
    [1] = {
      MESSAGE = self.TEXT.START_MESSAGE2 or "毒状態以外ダメージ無効",
      COLOR = Color.red,
      DURATION = 5
    },
    [2] = {
      MESSAGE = self.TEXT.START_MESSAGE3 or "水属性キラー",
      COLOR = Color.red,
      DURATION = 5
    }
  }
end
---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
  self.fromHost = false;
  self.gameUnit = nil;
  self.spValue = 20;
  self.attackCheckFlg = false;
  self.skillCheckFlg = false;
  self.skillCheckFlg2 = false;
  self.gameUnit = event.unit
  self.isCoroSummoned = false
  event.unit:setSkin("normal")

  self.currentTime = 0
  self.count = 1
  self.hpMarkers = {
    [50] = self.gameUnit:addNumHpMarker(0.5)
  }
  self.HP_TRIGGERS = {
    [50] = "HP_FLG_50"
  }
  self:setMessageBoxList()
  return 1
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:startWave(event)
  self:showMessage(self.MESSAGE_BOX_LIST)
  return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  event.unit:setReduceHitStop(2,self.HITSTOP)
  self:HPTriggersCheck(event.unit)
  self:summonCheck(event.unit,event.deltaTime)
  return 1
end

-- 10秒ごとにガウル召喚・ブレイク時にコログラン召喚
function class:summonCheck(unit,deltaTime)
  if not self:getIsHost() then
      return
  end
  self:dogManager(unit,deltaTime)
  self:coroManager(unit)
end

-- ガウル召喚判定
function class:dogManager(unit,deltaTime)
    self.currentTime = self.currentTime + deltaTime
    if self.currentTime > self.SPAN_INTERVAL then
      self:summon(unit,self.SUMMON_GAURU_01)
      self:summon(unit,self.SUMMON_GAURU_02)
      self.currentTime = 0
    end
end

-- コログラン召喚判定
function class:coroManager(unit)
  if unit:getBreakPoint() > 0 and self.isCoroSummoned then
    self.isCoroSummoned = false
    return
  end
  if unit:getBreakPoint() <= 0 and not self.isCoroSummoned then
    self:summon(unit,self.SUMMON_02)
    self.isCoroSummoned = true
  end
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
  self:creanUpEnemy(event.unit)
  return 1
end

function class:creanUpEnemy(unit)
  for i = 0, 5 do
    local enemy = unit:getTeam():getTeamUnit(i,true);--無敵や出現中でも殺せるように第二引数はtrue
    if enemy ~= nil then
        enemy:setHP(0);
    end
  end
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
 
  unit:takeAttack(tonumber(attackIndex))
  megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
  return 0;
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

function class:addSP(unit)
  unit:addSP(self.spValue);
  return 1;
end

--===================================================================================================================
-- エネミー召喚
--===================================================================================================================
function class:summon(unit,enemyID)
  local cnt = 0;
  for i = 0, 4 do
    if unit:getTeam():getTeamUnit(i) == nil then
      unit:getTeam():addUnit(i,enemyID);  --指定したインデックスの位置に指定したエネミーIDのユニットを出す
      return i 
    end
  end
end

--===================================================================================================================
-- HPトリガー関係
--===================================================================================================================
function class:HPTriggersCheck(unit)
  if not self:getIsHost() then
    return;
  end

  local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
  for i,v in pairs(self.HP_TRIGGERS) do
    if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
      if self:excuteTrigger(unit,self.HP_TRIGGERS[i]) then
        self.gameUnit:removeHpMarker(self.hpMarkers[i])
          self.HP_TRIGGERS[i] = nil;
      end
    end
  end
end

function class:excuteTrigger(unit,trigger)
  if trigger == "HP_FLG_50" then
    self:hp_50()
    megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0)
  end

  return true
end

function class:hp_50()
  self.gameUnit:setSkin("rage")
end

function class:receive3(args)
  self:hp_50()
  return 1
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
if index == nil then 
  self:showMessageRange(messageBoxList,0,table.maxn(messageBoxList))
  return
end
self:execShowMessage(messageBoxList[index])
end

function class:showMessageRange(messageBoxList,start,finish)
for i = start,finish do
  self:execShowMessage(messageBoxList[i])
end
end

function class:execShowMessage(messageBox)
  summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
end


class:publish();

return class;