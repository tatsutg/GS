local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="光威の遺跡第１５階_巨大エミー", version=1.3, id=2005442});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK2 = 50, ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK3 = 50 }
    },
    ADVANCED = {
        { ATTACK4 = 50, ATTACK5 = 50 },
        { ATTACK5 = 50, ATTACK6 = 50 },
        { ATTACK4 = 50, ATTACK6 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 50 }
    },
    ADVANCED = {
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
    SKILL3 = 9
}

class.cutInSkill = {
    --[3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        [1] ={
            ID = 200544201,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 9999999,
            ICON = 21  --物理耐性
        },
        [2] ={
            ID = 200544202,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 9999999,
            ICON = 22  --魔法耐性
        }
    }
    self.STUN_BUFF_LIST = {
        [1] ={
            ID = 200544203,
            BUFF_ID = 89,   --気絶
            VALUE = 100,
            DURATION = 5,
            ICON = 79
        }
    }
    self.HP50_BUFF_BOX_LIST = {
        [1] = {
            ID = 200544210,
            BUFF_ID = 17,  --与ダメージアップ
            VALUE = 20,
            DURATION = 9999999,
            ICON = 26
        },
        [2] = {
            ID = 200544220,
            BUFF_ID = 23, --クリティカル耐性
            VALUE = -50,
            DURATION = 9999999,
            ICON = 188
        }
    }
    self.HP30_BUFF_BOX_LIST = {
        [1] = {
            ID = 200544230,
            BUFF_ID = 17,  --与ダメージアップ
            VALUE = 30,
            DURATION = 9999999,
            ICON = 26
        },
        [2] = {
            ID = 200544240,
            BUFF_ID = 15,   -- 防御力
            VALUE = 100,
            DURATION = 9999999,
            ICON = 5
        }
    }
    self.HP0_BUFF_BOX_LIST = {
        ID = 200544250,
        BUFF_ID = 23, --クリティカル耐性
        VALUE = -100,
        DURATION = 9999999,
        ICON = 188,
        FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 20054001,
        BUFF_ID = 23,---被クリティカル率
        VALUE = 100,
        DURATION = 99999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 20054002,
        BUFF_ID = 0,---被クリティカル率
        VALUE = 0,
        DURATION = 99999,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "ダメージの大きい者をターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ターゲットへのクリティカル率アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ダメージを蓄積", COLOR = Color.yellow})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "フォールン・ドレイン：奥義ゲージ低下", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE2 or "ダメージ無効化無効", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE3 or "ターゲットを気絶＆奥義ゲージ低下", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "エミーがいちばん強いんだから！", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "ダメージ・クリティカル耐性アップ", COLOR = Color.yellow})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "あはははは！滅びろぉお！！", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE2 or "ダメージ・防御力アップ", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "もういいや…全部壊れちゃえ…", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE2 or "物理耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE3 or "魔法耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE4 or "クリティカル耐性・奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({ MESSAGE = self.TEXT.DEAD_MESSAGE1 or "こんなの、嘘…嘘だもん……", COLOR = Color.magenta })
    }
    self.TEXT.RESULT_MESSAGE1 = self.TEXT.RESULT_MESSAGE1 or "累計";
    self.TEXT.RESULT_MESSAGE2 = self.TEXT.RESULT_MESSAGE2 or "ダメージ！";
    self.TEXT.DAMAGE_MESSAGE1 = self.TEXT.DAMAGE_MESSAGE1 or "%d万の";
    self.TEXT.DAMAGE_MESSAGE2 = self.TEXT.DAMAGE_MESSAGE2 or "%d億の";
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.001,
            used = false
        }
    }
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

function class:hp50(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.hpSkill = 1
        self.gameUnit:setInvincibleTime(6)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.HP50_BUFF_BOX_LIST[1])
        self:execAddBuff(self.gameUnit,self.HP50_BUFF_BOX_LIST[2])
    end
end

function class:hp30(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.hpSkill = 1
        self.gameUnit:setInvincibleTime(6)
        self:showMessage(self.HP30_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.HP30_BUFF_BOX_LIST[1])
        self:execAddBuff(self.gameUnit,self.HP30_BUFF_BOX_LIST[2])
    end
end

function class:hp0(status)
    if status == "use3" then
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 20;---addSPの量
    event.unit:setAttackDelay(8);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
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

    self.isAdvanced = false
    self.deadFlg = false
    self.cutInFlg = false
    self.halfHP = event.unit:getHP() / 2
    self.skillCount = 0
    self.attackTypeValue = 0
    self.totalPhysicsDamage = 0
    self.totalMagicDamage = 0
    self.messageTime = 20
    self.messageCount = 1
    self.startTime = BattleControl:get():getTime()
    self.messageValue = {[1]="物理", [2]="魔法"}

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
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効

    --累計ダメージの表示
    if not self.isAdvanced then
        self:damageResultMsg()
    end
    return 1
end

function class:damageResultMsg()
    local time = BattleControl:get():getTime() - self.startTime
    if time > self.messageCount * self.messageTime then
        self.messageCount = self.messageCount + 1
        self:totalDamageCalc(self.totalPhysicsDamage,1)
        self:totalDamageCalc(self.totalMagicDamage,2)
    end
end

function class:totalDamageCalc(totalDamage,attackType)
    local okuBorder = 100000000
    local manBorder = 10000
    local damageG = math.floor(totalDamage/okuBorder);
    local damageM = math.floor(totalDamage%okuBorder/manBorder);
    local damageStr = "";
    local colorStr = ""

    if damageG > 0 then
        local oku = string.format(self.TEXT.DAMAGE_MESSAGE2,damageG);
        local man = string.format(self.TEXT.DAMAGE_MESSAGE1,damageM);
        if damageM == 0 then
            damageStr = self.TEXT.RESULT_MESSAGE1..oku..self.messageValue[attackType]..self.TEXT.RESULT_MESSAGE2;
        else
            damageStr = self.TEXT.RESULT_MESSAGE1..oku..man..self.messageValue[attackType]..self.TEXT.RESULT_MESSAGE2;
        end
    elseif damageM > 0 then
        local man = string.format(self.TEXT.DAMAGE_MESSAGE1,damageM);
        damageStr = self.TEXT.RESULT_MESSAGE1..man..self.messageValue[attackType]..self.TEXT.RESULT_MESSAGE2;
    else
        local damage =  math.floor(totalDamage);
        damageStr = self.TEXT.RESULT_MESSAGE1..damage.."の"..self.messageValue[attackType]..self.TEXT.RESULT_MESSAGE2;
    end

    if attackType == 1 then
        colorStr = summoner.Color.red
    else
        colorStr = summoner.Color.magenta
    end
    summoner.Utility.messageByPlayer(damageStr,5,colorStr);
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "idle2" then event.unit:takeAnimation(0,"idle2",true) end
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

    if self.isAdvanced then
        if event.index == 4 then
            event.unit:setNextAnimationName("attack1_A")
            event.unit:setNextAnimationEffectName("1-attack1")
        elseif event.index == 5 then
            event.unit:setNextAnimationName("attack2_A")
            event.unit:setNextAnimationEffectName("1-attack2")
        elseif event.index == 6 then
            event.unit:setNextAnimationName("attack3_A")
            event.unit:setNextAnimationEffectName("1-attack3")
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

    if self.deadFlg and self.cutInFlg then
        self.cutInFlg = false
        event.unit:takeSkillWithCutin(1,1);
        return 0;
    end

    if event.index == 1 then
        self:showMessage(self.SKILL_MESSAGE_LIST,1)
    elseif event.index == 2 then
        self:addTargetStunBuff()
        self:addSkill2Buff()
        self:showMessage(self.SKILL_MESSAGE_LIST,2)
        self:showMessage(self.SKILL_MESSAGE_LIST,3)
    elseif event.index == 3 then
        self:addTargetStunBuff()
        self:addSkill3Buff()
        self:showMessage(self.SKILL_MESSAGE_LIST,2)
        self:showMessage(self.SKILL_MESSAGE_LIST,3)
    end

    if self.isAdvanced then
        if event.index == 1 then
            event.unit:setNextAnimationName("skill1_A")
            event.unit:setNextAnimationEffectName("1-skill1")
        elseif event.index >= 2 then
            event.unit:setNextAnimationName("skill2_A")
            event.unit:setNextAnimationEffectName("1-skill2")
        end
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

--奥義時のバフ
function class:addTargetStunBuff()
    self.skillCount = self.skillCount + 1
    local valueCalc = 2 + self.skillCount * 3
    local STUN_BUFF_LIST = {
        ID = 2005401,
        BUFF_ID = 89,   --気絶
        VALUE = 100,
        DURATION = valueCalc,
        ICON = 79
    }

    self.gameUnit:updateHateTarget();
    local targetUnit = self.gameUnit:getHateTarget();
    local targetIndex = targetUnit:getIndex()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if i == targetIndex then
                myTeamUnit:setBurstPoint(0)
                myTeamUnit:setPositionX(myTeamUnit:getPositionX() + 200)
                self:execAddBuff(myTeamUnit,STUN_BUFF_LIST)
                self.targetUnitList[targetIndex] = nil ---ゲストの蓄積ダメージを0に
                local enemyUnit = self:getAncestorUnit(myTeamUnit)
                local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
                table.insert(self.targetUnitList,index,{unit = myTeamUnit,dps = 0})
            end
        end
    end

    ---ヘイトは全部手動で設定する
    local target = self:checkTargetUnit()
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

function class:addSkill2Buff()
    local count = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(100)
            if buff == nil then
                count = 1
            else
                count = buff:getNumber() + 1
            end
            if count <= 10 then
                local valueCalc = -30 * count
                local BUFF_LIST = {
                    ID = 2005402,
                    BUFF_ID = 13,   --攻撃力DOWN
                    VALUE = valueCalc,
                    DURATION = 9999999,
                    ICON = 4,
                    COUNT = count,
                    MAX = 11
                }
                self:buffRefresh(myTeamUnit,BUFF_LIST.ID)
                self:execAddBuff(myTeamUnit,BUFF_LIST)
            end
        end
    end
end

function class:addSkill3Buff()
    local count = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(200)
            if buff == nil then
                count = 1
            else
                count = buff:getNumber() + 1
            end
            if count <= 10 then
                local valueCalc = -20 * count
                local BUFF_LIST = {
                    ID = 2005403,
                    BUFF_ID = 32,   --命中率DOWN
                    VALUE = valueCalc,
                    DURATION = 9999999,
                    ICON = 15,
                    COUNT = count,
                    MAX = 11
                }
                self:buffRefresh(myTeamUnit,BUFF_LIST.ID)
                self:execAddBuff(myTeamUnit,BUFF_LIST)
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

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    local attackType = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
    if self.isAdvanced then
        --ダメージ補正
        if attackType == self.attackTypeValue then
            event.value = 1
        end
    else
        --累計ダメージ
        if attackType == 1 then
            self.totalPhysicsDamage = self.totalPhysicsDamage + event.value
        elseif attackType == 2 then
            self.totalMagicDamage = self.totalMagicDamage + event.value
        end
    end

    event.value = self:adjustHpFlg(event.unit,event.value)

    ---ユニットのダメージをテーブルに格納
    local enemyUnit = self:getAncestorUnit(event.enemy)
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

---ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
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
-- takeIn
---------------------------------------------------------------------------------
function class:takeIn(event)
    --event.unit:setNextAnimationName("in2")
    event.unit:setNextAnimationEffectName("change_in")
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.isAdvanced then
        event.unit:setNextAnimationName("idle_A");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    if self.isAdvanced then
        event.unit:setNextAnimationName("back_A");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if not self.deadFlg then
        self:advancedMode()
        return 0
    end
    --event.unit:setNextAnimationName("out2");
    self:showMessage(self.DEAD_MESSAGE_LIST)
    return 1
end

function class:advancedMode()
    self.deadFlg = true
    self.cutInFlg = true
    self.saveBP = self.gameUnit:getBurstPoint()
    self.gameUnit:addSP(100)
    self.hpSkill = 1
    self.gameUnit:setInvincibleTime(6)
    self.gameUnit:setHP(self.halfHP)
    self.spValue = 40;---addSPの量

    --累計ダメージが大きい方の判定(同量なら魔法優先)
    if self.totalPhysicsDamage == self.totalMagicDamage then
        self.attackTypeValue = 2
    elseif self.totalPhysicsDamage < self.totalMagicDamage then
        self.attackTypeValue = 2
    elseif self.totalPhysicsDamage > self.totalMagicDamage then
        self.attackTypeValue = 1
    end

    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:setPositionX(myTeamUnit:getPositionX() + 200)
            self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[1])
        end
    end
    self:execAddBuff(self.gameUnit,self.HP0_BUFF_BOX_LIST)
    self:execAddBuff(self.gameUnit,self.BUFF_LIST[self.attackTypeValue])  --耐性アイコン表示

    if self.attackTypeValue == 1 then
        self:showMessage(self.HP0_MESSAGE_LIST,1)
        self:showMessage(self.HP0_MESSAGE_LIST,2)
        self:showMessage(self.HP0_MESSAGE_LIST,4)
    else
        self:showMessage(self.HP0_MESSAGE_LIST,1)
        self:showMessage(self.HP0_MESSAGE_LIST,3)
        self:showMessage(self.HP0_MESSAGE_LIST,4)
    end

    --トータルダメージinfo表示
    self:totalDamageCalc(self.totalPhysicsDamage,1)
    self:totalDamageCalc(self.totalMagicDamage,2)

    ---パワーアップモード
    self.isAdvanced = true
    self:initAttackWeight({ADVANCED = 100})
    self:initSkillWeight({ADVANCED = 100})
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

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
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