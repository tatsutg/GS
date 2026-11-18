local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="レオーネ", version=1.7, id=102686412});

function class:setSurfaceBoxList()
   self.beforeMD = 0
   self.afterMD = 1
   self.SURFACE_BOX_LIST = {
      [self.beforeMD] = {
         ACTIVE_SKILL = 3,
         VOICE = "VOICE_FULLARTS_CUTIN_B_01",
         SKILL_NAME = self.TEXT.BEFORE_MD or "魔血真蝕",
         SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
      },
      [self.afterMD] = {
         ACTIVE_SKILL = 3,
         VOICE = "VOICE_FULLARTS_CUTIN_B_02",
         SKILL_NAME = self.TEXT.AFTER_MD or "クリムゾンブラッド",
         SE = "SE_BATTLE_040_UNIT_CALL"
      }
   }
end

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
     [1] = {
        ID = 1026862121,
        BUFF_ID = 0, -- MDアイコンのみ
        VALUE = 0,
        DURATION = self.AURA_INTERVAL,
        ICON = 0
     }
   }
end

---------------------------------------------------------------------------------
-- start 
---------------------------------------------------------------------------------
function class:start(event)
   self.isAura = false
   self.timer = 0
   self.gameUnit = event.unit
   self.AURA_INTERVAL = 120
   self:setSurfaceBoxList()
self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
   event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)

   self.WEAPON_ID = 50223300
   self.iFlag = false
   self.isFullHeal = false
   self:setBuffBoxList()
   return 1
end

function class:findWeapon(unit,weaponId)
  local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
  return buff ~= nil
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   if not self.isAura then
      event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
   end
   if self.iFlag and self.isAura then
      self:showEffect(event.unit)
   end
   return 1
end

function class:showEffect(unit)
   self.iFlag = false
   self:switchUnitEffect(unit,true)
   if self.isAura and self.aura ~= nil then
      self.aura:takeAnimation(0,"MD_loop",true);
   end
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   if self.isAura and event.unit:getHP() <= event.value then
      event.unit:setInvincibleTime(2)
      return event.unit:getHP() -1
   end
   return event.value
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:auraPosition(event.unit)
   self:auraTimer(event.deltaTime,event.unit)
   self:invisible(event.unit)
   self:checkHP(event.unit)
   return 1
end

function class:checkHP(unit)
   if unit:getHP() == 1 and self.isAura then
      self.timer = self.AURA_INTERVAL + 1
      self:showEffect(unit)
   end
end

function class:invisible(unit)
   if self.iFlag then
      self:switchUnitEffect(unit,false)
   end
end

function class:switchUnitEffect(unit,bool)
  local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
  if conditionSize == 0 then
    return 
  end

  for i = 0,(conditionSize - 1) do
     local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
     cond:setUnitEffectVisible(bool)
  end
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
         -- self:setSurface(unit,self.SURFACE_BOX_LIST[self.beforeMD])
         unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
         self:removeCondition(unit,self.BUFF_BOX_LIST[1].ID)
         unit:setInvincibleTime(1)
         if self.aura ~= nil then self.aura:takeAnimation(0,"empty",true) end
         unit:setParameter("isMD","0")
         unit:setBurstPoint(0)
      else
         self.timer = self.timer + deltaTime
         unit:setBurstPoint(200)
      end
   end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "md6Start" and event.unit:getHP() ~= 1 then
      self:setAura(event.unit)

      if not self.isAura then
         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
         self.isAura = true
         self.timer = 0
         self:addBuff(event.unit,self.BUFF_BOX_LIST)
         event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
      end
      event.unit:setParameter("isMD","1")
   end

   if event.spineEvent == "invisible" then
      self.iFlag = true
      self:switchUnitEffect(event.unit,false)
      if self.aura ~= nil then
         self.aura:takeAnimation(0,"empty",true);
      end

   end

   if event.spineEvent == "showEffec" then 
      self:showEffect(event.unit)
   end

   if event.spineEvent == "loopStart" then
      self.aura:takeAnimation(0,"MD_loop",true);
   end

   return 1
end

function class:setAura(unit)
   if self.aura ~= nil then
      self.aura:takeAnimation(0,"MD_in",true);
       self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
      return 
   end
   self.aura = unit:addOrbitSystemWithFile("MD_6","MD_in");
    self.aura:setOrbitType(4)
   self.aura:takeAnimation(0,"MD_in",true);
   self:auraPosition(unit)
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
end

---------------------------------------------------------------------------------
-- takeHeal
---------------------------------------------------------------------------------
function class:takeHeal(event)
    local healVal = event.heal_origin
    if self.isFullHeal then
       self.isFullHeal = false
       healVal = event.unit:getCalcHPMAX() - event.unit:getHP()
    end
   return healVal
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self:showEffect(event.unit)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    return 1
end
---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    return 1;
end
---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCast(event)
    self:loopStart1(event.unit)---MD1オーラ失敗時に動く
    return 1;
end

---MD1オーラ
function class:loopStart1(unit)
    if self.loopStart1FLG then
        self:setAura(unit)
    end
end

---------------------------------------------------------------------------------
-- takeSkill 
---------------------------------------------------------------------------------
function class:takeSkill(event)
   self:showEffect(event.unit)

   if event.index == 3 then
      if not self.isAura then

         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
          self.loopStart1FLG = true---オーラを出すためのフラグ
         self.isAura = true
         self.timer = 0
         self:showMDTimer(event.unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
          self:addBuff(event.unit,self.BUFF_BOX_LIST)
          event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)

         self:checkFullHeal(event.unit)
         if event.unit:getHP() == 1 then
            self.timer = self.AURA_INTERVAL - 1
            return 1
         end

      else
         event.unit:setNextAnimationName("skill3_2")
         event.unit:setNextAnimationEffectName("2skill3_2")
         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
      end
   end
   return 1
end

function class:setSurface(unit,surfaceBox)
   unit:setActiveSkill(surfaceBox.ACTIVE_SKILL);
   unit:getActiveBattleSkill():setSkillname(surfaceBox.SKILL_NAME);
   -- unit:setCutinVoice2(surfaceBox.VOICE);
   --unit:setCutinSE2(surfaceBox.SE);
end

function class:checkFullHeal(unit)
   if self:findWeapon(unit,self.WEAPON_ID) then
    self.isFullHeal = true
      unit:takeHeal(unit:getCalcHPMAX() - unit:getHP())
   end
end

function class:findWeapon(unit,weaponId)
   local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
   return buff ~= nil
end

function class:showMDTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_makethukakusei_time_gray.png","battle_makethukakusei_time.png",0,"unit/battle_trans_skill/frame_magiadrive.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
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
    self:addBuffSelector(unit,buffBoxList[index])
end

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit,buffBoxList,start,finish)
    for i = start,finish do
        self:addBuffSelector(unit,buffBoxList[i])
    end
end

function class:addBuffAll(unit,buffBoxList)
   for i,buffBox in pairs(buffBoxList) do
      self:addBuffSelector(unit,buffBox)
   end
end

function class:addBuffSelector(unit,buffBox)
   if buffBox.BUFF_TYPE == nil or buffBox.BUFF_TYPE == "mine" then
      self:execAddBuff(unit,buffBox)
   end

   if buffBox.BUFF_TYPE == "all" then
      for i = 0,6 do
         local teamUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i)
         if teamUnit ~= nil then
            self:addBuff(teamUnit,buffBox)
         end
      end
   end

   if buffBox.BUFF_TYPE == "other" then
      for i = 0,6 do
         local teamUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i)
         if teamUnit ~= nil and teamUnit ~= unit then
            self:addBuff(teamUnit,buffBox)
         end
      end
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
       buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
       if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
       if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
       if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
       if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
       if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
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

-- バフ削除
function class:removeCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
      unit:resumeUnit()
    end  
end


class:publish();

return class;