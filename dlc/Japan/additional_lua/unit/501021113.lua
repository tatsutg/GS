--@additionalEnemy,600000006
local instance = summoner.Bootstrap.createUnitClass({label="レイド魔獣", version=1.3, id=501021113});
instance:inheritFromUnit("bossBase");

--==============================================================================================================
--攻撃内容/
--///////

--使用する通常攻撃とその確率
instance.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50
}

--使用する奥義とその確率
instance.SKILL_WEIGHTS = {
    SKILL1 = 50,
    SKILL2 = 50
}

--攻撃や奥義に設定されるスキルの番号
instance.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL1 = 6,
    SKILL2 = 7
}
--==============================================================================================================
--定数/
--////

instance.hpBoders = {
    first = 70,
    second = 30
}


--魔獣の状態
instance.STATES = {
    normal = 0,
    hide = 2,
    rage = 3
}

instance.phaseCount = 0;

instance.buffArgs = {

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
    SPBUFF_EFID = 28,
    SPBUFF_VAUE = 30,
    SPBUFF_DURATION = 99999,
    SPBUFF_ICON = 7
}

instance.messages = summoner.Text:fetchByUnitID(501021113);




--==============================================================================================================

instance.TELOP_TIMER_DELAY = 30;
instance.KILL_COUNT_MAX = 50;
instance.SUMMON_ENEMY_ID = 600000006;
instance.HIDE_TIME_MAX = 60;
instance.BATTLE_POINT_VALUE = 10000;
instance.TARGET_BORDER_LINE = 1000000;
instance.FIRST_RAGE_HP = 0.7;
instance.SECOND_RAGE_HP = 0.3;


--==============================================================================================================

function instance:start(event)
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;

    --魔獣の状態
    self.state = 0;

    --この部屋でのガウルの撃破数
    self.killCount = 0;

    --自分が倒したガウルの数を部屋に送るまで持っておく　sendKillCountすると0に戻る
    self.killCountLocal = 0;

    self.isTarget = false;
    self.telopTimer = 1;
    self.isHide = false;
    self.hideTimer = 0;
    self.summonTimer = 0;
    self.killCountTimer = 0;
    self.fetchTimer = 0;
    self.isStart = false;
    self.attackdelayOriginal = 0;

    self.isHpZero = false;
    self.forceClearTimer = 0;
    self.isClear = false;

    self.shownMessageIDs = {};
    self.currentMessageID = "0";

    event.unit:setSkin("normal");
    event.unit:setSPGainValue(0);
    self.attackdelayOriginal = event.unit:getAttackDelay();
    return 1;
end

function instance:startWave(event)
    return 1;
end

function instance:excuteAction(event)
    self:breakCheck(event.unit);
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return 1;
    end
    if not self.isStart then
        return self:startFetch(event);
    end
    self:checkTarget();
    
    if self.isHide then
        return 0;
    end
    event.unit:setInvincibleTime(0);
    return self:checkState(event.unit);
end

function instance:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "hide" then self:hide(event.unit) end
    if event.spineEvent == "excuteRage" then self:excuteRage(event.unit) end
    return 1;
end

function instance:update(event)
    self:checkTelop(event.deltaTime);
    self:clearCheck(event.unit,event.deltaTime);
    if self.isHide then
        self:hideControll(event.unit,event.deltaTime);
        self:summon(event.unit,event.deltaTime);
    end
    return 1;
end

function instance:takeBreake(event)
    self:rageEnd(event.unit);
    return 1;
end

function instance:dead(event)
    for i = 0, 5 do
        local enemy = event.unit:getTeam():getTeamUnit(i,true);
        if not(enemy == nil )then
            enemy:setHP(0);
        end
    end
    return 1;
end

-- 【MEGA_D-9761】ボスの技の予告に、attackDamageValue の倍率（レイドの順位 3 位以内・累計 100 万ポイント超で ×2.5）を入れる（表示専用。古いアプリには無いので確かめてから呼ぶ）
-- 親（bossBase）の skillActiveSkillSetter と同じく技を付け、そのあと予告に倍率を入れる。bossBase は変えない（62 体が使う）
function instance:skillActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
    if self.isTarget and unit.announceSkillRate then unit:announceSkillRate(2.5) end
end

function instance:attackDamageValue(event)
    if self.isTarget then
        event.value = event.value * 2.5;
    end
    return event.value;
end

--==============================================================================================================
--魔獣のギミック周り/
--////////////////

function instance:startFetch(event)
    self:fetchState();
    self:fetchPhaseCount();
    self:fetchKillCount();
    self.isStart = true;
    return self:initState(event);
end

function instance:initState(event)
    if self.state == self.STATES.hide then
         self:startHide(event.unit);
         return 0;
    end
    if self.state == self.STATES.rage then
        event.unit:takeAnimation(0,"change",false);
        return 0;
    end
    return 1;
end

function instance:checkState(unit)
    if unit.m_breaktime > 0 then
        return 1;
    end

    if self.phaseCount == 0 and summoner.Utility.getUnitHealthRate(unit) < self.FIRST_RAGE_HP then
        self.phaseCount = 1;
        self.state = self.STATES.hide;

        self:sendState(self.state);
        self:sendPhaseCount();
        self:startHide(unit);
        return 0;
    end

    if self.phaseCount == 1 and summoner.Utility.getUnitHealthRate(unit) < self.SECOND_RAGE_HP then
        self.phaseCount = 2;
        self.state = self.STATES.hide;

        self:sendState(self.state);
        self:sendPhaseCount();
        self:startHide(unit);
        return 0;
    end

    --万が一移行モーションを止められても再チェックを行えるようにしておく
    if self.state == self.STATES.hide and not self.isHide then
        self:startHide(unit);
        return 0;
    end

    return 1;
end

function instance:startHide(unit)
    unit:takeAnimation(0,"hide",false);
    self.killCountLocal = 0;
    self.killCount = 0;
    unit:setInvincibleTime(125);
    unit._ignoreBorder = true;
end

function instance:hide(unit)
    self.isHide = true;
    for i=0,2 do
        if unit:getTeam():getTeamUnit(i) == nil then
        unit:getTeam():addUnit(i,self.SUMMON_ENEMY_ID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
      end
    end
end

function instance:finishHide(unit)
    unit:setInvincibleTime(0);
    self.isHide = false;
    self.hideTimer = 0;
    -- self:excuteRage(unit);
    self.isRage = true;
    self.state = self.STATES.rage;
    self:sendState(self.state);
    unit:takeAnimation(0,"in2",false);
    unit._ignoreBorder = true;
    
end

function instance:hideControll(unit,deltaTime)
    unit:setPosition(-1000,-1000);
    unit:getSkeleton():setPosition(0,0);--見た目上のズレも無くす
    unit._ignoreBorder = true;--アニメーションの更新があっても外に居られるようにする
    self.hideTimer = self.hideTimer + deltaTime;
    if self.hideTimer > self.HIDE_TIME_MAX then
        self:finishHide(unit);
    end
end

function instance:excuteRage(unit)
    unit._ignoreBorder = false;
    self.isRage = true;
    self.state = self.STATES.rage;
    self:sendState(self.state);
    unit:setReduceHitStop(2,0.8);--ヒットストップ無効Lv2　８割軽減
    unit:setAttackDelay(0);
    summoner.Utility.messageByEnemy(self.messages.mess3,5,summoner.Color.red);
    unit:setSkin("rage");
    
    --背景の色変える
    megast.Battle:getInstance():setBackGroundColor(99999,255,50,255);


    local buff = unit:getTeamUnitCondition():addCondition(
        self.buffArgs.SPBUFF_ID,
        self.buffArgs.SPBUFF_EFID,
        self.buffArgs.SPBUFF_VAUE,
        self.buffArgs.SPBUFF_DURATION,
        self.buffArgs.SPBUFF_ICON
    );

    buff:addAnimationWithFile("effect/aura1.json","aura2"); 

    unit:getTeamUnitCondition():addCondition(
        self.buffArgs.DBUFF_ID,
        self.buffArgs.DBUFF_EFID,
        self.buffArgs.DBUFF_VAUE,
        self.buffArgs.DBUFF_DURATION,
        self.buffArgs.DBUFF_ICON
    );
end

function instance:rageEnd(unit)
    if self.state == self.STATES.rage then
        self.state = self.STATES.normal;
    end
    self.isRage = false;
    
    self:sendState(self.state);
    unit:setSkin("normal");
    unit:setAttackDelay(self.attackdelayOriginal);

    local buff = unit:getTeamUnitCondition():findConditionWithID(self.buffArgs.SPBUFF_ID);
    if buff ~= nil then
        unit:getTeamUnitCondition():removeCondition(buff);
    end

    local buff2 = unit:getTeamUnitCondition():findConditionWithID(self.buffArgs.DBUFF_ID);
    if buff2 ~= nil then
        unit:getTeamUnitCondition():removeCondition(buff2);
    end

    --背景の色戻す
    megast.Battle:getInstance():setBackGroundColor(99999,255,255,255);
end

function instance:summon(unit,deltaTime)
    self.summonTimer = self.summonTimer + deltaTime;
    self.killCountTimer = self.killCountTimer + deltaTime;
    self.fetchTimer = self.fetchTimer + deltaTime;

    local summonDelay = 1;

    if self.summonTimer < summonDelay then
        return 1;
    else
        self.summonTimer = 0;
    end

    local fetchDelay = 5;
    if self.fetchTimer > fetchDelay then
        self.fetchTimer = 0;
        self:fetchKillCount();
        if self.killCount > self.KILL_COUNT_MAX then
            self:finishHide(unit);
        end
    end


    --0~2の場所が空席ならユニット召喚
    for i=0,2 do
        if unit:getTeam():getTeamUnit(i) == nil then
            unit:getTeam():addUnit(i,self.SUMMON_ENEMY_ID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
            self.killCountLocal = self.killCountLocal + 1;
            if self.killCountTimer > 7 then
                self.killCountTimer = 0;
                self:sendKillCount();
            end
            RaidControl:get():addBattlePoint(self.BATTLE_POINT_VALUE,0);
            summoner.Utility.messageByEnemy(string.format(self.messages.mess2,self.BATTLE_POINT_VALUE),1,summoner.Color.white);
            if self.killCount > self.KILL_COUNT_MAX then
                self:finishHide(unit);
            end
        end
    end
    
    return 1;
end



--==============================================================================================================
--レイド特有のギミック周り/
--////////////////////

function instance:getIsTarget()
    if RaidControl:get() == nil then
        return false;
    end
    return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > self.TARGET_BORDER_LINE;
end

function instance:checkTarget()
    if not self.isTarget and self:getIsTarget() then
        summoner.Utility.messageByEnemy(self.messages.mess1,5,summoner.Color.red);
    end
    if self:getIsTarget() then
        BattleControl:get():showHateAll();
    else
        BattleControl:get():hideHateAll();     
    end
    self.isTarget = self:getIsTarget();
end

function instance:checkTelop(deltatime)
    --テロップ表示のチェック
    self.telopTimer = self.telopTimer - deltatime;
    if self.telopTimer < 0 then
        self.telopTimer = self.TELOP_TIMER_DELAY;                
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

function instance:breakCheck(unit)
    if RaidControl:get():getRaidBreakCount() >= 1 then
        unit:getTeamUnitCondition():addCondition(
            self.buffArgs.BREAKBUFF_ID,
            self.buffArgs.BREAKBUFF_EFID,
            self.buffArgs.BREAKBUFF_VAUE,
            self.buffArgs.BREAKBUFF_DURATION,
            self.buffArgs.BREAKBUFF_ICON
        );
    end
    if RaidControl:get():getRaidBreakCount() >= 2 then
        unit:getTeamUnitCondition():addCondition(
            self.buffArgs.BREAKBUFF2_ID,
            self.buffArgs.BREAKBUFF2_EFID,
            self.buffArgs.BREAKBUFF2_VAUE,
            self.buffArgs.BREAKBUFF2_DURATION,
            self.buffArgs.BREAKBUFF2_ICON
        );
    end
    if RaidControl:get():getRaidBreakCount() >= 3 then
        unit:getTeamUnitCondition():addCondition(
            self.buffArgs.BREAKBUFF3_ID,
            self.buffArgs.BREAKBUFF3_EFID,
            self.buffArgs.BREAKBUFF3_VAUE,
            self.buffArgs.BREAKBUFF3_DURATION,
            self.buffArgs.BREAKBUFF3_ICON
        );
    end

end

function instance:clearCheck(unit,deltaTime)
   if self.isClear then
      return;
   end

   if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
       return;
   end

   if unit:getHP() <= 0 then
      self.isHpZero = true;
   end



   if self.isHpZero then
      self.forceClearTimer = self.forceClearTimer + deltaTime;
   end

   -- if self.forceClearTimer >= 5 then
   --    megast.Battle:getInstance():waveEnd(true);
   --    self.isClear = true;
   -- end


   return 1;
end

--==============================================================================================================
--部屋の同期周り/
--////////////


function instance:sendState(state)
    if RaidControl:get() ~= nil then
        RaidControl:get():setCustomValue("state",""..state);
    end
end

function instance:fetchState()
    if RaidControl:get() ~= nil then
        local st = tonumber(RaidControl:get():getCustomValue("state"));
        if st ~= "" and st ~= "error" and st ~= nil then
            self.state = st;
        else
            self.state = 0;
        end
    end
end

function instance:sendKillCount()
    self:fetchKillCount();
    
    self:sendMessage();

    if RaidControl:get() ~= nil then       
        if self.phaseCount >= 2 then
            RaidControl:get():setCustomValue("killCount2",""..(self.killCountLocal + self.killCount));
        else
            RaidControl:get():setCustomValue("killCount",""..(self.killCountLocal + self.killCount));
        end
        self.killCountLocal = 0;
    end
end

function instance:fetchKillCount()
    if RaidControl:get() ~= nil then
        local roomMessage = self:fetchMessage();
        if roomMessage ~= nil and roomMessage ~= "error" and roomMessage ~= "" then
            if nil == self.shownMessageIDs[self.currentMessageID] then
                RaidControl:get():addPauseMessage(self:toUnicode(roomMessage), 2.2);
                self.shownMessageIDs[self.currentMessageID] = roomMessage;
            end
        end
        if self.isHide then
            self:fetchHideTimer();
            self:sendHideTimer();
        end
        local st = tonumber(RaidControl:get():getCustomValue("killCount"));
        if self.phaseCount >= 2 then
            st = tonumber(RaidControl:get():getCustomValue("killCount2"));
        end
        if st ~= "" and st ~= "error" and st ~= nil then
            self.killCount = st;
        else
            self.killCount = 0;
        end
    end
end

function instance:sendPhaseCount()
 
    if RaidControl:get() ~= nil then
        RaidControl:get():setCustomValue("phaseCount",""..self.phaseCount);
    end
end

function instance:fetchPhaseCount()
    if RaidControl:get() ~= nil then
        local st = tonumber(RaidControl:get():getCustomValue("phaseCount"));
        if st ~= "" and st ~= "error" and st ~= nil then
            self.phaseCount = st;
        else
            self.phaseCount = 0;
        end
    end
end

function instance:sendHideTimer()
 
    if RaidControl:get() ~= nil then
        local key = "hideTimer";
        if self.phaseCount >= 2 then
            key = "hideTimer2"
        end
        local st = tonumber(RaidControl:get():getCustomValue(key));
        
        if st ~= "" and st ~= "error" and st ~= nil then
            if st < self.hideTimer then
                RaidControl:get():setCustomValue(key,""..self.hideTimer);
            end
        else
            RaidControl:get():setCustomValue(key,""..self.hideTimer);
        end
        
    end
end

function instance:fetchHideTimer()
    if RaidControl:get() ~= nil then

        local st = tonumber(RaidControl:get():getCustomValue("hideTimer"));
        if self.phaseCount >= 2 then
            st = tonumber(RaidControl:get():getCustomValue("hideTimer2"));
        end
        if st ~= "" and st ~= "error" and st ~= nil then
            if st > self.hideTimer then
                self.hideTimer = st;
            end
        else
            self.hideTimer = 0;
        end
    end
end

function instance:sendMessage(killCount)
    if RaidControl:get() ~= nil then
        local temp = string.format(self.messages.mess4,self.killCountLocal);
        local playerName = BattleControl:get():getPlayerName();
        local messageStr = playerName..temp;
        local byteCode = self:toByteCode(messageStr);
        RaidControl:get():setCustomValue("message",byteCode..","..LuaUtilities.rand(0,100000));
    end
end

function instance:fetchMessage()
    if RaidControl:get() ~= nil then
        local st = RaidControl:get():getCustomValue("message");
        if st ~= "" and st ~= "error" and st ~= nil then
            
            self.currentMessageID = string.match(st,",(%d+)");
            st = string.gsub(st,","..self.currentMessageID,"");
            return st;
        else
            return nil;
        end
    end
end

function instance:toByteCode(str)
    local i = 1;
    local result = "";
    for i=1, string.len(str) do
     result = result.." "..str:byte(i);
    end
    return result;
end

function instance:toUnicode(str)
    local result = "";
    for i in str:gmatch("%d+") do

        local code = tonumber(i);
        local tmp = str.char(code);
        result = result..tmp;
    end
    return result;
end



--============================================================================================================

instance:publish();

return instance;