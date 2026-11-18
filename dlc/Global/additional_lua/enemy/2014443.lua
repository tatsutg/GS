local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="シビル", version=1.3, id=2014443});
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

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "公開処刑を開始する",
         COLOR = Color.magenta,
         DURATION = 5,
         isPlayer = false        
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカル率アップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      },
      [3] = {
         MESSAGE = self.TEXT.START_MESSAGE3 or "クリティカルダメージアップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      }            
   }
   self.HP60_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP60_MESSAGE1 or "調子に乗るな…！",
         COLOR = Color.magenta,
         DURATION = 5,
         isPlayer = false        
      },
      [2] = {
         MESSAGE = self.TEXT.HP60_MESSAGE2 or "さらにクリティカルダメージアップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      }
   }
   self.HP30_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP30_MESSAGE1 or "絶望せよ…己の無力さにな！",
         COLOR = Color.magenta,
         DURATION = 5,
         isPlayer = false
      },
      [2] = {
         MESSAGE = self.TEXT.HP30_MESSAGE2 or "さらにクリティカルダメージアップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false
      }
   }

   self.OUGI_MESSAGE = {
      MESSAGE = self.TEXT.OUGI_MESSAGE1 or "奥義ゲージ速度アップ",
      COLOR = Color.yellow,
      DURATION = 5,
      isPlayer = false    
   }
   
end

--------[[バフ]]--------
function class:setBuffBoxList()
   self.BUFF_LIST = {
      [1] = {
         ID = 20144431,
         BUFF_ID = 17, -- クリティカルダメージ
         VALUE = 20,
         DURATION = 999999,
         ICON = 26,
         SCRIPT = {
            SCRIPT_ID = 22,
            VALUE1 = 0,
            VALUE2 = 0
         }
      },
      [2] = {
         ID = 20144432,
         BUFF_ID = 17, -- クリティカルダメージ
         VALUE = 30,
         DURATION = 999999,
         ICON = 26,
         SCRIPT = {
            SCRIPT_ID = 22,
            VALUE1 = 0,
            VALUE2 = 0
         }
      }
   }
end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp60(status) end,
         HP = 60,
         used = false
      },
      [2] = {
         tag = "HP_FLG",
         action = function (status) self:hp30(status) end,
         HP = 30,
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

function class:hp60(status)
   if status == "use3" then
      self.isRage = true
      self.gameUnit:addSP(100)
      self:execAddBuff(self.gameUnit,self.BUFF_LIST[1])
      self:showMessage(self.HP60_MESSAGE_LIST)
   end
end

function class:hp30(status)
   if status == "use3" then
      self.isRage = true
      self.gameUnit:addSP(100)
      self:execAddBuff(self.gameUnit,self.BUFF_LIST[2])
      self:showMessage(self.HP30_MESSAGE_LIST)
   end
end

function class:ougi()
   self:execShowMessage(self.OUGI_MESSAGE)
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
   event.unit:setReduceHitStop(2,self.hitStop)
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
      self.isRage = false
   elseif skillIndex == "2" then
      self:ougi()
      megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end

function class:receive4(event)
   self:ougi()
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

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].used = true
   self.TRIGGERS[args.arg].action("use3")
   self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
   return 1
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

    if buffBox.COUNT ~= nil then
        if buffBox.COUNT < buffBox.COUNT_MAX then
            buff:setNumber(buffBox.COUNT)
            megast.Battle:getInstance():updateConditionView()
            buffBox.COUNT = buffBox.COUNT + 1
            buffBox.VALUE = self.ougiBuffValue * buffBox.COUNT
         else
           buff:setNumber(10)
           megast.Battle:getInstance():updateConditionView()
        end
    end
end


class:publish();

return class;