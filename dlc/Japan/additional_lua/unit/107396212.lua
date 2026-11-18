local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="サンタリムル", version=1.3, id=107396212});

class.RIVIVE_RATIO = 0.5
class.RINASCITA_BUFF = {
    ID = 1073962124,
    BUFF_ID = 0, -- 自然蘇生
    VALUE = 0,
    DURATION = 999999,
    ICON = 37
}

--------[[バフ]]--------
function class:setBuffBoxList(i)
    self.ANIMATIONS = {
        [1] = {
            [1] = {
                ANIMATION = "skill1",
                EF = "2-skill1",
                ID = 1073952121,
                BUFF = function(unit) unit:getTeamUnitCondition():addCondition(
                        1073962121,
                        10,
                        3,
                        5 + i,
                        36
                ) end
            },
            [2] = {
                ANIMATION = "skill1_2",
                EF = "skill1_2",
                ID = 1073952122,
                BUFF = function(unit) unit:getTeamUnitCondition():addCondition(
                        1073962122,
                        13,
                        30,
                        5 + i,
                        3
                ) end
            },
            [3] = {
                ANIMATION = "skill1_3",
                EF = "skill1_3",
                ID = 1073952123,
                BUFF = function(unit) unit:getTeamUnitCondition():addCondition(
                        1073962123,
                        7,
                        math.floor(unit:getCalcHPMAX() * 0.03),
                        5 + i,
                        self.gameUnit,
                        35
                ) end
            }
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.skillFlag = false
    self.skillCheckFLG = false
    self.surfaceIndex = 1
    self:setBuffBoxList(2)
    ---自動蘇生関係
    if event.unit:getFantasyEvolutionType() == 4 then
        self:setRinascita(event.unit)
    end
    return 1
end

function class:startWave(event)
    megast.Battle:getInstance():updateConditionView()
    return 1
end

----// takeSkill //-----------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        event.unit:setNextAnimationName(self.ANIMATIONS[event.index][self.surfaceIndex].ANIMATION)
        event.unit:setNextAnimationEffectName(self.ANIMATIONS[event.index][self.surfaceIndex].EF)
        self:execAddBuffSpecial(event.unit,self.ANIMATIONS[event.index][self.surfaceIndex])
        self:moveSkill()
    end
    return 1
end


-----------------------------
function class:moveSkill()
    if self.surfaceIndex < 3 then
        self.surfaceIndex = self.surfaceIndex + 1
    else
        self.surfaceIndex = 1
    end
end

-----------------------------
function class:execAddBuffSpecial(unit,box)
    for i = 0,6 do
        local teamUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i);
        if teamUnit ~= nil then
            local b = teamUnit:getTeamUnitCondition():findConditionWithID(box.ID)
            if b ~= nil then
                teamUnit:getTeamUnitCondition():removeCondition(b);
            end
            box.BUFF(teamUnit)
        end
    end
end

---- 騎士道自然蘇生関係 ----
function class:setRinascita(unit)
    local param = unit:getParameter("isRinascita")
    if param == "" or param == "FALSE" then
        unit:setParameter("isRinascita","FALSE")
        self:execAddBuff(unit,self.RINASCITA_BUFF)
    end
end

function class:excuteAction(event)
    return self:checkRinascita(event.unit)
end

function class:checkRinascita(unit)
    if unit:getParameter("isRinascita") == "FALSE" then
        for i = 0,3 do
            local teamUnit = unit:getTeam():getTeamUnit(i,true);
            if teamUnit ~= nil and teamUnit:getHP() <= 0 and teamUnit ~= unit then
                unit:takeAnimation(0,"cast",false);
                self:checkRinascitaTarget(unit);
                unit:setUnitState(kUnitState_skill);
                unit:setBurstState(kBurstState_active);
                return 0;
            end
        end
    end
    return 1;
end

function class:checkRinascitaTarget(unit)
    if not self:getIsControll(unit) then
        return;
    end
    if unit:getParameter("isRinascita") == "FALSE" then
        for i = 0,3 do
            local teamUnit = unit:getTeam():getTeamUnit(i,true);
            if teamUnit ~= nil and teamUnit:getHP() <= 0 and teamUnit ~= unit then
                self:excuteRinascita(unit,teamUnit:getIndex());
                megast.Battle:getInstance():sendEventToLua(self.scriptID,2,teamUnit:getIndex());
                return;
            end
        end
    end
end

function class:excuteRinascita(unit,index)
    local teamUnit = unit:getTeam():getTeamUnit(index,true);
    if teamUnit == nil then return end

    unit:setParameter("isRinascita","TRUE")
    self:removeCondition(unit,self.RINASCITA_BUFF.ID)
    if not self:getIsControll(teamUnit) and not megast.Battle:getInstance():isPvp() then
        return;
    end
    unit:getTeam():reviveUnit(teamUnit:getIndex())
    local targetHP = teamUnit:getCalcHPMAX() * self.RIVIVE_RATIO >= 1 and teamUnit:getCalcHPMAX() * self.RIVIVE_RATIO or 1;
    teamUnit:setReviveHP(targetHP);
end

function class:getIsControll(unit)
    return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

-- バフ削除
function class:removeCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
        unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
    end
end

function class:receive2(args)
    self:excuteRinascita(self.gameUnit,args.arg);
    return 1;
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

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

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end
end

class:publish();

return class;