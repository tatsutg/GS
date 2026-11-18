local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="狐タマエ", version=1.8, id=2016231})
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50
}

class.ATTACK_WEIGHTS_NORMAL = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50
}

class.ATTACK_WEIGHTS_RAGE = {
    ATTACK5 = 50,
    ATTACK6 = 50,
    ATTACK7 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100,
    SKILL4 = 100
}

class.SKILL_WEIGHTS_NORMAL = {
    SKILL2 = 100,
    SKILL4 = 100
}

class.SKILL_WEIGHTS_RAGE = {
    SKILL3 = 100,
    SKILL5 = 100
}

class.ACTIVE_SKILLS = {
  ATTACK1 = 1,
  ATTACK2 = 2,
  ATTACK3 = 3,
  ATTACK4 = 4,
  ATTACK5 = 5,
  ATTACK6 = 6,
  ATTACK7 = 7,
  SKILL1 = 8,
  SKILL2 = 9,
  SKILL3 = 10, -- 怒り時スキル２
  SKILL4 = 11,
  SKILL5 = 12 -- 怒り時スキル３
}
class.FINAL_SKILL2 = 13
class.FINAL_SKILL3 = 14

function class:setTriggerList()
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp75(status) end,
         HP = 75,
         used = false
      },
      [2] = {
         tag = "HP_FLG",
         action = function (status) self:hp50(status) end,
         HP = 50,
         used = false
      },
      [3] = {
         tag = "HP_FLG",
         action = function (status) self:hp25(status) end,
         HP = 25,
         used = false
      },
      [4] = {
         tag = "HP_FLG",
         action = function (status) self:hp10(status) end,
         HP = 10,
         used = false
      }      
   }

    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            --self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

function class:hp75(status)
   if status ==  "use3" then
      self.hitStop = 1
   end
end

function class:hp50(status)
   if status ==  "use3" then
    -- self.gameUnit:setInvincibleTime(6)
    self:showMessage(self.HP50_MESSAGE_LIST)
    self:addBuff(self.gameUnit,self.HP50_BUFF_BOX)
   end
end

function class:hp25(status)
   if status ==  "use3" then
    self.isFury = true
    self:showMessage(self.HP25_MESSAGE_LIST)
    self:addBuff(self.gameUnit,self.HP25_BUFF_BOX)
   end
end

function class:hp10(status)
   if status ==  "use3" then
    self.isFinal = true
    self.gameUnit:addSP(100)
    self:showMessage(self.HP10_MESSAGE_LIST)
    self:addBuff(self.gameUnit,self.HP10_BUFF_BOX)
   end
end

function class:change()
   if self.isAwaken then self:awaken() else self:normal() end
   self.gameUnit:takeGrayScale(0.01)
   self.isNega = true
   self.negaTimer = 0

   for i = 0,3 do
      local u = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
       if u ~= nil then
          u:takeGrayScale(0.01)
       end 
   end
end

function class:awaken()
   self.isAwakened = true
   self.gameUnit:setSkin("rage")
   self.ATTACK_WEIGHTS = self.ATTACK_WEIGHTS_RAGE
   self.SKILL_WEIGHTS = self.SKILL_WEIGHTS_RAGE
   megast.Battle:getInstance():setBackGroundColor(9999,241,35,177);

   megast.Battle:getInstance():setBossCounterElement(5);
   self.gameUnit:setElementType(5);
end

function class:normal()
   self.isAwakened = false
   self.gameUnit:setSkin("normal")
   self.ATTACK_WEIGHTS = self.ATTACK_WEIGHTS_NORMAL
   self.SKILL_WEIGHTS = self.SKILL_WEIGHTS_NORMAL
   megast.Battle:getInstance():setBackGroundColor(9999,255,255,255);

   megast.Battle:getInstance():setBossCounterElement(1);
   self.gameUnit:setElementType(1);
end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "ブレイクで攻撃属性切替　炎⇔闇",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "攻撃力・命中率アップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      }
   }

   self.HP75_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP75_MESSAGE1 or "行動速度アップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      }
   }

   self.HP50_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "行動速度アップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      }
   }

   self.HP25_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP25_MESSAGE1 or "与ダメージアップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      }
   }
   
   self.HP10_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP10_MESSAGE1 or "仮置:吾は滅びぬ！ 何度でも蘇るさ！",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      }
   }

end

--------[[バフ]]--------
function class:setBuffBoxList()
   self.HP50_BUFF_BOX = {
    [1] = {
      ID = 5213132,
      BUFF_ID = 28, -- 行動速度
      VALUE = 50,
      DURATION = 999999,
      ICON = 7
    }
  }

   self.HP25_BUFF_BOX = {
    [1] = {
      ID = 5213133,
      BUFF_ID = 17, -- ダメージ
      VALUE = 30,
      DURATION = 999999,
      ICON = 26
    }
  }
   self.HP10_BUFF_BOX = {
    [1] = {
      ID = 5213134,
      BUFF_ID = 21, -- ダメージ軽減
      VALUE = -100,
      DURATION = 999999,
      ICON = 20
    }
  }
end


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.fromHost = false;
   self.gameUnit = event.unit;
   self.spValue = 20;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);

   self.gameUnit:setSkin("normal")
   self:setTriggerList()
   self:setMessageBoxList()
   self:setBuffBoxList()

   self:showMessage(self.START_MESSAGE_LIST)

   self.isAwaken = false
   self.isAwakened = false
   self.isFury = false
   self.negaTimer = 1.2
   self.LIMIT = 1.2
   self.hitStop = 0

   self.stageCount = 1
   self.stage = {
      [1] = 2,
      [2] = 3,
      [3] = 5
   }

   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   -- event.unit:setReduceHitStop(2,self.hitStop)
   -- self:HPTriggersCheck(event.unit);
   self:negaChange(event.deltaTime)
   return 1
end
function class:negaChange(deltaTime)
  if not self.isNega then return end

  if self.LIMIT >= self.negaTimer then
    self.negaTimer = self.negaTimer + deltaTime
  else
    self.isNega = false
    self.gameUnit:takeGrayScale(0.99)
    self:removeGrayScale(self.gameUnit)
  end

end

---------------------------------------------------------------------------------
-- run 
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "change" then
      self:change()
   end
   if event.spineEvent == "nega" then
      self:change()
   end

   return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
   if not self.isAwakened then
      event.unit:setNextAnimationEffectName("out")
   else
      event.unit:setNextAnimationEffectName("out2")
   end
   return 1
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
   if not self.isAwakened then
      event.unit:setNextAnimationName("back")
   else
      event.unit:setNextAnimationName("back2")
   end  
   return 1
end

---------------------------------------------------------------------------------
-- takeBreake
---------------------------------------------------------------------------------
function class:takeBreake(event)
   self.isBreak = true
   if self.isAwaken then self.isAwaken = false else self.isAwaken = true end
   -- self.isAwaken = not self.isAwaken
   self:removeConditionAll(self.gameUnit,93968200)
    self:removeConditionAll(self.gameUnit,93968300)
   return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
   if self.isBreak and self.gameUnit.m_breaktime <= 0 and megast.Battle:getInstance():isHost() then
     self.gameUnit:addSP(100)
     return 0
   end

  if self.isFinal then
    if self.stageCount <= #self.stage then
      self.gameUnit:addSP(100)
    else
      self:removeCondition(self.gameUnit,5213134)
      self.isFinal = false
    end
    return 1
  end

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

   unit:takeAttack(tonumber(attackIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
   return 0;
end

function class:addSP(unit)  
   if self.gameUnit.m_breaktime <= 0 then
      unit:addSP(self.spValue);
   end
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

   if self.stageCount == #self.stage + 1 and not self.skillCheckFlg2 then
      self.skillCheckFlg2 = true;
      event.unit:takeSkillWithCutin(event.index,1);
      return 0;
   end

   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;

   if self.stageCount == #self.stage + 1 then
     self.gameUnit:setActiveSkill(self.FINAL_SKILL3)
     self.stageCount = self.stageCount + 1
   elseif self.stageCount == #self.stage then
     self.gameUnit:setActiveSkill(self.FINAL_SKILL2)
   else 
     self:skillActiveSkillSetter(event.unit,event.index);
   end

   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   if self.isBreak then
      self.isBreak = false
      skillIndex = 1
   end

   if self.isFinal and self.stageCount <= #self.stage then
     skillIndex = self.stage[self.stageCount]
     self.stageCount = self.stageCount + 1
   end


   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end

function class:removeGrayScale(unit)
    for i = 0,3 do
       local u = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if u ~= nil then
           u:takeGrayScale(0.99)
      end 
    end
end

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
   if not self:getIsHost() then
      return;
   end

   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

   for index,trigger in pairs(self.HP_TRIGGERS) do
      if trigger.HP >= hpRate and not trigger.used then
         self:execTrigger(index)
      end
   end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
   if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end

   receiveNumber = receiveNumber ~= nil and receiveNumber or 3

   local action = "use" .. receiveNumber

    self.TRIGGERS[index].used = true
    self.TRIGGERS[index].action(action)
    if self.TRIGGERS[index].tag == "HP_FLG" then
        --self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
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
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
end

-- バフ削除
function class:removeCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
      unit:resumeUnit()
    end  
end

function class:removeConditionAll(unit,buffId)
     while unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil do
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
      unit:resumeUnit()
    end
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        --self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
   return 1
end



class:publish();

return class;