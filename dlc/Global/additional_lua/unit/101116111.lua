local class = summoner.Bootstrap.createUnitClass({label="ガナン", version=1.7, id=101116111});

--HP減少にかかる時間(秒)
class.SLICE_SCHEDULE = 2.5

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 20111704,
         BUFF_ID = 0, -- アイコンのみ
         VALUE = 0,
         DURATION = self.AURA_INTERVAL,
         ICON = 0 --199
      },
     [2] = {
        ID = 20111705,
        BUFF_ID = 21, -- 被ダメージ
        VALUE = 35,
        DURATION = self.AURA_INTERVAL,
        ICON = 199 --139
     },
     [3] = {
        ID = 20111706,
        BUFF_ID = 22, -- クリティカル
        VALUE = 100,
        DURATION = self.AURA_INTERVAL,
        ICON = 11
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
   self.AURA_INTERVAL = 99
   self.aura = nil
   self.defaultDamageRate = event.unit:getBurstSkill():getDamageRate()
   self.SLICE_VALUE = event.unit:getCalcHPMAX() * 0.4
   self.estimateHP = 0
    event.unit:setParameter("111_Senki","0")

   self:setBuffBoxList()
   return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "start" then
      self:setAura(event.unit)
      self:addBuff(event.unit,self.BUFF_BOX_LIST)
      self:showTimer(event.unit,self.BUFF_BOX_LIST[1].ID)
      self.isAura = true
      self.timer = 0
       event.unit:setParameter("111_Senki","1")
   end
   if event.spineEvent == "loopStart" then
      self.aura:takeAnimation(0,"loop",true);
   end
   if event.spineEvent == "slice" then
      if self.isAura then
         self.slicingHPValue = 0
         self.isSlicing = true
      end
   end
   return 1
end

function class:setAura(unit)
   if self.aura ~= nil then
      self.aura:takeAnimation(0,"in",true);
      return 
   end
   self.aura = unit:addOrbitSystemWithFile("gannanAura","in");
   self.aura:setOrbitType(4)
   self.aura:takeAnimation(0,"in",true);
   self:auraPosition(unit)
end

function class:showTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_ax_time_gray.png","battle_ax_time.png",0,"unit/battle_trans_skill/frame_101116111.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:checkHP(event.unit)
   self:auraPosition(event.unit)
   self:auraTimer(event.deltaTime,event.unit)
   self:sliceHP(event.unit,event.deltaTime)
    --summoner.Utility.messageByEnemy(event.unit:getParameter("111_Senki"))
   return 1
end

function class:checkHP(unit)
   if unit:getHP() == 1 and self.isAura then
      self.timer = self.AURA_INTERVAL + 1
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
         self:removeConditionAll(unit,self.BUFF_BOX_LIST)
         self.aura:takeAnimation(0,"empty",true);
          unit:setParameter("111_Senki","0")
      else
         self.timer = self.timer + deltaTime
      end
   end
end

-- HPが1未満にならないように減らす
function class:sliceHP(unit,deltaTime)
   if not self.isSlicing then return end

   if self.slicingHPValue <= self.SLICE_VALUE then
       local sliceValue = math.ceil((deltaTime / self.SLICE_SCHEDULE) * self.SLICE_VALUE)
       self.slicingHPValue = self.slicingHPValue + sliceValue
       if unit:getHP() - sliceValue < 1 then
         unit:setHP(1)
       elseif self.SLICE_VALUE < self.slicingHPValue then
         unit:setHP(unit:getHP() - (self.SLICE_VALUE - self.slicingHPValue + sliceValue))
       else
         unit:setHP(unit:getHP() - sliceValue)
       end
       return
   end
   self.slicingHPValue = 0
   self.isSlicing = false
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   if self.isAura then
      event.unit:addSPWithPvpCorrection(1)
   end
   return event.value
end

---------------------------------------------------------------------------------
-- takeSkill 
---------------------------------------------------------------------------------
function class:takeSkill(event)
   if event.index == 2 then
      if self.isAura then
         self:addDamage(event.unit,self.defaultDamageRate * 3)
      else
         self:addDamage(event.unit,self.defaultDamageRate)
      end
   end
   return 1
end

function class:addDamage(unit,value)
   unit:getBurstSkill():setDamageRate(value)
end

--===================================================================================================================
-- バフ関係
--===================================================================================================================
function class:addBuff(unit,buffBoxList)
   for i,buffBox in ipairs(buffBoxList) do
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
end

function class:removeConditionAll(unit,buffBoxList)
   for i,buffBox in ipairs(buffBoxList) do
      self:removeCondition(unit,buffBox.ID)
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