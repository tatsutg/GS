--@additionalEnemy,2004444
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="14階_光ドラゴン", version=1.3, id=2004443});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
   DEFAULT = {
      { ATTACK2 = 50 },
      { ATTACK3 = 50 },
      { ATTACK1 = 50,ATTACK4 = 50,ATTACK5 = 50 },
      { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50,ATTACK4 = 50,ATTACK5 = 50 },
      { ATTACK1 = 50,ATTACK4 = 50,ATTACK5 = 50 }
   }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
   DEFAULT = {
      { SKILL2 = 100 },
      { SKILL1 = 100 },
      { SKILL1 = 100 }
   }
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

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 20044431,
         BUFF_ID = 13, --攻撃力
         VALUE = 30,
         DURATION = 99999,
         ICON = 3
      },
      [2] = {
         ID = 20044432,
         BUFF_ID = 15, --防御力
         VALUE = 30,
         DURATION = 99999,
         ICON = 5
      },
      [3] = {
         ID = 20044433,
         BUFF_ID = 0, --奥義ゲージ
         VALUE = 0,
         DURATION = 99999,
         ICON = 36
      }
   }
end

function class:setBuffBoxListHeal(value)
   value = value > 10 and 10 or value
   local buffBox = {
      ID = 20044434,
      BUFF_ID = 126, --被回復
      VALUE = 0,
      DURATION = 99999,
      ICON = 162,
      COUNT = value,
      MAX = 10
   }
   if value == 1 then
      buffBox.VALUE = 50
   elseif value == 2 then
      buffBox.VALUE = 70
   else
      buffBox.VALUE = 50 + (value * 10)
   end
   buffBox.VALUE = buffBox.VALUE * -1
   return buffBox
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
   local message = {
      MESSAGE = messageBox.MESSAGE or "メッセージ",
      COLOR = messageBox.COLOR or Color.yellow,
      DURATION = messageBox.DURATION or 7,
      isPlayer = messageBox.isPlayer or false
   }
   return message
end

function class:setMessageBoxList()

   self.START_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"
      }),
      [2] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE2 or "魔族キラー"
      })
   }

   self.HP70_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP70_MESSAGE1 or "攻撃力アップ"
      })
   }
   self.HP50_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "防御力アップ"
      })
   }
   self.HP20_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP20_MESSAGE1 or "奥義ゲージ上昇量アップ"
      })
   }
   self.SUMMON_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "グロヴォーグが加勢した！",
         COLOR = Color.red
      })
   }
end

--------[[特殊行動]]--------
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
         action = function (status) self:hp20(status) end,
         HP = 20,
         used = false
      }
   }

   self.HP_TRIGGERS = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.HP_TRIGGERS[index] = trigger
         self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
      end
   end
end


function class:hp70(status)
   if status == "use3" then
      self.gameUnit:addSP(100)
      self:showMessage(self.HP70_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
      self.gameUnit:setInvincibleTime(10)
   end
end

function class:hp50(status)
   if status == "use3" then
      self.gameUnit:addSP(100)
      self:showMessage(self.HP50_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
      self.gameUnit:setInvincibleTime(10)
   end
end

function class:hp20(status)
   if status == "use3" then
      self.gameUnit:addSP(100)
      self:showMessage(self.HP20_MESSAGE_LIST)
      self.spValue = 40
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
      self.gameUnit:setInvincibleTime(10)
   end
end


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.fromHost = false;
   self.gameUnit = event.unit;
   self.spValue = 30;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;
   self.cutInFLG = false;
   self.attack2FLG = false
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);
   event.unit:setAttackDelay(3);

   self.hpMarkers = {}
   self.isRage = false
   self.isFury = false
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()

   self.skill2Count = 0
   self.timer = 0
   self.LIMIT = 350
   self.beforeIndex = 0

   self:initAttackWeight({DEFAULT = 100})
   self:initSkillWeight({DEFAULT = 100})
   self:showMessage(self.START_MESSAGE_LIST)
   self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない

   self.isLockOn = true
   self.neckAngle = 0
   self.shotAngle = 0
   self.isFireEnd = true

   self.gameUnit:addSP(40)

   return 1
end

function class:startWave(event)
   self.isWaved = true
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(100,1)
   self:HPTriggersCheck(event.unit)
   self:checkTimer(event.unit,event.deltaTime)
   return 1
end

function class:checkTimer(unit,deltaTime)
   if not self.isWaved then return end

   if self.LIMIT < (self.timer + deltaTime) * self:checkUnit(unit) then
      self.timer = 0
      self:summon(unit,2004444)
      self:showMessage(self.SUMMON_MESSAGE_LIST)
      return
   end
   self.timer = self.timer + deltaTime
end

function class:checkUnit(unit)
   local count = 5
   for i = 0,7 do
      local localUnit = megast.Battle:getInstance():getTeam(false):getTeamUnit(i)
      if localUnit ~= nil and localUnit ~= unit then
         count = count - 1
      end
   end
   return count <= 0 and -1 or count ^ 2
end

function class:summon(unit,enemyID)
   for i = 0, 7 do
      if unit:getTeam():getTeamUnit(i) == nil then
         unit:getTeam():addUnit(i,enemyID);  --指定したインデックスの位置に指定したエネミーIDのユニットを出す
         return
      end
   end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "targetLock" then self:targetLock() end
   if event.spineEvent == "fire" then self:fire(event.unit) end
   if event.spineEvent == "addSP" then self:addSP(event.unit) end
   return 1
end

function class:targetLock()
   self.isLockOn = true
   self.neckAngle = 295
end

function class:fire(unit)
   local shot = unit:addOrbitSystem("fireball",1)
   shot:setActiveSkill(1);
   shot:setHitCountMax(1);
   shot:setEndAnimationName("explosion")
   -- shot:EnabledFollow = true;

   local x = unit:getPositionX();
   local y = unit:getPositionY();
   local xb = unit:getSkeleton():getBoneWorldPositionX("EF_fire_mouth");
   local yb = unit:getSkeleton():getBoneWorldPositionY("EF_fire_mouth");
   shot:setPosition(x+xb,y+yb);
   -- getDeg(x+xb,y+yb,unit:getTargetUnit():getAnimationPositionX(),unit:getTargetUnit():getAnimationPositionY());
   shot:setRotation(-self.neckAngle);
   self.shotAngle = self.neckAngle;
   shot:setZOrder(unit:getZOrder() -1);
   self.isFireEnd = true
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
   ---奥義直後の通常攻撃ではaddSPしない---
   if self.addSpSkipFLG then
      self.addSpSkipFLG = false
      self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
   self.gameUnit:setInvincibleTime(0)
   elseif not self.addSpSkipFLG then
      --self:addSP(event.unit);
   end
   if event.index == 5 then
      event.unit:setNextAnimationName("attack5_2")
   end
   -----------------------------------
   return 1
end

function class:attackReroll(unit)
   local attackIndex = self:getAttackIndex()
   ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時、movePatternState()を動かさない---
   --if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
      self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
   --end
   --------------------------------------------------------------------------------------
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

   if event.index == 2 then
      self.skill2Count = self.skill2Count + 1
      for i = 0,7 do
         local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
         if localUnit ~= nil then
            self:execAddBuff(localUnit,self:setBuffBoxListHeal(self.skill2Count))
         end
      end
   end

   self.skillCheckFlg = false;
   self.cutInFLG = false
   self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
   self.fromHost = false;
   self:skillActiveSkillSetter(event.unit,event.index);
   return 1
end


function class:skillReroll(unit)
   local skillIndex = self:getSkillIndex()
   if not self.isRage and not self.isFury and not self.isFirst then
      self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   event.value = self:adjustHpFlg(event.unit,event.value)
   return event.value
end

function class:adjustHpFlg(unit,value)
   local anotherHp = unit:getHP() - value
   for _,trigger in pairs(self.HP_TRIGGERS) do
      local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
      if not trigger.used and stopBorder >= anotherHp then
         self:refresh(self.gameUnit) ---停止系状態異常除去(このタイミングでないとたまにバグる)
      return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value)
      end
   end
   return value
end

function class:calcDamageValue(unit,border)
   return unit:getHP() - border + 1
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
   for i = 1,table.getn(self.HP_TRIGGERS) do
      local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
      if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
         return 0
      end
   end
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
   for _,messageBox in ipairs(messageBoxList) do
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
-- receive3(トリガー時ゲスト側)
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
      buff:setMaxConditionIconNumber(buffBox.MAX);
      buff:setNumber(buffBox.COUNT);
      buffBox.COUNT = buffBox.COUNT < buffBox.MAX and buffBox.COUNT + 1 or buffBox.MAX
      megast.Battle:getInstance():updateConditionView();
   end
end

function class:movePatternState(SET_LIST,stateBox)
   stateBox.actCount = stateBox.actCount + 1
   if #SET_LIST[stateBox.setChar] < stateBox.actCount then
      stateBox.actCount = 1
      stateBox.setCount = stateBox.setCount + 1
      if #stateBox.SET_WEIGHT < stateBox.setCount then
         stateBox.setCount = 1
      end
      stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount])
   end
end

class.STATE_ATTACK = {}
function class:initAttackWeight(...)
   --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
   local attackList = {...}
   self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

function class:getAttackIndex()
   local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
   local attackIndex = string.gsub(attackStr,"ATTACK","");
   return tonumber(attackIndex)
end


class.STATE_SKILL = {}
function class:initSkillWeight(...)
   local skillList = {...}
   self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
   local skillIndex = string.gsub(skillStr,"SKILL","");
   return tonumber(skillIndex)
end

function class:initState(weightList)
   local state = {}
   state.SET_WEIGHT = weightList
   state.actCount = 1
   state.setCount = 1
   state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount])
   return state
end
---トリガー時停止系状態異常除去---
function class:refresh(unit)
   --for i,value in ipairs({89,91,96}) do
   --   local condition = unit:getTeamUnitCondition():findConditionWithType(value)
   --   if condition ~= nil then
   --      unit:getTeamUnitCondition():removeCondition(condition);
   --   end
   --end
end

class:publish();

return class;