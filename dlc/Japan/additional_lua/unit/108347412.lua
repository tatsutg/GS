local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒霧雨魔理沙", version=2.6, id=108347412});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1083371122,
            BUFF_ID = 17,
            VALUE = 100,
            DURATION = 99999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 520,
                VALUE1 = 2
            }
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.gameUnit = event.unit;
    event.unit:setDeadEffectWithFile("EAST_dead","dead");

    --固有アビリティ対応
    local ID = 52000 + (event.unit:getIndex() * 10);
    local buff = event.unit:getTeamUnitCondition():addCondition(ID,238,0,999999,0);
    buff:setScriptID(520);
    buff:setValue1(2);
    buff:setValue2(40364500);
    buff:setValue3(30);
    buff:setValue4(26);
    buff:setValue5(17);
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    BattleControl:get():cancelChangeBackgroundMusic(event.unit);
    if event.index == 5 then
        BattleControl:get():changeBackgroundMusic("LOSTWORD_MARISA_ONESHOT",event.unit,1000,1000,0,true);
        -- 現在HPの33倍（％）のダメージ。
        event.unit:getBurstSkill3():setDamageRate(event.unit:getHP() * 0.33);
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