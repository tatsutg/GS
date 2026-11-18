local class = summoner.Bootstrap.createUnitClass({label="レイドオージュ", version=1.4, id=501111413});
class:inheritFromUnit("bossBase");

--==============================================================================================================
--攻撃内容/
--///////

--使用するスキルのパターン skill1,2,3,7,8　の組み合わせ
class.SKILL_PATTERN_A = {7,2,3,1,8,8}

--4,5,6,9,10,11の組み合わせ
class.SKILL_PATTERN_B = {11,9,5,6,4,10,9,5,6,4,10}

class.messages = summoner.Text:fetchByUnitID(501111413);

--攻撃や奥義に設定されるスキルの番号
class.ACTIVE_SKILLS= {
    ATTACK1 = 1,
    ATTACK4 = 2,
    SKILL1 = 3,
    SKILL2 = 4,
    SKILL3 = 5,
    SKILL4 = 6,
    SKILL5 = 7,
    SKILL6 = 8,
    SKILL7 = 9,
    SKILL8 = 10,
    SKILL9 = 11,
    SKILL10 = 12,
    SKILL11 = 13,
    ATTACK5 = 14,
}

class.BUFF_ARGS = {

    DBUFF_ID = 500938,
    DBUFF_EFID = 21,
    DBUFF_VAUE = -25,
    DBUFF_DURATION = 99999,
    DBUFF_ICON = 0,

    BREAKBUFF_ID = 500935,
    BREAKBUFF_EFID = 27,
    BREAKBUFF_VAUE = -20,
    BREAKBUFF_DURATION = 99999,
    BREAKBUFF_ICON = 0,

    BREAKBUFF2_ID = 500935,
    BREAKBUFF2_EFID = 27,
    BREAKBUFF2_VAUE = -40,
    BREAKBUFF2_DURATION = 99999,
    BREAKBUFF2_ICON = 0,

    BREAKBUFF3_ID = 500935,
    BREAKBUFF3_EFID = 27,
    BREAKBUFF3_VAUE = -80,
    BREAKBUFF3_DURATION = 99999,
    BREAKBUFF3_ICON = 0,

    --SPeedBuff
    SPBUFF_ID = 500936,
    SPBUFF_EFID = 27,
    SPBUFF_VAUE = 30,
    SPBUFF_DURATION = 99999,
    SPBUFF_ICON = 7
}

class.TRIGGER_HP = {
    FIRST = 0.7
}

class.ANIMATION_STATES = {
    IN = "in",
    BACK = "back",
    DAMAGE = "damage",
    IDLE = "idle"
}
--==============================================================================================================
--定数/
--////

--魔獣の状態
class.STATES = {
    normal = 0,
    rage = 1
}


--==============================================================================================================
--レイドの部屋で保存しておくもの/
--//////////////////////////


--==============================================================================================================


--==============================================================================================================

function class:start(event)
    self.state = self.STATES.normal;
    self.attackIndex = 0;
    self.isTarget = false;
    self.telopTimer = 1;
    self.telopTimerDelay = 30;
    self.spValue = 20;
    self.attackIndexOffset = self:fetchOffset();

    
    event.unit:setSPGainValue(0);

    return 1;
end

function class:startWave(event)
    if self.state == self.STATES.rage then
        self:addRageBuff(event.unit);
    end
    self.attackIndex = self:fetchAttackIndex() > self.attackIndex and self:fetchAttackIndex() or self.attackIndex;
    return 1;
end

function class:takeIn(event)
    self:fetchState();
    self:animationSwitcher(self.ANIMATION_STATES.IN,event.unit);
    return 1;
end

function class:attackDamageValue(event)
    if self.isTarget then
        event.value = event.value * 1.5;
    end
    return event.value;
end

function class:excuteAction(event)
    self:checkTarget();
    return 1;
end

function class:update(event)
    self:checkTelop(event.deltaTime);
    event.unit:setReduceHitStop(2,0.99);--ヒットストップ無効Lv2　9.9割軽減
    self:breakCheck(event.unit);
    return 1;
end

function class:takeIdle(event)
    self:animationSwitcher(self.ANIMATION_STATES.IDLE,event.unit);
    return 1;
end

function class:takeBack(event)
    self:animationSwitcher(self.ANIMATION_STATES.BACK,event.unit);
    return 1;
end

function class:takeDamage(event)
    self:animationSwitcher(self.ANIMATION_STATES.DAMAGE,event.unit);
    return 1;
end


function class:attackBranch(unit)
    local index = 1;

    if self.state == self.STATES.rage then
        index = 4;
        unit:setSetupAnimationName("idle2-cast");
    end

    if self.state ~= self.STATES.rage and self:isRage(unit) then
        index = 5;
        self:getRage(unit);
    end

    unit:takeAttack(index);
    
    return 0;
end

function class:skillBranch(unit)
    local index = 1;
    if self.state == self.STATES.rage then
        index = self.SKILL_PATTERN_B[(self.attackIndex - self.attackIndexOffset) % table.maxn(self.SKILL_PATTERN_B) + 1];
    else
        index = self.SKILL_PATTERN_A[self.attackIndex % table.maxn(self.SKILL_PATTERN_A) + 1];
    end
    unit:takeSkill(index);
    self.attackIndex = self.attackIndex + 1;
    self:sendAttackIndex();
    return 0;
end

function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "red" then return self:red(event.unit) end
    if event.spineEvent == "redEnd" then return self:redEnd(event.unit) end
    if event.spineEvent == "showInEffect" then return self:showInEffect(event.unit) end
    if event.spineEvent == "addRageBuff" then return self:addRageBuff(event.unit) end
    if event.spineEvent == "showRageEffect" then return self:showRageEffect(event.unit) end
    if event.spineEvent == "firestart" then return self:firestart(event.unit) end            
    if event.spineEvent == "fireloop" then return self:fireloop(event.unit) end
    return 1;
end

--==============================================================================================================
--オージュ固有ギミック/
--////////////////

function class:isRage(unit)
    return summoner.Utility.getUnitHealthRate(unit) < self.TRIGGER_HP.FIRST; 
end

function class:getRage(unit)
    self.state = self.STATES.rage;
    self:sendState();
    self:sendOffset();
    self.attackIndexOffset = self:fetchOffset();
end

function class:addRageBuff(unit)
    local buff = unit:getTeamUnitCondition():addCondition(
        self.BUFF_ARGS.SPBUFF_ID,
        self.BUFF_ARGS.SPBUFF_EFID,
        self.BUFF_ARGS.SPBUFF_VAUE,
        self.BUFF_ARGS.SPBUFF_DURATION,
        self.BUFF_ARGS.SPBUFF_ICON
    );
    summoner.Utility.messageByEnemy(self.messages.mess2,5,summoner.Color.red);
    -- buff:addAnimationWithFile("effect/aura1.json","aura2"); 
    return 1;
end

function class:showRageEffect(unit)
    --背景の色変える
    megast.Battle:getInstance():setBackGroundColor(99999,255,50,255);

    self:firestart(unit);
    return 1;
end

function class:animationSwitcher(animstate,unit)
    if animstate == self.ANIMATION_STATES.IN then
        if self.state == self.STATES.rage then
            unit:setNextAnimationName("in3");
        end
    end
    if animstate == self.ANIMATION_STATES.IDLE then
        if self.state == self.STATES.rage then
            unit:setNextAnimationName("idle2");
        end
    end
    if animstate == self.ANIMATION_STATES.BACK then
        if self.state == self.STATES.rage then
            unit:setNextAnimationName("back2");
        end
    end
    if animstate == self.ANIMATION_STATES.DAMAGE then
        if self.state == self.STATES.rage then
            unit:setNextAnimationName("damage2");
        end
    end
end


function class:firestart(unit)
    self.fire = BattleControl:get():addAnimation("FIRE","FIRE4_00",true);
    self.fire:setPositionX(unit:getPositionX() -50);
    self.fire:setPositionY(unit:getPositionY() -20);
    self.fire:setZOrder(0);
    return 1;
end

function class:fireloop(unit)
    self.fire:setToSetupPose();
    self.fire:setAnimation(0, "FIRE3_00",true);
    return 1;
end

function class:red(unit)
    megast.Battle:getInstance():setBackGroundColor(15,255,0,0);
    return 1;
end

function class:redEnd(unit)
    megast.Battle:getInstance():setBackGroundColor(99999,255,50,255);
    return 1;
end

function class:showInEffect(unit)
    unit:takeAnimationEffect(0,"in1",false);
    return 1;
end


--==============================================================================================================
--レイド特有のギミック周り/
--////////////////////

function class:getIsTarget()
    if not megast.Battle:getInstance():isRaid() then
        return false;
    end
    return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > 1000000;
end

function class:checkTarget()
    if not self. isTarget and self:getIsTarget() then
        summoner.Utility.messageByEnemy(self.messages.mess1,5,summoner.Color.red);
        BattleControl:get():showHateAll();
    elseif self.isTarget and not self:getIsTarget() then
        BattleControl:get():hideHateAll();     
    end
    self.isTarget = self:getIsTarget();
end

function class:checkTelop(deltatime)
    if not megast.Battle:getInstance():isRaid() then
        return false;
    end
    --テロップ表示のチェック
    self.telopTimer = self.telopTimer - deltatime;
    if self.telopTimer < 0 then
        self.telopTimer = self.telopTimerDelay;                
        local rand = LuaUtilities.rand(0,4)
        if rand == 0 then
            if self.isTarget then
                RaidControl:get():addPauseMessage(self.messages.telop3 , 2.2);
            else
                RaidControl:get():addPauseMessage(self.messages.telop1 , 2.2);
            end
        elseif rand == 1 then
            if self.state == self.STATES.rage then
                RaidControl:get():addPauseMessage(self.messages.telop4 , 2.2);
            else
                RaidControl:get():addPauseMessage(self.messages.telop2 , 2.2);
            end
        elseif rand == 2 then
            RaidControl:get():addPauseMessage(self.messages.telop5 , 2.2);
        elseif rand == 3 then
            RaidControl:get():addPauseMessage(self.messages.telop6 , 2.2);
        end
    end
end

function class:breakCheck(unit)
    if not megast.Battle:getInstance():isRaid() then
        return;
    end
    if RaidControl:get():getRaidBreakCount() >= 1 then
        unit:getTeamUnitCondition():addCondition(
            self.BUFF_ARGS.BREAKBUFF_ID,
            self.BUFF_ARGS.BREAKBUFF_EFID,
            self.BUFF_ARGS.BREAKBUFF_VAUE,
            self.BUFF_ARGS.BREAKBUFF_DURATION,
            self.BUFF_ARGS.BREAKBUFF_ICON
        );
    end
    if RaidControl:get():getRaidBreakCount() >= 2 then
        unit:getTeamUnitCondition():addCondition(
            self.BUFF_ARGS.BREAKBUFF2_ID,
            self.BUFF_ARGS.BREAKBUFF2_EFID,
            self.BUFF_ARGS.BREAKBUFF2_VAUE,
            self.BUFF_ARGS.BREAKBUFF2_DURATION,
            self.BUFF_ARGS.BREAKBUFF2_ICON
        );
    end
    if RaidControl:get():getRaidBreakCount() >= 3 then
        unit:getTeamUnitCondition():addCondition(
            self.BUFF_ARGS.BREAKBUFF3_ID,
            self.BUFF_ARGS.BREAKBUFF3_EFID,
            self.BUFF_ARGS.BREAKBUFF3_VAUE,
            self.BUFF_ARGS.BREAKBUFF3_DURATION,
            self.BUFF_ARGS.BREAKBUFF3_ICON
        );
    end

end

--==============================================================================================================
--部屋の同期周り/
--////////////


function class:sendState()
    if not megast.Battle:getInstance():isRaid() then
        return;
    end
    if RaidControl:get() ~= nil then
        RaidControl:get():setCustomValue("state",""..self.state);
    end
end

function class:fetchState()
    if not megast.Battle:getInstance():isRaid() then
        return self.state;
    end
    if RaidControl:get() ~= nil then
        local st = tonumber(RaidControl:get():getCustomValue("state"));
        if st ~= "" and st ~= "error" and st ~= nil then
            self.state = st;
        else
            self.state = 0;
        end
    end
end

function class:sendAttackIndex()
    if not megast.Battle:getInstance():isRaid() then
        return;
    end
    if RaidControl:get() ~= nil then
        local roomAttackIndex = self:fetchAttackIndex();
        if roomAttackIndex < self.attackIndex then
            RaidControl:get():setCustomValue("attackIndex",""..self.attackIndex);
        end
    end
end

function class:fetchAttackIndex()
    if not megast.Battle:getInstance():isRaid() then
        return self.attackIndex;
    end
    if RaidControl:get() ~= nil then
        local st = tonumber(RaidControl:get():getCustomValue("attackIndex"));
        if st ~= "" and st ~= "error" and st ~= nil then
            return st;
        else
            return 0;
        end
    end
end

function class:sendOffset()
    if not megast.Battle:getInstance():isRaid() then
        return;
    end
    if RaidControl:get() ~= nil and self:fetchOffset() == 0 then

        RaidControl:get():setCustomValue("attackIndexOffset",""..self:fetchAttackIndex() + 1);
    end
end

function class:fetchOffset()
    if not megast.Battle:getInstance():isRaid() then
        return self.attackIndex + 1;
    end
    if RaidControl:get() ~= nil then
        local st = tonumber(RaidControl:get():getCustomValue("attackIndexOffset"));
        if st ~= "" and st ~= "error" and st ~= nil then
            return st;
        else
            return 0;
        end
    end
end


--============================================================================================================

class:publish();

return class;