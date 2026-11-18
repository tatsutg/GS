local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_蒼凰フレイダル(強)", version=1.3, id=600000102});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    STAND = {
        { ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK3 = 50 },
        { ATTACK10 = 50 }
    },
    FLY = {
        { ATTACK4 = 50, ATTACK5 = 50 },
        { ATTACK4 = 50, ATTACK6 = 50 },
        { ATTACK5 = 50, ATTACK6 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    FLY = {
        { SKILL1 = 50 },
        { SKILL2 = 50 },
        { SKILL1 = 50 },
        { SKILL2 = 50 },
        { SKILL3 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    SKILL1 = 7,
    SKILL2 = 8,
    SKILL3 = 9,
    ATTACK10 = 10  --take_off 用
}

class.cutInSkill = {
    --[3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 6010201,
            BUFF_ID = 53,  --毒耐性
            VALUE = 15,
            DURATION = 999999,
            ICON = 59,
            COUNT = 0,
            MAX = 10
        },
        [2] = {
            ID = 6010202,
            BUFF_ID = 56,  --暗闇耐性
            VALUE = 15,
            DURATION = 999999,
            ICON = 62,
            COUNT = 0,
            MAX = 10
        },
        [3] = {
            ID = 6010203,
            BUFF_ID = 60,  --燃焼耐性
            VALUE = 15,
            DURATION = 999999,
            ICON = 66,
            COUNT = 0,
            MAX = 10
        }
    }
    self.BUFF_LIST2 = {
        [1] = {
            ID = 6010204,
            BUFF_ID = 102,  --毒回避率
            VALUE = 15,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10
        },
        [2] = {
            ID = 6010205,
            BUFF_ID = 105,  --暗闇回避率
            VALUE = 15,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10
        },
        [3] = {
            ID = 6010206,
            BUFF_ID = 109,  --燃焼回避率
            VALUE = 15,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10
        }
    }
    self.FRY_BUFF_LIST = {
        [1] = {
            ID = 6010207,
            BUFF_ID = 31,  --回避率UP
            VALUE = 50,
            DURATION = 999999,
            ICON = 16
        },
        [2] = {
            ID = 6010207,
            BUFF_ID = 0,  --回避率UP
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        }
    }
    self.STUN_BUFF_LIST = {
        [1] = {
            ID = 6010208,
            BUFF_ID = 89,  --気絶
            VALUE = 100,
            DURATION = 3,
            ICON = 79
        }
    }
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 6010209,
            BUFF_ID = 59,  --氷結耐性
            VALUE = -20,
            DURATION = 999999,
            ICON = 75,
            COUNT = 0,
            MAX = 10
        },
        [2] = {
            ID = 6010210,
            BUFF_ID = 108,  --氷結回避率
            VALUE = -20,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10
        },
        [3] = {
            ID = 6010211,
            BUFF_ID = 17,  --与ダメ
            VALUE = 20,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 10
        }
    }
    self.TARGET_SKIL_BUFF_LIST = {
        [1] = {
            ID = 6010212,
            BUFF_ID = 96,  --氷結
            VALUE = 100,
            DURATION = 60,
            ICON = 86
        }
    }
    ---ターゲットギミック
    self.TARGET_BUFF_LIST1 = {
        ID = 6010220,
        BUFF_ID = 21,---被ダメージUP
        VALUE = 100,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 6010220,
        BUFF_ID = 0,---被ダメージUP
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "氷結状態の敵へのクリティカル率アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "飛行状態：回避率アップ、被ダメージ軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "飛行状態：毒・燃焼・暗闇状態で解除", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ダメージの大きい者をターゲット・ターゲットへのダメージアップ", COLOR = Color.yellow})
    }
    self.STAND_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.STAND_MESSAGE1 or "毒で飛行状態解除成功！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.STAND_MESSAGE2 or "暗闇で飛行状態解除成功！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.STAND_MESSAGE3 or "燃焼で飛行状態解除成功！", COLOR = Color.red})
    }
    self.FRY_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FRY_MESSAGE1 or "毒耐性アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.FRY_MESSAGE2 or "暗闇耐性アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.FRY_MESSAGE3 or "燃焼耐性アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.FRY_MESSAGE4 or "飛行状態：回避率アップ、被ダメージ軽減", COLOR = Color.red})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "ターゲットを氷結", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {}
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 30;---addSPの量
    event.unit:setAttackDelay(7);---アタックディレイ
    event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
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

    self:initAttackWeight({FLY = 100})
    self:initSkillWeight({FLY = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"
    self.breakSkip = true
    self.hpSkill = 0
    self.saveBP = 0

    ---ボスギミック
    self.windUnit = nil
    self.isWind = false
    self.auraUnit = nil

    self.isFlying = true
    self.attack6Flg = false
    self.deBuffFlg = 0
    self.targetIndex = 0
    self.fryDamageRate = 0.2
    self.fryAddSP = 30
    self.standAddSP = 0
    self.fryAttackDelay = 7
    self.standAttackDelay = 10

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
    if self.isFlying then
        self:execAddBuff(event.unit,self.FRY_BUFF_LIST[1])
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:hpTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効

    --地上モードへの移行
    if self.isFlying then
        self.deBuffFlg = self:findDeBuff(event.unit)
        if self.deBuffFlg ~= 0 then
            self:changeStandMode(event.unit)
        end
    end

    --addSP対策
    if event.unit:getUnitState() ~= kUnitState_attack and self.attack6Flg then
        self.attack6Flg = false
        self:addSP(event.unit)
    end
    return 1
end

function class:findDeBuff(unit)
    local intFlg = 0
    local poison = unit:getTeamUnitCondition():findConditionWithType(90)
    local darkness = unit:getTeamUnitCondition():findConditionWithType(93)
    local nightmare = unit:getTeamUnitCondition():findConditionWithType(131)
    local flame = unit:getTeamUnitCondition():findConditionWithType(97)

    --毒＞暗闇＞燃焼
    if flame ~= nil then
        intFlg = 3
    end

    if darkness ~= nil or nightmare ~= nil then
        intFlg = 2
    end

    if poison ~= nil then
        intFlg = 1
    end
    return intFlg
end

function class:changeStandMode(unit)
    self.isFlying = false
    self.spValue = self.standAddSP;---addSPの量
    unit:setAttackDelay(self.standAttackDelay);---アタックディレイ
    self:execAddBuff(unit,self.FRY_BUFF_LIST[2])  --回避バフ解除
    self:execAddBuff(unit,self.STUN_BUFF_LIST[1])  --気絶
    self:deBuffRefresh(unit)
    self:buffRefresh(unit)  --奥義バフ(skill1)削除用
    self:initAttackWeight({STAND = 100})
    self:showMessage(self.STAND_MESSAGE_LIST,self.deBuffFlg)
end

function class:changeFryMode(unit)
    self.isFlying = true
    self.spValue = self.fryAddSP;---addSPの量
    unit:setAttackDelay(self.fryAttackDelay);---アタックディレイ
    self:execAddBuff(unit,self.FRY_BUFF_LIST[1])  --回避バフ
    self:execAddBuff(unit,self.BUFF_LIST[self.deBuffFlg])  --デバフ耐性
    self:execAddBuff(unit,self.BUFF_LIST2[self.deBuffFlg])  --デバフ回避率
    self:initAttackWeight({FLY = 100})
    --self:initSkillWeight({FLY = 100})
    unit:setNextAnimationName("take_off");
    unit:setNextAnimationEffectName("empty");
    local buffCount = 0
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[self.deBuffFlg].ID);
    if cond ~= nil then
        buffCount = cond:getNumber()
    end

    self:showMessage(self.FRY_MESSAGE_LIST,4)
    if buffCount <= 9 then
        self:showMessage(self.FRY_MESSAGE_LIST,self.deBuffFlg)
    end
end

function class:deBuffRefresh(unit)
    local badStatusIDs = {90,93,97,131};
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

function class:buffRefresh(unit)
    local badStatusIDs = {88607400,88607701,88607700,88607701};
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

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "takeOffEnd" then
        --self.isFlying = true
        --event.unit:takeSkill(1)
    end

    if "showWindAura" == event.spineEvent or "hideWindAura" == event.spineEvent then
        --self:switchWind(event.spineEvent)
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

    if event.index == 3 then
        event.unit:setAttackDelay(1);---アタックディレイ
    elseif event.index == 6 then
        self.attack6Flg = true
    elseif event.index == 10 then
        self:changeFryMode(event.unit)
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

    if event.index == 1 then
        self:takeSkillDeBuff()
    elseif event.index == 2 then
        self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[3])  --与ダメUP
        self:takeTargetDeBuff(self.targetIndex)
        self:showMessage(self.SKILL_MESSAGE_LIST)
    end

    if event.index == 2 and self.isRage then
        self.isRage = false
    elseif event.index == 3 and self.isFury then
        self.isFury = false
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

---ボスギミック
function class:takeSkillDeBuff()
    ---庇うユニットが居るか確認
    local target = nil
    local loopNum = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            loopNum = loopNum + 1
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                target = cond:getProtectTarget()
            end
        end
    end

    if target ~= nil then
        --庇うユニットが居た場合
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getIndex() == target then
                    for l = 1,loopNum do
                        self:execAddBuff(teamUnit,self.SKILL_BUFF_LIST[1])
                        self:execAddBuff(teamUnit,self.SKILL_BUFF_LIST[2])
                    end
                end
            end
        end
    else
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,self.SKILL_BUFF_LIST[1])
                self:execAddBuff(teamUnit,self.SKILL_BUFF_LIST[2])
            end
        end
    end
end

function class:takeTargetDeBuff(targetIndex)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            if targetIndex == teamUnit:getIndex() then
                self:execAddBuff(teamUnit,self.TARGET_SKIL_BUFF_LIST[1])
            end
        end
    end
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.isFlying then
        event.value = event.value * self.fryDamageRate
    end

    --ターゲットギミック
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local targetIndex = enemyUnit:getIndex()
    ---ユニットのダメージをテーブルに格納
    --local enemyUnit = self:getAncestorUnit(event.enemy)
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
                    self.targetIndex = i
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
        return self:calcDamageValue(unit,stopBorder,value)
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
    ---ヘイトは全部手動で設定する
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local target = myTeam:getTeamUnit(args.arg)
    self.gameUnit:setHateTarget(target)
    self.gameUnit:updateHateTarget();
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
    if self.afterSkillFLG then
        self.gameUnit:setInvincibleTime(0)
    end

    if self.isFlying then
        event.unit:setNextAnimationName("idle")
    else
        event.unit:setNextAnimationName("idle2")
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.isFlying then
        event.unit:setNextAnimationName("out")
    else
        event.unit:setNextAnimationName("out2")
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
            self:execTrigger(index)
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
    self.TRIGGERS[index].action(action)
    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

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