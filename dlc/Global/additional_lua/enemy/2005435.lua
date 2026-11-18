local Bootstrap, Color, Random, Utility, Vector2 = summoner.import("Bootstrap", "Color", "Random", "Utility", "Vector2")
local class = summoner.Bootstrap.createEnemyClass({label="ラグシェルム", version=1.3, id=2005435});
class:inheritFromUnit("unitBossBase");


--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50,
    ATTACK5 = 50
    -- ATTACK6 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    SKILL1 = 7,
    SKILL2 = 8,
    SKILL3 = 9
}


--------[[create]]--------
function class:createTable()
   self.glabEffect = {
      orbitSystem = nil,
      position = nil
   }
end

--------[[バフ]]--------
function class:setBuffBoxList()

  self.HP50_BUFF_LIST = {
    [1] = {
      ID = 20054351,
      BUFF_ID = 27,   -- ブレイク耐性
      VALUE = -50,
      DURATION = 99999,
      ICON = 0
    },
    [2] = {
      ID = 20054352,
      BUFF_ID = 21,
      VALUE = -50,
      DURATION = 99999,
      ICON = 0
    }
  }
end

----------[[メッセージ]]----------
function class:setMessageBoxList()
   self.HP50_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "ブレイク耐性",
         COLOR = Color.yellow,
         DURATION = 5
      },
      [2] = {
         MESSAGE = self.TEXT.HP50_MESSAGE2 or "ダメージ軽減",
         COLOR = Color.yellow,
         DURATION = 5
      }
  }
end

function class:subBars()
   self.subBar = BattleControl:get():createSubBar();
   self.subBar:setWidth(200); --バーの全体の長さを指定
   self.subBar:setHeight(13);
   self.subBar:setPercent(0); --バーの残量を0%に指定
   self.subBar:setVisible(false);
   self.subBar:setPositionX(0);
   self.subBar:setPositionY(150);
end

--------[[特殊行動]]--------
function class:setTriggersList()
   self.HP_FLG = "HP_FLG"
   self.HP_50 = 1
   self.HP_25 = 2

   self.TRIGGERS = {
      [self.HP_50] = {
         tag = self.HP_FLG,
         action = function (status) self:hpFlg50(status) end,
         HP = 50,
         used = false
      },
      [self.HP_25] = {
         tag = self.HP_FLG,
         action = function(status) self:hpFlg25(status) end,
         HP = 25,
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

-- status = use + receive番号
function class:hpFlg50(status)
   if status == "use3" then
      self.isRage = true
      self:showMessage(self.HP50_MESSAGE_LIST)
      self:addBuff(self.gameUnit,self.HP50_BUFF_LIST)
   end
end

function class:hpFlg25(status)
   if status == "use3" and not self.isGlab then
      self.isRage = true
      self:showMessage(self.HP50_MESSAGE_LIST)
      self:addBuff(self.gameUnit,self.HP50_BUFF_LIST)
   end
end

function class:tryGlab(unit)
   local index = unit:getHateTarget():getIndex() or 0;
   self:executeGlab(unit,index)
end

function class:executeGlab(unit,index)
   self.glabTarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(index)
   if self.glabTarget == nil then
      return
   end

   unit:getTeamUnitCondition():addCondition(-11,113,500,2000,0);
   self.isGlab = true;
   self.glabEffect.orbitSystem = unit:addOrbitSystem("lock-on");
   self.glabEffect.orbitSystem:takeAnimation(0,"lock-on",true);
   self.glabEffect.position = Vector2:new(self.glabTarget:getAnimationPositionX(),self.glabTarget:getAnimationPositionY())
   self.glabEffect.orbitSystem:setPosition(self.glabEffect.position.x,self.glabEffect.position.y);
   self.glabTarget:getTeamUnitCondition():addCondition(-10,89,1,14,0);
end

function class:glabEnd(unit)
   if not self.isGlab then
      return
   end
   if self.glabTarget ~= nil then
      self:removeCondition(self.glabTarget,-10)
      self.glabTarget = nil
   end
   self:removeCondition(unit,-11)
   self.dpsCounter = 0
   self.isGlab = false
   if self.glabEffect ~= nil then
      self.glabEffect.orbitSystem:takeAnimation(0,"none",false)
      self.glabEffect.orbitSystem = nil
   end
end

function class:glabControll(unit,deltaTime)
   if self.glabTarget ~= nil then
      local x = 150 + unit:getPositionX();
      local y = 464 + unit:getPositionY();
      local distance = Vector2.subtracts(Vector2:new(x,y),self.glabEffect.position)

      if self.SPEED * deltaTime >= math.abs(distance.magnitude) then
         self.glabEffect.position = self.glabEffect.position + distance
      else
         self.glabEffect.position = self.glabEffect.position + (distance:normalize() * self.SPEED * deltaTime)
      end

      
      self.glabEffect.orbitSystem:setPosition(self.glabEffect.position.x,self.glabEffect.position.y);
      self.glabTarget:setPosition(self.glabEffect.position.x - self.glabTarget:getSkeleton():getBoneWorldPositionX("MAIN"),self.glabTarget:getPositionY());
      self.glabTarget:getSkeleton():setPosition(0,self.glabEffect.position.y - self.glabTarget:getPositionY() - self.glabTarget:getSkeleton():getBoneWorldPositionY("MAIN"));

   end
end

function class:setSP0(unit)
   unit:setBurstPoint(0)
   self.isDPSCheck  = true
   self.dpsStartHP = unit:getHP()
   self.subBar:setVisible(true)
end

function class:removeCondition(unit,buffID)
   local buff = unit:getTeamUnitCondition():findConditionWithID(buffID);
   if buff ~= nil then
      unit:getTeamUnitCondition():removeCondition(buff);
   end
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

   self:createTable()
   self:setBuffBoxList()
   self:setMessageBoxList()
   self:setTriggersList()
   self:subBars()
   self.hitStop = 0.5
   self.isGlab = false
   self.isDPSCheck = false
   self.glabTarget = nil
   self.dpsStartHP = 0
   self.dpsCounter = 0
   self.damageParSecond = 29000
   self.SPEED = 300
   self.hateTargetRate = 1.4
   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   BattleControl:get():visibleHateTarget(true);
   BattleControl:get():setHateTargetIcon(14);

   event.unit:setEnableHate(true);
   event.unit:updateHateTarget();
   event.unit:addSP(100)
   return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "addSP" then self:addSP(event.unit) end
   if event.spineEvent == "tryGlab" then self:tryGlab(event.unit) end
   if event.spineEvent == "glabEnd" then self:glabEnd(event.unit) end
   if event.spineEvent == "setSP0" then self:setSP0(event.unit) end

   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(2,self.hitStop)
   self:HPTriggersCheck(event.unit)

   if self.isGlab then
      self:glabControll(event.unit,event.deltaTime);
   end

   if self.isDPSCheck then
      self:dpsChecker(event.unit)
   end
   return 1
end

function class:dpsChecker(unit)
   self.dpsCounter = self.dpsStartHP - unit:getHP()
   if self.dpsCounter >= self.damageParSecond then
      self.dpsCounter = 0
      unit:takeDamage()
   end

   self.subBar:setPositionX(unit:getPositionX())
   self.subBar:setPositionY(unit:getPositionY() + 250)
   self.subBar:setPercent(100 * 
      (self.damageParSecond - self.dpsCounter) / self.damageParSecond)

end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
   if self.isGlab then
      self.glabEnd(event.unit)
   end
   if self.isDPSCheck then
      self.isDPSCheck = false
      self.dpsCounter = 0
      self.subBar:setVisible(false)
   end

   return 1
end
---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   if self.isDPSCheck then
      self.dpsCounter = self.dpsStartHP - event.unit:getHP()
      if self.dpsCounter >= self.damageParSecond then
         event.unit:takeDamage()
      end
   end
   return event.value
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
   if event.enemy == event.unit:getHateTarget() then
      event.value = event.value * self.hateTargetRate;
   end
   return event.value
end

---------------------------------------------------------------------------------
-- executeAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
   event.unit:updateHateTarget();
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
   self.fromHost = false;
   self:attackActiveSkillSetter(event.unit,event.index);
   return 1
end

function class:attackReroll(unit)
   local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
   local attackIndex = string.gsub(attackStr,"ATTACK","");

   if self.isRage then
      self.isRage = false
      attackIndex = 6
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
   self.isDPSCheck = false
   self.subBar:setVisible(false)

   if not megast.Battle:getInstance():isHost() and not self.fromHost then
      event.unit:takeIdle();
   return 0;
   end

   self.skillCheckFlg = false;
   -- self.skillCheckFlg2 = false;
   self.fromHost = false;
   if event.index == 2 then
      self:removeCondition(self.gameUnit,self.HP50_BUFF_LIST[1].ID)
      self:removeCondition(self.gameUnit,self.HP50_BUFF_LIST[2].ID)
   end
   self:skillActiveSkillSetter(event.unit,event.index);
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   if self.isGlab then
      skillIndex = 2
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


class:publish();

return class;