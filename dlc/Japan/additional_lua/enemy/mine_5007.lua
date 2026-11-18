local Vector2 = summoner.import("Vector2")
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="イフリート", version=1.3, id="mine_50007"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 3,
    ATTACK2 = 1,
    ATTACK3 = 3,
    ATTACK4 = 3
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    -- SKILL1 = 100,
    SKILL2 = 100,
    SKILL3 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7
}



function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [0] = {
          ID = 60004,
          BUFF_ID = 1, -- オーラ用ダミー
          VALUE = 0,
          DURATION = 99999,
          ICON = 0
       },
       [1] = {
          ID = 600042,
          BUFF_ID = 97, -- 開幕自身燃焼
          VALUE = 100,
          DURATION = 99999,
          ICON = 87,
          GROUP_ID = 91,
          PRIORITY = 50
        },
       [2] = {
          ID = 600043,
          BUFF_ID = 97, -- 開幕相手燃焼
          VALUE = 1000,
          DURATION = 99999,
          ICON = 87
       }
    }
   self.MINE_BUFF_BOX_LIST = {
     [0] = {
         ID = 5000031,
         BUFF_ID = 31,      --回避率アップ
         VALUE = math.atan(megast.Battle:getInstance():getCurrentMineFloor()*0.05)*2/math.pi*200+5,       --効果量
         DURATION = 9999999,
         ICON = 16
     },
     [1] = {
         ID = 5000032,
         BUFF_ID = 27,      --ブレイク耐性
         VALUE = -5,
         DURATION = 99999,
         ICON = 0
     }
   }

   self.TIMEUP_BUFF_BOX_LIST = {
     [0] = {
         ID = 5000033,
         BUFF_ID = 17,      --ダメージ
         VALUE = 500,       --効果量
         DURATION = 9999999,
         ICON = 26,
         isTimer = true
     },
     [1] = {
         ID = 5000036,
         BUFF_ID = 13,      --攻撃力
         VALUE = 500,       --効果量
         DURATION = 9999999,
         ICON = 3,
         isTimer = true
     }
   }


end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TID_TIME_UP = 2
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp50(status) end,
         HP = 50,
         used = false
      },
      [self.TID_TIME_UP] = {
         tag = "TIME_UP",
         action = function (status) self:timeUp(status) end,
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

function class:hp50(status)
   if status ==  "use3" then
      self.isRage = true
      self.gameUnit:addSP(100)
      -- self:showMessage(self.HP50_MESSAGE_LIST)
   end
end

function class:timeUp(status)
   if status == "use3" then
      self:addBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST)
      self:showMessage(self.TIMEUP_BUFF_MESSAGE_LIST)
   end
end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.BUFF_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.BUFF_MESSAGE2,
         COLOR = Color.red,
         DURATION = 5
      }      
   }

   self.TIMEUP_BUFF_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE1,
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false         
      },
      [1] = {
         MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE2,
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false         
      }
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

   self.ADD_BASE_VALUE = -2
   self.hitStop = math.floor((megast.Battle:getInstance():getCurrentMineFloor() - 1) / 5) * 0.2 
   self.addBuffValue = self:multiply(self.ADD_BASE_VALUE)

   self.SLICE_RATIO = 0.5
   self:setTriggerList()
   self:setMessageBoxList()
   self:setBuffBoxList()
   self.telopSpan = 60
   self.showMessageTimer = 0


   return 1
end


function class:multiply(multiplier)
   local buffValue = (multiplier * megast.Battle:getInstance():getCurrentMineFloor())
   return buffValue
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   self:execAddBuff(event.unit,self.BUFF_BOX_LIST[0])
   return 1
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:HPTriggersCheck(event.unit)
   self:setTimeUp()
   self:telopCheck(event.deltaTime)
   event.unit:setReduceHitStop(2,self.hitStop)   
   return 1
end

function class:setTimeUp()
   if BattleControl:get():getTime() > 180 and not self.TRIGGERS[self.TID_TIME_UP].used then
      self:execTrigger(self.TID_TIME_UP)
   end
end

function class:telopCheck(deltaTime)
    if self.showMessageTimer > self.telopSpan then
       self.showMessageTimer = 0
       self:showMessage(self.BUFF_MESSAGE_LIST)
    else
       self.showMessageTimer = self.showMessageTimer + deltaTime
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "InTheBurst" then
      self:sliceHP()
      self:showMessage(self.BUFF_MESSAGE_LIST)
   end
   return 1
end

function class:sliceHP()
   self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1]);
   for i = 0,3 do
      local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
      if localUnit ~= nil then
         local shavedHPValue = localUnit:getHP() - (localUnit:getHP() * self.SLICE_RATIO)
         localUnit:setHP(shavedHPValue)
         self:execAddBuff(localUnit,self.BUFF_BOX_LIST[2]);
      end  
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

   if self.isRage then
      self.isRage = false
      skillIndex = 1
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

function class:execAddBuff(unit,buffBox)
  local buff  = nil;
  local correction = buffBox.isTimer and buffBox.VALUE or self.addBuffValue + buffBox.VALUE

  if buffBox.EFFECT ~= nil then
    buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,correction,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
  else
    buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,correction,buffBox.DURATION,buffBox.ICON);
  end
  if buffBox.SCRIPT ~= nil then
    buff:setScriptID(buffBox.SCRIPT);
  end
  if buffBox.SCRIPTVALUE1 ~= nil then
    buff:setValue1(buffBox.SCRIPTVALUE1);
  end

  if buffBox.GROUP_ID ~= nil then
    local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
    if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
       unit:getTeamUnitCondition():removeCondition(cond);
       buff:setGroupID(buffBox.GROUP_ID);
       buff:setPriority(buffBox.PRIORITY);
    elseif cond == nil then
       buff:setGroupID(buffBox.GROUP_ID);
       buff:setPriority(buffBox.PRIORITY);
    end
  end

end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
    self.TRIGGERS[args.arg].used = true
    if self.TRIGGERS[args.arg].used == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
   return 1
end


class:publish();

return class;
