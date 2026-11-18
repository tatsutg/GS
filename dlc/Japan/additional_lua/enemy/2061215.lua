--@additionalEnemy,2061217
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="人族遺跡_12層_HARD_統神イフリート", version=2.8, id=2061215});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK3 = 50 },
        { ATTACK4 = 50 }
    },
    HP50 = {
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50 },
        { ATTACK3 = 50 },
        { ATTACK3 = 50, ATTACK4 = 50 }
    },
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 50 },
        { SKILL3 = 50 }
    },
    HP50 = {
        { SKILL2 = 50 },
        { SKILL3 = 50 },
        { SKILL2 = 50 },
        { SKILL3 = 50 },
        { SKILL2 = 50 },
        { SKILL3 = 50 },
        { SKILL1 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7,
    SKILL4 = 8
}

class.cutInSkill = {
    --[3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 20612150,
            BUFF_ID = 59, --氷結耐性
            VALUE = self.GD.buffVal_59_1,
            DURATION = self.GD.buffTime_59,
            ICON = 75,
        },
        [2] = {
            ID = 20612151,
            BUFF_ID = 108, --氷結回避率
            VALUE = self.GD.buffVal_59_1,
            DURATION = self.GD.buffTime_59,
            ICON = 0,
        }
    }
    self.ICE_BUFF_LIST = {
        [1] = {
            ID = 20612152,
            BUFF_ID = 59, --氷結耐性
            VALUE = self.GD.buffVal_59_2,
            DURATION = 999999,
            ICON = 65,
            COUNT = 0,
            MAX = 99
        }
    }
    self.HP_BUFF_LIST = {
        [1] = {
            ID = 20612153,
            BUFF_ID = 17,   --クリティカルダメージUP
            VALUE = self.GD.buffValue_17,
            DURATION = 999999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 22,
                VALUE1 = 0,
                VALUE2 = 0
            }
        }
    }
    self.STUN_BUFF_LIST = {
        [1] = {
            ID = 20612154,
            BUFF_ID = 89, --気絶
            VALUE = 100,
            DURATION = self.GD.buffTime_89,
            ICON = 79,
        }
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 206121550,
        BUFF_ID = 21,   --被ダメージ割合
        VALUE = self.GD.targetBuff_21,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 206121550,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "ボス燃焼時、CRI率アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "庇う無効", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "炎獄", COLOR = Color.red, isPlayer = true}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "一定時間経過で炎獄強化：ボス燃焼中加速", COLOR = Color.red, isPlayer = true}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE6 or "一定時間経過で炎獄強化：ボス氷結中停止", COLOR = Color.red, isPlayer = true}),
    }
    self.FIELD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FIELD_MESSAGE1 or "炎獄強化%d回目", COLOR = Color.red}),
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "一定時間氷結耐性ダウン", COLOR = Color.red}),
    }
    self.ICE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.ICE_MESSAGE1 or "氷結耐性：ブレイクで解除", COLOR = Color.yellow}),
    }
    self.HP75_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE1 or "ヴァルカンナックルを止めろ！！", COLOR = Color.White}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE2 or "ミルザ一定数撃破で阻止", COLOR = Color.White}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE3 or "行動速度アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE4 or "焔統神イフリート：ミルザ一定数撃破or失敗まで被ダメージ耐性", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "クリティカルダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "累計ダメージが多いユニットをターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE3 or "ターゲットに対して同属性のユニット数に応じて被ダメージアップ", COLOR = Color.yellow}),
    }
    self.HP25_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE1 or "ヴァルカンナックルを止めろ！！", COLOR = Color.White}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE2 or "ミルザ一定数撃破で阻止", COLOR = Color.White}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE3 or "奥義ゲージ上昇量大アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE4 or "焔統神イフリート：ミルザ一定数撃破or失敗まで被ダメージ耐性", COLOR = Color.yellow})
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "ミルザ：反射・HP吸収・奥義ゲージ低下耐性・庇う無効", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE2 or "ミルザ：撃破時、累計ダメージの多い属性の耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE3 or "ミルザ：最大2属性まで属性耐性保持・超過時、古い順に解除", COLOR = Color.yellow}),
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp75(status) end,
            HP = 75,
            used = false,
            isEnableSkip = false
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
            action = function (status) self:hp25(status) end,
            HP = 25,
            used = false,
            isEnableSkip = false
        },
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

function class:hp75(status)
    if status == "use3" then
        self.stateName = "FURY";
        self:showMessage(self.HP75_MESSAGE_LIST);
        self:deBuffRefresh(self.gameUnit);
        self.gameUnit:setAttackDelay(self.GD.hp75AttackDelay);
        self.subBarFlg = true;
        self.SUB_HP = self.GD.exGageHP;
        self.timeIndex2 = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer2, self.GD.tgLimit2 ,self.GD.tgIconNum1_2, self.GD.tgIconNum2_2, self.GD.tgPosX2, self.GD.tgPosY2, self.GD.tgScale2);
        self.timeSpeed2 = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex2);
        self:MultipleSummon(self.gameUnit,self.summonID,self.GD.summonMax);
        self.hpInfoFlg = true;
    end
end

function class:hp50(status)
    if status == "use3" then
        self.stateName = "FURY";
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 1;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(20);
        self:showMessage(self.HP50_MESSAGE_LIST);
        self:setHate(self.gameUnit);
        self:deBuffRefresh(self.gameUnit);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[1]);
        self:initAttackWeight({HP50 = 100});
        self:initSkillWeight({HP50 = 100});
    end
end

function class:hp25(status)
    if status == "use3" then
        self.stateName = "FURY";
        self:showMessage(self.HP25_MESSAGE_LIST);
        self:deBuffRefresh(self.gameUnit);
        self.spValue = self.GD.hp25AddSP;
        self.subBarFlg = true;
        self.SUB_HP = self.GD.exGageHP2;
        self.timeIndex2 = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer2, self.GD.tgLimit2 ,self.GD.tgIconNum1_2, self.GD.tgIconNum2_2, self.GD.tgPosX2, self.GD.tgPosY2, self.GD.tgScale2);
        self.timeSpeed2 = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex2);
        self:MultipleSummon(self.gameUnit,self.summonID,self.GD.summonMax);
        self.hpInfoFlg = true;
    end
end

function class:deBuffRefresh(unit)
    self.badStatusList = { 89,90,91,92,93,94,95,96,97 };
    for k,v in pairs(self.badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            local cond = unit:getTeamUnitCondition():findConditionWithType(v);
            cond:setValue(0);
            cond:setTime(0);
            cond:setThumbnailID(0);
        end
    end
    megast.Battle:getInstance():updateConditionView();
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 25,
        hp25AddSP = 50,
        startAddSP = 0,
        attackDelay = 8,
        hp75AttackDelay = 5,
        hitStop = 100,

        burnFieldDmgRate = 2,
        burnFieldDmgRate2 = 1,
        burnFieldTimeDmgRate_1 = 10,
        burnFieldTimeDmgRate_2 = 5,

        tgTimer = 40,
        tgLimit = 99,
        tgIconNum1 = 87,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        deBuffTimeSpeed = 2,

        tgTimer2 = 30,
        tgLimit2 = 1,
        tgIconNum1_2 = 31,
        tgIconNum2_2 = 0,
        tgPosX2 = 80,
        tgPosY2 = 0,
        tgScale2 = 1,

        exGageHP = 20,
        exGageHP2 = 20,
        summonMax = 2,

        buffValue_17 = 50,
        targetBuff_21 = 30,
        buffVal_59_1 = -200,
        buffVal_59_2 = 10,
        buffTime_59 = 5,
        buffTime_89 = 3,
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
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
    self.timeIndex2 = nil;
    self.timeSpeed2 = nil;

    ---エクストラゲージギミック
    self.subBarFlg = false;
    self.subBarDamage = 0;
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = self.GD.exGageHP;---サブバーのHP
    
    ---ターゲットギミック
    self.targetUnitList = {};

    ---召喚ギミック
    self.friendCount = 0;
    self.summonID = 2061217;

    ---フィールド効果：炎獄
    self.fieldStart = false;
    self.DAMAGE_SPAN = 5;
    self.damageTimer = 0;
    self.burnFieldCount = 0;

    ---ボスギミック
    self.skillBuffFlg = false;
    self.deBuffFlg = false;
    self.fieldCount = 0;
    self.hpInfoFlg = false;
    self.infoTime = 0;
    self.showInfoTime = 5;
    return 1;
end

function class:setHate(unit)
    ---ターゲットギミック
    --自動ヘイトは使わない
    unit:setHateRate_Heal(0);
    unit:setHateRate_Damage(0);
    self.targetUnit = nil;
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    unit:setEnableHate(true);
    unit:updateHateTarget();
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self.fieldStart = true;
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    --エクストラタイマー
    self:extraTimerOperation(event.unit);
    self:extraTimerOperation2(event.unit);
    --氷結耐性ギミック
    self:deBuffResistGimmick(event.unit);
    --奥義後にバフを付与
    if self.skillBuffFlg and event.unit:getUnitState() ~= kUnitState_skill then
        self.skillBuffFlg = false;
        self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[1]);
        self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[2]);
        self:showMessage(self.SKILL_MESSAGE_LIST);
    end
    ---エクストラゲージギミック
    if self.subBarFlg then
        self:subBarControll(event.unit, self.subBarDamage);
        ---召喚ギミック
        self:findFriend()
        if self.friendCount < self.GD.summonMax then
            self.subBarDamage = self.subBarDamage + 1;
            self:MultipleSummon(self.gameUnit,self.summonID,1);
        end
    end
    ---フィールドギミック：炎獄
    if self.fieldStart then
        local playerTeam = megast.Battle:getInstance():getTeam(true);
        self:countUp(event.deltaTime,playerTeam); 
    end
    --召喚時のinfoをズラす
    if self.hpInfoFlg then
        self.infoTime = self.infoTime + event.deltaTime;
        if self.infoTime >= self.showInfoTime then
            self.hpInfoFlg = false;
            self.infoTime = 0;
            self:showMessage(self.SUMMON_MESSAGE_LIST);
        end
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

function class:deBuffResistGimmick(unit)
    -- ボスが状態異常の場合
    local cond1 = unit:getTeamUnitCondition():findConditionWithType(96);
    if cond1 ~= nil then
        if not self.deBuffFlg then
            self.deBuffFlg = true;
            self:execAddBuff(unit,self.ICE_BUFF_LIST[1]);
            self:showMessage(self.ICE_MESSAGE_LIST);
        end
    else
        self.deBuffFlg = false;
    end
end

function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage) / self.SUB_HP);
    --summoner.Utility.messageByEnemy(self.SUB_HP - damage);
    ---ゲージ0%になった場合の処理
    if self.SUB_HP - damage <= 0 then
        self.subBarFlg = false;
        self.subBar:setVisible(false);
        self.subBarDamage = 0;
        self:execAddBuff(unit,self.STUN_BUFF_LIST[1]);
        --エクストラタイマー非表示
        if self.timeIndex2 ~= nil then
            megast.Battle:getInstance():removeExtraTimer(self.timeIndex2 ,1 ,1 ,true);
            self.timeIndex2 = nil;
            self.timeSpeed2 = nil;
        end
        self:friendAllDead();
    end
end

function class:findFriend()  --雑魚の監視
    self.friendCount = 0;
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getEnemyID() == self.summonID then
                self.friendCount = self.friendCount + 1;
            end
        end
    end
end

function class:friendAllDead()
    self.friendCount = 0;
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getEnemyID() == self.summonID then
                myTeamUnit:getTeamUnitCondition():addCondition(2061215,0,0,100,0);
                myTeamUnit:setHP(0);
            end
        end
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    if event.index == self.timeIndex then
        self.burnFieldCount = self.burnFieldCount + 1;
        self:showFormatMessage(self.FIELD_MESSAGE_LIST[1],self.burnFieldCount);
    elseif event.index == self.timeIndex2 then
        self.hpSkill = 4;
        self.gameUnit:addSP(100);
        self.gameUnit:setInvincibleTime(20);
        --エクストラゲージ非表示
        self.subBarFlg = false;
        self.subBar:setVisible(false);
        self.subBarDamage = 0;
        if self.timeIndex2 ~= nil then
            megast.Battle:getInstance():removeExtraTimer(self.timeIndex2 ,1 ,1 ,true);
            self.timeIndex2 = nil;
            self.timeSpeed2 = nil;
        end
        self:friendAllDead();
    end
    return event.count;
end

function class:extraTimerOperation(unit)
    if self.timeIndex ~= nil then
        local FLG = 0;
        -- デバフ状態かどうか
        local badStatusList = {96}; --氷結
        for k,v in pairs(badStatusList) do
            if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
                local cond = unit:getTeamUnitCondition():findConditionWithType(v);
                if cond ~= nil  then
                    FLG = 2;
                    break;
                end
            end
        end

        local badStatusList = {97}; --燃焼
        for k,v in pairs(badStatusList) do
            if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
                local cond = unit:getTeamUnitCondition():findConditionWithType(v);
                if cond ~= nil  then
                    FLG = 1;
                    break;
                end
            end
        end

        -- ブレイク中か無敵中は停止
        if unit:isBreak() or unit:getInvincibleTime() > 0 then
            FLG = 2;
        end

        -- 奥義中は停止
        if unit:getUnitState() == kUnitState_skill then
            FLG = 2;
        end

        if FLG == 2 then
            self.timeSpeed = 0;
        elseif FLG == 1 then
            self.timeSpeed = 1 * self.GD.deBuffTimeSpeed;
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

function class:extraTimerOperation2(unit)
    if self.timeIndex2 ~= nil then
        local FLG = 0;
        -- ブレイク中か無敵中は停止
        if unit:isBreak() or unit:getInvincibleTime() > 0 then
            FLG = 2;
        end

        -- 奥義中は停止
        if unit:getUnitState() == kUnitState_skill then
            FLG = 2;
        end

        if FLG == 2 then
            self.timeSpeed2 = 0;
        else
            self.timeSpeed2 = 1;
        end

        -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex2) ~= self.timeSpeed2 then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex2 , self.timeSpeed2);
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex2);
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end
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

    --if event.index == 1 then
    --    event.unit:setNextAnimationName("attack1");
    --    event.unit:setNextAnimationEffectName("1-attack1");
    --end

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

    --if event.index == 1 and self.cutInFLG then
    --    self.cutInFLG = false;
    --    event.unit:takeSkillWithCutin(event.index,1);
    --    return 0;
    --end

    if event.index == 1 or event.index == 2 or event.index == 3 then
        self.skillBuffFlg = true;
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
    ---フィールドギミック：炎獄
    self:burnTakeDamageValue(event);
    ---エクストラゲージギミック
    if self.subBarFlg then event.value = 1; end
    ---ダメージギミック
    --ダメージ計算はしておく
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10);
    if self.targetUnitList[index] == nil then
        table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value});
    else
        self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value;
    end
    --HP50%以降にターゲットギミックを発動
    if self.TRIGGERS[2].used then
        ---ホストのみ---
        if megast.Battle:getInstance():isHost() then
            ---ヘイトは全部手動で設定する
            local target = self:checkTargetUnit()
            --megast.Battle:getInstance():sendEventToLua(self.scriptID,5,target:getIndex())---ゲストにターゲットを送る
            event.unit:setHateTarget(target)
            event.unit:updateHateTarget();
            ---ターゲットにバフ
            local myTeam = megast.Battle:getInstance():getTeam(true);
            for i = 0,3 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    if i == target:getIndex() then
                        local elementCount = self:enemyElementCount(event.unit,target:getElementType());
                        self.TARGET_BUFF_LIST1.VALUE = self.GD.targetBuff_21 * elementCount;
                        self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
                    else
                        self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
                    end
                end
            end
        end
        ------
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

---与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil;
    local val = 0;
    for i,v in pairs(self.targetUnitList) do
        if v.unit == nil or v.unit:getHP() < 1 then
            --v.dps = 0;
        elseif v.dps >= val then
            val = v.dps;
            target = v.unit;
        end
    end
    return target;
end

function class:enemyElementCount(unit,targetElement)
    local unitTeam = unit:getTeam();
    local targetTeam = nil;
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true);
    else
        targetTeam = megast.Battle:getInstance():getTeam(false);
    end

    local count = 0;
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i,true);
        if myTeamUnit ~= nil and myTeamUnit:getElementType() == targetElement then
            count = count + 1;
        end
    end
    return count;
end

---------------------------------------------------------------------------------
-- takeMultiDamageValue
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0
    end
    event.value = self:adjustHpFlg(event.unit, event.value)
    return event.value
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

    --耐性バフを削除
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.ICE_BUFF_LIST[1].ID);
    if cond ~= nil then
        event.unit:getTeamUnitCondition():removeCondition(cond);
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
            count = count + 1;
            if count > 100 then
                break;
            end
        end
    end
end

--- チーム取得
function class:getMyTaem(unit,teamFlg)
    local unitTeam = unit:getTeam();
    local targetTeam = nil;
    if teamFlg then
        --自分PTからみて味方PTを取る
        if unitTeam == megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(true);
        else
            targetTeam = megast.Battle:getInstance():getTeam(false);
        end
    else
        --自分PTからみて敵PTを取る
        if unitTeam == megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(false);
        else
            targetTeam = megast.Battle:getInstance():getTeam(true);
        end
    end
    return targetTeam;
end


---召喚系
---------------------------
function class:summon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i,unitID)--指定したインデックスの位置に指定したエネミーIDのユニットを出す
                break
            end
        end
    end
end

function class:MultipleSummon(unit,unitID,Num)
    for i = 1,Num do
        self:summon(unit,unitID)
    end
end

---フィールド効果
---炎獄
---------------------------
function class:burnTakeDamageValue(event)
    if event.value <= 0 then
    	return 1;
    end

    local targetUnit = event.enemy;
    if targetUnit:getParentTeamUnit() ~= nil then
        targetUnit = targetUnit:getParentTeamUnit();
    end

    --耐性チェック
    local timerCalc = self.GD.burnFieldDmgRate + (self.burnFieldCount * self.GD.burnFieldDmgRate2);
    local damage = event.value * timerCalc / 100;
    local condValue = targetUnit:getTeamUnitCondition():findConditionValue(3002);
    damage = damage * (100 - condValue) / 100;
    if damage < 1 then
        damage = 1;
    end

    damage = math.floor(damage);

    --ダメージ表記とHP減算処理
    targetUnit:takeDamagePopup(event.enemy,damage);
    targetUnit:setHP(targetUnit:getHP() - damage);
    megast.Battle:getInstance():recAddDamage(event.enemy,event.unit,damage);
    print("burnTakeDamageValue");
    return 1;
end

function class:playBurnFieldVisual()
    megast.Battle:getInstance():playFieldEffectActive();
end

function class:excuteBurnDamage(playerTeam)
    self:playBurnFieldVisual();
    for i = 0, 4 do
        local unit = playerTeam:getTeamUnit(i);
        if unit ~= nil then
            local timerCalc = self.GD.burnFieldTimeDmgRate_1 + self.GD.burnFieldTimeDmgRate_2 * self.burnFieldCount;
            local damageValue = unit:getCalcHPMAX() * timerCalc / 100;
            --耐性チェック
            local condValue = unit:getTeamUnitCondition():findConditionValue(3001);
            damageValue = damageValue * (100 - condValue) / 100;
            --ダメージ表記とHP減算処理
            if megast.Battle:getInstance():isPvp() == false then
                unit:takeDamagePopup(unit,damageValue);
                unit:setHP(unit:getHP() - damageValue);
                megast.Battle:getInstance():recAddDamage(nil,unit,damageValue);
            else
                -- PVPのときは死なないようにする
                unit:takeFieldEffectDamage(damageValue, false);
                --megast.Battle:getInstance():recAddDamage(nil,unit,damageValue);
            end
        end
    end
end

function class:excuteBurnEffect()
    self:playBurnFieldVisual();
end

function class:countUp2(deltaTime,playerTeam)
    local damageTimer2 = self.damageTimer + deltaTime;
    if damageTimer2 > self.DAMAGE_SPAN then
        self:excuteBurnDamage(playerTeam);
    	return 1;
    end
    return 0;
end

function class:countUp(deltaTime,playerTeam)
    if megast.Battle:getInstance():isPvp() == true and megast.Battle:getInstance():isPvpHost() == false then
        if megast.Battle:getInstance():getFieldEffectSync() == true then
            megast.Battle:getInstance():setFieldEffectSync(false);
            self:excuteBurnEffect();
            return 1;
        end
        return 0;
    end

    self.damageTimer = self.damageTimer + deltaTime;
    if self.damageTimer > self.DAMAGE_SPAN then
        self:excuteBurnDamage(playerTeam);
        self.damageTimer = self.damageTimer - self.DAMAGE_SPAN;
    	return 1;
    end
    return 0;
end



class:publish();

return class;