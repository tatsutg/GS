local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトルEP6_エリアボス_銀のヴァルザンデス", version=2.5, id="gb_605601"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50 },
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
    },
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    --ATTACK4 = 4,
    SKILL1 = 4,
    SKILL2 = 5,
}

class.cutInSkill = {
    [1] = 1,
    [2] = 1,
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---グランドバトル共有
    self.GB_BUFF_BOX = {
        [1] = {
            ID = 6000100,
            BUFF_ID = 17,   -- 与ダメージ上昇
            VALUE = self.GD.buffVal_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        }
    }
    ---ボスギミック
    self.BUFF_BOX_LIST = {
    }
    self.STUN_BOX_LIST = {
        [1] = {
            ID = 9010699,
            BUFF_ID = 89,   --気絶
            VALUE = 100,
            DURATION = self.GD.exGageBrokenbuffTime_89,
            ICON = 79,
        },
    }
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "一定時間経過するたびに割合ダメージ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "毒で遅延・ブレイク、麻痺で停止", COLOR = Color.yellow}),
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "与ダメージアップ", COLOR = Color.red})
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "シャドウライトニング・改：クリティカル率アップ", COLOR = Color.red})
    }
    self.EX_GAUGE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_MESSAGE1 or "力を溜めている……", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_MESSAGE2 or "一定ダメージ・ブレイクで解除", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_MESSAGE3 or "炎・水・樹属性ユニットからの被ダメージアップ", COLOR = Color.red}),
    }
    self.EX_GAUGE_BROKEN_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_BROKEN_MESSAGE1 or "力溜め解除成功！", COLOR = Color.white}),
    }
    self.TG_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TG_MESSAGE1 or "最大HP%d％の割合ダメージ", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp60(status) end,
            HP = 60,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false,
            isEnableSkip = false
        }
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255)
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist")
            end
        end
    end
end

function class:hp60(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 2;
            self.saveBP = self.gameUnit:getBurstPoint();
            --self.gameUnit:addSP(100)
        end
        --self.gameUnit:setInvincibleTime(10);
        self:buffRefreshAll(self.gameUnit);
        -- チャージ状態
        self:chargeStart(self.gameUnit, 1)
    end
end

function class:hp30(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 2;
            self.saveBP = self.gameUnit:getBurstPoint();
            --self.gameUnit:addSP(100)
        end
        --self.gameUnit:setInvincibleTime(10);
        self:buffRefreshAll(self.gameUnit);
        if self.isChargingState == 0 then
            -- チャージ状態
            self:chargeStart(self.gameUnit, 2)
        end
    end
end

function class:chargeStart(unit, state)
    self.hpSkill = 2
    self.gameUnit:setUnitState(3)
    self.isChargingState = 1
    self.afterSkillFLG = true
    self.gameUnit:takeAnimation(0,"charge_loop",true);
    self.gameUnit:takeAnimationEffect(0,"charge_short",true);

    self.gameUnit:setBurstPoint(0);

    ---サブバー表示
    self.subBarFlg = true;
    self.damage = 0;
    if state == 1 then
        self.SUB_HP = unit:getCalcHPMAX() * (self.GD.hp60subBarHPBaseRate);
    else
        self.SUB_HP = unit:getCalcHPMAX() * (self.GD.hp30subBarHPBaseRate + (self.gbAreaNumber * self.GD.hp30subBarHPRate));
    end
    --self.SUB_HP = (unit:getCalcHPMAX() * (self.GD.subBarHPBaseRate + (self.subBarCount * self.GD.subBarHPRate))) /100;
    --self.SUB_HP = 100000
    self:showMessage(self.EX_GAUGE_MESSAGE_LIST);

end

function class:buffRefreshAll(unit)
    self.buffIDList = {89,90,91,92,93,94,95,97,129,131,135}
    local badStatusIDs = self.buffIDList;
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1
            if count > 100 then
                break
            end
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 30,
        startAddSP = 0,
        attackDelay = 7,
        hitStop = 100,
        timeLimit = 180,
        deBuffTimeSpeed = 0.4,
        tgNum1 = 55,
        tgNum2 = 20,
        tgNum3 = 0.01,
        tgNum4 = 2,
        tgNum5 = 27,
        tgTimer = 25,
        tgLimit = 99,
        tgIconNum1 = 211,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        buffVal_17 = 10,
        hp60subBarHPBaseRate = 0.4,
        hp30subBarHPBaseRate = 0.7,
        hp30subBarHPRate = 0.003,
        exGageBossTakeDamageValue = 0.05,
        exGageElementTakeDamageValue = 2.5,
        exGageBrokenbuffTime_89 = 2,
        chargeSec = 1.3,
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;

    ---グランドバトル
    self.gbAreaNumber = megast.Battle:getInstance():getCurrentGrandBattleFloor();

    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;
    self.cutInFLG = false;

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"
    self.breakSkip = true
    self.hpSkill = 0
    self.saveBP = 0

    -- チャージギミック
    self.isChargingState = 0
    self.chargeCnt = 0

    ---グランドバトル
    ---EP6共通ギミック
    -- 経過時間ギミック
    self.breakFlg = false;
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)

    ---バトルタイム
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.GD.timeLimit ,30, 620 , -100 ,0.8);

    ---サブHP表示用
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.subBarFlg = false;
    self.subBarCount = 0;
    self.damage = 0; ---サブバー表示時のダメージ
    self.SUB_HP = 0;

    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効

    -- 経過時間ギミック
    self:extraTimerOperation(event.unit)

    ---サブバー表示
    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);
    end

    if self.isChargingState == 1 then
        self:charge(event.deltaTime)---チャージ
    end

    ---バトルタイム
    self:countDown()
    return 1
end

-- 経過時間ギミック
function class:extraTimerOperation(unit)
    local flg = "";
    local nowSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);

    -- デバフ状態かどうか
    local cond1 = unit:getTeamUnitCondition():findConditionWithType(90);  --毒
    local cond2 = unit:getTeamUnitCondition():findConditionWithType(91);  --麻痺
    if cond1 ~= nil and cond2 ~= nil then  --両方ある場合
        flg = "stop";
    elseif cond1 == nil and cond2 == nil and nowSpeed ~= 1 then  --両方ない場合
        flg = "changeOff";
    elseif cond2 ~= nil and (nowSpeed == 1 or nowSpeed == self.GD.deBuffTimeSpeed) then --麻痺状態
        flg = "stop";
    elseif cond1 ~= nil and nowSpeed == 1 then --毒状態
        flg = "changeOn";
    elseif cond2 == nil and nowSpeed == 0 then --麻痺状態でない場合
        flg = "changeOff";
    elseif cond1 == nil and nowSpeed == self.GD.deBuffTimeSpeed then --毒状態でない場合
        flg = "changeOff";
    end

    -- ブレイク中は止める
    if unit:isBreak() and self.breakFlg then
        flg = "stop";
    elseif not unit:isBreak() and self.breakFlg then
        self.breakFlg = false;
        flg = "changeOff";
    end

    if flg == "stop" then
        self:extraTimer("stop" ,self.timeIndex);
    elseif flg == "changeOn" then
        self:extraTimer("change" ,self.timeIndex ,self.timeSpeed ,self.GD.deBuffTimeSpeed);
    elseif flg == "changeOff" then
        self:extraTimer("change" ,self.timeIndex ,self.timeSpeed ,1);
    end
end

---サブHP表示
function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage)/self.SUB_HP);
    ---ゲージ0になった場合非表示
    if self.SUB_HP - damage <= 0 then
        self.hpSkill = 0
        self.isChargingState = 0
        self.subBar:setVisible(false);
        self.subBarFlg = false
        self.damage = 0
        self.gameUnit:setBurstPoint(0)
        self.saveBP = 0
        self:showMessage(self.EX_GAUGE_BROKEN_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.STUN_BOX_LIST[1])
    end
end

---チャージ中のカウント
function class:charge(deltaTime)
    self.chargeCnt = self.chargeCnt + deltaTime
    if self.chargeCnt > self.GD.chargeSec then
        self.chargeCnt = 0
        self.gameUnit:addSP(20)
    end
    --[[
    ---サブHPが時間内に0にならなかった場合の処理
    if self.count10 < 0 then
        self.SUB_HP = 0
        self.damage = 0
    end
    ]]
end

function class:countDown()
    if BattleControl:get():getTime() > self.GD.timeLimit then
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                myTeamUnit:setHP(0)
                myTeam:deadUnit(myTeamUnit:getIndex());
            end
        end
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    self:takeHpDamage(self.gbAreaNumber);
    return event.count
end

function class:takeHpDamage(areaNum)
    local value = math.floor(self.GD.tgNum1 * math.atan((areaNum - self.GD.tgNum2) * self.GD.tgNum3) * self.GD.tgNum4 / math.pi + self.GD.tgNum5);
    local rate = value * 0.01;
    --summoner.Utility.messageByEnemy(rate)
    self:showFormatMessage(self.TG_MESSAGE_LIST[1],value)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local damage = myTeamUnit:getCalcHPMAX() * rate;
            myTeamUnit:setHP(myTeamUnit:getHP() - damage);
        end
    end
end

--extraTimer操作系
function class:extraTimer(str,timeIndex,timeSpeed,changeSpeed,buffIcon,skillIndex)
    if str == "start" then
        --setExtraTimerSpeed(int index,float speed);
        megast.Battle:getInstance():setExtraTimerSpeed(timeIndex ,timeSpeed);
    elseif str == "change" then
        megast.Battle:getInstance():setExtraTimerSpeed(timeIndex ,timeSpeed * changeSpeed);
    elseif str == "stop" then
        megast.Battle:getInstance():setExtraTimerSpeed(timeIndex ,0);
    elseif str == "reset" then
        --setExtraTimerSpeed(int index,float speed);
        megast.Battle:getInstance():setExtraTimerPercentage(timeIndex ,0);
    elseif str == "delete" then
        --removeExtraTimer(int index,float fadeTime,float delayTime,bool isAnimation);
        megast.Battle:getInstance():removeExtraTimer(timeIndex ,1 ,1 ,true);
    elseif str == "iconChange" then
        --setExtraTimerBuffIcon(int index,int iconNumber,int iconNumber2);
        megast.Battle:getInstance():setExtraTimerBuffIcon(timeIndex ,buffIcon ,0);
    elseif str == "setSkill" then
        --setExtraTimerBattleSkill(int index,int skillIndex);
        megast.Battle:getInstance():setExtraTimerBattleSkill(timeIndex ,skillIndex);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    return 1;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackReroll(event.unit);
    end

    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if self.isChargingState == 2 then
        self.isChargingState = 0
        self.subBar:setVisible(false);
        self.subBarFlg = false
        self.damage = 0
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    end

    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function class:addSP(unit)
    if self.isChargingState == 1 then
        return 1
    end
    unit:addSP(self.spValue);
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if event.index == 1 then
        self:execAddBuff(event.unit,self.GB_BUFF_BOX[1])
        self:showMessage(self.SKILL_MESSAGE_LIST);
    end

    if event.index == 2 then
        if self.isChargingState == 1 then
            self.isChargingState = 2
            event.unit:setInvincibleTime(10)
        end
        self:execAddBuff(event.unit,self.GB_BUFF_BOX[1])
        self:showMessage(self.SKILL_MESSAGE_LIST);
        self:showMessage(self.SKILL2_MESSAGE_LIST);
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill
        self.hpSkill = 0
    else
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end

    if self.cutInSkill[skillIndex] ~= nil then
        unit:takeSkillWithCutin(tonumber(skillIndex),self.cutInSkill[skillIndex]);
    else
        unit:takeSkill(tonumber(skillIndex));
    end

    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

function class:takeSkillFromHost(unit,index)
    self.fromHost = true;
    if self.cutInSkill[index] ~= nil then
        unit:takeSkillWithCutin(index,self.cutInSkill[index]);
    else
        unit:takeSkill(index);
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    return event.value
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    return event.value
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)

    ---サブバー表示時
    if self.subBarFlg then
        local exDamage = event.value;
        -- 相応の属性ユニットのとき被ダメージアップ
        local etype = event.enemy:getElementType();
        if etype == kElementType_Fire or etype == kElementType_Aqua or etype == kElementType_Earth then
            exDamage = exDamage * self.GD.exGageElementTakeDamageValue
        end
        self.damage = self.damage + exDamage;
        --summoner.Utility.messageByEnemy("EXHP : " .. math.floor(self.SUB_HP - self.damage))

        event.value = event.value * self.GD.exGageBossTakeDamageValue
    end

    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit) ---停止系状態異常除去(このタイミングでないとたまにバグる)
        return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value)
        end
    end
    return value
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true
    return unit:getHP() - border + 1
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
end

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end
    --オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
    return event.value
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end
    self.breakFlg = true;

    if self.subBarFlg then
        self.SUB_HP = 0
    end

    return 1
end

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.afterSkillFLG then
        self.gameUnit:setInvincibleTime(0)
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList)
        return
    end
    self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox)
    end
end

function class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i])
    end
end

function class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

function class:showFormatMessage(messageBox,str)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
    end
end

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:hpTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            if not trigger.isEnableSkip then
                ---通常マーカーはブレイク中は発動しない
                if not unit:isBreak() then
                    self:execTrigger(index)
                end
            else
                ---ブレイクスルー
                self:execTrigger(index)
            end
        end
    end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3
    local action = "use" .. receiveNumber
    self.TRIGGERS[index].used = true

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP],true)
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index)
        return;
    end

    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

    self.TRIGGERS[index].action(action)
    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive3(トリガー時ゲスト側)
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    return 1
end

---------------------------------------------------------------------------------
-- receive5(トリガースキップ時ゲスト側)
---------------------------------------------------------------------------------
function class:receive5(args)
    self.TRIGGERS[args.arg].used = true
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP],true)
    end
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > buffBox.MAX then
                count = buffBox.MAX
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
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

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end
end

function class:movePatternState(SET_LIST,stateBox)
    stateBox.actCount = stateBox.actCount + 1
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1
        stateBox.setCount = stateBox.setCount + 1
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1
        end
        stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount])
    end
end

class.STATE_ATTACK = {}
function class:initAttackWeight(...)
    --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
    local attackList = {...}
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    return tonumber(attackIndex)
end

class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    return tonumber(skillIndex)
end

function class:initState(weightList)
    local state = {}
    state.SET_WEIGHT = weightList
    state.actCount = 1
    state.setCount = 1
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount])
    return state
end

---トリガー時状態異常除去---
function class:refresh(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1
            if count > 100 then
                break
            end
        end
    end
end

function class:buffRefresh(unit,buffID)
    local badStatusIDs = {buffID};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithID(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1
            if count > 100 then
                break
            end
        end
    end
end

class:publish();

return class;