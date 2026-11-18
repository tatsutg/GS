local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒水着リヴィエラ", version=1.3, id=103747112});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1037471121,
            BUFF_ID = 17,
            VALUE = 0,
            DURATION = 99999,
            ICON = 26,
            GROUP_ID = 1029,
            PRIORITY = 0
        },
        [2] = {
            ID = 1037471122,
            BUFF_ID = BARRIER, --バリア
            VALUE = 5000,
            DURATION = 20,
            ICON = 24,
            EFFECT = 1,
            GROUP_ID = 3690,
            PRIORITY = 100
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.skill5FLG = false
    self.gameUnit = event.unit
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---FLG管理
    if event.unit:getParameter("once") == "" then
        event.unit:setParameter("once","TRUE")
    end
    ---超奥義効果
    if self.skill5FLG then
        self.skill5FLG = false
        local count = self:teamCountHP90(event.unit)
        if count > 0 then
            self.BUFF_BOX_LIST[1].VALUE = 100 * count
            self.BUFF_BOX_LIST[1].PRIORITY = 100 * count
            local buff = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
            buff:setRemoveOnResetState(true);
        end
    end
    ---瀕死時HP回復&バフ
    if event.unit:getParameter("once") == "TRUE" and summoner.Utility.getUnitHealthRate(event.unit) < 0.4 then
        event.unit:setParameter("once","FALSE")
        self:teamHeal(event.unit)
        self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[2])
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
    end
    return 1
end

function class:receive1(args)
    if self.gameUnit:getParameter("once") == "TRUE" then
        self.gameUnit:setParameter("once","FALSE")
        self:teamHeal(self.gameUnit)
        self:teamAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
    end
    return 1;
end

function class:teamCountHP90(unit)
    local count = 0
    for i = 0,6 do
        local myTeamUnit = unit:getTeam():getTeamUnit(i)
        if myTeamUnit ~= nil then
            if summoner.Utility.getUnitHealthRate(myTeamUnit) >= 0.9 then
                count = count + 1
            end
        end
    end
    return count
end

function class:teamAddBuff(unit,buffBox)
    for i = 0,6 do
        local myTeamUnit = unit:getTeam():getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

function class:teamHeal(unit)
    for i = 0,6 do
        local myTeamUnit = unit:getTeam():getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:takeHeal(myTeamUnit:getCalcHPMAX(),unit)
        end
    end
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 5 then
        self.skill5FLG = true
    end
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil and buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupIDWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY,100,nil,buffBox.EFFECT);
    elseif buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
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

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
    return buff;
end

class:publish();

return class;