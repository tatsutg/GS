local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒_ハロウィンヴァレリー", version=1.3, id=103787212});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 10378701,  --固有アビリティ
            BUFF_ID = 21,  --被ダメ軽減
            VALUE = self.buffValue,
            DURATION = 0.5,
            ICON = 0
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.buffValue = 0
    self.buffRate = -0.3
    self.skill5Count = 0
    self:getUnitHPCalc(event.unit)
    self:setBuffBoxList()
    if event.unit:getParameter("firstSkillFlg") == "" then
        event.unit:setParameter("firstSkillFlg","TRUE");
        event.unit:setParameter("skillCount","0");
    end
    return 1
end

function class:getUnitHPCalc(unit)
    local unitHP = unit:getHPPercent() * 100
    self.buffValue = unitHP * self.buffRate
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:getUnitHPCalc(event.unit)
    self:setBuffBoxList()
    local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID)
    if buff ~= nil then
        local nowBuffVal = buff:getValue()
        if nowBuffVal >= self.buffValue then
            event.unit:getTeamUnitCondition():removeCondition(buff)
            self.BUFF_BOX_LIST[1].VALUE = self.buffValue
            self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        end
    else
        self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1])
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill5_orbit" then
        local orbit = event.unit:addOrbitSystem("skill5_orbit",0)
        orbit:setDamageRateOffset(0.6)
        orbit:setBreakRate(0.6)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)

    if event.index == 5 then
        event.unit:setDamageRateOffset(0.4)
        event.unit:setBreakRate(0.4)
        if event.unit:getParameter("firstSkillFlg") == "TRUE" then
            local flg = false
            local param = event.unit:getParameter("skillCount")
            if param == "0" then
                flg = true
                event.unit:setParameter("skillCount","1")
            elseif param == "1" then
                flg = true
                event.unit:setParameter("skillCount","2")
            else
                event.unit:setParameter("firstSkillFlg","FALSE");
            end

            if flg then
                self:weaponCoolTimeReset(event.unit)
            end
        end
    end
    return 1
end

function class:weaponCoolTimeReset(unit)
    local battleSkill = nil
    for i = 0,2 do
        battleSkill = unit:getItemSkill(i)
        if battleSkill ~= nil then
            if battleSkill:getBattleItem():getItemTypeAsInt() == 2 then
                if not megast.Battle:getInstance():isPvp() then
                    battleSkill:setCoolTimer(0)
                else
                    battleSkill:setCoolTimer(battleSkill:getCoolTimer() / 2)
                end
            end
        end
    end
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
    ---グループID関係1
    local targetCond = nil
    if buffBox.GROUP_ID ~= nil then
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getGroupID() == buffBox.GROUP_ID and not cond:getIsPassive() then
                    targetCond = cond
                end
            end
            ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
            if targetCond ~= nil then
                if targetCond:getPriority() <= buffBox.PRIORITY then
                    ---アビリティではない同グループID、優先度が自身以下のバフを見つけた場合
                    unit:getTeamUnitCondition():removeCondition(targetCond)
                else
                    ---アビリティではない同グループID、優先度が自身以上のバフを見つけた場合
                    return
                end
            end
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

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    ---グループID関係2
    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
end

function class:teamAddBuff(unit,buffBox)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end



class:publish();

return class;