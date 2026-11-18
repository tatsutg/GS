local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="超覚醒エキドナ", version=2.8, id=108447312});


function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 108447312,
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
    self.gameUnit = event.unit;
    self.abilityLevel = 1;
    self.runReraiseFLG = false;
    self.reraiseTimeFLG = false;
    self:setBuffBoxList();
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.waves == 1 and event.unit:getLevel() >= self.abilityLevel then
        event.unit:getTeamUnitCondition():addCondition(-44,0,0,99999,37);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.runReraiseFLG then
        self.runReraiseFLG = false;
        self:runReraise(event.unit);
    end
    ---復活後停止の回避策
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
    if not self.reraiseTimeFLG and cond then
        self.reraiseTimeFLG = true;
    elseif self.reraiseTimeFLG and not cond then
        self.reraiseTimeFLG = false;
        event.unit:takeAttack(1);
    end
    return 1;
end

function class:flgOff(unit)
    unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID);
    self.reraiseTimeFLG = false;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self:flgOff(event.unit);
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self:flgOff(event.unit);
    return 1;
end

---------------------------------------------------------------------------------
-- changeIn
---------------------------------------------------------------------------------
function class:changeIn(event)
    if event.unit:getLevel() >= self.abilityLevel then
        event.unit:getTeamUnitCondition():addCondition(-44,0,0,99999,37);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- changeOut
---------------------------------------------------------------------------------
function class:changeOut(event)
    return 1;
end

---------------------------------------------------------------------------------
-- avoidDead
---------------------------------------------------------------------------------
function class:avoidDead(event)
    self:beforeReraise(event.unit);
    event.unit:setIsDisableSkillEffect(true);
    return 1;
end

function class:beforeReraise(unit)
    unit:setUnitState(kUnitState_skill);
    unit:setBurstState(kBurstState_active);
    unit:setInvincibleTime(1.8);
    self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
    unit:getDeadSkill():runSkillEffectWithID(40372502,false);
    self.runReraiseFLG = true;
    return 1;
end

function class:runReraise(unit)
    unit:getDeadSkill():runSkillEffectWithID(40372501,false);
    unit:getDeadSkill():runSkillEffectWithID(40372502,false);
    unit:getDeadSkill():runSkillEffectWithID(40372503,false);
    unit:getTeamUnitCondition():removeConditionWithID(-44);
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1;
end

---------------------------------------------------------------------------------
-- ヘルパー関数
---------------------------------------------------------------------------------
--- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil;
    local count = 1;
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1;
            if count > buffBox.MAX then
                count = buffBox.MAX;
            end
        end
    end

    ---グループID関係1
    local targetCond = nil;
    if buffBox.GROUP_ID ~= nil then
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getGroupID() == buffBox.GROUP_ID and not cond:getIsPassive() then
                    targetCond = cond;
                end
            end
            ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
            if targetCond ~= nil then
                if targetCond:getPriority() <= buffBox.PRIORITY then
                    ---アビリティではない同グループID、優先度が自身以下のバフを見つけた場合
                    unit:getTeamUnitCondition():removeCondition(targetCond);
                else
                    ---アビリティではない同グループID、優先度が自身以上のバフを見つけた場合
                    return;
                end
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID);
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1); end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2); end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3); end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4); end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5); end
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    ---グループID関係2
    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff);
    end
    return buff;
end

function class:teamAddBuff(unit,buffBox)
    local targetTeam = self:getMyTaem(unit,true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
        end
    end
end

--- チーム取得
function class:getMyTaem(unit,teamFlg)
    local unitTeam = unit:getTeam();
    local targetTeam = nil;
    if teamFlg then
        --自分PTからみて味方PTを取る
        if unitTeam == megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(true);
        else
            targetTeam = megast.Battle:getInstance():getTeam(false);
        end
    else
        --自分PTからみて敵PTを取る
        if unitTeam == megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(false);
        else
            targetTeam = megast.Battle:getInstance():getTeam(true);
        end
    end
    return targetTeam;
end



class:publish();

return class;