local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒モルク", version=2.5, id=104237212});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.ADD_SP_VALUE = 100
    self.isShinOugi = false
    --self:setBuffBoxList()
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self.isShinOugi = false
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)

    local type = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if type == 3 or type == 6 then
        return event.value;
    end

    if self.isShinOugi and event.unit == self.gameUnit then
        if event.enemy:getHP() < event.value then
            event.unit:addSPWithPvpCorrection(self.ADD_SP_VALUE)
        end
    end
    return event.value
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    local myUnit = self:getAncestorUnit(event.unit)

    local type = myUnit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if type == 3 or type == 6 then
        return event.value;
    end

    if self.isShinOugi and myUnit == self.gameUnit then
        if event.enemy:getHP() < event.value then
            myUnit:addSPWithPvpCorrection(self.ADD_SP_VALUE)
        end
    end
    return event.value
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill3_orbit" then
        local orbit = event.unit:addOrbitSystem("skill3_orbit",0)
        orbit:setDamageRateOffset(0.5)
        orbit:setBreakRate(0.5)
    end
    if event.spineEvent == "Library_skill5_orbit" then
        local orbit = event.unit:addOrbitSystem("skill5_orbit",0)
        orbit:setDamageRateOffset(0.5)
        orbit:setBreakRate(0.5)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.isShinOugi = false
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.isShinOugi = false
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)

    if event.index == 3 then
        self.isShinOugi = true
        event.unit:setDamageRateOffset(0.5)
        event.unit:setBreakRate(0.5)
    elseif event.index == 5 then
        self.isShinOugi = false
        event.unit:setDamageRateOffset(0.5)
        event.unit:setBreakRate(0.5)
    end

    -- 【MEGA_D-9761】ボスの技の予告に、この技で Lua が作る弾（addOrbitSystem）の取り分を入れる（本体の取り分を下げた残り。表示専用。古いアプリには無いので確かめてから呼ぶ）
    if (event.index == 3 or event.index == 5) and event.unit.announceSkillDamage then event.unit:announceSkillDamage(3, 0.5, 1) end
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    self.isOugi = false
    return 1
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
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
end


class:publish();

return class;