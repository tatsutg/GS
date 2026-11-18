local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ナターシャ：スピリチア05", version=1.3, id=104057512});

function class:setBuffBoxList(unit)
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1040510 + unit:getIndex(),
            BUFF_ID = 21,---被ダメージダウン
            VALUE = self.skill2Value,
            DURATION = self.skill2Time,
            ICON = 20,
            GROUP_ID = 6,
            PRIORITY = math.abs(self.skill2Value),
            MAX = 3
        },
        [2] = {
            ID = 1040520 + unit:getIndex(),
            BUFF_ID = 13,---攻撃力
            VALUE = 100,
            DURATION = 20,
            ICON = 3,
            GROUP_ID = 1006,
            PRIORITY = 100,
            MAX = 3
        },
        [3] = {
            ID = 1040530 + unit:getIndex(),
            BUFF_ID = 21,---物理耐性ダウン
            VALUE = 100,
            DURATION = 20,
            ICON = 185,
            GROUP_ID = 2067,
            PRIORITY = 100,
            SCRIPT = {
                SCRIPT_ID = 2
            },
            MAX = 3
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.skill2Value = -20
    self.skill2Time = 20
    self:setBuffBoxList(event.unit)
    self.skill2FLG = false
    self.skill5FLG = false
    self.skill5FLG_HIT = false
    self.skill5AddConditionList = {}
    return 1
end

function class:startWave(event)
    if self:findWeapon(event.unit,50314100) then
        self.BUFF_BOX_LIST[1].DURATION = self.BUFF_BOX_LIST[1].DURATION + 5
        self.BUFF_BOX_LIST[2].DURATION = self.BUFF_BOX_LIST[2].DURATION + 5
        self.BUFF_BOX_LIST[3].DURATION = self.BUFF_BOX_LIST[3].DURATION + 5
    end
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
    if self.skill2FLG then
        self.skill2FLG = false
        self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1])
    end
    if self.skill5FLG then
        self.skill5FLG = false
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
    end
    return 1
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
    if event.index == 2 then
        self.skill2FLG = true
    end
    if event.index == 3 then
        self.skill2FLG = false
    end
    if event.index == 5 then
        self.skill5FLG = true
        self.skill5FLG_HIT = true
    end
    return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.skill5FLG_HIT then
        if self.skill5AddConditionList[event.enemy:getIndex()] == nil then
            self.skill5AddConditionList[event.enemy:getIndex()] = true
            self:execAddBuff(event.enemy,self.BUFF_BOX_LIST[3])
        end
    end
    return event.value
end

---------------------------------------------------------------------------------
-- executeAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    self.skill5FLG_HIT = false
    self.skill5AddConditionList = {}
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > buffBox.MAX then
                count = buffBox.MAX
            end
        end
    end
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE*count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE*count,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY*count);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE*count,buffBox.DURATION,buffBox.ICON);
    end
    if buff ~= nil then
        if buffBox.SCRIPT ~= nil then
            buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
            if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
            if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
            if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
            if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
            if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
        end

        if buffBox.MAX ~= nil then
            buff:setMaxConditionIconNumber(buffBox.MAX);
            buff:setNumber(count)
            megast.Battle:getInstance():updateConditionView()
        end
    end
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