local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="転スラコラボ跳兎祭前半_刀神ルアン(真EX・極)", version=2.7, id=2078690});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK3 = 50},
    },
    RAGE = {
        { ATTACK2 = 50 },
        { ATTACK6 = 50 },
        { ATTACK1 = 50 },
        { ATTACK4 = 50 },
        { ATTACK1 = 50, ATTACK6 = 50},
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 },
    },
    RAGE = {
        { SKILL3 = 100 },
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL2 = 5,
    ATTACK6 = 6,
    SKILL3 = 7,
    SKILL5 = 8,
}

class.cutInSkill = {
    [2] = 0,
    [3] = 1,
    [5] = 4
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 207869001,
            BUFF_ID = 0, -- 出血(Icon表示用)
            VALUE = 0,
            DURATION = 999999,
            ICON = 207,
            COUNT = 0,
            MAX = self.GD.bloodCountMax
        },
        [2] = {
            ID = 207869002,
            BUFF_ID = 17, -- クリティカルダメージ
            VALUE = self.GD.hp80BuffValue_17,
            DURATION = 999999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 22
            }
        },
        [3] = {
            ID = 207869003,
            BUFF_ID = 0, -- 物理耐性(Icon表示用)
            VALUE = 0,
            DURATION = 999999,
            ICON = 21,
        },
        [4] = {
            ID = 207869004,
            BUFF_ID = 31, -- 回避率
            VALUE = self.GD.hp20BuffValue_31,
            DURATION = 999999,
            ICON = 16,
        },
        [5] = {
            ID = 207869005,
            BUFF_ID = 0, -- 天之揺々祇顕現状態(Icon表示用)
            VALUE = 0,
            DURATION = 999999,
            ICON = 7,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        },
        [6] = {
            ID = 207869006,
            BUFF_ID = 22, -- 天之揺々祇顕現状態(クリティカル率)
            VALUE = self.GD.rageBuffValue_22,
            DURATION = 999999,
            ICON = 11,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "僕がやろう", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "一定ダメージで白玄龍 天之揺々祇　顕現", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "クリティカルダメージで顕現速度アップ", COLOR = Color.yellow}),
    }
    self.HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE1 or "いくよ、ユララギ", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE2 or "クリティカルダメージアップ", COLOR = Color.yellow}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "舞い踊れ――", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "物理耐性アップ", COLOR = Color.yellow}),
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "白玄龍よ、吠え叫べ", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE2 or "回避率アップ", COLOR = Color.yellow}),
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "天之揺々祇よ、地を這い、天を翔けよ", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE2 or "%sに%dの固定ダメージ！", COLOR = Color.red, isPlayer = true}),
    }
    self.RAGE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.RAGE_MESSAGE1 or "天之揺々祇 顕現！：一定時間、またはブレイクで解除", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.RAGE_MESSAGE2 or "行動パターン変化・行動速度アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.RAGE_MESSAGE3 or "CRIダメージ無効・クリティカル率大幅アップ", COLOR = Color.red}),
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "奥義ゲージ自然減少", COLOR = Color.red, isPlayer = true}),
    }
    self.SKILL6_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL6_MESSAGE1 or "累計ダメージの多いユニットに出血", COLOR = Color.red}),
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "やる…ね……！", COLOR = Color.magenta})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp80(status) end,
            HP = 80,
            used = false,
            isEnableSkip = true
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp20(status) end,
            HP = 20,
            used = false,
            isEnableSkip = false
        },
        [4] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
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

function class:hp80(status)
    if status == "use3" then
        --self.hpSkill = 2
        --self.saveBP = self.gameUnit:getBurstPoint()
        --self.gameUnit:addSP(100)
        --self:refresh(self.gameUnit)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
        self:showMessage(self.HP80_MESSAGE_LIST)
    end
end

function class:hp50(status)
    if status == "use3" then
        self.hpSkill = 2
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(10)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end

function class:hp20(status)
    if status == "use3" then
        self.hpSkill = 3
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(10)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
        self:showMessage(self.HP20_MESSAGE_LIST)
    end
end

function class:hp0(status)
    if status == "use3" then
        self.hpSkill = 5
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(10)
        self:showMessage(self.HP0_MESSAGE_LIST, 1)
        self:bloodBuffCountDamage()
    end
end

-- 出血カウントに応じた固定ダメージ
function class:bloodBuffCountDamage()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID)
            if buff ~= nil then
                local count = buff:getNumber()
                local num = myTeamUnit:getHP() - self.GD.bloodCountDamage * count
                if num <= 0 then
                    myTeamUnit:setHP(0)
                else
                    myTeamUnit:setHP(num)
                end
                self:showFormatMessage(self.HP0_MESSAGE_LIST[2],myTeamUnit:getUnitName(),self.GD.bloodCountDamage * count)
            end
        end
    end
end

function class:showFormatMessage(messageBox,unitName,damageNum)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(string.format(messageBox.MESSAGE,damageNum,unitName),messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(string.format(messageBox.MESSAGE,damageNum,unitName),messageBox.DURATION,messageBox.COLOR);
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        attackDelay = 7,
        hitStop = 100,
        startAddSP = 0,
        firstBloodCount = 2,
        secondBloodCount = 1,
        bloodCountMax = 10,
        bloodCountDamage = 1000,
        hp80BuffValue_17 = 30,
        hp50TakeDamageValue = 0.5,
        hp20BuffValue_31 = 50,
        rageBuffValue_22 = 100,
        rageAttackDelay = 3,
        rageAddSP = 40,
        subHPPercent = 70,
        subHPCriTakeDamageValue = 2,
        tgTimer = 30,
        tgLimit = 1,
        tgIconNum1 = 0,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
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

    --HP0ギミック
    self.lastSkillFLG = false
    self.deadFlg = false

    --累計ダメージ格納用
    self.targetUnitList = {}
    self.targetUnit1 = nil
    self.targetUnit2 = nil

    ---サブHP表示用
    self.subBar = BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    --self.subBar:setBarColor(self.GD.subBarColorR, self.GD.subBarColorG, self.GD.subBarColorB);
    self.SUB_HP = event.unit:getHP() * (self.GD.subHPPercent / 100)
    self.damage = 0---サブバー表示時のダメージ
    self.subBarFlg = false

    -- 天之揺々祇顕現状態用
    self.rageState = 0
    -- 経過時間ギミック
    self.timeIndex = nil;
    self.timeSpeeddefault = nil
    self.timeSpeed = 0

    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self.subBarFlg = true
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end

    --経過時間ギミック
    self:timeGimmick(event.unit)

    --EXゲージギミック
    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);---サブバー表示
    end

    -- 天之揺々祇顕現状態用
    if self.rageState == 1 then
        if event.unit:getUnitState() ~= kUnitState_skill and event.unit:getUnitState() ~= kUnitState_attack then
            if not event.unit:isBreak() then
                self.rageState = 2
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[5])
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[6])
                self.gameUnit:setAttackDelay(self.GD.rageAttackDelay);---アタックディレイ
                self.spValue = self.GD.rageAddSP;---addSPの量
                self:initAttackWeight({RAGE = 100})
                self:initSkillWeight({RAGE = 100})

                self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit, self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
                self.timeSpeeddefault = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
                self.timeSpeed = self.timeSpeeddefault

                self:showMessage(self.RAGE_MESSAGE_LIST)

            end
        end
    end

    ---死亡時処理
    if megast.Battle:getInstance():isHost() then
        if megast.Battle:getInstance():getBattleState() == kBattleState_active then
            if self.lastSkillFLG == nil then self.lastSkillFLG = false end
            if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
                self.deadFlg = true
                event.unit:setHP(0)
                --event.unit:getTeam():deadUnit(event.unit:getIndex());
                --megast.Battle:getInstance():waveEnd(true);
            end
            if self.TRIGGERS[4].used then
                if self.deadCount == nil then self.deadCount = 0 end
                self.deadCount = self.deadCount + event.deltaTime
                if self.deadCount >= 10 then
                    self.deadFlg = true
                    event.unit:setHP(0)
                    --event.unit:getTeam():deadUnit(event.unit:getIndex());
                    --megast.Battle:getInstance():waveEnd(true);
                end
            end
        end
    end

    return 1
end

function class:timeGimmick(unit)
    if self.timeIndex ~= nil then

        local FLG = 0

        -- 燃焼、毒、病気、暗闇、麻痺の時、タイマーの速度を2.5倍
        --if dbuff > 0 then
        --    FLG = 1
        --end

        -- ブレイク中か無敵中は停止
        --if unit:isBreak() or unit:getInvincibleTime() > 0 then
        --    FLG = 2
        --end

        --if FLG == 2 then
        --    self.timeSpeed = 0
        --elseif FLG == 1 then
        --    self.timeSpeed = self.timeSpeeddefault * self.GD.tgFastSpeed
        --else
        --    self.timeSpeed = self.timeSpeeddefault
        --end

        -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= self.timeSpeed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , self.timeSpeed)
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
        end

    end
end

---サブHP表示
function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定(通常とは逆でゲージを増やしてしく方式)
    self.subBar:setPercent(100 * damage / self.SUB_HP);
    ---ゲージ100%になった場合の処理
    if damage >= self.SUB_HP then
        if megast.Battle:getInstance():isHost() then
            self.subBarFlg = false
            self.subBar:setVisible(false);
            self.damage = 0
            self.rageState = 1
            megast.Battle:getInstance():sendEventToLua(self.scriptID,7,0);
        end
    end
end

function class:receive7(args)
    self.subBarFlg = false
    self.subBar:setVisible(false);
    self.damage = 0
    self.rageState = 1
    return 1
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    self:rageClear()
    return event.count
end

function class:rageClear()
    if self.rageState == 2 then
        self.rageState = 0
        self.gameUnit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
        self.spValue = self.GD.addSP;---addSPの量
        self:initAttackWeight({DEFAULT = 100})
        self:initSkillWeight({DEFAULT = 100})

        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[5].ID)
        if cond ~= nil then
            self.gameUnit:getTeamUnitCondition():removeCondition(cond);
        end
        local cond2 = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[6].ID)
        if cond2 ~= nil then
            self.gameUnit:getTeamUnitCondition():removeCondition(cond2);
        end

        if self.timeIndex ~= nil then
            megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
            self.timeIndex = nil
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    --if event.unit:getUnitState() ~= kUnitState_skill then
    --    if self.addSpSkipFLG then
    --        self.gameUnit:setInvincibleTime(0)
    --    end
    --end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if not self.deadFlg then
        return 0
    end
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
        self.timeIndex = nil
    end
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
        self.timeIndex = nil
    end
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

    if event.index == 2 then
        self:showMessage(self.SKILL2_MESSAGE_LIST)
        event.unit:setNextAnimationName("attack1")
        event.unit:setNextAnimationEffectName("2-attack1") ---EFのアニメーション名に気をつける
    end

    if event.index == 3 or event.index == 4 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("2-skill1") ---EFのアニメーション名に気をつける
    end

    if event.index == 6 then
        -- 出血付与
        if megast.Battle:getInstance():isHost() then
            local sendindex = 0
            self:checkTargetUnit()
            sendindex = self:addBloodBuff()
            megast.Battle:getInstance():sendEventToLua(self.scriptID,6,sendindex)
            --local tst = (self.targetUnit1:getIndex() + 1) * 10 + self.targetUnit2:getIndex()
            --summoner.Utility.messageByEnemy(tst.. " " .. Unit1 .. " " .. Unit2)
        end
        self:showMessage(self.SKILL6_MESSAGE_LIST)
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("2-skill2") ---EFのアニメーション名に気をつける
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

    if event.index == 5 then
        self.gameUnit:setInvincibleTime(10)
        self.lastSkillFLG = true
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

function class:addBloodBuff()
    local rtn = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if i == self.targetUnit1:getIndex() then
                for i = 1,self.GD.firstBloodCount do
                    self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[1])
                end
            elseif i == self.targetUnit2:getIndex() then
                for i = 1,self.GD.secondBloodCount do
                    self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[1])
                end
            end
        end
    end

    -- マルチ同期用のindex値設定
    rtn = (self.targetUnit1:getIndex() + 1) * 10
    if self.targetUnit2 ~= nil then
        rtn = rtn + self.targetUnit2:getIndex()
    else
        -- ２人目のユニットが存在しない場合のsend値
        rtn = rtn + 9
    end
    return rtn
end

function class:receive6(args)
    local Unit1 = math.floor(args.arg / 10 - 1)
    local Unit2 = args.arg % 10
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if i == Unit1 then
                self.targetUnit1 = myTeamUnit
                for i = 1,self.GD.firstBloodCount do
                    self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[1])
                end
            elseif i == Unit2 then
                self.targetUnit2 = myTeamUnit
                for i = 1,self.GD.secondBloodCount do
                    self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[1])
                end
            end
        end
    end
    return 1
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

    local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[3].ID)
    if buff ~= nil then
        --物理ダメージ補正
        local attackType = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attackType == 1 then
            event.value = event.value * self.GD.hp50TakeDamageValue
        end
    end

    if self.subBarFlg then
        --クリティカルダメージ補正
        local critical = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().critical;
        if critical then
            self.damage = self.damage + (event.value * self.GD.subHPCriTakeDamageValue)
        else
            self.damage = self.damage + (event.value)
        end
        --確認用info
        --summoner.Utility.messageByEnemy(math.floor(self.damage) .. " / " .. self.SUB_HP);
    end

    -- 天之揺々祇顕現状態時
    if self.rageState == 2 then
        --クリティカルダメージ補正
        local critical = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().critical;
        if critical then
            event.value = 0
        end
    end

    event.value = self:adjustHpFlg(event.unit,event.value)

    -- 天之揺々祇顕現状態時
    if self.rageState == 2 then
        -- 累計ダメージ格納
        local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
        if self.targetUnitList[index] == nil then
            table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value})
        else
            self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value
        end
    end

    return event.value
end

-- 与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil
    local target2 = nil
    local targetTeam = megast.Battle:getInstance():getTeam(true)
    --for i = 0,6 do
    --    local myTeamUnit = targetTeam:getTeamUnit(i)
    --    if myTeamUnit ~= nil then
    --        target = myTeamUnit
    --        break;
    --    end
    --end
    local val = 0
    for i,v in pairs(self.targetUnitList) do
        if v.unit == nil or v.unit:getHP() < 1 then
            v.dps = 0
        end
        -- 一番右のユニットが２番目のターゲットにならない対処
        if target2 == nil and target ~= nil and v.dps > 0 then
            target2 = v.unit
        end
        if v.dps > val then
            val = v.dps
            -- 二番目のユニット情報を入れる
            if target ~= nil then
                target2 = target
            end
            target = v.unit
        end
    end

    --ターゲットを取得できなかった場合(一番左のユニットから順に格納する)
    if target == nil then
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if target == nil then
                    target = myTeamUnit
                else
                    target2 = myTeamUnit
                    break;
                end
            end
        end
    end

    --２番目のターゲットを取得できなかった場合(１番目のターゲットを除外して一番左のユニットから順に格納する)
    if target2 == nil then
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if target ~= myTeamUnit then
                    target2 = myTeamUnit
                    break;
                end
            end
        end
    end

    self.targetUnit1 = target
    self.targetUnit2 = target2
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

    self:rageClear()

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