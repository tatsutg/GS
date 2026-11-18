local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="ベリック", version=1.3, id=102486112});

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
         SKILL_NAME = self.TEXT.AFTER_MD or "エクスプロキオン",
         SE = "SE_BATTLE_040_UNIT_CALL"
      }
   }
end

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
    [0] = {
      ID = 1024861121,
      BUFF_ID = 22, -- クリティカル
      VALUE = 100,
      DURATION = self.AURA_INTERVAL,
      ICON = 11
    },
   [1] = {
      ID = 1024861122,
      BUFF_ID = 10, -- 奥義自然増加
      VALUE = 3,
      DURATION = self.AURA_INTERVAL,
      ICON = 36
    },
    [2] = {
      ID = 1024861123,
      BUFF_ID = 0, -- MDアイコンのみ
      VALUE = 0,
      DURATION = self.AURA_INTERVAL,
      ICON = 0
    }
   }
end

function class:takeMD(unit)
   unit:addSPWithPvpCorrection(200)
end

---------------------------------------------------------------------------------
-- start 
---------------------------------------------------------------------------------
function class:start(event)
   self.isAura = false
   self.timer = 0
   self.gameUnit = event.unit
   self.AURA_INTERVAL = 180
   self:setSurfaceBoxList()
   self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
   self:setBuffBoxList()
   event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)

   --超レオーネアビリティ対応
   self.mdTime = self.AURA_INTERVAL;
   return 1
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
          if self.aura ~= nil then
              self.aura:takeAnimation(0,"empty",true);
          end
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
   if event.spineEvent == "md1Start" then
      self:setAura(event.unit)
       event.unit:setParameter("isMD","1")
   end
   if event.spineEvent == "loopStart" then
       if self.aura ~= nil then
           self.aura:takeAnimation(0,"MD_loop",true);
       end
   end
   return 1
end

function class:setAura(unit)
    self:takeMD(unit)
   if self.aura ~= nil then
      self.aura:takeAnimation(0,"MD_in",true);
       self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
      return 
   end
   self.aura = unit:addOrbitSystemWithFile("MD_1","MD_in");
    self.aura:setOrbitType(4)
   self.aura:takeAnimation(0,"MD_in",true);
   self:auraPosition(unit)
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
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


   if event.index == 3 then
      --超レオーネアビリティ対応
      self:checkPlusMdTime(event.unit);
      if not self.isAura then
         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
         self.loopStart1FLG = true---オーラを出すためのフラグ
         self.isAura = true
         self.isBeforeSkill = true
         self:showMDTimer(event.unit,self.BUFF_BOX_LIST[2].ID)---マギアドライブタイマー表示
         self:addBuff(event.unit,self.BUFF_BOX_LIST)
         event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.afterMD].VOICE)
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

function class:showMDTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_magia_d_time_gray.png","battle_magia_d_time.png",0,"unit/battle_trans_skill/frame_magiadrive.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
end

function class:checkPlusMdTime(unit)
    local cond = unit:getTeamUnitCondition():findConditionWithType(172);
    if cond ~= nil then
        self.AURA_INTERVAL = self.mdTime + cond:getValue();
        self.BUFF_BOX_LIST[0].DURATION = self.AURA_INTERVAL;
        self.BUFF_BOX_LIST[1].DURATION = self.AURA_INTERVAL;
        self.BUFF_BOX_LIST[2].DURATION = self.AURA_INTERVAL;
    else
        self.AURA_INTERVAL = self.mdTime;
        self.BUFF_BOX_LIST[0].DURATION = self.AURA_INTERVAL;
        self.BUFF_BOX_LIST[1].DURATION = self.AURA_INTERVAL;
        self.BUFF_BOX_LIST[2].DURATION = self.AURA_INTERVAL;
    end
end

--===================================================================================================================
-- バフ関係
--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit,buffBoxList,index)
    if index == nil then 
        self:addBuffRange(unit,buffBoxList,0,table.maxn(buffBoxList))
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