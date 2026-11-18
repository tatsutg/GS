--@additionalEnemy,2005457
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="光属護の遺跡_19層_氷城塞ジオ＝ザグナス", version=2.8, id=2005456});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK5 = 100 },
    },
    HUMMER = {
        { ATTACK4 = 100 },
        { ATTACK4 = 100 },
        { ATTACK5 = 100 },
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL1 = 100 }
    },
    HUMMER = {
        { SKILL1 = 100 }
    },
    HP25 = {
        { SKILL1 = 100 },
        { SKILL1 = 100 },
        { SKILL2 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,  --踏みつけ
    ATTACK2 = 2,  --アッパー
    ATTACK3 = 3,  --ハンマー抜刀
    ATTACK4 = 4,  --ハンマー攻撃
    ATTACK5 = 5,  --掴み
    SKILL1 = 6,   --飛びかかる
    ATTACK6 = 7,  --投擲物
    ATTACK7 = 8,  --毒瓶
    ATTACK8 = 9,  --掴みなげ
    SKILL2 = 10,  --飛びかかる
    SKILL10 = 3   --ハンマー抜刀
}

class.cutInSkill = {}


---
class.BONE_NAMES = {
    FIRST = "L_arm3_hand_4",
    SECOND = "Glab"
}

class.ORBIT_ARGS = {
    AX = {
        start = "goblin_ax",
        finish = "goblin_axEnd",
        activeSkill = 7
    },
    BONE = {
        start = "goblin_bone",
        finish = "goblin_bone_bound",
        activeSkill = 7
    },
    IRON = {
        start = "goblin_iron-ball",
        finish = "goblin_iron-ballEnd",
        activeSkill = 7
    },
    POISON = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 8
    },
    POISON1 = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 8
    },
    POISON2 = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 8
    },
    POISON3 = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 8
    }
}

class.WEAPON_STATES = {
    NONE = 0,
    HUMMER = 1,
    BREAKED = 2
}

--===============================================================================================================================================
--定数
class.STAN_BUFFID = -10;
class.STAN_BUFFEFID = 89;
class.STAN_BUFFEFVALUE = 100;
class.STAN_BUFFEFDURATION = 1;

class.GRENADE_RECAST = 10;



--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.HP_BUFF_LIST = {
        [1] = {
            ID = 20054561,
            BUFF_ID = 13, --攻撃力ダウン
            VALUE = self.GD.hpBuffVal_13,
            DURATION = 999999,
            ICON = 4,
        },
        [2] = {
            ID = 20054562,
            BUFF_ID = 2, --最大HPダウン
            VALUE = self.GD.hpBuffVal_2,
            DURATION = 999999,
            ICON = 2
        },
        [3] = {
            ID = 20054563,
            BUFF_ID = 10,  --奥義ゲージ自然上昇
            VALUE = self.GD.hpBuffVal_10,
            DURATION = 999999,
            ICON = 213
        },
        [4] = {
            ID = 20054564,
            BUFF_ID = 238,  --ユニットのスキル使用時に奥義ゲージダウン
            VALUE = 1,
            DURATION = 999999,
            ICON = 0,
            SCRIPT = {
                SCRIPT_ID = 477,
                VALUE1 = self.GD.hpBuffVal_238
            }
        }
    }
    self.STUN_BUFF_LIST = {
        ID = 20054560,
        BUFF_ID = 89, --気絶効果
        VALUE = 100,
        DURATION = self.GD.buffTime_89,
        ICON = 79
    }
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 20054565,
            BUFF_ID = 17, --奥義ダメージUP
            VALUE = 0,
            DURATION = 999999,
            ICON = 31
        },
        [2] = {
            ID = 20054565,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 31
        },
        [3] = {
            ID = 20054565,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        }
    }
    self.SUMMON_BUFF_LIST = {
        [1] = {
            ID = 20054566,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 20
        },
        [2] = {
            ID = 20054566,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        }
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "スーパークリティカル以外のダメージを軽減：ハンマー破壊で解除", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "一定回数装備使用でハンマー破壊", COLOR = Color.yellow}),
    }
    self.GLAB_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GLAB_MESSAGE1 or "奥義ゲージが高いユニットをホールド", COLOR = Color.yellow}),
    }
    self.HUMMER_LOST_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HAMMER_LOST_MESSAGE1 or "ハンマー破壊成功！：ダメージ軽減解除・気絶", COLOR = Color.red}),
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "召喚数に応じてダメージを軽減・奥義ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE2 or "クリティカル大耐性・防御力大アップ", COLOR = Color.yellow})
    }
    self.ALL_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.ALL_DEAD_MESSAGE1 or "ダメージを軽減・奥義ダメージアップ：解除", COLOR = Color.red}),
    }
    self.HP75_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE1 or "奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "一定時間経過でブルーゴブル召喚：毒で遅延", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE3 or "攻撃力ダウン・最大HPダウン", COLOR = Color.red, isPlayer = true}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE4 or "スキル使用時奥義ゲージ減少", COLOR = Color.red, isPlayer = true}),
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
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 2;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(10);
        self.hpSkillFLG = true;
        self.spValue = self.GD.hp75AddSP;
        self:showMessage(self.HP75_MESSAGE_LIST);
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
        self.hpSkillFLG = true;
        self.spValue = self.GD.hp50AddSP;
        self:takeHP50Effect(self.gameUnit);
        self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
        self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
    end
end

function class:hp25(status)
    if status == "use3" then
        self.stateName = "FURY";
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 2;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(10);
        self.hpSkillFLG = true;
        self:initSkillWeight({HP25 = 100});
        -- self:showMessage(self.HP25_MESSAGE_LIST);
    end
end

function class:takeHP50Effect(unit)
    if self.dragonElemnt == 4 then
        --光属性
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                self:execAddBuff(myTeamUnit,self.HP_BUFF_LIST[1]);
                self:execAddBuff(myTeamUnit,self.HP_BUFF_LIST[2]);
            end
        end
        self:showMessage(self.HP50_MESSAGE_LIST,1);
        self:showMessage(self.HP50_MESSAGE_LIST,2);
        self:showMessage(self.HP50_MESSAGE_LIST,3);
    elseif self.dragonElemnt == 5 then    
        --闇属性
        -- self.attackBpDownFlg = true;
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                self:execAddBuff(myTeamUnit,self.HP_BUFF_LIST[3]);
                self:execAddBuff(myTeamUnit,self.HP_BUFF_LIST[4]);
            end
        end
        self:showMessage(self.HP50_MESSAGE_LIST,1);
        self:showMessage(self.HP50_MESSAGE_LIST,2);
        self:showMessage(self.HP50_MESSAGE_LIST,4);
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        hp75AddSP = 25,
        hp50AddSP = 35,
        startAddSP = 0,
        attackDelay = 8,
        hitStop = 100,

        grenadeRecast = 10,
        hummerOnDmgVal = 0.01,
        exGageHP = 500,
        gageRepairTime = 1,
        gageRepairRate = 1,
        useItemDmg = 10,

        throwFixDmg = 6000,
        throwDownBP = 300,
        attackBpDownRate = 20,

        tgTimer = 20,
        tgLimit = 99,
        tgIconNum1 = 3,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        summonCntTimeSpeed = 5,
        deBuffTimeSpeed = 0.333,

        hpBuffVal_2 = -50,
        hpBuffVal_10 = -2,
        hpBuffVal_13 = -100,
        hpBuffVal_238 = -30,
        buffTime_89 = 3,

        summonOnDmgValTbl ={
            0.6,
            0.3,
            0.15,
            0.03,
            0.01
        },
        summonOnBuffValTbl ={
            20,
            50,
            100,
            200,
            500
        },
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
    self.breakFlg = false;
    self.hpSkillFLG = false;
    self.timeIndex = nil;
    self.timeSpeed = nil;

    ---エクストラゲージ（サブバー）
    self.subBarFlg = false;
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = self.GD.exGageHP;---サブバーのHP
    self.subBarDamage = 0;

    ---召喚ギミック
    self.friendCount = 0;
    self:setEnemyIDs();

    ---ユニット装備使用監視ギミック
    self.infoCount = 0;
    self.itemCount = 0;
    self.itemUnitList = {};
    self:initItemCheck();

    ---ボスギミック
    self.skill2Flg = false;
    self.attackBpDownFlg = false;
    self.summonDeadFlg = false;
    self.repairTime = 0;
    self.dragonElemnt = 0;

    ---ボス固有
    ---つかみ関連の変数たち
    self.glabTargetIndex = nil;
    self.glabBoneName = "";
    self.tryGlab = false;
    self.isGlab = false;
    ---投擲物関連の変数たち
    self.grenadeTimer = 0;
    self.granedeTargetIndex = 0;
    ---武器状態の変数たち
    self.state = 0;
    self.startBreakPoint = 0;--バトル開始時から抜刀時までのブレイクダメージ合計を入れる
    self.attackDelayDefault = event.unit:getAttackDelay();
    ---足関係
    event.unit:addSubSkeleton("50103_leg",-30);
    event.unit:setSkin("1");
    return 1;
end

function class:setEnemyIDs()
    self.summonEnemyID = 2005457;
end

function class:initItemCheck()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local battleSkill = nil;
            for j = 0,2 do
                battleSkill = myTeamUnit:getItemSkill(j);
                if battleSkill ~= nil then
                    local index = (i * 10) + j + 1;
                    local ct = battleSkill:getCoolTimer();
                    if ct > 0 then
                        -- 使っている状態
                        self.itemUnitList[index] = 2;
                    else
                        -- 装備回復
                        battleSkill:setCoolTimer(0)
                        self.itemUnitList[index] = 0;
                    end
                end
            end
        end
    end
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:getUnitElemnt();
    --startWaveで同時にハンマー抜刀
    self.hpSkill = 10;
    self.saveBP = self.gameUnit:getBurstPoint();
    self.gameUnit:addSP(100);
    return 1;
end

function class:getUnitElemnt()
    for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if localUnit ~= nil then
            self.dragonElemnt = localUnit:getElementType();
            return;
        end
    end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    self:extraTimerOperation(event.unit);
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    
    ---召喚ギミック
    self:findFriend();
    if self.friendCount >= 1 then
        if not self.summonDeadFlg then self.summonDeadFlg = true; end
        self:execAddBuff(event.unit,self.SUMMON_BUFF_LIST[1]);
        if event.unit:getUnitState() ~= kUnitState_skill then
            self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[2]);
        end
    else
        self:execAddBuff(event.unit,self.SUMMON_BUFF_LIST[2]);
        self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[3]);
        if self.summonDeadFlg then
            self.summonDeadFlg = false;
            self:showMessage(self.ALL_DEAD_MESSAGE_LIST);
        end
    end

    ---奥義後のハンマー抜刀
    if event.unit:getUnitState() ~= kUnitState_skill and self.skill2Flg then
        self.skill2Flg = false;
        self.hpSkill = 10;
        self.saveBP = self.gameUnit:getBurstPoint();
        self.gameUnit:addSP(100);
    end

    ---プレイヤーPTの装備使用ギミック
    self:useItemCheck();
    ---エクストラゲージ
    if self.subBarFlg then
        self:subBarControll(event.unit, self.subBarDamage);
        --エクストラゲージ回復カウント
        self.repairTime = self.repairTime + event.deltaTime;
        if self.repairTime >= self.GD.gageRepairTime then
            self.repairTime = 0;
            self.SUB_HP = self.SUB_HP + self.GD.gageRepairRate;
        end
    end

    ---ボス固有ギミック
    --掴み時に奥義発動した場合の対策
    if event.unit:getUnitState() == kUnitState_skill and self.isGlab and self.glabTargetIndex ~= nil then
        self:throwEnd(event.unit);
    end
    --掴み投げ関係
    if self.isGlab and self.glabTargetIndex ~= nil then
        self:glabControll(event.unit);
    end
    --投擲物関係
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:grenadeCheck(event.deltaTime);
    end
    return 1;
end

function class:findFriend()   --雑魚の監視
    self.friendCount = 0;
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getEnemyID() == self.summonEnemyID then
                self.friendCount = self.friendCount + 1;
            end
        end
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
        self:weaponBreak(unit);
    end
end

--プレイヤーPTの装備使用ギミック
function class:useItemCheck()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local battleSkill = nil;
            for j = 0,2 do
                battleSkill = myTeamUnit:getItemSkill(j);
                if battleSkill ~= nil then
                    local index = (i * 10) + j + 1;
                    local ct = battleSkill:getCoolTimer()
                    if ct ~= 0 and self.itemUnitList[index] == 1 then
                        -- 使っている状態
                        self.itemCount = self.itemCount + 1;
                        self.itemUnitList[index] = 2;
                        self:takeSubBarDamage(self.itemCount);
                    elseif ct <= 0 and self.itemUnitList[index] == 2 then
                        -- 装備回復
                        self.itemUnitList[index] = 0
                        battleSkill:setCoolTimer(0);
                        --summoner.Utility.messageByEnemy("回復 "..index);
                    elseif ct ~= 0 and self.itemUnitList[index] == 0 then
                        -- 装備使用
                        self.itemUnitList[index] = 1;
                        --summoner.Utility.messageByEnemy("使用 "..index);
                    end
                end
            end
        end
    end
end

function class:takeSubBarDamage(itemCount)
    if self.subBarFlg then
        self.subBarDamage = self.subBarDamage + self.GD.useItemDmg;
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    if event.index == self.timeIndex then
        self:findFriend();
        self:friendObservation(event.unit,self.friendCount);
    end
    return event.count;
end

function class:friendObservation(unit,friendCount)   --雑魚の監視召喚
    local rand = math.random(0,9);
    if friendCount >= 5 then
        --何もしない
    elseif friendCount == 0 then--0体の場合は30%の確率で1体を召喚、60%の確率で2体を召喚、10%の確率3体を召喚
        if rand <= 2 then
            self:MultipleSummon(1);  -- 0〜2: 30%
        elseif rand <= 8 then
            self:MultipleSummon(2);  -- 3〜8: 60%
        else
            self:MultipleSummon(3);  -- 9: 10%
        end
        self:showMessage(self.SUMMON_MESSAGE_LIST);
    elseif friendCount == 4 then--4体の場合は50%の確率で1体を召喚
        if rand <= 4 then
            self:MultipleSummon(1);  -- 1: 50%
            self:showMessage(self.SUMMON_MESSAGE_LIST);
        end
    elseif friendCount == 3 then--3体の場合は60%の確率で1体を召喚、10%の確率で2体を召喚
        if rand <= 2 then-- 0〜2: 30% 何もしない
        elseif rand <= 8 then
            self:MultipleSummon(1);  -- 3〜8: 60%
            self:showMessage(self.SUMMON_MESSAGE_LIST);
        else
            self:MultipleSummon(2);  -- 9: 10%
            self:showMessage(self.SUMMON_MESSAGE_LIST);
        end  
    elseif friendCount >= 1 then--1体の場合は60%の確率で1体を召喚、30%の確率で2体を召喚、10%の確率3体を召喚
        if rand <= 4 then
            self:MultipleSummon(1);  -- 0〜5: 60%
        elseif rand <= 8 then
            self:MultipleSummon(2);  -- 6〜8: 30%
        else
            self:MultipleSummon(3);  -- 9: 10%
        end
        self:showMessage(self.SUMMON_MESSAGE_LIST);
    end
end

function class:extraTimerOperation(unit)
    if self.timeIndex ~= nil then
        local FLG = 0;
        ---デバフ状態かどうか
        local badStatusList = {90};
        for k,v in pairs(badStatusList) do
            if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
                local cond = unit:getTeamUnitCondition():findConditionWithType(v);
                if cond ~= nil  then
                    FLG = 1;
                    break;
                end
            end
        end

        ---ブレイク中か無敵中は停止
        if unit:isBreak() or unit:getInvincibleTime() > 0 then
            FLG = 2;
        end

        ---召喚ユニットが一定数居る場合は停止
        self:findFriend();
        if self.friendCount >= self.GD.summonCntTimeSpeed then
            FLG = 2;
        end

        if FLG == 2 then
            self.timeSpeed = 0;
        elseif FLG == 1 then
            self.timeSpeed = 1 * self.GD.deBuffTimeSpeed;
        else
            self.timeSpeed = 1;
        end

        ---経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= self.timeSpeed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , self.timeSpeed);
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end

    if event.spineEvent == "glab" then self:glab(event.unit) end
    if event.spineEvent == "throw" then self:throw(event.unit) end
    if event.spineEvent == "throwEnd" then self:throwEnd(event.unit) end
    if event.spineEvent == "lunchPoisonGrenade" then self:lunchPoisonGrenade(event.unit) end
    if event.spineEvent == "checkGlabSucsess" and self.tryGlab then self:checkGlabSucsess(event.unit) end
    if event.spineEvent == "lunchOther" then self:lunchOther(event.unit) end
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

    if self.attackBpDownFlg then
        self:attackUnitBpDown()
    end

    --掴み攻撃時のaddSP用
    if event.index == 5 then
        self.attackFlg = true;
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit); ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0);
        self.hpSkillFLG = false;
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

function class:attackUnitBpDown()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            myTeamUnit:setBreakPoint(myTeamUnit:getBreakPoint() - self.GD.attackBpDownRate)
        end
    end
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

    ---召喚ギミック
    self:findFriend();
    if self.friendCount >= 1 then
        self.SKILL_BUFF_LIST[1].VALUE = self.GD.summonOnBuffValTbl[self.friendCount];
        self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[1]);
    end

    if event.index == 1 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
    elseif event.index == 2 then
        self.skill2Flg = true;
    elseif event.index == 10 then
        event.unit:setNextAnimationName("attack3");
        event.unit:setNextAnimationEffectName("1-attack3");
        self:getRage(event.unit);
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

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.tryGlab then
        if self.glabTargetIndex == nil then
            self.glabTargetIndex = self:checkTarget(event.unit)
            self:checkGlabSucsess(event.unit);
        end
    end
    return event.value;
end

function class:checkTarget(unit)
    ---奥義ゲージ最も多いユニットを出す
    local index = 0;
    local bp = 0;
    for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if localUnit ~= nil then
            if bp < localUnit:getBurstPoint() then
                index = i;
                bp = localUnit:getBurstPoint();
            end
        end
    end
    return index;
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
    --ハンマー状態
    if self.state == self.WEAPON_STATES.HUMMER then
        --スーパークリティカル以外
        local superCritical = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().superCritical;
        if not superCritical then
            event.value = event.value * self.GD.hummerOnDmgVal;
        end
    end
    
    --召喚ギミック
    self:findFriend();
    if self.friendCount >= 1 then
        event.value = event.value * self.GD.summonOnDmgValTbl[self.friendCount];
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

    ---ハンマーギミック
    if self.subBarFlg then
        self.subBarFlg = false;
        self.subBar:setVisible(false);
        self:weaponBreak(event.unit);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.state == self.WEAPON_STATES.HUMMER then
        event.unit:setNextAnimationName("idle2");
    end

    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.afterSkillFLG then
            self.gameUnit:setInvincibleTime(0);
            self.hpSkillFLG = false;
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    megast.Battle:getInstance():waveEnd(true);
    -- megast.Battle:getInstance():sendEventToLua(self.scriptID, 4, 1)
    return 1
end

function class:receive4(args)
    return 1
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

---トリガー時停止系状態異常除去（HPギミックが状態異常で発動できないことを防ぐ）---
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

---HPトリガー時の全状態異常回復（仕様書に「状態異常を回復」とある場合に使用）---
function class:refreshAll(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97,135};
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

function class:MultipleSummon(Num)
    for i = 1,Num do
        self:summon(self.gameUnit, self.summonEnemyID)
    end
end




--===============================================================================================================================================
--掴み投げ関連のメソッド/
--------------------
function class:glab(unit)
    self.tryGlab = true;
end

function class:checkGlabSucsess(unit)
    if not self:isHost() then
        return;
    end

    self.tryGlab = false;
    if self.glabTargetIndex ~= nil then
        self:glabExecute(unit,self.glabTargetIndex);
        self:showMessage(self.GLAB_MESSAGE_LIST);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,self.glabTargetIndex);
    else
        self:glabFaild(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,8,0);
    end
end

function class:glabExecute(unit,index)
    self.glabBoneName = self.BONE_NAMES.FIRST;
    self.isGlab = true;
    unit:setAnimation(0,"skill1_throw",false);
    self:getUnitByIndex(index):getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFVALUE,self.STAN_BUFFEFDURATION,0);
end

function class:throw(unit)
    self.glabBoneName = self.BONE_NAMES.SECOND;
end

function class:throwEnd(unit)
    self.isGlab = false;
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    self.glabTargetIndex = nil;
    if glabUnit == nil then
        return;
    end

    local hit = unit:addOrbitSystem("GrowndHit");
    self.gameUnit:takeHitStop(0.5);
    hit:setPosition(glabUnit:getPositionX(),glabUnit:getPositionY());
    hit:setTargetUnit(glabUnit);
    hit:setHitType(2);
    hit:setActiveSkill(9);

    --固定ダメージ・奥義ゲージダウン
    glabUnit:setHP(glabUnit:getHP() - self.GD.throwFixDmg);
    glabUnit:setBurstPoint(glabUnit:getBurstPoint() - self.GD.throwDownBP);

    --通常攻撃でaddSPする用
    if self.attackFlg then
        self.attackFlg = false;
        self:addSP(self.gameUnit);
    end
end

function class:glabFaild(unit)
    unit:setAnimation(0,"skill1_miss",false);
end

function class:glabControll(unit)
    local x = unit:getSkeleton():getBoneWorldPositionX(self.glabBoneName);
    local y = unit:getSkeleton():getBoneWorldPositionY(self.glabBoneName);
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    if glabUnit == nil then
        return;
    end

    glabUnit:getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFVALUE,self.STAN_BUFFEFDURATION,0);
    glabUnit:setPosition(x + unit:getPositionX(),0);
    glabUnit:getSkeleton():setPosition(0,y + unit:getPositionY() - 50);
    glabUnit._autoZorder = false;
    glabUnit:setZOrder(unit:getZOrder()+1);
end

--===============================================================================================================================================
--投擲物関連のメソッド/
------------------
function class:grenadeCheck(deltaTime)
    self.grenadeTimer = self.grenadeTimer + deltaTime;
    if self.grenadeTimer > self.GD.grenadeRecast and self:isHost() then
        self.grenadeTimer = 0;
        local rand = math.random(1,2);
        if rand == 1 then
            self:takeOtherAnimation(self.gameUnit);
            --megast.Battle:getInstance():sendEventToLua(self.scriptID,9,1);
        else
            self:takePoizonGrenadeAnimation(self.gameUnit);
            --megast.Battle:getInstance():sendEventToLua(self.scriptID,9,0);
        end
    end
end

function class:takePoizonGrenadeAnimation(unit)
    unit:setAnimation(1,"goblin_attack",false);
end

function class:takeOtherAnimation(unit)
    unit:setAnimation(1,"goblin_attack2",false);
end

function class:lunchPoisonGrenade(unit)
    self:lunch(unit,self.ORBIT_ARGS.POISON);
end

function class:lunchOther(unit)
    --何を投げるかランダムで決定
    local rand = LuaUtilities.rand(0,100);
    local arg = {};
    if rand < 33 then
        arg = self.ORBIT_ARGS.AX;
    elseif rand < 66 then
        arg = self.ORBIT_ARGS.BONE;
    else
        arg = self.ORBIT_ARGS.IRON;
    end
    self:lunch(unit,arg);
end

function class:lunch(unit,arg)
    local bullet = unit:addOrbitSystem(arg.start,1);
    bullet:setHitCountMax(1);
    bullet:setEndAnimationName(arg.finish);
    bullet:setActiveSkill(arg.activeSkill);

    local x = unit:getPositionX()
    local y = unit:getPositionY()
    local xb = unit:getSkeleton():getBoneWorldPositionX("gobul_top");
    local yb = unit:getSkeleton():getBoneWorldPositionY("gobul_top");
    bullet:setPosition(x+xb,y+yb);

    local counter = 0;
    local tgt = nil;
    while counter < 4 and tgt == nil do
        counter = counter + 1;
        tgt = self:getUnitByIndex(self.granedeTargetIndex%4);
        self.granedeTargetIndex = self.granedeTargetIndex + 1;
    end

    local targetx = 0;
    local targety = 0;
    if tgt ~= nil then
        targetx = tgt:getAnimationPositionX();
        targety = tgt:getAnimationPositionY();
    end

    LuaUtilities.runJumpTo(bullet,3,targetx , targety,400,1);
end


--===============================================================================================================================================
--状態変化関連のメソッド/
--------------------
function class:getRage(unit)
    self.state = self.WEAPON_STATES.HUMMER;
    unit:setSetupAnimationName("setUpWeapon");
    self:initAttackWeight({HUMMER = 100});
    self:initSkillWeight({HUMMER = 100});
    --エクスゲージ表示
    self.subBarFlg = true;
    self.subBarDamage = 0;
    --プレイヤーPTを初期位置へ
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            myTeamUnit:setPositionX(myTeamUnit:getPositionX() + 200);
        end
    end
end

function class:weaponCheck(unit,damage)
    self.WEAPON_DAMAGE = self.WEAPON_DAMAGE + damage
    if self.WEAPON_DAMAGE >= self.WEAPON_HP and self:isHost() and unit.m_breaktime <= 0 then
        self:weaponBreak(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,0);
    end
end

function class:weaponBreak(unit)
    self.state = self.WEAPON_STATES.BREAKED;
    self.subBar:setVisible(false);
    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    if self.TRIGGERS[3].used then
        self:initSkillWeight({HP25 = 100});
    end
    self:showMessage(self.HUMMER_LOST_MESSAGE_LIST);

    unit:takeAnimation(0,"damage2",false);
    unit:takeAnimationEffect(0,"damage2",false);
    unit:setSetupAnimationName("setUpWeaponBreaked");
    unit:setReduceHitStop(0,0);--ヒットストップ無効解除
    unit:setSkin("1");

    --掴み投げ対策
    if self.isGlab and self.glabTargetIndex ~= nil then
        self:throwEnd(unit);
    end

    --気絶効果付与
    self:execAddBuff(unit,self.STUN_BUFF_LIST);
end

--[[
function class:subBarControll(unit,damage)
    local x = unit:getSkeleton():getBoneWorldPositionX("weapon2");
    local y = unit:getSkeleton():getBoneWorldPositionY("weapon2");
    self.subBar:setPositionX(unit:getPositionX() + x);--位置を指定
    self.subBar:setPositionY(unit:getPositionY()+ y);
    self.subBar:setVisible(true);
    self.subBar:setPercent(100 * (self.WEAPON_HP - damage)/self.WEAPON_HP);
    if self.WEAPON_HP - damage <= 0 then
        self.subBar:setVisible(false);
    end
end
--]]

--===============================================================================================================================================
--マルチ同期/
----------
function class:receive7(args)
    self.glabTargetIndex = args.arg;
    self:glabExecute(self.gameUnit,args.arg);
    self:showMessage(self.GLAB_MESSAGE_LIST)
    return 1;
end

function class:receive8(args)
    self:glabFaild(self.gameUnit);
    return 1;
end

function class:receive9(args)
    if args.arg == 0 then
        self:takePoizonGrenadeAnimation(self.gameUnit);
    else
        self:takeOtherAnimation(self.gameUnit);
    end
    return 1;
end

--===============================================================================================================================================
function class:getUnitByIndex(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

function class:isHost()
    return megast.Battle:getInstance():isHost();
end





class:publish();

return class;