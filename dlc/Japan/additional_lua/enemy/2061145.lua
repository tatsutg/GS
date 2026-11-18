--@additionalEnemy,2061147
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="人族の遺跡_7階層_HARD_炎玉精イグニス", version=2.0, id=2061145});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK2 = 50, ATTACK3 = 50 },
        { ATTACK4 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
        { SKILL2 = 50 }
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
    [3] = 1
}

--ボス固有定数
class.CRYSTAL_NUM = 3;
class.CRYSTAL_POSITIONS = {
    {x = -300,y = 500},
    {x = 300,y = 500},
    {x = 0,y = 530}
}
class.CRYSTAL_STATES = {
    start = 0,
    deactive = 1,
    activation = 2,
    active = 3,
    out = 4,
    hide = 5,
    start2 = 6
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = -20611451,
            BUFF_ID = 59, --氷結耐性
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
            --COUNT = 0,
            --MAX = 20
        },
        [2] = {
            ID = -20611452,
            BUFF_ID = 108, --氷結回避
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
            --COUNT = 0,
            --MAX = 20
        },
        [3] = {
            ID = 206114510,
            BUFF_ID = 0, --氷結耐性カウント用1~9
            VALUE = 0,
            DURATION = 999999,
            ICON = 65,
            COUNT = 1,
            MAX = 20
        },
        [4] = {
            ID = 206114511,
            BUFF_ID = 0, --氷結耐性カウント用10~20
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
            COUNT = 10,
            MAX = 20
        },
        [5] = {
            ID = 206114512,
            BUFF_ID = 0, --氷結耐性カウント用MAX
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
            COUNT = 20,
            MAX = 20
        }
    }
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 20611453,
            BUFF_ID = 17,  --与ダメ
            VALUE = self.GD.skillBuffVal_17_1,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        }
    }
    self.HP_BUFF_LIST = {
        [1] = {
            ID = -20611454,
            BUFF_ID = 59, --氷結耐性
            VALUE = self.GD.hpBuffVal_59,
            DURATION = 999999,
            ICON = 65
        },
        [2] = {
            ID = -20611455,
            BUFF_ID = 108, --氷結回避
            VALUE = self.GD.hpBuffVal_59,
            DURATION = 999999,
            ICON = 0
        },
        [3] = {
            ID = 20611456,
            BUFF_ID = 23,  --クリティカル耐性
            VALUE = self.GD.hpBuffValue_23,
            DURATION = 999999,
            ICON = 188
        }
    }
    self.COUNT_BUFF_LIST = {
        [1] = {
            ID = 20611100,
            BUFF_ID = 0,  --召喚カウント用
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
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "氷結状態・被クリティカル時ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "HP自然回復効果 反転", COLOR = Color.red})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "ブレイジングインパクト：ダメージ無効化無効", COLOR = Color.red})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "クリティカル・氷結耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.ICE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.ICE_MESSAGE1 or "氷結耐性アップ", COLOR = Color.red})
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "コログラン：物理耐性", COLOR = Color.yellow})
    }
    self.SUMMON_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_DEAD_MESSAGE1 or "コログラン撃破で炎精霊の氷結耐性ダウン", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.01,
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

function class:hp50(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 1
            self.saveBP = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
        end
        self.cutInFLG = true
        self.gameUnit:setInvincibleTime(30)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self.spValue = self.GD.hpAddSP
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[1])  --氷結耐性
        --self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[2])  --氷結回避
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[3])  --クリティカル耐性
        self.hpFlg = true
    end
end

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3
            self.saveBP = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
        end
        self.gameUnit:setInvincibleTime(30)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        startAddSP = 60,
        attackDelay = 6,
        hitStop = 100,

        hpAddSP = 30,
        criDmgVal = 0.1,
        iceDmgVal_1 = 1.2,
        iceDmgVal_2 = 0.1,
        startSummon = 2,
        skillSummon = 2,
        hpSummon = 3,
        healReverseBuffTime = 30,

        buffVal_59_1 = 10,
        buffVal_59_2 = 30,
        buffVal_60 = 10,
        skillBuffVal_17_1 = 20,
        skillBuffVal_17_2 = 2,
        skillBuffVal_17_3 = 5,
        hpBuffValue_23 = -70,
        hpBuffVal_59 = 30
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

    ---ボスギミック
    self.hpFlg = false
    self.iceBuffFlg = false
    self.friendCount = 0
    self.friendCountFlg = 0
    self.summonUnitID = 2061147

    --ボス固有ギミック
    self.crystalBuffs = {};
    self.crystals = {};
    self.crystalCounter = 0;
    self.crystalExcutionFlg = false;
    self:initCrystals(event.unit);
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:execAddBuff(event.unit,self.BUFF_LIST[1])  --氷結耐性
    self:execAddBuff(event.unit,self.BUFF_LIST[2])  --氷結回避
    self:execAddBuff(event.unit,self.BUFF_LIST[3])  --耐性バフカウント用
    self:execAddBuff(event.unit,self.BUFF_LIST[4])  --耐性バフカウント用
    self:execAddBuff2(event.unit,self.BUFF_LIST[5])  --耐性バフカウント用
    for i = 1,self.GD.startSummon do
        local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[1].ID);
        if cond ~= nil then
            cond:setValue(cond:getValue() + self.GD.buffVal_59_1)
        end

        local cond2 = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[2].ID);
        if cond2 ~= nil then
            cond2:setValue(cond2:getValue() + self.GD.buffVal_59_1)
        end

        local countBuff1 = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[3].ID);
        if countBuff1 ~= nil then
            countBuff1:setNumber(cond:getValue() / 10)
        end
    end

    self:execAddBuff(event.unit,self.COUNT_BUFF_LIST[1])  --召喚カウント用
    self:summonCount(event.unit,self.GD.startSummon)  --召喚
    self:findFriend()
    return 1
end

function class:summonCount(unit,num)
    self:MultipleSummon(self.gameUnit,self.summonUnitID,num)
    self:showMessage(self.SUMMON_MESSAGE_LIST)
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.COUNT_BUFF_LIST[1].ID);
    if cond ~= nil then
        for i = 1,num do
            cond:setValue(cond:getValue() + 1)
        end
    end
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

    ---氷結耐性ギミック
    self:iceBuffCheck(event.unit)
    ---召喚数ギミック
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.COUNT_BUFF_LIST[1].ID);
    if cond ~= nil then
        self:friendDeadBuff(event.unit,cond:getValue(),self.friendCount)
    end
    self:findFriend()

    ---死亡時処理
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.lastSkillFLG == nil then self.lastSkillFLG = false end
        if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
            event.unit:getTeam():deadUnit(event.unit:getIndex());
            megast.Battle:getInstance():waveEnd(true);
        end
        if self.TRIGGERS[2].used then
            if self.deadCount == nil then self.deadCount = 0 end
            self.deadCount = self.deadCount + event.deltaTime
            if self.deadCount >= 30 then
                event.unit:getTeam():deadUnit(event.unit:getIndex());
                megast.Battle:getInstance():waveEnd(true);
            end
        end
    end
    return 1
end

function class:iceBuffCheck(unit)
    local ice = unit:getTeamUnitCondition():findConditionWithType(96);
    if ice ~= nil then
        self.iceBuffFlg = true
    else
        if self.iceBuffFlg then
            self.iceBuffFlg = false
            --耐性バフ処理
            local infoFlg = true
            local buffVal = 0
            local buffNum = 0
            local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[1].ID);
            if cond ~= nil then
                if (cond:getValue() / 10) == 20 then infoFlg = false end
                buffVal = cond:setValue(cond:getValue() + self.GD.buffVal_59_2)
                buffNum = cond:getValue() / 10
                if buffNum >= 20 then
                    cond:setValue(200)
                end
            end

            local cond2 = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[2].ID);
            if cond2 ~= nil then
                cond2:setValue(cond2:getValue() + self.GD.buffVal_59_2)
                if buffNum >= 20 then
                    cond2:setValue(200)
                end
            end

            --バフカウント処理
            local countBuff1 = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[3].ID);
            local countBuff2 = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[4].ID);
            local countBuff3 = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[5].ID);
            if buffNum >= 20 then
                countBuff1:setThumbnailID(0)
                countBuff2:setThumbnailID(0)
                countBuff3:setThumbnailID(65)
            elseif buffNum <= 9 then
                if countBuff1 ~= nil then
                    countBuff1:setThumbnailID(65)
                    countBuff1:setNumber(buffNum)
                end

                if countBuff2 ~= nil then
                    countBuff2:setThumbnailID(0)
                end

                if countBuff3 ~= nil then
                    countBuff3:setThumbnailID(0)
                end
            elseif buffNum > 9 then
                if countBuff1 ~= nil then
                    countBuff1:setThumbnailID(0)
                end

                if countBuff2 ~= nil then
                    countBuff2:setThumbnailID(65)
                    countBuff2:setNumber(buffNum)
                end

                if countBuff3 ~= nil then
                    countBuff3:setThumbnailID(0)
                end
            end
            megast.Battle:getInstance():updateConditionView()
            if infoFlg then
                self:showMessage(self.ICE_MESSAGE_LIST)
            end
        end
    end
end

function class:findFriend()   --雑魚の監視
    self.friendCount = 0
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getUnitID() == 100182311 then   --コログランの数
                self.friendCount = self.friendCount + 1
            end
        end
    end
end

function class:friendDeadBuff(unit,countBuffVal,friendCount)
    if countBuffVal ~= friendCount then
        local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[1].ID);
        if cond ~= nil then
            if cond:getValue() ~= 0 then
                --耐性バフ処理
                local buffVal = cond:setValue(cond:getValue() - self.GD.buffVal_59_1)
                local buffNum = cond:getValue() / 10
                local cond2 = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[2].ID);
                cond2:setValue(cond2:getValue() - self.GD.buffVal_59_1)

                --バフカウント処理
                local countBuff1 = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[3].ID);
                local countBuff2 = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[4].ID);
                local countBuff3 = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[5].ID);
                if buffNum <= 9 then
                    if countBuff1 ~= nil then
                        if buffNum == 0 then
                            countBuff1:setThumbnailID(0)
                        else
                            countBuff1:setThumbnailID(65)
                        end
                        countBuff1:setNumber(buffNum)
                    end

                    if countBuff2 ~= nil then
                        countBuff2:setThumbnailID(0)
                    end
                elseif buffNum > 9 then
                    if countBuff1 ~= nil then
                        countBuff1:setThumbnailID(0)
                    end

                    if countBuff2 ~= nil then
                        countBuff2:setThumbnailID(65)
                        countBuff2:setNumber(buffNum)
                    end

                    if countBuff3 ~= nil then
                        countBuff3:setThumbnailID(0)
                    end
                end
                megast.Battle:getInstance():updateConditionView()
                self:showMessage(self.SUMMON_DEAD_MESSAGE_LIST)
            end
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "crystalActionEnd" then self:crystalStateEnd(event.unit) end
    if event.spineEvent == "skill2Start" then self:skill2Start() end
    if event.spineEvent == "skill2Compleat" then self:skill2Compleat() end
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
        self:summonCount(event.unit,1)  --召喚
        self:findFriend()
        local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.COUNT_BUFF_LIST[1].ID);
        if cond ~= nil then
            cond:setValue(self.friendCount)
        end
    end

    local count = 0
    local targetTeam = megast.Battle:getInstance():getTeam(true)
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            count = count + self:autoHealReverse(myTeamUnit)
        end
    end
    if count > 0 then
        --self:showMessage(self.REVERSE_MESSAGE_LIST)
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

function class:autoHealReverse(unit)
    unit:getTeamUnitCondition():StopConditionDataEntirely(7)
    ---バフ設定
    local MINUS_BP_BUFF_LIST = {}
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    local condCount = 0
    local workCount = 0
    if conditionSize ~= 0 then
        for i = 0,(conditionSize - 1) do
            local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
            if cond ~= nil and cond:getConditionTypeAsInt() == 7 then
                if cond:getValue() > 0 then
                    ---2004349は自然回復を判定するフラグになっているので使い回す場合は絶対にこの数値を変えないこと
                    if cond:getValue4() == 2004349 then
                        ---バフリスト作成(割合)
                        MINUS_BP_BUFF_LIST[i] = {
                            ID = 0,
                            BUFF_ID = 129,
                            VALUE = cond:getValue(),
                            DURATION = self.GD.healReverseBuffTime,
                            ICON = 180,
                            SCRIPT = {
                                SCRIPT_ID = 228
                            },
                            GROUP_ID = cond:getGroupID(),---グループIDセット
                            PRIORITY = cond:getPriority() * 100 ---優先度100倍
                        }
                    else
                        ---バフリスト作成(固定)
                        MINUS_BP_BUFF_LIST[i] = {
                            ID = 0,
                            BUFF_ID = 129,
                            VALUE = cond:getValue() * 10,
                            DURATION = self.GD.healReverseBuffTime,
                            ICON = 180,
                            GROUP_ID = cond:getGroupID(),---グループIDセット
                            PRIORITY = cond:getPriority() * 100 ---優先度100倍
                        }
                    end
                    cond:setValue(0) ---バフ無効化
                    cond:setTime(0) ---バフ除去
                    cond:setThumbnailID(0) ---アイコンなし
                    workCount = workCount + 1
                end
                ---ループ回避
                condCount = condCount + 1
                if condCount > 100 then
                    break
                end
            end
        end
    end
    ---逆転バフ付与
    for index,buffList in pairs(MINUS_BP_BUFF_LIST) do
        self:reverseExecAddBuff(unit,MINUS_BP_BUFF_LIST[index])
    end
    return workCount
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

    if self.cutInFLG then
        self.cutInFLG = false
        event.unit:takeSkillWithCutin(event.index,1);
        return 0
    end

    if event.index == 1 or event.index == 2 then
        self:skillExecAddBuff(event.unit,self.SKILL_BUFF_LIST[1])
        if not self.hpFlg then
            self:summonCount(event.unit,self.GD.skillSummon)  --召喚
            self:findFriend()
        else
            self.hpFlg = false
            self:summonCount(self.gameUnit,self.GD.hpSummon)  --召喚
            self:findFriend()
        end

        local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.COUNT_BUFF_LIST[1].ID);
        if cond ~= nil then
            cond:setValue(self.friendCount)
        end
    end

    if event.index == 3 then
        self.lastSkillFLG = true
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
    end

    if event.index == 2 or event.index == 3 then
        self:showMessage(self.SKILL_MESSAGE_LIST)
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
    ---クリティカル判定
    local critical = event.unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if not critical then
        event.value = event.value * self.GD.criDmgVal
    end
    ---氷結バフ判定
    local ice = event.unit:getTeamUnitCondition():findConditionWithType(96);
    if ice ~= nil then
        event.value = event.value * self.GD.iceDmgVal_1
    else
        event.value = event.value * self.GD.iceDmgVal_2
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
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 0
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

function class:execAddBuff2(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT)
        megast.Battle:getInstance():updateConditionView()
    end
end

function class:reverseExecAddBuff(unit,buffBox)
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            if buffBox.EXCEPTION == nil or cond:getID() ~= buffBox.EXCEPTION then
                unit:getTeamUnitCondition():removeCondition(cond);
            end
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end
    return buff
end

function class:skillExecAddBuff(unit,buffBox)
    local buff  = nil;
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

    local buffVal = count^self.GD.skillBuffVal_17_2 * self.GD.skillBuffVal_17_3 + self.GD.skillBuffVal_17_1
    buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffVal,buffBox.DURATION,buffBox.ICON);
    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
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



--====================================================================================================================================
--クリスタル関係

function class:initCrystals(unit)
    for i=1,3 do
        self.crystals[i] = self:createCrystal(unit,self.CRYSTAL_POSITIONS[i].x,self.CRYSTAL_POSITIONS[i].y);
    end
end

function class:createCrystal(unit,x,y)
    local crystal = {}
    crystal.orbit = unit:addOrbitSystem("crystal_idle_off");
    crystal.orbit:takeAnimation(0,"crystal_idle_off",true);
    crystal.orbit:setPosition(x,y);
    crystal.orbit:setZOrder(8999);
    crystal.state = self.CRYSTAL_STATES.deactive;

    crystal.endState = function(class,this)
        if this.state == class.CRYSTAL_STATES.start then
            this.switchState(class,this,class.CRYSTAL_STATES.deactive);
        elseif this.state == class.CRYSTAL_STATES.activation then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
        elseif this.state == class.CRYSTAL_STATES.out then
            this.switchState(class,this,class.CRYSTAL_STATES.hide);
        elseif this.state == class.CRYSTAL_STATES.start2 then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
        end
    end

    crystal.switchState = function(class,this,targetState)
        this.state = targetState;
        if targetState == class.CRYSTAL_STATES.active then
            this.orbit:takeAnimation(0,"crystal_idle_on",true);
        end
        if targetState == class.CRYSTAL_STATES.deactive then
            this.orbit:takeAnimation(0,"crystal_idle_off",true);
        end
        if targetState == class.CRYSTAL_STATES.activation then
            this.orbit:takeAnimation(0,"crystal_activate",true);
        end
        if targetState == class.CRYSTAL_STATES.start then
            this.orbit:takeAnimation(0,"crystal_in",true);
        end

        if targetState == class.CRYSTAL_STATES.start2 then
            this.orbit:takeAnimation(0,"crystal_in2",true);
        end

        if targetState == class.CRYSTAL_STATES.out then
            this.orbit:takeAnimation(0,"crystal_out",true);
        end

        if targetState == class.CRYSTAL_STATES.hide then
            this.orbit:takeAnimation(0,"crystal_hide",true);
        end
    end

    return crystal;
end

function class:crystalStateEnd(unit)
    for i=1,self.CRYSTAL_NUM do
        if self.crystals[i].orbit == unit then
            self.crystals[i].endState(self,self.crystals[i]);
            return;
        end
    end
end

function class:lightUp(unit,num)
    if num > self.CRYSTAL_NUM then
        return;
    end

    if self.crystalBuffs[num] ~= nil then
        self.crystalBuffs[num].action(self,unit);
        self.crystalBuffs[num] = nil;
    end


    for i=1,num do
        if self.crystals[i].state == self.CRYSTAL_STATES.deactive then
            self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.activation);
        end
    end
end

function class:excutionCrystals()
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.out);
    end
end

function class:restertCrystals()
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.start2);
    end
end

function class:skill2Start()
    self.crystalExcutionFlg = true;
    self:excutionCrystals();
end

function class:skill2Compleat()
    self.crystalExcutionFlg = false;
    -- self.crystalCounter = 0;
    self:restertCrystals();
end

function class:takeHPReduce(unit,deltaTime)
    self.hpReduceCheckTimer = self.hpReduceCheckTimer + deltaTime;
    if self.hpReduceCheckTimer < 0.2 then
        return;
    end
    self.hpReduceCheckTimer = self.hpReduceCheckTimer - 0.2;
    for i=0,4 do
        local teamUnit = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
        if teamUnit ~= nil then
            if teamUnit:getTeamUnitCondition():findConditionWithID(501314) == nil then
                self:addBuffs(teamUnit,self.HP_REDUCE_BUFF_ARGS);
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