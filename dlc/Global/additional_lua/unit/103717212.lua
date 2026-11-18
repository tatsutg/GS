local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒カナリア", version=1.3, id=103717212});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1037172121,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 230
        },
        [2] = {
            ID = 1037172122,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 205
        },
        [3] = {
            ID = 1037172123,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 206
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.num = 2
    self.jacketColor = {
        [2] = "",
        [3] = "_G",
        [1] = "_R"
    }
    self.skillFLG = false
    self.skill2FLG = false
    self:setBuffBoxList()
    self.maxBP = 300
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[self.num])
    megast.Battle:getInstance():updateConditionView();
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    megast.Battle:getInstance():updateConditionView();
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.skill2FLG then
        self.skill2FLG = false
        ---奥義の時に服変更
        event.unit:getTeamUnitCondition():removeConditionWithID(1037172120 + self.num)
        self.num = self.num + 1
        if self.num > 3 then
            self.num = 1
        end
        event.unit:setElementType(self.num)
        event.unit:updateElementIcon(self.num)
        event.unit:getNormalSkill():setElementType(self.num);
        event.unit:setSuperArtsCutInBorder(self.num,self.num);
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[self.num])
        event.unit:setSetupAnimationName("idle"..self.jacketColor[self.num]);
    end
    ---攻撃の属性を変更
    if self.skillFLG then
        self.skillFLG = false
        if event.unit:getActiveBattleSkill() ~= nil then
            event.unit:getActiveBattleSkill():setElementType(self.num);
        end
    end
    return 1
end
---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "skill3" then
        local orbit = event.unit:addOrbitSystem("skill3_orbit"..self.jacketColor[self.num],0);
        orbit:setDamageRateOffset(0.5)
        orbit:setBreakRate(0.5)
    end
    if event.spineEvent == "skill5" then
        local orbit = event.unit:addOrbitSystem("skill5_orbit"..self.jacketColor[self.num],0);
        orbit:setDamageRateOffset(0.5)
        orbit:setBreakRate(0.5)
    end
    return 1
end
---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCast(event)
    event.unit:setNextAnimationName("cast"..self.jacketColor[self.num]);
    return 1;
end
---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    event.unit:setNextAnimationName("idle"..self.jacketColor[self.num]);
    return 1;
end
---------------------------------------------------------------------------------
-- takeFront
---------------------------------------------------------------------------------
function class:takeFront(event)
    event.unit:setNextAnimationName("front"..self.jacketColor[self.num]);
    return 1
end
---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    event.unit:setNextAnimationName("back"..self.jacketColor[self.num]);
    return 1
end
---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    event.unit:setNextAnimationName("damage"..self.jacketColor[self.num]);
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    event.unit:setNextAnimationName("attack"..event.index..self.jacketColor[self.num])
    event.unit:setNextAnimationEffectName("2-attack"..event.index..self.jacketColor[self.num])
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    event.unit:setNextAnimationName("skill"..event.index..self.jacketColor[self.num])
    event.unit:setNextAnimationEffectName("2-skill"..event.index..self.jacketColor[self.num])
    local oldNum = self.num
    if event.index == 1 then
        if not megast.Battle:getInstance():isPvp() then
            event.unit:addSP(math.ceil((self.maxBP - event.unit:getBurstPoint()) /2))
        else
            ---pvp特別補正
            event.unit:addSP(math.ceil((self.maxBP - event.unit:getBurstPoint()) /2 / 3))
        end
    elseif event.index == 2 then
        self.skill2FLG = true
    elseif event.index >= 3 then
        self.skill2FLG = false
        event.unit:setDamageRateOffset(0.5)
        event.unit:setBreakRate(0.5)
    end
    self.skillFLG = true
    return 1
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

class:publish();

return class;