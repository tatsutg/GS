local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ミゼット", version=2.3, id=104037412});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 104037412,
            BUFF_ID = 98, -- バリア
            VALUE = 30000,
            DURATION = 100,
            ICON = 24,
            EFFECT = 1,
            GROUP_ID = 3828,
            PRIORITY = 30000
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.skill5orbit = nil
    self.skill5FLG = false
    self:setBuffBoxList()
    self:changeDamageText(false,event.unit)
    if megast.Battle:getInstance():isPvp() then
        self.BUFF_BOX_LIST[1].VALUE = 3000 / megast.Battle:getInstance():getPvpCorrectionValue(self.BUFF_BOX_LIST[1].BUFF_ID,1);
        self.BUFF_BOX_LIST[1].DURATION = 75 / megast.Battle:getInstance():getPvpCorrectionValue(self.BUFF_BOX_LIST[1].BUFF_ID,1);
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 5 then
        self.skill5FLG = true
        self:changeDamageText(true,event.unit)
    end
    return 1
end

function class:changeDamageText(isCamera,unit)
    if isCamera then
        megast.Battle:getInstance():changeDamageTextLayerToCameraWithUnit(unit)
    else
        megast.Battle:getInstance():changeDamageTextLayerToBattleFieldWithUnit(unit)
    end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getParameter("barrierUsed") == "" then
        event.unit:setParameter("barrierUsed","TRUE");
        self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1])
    end
    if self.skill5FLG then
        if event.unit:getUnitState() ~= kUnitState_skill then
            self.skill5FLG = false
            self:changeDamageText(false,event.unit)
            if self.skill5orbit then
                self.skill5orbit:takeAnimation(0,"empty",false);
                self.skill5orbit = nil
            end
            BattleControl:get():restoreBackgroundLWF(event.unit,false,0,0.1,0.3);
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "BGChange" then
        BattleControl:get():changeBackgroundLWF(2047100,event.unit,0,0.1,0.3);
    end
    if event.spineEvent == "BGChangeEnd" then
        self.skill5orbit = nil
        BattleControl:get():restoreBackgroundLWF(event.unit,false,0,0.1,0.3);
    end
    if event.spineEvent == "Library_skill5" then
        self.skill5orbit = event.unit:addOrbitSystemCamera("skill5");
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:changeDamageText(false,event.unit)
    BattleControl:get():restoreBackgroundLWF(event.unit,false,0,0.1,0.3);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self:changeDamageText(false,self.gameUnit)
    BattleControl:get():restoreBackgroundLWF(self.gameUnit,false,0,0.1,0.3);
    return 1
end

---------------------------------------------------------------------------------
-- changeOut
---------------------------------------------------------------------------------
function class:changeOut(event)
    self:changeDamageText(false,event.unit)
    BattleControl:get():restoreBackgroundLWF(event.unit,false,0,0.1,0.3);
    return 1
end

function class:teamAddBuff(unit,buffBox)
    local myTeam = unit:getTeam()
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
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
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

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end
end

class:publish();

return class;