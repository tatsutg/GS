local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒和装シュナ", version=2.0, id=108087412});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1080874121,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 137
        },
        [2] = {
            ID = 1080874122,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 138
        }
    }
end

function class:setSkillAddSP()
    self.skillAddSP = {
        [1] = 40,
        [2] = 45,
        [3] = 50
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.gameUnit = event.unit
    self.skill5FLG = false
    self.limit = 60
    self.timer = 60
    self:askRecast(event.unit)
    self.skill1AddSP = 0
    self:setSkillAddSP()
    return 1
end

function class:askRecast(unit)
    if unit:getParameter("Recast") ~= "" then
        self.timer = tonumber(unit:getParameter("Recast"));
    end
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    local recast = self.timer.."";
    event.unit:setParameter("Recast",recast)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,self.timer);
    return 1
end

function class:receive4(args)
    local recast = self.timer.."";
    self.gameUnit:setParameter("Recast",recast)
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self.timer = self.timer + event.deltaTime
    local flg = self:timerCheck(event.unit)
    if self.skill5FLG then
        self.skill5FLG = false
        if flg then
            self:checkRinascitaTarget(event.unit)
        end
    end
    return 1
end

function class:timerCheck(unit)
    if self.timer >= self.limit then
        local buff = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID)
        if buff == nil then
            unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[2].ID)
            self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
        end
        return true
    else
        local buff = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID)
        if buff == nil then
            unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID)
            self:execAddBuff(unit,self.BUFF_BOX_LIST[2])
        end
        return false
    end
end

---------------------------------------------------------------------------------
-- excuteAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    if self.skill1AddSP > 0 then
        event.unit:addSPWithPvpCorrection(self.skill1AddSP);
        self.skill1AddSP = 0
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        local rand = megast.Battle:getInstance():makeBattleRandom() % 10 + 1
        local result = 1
        if rand >= 5 then
            result = 2
        end
        if rand >= 8 then
            result = 3
        end
        if result >= 2 then
            event.unit:setNextAnimationEffectName("2-skill1_"..result)
        end
        self.skill1AddSP = self.skillAddSP[result]
    end
    if event.index == 5 then
        self.skill5FLG = true
    end
    return 1
end

function class:checkRinascitaTarget(unit)
    if not self:getIsControll(unit) then
        return;
    end
    for i = 0,3 do
        ---getTeamUnit(i,true)で死亡しているユニットも取れる
        local teamUnit = unit:getTeam():getTeamUnit(i,true);
        ---体力が0以下のユニットを蘇生
        if teamUnit ~= nil and teamUnit:getHP() <= 0 and teamUnit ~= unit then
            self.timer = 0
            self:excuteRinascita(unit,teamUnit:getIndex());
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,teamUnit:getIndex());
            break;
        end
    end
    megast.Battle:getInstance():updateConditionView();
end

function class:excuteRinascita(unit,index)
    local teamUnit = unit:getTeam():getTeamUnit(index,true);
    if teamUnit ~= nil then
        if not self:getIsControll(teamUnit) and not megast.Battle:getInstance():isPvp() then
            return;
        end
        ---蘇生処理
        unit:getTeam():reviveUnit(teamUnit:getIndex())
        local targetHP = teamUnit:getCalcHPMAX();
        teamUnit:setReviveHP(targetHP);
    end
end

function class:getIsControll(unit)
    return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

function class:receive1(args)
    self.timer = 0
    self:excuteRinascita(self.gameUnit,args.arg);
    megast.Battle:getInstance():updateConditionView();
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "skill1AddSP" then
        if self.skill1AddSP > 0 then
            event.unit:addSPWithPvpCorrection(self.skill1AddSP);
            self.skill1AddSP = 0
        end
    end
    if event.spineEvent == "Library_skill3_orbit" then
        local orbit = event.unit:addOrbitSystem("skill3_orbit",0)
    end
    return 1
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