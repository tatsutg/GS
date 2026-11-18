local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ヴィラーゴ", version=1.3, id=2019301});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 200,
    SKILL3 = 100
}

class.SKILL_WEIGHTS_DEFAULT = {
   SKILL2 = 200,
   SKILL3 = 100
}

class.SKILL_WEIGHTS_RAGE = {
   SKILL2 = 100,
   SKILL3 = 200
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 6
}

class.ACTIVE_SKILLS_RAGE = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 4,
    SKILL3 = 7   
}

class.ACTIVE_SKILLS_FURY = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 5,
    SKILL3 = 8
}

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 20157501,
         BUFF_ID = 15, -- 防御力
         VALUE = 100,
         DURATION = 999999,
         ICON = 5
      },
      [2] = {
         ID = 20157502,
         BUFF_ID = 15, -- 防御力
         VALUE = 5000,
         DURATION = 999999,
         ICON = 5
      },
      [3] = {
         ID = 20157503,
         BUFF_ID = 15, -- 防御力
         VALUE = 1000,
         DURATION = 999999,
         ICON = 5
      },
      [4] = {
         ID = 20157504,
         BUFF_ID = 15, -- 防御力
         VALUE = 1000000,
         DURATION = 999999,
         ICON = 5
      }
   }

   self.BUFF_BOX_LIST_OUGI = {
      [1] = {
         ID = 20157605,
         BUFF_ID = 13, -- 攻撃力
         VALUE = 40,
         DURATION = 999999,
         ICON = 3
      }      
   }

   self.BUFF_BOX_LIST_BREAK = {
      [1] = {
         ID = 20157705,
         BUFF_ID = 21, -- 被ダメ
         VALUE = 50,
         DURATION = 999999,
         ICON = 139
      }
   }

-- 難易度調整
   self.BUFF_BOX_LIST_PLUS = {
      [1] = {
         ID = 20157805,
         BUFF_ID = 7, -- 自然回復   
         VALUE = 5000,
         DURATION = 999999,
         ICON = 35
      }
   }
end


--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
   local message = {
      MESSAGE = messageBox.MESSAGE or "メッセージ",
      COLOR = messageBox.COLOR or Color.yellow,
      DURATION = messageBox.DURATION or 5,
      isPlayer = messageBox.isPlayer or false
   }
   return message
end

function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE1 or "汝が王たる器か、この目で見極めてやろう",
         COLOR = Color.cyan
      }),
      [2] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE2 or "水属性キラー・水属性ダメージ無効"
      }),
      [3] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE3 or "クリティカルダメージ無効・庇うキラー"
      }),
      [4] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE4 or "奥義・真奥義発動毎に攻撃力アップ"
      })
   }

   self.HP90_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP90_MESSAGE1 or "防御力アップ"
      })
   }

   self.HP80_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP80_MESSAGE1 or "行動速度・防御力アップ"
      })
   }

   self.HP70_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP70_MESSAGE1 or "奥義ゲージ速度・防御力アップ"
      })
   }

   self.HP60_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP60_MESSAGE1 or "防御力アップ"
      })
   }

   self.HP50_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "誇り高き竜の力、その眼に焼き付けよ",
         COLOR = Color.cyan
      })
   }

   self.HP40_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP40_MESSAGE1 or "奥義ゲージ速度アップ"
      })
   }

   self.HP30_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP30_MESSAGE1 or "我が鱗は鋼――決して砕けぬ",
         COLOR = Color.cyan
      }),
      [2] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP30_MESSAGE2 or "奥義ゲージ速度・防御力アップ"
      })
      -- [3] = self:setMessageInfo({
      --    MESSAGE = self.TEXT.HP30_MESSAGE3 or "HP自然回復"
      -- })
   }

   self.HP1_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP1_MESSAGE1 or "最後に問おう、汝の意志と王たる素質を",
         COLOR = Color.cyan
      })
   }
end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TRIGGERS = {
      -- [1] = {
      --    tag = "HP_FLG",
      --    action = function (status) self:hp90(status) end,
      --    HP = 90,
      --    used = false
      -- },
      [2] = {
         tag = "HP_FLG",
         action = function (status) self:hp80(status) end,
         HP = 80,
         used = false
      },
      [3] = {
         tag = "HP_FLG",
         action = function (status) self:hp70(status) end,
         HP = 70,
         used = false
      },
      -- [4] = {
      --    tag = "HP_FLG",
      --    action = function (status) self:hp60(status) end,
      --    HP = 60,
      --    used = false
      -- },
      [5] = {
         tag = "HP_FLG",
         action = function (status) self:hp50(status) end,
         HP = 50,
         used = false
      },
      -- [6] = {
      --    tag = "HP_FLG",
      --    action = function (status) self:hp40(status) end,
      --    HP = 40,
      --    used = false,
      -- },
      [7] = {
         tag = "HP_FLG",
         action = function (status) self:hp30(status) end,
         HP = 30,
         used = false
      },
      -- [8] = {
      --    tag = "HP_FLG",
      --    action = function (status) self:hp20(status) end,
      --    HP = 20,
      --    used = false
      -- },
      [9] = {
         tag = "HP_FLG",
         action = function (status) self:hp1(status) end,
         HP = 1,
         used = false
      },
      [10] = {
         tag = "OTHER",
         action = function (status) self:deadSkill1(status) end,
         used = false
      },
      [11] = {
         tag = "OTHER",
         action = function (status) self:deadSkill2(status) end,
         used = false
      },
      [12] = {
         tag = "OTHER",
         action = function (status) self:deadSkill3(status) end,
         used = false
      },
      [13] = {
         tag = "HP_FLG",
         action = function (status) self:hp0(status) end,
         HP = 0,
         used = false
      }
   }

   self.HP_TRIGGERS = {}
   self.hpMarkers = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.HP_TRIGGERS[index] = trigger
         self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
      end
   end
end

function class:hp90(status)
   if status == "use3" then
      self:showMessage(self.HP90_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
   end
end

function class:hp80(status)
   if status == "use3" then
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
      self:showMessage(self.HP80_MESSAGE_LIST)
      self.hitStop = 1
   end
end

function class:hp70(status)
   if status == "use3" then
      self:showMessage(self.HP70_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
      self.spValue = 25
   end
end

function class:hp60(status)
   if status == "use3" then
      self:showMessage(self.HP60_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
   end
end

function class:hp50(status)
   if status == "use3" then
      self:showMessage(self.HP50_MESSAGE_LIST)
      self.SKILL_WEIGHTS = self.SKILL_WEIGHTS_RAGE
      self.ACTIVE_SKILLS = self.ACTIVE_SKILLS_RAGE
      self.isRage = true
      self.isRage2 = true
      self.isFury = true
      self.gameUnit:addSP(100)
      self.gameUnit:setInvincibleTime(7)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
   end
end

function class:hp40(status)
   if status == "use3" then
      self:showMessage(self.HP40_MESSAGE_LIST)
      self.spValue = 40
   end
end

function class:hp30(status)
   if status == "use3" then
      self:showMessage(self.HP30_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
      -- self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST_PLUS[1])
   end
end

function class:hp20(status)
   if status == "use3" then
      self:showMessage(self.HP20_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
   end
end

function class:hp1(status)
   if status == "use3" then
      self:showMessage(self.HP1_MESSAGE_LIST)
      self.gameUnit:setInvincibleTime(self.DEAD_LINE)
      -- self:execRemoveCondition(self.gameUnit,self.BUFF_BOX_LIST_PLUS[1].ID)
      self.gameUnit:setHP(1)
      self.isFury = true
      self.isDead = true
      self.isDead2 = true
      self.ACTIVE_SKILLS = self.ACTIVE_SKILLS_FURY
      self.gameUnit:addSP(100)
   end
end

function class:hp0(status)
   if status == "use3" then
   end
end

function class:deadSkill1(status)
   if status == "use3" then
      self.deadCount = 11
      self.deadSkillIndex = 2
      self.gameUnit:addSP(100)
      self.gameUnit:removeHpMarker(self.hpMarkers[0])
   end
end

function class:deadSkill2(status)
   if status == "use3" then
      self.deadCount = 12
      self.deadSkillIndex = 3
      self.deadTimer = self.DEAD_LINE - 6.4
      self.gameUnit:addSP(100)
   end
end

function class:deadSkill3(status)
   if status == "use3" then
      self.deadCount = 12
      self.deadTimer = self.DEAD_LINE + 1
      self.deadSkillIndex = 3
   end
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

   self.hitStop = 0.7
   self.HIT_LIST = 20
   self.DEFAULT_VALUE = 40
   self.DEAD_LINE = 20
   self.ougiCount = 0
   self.deadCount = 10
   self.deadTimer = 0
   self.deadSkillIndex = 0
   self.isRage = false
   self.isRage2 = false
   self.isFury = false
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()
   self:showMessage(self.START_MESSAGE_LIST)
   return 1
end


---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   if not self.isDead2 and event.value >= event.unit:getHP() then
      self.gameUnit:setInvincibleTime(self.DEAD_LINE)
      self.gameUnit:setHP(1)
      -- self:execTrigger(9)
      return 0
   end
   return event.value
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
   if self.deadCount < 12 and self.deadTimer < self.DEAD_LINE then
      event.unit:setHP(1)
      return 0
   end
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:HPTriggersCheck(event.unit)
   event.unit:setReduceHitStop(2,self.hitStop) 
   self:checkDead(event.unit,event.deltaTime)
   self:checkBreak(event.unit)
   return 1
end

function class:checkDead(unit,deltaTime)
   if self.isDead and megast.Battle:getInstance():getBattleState() == kBattleState_active then
      self.gameUnit:addSP(100)
      if self.deadTimer < self.DEAD_LINE then
         self.deadTimer = self.deadTimer + deltaTime
         return
      end
      unit:setInvincibleTime(0)
      unit:setHP(0)
   end
end

function class:checkBreak(unit)
   if unit.m_breaktime <= 0 then
      self:execRemoveCondition(unit,self.BUFF_BOX_LIST_BREAK[1].ID)
   end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
   if self.deadSkillIndex == 3 then      
      return 7000 / self.HIT_LIST
   end
   return event.value
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

   if not self.skillCheckFlg2 and self.isFury then
      if not self.isDead then
         self.isFury = false
      end
      self.skillCheckFlg2 = true;
      event.unit:takeSkillWithCutin(event.index,1);
      return 0;
   end

   self:addAttackBuff(event.unit,event.index)
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   self:skillActiveSkillSetter(event.unit,event.index);
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   if self.isRage then
      skillIndex = 3
      self.isFury = true
      self.isRage = false
      megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
   end

   if self.isRage2 and skillIndex == "3" then
      self.isFury = true
      megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
   end

   if self.isDead then
      self:execTrigger(self.deadCount)
      skillIndex = self.deadSkillIndex
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end

function class:receive5(args)
   self.isFury = true
   return 1
end

function class:addAttackBuff(unit,index)
   if index == 1 then return end

   self.ougiCount = self.ougiCount + 1
   self.BUFF_BOX_LIST_OUGI[1].VALUE = self.ougiCount * self.DEFAULT_VALUE
   self:execAddBuff(unit,self.BUFF_BOX_LIST_OUGI[1])
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
   if self.TRIGGERS[index].tag == "HP_FLG" then
      self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
   end

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
   self.TRIGGERS[args.arg].used = true
   if self.TRIGGERS[args.arg].tag == "HP_FLG" then
      self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
   end
   return 1
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

function class:execRemoveCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
    end  
end

class:publish();

return class;