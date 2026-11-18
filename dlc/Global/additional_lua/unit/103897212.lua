local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ヴァレリー", version=1.3, id=103897212});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1038972121,
            BUFF_ID = 17,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.abilityValue = 60
    self.saveCount = 0
    self:setBuffBoxList()
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---アビリティ
    local count = self:teamHpCheck(event.unit)
    if self.saveCount ~= count then
        local buff = event.unit:getTeamUnitCondition():findConditionWithID(1038972121)
        if buff ~= nil then
            buff:setValue(self.abilityValue * count)
        end
        self.saveCount = count
    end
    ---超奥義
    if self.skill5FLG then
        ---初回だけ動く
        if event.unit:getParameter("389_SuperArtsDamage") == "" then
            event.unit:setParameter("389_SuperArtsDamage",event.unit:getActiveBattleSkill():getDamageRate())
        end
        local addDamage = event.unit:getCalcAttack() / 10
        event.unit:getActiveBattleSkill():setDamageRate(tonumber(event.unit:getParameter("389_SuperArtsDamage")) + addDamage)
        --summoner.Utility.messageByEnemy(addDamage)
        --summoner.Utility.messageByEnemy(tonumber(event.unit:getParameter("389_SuperArtsDamage")))
        self.skill5FLG = false
    end
    return 1
end

function class:teamHpCheck(unit)
    local targetTeam = unit:getTeam()
    local count = 0
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local rate = myTeamUnit:getHP() / myTeamUnit:getCalcHPMAX()
            if rate >= 0.7 then
                count = count + 1
            end
        end
    end
    return count
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
    return buff
end

class:publish();

return class;