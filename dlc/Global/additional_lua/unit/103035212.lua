local class = summoner.Bootstrap.createUnitClass({label="ヴィラーゴ", version=1.8, id=103035212});

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 1030362121,
         BUFF_ID = 13,      --攻撃力
         VALUE = 10,        --効果量
         DURATION = 9999999,
         ICON = 200,
         COUNT = 1,
         COUNT_MAX = 5,
         VALUE_BASE = 10,
         VALUE_MAX = 50
      },
      [2] = {
         ID = 1030362122,
         BUFF_ID = 15,      --防御力
         VALUE = 10,        --効果量
         DURATION = 9999999,
         ICON = 0,
         COUNT = 1,
         COUNT_MAX = 5,
         VALUE_BASE = 10,
         VALUE_MAX = 50
      }
   }
end

function class:start(event)
   self.gameUnit = event.unit
   self.defaultDamageRate = 750
   self:setBuffBoxList()
    self.gameUnit:setParameter("303_Squire","0");
   return 1
end

function class:run(event)
   if event.spineEvent == "addBuff" then
      if event.unit:isMyunit() then
         self:checkValue(self.BUFF_BOX_LIST[1])
         self:checkValue(self.BUFF_BOX_LIST[2])
         megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.BUFF_BOX_LIST[1].COUNT);
         self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[1].COUNT)
         self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2],self.BUFF_BOX_LIST[2].COUNT)
          local count = self.BUFF_BOX_LIST[1].COUNT
          if count >= 5 then count = 5 end
          self.gameUnit:setParameter("303_Squire",""..count);
         self:count(self.BUFF_BOX_LIST[1])
         self:count(self.BUFF_BOX_LIST[2])
      end
   end

   if event.spineEvent == "link" then
      self:checkBuff(event.unit:getCurrentLinkPartner())
   end
   return 1
end

function class:checkBuff(oberu)
   local buff =  oberu:getTeamUnitCondition():findConditionWithID(1030264121)
    if buff ~= nil then
        if buff:getNumber() >= 10 and self.BUFF_BOX_LIST[1].COUNT >= 10 then
            self:addDamage(oberu:getCurrentLinkOrbitSystem(),self.defaultDamageRate + 750)
            return;
        end
    end
    self:addDamage(oberu:getCurrentLinkOrbitSystem(),self.defaultDamageRate)
end

function class:addDamage(unit,value)
   unit:getActiveBattleSkill():setDamageRate(value)
end

function class:checkValue(buffBox)
   if buffBox.COUNT < buffBox.COUNT_MAX then
      buffBox.VALUE = buffBox.VALUE_BASE * buffBox.COUNT
   else 
      buffBox.VALUE = buffBox.VALUE_MAX
      buffBox.COUNT = 10
   end
end

function class:count(buffBox)
   if buffBox.COUNT < buffBox.COUNT_MAX then
      buffBox.COUNT = buffBox.COUNT + 1
   else
      buffBox.COUNT = 10
   end

end

function class:receive1(args)
   self.BUFF_BOX_LIST[1].COUNT = args.arg
   self.BUFF_BOX_LIST[2].COUNT = args.arg
   self:checkValue(self.BUFF_BOX_LIST[1])
   self:checkValue(self.BUFF_BOX_LIST[2])
   self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[1].COUNT)
   self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2],self.BUFF_BOX_LIST[2].COUNT)
    local count = self.BUFF_BOX_LIST[1].COUNT
    if count >= 5 then count = 5 end
    self.gameUnit:setParameter("303_Squire",""..count);
   return 1;
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox,count)
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
    if count ~= nil then
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end
end

class:publish();

return class;