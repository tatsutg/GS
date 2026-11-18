local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒 志々雄真実", version=1.3, id=108147112});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1081471122,
            BUFF_ID = 97,
            VALUE = 200,
            DURATION = 60,
            ICON = 87,
            GROUP_ID = 3837,
            PRIORITY = 151500
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.skill5FLG = false
    return 1
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

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.skill5FLG then
        self.skill5FLG = false
        local hp = event.unit:getHP() / event.unit:getCalcHPMAX() * 100
        if hp <= 50 then
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        end
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
end

class:publish();

return class;