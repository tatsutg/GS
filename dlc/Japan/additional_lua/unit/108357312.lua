local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒魂魄妖夢", version=2.6, id=108357312});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 108357312,
            BUFF_ID = 17,
            VALUE = 100,
            DURATION = 99999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 520,
                VALUE1 = 3
            }
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList();
    self.gameUnit = event.unit;
    self.skill5Dmg = event.unit:getBurstSkill3():getDamageRate();
    event.unit:setDeadEffectWithFile("EAST_dead","dead");

    --固有アビリティ対応
    local ID = 52000 + (event.unit:getIndex() * 10);
    local buff = event.unit:getTeamUnitCondition():addCondition(ID,238,0,999999,0);
    buff:setScriptID(520);
    buff:setValue1(3);
    buff:setValue2(40364600);
    buff:setValue3(15);
    buff:setValue4(34);
    buff:setValue5(29);
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill5BG" then
        event.unit:addOrbitSystem("skill5BG",0);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    BattleControl:get():cancelChangeBackgroundMusic(event.unit);
    --summoner.Utility.messageByEnemy(megast.Battle:getInstance():getQuestScriptID())
    if event.index == 5 then
        event.unit:setNextAnimationEffectName("2-skill5")
        if megast.Battle:getInstance():getQuestScriptID() ~= 2078310 then
            BattleControl:get():changeBackgroundMusic("LOSTWORD_YOUMU_ONESHOT",event.unit,1000,1000,0,true);
        end
        -- クエスト開始から120秒以内に発動した場合、ダメージ倍率2倍。
        if BattleControl:get():getTime() <= 120 then
            event.unit:getBurstSkill3():setDamageRate(self.skill5Dmg * 2);
        else
            event.unit:getBurstSkill3():setDamageRate(self.skill5Dmg);
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    event.unit:getBurstSkill3():setDamageRate(self.skill5Dmg);
    return 1;
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