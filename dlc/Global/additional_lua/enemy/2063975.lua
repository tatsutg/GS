local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="神族の遺跡9層(HARD)_怨涸神オルデウス", version=2.5, id=2063975});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK4 = 50 },
    },
    HP40 = {
        { ATTACK1 = 50, ATTACK4 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK4 = 50 },
        { ATTACK3 = 50 },
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
        { SKILL2 = 50 },
    },
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7,
    SKILL4 = 8,
}

class.cutInSkill = {
    [3] = 1,
    [4] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.HP70_BUFF_BOX_LIST = {
        [1] = {
            ID = 206397501,
            BUFF_ID = 53,   -- 毒耐性
            VALUE = self.GD.hp70BuffValue_53,
            DURATION = 999999,
            ICON = 59,
        },
        [2] = {
            ID = 206397502,
            BUFF_ID = 102,   -- 毒回避率
            VALUE = self.GD.hp70BuffValue_53,
            DURATION = 999999,
            ICON = 0,
        },
        [3] = {
            ID = 206397503,
            BUFF_ID = 60,   -- 燃焼耐性
            VALUE = self.GD.hp70BuffValue_60,
            DURATION = 999999,
            ICON = 66,
        },
        [4] = {
            ID = 206397504,
            BUFF_ID = 109,   -- 燃焼回避率
            VALUE = self.GD.hp70BuffValue_60,
            DURATION = 999999,
            ICON = 0,
        },
        [5] = {
            ID = 206397505,
            BUFF_ID = 56,   -- 暗闇耐性
            VALUE = self.GD.hp70BuffValue_56,
            DURATION = 999999,
            ICON = 62,
        },
        [6] = {
            ID = 206397506,
            BUFF_ID = 105,   -- 暗闇回避率
            VALUE = self.GD.hp70BuffValue_56,
            DURATION = 999999,
            ICON = 0,
        },
    }
    self.HP40_BUFF_BOX_LIST = {
        [1] = {
            ID = 206397511,
            BUFF_ID = 53,   -- 毒耐性
            VALUE = self.GD.hp40BuffValue_53,
            DURATION = 999999,
            ICON = 59,
        },
        [2] = {
            ID = 206397512,
            BUFF_ID = 102,   -- 毒回避率
            VALUE = self.GD.hp40BuffValue_53,
            DURATION = 999999,
            ICON = 0,
        },
        [3] = {
            ID = 206397513,
            BUFF_ID = 60,   -- 燃焼耐性
            VALUE = self.GD.hp40BuffValue_60,
            DURATION = 999999,
            ICON = 66,
        },
        [4] = {
            ID = 206397514,
            BUFF_ID = 109,   -- 燃焼回避率
            VALUE = self.GD.hp40BuffValue_60,
            DURATION = 999999,
            ICON = 0,
        },
        [5] = {
            ID = 206397515,
            BUFF_ID = 56,   -- 暗闇耐性
            VALUE = self.GD.hp40BuffValue_56,
            DURATION = 999999,
            ICON = 62,
        },
        [6] = {
            ID = 206397516,
            BUFF_ID = 105,   -- 暗闇回避率
            VALUE = self.GD.hp40BuffValue_56,
            DURATION = 999999,
            ICON = 0,
        },
    }
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 206397521,
            BUFF_ID = 0,   -- 割合ダメージIcon用
            VALUE = 0,
            DURATION = 999999,
            ICON = 3,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 206397522,
            BUFF_ID = 0,   -- 物理軽減Icon用
            VALUE = 0,
            DURATION = 999999,
            ICON = 21,
        },
        [3] = {
            ID = 206397523,
            BUFF_ID = 0,   -- 物理軽減Icon用
            VALUE = 0,
            DURATION = 999999,
            ICON = 22,
        },
    }
    self.RESIST_BUFF_BOX_LIST = {
        [1] = {
            ID = 206397531,
            BUFF_ID = 53,   -- 毒耐性
            VALUE = self.GD.resistBuffValue_53,
            DURATION = 999999,
            ICON = 59,
        },
        [2] = {
            ID = 206397532,
            BUFF_ID = 102,   -- 毒回避率
            VALUE = self.GD.resistBuffValue_53,
            DURATION = 999999,
            ICON = 0,
        },
        [3] = {
            ID = 206397533,
            BUFF_ID = 60,   -- 燃焼耐性
            VALUE = self.GD.resistBuffValue_60,
            DURATION = 999999,
            ICON = 66,
        },
        [4] = {
            ID = 206397534,
            BUFF_ID = 109,   -- 燃焼回避率
            VALUE = self.GD.resistBuffValue_60,
            DURATION = 999999,
            ICON = 0,
        },
        [5] = {
            ID = 206397535,
            BUFF_ID = 56,   -- 暗闇耐性
            VALUE = self.GD.resistBuffValue_56,
            DURATION = 999999,
            ICON = 62,
        },
        [6] = {
            ID = 206397536,
            BUFF_ID = 105,   -- 暗闇回避率
            VALUE = self.GD.resistBuffValue_56,
            DURATION = 999999,
            ICON = 0,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "汝が魂ハ闇へト堕ちル", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "一定時間経過するたびに奥義発動時割合ダメージ追加：燃焼・毒・暗闇で遅延", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "割合ダメージ：防御力アップで軽減", COLOR = Color.yellow}),
    }
    self.HP70_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE1 or "行動速度・物理耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE2 or "燃焼・毒・暗闇耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE3 or "割合ダメージ：防御力アップで軽減", COLOR = Color.yellow}),
    }
    self.HP40_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP40_MESSAGE1 or "奥義ゲージ上昇量・魔法耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP40_MESSAGE2 or "燃焼・毒・暗闇耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP40_MESSAGE3 or "物理耐性：解除", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP40_MESSAGE4 or "割合ダメージ：防御力アップで軽減", COLOR = Color.yellow}),
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "全て…滅セよ…", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE2 or "割合ダメージ：防御力アップで軽減", COLOR = Color.yellow}),
    }
    self.DBUFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DBUFF_MESSAGE1 or "次に燃焼・毒・暗闇状態になるまで毒耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.DBUFF_MESSAGE2 or "次に燃焼・毒・暗闇状態になるまで燃焼耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.DBUFF_MESSAGE3 or "次に燃焼・毒・暗闇状態になるまで暗闇耐性アップ", COLOR = Color.yellow}),
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp70(status) end,
            HP = 70,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false,
            isEnableSkip = false
        },
        [3] = {
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

function class:hp70(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3
            self.saveBP = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
        end
        self.triggerState = 1
        self.ratioBaseValue = self.GD.hp70ratioDamageBaseValue
        self.gameUnit:setAttackDelay(self.GD.hp70AttackDelay);
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(20)
        self:execAddBuff(self.gameUnit,self.HP70_BUFF_BOX_LIST[1])
        self:execAddBuff(self.gameUnit,self.HP70_BUFF_BOX_LIST[2])
        self:execAddBuff(self.gameUnit,self.HP70_BUFF_BOX_LIST[3])
        self:execAddBuff(self.gameUnit,self.HP70_BUFF_BOX_LIST[4])
        self:execAddBuff(self.gameUnit,self.HP70_BUFF_BOX_LIST[5])
        self:execAddBuff(self.gameUnit,self.HP70_BUFF_BOX_LIST[6])
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
        self:showMessage(self.HP70_MESSAGE_LIST)
    end
end

function class:hp40(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3
            self.saveBP = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
        end
        self.triggerState = 2
        self.ratioBaseValue = self.GD.hp40ratioDamageBaseValue
        self.spValue = self.GD.hp40addSP;
        self:initAttackWeight({HP40 = 100})
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(20)
        self:execAddBuff(self.gameUnit,self.HP40_BUFF_BOX_LIST[1])
        self:execAddBuff(self.gameUnit,self.HP40_BUFF_BOX_LIST[2])
        self:execAddBuff(self.gameUnit,self.HP40_BUFF_BOX_LIST[3])
        self:execAddBuff(self.gameUnit,self.HP40_BUFF_BOX_LIST[4])
        self:execAddBuff(self.gameUnit,self.HP40_BUFF_BOX_LIST[5])
        self:execAddBuff(self.gameUnit,self.HP40_BUFF_BOX_LIST[6])
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID);
        if cond ~= nil then
            self.gameUnit:getTeamUnitCondition():removeCondition(cond);
        end
        self:showMessage(self.HP40_MESSAGE_LIST)
    end
end

-- HARD
function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 4
            self.saveBP = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
        end
        self.ratioBaseValue = self.GD.hp0ratioDamageBaseValue
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(20)
        self:showMessage(self.HP0_MESSAGE_LIST)
    end
end


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 30,
        attackDelay = 7,
        hitStop = 100,
        startAddSP = 0,
        hp70BuffValue_53 = 30,
        hp70BuffValue_60 = 30,
        hp70BuffValue_56 = 30,
        hp70AttackDelay = 4,
        hp40BuffValue_53 = 30,
        hp40BuffValue_60 = 30,
        hp40BuffValue_56 = 30,
        hp40addSP = 35,
        resistBuffValue_53 = 200,
        resistBuffValue_60 = 200,
        resistBuffValue_56 = 200,
        notCriticalTakeDamageValue = 0.2,
        physicalTakeDamageValue = 0.2,
        magicTakeDamageValue = 0.2,
        tgTimer = 10,
        tgLimit = 999,
        tgIconNum1 = 3,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        tgSlowSpeed = 3,
        ratioDamageRateValue = 50,
        hp70ratioDamageBaseValue = 120,
        hp40ratioDamageBaseValue = 160,
        hp0ratioDamageBaseValue = 250,
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

    self.skillflg = false
    self.triggerState = 0
    self.deadFlg = false
    self.deadCount = nil
    self.ratioDamageFlg = false
    self.ratioCount = 0
    self.ratioBaseValue = 0
    self.blindFlg = false
    self.poisonFlg = false
    self.flameFlg = false

    -- 経過時間ギミック
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit, self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeeddefault = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
    self.timeSpeed = self.timeSpeeddefault

    --葬魂神オルデウスの共有ギミック
    self.bullets = {}
    self.bulletInfo = {
        new = function (_bullet,_targetUnit,_uniqueID)
            return {
                bullet = _bullet,
                targetUnit = _targetUnit,
                uniqueID = _uniqueID,
                frame = 0,
                angle = 0,
                posx = 0,
                posy = 0,
                speedkeisuu = 1
            }
        end
    }

    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効

    -- 経過時間ギミック(HARD)
    self:timeGimmick(event.unit)

    -- デバフチェック(HARD)
    self:dbuffCheck(event.unit)

    --死亡時処理(HARD)
    if event.unit:getUnitState() ~= kUnitState_skill then
        if megast.Battle:getInstance():getBattleState() == kBattleState_active then
            if self.TRIGGERS[3].used then
                if self.deadCount == nil then self.deadCount = 0 end
                self.deadCount = self.deadCount + event.deltaTime
                if self.deadCount >= 20 then
                    self.deadFlg = true
                    event.unit:setHP(0)
                    --event.unit:getTeam():deadUnit(event.unit:getIndex());
                    --megast.Battle:getInstance():waveEnd(true);
                end
            end
        end
    end

    --葬魂神オルデウスの共有ギミック
    if table.maxn(self.bullets) > 0 then
        for i = 1,table.maxn(self.bullets) do
            self:bulletControll(self.bullets[i],event.deltaTime)
        end
    end

    return 1
end

function class:timeGimmick(unit)
    if self.timeIndex ~= nil then

        local FLG = 0

        -- ボスが毒・燃焼・暗闇（ナイトメア）状態の場合、遅延
        local cond1 = unit:getTeamUnitCondition():findConditionWithType(93);
        local cond2 = unit:getTeamUnitCondition():findConditionWithType(131);
        local cond3 = unit:getTeamUnitCondition():findConditionWithType(90);
        local cond4 = unit:getTeamUnitCondition():findConditionWithType(97);
        if cond1 ~= nil or cond2 ~= nil or cond3 ~= nil or cond4 ~= nil then
            FLG = 1
        end

        -- ブレイク中、奥義発動中は停止
        if self.skillflg or unit:isBreak() then
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

function class:dbuffCheck(unit)
    -- ボスが毒・燃焼・暗闇（ナイトメア）状態になったら相応のバフをつける
    -- 暗闇
    local cond1 = unit:getTeamUnitCondition():findConditionWithType(93);
    local cond2 = unit:getTeamUnitCondition():findConditionWithType(131);
    if (cond1 ~= nil or cond2 ~= nil) then
        if not self.blindFlg then
            self:removeBuffs(self.gameUnit,self.RESIST_BUFF_BOX_LIST);
            self:execAddBuff(self.gameUnit,self.RESIST_BUFF_BOX_LIST[5])
            self:execAddBuff(self.gameUnit,self.RESIST_BUFF_BOX_LIST[6])
            self:showMessage(self.DBUFF_MESSAGE_LIST,3)
            self.blindFlg = true
        end
    else
        self.blindFlg = false
    end

    -- 毒
    local cond3 = unit:getTeamUnitCondition():findConditionWithType(90);
    if cond3 ~= nil then
        if not self.poisonFlg then
            self:removeBuffs(self.gameUnit,self.RESIST_BUFF_BOX_LIST);
            self:execAddBuff(self.gameUnit,self.RESIST_BUFF_BOX_LIST[1])
            self:execAddBuff(self.gameUnit,self.RESIST_BUFF_BOX_LIST[2])
            self:showMessage(self.DBUFF_MESSAGE_LIST,1)
            self.poisonFlg = true
        end
    else
        self.poisonFlg = false
    end

    -- 燃焼
    local cond4 = unit:getTeamUnitCondition():findConditionWithType(97);
    if cond4 ~= nil then
        if not self.flameFlg then
            self:removeBuffs(self.gameUnit,self.RESIST_BUFF_BOX_LIST);
            self:execAddBuff(self.gameUnit,self.RESIST_BUFF_BOX_LIST[3])
            self:execAddBuff(self.gameUnit,self.RESIST_BUFF_BOX_LIST[4])
            self:showMessage(self.DBUFF_MESSAGE_LIST,2)
            self.flameFlg = true
        end
    else
        self.flameFlg = false
    end

end

function class:removeBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:removeBuff(unit,v.ID);
    end
end

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end

    unit:getTeamUnitCondition():removeCondition(buff);
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    self.ratioCount = self.ratioCount + 1
    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])

    return event.count
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    --葬魂神オルデウスの共有ギミック
    if event.spineEvent == "death" then return self:death(event.unit) end
    if event.spineEvent == "skull" then
        self:ratioDamage(self:getAncestorUnit(event.unit))
        return self:skull(event)
    end
    if event.spineEvent == "onDestroy" then
        return self:onDestroy(event.unit)
    end
    return 1;
end

function class:death(unit)
    self:ratioDamage(unit)
    return 1
end

function class:ratioDamage(unit)
    if self.ratioDamageFlg then
        self.ratioDamageFlg = false

        -- 割合ダメージを起こす
        --summoner.Utility.messageByEnemy(self.ratioBaseValue .. " + " .. self.GD.ratioDamageRateValue .. " * " .. self.ratioCount)
        local myTeam = megast.Battle:getInstance():getTeam(true)
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            local ratioValue = self.ratioBaseValue + self.GD.ratioDamageRateValue * self.ratioCount
            local defenseValue = 0
            if myTeamUnit ~= nil then
                -- 防御力割合（type:15）をみてvalue値を合算させる
                local conditionSize = myTeamUnit:getTeamUnitCondition():getAllConditionsSize();
                if conditionSize > 0 then
                    for i = 0,(conditionSize - 1) do
                        local cond = myTeamUnit:getTeamUnitCondition():getAllConditionsAt(i);
                        if cond ~= nil then
                            if cond:getConditionTypeAsInt() == 15 then
                                defenseValue = defenseValue + cond:getValue()
                            end
                        end
                    end
                end
                -- 防御力割合のvalue値の合計値から大元の割合ダメージ値を減算する
                ratioValue = ratioValue - defenseValue
                if ratioValue < 0 then
                    ratioValue = 0
                end

                --summoner.Utility.messageByEnemy(myTeamUnit:getUnitName() .. " : " .. ratioValue .. "%")
                myTeamUnit:setHP(myTeamUnit:getHP() - myTeamUnit:getCalcHPMAX() * (ratioValue * 0.01))

            end
        end

        self.ratioCount = 0
        local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
        if cond ~= nil then
            unit:getTeamUnitCondition():removeCondition(cond);
        end
    end

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

    if self.deadCount ~= nil then
        self.deadFlg = true
        event.unit:setHP(0)
    end

    self.ratioBaseValue = 0
    self.ratioDamageFlg = false
    self.skillflg = false

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

    if self.cutInFLG then
        self.cutInFLG = false
        event.unit:takeSkillWithCutin(event.index,1);
        return 0
    end

    if event.index == 3 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
    end

    if event.index == 4 then
        event.unit:setNextAnimationName("skill3");
        event.unit:setNextAnimationEffectName("1-skill3");
    end

    self.skillflg = true
    -- 割合ダメージフラグを立てる
    self.ratioDamageFlg = true

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
    -- 奥義最初のヒット時に割合ダメージを起こす
    self:ratioDamage(event.unit)
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

    -- ブレイク中でなければ
    if not event.unit:isBreak() then
        --クリティカル以外は軽減
        local critical = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().critical;
        if not critical then
            event.value = event.value * self.GD.notCriticalTakeDamageValue
        end

        --トリガーに応じて物理魔法軽減
        local attribute = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if self.triggerState == 1 then
            -- 物理軽減
            if attribute == 1 then
                event.value = event.value * self.GD.physicalTakeDamageValue
            end
        elseif self.triggerState == 2 then
            -- 魔法軽減
            if attribute == 2 then
                event.value = event.value * self.GD.magicTakeDamageValue
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

    self.ratioDamageFlg = false
    self.ratioCount = 0
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
    if cond ~= nil then
        event.unit:getTeamUnitCondition():removeCondition(cond);
    end

    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if not self.deadFlg then
        event.unit:setHP(1)
        return 0
    end
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , 1)
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
        self.timeIndex = nil
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

--葬魂神オルデウスの共有ギミック
-- == 壊魂振動 ==
--==========================================
function class:skull(event)
    --local hpRatio = event.unit:getHP()/event.unit:getCalcHPMAX();
    --local bulletCount = 4 - hpRatio * 2;
    local bulletCount = 1
    if event.unit:getTargetUnit() ~= nil then
        for i = 0,bulletCount do
            local s = event.unit:addOrbitSystem("skullBase",2)
            s:setHitCountMax(1)
            s:setEndAnimationName("explosion")
            local x = event.unit:getPositionX()
            local y = event.unit:getPositionY()
            --玉の出る座標をちょっとランダムにばらけさせたい
            local amplitude = 100;
            local rand = LuaUtilities.rand(0,amplitude);
            local rand2 = LuaUtilities.rand(0,amplitude);
            s:setPosition(x + rand - 50,y+350 + rand2 - 50);
            --s:setActiveSkill(2);
            -- s:takeAnimation(0,"skullBase",true);
            s:setOpacity(0);
            s:runAction(cc.FadeIn:create(1));
            local tama = self.bulletInfo.new(s,event.unit:getTargetUnit():getIndex(),0);
            table.insert(self.bullets,tama)
        end
    end
    return 1;
end

function class:onDestroy(unit)

    local atari = 1
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i].bullet == unit then
            atari = i
        end
    end

    self.bullets[atari].bullet:setEndAnimationName("");
    table.remove(self.bullets,atari);
    return 1;
end

function class:bulletControll(bulletinstance,deltaTime)
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local sp = 1;
    local speedOrigin = 1;
    if framecnt == 0 then
        local rand = LuaUtilities.rand(0,360);
        bulletinstance.angle = rand;
        bulletinstance.speedkeisuu = LuaUtilities.rand(100,130)/100;
        sp = speedOrigin;
        bulletinstance.posx = bulletinstance.bullet:getPositionX();
        bulletinstance.posy = bulletinstance.bullet:getPositionY();
    end

    bulletinstance.frame = bulletinstance.frame + 1 * deltaTime/0.016666667;
    if framecnt <= 1 then
    elseif framecnt < 30 then
        sp = 1 + math.abs(30 - framecnt)/30 * speedOrigin*3;
    elseif framecnt < 600 then
        sp = 2;
        local bullettarget = megast.Battle:getInstance():getTeam(not bulletinstance.isPlayer):getTeamUnit(bulletinstance.targetUnit);
        if bullettarget ~= nil then
            local targetangle = self:getDeg(currentbullet:getPositionX(),currentbullet:getPositionY(),bullettarget:getPositionX(),bullettarget:getPositionY());
            if targetangle < 0 then
                targetangle = 360 + targetangle;
            end

            local dir = targetangle - bulletinstance.angle;
            if dir > 180 then
                dir = -(360 - dir);
            end

            if dir < -180 then
                dir = (360 - dir);
            end

            if dir ~= 0 then
                local maxdir = 1 * deltaTime/0.016666667;
                if dir > maxdir then
                    dir = maxdir;
                elseif dir < -maxdir then
                    dir = -maxdir;
                end
                bulletinstance.angle = bulletinstance.angle + dir;
            end
        end
    else
        bulletinstance.bullet:takeAnimation(0,"explosion",false);
    end

    local oneFrame = 0.016666666;
    self:moveByFloat(
            bulletinstance,
            self:calcXDir(self:degToRad(bulletinstance.angle),sp * deltaTime/oneFrame),
            self:calcYDir(self:degToRad(bulletinstance.angle),sp * deltaTime/oneFrame)
    );
end

function class:getDeg(startx,starty,targetx,targety)
    return self:radToDeg(self:getRad(startx,starty,targetx,targety))
end

function class:getRad(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx)
end

function class:degToRad(deg)
    return deg * 3.14/180;
end

function class:radToDeg(rad)
    return rad * 180/3.14;
end

function class:calcXDir(rad,speed)
    return math.cos(rad)*speed;
end

function class:calcYDir(rad,speed)
    return math.sin(rad)*speed;
end

function class:move(node,movex,movey)
    node:setPosition(node:getPositionX()+movex,node:getPositionY()+movey);
    return 1;
end

function class:moveByFloat(_bulletinstance,xdistance,ydistance)
    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;
    return true;
end
--==========================================

class:publish();

return class;