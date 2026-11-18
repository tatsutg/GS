--@additionalEnemy,600000023,600000024,600000025,600000026,600000027
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="女神", version=1.3, id=501261413});
class:inheritFromUnit("unitBossBase")


--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
   ATTACK1 = 20,
   ATTACK2 = 20,
   ATTACK3 = 20,
   ATTACK4 = 20,
   ATTACK5 = 20,
   ATTACK6 = 20
   -- ATTACK7 = 20
   -- ATTACK8 = 20
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 50,
    -- SKILL2 = 50,
    SKILL3 = 50
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    ATTACK7 = 7,   
    -- ATTACK8 = 8,   
    SKILL1 = 8,
    -- SKILL2 = 9,
    SKILL3 = 10
}


--------[[ユニット召喚の準備]]--------
function class:setSpiderConf()
   self.ENEMYS = {
   }
end

--------[[特殊行動フラグ]]--------
function class:setTriggersList()
   self.HP_FLG = "HP_FLG"
   self.HP_40 = 0

   self.TRIGGERS = {
      [self.HP_40] = {
         tag = self.HP_FLG,
         action = function (status) self:hpFlg40(status) end,
         timing = 40,
         used = false
      }
   }
end

function class:hpFlg40(status)
   if status == "use" then
      self:addBuff(self.gameUnit,self.BUFF_BOX_LIST)
      self:showMessage(self.RAGE_MESSAGE_LIST)
   end
end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.START_MESSAGE3 or "命中率アップ",
         COLOR = Color.yellow,
         DURATION = 10         
      }
   }

   self.RAGE_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.RAGE_MESSAGE or "行動速度アップ",
         COLOR = Color.yellow,
         DURATION = 10         
      }
   }

   self.BREAK_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.BREAK_MESSAGE or "ブレイク時被ダメージアップ",
         COLOR = Color.yellow,
         DURATION = 10        
      }
   }
end

--------[[バフ]]--------
function class:setBuffBoxList()
  self.BUFF_BOX_LIST = {
    [0] = {
      ID = 60000171,
      BUFF_ID = 28, -- 行動速度UP
      VALUE = 20,
      DURATION = 999999,
      ICON = 34
    }
  }

  -- ブレイク耐性
  self.BREAK_RESISTANCE_LIST = {
    [0] = {
      ID = 60000172,
      BUFF_ID = 27,
      VALUE = 20,
      DURATION = 99999,
      ICON = 0
    },
    [1] = {
      ID = 60000173,
      BUFF_ID = 27,
      VALUE = 40,
      DURATION = 99999,
      ICON = 0
    },
    [2] = {
      ID = 60000174,
      BUFF_ID = 27,
      VALUE = 80,
      DURATION = 99999,
      ICON = 0
    }
  }
  
   self.TARGET_BUFF_BOX_LIST = {
      [0] = {
      ID = 60000175,
      BUFF_ID = 17, -- ダメージ
      VALUE = 50,
      DURATION = 999999,
      ICON = 26
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
   self:setSpiderConf()
   self:setMessageBoxList()
   self:setBuffBoxList()
   self:setTriggersList()


   self.spiderTimer = 0
   self.SUMMON_SPIDER_SPAN = 120
   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   self:showMessage(self.START_MESSAGE_LIST)
   self:setSummonSpider(event.unit)
   self:summonSpider(event.unit)
   return 1
end

function class:setSummonSpider(unit)
   self:setSpiderConf() 
   local count = 0
   for i = 0,3 do
      local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
      if uni ~= nil then
         local spiderID = self:selectSpiderElement(uni)
         self.ENEMYS[count] = spiderID
         count = count + 1
      end
   end
end

function class:selectSpiderElement(unit)
   local spiderID = 0
   if unit:getElementType() ==  kElementType_Fire then
      spiderID = 600000023
   end
   if unit:getElementType() ==  kElementType_Aqua then
      spiderID = 600000024
   end
   if unit:getElementType() ==  kElementType_Earth then
      spiderID = 600000025
   end
   if unit:getElementType() ==  kElementType_Light then
      spiderID = 600000026
   end
   if unit:getElementType() ==  kElementType_Dark then
      spiderID = 600000027
   end

   return spiderID
end

function class:summonSpider(unit)
   local cnt = 0;
   for i = 0, 6 do
      if unit:getTeam():getTeamUnit(i) == nil then
         local index = math.random(0,table.maxn(self.ENEMYS))
         local enemyID = self.ENEMYS[tonumber(index)];
         unit:getTeam():addUnit(i,enemyID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
         break;
      end
   end
end

function class:takeBreake(event)
  self:showMessage(self.BREAK_MESSAGE_LIST)
  return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(2, 1)
   self:spiderChecker(event.unit,event.deltaTime)
   self:HPTriggersCheck(event.unit)
   return 1
end

function class:spiderChecker(unit,deltaTime)
   if self.spiderTimer < self.SUMMON_SPIDER_SPAN then
      self.spiderTimer = self.spiderTimer + deltaTime
   elseif unit:getUnitState() ~= kUnitState_skill and unit:getUnitState() ~= kUnitState_skillwait then
      self.spiderTimer = 0
      self:setSummonSpider(unit)
      self:summonSpider(unit)
   end
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
    summoner.Utility.messageByEnemy(self.TEXT.mess1,10,Color.red);
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

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
  event.unit:setNextAnimationName("idle1")
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

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
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

-- バフ削除
function class:removeCondition(unit,buffId)
  if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
    unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
  end  
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
-- function class:receive3(args)
--    self.TRIGGERS[args.arg].action(self.currentAction)
--    return 1
-- end

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
function class:execTrigger(index,action)
   if not self:getIsHost() then
      return
   end

   if index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end

   self.currentAction = action == nil and "use" or action

   self.TRIGGERS[index].action(self.currentAction)
   self.TRIGGERS[index].used = true
   -- megast.Battle:getInstance():sendEventToLua(self.scriptID,3,index)
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end


class:publish();

return class;
