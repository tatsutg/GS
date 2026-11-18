local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="MSH5_エチカ(真EX)", version=2.5, id=2075480});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
    },
    HP60 = {
        { ATTACK2 = 50 },
        { ATTACK3 = 50 },
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 },
        { SKILL3 = 100 },
    },
    HP60 = {
        { SKILL3 = 100 },
        { SKILL5 = 100 },
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL2 = 4,
    SKILL3 = 5,
    SKILL5 = 6,
    SKILL6 = 7,
}

class.cutInSkill = {
    [6] = 1,
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 2075848001,
            BUFF_ID = 17, --与ダメージダウン
            VALUE = self.GD.tgBuffValue_17,
            DURATION = 999999,
            ICON = 27,
            COUNT = 0,
            MAX = 99,
        },
    }
    self.TARGET_BUFF_LIST11 = {
        ID = 05,
        BUFF_ID = 129,---継続ダメージ
        VALUE = self.GD.targetBuffValue_129 * 2,
        DURATION = 999999,
        ICON = 180
    }
    self.TARGET_BUFF_LIST10 = {
        ID = 05,
        BUFF_ID = 129,---継続ダメージ
        VALUE = self.GD.targetBuffValue_129,
        DURATION = 999999,
        ICON = 180
    }
    self.TARGET_BUFF_LIST21 = {
        ID = 06,
        BUFF_ID = 129,---継続ダメージ
        VALUE = self.GD.targetBuffValue_129 * 2,
        DURATION = 999999,
        ICON = 180
    }
    self.TARGET_BUFF_LIST20 = {
        ID = 06,
        BUFF_ID = 129,---継続ダメージ
        VALUE = self.GD.targetBuffValue_129,
        DURATION = 999999,
        ICON = 180
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "すべては、剣によって！", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下・物理耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "精霊族・光属性からの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "一定時間経過でパーティのダメージダウン", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "パーティのHP回復でタイマー遅延", COLOR = Color.yellow}),
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "精霊王の翼よ！", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE2 or "精霊王の翼状態", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE3 or "行動速度・奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE4 or "ダメージの一番多いユニットをターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE5 or "ターゲットした相手の継続ダメージを2倍にする", COLOR = Color.yellow}),
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "我が刃にて裁きましょう！！", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE2 or "奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
    }

    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "イヤぁあああああッ！！", COLOR = Color.yellow})
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
        },
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
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setAttackDelay(self.GD.hp60AttackDelay)
        self.spValue = self.GD.hp60AddSP
        self:initAttackWeight({HP60 = 100})
        self:initSkillWeight({HP60 = 100})
        self:refresh(self.gameUnit)
        self:showMessage(self.HP60_MESSAGE_LIST)
        self.targetGimmickState = 1
    end
end

function class:hp30(status)
    if status == "use3" then
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.spValue = self.GD.hp30AddSP;
        self:refresh(self.gameUnit)
        self:showMessage(self.HP30_MESSAGE_LIST)
        self.targetGimmickState = 2
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        startAddSP = 0,
        attackDelay = 6,
        hp60AttackDelay = 3,
        hp60AddSP = 25,
        hp30AddSP = 35,
        hitStop = 100,
        tgTimer = 20,
        tgLimit = 99,
        tgIconNum1 = 27,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        tgSlowSpeed = 3,
        tgslowTime = 5,
        tgBuffValue_17 = -30,
        targetBuffValue_129 = 200,
        magicTakeDamageValue = 0.5,
        skill7orbitOnTime = 7,
        skill7DamageRateOffset = 500,
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.hpMarkers = {}
    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false
    self.hpSkill = 0
    self.saveBP = 0

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnit = nil
    self.targetUnitList = {}
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    self.hateResetFlg = false
    self.targetGimmickState = 0

    -- 経過時間ギミック
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit, self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeeddefault = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
    self.timeSpeed = self.timeSpeeddefault

    self.tmpHP = {0,0,0,0}
    self.slowTime = 0
    self.healFlg = false

    -- エチカ翼ギミック
    self.wingMode = false;
    self.wing = nil;
    self.orbitOff = false;
    self.orbitOnTime = self.GD.skill7orbitOnTime;
    self.orbitCountTime = 0;
    self.orbitDamage = 100;
    self.skill5Damage = self.GD.skill7DamageRateOffset;
    self.skill5Flg = false

    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self.tmpHP[i+1] = myTeamUnit:getHP()
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    self:HPTriggersCheck(event.unit)

    --経過時間ギミック
    self:timeGimmick(event.unit, event.deltaTime)

    ---時間経過でオービットを出す
    if self.wingMode then
        if not self.orbitOff and megast.Battle:getInstance():getBattleState() == kBattleState_active then
            --オービット処理
            --停止系状態異常バフ監視
            local buffFlg = self:findBuff(event.unit);
            if not buffFlg then
                self:setWing(event.unit,event.deltaTime);
                self:wingSetPosition(event.unit);
            elseif buffFlg and self.wing ~= nil then
                self.wing:takeAnimation(0,"empty",false);
                self.wing = nil;
            end
        end
        --奥義中か確認
        if self.orbitOff and event.unit:getUnitState() ~= kUnitState_skill then
            self.orbitOff = false;
        end
    end
    ---モード切り替えできなかった場合の補助
    --超奥義中か確認
    if self.skill5Flg and event.unit:getUnitState() ~= kUnitState_skill then
        self.skill5Flg = false;
        if not self.wingMode then
            self.wingMode = true;
            self.setTimerFlg = true;
            self.orbitCountTime = 0;
            event.unit:setSetupAnimationName("idle2");
        end
    end

    return 1
end

function class:timeGimmick(unit, deltaTime)
    if self.timeIndex ~= nil then

        local FLG = 0

        -- 前フレームと比較してHPが増えていたら遅延
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getHP() > 0 and myTeamUnit:getHP() > self.tmpHP[i+1] then
                    self.healFlg = true
                    self.slowTime = 0
                end

                self.tmpHP[i+1] = myTeamUnit:getHP()
            end
        end

        if self.healFlg then
            FLG = 1
            self.slowTime = self.slowTime + deltaTime
            if self.slowTime >= self.GD.tgslowTime then
                self.slowTime = 0
                self.healFlg = false
            end
        end

        -- ブレイク中は停止
        if unit:isBreak() then
            FLG = 2
        end

        if FLG == 2 then
            self.timeSpeed = 0
        elseif FLG == 1 then
            self.timeSpeed = self.timeSpeeddefault / self.GD.tgSlowSpeed
        else
            self.timeSpeed = self.timeSpeeddefault
        end

        -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= self.timeSpeed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , self.timeSpeed)
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
        end

    end
end

function class:setWing(unit,deltaTime)
    self.orbitCountTime = self.orbitCountTime + deltaTime;
    if self.orbitCountTime >= self.orbitOnTime then
        self.orbitCountTime = 0;
        if self.wing == nil then
            self.wing = unit:addOrbitSystem("WingbBlade2");
            self.wing:setActiveSkill(6);
            self.wing:setDamageRateOffset(self.orbitDamage/self.skill5Damage);
            self.wing:setBreakRate(0);
        end
    end
end

function class:wingSetPosition(unit)
    if self.wing == nil then
        return;
    end

    if self.wing ~= nil then
        local vec = unit:getisPlayer() and 1 or -1;
        local posX = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
        local posY = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
        self.wing:setPosition(posX,posY);
        self.wing:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY());
        self.wing:setZOrder(unit:getZOrder() + 1);
    end
end

---状態異常監視
function class:findBuff(unit)
    local buffFlg = false;
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0;
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                buffFlg = true;
                return buffFlg;
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
    return buffFlg;
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    ---ターゲットにバフ
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[1])
        end
    end
    return event.count
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "wingMode" then
        self.wingMode = true;
        self.orbitOff = true;
        self.setTimerFlg = true;
        self.orbitCountTime = 0;
        event.unit:setSetupAnimationName("idle2");
    end
    if event.spineEvent == "orbitNil" then
        if self.wing ~= nil then
            self.wing = nil;
        end
        self.wing = nil;
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0)
        end
    end
    if self.wingMode then
        event.unit:setNextAnimationName("idle2");
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeFront
---------------------------------------------------------------------------------
function class:takeFront(event)
    if self.wingMode then
        event.unit:setNextAnimationName("front2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    if self.wingMode then
        event.unit:setNextAnimationName("back2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- castItem
---------------------------------------------------------------------------------
function class:castItem(event)
    if self.wingMode then
        event.unit:setNextAnimationName("cast2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCast(event)
    if self.wingMode then
        event.unit:setNextAnimationName("cast2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
        self.timeIndex = nil
    end
    BattleControl:get():visibleHateTarget(false);
    self.gameUnit:setEnableHate(false);
    self.gameUnit:updateHateTarget();

    if self.wing ~= nil then
        self.wing = nil;
    end
    self.wing = nil;

    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
        self.timeIndex = nil
    end
    BattleControl:get():visibleHateTarget(false);
    self.gameUnit:setEnableHate(false);
    self.gameUnit:updateHateTarget();

    if self.wing ~= nil then
        self.wing = nil;
    end
    self.wing = nil;

    self:showMessage(self.DEAD_MESSAGE_LIST)
    return 1
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

    if event.index == 1 then
        if self.wingMode then
            event.unit:setNextAnimationName("attack2");
            event.unit:setNextAnimationEffectName("2-attack2");
        end
    end

    if event.index == 2 then
        if self.wingMode then
            event.unit:setNextAnimationName("skill1_2");
            event.unit:setNextAnimationEffectName("2-skill1_2");
        else
            event.unit:setNextAnimationName("skill1")
            event.unit:setNextAnimationEffectName("2-skill1") ---EFのアニメーション名に気をつける
        end
    end

    if event.index == 3 then
        if self.wingMode then
            event.unit:setNextAnimationName("skill2_2");
            event.unit:setNextAnimationEffectName("2-skill2_2");
        else
            event.unit:setNextAnimationName("skill2")
            event.unit:setNextAnimationEffectName("2-skill2") ---EFのアニメーション名に気をつける
        end
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    elseif not self.addSpSkipFLG then
        self:addSP(event.unit);
    end
    -----------------------------------
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時、movePatternState()を動かさない---
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    end
    --------------------------------------------------------------------------------------
    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:addSP(unit)
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

    --if self.cutInFLG then
    --    self.cutInFLG = false
    --    event.unit:takeSkillWithCutin(event.index,1);
    --    return 0
    --end
    if event.index == 2 then
        if self.wingMode then
            event.unit:setNextAnimationName("skill2_2");
            event.unit:setNextAnimationEffectName("2-skill2_2");
        else
            event.unit:setNextAnimationName("skill2")
            event.unit:setNextAnimationEffectName("2-skill2") ---EFのアニメーション名に気をつける
        end
    end

    if event.index == 3 then
        if self.wingMode then
            event.unit:setNextAnimationName("skill3_2");
            event.unit:setNextAnimationEffectName("2-skill3_2");
        else
            event.unit:setNextAnimationName("skill3")
            event.unit:setNextAnimationEffectName("2-skill3") ---EFのアニメーション名に気をつける
        end
    end

    if event.index == 5 then
        if self.wingMode then
            event.unit:setNextAnimationName("skill5_2");
            event.unit:setNextAnimationEffectName("2-skill5_2");
        else
            event.unit:setNextAnimationName("skill5")
            event.unit:setNextAnimationEffectName("2-skill5") ---EFのアニメーション名に気をつける
        end
    end

    if event.index == 6 then
        if self.wingMode then
            event.unit:setNextAnimationName("skill5_2");
            event.unit:setNextAnimationEffectName("2-skill5_2");
        else
            event.unit:setNextAnimationName("skill5")
            event.unit:setNextAnimationEffectName("2-skill5") ---EFのアニメーション名に気をつける
        end
        self.skill5Flg = true;
        -- ターゲットリセット
        self:targetUnitReset(event.unit)
    end

    self.skillCheckFlg = false;
    self.cutInFLG = false
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    --self:initAttackWeight({DEFAULT = 100})---奥義使用後はリセットでスキル1からスタート
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

-- ターゲットリセット
function class:targetUnitReset(unit)
    ---ホストのみ---
    if megast.Battle:getInstance():isHost() then
        ---ヘイトは全部手動で設定する
        local target = self:checkTargetUnit()
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex())---ゲストにターゲットを送る
        unit:setHateTarget(target)
        unit:updateHateTarget();
        ---ターゲットにバフ
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if i == target:getIndex() then
                    self.targetUnit = target
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST11)
                    if self.targetGimmickState >= 2 then
                        self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST21)
                    end
                else
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST10)
                    if self.targetGimmickState >= 2 then
                        self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST20)
                    end
                end
            end
        end
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

    --魔法ダメージ軽減
    local attribute = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
    if attribute == 2 then
        event.value = event.value * self.GD.magicTakeDamageValue
    end

    event.value = self:adjustHpFlg(event.unit,event.value)

    if self.targetGimmickState >= 1 then
        local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
        if self.targetUnitList[index] == nil then
            table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value})
        else
            self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value
        end
        ---ホストのみ---
        if megast.Battle:getInstance():isHost() then
            ---ヘイトは全部手動で設定する
            local target = self:checkTargetUnit()
            megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex())---ゲストにターゲットを送る
            event.unit:setHateTarget(target)
            event.unit:updateHateTarget();
            ---ターゲットにバフ
            local myTeam = megast.Battle:getInstance():getTeam(true);
            for i = 0,3 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    if i == target:getIndex() then
                        self.targetUnit = target
                        self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST11)
                        if self.targetGimmickState >= 2 then
                            self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST21)
                        end
                    else
                        self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST10)
                        if self.targetGimmickState >= 2 then
                            self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST20)
                        end
                    end
                end
            end
        end
    end

    return event.value
end

-- 与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil
    local targetTeam = megast.Battle:getInstance():getTeam(true)
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            target = myTeamUnit
            break;
        end
    end
    local val = 0
    for i,v in pairs(self.targetUnitList) do
        if v.unit == nil or v.unit:getHP() < 1 then
            v.dps = 0
        end
        if v.dps > val then
            val = v.dps
            target = v.unit
        end
    end

    --ターゲットを取得できなかった場合
    if target == nil then
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                target = myTeamUnit
                break;
            end
        end
    end

    return target
end

function class:receive6(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    ---ヘイトは全部手動で設定する
    local target = myTeam:getTeamUnit(args.arg)
    self.gameUnit:setHateTarget(target)
    self.gameUnit:updateHateTarget();
    ---ターゲットにバフ
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if args.arg == myTeamUnit:getIndex() then
                self.targetUnit = target
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST11)
                if self.targetGimmickState >= 2 then
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST21)
                end
            else
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST10)
                if self.targetGimmickState >= 2 then
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST20)
                end
            end
        end
    end
    return 1
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
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

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    if self.wingMode then
        event.unit:setNextAnimationName("damage2");
    end
    return 1;
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
    ---オービット判定
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

    if self.wingMode then
        event.unit:setNextAnimationName("damage2");
    end

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

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
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

function class:checkDbuff(unit)
    local badStatusIDs = {89,91,96};
    local rtn = false
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
        if cond ~= nil then
            rtn = true;
        end
    end
    return rtn
end

class:publish();

return class;