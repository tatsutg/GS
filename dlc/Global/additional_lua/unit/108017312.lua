local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒水着ルヴィア＆凛", version=1.3, id=108017312});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 10801701,
            BUFF_ID = 21,  --被ダメージ軽減
            VALUE = -30,
            DURATION = 15,
            ICON = 20
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.gameUnit = event.unit
    self.abilityBurstPoint = 200
    if event.unit:getParameter("abilityFlg") == "" then
        event.unit:setParameter("abilityFlg","true")
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---瀕死時 奥義回復&バフ
    if event.unit:getParameter("abilityFlg") == "true" and summoner.Utility.getUnitHealthRate(event.unit) < 0.4 then
        event.unit:setParameter("abilityFlg","false")
        self:teamBurstHeal(event.unit)
        self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0)
    end
    return 1
end

function class:teamBurstHeal(unit)
    for i = 0,6 do
        local myTeamUnit = unit:getTeam():getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:addSPWithPvpCorrection(self.abilityBurstPoint)
        end
    end
end

function class:teamAddBuff(unit,buffBox)
    for i = 0,6 do
        local myTeamUnit = unit:getTeam():getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

function class:receive1(args)
    if self.gameUnit:getParameter("abilityFlg") == "true" then
        self.gameUnit:setParameter("abilityFlg","false")
        self:teamBurstHeal(self.gameUnit)
        self:teamAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_shot" then
        local orbit = event.unit:addOrbitSystemInsightRotation("shot_1","hit",1,-50,70,0,0)
        orbit:setDamageRateOffset(event.unit:getAttackDelay());
    end

    if event.spineEvent == "Library_shot_1" then
        local orbit1 = event.unit:addOrbitSystemInsightRotation("shot_1","hit",1,-50,70,0,0)
        orbit1:setDamageRateOffset(0.5)
        orbit1:setBreakRate(0.5)
    end

    if event.spineEvent == "Library_shot_2" then
        local orbit2 = event.unit:addOrbitSystemInsightRotation("shot_2","hit",1,-50,50,0,0)
        orbit2:setDamageRateOffset(0.5)
        orbit2:setBreakRate(0.5)
    end

    if event.spineEvent == "Library_skill3_rin" then
        event.unit:addOrbitSystem("skill3_rin",0)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
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


class:publish();

return class;