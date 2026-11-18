local class = summoner.Bootstrap.createUnitClass({label="オーヴェル", version=1.8, id=103026412});

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 1030264121,
         BUFF_ID = 17,      --ダメージアップ
         VALUE = 60,        --効果量
         DURATION = 9999999,
         ICON = 201,
         COUNT = 1,
         COUNT_MAX = 5,
         VALUE_BASE = 60,
         VALUE_MAX = 300
      },
      [2] = {
         ID = 1030264122,
         BUFF_ID = 29,      --スキルCT
         VALUE = 20,        --効果量
         DURATION = 9999999,
         ICON = 0,
         COUNT = 1,
         COUNT_MAX = 5,
         VALUE_BASE = 20,
         VALUE_MAX = 100
      }
   }
end

function class:start(event)
   self.gameUnit = event.unit
   self.defaultDamageRate = 750
   self:setBuffBoxList()
    event.unit:setParameter("302_King","0");
   return 1
end

function class:run(event)
   if event.spineEvent == "addBuff" then
       if megast.Battle:getInstance():isHost() then
           megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.BUFF_BOX_LIST[1].COUNT);
           self:addBuffs(event.unit)
       elseif megast.Battle:getInstance():isPvp() then
           self:addBuffs(event.unit)
       end
   end
   if event.spineEvent == "link" then
      self:checkBuff(event.unit:getCurrentLinkPartner())
   end
   return 1
end

function class:addBuffs(unit)
    self:checkValue(self.BUFF_BOX_LIST[1])
    self:checkValue(self.BUFF_BOX_LIST[2])
    self:execAddBuff(unit,self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[1].COUNT)
    self:execAddBuff(unit,self.BUFF_BOX_LIST[2],self.BUFF_BOX_LIST[2].COUNT)
    local count = self.BUFF_BOX_LIST[1].COUNT
    if count >= 5 then count = 5 end
    unit:setParameter("302_King",""..count);
    self:count(self.BUFF_BOX_LIST[1])
    self:count(self.BUFF_BOX_LIST[2])
end

function class:checkBuff(oberu)
   local buff =  oberu:getTeamUnitCondition():findConditionWithID(1030362121)
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
    self.gameUnit:setParameter("302_King",""..count);
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