local class = summoner.Bootstrap.createUnitClass({label="こーとにー", version=1.5, id=102186512});

--バフカウンター配列


class.BUFF_ID = 10210;
class.BUFF_ID2 = 102102;

function class:start(event)
    self.gameUnit = event.unit;
    self:resetEffect();
    self.hitList = {};
    return 1;
end

function class:excuteAction(event)
    self:resetEffect();
    return 1;
end


function class:takeDamage(event)
    self:resetEffect();
    return 1;
end

function class:attackDamageValue(event)
    local controll = event.unit:isMyunit() or event.unit:getisPlayer() == false;
    if self.isEffect and controll then
        local targetIndex = event.enemy:getIndex();
        if not self:isContainUnit(targetIndex) then
            self:setHitUnit(targetIndex);
            self:addBuff(event.unit,targetIndex);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,targetIndex);
        end
    end
    return event.value;
end


function class:run(event)
    if event.spineEvent == "addEffect" then
        self.isEffect = true;
    end
    return 1;
end


function class:addBuff(unit,index)
    
    local target = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(index);
    if target ~= nil then
        local cond = target:getTeamUnitCondition():findConditionWithGroupID(3074);--レムなどの「攻防ダウン」系の効果
        
        if cond ~= nil and cond:getPriority() <= 50 then
            target:getTeamUnitCondition():removeCondition(cond);
            local cond2 = target:getTeamUnitCondition():findConditionWithGroupID(3074);
            if cond2 ~= nil then
                target:getTeamUnitCondition():removeCondition(cond2);
            end
            local newCond = target:getTeamUnitCondition():addCondition(self.BUFF_ID,15,-50,15,6);
            local newCond2 = target:getTeamUnitCondition():addCondition(self.BUFF_ID2,13,-50,15,4);
            newCond:setGroupID(3074);
            newCond2:setGroupID(3074);
            newCond:setPriority(50);
            newCond2:setPriority(50);
        elseif cond == nil then
            local newCond = target:getTeamUnitCondition():addCondition(self.BUFF_ID,15,-50,15,6);
            local newCond2 = target:getTeamUnitCondition():addCondition(self.BUFF_ID2,13,-50,15,4);
            newCond:setGroupID(3074);
            newCond2:setGroupID(3074);
            newCond:setPriority(50);
            newCond2:setPriority(50);
        end
        
    end


end

function class:resetEffect()
    self.isEffect = false;
    self.hitList = {};
end

function class:setHitUnit(value)
    self.hitList[value] = true;
end

function class:isContainUnit(value)
    return true == self.hitList[value];
end

function class:receive1(args)
    self:addBuff(self.gameUnit,args.arg);
    return 1;
end


class:publish();

return class;
