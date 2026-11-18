local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="UnitName", version=1.3, id=2000663})
class:inheritFromUnit("unitBossBase")

-- 攻撃パターン ループ
class.ATTACK_WEIGHTS = {
  [0] = "SKILL1",
  [1] = "ATTACK1",
  [2] = "ATTACK1"
}

-- アクティブスキル
class.ACTIVE_SKILL = {
  ATTACK1 = 1,
  SKILL1 = 2,
  SKILL2 = 3,
  SKILL3 = 4
}

class.REDUCE_HIT_STOP = {
  DEFAULT = 0.5,
  HALF = 0.9
}

--メッセージ一覧
class.MESSAGES = {
  MESS1 = {
    MESSAGE = class.TEXT.mess1,
    COLOR = Color.yellow,
    DURATION = 5
  },
  MESS2 = {
    MESSAGE = class.TEXT.mess2,
    COLOR = Color.magenta,
    DURATION = 5    
  },
  MESS3 = {
    MESSAGE = class.TEXT.mess3,
    COLOR = Color.red,
    DURATION = 5 
  },
  MESS4 = {
    MESSAGE = class.TEXT.mess4,
    COLOR = Color.red,
    DURATION = 5
  },
  MESS5 = {
    MESSAGE = class.TEXT.mess5,
    COLOR = Color.red,
    DURATION = 5
  },
  MESS6_1 = {
    MESSAGE = class.TEXT.mess6_1,
    COLOR = Color.red,
    DURATION = 3.2
  },
  MESS6_2 = {
    MESSAGE = class.TEXT.mess6_2,
    COLOR = Color.red,
    DURATION = 3.2
  },
  MESS6_3 = {
    MESSAGE = class.TEXT.mess6_3,
    COLOR = Color.red,
    DURATION = 5
  },
  MESS7 = {
    MESSAGE = class.TEXT.mess7,
    COLOR = Color.red,
    DURATION = 5
  }

}

function class:start(event)
    self.fromHost = false
    self.spValue = 20
    self.attackCheckFlg = false
    self.skillCheckFlg = false
    self.isProsperity = false
    self.attackCount = 0
    self.battleStartTimer = 0
    self.currentTime = 0
    self.currentMessage = 1
    self.protectFlg = false
    self.TEXT_UPDATE_TIME = 3.5
    self.hitStopValue = self.REDUCE_HIT_STOP["DEFAULT"]
    self.thisUnit = event.unit
    self.HP_TRIGGER = {
      [50] = "getHalf",
      [30] = "getRage"
    }
    event.unit:setSkillInvocationWeight(0);
    event.unit:setSPGainValue(0)
    self.gameUnit = event.unit;
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGER) do
        self.hpMarkers[index] = self.gameUnit:addNumHpMarker(index * 0.01)
    end
  return 1
end

function class:startWave(event)
    self:showMassage(self.MESSAGES.MESS1)
    self:showMassage(self.MESSAGES.MESS2)
    self:showMassage(self.MESSAGES.MESS3)
    self:showMassage(self.MESSAGES.MESS4)
    self:showMassage(self.MESSAGES.MESS5)
    return 1
end

function class:showMassage(messages)
    Utility.messageByEnemy(messages.MESSAGE, messages.DURATION, messages.COLOR)
end

function class:update(event)
  self:HPTriggersCheck(event.unit)
  event.unit:setReduceHitStop(2,self.hitStopValue)

  if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
    return 1
  end

  self.battleStartTimer = self.battleStartTimer + event.deltaTime

  for i = 0,3 do
      local uni = megast.Battle:getInstance():getTeam(not event.unit:getisPlayer()):getTeamUnit(i);
      if uni ~= nil then
          if uni:getTeamUnitCondition():findConditionWithType(128) ~= nil and not self.isProsperity then
            event.unit:getTeamUnitCondition():addCondition(2000663,17,100,9999,26)
            self.protectFlg = true
            self.isProsperity = true
          end
      end
  end

  if self.protectFlg and self.battleStartTimer > 3 then
    self.currentTime = self.currentTime + event.deltaTime
    if self.currentTime > self.TEXT_UPDATE_TIME then
      self:showMess6()
    end
  end

  return 1
end

function class:showMess6()
  if self.currentMessage > 3 then
    self.protectFlg = false
    return
  end
  self:showMassage(self.MESSAGES["MESS6_" .. self.currentMessage])
  self.currentMessage = self.currentMessage + 1
  self.currentTime = 0
end

function class:takeDamageValue(event)
  if self:checkCritical(event) then
    return event.value
  end
  return 1
end

function class:checkCritical(event)
  if self.HP_TRIGGER[50] == nil then
    if not event.enemy:getTeamUnitCondition():getDamageAffectInfo().critical then
      return true
    end
  elseif event.enemy:getTeamUnitCondition():getDamageAffectInfo().critical then 
    return true
  end

  return false
end

--===================================================================================================================

function class:attackImpi(unit,attackStr)
  local attackIndex = string.gsub(attackStr,"ATTACK","")
  unit:takeAttack(tonumber(attackIndex))
  return 0
end

function class:skillImpl(unit,skillStr)
  local skillIndex = string.gsub(skillStr,"SKILL","")
  self.skillCheckFlg = true
  unit:takeSkill(tonumber(skillIndex))
  return 0
end

function class:attackBranch(unit)
  local attackStr = self.ATTACK_WEIGHTS[self.attackCount]
  if string.match(attackStr,"ATTACK") then
    self:attackImpi(unit,attackStr)
  elseif string.match(attackStr,"SKILL") then
    self:skillImpl(unit,attackStr)
  end

  self.attackCount = self.attackCount + 1
  if self.attackCount > 1 then
    self.attackCount = 0
  end

  return 0
end

function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true
        return self:attackBranch(event.unit)
    end
    self.attackCheckFlg = false
    self.fromHost = false
    self:addSP(event.unit)
    event.unit:setActiveSkill(self.ACTIVE_SKILL["ATTACK" .. event.index]);
    if event.unit:getBurstPoint() < event.unit:getNeedSP() then
      local localInst = event.unit:addOrbitSystemWithFile("../../effect/itemskill/itemskill2016","attack1")
      -- localInst:setActiveSkill(self.ACTIVE_SKILL["ATTACK" .. event.index]);
    end
    return 1
end

function class:skillBranch(unit)
  local skillIndex = 2
  if self.HP_TRIGGER[30] == nil then
    skillIndex = 3
  end
  unit:takeSkill(tonumber(skillIndex));
  return 0;
end

-- HP30%までは奥義のみ30切ったら真奥義のみ
function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true
        self.attackCount = 0
        return self:skillBranch(event.unit)
    end
    self.skillCheckFlg = false
    event.unit:setActiveSkill(self.ACTIVE_SKILL["SKILL" .. event.index]);
    return 1
end

function class:addSP(unit) 
    unit:addSP(self.spValue)
    return 1
end

--===================================================================================================================

--HPトリガー
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGER) do
        if i >= hpRate and self.HP_TRIGGER[i] ~= nil then
            if self:excuteTrigger(unit,self.HP_TRIGGER[i]) then
                self.HP_TRIGGER[i] = nil;
                if self.hpMarkers[i] ~= nil then
                    self.gameUnit:removeHpMarker(self.hpMarkers[i])
                end
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "getHalf" then
        self.hitStopValue = self.REDUCE_HIT_STOP["HALF"]
        self:showMassage(self.MESSAGES.MESS7  )
        return true;
    end
    if trigger == "getRage" then
        return true;
    end
    return false;
end



function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


--===================================================================================================================

class:publish();

return class;