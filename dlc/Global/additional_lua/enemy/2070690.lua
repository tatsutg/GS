local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="フリーレンコラボ_フリーレン(真EX・極)", version=2.4, id=2070690});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK1 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 },
        { SKILL3 = 100 },
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    SKILL5 = 5,
    SKILL6 = 4,
}

class.cutInSkill = {
    [5] = 4,
    [6] = 1,
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 207069001,
            BUFF_ID = 17,   -- 与ダメージ
            VALUE = self.GD.skill3BuffValue_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 10
        },
        [2] = {
            ID = 207069002,
            BUFF_ID = 23,   -- クリティカル耐性
            VALUE = self.GD.hp80BuffValue_23,
            DURATION = 999999,
            ICON = 188,
        },
        [3] = {
            ID = 207069003,
            BUFF_ID = 31,  --回避率
            VALUE = self.GD.hp50BuffValue_31,
            DURATION = 999999,
            ICON = 16,
        },
    }
    self.TIME_BUFF_BOX = {
        [1] = {
            ID = 207069004,
            BUFF_ID = 13,  --攻撃力
            VALUE = self.GD.skill4buffValue_13,
            DURATION = self.GD.skill4buffTime,
            ICON = 4
        }
    }
    self.CHARGE_BUFF_BOX = {
        [1] = {
            ID = 207069005,
            BUFF_ID = 56,  --暗闇耐性
            VALUE = self.GD.buffValue_56,
            DURATION = 999999,
            ICON = 62,
            COUNT = 0,
            MAX = 3
        },
        [2] = {
            ID = 207069006,
            BUFF_ID = 105,  --暗闇回避率
            VALUE = self.GD.buffValue_56,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 3
        },
        [3] = {
            ID = 207069007,
            BUFF_ID = 57,  --病気耐性
            VALUE = self.GD.buffValue_57,
            DURATION = 999999,
            ICON = 63,
            COUNT = 0,
            MAX = 3
        },
        [4] = {
            ID = 207069008,
            BUFF_ID = 106,  --病気回避率
            VALUE = self.GD.buffValue_57,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 3
        },
        [5] = {
            ID = 207069009,
            BUFF_ID = 89,  --気絶
            VALUE = 100,
            DURATION = 3,
            ICON = 79,
        },
        [6] = {
            ID = 207069010,
            BUFF_ID = 52,  --気絶耐性
            VALUE = self.GD.buffValue_52,
            DURATION = 999999,
            ICON = 58,
            COUNT = 0,
            MAX = 3
        },
        [7] = {
            ID = 207069011,
            BUFF_ID = 101,  --気絶回避率
            VALUE = self.GD.buffValue_52,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 3
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "この魔力…魔導書かも", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "人族、炎・光属性からの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "奥義ゲージ低下・反射・魔法耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "魔族キラー", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ダメージ無効化無効", COLOR = Color.red}),
    }
    self.SKILL4_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL4_MESSAGE1 or "地獄の業火を出す魔法：パーティの攻撃力ダウン", COLOR = Color.yellow}),
    }
    self.SKILL5_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL5_MESSAGE1 or "それじゃあ、さっさと終わらせようか", COLOR = Color.yellow}),
    }
    self.CHARGE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.CHARGE_MESSAGE1 or "一般攻撃魔法発動準備", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.CHARGE_MESSAGE2 or "暗闇、病気、宝箱、ブレイクで解除", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.CHARGE_MESSAGE3 or "発動解除成功！", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.CHARGE_MESSAGE4 or "暗闇耐性アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.CHARGE_MESSAGE5 or "病気耐性アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.CHARGE_MESSAGE6 or "気絶耐性アップ", COLOR = Color.red}),
    }
    self.HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE1 or "さて、これはどう？", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE2 or "クリティカル耐性アップ", COLOR = Color.yellow}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "いいね、面白くなってきた", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "回避率アップ", COLOR = Color.yellow}),
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "いいね、魔法使いはこうでなくちゃ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE2 or "奥義上昇量アップ", COLOR = Color.yellow}),
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "うー…", COLOR = Color.yellow})
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
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.chargeModeFlg = 1
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(8)
        self:refresh(self.gameUnit)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
        self:showMessage(self.HP80_MESSAGE_LIST)
        self:showMessage(self.SKILL4_MESSAGE_LIST)
        self:skill4addBuff()
    end
end

function class:hp50(status)
    if status == "use3" then
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.chargeModeFlg = 1
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(8)
        self:refresh(self.gameUnit)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
        self:showMessage(self.HP50_MESSAGE_LIST)
        self:showMessage(self.SKILL4_MESSAGE_LIST)
        self:skill4addBuff()
    end
end

function class:hp20(status)
    if status == "use3" then
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.chargeModeFlg = 1
        self.spValue = self.GD.hp20addSP
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(8)
        self:refresh(self.gameUnit)
        self:showMessage(self.HP20_MESSAGE_LIST)
        self:showMessage(self.SKILL4_MESSAGE_LIST)
        self:skill4addBuff()
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 15,
        attackDelay = 8,
        hitStop = 100,
        magicDamageRate = 0.5,
        chargeDamageRate = 0.2,
        buffValue_56 = 30,
        buffValue_57 = 30,
        skill3BuffValue_17 = 15,
        skill4buffValue_13 = -50,
        skill4buffTime = 10,
        hp80BuffValue_23 = -80,
        hp50BuffValue_31 = 30,
        hp20addSP = 30,
        buffValue_52 = 30
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    --event.unit:addSP(100)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.hpMarkers = {}
    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false
    self.hpSkill = 0
    self.saveBP = 0

    self.chargeModeFlg = 0
    self.sucDbuff = 0
    self.endTimer = 0
    self.END_TIME = 2

    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    self:HPTriggersCheck(event.unit)

    self:chargeMode(event.unit, event.deltaTime)
    return 1
end

function class:chargeMode(unit, deltaTime)
    -- 溜め状態中
    if self.chargeModeFlg == 2 then
        self.hpSkill = 5
        -- 暗闇状態かどうか
        local cond = unit:getTeamUnitCondition():findConditionWithType(93);
        if cond ~= nil then
            self.sucDbuff = 93
        end
        -- 病気状態かどうか
        local cond = unit:getTeamUnitCondition():findConditionWithType(94);
        if cond ~= nil then
            self.sucDbuff = 94
        end
        -- 宝箱状態かどうか
        local cond = unit:getTeamUnitCondition():findConditionWithType(135);
        if cond ~= nil then
            self.sucDbuff = 135
        end

        if self.endTimer > self.END_TIME then
            unit:addSP(20)
            --summoner.Utility.messageByEnemy(self.endTimer)
            self.endTimer = 0
        end
        self.endTimer = self.endTimer + deltaTime
        unit:setSPGainValue(0);
        -- 気絶状態にする
        if self.sucDbuff > 0 then
            self:showMessage(self.CHARGE_MESSAGE_LIST, 3)
            self:execAddBuff(unit,self.CHARGE_BUFF_BOX[5])
            self.saveBP = 0
            self.hpSkill = 0
            unit:setBurstPoint(0)
            self.chargeModeFlg = 99
        end
    elseif self.chargeModeFlg == 99 then
        -- 気絶状態かどうか
        local cond = unit:getTeamUnitCondition():findConditionWithType(89);
        if cond ~= nil then
            return
        end

        -- 受けた状態異常の耐性バフをつける
        if self.sucDbuff == 93 then
            self:showMessage(self.CHARGE_MESSAGE_LIST, 4)
            self:execAddBuff(unit,self.CHARGE_BUFF_BOX[1])
            self:execAddBuff(unit,self.CHARGE_BUFF_BOX[2])
        end
        if self.sucDbuff == 94 then
            self:showMessage(self.CHARGE_MESSAGE_LIST, 5)
            self:execAddBuff(unit,self.CHARGE_BUFF_BOX[3])
            self:execAddBuff(unit,self.CHARGE_BUFF_BOX[4])
        end
        if self.sucDbuff == 135 then
            self:showMessage(self.CHARGE_MESSAGE_LIST, 6)
            self:execAddBuff(unit,self.CHARGE_BUFF_BOX[6])
            self:execAddBuff(unit,self.CHARGE_BUFF_BOX[7])
        end

        self.sucDbuff = 0
        self.chargeModeFlg = 0
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0)
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self:showMessage(self.DEAD_MESSAGE_LIST)
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

    if event.index == 2 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("2-skill1") ---EFのアニメーション名に気をつける
    end

    if self.chargeModeFlg == 1 then
        self.addSpSkipFLG = false
        self.endTimer = 0
        self:refreshAll(self.gameUnit)
        self.gameUnit:setInvincibleTime(0)
        self:showMessage(self.CHARGE_MESSAGE_LIST, 1)
        self:showMessage(self.CHARGE_MESSAGE_LIST, 2)
        self.chargeModeFlg = 2
    elseif self.chargeModeFlg == 3 then
        self.chargeModeFlg = 0
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        --summoner.Utility.messageByEnemy("saveBP")
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    elseif not self.addSpSkipFLG then
        self:addSP(event.unit);
    end
    -----------------------------------
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時、movePatternState()を動かさない---
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    end
    --------------------------------------------------------------------------------------
    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:addSP(unit)
    -- 溜め状態中はやらない
    if self.chargeModeFlg == 0 then
        --summoner.Utility.messageByEnemy("addSP")
        unit:addSP(self.spValue);
    end
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

    --if self.cutInFLG then
    --    self.cutInFLG = false
    --    event.unit:takeSkillWithCutin(event.index,1);
    --    return 0
    --end

    if event.index == 2 then
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
    elseif event.index == 3 then
        self:skill4addBuff()
        self:showMessage(self.SKILL4_MESSAGE_LIST)
    end

    if event.index == 5 then
        self:showMessage(self.SKILL5_MESSAGE_LIST)
        self.gameUnit:setInvincibleTime(10)
        self.chargeModeFlg = 3
    end

    if event.index == 6 then
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("2-skill3") ---EFのアニメーション名に気をつける
    end

    self.skillCheckFlg = false;
    self.cutInFLG = false
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    --self:initAttackWeight({DEFAULT = 100})---奥義使用後はリセットでスキル1からスタート
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

function class:skill4addBuff()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.TIME_BUFF_BOX[1])
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
    local attribute = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
    -- 魔法軽減
    if attribute == 2 then
        event.value = event.value * self.GD.magicDamageRate;
    end
    -- 溜め状態中
    if self.chargeModeFlg == 2 or self.chargeModeFlg == 3 then
        event.value = event.value * self.GD.chargeDamageRate;
    end
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
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
    ---オービット判定
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

    if self.chargeModeFlg == 2 then
        self:showMessage(self.CHARGE_MESSAGE_LIST, 3)
        self:execAddBuff(event.unit,self.CHARGE_BUFF_BOX[5])
        self.saveBP = 0
        self.hpSkill = 0
        event.unit:setBurstPoint(0)
        self.chargeModeFlg = 99
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

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
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

function class:checkDbuff(unit)
    local badStatusIDs = {89,91,96};
    local rtn = false
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
        if cond ~= nil then
            rtn = true;
        end
    end
    return rtn
end

class:publish();

return class;