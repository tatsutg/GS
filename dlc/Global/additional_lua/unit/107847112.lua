local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒ミリム戦闘形態", version=1.3, id=107847112});

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 107841,
            BUFF_ID = 0,  --真奥義カウント用
            VALUE = 0,
            DURATION = 999999,
            ICON = 9,
            COUNT = 0,
            MAX = self.breakUpCountMax
        },
        [2] = {
            ID = 107842,
            BUFF_ID = 0,  --超奥義カウント用
            VALUE = 0,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = self.powerUpCountMax
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.checkFlg = false
    self.upFlg  = false
    self.skill2Flg = false
    self.skill3Flg = false
    self.skill5Flg = false
    self.skill3PowerPoint = 300
    self.skill3BreakPoint = 4000
    self.skill5PowerPoint = 1800
    self.skill5BreakPoint = 1500
    self.breakUpCount = 0
    self.breakUpCountMax = 5
    self.powerUpCount = 0
    self.powerUpCountMax = 3

    self:setBuffBoxList()
    return 1
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.checkFlg then
        self.checkFlg = false
        self:checkFlgList(event.unit)
    end

    if self.skill2Flg then
        self.skill2Flg = false
        self.breakUpCount = 0
        self.powerUpCount = 0
        event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID)
        event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[2].ID)
    elseif self.skill3Flg and self.upFlg then
        self.upFlg  = false
        if event.unit:getActiveBattleSkill() ~= nil then
            event.unit:getActiveBattleSkill():setDamageRate(self.skill3PowerPoint)
            event.unit:getActiveBattleSkill():setBreakValue(self.skill3BreakPoint * self.breakUpCount)
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
            event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[2].ID)
            --local a = event.unit:getActiveBattleSkill():getDamageRate()
            --local b = event.unit:getActiveBattleSkill():getBreakValue()
            --summoner.Utility.messageByEnemy("Damage:"..a);
            --summoner.Utility.messageByEnemy("Break:"..b);
        end
    elseif self.skill5Flg and self.upFlg then
        self.upFlg  = false
        self.skill5Flg = false
        if event.unit:getActiveBattleSkill() ~= nil then
            event.unit:getActiveBattleSkill():setDamageRate(self.skill5PowerPoint * self.powerUpCount)
            event.unit:getActiveBattleSkill():setBreakValue(self.skill5BreakPoint)
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
            event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID)
            --local a = event.unit:getActiveBattleSkill():getDamageRate()
            --local b = event.unit:getActiveBattleSkill():getBreakValue()
            --summoner.Utility.messageByEnemy("Damage:"..a);
            --summoner.Utility.messageByEnemy("Break:"..b);
        end
    end
    return 1
end

function class:checkFlgList(unit)
    if self.skill5Flg then
        self.skill3Flg = false
        self.breakUpCount = 0
    elseif self.skill3Flg then
        self.skill5Flg = false
        self.powerUpCount = 0
    elseif self.skill2Flg then
        self.skill3Flg = false
        self.skill5Flg = false
        self.breakUpCount = 0
        self.powerUpCount = 0
    end
end


---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.skill2Flg = false
    return 1
end


---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.checkFlg = true
    if event.index == 1 then
        self.skill2Flg = false
    elseif event.index == 2 then
        self.skill2Flg = true
    elseif event.index == 3 then
        self.upFlg = true
        self.skill2Flg = false
        self.skill3Flg = true
        self.breakUpCount = self.breakUpCount + 1
    elseif event.index == 5 then
        self.upFlg = true
        self.skill2Flg = false
        self.skill5Flg = true
        self.powerUpCount = self.powerUpCount + 1
    end

    if self.breakUpCount >= self.breakUpCountMax then
        self.breakUpCount = self.breakUpCountMax
    elseif self.powerUpCount >= self.powerUpCountMax then
        self.powerUpCount = self.powerUpCountMax
    end
    return 1
end


---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self.breakUpCount = 0
    self.powerUpCount = 0
    event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID)
    event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[2].ID)
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

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
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