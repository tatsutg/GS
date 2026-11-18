local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ハロウィンシャルロット", version=2.0, id=103777112});

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 103777112,
            BUFF_ID = 21,---物理被ダメージアップ
            VALUE = 100,
            DURATION = 25,
            ICON = 185,
            GROUP_ID = 2067,
            PRIORITY = 100,
            SCRIPT = {
                SCRIPT_ID = 2
            }
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.idleFLG = false
    self.skill5FLG = false
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.skill5FLG then
        self.skill5FLG = false
        self:enemyAddBuffSpecial(event.unit,self.BUFF_BOX_LIST[1])
    end
    return 1
end

function class:enemyAddBuffSpecial(unit,buffBox)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local bloodLevel = tonumber(myTeamUnit:getParameter("304_Blood"))
            if bloodLevel == nil then
                bloodLevel = 0
            end
            buffBox.VALUE = 100 + ( 100 * bloodLevel )
            buffBox.PRIORITY = 100 + ( 100 * bloodLevel )
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "idle2" then
        self.idleFLG = true
        event.unit:takeIdle()
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if not self.idleFLG then
        event.unit:setNextAnimationName("idle")
    else
        event.unit:setNextAnimationName("idle2")
    end
    return 1;
end
---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.idleFLG = false
    if event.index == 5 then
        self.skill5FLG = true
    end
    return 1
end
---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.idleFLG = false
    return 1
end
---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCast(event)
    self.idleFLG = false
    return 1;
end
---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    self.idleFLG = false
    return 1;
end
---------------------------------------------------------------------------------
-- takeFront
---------------------------------------------------------------------------------
function class:takeFront(event)
    self.idleFLG = false
    return 1
end
---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    self.idleFLG = false
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

    if buff ~= nil then
        if buffBox.SCRIPT ~= nil then
            buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
            if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
            if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
            if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
            if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
            if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
        end
    end
    return buff
end

class:publish();

return class;