local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="35章_HARD_堕天神獣ヴァルザンデス", version=2.5, id=3505033});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL1 = 4,
    SKILL2 = 4,
    SKILL3 = 5
}

class.cutInSkill = {
    [3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.TIMEBUFF_BOX_LIST = {
        [1] = {
            ID = 350503301,
            BUFF_ID = 17,   -- クリティカルダメージ
            VALUE = self.GD.tg1BuffValue_17,
            DURATION = 999999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 22
            },
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 350503302,
            BUFF_ID = 1,   -- 最大HP固定値
            VALUE = self.GD.tg2BuffValue_1,
            DURATION = 999999,
            ICON = 2,
            COUNT = 0,
            MAX = 99
        },
    }
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 350503303,
            BUFF_ID = self.targetElement,   -- 属性耐性
            VALUE = self.GD.hp60BuffValue_61_65,
            DURATION = 999999,
            ICON = self.targetElementIcon,
        },
        [2] = {
            ID = 350503304,
            BUFF_ID = 112,   -- 状態異常耐性
            VALUE = self.GD.hp60buffValue_112,
            DURATION = 999999,
            ICON = 67,
        },
        [3] = {
            ID = 350503305,
            BUFF_ID = 113,   -- 状態異常回避率
            VALUE = self.GD.hp60buffValue_112,
            DURATION = 999999,
            ICON = 0,
        },
        [4] = {
            ID = 350503306,
            BUFF_ID = 112,   -- 状態異常耐性
            VALUE = self.GD.hp20buffValue_112,
            DURATION = 999999,
            ICON = 67,
        },
        [5] = {
            ID = 350503307,
            BUFF_ID = 113,   -- 状態異常回避率
            VALUE = self.GD.hp20buffValue_112,
            DURATION = 999999,
            ICON = 0,
        },
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下・水属性耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "ダメージの大きい者をターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ターゲットへのクリティカル率アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "時間経過でボスのクリダメアップ：暗闇で遅延", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "時間経過でパーティの最大HPダウン：気絶で停止", COLOR = Color.white}),
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE_LIST1 or "シャドウライトニング：ダメージ無効化無効", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE_LIST2 or "堕天の咆哮：ダメージ無効化無効", COLOR = Color.yellow}),
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "状態異常耐性・%s属性耐性アップ", COLOR = Color.yellow}),
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "状態異常耐性・奥義上昇量アップ", COLOR = Color.yellow}),
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

function class:hp60(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3
            self.saveBP = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
        end
        self.cutInFLG = true
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(5)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
        self:hp60addBuff()
    end
end

function class:hp60addBuff()
    ---ホストのみ---
    if megast.Battle:getInstance():isHost() then
        -- タゲとってなければ左のユニット
        if self.targetUnit == nil then
            local targetTeam = megast.Battle:getInstance():getTeam(true)
            for i = 0,6 do
                local myTeamUnit = targetTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    self.targetUnit = myTeamUnit
                    break;
                end
            end
        end

        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getIndex() == self.targetUnit:getIndex() then
                    self:setTargetElement(myTeamUnit)
                    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
                    self:showFormatMessage(self.HP60_MESSAGE_LIST[1],self.ELEMENT_MESSAGE_LIST[myTeamUnit:getElementType()].MESSAGE)
                    megast.Battle:getInstance():sendEventToLua(self.scriptID,7,self.targetUnit:getIndex())
                end
            end
        end
        ---ターゲットユニットの累計ダメージリセット
        self.gameUnit:updateHateTarget();
        local target = self.gameUnit:getHateTarget();
        local targetIndex = 0
        if target ~= nil then
            targetIndex = target:getIndex()
        end
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if i == targetIndex then
                    self.targetUnitList[targetIndex] = nil ---ゲストの蓄積ダメージを0に
                    local enemyUnit = self:getAncestorUnit(myTeamUnit)
                    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
                    table.insert(self.targetUnitList,index,{unit = myTeamUnit,dps = 0})
                end
            end
        end
        --ヘイトは全部手動で設定する
        local target = self:checkTargetUnit()
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex())---ゲストにターゲットを送る
        self.gameUnit:setHateTarget(target)
        self.gameUnit:updateHateTarget();
        --ターゲットにバフ
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
end

function class:receive7(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if args.arg == myTeamUnit:getIndex() then
                self:setTargetElement(myTeamUnit)
                self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
                self:showFormatMessage(self.HP60_MESSAGE_LIST[1],self.ELEMENT_MESSAGE_LIST[myTeamUnit:getElementType()].MESSAGE)
            end
        end
    end
    return 1
end

function class:setTargetElement(unit)
    if unit:getElementType() == 1 then
        self.targetElement = 61
        self.targetElementIcon = 38
    end
    if unit:getElementType() == 2 then
        self.targetElement = 62
        self.targetElementIcon = 39
    end
    if unit:getElementType() == 3 then
        self.targetElement = 63
        self.targetElementIcon = 40
    end
    if unit:getElementType() == 4 then
        self.targetElement = 64
        self.targetElementIcon = 41
    end
    if unit:getElementType() == 5 then
        self.targetElement = 65
        self.targetElementIcon = 42
    end
    self:setBuffBoxList()
end

function class:hp20(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3
            self.saveBP = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
        end
        self.cutInFLG = true
        self:refresh(self.gameUnit)
        self.spValue = self.GD.hp20addSP
        self.gameUnit:setInvincibleTime(5)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[5])
        self:showMessage(self.HP20_MESSAGE_LIST)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        attackDelay = 5,
        hitStop = 100,
        targetBuff_23 = 100,
        tg1Timer = 20,
        tg1Limit = 99,
        tg1IconNum1 = 26,
        tg1IconNum2 = 0,
        tg1PosX = -100,
        tg1PosY = 0,
        tg1Scale = 1,
        tg1BuffValue_17 = 40,
        tg2Timer = 25,
        tg2Limit = 99,
        tg2IconNum1 = 2,
        tg2IconNum2 = 0,
        tg2PosX = 100,
        tg2PosY = 0,
        tg2Scale = 1,
        tg2BuffValue_1 = -1000,
        hp60BuffValue_61_65 = 100,
        hp60buffValue_112 = 20,
        hp20buffValue_112 = 40,
        hp20addSP = 40
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

    self.targetElement = 0
    self.targetElementIcon = 0

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

    -- 経過時間ギミック(1)
    self.time1Index = megast.Battle:getInstance():createExtraTimer(self.GD.tg1Timer, self.GD.tg1Limit, self.GD.tg1IconNum1, self.GD.tg1IconNum2, self.GD.tg1PosX, self.GD.tg1PosY, self.GD.tg1Scale);
    self.time1Speeddefault = megast.Battle:getInstance():getExtraTimerSpeed(self.time1Index)
    self.time1Speed = self.time1Speeddefault

    -- 経過時間ギミック(2)
    self.time2Index = megast.Battle:getInstance():createExtraTimer(self.GD.tg2Timer, self.GD.tg2Limit, self.GD.tg2IconNum1, self.GD.tg2IconNum2, self.GD.tg2PosX, self.GD.tg2PosY, self.GD.tg2Scale);
    self.time2Speeddefault = megast.Battle:getInstance():getExtraTimerSpeed(self.time2Index)
    self.time2Speed = self.time2Speeddefault

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
    ---経過時間ギミック
    self:timeGimmick(event.unit)
    return 1
end

function class:timeGimmick(unit)
    -- 暗闇状態かどうか
    local cond = unit:getTeamUnitCondition():findConditionWithType(93);
    local nightmare = unit:getTeamUnitCondition():findConditionWithType(131)  --ナイトメア
    if cond ~= nil or nightmare ~= nil then
        --・時計速度セッター、ゲッター
        self.time1Speed = self.time1Speeddefault / 4
    else
        self.time1Speed = self.time1Speeddefault
    end
    -- ブレイク中は止める
    if unit:isBreak() then
        self.time1Speed = 0
    end

    -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
    if megast.Battle:getInstance():getExtraTimerSpeed(self.time1Index) ~= self.time1Speed then
        megast.Battle:getInstance():setExtraTimerSpeed(self.time1Index , self.time1Speed)
        self.time1Speed = megast.Battle:getInstance():getExtraTimerSpeed(self.time1Index)
    end

    -- 気絶状態かどうか
    local cond = unit:getTeamUnitCondition():findConditionWithType(89);
    local takara = unit:getTeamUnitCondition():findConditionWithType(135);  -- 宝箱
    if cond ~= nil or takara ~= nil then
        --・時計速度セッター、ゲッター
        self.time2Speed = 0
    else
        self.time2Speed = self.time2Speeddefault
    end
    -- ブレイク中は止める
    if unit:isBreak() then
        self.time2Speed = 0
    end

    -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
    if megast.Battle:getInstance():getExtraTimerSpeed(self.time2Index) ~= self.time2Speed then
        megast.Battle:getInstance():setExtraTimerSpeed(self.time2Index , self.time2Speed)
        self.time2Speed = megast.Battle:getInstance():getExtraTimerSpeed(self.time2Index)
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    if event.index == 0 then
        self:execAddBuff(event.unit,self.TIMEBUFF_BOX_LIST[1])
    end
    if event.index == 1 then
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                self:execAddBuff(myTeamUnit,self.TIMEBUFF_BOX_LIST[2])
            end
        end
    end
    return event.count
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

    --[[
    if event.index == 2 then
        event.unit:setNextAnimationName("attack1");
        event.unit:setNextAnimationEffectName("1-attack1");
    elseif event.index == 3 then
        event.unit:setNextAnimationName("attack2");
        event.unit:setNextAnimationEffectName("1-attack2");
    end
    ]]

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

    --if event.index == 1 and self.cutInFLG then
    --    self.cutInFLG = false
    --    event.unit:takeSkillWithCutin(event.index,1);
    --    return 0
    --end

    if event.index == 1 then
        self:showMessage(self.SKILL_MESSAGE_LIST, 1)
    end
    if event.index == 3 then
        self:showMessage(self.SKILL_MESSAGE_LIST, 2)
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

class:publish();

return class;