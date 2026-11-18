local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="デューク", version=1.3, id=102525512});

-- ブレイクポイント減少(固定値/レイド)
class.REDUCE_BREAKPOINT_CONSTANT = 20000
-- ブレイクポイント減少(固定値/クロスバトル)
class.REDUCE_BREAKPOINT_CONSTANT_CROSS = 20000

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
         SKILL_NAME = self.TEXT.AFTER_MD or "アブソリュート・カリング",
         SE = "SE_BATTLE_040_UNIT_CALL"
      }
   }
end

function class:setBuffBoxList(duration)
   self.BUFF_BOX_LIST = {
     [1] = {
      ID = 1025255121,
      BUFF_ID = 0, -- MDアイコンのみ
      VALUE = 0,
      DURATION = duration or self.AURA_INTERVAL,
      ICON = 186
    },
    [2] = {
      ID = 1025255123,
      BUFF_ID = 24, -- ブレイク力
      VALUE = 1000,
      DURATION = duration or self.AURA_INTERVAL,
      ICON = 0,
      SCRIPT = {
        SCRIPT_ID = 76
      } 
    }
 }

    self.OUGI_BUFF_LIST = {
      [1] = {
         ID = 1025265123,
         BUFF_ID = 21, -- 被ダメUP
         VALUE = 30,
         DURATION = 20,
         ICON = 139,
         GROUP_ID = 2030,
         PRIORITY = 140
      },
      [2] = {
         ID = 1025265124,
         BUFF_ID = 21, -- 被ダメUP
         VALUE = 60,
         DURATION = 20,
         ICON = 139,
         GROUP_ID = 2030,
         PRIORITY = 210
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
   event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)

   self.RATE = 0.05
   self.breakCount = 0
   self.enemyList = {}
   self:setBuffBoxList()
   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   if not self.isAura then
      event.unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
   end

   self:searchOtherDaunt(event.unit)
   return 1
end

function class:searchOtherDaunt(unit)
    if self:checkBossWave() and unit:getisPlayer() then
        --威圧フラグ用バフがPTに居るか確認
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,7 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(1040499);
                if buff ~= nil then
                    return 1
                else
                    myTeamUnit:getTeamUnitCondition():addCondition(1040499,0,0,999999,0)
                end
            end
        end

        self:execute(unit)
    end
end

function class:checkBossWave()
   local boss = megast.Battle:getInstance():getTeam(false):getBoss()
   if boss == nil then
      return false
   end

   return boss:getSize() == 3
end

function class:findUnit(cond)
   local resultTable = {}
   for i = 0,4 do 
      local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
      if target ~= nil and cond(target) then
         return target
      end
   end
end

function class:execute(unit)
    local boss = megast.Battle:getInstance():getTeam(false):getBoss()
    if megast.Battle:getInstance():isRaid() then
        megast.Battle:getInstance():recAddBreakPoint(unit, boss, boss:getBreakPoint() - (boss:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT));
        boss:setBreakPoint(boss:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT);
        RaidControl:get():addBreakPool(self.REDUCE_BREAKPOINT_CONSTANT);
    elseif megast.Battle:getInstance():isCrossBattle() then
        megast.Battle:getInstance():recAddBreakPoint(unit, boss, boss:getBreakPoint() - (boss:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT));
        boss:setBreakPoint(boss:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT_CROSS);
    else
        megast.Battle:getInstance():recAddBreakPoint(unit, boss, boss:getBreakPoint() - (boss:getBreakPoint()/2));
        boss:setBreakPoint(boss:getBreakPoint()/2);
    end
    self:execShowMessage({MESSAGE = self.TEXT.MESSAGE1 or "威圧効果発動",DURATION = 5,COLOR = Color.yellow})
end

function class:execShowMessage(messageBox)
   if self.gameUnit:getisPlayer() then
      summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   else
      summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   end
end

---------------------------------------------------------------------------------
-- endWave
---------------------------------------------------------------------------------
function class:endWave(event)
    self:checkDauntBuffFlg()
    return 1
end

function class:checkDauntBuffFlg()
    --威圧フラグ用バフがPTに居るか確認
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,7 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(1040499);
            if buff ~= nil then
                myTeamUnit:getTeamUnitCondition():removeCondition(buff);
            end
        end
    end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:auraPosition(event.unit)
   self:auraTimer(event.deltaTime,event.unit)
   if self:checkBreak(event.unit) then
      self.gameUnit:addSPWithPvpCorrection(100)
      megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0)
   end
   return 1
end

function class:checkBreak(unit)
   if self.isAura and unit:isMyunit() then
      local boss = megast.Battle:getInstance():getTeam(false):getBoss()
      if boss ~= nil then
         currentBreakCount = megast.Battle:getInstance():getBattleRecord():getBreakCount()
         if self.breakCount < currentBreakCount then
            self.breakCount = currentBreakCount
            return true
         end
         self.breakCount = currentBreakCount
      end
   end
   return false
end

function class:receive3(args)
   self.gameUnit:addSPWithPvpCorrection(100)
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
         unit:setCutinVoice2(self.SURFACE_BOX_LIST[self.beforeMD].VOICE)
         self.aura:takeAnimation(0,"empty",true);
      else
         self.timer = self.timer + deltaTime
      end
   end
end


---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    local activeBattleSkill = event.unit:getActiveBattleSkill();
    local type = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillType;

    if activeBattleSkill == nil then
        return event.value;
    end

    if not activeBattleSkill:isBurst2() and type == 2 then
      if  event.enemy:getBreakPoint() <= 0 then
         self:execAddBuff(event.enemy,self.OUGI_BUFF_LIST[2])
      else
         self:execAddBuff(event.enemy,self.OUGI_BUFF_LIST[1])
      end

    end


    if activeBattleSkill:isBurst2() and type == 2 then
      local mozi = event.enemy:getIsBoss() and event.enemy:getIndex() .. ":true" or event.enemy:getIndex() .. ":none"
      self:execShowMessage({MESSAGE = mozi,DURATION = 5,COLOR = Color.yellow})
      if event.enemy:getIsBoss() and megast.Battle:getInstance():isHost() then
         local index = event.enemy:getIndex()
         self:setBreakValue(index,event.value * self.RATE)
         megast.Battle:getInstance():sendEventToLua(self.scriptID,1,(self:getBreakValue(index) * 10) + event.enemy:getIndex());
      end
    end

    return event.value;
end

function class:receive1(args)
    self:setBreakValue(args.arg % 10,args.arg / 10);
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "md5Start" then
      self:setAura(event.unit)
   end
   if event.spineEvent == "loopStart" then
      self.aura:takeAnimation(0,"MD_loop",true);
   end
   if event.spineEvent == "addBreak" then
      if megast.Battle:getInstance():isHost() then
         self:addBreak()
         megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0)
      end
   end

   return 1
end

function class:receive2(args)
    self:addBreak()
    return 1;
end

function class:setBreakValue(index,value)
   local breakValue = value + self:getBreakValue(index)

   self.enemyList = {
      [index] = breakValue
   }
end

function class:getBreakValue(index)
   return self.enemyList[index] ~= nil and self.enemyList[index] or 0
end

function class:addBreak()
   for i = 0,7 do
       local value = self.enemyList[i]
       if value ~= nil then
         self:execShowMessage({MESSAGE = tostring(i) .. ":" .. value,DURATION = 5,COLOR = Color.green})
          local localUnit = megast.Battle:getInstance():getTeam(not self.gameUnit:getisPlayer()):getTeamUnit(i)
          if localUnit ~= nil then
             localUnit:setBreakPoint(localUnit:getBreakPoint() - value)
             if megast.Battle:getInstance():isRaid() then
                RaidControl:get():addBreakPool(value); 
             end
          end
       end
   end
   self.enemyList = {}
end


function class:setAura(unit)
   if self.aura ~= nil then
      self.aura:takeAnimation(0,"MD_in",true);
      return 
   end
   self.aura = unit:addOrbitSystemWithFile("MD_5","MD_in");
    self.aura:setOrbitType(4)
   self.aura:takeAnimation(0,"MD_in",true);
   self:auraPosition(unit)
end

---------------------------------------------------------------------------------
-- takeSkill 
---------------------------------------------------------------------------------
function class:takeSkill(event)

   if self.isAura then
      if event.index == 1 then
         event.unit:addSPWithPvpCorrection(20)
      end
   end

   if event.index == 3 then
      if not self.isAura then
         self:setSurface(event.unit,self.SURFACE_BOX_LIST[self.beforeMD])
         self.isAura = true
         self.timer = 0
         self.isBeforeSkill = true
         self.gameUnit:addSPWithPvpCorrection(100)
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
    if not self:checkGroupId(unit,buffBox) then
       return
    end

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

   if buffBox.GROUP_ID ~= nil then
      buff:setGroupID(buffBox.GROUP_ID);
      buff:setPriority(buffBox.PRIORITY);
   end
end

function class:checkGroupId(unit,buffBox)
   if buffBox.GROUP_ID == nil then
      return true
   end
   local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
   if cond == nil then
      return true
   end
   if cond:getPriority() <= buffBox.PRIORITY then
      unit:getTeamUnitCondition():removeCondition(cond);
      return true
   end
   return false
end

class:publish();

return class;
