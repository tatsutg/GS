local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="神族の遺跡11層_Hard_真魔翼従ヴァルザンデス", version=2.6, id=2064005});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 50 },
        { SKILL1 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL1 = 4,
    SKILL2 = 5,
    SKILL3 = 6,
    SKILL4 = 7
}

class.cutInSkill = {
    [1] = 0,
    [2] = 0,
    [4] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 20640050,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 1,
            ICON = 0,
            --COUNT = 0,
            --MAX = 10
        }
    }
    self.STUN_BUFF_LIST = {
        [1] = {
            ID = 20640052,
            BUFF_ID = 89,--気絶
            VALUE = 100,
            DURATION = self.GD.buffTime_89_1,
            ICON = 79
        },
        [2] = {
            ID = 20640053,
            BUFF_ID = 89,--気絶
            VALUE = 100,
            DURATION = self.GD.bossBuffTime_89,
            ICON = 79
        }
    }
    self.TG_BUFF_LIST = {
        [1] = {
            ID = 206400510,
            BUFF_ID = 95,--呪い
            VALUE = 100,
            DURATION = 999999,
            ICON = 85
        },
        [2] = {
            ID = 206400520,
            BUFF_ID = 13,--攻撃力ダウン
            VALUE = self.GD.tgBuffVal_13,
            DURATION = 999999,
            ICON = 4,
            COUNT = 0,
            MAX = 99
        }
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 206400599,
        BUFF_ID = 0,---被クリティカル率
        VALUE = 0,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 206400599,
        BUFF_ID = 0,---被クリティカル率
        VALUE = 0,
        DURATION = 999999,
        ICON = 0
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
    return message;
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "光属性耐性・庇うキラー", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "時間経過で呪い：徐々に加速", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "時間経過で攻撃力低下：徐々に加速", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "出血で遅延：出血Lvアップで遅延大", COLOR = Color.white})
    }
    self.ATTACK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.ATTACK_MESSAGE1 or "累計ダメージの大きいユニットを気絶", COLOR = Color.red, isPlayer = true})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "破滅の咆哮：%dの固定ダメージ", COLOR = Color.yellow})
    }
    self.HP70_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE1 or "シャドウライトニングの構え：魔法ダメージで解除", COLOR = Color.yellow})
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "シャドウライトニングの構え：魔法ダメージで解除", COLOR = Color.yellow})
    }
    self.EX_GAUGE_BROKEN_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_BROKEN_MESSAGE1 or "構え解除成功！", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp70(status) end,
            HP = 70,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp20(status) end,
            HP = 20,
            used = false,
            isEnableSkip = false
        }
    }
    self.HP_TRIGGERS = {};
    self.hpMarkers = {};
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger;
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01);
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255);
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist");
            end
        end
    end
end

function class:hp70(status)
    if status == "use3" then
        self.stateName = "FURY";
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 4;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        -- self.gameUnit:setInvincibleTime(20);
        self:showMessage(self.HP70_MESSAGE_LIST);
        self.STUN_BUFF_LIST[1].DURATION = self.GD.buffTime_89_2;
        self:deBuffRefresh(self.gameUnit);
        self.gameUnit:setParameter("304_Blood","0");
        if self.isChargingState == 0 then
            self:chargeStart(self.gameUnit, 1);-- チャージ状態
        end
    end
end

function class:hp20(status)
    if status == "use3" then
        self.stateName = "FURY";
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 4;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        -- self.gameUnit:setInvincibleTime(20);
        self:showMessage(self.HP20_MESSAGE_LIST);
        self:deBuffRefresh(self.gameUnit);
        self.gameUnit:setParameter("304_Blood","0");
        if self.isChargingState == 0 then
            self:chargeStart(self.gameUnit, 2);-- チャージ状態
        end
    end
end

function class:deBuffRefresh(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0;
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
                break;
            end
        end
    end
end

function class:chargeStart(unit, state)
    self.hpSkill = 4;
    unit:setUnitState(3);
    self.isChargingState = 1;
    self.afterSkillFLG = true;
    unit:takeAnimation(0,"charge_loop",true);
    unit:takeAnimationEffect(0,"charge_short",true);
    unit:setBurstPoint(0);
    ---サブバー表示
    self.subBarFlg = true;
    self.damage = 0;
    if state == 1 then
        self.SUB_HP = unit:getCalcHPMAX() * self.GD.hp70subBarHPBaseRate;
    else
        self.SUB_HP = unit:getCalcHPMAX() * self.GD.hp20subBarHPBaseRate;
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 30,
        startAddSP = 0,
        attackDelay = 5,
        hitStop = 100,

        tgTimer = 25,
        tgLimit = 99,
        tgIconNum1 = 85,
        tgIconNum2 = 0,
        tgPosX = -50,
        tgPosY = 0,
        tgScale = 1,
        tgStartTimer = 10,
        tgMinTimer = 10,

        tgTimerB = 35,
        tgLimitB = 99,
        tgIconNum1B = 4,
        tgIconNum2B = 0,
        tgPosXB = 50,
        tgPosYB = 0,
        tgScaleB = 1,
        tgStartTimerB = 15,
        tgMinTimerB = 10,
        tgDeBuffTaimeB_1 = 0.8,
        tgDeBuffTaimeB_2 = 0.6,
        tgDeBuffTaimeB_3 = 0.4,

        skill2FixDamege = 5000,
        skill2Damege = 1000,

        hp70subBarHPBaseRate = 0.25,
        hp20subBarHPBaseRate = 0.4,
        subBarDmgVal = 0.01,
        chargeSec = 3,
        chargeAddSP = 20,

        buffTime_89_1 = 7,
        buffTime_89_2 = 12,
        bossBuffTime_89 = 2,
        tgBuffVal_13 = -20,

        bossLevel = 1
    })
    self:dump(self.GD);

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP);---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    self.stateName = "NORMAL";
    self.breakSkip = true;
    self.hpSkill = 0;
    self.saveBP = 0;

    ---経過時間ギミック
    if self.GD.bossLevel == 1 then
        self.timerCount = 0;
        --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
        self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgStartTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
        self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
        self.timerCountB = 0;
        self.timeIndexB = megast.Battle:getInstance():createExtraTimer(self.GD.tgStartTimerB, self.GD.tgLimitB ,self.GD.tgIconNum1B, self.GD.tgIconNum2B, self.GD.tgPosXB, self.GD.tgPosYB, self.GD.tgScaleB);
        self.timeSpeedB = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexB);
    end

    ---自動ヘイトは使わない
    if self.GD.bossLevel == 1 then
        event.unit:setHateRate_Heal(0);
        event.unit:setHateRate_Damage(0);
        self.targetUnit = nil;
        self.targetUnitList = {};
        BattleControl:get():visibleHateTarget(true);
        BattleControl:get():setHateTargetIcon(14);
        event.unit:setEnableHate(true);
        event.unit:updateHateTarget();
    end

    ---サブHP表示用
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.subBarFlg = false;
    self.damage = 0; ---サブバー表示時のダメージ
    self.SUB_HP = 0;

    ---ボスギミック
    self.skill2Count = -1;
    -- チャージギミック
    self.isChargingState = 0;
    self.chargeCnt = 0;
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    if self.GD.bossLevel == 1 then
        self:extraTimerOperation(event.unit);
        self:extraTimerOperationB(event.unit);
    end

    ---サブバー表示
    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);
    end
    ---チャージ
    if self.isChargingState == 1 then
        self:charge(event.deltaTime);
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
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
        self.hpSkill = 0;
        self.isChargingState = 0;
        self.subBar:setVisible(false);
        self.subBarFlg = false;
        self.damage = 0;
        self.gameUnit:setBurstPoint(0);
        self.saveBP = 0;
        self:execAddBuff(unit,self.STUN_BUFF_LIST[2]);
        self:showMessage(self.EX_GAUGE_BROKEN_MESSAGE_LIST);
    end
end

---チャージ中のカウント
function class:charge(deltaTime)
    self.chargeCnt = self.chargeCnt + deltaTime;
    if self.chargeCnt > self.GD.chargeSec then
        self.chargeCnt = 0;
        self.gameUnit:addSP(self.GD.chargeAddSP);
    end
    --[[
    ---サブHPが時間内に0にならなかった場合の処理
    if self.count10 < 0 then
        self.SUB_HP = 0;
        self.damage = 0;
    end
    ]]
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    if event.index == self.timeIndex then
        self:addTeamBuff(self.TG_BUFF_LIST[1]);
        self.timerCount = self.timerCount + 1;
        local time = self.GD.tgTimer - self.timerCount;
        if time <= self.GD.tgMinTimer then
            time = self.GD.tgMinTimer;
        end
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex ,1 ,1 ,false);
        self.timeIndex = megast.Battle:getInstance():createExtraTimer(time, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
        self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
    elseif event.index == self.timeIndexB then
        self:addTeamBuff(self.TG_BUFF_LIST[2]);
        self.timerCountB = self.timerCountB + 1;
        local time = self.GD.tgTimerB - self.timerCountB;
        if time <= self.GD.tgMinTimerB then
            time = self.GD.tgMinTimerB;
        end
        megast.Battle:getInstance():removeExtraTimer(self.timeIndexB ,1 ,1 ,false);
        self.timeIndexB = megast.Battle:getInstance():createExtraTimer(time, self.GD.tgLimitB ,self.GD.tgIconNum1B, self.GD.tgIconNum2B, self.GD.tgPosXB, self.GD.tgPosYB, self.GD.tgScaleB);
        self.timeSpeedB = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexB);
    end
    return event.count;
end

function class:addTeamBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
        end
    end
end

function class:extraTimerOperation(unit)
    if self.timeIndex ~= nil then
        local FLG = 0;
        -- デバフ状態かどうか
        local cond1 = unit:getTeamUnitCondition():findConditionWithType(89);  --気絶
        local cond2 = unit:getTeamUnitCondition():findConditionWithType(91);  --麻痺
        local cond3 = unit:getTeamUnitCondition():findConditionWithType(96);  --氷結
        if cond1 ~= nil or cond2 ~= nil or cond3 ~= nil then
            FLG = 1;
        end

        -- ブレイク中か無敵中は停止
        if unit:isBreak() or unit:getInvincibleTime() > 0 then
            FLG = 2;
        end

        if FLG == 2 then
            self.timeSpeed = 0;
        elseif FLG == 1 then
            self.timeSpeed = 0;
        else
            self.timeSpeed = 1;
        end

        -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= self.timeSpeed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , self.timeSpeed);
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
        end
    end
end

function class:extraTimerOperationB(unit)
    if self.timeIndexB ~= nil then
        local FLG = 0;
        -- デバフ状態かどうか
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(21011);--出血専用グループID
        if cond ~= nil then
            FLG = 1;
        end

        local cond1 = unit:getTeamUnitCondition():findConditionWithType(89);  --気絶
        local cond2 = unit:getTeamUnitCondition():findConditionWithType(91);  --麻痺
        local cond3 = unit:getTeamUnitCondition():findConditionWithType(96);  --氷結
        if cond1 ~= nil or cond2 ~= nil or cond3 ~= nil then
            FLG = 2;
        end

        -- ブレイク中か無敵中は停止
        if unit:isBreak() or unit:getInvincibleTime() > 0 then
            FLG = 2;
        end

        if FLG == 2 then
            self.timeSpeedB = 0;
        elseif FLG == 1 then
            self.timeSpeedB = 1;
            local stage = "0";
            stage = unit:getParameter("304_Blood");
            if stage == "1" then
                self.timeSpeedB = self.timeSpeedB * self.GD.tgDeBuffTaimeB_1;
            elseif stage == "2" then
                self.timeSpeedB = self.timeSpeedB * self.GD.tgDeBuffTaimeB_2;
            elseif stage == "3" then
                self.timeSpeedB = self.timeSpeedB * self.GD.tgDeBuffTaimeB_3;
            end
        else
            self.timeSpeedB = 1;
        end

        -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexB) ~= self.timeSpeedB then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndexB , self.timeSpeedB);
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexB);
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then
        if self.isChargingState == 0 then
            return self:addSP(event.unit);
        end
    end
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

    if event.index == 3 then
        if self.targetUnit ~= nil then
            self:takeAttck3Buff(event.unit,self.targetUnit);
            self:showMessage(self.ATTACK_MESSAGE_LIST);
        end
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit); ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0);
        self.afterSkillFLG = false;
        event.unit:addSP(self.saveBP);
        self.saveBP = 0;
    end

    self:attackActiveSkillSetter(event.unit,event.index);
    return 1;
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex();
    if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK);
    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end

function class:takeAttck3Buff(unit,targetUnit)
    self:execAddBuff(targetUnit,self.STUN_BUFF_LIST[1]);
    --ターゲットの累計ダメージを半分にする
    local enemyUnit = self:getAncestorUnit(targetUnit);
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10);
    if self.targetUnitList[index] ~= nil then
        self.targetUnitList[index].dps = self.targetUnitList[index].dps / 2;
    end
    ---ヘイトは全部手動で設定する
    local target = self:checkTargetUnit();
    megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex());---ゲストにターゲットを送る
    unit:setHateTarget(target);
    unit:updateHateTarget();
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
        event.unit:setNextAnimationName("skill1");
        event.unit:setNextAnimationEffectName("1-skill1");
    elseif event.index == 2 then
        self.skill2Count = self.skill2Count + 1;
        self:execSlice(self.GD.skill2FixDamege,self.skill2Count);
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
    elseif event.index == 4 then
        self.isChargingState = 0;
        self.subBarFlg = false;
        self.damage = 0;
        self.subBar:setVisible(false);
        event.unit:setNextAnimationName("skill1");
        event.unit:setNextAnimationEffectName("1-skill1");
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1;
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex();
    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill;
        self.hpSkill = 0;
    else
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL);
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

function class:execSlice(fixDamege,count)
    local damage = fixDamege + self.GD.skill2Damege * count;
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            myTeamUnit:setHP(myTeamUnit:getCalcHPMAX() - damage);
        end
    end
    self:showFormatMessage(self.SKILL_MESSAGE_LIST[1],damage);
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    return event.value;
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    return event.value;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);

    if self.subBarFlg then
        --魔法ダメージ
        local attribute = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 2 then
            self.damage = self.damage + event.value;
        end
        event.value = event.value * self.GD.subBarDmgVal;
    end

    if self.GD.bossLevel == 1 then
        local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10);
        if self.targetUnitList[index] == nil then
            table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value});
        else
            self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value;
        end
        ---ホストのみ---
        if megast.Battle:getInstance():isHost() then
            ---ヘイトは全部手動で設定する
            local target = self:checkTargetUnit();
            megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex());---ゲストにターゲットを送る
            event.unit:setHateTarget(target);
            event.unit:updateHateTarget();
            ---ターゲットにバフ
            local myTeam = megast.Battle:getInstance():getTeam(true);
            for i = 0,3 do
                local myTeamUnit = myTeam:getTeamUnit(i);
                if myTeamUnit ~= nil then
                    if i == target:getIndex() then
                        self.targetUnit = target;
                        self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1);
                    else
                        self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0);
                    end
                end
            end
        end
    end

    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value;
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01;
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit); ---停止系状態異常除去(このタイミングでないとたまにバグる)
            return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value);
        end
    end
    return value;
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true;
    return unit:getHP() - border + 1;
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit;
    else
        return self:getAncestorUnit(unit:getParentTeamUnit());
    end
end

-- 与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil;
    local targetTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            target = myTeamUnit;
            break;
        end
    end
    local val = 0
    for i,v in pairs(self.targetUnitList) do
        if v.unit == nil or v.unit:getHP() < 1 then
            v.dps = 0;
        end
        if v.dps > val then
            val = v.dps;
            target = v.unit;
        end
    end

    --ターゲットを取得できなかった場合
    if target == nil then
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                target = myTeamUnit;
                break;
            end
        end
    end
    return target;
end

function class:receive6(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    ---ヘイトは全部手動で設定する
    local target = myTeam:getTeamUnit(args.arg);
    self.gameUnit:setHateTarget(target);
    self.gameUnit:updateHateTarget();
    ---ターゲットにバフ
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if args.arg == myTeamUnit:getIndex() then
                self.targetUnit = target;
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1);
            else
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0);
            end
        end
    end
    return 1;
end


----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false;
        return 0;
    end
    --オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    return event.value;
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01;
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0;
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.afterSkillFLG then
            self.gameUnit:setInvincibleTime(0);
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1;
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList);
        return
    end
    self:execShowMessage(messageBoxList[index]);
end

function class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox);
    end
end

function class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i]);
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
                    self:execTrigger(index);
                end
            else
                ---ブレイクスルー
                self:execTrigger(index);
            end
        end
    end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return;
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3;
    local action = "use" .. receiveNumber;
    self.TRIGGERS[index].used = true;

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP],true);
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index);
        return;
    end

    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP]);
    end

    self.TRIGGERS[index].action(action);
    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index);
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive3(トリガー時ゲスト側)
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true;
    self.TRIGGERS[args.arg].action("use3");
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP]);
    return 1;
end

---------------------------------------------------------------------------------
-- receive5(トリガースキップ時ゲスト側)
---------------------------------------------------------------------------------
function class:receive5(args)
    self.TRIGGERS[args.arg].used = true;
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP],true);
    end
    return 1;
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

    local oldBuff = nil;
    local count = 1;
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1;
            if count > buffBox.MAX then
                count = buffBox.MAX;
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID);
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1); end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2); end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3); end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4); end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5); end
    end

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff);
    end
end

function class:movePatternState(SET_LIST,stateBox)
    stateBox.actCount = stateBox.actCount + 1;
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1;
        stateBox.setCount = stateBox.setCount + 1;
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1;
        end
        stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount]);
    end
end

class.STATE_ATTACK = {};
function class:initAttackWeight(...)
    --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
    local attackList = {...};
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT);
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    return tonumber(attackIndex);
end

class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...};
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT);
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    return tonumber(skillIndex);
end

function class:initState(weightList)
    local state = {};
    state.SET_WEIGHT = weightList;
    state.actCount = 1;
    state.setCount = 1;
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount]);
    return state;
end

---トリガー時状態異常除去---
function class:refresh(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0;
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1;
            if count > 100 then
                break;
            end
        end
    end
end


class:publish();

return class;