local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="闇堕ち光ドラ", version=1.3, id=600000028});
class:inheritFromUnit("unitBossBase")


--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
   -- ATTACK1 = 20,
   ATTACK2 = 30,
   ATTACK3 = 30,
   ATTACK4 = 30,
   -- ATTACK5 = 20,
   ATTACK6 = 10
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 50,
    SKILL2 = 50
}

class.ACTIVE_SKILLS = {
    -- ATTACK1 = 1,
    ATTACK2 = 1,
    ATTACK3 = 2,
    ATTACK4 = 3,
    ATTACK5 = 4,
    ATTACK6 = 5,
    SKILL1 = 6,
    SKILL2 = 7
}

function class:setTriggerList()
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp50(status) end,
         HP = 50,
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
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.HP_TRIGGERS[index] = trigger
      end
   end
end

function class:hp50(status) 
   if status == "use3" then
      self:showMessage(self.HP50_MESSAGE_LIST)
      self:addBuff(self.gameUnit,self.HP50_BUFF_BOX_LIST)
      self.isRage = true
   end
end

function class:hp30(status) 
   if status == "use3" then
      self:showMessage(self.HP30_MESSAGE_LIST)
      self.spValue = 50
      self.isRage = true
   end
end

--------[[バフ]]--------
function class:setBuffBoxList()

  -- ブレイク耐性
  self.BREAK_RESISTANCE_LIST = {
    [0] = {
      ID = 5013315131,
      BUFF_ID = 27,
      VALUE = 20,
      DURATION = 99999,
      ICON = 0
    },
    [1] = {
      ID = 5013315133,
      BUFF_ID = 27,
      VALUE = 40,
      DURATION = 99999,
      ICON = 0
    },
    [2] = {
      ID = 5013315134,
      BUFF_ID = 27,
      VALUE = 80,
      DURATION = 99999,
      ICON = 0
    }
  }

   self.TARGET_BUFF_BOX_LIST = {
      [0] = {
      ID = 5013315135,
      BUFF_ID = 17, -- ダメージ
      VALUE = 50,
      DURATION = 999999,
      ICON = 26
    }
   }

   self.HP50_BUFF_BOX_LIST = {
      [0] = {
      ID = 5013315136,
      BUFF_ID = 17, -- ダメージ
      VALUE = 30,
      DURATION = 999999,
      ICON = 26
    }
   }
end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "相手の回復量低下",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false        
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "ブレイクダメージを受ける程、被ダメージアップ",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false        
      },
      [3] = {
         MESSAGE = self.TEXT.START_MESSAGE3 or "回避率アップ",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false        
      }      
   }

   self.HP50_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "与ダメージアップ",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false              
      }
   }

   self.HP30_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP30_MESSAGE1 or "奥義ゲージ速度アップ",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false              
      }
   }

   self.TARGET_MESSAGE = {
     MESSAGE = self.TEXT.TARGET or "ボスに狙われている！",
     COLOR = Color.red,
     DURATION = 10,
     isPlayer = false
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

   self:setBuffBoxList()
   self:setMessageBoxList()
   self:setTriggerList()
   self.strageBreakValue = 0
   self.DIVIDE_POINT = 10000
   self.isRage = false

   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   self.breakNumberOrbit =  self.gameUnit:addOrbitSystemWithFile("breakNumber","0");
   for i = 0,6 do 
      self.breakNumberOrbit:takeAnimation(i,"0",true);
   end
   self.breakNumberOrbit:setPosition(-160,450)
   self.breakNumberOrbit:setScaleX(1.45)
   self.breakNumberOrbit:setScaleY(1.45)
   self.breakNumberOrbit:setZOrder(10011)
   self:showMessage(self.START_MESSAGE_LIST)
   return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "addSP" then
      self:addSP(event.unit)
   end
   return 1
end

function class:addSP(unit)  
   unit:addSP(self.spValue);
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(2, 1)
   self:HPTriggersCheck(event.unit)
   
   if self.breakNumberOrbit ~= nil then
     self:viewTotalBreak(math.floor(self.strageBreakValue),(#tostring(math.floor(self.strageBreakValue))) - 1)
   end
   
   if self.strageBreakValue / self.DIVIDE_POINT >= 1 then
      local value = math.floor(self.strageBreakValue / self.DIVIDE_POINT) * 10
      -- 被ダメージアップ
      event.unit:getTeamUnitCondition():addCondition(99999,21,value,99999,6);
   end
   return 1
end

function class:viewTotalBreak(breakDamage,layer)
   if layer < 0 then
      return
   end

   local cardinal = 10 ^ layer
   local multiply = 0
   if breakDamage - cardinal >= 0 then
      multiply =  tonumber(string.match(tostring(breakDamage),"^."))
   end
   local animationNum = cardinal * multiply
   local animationStr = animationNum ~= 0 and tostring(animationNum) or string.format( "%0" .. (layer + 1) .."d", 0 )
   local nokori = breakDamage - animationNum

   self.breakNumberOrbit:takeAnimation(layer,animationStr,true)
   self:viewTotalBreak(nokori,layer - 1)
end


---------------------------------------------------------------------------------
-- takeBreakeDamageValue
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
   self.strageBreakValue = self.strageBreakValue + event.value
   return event.value
end

-- バフ削除
function class:removeCondition(unit,buffId)
  if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
    unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
  end  
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


---------------------------------------------------------------------------------
-- executeAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
  self:checkTarget()
  self:checkBreak(event.unit)

  return 1
end

-- 被ターゲット判定
function class:checkTarget()
  if not self.isTarget and self:getIsTarget() then
    self:addBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST)
    self:execShowMessage(self.TARGET_MESSAGE)
  end
  if self:getIsTarget() then
    BattleControl:get():showHateAll()
  else
    BattleControl:get():hideHateAll(); 
    self:removeCondition(self.gameUnit,self.TARGET_BUFF_BOX_LIST[0].ID)    
  end
  self.isTarget = self:getIsTarget();
end

function class:getIsTarget()
  return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > 1000000;
end

function class:checkBreak(unit)
  if not megast.Battle:getInstance():isRaid() then
    return;
  end

  if RaidControl:get():getRaidBreakCount() >= 1 then
    self:addBuff(unit,self.BREAK_RESISTANCE_LIST,0)
  end
  if RaidControl:get():getRaidBreakCount() >= 2 then
    self:addBuff(unit,self.BREAK_RESISTANCE_LIST,1)
  end
  if RaidControl:get():getRaidBreakCount() >= 3 then
    self:addBuff(unit,self.BREAK_RESISTANCE_LIST,2)
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

function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

class:publish();

return class;
