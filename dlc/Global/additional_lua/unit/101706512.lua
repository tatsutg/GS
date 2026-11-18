local class = summoner.Bootstrap.createUnitClass({label="ダリア", version=1.3, id=101706512});

class.TRUEARTS_BUFF_ARGS = {
    [0] = {
       ID = 1017065121,
       BUFF_ID = 10,
       VALUE = 3,
       DURATION = 20,
       ICON = 36,
       GROUP_ID = 3397,
       PRIORITY = 3
   }
}

class.TRUEARTS_BUFF_ARGS2 = {
    [0] = {
       ID = 1017065122,
       BUFF_ID = 17,
       VALUE =50,
       DURATION = 20,
       ICON = 26,
       GROUP_ID = 3160,
       PRIORITY = 50
   }
}


function class:start(event)
    self.badStatusUnits = {};
    self.targetTable = {
        new = function(_index,_rate)
            return {index = _index,rate = _rate}
        end 
    };
    self.orbits = {};
    self.lockOnOrbit = {
        new = function(_index,_orbit)
            return {index = _index,orbit = _orbit}
        end 
    }

    self.gameUnit = event.unit;

    return 1;
end

function class:attackDamageValue(event)
    
    local skillType = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if skillType ~= 2 then
        return event.value;
    end

    local skill = event.unit:getActiveBattleSkill();

    if skill == nil then
        return event.value;
    end

    if skill:isBurst2() then
        return event.value;
    end

    for i=1,table.maxn(self.badStatusUnits) do
        if event.enemy:getIndex() == self.badStatusUnits[i].index then
            self:bomber(event.unit,event.enemy);
            local damageRate = 1.5 +  (0.5 * self.badStatusUnits[i].rate)
         
            event.value = event.value * damageRate;
            
            table.remove(self.badStatusUnits,i);
            break;
        end
    end
    return event.value;
end


function class:update(event)
    for i=1,table.maxn(self.orbits) do
        local target = megast.Battle:getInstance():getTeam(not event.unit:getisPlayer()):getTeamUnit(self.orbits[i].index);
        if target ~= nil then
            self.orbits[i].orbit:setPositionX(target:getAnimationPositionX());
            self.orbits[i].orbit:setPositionY(target:getAnimationPositionY());
        end
    end
    return 1;
end

function class:run(event)
    if event.spineEvent == "findBadStatus" then self:findBadStatus(event.unit) end
    if event.spineEvent == "orbitEnd" then self:orbitEnd(event.unit) end
    if event.spineEvent == "addTrueArtsBuff" then self:addTrueArtsBuff(event.unit) end
    return 1;
end

function class:findBadStatus(unit)
    for i = 0,7 do
        local target = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
        if target ~= nil then
            local cnt = self:countBadStatus(target);
            if cnt > 0 then
                self:addOrbit(unit,target);
                local  tmp = self.targetTable.new(target:getIndex(),cnt);
                local buff = unit:getTeamUnitCondition():addCondition(-1,22,100,10,0);
                buff:setScriptID(84);
                buff:setValue1(target:getIndex());
                table.insert(self.badStatusUnits,tmp);
            end
        end
    end
end

function class:countBadStatus(unit)
    local cnt = 0;
    local badStatusIDs = {89,90,91,92,93,94,95,96,97,129,131,135};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
       
        local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
        if cond ~= nil then
            cnt = cnt + 1;
        end
        
    end
    return cnt;
end

function class:countBadStatusFromAllEnemys(unit)
    local max = 0;
    for i=0,7 do
        local targetUnit = Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
        if targetUnit ~= nil then
            local count = self:countBadStatus(targetUnit);
            if count > max then
                max = count;
            end
        end
    end
    return max;
end

function class:addOrbit(unit,target)
    local orbit = unit:addOrbitSystem("target");
    orbit:setPositionX(target:getAnimationPositionX());
    orbit:setPositionY(target:getAnimationPositionY());
    local tmp = self.lockOnOrbit.new(target:getIndex(),orbit);
    table.insert(self.orbits,tmp);
end

function class:bomber(unit,target)
    local orbit = unit:addOrbitSystem("hit");
    orbit:setPositionX(target:getAnimationPositionX());
    orbit:setPositionY(target:getAnimationPositionY());
end


function class:orbitEnd(unit)
    local hit = 0;
    for i=1,table.maxn(self.orbits) do
        if self.orbits[i].orbit == unit then
            hit = i;
        end
    end
    table.remove(self.orbits,hit);
end

function class:addTrueArtsBuff(unit)
    local rate = self:countBadStatusFromAllEnemys(unit);
    if rate <= 0 then
        return;
    end
    if self:isControll(unit) then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,rate);
        self:innerAddTrueArtsBuff(unit,rate);
    end
end

function class:innerAddTrueArtsBuff(unit,rate)
    self:addBuffs(unit,self.TRUEARTS_BUFF_ARGS,rate);
    for i = 0,7 do
        local teamUnit = unit:getTeam():getTeamUnit(i);
        if teamUnit ~= nil then
            --バフかけ
            self:addBuffs(teamUnit,self.TRUEARTS_BUFF_ARGS2,rate);
        end
    end
end

--============================================================================================
--バフかけ周り（テンプレ）
--============================================================================================

function class:addBuffs(unit,buffs,rate)
    for k,v in pairs(buffs) do
        self:execAddBuff(unit,v,rate);
    end
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox,rate)
  if buffBox.GROUP_ID ~= nil then
    local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
    if cond ~= nil then
        if cond:getPriority() > buffBox.PRIORITY * rate then
            return;
        end
        --同一優先度で自分のバフよりも長時間持続するものには手を触れない
        if cond:getPriority() == buffBox.PRIORITY * rate and cond:getTime() > buffBox.DURATION then
            return;
        end
        if buffBox.EXCEPTION == nil or cond:getID() ~= buffBox.EXCEPTION then
          unit:getTeamUnitCondition():removeCondition(cond);
        end
    end
    self:addConditionWithGroup(unit,buffBox,rate);
    return;
  end

    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * rate,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * rate,buffBox.DURATION,buffBox.ICON);
    end
    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end

end

--グループIDつきバフ
function class:addConditionWithGroup(unit,buffBox,rate)
  
    local newCond = nil;
    if buffBox.EFFECT ~= nil then
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * rate,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * rate,buffBox.DURATION,buffBox.ICON);
    end
    newCond:setGroupID(buffBox.GROUP_ID);
    newCond:setPriority(buffBox.PRIORITY * rate);
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
    self:innerAddTrueArtsBuff(self.gameUnit,args.arg);
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
