local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="ミヅキ", version=1.8, id=102825212});

function class:setSurfaceBoxList()
   self.beforeMD = 0
   self.afterMD = 1
   self.SURFACE_BOX_LIST = {
      [self.beforeMD] = {
         ACTIVE_SKILL = 3,
         VOICE = "VOICE_FULLARTS_CUTIN_B_01",
         SKILL_NAME = self.TEXT.BEFORE_MD or "カイガン",
         SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
      },
      [self.afterMD] = {
         ACTIVE_SKILL = 3,
         VOICE = "VOICE_FULLARTS_CUTIN_B_02",
         SKILL_NAME = self.TEXT.AFTER_MD or "最終奥義「星離雨散」",
         SE = "SE_BATTLE_040_UNIT_CALL"
      }
   }
end

function class:setBuffBoxList(duration)
   self.BUFF_BOX_LIST = {
     [1] = {
      ID = 1028252121,
      BUFF_ID = 4001, -- カイガン
      VALUE = 0,
      DURATION = duration or self.AURA_INTERVAL,
      ICON = 190
    },
     [2] = {
         ID = 1028252122,
         BUFF_ID = 17, -- 炎属性に対するダメージ
         VALUE = 100,
         DURATION = duration or self.AURA_INTERVAL,
         ICON = 26,
         SCRIPT = {
          SCRIPT_ID = 14,
          VALUE1 = 1
         }
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
   self.AURA_INTERVAL = 60
   self:setSurfaceBoxList()
   event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
   if self:findWeapon(event.unit,50223500) then
      self.AURA_INTERVAL = 120
   end

   self.kaiganBuffIconList = {checked = false,conds = {}}
   self.isKilled = false
   self:searchUnitEffect(event.unit,18,4001,0)
   self:setBuffBoxList()
   return 1
end

function class:findWeapon(unit,weaponId)
  local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
  return buff
end

---------------------------------------------------------------------------------
-- takeIn
---------------------------------------------------------------------------------
function class:firstIn(event)
   if not self.kaiganBuffIconList.checked then
      self:searchUnitEffect(event.unit,18,4001,0)
   end
   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   if self:findWeapon(event.unit,50223500) then
      self.AURA_INTERVAL = 120
      self:setBuffBoxList()
   end
   if not self.isAura then
      self:searchUnitEffect(event.unit,18,4001,0)
      event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
   end
   return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
   for i,v in ipairs(self.kaiganBuffIconList.conds) do
      self:searchUnitEffect(event.unit,18,4001,v)
   end
   if not self.isAura then
      self.kaiganBuffIconList.checked = false
      self.isKilled = false
   end
   
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   if not self.kaiganBuffIconList.checked then
      self:searchUnitEffect(event.unit,18,4001,0)
   end


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
         self:setBuffBoxList()
         -- self:setSurface(unit,self.SURFACE_BOX_LIST[self.beforeMD])
         self:removeCondition(unit,self.BUFF_BOX_LIST[1].ID)
         self:removeCondition(unit,self.BUFF_BOX_LIST[2].ID)
         self:searchUnitEffect(unit,18,4001,0)
         unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
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
      self.aura:takeAnimation(0,"Kaigan_loop",true);
   end
   return 1
end

function class:setAura(unit)
   if self.aura ~= nil then
      self.aura:takeAnimation(0,"Kaigan_in",true);
      return 
   end
   self.aura = unit:addOrbitSystemWithFile("Kaigan2","Kaigan_in");
    self.aura:setOrbitType(4)
   self.aura:takeAnimation(0,"Kaigan_in",true);
   self:auraPosition(unit)
end

---------------------------------------------------------------------------------
-- takeSkill 
---------------------------------------------------------------------------------
function class:takeSkill(event)

   if event.index == 3 then
      if not self.isAura then
         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
         self.isAura = true
         self.timer = 0
         self.isBeforeSkill = true
         self:addBuff(event.unit,self.BUFF_BOX_LIST)
         for i,v in ipairs(self.kaiganBuffIconList.conds) do
            self:searchUnitEffect(event.unit,18,4001,v)
         end

         event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
      else
         event.unit:setNextAnimationName("skill3b")
         event.unit:setNextAnimationEffectName("skill3b")
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
   for i,buffBox in ipairs(buffBoxList) do
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

    for i,condBox in ipairs(self.kaiganBuffIconList) do
       self:switchBuffIcon(condBox.condition,condBox.iconID)
    end

end

-- バフ削除
function class:removeCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
      unit:resumeUnit()
    end  
end

function class:searchUnitEffect(unit,scriptId,value1,afterIconID)
  local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
  if conditionSize == 0 then
    return 
  end

  for i = 0,(conditionSize - 1) do
     local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
     if cond ~= nil and cond:getScriptID() == scriptId and cond:getValue1() == value1 then
        if not self.kaiganBuffIconList.checked then
           self.isKilled = true
           table.insert(self.kaiganBuffIconList.conds,cond:getThumbnailID())
        end
        if afterIconID ~= nil then
           self:switchBuffIcon(cond,afterIconID)
        end
     end
  end
  if self.isKilled then
     self.kaiganBuffIconList.checked = true
  end
end

-- バフアイコン設定
function class:switchBuffIcon(cond,iconId)
   cond:setThumbnailID(iconId)
   megast.Battle:getInstance():updateConditionView()
end

class:publish();

return class;