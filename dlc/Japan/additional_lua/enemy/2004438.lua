local class = summoner.Bootstrap.createUnitClass({label="ガウル", version=1.3, id=2004438});


--------[[バフ]]--------
function class:setBuffBoxList()
   self.BUFF_LIST = {
      [1] = {
         ID = -514000,
         BUFF_ID = 62, -- 水耐性
         VALUE = 15,
         DURATION = 999999,
         ICON = 39
      }
   }

   self.BUFF_LIST_FORDEAD = {
      [1] = {
         ID = -514001,
         BUFF_ID = 17, -- 与ダメ
         VALUE = 5,
         DURATION = 999999,
         ICON = 26
      }
   }

end


function class:start(event)
	self.conditionCheckTimer = 0;
	self.firstUpdate = false;

	self.TEXT.DEAD_MESSAGE1 = self.TEXT.DEAD_MESSAGE1 or "";



	return 1;
end


function class:sarchBoss(unit)
	local team = megast.Battle:getInstance():getTeam(false);
	for i=0,7 do
        local target = team:getTeamUnit(i);
        if target ~= nil and target ~= unit and target:getBaseID3() == 40002 then
            return target;
        end
    end
    return nil;
end





function class:update(event)
	if not self.firstUpdate then
		self.firstUpdate = true;
		self.boss = self:sarchBoss(event.unit);
		self:setBuffBoxList();

		if self.boss ~= nil then
			self:execAddBuff(self.boss,self.BUFF_LIST[1]);
		end
		
	end
	if self:sarchBoss(event.unit) == nil then
		event.unit:setHP(0);
	end
	self:sarchConditionTartget(event.unit,event.deltaTime);
	return 1;
end


function class:dead(event)

	if self:sarchBoss(event.unit) == nil then
		return 1;
	end
  if self.boss ~= nil then
      self:execAddBuff(self.boss,self.BUFF_LIST_FORDEAD[1]);
  end
	self:removeConditionTartget(event.unit);
	return 1;
end

function class:sarchConditionTartget(unit,deltaTime)
	if not self.FORPLAYER then
		return;
	end
	self.conditionCheckTimer = self.conditionCheckTimer + deltaTime;
	if self.conditionCheckTimer < 1 then
		return;
	end

	self.conditionCheckTimer = self.conditionCheckTimer - 1;

	local team = megast.Battle:getInstance():getTeam(not unit.getisPlayer);
	for i=0,7 do
        local target = team:getTeamUnit(i);
        if target ~= nil then
            self:execAddBuff(target,self.BUFF_LIST);
        end
    end

end

function class:removeConditionTartget(unit)

	if not self.FORPLAYER then
		local buff = self.boss:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[1].ID);
    	if buff ~= nil then
        	self.boss:getTeamUnitCondition():removeCondition(buff);
        end
		return;
	end

	local team = megast.Battle:getInstance():getTeam(not unit.getisPlayer);
	for i=0,7 do
        local target = team:getTeamUnit(i);
        if target ~= nil then
        	local buff = target:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[1].ID);
        	if buff ~= nil then
            	target:getTeamUnitCondition():removeCondition(buff);
            end
        end
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