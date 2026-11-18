local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ダンダダンコラボ_ジジ(真EX・極)", version=2.5, id=2072890});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50},
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 },
        { SKILL3 = 100 },
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    SKILL5 = 5,
    SKILL6 = 5
}

class.cutInSkill = {
    [5] = 1,
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 207289001,
            BUFF_ID = 21,   --物理耐性UP
            VALUE = self.GD.hp90BuffValue_21,
            DURATION = 999999,
            ICON = 21,
            SCRIPT = {
                SCRIPT_ID = 2
            }
        },
        [2] = {
            ID = 207289002,
            BUFF_ID = 23,   -- クリティカル耐性
            VALUE = self.GD.hp60BuffValue_23,
            DURATION = 999999,
            ICON = 188,
        },
        [3] = {
            ID = 207289003,
            BUFF_ID = 27, -- ブレイク耐性
            VALUE = self.GD.hp60BuffValue_27,
            DURATION = 999999,
            ICON = 9
        },
        [4] = {
            ID = 207289004,
            BUFF_ID = 17,   -- 与ダメージ
            VALUE = self.GD.skillBuffValue_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 10
        },
    }
    self.STUN_BUFF_LIST = {
        ID = 207289011,
        BUFF_ID = 89,  -- 気絶効果
        VALUE = 100,
        DURATION = 999999,
        ICON = 79
    }
    self.STUN_BUFF_LIST2 = {
        ID = 207289012,
        BUFF_ID = 89,  -- 気絶効果
        VALUE = 100,
        DURATION = self.GD.buffTime_89,
        ICON = 79
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 05,
        BUFF_ID = 23,---被クリティカル率
        VALUE = self.GD.targetBuff_23,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 05,
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
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "人間は皆殺しじゃあ", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "奥義ゲージ低下・反射耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "炎・闇属性・精霊族・魔族からの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ダメージの大きい者をターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ターゲットへのクリティカル率アップ", COLOR = Color.yellow}),
    }
    self.SKILL5_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL5_MESSAGE1 or "呪いのボール:ダメージ無効化無効", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL5_MESSAGE2 or "呪いのボール:ダメージ無効化無効・奥義ゲージ減少", COLOR = Color.red}),
    }
    self.TG_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TG_MESSAGE1 or "ターゲットを強制気絶：一定ダメージで解除", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.TG_MESSAGE2 or "一定時間を過ぎると%s死亡", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.TG_MESSAGE3 or "気絶解除成功！", COLOR = Color.white}),
    }
    self.HP90_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP90_MESSAGE1 or "地獄を見せてやるからのお", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP90_MESSAGE2 or "物理耐性アップ", COLOR = Color.yellow}),
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "もっとじゃ、もっとやろう", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE2 or "クリティカル・ブレイク耐性アップ", COLOR = Color.yellow}),
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "この恨みは、決して晴れん", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE2 or "奥義上昇量アップ", COLOR = Color.yellow}),
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "つまらぬ…このあそび、もう終わりか", COLOR = Color.magenta})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp90(status) end,
            HP = 90,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp60(status) end,
            HP = 60,
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

function class:hp90(status)
    if status == "use3" then
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        --self.timerFlg = true
        self.subBarFlg = true
        self.damage = 0
        self.SUB_HP = self.bossHP * self.subBarHpRateTbl[0]
        self:refresh(self.gameUnit)
        --self.gameUnit:setInvincibleTime(10)
        self:showMessage(self.HP90_MESSAGE_LIST,1)
    end
end

function class:hp60(status)
    if status == "use3" then
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        --self.timerFlg = true
        self.subBarFlg = true
        self.damage = 0
        self.SUB_HP = self.bossHP * self.subBarHpRateTbl[1]
        self:refresh(self.gameUnit)
        --self.gameUnit:setInvincibleTime(10)
        self:showMessage(self.HP60_MESSAGE_LIST,1)
    end
end

function class:hp20(status)
    if status == "use3" then
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        --self.timerFlg = true
        self.subBarFlg = true
        self.damage = 0
        self.SUB_HP = self.bossHP * self.subBarHpRateTbl[2]
        self.spValue = self.GD.hp20addSP
        self:refresh(self.gameUnit)
        --self.gameUnit:setInvincibleTime(10)
        --self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
        self:showMessage(self.HP20_MESSAGE_LIST,1)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 15,
        attackDelay = 7,
        hitStop = 100,
        hp90BuffValue_21 = -70,
        hp60BuffValue_23 = -80,
        hp60BuffValue_27 = -30,
        hp20addSP = 30,
        skillBuffValue_17 = 20,
        targetBuff_23 = 20,
        skill5downSP1 = 100,
        skill5downSP2 = 150,
        skill5downSP3 = 200,
        tgTimer = 60,
        tgLimit = 1,
        tgIconNum1 = 0,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        shaderR = 128,
        shaderG = 0,
        shaderB = 128,

        buffTime_89 = 3,
        addSpTime = 12,
        exDmgVal = 0.02,
        exHP1 = 0.3,
        exHP2 = 0.4,
        exHP3 = 0.2,
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    --event.unit:addSP(100)---戦闘開始時の奥義ゲージ量
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

    self.skill5flg = false
    self.skill5Cnt = 0

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

    -- 経過時間ギミック
    self.timerFlg = false
    self.timeIndex = nil
    self.timeSpeeddefault = 0
    self.timeSpeed = 0
    self.tgtargetUnit = nil

    --シェーダー追加
    megast.Battle:getInstance():setMultiColorFilter(self.GD.shaderR,self.GD.shaderG,self.GD.shaderB);

    ---サブHP表示用
    self.bossHP = event.unit:getHP()
    self.subBarHpRateTbl = {[0] = self.GD.exHP1,
                            [1] = self.GD.exHP2,
                            [2] = self.GD.exHP3,
    }

    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = self.bossHP * self.subBarHpRateTbl[0]
    self.damage = 0---サブバー表示時のダメージ
    self.subBarFlg = false

    self.battleTime = 0
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    self:HPTriggersCheck(event.unit)

    --経過時間ギミック
    --self:timeGimmick(event.unit)

    --EXゲージギミック
    if self.subBarFlg then
        self.battleTime = self.battleTime + event.deltaTime
        if self.battleTime >= self.GD.addSpTime then
            self.battleTime = 0
            event.unit:addSP(20);
            self.hpSkill = 5
        end
        self:subBarControll(event.unit,self.damage);---サブバー表示
    end

    return 1
end

function class:timeGimmick(unit)
    if self.timeIndex ~= nil then
        -- ブレイク中は止める
        if unit:isBreak() then
            self.timeSpeed = 0
        else
            self.timeSpeed = self.timeSpeeddefault
        end

        -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= self.timeSpeed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , self.timeSpeed)
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
        end

        -- 気絶ユニットが死亡したらタイマーを非表示にする
        if self.tgtargetUnit ~= nil then
            if self.tgtargetUnit:getHP() <= 0 then
                megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
                self.tgtargetUnit = nil
                self.timeIndex = nil
            end
        end
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
    --確認用info
    --summoner.Utility.messageByEnemy(self.SUB_HP - damage);
    ---ゲージ0%になった場合の処理
    if self.SUB_HP - damage <= 0 then
        self.subBarFlg = false
        self.subBar:setVisible(false);
        self.damage = 0
        self.hpSkill = 0
        unit:setBurstPoint(0);
        self:execAddBuff(unit,self.STUN_BUFF_LIST2)
        self:removeStun()
        self:showMessage(self.TG_MESSAGE_LIST, 3)
    end
end

--[[
---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    if self.timeIndex ~= nil then
        self.timeIndex = nil
        if self.tgtargetUnit ~= nil then
            self.tgtargetUnit:setHP(0)
        end
    end
    return event.count
end
--]]

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
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0)
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.timeIndex ~= nil then
        self:removeStun()
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
        self.timeIndex = nil
    end
    BattleControl:get():visibleHateTarget(false);
    event.unit:setEnableHate(false);
    event.unit:updateHateTarget();
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    if self.timeIndex ~= nil then
        self:removeStun()
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
        self.timeIndex = nil
    end
    BattleControl:get():visibleHateTarget(false);
    self.gameUnit:setEnableHate(false);
    self.gameUnit:updateHateTarget();
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
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("2-skill1") ---EFのアニメーション名に気をつける
    end

    --if self.skill5flg then
    --    self.skill5flg = false
    --    self:unitDownSP()
    --end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        if not self.subBarFlg then
            event.unit:addSP(self.saveBP)
        end
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
    if not self.subBarFlg then
        unit:addSP(self.spValue);
    end
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

    if event.index == 2 or event.index == 3 then
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
    end

    --if self.skill5flg then
    --    self.skill5flg = false
    --end

    if event.index == 5 then
        self:showMessage(self.SKILL5_MESSAGE_LIST, 1)
        -- 奥義時タイマー表示
        --self:TimerStart(event.unit)
        -- EXゲージギミック
        self.subBarFlg = false
        self.damage = 0
        self.subBar:setVisible(false);
        -- ターゲットリセット
        self:targetUnitReset(event.unit)
    elseif event.index == 6 then
        --self.skill5flg = true
        self:showMessage(self.SKILL5_MESSAGE_LIST, 2)
        self:unitDownSP()
        ---ホストのみ---
        if megast.Battle:getInstance():isHost() then
            -- 気絶を解除(一応ここに置いておく)
            self:removeStun()
            -- 一応タゲチェック
            self:unitTargetCheck(event.unit)
            self:showMessage(self.TG_MESSAGE_LIST, 1)
            self:showFormatMessage(self.TG_MESSAGE_LIST[2],self.targetUnit:getUnitName())
            -- 時間切れの時に使う対象ユニットを入れておく
            self:execAddBuff(self.targetUnit,self.STUN_BUFF_LIST)
            self.tgtargetUnit = self.targetUnit
            megast.Battle:getInstance():sendEventToLua(self.scriptID,7,self.targetUnit:getIndex())---ゲストにターゲットを送る
        end
        event.unit:setBurstPoint(0);
        event.unit:setNextAnimationName("skill5")
        event.unit:setNextAnimationEffectName("2-skill5") ---EFのアニメーション名に気をつける
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

function class:unitDownSP()
    self.skill5Cnt = self.skill5Cnt + 1
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if self.skill5Cnt == 1 then
                myTeamUnit:setBurstPoint(myTeamUnit:getBurstPoint() - self.GD.skill5downSP1)
            elseif self.skill5Cnt == 2 then
                myTeamUnit:setBurstPoint(myTeamUnit:getBurstPoint() - self.GD.skill5downSP2)
            else
                myTeamUnit:setBurstPoint(myTeamUnit:getBurstPoint() - self.GD.skill5downSP3)
            end
        end
    end
    if self.skill5Cnt == 1 then
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
        self:showMessage(self.HP90_MESSAGE_LIST,2)
    elseif self.skill5Cnt == 2 then
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
        self:showMessage(self.HP60_MESSAGE_LIST,2)
    else
        self:showMessage(self.HP20_MESSAGE_LIST,2)
    end
end

function class:TimerStart(unit)
    if self.timerFlg then
        self.timerFlg = false
        if self.timeIndex == nil then
            -- タイマーが表示されていない場合
            self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit, self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
            self.timeSpeeddefault = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
            self.timeSpeed = self.timeSpeeddefault
        else
            -- タイマーが既に表示されている場合
            self:showMessage(self.TG_MESSAGE_LIST, 3)
            -- 既にタイマーがでてる場合は初期値にセットする
            megast.Battle:getInstance():setExtraTimerPercentage(self.timeIndex, 0);
        end

        ---ホストのみ---
        if megast.Battle:getInstance():isHost() then
            -- 気絶を解除(一応ここに置いておく)
            self:removeStun()
            -- 一応タゲチェック
            self:unitTargetCheck(unit)
            self:showMessage(self.TG_MESSAGE_LIST, 1)
            self:showFormatMessage(self.TG_MESSAGE_LIST[2],self.targetUnit:getUnitName())
            -- 時間切れの時に使う対象ユニットを入れておく
            self:execAddBuff(self.targetUnit,self.STUN_BUFF_LIST)
            self.tgtargetUnit = self.targetUnit
            megast.Battle:getInstance():sendEventToLua(self.scriptID,7,self.targetUnit:getIndex())---ゲストにターゲットを送る
        end
    end
end

function class:unitTargetCheck(unit)
    ---ヘイトは全部手動で設定する
    local target = self:checkTargetUnit()
    --megast.Battle:getInstance():sendEventToLua(self.scriptID,5,target:getIndex())---ゲストにターゲットを送る
    unit:setHateTarget(target)
    unit:updateHateTarget();
    ---ターゲットにバフ
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if i == target:getIndex() then
                self.targetUnitIndex = myTeamUnit:getIndex()
                self.targetUnit = myTeamUnit
                local index = myTeamUnit:getIndex() + (myTeamUnit:getBaseID3() * 10)
                if self.targetUnitList[index] == nil then
                    table.insert(self.targetUnitList,index,{unit = myTeamUnit,dps = 0})
                end
            end
        end
    end
end

-- ターゲットリセット
function class:targetUnitReset(unit)
    unit:updateHateTarget();
    local targetUnit = unit:getHateTarget();
    if targetUnit == nil then
        return
    end

    local targetIndex = targetUnit:getIndex();
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if i == targetIndex then
                --ターゲットは死亡
                myTeamUnit:setHP(0)
                local enemyUnit = self:getAncestorUnit(myTeamUnit);
                local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10);
                self.targetUnitList[index].dps = 0;
            end
        end
    end

    ---ヘイトは全部手動で設定する
    local target = self:checkTargetUnit();
    unit:setHateTarget(target);
    unit:updateHateTarget();
    ---ターゲットにバフ
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if i == target:getIndex() then
                self.targetUnit = target
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1);
            else
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0);
            end
        end
    end
end

function class:removeStun()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:getTeamUnitCondition():addCondition(self.STUN_BUFF_LIST.ID,0,0,0,0);
        end
    end
    return 1
end

function class:receive7(args)
    -- 気絶を解除(一応ここに置いておく)
    self:removeStun()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if args.arg == myTeamUnit:getIndex() then
                self:showMessage(self.TG_MESSAGE_LIST, 1)
                self:showFormatMessage(self.TG_MESSAGE_LIST[2],myTeamUnit:getUnitName())
                -- 時間切れの時に使う対象ユニットを入れておく
                self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST)
                self.targetUnit = myTeamUnit
                self.tgtargetUnit = myTeamUnit
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
    if self.subBarFlg then
        self.damage = self.damage + event.value
        event.value = event.value * self.GD.exDmgVal
    end

    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
    event.value = self:adjustHpFlg(event.unit,event.value)

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
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
                else
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
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
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
            else
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
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