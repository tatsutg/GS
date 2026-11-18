local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒アルファ", version=1.3, id=108047412});

function class:setBuffBoxList(unit)
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1080474120 + unit:getIndex(),
            BUFF_ID = 17, ---物理ダメージ
            VALUE = 0,
            DURATION = 30,
            ICON = 28,
            SCRIPT = {
                SCRIPT_ID = 4
            },
            COUNT = 1,
            MAX = 4,
            GROUP_ID = 1066,
            PRIORITY = 0

        },
        [2] = {
            ID = 1080474129,
            BUFF_ID = 21,  --被ダメージ軽減
            VALUE = -50,
            DURATION = 10,
            ICON = 20
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList(event.unit)
    self.skill5FLG = false;
    self.gameUnit = event.unit
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.skill5FLG then
        self.skill5FLG = false
        ---カウント関係
        local count = tonumber(event.unit:getParameter("804_Chain"));
        count = count < self.BUFF_BOX_LIST[1].MAX and count + 1 or self.BUFF_BOX_LIST[1].MAX
        event.unit:setParameter("804_Chain",""..count)
        self.BUFF_BOX_LIST[1].VALUE = 100 * count
        self.BUFF_BOX_LIST[1].PRIORITY = 100 * count
        self.BUFF_BOX_LIST[1].COUNT = count
        self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1])
    end
    ---カウント初期化,他のindexのユニットに上書きされた場合も
    local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
    if buff == nil then
        event.unit:setParameter("804_Chain",""..0)
    end

    ---FLG管理
    if event.unit:getParameter("once") == "" then
        event.unit:setParameter("once","TRUE")
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

function class:teamHeal(unit)
    for i = 0,6 do
        local myTeamUnit = unit:getTeam():getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:takeHeal(myTeamUnit:getCalcHPMAX(),unit)
        end
    end
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
    if event.index == 5 then
        self.skill5FLG = true
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self.deadFLG = 0
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

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end
    if buffBox.COUNT ~= nil then
        buff:setNumber(buffBox.COUNT);
        buff:setMaxConditionIconNumber(buffBox.MAX);
    end
    megast.Battle:getInstance():updateConditionView();
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