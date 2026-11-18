local class = summoner.Bootstrap.createUnitClass({label="タマエ様", version=1.3, id=102895112});

class.SPVALUE = 10;


function class:start(event)
	self:setBuffBoxList()
	return 1;
end

function class:setBuffBoxList()
	self.defaultID = 102890
	self.BUFF_BOX_LIST = {
		[1] = {
			ID = self.defaultID,
			BUFF_ID = 0,
			VALUE = 0,
			DURATION = 99999,
			ICON = 0
		},
		[2] = {
			ID = self.defaultID,
			BUFF_ID = 0,
			VALUE = 0,
			DURATION = 99999,
			ICON = 0
		}
	}
end

function class:attackDamageValue(event)
	self.BUFF_BOX_LIST[1].ID = self.BUFF_BOX_LIST[1].ID + event.enemy:getIndex()
	self:execAddBuff(event.enemy,self.BUFF_BOX_LIST[1])
	self.BUFF_BOX_LIST[2].ID = self.BUFF_BOX_LIST[2].ID + event.enemy:getIndex()
	local unit = self:getAncestorUnit(event.unit)
	self:execAddBuff(unit,self.BUFF_BOX_LIST[2])
	self.BUFF_BOX_LIST[1].ID = self.defaultID
	self.BUFF_BOX_LIST[2].ID = self.defaultID
	return event.value
end

function class:attackDamageValue_OrbitSystem(event)
	self.BUFF_BOX_LIST[1].ID = self.BUFF_BOX_LIST[1].ID + event.enemy:getIndex()
	self:execAddBuff(event.enemy,self.BUFF_BOX_LIST[1])
	self.BUFF_BOX_LIST[2].ID = self.BUFF_BOX_LIST[2].ID + event.enemy:getIndex()
	local unit = self:getAncestorUnit(event.unit)
	self:execAddBuff(unit,self.BUFF_BOX_LIST[2])
	self.BUFF_BOX_LIST[1].ID = self.defaultID
	self.BUFF_BOX_LIST[2].ID = self.defaultID
	return event.value
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
	if unit:getParentTeamUnit() == nil then
		return unit
	else
		return self:getAncestorUnit(unit:getParentTeamUnit())
	end
end

function class:update(event)
	--self:deadCheck(event.unit,event.deltaTime);
	self:enemyCheck(event.unit)
	return 1;
end

function class:enemyCheck(unit)
	for i = 0,6 do
		local ID = self.defaultID + i
		local buff = unit:getTeamUnitCondition():findConditionWithID(ID)
		if buff ~= nil then
			--summoner.Utility.messageByEnemy("敵死亡確認開始"..ID)
			local unitTeam = unit:getTeam()
			local targetTeam = nil
			if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
				targetTeam = megast.Battle:getInstance():getTeam(true)
			else
				targetTeam = megast.Battle:getInstance():getTeam(false)
			end
			local FLG = false
			for i = 0,6 do
				local enemyTeamUnit = targetTeam:getTeamUnit(i)
				if enemyTeamUnit ~= nil then
					local enemyBuff = enemyTeamUnit:getTeamUnitCondition():findConditionWithID(ID)
					if enemyBuff ~= nil then
						FLG = true
						enemyTeamUnit:getTeamUnitCondition():removeCondition(enemyBuff)
					end
				end
			end
			if not FLG then
				unit:addSPWithPvpCorrection(self.SPVALUE)
				--summoner.Utility.messageByEnemy("死亡確認"..ID)
			end
			unit:getTeamUnitCondition():removeCondition(buff)
			--summoner.Utility.messageByEnemy("敵死亡確認終了"..ID)
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
		buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
		if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
		if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
		if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
		if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
		if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
	end
end

class:publish();

return class;