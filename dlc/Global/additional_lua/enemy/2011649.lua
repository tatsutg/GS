local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="セティス", version=1.3, id=2011649});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 5
}

class.MAGIA_DRIVE = 4

function class:setTriggerList()
   self.TRIGGERS = {
      [0] = {
         tag = "HP_FLG",
         action = function (status) self:hp50(status) end,
         HP = 50,
         used = false
      },
      [1] = {
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

function class:hp50(status)
   if status == "use3" then
      self.isRage = true
      self.gameUnit:addSP(100)
      self:showMessage(self.HP50_MESSAGE_LIST)
   end
end

function class:hp30(status)
   if status == "use3" then
      self.hitStop = self.hitStop + 0.5
      self.gameUnit:addSP(100)
      self:showMessage(self.HP30_MESSAGE_LIST)
   end
end

--------[[バフ]]--------
function class:setBuffBoxList()
   self.BUFF_LIST = {
      [0] = {
         ID = 20116431,
         BUFF_ID = 0, -- 行動速度
         VALUE = 0,
         DURATION = 999999,
         ICON = 186
      }
   }
end


--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "ボクにだって護りたいものぐらいあるっ！",
         COLOR = Color.cyan,
         DURATION = 5         
      },
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカル耐性",
         COLOR = Color.yellow,
         DURATION = 5         
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE3 or "炎耐性",
         COLOR = Color.cyan,
         DURATION = 5         
      }
   }
   self.HP50_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "我らが王に誓う",
         COLOR = Color.cyan,
         DURATION = 5
      }
   }

   self.HP30_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.HP30_MESSAGE1 or "全身全霊…！",
         COLOR = Color.cyan,
         DURATION = 5
      },
      [1] = {
         MESSAGE = self.TEXT.HP30_MESSAGE2 or "ダメージ・行動速度アップ",
         COLOR = Color.yellow,
         DURATION = 5
      }
   }
end

-- function class:setSurfaceBoxList()
--    self.beforeMD = 0
--    self.afterMD = 1
--    self.SURFACE_BOX_LIST = {
--       [self.beforeMD] = {
--          ACTIVE_SKILL = 3,
--          VOICE = "VOICE_FULLARTS_CUTIN_B_01",
--          SKILL_NAME = self.TEXT.BEFORE_MD or "マギアドライブ",
--          SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
--       },
--       [self.afterMD] = {
--          ACTIVE_SKILL = 3,
--          VOICE = "VOICE_FULLARTS_CUTIN_B_02",
--          SKILL_NAME = self.TEXT.AFTER_MD or "グロスエルデ・アーテム",
--          SE = "SE_BATTLE_040_UNIT_CALL"
--       }
--    }
-- end
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

   self.aura = nil
   self.hitStop = 0.5
   self.isRage = false
   self.isAura = false
   self.timer = 0
   self.AURA_INTERVAL = 99999
   self:setMessageBoxList()
   self:setBuffBoxList()
   self:setTriggerList()
   -- self:setSurfaceBoxList()
   self:showMessage(self.START_MESSAGE_LIST)
   -- event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE);
   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   self.gameUnit:addSP(100)
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(2,self.hitStop)
   self:HPTriggersCheck(event.unit);
   self:auraPosition(event.unit)
   self:auraTimer(event.deltaTime,event.unit)
   return 1
end

function class:auraPosition(unit)
   if self.aura == nil then
      return
   end

   local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN");
   local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
   self.aura:setPosition(targetx,targety);
   self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
   self.aura:setZOrder(unit:getZOrder() + 1)
end

function class:auraTimer(deltaTime,unit)
   if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
      if self.AURA_INTERVAL < self.timer then
         self.isAura = false
         self.timer = 0
         -- unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE);
         self.aura:takeAnimation(0,"empty",true);
      else
         self.timer = self.timer + deltaTime
      end
   end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "md2Start" then
      self:setAura(event.unit)
   end
   if event.spineEvent == "loopStart" then
      self.aura:takeAnimation(0,"MD_loop",true);
   end
   return 1
end

function class:setAura(unit)
   if self.aura ~= nil then
      self.aura:takeAnimation(0,"MD_in",true);
      return 
   end
   self.aura = unit:addOrbitSystemWithFile("MD_2","MD_in");
   self.aura:takeAnimation(0,"MD_in",true);
   self:auraPosition(unit)
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

   if tonumber(attackIndex) == 1 then
      unit:takeAttack(tonumber(attackIndex));
   else
      self.skillCheckFlg = true;
      unit:takeSkill(1);
      megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
      return 0;
   end
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
   if event.index == 3 then
      self:setupSkill3(event.unit)
   end
   return 1
end

function class:setupSkill3(unit)
   if not self.isAura then
      -- self:setSurface(unit,self.SURFACE_BOX_LIST[self.beforeMD])
      self.isAura = true
      -- unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
      unit:setActiveSkill(self.MAGIA_DRIVE)
   else
      unit:setNextAnimationName("skill3b")
      unit:setNextAnimationEffectName("2skill3b")
      -- self:setSurface(unit,self.SURFACE_BOX_LIST[self.afterMD])
   end
end

-- function class:setSurface(unit,surfaceBox)
--    unit:setActiveSkill(surfaceBox.ACTIVE_SKILL);
--    unit:getActiveBattleSkill():setSkillname(surfaceBox.SKILL_NAME);
--    unit:setCutinSE2(surfaceBox.SE);
-- end

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

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
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
   summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
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

class:publish();

return class;
