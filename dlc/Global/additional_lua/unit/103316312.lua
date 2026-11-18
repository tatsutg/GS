local class = summoner.Bootstrap.createUnitClass({label="覚醒ヴァルティー-Lr-", version=1.9, id=103316312});

function class:start(event)
    self.deadFLG = -1
    event.unit:setCutinVoicePB("VOICE_FULLARTS_CUTIN_FB")
    self.gameUnit = event.unit
    self.afterPB = false
    self.PB_Count = event.unit:getPhantomBulletCount()
    self.BUFF_BOX_LIST = {
        ID = 103286512,
        BUFF_ID = 0,
        VALUE = 0,
        DURATION = 999999,
        ICON = 180,
        COUNT = 1,
        MAX = self.PB_Count
    }
    self.gameUnit:setParameter("331_PB",""..self.BUFF_BOX_LIST.COUNT)
    self.BUFF_BOX_LIST2 = {
        ID = 0,
        BUFF_ID = 17,
        VALUE = 30,
        DURATION = 40,
        ICON = 26,
        SCRIPT = {
            SCRIPT_ID = 70,
            VALUE1 = 3
        }
    }
    if self.PB_Count == 0 then
        self.BUFF_BOX_LIST.ICON = 0
    end
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST)
    self.doubleUp = 0
    return 1
end

function class:startWave(event)
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST)
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.deadFLG ~= -1 then
        self.BUFF_BOX_LIST.COUNT = self.deadFLG
        self.gameUnit:setParameter("331_PB",""..self.BUFF_BOX_LIST.COUNT)
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST)
        self.deadFLG = -1
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if self.afterPB then
        if self.PB_Count > 0 then
            self.BUFF_BOX_LIST.COUNT = 1
            self.gameUnit:setParameter("331_PB",""..self.BUFF_BOX_LIST.COUNT)
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST)
        else
            self.BUFF_BOX_LIST.ICON = 0
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST)
        end
        self.afterPB = false
    end
    return 1
end
---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if self.afterPB then
        self.BUFF_BOX_LIST.COUNT = 1
        self.gameUnit:setParameter("331_PB",""..self.BUFF_BOX_LIST.COUNT)
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST)
        self.afterPB = false
    end
    
    if event.index == 4 then

        local PBN = self.BUFF_BOX_LIST.COUNT + self.doubleUp
        --summoner.Utility.messageByPlayer(PBN)
        event.unit:setNextAnimationName("skill3_PB_"..PBN)
        event.unit:setNextAnimationEffectName("2-skill3_PB")
        self.PB_Count = self.PB_Count - self.BUFF_BOX_LIST.COUNT
        event.unit:setPhantomBulletCount(self.PB_Count + 1);
        self.afterPB = true
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self.deadFLG = self.BUFF_BOX_LIST.COUNT
    self.BUFF_BOX_LIST.COUNT = 1
    self.gameUnit:setParameter("331_PB",""..self.BUFF_BOX_LIST.COUNT)
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "PB" then
        local PBN = self.BUFF_BOX_LIST.COUNT + self.doubleUp
        local orbit = event.unit:addOrbitSystem("PB_Hit_"..PBN,0)
        local skill = orbit:getActiveBattleSkill();
        if skill ~= nil then
            if event.unit:getFantasyEvolutionType() == 5 then
                event.unit:getPhantomBulletSkill():setDamageRate(800 + (800 * (PBN - 1)))
            else
                event.unit:getPhantomBulletSkill():setDamageRate(500 + (500 * (PBN - 1)))
            end
        end
    end
    if event.spineEvent == "addBullet" then self:addBullet() end
    if event.spineEvent == "treeBuff" then self:treeBuff() end
    return 1;
end

function class:treeBuff()
    local myTeam = megast.Battle:getInstance():getTeam(self.gameUnit:getisPlayer());
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST2)
        end
    end
    return 1
end

function class:addBullet()
    if self.PB_Count > self.BUFF_BOX_LIST.COUNT then
        self.BUFF_BOX_LIST.COUNT = self.BUFF_BOX_LIST.COUNT < self.BUFF_BOX_LIST.MAX and self.BUFF_BOX_LIST.COUNT + 1 or self.BUFF_BOX_LIST.MAX
        self.gameUnit:setParameter("331_PB",""..self.BUFF_BOX_LIST.COUNT)
    end
    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST)
    return 1;
end

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
        --buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end
end


class:publish();

return class;