local class = summoner.Bootstrap.createUnitClass({label="ルーデウス", version=1.9, id=107516312});

class.range = {
   left = -200,
   right = 200,
   up = 50,
   down = -50
}

function class:getBuffBox(value)
   local buffBox = {
      ID = 1075163121,
      BUFF_ID = 17, -- ダメージ
      VALUE = 30 * value,
      DURATION = 20,
      ICON = 31,
      GROUP_ID = 1064,
      PRIORITY = 30 * value,
      SCRIPT = {
         SCRIPT_ID = 58
      }
   }
   return buffBox
end

function class:start(event)
   self.enemyList = {}
   self.swampX = 0
   self.swampY = 0
   self.total = event.unit:getParameter("total") == "" and 0 or tonumber(event.unit:getParameter("total"))
   return 1
end

function class:startWave(event)
   self.enemyList = {}
   self.isSwamp = false
   return 1
end

function class:attackElementRate(event)
   local skillType = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
   if skillType ~= 1 then
      return event.value;
   end
   local el = event.enemy:getElementType();
   if el == kElementType_Earth then
      event.value = megast.Battle:getInstance():getElementalRate(1,3)
   end
   return event.value;
end

function class:update(event)
   if self.isSwamp then
      for _,list in ipairs(self.enemyList) do
         if list.teamUnit ~= nil and list.teamUnit:getParameter("total") == list.total and list.orbit ~= nil then
            local x = list.teamUnit:getPositionX() + list.teamUnit:getSkeleton():getBoneWorldPositionX("root")
            local y = list.teamUnit:getPositionY() + list.teamUnit:getSkeleton():getBoneWorldPositionY("root")
            list.orbit:setPosition(x,y)
         end
      end
   end
   return 1
end

function class:run(event)
   if event.spineEvent == "swamp" then
      local target = event.unit:getTargetUnit()
      if target ~= nil then
         self:setSwamp(event.unit,target)
      end
   end
   if event.spineEvent == "skill2Shot" then
      self.enemyList = {}
      local hit = event.unit:addOrbitSystem("hit_skill2")
      hit:setDamageRateOffset(0.5)
      hit:setBreakRate(0.5)
      hit:setPosition(self.swampX,self.swampY)
      for i = 0,6 do
         local teamUnit = megast.Battle:getInstance():getTeam(not event.unit:getisPlayer()):getTeamUnit(i);
         if teamUnit ~= nil then
            self.isSwamp = true
            local x = teamUnit:getPositionX() + teamUnit:getSkeleton():getBoneWorldPositionX("MAIN")
            local y = teamUnit:getPositionY() + teamUnit:getSkeleton():getBoneWorldPositionY("MAIN")
            if self:checkPosition(x,y) then
               local orbit
               if teamUnit:getSize() == 3 then
                  orbit = event.unit:addOrbitSystem("earthcuffs_large",0)
               else
                  orbit = event.unit:addOrbitSystem("earthcuffs_small",0)
               end
               orbit:setPosition(x,y)
               self.total = self.total + 1
               event.unit:setParameter("total",self.total)
               teamUnit:setParameter("total",self.total)
               table.insert(self.enemyList,{orbit = orbit,teamUnit = teamUnit,total = self.total})
            end
         end
      end
   end
   if event.spineEvent == "endShot" then
      self.isSwamp = false
   end
   return 1
end

function class:setSwamp(unit,target)
   self.enemyList = {}
   local swamp = unit:addOrbitSystem("swanp")
   self.swampX = target:getPositionX() + target:getSkeleton():getBoneWorldPositionX("root")
   self.swampY = target:getPositionY() + target:getSkeleton():getBoneWorldPositionY("root")
   swamp:setDamageRateOffset(0.5)
   swamp:setBreakRate(0.5)
   swamp:setPosition(self.swampX, self.swampY)
end

function class:checkPosition(x,y)
   if self.swampX + self.range.left < x and x < self.swampX + self.range.right and self.swampY + self.range.down < y and y < self.swampY + self.range.up then
      return true
   end
   return false
end



function class:takeSkill(event)
   if event.index == 3 then
      local count = self:countTeam(event.unit)
      for i = 0,6 do
         local team = event.unit:getTeam():getTeamUnit(i);
         if team ~= nil then
            self:execAddBuff(team,self:getBuffBox(count))
         end
      end
   end
   return 1
end

function class:countTeam(unit)
   local count = 0
   for i = 0,6 do
      local team = unit:getTeam():getTeamUnit(i);
      if team ~= nil and team:getElementType() == kElementType_Earth then
         count = count + 1
      end
   end
   return count
end
-- バフ処理実行
function class:execAddBuff(unit,buffBox)
   local buff  = nil;
   if buffBox.GROUP_ID ~= nil then
      local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
      if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
         unit:getTeamUnitCondition():removeCondition(cond);
      elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
         return;
      end
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


class:publish();

return class;