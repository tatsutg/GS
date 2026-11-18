local class = summoner.Bootstrap.createUnitClass({label="ソレイユ", version=1.3, id=101226112});

--------[[バフ]]--------
function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
        ID = class.BURN_UNIQ_ID,
        BUFF_ID = 0, -- アイコンだけ
        VALUE = 0,
        DURATION = 999999,
        ICON = 104
      },
      [2] = {
        ID = class.BURN_UNIQ_ID,
        BUFF_ID = 0, -- アイコンだけ
        VALUE = 0,
        DURATION = 999999,
        ICON = 105
      }
   }
end

--------[[定数]]--------
class.PROBABILITY_SKILL1 = 100
class.PROBABILITY_SKILL2 = 100
class.BURN_MAX = 3
class.BURN_UNIQ_ID = 1012261121

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.gameUnit = event.unit
   self.skill1Flg = false
   self.skill1BPUp = 20
   self.burnCount = 0
   self:setBuffBoxList()
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.skill1Flg then
        self.skill1Flg = false
        event.unit:addSPWithPvpCorrection(self.skill1BPUp)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        self.skill1Flg = true
    elseif event.index == 2 then
        self.skill1Flg = false
    elseif event.index == 3 then
        self.skill1Flg = false
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "skill1Shot" then self:skill1Shot(event.unit) end
   if event.spineEvent == "BurstBurningSkill1" then self:burnSkill1(event.unit) end
   if event.spineEvent == "BurstBurningSkill2" then  self:burnSkill2(event.unit) end
   if event.spineEvent == "additionAttack" then self:additionAttack() end
   return 1
end

function class:skill1Shot(unit)
   unit:addOrbitSystemInsightRotation("2_skill1_boll","2_skill1_explosion",1,-60,100,180,0)
end

function class:burnSkill1(unit)
   self:countUpBurning(unit)
end

function class:burnSkill2(unit)
   self:burstBurning(unit)
end

function class:countUpBurning(unit)
   if self:isController(unit) then
      self.burnCount = self.burnCount + 1
      if self.burnCount >= self.BURN_MAX then
        self.burnCount = 0
        self:burstBurning(unit)
      end
      self:switchBurnIcon(unit,self.burnCount)
      megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.burnCount);
   end
end

function class:receive1(args)
   self:switchBurnIcon(self.gameUnit,args.arg)   
   return 1
end

function class:switchBurnIcon(unit,index)
   self:execRemoveCondition(unit,class.BURN_UNIQ_ID)
   if index ~= 0 then
      self:execAddBuff(unit,self.BUFF_BOX_LIST[index])
   end
end

function class:burstBurning(unit)
   unit:getNormalSkill():runSkillEffect(0)
end

function class:isController(unit)
   local isHost = megast.Battle:getInstance():isHost();
   local isPlayer = unit:getisPlayer();

   if unit:isMyunit() or not isPlayer and isHost then
      return true;
   end   
   return false;
end

function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
       buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
       buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
end

function class:execRemoveCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
    end  
end

function class:countBurn()
    local cnt = 0;
    for i=0,7 do
       local tgt = megast.Battle:getInstance():getTeam(not self.gameUnit:getisPlayer()):getTeamUnit(i);
       if tgt ~= nil and tgt:getTeamUnitCondition():findConditionValue(97) > 0 then
         cnt = cnt + 1;
       end
    end

    return cnt;
end

function class:additionAttack()
    local animName = ""
    local cnt = self:countBurn();
    if cnt < 1 then
       return
    end
    if self:isController(self.gameUnit) then
       self:makeOrbit(cnt);
       megast.Battle:getInstance():sendEventToLua(self.scriptID,2,cnt);
    end
end

function class:makeOrbit(level)
    if level > 6 then
       level = 6;
    end
    animName = "addition"..level;
    local orb = self.gameUnit:addOrbitSystem(animName,0);
    orb:setActiveSkill(0);
    orb:setDamageRateOffset(level * 10/self.gameUnit:getNormalSkill():getDamageRate());
    orb:setBreakRateOffset(0);
end

function class:receive2(args)
   self:makeOrbit(args.arg); 
   return 1
end

class:publish();

return class;
