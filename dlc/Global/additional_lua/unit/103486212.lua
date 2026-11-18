local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒ヴァレリー", version=1.3, id=103486212});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0000,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0
        }
    }
end

----// start //----------------------------------------------------------------------------
-- 条件 : ユニット登場時。（戦闘開始、交代、蘇生時など）
-- 引数 : event.unit / 自ユニット
---------------------------------------------------------------------------------
function class:start(event)
    if event.unit:getParameter("used") ~= "false" and event.unit:getParameter("used") ~= "true" then
        event.unit:setParameter("used","false")
    end
    self.gameUnit = event.unit
    self:setBuffBoxList()
    return 1
end

----// update //-----------------------------------------------------------------------------
-- 条件 : 毎フレームごと。
-- 引数 : event.unit / 自ユニット
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getParameter("used") == "false" then
        self:checkHp(event.unit)
    end
    return 1
end

function class:checkHp(unit)
    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
    if hpRate <= 40 and unit:getLevel() >= 90 then
        unit:setParameter("used","true")
        unit:addSPWithPvpCorrection(200);
        unit:takeHeal(unit:getCalcHPMAX() * 1,unit)
    end
end


----// excuteAction //-----------------------------------------------------------------------------
-- 条件 : 行動時。(とりあえず何か行動するたびに呼ばれる)
-- 引数 : event.unit / 自ユニット
---------------------------------------------------------------------------------
function class:excuteAction(event)
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
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

function class:teamAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end


class:publish();

return class;