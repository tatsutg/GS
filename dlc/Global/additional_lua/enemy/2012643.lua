local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="魔獣", version=1.3, id=2012643})
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100,
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
  ATTACK1 = 1,
  ATTACK2 = 2,
  ATTACK3 = 3,
  ATTACK4 = 4,
  ATTACK5 = 5,
  SKILL1 = 6,
  SKILL2 = 7
}

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
      },

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

function class:hp70(status)
   if status ==  "use3" then
      self.isRage = true
      self.gameUnit:setSkin("rage")
      self.gameUnit:setBurstPoint(0)
      self.gameUnit:getTeamUnitCondition():addCondition(5213133,0,1,999999,0,50009)
      self:showMessage(self.HP70_MESSAGE_LIST)
   end
end

function class:hp50(status)
   if status ==  "use3" then
      self:execAddBuff(self.gameUnit,self.HP50_BUFF_BOX)
      self:showMessage(self.HP50_MESSAGE_LIST)
   end
end

function class:hp30(status)
   if status ==  "use3" then
      self:execAddBuff(self.gameUnit,self.HP30_BUFF_BOX)
      self:showMessage(self.HP30_MESSAGE_LIST)
   end
end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "水属性ダメージ50%軽減",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "状態異常攻撃（燃焼・氷結・封印以外）",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      }
   }

   self.HP70_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP70_MESSAGE1 or "怒り状態：奥義ゲージ減少攻撃",
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

   self.HP30_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP30_MESSAGE1 or "行動速度アップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      }
   }

end

--------[[バフ]]--------
function class:setBuffBoxList()
   self.HP50_BUFF_BOX = {
      ID = 5213131,
      BUFF_ID = 17, -- ダメージ
      VALUE = 30,
      DURATION = 999999,
      ICON = 26
   }
   self.HP30_BUFF_BOX = {
      ID = 5213132,
      BUFF_ID = 28, -- 行動速度
      VALUE = 30,
      DURATION = 999999,
      ICON = 7
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

   return 1
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:HPTriggersCheck(event.unit);
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
   -- self:addSP(event.unit);
   return 1
end

function class:attackReroll(unit)
   local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
   local attackIndex = string.gsub(attackStr,"ATTACK","");

   if self.isRage then
      self.isRage = false
      attackIndex = 5
   end

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
   for i,messageBox in pairs(messageBoxList) do
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
   for i,buffBox in pairs(buffBoxList) do
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

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].used = true
   self.TRIGGERS[args.arg].action("use3")
   self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
   return 1
end


class:publish();

return class;