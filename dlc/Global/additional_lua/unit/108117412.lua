local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒緋村剣心", version=2.0, id=108117412});

function class:setBuffBoxList()
    self.abilityValue = -10 * self.lightCount
    self.abilityTime = 30 * self.humanCount
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 10811701,
            BUFF_ID = 21,  --被ダメージ軽減
            VALUE = self.abilityValue,
            DURATION = self.abilityTime,
            ICON = 20,
            GROUP_ID  = 3831,
            PRIORITY = -self.abilityValue
        }
    }
end

---------------------------------------------------------------------------------
-- firstIn
---------------------------------------------------------------------------------
function class:firstIn(event)
    event.unit:setNextAnimationName("in2")
    event.unit:setNextAnimationEffectName("empty")
    return 0;
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.startFlg = false
    self.gameUnit = event.unit
    self.humanCount = 0
    self.lightCount = 0
    if event.unit:getParameter("abilityFlg") == "" then
        event.unit:setParameter("abilityFlg","true")
    else
        self.humanCount = tonumber(event.unit:getParameter("humanCount"))
        self.lightCount = tonumber(event.unit:getParameter("lightCount"))
    end

    self:setBuffBoxList()
    event.unit:setSuperArtsCutInBorder(event.unit:getElementType(),event.unit:getElementType());
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.unit:getParameter("abilityFlg") == "true" then
        event.unit:setParameter("abilityFlg","false")
        self:unitTypeCount(event.unit)
        event.unit:setParameter("humanCount",self.humanCount)
        event.unit:setParameter("lightCount",self.lightCount)
        self:setBuffBoxList()
    end
    return 1
end

function class:unitTypeCount(unit)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getRaceType() == 1 then  --人族
                self.humanCount = self.humanCount + 1
            end

            if myTeamUnit:getElementType() == 4 then  --光属性
                self.lightCount = self.lightCount + 1
            end
        end
    end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if BattleControl:get():getTime() < self.abilityTime then
        self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1],true)
    else
        self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1],false)
    end
    return 1
end

function class:teamAddBuff(unit,buffBox,flg)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
            if flg then
                if cond == nil then
                    buffBox.DURATION = self.abilityTime - BattleControl:get():getTime()
                    local buff = self:execAddBuff(myTeamUnit,buffBox)
                    if buff ~= nil then
                        buff:setCaster(unit)
                    end
                end
            else
                if cond ~= nil then
                    myTeamUnit:getTeamUnitCondition():removeConditionWithID(buffBox.ID)
                end
            end
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_bg" then
        event.unit:addOrbitSystem("bg");
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:teamRemoveBuff(event.unit,self.BUFF_BOX_LIST[1])
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,1)
    return 1
end

function class:teamRemoveBuff(unit,buffBox)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
            if cond ~= nil then
                myTeamUnit:getTeamUnitCondition():removeCondition(cond);
            end
        end
    end
end

function class:receive1(args)
    self:teamRemoveBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
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
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

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
        buff:setNumber(count);
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
    return buff
end


class:publish();

return class;