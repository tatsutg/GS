local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="女神", version=1.3, id="mine_50008"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    -- ATTACK3 = 50,
    ATTACK4 = 50,
    ATTACK5 = 50,
    ATTACK6 = 50,
    -- ATTACK7 = 50,
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 75,
    -- SKILL2 = 100,
    SKILL3 = 25
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 4,
    ATTACK4 = 3,
    ATTACK5 = 5,
    ATTACK6 = 6,
    ATTACK7 = 7,                    
    SKILL1 = 8,
    SKILL2 = 9,
    SKILL3 = 10
}

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = { 
      [1] = {
          ID = 60004,
          BUFF_ID = 1, -- オーラ用ダミー
          VALUE = 0,
          DURATION = 99999,
          ICON = 0
      }
   }

   self.HP50_BUFF_LIST = {
     [1] = {
         ID = 6000033,
         BUFF_ID = 13,      --攻撃力
         VALUE = 50,       --効果量
         DURATION = 9999999,
         ICON = 3
     },
     [2] = {
         ID = 6000036,
         BUFF_ID = 28,      --攻撃速度
         VALUE = 30,       --効果量
         DURATION = 9999999,
         ICON = 7
     }
   }

   self.TIMEUP_BUFF_BOX_LIST = {
     [1] = {
         ID = 5000033,
         BUFF_ID = 17,      --ダメージ
         VALUE = 500,       --効果量
         DURATION = 9999999,
         ICON = 26
     },
     [2] = {
         ID = 5000036,
         BUFF_ID = 13,      --攻撃力
         VALUE = 500,       --効果量
         DURATION = 9999999,
         ICON = 3
     }
   }
end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカル率アップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE3 or "クリティカルダメージアップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      },
      [3] = {
         MESSAGE = self.TEXT.START_MESSAGE4 or "クリティカルダメージ無効",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false        
      }      
   }

   self.HP50_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "攻撃力・行動速度アップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false
      }
   }

   self.KABAU_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.KABAU_MESSAGE1 or "被ダメージアップ",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false
      }
   }

   self.TIMEUP_BUFF_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE1,
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false         
      },
      [2] = {
         MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE2,
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false         
      }
  }
end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TID_TIME_UP = 1
   self.TRIGGERS = {
      [self.TID_TIME_UP] = {
         tag = "TIME_UP",
         action = function (status) self:timeUp(status) end,
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


function class:timeUp(status)
   if status == "use3" then
      self:addBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST)
      self:showMessage(self.TIMEUP_BUFF_MESSAGE_LIST)
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

   self.hitStop = 1
   self.isAttack3 = false
   self.isShowMessage = false
   self.telopSpan = 60
   self.showMessageTimer = 0
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()
   self:showMessage(self.START_MESSAGE_LIST)
   
   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
   return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    return 1;
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
  event.unit:setNextAnimationName("idle1")
  return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(2,self.hitStop)
   self:setTimeUp()
   self:switchSkill()
   self:telopCheck(event.deltaTime)
   return 1
end

function class:telopCheck(deltaTime)
    if self.showMessageTimer > self.telopSpan then
       self.showMessageTimer = 0
       self:showMessage(self.START_MESSAGE_LIST)
    else
       self.showMessageTimer = self.showMessageTimer + deltaTime
    end
end

function class:setTimeUp()
   if BattleControl:get():getTime() > 180 and not self.TRIGGERS[self.TID_TIME_UP].used then
      self:execTrigger(self.TID_TIME_UP)
   end
end

function class:switchSkill()
   if self.checkProtect() then
      self.isProtect = true

      if not self.isShowMessage then
         self.isShowMessage = true
         self:showMessage(self.KABAU_MESSAGE_LIST)
      end
   else
      if self.isAttack3 then
         self.isAttack3 = false
      end
      self.isProtect = false
   end
end

function class:checkProtect()
    local isCheck = false
    for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if localUnit ~= nil then
            local checkUnit = localUnit:getTeamUnitCondition():findConditionWithType(128)
            if checkUnit ~= nil then
              isCheck = true
            end
        end
    end

    return isCheck

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

   if self.isProtect and not self.isAttack3 then
      attackIndex = 3
      self.isAttack3 = true
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
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
   return 1
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

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end


class:publish();

return class;
