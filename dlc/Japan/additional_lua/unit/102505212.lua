local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="セティス", version=1.3, id=102505212});

function class:setSurfaceBoxList()
   self.beforeMD = 0
   self.afterMD = 1
   self.SURFACE_BOX_LIST = {
      [self.beforeMD] = {
         ACTIVE_SKILL = 3,
         VOICE = "VOICE_FULLARTS_CUTIN_B_01",
         SKILL_NAME = self.TEXT.BEFORE_MD or "マギアドライブ",
         SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
      },
      [self.afterMD] = {
         ACTIVE_SKILL = 3,
         VOICE = "VOICE_FULLARTS_CUTIN_B_02",
         SKILL_NAME = self.TEXT.AFTER_MD or "グロスエルデ・アーテム",
         SE = "SE_BATTLE_040_UNIT_CALL"
      }
   }
end

--------[[バフ]]--------
function class:setBuffBoxList()
   self.BUFF_LIST = {
      [0] = {
         ID = 102506212,
         BUFF_ID = 0, -- 行動速度
         VALUE = 0,
         DURATION = 999999,
         ICON = 37
      },
      [1] = {
         ID = 1025062121,
         BUFF_ID = 98,
         VALUE = 25000,
         DURATION = 30,
         ICON = 24,
         GROUP_ID = 3348,
         PRIORITY = 25000,
         EFFECT = 1
      },
      [2] = {
         ID = 1025062122,
         BUFF_ID = 0, --マギアドライブアイコン用
         VALUE = 1,
         DURATION = 120,
         ICON = 186
      },
      [3] = {
         ID = 1025062123,
         BUFF_ID = 21, --ダメージカット
         VALUE = -25,
         DURATION = 120,
         ICON = 20
      }
   }
end

---------------------------------------------------------------------------------
-- start 
---------------------------------------------------------------------------------
function class:start(event)
   self.gameUnit = event.unit
   self.isAura = false
   self.timer = 0
   self.AURA_INTERVAL = 120
   self.SKILL3_SP_VALUE = 20
   self:setSurfaceBoxList()
   self:setBuffBoxList()
   self.skill2DamageRate = 0;
   self.RIVIVE_RATIO = 0.5
   self.DEFENCE_RATE = 1.2
   self.isDead = false
   event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE);
   


   --防御力計算はスキルを使用するたびに行いたいので、isFirstを消して、代わりにstartで取得したBurstSkillのダメージをパラメーターに保存するように変更
   self:checkBurstSkillRate(event.unit);

   --startwaveでかけると蘇生時にアイコンがつかなくなってしまうためstartに移動
   self:setRinascita(event.unit) 
   return 1
end



function class:startWave(event)
     megast.Battle:getInstance():updateConditionView()
   return 1
end

function class:setRinascita(unit)
   local param = unit:getParameter("isRinascita")
   if param == "" or param == "FALSE" then
      unit:setParameter("isRinascita","FALSE")
      self:execAddBuff(unit,self.BUFF_LIST[0])
   end
end

function class:checkBurstSkillRate(unit)
  local param = unit:getParameter("skill2DamageRate")
  if param == "" then
    self.skill2DamageRate = unit:getBurstSkill():getDamageRate();
    unit:setParameter("skill2DamageRate",""..self.skill2DamageRate);
    self.skill2DamageRate = unit:getBurstSkill():getDamageRate();
  else
    self.skill2DamageRate = tonumber(param);
  end
end

function class:excuteAction(event)
  return self:checkRinascita(event.unit)
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:auraPosition(event.unit)
   self:auraTimer(event.deltaTime,event.unit)
   return 1
end

function class:auraPosition(unit)
   if self.aura == nil then
      return
   end

   local vec = unit:getisPlayer() and 1 or -1
   local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
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
         unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE);
         self.aura:takeAnimation(0,"empty",true);
      else
         self.timer = self.timer + deltaTime
      end
   end
end


function class:checkRinascita(unit)

   if unit:getParameter("isRinascita") == "FALSE" then
      for i = 0,3 do
         local teamUnit = unit:getTeam():getTeamUnit(i,true);
         if teamUnit ~= nil and teamUnit:getHP() <= 0 and teamUnit ~= unit then
            unit:takeAnimation(0,"rinascita",false);
            unit:setUnitState(kUnitState_skill);
            unit:setBurstState(kBurstState_active);
            return 0;
         end
      end
   end
   return 1;
end

function class:checkRinascitaTarget(unit)
   if not self:getIsControll(unit) then
      return;
   end
   
   if unit:getParameter("isRinascita") == "FALSE" then
      for i = 0,3 do
         local teamUnit = unit:getTeam():getTeamUnit(i,true);
         if teamUnit ~= nil and teamUnit:getHP() <= 0 and teamUnit ~= unit then
            self:excuteRinascita(unit,teamUnit:getIndex());
            megast.Battle:getInstance():sendEventToLua(self.scriptID,2,teamUnit:getIndex());
            return;
         end
      end
   end
end

function class:excuteRinascita(unit,index)
  
  local teamUnit = unit:getTeam():getTeamUnit(index,true);

  if teamUnit ~= nil then

    unit:setParameter("isRinascita","TRUE")
    self:removeCondition(unit,self.BUFF_LIST[0].ID)


    if not self:getIsControll(teamUnit) and not megast.Battle:getInstance():isPvp() then
       return;
    end
    
    unit:getTeam():reviveUnit(teamUnit:getIndex())
    local targetHP = teamUnit:getCalcHPMAX() * self.RIVIVE_RATIO >= 1 and teamUnit:getCalcHPMAX() * self.RIVIVE_RATIO or 1;
    teamUnit:setReviveHP(targetHP);
    
  end
end


---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "addDamage" then
      self:addDamage(event.unit)
   end
   if event.spineEvent == "md2Start" then
      self:setAura(event.unit)
   end
   if event.spineEvent == "loopStart" then
      self.aura:takeAnimation(0,"MD_loop",true);
      self:takeMD(event.unit)
   end

   if event.spineEvent == "execRinascita" then
      self:checkRinascitaTarget(event.unit);
   end

   return 1
end

function class:takeMD(unit)
   unit:addSPWithPvpCorrection(100)
end

function class:takeDamageValue(event)
   if self.isAura then
      event.unit:addSPWithPvpCorrection(1)
   end
   return event.value
end

function class:addDamage(unit,value)
   --防御力*2を威力に上乗せ
   unit:getBurstSkill():setDamageRate(value)

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
-- takeSkill 
---------------------------------------------------------------------------------
function class:takeSkill(event)
   if event.index == 2 then
      self:addDamage(event.unit,self.skill2DamageRate + ((event.unit:getCalcDefence() / 100) * self.DEFENCE_RATE))
   end
   if event.index == 3 then
      if not self.isAura then
         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
         self.isAura = true
         self.isBeforeSkill = true
         self:execAddBuff(event.unit,self.BUFF_LIST[2])
         self:execAddBuff(event.unit,self.BUFF_LIST[3])
         event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
      else
         event.unit:setNextAnimationName("skill3b")
         event.unit:setNextAnimationEffectName("2skill3b")
         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
      end
   end
   return 1
end

function class:setSurface(unit,surfaceBox)
   unit:setActiveSkill(surfaceBox.ACTIVE_SKILL);
   unit:getActiveBattleSkill():setSkillname(surfaceBox.SKILL_NAME);
   --unit:setCutinSE2(surfaceBox.SE);
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
  if buffBox.GROUP_ID ~= nil then
    local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
      if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
        unit:getTeamUnitCondition():removeCondition(cond);
    end
    self:addConditionWithGroup(unit,buffBox);
    return;
  end

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

--グループIDつきバフ
function class:addConditionWithGroup(unit,buffBox)
  
    local newCond = nil;
    if buffBox.EFFECT ~= nil then
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    newCond:setGroupID(buffBox.GROUP_ID);
    newCond:setPriority(buffBox.PRIORITY);
    if buffBox.SCRIPT_ID ~= nil then
       newCond:setScriptID(buffBox.SCRIPT_ID)
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



function class:getIsControll(unit)
     return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end



function class:receive2(args)
    self:excuteRinascita(self.gameUnit,args.arg);
    return 1;
end

class:publish();


return class;
