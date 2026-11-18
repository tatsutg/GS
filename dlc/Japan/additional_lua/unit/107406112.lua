local class = summoner.Bootstrap.createUnitClass({label="サンタミリム", version=1.3, id=107406112});

--------[[バフ]]--------
function class:setBuffBoxList(unit)
    local buffValue = 15
    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
    if unit:getLevel() >= 90 and hpRate >= 50 then
        buffValue = buffValue * 2
    end
    --- 炎属性耐性はデータ側で対応するよう修正
    self.SPECIAL2_BUFF = {
        ID = -1,
        BUFF_ID = 61, -- 炎属性耐性
        VALUE = -40,
        DURATION = buffValue,
        ICON = 43,
        --GROUP_ID = 2010,
        --PRIORITY = 40
    }
    self.SPECIAL3_BUFF = {
        ID = 1074061122,
        BUFF_ID = 22, -- クリティカル
        VALUE = 100,
        DURATION = buffValue,
        ICON = 11,
        GROUP_ID = 1024,
        PRIORITY = 100
    }
    self.SPECIAL3_BUFF2 = {
        ID = 1074061123,
        BUFF_ID = 10, -- 奥義ゲージ
        VALUE = 5,
        DURATION = buffValue,
        ICON = 36,
        GROUP_ID = 3550,
        PRIORITY = buffValue * 5
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)

    self:setBuffBoxList(self.gameUnit)
    if event.spineEvent == "special2Mirimu" then
       self.isSpecial2 = true
    end
    if event.spineEvent == "special3Mirimu" then
        ---【MEGA_D-9599】味方全体へのクリティカル率UPは、バフ無効化に当たるなら配らない（奥義ゲージの効果は配る）
        local critBlocked = isTeamConditionBlockedByLua ~= nil and isTeamConditionBlockedByLua(event.unit, self.SPECIAL3_BUFF.BUFF_ID, self.SPECIAL3_BUFF.ICON, false)
        for i = 0,6 do
            local localUnit =  megast.Battle:getInstance():getTeam(event.unit:getisPlayer()):getTeamUnit(i)
            if localUnit ~= nil then
                if not critBlocked then self:execAddBuff(localUnit,self.SPECIAL3_BUFF) end
                self:execAddBuff(localUnit,self.SPECIAL3_BUFF2)
            end
        end
    end
    return 1
end

function class:takeAttack(event)
    self.isSpecial2 = false
    return 1
end

function class:takeSkill(event)
    self.isSpecial2 = false
    return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    --if self.isSpecial2 then
    --    self:execAddBuff(event.enemy,self.SPECIAL2_BUFF)
    --end
    return event.value
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;

    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
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

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

end



class:publish();

return class;