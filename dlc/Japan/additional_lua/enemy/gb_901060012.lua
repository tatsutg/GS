--@additionalEnemy,901060013,901060014
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星15_銀翼魔従ヴァルザンデス", version=2.7, id="gb_901060012"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
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
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7
}

class.cutInSkill = {
    [1] = 1,
    [2] = 1,
    [3] = 1
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
    self.ATTACK_BUFF = {
        ID = 9010601,
        BUFF_ID = 21,  --被ダメ
        VALUE = self.GD.attack4buffValue_21,
        DURATION = 999999,
        ICON = 139,
        COUNT = 0,
        MAX = 99
    }
    self.SKILL_BUFF = {
        [1] = {
            ID = 9010602,
            BUFF_ID = 1,  --最大HP
            VALUE = self.GD.skill6buffValue_1,
            DURATION = 999999,
            ICON = 2,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 9010603,
            BUFF_ID = 89,  --気絶
            VALUE = 100,
            DURATION = self.GD.skill5buffTime_89,
            ICON = 79,
        },
        [3] = {
            ID = 9010604,
            BUFF_ID = 0,   -- 属性耐性(Icon表示用)
            VALUE = 0,
            DURATION = 999999,
            ICON = self.targetElementIcon,
        },
    }
    self.HP_BUFF = {
        [1] = {
            ID = 9010611,
            BUFF_ID = 23,  -- クリティカル耐性
            VALUE = self.GD.hp60buffValue_23,
            DURATION = 999999,
            ICON = 188
        },
        [2] = {
            ID = 9010612,
            BUFF_ID = 56,  --暗闇耐性(時間短縮)
            VALUE = self.GD.hp30buffValue_56,
            DURATION = 999999,
            ICON = 62
        },
    }
    self.BLINDRESIST_BOX_LIST = {
        [1] = {
            ID = 9010621,
            BUFF_ID = 56,  --暗闇耐性(時間短縮)
            VALUE = self.GD.buffValue_56,
            DURATION = 999999,
            ICON = 62,
            COUNT = 0,
            MAX = 10
        },
        [2] = {
            ID = 9010622,
            BUFF_ID = 105,  --暗闇耐性(回避率)
            VALUE = self.GD.buffValue_56,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10
        },
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "与ダメージの大きい者へのダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "与ダメージの大きい者をターゲット", COLOR = Color.yellow})
    }
    self.SKILL1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE1 or "%s属性耐性", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE2 or "%s属性ユニットを強制気絶", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE3 or "%s属性ユニットの奥義ゲージダウン", COLOR = Color.red}),
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "パーティの最大HPダウン", COLOR = Color.red})
    }
    self.SKILL3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "シャドウライトニング改：ダメージ無効化無効", COLOR = Color.red})
    }
    self.EX_GAUGE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_MESSAGE1 or "力を溜めている：物理耐性", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_MESSAGE2 or "一定ダメージで解除、暗闇状態のとき被ダメージアップ", COLOR = Color.red}),
    }
    self.EX_GAUGE_BROKEN_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_BROKEN_MESSAGE1 or "力溜め解除成功！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_BROKEN_MESSAGE2 or "暗闇耐性アップ", COLOR = Color.red}),
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "メルキオン：ブレイクダメージでHP減少", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE2 or "竜牙兵：神族からの被ダメージアップ", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE3 or "メルキオン・竜牙兵が多いほどボスの被ダメージ軽減", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE4 or "メルキオン・竜牙兵撃破で奥義アップ＆ボスの暗闇耐性ダウン", COLOR = Color.white}),
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "クリティカル耐性アップ", COLOR = Color.yellow})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "暗闇耐性・奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "HP回復・奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.ELEMENT_MESSAGE_LIST = {
        [0] = self:setMessageInfo({MESSAGE = self.TEXT.ELEMENT_MESSAGE1 or "無", COLOR = Color.yellow}),
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.ELEMENT_MESSAGE2 or "炎", COLOR = Color.yellow}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.ELEMENT_MESSAGE3 or "水", COLOR = Color.yellow}),
        [3] = self:setMessageInfo({MESSAGE = self.TEXT.ELEMENT_MESSAGE4 or "樹", COLOR = Color.yellow}),
        [4] = self:setMessageInfo({MESSAGE = self.TEXT.ELEMENT_MESSAGE5 or "光", COLOR = Color.yellow}),
        [5] = self:setMessageInfo({MESSAGE = self.TEXT.ELEMENT_MESSAGE6 or "闇", COLOR = Color.yellow})
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
            self.hpSkill = 2;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100)
        end
        self.gameUnit:setInvincibleTime(10);
        --self:showMessage(self.HP80_MESSAGE_LIST);
        self:buffRefreshAll(self.gameUnit);
        --self:execAddBuff(self.gameUnit,self.HP_BUFF[1]);
        self.summonFlg = 3
        --self:findFriend();
        --self:friendSummonCheck(self.eID1count,self.eID2count,self.GD.hpSummonPar);
    end
end

function class:hp60(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 2;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(10);
        self:showMessage(self.HP60_MESSAGE_LIST);
        self:buffRefreshAll(self.gameUnit);
        self:execAddBuff(self.gameUnit,self.HP_BUFF[1]);
        self.summonFlg = 3
        --self:findFriend();
        --self:friendSummonCheck(self.eID1count,self.eID2count,self.GD.hpSummonPar);
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
        self:buffRefreshAll(self.gameUnit);
        self:execAddBuff(self.gameUnit,self.HP_BUFF[2]);
        self.spValue = self.GD.hp30AddSP;
        self.summonFlg = 3
        --self:findFriend();
        --self:friendSummonCheck(self.eID1count,self.eID2count,self.GD.hpSummonPar);
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
        self:buffRefreshAll(self.gameUnit);

        if self.GD.difficultyLevel >= 15 then
            self.gameUnit:takeHeal(self.hp0Heal);
            self:initSkillWeight({HP0 = 100});
            self.saveBP = 0;
            self.gameUnit:setBurstPoint(0);
            self.spValue = self.GD.hp0AddSP;
            self:showMessage(self.HP0_MESSAGE_LIST);

            -- 6体になるように出す
            self:findFriend();
            self:hp0friendSummonCheck(self.eID1count,self.eID2count);
        end
    end
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

--雑魚の監視召喚(既に場にいる敵１の数、敵２の数、召喚確率)
function class:friendSummonCheck(eID1count,eID2count,percent)
    local rtn = false
    local friendCount = eID1count + eID2count
    local rand = math.random(0,100);
    if friendCount == 6 then  --何もしない
    else
        if rand <= percent then
            if self.GD.difficultyLevel >= 12 then
                if friendCount == 5 then
                    -- 既に5体いる場合は少ない方を出す
                    if eID1count > eID2count then
                        rtn = self:MultipleSummon(self.summonEnemyID2, 1, true);
                    else
                        rtn = self:MultipleSummon(self.summonEnemyID1, 1, true);
                    end
                elseif friendCount == 4 then
                    -- 既に4体いる場合は少ない方を2体出す(同数の場合は1体ずつ出す)
                    if eID1count == eID2count then
                        rtn = self:MultipleSummon(self.summonEnemyID1, 1, true);
                        rtn = self:MultipleSummon(self.summonEnemyID2, 1, true);
                    elseif eID1count > eID2count then
                        rtn = self:MultipleSummon(self.summonEnemyID2, 2, true);
                    else
                        rtn = self:MultipleSummon(self.summonEnemyID1, 2, true);
                    end
                elseif friendCount == 3 then
                    -- 既に3体いる場合は少ない方を2体出し、多い方を1体出す
                    if eID1count > eID2count then
                        rtn = self:MultipleSummon(self.summonEnemyID1, 1, true);
                        rtn = self:MultipleSummon(self.summonEnemyID2, 2, true);
                    else
                        rtn = self:MultipleSummon(self.summonEnemyID1, 2, true);
                        rtn = self:MultipleSummon(self.summonEnemyID2, 1, true);
                    end
                else
                    -- 2体ずつ出す
                    rtn = self:MultipleSummon(self.summonEnemyID1, 2, true);
                    rtn = self:MultipleSummon(self.summonEnemyID2, 2, true);
                end
            elseif self.GD.difficultyLevel >= 6 then
                if friendCount == 5 then
                    -- 既に5体いる場合は少ない方を出す
                    if eID1count > eID2count then
                        rtn = self:MultipleSummon(self.summonEnemyID2, 1, true);
                    else
                        rtn = self:MultipleSummon(self.summonEnemyID1, 1, true);
                    end
                else
                    -- 1体ずつ出す
                    rtn = self:MultipleSummon(self.summonEnemyID1, 1, true);
                    rtn = self:MultipleSummon(self.summonEnemyID2, 1, true);
                end
            elseif self.GD.difficultyLevel >= 5 then
            end
        end
    end

    -- 召喚に成功したらInfo出す
    if rtn then
        self:showMessage(self.SUMMON_MESSAGE_LIST, 3);
        self:showMessage(self.SUMMON_MESSAGE_LIST, 4);
    end
end

--雑魚の監視召喚_HP0ギミック用(既に場にいる敵１の数、敵２の数)
function class:hp0friendSummonCheck(eID1count,eID2count)
    local rtn = false
    local friendCount = eID1count + eID2count
    if friendCount == 6 then  --何もしない
    else
        if friendCount == 5 then
            -- 既に5体いる場合は少ない方を出す
            if eID1count > eID2count then
                rtn = self:MultipleSummon(self.summonEnemyID2, 1, true);
            else
                rtn = self:MultipleSummon(self.summonEnemyID1, 1, true);
            end
        elseif friendCount == 4 then
            -- 既に4体いる場合は少ない方を2体出す(同数の場合は1体ずつ出す)
            if eID1count == eID2count then
                rtn = self:MultipleSummon(self.summonEnemyID1, 1, true);
                rtn = self:MultipleSummon(self.summonEnemyID2, 1, true);
            elseif eID1count > eID2count then
                rtn = self:MultipleSummon(self.summonEnemyID2, 2, true);
            else
                rtn = self:MultipleSummon(self.summonEnemyID1, 2, true);
            end
        else
            -- 各々3体になるように出す
            for i = eID1count, 3 - 1 do
                rtn = self:MultipleSummon(self.summonEnemyID1, 1, false);
                if i == 2 then
                    self:showMessage(self.SUMMON_MESSAGE_LIST, 1);
                end
            end

            for i = eID2count, 3 - 1 do
                rtn = self:MultipleSummon(self.summonEnemyID2, 1, false);
                if i == 2 then
                    self:showMessage(self.SUMMON_MESSAGE_LIST, 2);
                end
            end
        end
    end

    -- 召喚に成功したらInfo出す
    if rtn then
        self:showMessage(self.SUMMON_MESSAGE_LIST, 3);
        self:showMessage(self.SUMMON_MESSAGE_LIST, 4);
    end
end

--召喚するエネミーID、召喚回数
function class:MultipleSummon(eID, Num, isInfoDisp)
    local rtn = false
    for i = 1,Num do
        local summonEnemyUnit = self:Summon(self.gameUnit,eID)
        if summonEnemyUnit ~= nil then
            rtn = true
            local hp = 0
            if eID == self.summonEnemyID1 then
                self.eID1summonCount = self.eID1summonCount + 1; -- メルキオンの召喚回数
                hp = (self.gameUnit:getBaseBreakCapacity() * (self.GD.summon1HPBaseRate + self.eID1summonCount * self.GD.summon1HPRate))
                --summoner.Utility.messageByEnemy("eID1:" ..hp.. " " ..self.gameUnit:getBaseBreakCapacity())
            end
            if eID == self.summonEnemyID2 then
                self.eID2summonCount = self.eID2summonCount + 1; -- 竜牙兵の召喚回数
                hp = (self.gameUnit:getCalcHPMAX() * (self.GD.summon2HPBaseRate + self.eID2summonCount * self.GD.summon2HPRate))
                --summoner.Utility.messageByEnemy("eID2:" ..hp)
            end
            summonEnemyUnit:setBaseHP(hp)
            summonEnemyUnit:setHP(hp)
        end
    end

    if isInfoDisp and rtn then
        if eID == self.summonEnemyID1 then
            self:showMessage(self.SUMMON_MESSAGE_LIST, 1);
        end
        if eID == self.summonEnemyID2 then
            self:showMessage(self.SUMMON_MESSAGE_LIST, 2);
        end
    end
    return rtn
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        startAddSP = 40,
        attackDelay = 5,
        hitStop = 100,
        buffValue_56 = 10,
        buffValueCount_56 = 5,

        hateGimmickRate = 1.5,
        hateGimmickBase = 50,
        SPBonusRate = 70,

        difficultyLevel = 15,
        elementTakeDamageValue = 0.01,
        summonTakeDamageValue = {
            0.7,
            0.5,
            0.3,
            0.1,
            0.01,
            0,
        },
        exGageBossTakeDamageValue = 0.01,
        exGagePhysicalTakeDamageValue = 0.01,
        exGageBlindTakeDamageValue = 5.0,
        exGageBrokenbuffTime_89 = 5,
        chargeSec = 3,

        hp60buffValue_23 = -150,
        hp30buffValue_56 = 30,
        hp30AddSP = 40,
        hp0AddSP = 50,
        hp0HealRate = 0.5,

        hpSummonPar = 100,
        attackSummonPar = 50,
        skill1SummonPar = 100,
        skill2SummonPar = 100,

        summon1HPBaseRate = 0.1,
        summon1HPRate = 0.02,
        summon2HPBaseRate = 0.1,
        summon2HPRate = 0.02,

        subBarHPBaseRate = 0.1,
        subBarHPRate = 0.04,

        attack4buffValue_21 = 30,
        skill5buffTime_89 = 2,
        skill5DownSP = 50,
        skill6buffValue_1 = -3000,
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

    ---グランドバトル
    self.gbAreaNumber = megast.Battle:getInstance():getCurrentGrandBattleFloor();
    ---ヘイトギミック
    event.unit:setEnableGBHate(true);
    ---グランドバトルEXボス
    megast.Battle:getInstance():setGBExBossSPBonusRate(self.GD.SPBonusRate);

    ---サブHP表示用
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.subBarFlg = false;
    self.subBarCount = 0;
    self.damage = 0; ---サブバー表示時のダメージ
    self.SUB_HP = event.unit:getCalcHPMAX() * (self.GD.subBarHPBaseRate + (self.subBarCount * self.GD.subBarHPRate));

    ---ボスギミック
    --召喚ギミック
    self.friendCount = 0;   -- 場にいる雑魚敵の数
    self.eID1count = 0  -- 場にいるメルキオンの数
    self.eID2count = 0  -- 場にいる竜牙兵の数
    self.eID1summonCount = 0; -- メルキオンの召喚回数
    self.eID2summonCount = 0; -- 竜牙兵の召喚回数

    --ヘイトギミック
    self.targetUnit = nil;
    self.targetUnitIndex = 0;

    self.skill1Flg = false;
    self.summonFlg = 0;
    self.summonCnt = 0;
    self.targetElementType = -1;
    self.targetElementIcon = 0
    self.isChargingState = 0
    self.chargeCnt = 0

    self.lastSkillFLG = false;

    self.hp0Heal = event.unit:getCalcHPMAX() * self.GD.hp0HealRate;
    self:setIDs();
    return 1
end

function class:setIDs()
    self.summonEnemyID1 = 901060013  --メルキオンのID
    self.summonEnemyID2 = 901060014  --竜牙兵のID
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    -- 暗闇耐性をつける
    if self.GD.buffValueCount_56 ~= 0 then
        for i = 1 , self.GD.buffValueCount_56 do
            self:execAddBuff(self.gameUnit,self.BLINDRESIST_BOX_LIST[1]);
            self:execAddBuff(self.gameUnit,self.BLINDRESIST_BOX_LIST[2]);
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    -- 雑魚敵の人数を常に監視
    local count = self.friendCount
    self:findFriend()
    if count ~= self.friendCount then
        -- 人数に応じてバフを更新する
        self:addFriendBuff(event.unit)
    end

    -- 奥義５発動後
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.skill1Flg then
            self.skill1Flg = false
            if megast.Battle:getInstance():getBattleState() == kBattleState_active then
                ---ヘイトギミック
                self:gbHateTargetCheck(event.unit);
                self:setSkill1Gimmick(event.unit);
            end
        end
    end

    -- 召喚の実行
    self:summonExecute(event.deltaTime)

    ---サブバー表示
    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);
    end

    if self.isChargingState == 1 then
        self:charge(event.deltaTime)---チャージ
    end

    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1
end

function class:findFriend()   --雑魚の監視
    self.friendCount = 0;
    self.eID1count = 0
    self.eID2count = 0
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getEnemyID() == self.summonEnemyID1 then
                -- メルキオンのID
                self.friendCount = self.friendCount + 1;
                self.eID1count = self.eID1count + 1
            end
            if myTeamUnit:getEnemyID() == self.summonEnemyID2 then
                -- 竜牙兵のID
                self.friendCount = self.friendCount + 1;
                self.eID2count = self.eID2count + 1
            end
        end
    end
    if self.friendCount > 6 then
        self.friendCount = 6
    end
end

function class:addFriendBuff(unit)
    local ICON_BUFF_LIST = {
        [1] = {
            ID = 0006,
            BUFF_ID = 0,   --ICON表示用
            VALUE = 0,
            DURATION = 999999,
            ICON = 20,
            COUNT = 0,
            MAX = 99,
        },
    }

    if self.friendCount ~= 0 then
        self:buffRefresh(unit,ICON_BUFF_LIST[1].ID)
        for i = 1, self.friendCount do
            self:execAddBuff(unit,ICON_BUFF_LIST[1])
        end
    else
        self:buffRefresh(unit,ICON_BUFF_LIST[1].ID)
    end
end

-- 召喚の実行（奥義やHPトリガーと同時だとInfoが溢れるので少しだけディレイをかけてる）
function class:summonExecute(deltaTime)
    if self.summonFlg > 0 then
        self.summonCnt = self.summonCnt + deltaTime
        if self.summonCnt > 0.2 then
            local summonpar = 0
            if self.summonFlg == 3 then
                -- HPトリガー
                summonpar = self.GD.hpSummonPar
            elseif self.summonFlg == 2 then
                -- 奥義６
                summonpar = self.GD.skill2SummonPar
            else
                -- 奥義５
                summonpar = self.GD.skill1SummonPar
            end
            self.summonCnt = 0
            self.summonFlg = 0
            ---召喚ギミック
            self:findFriend();
            self:friendSummonCheck(self.eID1count,self.eID2count, summonpar);
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
    ---ゲージ0になった場合非表示
    if self.SUB_HP - damage <= 0 then
        self.hpSkill = 0
        self.isChargingState = 0
        self.subBar:setVisible(false);
        self.subBarFlg = false
        self.damage = 0
        self.gameUnit:setBurstPoint(0)
        self:showMessage(self.EX_GAUGE_BROKEN_MESSAGE_LIST, 1)

        if self.GD.difficultyLevel >= 6 then
            local cond1 = self.gameUnit:getTeamUnitCondition():findConditionWithType(93);
            local cond2 = self.gameUnit:getTeamUnitCondition():findConditionWithType(131);
            if cond1 ~= nil or cond2 ~= nil then
                --暗闇になっていたら暗闇耐性をつける
                for i = 1, 3 do
                    self:execAddBuff(self.gameUnit,self.BLINDRESIST_BOX_LIST[1]);
                    self:execAddBuff(self.gameUnit,self.BLINDRESIST_BOX_LIST[2]);
                end
                self:showMessage(self.EX_GAUGE_BROKEN_MESSAGE_LIST, 2)
            end
        end

        self:buffRefreshAll(self.gameUnit);
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

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    return event.count;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "summonDead" then return self:summonDead(event.unit) end
    return 1;
end

function class:summonDead(unit)
    local number = 0
    local cond = unit:getTeamUnitCondition():findConditionWithID(9010621);
    if cond ~= nil then
        number = cond:getNumber()
        unit:getTeamUnitCondition():removeCondition(cond);
        local cond2 = unit:getTeamUnitCondition():findConditionWithID(9010622);
        if cond2 ~= nil then
            unit:getTeamUnitCondition():removeCondition(cond2);
        end
    end

    if number > 0 then
        for i = 1 , number - 1 do
            self:execAddBuff(self.gameUnit,self.BLINDRESIST_BOX_LIST[1]);
            self:execAddBuff(self.gameUnit,self.BLINDRESIST_BOX_LIST[2]);
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

    if event.index == 4 then
        self:unitAddBuff(self.ATTACK_BUFF);
        ---召喚ギミック
        self:findFriend();
        self:friendSummonCheck(self.eID1count,self.eID2count,self.GD.attackSummonPar);
    end

    if self.isChargingState == 2 then
        self.isChargingState = 0
        self.subBar:setVisible(false);
        self.subBarFlg = false
        self.damage = 0

        if self.GD.difficultyLevel >= 6 then
            local cond1 = self.gameUnit:getTeamUnitCondition():findConditionWithType(93);
            local cond2 = self.gameUnit:getTeamUnitCondition():findConditionWithType(131);
            if cond1 ~= nil or cond2 ~= nil then
                --暗闇になっていたら暗闇耐性をつける
                for i = 1, 3 do
                    self:execAddBuff(self.gameUnit,self.BLINDRESIST_BOX_LIST[1]);
                    self:execAddBuff(self.gameUnit,self.BLINDRESIST_BOX_LIST[2]);
                end
                self:showMessage(self.EX_GAUGE_BROKEN_MESSAGE_LIST, 2)
            end
        end
        self:buffRefreshAll(self.gameUnit);
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

    if event.index == 1 then
        self.skill1Flg = true;
        ---召喚ギミック
        self.summonFlg = 1
    elseif event.index == 2 then
        self:unitAddBuff(self.SKILL_BUFF[1]);
        self:showMessage(self.SKILL2_MESSAGE_LIST);
        ---召喚ギミック
        if self.summonFlg ~= 3 then
            self.summonFlg = 2
        end
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("1-skill3") ---EFのアニメーション名に気をつける
    elseif event.index == 3 then
        if self.isChargingState == 1 then
            self.isChargingState = 2
            event.unit:setInvincibleTime(10)
        end
        if self.GD.difficultyLevel >= 12 then
            if self.TRIGGERS[4].used then
                self.lastSkillFLG = true;
                event.unit:setInvincibleTime(10)
            end
        end
        self:showMessage(self.SKILL3_MESSAGE_LIST)
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
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

function class:setSkill1Gimmick(unit)
    ---サブバー表示
    self.subBarFlg = true;
    self.damage = 0;
    self.subBarCount = self.subBarCount + 1;
    self.SUB_HP = unit:getCalcHPMAX() * (self.GD.subBarHPBaseRate + (self.subBarCount * self.GD.subBarHPRate));
    --self.SUB_HP = (unit:getCalcHPMAX() * (self.GD.subBarHPBaseRate + (self.subBarCount * self.GD.subBarHPRate))) /100;
    --self.SUB_HP = 100000
    self:showMessage(self.EX_GAUGE_MESSAGE_LIST);

    -- チャージ状態
    self:chargeStart()

    ---属性ダーゲットギミック
    self.targetElementType = self:getTargetUnitElementType(self.targetUnitIndex);
    self:showFormatMessage(self.SKILL1_MESSAGE_LIST[1] ,self.ELEMENT_MESSAGE_LIST[self.targetElementType].MESSAGE);
    self:showFormatMessage(self.SKILL1_MESSAGE_LIST[2] ,self.ELEMENT_MESSAGE_LIST[self.targetElementType].MESSAGE);
    self:showFormatMessage(self.SKILL1_MESSAGE_LIST[3] ,self.ELEMENT_MESSAGE_LIST[self.targetElementType].MESSAGE);

    -- 属性耐性アイコンをつける
    self:setTargetElement(self.targetElementType)
    self:execAddBuff(self.gameUnit,self.SKILL_BUFF[3])

    -- 属性ターゲット全員気絶と奥義ゲージダウン
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getElementType() == self.targetElementType then
                self:execAddBuff(myTeamUnit,self.SKILL_BUFF[2]);
                self:findFriend();
                local downSP = myTeamUnit:getBurstPoint() - self.friendCount * self.GD.skill5DownSP
                if downSP < 0 then
                    downSP = 0
                end
                myTeamUnit:setBurstPoint(downSP)
            end
        end
    end
end

function class:setTargetElement(targetElementType)
    if targetElementType == 1 then
        --self.targetElement = 61
        self.targetElementIcon = 38
    end
    if targetElementType == 2 then
        --self.targetElement = 62
        self.targetElementIcon = 39
    end
    if targetElementType == 3 then
        --self.targetElement = 63
        self.targetElementIcon = 40
    end
    if targetElementType == 4 then
        --self.targetElement = 64
        self.targetElementIcon = 41
    end
    if targetElementType == 5 then
        --self.targetElement = 65
        self.targetElementIcon = 42
    end
    self:setBuffBoxList()
end

function class:chargeStart()
    self.hpSkill = 3
    self.gameUnit:setUnitState(3)
    self.isChargingState = 1
    self.afterSkillFLG = true
    self.gameUnit:takeAnimation(0,"charge_loop",true);
    self.gameUnit:takeAnimationEffect(0,"charge_short",true);
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
    --ターゲットのヘイト値を半分にする
    unit:resetGBHate();
    for i = 0, 3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if self.targetUnitIndex ~= myTeamUnit:getIndex() then
                unit:addGBHate(myTeamUnit:getIndex() ,hateValTbl[myTeamUnit:getIndex()]);
            elseif self.targetUnitIndex == myTeamUnit:getIndex() then
                unit:addGBHate(myTeamUnit:getIndex() ,hateValTbl[myTeamUnit:getIndex()] / 2);  --ターゲットのヘイト値を半分に
            end
        end
    end
end

function class:getTargetUnitElementType(targetUnitIndex)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == targetUnitIndex then
                return myTeamUnit:getElementType();
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

    --属性ダメージ補正
    if self.targetElementType == event.enemy:getElementType() then
        event.value = event.value * self.GD.elementTakeDamageValue
    end

    -- 雑魚敵の人数分軽減
    if self.friendCount ~= 0 then
        if self.GD.summonTakeDamageValue[self.friendCount] == 0 then
            event.value = 1
        else
            event.value = event.value * self.GD.summonTakeDamageValue[self.friendCount]
        end
        --summoner.Utility.messageByEnemy(self.GD.summonTakeDamageValue[self.friendCount])
    end

    ---サブバー表示時
    if self.subBarFlg then
        local exDamage = event.value;
        -- 暗闇状態のとき被ダメージアップ
        local cond1 = event.unit:getTeamUnitCondition():findConditionWithType(93);
        local cond2 = event.unit:getTeamUnitCondition():findConditionWithType(131);
        if cond1 ~= nil or cond2 ~= nil then
            exDamage = exDamage * self.GD.exGageBlindTakeDamageValue
        end

        -- 物理耐性
        local attackType = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attackType == 1 then
            exDamage = exDamage * self.GD.exGagePhysicalTakeDamageValue
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

---召喚系
---------------------------
function class:Summon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                local addUnit = unit:getTeam():addUnit(i,unitID)
                return addUnit
            end
        end
    end
    return nil
end

--function class:MultipleSummon(unit,unitID,Num)
--    for i = 1,Num do
--        self:summon(unit,unitID)
--    end
--end


class:publish();

return class;