local class = summoner.Bootstrap.createUnitClass({label="UnitName", version=1.3, id=102796212});

class.TRUEARTS_BUFF_ARGS = {
    [0] = {
       ID = 1027962121,
       BUFF_ID = 2,
       VALUE =30,
       DURATION = 10,
       ICON = 1,
       GROUP_ID = 1042,
       PRIORITY = 30,
       EXCEPTION = 1027962122,
       EXCEPTION2 = 1027962123
   },
   [1] = {
       ID = 1027963122,
       BUFF_ID = 13,
       VALUE =30,
       DURATION = 10,
       ICON = 3,
       GROUP_ID = 1042,
       PRIORITY = 30,
       EXCEPTION = 1027962121, --例外的にこのIDのバフとは重複関係を持たない
       EXCEPTION2 = 1027962123
   },
   [2] = {
       ID = 1027963123,
       BUFF_ID = 15,
       VALUE =30,
       DURATION = 10,
       ICON = 5,
       GROUP_ID = 1042,
       PRIORITY = 30,
       EXCEPTION = 1027962121, --例外的にこのIDのバフとは重複関係を持たない
       EXCEPTION2 = 1027962122
   },
   [3] = {
       ID = 1027963124,
       BUFF_ID = 10,
       VALUE =3,
       DURATION = 10,
       ICON = 36,
       GROUP_ID = 1034,
       PRIORITY = 20
   }
}

class.TRUEARTS_BUFF_ARGS2 = {
    [0] = {
       ID = 1027962121,
       BUFF_ID = 2,
       VALUE =30,
       DURATION = 20,
       ICON = 1,
       GROUP_ID = 1042,
       PRIORITY = 30,
       EXCEPTION = 1027962122,
       EXCEPTION2 = 1027962123
   },
   [1] = {
       ID = 1027963122,
       BUFF_ID = 13,
       VALUE =30,
       DURATION = 20,
       ICON = 3,
       GROUP_ID = 1042,
       PRIORITY = 30,
       EXCEPTION = 1027962121, --例外的にこのIDのバフとは重複関係を持たない
       EXCEPTION2 = 1027962123
   },
   [2] = {
       ID = 1027963123,
       BUFF_ID = 15,
       VALUE =30,
       DURATION = 20,
       ICON = 5,
       GROUP_ID = 1042,
       PRIORITY = 30,
       EXCEPTION = 1027962121, --例外的にこのIDのバフとは重複関係を持たない
       EXCEPTION2 = 1027962122
   },
   [3] = {
       ID = 1027963124,
       BUFF_ID = 10,
       VALUE =3,
       DURATION = 20,
       ICON = 36,
       GROUP_ID = 1034,
       PRIORITY = 20
   }
}

class.ARTS_BUFF_ARGS = {
    [0] = {
       ID = 1027962125,
       BUFF_ID = 0,
       VALUE =100,
       DURATION = 10,
       ICON = 0
   }
}

class.ABBIRITY_BUFF_ARGS = {
    [0] = {
       ID = 1027962126,
       BUFF_ID = 22,
       VALUE =1,
       DURATION = 9999,
       ICON = 0
   },
   [1] = {
       ID = 1027962127,
       BUFF_ID = 32,
       VALUE =1,
       DURATION = 9999,
       ICON = 0
   }
}

function class:start(event)
	self.hitCount = 0;
	self.numbersOrbit = nil;
	self.gameUnit = event.unit;
	self.SPValue = 20;
	return 1;
end

function class:attackDamageValue(event)
    local activeBattleSkill = event.unit:getActiveBattleSkill();
    if activeBattleSkill ~= nil and self.hitCount < 99 then
        self.hitCount = self.hitCount + 1;
        
        local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.ARTS_BUFF_ARGS[0].ID);
        if buff ~= nil then
            self.hitCount = self.hitCount + 1 < 99 and self.hitCount + 1 or 99;
        end

        self:setParam(event.unit,self.hitCount);
    end

    return event.value;
end

function class:update(event)

	if self.numbersOrbit == nil then
        self.numbersOrbit = event.unit:addOrbitSystemWithFile("10279num","0");
        self.numbersOrbit:takeAnimation(0,"none",true);
        self.numbersOrbit:takeAnimation(1,"none2",true);
        self.numbersOrbit:setZOrder(10011);
        local cnt = event.unit:getParameter("hitCounter");
        if cnt ~= nil and cnt ~= "" then
            self.hitCount = tonumber(cnt);
        end
    end
    if self.numbersOrbit ~= nil then
        self:numbersControll(event.unit);
    end

    self:criticalBuffCheck(event.unit);
	return 1;
end

function class:run(event)
    if event.spineEvent == "reduceHit" then self:reduceHit(event.unit) end
    if event.spineEvent == "takeAdditionalHitBuff" then self:takeAdditionalHitBuff(event.unit) end
    return 1;
end

function class:excuteAction(event)
    self:sendHit(event.unit);
    return 1;
end

--============================================================================================
--アビリティによるクリティカル上昇
--============================================================================================

function class:criticalBuffCheck(unit)
    local buff = unit:getTeamUnitCondition():findConditionWithID(self.ABBIRITY_BUFF_ARGS[0].ID);
    if self.hitCount >= 3 then
        if buff ~= nil then
            buff:setValue(math.floor(self.hitCount/3));
        else
            self:addBuffs(unit,self.ABBIRITY_BUFF_ARGS);
        end
        local buff2 = unit:getTeamUnitCondition():findConditionWithID(self.ABBIRITY_BUFF_ARGS[1].ID);
        if buff2 ~= nil then
            buff2:setValue(math.floor(self.hitCount/3));
        end
    else
        if buff ~= nil then
            unit:getTeamUnitCondition():removeCondition(buff);
        end
        local buff2 = unit:getTeamUnitCondition():findConditionWithID(self.ABBIRITY_BUFF_ARGS[1].ID);
        if buff2 ~= nil then
            unit:getTeamUnitCondition():removeCondition(buff2);
        end
    end
end


--============================================================================================
--ヒット数表示周り
--============================================================================================

function class:numbersControll(unit)
    local isPlayer = unit:getisPlayer();
    local xpos = unit:getAnimationPositionX()+20 < 400 and unit:getAnimationPositionX()+20 or 400;
    if not isPlayer then
        xpos = unit:getAnimationPositionX()-70 > -400 and unit:getAnimationPositionX()-70 or -400;
        self.numbersOrbit:getSkeleton():setScaleX(-1);
    end
    self.numbersOrbit:setPosition(xpos,unit:getAnimationPositionY()+50);
    self.numbersOrbit:takeAnimation(0,self:intToAnimationNameOne(self.hitCount),true);
    self.numbersOrbit:takeAnimation(1,self:intToAnimationNameTen(self.hitCount),true);
end


function class:intToAnimationNameOne(int)
    local temp = int%10;
    if int == 0 then
        return "none";
    end
    return ""..temp;
end

function class:intToAnimationNameTen(int)
    local temp = math.floor(int/10);
    if temp == 0 then
        return "none2";
    end
    return ""..temp.."0";
end

function class:setParam(unit,int)
    unit:setParameter("279_HitCounter",""..int);
end

function class:sendHit(unit)
    if self:isControll(unit) then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.hitCount);
    end
end

function class:reduceHit(unit)
    if self:isControll(unit) then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,self.hitCount);
        self:innerReduceHit(unit,self.hitCount);          
    end
end

function class:innerReduceHit(unit,hitCount)
    if hitCount < 99 then
        self:addBuffs(unit,self.TRUEARTS_BUFF_ARGS);
        return;
    end
    for i = 0,7 do
        local teamUnit = unit:getTeam():getTeamUnit(i);
        if teamUnit ~= nil then
            --バフかけ
            self:addBuffs(teamUnit,self.TRUEARTS_BUFF_ARGS2);
        end
    end
    self.hitCount = hitCount - 77;
    self:setParam(unit,self.hitCount);
end

function class:takeAdditionalHitBuff(unit)
    self:addBuffs(unit,self.ARTS_BUFF_ARGS);
end

--============================================================================================
--バフかけ周り（テンプレ）
--============================================================================================

function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:execAddBuff(unit,v);
    end
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
  if buffBox.GROUP_ID ~= nil then
    local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
    if cond ~= nil then
        if cond:getPriority() > buffBox.PRIORITY then
            return;
        end
        --同一優先度で自分のバフよりも長時間持続するものには手を触れない
        if cond:getPriority() == buffBox.PRIORITY and cond:getTime() > buffBox.DURATION then
            return;
        end
        if buffBox.EXCEPTION == nil or cond:getID() ~= buffBox.EXCEPTION then
          unit:getTeamUnitCondition():removeCondition(cond);
        end
    end
    self:addConditionWithGroup(unit,buffBox);
    return;
  end

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

--グループIDつきバフ
function class:addConditionWithGroup(unit,buffBox)
  
    local newCond = nil;
    if buffBox.EFFECT ~= nil then
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    newCond:setGroupID(buffBox.GROUP_ID);
    newCond:setPriority(buffBox.PRIORITY);
    if buffBox.SCRIPT ~= nil then
       newCond:setScriptID(buffBox.SCRIPT)
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
 
end

--============================================================================================
--マルチ同期
--============================================================================================

function class:receive1(args)
    self.hitCount = args.arg;
    self:setParam(self.gameUnit,args.arg);
    return 1;
end

function class:receive2(args)
    self:innerReduceHit(self.gameUnit,args.arg);
    return 1;
end


function class:isControll(unit)
    if unit:isMyunit() then
        return true;
    end
    if not unit:getisPlayer() then
        return megast.Battle:getInstance():isHost();
    end

end

class:publish();

return class;