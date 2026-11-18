local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ネリム", version=2.6, id=101416312});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.abilityLevel = 1
    self.highAbilityLevel = 90
    self.runReraiseFLG = false
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.waves == 1 then
        event.unit:getTeamUnitCondition():addCondition(-44,0,0,99999,37);
        megast.Battle:getInstance():updateConditionView()
    end
    return 1;
end

---------------------------------------------------------------------------------
-- changeIn
---------------------------------------------------------------------------------
function class:changeIn(event)
    event.unit:getTeamUnitCondition():addCondition(-44,0,0,99999,37);
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.runReraiseFLG and event.unit:getHP() == 0 then
        event.unit:setHP(1)
    end
    return 1
end

---------------------------------------------------------------------------------
-- avoidDead
---------------------------------------------------------------------------------
function class:avoidDead(event)
    self:beforeReraise(event.unit)
    event.unit:setIsDisableSkillEffect(true)
    return 0
end

function class:beforeReraise(unit)
    unit:takeAnimation(0,"reraise",false);
    unit:takeAnimationEffect(0,"1_reraise",false);
    unit:setUnitState(kUnitState_skill);
    unit:setBurstState(kBurstState_active);
    unit:setInvincibleTime(1.8);
    unit:getTeamUnitCondition():addCondition(10384,0,0,1.8,0);
    unit:setHP(1);
    self.runReraiseFLG = true
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.runReraiseFLG then
        return 0;
    end
    return 1
end

function class:runReraise(unit)
    unit:getTeamUnitCondition():removeConditionWithID(-44);
    unit:getDeadSkill():runSkillEffect(0);
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    --summoner.Utility.messageByEnemy(event.spineEvent)
    if event.spineEvent == "RunReraise" then
        if self.runReraiseFLG then
            self.runReraiseFLG = false
            self:runReraise(event.unit)
        end
    end
    return 1
end

----// takeAttack //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if self.runReraiseFLG then
        self.runReraiseFLG = false
        self:runReraise(event.unit)
    end
    return 1
end
----// takeSkill //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if self.runReraiseFLG then
        self.runReraiseFLG = false
        self:runReraise(event.unit)
    end
    return 1
end
----// takeIdle //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.runReraiseFLG then
        self.runReraiseFLG = false
        self:runReraise(event.unit)
    end
    return 1;
end
----// takeBack //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeBack(event)
    if self.runReraiseFLG then
        self.runReraiseFLG = false
        self:runReraise(event.unit)
    end
    return 1;
end
----// takeFront //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeFront(event)
    if self.runReraiseFLG then
        self.runReraiseFLG = false
        self:runReraise(event.unit)
    end
    return 1;
end
----// takeCast //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:castItem(event)
    if self.runReraiseFLG then
        self.runReraiseFLG = false
        self:runReraise(event.unit)
    end
    return 1;
end
----// takeDamage //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeDamage(event)
    if self.runReraiseFLG then
        self.runReraiseFLG = false
        self:runReraise(event.unit)
    end
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil and buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupIDWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY,buffBox.WEIGHT);
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
    return buff
end

class:publish();

return class;

