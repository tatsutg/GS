--@additionalEnemy,901050013
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星15_光耀竜フォスラディウス", version=2.5, id="gb_901050012"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50, ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50 },
        { ATTACK4 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
        { SKILL2 = 50 },
        { SKILL2 = 50 }
    },
    HP0 = {
        { SKILL3 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL1 = 6,
    SKILL2 = 7,
    SKILL3 = 8
}

class.cutInSkill = {
    [1] = 1,
    [2] = 1,
    [3] = 1,
    [4] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 0001,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 1,
            ICON = 0,
            --COUNT = 0,
            --MAX = 10
        }
    }
    self.TARGET_BUFF = {
        [1] = {
            ID = 9010501,
            BUFF_ID = 91,  --麻痺
            VALUE = 100,
            DURATION = self.GD.targetBuffTime_91,
            ICON = 81
        }
    }
    self.SUMMON_BUFF_LIST = {
        [1] = {
            ID = 9010502,
            BUFF_ID = 0,  --奥義ダメージアップアイコン用
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,  --31
            COUNT = 0,
            MAX = 6,
            --SCRIPT = {
            --    SCRIPT_ID = 127,
            --    VALUE1 = 0,
            --    VALUE2 = 1000
            --}
        },
        [2] = {
            ID = 9010508,
            BUFF_ID = 17, --奥義ダメージアップ用
            VALUE = 0,
            DURATION = 20,
            ICON = 0
        },
        [3] = {
            ID = 9010508,
            BUFF_ID = 0, --奥義ダメージアップ用
            VALUE = 0,
            DURATION = 1,
            ICON = 0
        }
    }
    self.ATTACK_BUFF = {
        ID = 9010503,
        BUFF_ID = 21,  --被ダメ
        VALUE = self.GD.buffVal_21,
        DURATION = 999999,
        ICON = 139,
        COUNT = 0,
        MAX = 99
    }
    self.TIME_BUFF = {
        ID = 9010504,
        BUFF_ID = 1,  --最大HP
        VALUE = self.GD.buffVal_1,
        DURATION = 999999,
        ICON = 2,
        COUNT = 0,
        MAX = 99
    }
    self.HP_BUFF = {
        [1] = {
            ID = 9010505,
            BUFF_ID = 15,  --防御力
            VALUE = self.GD.buffVal_15,
            DURATION = 999999,
            ICON = 5
        },
        [2] = {
            ID = 9010506,
            BUFF_ID = 132,  --ダメージ無効化無効
            VALUE = 100,
            DURATION = 999999,
            ICON = 0
        },
        [3] = {
            ID = 9010507,
            BUFF_ID = 23,---クリティカル耐性
            VALUE = self.GD.buffVal_23,
            DURATION = 999999,
            ICON = 188
        }
    }
    self.FRIEND_BUFF = {
        [1] = {
            ID = 90105010,
            BUFF_ID = 0,
            VALUE = 0,  --召喚カウント
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
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "与ダメージの大きい者へのダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "与ダメージの大きい者をターゲット", COLOR = Color.yellow})
    }
    self.SKILL1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE1 or "%s耐性", COLOR = Color.red})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "ターゲットを強制麻痺", COLOR = Color.red})
    }
    self.TIME_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TIME_MESSAGE1 or "パーティの最大HPダウン", COLOR = Color.red})
    }
    self.EX_GAUGE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_MESSAGE1 or "一定時間経過でパーティの最大HPダウン：ダメージで解除", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_MESSAGE2 or "物理耐性", COLOR = Color.yellow})
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "ブラッディバット：魔法耐性", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE2 or "ブラッディバットの数が多いほどボスの奥義ダメージアップ", COLOR = Color.magenta})
    }
    self.HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE1 or "防御力アップ", COLOR = Color.yellow})
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "ダメージ無効化無効", COLOR = Color.red})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "クリティカル耐性・奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "HP回復・奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.RACE_MESSAGE_LIST = {
        [0] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE0 or "種族なし", COLOR = Color.red}),
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE1 or "人族", COLOR = Color.red}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE2 or "獣人族", COLOR = Color.red}),
        [3] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE3 or "精霊族", COLOR = Color.red}),
        [4] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE4 or "巨人族", COLOR = Color.red}),
        [5] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE5 or "機族", COLOR = Color.red}),
        [6] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE6 or "竜族", COLOR = Color.red}),
        [7] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE7 or "神族", COLOR = Color.red}),
        [8] = self:setMessageInfo({MESSAGE = self.TEXT.RACE_MESSAGE8 or "魔族", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    if self.GD.difficultyLevel >= 15 then
        self.TRIGGERS = {
            [1] = {
                tag = "HP_FLG",
                action = function (status) self:hp80(status) end,
                HP = 80,
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
                action = function (status) self:hp30(status) end,
                HP = 30,
                used = false,
                isEnableSkip = false
            },
            [4] = {
                tag = "HP_FLG",
                action = function (status) self:hp0(status) end,
                HP = 0.1,
                used = false,
                isEnableSkip = false
            }
        }
    elseif self.GD.difficultyLevel >= 12 then
        self.TRIGGERS = {
            [1] = {
                tag = "HP_FLG",
                action = function (status) self:hp80(status) end,
                HP = 80,
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
                action = function (status) self:hp30(status) end,
                HP = 30,
                used = false,
                isEnableSkip = false
            },
            [4] = {
                tag = "HP_FLG",
                action = function (status) self:hp0(status) end,
                HP = 0.1,
                used = false,
                isEnableSkip = false
            }
        }
    elseif self.GD.difficultyLevel >= 9 then
        self.TRIGGERS = {
            [1] = {
                tag = "HP_FLG",
                action = function (status) self:hp80(status) end,
                HP = 80,
                used = false,
                isEnableSkip = false
            },
            [2] = {
                tag = "HP_FLG",
                action = function (status) self:hp60(status) end,
                HP = 60,
                used = false,
                isEnableSkip = false
            }
        }
    elseif self.GD.difficultyLevel >= 6 then
        self.TRIGGERS = {
            [1] = {
                tag = "HP_FLG",
                action = function (status) self:hp80(status) end,
                HP = 80,
                used = false,
                isEnableSkip = false
            }
        }
    elseif self.GD.difficultyLevel >= 5 then
        self.TRIGGERS = {}
    end

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
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 1;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100)
        end
        self.gameUnit:setInvincibleTime(10);
        self:showMessage(self.HP80_MESSAGE_LIST);
        self:buffRefresh(self.gameUnit);
        self:execAddBuff(self.gameUnit,self.HP_BUFF[1]);
        self:findFriend();
        self:friendSummonCheck(self.friendCount,self.GD.hpSummonPar);
    end
end

function class:hp60(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 1;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(10);
        self:showMessage(self.HP60_MESSAGE_LIST);
        self:buffRefresh(self.gameUnit);
        self:execAddBuff(self.gameUnit,self.HP_BUFF[2]);
        self:findFriend();
        self:friendSummonCheck(self.friendCount,self.GD.hpSummonPar);
    end
end

function class:hp30(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 2;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(10);
        self:showMessage(self.HP30_MESSAGE_LIST);
        self:buffRefresh(self.gameUnit);
        self:execAddBuff(self.gameUnit,self.HP_BUFF[3]);
        self.spValue = self.GD.hp30AddSP;
        self:findFriend();
        self:friendSummonCheck(self.friendCount,self.GD.hpSummonPar);
    end
end

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(10);
        self:showMessage(self.HP0_MESSAGE_LIST);
        self:buffRefresh(self.gameUnit);
        if self.GD.difficultyLevel >= 15 then
            self.gameUnit:takeHeal(self.hp0Heal);
            self:initSkillWeight({HP0 = 100});
            self.spValue = self.GD.hp0AddSP;
        end
    end
end

function class:buffRefresh(unit)
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

function class:friendSummonCheck(friendCount,percent)   --雑魚の監視召喚
    local rand = math.random(0,100);
    if friendCount == 6 then  --何もしない
    else
        if rand <= percent then
            if self.GD.difficultyLevel >= 9 then
                self:enemySummon(2);
            elseif self.GD.difficultyLevel >= 6 then
                self:enemySummon(1);
            elseif self.GD.difficultyLevel >= 5 then
            end
        end
    end
end

function class:enemySummon(Num)   --召喚回数
    for i = 1,Num do
        self.summonCount = self.summonCount + 1;
        self:MultipleSummon(self.gameUnit,self.summonEnemyID,1);
        self:friendAddBuff(self.summonCount);
    end
    self:showMessage(self.SUMMON_MESSAGE_LIST);
end

function class:friendAddBuff(summonCount)   --召喚されたやつにバフをかける
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.FRIEND_BUFF[1].ID);
            if cond == nil then
                if myTeamUnit:getEnemyID() == self.summonEnemyID then
                    self.FRIEND_BUFF[1].VALUE = summonCount;
                    self:execAddBuff(myTeamUnit,self.FRIEND_BUFF[1]);
                end
            end
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        startAddSP = 40,
        attackDelay = 7,
        hitStop = 100,

        hateGimmickRate = 1.5,
        hateGimmickBase = 50,
        SPBonusRate = 500,

        tgTimer = 20,
        tgLimit = 999,
        tgIconNum1 = 2,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,

        difficultyLevel = 15,
        raceDmgVal = 0.01,
        exDmgVal = 0.01,

        hp30AddSP = 40,
        hp0AddSP = 50,
        hp0HealRate = 0.3,

        hpSummonPar = 100,
        attackSummonPar = 70,
        skill1SummonPar = 100,
        skill2SummonPar = 70,

        subBarHPBaseRate = 0.05,
        subBarHPRate = 0.05,

        buffVal_1 = -3000,
        buffVal_15 = 30,
        buffVal_21 = 30,
        buffVal_23 = -300,
        targetBuffTime_91 = 60,
        summonBuffValTbl_17 = {
            0,
            50,
            80,
            110,
            150,
            200,
            300
        }
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

    --光竜共通
    self.isLockOn = true;
    self.neckAngle = 0;
    self.shotAngle = 0;
    self.isFireEnd = true;
    self.fireSwitch = 1;

    ---グランドバトル
    self.gbAreaNumber = megast.Battle:getInstance():getCurrentGrandBattleFloor();
    ---ヘイトギミック
    event.unit:setEnableGBHate(true);
    ---グランドバトルEXボス
    megast.Battle:getInstance():setGBExBossSPBonusRate(self.GD.SPBonusRate);

    ---経過時間ギミック
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    --self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
    self.timerFlg = false;
    self.deBuffFlg = false;
    self.breakFlg = false;
    self:exTimerSetter()

    ---サブHP表示用
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.subBarFlg = false;
    self.subBarCount = 0;
    self.damage = 0; ---サブバー表示時のダメージ
    self.SUB_HP = (event.unit:getCalcHPMAX() * (self.GD.subBarHPBaseRate + (self.subBarCount * self.GD.subBarHPRate))) /100;

    ---ボスギミック
    --召喚ギミック
    self.friendCount = 0;
    self.summonCount = 0;
    self.summonBuffValTbl_17 = {};
    for i = 0,6 do
        self.summonBuffValTbl_17[i] = self.GD.summonBuffValTbl_17[i + 1];
    end

    --ヘイトギミック
    self.targetUnit = nil;
    self.targetUnitIndex = 0;

    self.skillFlg = false;
    self.targetRaceType = 0;
    self.hp0Heal = event.unit:getCalcHPMAX() * self.GD.hp0HealRate;
    self:setIDs();
    return 1
end

function class:setIDs()
    self.summonEnemyID = 901050013  --ブラッディバットのID
end

function class:exTimerSetter()
    self.exTimerSetTbl = {
        timeIndex = self.timeIndex,
        timeSpeed = self.timeSpeed,
        changeSpeed = 0.5,
        buffIcon1 = 2,
        buffIcon2 = 0,
        skillIndex = 1
    };
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:execAddBuff(event.unit,self.SUMMON_BUFF_LIST[1]);
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    if event.unit:getUnitState() == kUnitState_skill and self.skillFlg then
        self:execAddBuff(event.unit,self.SUMMON_BUFF_LIST[2]);
    elseif event.unit:getUnitState() ~= kUnitState_skill and self.skillFlg then
        self.skillFlg = false;
        self:execAddBuff(event.unit,self.SUMMON_BUFF_LIST[3]);
    end

    ---サブバー表示
    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);
    elseif not self.subBarFlg and self.timerFlg then
        self.timerFlg = false;
        self:extraTimer("delete" ,self.exTimerSetTbl);
    end

    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1
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

function class:friendCountAddBuff(unit,friendCount,buffIcon)
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.SUMMON_BUFF_LIST[1].ID);
    if cond ~= nil then
        if friendCount == 0 then
            cond:setNumber(0);
            cond:setThumbnailID(0)
        elseif friendCount ~= 0 then
            self.SUMMON_BUFF_LIST[2].VALUE = self.summonBuffValTbl_17[friendCount];
            cond:setNumber(friendCount);
            cond:setThumbnailID(buffIcon)
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

    --デバッグ表示用
    --local subBarHP = self.SUB_HP - damage;
    --summoner.Utility.messageByEnemy(subBarHP);

    ---ゲージ0になった場合非表示
    if self.SUB_HP - damage <= 0 then
        self.subBarFlg = false;
        self.damage = 0;
        self.subBar:setVisible(false);
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    self:unitAddBuff(self.TIME_BUFF);
    self:showMessage(self.TIME_MESSAGE_LIST);
    return event.count;
end

function class:setExtraTimer()
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
    self:exTimerSetter()
end

--extraTimer操作系
function class:extraTimer(str,setTbl)
    if str == "start" then
        --setExtraTimerSpeed(int index,float speed);
        megast.Battle:getInstance():setExtraTimerSpeed(setTbl.timeIndex ,setTbl.timeSpeed);
    elseif str == "change" then
        megast.Battle:getInstance():setExtraTimerSpeed(setTbl.timeIndex ,setTbl.timeSpeed * setTbl.changeSpeed);
    elseif str == "stop" then
        megast.Battle:getInstance():setExtraTimerSpeed(setTbl.timeIndex ,0);
    elseif str == "reset" then
        --setExtraTimerSpeed(int index,float speed);
        megast.Battle:getInstance():setExtraTimerPercentage(setTbl.timeIndex ,0);
    elseif str == "delete" then
        --removeExtraTimer(int index,float fadeTime,float delayTime,bool isAnimation);
        megast.Battle:getInstance():removeExtraTimer(setTbl.timeIndex ,1 ,1 ,true);
    elseif str == "iconChange" then
        --setExtraTimerBuffIcon(int index,int iconNumber,int iconNumber2);
        megast.Battle:getInstance():setExtraTimerBuffIcon(setTbl.timeIndex ,setTbl.buffIcon1 ,0);
    elseif str == "setSkill" then
        --setExtraTimerBattleSkill(int index,int skillIndex);
        megast.Battle:getInstance():setExtraTimerBuffIcon(setTbl.timeIndex ,setTbl.skillIndex);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "targetLock" then self:targetLock() end
    if event.spineEvent == "fire" then self:fire(event.unit) end
    return 1;
end

--光竜共通
function class:targetLock()
    self.isLockOn = true;
    self.neckAngle = 295;
end

function class:fire(unit)
    local shot = unit:addOrbitSystem("fireball",1);
    shot:setActiveSkill(self.fireSwitch);
    shot:setHitCountMax(1);
    shot:setEndAnimationName("explosion");
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = unit:getSkeleton():getBoneWorldPositionX("EF_fire_mouth");
    local yb = unit:getSkeleton():getBoneWorldPositionY("EF_fire_mouth");
    shot:setPosition(x+xb,y+yb);
    shot:setRotation(-self.neckAngle);
    self.shotAngle = self.neckAngle;
    shot:setZOrder(unit:getZOrder() -1);
    self.isFireEnd = true;
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

    if event.index == 4 then
        self:unitAddBuff(self.ATTACK_BUFF);
        ---召喚ギミック
        self:findFriend();
        self:friendSummonCheck(self.friendCount,self.GD.attackSummonPar);
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
    unit:addSP(self.spValue);
    return 1;
end

function class:unitAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
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

    if event.index == 1 and self.cutInFLG then
        self.cutInFLG = false
        event.unit:takeSkillWithCutin(event.index,1);
        return 0
    end

    self.skillFlg = true;

    ---ヘイトギミック
    self:gbHateTargetCheck(event.unit);
    self:showMessage(self.SKILL_MESSAGE_LIST);
    if event.index == 1 then
        self:setSill1Gimmick(event.unit);
    elseif event.index == 2 then
        self:setSill2Gimmick(event.unit);
    elseif event.index == 3 then
        self.lastSkillFLG = true;
        event.unit:setNextAnimationName("attack5");
        event.unit:setNextAnimationEffectName("1-attack5");
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    -- 【MEGA_D-9761】ボスの技の予告に、attackDamageValue の GB のヘイトの割合の倍率（(割合 × hateGimmickRate + hateGimmickBase) ÷ 100。弾も同じ）を入れる（表示専用。予測のたびに今の割合で出す。係数が数のときだけ呼ぶ。古いアプリには無いので確かめてから呼ぶ）
    do local gd = self.GD; if event.unit.announceSkillRateBy and gd and type(gd.hateGimmickRate) == "number" and type(gd.hateGimmickBase) == "number" then event.unit:announceSkillRateBy(3, gd.hateGimmickRate, gd.hateGimmickBase) end end
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

function class:setSill1Gimmick(unit)
    ---召喚ギミック
    self:findFriend();
    self:friendSummonCheck(self.friendCount,self.GD.skill1SummonPar);
    ---サブバー表示
    self.subBarFlg = true;
    self.damage = 0;
    self.subBarCount = self.subBarCount + 1;
    self.SUB_HP = (unit:getCalcHPMAX() * (self.GD.subBarHPBaseRate + (self.subBarCount * self.GD.subBarHPRate))) /100;
    self:showMessage(self.EX_GAUGE_MESSAGE_LIST);
    ---経過時間ギミック
    if not self.timerFlg then
        self.timerFlg = true;
        self:setExtraTimer();
    end
    ---種族ダーゲットギミック
    self.targetRaceType = self:getTargetUnitRaceType(self.targetUnitIndex);
    self:showFormatMessage(self.SKILL1_MESSAGE_LIST[1] ,self.RACE_MESSAGE_LIST[self.targetRaceType].MESSAGE);
end

function class:setSill2Gimmick(unit)
    ---サブバー表示
    self.subBarFlg = true;
    self.damage = 0;
    self.subBarCount = self.subBarCount + 1;
    self.SUB_HP = (unit:getCalcHPMAX() * (self.GD.subBarHPBaseRate + (self.subBarCount * self.GD.subBarHPRate))) /100;
    self:showMessage(self.EX_GAUGE_MESSAGE_LIST);
    ---経過時間ギミック
    if not self.timerFlg then
        self.timerFlg = true;
        self:setExtraTimer();
    end
    ---召喚ギミック
    self:findFriend();
    self:friendSummonCheck(self.friendCount,self.GD.skill2SummonPar);
    self:findFriend();
    self:friendCountAddBuff(unit,self.friendCount,31);
end

function class:gbHateTargetCheck(unit)
    local hateValTbl = {
        [0] = 0, [1] = 0, [2] = 0, [3] = 0
    }
    local maxHatePar = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            hateValTbl[myTeamUnit:getIndex()] = unit:getGBHate(myTeamUnit:getIndex());
            if maxHatePar < unit:getGBHate(myTeamUnit:getIndex()) then
                maxHatePar = unit:getGBHate(myTeamUnit:getIndex())
                self.targetUnitIndex = myTeamUnit:getIndex()
                self.targetUnit = myTeamUnit
            end
        end
    end
    
    --ターゲットへデバフ
    --ターゲットのヘイト値を0にする
    unit:resetGBHate();
    for i = 0, 3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if self.targetUnitIndex ~= myTeamUnit:getIndex() then
                unit:addGBHate(myTeamUnit:getIndex() ,hateValTbl[myTeamUnit:getIndex()]);  --ターゲットのヘイト値リセット
            elseif self.targetUnitIndex == myTeamUnit:getIndex() then
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF[1]);
            end
        end
    end
end

function class:getTargetUnitRaceType(targetUnitIndex)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == targetUnitIndex then
                return myTeamUnit:getRaceType();
            end
        end
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local gbHatePercent = event.unit:getGBHatePercent(enemyUnit:getIndex())
    local rate = ((gbHatePercent * self.GD.hateGimmickRate) + self.GD.hateGimmickBase) / 100
    --summoner.Utility.messageByEnemy(gbHatePercent.."/"..rate)
    event.value = event.value * rate
    return event.value
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local gbHatePercent = event.unit:getGBHatePercent(enemyUnit:getIndex())
    local rate = ((gbHatePercent * self.GD.hateGimmickRate) + self.GD.hateGimmickBase) / 100
    --summoner.Utility.messageByEnemy(gbHatePercent.."/"..rate)
    event.value = event.value * rate
    return event.value
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)

    --種族ダメージ補正
    if self.targetRaceType == event.enemy:getRaceType() then
        event.value = event.value * self.GD.raceDmgVal
    end

    ---サブバー表示時
    if self.subBarFlg then
        --物理ダメージ補正
        local exDamage = event.value;
        local attackType = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attackType == 1 then
            exDamage = exDamage * self.GD.exDmgVal
        end
        self.damage = self.damage + exDamage;
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
    megast.Battle:getInstance():waveEnd(true);
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
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
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


class:publish();

return class;