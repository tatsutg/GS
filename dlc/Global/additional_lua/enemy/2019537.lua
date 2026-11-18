local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class                             = summoner.Bootstrap.createEnemyClass({ label = "火ドラ", version = 1.3, id = 2019537 });
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
   -- ATTACK1 = 50,
   ATTACK2 = 50,
   ATTACK3 = 50,
   ATTACK4 = 50

}

--使用する奥義とその確率
class.SKILL_WEIGHTS  = {
   SKILL1 = 2,
   SKILL2 = 3
}

class.ACTIVE_SKILLS  = {
   ATTACK1 = 1,
   ATTACK2 = 2,
   ATTACK3 = 3,
   ATTACK4 = 4,
   ATTACK5 = 5,
   SKILL1  = 7,
   SKILL2  = 8
}

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID       = 20157501,
         BUFF_ID  = 28, -- 行動速度
         VALUE    = 50,
         DURATION = 999999,
         ICON     = 7
      },
      [2] = {
         ID       = 20157502,
         BUFF_ID  = 17, -- ダメージ
         VALUE    = 30,
         DURATION = 999999,
         ICON     = 26
      },
      [3] = {
         ID       = 20157503,
         BUFF_ID  = 0, -- 奥義ゲージ
         VALUE    = 0,
         DURATION = 999999,
         ICON     = 36
      }
   }
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
   local message = {
      MESSAGE  = messageBox.MESSAGE or "メッセージ",
      COLOR    = messageBox.COLOR or Color.yellow,
      DURATION = messageBox.DURATION or 5,
      isPlayer = messageBox.isPlayer or false
   }
   return message
end

function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE1 or "燃焼状態：攻撃力アップ・被ダメージアップ"
      }),
      [2] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE2 or "燃焼耐性アップ"
      })
   }

   self.HP70_MESSAGE_LIST  = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP70_MESSAGE1 or "行動速度アップ"
      })
   }

   self.HP50_MESSAGE_LIST  = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "デグルマグナの怒りで辺りが炎に包まれる"
      }),
      [2] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP50_MESSAGE2 or "全攻撃に燃焼効果・奥義ゲージ速度アップ"
      })
   }

   self.HP30_MESSAGE_LIST  = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP30_MESSAGE1 or "ダメージアップ"
      })
   }
end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TRIGGERS    = {
      [1] = {
         tag    = "HP_FLG",
         action = function(status) self:hp70(status) end,
         HP     = 70,
         used   = false
      },
      [2] = {
         tag    = "HP_FLG",
         action = function(status) self:hp50(status) end,
         HP     = 50,
         used   = false
      },
      [3] = {
         tag    = "HP_FLG",
         action = function(status) self:hp30(status) end,
         HP     = 30,
         used   = false
      }
   }

   self.HP_TRIGGERS = {}
   for index, trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         trigger.hpMarker = self.gameUnit:addNumHpMarker(trigger.HP * 0.01)
         self.HP_TRIGGERS[index] = trigger
      end
   end
end

function class:hp70(status)
   if status == "use3" then
      self:showMessage(self.HP70_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[1])
   end
end

function class:hp50(status)
   if status == "use3" then
      self:showMessage(self.HP50_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
      self.spValue = 40
   end
end

function class:hp30(status)
   if status == "use3" then
      self:showMessage(self.HP30_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[2])
   end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.fromHost       = false;
   self.gameUnit       = event.unit;
   self.spValue        = 20;
   self.attackCheckFlg = false;
   self.skillCheckFlg  = false;
   self.skillCheckFlg2 = false;
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);

   self.isRage = false
   self.isFury = false
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()
   self:showMessage(self.START_MESSAGE_LIST)
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:HPTriggersCheck(event.unit)
   return 1
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
   self:attackActiveSkillSetter(event.unit, event.index);
   -- self:addSP(event.unit);
   return 1
end

function class:attackReroll(unit)
   local attackStr   = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
   local attackIndex = string.gsub(attackStr, "ATTACK", "");

   unit:takeAttack(tonumber(attackIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID, 1, tonumber(attackIndex));
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

   if event.index == 3 and not self.skillCheckFlg2 then
      self.skillCheckFlg2 = true;
      event.unit:takeSkillWithCutin(3, 1);
      return 0;
   end

   self.skillCheckFlg  = false;
   self.skillCheckFlg2 = false;
   self.fromHost       = false;
   self:skillActiveSkillSetter(event.unit, event.index);
   return 1
end

function class:skillReroll(unit)
   local skillStr   = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr, "SKILL", "");

   if self.isRage then
      skillIndex = 3
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID, 2, tonumber(skillIndex));
   return 0;
end

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
   if not self:getIsHost() then
      return ;
   end

   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

   for index, trigger in pairs(self.HP_TRIGGERS) do
      if trigger.HP >= hpRate and not trigger.used then
         self:execTrigger(index)
      end
   end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index, receiveNumber)
   if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end

   receiveNumber = receiveNumber ~= nil and receiveNumber or 3

   local action  = "use" .. receiveNumber

   self.TRIGGERS[index].action(action)
   self.TRIGGERS[index].used = true
   if self.TRIGGERS[index].hpMarker ~= nil then
      self.gameUnit:removeHpMarker(self.TRIGGERS[index].hpMarker)
   end

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID, receiveNumber, index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
   self.TRIGGERS[args.arg].used = true
   self.gameUnit:removeHpMarker(self.TRIGGERS[args.arg].hpMarker)
   return 1
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList, index)
   if index == nil then
      self:showMessageAll(messageBoxList)
      return
   end
   self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
   for i, messageBox in ipairs(messageBoxList) do
      self:execShowMessage(messageBox)
   end
end

function class:showMessageRange(messageBoxList, start, finish)
   for i = start, finish do
      self:execShowMessage(messageBoxList[i])
   end
end

function class:execShowMessage(messageBox)
   if messageBox.isPlayer then
      summoner.Utility.messageByPlayer(messageBox.MESSAGE, messageBox.DURATION, messageBox.COLOR);
   else
      summoner.Utility.messageByEnemy(messageBox.MESSAGE, messageBox.DURATION, messageBox.COLOR);
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

class:publish();

return class;