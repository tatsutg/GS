local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒_刀神ルアン", version=1.3, id=103997512});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1039971,
            BUFF_ID = 30,  --装備CT速度アップ
            VALUE = 50,
            DURATION = self.abilityTime,
            ICON = 33
        }
    }
end

function class:setSkillBuffBoxList()
    self.SKILL_BUFF_BOX_LIST = {
        [1] = {
            ID = 1039972,
            BUFF_ID = 22,   --クリティカル率
            VALUE = 100,
            DURATION = self.buffTime * self.raceTypeCount,
            ICON = 11,
            GROUP_ID = 1024,
            PRIORITY = 100
        },
        [2] = {
            ID = 1039973,
            BUFF_ID = 142,   --スーパークリティカル率
            VALUE = 50,
            DURATION = self.buffTime * self.raceTypeCount,
            ICON = 229,
            GROUP_ID = 3615,
            PRIORITY = 50
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.abilityTime = 100
    self.buffTime = 15
    self.raceTypeCount = 0
    self.skillRate = 0.07
    self.raceBox = {}  --種族カウント
    self:setBuffBoxList()
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getIsLeader() and event.unit:getLevel() >= 1 then  --固有アビ
        if BattleControl:get():getTime() < self.abilityTime then
            self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1],true)
        else
            self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1],false)
        end
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
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 2 then
        event.unit:getBurstSkill():setDamageRate(event.unit:getHP() * self.skillRate)---現在のHP*0.05ダメージ
    elseif event.index == 5 then
        self.raceTypeCount = self:enemyRaceTypeCount(event.unit)
        self:setSkillBuffBoxList()
        self:teamAddSkillBuff(event.unit,self.SKILL_BUFF_BOX_LIST[1])
        self:execAddBuff(event.unit,self.SKILL_BUFF_BOX_LIST[2])
    end
    return 1
end

function class:enemyRaceTypeCount(unit)
    for i = 0,8 do
        self.raceBox[i] = false
    end

    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(false) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end

    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self.raceBox[myTeamUnit:getRaceType()] = true
        end
    end

    local count = 0
    for i = 0,8 do
        if self.raceBox[i] then
            count = count + 1
        end
    end
    return count
end

function class:teamAddSkillBuff(unit,buffBox)
    local myTeam = unit:getTeam();
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

    return buff
end


class:publish();

return class;