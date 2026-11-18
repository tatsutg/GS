local class = summoner.Bootstrap.createUnitClass({label="覚醒ハルト", version=2.1, id=103276312});

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 1032763121,
         BUFF_ID = 2, -- HP
         VALUE = 10,
         DURATION = 999999,
         ICON = 212,
         MAX = 3
      },
      [2] = {
         ID = 1032763122,
         BUFF_ID = 13, -- 攻撃
         VALUE = 10,
         DURATION = 999999,
         ICON = 0,
         MAX = 3
      },
      [3] = {
         ID = 1032763123,
         BUFF_ID = 15, -- 防御
         VALUE = 10,
         DURATION = 999999,
         ICON = 0,
         MAX = 3
      }
   }
end

function class:start(event)
   self:addChangeSP(event.unit,100,1)
   self:setBuffBoxList()
   self.myIndex = event.unit:getIndex()
   return 1
end

function class:addChangeSP(unit,limit,rate)
   if not megast.Battle:getInstance():isRaid() and not megast.Battle:getInstance():isCrossBattle() then return end

   if unit:getTakeOverBurstPoint() == nil or unit:getLevel() < 70 then return end

   local sp = unit:getTakeOverBurstPoint()*rate > limit and limit or unit:getTakeOverBurstPoint()*rate
   unit:addSPNonPvpCorrection(sp)
end

function class:takeSkill(event)
   if event.unit:getLevel() < 90 then return 1 end

   if not megast.Battle:getInstance():isRaid() and not megast.Battle:getInstance():isCrossBattle() then
      if event.unit:getIndex() ~= self.myIndex then return 1 end
   end

   if event.index == 3 then
      local myTeam = event.unit:getTeam()
      for i = 0,6 do
         local myTeamUnit = myTeam:getTeamUnit(i)
         if myTeamUnit ~= nil then
            self:addBuff301(event.unit,myTeamUnit,self.BUFF_BOX_LIST[1])
            self:addBuff301(event.unit,myTeamUnit,self.BUFF_BOX_LIST[2])
            self:addBuff301(event.unit,myTeamUnit,self.BUFF_BOX_LIST[3])
         end
      end
   end

   return 1
end

function class:addBuff301(unit,target,buffBox)
   if unit:getLevel() < 90 then
      return;
   end
   local level = 0
   local conditionSize = target:getTeamUnitCondition():getAllConditionsSize();
   if conditionSize ~= 0 then
      for i = 0,(conditionSize - 1) do
         local cond = target:getTeamUnitCondition():getAllConditionsAt(i);
         if cond ~= nil then
            if cond:getScriptID() == 301 and buffBox.BUFF_ID == cond:getConditionTypeAsInt() then
               level = cond:getValue1()
               if level >= 3 then
                  break;
               end
               target:getTeamUnitCondition():removeCondition(cond)
               break;
            end
         end
      end
   end
   level = level + 1
   if level > 3 then
      return;
   end
   local buff = target:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * level,buffBox.DURATION,buffBox.ICON);
   buff:setScriptID(301)
   buff:setValue1(level)
   buff:setMaxConditionIconNumber(3);
   buff:setNumber(level)
end

function class:enableChangeBuff(event)
   if not megast.Battle:getInstance():isRaid() and not megast.Battle:getInstance():isCrossBattle() then return 0 end
   if event.unit:getLevel() < 70 then return 0 end
   return 1
end


--===================================================================================================================
-- バフ関係
--===================================================================================================================

function class:addBuff(unit,buffBoxList)

   for _,buffBox in ipairs(buffBoxList) do
      self:execAddBuff(unit,buffBox)
   end
end


function class:execAddBuff(unit,buffBox)
   local team = megast.Battle:getInstance():getTeam(unit:getisPlayer())
   for i = 0,7 do
      local teamUnit = team:getTeamUnit(i);
      if teamUnit ~= nil then
         local buff = teamUnit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
         local num = buff == nil and 1 or buff:getValue1()

         if num < buffBox.MAX then
            num = self:setStatusUp(teamUnit,buffBox,buff,num)
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,(num * 10) + i);
         end
      end
   end
end

function class:setStatusUp(teamUnit,buffBox,buff,num)
   if buff == nil then
      buff = teamUnit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * num,buffBox.DURATION,buffBox.ICON);
      buff:setScriptID(301)
      buff:setValue2(3)
      self:execAnyBuff(teamUnit,buffBox,buff,num)
   elseif num < buffBox.MAX then
      if megast.Battle:getInstance():isHost() then
         num = num + 1
      end
      self:execAnyBuff(teamUnit,buffBox,buff,num)
   elseif not megast.Battle:getInstance():isHost() and num == buffBox.MAX then
      self:execAnyBuff(teamUnit,buffBox,buff,num)
   end
   return num
end

function class:execAnyBuff(teamUnit,buffBox,buff,num)
   local beforeHP = teamUnit:getCalcHPMAX()
   buff:setValue(buffBox.VALUE * num)
   if buffBox.ID == self.BUFF_BOX_LIST[1].ID then
      teamUnit:takeHeal(teamUnit:getCalcHPMAX() - beforeHP)
      buff:setMaxConditionIconNumber(buffBox.MAX);
      buff:setNumber(num)
   end
   buff:setValue1(num)
   megast.Battle:getInstance():updateConditionView()
end

function class:receive1(args)
   local num = math.floor(args.arg / 10)
   local index = args.arg % 10
   local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);

   if target ~= nil then
      for _,buffBox in pairs(self.BUFF_BOX_LIST) do
         local buff = target:getTeamUnitCondition():findConditionWithID(buffBox.ID);
         self:setStatusUp(target,buffBox,buff,num)
      end
   end
   return 1
end

class:publish();

return class;
