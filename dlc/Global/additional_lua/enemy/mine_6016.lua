local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="鉱山デグルマグナ", version=1.9, id="mine_6016"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
   DEFAULT = {
      { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50 },
      { ATTACK4 = 50 },
      { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50 },
      { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50 },
      { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50, ATTACK4 = 50},
   }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
   DEFAULT = {
      { SKILL1 = 100 }
   }
}

class.ACTIVE_SKILLS = {
   ATTACK1 = 1,
   ATTACK2 = 2,
   ATTACK3 = 3,
   ATTACK4 = 4,
   ATTACK5 = 5,
   SKILL1 = 5,
   SKILL2 = 6
}

------ブレイク・ダメージ値---------
function class:setDamageBreakRateList()
   self.BreakRate = {
      [0] = 1.0,
      [1] = 0.8,
      [2] = 0.7,
      [3] = 0.4,
      [4] = 0.2,
      [5] = 0.1
   }

   self.DamageRate = {
      [0] = 0.05,
      [1] = 0.10,
      [2] = 0.3,
      [3] = 0.7,
      [4] = 1.0
   }
end

function class:setBuffBoxList()
   self.HP30_BUFF = {
      ID = 5000031,
      BUFF_ID = 132,
      VALUE = 99999,
      DURATION = 99999,
      ICON = 0
   }
   self.STUN_BUFF = {
      ID = 5000039,
      BUFF_ID = 89, -- 気絶
      VALUE = 99999,
      DURATION = 2,
      ICON = 79
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
         MESSAGE = self.TEXT.START_MESSAGE2 or "樹属性攻撃無効"
      }),
      [3] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE3 or "自身燃焼時クリティカル率アップ"
      }),
      [4] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE4 or "ブレイクするほど被ダメージアップ"
      })
   }

   self.BREAK_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ブレイク成功！被ダメージアップ！"
      })
   }
   self.BREAK_END_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.BREAK_END_MESSAGE1 or "ブレイク耐性アップ"
      })
   }
   self.BURN_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.BURN_MESSAGE1 or "燃焼してクリティカル率アップ",
         COLOR = Color.red
      })
   }
   self.HP30_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP30_MESSAGE1 or "奥義増加量アップ・ダメージ無効化無効"
      })
   }

   self.TIMEUP_BUFF_MESSAGE_LIST = {
      self:setMessageInfo({MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE1 or "攻撃力アップ",COLOR=Color.red}),
      self:setMessageInfo({MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE2 or "ダメージアップ",COLOR=Color.red})
   }

end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TIME_UP_ID = 4
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp30(status) end,
         HP = 30,
         used = false
      },
      [self.TIME_UP_ID] = {
         tag = "TIME_UP",
         action = function (status) self:timeUp(status) end,
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

function class:hp30(status)
   if status == "use3" then
      self.beforeSpValue = self.gameUnit:getBurstPoint()
      self.isSkill2 = true
      self.spValue = 40
      self.gameUnit:addSP(100)
      self.gameUnit:setAttackDelay(2)
      self:showMessage(self.HP30_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.HP30_BUFF)

      for i = 0,3 do
         local unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
         if unit ~= nil then
            self:execAddBuff(unit,self.STUN_BUFF)
         end
      end
   end
end

function class:timeUp(status)
   if status == "use3" then
      self:showMessage(self.TIMEUP_BUFF_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[1])
      self:execAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[2])
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
   self.cutInFLG = false;
   self.attack2FLG = false
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);
   event.unit:setAttackDelay(6)

   self.hpMarkers = {}
   self.isRage = false
   self.isFury = false
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()
   self:setDamageBreakRateList()

   self:initAttackWeight({DEFAULT = 100})
   self:initSkillWeight({DEFAULT = 100})
   self:showMessage(self.START_MESSAGE_LIST)
   self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない

   self.isLockOn = true
   self.neckAngle = 0
   self.neckAngleDeffault = 0
   self.shotAngle = 0
   self.isFireEnd = true

   self.BreakCount = 0; --ブレイク回数
   self.BreakFLG = false --ブレイク後、ブレイク終了までのフラグ
   self.BreakDamageCount = 0
   self.gameUnit:addNumBreakBadge(6)
   self.gameUnit:setSetupAnimationName("setUpNormal")
   self.isBurned = false
   self.breakTime = -1
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   if self.BreakFLG and event.unit.m_breaktime <= 0 and self.BreakCount < 6 then
      self.breakTime = -1
      self.BreakFLG = false
      self.BreakDamageCount = self.BreakCount
      self:showMessage(self.BREAK_END_MESSAGE_LIST)
   end

   if not self.isBurned and self:findBurn(event.unit) then
      self.isBurned = true
      self:showMessage(self.BURN_MESSAGE_LIST)
   end
   if not self:findBurn(event.unit) then
      self.isBurned = false
   end

   if self.isLockOn then
      self:attack5ArmControl(event.unit);
   end
   event.unit:setReduceHitStop(100,1)
   self:HPTriggersCheck(event.unit)
   self:setTimeUp()
   return 1
end

function class:setTimeUp()
   if BattleControl:get():getTime() > 180 and not self.TRIGGERS[self.TIME_UP_ID].used then
      self:execTrigger(self.TIME_UP_ID)
   end
end

function class:findBurn(unit)
   if unit:getTeamUnitCondition():findConditionWithType(97) or unit:getTeamUnitCondition():findConditionWithType(208) then
      return true
   end
   return false
end

function class:attack5ArmControl(unit)
   self:boneRotation(unit,"head");
   return 1;
end

function class:boneRotation(unit,boneName)
   if not self.isFireEnd then
      unit:getSkeleton():setBoneRotation(boneName,self:calcDeg(unit,boneName));
   else
      unit:getSkeleton():setBoneRotation(boneName,self:calcDegForEnd(unit,boneName));
   end
end


----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : ブレイク時。
-- 引数 : event.unit / 自ユニット
---------------------------------------------------------------------------------
function class:takeBreake(event)
   if event.unit.m_breaktime == 0 and self.breakTime < 0 then
      self.breakTime = 0
      self.BreakFLG = true
      self:showMessage(self.BREAK_MESSAGE_LIST)
      self.BreakCount = self.BreakCount + 1
      self.gameUnit:removeNumBreakBadge()
   end
   return 1
end

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- ブレイクごとにブレイクダメージ低下(5回まで)
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
   event.value = event.value * self.BreakRate[self.BreakDamageCount]

   return event.value
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- ブレイクごとにダメージ増加
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   if self.BreakCount < 5 then
      event.value = event.value * self.DamageRate[self.BreakCount]
   else
      local floatNum = (self.BreakCount - 4) / 10
      event.value = event.value * (1 + floatNum)
   end
   return event.value
end
---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "targetLock" then self:targetLock() end
   if event.spineEvent == "fire" then self:fire(event.unit) end
   if event.spineEvent == "setFire" then self:setFire(event.unit) end
   if event.spineEvent == "addSP" then self:addSP(event.unit) end
   if event.spineEvent == "startFire" then self:startFire(event.unit) end
   return 1
end

function class:targetLock()
   self.isLockOn = true
   self.neckAngle = 321
end

function class:fire(unit)
   local shot = unit:addOrbitSystem("fireball",1)
   shot:setActiveSkill(1);
   shot:setHitCountMax(1);
   shot:setEndAnimationName("explosion2")
   -- shot:EnabledFollow = true;
   local x = unit:getPositionX();
   local y = unit:getPositionY();
   local xb = unit:getSkeleton():getBoneWorldPositionX("EF_fire_mouth");
   local yb = unit:getSkeleton():getBoneWorldPositionY("EF_fire_mouth");
   shot:setPosition(x+xb,y+yb);
   -- getDeg(x+xb,y+yb,unit:getTargetUnit():getAnimationPositionX(),unit:getTargetUnit():getAnimationPositionY());
   shot:setRotation(self.neckAngle +90);
   self.shotAngle = self.neckAngle;
   shot:setZOrder(unit:getZOrder() -1);
   self.isFireEnd = true;
end

function class:setFire(unit)
   if not self.isRage then
      return 1;
   end
   local shot = unit:addOrbitSystem("firePiller",2)
   shot:setHitCountMax(999);
   shot:setEndAnimationName("fireEnd");
   -- shot:EnabledFollow = true;
   local x = unit:getPositionX();
   local y = unit:getPositionY();
   local xb = 0;
   local yb = 0;

   local rand = LuaUtilities.rand(0,5);

   if rand == 1 then
      xb = 300;
   elseif rand == 2 then
      xb = 350;
      yb = -100;
   elseif rand == 3 then
      xb = 400;
      yb = 50;
   elseif rand == 4 then
      xb = 500;
   elseif rand == 5 then
      xb = 600;
      yb = 100;
   end

   shot:setPosition(x+xb,y+yb);
   shot:setAutoZOrder(true);
   shot:setZOderOffset(-5000);
end

function class:startFire(unit)
   local headangle = unit:getSkeleton():getBoneRotation("head");
   self.neckAngle = headangle;
   self.neckAngleDeffault = headangle;
end

function class:excuteAction(event)
   self.isLockOn = false;
   self.isFireEnd = false;
   if self.isSkilled2 then
      self.isSkilled2 = false
      self.gameUnit:setBurstPoint(self.beforeSpValue)
   end
   return 1
end

function class:takeIdle(event)
   if not self.isRage then
      event.unit:setNextAnimationName("zcloneNidle");
   end
   return 1
end

function class:takeDamage(event)
   if not self.isRage then
      event.unit:setNextAnimationName("zcloneNdamage");
   end
   return 1
end

function class:dead(event)
   if not self.isRage then
      event.unit:setNextAnimationName("zcloneNout");
   end
   return 1
end

function class:takeBack(event)
   if not self.isRage then
      event.unit:setNextAnimationName("zcloneNback");
   end
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

   if event.index == 5 then
      self.isRage = true;
      event.unit:setSetupAnimationName("setUpFire");
   elseif not self.isRage then
      event.unit:setNextAnimationName("zcloneNattack" .. event.index)
   end
   return 1
end

function class:attackReroll(unit)
   local attackIndex = self:getAttackIndex()
   self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)

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
   self.cutInFLG = false
   self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
   self.fromHost = false;
   self:skillActiveSkillSetter(event.unit,event.index);
   if not self.isRage and event.index < 3 then
      event.unit:setNextAnimationName("zcloneNskill" .. event.index)
   end

   if event.index == 2 then
      self.isSkilled2 = true
   end
   return 1
end

function class:skillReroll(unit)
   local skillIndex = self:getSkillIndex()
   if not self.isRage and not self.isFury and not self.isFirst then
      self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
   end
   if self.isSkill2 then
      self.isSkill2 = false
      skillIndex = 2
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
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
   for i,value in ipairs({89,91,96}) do
      local condition = unit:getTeamUnitCondition():findConditionWithType(value)
      if condition ~= nil then
         unit:getTeamUnitCondition():removeCondition(condition);
      end
   end
end



function class:calcDeg(unit,boneName)
   local target = unit:getTargetUnit();
   if target ~= nil then
      local x = unit:getPositionX();
      local y = unit:getPositionY();
      local xb = unit:getSkeleton():getBoneWorldPositionX(boneName);
      local yb = unit:getSkeleton():getBoneWorldPositionY(boneName);
      local tx = target:getPositionX();
      local ty = target:getPositionY();
      local txb = target:getSkeleton():getBoneWorldPositionX("MAIN");
      local tyb = target:getSkeleton():getBoneWorldPositionY("MAIN");
      local targetangle = self:getDeg(x+xb,y+yb,tx+txb,ty+tyb) + 18;

      if targetangle < 0 then
         targetangle = 360 + targetangle;
      end

      local dir = targetangle - self.neckAngle;

      if dir > 180 then
         dir = -(360 - dir);
      end

      if dir < -180 then
         dir = (360 + dir);
      end

      if dir ~= 0 then
         local maxdir = 1 * unitManagerDeltaTime/0.016666667;
         if dir > maxdir then
            dir = maxdir;
         elseif dir < -maxdir then
            dir = -maxdir;
         end
      end
      self.neckAngle = self.neckAngle + dir;

      if self.neckAngle > 360 then
         self.neckAngle = self.neckAngle % 360;
      end

      if self.neckAngle < 0 then
         self.neckAngle = 360 - self.neckAngle;
      end

      if self.neckAngle < 270  and self.neckAngle > 180 then
         self.neckAngle = 270;
      elseif self.neckAngle > 90 and self.neckAngle <= 180 then
         self.neckAngle = 90;
      end
      return self.neckAngle;
   end
end

function class:calcDegForEnd()
   local targetangle = self.neckAngleDeffault;
   -- local angle = unit:getSkeleton():getBoneRotation(boneName);

   --local angle = this.neckAngle;
   if targetangle < 0 then
      targetangle = 360 + targetangle;
   end


   local dir = targetangle - self.neckAngle;

   if dir > 180 then
      dir = -(360 - dir);
   end

   if dir < -180 then
      dir = (360 + dir);
   end

   if dir ~= 0 then
      local maxdir = 1 * unitManagerDeltaTime/0.016666667;
      if dir > maxdir then
         dir = maxdir;
      elseif dir < -maxdir then
         dir = -maxdir;
      end
   end
   self.neckAngle = self.neckAngle + dir;

   if self.neckAngle > 360 then
      self.neckAngle = self.neckAngle % 360;
   end

   if self.neckAngle < 0 then
      self.neckAngle = 360 - self.neckAngle;
   end

   return self.neckAngle;
end


function class:getDeg(startx,starty,targetx,targety)
   return class:radToDeg(class:getRad(startx,starty,targetx,targety))

end

function class:getRad(startx,starty,targetx,targety)
   return math.atan2(targety-starty,targetx-startx)
end

function class:degToRad(deg)
   return deg * 3.14/180;
end

function class:radToDeg(rad)
   return rad * 180/3.14;
end


class:publish();

return class;