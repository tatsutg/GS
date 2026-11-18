--@additionalEnemy,2064576
--@additionalItem,160052502
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="魔族の遺跡_9層_HARD_ツァイバーZ", version=2.7, id=2064575});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK3 = 50 },
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 50 },
        { SKILL3 = 50 }
    },
    HP60 = {
        { SKILL5 = 50 },
        { SKILL6 = 50 }
    },
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL1 = 4,
    SKILL2 = 5,
    SKILL3 = 6,
    SKILL4 = 7,
    SKILL5 = 8,
    SKILL6 = 9,
    SKILL7 = 4,
}

class.cutInSkill = {
    [4] = 1,
    [7] = 1,
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 206457501,  --フラグ用
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 9999999,
            ICON = 0
        },
        [2] = {
            ID = 206457502,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 9999999,
            ICON = 0
        },
        [3] = {
            ID = 206457503,
            BUFF_ID = 89,  --気絶効果
            VALUE = 100,
            DURATION = self.GD.pilebrokenbuffTime_89,
            ICON = 79
        },
        [4] = {
            ID = 206457504,
            BUFF_ID = 17, -- クリティカルダメージ
            VALUE = self.GD.criDamageUpbuffValue_17,
            DURATION = 999999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 22
            },
        },
        [5] = {
            ID = 206457505,
            BUFF_ID = 109,   -- 燃焼回避率(グラーシーザに)
            VALUE = self.GD.pilebuffValue_109,
            DURATION = 999999,
            ICON = 66,
            COUNT = 0,
            MAX = 9
        },
        [6] = {
            ID = 206457506,
            BUFF_ID = 94,  --病気(グラーシーザに)
            VALUE = 100,
            DURATION = 999999,
            ICON = 84
        },
        [7] = {
            ID = 206457507,
            BUFF_ID = 60,  --燃焼耐性
            VALUE = -100,
            DURATION = 999999,
            ICON = 0
        },
        [8] = {
            ID = 206457508,
            BUFF_ID = 109, --燃焼回避率DOWN
            VALUE = -100,
            DURATION = 999999,
            ICON = 0
        }
    }
    self.HPBUFF_BOX_LIST = {
        [1] = {
            ID = 206457511,
            BUFF_ID = 15,    -- 防御力割合
            VALUE = self.GD.hp80buffValue_15,
            DURATION = 9999999,
            ICON = 5
        },
        [2] = {
            ID = 206457512,
            BUFF_ID = 17,    -- 与ダメージUP
            VALUE = self.GD.hp60buffValue_17,
            DURATION = 9999999,
            ICON = 26
        },
        [3] = {
            ID = 206457513,
            BUFF_ID = 15,    -- 防御力割合
            VALUE = self.GD.hp20buffValue_15,
            DURATION = 9999999,
            ICON = 5
        },
    }
    self.TARGET_BUFF_LIST1 = {
        [1] = {
            ID = 05,
            BUFF_ID = 59,--氷結耐性
            VALUE = self.GD.targetBuffValue_59,
            DURATION = 999999,
            ICON = 75
        },
        [2] = {
            ID = 06,
            BUFF_ID = 108,--氷結回避率
            VALUE = self.GD.targetBuffValue_59,
            DURATION = 999999,
            ICON = 0
        }
    }
    self.TARGET_BUFF_LIST0 = {
        [1] = {
            ID = 05,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        },
        [2] = {
            ID = 06,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        }
    }
    self.STUN_BUFF_LIST = {
        ID = 504601100,
        BUFF_ID = 96,   -- グラーシーザ出現時永続氷結状態
        VALUE = 100,
        DURATION = 999999,
        ICON = 86,
        GROUP_ID = 94,
        PRIORITY = 100
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "氷結状態の敵に対してクリティカル", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "一定時間経過するたびに吹雪発動：毒状態で遅延", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "奥義中、被ダメージ軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "クリティカルダメージ耐性", COLOR = Color.yellow}),
    }
    self.PILE_SET_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.PILE_SET_MESSAGE1 or "%sを氷結：グラーシーザを破壊・状態異常回復で解除", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.PILE_SET_MESSAGE2 or "奥義上昇量アップ：グラーシーザ破壊で解除", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.PILE_SET_MESSAGE3 or "グラーシーザ：燃焼ダメージ以外ダメージ耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.PILE_SET_MESSAGE4 or "グラーシーザ病気でボス：ダメージ耐性・クリティカルダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.PILE_SET_MESSAGE5 or "グラーシーザの病気：燃焼で解除", COLOR = Color.yellow}),
    }
    self.PILE_DESTROY_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.PILE_DESTROY_MESSAGE1 or "グラーシーザ破壊成功！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.PILE_DESTROY_MESSAGE2 or "奥義上昇量アップ解除", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.PILE_DESTROY_MESSAGE3 or "気絶状態", COLOR = Color.red})
    }
    self.PILE_ICERECOVERY_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE_LIST1 or "ダメージ耐性・クリティカルダメージアップ：解除", COLOR = Color.red}),
    }
    self.HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE1 or "防御力アップ", COLOR = Color.yellow}),
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "ダメージアップ", COLOR = Color.yellow}),
    }
    self.HP40_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP40_MESSAGE1 or "行動速度アップ", COLOR = Color.yellow}),
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "防御力大アップ", COLOR = Color.yellow}),
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
            action = function (status) self:hp60(status) end,
            HP = 60,
            used = false,
            isEnableSkip = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false,
            isEnableSkip = false
        },
        [4] = {
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

function class:hp80(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 7
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        --self.gameUnit:setInvincibleTime(7)
        self:execAddBuff(self.gameUnit,self.HPBUFF_BOX_LIST[1])
        self.hpskillflg = true
        self:showMessage(self.HP80_MESSAGE_LIST)
        self:pileCheck()
    end
end

--(HARD)
function class:hp60(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 7
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        --self.gameUnit:setInvincibleTime(7)
        self:execAddBuff(self.gameUnit,self.HPBUFF_BOX_LIST[2])
        self:initSkillWeight({HP60 = 100})
        self.hpskillflg = true
        self:showMessage(self.HP60_MESSAGE_LIST)
        self:pileCheck()
    end
end

--(HARD)
function class:hp40(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 4
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        --self.gameUnit:setInvincibleTime(7)
        self.hpskillflg = true
        self.gameUnit:setAttackDelay(self.GD.hp40attackDelay)
        self:showMessage(self.HP40_MESSAGE_LIST)
        self:pileCheck()
    end
end

function class:hp20(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 4
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        --self.gameUnit:setInvincibleTime(7)
        self:execAddBuff(self.gameUnit,self.HPBUFF_BOX_LIST[3])
        self.hpskillflg = true
        self:showMessage(self.HP20_MESSAGE_LIST)
        self:pileCheck()
    end
end

function class:pileCheck()
    local pile = self:findUnit(self.gameUnit,501851250)
    if pile ~= nil then
        pile:setHP(0)
        self:removeStun(self.gameUnit)
        self.gameUnit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID)
        self.gameUnit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[2].ID)
        self.gameUnit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[4].ID)   -- (HARD)
        self.flameFlg = false
        self.pileFLG = false
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 25,
        attackDelay = 7,
        hitStop = 100,
        startAddSP = 0,
        skillTakeDamageValue = 0.01,
        criDamageUpbuffValue_17 = 200,
        hp80buffValue_15 = 200,
        hp60buffValue_17 = 50,
        hp40attackDelay = 5,
        hp20buffValue_15 = 1800,
        tgTimer = 10,
        tgLimit = 99,
        tgIconNum1 = 0,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        tgSlowSpeed = 3,
        targetBuffValue_59 = -150,
        pileHP = 20000,
        pileAddSP = 40,
        pilebrokenbuffTime_89 = 4,
        pilebuffValue_109 = 10,
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
    self.targetUnit = nil
    self.skill1FLG = false
    self.targetUnitIndex = 0

    self.hpskillflg = false
    self.skillflg = false
    self.flameFlg = false

    ---蒼機士ギミック
    self.pileFLG = false
    self.pileEnemyID = 2064576
    self.pileDamageRate = 0.3
    self.count = 0
    self.posX = 0
    self.posY = 0
    --event.unit:setIsPlayFocus(false)

    -- 経過時間ギミック
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit, self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeeddefault = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
    self.timeSpeed = self.timeSpeeddefault

    ---装備ギミック
    self.itemFlg = false
    self.itemId = 160052502;
    self.item = event.unit:setItemSkill(0,self.itemId);

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
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効

    --経過時間ギミック(HARD)
    self:timeGimmick(event.unit)

    ---装備ギミック(HARD)
    if self.itemFlg and self:attackCheck(event.unit) then
        self.itemFlg = false
        self:useItem()
    end

    ---蒼機士ギミック
    local pile = self:findUnit(event.unit,501851250)
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID)
    if pile ~= nil then
        if cond == nil then
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
            self.spValue = self.GD.pileAddSP
        end
        pile:setPosition(self.posX,self.posY)
        self.pileFLG = false

        --pileが病気状態だとバフ追加(HARD)
        local cond = pile:getTeamUnitCondition():findConditionWithType(94);
        if cond ~= nil then
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[4])  --クリティカルダメージ
        else
            event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[4].ID)
        end

        --pileが燃焼状態だと燃焼にさせた相手にバフ追加しpileの病気解除(HARD)
        local cond = pile:getTeamUnitCondition():findConditionWithType(97);
        if cond ~= nil and not self.flameFlg then
            self.flameFlg = true
            local cond2 = pile:getTeamUnitCondition():findConditionWithType(94);
            if cond2 ~= nil then
                pile:getTeamUnitCondition():removeCondition(cond2);
            end
            self:showMessage(self.PILE_ICERECOVERY_MESSAGE_LIST)
            local caster = self:getAncestorUnit(cond:getCaster())
            if caster ~= nil then
                self:addIceResist(caster)
            end
        end

    else
        if cond ~= nil then
            event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID)
            event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[2].ID)
            event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[4].ID)   -- (HARD)
            self:removeStun(event.unit)
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[3])  --気絶
            self.spValue = self.GD.addSP
            self.flameFlg = false
            self:showMessage(self.PILE_DESTROY_MESSAGE_LIST)
        end
        --パイルが無いかつ奥義発動後
        if self.pileFLG then
            self.pileFLG = false
            self.hpSkill = 1
            event.unit:addSP(100)
        end
    end

    return 1
end

function class:findUnit(unit,id)
    local targetTeam = unit:getTeam()
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getUnitID() == id and myTeamUnit:getHP() > 0 then
                return myTeamUnit
            end
        end
    end
    return nil
end

function class:removeStun(unit)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:getTeamUnitCondition():addCondition(self.STUN_BUFF_LIST.ID,0,0,0,0);
        end
    end
    return 1
end

-- 経過時間ギミック(HARD)
function class:timeGimmick(unit)
    if self.timeIndex ~= nil then

        local FLG = 0

        -- ボスが毒状態の場合、遅延
        local cond = unit:getTeamUnitCondition():findConditionWithType(90);
        if cond  then
            FLG = 1
        end

        -- ブレイク中、グラーシーザモーション中、HPトリガー奥義発動中は停止
        if self.hpskillflg or self.skill1FLG or unit:isBreak() then
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

function class:attackCheck(unit)
    local state = unit:getUnitState();
    if state ~= kUnitState_attack and state ~= kUnitState_skill then
        return true;
    end
    return false;
end

-- 燃焼状態にしたユニットに氷結回避率ダウンバフをつける(HARD)
function class:addIceResist(unit)
    ---庇うユニットが居るか確認
    local target = nil
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                target = cond:getProtectTarget()
            end
        end
    end

    if target ~= nil then
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getIndex() == target then
                    self.gameUnit:setHateTarget(teamUnit)
                    self.gameUnit:updateHateTarget();
                    self:execAddBuff(teamUnit,self.TARGET_BUFF_LIST1[1])
                    self:execAddBuff(teamUnit,self.TARGET_BUFF_LIST1[2])
                else
                    self:execAddBuff(teamUnit,self.TARGET_BUFF_LIST0[1])
                    self:execAddBuff(teamUnit,self.TARGET_BUFF_LIST0[2])
                end
            end
        end
    else
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getIndex() == unit:getIndex() then
                    self.gameUnit:setHateTarget(unit)
                    self.gameUnit:updateHateTarget();
                    self:execAddBuff(teamUnit,self.TARGET_BUFF_LIST1[1])
                    self:execAddBuff(teamUnit,self.TARGET_BUFF_LIST1[2])
                else
                    self:execAddBuff(teamUnit,self.TARGET_BUFF_LIST0[1])
                    self:execAddBuff(teamUnit,self.TARGET_BUFF_LIST0[2])
                end
            end
        end
    end

    return 1
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    self.itemFlg = true
    return event.count
end

function class:useItem()
    self.gameUnit:takeItemSkill(0); --吹雪
    self.item:setCoolTimer(0);
end

---------------------------------------------------------------------------------
-- takeCastItem
---------------------------------------------------------------------------------
function class:takeCastItem(event)
    -- castモーションがないので後退で後続に繋げる
    event.unit:setNextAnimationName("back_S")
    return 0;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    ---蒼機士ギミック
    if event.spineEvent == "pileSet" then
        self:stun(event.unit)
        local pile = self:pileSummon(event.unit,self.pileEnemyID)
        if pile ~= nil then
            self.posX = event.unit:getPositionX() + 180
            self.posY = event.unit:getPositionY()
            pile:setDefaultPosition(self.posX,self.posY)
            self.count = self.count + 1
            --local hpCalc = self.GD.pileHP1 + self.GD.pileHP2 * self.count + self.GD.pileHP3 * self.gbAreaNumber^self.GD.pileHP4
            --local hp = (event.unit:getCalcHPMAX() * hpCalc) / 100
            local hp = self.GD.pileHP
            pile:setBaseHP(hp)
            pile:setHP(hp)
            self:unitTargetCheck(event.unit)
            self:showFormatMessage(self.PILE_SET_MESSAGE_LIST[1],self.targetUnit:getUnitName())
            --self:showFormatMessage(self.PILE_SET_MESSAGE_LIST[2],self.ELEMENT_MESSAGE_LIST[self.targetUnit:getElementType()].MESSAGE)
            self:execShowMessage(self.PILE_SET_MESSAGE_LIST[2])
            self:execShowMessage(self.PILE_SET_MESSAGE_LIST[3])
            self:execShowMessage(self.PILE_SET_MESSAGE_LIST[4])
            self:execShowMessage(self.PILE_SET_MESSAGE_LIST[5])
            --self:showMessage(self.PILE_SET_MESSAGE_LIST)
            --self:execAddBuff(pile,self.BUFF_BOX_LIST[7])
            --self:execAddBuff(pile,self.BUFF_BOX_LIST[8])
            self:execAddBuff(pile,self.BUFF_BOX_LIST[6])
            if self.count >= 2 then
                for i = 2, self.count do
                    self:execAddBuff(pile,self.BUFF_BOX_LIST[5])
                end
            end
        end
    end

    if event.spineEvent == "disk1" then
        local disk = event.unit:addOrbitSystem("disk_1",0)
        disk:setDamageRateOffset(1/2)
        disk:setBreakRate(1/2)
    end
    if event.spineEvent == "disk2" then
        local disk = event.unit:addOrbitSystem("disk_2",0)
        disk:setDamageRateOffset(1/2)
        disk:setBreakRate(1/2)
    end
    if event.spineEvent == "defaultPos" then
        event.unit:setPositionX(event.unit:getPositionX() + 100);
    end
    return 1;
end

function class:pileSummon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 5 do
            if unit:getTeam():getTeamUnit(i) == nil then
                local addUnit = unit:getTeam():addUnit(i,unitID)
                return addUnit
            end
        end
    end
    return nil
end

---ユニット氷結,初期位置移動
function class:stun(unit)
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST)
            myTeamUnit:setPosition((x + 480 + math.random(-50,50)),(y + math.random(-50,50)))
        end
    end
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

    self.hpskillflg = false
    self.skillflg = false

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
        if self.skill1FLG then
            self.skill1FLG = false
            self:stun2(event.unit)
        end
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

--一体のみ永続氷結（一番ダメージの大きいユニットを対象）
function class:stun2(unit)
    ---庇うユニットが居るか確認
    local target = nil
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                target = cond:getProtectTarget()
            end
        end
    end

    if target ~= nil then
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getIndex() == target then
                else
                    -- 庇うユニット以外のユニットは氷結解除
                    teamUnit:getTeamUnitCondition():addCondition(self.STUN_BUFF_LIST.ID,0,0,0,0);
                end
            end
        end
    else
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getIndex() == self.targetUnitIndex then
                    --targetElement = myTeamUnit:getElementType()
                else
                    -- ターゲットユニット以外のユニットは氷結解除
                    teamUnit:getTeamUnitCondition():addCondition(self.STUN_BUFF_LIST.ID,0,0,0,0);
                end
            end
        end
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

    self.skillflg = true

    if event.index == 1 then
        self.skill1FLG = true
        self:deBuffRefresh(event.unit)
        event.unit:setInvincibleTime(30)
    elseif event.index == 2 then
        self.pileFLG = true
    elseif event.index == 3 then
        self.pileFLG = true
    end

    if event.index == 4 or event.index == 7 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("1-skill1") ---EFのアニメーション名に気をつける
        self.skill1FLG = true
        self:deBuffRefresh(event.unit)
        event.unit:setInvincibleTime(30)
    elseif event.index == 5 then
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("1-skill2") ---EFのアニメーション名に気をつける
        self.pileFLG = true
    elseif event.index == 6 then
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("1-skill3") ---EFのアニメーション名に気をつける
        self.pileFLG = true
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

function class:deBuffRefresh(unit)
    self.buffIDList = {89,91,96}
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

function class:unitTargetCheck(unit)
    ---ヘイトは全部手動で設定する
    --local target = self:checkTargetUnit()
    --megast.Battle:getInstance():sendEventToLua(self.scriptID,5,target:getIndex())---ゲストにターゲットを送る
    --unit:setHateTarget(target)
    --unit:updateHateTarget();
    ---庇うユニットが居るか確認
    local target = nil
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                target = cond:getProtectTarget()
            end
        end
    end

    if target ~= nil then
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getIndex() == target then
                    self.targetUnitIndex = teamUnit:getIndex()
                    self.targetUnit = teamUnit
                end
            end
        end
    else
        target = self:checkTargetUnit()
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                if i == target:getIndex() then
                    self.targetUnitIndex = teamUnit:getIndex()
                    self.targetUnit = teamUnit
                    local index = teamUnit:getIndex() + (teamUnit:getBaseID3() * 10)
                    if self.targetUnitList[index] == nil then
                        table.insert(self.targetUnitList,index,{unit = teamUnit,dps = 0})
                    end
                end
            end
        end
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

    -- 奥義発動中はダメージ軽減
    if self.skillflg or self.hpskillflg then
        event.value = event.value * self.GD.skillTakeDamageValue
    end

    local pile = self:findUnit(event.unit,501851250)
    if pile ~= nil then
        --グラーシーザが病気状態の場合は固定ダメージ
        local cond = pile:getTeamUnitCondition():findConditionWithType(94);
        if cond ~= nil then
            event.value = 1
        end
    end

    --クリティカル耐性
    local critical = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical then
        event.value = 1
    end

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
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,5,target:getIndex())---ゲストにターゲットを送る
        --event.unit:setHateTarget(target)
        --event.unit:updateHateTarget();
        ---ターゲットにバフ
        --local myTeam = megast.Battle:getInstance():getTeam(true);
        --for i = 0,3 do
        --    local myTeamUnit = myTeam:getTeamUnit(i)
        --    if myTeamUnit ~= nil then
        --        if i == target:getIndex() then
        --            self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
        --        else
        --            self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
        --        end
        --    end
        --end
    end
    ------

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

    self.targetUnit = target
    return target
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
        if self.skill1FLG then
            self.skill1FLG = false
            self:stun2(event.unit)
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- damage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , 1)
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
        self.timeIndex = nil
    end
    --ターゲットリセット
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnitList = {}
    BattleControl:get():visibleHateTarget(false);
    BattleControl:get():setHateTargetIcon(0);
    event.unit:setEnableHate(false);
    event.unit:updateHateTarget();
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


class:publish();

return class;