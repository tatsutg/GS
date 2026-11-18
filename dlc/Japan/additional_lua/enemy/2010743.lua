local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ヴァルザンデス", version=1.3, id=2010743});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 50,
    SKILL2 = 50
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 2,
    ATTACK2 = 3,
    ATTACK3 = 4,

    SKILL1 = 1,
    SKILL2 = 5
}

--------[[バフ]]--------
function class:setBuffBoxList()
  self.BUFF_BOX_LIST = {
   [0] = {
      ID = 10003,
      BUFF_ID = 17, -- ダメージ
      VALUE = 30,
      DURATION = 999999,
      ICON = 26
    }
  }
end

--------[[特殊行動フラグ]]--------
function class:setTriggersList()
   self.HP_FLG = "HP_FLG"
   self.HP_50 = 0

   self.TRIGGERS = {
      [self.HP_50] = {
         tag = self.HP_FLG,
         action = function (status) self:hpFlg50(status) end,
         timing = 50,
         used = false
      },
      [1] = {
         tag = self.HP_FLG,
         action = function (status) self:hpFlg25(status) end,
         timing = 25,
         used = false
      }
   }
end

-- status = use + receive番号
function class:hpFlg50(status)
   if status == "use3" then
      self.isRage = true
      self.hitStop = 1
      self:showMessage(self.RAGE_MESSAGE_LIST)
      self:addBuff(self.gameUnit,self.BUFF_BOX_LIST)
      self.gameUnit:removeHpMarker(self.hpMarkers[50])
      self.gameUnit:setParameter("2010743_isRage","1")
      self:checkAiDropView(self.gameUnit,"2010743_isRage")
   end
end
function class:hpFlg25(status)
   if status == "use3" then
      self.gameUnit:setParameter("2010743_isPinch","1")
      self:checkAiDropView(self.gameUnit,"2010743_isPinch")
   end
end

function class:checkAiDropView(unit,key)
   if megast.Battle:getInstance():getAiLearningLuaKey() == key then
      local rnd = math.random(1,100)
      if rnd > 0 then
         megast.Battle:getInstance():addAiLearningDropItem(unit)
      end
   end
end


--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "樹属性耐性ダウン",
         COLOR = Color.cyan,
         DURATION = 5         
      },
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカル率・クリティカルダメージアップ",
         COLOR = Color.yellow,
         DURATION = 5         
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE3 or "行動速度アップ",
         COLOR = Color.yellow,
         DURATION = 5         
      }
   }

   self.RAGE_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.RAGE_MESSAGE or "行動速度・ダメージアップ",
         COLOR = Color.cyan,
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
   self:setTriggersList()
   self:setBuffBoxList()
   self:showMessage(self.START_MESSAGE_LIST)

   event.unit:setAttackDelay(0)
   self.hitStop = 0.5
   self.hpMarkers = {
      [50] = self.gameUnit:addNumHpMarker(0.5)
   }
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

   -- if tonumber(attackIndex) == 1 then

   -- else
   --    self.skillCheckFlg = true;
   --    unit:takeSkill(1);
   --    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
   --    return 0;
   -- end
   unit:takeAttack(tonumber(attackIndex));
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

   -- if event.index == 3 and not self.skillCheckFlg2 then
   --    self.skillCheckFlg2 = true;
   --    event.unit:takeSkillWithCutin(3,1);
   --    return 0;
   -- end

   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   self:skillActiveSkillSetter(event.unit,event.index);
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   -- if self.isRage then 
   --    skillIndex = 2
   -- end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
   return 1
end

--===================================================================================================================
--トリガー
function class:HPTriggersCheck(unit)
   if not self:getIsHost() then
      return;
   end

   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
   local priorityIndex = nil

   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == self.HP_FLG then
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

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
   if not self:getIsHost() then
      return
   end
   if index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end
   if receiveNumber == nil then
      receiveNumber = 3
   end

   local action = "use" .. receiveNumber

   self.TRIGGERS[index].action(action)
   self.TRIGGERS[index].used = true
   megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

--===================================================================================================================
-- バフ関係
--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit,buffBoxList,index)
    if index == nil then 
        self:addBuffRange(unit,buffBoxList,0,table.maxn(buffBoxList))
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