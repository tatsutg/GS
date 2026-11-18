--@additionalEnemy,2017914
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="メルティ襲来", version=1.3, id=2017901});
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

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 20077091,
         BUFF_ID = 17, -- ダメージ
         VALUE = 30,
         DURATION = 999999,
         ICON = 26
      },
      [2] = {
         ID = 20077092,
         BUFF_ID = 22, -- クリティカル
         VALUE = 50,
         DURATION = 999999,
         ICON = 11
      },
      [3] = {
         ID = 20077093,
         BUFF_ID = 126, -- 回復量
         VALUE = 100,
         DURATION = 999999,
         ICON = 106
      },
      [4] = {
         ID = 20077094,
         BUFF_ID = 15, -- 行動速度
         VALUE = 30,
         DURATION = 999999,
         ICON = 28
      }
   }
end


--------[[メッセージ]]--------
function class:setMessageBoxList()

  self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "闇属性キラー・闇属性耐性アップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false
      }
      -- [2] = {
      --    MESSAGE = self.TEXT.START_MESSAGE2 or "回避率アップ",
      --    COLOR = Color.yellow,
      --    DURATION = 5,
      --    isPlayer = false
      -- }    
  }

   self.HP80_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP80_MESSAGE1 or "行動速度アップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false
      }
   }

   self.HP70_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP70_MESSAGE1 or "た、助けにきました！",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false
      }
   }

   self.HP50_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "ダメージアップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false
      }
   }

   self.HP40_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP40_MESSAGE1 or "クリティカル率アップ・回復量アップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false
      }
   }

   self.HP20_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP20_MESSAGE1 or "行動速度アップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false
      }
   }

end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TRIGGERS = {
      -- [1] = {
      --    tag = "HP_FLG",
      --    action = function (status) self:hp80(status) end,
      --    HP = 80,
      --    used = false
      -- },
      [2] = {
         tag = "HP_FLG",
         action = function (status) self:hp70(status) end,
         HP = 70,
         used = false
      },
      [3] = {
         tag = "HP_FLG",
         action = function (status) self:hp50(status) end,
         HP = 50,
         used = false
      }
      -- [4] = {
      --    tag = "HP_FLG",
      --    action = function (status) self:hp40(status) end,
      --    HP = 40,
      --    used = false
      -- },
      -- [5] = {
      --    tag = "HP_FLG",
      --    action = function (status) self:hp20(status) end,
      --    HP = 20,
      --    used = false
      -- }
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

function class:hp80(status)
   if status == "use3" then
      self.hitStop = 1
      self:showMessage(self.HP80_MESSAGE_LIST)
      -- self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
   end
end

function class:hp70(status)
   if status == "use3" then
      self:showMessage(self.HP70_MESSAGE_LIST)
      -- self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
      self:summon(self.gameUnit,2017914)
   end
end

function class:hp50(status)
   if status == "use3" then
      self:showMessage(self.HP50_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
   end
end

function class:hp40(status)
   if status == "use3" then
      self:showMessage(self.HP40_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
   end
end

function class:hp20(status)
   if status == "use3" then
      self.isFury = true
      self.gameUnit:addSP(100)
      self:showMessage(self.HP20_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
   end
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

   self.isRage = true
   self.isFury = false
   self.hitStop = 0
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()

   self.gameUnit:addSP(100)
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

   if event.index == 3 and not self.skillCheckFlg2 and self.isFury then
      self.skillCheckFlg2 = true;
      event.unit:takeSkillWithCutin(3,1);
      return 0;
   end

   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   if self.isFury then
      self.isFury = false
      event.unit:setActiveSkill(5)
   else
      self:skillActiveSkillSetter(event.unit,event.index);
   end
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   if self.isRage then
      self.isRage = false
      skillIndex = 2
   end

   if self.isFury then
      skillIndex = 3
   end
   
   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
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
   self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])

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
   self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
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
-- バフ関係
--===================================================================================================================
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