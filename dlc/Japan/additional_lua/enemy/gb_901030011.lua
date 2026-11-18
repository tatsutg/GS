local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星15_氷塊砦オ＝ザグン", version=2.0, id="gb_901030011"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK5 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    },
    ATTACK3 = {
        { ATTACK3 = 50 }
    },
    RAGE = {
        { ATTACK4 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 }
    },
    HP0 = {
        { SKILL4 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    ATTACK7 = 7,
    ATTACK8 = 8,
    SKILL1 = 9,
    SKILL2 = 10,
    SKILL3 = 11,
    SKILL4 = 12
}

class.cutInSkill = {
    [1] = 1,
    [2] = 1,
    [3] = 1,
    [4] = 1
}

---オ＝ザグン共通
--===============================================================================================================================================
class.BONE_NAMES = {
    FIRST = "L_arm3_hand_4",
    SECOND = "Glab"
}

--setActiveSkill関連
--投擲物:AX,BONE,IRON
--毒瓶:POISON
class.ORBIT_ARGS = {
    AX = {
        start = "goblin_ax",
        finish = "goblin_axEnd",
        activeSkill = 6
    },
    BONE = {
        start = "goblin_bone",
        finish = "goblin_bone_bound",
        activeSkill = 6
    },
    IRON = {
        start = "goblin_iron-ball",
        finish = "goblin_iron-ballEnd",
        activeSkill = 6
    },
    POISON = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 7
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

class.RAGE_HP = 0.8;
class.RAGE_ATTACK_INDEX = 3;
class.GRENADE_RECAST = 10;  --投擲の頻度

class.WEAPON_HP = 100000;

class.SUMMON_ENEMY_ID = 48924;
class.SUMMON_DELAY = 20;


--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 9010301,
            BUFF_ID = 89,  --気絶
            VALUE = 100,
            DURATION = self.GD.buffTime_89,
            ICON = 0
        },
        [2] = {
            ID = 9010302,
            BUFF_ID = 1,  --HP固定値
            VALUE = self.GD.buffValue_1,
            DURATION = 999999,
            ICON = 2,
            COUNT = 0,
            MAX = 99
        },
        [3] = {
            ID = 9010303,
            BUFF_ID = 21,  --被ダメUP
            VALUE = self.GD.buffValue_21,
            DURATION = 999999,
            ICON = 139,
            COUNT = 0,
            MAX = 99
        },
        [4] = {
            ID = 9010304,
            BUFF_ID = 23,  --クリティカル耐性UP
            VALUE = self.GD.buffValue_23,
            DURATION = 999999,
            ICON = 188
        }
    }
    self.RESISTANCE_BUFF_LIST = {
        [1] = {
            ID = 9010305,
            BUFF_ID = 0, --麻痺耐性ダウンアイコン用
            VALUE = 0,
            DURATION = 999999,
            ICON = 70
        },
        [2] = {
            ID = 9010306,
            BUFF_ID = 0, --気絶耐性ダウンアイコン用
            VALUE = 0,
            DURATION = 999999,
            ICON = 68
        }
    }
    self.AURA_BUFF_LIST = {
        [1] = {
            ID = 9010310,
            BUFF_ID = 0, --オーラ用
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "与ダメージの大きい者へのダメージアップ", COLOR = Color.yellow})
    }
    self.START2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START2_MESSAGE1 or "闇属性ユニットからのダメージを軽減", COLOR = Color.yellow})
    }
    self.PRAYER_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.PRAYER_MESSAGE1 or "奥義ゲージ上昇無効", COLOR = Color.red, isPlayer = true }),
        self:setMessageInfo({MESSAGE = self.TEXT.PRAYER_MESSAGE2 or "被ダメージで奥義ゲージ上昇", COLOR = Color.red, isPlayer = true })
    }
    self.RAGE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.RAGE_MESSAGE1 or "怒り状態：麻痺・気絶・ブレイクで解除", COLOR = Color.red})
    }
    self.CHILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.CHILL_MESSAGE1 or "巨人の怒りを鎮めた！", COLOR = Color.white})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "パーティの最大HPダウン", COLOR = Color.red})
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "クリティカル耐性アップ", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "HP回復・奥義上昇量アップ", COLOR = Color.yellow})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {}
    if self.GD.difficultyLevel >= 9 then
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
                action = function (status) self:hp20(status) end,
                HP = 20,
                used = false,
                isEnableSkip = false
            },
            [3] = {
                tag = "HP_FLG",
                action = function (status) self:hp0(status) end,
                HP = 0.1,
                used = false,
                isEnableSkip = false
            }
        }
    elseif self.GD.difficultyLevel >= 6 then
        self.TRIGGERS = {
            [1] = {
                tag = "HP_FLG",
                action = function (status) self:hp60(status) end,
                HP = 60,
                used = false,
                isEnableSkip = false
            }
        }
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

function class:hp60(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 2
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(20)
        self.spValue = self.GD.hpAddSP_1
        self:deBuffRefresh(self.gameUnit)
        self:showMessage(self.HP60_MESSAGE_LIST)
    end
end

function class:hp20(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 3
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(20)
        self:deBuffRefresh(self.gameUnit)
        self:execAddBuff(self.gameUnit,self.BUFF_LIST[4])
        self:showMessage(self.HP20_MESSAGE_LIST)
    end
end

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 4
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:deBuffRefresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(20)
        if self.GD.difficultyLevel >= 15 then
            self.gameUnit:takeHeal(self.healValue)  --ボスHP回復
            self:initSkillWeight({HP0 = 100})
            self.spValue = self.GD.hpAddSP_2
            self:showMessage(self.HP0_MESSAGE_LIST)
        end
    end
end

--状態異常除去
function class:deBuffRefresh(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97};
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
        addSP = 20,
        attackDelay = 7,
        hitStop = 100,

        difficultyLevel = 15,
        SPBonusRate = 70,
        hateGimmickRate = 1.5,
        hateGimmickBase = 50,

        rageAttackDelay = 5,
        downBurstPoint = 300,
        resistanceValue_1 = 150,
        resistanceValue_2 = 70,
        darkUnitDmgVal = 0.1,
        hpAddSP_1 = 30,
        hpAddSP_2 = 50,
        healValue = 0.2,
        buffValue_1 = -2000,
        buffValue_21 = 30,
        buffValue_23 = -150,
        buffTime_89 = 10,

        grenadeRecast = 10,
        goblinAnimeRand = 50,
        orbitAXRand = 25,
        orbitBoneRand = 50,
        orbitIronRand = 75
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;

    self.gbAreaNumber = megast.Battle:getInstance():getCurrentGrandBattleFloor();
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    --event.unit:addSP(self.gbAreaNumber * self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
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
    if self.GD.difficultyLevel >= 6 then
        self:showMessage(self.START2_MESSAGE_LIST)
    end
    self:showMessage(self.PRAYER_MESSAGE_LIST)

    self.stateName = "NORMAL"
    self.breakSkip = true
    self.hpSkill = 0
    self.saveBP = 0

    ---ヘイトギミック
    event.unit:setEnableGBHate(true);
    ---グランドバトルEXボス
    megast.Battle:getInstance():setGBExBossSPBonusRate(self.GD.SPBonusRate);
    ---ボスギミック
    self.nextGlabTargetIndex = 0
    self.attack3Flg = false
    self.rageIdleFlg = false
    self.healValue = event.unit:getCalcHPMAX() * self.GD.healValue  --最大体力の20%
    self.skillIDs = {}
    self:setSkillIDTbl()

    ---オ＝ザグンの変数たち
    --つかみ関連の変数たち
    self.glabTargetIndex = nil;
    self.glabBoneName = "";
    self.tryGlab = false;
    self.isGlab = false;
    self.attack5Flg = false;

    --掴み投げのSkillIndex
    self.throwSkillIndex = 8

    --投擲物関連のSkillIndex
    self.orbitSkillIndex = 6  --投擲物
    self.poisonSkillIndex = 7  --毒瓶

    --投擲物の頻度
    self.GRENADE_RECAST = self.GD.grenadeRecast

    --投擲物関連の変数たち
    self.grenadeTimer = 0;
    self.granedeTargetIndex = 0;
    self.myself = nil
    self.BeforetargetUnitIndex = 0
    self.bullets = {}
    self.bulletinfo = {
        new = function (_bullet,_targetUnit,_otherparam)
            return {
                bullet = _bullet,
                targetUnit = _targetUnit,
                jimen = 0,
                endAnimationName = "",
                frame = 0,
                angle = 0,
                posx = 0,
                posy = 0,
                speedkeisuu = 1,
                yield = true
            }
        end
    }

    --武器状態の変数たち
    self.state = 0;
    self.startBreakPoint = 0;--バトル開始時から抜刀時までのブレイクダメージ合計を入れる
    self.attackDelayDefault = event.unit:getAttackDelay();

    --足を表示
    event.unit:addSubSkeleton("50004_leg",-30);
    event.unit:setSkin("1");
    return 1
end

function class:setSkillIDTbl()
    --星15 データskill_id
    self.skillIDs = {
        60035200,  --麻痺耐性
        60035300   --気絶耐性
    }
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:hpTriggersCheck(event.unit)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    ---ボスギミック
    --奥義中か確認
    if not event.unit:isBreak() then
        --攻撃中か確認
        if self.attack3Flg and event.unit:getUnitState() ~= kUnitState_attack then
            self.attack3Flg = false
            self:rageMode(event.unit)
        end
    end

    if self.isRage then
        local stun = event.unit:getTeamUnitCondition():findConditionWithType(89);
        local palsy = event.unit:getTeamUnitCondition():findConditionWithType(91);
        if stun ~= nil or palsy ~= nil or event.unit:isBreak() then
            self:chillMode(event.unit)
        end
    end

    ---死亡時処理
    if self.GD.difficultyLevel >= 15 then  --難易度15は何もしない
    elseif self.GD.difficultyLevel >= 9 then  --難易度9
        if megast.Battle:getInstance():getBattleState() == kBattleState_active then
            if self.lastSkillFLG == nil then self.lastSkillFLG = false end
            if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
                event.unit:getTeam():deadUnit(event.unit:getIndex());
                megast.Battle:getInstance():waveEnd(true);
            end
            if self.TRIGGERS[3].used then
                if self.deadCount == nil then self.deadCount = 0 end
                self.deadCount = self.deadCount + event.deltaTime
                if self.deadCount >= 20 then
                    event.unit:getTeam():deadUnit(event.unit:getIndex());
                    megast.Battle:getInstance():waveEnd(true);
                end
            end
        end
    end

    ---オ＝ザグン ギミック
    --投擲
    self:grenadeCheck(event.deltaTime);
    --掴み
    if self.isGlab and self.glabTargetIndex ~= nil then
        self:glabControll(event.unit);
    end
    --武器状態
    --if self.state == self.WEAPON_STATES.HUMMER then
    --    self:weaponCheck(event.unit);
    --end
    return 1
end

function class:rageMode(unit)
    self.isRage = true
    self.rageIdleFlg = false
    unit:setAttackDelay(self.GD.rageAttackDelay)
    self:initAttackWeight({RAGE = 100})
    self:execAddBuff(unit,self.RESISTANCE_BUFF_LIST[1])
    self:execAddBuff(unit,self.RESISTANCE_BUFF_LIST[2])
    self:execAddBuff(unit,self.AURA_BUFF_LIST[1])
    self:resistanceChange(unit,self.GD.resistanceValue_2)
    self:showMessage(self.RAGE_MESSAGE_LIST)
end

function class:chillMode(unit)
    self.isRage = false
    unit:setAttackDelay(self.GD.attackDelay)
    self:initAttackWeight({DEFAULT = 100})
    self:resistanceChange(unit,self.GD.resistanceValue_1)
    self:showMessage(self.CHILL_MESSAGE_LIST)
    local buffTbl = { self.RESISTANCE_BUFF_LIST[1].ID,
                      self.RESISTANCE_BUFF_LIST[2].ID,
                      self.AURA_BUFF_LIST[1].ID
    }
    for i,id in pairs(buffTbl) do
        local cond = unit:getTeamUnitCondition():findConditionWithID(id);
        if cond ~= nil then
            unit:getTeamUnitCondition():removeCondition(cond);
        end
    end
end

function class:resistanceChange(unit,buffValue)
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            for l,id in pairs(self.skillIDs) do
                if cond:getID() == id then
                    cond:setValue(buffValue)
                end
            end
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "goblinAttack" then return self:goblinAttack(event.unit) end
    if event.spineEvent == "glab" then self:glab(event.unit) end
    if event.spineEvent == "throw" then self:throw(event.unit) end
    if event.spineEvent == "throwEnd" then self:throwEnd(event.unit) end
    if event.spineEvent == "lunchPoisonGrenade" then self:lunchPoisonGrenade(event.unit) end
    if event.spineEvent == "checkGlabSucsess" and self.tryGlab then self:checkGlabSucsess(event.unit) end
    --if event.spineEvent == "lunchOther" then self:lunchOther(event.unit) end
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

    self.isGlab = false;
    self.glabTargetIndex = nil;
    if event.index == 3 then
        self.attack3Flg = true
    elseif event.index == 4 then
        self:addSkillBuff(self.BUFF_LIST[3])
    elseif event.index == 5 then
        self.attack5Flg = true;
        event.unit:setNextAnimationName("attack5");
        event.unit:setNextAnimationEffectName("1-attack5");
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

    self.isGlab = false;
    self.glabTargetIndex = nil;
    if event.index == 1 then
        if not self.isRage then
            self.rageIdleFlg = true
            self:initAttackWeight({ATTACK3 = 100})
        end

        self:addSkillBuff(self.BUFF_LIST[2])
        self:showMessage(self.SKILL_MESSAGE_LIST)
    elseif event.index == 4 then
        self.lastSkillFLG = true
    end

    if event.index == 1 or event.index == 2 or event.index == 3 or event.index == 4 then
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

function class:addSkillBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    self.isGlab = false;
    self.glabTargetIndex = nil;
    return 1;
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.tryGlab then
        if self.glabTargetIndex == nil then
            --self.glabTargetIndex = self:checkTarget(event.unit)
            self:targetUnitAddBuff(self.glabTargetIndex)
            self:checkGlabSucsess(event.unit);
        end
    end

    local enemyUnit = self:getAncestorUnit(event.enemy)
    local gbHatePercent = event.unit:getGBHatePercent(enemyUnit:getIndex())
    local rate = ((gbHatePercent * self.GD.hateGimmickRate) + self.GD.hateGimmickBase) / 100
    --summoner.Utility.messageByEnemy(gbHatePercent.."/"..rate)
    event.value = event.value * rate
    return event.value
end

---掴みのターゲットの条件を書く
function class:checkTarget(unit)
    local flg = false
    local targetIndex = self.nextGlabTargetIndex
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,7 do
        local myTeamUnit = myTeam:getTeamUnit(i,true)
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == targetIndex then
                --HP0なら次のユニットへ
                if myTeamUnit:getHP() <= 0 then
                    targetIndex = targetIndex + 1
                    if targetIndex == 4 then
                        flg = true
                        targetIndex = 0
                    end
                else
                    self.nextGlabTargetIndex = targetIndex + 1
                    if self.nextGlabTargetIndex == 4 then
                        self.nextGlabTargetIndex = 0
                    end
                    return targetIndex
                end
            end
        end
    end

    if flg then
        for i = 0,7 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                targetIndex = myTeamUnit:getIndex()
                self.nextGlabTargetIndex = targetIndex + 1
                if self.nextGlabTargetIndex == 4 then
                    self.nextGlabTargetIndex = 0
                end
                return targetIndex
            end
        end
    end
    return targetIndex
end

function class:targetUnitAddBuff(targetIndex)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,7 do
        local myTeamUnit = myTeam:getTeamUnit(i,true)
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == targetIndex then
                myTeamUnit:setBurstPoint(myTeamUnit:getBurstPoint() - self.GD.downBurstPoint);
                self:execAddBuff(myTeamUnit,self.BUFF_LIST[1])
            end
        end
    end
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
    if self.GD.difficultyLevel >= 6 then
        --闇属性ユニット判定
        local enemyElementType = enemyUnit:getElementType()
        if enemyElementType == 5 then
            event.value = event.value * self.GD.darkUnitDmgVal
        end
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
    if not self.isRage then
        event.unit:setNextAnimationName("idle")
        event.unit:setNextAnimationEffectName("empty")
    else
        event.unit:setNextAnimationName("idle2")
        event.unit:setNextAnimationEffectName("empty")
    end

    if self.rageIdleFlg then
        event.unit:setNextAnimationName("idle2")
        event.unit:setNextAnimationEffectName("empty")
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.GD.difficultyLevel >= 15 then  --難易度15
    elseif self.GD.difficultyLevel >= 9 then  --難易度9
        return 0
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
    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index)
        return;
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
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
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


--===============================================================================================================================================
--状態変化関連のメソッド/
--------------------
function class:getRage(unit)
    self.state = self.WEAPON_STATES.HUMMER;
    unit:setAttackDelay(0);
    self.startBreakPoint = unit:getRecordBreakPoint();
end

function class:weaponCheck(unit)
    local weaponDamage = unit:getRecordBreakPoint() - self.startBreakPoint;
    self:subBarControll(unit,weaponDamage);
    if weaponDamage >= self.WEAPON_HP and self:isHost() and unit.m_breaktime <= 0 then
        self:weaponBreak(unit);
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,6,0);
    end
end

function class:weaponBreak(unit)
    self.state = self.WEAPON_STATES.BREAKED;
    self.subBar:setVisible(false);
    unit:setAttackDelay(self.attackDelayDefault);
    unit:takeAnimation(0,"damage2",false);
    unit:takeAnimationEffect(0,"damage2",false);
    unit:setSetupAnimationName("setUpWeaponBreaked");
    --unit:setReduceHitStop(0,0);--ヒットストップ無効解除
    unit:setSkin("2");
end

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

--===============================================================================================================================================
--掴み投げ関連のメソッド/
--------------------
function class:glab(unit)
    self.tryGlab = true;
end

function class:isHost()
    return megast.Battle:getInstance():isHost();
end

function class:getUnitByIndex(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

function class:checkGlabSucsess(unit)
    if not self:isHost() then
        return;
    end

    self.glabTargetIndex = self:checkTarget(unit)

    self.tryGlab = false;
    if self.glabTargetIndex ~= nil then
        self:glabExecute(unit,self.glabTargetIndex);
        --self:showMessage(self.GRAD_MESSAGE_LIST)
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,7,self.glabTargetIndex);
    else
        self:glabFaild(unit);
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,8,0);
    end
end

function class:glabExecute(unit,index)
    self.glabBoneName = self.BONE_NAMES.FIRST;
    self.isGlab = true;
    unit:setAnimation(0,"skill1_throw",false);
    self:getUnitByIndex(index):getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFID,self.STAN_BUFFEFDURATION,0);
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

    if self.attack5Flg then
        self.attack5Flg = false;
        self:addSP(self.gameUnit)
    end

    local hit = unit:addOrbitSystem("GrowndHit");
    self.gameUnit:takeHitStop(0.5);
    hit:setPosition(glabUnit:getPositionX(),glabUnit:getPositionY());
    hit:setTargetUnit(glabUnit);
    hit:setHitType(2);
    hit:setActiveSkill(self.throwSkillIndex);
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

    glabUnit:getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFID,self.STAN_BUFFEFDURATION,0);
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
    if self.grenadeTimer > self.GRENADE_RECAST and self:isHost() then
        self.grenadeTimer = 0;
        local rand = LuaUtilities.rand(0,100);
        if rand < self.GD.goblinAnimeRand then
            self:takePoisonGrenadeAnimation(self.gameUnit);
            --megast.Battle:getInstance():sendEventToLua(self.scriptID,9,0);
        else
            self:takeOtherAnimation(self.gameUnit,rand);
            --megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
        end
    end
end

function class:takePoisonGrenadeAnimation(unit)
    unit:setAnimation(1,"goblin_attack",false);
end

function class:takeOtherAnimation(unit)
    unit:setAnimation(1,"goblin_attack2",false);
end

function class:lunchPoisonGrenade(unit)
    self:lunch(unit,self.ORBIT_ARGS.POISON);
end

function class:goblinAttack(unit)
    if unit:getHP() <= 0 then
        return 0;
    end

    unit:setTargetUnit(megast.Battle:getInstance():getTeam(true):getTeamUnit(self.BeforetargetUnitIndex));
    if unit:getTargetUnit() ~= nil then
        local rand = LuaUtilities.rand(0,100);
        local animationStr = "";
        local endAnimationName = "";
        local vanishAnimationName = "";
        local speed = 10;
        local activeSkillNum = 0;
        if rand < self.GD.orbitAXRand then
            activeSkillNum = self.orbitSkillIndex;
            animationStr = "goblin_ax";
            endAnimationName = "goblin_attack";
            vanishAnimationName = "goblin_axEnd";
        elseif rand < self.GD.orbitBoneRand then
            activeSkillNum = self.orbitSkillIndex;
            animationStr = "goblin_bone"
            endAnimationName = "goblin_attack";
            vanishAnimationName = "goblin_bone_bound";
        elseif rand < self.GD.orbitIronRand then
            activeSkillNum = self.orbitSkillIndex;
            animationStr = "goblin_iron-ball"
            endAnimationName = "goblin_attack";
            vanishAnimationName = "goblin_iron-ballEnd";
        else
            activeSkillNum = self.poisonSkillIndex;
            animationStr = "goblin_poison"
            endAnimationName = "goblin_poison_dusty";
            vanishAnimationName = "goblin_poison_dusty";
        end

        local bullet = unit:addOrbitSystem(animationStr,1);
        bullet:takeAnimation(0,animationStr,true);
        bullet:setHitCountMax(1);
        bullet:setEndAnimationName(endAnimationName);
        --bullet:getTeamUnitCondition():addCondition(-12,35,0,25,0);
        bullet:setActiveSkill(activeSkillNum);
        local x = unit:getPositionX()
        local y = unit:getPositionY()
        local xb = unit:getSkeleton():getBoneWorldPositionX("gobul_top");
        local yb = unit:getSkeleton():getBoneWorldPositionY("gobul_top");
        bullet:setPosition(x+xb,y+yb);

        local targetx = unit:getTargetUnit():getPositionX();
        local targety = unit:getTargetUnit():getPositionY();

        LuaUtilities.runJumpTo(bullet,3,targetx , targety,400,1);
        local t = self.bulletinfo.new(bullet,unit:getTargetUnit():getIndex(),0);
        t.jimen = unit:getTargetUnit():getPositionY() + 10;
        t.endAnimationName = vanishAnimationName;
        t.speedkeisuu = speed;
        table.insert(self.bullets,t);
    end
    return 1
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
--マルチ同期/
----------
--function class:receive4(args)
--    self:takeOtherAnimation(self.gameUnit);
--    return 1;
--end
--
--function class:receive6(args)
--    self:weaponBreak(self.gameUnit);
--    return 1;
--end
--
--function class:receive7(args)
--    self.glabTargetIndex = args.arg;
--    self:glabExecute(self.gameUnit,args.arg);
--    return 1;
--end
--
--function class:receive8(args)
--    self:glabFaild(self.gameUnit);
--    return 1;
--end
--
--function class:receive9(args)
--    self:takePoisonGrenadeAnimation(self.gameUnit);
--    return 1;
--end
--
--function class:receive10(args)
--    self:getRage(self.gameUnit);
--    return 1;
--end


class:publish();

return class;