local class = summoner.Bootstrap.createUnitClass({label="ココ", version=1.5, id=101916512});


class.ANIMATION_STATE = {
    IDLE = 0,
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    BACK = 5,
    DAMAGE = 6,
    FRONT = 7
}

class.SWORD_BUFFID = 1911;
class.DEVIDE_BUFFID = 1912;

--レイド
class.REDUCE_BREAKPOINT_CONSTANT = 20000
--クロスバトル
class.REDUCE_BREAKPOINT_CONSTANT_CROSS = 20000

function class:start(event)
    self.gameUnit = event.unit;
    self.isDeveide = false;--このフラグが立っている間に攻撃を当てると対象のブレイクを半減させる
    return 1;
end

function class:attackDamageValue(event)
    self:devideBreak(event.unit,event.enemy);
    return event.value;
end

function class:takeIdle(event)
    self:animationSwitcher(event.unit,self.ANIMATION_STATE.IDLE);
    return 1;
end

function class:takeAttack(event)

    self.isDeveide = false;
    self:animationSwitcher(event.unit,self.ANIMATION_STATE.ATTACK1);
    return 1;
end

function class:takeSkill(event)

    self.isDeveide = false;
    if event.index == 1 then
        self:animationSwitcher(event.unit,self.ANIMATION_STATE.SKILL1);
    elseif event.index == 2 then
        self:animationSwitcher(event.unit,self.ANIMATION_STATE.SKILL2);
    else
        self:animationSwitcher(event.unit,self.ANIMATION_STATE.SKILL3);
    end
    return 1;
end

function class:takeDamage(event)
    self.isDeveide = false;
    self:animationSwitcher(event.unit,self.ANIMATION_STATE.DAMAGE);
    return 1;
end

function class:takeFront(event)
    self:animationSwitcher(event.unit,self.ANIMATION_STATE.FRONT);
    return 1;
end

function class:takeBack(event)
    self:animationSwitcher(event.unit,self.ANIMATION_STATE.BACK);
    return 1;
end

function class:excuteAction(event)
    return 1;
end



function class:run(event)
    if event.spineEvent == "addDevide" then
        self.isDeveide = true;
    end
    if event.spineEvent == "addBuff" then
        if self:isControll(event.unit) then
            self:addBuff(event.unit,self.buffCount);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
        end
    end
    return 1;
end


--==================================================================================================================-
--ブレイク半減

function class:devideBreak(unit,target)
    if megast.Battle:getInstance():isRaid() and self.isDeveide then
    	megast.Battle:getInstance():recAddBreakPoint(unit,target, target:getBreakPoint() - (target:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT));
        target:setBreakPoint(target:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT);
        if target:getIsBoss() then
        	RaidControl:get():addBreakPool(self.REDUCE_BREAKPOINT_CONSTANT);
        end
    end
    if megast.Battle:getInstance():isCrossBattle() and self.isDeveide then
    	megast.Battle:getInstance():recAddBreakPoint(unit,target, target:getBreakPoint() - (target:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT_CROSS));
        target:setBreakPoint(target:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT_CROSS);
    end

    if not self.isDeveide or target:getTeamUnitCondition():findConditionWithID(self.DEVIDE_BUFFID) ~= nil or not self:isControll(unit) then
        return;
    end
    
    if not megast.Battle:getInstance():isRaid() and not megast.Battle:getInstance():isCrossBattle() then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,target:getIndex());
        self:excuteDevide(unit,target:getIndex());
    end
end

function class:excuteDevide(unit,index)
    local cond = unit:getTeamUnitCondition():findConditionWithType(239)
    if cond ~= nil then
        if cond:getValue() == 0 then
            return;
        end
    end
    local target = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(index);
   	megast.Battle:getInstance():recAddBreakPoint(unit,target, target:getBreakPoint() - (target:getBreakPoint()/2));
    target:setBreakPoint(target:getBreakPoint()/2);
    target:getTeamUnitCondition():addCondition(self.DEVIDE_BUFFID,0,1,40,177);
end


--==================================================================================================================-
--魔剣解放の見た目関係

function class:addBuff(unit,buffCount)
    unit:getTeamUnitCondition():addCondition(self.SWORD_BUFFID,0,1,60,0);
    -- unit:playSummary(string.format(self.TEXT.mess1,buffCount * self.BUFF_VALUE),true);
end

function class:animationSwitcher(unit,animState)
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.SWORD_BUFFID);
    if cond == nil then
        -- unit:setSetupAnimationName("");
        return;
    end
    -- unit:setSetupAnimationName("setup-release");
    if animState == self.ANIMATION_STATE.IDLE then
        unit:setNextAnimationName("idle-release");
        unit:takeAnimationEffect(0,"2-idle-release",true);
    elseif animState == self.ANIMATION_STATE.ATTACK1 then
        unit:setNextAnimationName("attack1-release");
        unit:setNextAnimationEffectName("2-attack1-release");
    elseif animState == self.ANIMATION_STATE.SKILL1 then
        unit:setNextAnimationName("skill1-release");
        unit:setNextAnimationEffectName("2-skill1-release");
    elseif animState == self.ANIMATION_STATE.SKILL2 then
        unit:setNextAnimationName("skill2-release");
        unit:setNextAnimationEffectName("2-skill2-release");
    elseif animState == self.ANIMATION_STATE.SKILL3 then
        unit:setNextAnimationName("skill3-release");
        unit:setNextAnimationEffectName("2-skill3-release");
    elseif animState == self.ANIMATION_STATE.BACK then
        unit:setNextAnimationName("back-release");
        unit:takeAnimationEffect(0,"2-back-release",false);
    elseif animState == self.ANIMATION_STATE.DAMAGE then
        unit:setNextAnimationName("damage-release");
        unit:takeAnimationEffect(0,"2-damage-release",true);
    elseif animState == self.ANIMATION_STATE.FRONT then
        unit:setNextAnimationName("front-release");
        unit:takeAnimationEffect(0,"2-front-release",true);
    end
end

--==================================================================================================================-
--マルチ同期


function class:receive1(args)
    self:addBuff(self.gameUnit,0);
    return 1;
end

function class:receive2(args)
    self:excuteDevide(self.gameUnit,args.arg);
    return 1;
end

function class:isControll(unit)
    return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end


class:publish();

return class;
