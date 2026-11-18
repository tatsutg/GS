local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒アインズ", version=1.9, id=107697512});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 107697512,
            BUFF_ID = 0,
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
    self:setBuffBoxList()
    self.fireFLG = false

    self.fireOrbit = nil
    self.firstHitFLG = false
    event.unit:setSuperArtsCutInBorder(event.unit:getElementType(),event.unit:getElementType());
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.fireFLG then
        local buff = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
        buff:setRemoveOnResetState(true);
        self.fireFLG = false
    end
    return 1
end

function class:attackElementRate(event)
    local caster = event.unit:getTeamUnitCondition():getDamageAffectInfo().caster
    if caster == self.fireOrbit then
        ---大型ボス対応
        if self.firstHitFLG then
            self.firstHitFLG = false
            if event.enemy:getSize() == 3 then
                ---再生アニメーション変更
                self.fireOrbit:setEndAnimationName("skill2_hit_Boss")
            end
        end
    end
    return event.value;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "skill2_orbit" then
        self.fireOrbit = event.unit:addOrbitSystemInsightRotation("skill2_shot","skill2_hit_normal",1,-98,0,120,0)
        self.firstHitFLG = true
    end

    if event.spineEvent == "skill5_BG" then
        event.unit:addOrbitSystem("skill5_BG",0)
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 2 then
        self.fireFLG = true
    elseif event.index == 3 then
        self.fireFLG = false
    end
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

    return buff
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