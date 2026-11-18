local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒千冬", version=1.3, id=107646312});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 10764,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 137
        },
        [2] = {
            ID = 10764,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 138
        },
        [3] = {
            ID = 107643,
            BUFF_ID = 13,
            VALUE = 30,
            DURATION = 10,
            ICON = 3,
            GROUP_ID = 1042,
            PRIORITY = 30,
            EXCEPTION = 107644, --例外的にこのIDのバフとは重複関係を持たない
            EXCEPTION2 = 107645
        },
        [4] = {
            ID = 107644,
            BUFF_ID = 15,
            VALUE = 30,
            DURATION = 10,
            ICON = 5,
            GROUP_ID = 1042,
            PRIORITY = 30,
            EXCEPTION = 107643, --例外的にこのIDのバフとは重複関係を持たない
            EXCEPTION2 = 107645
        },
        [5] = {
            ID = 107645,
            BUFF_ID = 2,
            VALUE = 30,
            DURATION = 10,
            ICON = 1,
            GROUP_ID = 1042,
            PRIORITY = 30,
            EXCEPTION = 107643, --例外的にこのIDのバフとは重複関係を持たない
            EXCEPTION2 = 107644
        },
        [6] = {
            ID = 107646,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 10,
            ICON = 0
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    ---自動蘇生、コンティニュー分岐用フラグ
    self.deadFLG = -1
    self:setBuffBoxList()
    self.skill2FLG = false
    if event.unit:getParameter("Recast") == "" then
        self.timer = 50
        local recast = self.timer.."";
        event.unit:setParameter("Recast",recast)
    end
    self.limit = 50
    self.RIVIVE_RATIO = 1
    self:askRecast(event.unit)
    self:teamTableSet(event.unit)
    return 1
end

function class:askRecast(unit)
    if unit:getParameter("Recast") ~= "" then
        self.timer = tonumber(unit:getParameter("Recast"));
    end
end

function class:receive2(args)
    self.timer = args.arg
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:teamTableSet(event.unit)
    return 1
end

function class:teamTableSet(unit)
    self.teamTable = {}
    local myTeam = unit:getTeam()
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self.teamTable[i] = true
        else
            self.teamTable[i] = false
        end
    end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self.timer = self.timer + event.deltaTime
    self:iconCheck(event.unit)
    self:skill2Check(event.unit)
    if self.deadFLG ~= -1 then
        ---自動蘇生時処理
        self.deadFLG = -1
    end
    if self.skill2FLG then
        self.skill2FLG = false
        if self.timer >= self.limit then
            self:checkRinascitaTarget(event.unit)
        end
        self:teamAddBuff3(event.unit,10)
        ---この時点で死亡しているユニットを確認
        self:teamTableSet(event.unit)
    end
    return 1
end

function class:teamAddBuff3(unit,time)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff3(myTeamUnit,time)
        end
    end
end

function class:execAddBuff3(unit,time)
    self:durationChange(time)
    self:execAddBuff(unit,self.BUFF_BOX_LIST[3])
    self:execAddBuff(unit,self.BUFF_BOX_LIST[4])
    self:execAddBuff(unit,self.BUFF_BOX_LIST[5])
    self:execAddBuff(unit,self.BUFF_BOX_LIST[6])
    self:durationChange(10)
    return 1
end

function class:durationChange(time)
    self.BUFF_BOX_LIST[3].DURATION = time
    self.BUFF_BOX_LIST[4].DURATION = time
    self.BUFF_BOX_LIST[5].DURATION = time
    self.BUFF_BOX_LIST[6].DURATION = time
    return 1
end

function class:skill2Check(unit)
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[6].ID);
    if cond ~= nil then
        local myTeam = unit:getTeam()
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil and self.teamTable[i] == false then
                if myTeamUnit ~= unit then
                    local cond2 = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[6].ID)
                    if cond2 == nil then
                        self:execAddBuff3(myTeamUnit,cond:getTime())
                        self.teamTable[i] = true
                    end
                end
            end
        end
    end
end

function class:iconCheck(unit)
    if self.timer < 50 then
        self:execAddBuff(unit,self.BUFF_BOX_LIST[2])
    elseif self.timer >= 50 then
        self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
    end
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
        local targetHP = teamUnit:getCalcHPMAX() * self.RIVIVE_RATIO >= 1 and teamUnit:getCalcHPMAX() * self.RIVIVE_RATIO or 1;
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
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    return 1
end


---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.skill2FLG = false
    if event.index == 2 then
        self.skill2FLG = true
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self.deadFLG = 0
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


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;

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
        newCond:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then newCond:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then newCond:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then newCond:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then newCond:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then newCond:setValue5(buffBox.SCRIPT.VALUE5) end
    end
end

class:publish();

return class;