local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="狐タマエ", version=1.8, id=600000053})
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
    SKILL4 = 100
}

class.SKILL_WEIGHTS_NORMAL = {
    SKILL4 = 100
}

class.SKILL_WEIGHTS_RAGE = {
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

class.TELOP_SPAN = 30;

function class:setTriggerList()
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp70(status) end,
         HP = 70,
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
         action = function (status) self:hp30(status) end,
         HP = 30,
         used = false
      }    
   }

   self.HP_TRIGGERS = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.HP_TRIGGERS[index] = trigger
      end
   end
end

function class:hp70(status)
   if status ==  "use3" then
      self:showMessage(self.HP70_MESSAGE_LIST)
      self:addBuff(self.gameUnit,self.HP70_BUFF_BOX)
   end
end

function class:hp50(status)
   if status ==  "use3" then
    self:showMessage(self.HP50_MESSAGE_LIST)
    self:addBuff(self.gameUnit,self.HP50_BUFF_BOX)
   end
end

function class:hp30(status)
   if status ==  "use3" then
    self:showMessage(self.HP30_MESSAGE_LIST)
    self:addBuff(self.gameUnit,self.HP30_BUFF_BOX)
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
   self:execShowMessage(self.MODECHANGE_MESSAGE_LIST[2])
   self:removeCondition(self.gameUnit,self.MODE_BUFF_LIST[1].ID)
   self:execAddBuff(self.gameUnit,self.MODE_BUFF_LIST[2])
end

function class:normal()
   self.isAwakened = false
   self.gameUnit:setSkin("normal")
   self.ATTACK_WEIGHTS = self.ATTACK_WEIGHTS_NORMAL
   self.SKILL_WEIGHTS = self.SKILL_WEIGHTS_NORMAL
   megast.Battle:getInstance():setBackGroundColor(9999,255,255,255);

   megast.Battle:getInstance():setBossCounterElement(1);
   self.gameUnit:setElementType(1);
   self:execShowMessage(self.MODECHANGE_MESSAGE_LIST[1])
   self:removeCondition(self.gameUnit,self.MODE_BUFF_LIST[2].ID)
   self:execAddBuff(self.gameUnit,self.MODE_BUFF_LIST[1])
end

--------[[メッセージ]]--------
function class:setMessageInfo(messageBox)
   local message = {
      MESSAGE = messageBox.MESSAGE or "メッセージ",
      COLOR = messageBox.COLOR or Color.yellow,
      DURATION = messageBox.DURATION or 10,
      isPlayer = messageBox.isPlayer or false
   }
   return message
end

function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE1 or "炎属性攻撃無効",
         COLOR = Color.red
      })
   }

   self.HP70_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP70_MESSAGE1 or "クリティカルダメージアップ"
      })
   }

   self.HP50_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "クリティカル率・攻撃力アップ"
      })
   }

   self.HP30_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP30_MESSAGE1 or "クリティカルダメージアップ"
      })
   }

   self.SUMIRE_MESSSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.SUMIRE_MESSAGE1 or "ちょいとひと筆、ごらんあれ！",
         COLOR = Color:new(244,131,37),
         isPlayer = true
      }),
      [2] = self:setMessageInfo({
         MESSAGE = self.TEXT.SUMIRE_MESSAGE2 or "てやんでー、どんなもんだい！",
         COLOR = Color:new(244,131,37),
         isPlayer = true
      }),
      [3] = self:setMessageInfo({
         MESSAGE = self.TEXT.SUMIRE_MESSAGE3 or "しっかりおやりよ、剛の者",
         COLOR = Color:new(244,131,37),
         isPlayer = true
      })
   }

   self.SUMIRE_BUFF_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.SUMIRE_BUFF_MESSAGE1 or "状態異常回復",
         COLOR = Color.green,
         isPlayer = true
      }),
      [2] = self:setMessageInfo({
         MESSAGE = self.TEXT.SUMIRE_BUFF_MESSAGE2 or "HP自然回復",
         COLOR = Color.green,
         isPlayer = true
      }),
      [3] = self:setMessageInfo({
         MESSAGE = self.TEXT.SUMIRE_BUFF_MESSAGE3 or "奥義ゲージ自然回復",
         COLOR = Color.green,
         isPlayer = true
      })
   }

   self.MODECHANGE_MESSAGE_LIST ={
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.MODECHANGE_MESSAGE1 or "炎属性攻撃無効",
         COLOR = Color.red
      }),
      [2] = self:setMessageInfo({
         MESSAGE = self.TEXT.MODECHANGE_MESSAGE2 or "闇属性攻撃無効",
         COLOR = Color.magenta
      })
   }

        -- レイドメッセージ
    self.RAID_MESSAGES = {
      [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.mess1 or "ボスに狙われている！",
            COLOR = Color.red
        })
    }
   -- テロップ
  self.mes_telop1 = self.TEXT.telop1 or "ボスに狙われると被ダメージが増加します。"
  self.mes_telop2 = self.TEXT.telop2 or "ユニットが倒れた時は、入れ替えて戦いましょう。"
  self.mes_telop3 = self.TEXT.telop3 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"
end

--------[[バフ]]--------
function class:setBuffBoxList()
   self.HP70_BUFF_BOX = {
    [1] = {
      ID = 5213134,
      BUFF_ID = 17, -- クリティカル
      VALUE = 20,
      DURATION = 999999,
      ICON = 26,
      SCRIPT = 22,
      SCRIPTVALUE1 = 0
    }
  }

   self.HP50_BUFF_BOX = {
    [1] = {
      ID = 5213132,
      BUFF_ID = 22, -- クリティカル率
      VALUE = 30,
      DURATION = 999999,
      ICON = 11
    },
     [2] = {
      ID = 5213133,
      BUFF_ID = 13, -- 攻撃力
      VALUE = 50,
      DURATION = 999999,
      ICON = 3
    }
  }

   self.HP30_BUFF_BOX = {
    [1] = {
      ID = 5213134,
      BUFF_ID = 17, -- クリティカル
      VALUE = 20,
      DURATION = 999999,
      ICON = 26,
      SCRIPT = 22,
      SCRIPTVALUE1 = 0
    }
  }

   self.SUMIRE_BUFF_BOX_LIST = {
     [1] = {
          ID = 600002,
          BUFF_ID = 7, -- 自然回復
          VALUE = 1000,
          DURATION = 10,
          ICON = 35
     },
     [2] = {
          ID = 600003,
          BUFF_ID = 10, -- 奥義ゲージ増加
          VALUE = 20,
          DURATION = 10,
          ICON = 36
     }
   }


   self.TARGET_BUFF_BOX_LIST = {
      [1] = {
          ID = 501299,
          BUFF_ID = 17, -- ダメージ
          VALUE = 100,
          DURATION = 999999,
          ICON = 26
     }
   }

   self.MODE_BUFF_LIST = {
      [1] = {
          ID = 501300,
          BUFF_ID = 61, -- 炎属性無効
          VALUE = 1000,
          DURATION = 999999,
          ICON = 38
     },
      [2] = {
          ID = 5013301,
          BUFF_ID = 65, -- 闇属性無効
          VALUE = 1000,
          DURATION = 999999,
          ICON = 42
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
   self:execAddBuff(self.gameUnit,self.MODE_BUFF_LIST[1])

   self.isAwaken = false
   self.isAwakened = false
   self.isFury = false
   self.negaTimer = 1.2
   self.LIMIT = 1.2
   self.hitStop = 1
   self.targetUnitList = {}

   self.sumire = nil
   self.isRemove = true

   --自動ヘイトは使わん
   event.unit:setHateRate_Heal(0)
   event.unit:setHateRate_Damage(0)

   self.telopTimer = 0   
   self.startTimer = 0
   self.alreadyBreaked = true
   self.REMOVE_BADSTATUS = {89,90,91,92,93,94,95,96,97}

   return 1
end

-- 絶対通らない関数。efがほしかった…！！！！！
function class:kotou(tekitou)
   local toriaezu = event.unit:addOrbitSystemWithFile("10311ef")
   local ochinakunaru = event.unit:addOrbitSystemWithFile("103116112")
end


function class:startWave(event)
   BattleControl:get():visibleHateTarget(true);
   BattleControl:get():setHateTargetIcon(14);
   event.unit:setEnableHate(true);
   event.unit:updateHateTarget();
   self:checkPlayersParty()
   return 1
end

function class:checkPlayersParty()
   for i = 0,3 do
      local unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
      if unit ~= nil then
         local targetInfo = {unit = unit,dps = 0}
         table.insert(self.targetUnitList,unit:getIndex() + (unit:getBaseID3() * 10),targetInfo)
      end 
   end
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   if event.enemy:getIndex() == 4 then return event.value end

   local enemyUnit = self:getAncestorUnit(event.enemy)
   local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)

   if self.targetUnitList[index] == nil then
      table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value})
   else
      self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value
   end

   --ヘイトは全部手動で設定する！！！！！！！
   event.unit:setHateTarget(self:checkTargetUnit())
   event.unit:updateHateTarget();
   return event.value
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
   if unit:getParentTeamUnit() == nil then
      return unit
   else
      return self:getAncestorUnit(unit:getParentTeamUnit())
   end
end

-- 与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
   local target = nil
   local val = 0
   for i,v in pairs(self.targetUnitList) do
      if v.unit == nil or v.unit:getHP() < 1 then
         v.dps = 0
      end
      if v.dps > val then
         val = v.dps
         target = v.unit
      end
   end
   return target
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(2,self.hitStop)
   self:HPTriggersCheck(event.unit);
   self:negaChange(event.deltaTime)
   self:telop(event.deltaTime)
   self:sumireCheck(event.deltaTime)
   self:startTimerCheck(event.deltaTime)

   -- ブレイクが溶けたらスミレ退場
   if self.gameUnit.m_breaktime <= 0 and not self.isRemove and self.sumire ~= nil then
      megast.Battle:getInstance():getTeam(true):removeUnit(4)
      self:execShowMessage(self.SUMIRE_MESSSAGE_LIST[3])
      self.isRemove = true
   end
   return 1
end

function class:startTimerCheck(deltaTime)
   if self.alreadyBreaked then
      if self.startTimer < 3 then
         self.startTimer = self.startTimer + deltaTime
      else
         self.alreadyBreaked = false
      end
   end
end

function class:sumireCheck(deltaTime)
  if not self.isRemove then
    if self.sumireEnable and self.sumireCounter > 8 then
       self:execShowMessage(self.SUMIRE_MESSSAGE_LIST[2])
       self.sumireEnable = false
    end
    self.sumireCounter = self.sumireCounter + deltaTime
  end
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
function class:telop(deltaTime)
    if self.TELOP_SPAN < self.telopTimer then
        self.telopTimer = 0
        local rand = LuaUtilities.rand(1,4)
        if rand == 1 then
            RaidControl:get():addPauseMessage(self.mes_telop1 , 2.2);
        elseif rand == 2 then
            RaidControl:get():addPauseMessage(self.mes_telop2 , 2.2);
        elseif rand == 3 then
            RaidControl:get():addPauseMessage(self.mes_telop3 , 2.2);
        end                
    else
        self.telopTimer = self.telopTimer + deltaTime
    end
end

function class:excuteAction(event)
  self:checkTarget()
  return 1
end

-- 被ターゲット判定
function class:checkTarget()
  if not self.isTarget and self:getIsTarget() then
    self:execAddBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST[1])
    self:showMessage(self.RAID_MESSAGES)
  end
  if self:getIsTarget() then
    -- BattleControl:get():showHateAll()
  else
    -- BattleControl:get():hideHateAll(); 
    self:removeCondition(self.gameUnit,self.TARGET_BUFF_BOX_LIST[1].ID)    
  end
  self.isTarget = self:getIsTarget();
end

function class:getIsTarget()
  return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > 1000000;
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

   if event.spineEvent == "snap" then
      if self:checkTargetUnit() ~= nil then
         self:checkTargetUnit():setHP(0)
      end
      event.unit:resetHate()
      self:refreshDps()
   end
   return 1
end

function class:refreshDps()
   for i,v in pairs(self.targetUnitList) do
      v.dps = 0
   end
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
   if self.alreadyBreaked then return 1 end

   self.sumire = self:summonFriend()
   self.isRemove = false
   return 1
end

function class:execModeChange()
   self.modeChange = true
   if self.isAwaken then self.isAwaken = false else self.isAwaken = true end
   self:removeConditionAll(self.gameUnit,93966200)
   self:removeConditionAll(self.gameUnit,93966300)
end

function class:summon(unit,unitID)
   if megast.Battle:getInstance():isHost() then
      for i = 0, 4 do
          if unit:getTeam():getTeamUnit(i) == nil then
               unit:getTeam():addUnit(i,unitID)--指定したインデックスの位置に指定したエネミーIDのユニットを出す
              break
          end
      end
   end
end

function class:summonFriend()
   local unit = megast.Battle:getInstance():getPlayerTeam():addTeamUnit(103116112,90,4); --スミレ
   unit:setEvolutionStage(2);
   unit:setBaseHP(100000);
   unit:setHP(100000);
   unit:setPosition(30,20);
   unit:setDefaultPosition(30,20);
   unit:setBasePower(4000);


   -- unit:takeIn();
   unit:addSP(100)
   unit:takeAnimation(0,"skill3raid",false)
   unit:setUnitState(kUnitState_attack);
   -- unit:takeSkill(3)
   unit:setInvincibleTime(10)
   self.sumireCounter = 0
   self.sumireEnable = true
   self:execShowMessage(self.SUMIRE_MESSSAGE_LIST[1])
   self:showMessage(self.SUMIRE_BUFF_MESSAGE_LIST)
   for i = 0,3 do
      local teamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
      if teamUnit ~= nil then
         self:addBuff(teamUnit,self.SUMIRE_BUFF_BOX_LIST)
         for i,v in ipairs(self.REMOVE_BADSTATUS) do
            self:removeConditionWithType(teamUnit,v)
         end
      end 
   end

   return unit
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
   self.alreadyBreaked = false
   if self.modeChange then
      self.modeChange = false
      event.unit:setNextAnimationName("skill1")
      event.unit:setNextAnimationEffectName("1-skill1")
      event.unit:setActiveSkill(8)
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

   if not self.skillCheckFlg2 and event.index ~= 1 then
      self.skillCheckFlg2 = true;
      event.unit:takeSkillWithCutin(event.index,1);
      return 0;
   end

   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;

   self:skillActiveSkillSetter(event.unit,event.index);
     self:execModeChange()
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

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

   self.TRIGGERS[index].action(action)
   self.TRIGGERS[index].used = true

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

-- バフ削除
function class:removeConditionWithType(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithType(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithType(buffId))
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
   self.TRIGGERS[args.arg].action("use3")
   return 1
end



class:publish();

return class;