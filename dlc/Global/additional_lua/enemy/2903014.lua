local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="29章_HARD_ヴェルザード", version=1.3, id=2903014});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    },
    HP50 = {
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL3 = 100 },
        { SKILL5 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL3 = 4,
    SKILL5 = 5
}

class.cutInSkill = {
    [3] = 0,
    [5] = 1
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 2903001,
            BUFF_ID = 17,  --与ダメ
            VALUE = self.gimmickData.buffValue_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 2903002,
            BUFF_ID = 89, --気絶
            VALUE = 100,
            DURATION = self.gimmickData.buffTime_89,
            ICON = 79
        },
        [3] = {
            ID = 2903003,
            BUFF_ID = 13,  --攻撃力ダウン
            VALUE = self.gimmickData.buffValue_13,
            DURATION = 999999,
            ICON = 4,
            COUNT = 0,
            MAX = 10
        },
        [4] = {
            ID = 2903004,
            BUFF_ID = 129,  --継続ダメージ
            VALUE = self.gimmickData.buffValue_129,
            DURATION = 999999,
            ICON = 180,
            COUNT = 0,
            MAX = 30,
            SCRIPT = {
                SCRIPT_ID = 228
            }
        },
        [5] = {
            ID = 2903005,
            BUFF_ID = 22,  --クリティカル率UP
            VALUE = self.gimmickData.hpBuffValue_22_1,
            DURATION = 999999,
            ICON = 11
        },
        [6] = {
            ID = 2903006,
            BUFF_ID = 15,  --防御力UP
            VALUE = self.gimmickData.hpBuffValue_15,
            DURATION = 999999,
            ICON = 5
        },
        [7] = {
            ID = 2903007,
            BUFF_ID = 52,  --気絶耐性
            VALUE = self.gimmickData.hpBuffValue_52,
            DURATION = 999999,
            ICON = 58
        },
        [8] = {
            ID = 2903008,
            BUFF_ID = 101,  --気絶回避
            VALUE = self.gimmickData.hpBuffValue_101,
            DURATION = 999999,
            ICON = 0
        },
        [9] = {
            ID = 2903009,
            BUFF_ID = 17,  --与ダメ
            VALUE = self.gimmickData.hpBuffValue_17,
            DURATION = 999999,
            ICON = 26
        },
        [10] = {
            ID = 2903010,
            BUFF_ID = 0, --オーラ用
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        },
        [11] = {
            ID = 2903011,
            BUFF_ID = 22,  --クリティカル率UP
            VALUE = self.gimmickData.hpBuffValue_22_2,
            DURATION = 999999,
            ICON = 11
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "宴の始まりだ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・奥義ゲージ低下・クリティカル耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ダメージ無効化無効", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "気絶状態のとき、被ダメージアップ", COLOR = Color.yellow})
    }
    self.SKILL3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "くっ……姑息な！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE2 or "を気絶・攻撃力ダウン", COLOR = Color.red})
    }
    self.SKILL5_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL5_MESSAGE1 or "私の邪魔をするな！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL5_MESSAGE2 or "パーティに持続ダメージ", COLOR = Color.red})
    }
    self.HP75_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE1 or "汝が魂は、このヴェルザードが救済しよう", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP75_MESSAGE2 or "奥義上昇量・クリティカル率アップ", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "すべては我が主のために", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "奥義上昇量・防御力アップ", COLOR = Color.yellow})
    }
    self.HP25_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE1 or "恐れよ、讃えよ、そして受け入れよ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP25_MESSAGE2 or "気絶耐性・ダメージアップ", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "私もやがては赤に呑まれるだろう", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE2 or "クリティカル率アップ", COLOR = Color.yellow})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "くっ……月の子だけは……", COLOR = Color.red})
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
            isEnableSkip = true
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = true
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp25(status) end,
            HP = 25,
            used = false,
            isEnableSkip = true
        },
        [4] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
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

function class:hp75(status)
    if status == "use3" then
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.hpSkill = 3
        self.hpFlg = true
        self.gameUnit:setInvincibleTime(10)
        self.spValue = self.spValue + self.gimmickData.addSpPlusValue1
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[5])  --クリティカル率
        self:showMessage(self.HP75_MESSAGE_LIST)
    end
end

function class:hp50(status)
    if status == "use3" then
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.hpSkill = 5
        self.hpFlg = true
        self.gameUnit:setInvincibleTime(10)
        self.spValue = self.spValue + self.gimmickData.addSpPlusValue2
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[6])  --防御力
        self:initAttackWeight({HP50 = 100})
        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end

function class:hp25(status)
    if status == "use3" then
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.hpSkill = 3
        self.hpFlg = true
        self.gameUnit:setInvincibleTime(10)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[7])  --気絶耐性
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[8])  --気絶回避
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[9])  --与ダメージ
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[10])  --オーラ
        self:showMessage(self.HP25_MESSAGE_LIST)
    end
end

function class:hp0(status)
    if status == "use3" then
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.hpSkill = 5
        self.gameUnit:setInvincibleTime(10)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[11])  --クリティカル率
        self:showMessage(self.HP0_MESSAGE_LIST)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gimmickData = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 10,
        attackDelay = 7,
        hitStop = 100,
        buffValue_17 = 40,
        buffValue_13 = -30,
        buffValue_129 = 1,
        hpBuffValue_22_1 = 20,
        hpBuffValue_22_2 = 50,
        hpBuffValue_15 = 50,
        hpBuffValue_52 = 30,
        hpBuffValue_101 = 30,
        hpBuffValue_17 = 50,
        buffTime_89 = 20,
        addSpPlusValue1 = 5,
        addSpPlusValue2 = 5
    })
    self:dump(self.gimmickData)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.gimmickData.addSP;---addSPの量
    event.unit:setAttackDelay(self.gimmickData.attackDelay);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
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

    --ボスギミック
    self.hpFlg = false
    self.hp50Flg = true
    self.skill3Flg = false
    self.skill5Flg = false
    self.badStatusList = { 89,91,96 }  --気絶、麻痺、凍結
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(self.gimmickData.hitStop,1)---ヒットストップ無効or時止め無効
    self:HPTriggersCheck(event.unit)
    ---HP50%で攻撃パターン変化
    if self.TRIGGERS[2].used and self.hp50Flg then
        self.hp50Flg = false
        self:initAttackWeight({HP50 = 100})
    end

    ---奥義中か確認
    --真奥義
    if event.unit:getUnitState() ~= kUnitState_skill and self.skill3Flg then
        self.hpFlg = false
        self.skill3Flg = false
        local deBuffFlg = self:deBuffCheck(event.unit)
        if deBuffFlg or event.unit:isBreak() then
            self:showMessage(self.SKILL3_MESSAGE_LIST,1)
        else
            self:skill3EndBuff()
        end
    end
    --超奥義
    if event.unit:getUnitState() ~= kUnitState_skill and self.skill5Flg then
        self.hpFlg = false
        self.skill5Flg = false
        local deBuffFlg = self:deBuffCheck(event.unit)
        if deBuffFlg or event.unit:isBreak() then
            self:showMessage(self.SKILL5_MESSAGE_LIST,1)
        else
            self:skill5EndBuff()
            self:showMessage(self.SKILL5_MESSAGE_LIST,2)
        end
    end

    ---死亡時処理
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.lastSkillFLG == nil then self.lastSkillFLG = false end
        if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
            event.unit:getTeam():deadUnit(event.unit:getIndex());
            self:showMessage(self.DEAD_MESSAGE_LIST)
            megast.Battle:getInstance():waveEnd(true);
        end
        if self.TRIGGERS[4].used then
            if self.deadCount == nil then self.deadCount = 0 end
            self.deadCount = self.deadCount + event.deltaTime
            if self.deadCount >= 7 then
                self:showMessage(self.DEAD_MESSAGE_LIST)
                event.unit:getTeam():deadUnit(event.unit:getIndex());
                megast.Battle:getInstance():waveEnd(true);
            end
        end
    end
    return 1
end

function class:deBuffCheck(unit)
    for k,v in pairs(self.badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return true
        end
    end
    return false
end

function class:skill3EndBuff()
    local targetUnit = nil
    local flag = true
    local count = 0
    local rand = 0
    --プレイヤーユニットが一体のみか判定
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            count = count + 1
            targetUnit = myTeamUnit:getIndex()
        end
    end
    --プレイヤーユニットが居ない場合は終了
    if count == 0 then
        return
    end

    while flag do
        rand = math.random(0,3);
        if count == 1 then
            rand = targetUnit
        end

        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getIndex() == rand then
                    flag = false
                    if megast.Battle:getInstance():isHost() then
                        self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[2])  --気絶
                        self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[3])  --攻撃力ダウン
                        --self:execShowFixedMessage(self.SKILL3_MESSAGE_LIST[2],myTeamUnit:getUnitName())
                        self:showFormatMessage(self.SKILL3_MESSAGE_LIST[2],myTeamUnit:getUnitName())
                        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,rand)
                    end
                end
            end
        end
    end
end

function class:receive6(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == args.arg then
                self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[2])  --気絶
                self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[3])  --攻撃力ダウン
                --self:execShowFixedMessage(self.SKILL3_MESSAGE_LIST[2],myTeamUnit:getUnitName())
                self:showFormatMessage(self.SKILL3_MESSAGE_LIST[2],myTeamUnit:getUnitName())
            end
        end
    end
    return 1
end

function class:skill5EndBuff()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[4])  --継続ダメージ
        end
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
    --self:showMessage(self.DEAD_MESSAGE_LIST)
    --megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    --self:showMessage(self.DEAD_MESSAGE_LIST)
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
    elseif event.index == 3 then
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("2-skill2") ---EFのアニメーション名に気をつける
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
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

    if event.index == 3 then
        self.skill3Flg = true
    elseif event.index == 5 then
        self.skill5Flg = true
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
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

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
    ---ダメージ軽減ギミック
    if self.hpFlg then
        event.value = 1
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

function class:execShowFixedMessage(messageBox,str)
    local fixedMessage = str..messageBox.MESSAGE
    summoner.Utility.messageByEnemy(fixedMessage,messageBox.DURATION,messageBox.COLOR);
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