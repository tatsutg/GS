local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒_魔王リムル", version=1.3, id=107837512});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1078375123,
            BUFF_ID = 0,  --アイコン用
            VALUE = 0,
            DURATION = 9999999,
            ICON = 218
        }
    }
end

---------------------------------------------------------------------------------
-- start
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()

    self.skillFlg = false
    self.skill2Flg = false
    self.skillBpUp = 150
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    local skill = event.unit:getActiveBattleSkill()
    if skill ~= nil then
        if skill:getSkillType() == 2 and not self.skillFlg then
            self.skill2Flg = true
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "skill3_orbit" then
        event.unit:addOrbitSystem("skill3_orbit",0)
    end
    return 1
end


---------------------------------------------------------------------------------
-- takeSkill
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function class:takeSkill(event)
    self.skillFlg = false
    if event.index == 3 then
        self.skillFlg = true
    elseif event.index == 5 then
        self.skillFlg = true
        if self.skill2Flg then
            self.skill2Flg = false
            event.unit:addSPWithPvpCorrection(self.skillBpUp)
            event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID)
        end
    end
    return 1
end


---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self.skill2Flg = false
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

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
end

class:publish();

return class;