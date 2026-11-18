local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒ミラ", version=2.6, id=101046111});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = -55,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 2000,
            ICON = 107
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.isFirstStepUpdate = false
    self.PhoenixSwitch = false
    self.isPhoenix = false
    self.PhoenixTime = 0
    self.PhoenixLimitTime = 5

    self.phoenixIconID = {
        [0] = 0,
        [1] = 108,
        [2] = 109,
        [3] = 110,
        [4] = 111,
        [5] = 112,
        [6] = 107
    }

    self:setBuffBoxList()

    if event.unit:getParameter("104_StartWave") ~= "" then
        local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
        if buff == nil then
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.waves == 1 then
        local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
        if buff == nil then
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        end
    end
    event.unit:setParameter("104_StartWave",""..1)
    return 1
end

---------------------------------------------------------------------------------
-- changeIn
---------------------------------------------------------------------------------
function class:changeIn(event)
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
    event.unit:setParameter("104_StartWave",""..1)
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---バフアイコン変更処理
    self:phoenixBuffSwitch(event.unit,event.deltaTime)
    return 1
end

function class:phoenixBuffSwitch(unit,deltaTime)
    if self.PhoenixSwitch == true then
        self.PhoenixTime = self.PhoenixTime + deltaTime;
        local floorTime = math.floor(self.PhoenixTime);
        local nowID = 5 - floorTime

        ---5秒すぎた場合
        if nowID == 0 then
            self.isPhoenix = true;
            self.PhoenixSwitch = false;
            self.PhoenixTime = 0;
        end

        ---秒数でバフアイコン変更
        if self.BUFF_BOX_LIST[1].ICON ~= self.phoenixIconID[nowID] then
            self.BUFF_BOX_LIST[1].ICON = self.phoenixIconID[nowID];
            local condition = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
            if condition ~= nil then
                unit:getTeamUnitCondition():removeCondition(condition);
            end
            self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
        end
    end
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---復活から5秒間はダメージを受けない
    if self.PhoenixSwitch == true then
        return 0
    end
    return event.value
end

---------------------------------------------------------------------------------
-- avoidDead
---------------------------------------------------------------------------------
function class:avoidDead(event)
    self:takePhoenixBuff(event.unit);
    event.unit:setHP(1);
    event.unit:updateStatus();
    return 1;
end

function class:takePhoenixBuff(unit)
    if self.PhoenixSwitch == false then
        local condition = unit:getTeamUnitCondition():findConditionWithID(-55);
        if not(condition == nil) then
            unit:getTeamUnitCondition():removeCondition(condition);
        end
        self.PhoenixSwitch = true;
    end
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