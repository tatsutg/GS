local class = summoner.Bootstrap.createEnemyClass({label="ジュノー", version=1.7, id=2025428});

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
         VOICE = "VOICE_FULLARTS_CUTIN_B",
         SKILL_NAME = self.TEXT.AFTER_MD or "シュヴァルツ・ディ・ヴァーム",
         SE = "SE_BATTLE_040_UNIT_CALL"
      }
   }
end

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 1032264121,
         BUFF_ID = 0, -- MDアイコンのみ
         VALUE = 0,
         DURATION = self.AURA_INTERVAL,
         ICON = 208
      },
      [2] = {
         ID = 1032264122,
         BUFF_ID = 10, -- 奥義ゲージ
         VALUE = 5,
         DURATION = self.AURA_INTERVAL,
         ICON = 0
      },
      [3] = {
         ID = 1032264123,
         BUFF_ID = 17, -- ダメージ
         VALUE = 100,
         DURATION = self.AURA_INTERVAL,
         ICON = 0
      },
      [4] = {
         ID = 1032264124,
         BUFF_ID = 32, -- 命中率
         VALUE = 100,
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
   self.AURA_INTERVAL = 99999
   self:setSurfaceBoxList()
   event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)

   self:setBuffBoxList()
   self.isCheck = false
   return 1
end

function class:takeIn(event)
   self:setAura(event.unit)
   if not self.isAura then
      self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
      self.isAura = true
      self.timer = 0
      self:addBuff(event.unit,self.BUFF_BOX_LIST)
      event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
   end
   return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   
   if not self.isAura then
      event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
   end
   return 1
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

   --今回に限っては開始前にかけておきたいので、MAINの座標がまだ取れないときは手動でオフセットをかけることにした。
   if unit:getSkeleton():getBoneWorldPositionY("MAIN") <= 0 then
      targety = targety + 60;
   end   

   local unitZorder = unit:getZOrder();

   --今回に限っては開始前にかけておきたいので、z座標も（以下省略
   if unitZorder == 0 then
      unitZorder = 9000;
   end

   self.aura:setPosition(targetx,targety);
   self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
   self.aura:setZOrder(unitZorder);
end

function class:auraTimer(deltaTime,unit)
   if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
      local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100

      if self.AURA_INTERVAL < self.timer or (hpRate <= 20 and megast.Battle:getInstance():isHost() and self.isCheck) then
         self:resetAura(unit)
         megast.Battle:getInstance():sendEventToLua(self.scriptID,1,1);
      else
         self.timer = self.timer + deltaTime
      end
   end
end

function class:resetAura(unit)
   self.isAura = false
   self.timer = 0
   -- self:setSurface(unit,self.SURFACE_BOX_LIST[self.beforeMD])
   unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
   for _,cond in ipairs(self.BUFF_BOX_LIST) do
      self:removeCondition(unit,cond.ID)
   end
   if self.aura ~= nil then self.aura:takeAnimation(0,"empty",true) end
end

function class:receive1(args)
   self:resetAura(self.gameUnit)
   return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "checkWeapon" then
      if megast.Battle:getInstance():isHost() then
         self:takeMD(self.gameUnit)
         megast.Battle:getInstance():sendEventToLua(self.scriptID,2,1);
      end
   end

   if event.spineEvent == "md6Start" then
      self:setAura(event.unit)
      if not self.isAura then
         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
         self.isAura = true
         self.timer = 0
         self:addBuff(event.unit,self.BUFF_BOX_LIST)
         event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
      end

   end

   if event.spineEvent == "loopStart" then
      self.isCheck = true
      self.aura:takeAnimation(0,"MD_loop",true);
   end

   return 1
end

function class:receive2(args)
   self:addBuff(self.gameUnit,self.BUFF_BOX_LIST)
   self:takeMD(self.gameUnit)
   return 1
end

function class:setAura(unit)
   if self.aura ~= nil then
      self.aura:takeAnimation(0,"MD_in",true);
      return
   end
   self.aura = unit:addOrbitSystemWithFile("MD_6","MD_in");
   self.aura:takeAnimation(0,"MD_in",true);
   self:auraPosition(unit)
end

function class:takeMD(unit)
   if self:findWeapon(unit,50241100) then
      unit:addSP(100)
      unit:takeHeal(math.floor(unit:getCalcHPMAX()/2))
   end
end

function class:findWeapon(unit,weaponId)
   local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
   return buff ~= nil
end

---------------------------------------------------------------------------------
-- takeSkill 
---------------------------------------------------------------------------------
function class:takeSkill(event)

   if event.index == 3 then
      if not self.isAura then
         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
         self.isAura = true
         self.isCheck = false
         self.timer = 0
         self:addBuff(event.unit,self.BUFF_BOX_LIST)
         event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
      else
         event.unit:setNextAnimationName("skill3_2")
         event.unit:setNextAnimationEffectName("2-skill3_2")
         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.afterMD])
      end
   end
   return 1
end

function class:setSurface(unit,surfaceBox)
   -- unit:setActiveSkill(surfaceBox.ACTIVE_SKILL);
   -- unit:getActiveBattleSkill():setSkillname(surfaceBox.SKILL_NAME);
   -- -- unit:setCutinVoice2(surfaceBox.VOICE);
   -- unit:setCutinSE2(surfaceBox.SE);
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