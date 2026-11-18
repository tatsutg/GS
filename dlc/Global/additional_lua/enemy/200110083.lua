local class = summoner.Bootstrap.createEnemyClass({label="まーる", version=1.6, id=200110083});
class:inheritFromUnit("bossBase");

--使用する通常攻撃とその確率
class.WEAPON_STATE = {
    NONE = 0,
    FIRE = 1,
    ICE = 2,
    EARTH = 3
}

class.STATE_ACTOIN = {
    [0] = {
        ATTACK = 1,
        SKILL = 4
    },
    [1] = {
        ATTACK = 2,
        SKILL = 1
    },
    [2] = {
        ATTACK = 3,
        SKILL = 2
    },
    [3] = {
        ATTACK = 4,
        SKILL = 3
    }
}



--攻撃や奥義に設定されるスキルの番号
class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 1,
    ATTACK6 = 1,
    ATTACK7 = 1,
    ATTACK8 = 1,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7,
    SKILL4 = 8
}

class.BUFF_ARGS = {
    ID = 500241,
    EFID = 7,
    VALUE = 3000,
    DURATION = 9999999,
    ICON = 35
}

class.ANIMATION_STATE = {
    IDLE = 0,
    BACK = 1
}




--===============================================================================================================================================
--デフォルトのイベント/
------------------
function class:start(event)

    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.state = self.WEAPON_STATE.NONE;
    self.modeChangeFlag = false;

    self.modeList = {
        mode1 = 50,
        mode2 = 50,
        mode3 = 50 
    }

    self.hpTriggers = {
        [100] = "modeChange",
        [67] = "modeChange",
        [34] = "modeChange"
    }

    self.gameUnit = event.unit;
    event.unit:addSP(100);
    return 1;
end





function class:run (event)
    if event.spineEvent == "addSP" then self:addSP(event.unit) end
    if event.spineEvent == "endless" then self:endless(event.unit) end
    if event.spineEvent == "silence" then self:silence(event.unit) end
    if event.spineEvent == "criticalHit" then self:criticalHit(event.unit) end
    if event.spineEvent == "colorChange" then self:colorChange(event.unit) end
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    if self.modeChangeFlag then
        event.unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2
    end
    return 1;
end

function class:takeIdle(event)
    self:animationSwitcher(event.unit,self.ANIMATION_STATE.IDLE);
    return 1;
end

function class:takeBack(event)
    self:animationSwitcher(event.unit,self.ANIMATION_STATE.BACK);
    return 1;
end


function class:attackBranch(unit)
    if self.modeChangeFlag then
        local mode = self:randomPopFromModeList();

        if mode == self.WEAPON_STATE.FIRE then
            unit:takeAttack(5);
        elseif mode == self.WEAPON_STATE.ICE then
            unit:takeAttack(6);
        elseif mode == self.WEAPON_STATE.EARTH then
            unit:takeAttack(7);
        end
        
        self:modeChange(unit,mode);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.state);
    else
        unit:takeAttack(self.STATE_ACTOIN[self.state].ATTACK);
    end
    
    return 0;
end

function class:skillBranch(unit)
    unit:takeSkill(self.STATE_ACTOIN[self.state].SKILL);
    return 0;
end

function class:takeDamage(event)
    return 1;
end

function class:takeDamageValue(event)
    if self.modeChangeFlag then
        return 1;
    end
    return event.value;
end

function class:takeBreakeDamageValue(event)
    if self.modeChangeFlag then
        return 0;
    end
    return event.value;
end

-- function class:takeElementRate(event)
--     if event.value <= 1 then
--         local active = event.enemy:getActiveBattleSkill();
--         if active ~= nil then
--             el = active:getElementType();
--             return el == 0 and event.value or 0;
--         end
--         return 0;
--     end
--     return event.value;
-- end

function class:dead(event)

    return 1;
end


function class:endless(unit)
    unit:addOrbitSystemWithFile("50024Skill4Ef","skill4");
    unit:addOrbitSystemCameraWithFile("50024Skill4Ef2","skill4",false);
    unit:addOrbitSystemWithFile("50024Skill4Ef3","skill4");
    unit:addOrbitSystem("skill4Effect",0);
end

function class:silence(unit)
        --全員沈黙させる
        for i = 0,6 do
            local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
            if uni ~= nil then
                uni:getTeamUnitCondition():addCondition(-12,92,100,20,0);    
            end
        end
    return 1;
end

function class:criticalHit(unit)
    unit:getTeamUnitCondition():addCondition(22,22,200,15,0);
    return 1;
end

function class:HPTriggersCheck(unit)
    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.hpTriggers) do

        if i >= hpRate and self.hpTriggers[i] ~= nil then
            self:excuteTrigger(unit,self.hpTriggers[i]);
            self.hpTriggers[i] = nil;
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "modeChange" then
        self.modeChangeFlag = true;
    end
end

function class:randomPopFromModeList()
    local str = summoner.Random.sampleWeighted(self.modeList);
    local index = string.gsub(str,"mode","");
    self.modeList[str] = 0;
    return tonumber(index);
end

function class:modeChange(unit,stateIndex)
    self.modeChangeFlag = false;
    local buff =  unit:getTeamUnitCondition():findConditionWithID(500241);
    if buff ~= nil then
        unit:getTeamUnitCondition():removeCondition(buff);
    end
    
    if stateIndex == 0 then
        unit:setSetupAnimationName("");
        unit:setElementType(kElementType_None);
        megast.Battle:getInstance():setBossCounterElement(kElementType_None);
    end
    if stateIndex == 1 then
        unit:setSetupAnimationName("setUpSword");
        unit:setElementType(kElementType_Fire);
        megast.Battle:getInstance():setBossCounterElement(kElementType_Fire);
        -- summoner.Utility.messageByEnemy(self.TEXT.mess3,5,summoner.Color.cyan);
        -- summoner.Utility.messageByEnemy(self.TEXT.mess4,5,summoner.Color.red);
    end
    if stateIndex == 2 then
        unit:setSetupAnimationName("setUpSpear");
        unit:setElementType(kElementType_Aqua);
        megast.Battle:getInstance():setBossCounterElement(kElementType_Aqua);
        -- summoner.Utility.messageByEnemy(self.TEXT.mess5,5,summoner.Color.green);
        -- summoner.Utility.messageByEnemy(self.TEXT.mess6,5,summoner.Color.cyan);
        
    end
    if stateIndex == 3 then
        unit:setSetupAnimationName("setUpBow");
        unit:setElementType(kElementType_Earth);
        megast.Battle:getInstance():setBossCounterElement(kElementType_Earth);
        -- summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.red);
        -- summoner.Utility.messageByEnemy(self.TEXT.mess2,5,summoner.Color.green);
        --unit:getTeamUnitCondition():addCondition(self.BUFF_ARGS.ID,self.BUFF_ARGS.EFID,self.BUFF_ARGS.VALUE,self.BUFF_ARGS.DURATION,self.BUFF_ARGS.ICON);
    end
    self.state = stateIndex;
end

function class:colorChange(unit)
    if self.state == self.WEAPON_STATE.FIRE then
        megast.Battle:getInstance():setBackGroundColor(99999,255,0,0);
    elseif self.state == self.WEAPON_STATE.ICE then
        megast.Battle:getInstance():setBackGroundColor(99999,0,0,255);
    elseif self.state == self.WEAPON_STATE.EARTH then
        megast.Battle:getInstance():setBackGroundColor(99999,0,255,0);
    end
end

--===============================================================================================================================================
--アニメーション関係/
----------
function class:animationSwitcher(unit,animState)
    if animState == self.ANIMATION_STATE.IDLE then
        if self.state == self.WEAPON_STATE.NONE then
            unit:setNextAnimationName("idle");
        end
        if self.state == self.WEAPON_STATE.FIRE then
            unit:setNextAnimationName("idle2");
        end
        if self.state == self.WEAPON_STATE.ICE then
            unit:setNextAnimationName("idle3");
        end
        if self.state == self.WEAPON_STATE.EARTH then
            unit:setNextAnimationName("idle4");
        end
    end

    if animState == self.ANIMATION_STATE.BACK then
        if self.state == self.WEAPON_STATE.NONE then
            unit:setNextAnimationName("back1");
        end
        if self.state == self.WEAPON_STATE.FIRE then
            unit:setNextAnimationName("back2");
        end
        if self.state == self.WEAPON_STATE.ICE then
            unit:setNextAnimationName("back3");
        end
        if self.state == self.WEAPON_STATE.EARTH then
            unit:setNextAnimationName("back4");
        end
        unit:takeAnimationEffect(0,"back",false);
    end
end



--===============================================================================================================================================
--マルチ同期/
----------

function class:receive1(args)
    self:modeChange(self.gameUnit,args.arg);
    return 1;
end



--===============================================================================================================================================

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end



class:publish();

return class;
