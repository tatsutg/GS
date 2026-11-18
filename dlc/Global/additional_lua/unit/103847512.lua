local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒_虚構魔術士ハルト", version=1.3, id=103847512});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 103847512,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 1.8,
            ICON = 0
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self:setBuffBoxList()
    self.abilityLevel = 90
    if event.unit:getParameter("isRinascita") ~= "TRUE" and event.unit:getLevel() >= self.abilityLevel then
        event.unit:getTeamUnitCondition():addCondition(-44,0,0,99999,37);
    end
    self.runReraiseFLG = false
    self.skill5FLG = false
    self.reraiseTimeFLG = false
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    megast.Battle:getInstance():updateConditionView()
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.runReraiseFLG then
        self.runReraiseFLG = false
        self:runReraise(event.unit)
    end
    if self.skill5FLG then
        self.skill5FLG = false;
        local hp = event.unit:getHP() - 1
        local hpMax = event.unit:getCalcHPMAX() - 1
        local rate = (hpMax - hp) / hpMax
        event.unit:addSPWithPvpCorrection(150 * rate);
    end
    ---復活後停止の回避策
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
    if not self.reraiseTimeFLG and cond then
        self.reraiseTimeFLG = true
    elseif self.reraiseTimeFLG and not cond then
        self.reraiseTimeFLG = false
        event.unit:takeAttack(1);
    end
    return 1
end

function class:flgOff(unit)
    unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID)
    self.reraiseTimeFLG = false
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if event.unit:getParameter("isRinascita") ~= "TRUE" and event.unit:getLevel() >= self.abilityLevel then
        if self:getIsControll(event.unit) then
            self:beforeReraise(event.unit)
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
        end
        return 0
    end
    return 1
end

function class:beforeReraise(unit)
    unit:setUnitState(kUnitState_skill);
    unit:setBurstState(kBurstState_active);
    unit:setInvincibleTime(1.8);
    self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
    local targetHP = unit:getCalcHPMAX()*0.3 >= 1 and unit:getCalcHPMAX()*0.3 or 1;
    unit:setHP(targetHP);
    self.runReraiseFLG = true
    return 1
end

function class:runReraise(unit)
    for i = 0,7 do
        local teamUnit = unit:getTeam():getTeamUnit(i,true);
        if teamUnit ~= nil then
            if teamUnit:getHP() <= 0 then
                if teamUnit ~= unit then
                    ---何のためにあるのかよくわからないけど必要っぽいので
                    if teamUnit:getParent() then
                        teamUnit:removeFromParent();
                    end
                    unit:getTeam():reviveUnit(teamUnit:getIndex());
                    local targetHP = teamUnit:getCalcHPMAX()*0.3 >= 1 and teamUnit:getCalcHPMAX()*0.3 or 1;
                    teamUnit:setHP(targetHP);
                end
            end
            ---奥義ゲージUP
            teamUnit:addSPWithPvpCorrection(200);
        end
    end
    unit:getTeamUnitCondition():removeConditionWithID(-44);
    unit:setParameter("isRinascita","TRUE");
    return 1
end

function class:getIsControll(unit)
    return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

function class:receive1(args)
    self:beforeReraise(self.gameUnit)
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_wood" then
        local orbit = event.unit:addOrbitSystem("wood",0)
        orbit:setDamageRateOffset(0.4)
        orbit:setBreakRate(0.4)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self:flgOff(event.unit)
    event.unit:setDamageRateOffset(1);
    event.unit:setBreakRate(1);
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self:flgOff(event.unit)
    event.unit:setDamageRateOffset(1);
    event.unit:setBreakRate(1);
    if event.index == 5 then
        event.unit:setDamageRateOffset(0.6);
        event.unit:setBreakRate(0.6);
        self.skill5FLG = true
    end
    return 1
end

function class:teamAddBuff(unit,buffBox)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
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