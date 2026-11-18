local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒エレノア", version=1.3, id=103887312});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 29,---スキルCT
            VALUE = 15 * self.clockTime,
            DURATION = 30,
            ICON = 34,
            MAX = 12,
            GROUP_ID = 1022,
            PRIORITY = 15 * self.clockTime
        },
        [2] = {
            ID = 0,
            BUFF_ID = 30,---装備CT
            VALUE = 5 * self.clockTime,
            DURATION = 30,
            ICON = 33,
            MAX = 12,
            GROUP_ID = 1025,
            PRIORITY = 5 * self.clockTime
        },
        [3] = {
            ID = 1038873123,
            BUFF_ID = 21,---被ダメージ軽減
            VALUE = -30,
            DURATION = 15,
            ICON = 20,
            GROUP_ID = 6,
            PRIORITY = 20
        },
        [4] = {
            ID = 1038873124,
            BUFF_ID = 10,---奥義ゲージ
            VALUE = 0,
            DURATION = 99999,
            ICON = 0,
            GROUP_ID = 3748,
            PRIORITY = 2
        }
    }
end

---------------------------------------------------------------------------------
-- start
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function class:start(event)
    self.clockTime = 0
    self:setBuffBoxList()
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[4])
    self.firstUpdate = true
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    return 1
end

function class:findWeapon(unit,weaponId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
    return buff ~= nil
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.firstUpdate then
        self.firstUpdate = false
        if self:findWeapon(event.unit,50288100) then
            self.clockTime = 3
        end
    end
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[4].ID);
    if cond ~= nil then
        local pvpCorrectionValue = megast.Battle:getInstance():getPvpCorrectionValue(cond:getConditionTypeAsInt(),1);
        local fixValue = 2 * self:teamCountElement(event.unit,3) * pvpCorrectionValue
        if cond:getValue() ~= fixValue then
            cond:setValue(fixValue)
        end
    end
    return 1
end

function class:teamCountElement(unit,element)
    local myTeam = unit:getTeam()
    local getElementCount = 0
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getElementType() == element then
                getElementCount = getElementCount + 1
            end
        end
    end
    return getElementCount;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_smallclock" then
        local sClock = event.unit:addOrbitSystemCamera("smallclock",0)
        if not event.unit:getisPlayer() then
            sClock:getSkeleton():setScaleX(-1);
        end
    end
    if event.spineEvent == "Library_clock" then
        local hour = string.format( "%02d", self.clockTime )---0埋め
        local clock = event.unit:addOrbitSystemCamera("clock"..hour,0)
        if not event.unit:getisPlayer() then
            clock:getSkeleton():setScaleX(-1);
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 5 then
        ---時計を進める
        if self.clockTime < 12 then
            self.clockTime = self.clockTime + 1
            self:setBuffBoxList()
        end
        ---バフ付与
        self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[2])
        self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[3])
    end
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(self.clockTime);
        megast.Battle:getInstance():updateConditionView();
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

function class:teamAddBuff(unit,buffBox)
    local myTeam = unit:getTeam()
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

class:publish();

return class;