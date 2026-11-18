local class = summoner.Bootstrap.createUnitClass({label="闇シーリア", version=1.3, id=102546512});

--古代種バフ
class.ANCIENT_BUFF_ARGS = {
    [0] = {
       ID = 1025465121,
       BUFF_ID = 13,
       VALUE =20,
       DURATION = 9999,
       ICON = 195,
       COUNT_MAX = 5
   }
}

class.ANCIENT_PARFECT_BUFF_ARGS = {
    [0] = {
       ID = 1025465122,
       BUFF_ID = 22,
       VALUE =100,
       DURATION = 9999,
       ICON = 0
    },
    [1] = {
       ID = 1025465125,
       BUFF_ID = 17,
       VALUE =100,
       DURATION = 9999,
       ICON = 0
    }

}

class.ANCIENT_TRUEARTS_BUFF_ARGS = {
    [0] = {
       ID = 1025465123,
       BUFF_ID = 10,
       VALUE =3,
       DURATION = 10,
       ICON = 36,
       GROUP_ID = 1034,
       PRIORITY = 30
   }
}


class.ANCIENT_TRUEARTS_BUFF_ARGS2 = {
    [0] = {
       ID = 1025465124,
       BUFF_ID = 10,
       VALUE = 6,
       DURATION = 20,
       ICON = 36,
       GROUP_ID = 1034,
       PRIORITY = 120
   }
}

class.SP_ABSORB_AMOUNT = 5;

function class:start(event)
	self.gameUnit = event.unit;
	self.isSkillAttack = false;
	self.skillHitList = {};
	self.ancientCount = 0;
  self.isShowEffect = false
    self:setAncientCount(event.unit,0);

	-- if self:getAncientCount(event.unit) > 0 then
	-- 	self.ancientCount = self:getAncientCount(event.unit);
	-- 	self:addBuff1(event.unit,self.ancientCount);
	-- end


	return 1;
end

function class:startWave(event)
   if not self.isShowEffect then
      self:showEffect(event.unit)
   end
   return 1
end

function class:showEffect(unit)
   self.isShowEffect = true
   self:switchUnitEffect(unit,self.isShowEffect)
end


function class:attackDamageValue(event)
	if self.isSkillAttack and self:checkHitList(event.unit,event.enemy:getIndex()) then
    local sp_value = self.SP_ABSORB_AMOUNT;
    local sp_percent = 1 - (event.enemy:getTeamUnitCondition():findConditionValue(140) / 100);
    if sp_percent < 0 then 
       sp_percent = 0;
    end
    sp_value = sp_value * sp_percent;
    if event.enemy:getBurstPoint() - sp_value > 0 then
      event.enemy:setBurstPoint(event.enemy:getBurstPoint() - sp_value);
      event.unit:addSPNonPvpCorrection(sp_value);
    else
      event.unit:addSPNonPvpCorrection(event.enemy:getBurstPoint());
      event.enemy:setBurstPoint(0);
    end
  end
	return event.value;
end

function class:takeAttack(event)
   self:showEffect(event.unit)
	self.isSkillAttack = false;
	return 1;
end

function class:takeSkill(event)
   self:showEffect(event.unit)
	self.isSkillAttack = false;
	if event.index == 1 then
		self.isSkillAttack = true;
		self.skillHitList = {};
	end
	return 1;
end

function class:takeDamage(event)
	self.isSkillAttack = false;
	return 1;
end

function class:run(event)
    if event.spineEvent == "addBuff1" and self:getIsControll(event.unit) then
    	self.ancientCount = self.ancientCount < 5 and self.ancientCount + 1 or self.ancientCount;
        self:addBuff1(event.unit,self.ancientCount);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.ancientCount);
    end

    if event.spineEvent == "addBuff2" and self:getIsControll(event.unit) then
       	self:addBuff2(event.unit,self.ancientCount);
       	megast.Battle:getInstance():sendEventToLua(self.scriptID,2,self.ancientCount); 
    end

   if event.spineEvent == "invisible" then
      self.isShowEffect = false
      self:switchUnitEffect(event.unit,self.isShowEffect)
   end

   if event.spineEvent == "showEffect" then 
      self:showEffect(event.unit)
   end

    return 1;
end

function class:update(event)
   self:invisible(event.unit)
   return 1
end

function class:invisible(unit)
   if not self.isShowEffect then
      self:switchUnitEffect(unit,self.isShowEffect)
   end
end

function class:switchUnitEffect(unit,bool)
  local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
  if conditionSize == 0 then
    return 
  end

  for i = 0,(conditionSize - 1) do
     local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
     cond:setUnitEffectVisible(bool)
  end
end

function class:addBuff1(unit,count)
	if unit:getLevel() < 70 then
		return ;
	end
	self:addBuffs(unit,self.ANCIENT_BUFF_ARGS,count);
	self:setAncientCount(unit,count);
	if count >= 5 then
		self:addBuffs(unit,self.ANCIENT_PARFECT_BUFF_ARGS,1);
	end
end


function class:addBuff2(unit,count)
	if count >= 5 then
		self:addBuffAll(unit,self.ANCIENT_TRUEARTS_BUFF_ARGS2,1);
	else
		self:addBuffAll(unit,self.ANCIENT_TRUEARTS_BUFF_ARGS,1);
	end
end

function class:addBuffAll(unit,buffBox,buffRank)
   for i = 0,6 do
      local teamUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i)
      if teamUnit ~= nil then
         self:addBuffs(teamUnit,buffBox,buffRank)
      end
   end
end

function class:addBuffs(unit,buffBoxList,buffRank)
   for i,buffBox in pairs(buffBoxList) do
      self:execAddBuff(unit,buffBox,buffRank)
   end
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox,buffRank)
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
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * buffRank,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * buffRank,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end


    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end

    if buffBox.COUNT_MAX ~= nil then
	    if buffRank < buffBox.COUNT_MAX then
	        buff:setNumber(buffRank)
	        megast.Battle:getInstance():updateConditionView()
	     else
	       buff:setNumber(10)
	       megast.Battle:getInstance():updateConditionView()
	    end
	end
    

end

function class:checkHitList(event,index)
	if self.skillHitList[index] ~= nil then
		return false;
	end
	self.skillHitList[index] = true;
	return true;
end

function class:setAncientCount(unit,count)
	unit:setParameter("254_AncientCount",""..count);
end

function class:getAncientCount(unit)
	local tmp = unit:getParameter("254_AncientCount");
	if tmp ~= nil and tmp ~= "" and tmp ~= "false" then
		return tonumber(tmp);
	end
	return 0;
end

function class:receive1(args)
    self.ancientCount = args.arg;
    self:addBuff1(self.gameUnit,args.arg);
    return 1;
end

function class:receive2(args)
    self:addBuff2(self.gameUnit,args.arg);
    return 1;
end

function class:getIsControll(unit)
     return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

class:publish();

return class;