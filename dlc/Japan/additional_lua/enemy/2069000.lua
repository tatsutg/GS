--@additionalEnemy,2069003
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超神級_ゴールドーラ", version=2.0, id=2069000});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50, ATTACK5 = 50 },
        { ATTACK4 = 50 },
        { ATTACK1 = 50 },
        { ATTACK2 = 50, ATTACK5 = 50 },
        { ATTACK3 = 50 },
        { ATTACK2 = 50, ATTACK5 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
        { SKILL1 = 50 },
        { SKILL2 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL1 = 6,
    SKILL2 = 7
}

class.cutInSkill = {
    --[3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.SKILL1_BUFF_LIST = {
        [1] = {
            ID = 2069001,
            BUFF_ID = 13,  --攻撃力ダウン
            VALUE = self.GD.buffVal_13,
            DURATION = 99999,
            ICON = 4,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 2069002,
            BUFF_ID = 89,  --気絶効果
            VALUE = 100,
            DURATION = self.GD.buffTime_89,
            ICON = 79
        }
    }
    self.SKILL2_BUFF_LIST = {
        [1] = {
            ID = -2069003,
            BUFF_ID = 21,  --被ダメージアップ
            VALUE = self.GD.buffVal_21,
            DURATION = 999999,
            ICON = 139,
        },
        [2] = {
            ID = 2069004,
            BUFF_ID = 53,  --毒耐性ダウン
            VALUE = self.GD.buffVal_53,
            DURATION = 999999,
            ICON = 69,
            COUNT = 0,
            MAX = 99
        },
        [3] = {
            ID = 2069005,
            BUFF_ID = 102,  --毒回避率
            VALUE = self.GD.buffVal_53,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 99
        },
    }
    self.HP_BUFF_LIST = {
        [1] = {
            ID = 2069006,
            BUFF_ID = 13, -- 攻撃力
            VALUE = self.GD.hpBuffVal_13,
            DURATION = 999999,
            ICON = 3
        },
        [2] = {
            ID = 2069007,
            BUFF_ID = 60,  --燃焼耐性
            VALUE = self.GD.hpBuffVal_60_1,
            DURATION = 999999,
            ICON = 66
        },
        [3] = {
            ID = -2069008,
            BUFF_ID = 60,  --燃焼耐性
            VALUE = self.GD.hpBuffVal_60_2,
            DURATION = 999999,
            ICON = 66
        },
        [4] = {
            ID = 2069009,
            BUFF_ID = 23,  --クリティカル耐性
            VALUE = self.GD.hpBuffVal_23,
            DURATION = 99999,
            ICON = 188
        }
    }
    self.SUMMON_DEAD_BUFF = {
        [1] = {
            ID = 2069020,
            BUFF_ID = 17,  --クリティカルダメージUP
            VALUE = self.GD.buffVal_17_2,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99,
            SCRIPT = {
                SCRIPT_ID = 22
            }
        },
        [2] = {
            ID = 2069021,
            BUFF_ID = 0,  --被ダメUPアイコン用
            VALUE = 0,
            DURATION = 999999,
            ICON = 139,
            COUNT = 0,
            MAX = 99
        },
    }
    self.COUNT_BUFF_LIST = {
        [1] = {
            ID = 2069100,
            BUFF_ID = 0,  --召喚カウント用
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        }
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 2069050,
        BUFF_ID = 23,---被クリティカル率
        VALUE = self.GD.targetBuff_23,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 2069050,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "水属性耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "燃焼時、被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ダメージの大きい者をターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ターゲットへのクリティカル率アップ", COLOR = Color.yellow})
    }
    self.SKILL1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE1 or "%sの攻撃力・奥義ゲージ低下", COLOR = Color.red})
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "グランドクライ：ダメージ無効化無効", COLOR = Color.yellow})
    }
    self.HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE1 or "燃焼耐性・攻撃力アップ", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "燃焼耐性・奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "燃焼耐性・クリティカル耐性アップ", COLOR = Color.yellow})
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "モルドーラ：装備以外のダメージを軽減", COLOR = Color.green})
    }
    self.SUMMON_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_DEAD_MESSAGE1 or "モルドーラ討伐成功！", COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_DEAD_MESSAGE2 or "ボスの被ダメージ・CRIダメージアップ", COLOR = Color.green})
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
            action = function (status) self:hp20(status) end,
            HP = 20,
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

function class:hp80(status)
    if status == "use3" then
        self.stateName = "FURY"
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[1])
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[2])
        if self.startHp > 80 then
            if megast.Battle:getInstance():isHost() then
                self.hpSkill = 2
                self.saveBP = self.gameUnit:getBurstPoint()
                self.gameUnit:addSP(100)
            end
            self.cutInFLG = true
            self.hpSkillFlg = true
            self.gameUnit:setInvincibleTime(30)
            self:showMessage(self.HP80_MESSAGE_LIST)
            self:buffRefresh(self.gameUnit)
        end
    end
end

function class:hp50(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hp50Flg = true
        self.spValue = self.GD.hpAddSP;
        self.gameUnit:setAttackDelay(self.GD.hpAttackDelay);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[3])
        if self.startHp > 50 then
            if megast.Battle:getInstance():isHost() then
                self.hpSkill = 2
                self.saveBP = self.gameUnit:getBurstPoint()
                self.gameUnit:addSP(100)
            end
            self.cutInFLG = true
            self.hpSkillFlg = true
            self.gameUnit:setInvincibleTime(30)
            self:showMessage(self.HP50_MESSAGE_LIST)
            self:buffRefresh(self.gameUnit)
            self:findFriend()
            self:hpSummon(self.gameUnit,self.friendCount)
        end
    end
end

function class:hp20(status)
    if status == "use3" then
        self.stateName = "FURY"
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[3])
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[4])
        if self.startHp > 20 then
            if megast.Battle:getInstance():isHost() then
                self.hpSkill = 2
                self.saveBP = self.gameUnit:getBurstPoint()
                self.gameUnit:addSP(100)
            end
            self.cutInFLG = true
            self.hpSkillFlg = true
            self.gameUnit:setInvincibleTime(30)
            self:showMessage(self.HP20_MESSAGE_LIST)
            self:buffRefresh(self.gameUnit)
        end
    end
end

function class:buffRefresh(unit)
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

function class:hpSummon(unit,friendCount)
    if friendCount < 5 then
        self:MultipleSummon(self.gameUnit,self.summonUnitID,1)
        self:showMessage(self.SUMMON_MESSAGE_LIST)
    end

    self:findFriend()
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.COUNT_BUFF_LIST[1].ID);
    if cond ~= nil then
        cond:setValue(self.friendCount)
    end
    return 1
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        attackDelay = 7,
        hitStop = 100,
        hpAddSP = 30,
        hpAttackDelay = 2,

        barnDmgVal_1 = 1.0,
        barnDmgVal_2 = 0.2,
        barnDmgVal_3 = 0.01,
        barnDmgVal_4 = 0.05,

        summonPar1 = 30,
        summonPar2 = 5,
        summonPar3 = 50,
        summonPar4 = 10,

        buffVal_13 = -20,
        buffVal_17_1 = 20,
        buffVal_17_2 = 40,
        buffVal_21 = 30,
        buffVal_53 = -20,
        targetBuff_23 = 200,
        hpBuffVal_13 = 50,
        hpBuffVal_60_1 = 30,
        hpBuffVal_60_2 = 20,
        hpBuffVal_23 = 150,
        buffTime_89 = 3
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    --event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
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

    self.startHpFLG = true
    self.hp50Flg = false
    self.hpSkillFlg = false
    self.friendCount = 0
    self.friendDeadCount = 0
    self.summonUnitID = 2069003
    self.buffIDList = {89,90,91,92,93,94,95,97,129,131,135}

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnitList = {}
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:execAddBuff(event.unit,self.COUNT_BUFF_LIST[1])  --召喚カウント用
    self:findFriend()
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---継戦時HP管理
    if self.startHpFLG then
        self.startHpFLG = false
        if megast.Battle:getInstance():isHost() then
            self.startHp = summoner.Utility.getUnitHealthRate(self.gameUnit) * 100
            if self.startHp <= 0.1 then
                self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * 0.03)
            end
            megast.Battle:getInstance():sendEventToLua(self.scriptID,7,event.unit:getHP());
            megast.Battle:getInstance():sendEventToLua(self.scriptID,9,self.startHp);
        end
    end

    ---召喚数ギミック
    local cont = self.friendDeadCount
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.COUNT_BUFF_LIST[1].ID);
    if cond ~= nil then
        self:friendDeadCheck(event.unit,cond:getValue(),self.friendCount)
    end

    if cont ~= self.friendDeadCount then
        self:friendDeadBuff(event.unit,cont,self.friendDeadCount)
    end
    self:findFriend()

    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    return 1
end

function class:friendDeadCheck(unit,countBuffVal,friendCount)
    if countBuffVal ~= friendCount then
        local cond = unit:getTeamUnitCondition():findConditionWithID(self.COUNT_BUFF_LIST[1].ID);
        if cond ~= nil then
            for i = countBuffVal + 1 ,friendCount do
                self.friendDeadCount = self.friendDeadCount + 1
            end
        end
    end
end

function class:friendDeadBuff(unit,count,deadCount)
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.COUNT_BUFF_LIST[1].ID);
    if cond ~= nil then
        for i = count + 1, deadCount do
            self:execAddBuff(unit,self.SUMMON_DEAD_BUFF[1])
            self:execAddBuff(unit,self.SUMMON_DEAD_BUFF[2])
            self:showMessage(self.SUMMON_DEAD_MESSAGE_LIST)
        end

        self:findFriend()
        cond:setValue(self.friendCount)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,8,deadCount);
    end
end

function class:findFriend()   --雑魚の監視
    self.friendCount = 0
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getUnitID() == 500951313 then   --モルドーラの数
                self.friendCount = self.friendCount + 1
            end
        end
    end
end

function class:receive7(args)
    self.gameUnit:setHP(args.arg)
    return 1
end

function class:receive8(args)
    if args.arg == 0 then
        self:showMessage(self.SUMMON_MESSAGE_LIST)
    elseif args.arg == 100 then
        self:findFriend()
        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.COUNT_BUFF_LIST[1].ID);
        if cond ~= nil then
            cond:setValue(self.friendCount)
        end
    else
        local cont = self.friendDeadCount
        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.COUNT_BUFF_LIST[1].ID);
        if cond ~= nil then
            for i = cont + 1, args.arg do
                self.friendDeadCount = self.friendDeadCount + 1
                self:execAddBuff(self.gameUnit,self.SUMMON_DEAD_BUFF[1])
                self:execAddBuff(self.gameUnit,self.SUMMON_DEAD_BUFF[2])
                self:showMessage(self.SUMMON_DEAD_MESSAGE_LIST)
            end
            self:findFriend()
            cond:setValue(self.friendCount)
        end
    end
    return 1
end

function class:receive9(args)
    self.startHp = args.arg
    if self.startHp <= 0.1 then
        self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * 0.03)
    end
    return 1
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

    self.hpSkillFlg = false
    if event.index == 2 then
        if megast.Battle:getInstance():isHost() then
            self:findFriend()
            self:summonCount(event.unit,self.friendCount)  --召喚
        end
    elseif event.index == 4 then
        if megast.Battle:getInstance():isHost() then
            self:findFriend()
            self:attack4Summon(event.unit,self.friendCount)  --召喚
        end
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
    megast.Battle:getInstance():sendEventToLua(self.scriptID,6,self.startHp);
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end

function class:summonCount(unit,friendCount)
    if friendCount < 5 then
        local summonFlg = false
        local rand = math.random(0,100)
        if not self.hp50Flg and friendCount == 0 then
            if rand <= self.GD.summonPar1 then
                summonFlg = true
            end
        elseif not self.hp50Flg and friendCount ~= 0 then
            if rand <= self.GD.summonPar2 then
                summonFlg = true
            end
        elseif  self.hp50Flg and friendCount == 0 then
            if rand <= self.GD.summonPar3 then
                summonFlg = true
            end
        elseif  self.hp50Flg and friendCount ~= 0 then
            if rand <= self.GD.summonPar4 then
                summonFlg = true
            end
        end

        if summonFlg then
            self:MultipleSummon(self.gameUnit,self.summonUnitID,1)
            self:showMessage(self.SUMMON_MESSAGE_LIST)
            megast.Battle:getInstance():sendEventToLua(self.scriptID,8,0);
        end
    end

    self:findFriend()
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.COUNT_BUFF_LIST[1].ID);
    if cond ~= nil then
        cond:setValue(self.friendCount)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,8,100);
    end
    return 1
end

function class:attack4Summon(unit,friendCount)
    if friendCount < 5 then
        self:MultipleSummon(self.gameUnit,self.summonUnitID,1)
        self:showMessage(self.SUMMON_MESSAGE_LIST)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,8,0);
    end

    self:findFriend()
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.COUNT_BUFF_LIST[1].ID);
    if cond ~= nil then
        cond:setValue(self.friendCount)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,8,100);
    end
    return 1
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

    if event.index == 2 and self.cutInFLG then
        self.cutInFLG = false
        event.unit:takeSkillWithCutin(event.index,1);
        return 0
    end

    if event.index == 1 then
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("1-skill2") ---EFのアニメーション名に気をつける
        if megast.Battle:getInstance():isHost() then
            self:targetAddBuff()
        end
    elseif event.index == 2 then
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("1-skill3") ---EFのアニメーション名に気をつける
        self:showMessage(self.SKILL2_MESSAGE_LIST)
    end

    if not self.hpSkillFlg and event.index == 2 then
        self:addSkill2Buff()
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
    megast.Battle:getInstance():sendEventToLua(self.scriptID,6,self.startHp);
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

function class:targetAddBuff(unit)
    self.gameUnit:updateHateTarget();
    local targetUnit = self:checkTargetUnit();
    local targetIndex = 10
    if targetUnit ~= nil then
        targetIndex = targetUnit:getIndex()
    end

    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if i == targetIndex then
                myTeamUnit:setBurstPoint(0)
                self:execAddBuff(myTeamUnit,self.SKILL1_BUFF_LIST[1])
                self:execAddBuff(myTeamUnit,self.SKILL1_BUFF_LIST[2])
                self.targetUnitList[targetIndex] = nil ---ゲストの蓄積ダメージを0に
                local enemyUnit = self:getAncestorUnit(myTeamUnit)
                local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
                table.insert(self.targetUnitList,index,{unit = myTeamUnit,dps = 0})
                self:showFormatMessage(self.SKILL1_MESSAGE_LIST[1],myTeamUnit:getUnitName())
                if megast.Battle:getInstance():isHost() then
                    megast.Battle:getInstance():sendEventToLua(self.scriptID,10,targetIndex);
                end
            end
        end
    end

    ---ヘイトは全部手動で設定する
    if megast.Battle:getInstance():isHost() then
        local target = self:checkTargetUnit()
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex())---ゲストにターゲットを送る
        self.gameUnit:setHateTarget(target)
        self.gameUnit:updateHateTarget();
        ---ターゲットにバフ
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if i == target:getIndex() then
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
                else
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
                end
            end
        end
    end
end

function class:addSkill2Buff()
    local team = megast.Battle:getInstance():getTeam(true)
    local FLG = false
    local count = 1
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                FLG = true
                count = count + 1
            end
        end
    end
    ---庇うユニットがいる場合
    if FLG then
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
                if cond == nil then
                    for i = 1,count do
                        self:execAddBuff(teamUnit,self.SKILL2_BUFF_LIST[1])
                        self:execAddBuff(teamUnit,self.SKILL2_BUFF_LIST[2])
                        self:execAddBuff(teamUnit,self.SKILL2_BUFF_LIST[3])
                    end
                end
            end
        end
    else
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,self.SKILL2_BUFF_LIST[1])
                self:execAddBuff(teamUnit,self.SKILL2_BUFF_LIST[2])
                self:execAddBuff(teamUnit,self.SKILL2_BUFF_LIST[3])
            end
        end
    end
end

function class:receive10(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if i == args.arg then
                myTeamUnit:setBurstPoint(0)
                self:execAddBuff(myTeamUnit,self.SKILL1_BUFF_LIST[1])
                self:execAddBuff(myTeamUnit,self.SKILL1_BUFF_LIST[2])
                self.targetUnitList[args.arg] = nil ---ゲストの蓄積ダメージを0に
                local enemyUnit = self:getAncestorUnit(myTeamUnit)
                local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
                table.insert(self.targetUnitList,index,{unit = myTeamUnit,dps = 0})
                self:showFormatMessage(self.SKILL1_MESSAGE_LIST[1],myTeamUnit:getUnitName())
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

    ---燃焼時ダメージ補正
    local barn = event.unit:getTeamUnitCondition():findConditionWithType(97);
    if barn ~= nil then
        event.value = event.value * (self.GD.barnDmgVal_1 + self.friendDeadCount * self.GD.barnDmgVal_2)
    else
        event.value = event.value * (self.GD.barnDmgVal_3 + self.friendDeadCount * self.GD.barnDmgVal_4)
    end

    ---ターゲット処理
    ---ユニットのダメージをテーブルに格納
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
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
                else
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
                end
            end
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
    if self.startHp ~= nil then
        return unit:getHP() - border + 1
    else
        return 0
    end
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
end

---与ダメが最も大きいやつをターゲットにする
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
            --v.dps = 0
        elseif v.dps >= val then
            val = v.dps
            target = v.unit
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
    if target == nil then
        return 1
    end

    ---ターゲットにバフ
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if i == target:getIndex() then
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
            else
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
            end
        end
    end
    return 1
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