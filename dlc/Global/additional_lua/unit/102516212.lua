local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="ヴォックス", version=1.3, id=102516212});

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
         SKILL_NAME = self.TEXT.AFTER_MD or "絶技・氷迅天衝",
         SE = "SE_BATTLE_040_UNIT_CALL"
      }
   }
end

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 1025162121,
         BUFF_ID = 0, -- MDアイコンのみ
         VALUE = 0,
         DURATION = self.AURA_INTERVAL,
         ICON = 0
      },
      [2] = {
         ID = 1025162122,
         BUFF_ID = 29, -- スキル速度
         VALUE = 100,
         DURATION = self.AURA_INTERVAL,
         ICON = 34
      },
      [3] = {
         ID = 1025162123,
         BUFF_ID = 13, -- 攻撃力
         VALUE = 100,
         DURATION = self.AURA_INTERVAL,
         ICON = 3
      },
      [4] = {
         ID = 1025162124,
         BUFF_ID = 103, -- 麻痺無効
         VALUE = 100,
         DURATION = self.AURA_INTERVAL,
         ICON = 0
      },
      [5] = {
         ID = 1025162125,
         BUFF_ID = 108, -- 氷結無効
         VALUE = 100,
         DURATION = self.AURA_INTERVAL,
         ICON = 0
      },
      [6] = {
         ID = 1025162126,
         BUFF_ID = 27, -- ブレイク無効
         VALUE = -100,
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
   self.AURA_INTERVAL = 180
   self:setSurfaceBoxList()
self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
   self:setBuffBoxList()
   event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE);

   self.ABSORB_SP_MAX = 50
   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   if not self.isAura then
      event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE);
   end
   return 1;
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
         -- self:setSurface(unit,self.SURFACE_BOX_LIST[self.beforeMD])
         unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE);
         self.aura:takeAnimation(0,"empty",true);
         unit:setParameter("isMD","0")
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
      event.unit:setParameter("isMD","1")
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
   self.aura = unit:addOrbitSystemWithFile("MD_2","MD_in");
    self.aura:setOrbitType(4)
   self.aura:takeAnimation(0,"MD_in",true);
   self:auraPosition(unit)
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
end

function class:takeMD(unit)
   self:showMDTimer(unit,self.BUFF_BOX_LIST[1].ID)---マギアドライブタイマー表示
    self:addBuff(unit,self.BUFF_BOX_LIST)
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
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
   if event.index == 1 then
      if self.isAura then
         event.unit:addSPWithPvpCorrection(20)
      end
   end

   if event.index == 3 then
      if not self.isAura then
         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
        self.loopStart1FLG = true---オーラを出すためのフラグ
         self.isAura = true
         self.isBeforeSkill = true
         self:takeMD(event.unit)
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
   -- unit:setCutinVoice2(surfaceBox.VOICE);
   --unit:setCutinSE2(surfaceBox.SE);
end

function class:showMDTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_magia_d_time_gray.png","battle_magia_d_time.png",0,"unit/battle_trans_skill/frame_magiadrive.plist")
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
