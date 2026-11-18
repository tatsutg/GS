local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="闇ドラ", version=1.3, id=2018131});
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

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 20157501,
         BUFF_ID = 15, -- 防御力
         VALUE = 100,
         DURATION = 999999,
         ICON = 5
      },
      [2] = {
         ID = -99,
         BUFF_ID = 89, -- スタン
         VALUE = 100,
         DURATION = 0.1,
         ICON = 0         
      },
      [3] = {
         ID = 500151,
         BUFF_ID = 114, -- HP減少
         VALUE = 333,
         DURATION = 15,
         ICON = 0
      },
      [4] = {
         ID = 500152,
         BUFF_ID = 28, -- 行動速度
         VALUE = 50,
         DURATION = 999999,
         ICON = 7
      },
      [5] = {
         ID = 500153,
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
         MESSAGE = self.TEXT.START_MESSAGE1 or "魔法耐性アップ・物理耐性ダウン",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカル無効",
         COLOR = Color.yellow,
         DURATION = 5,
         isPlayer = false
      }   
  }

   self.HP70_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP70_MESSAGE1 or "行動速度アップ",
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
         action = function (status) self:hp30(status) end,
         HP = 30,
         used = false
      }
   }

   self.HP_TRIGGERS = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         trigger.hpMarker = self.gameUnit:addNumHpMarker(trigger.HP * 0.01)
         self.HP_TRIGGERS[index] = trigger
      end
   end
end

function class:hp70(status)
   if status == "use3" then
      self:showMessage(self.HP70_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
   end
end

function class:hp50(status)
   if status == "use3" then
      self:showMessage(self.HP50_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[5])
   end
end

function class:hp30(status)
   if status == "use3" then
      self:showMessage(self.HP30_MESSAGE_LIST)
      self.hitStop = 0.8
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

   self.isRage = false
   self.isFury = false
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()

   self.hitStop = 0

   self.glabTarget = {
      unit = nil,
      x = 0,
      y = 0
   }
   self.currentGlabPhase = 0
   self.glabPhase = {
      none = 0,
      gravity = 1,
      hold = 2,
      fade = 3,
      finish = 4
   }

   self.glabPhaseContents = {
      [self.glabPhase.gravity] = {
         useAction = function(unit,deltaTime) self:useGravity(unit,deltaTime) end
      },
      [self.glabPhase.fade] = {
         useAction = function(unit,deltaTime) self:useFade(unit,deltaTime) end
      },
      [self.glabPhase.hold] = {
         useAction = function(unit,deltaTime) self:useHold(unit) end
      },
      [self.glabPhase.finish] = {
         useAction = function(unit,deltaTime) self:useFinish(unit) end
      }
   }
   self.dejyonCounter = 0
   self.dejyonDuration = 15
   self.gravityPower = 200
   self.neckAngle = 321
   self.isFireEnd = false
   self.shotAngle = 0
   self.attack5Timer = 30
   self.isFirst = false
   event.unit:takeAnimation(1,"setUpNormal",true);

   self:showMessage(self.START_MESSAGE_LIST)
   return 1
end

function class:useGravity(unit,deltaTime)
   self:gravityWork(unit,deltaTime)
   self:execAddBuff(self.glabTarget.unit,self.BUFF_BOX_LIST[2])
end

function class:useFade(unit,deltaTime)
   self:gravityWork(unit,deltaTime)
   self:execAddBuff(self.glabTarget.unit,self.BUFF_BOX_LIST[2])
   self:fadeOutUpdate(self.glabTarget.unit,deltaTime)
end

function class:useHold(unit)
   if self.glabTarget.unit == nil then return end
   self:execAddBuff(self.glabTarget.unit,self.BUFF_BOX_LIST[2])
   self.glabTarget.unit:setPosition(self.glabTarget.unit:getPositionX(),-1000)
end

function class:useFinish(unit)
   local buff = self.glabTarget.unit:getTeamUnitCondition():findConditionWithID(500151);
   if buff ~= nil then
      self.glabTarget.unit:getTeamUnitCondition():removeCondition(buff);
   end

   self.glabTarget.unit:getSkeleton():setPosition(0,1000);--解放するときは上空から落とす
   self.glabTarget.unit:setOpacity(255);
   self.glabTarget.unit:resumeUnit();
   if self.glabTarget.unit:getBurstPoint() < 0 then
     self.glabTarget.unit:setBurstPoint(0);
   end
   self.currentGlabPhase = self.glabPhase.none;
   self.glabTarget.unit = nil;
end

function class:gravityWork(unit,deltaTime)
   if unit == nil then return end
   local target = self.glabTarget.unit
   local bonePosition = {
       x = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("DAMAGEAREA"),
       y = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("DAMAGEAREA")
   }
   local tgtx = self.glabTarget.x
   local tgty = self.glabTarget.y
   local rad = self:getRad(tgtx,tgty,bonePosition.x,bonePosition.y)
   local moveSpeed = self.gravityPower * deltaTime;
   if self:getDistance(tgtx,tgty,bonePosition.x,bonePosition.y) < moveSpeed then
      target:setPosition(bonePosition.x,bonePosition.y)
   else
       target:setPosition(tgtx + math.cos(rad) * moveSpeed,tgty + math.sin(rad) * moveSpeed);
       self.glabTarget.x = tgtx + math.cos(rad) * moveSpeed;
       self.glabTarget.y = tgty + math.sin(rad) * moveSpeed;
   end
end

function class:fadeOutUpdate(unit,deltaTime)
   local frameRate = deltaTime / 0.016666667
   if unit ~= nil then
      local opa = unit:getOpacity() - 10 * frameRate;
      if opa < 0 then--アンダーフローさせないため
        opa = 0;
      end 
      unit:setOpacity(opa)
   end
end

function class:getDeg(startx,starty,targetx,targety)
   return radToDeg(getRad(startx,starty,targetx,targety))
end

function class:getRad(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx)
end

function class:getDistance(x1,y1,x2,y2)
   local squareResult = (x1 - x2) * (x1 - x2) + (y1 - y2)*(y1 - y2);
   return math.sqrt(squareResult);
end

function class:degToRad(deg)
    return deg * 3.14/180;
end

function class:radToDeg(rad)
    return rad * 180/3.14;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
   event.unit:takeAnimation(1,"empty",false);
   megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
   return 1
end

function class:receive4(args)
   self.gameUnit:takeAnimation(1,"empty",false);
   return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   -- if event.spineEvent == "targetLock" then self:targetLock(unit) end
   if event.spineEvent == "fire" then self:fire(event.unit) end
   if event.spineEvent == "setFire" then self:setFire(event.unit) end
   if event.spineEvent == "addSP" then self:addSP(event.unit) end
   if event.spineEvent == "startFire" then self:startFire(event.unit) end
   if event.spineEvent == "gravityStart" then self:gravityStart(event.unit) end
   if event.spineEvent == "gravityEnd" then self:gravityEnd(event.unit) end
   if event.spineEvent == "hideUnit" then self:hideUnit(event.unit) end
   return 1
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
   self.isFireEnd = true;
end

function class:setFire(unit) 
   if not self.isRage then return end

   local shot = unit:addOrbitSystem("firePiller",2)
   shot:setHitCountMax(999);
   shot:setEndAnimationName("fireEnd");
   -- shot:EnabledFollow = true;
   local x = unit:getPositionX();
   local y = unit:getPositionY();
   local xb = 0;
   local yb = 0;

   local rand = math.random(5);

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

function class:addSP(unit)
   unit:addSP(20)
end

function class:startFire(unit)
   local headangle = unit:getSkeleton():getBoneRotation("head");

   print("start fire");   
end



function class:gravityStart(unit)
   if not megast.Battle:getInstance():isHost() then
      return
   end

   local units = {}
   local target = self:selectTarget(self.isFirst)

      --吸引対象に設定
   if target ~= nil then
       self.BUFF_BOX_LIST[3].VALUE = self:setDownValue(target)
       self:setGlabTarget(target)
       megast.Battle:getInstance():sendEventToLua(self.scriptID,5,target:getIndex());
       target:resumeUnit();
       self:addStanBuff(target);
       self.currentGlabPhase = self.glabPhase.gravity;
       self.dejyonCounter = 0;
   end
end

--最初は最小、以降は最大
function class:selectTarget(isFirst)
   local targetHp = isFirst and 0 or 101
   local target = nil
   for i = 0,3 do
      local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
       if uni ~= nil and uni:getHP() > 0 then
           local hpRate = summoner.Utility.getUnitHealthRate(uni) * 100;
           if isFirst then
              if targetHp < hpRate then
                targetHp = hpRate
                target = uni
              end
           else
              if targetHp > hpRate then
                targetHp = hpRate
                target = uni
              end
           end
       end
   end
   return target
end

function class:setDownValue(target)
   if not self.isFirst then
      self.isFirst = true
      return (target:getCalcHPMAX() * 0.15) / 15 
   else
      return (target:getCalcHPMAX() * 0.15) / 15 
   end 
end

function class:addStanBuff(target)
   self:execAddBuff(target,self.BUFF_BOX_LIST[2])
end

function class:setGlabTarget(target)
   self.glabTarget.unit = target
   self.glabTarget.x = target:getPositionX();
   self.glabTarget.y = target:getPositionY();
end

function class:receive5(args)
   local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(args.arg)
   self.BUFF_BOX_LIST[3].VALUE = self:setDownValue(target)
   self.isFirst = true;
   self:setGlabTarget(target)
   self.currentGlabPhase = self.glabPhase.gravity
   self.dejyonCounter = 0
   return 1
end

function class:gravityEnd(unit,target)
   self.currentGlabPhase = self.glabPhase.hold
end

function class:hideUnit(unit)
   self.currentGlabPhase = self.glabPhase.fade
end
---------------------------------------------------------------------------------
-- takeBreake
---------------------------------------------------------------------------------
function class:takeBreake(event)
   if self.glabTarget.unit ~= nil then
      self.currentGlabPhase = self.glabPhase.finish
   end
   return 1
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
   if self.glabTarget.unit ~= nil then
      self.currentGlabPhase = self.glabPhase.finish
   end
   return 1
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(2, self.hitStop);
   self.attack5Timer = self.attack5Timer + event.deltaTime
   self:HPTriggersCheck(event.unit)
   if self.glabTarget.unit ~= nil then
      self:glabControll(event.unit,event.deltaTime)
   end
   return 1
end

function class:glabControll(unit,deltaTime)
   self.dejyonCounter = self.dejyonCounter + deltaTime
   if self.glabTarget.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[3].ID) == nil then
      self:execAddBuff(self.glabTarget.unit,self.BUFF_BOX_LIST[3])
   end
   if self.dejyonCounter > self.dejyonDuration then
      print("闇ドラゴン　除外時間終了");
      self.currentGlabPhase = self.glabPhase.finish;
   end
   self.glabPhaseContents[self.currentGlabPhase].useAction(unit,deltaTime)
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

   if self.attack5Timer > 40 then
      attackIndex = 5
      self.attack5Timer = 0
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

   if self.isRage then
      skillIndex = 3
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
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
   if self.TRIGGERS[index].hpMarker ~= nil then
      self.gameUnit:removeHpMarker(self.TRIGGERS[index].hpMarker)
   end


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
   self.gameUnit:removeHpMarker(self.TRIGGERS[args.arg].hpMarker)
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




class:publish();

return class;
