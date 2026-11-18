local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ストラフ", version=1.3, id=2010009});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

----------[[特殊行動フラグ]]----------
function class:setHpTriggersList()
   self.HP_FLG_1 = 0
   self.IN_BREAK = 1
   self.RECOVERY_BREAK = 2

   self.TRIGGERS = {
      [self.HP_FLG_1] = {
         tag = "HP_FLG",
         action = function (status) self:hpFlg50(status) end,
         timing = 50,
         used = false
      },
      [self.IN_BREAK] = {
         tag = "IN_BREAK",
         action = function (status) self:inBreak(status) end,
         used = false
      },
      [self.RECOVERY_BREAK] = {
         tag = "RECOVERY_BREAK",
         action = function (status) self:recoveryBreak(status) end,
         used = false,
         counter = 3
      }
   }
   self.hpMarkers = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.hpMarkers[self.TRIGGERS[index].timing] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].timing * 0.01)
      end
   end
end

function class:hpFlg50(status)
   if status == "use" then
      self.isRage = true
      self.spValue = 40
      self:showMessage(self.RAGE_MESSAGE_LIST)
   end
end

function class:inBreak(status)
   if status == "use" then
      self.isBreak = true
      -- self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
      self:showMessage(self.BREAK_IN_MESSAGE_LIST)
   end
end

function class:recoveryBreak(status)
   if status == "use" then
      self.isBreak = false
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[0])
      -- self:removeCondition(self.gameUnit,self.BUFF_BOX_LIST[1].BUFF_ID)
      self:showMessage(self.BREAK_OUT_MESSAGE_LIST)
   end
end

----------[[バフ]]----------
function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [0] = {
         ID = 2010010,
         BUFF_ID = 27,         --ブレイク耐性
         VALUE = -20,        --効果量
         DURATION = 9999999,
         ICON = 5,
         COUNT = 1,
         COUNT_MAX = 3
      },
      [1] = {
         ID = 2010011,
         BUFF_ID = 21,         --被ダメUP
         VALUE = 25,        --効果量
         DURATION = 9999999,
         ICON = 6
      }
   }
end

----------[[メッセージ]]----------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "供物の器がこんなに...!",
         COLOR = Color.magenta,
         DURATION = 5
      },
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "魔法耐性・回避UP",
         COLOR = Color.yellow,
         DURATION = 5
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE3 or "燃焼時奥義ダメージDOWN",
         COLOR = Color.yellow,
         DURATION = 5
      }
   }

  self.BREAK_IN_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.BREAK_IN_MESSAGE or "物理被ダメージUP",
         COLOR = Color.yellow,
         DURATION = 5
      }
   }

  self.BREAK_OUT_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.BREAK_OUT_MESSAGE or "ブレイク耐性UP",
         COLOR = Color.yellow,
         DURATION = 5
      }
   }

  self.RAGE_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.RAGE_MESSAG1 or "あなたはよい...非常によい...!",
         COLOR = Color.magenta,
         DURATION = 5
      },
      [1] = {
         MESSAGE = self.TEXT.RAGE_MESSAGE2 or "奥義ゲージ上昇量UP",
         COLOR = Color.yellow,
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
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);
   self.gameUnit = event.unit;
   self:setMessageBoxList()
   self:setHpTriggersList()
   self:setBuffBoxList()
   self:showMessage(self.START_MESSAGE_LIST)

   self.isRage = false
   self.isBreak = false

   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   if not megast.Battle:getInstance():isHost() then
      return 1
   end
   self:HPTriggersCheck(event.unit);
   if self.isBreak and self.gameUnit.m_breaktime <= 0 then
      self:execTrigger(self.RECOVERY_BREAK)
   end
   return 1
end

---------------------------------------------------------------------------------
-- takeBreak
---------------------------------------------------------------------------------
function class:takeBreake(event)
   if not megast.Battle:getInstance():isHost() then
      return 1
   end
   self:execTrigger(self.IN_BREAK)
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

   if event.index == 3 and not self.skillCheckFlg2 then
      self.skillCheckFlg2 = true;
      event.unit:takeSkillWithCutin(3,1);
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

   if self.isRage then 
      skillIndex = 3
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].used = true
   self.TRIGGERS[args.arg].action("use")
   if self.TRIGGERS[args.arg].tag == "HP_FLG" then
      self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].timing])
   end
   return 1
end

--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
   if not self:getIsHost() then
      return;
   end

   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
   local priorityIndex = nil

   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         if trigger.timing >= hpRate and not trigger.used then
            if priorityIndex == nil then 
               priorityIndex = index 
            end
            priorityIndex = self.TRIGGERS[priorityIndex].timing > trigger.timing and index or priorityIndex
         end
      end
   end
   self:execTrigger(priorityIndex)
end

function class:execTrigger(index)
   if index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end

  if self.TRIGGERS[index].counter ~= nil then
    if self.TRIGGERS[index].counter <= 0 then
      return
    end
    self.TRIGGERS[index].counter = self.TRIGGERS[index].counter -1;
  end

   self.TRIGGERS[index].used = true
   self.TRIGGERS[index].action("use")
   if self.TRIGGERS[index].tag == "HP_FLG" then
      self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].timing])
   end
   megast.Battle:getInstance():sendEventToLua(self.scriptID,3,index)
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

--===================================================================================================================
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

    if buffBox.COUNT ~= nil then
        buff:setNumber(buffBox.COUNT)
        megast.Battle:getInstance():updateConditionView()
        if buffBox.COUNT < buffBox.COUNT_MAX then
            buffBox.COUNT = buffBox.COUNT + 1
            self:incBuffValue(buffBox,-20)
        end
    end

end

-- バフ効果量インクリメント
function class:incBuffValue(buffBox,value)
   buffBox.VALUE = buffBox.VALUE + value
end

-- バフ削除
function class:removeCondition(unit,buffId)
  if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
    unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
  end  
end

class:publish();

return class;