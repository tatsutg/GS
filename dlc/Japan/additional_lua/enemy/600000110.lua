--@additionalEnemy,600000112
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_強_絶氷竜アエルグラキエス", version=2.0, id=600000110});
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
    SKILL2 = 6
}

class.cutInSkill = {
    --[3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 6011001,
            BUFF_ID = 60,  --燃焼耐性
            VALUE = self.GD.buffVal_60_1,
            DURATION = 999999,
            ICON = 66,
            MAX = 20
        },
        [2] = {
            ID = 6011002,
            BUFF_ID = 109,  --燃焼回避率
            VALUE = self.GD.buffVal_60_1,
            DURATION = 999999,
            ICON = 0,
            MAX = 20
        },
        [3] = {
            ID = 6011008,
            BUFF_ID = 59, --氷結耐性
            VALUE = self.GD.buffVal_59,
            DURATION = 999999,
            ICON = 75,
            MAX = 10
        },
        [4] = {
            ID = 6011009,
            BUFF_ID = 108, --氷結回避
            VALUE = self.GD.buffVal_59,
            DURATION = 999999,
            ICON = 0,
            MAX = 10
        }
    }
    self.BURN_BUFF_LIST = {
        [1] = {
            ID = 6011001,
            BUFF_ID = 60,  --燃焼耐性
            VALUE = 10,
            DURATION = 999999,
            ICON = 66,
            MAX = 20
        },
        [2] = {
            ID = 6011010,
            BUFF_ID = 60,  --燃焼耐性
            VALUE = -10,
            DURATION = 999999,
            ICON = 76,
            MAX = 20
        }
    }
    self.ICE_BUFF_LIST = {
        [1] = {
            ID = 6011003,
            BUFF_ID = 96, --氷結
            VALUE = 100,
            DURATION = self.GD.buffTime_96_1,
            ICON = 86
        },
        [2] = {
            ID = 6011004,
            BUFF_ID = 96, --氷結
            VALUE = 100,
            DURATION = self.GD.buffTime_96_2,
            ICON = 86
        }
    }
    self.TIME_BUFF_LIST = {
        [1] = {
            ID = 6011005,
            BUFF_ID = 23,  --クリティカル耐性DOWN
            VALUE = self.GD.buffVal_23,
            DURATION = 999999,
            ICON = 13,
            MAX = 99
        },
        [2] = {
            ID = 6011006,
            BUFF_ID = 2,  --最大HP
            VALUE = self.GD.buffVal_2,
            DURATION = 999999,
            ICON = 2,
            MAX = 99
        },
        [3] = {
            ID = 6011007,
            BUFF_ID = 13,  --攻撃力
            VALUE = self.GD.buffVal_13,
            DURATION = 999999,
            ICON = 4,
            MAX = 99
        }
    }
    self.TIME_UNIT_BUFF_LIST = {
        [1] = {
            ID = 6011006,
            BUFF_ID = 2,  --最大HP
            VALUE = self.GD.buffVal_2,
            DURATION = 999999,
            ICON = 2
        },
        [2] = {
            ID = 6011007,
            BUFF_ID = 13,  --攻撃力
            VALUE = self.GD.buffVal_13,
            DURATION = 999999,
            ICON = 4
        }
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 6011050,
        BUFF_ID = 23,---被クリティカル率
        VALUE = self.GD.targetBuffVal_23,
        DURATION = 99999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 6011050,
        BUFF_ID = 0, ---被クリティカル率
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "クリティカル・反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "燃焼時間が長いほどボスのクリティカル耐性ダウン", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "燃焼状態のとき、被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "最大HPの大きい者をターゲット・ターゲットへのダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "凍傷：氷結時間が長いほどユニットのHP・攻撃力低下", COLOR = Color.red})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "ターゲットを氷結", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE2 or "ターゲット以外を氷結", COLOR = Color.red})
    }
    self.BUFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BUFF_MESSAGE1 or "燃焼耐性アップ", COLOR = Color.red})
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "キングレキュオンが加勢した", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE2 or "キングレキュオン：クリティカルダメージ耐性", COLOR = Color.red})
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
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255)
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist")
            end
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 30,
        attackDelay = 8,
        hitStop = 100,
        dmgVal = 0.5,
        deBuffDmgVal = 1.1,
        bossBuffTime = 1,
        unitBuffTime = 1,
        buffVal_2 = 2,
        buffVal_13 = 2,
        buffVal_23 = 5,
        buffVal_59 = -20,
        buffVal_60_1 = 20,
        buffVal_60_2 = 30,
        targetBuffVal_23 = 100,
        buffTime_96_1 = 60,
        buffTime_96_2 = 20,
        startSummon = 2,
        attackSummon = 2,
        skillSummon = 3
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

    ---ボスギミック
    self.burnBuffFlg = nil
    self.summonUnitID = 600000112
    self.targetIndex = 0
    self.bossTimeBuff = 0
    self.unitTimeBuffTbl = {}
    for i = 0,3 do
        self.unitTimeBuffTbl[i] = 0
    end

    ---自動ヘイトは使わない
    self.targetUnitList = {}
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();

    --ボス固有の変数
    self.isLockOn = true
    self.neckAngle = 0
    self.shotAngle = 0
    self.isFireEnd = true
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:execAddBuff(event.unit,self.BUFF_LIST[1])
    self:execAddBuff(event.unit,self.BUFF_LIST[2])
    local burn = event.unit:getTeamUnitCondition():findConditionWithID(self.BURN_BUFF_LIST[1].ID); --燃焼耐性アップ
    if burn ~= nil then
        burn:setNumber(self.GD.buffVal_60_1 / 10)
    end
    self:MultipleSummon(self.gameUnit,self.summonUnitID,self.GD.startSummon)  --召喚
    self:showMessage(self.SUMMON_MESSAGE_LIST)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:hpTriggersCheck(event.unit)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    ---燃焼耐性ギミック
    self:barnBuffCheck(event.unit,event.deltaTime)
    ---氷結時間ギミック
    self:iceBuffCheck(event.unit,event.deltaTime)
    return 1
end

function class:barnBuffCheck(unit,time)
    local burn = unit:getTeamUnitCondition():findConditionWithType(97);
    if burn ~= nil then
        self.burnBuffFlg = true
    else
        if self.burnBuffFlg then
            self.burnBuffFlg = false
            local value = 0
            local burn = unit:getTeamUnitCondition():findConditionWithID(self.BURN_BUFF_LIST[1].ID); --燃焼耐性アップ
            local burn2 = unit:getTeamUnitCondition():findConditionWithID(self.BURN_BUFF_LIST[2].ID); --燃焼耐性ダウン
            local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[2].ID); --燃焼回避
            if cond ~= nil then
                local buffValue = cond:getValue() + self.GD.buffVal_60_2
                if buffValue == 0 then
                    cond:setValue(buffValue)
                    if burn ~= nil then
                        unit:getTeamUnitCondition():removeCondition(burn)
                    end

                    if burn2 ~= nil then
                        unit:getTeamUnitCondition():removeCondition(burn2)
                    end
                elseif buffValue >= 10 then
                    self:execAddBuff2(unit,self.BURN_BUFF_LIST[1])
                    cond:setValue(buffValue)
                    burn = unit:getTeamUnitCondition():findConditionWithID(self.BURN_BUFF_LIST[1].ID); --燃焼耐性アップ
                    if burn ~= nil then
                        if burn:getValue() ~= buffValue then
                            burn:setValue(buffValue)
                            burn:setNumber(buffValue / 10)
                        end
                    end

                    if burn2 ~= nil then
                        unit:getTeamUnitCondition():removeCondition(burn2)
                    end
                else
                    cond:setValue(buffValue)
                    if burn2 ~= nil then
                        burn2:setValue(buffValue)
                        burn2:setNumber(buffValue / 10 * -1)
                    end
                end

                if cond:getNumber() >= cond:getMaxConditionIconNumber() then
                    cond:setValue(-10 * cond:getMaxConditionIconNumber())
                end
                megast.Battle:getInstance():updateConditionView()
            end

            local buffCount = cond:getNumber()
            if buffCount < 20 then
                self:showMessage(self.BUFF_MESSAGE_LIST)
            end
        end
    end
    --一定時間でクリティカル耐性ダウン
    if self.burnBuffFlg then
        self.bossTimeBuff = self.bossTimeBuff + time
        if self.bossTimeBuff >= self.GD.bossBuffTime then
            self.bossTimeBuff = 0
            self:execAddTimeBuff(unit,self.TIME_BUFF_LIST[1])
        end
    end
end

function class:iceBuffCheck(unit,time)
    local team = megast.Battle:getInstance():getTeam(true)
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            local ice = teamUnit:getTeamUnitCondition():findConditionWithType(96);
            if ice ~= nil then
                self.unitTimeBuffTbl[i] = self.unitTimeBuffTbl[i] + time
                if self.unitTimeBuffTbl[i] >= self.GD.unitBuffTime then
                    self.unitTimeBuffTbl[i] = 0
                    self:execAddTimeBuff2(teamUnit,self.TIME_BUFF_LIST[2])  --最大HPバフ
                    self:execAddTimeBuff2(teamUnit,self.TIME_BUFF_LIST[3])  --攻撃力
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
    if event.spineEvent == "targetLock" then self:targetLock() end
    if event.spineEvent == "fire" then self:fire(event.unit) end
    return 1;
end

function class:targetLock()
    self.isLockOn = true
    self.neckAngle = 295
end

function class:fire(unit)
    local shot = unit:addOrbitSystem("fireball",1)
    shot:setActiveSkill(1);
    shot:setHitCountMax(1);
    shot:setEndAnimationName("explosion")
    -- shot:EnabledFollow = true;

    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = unit:getSkeleton():getBoneWorldPositionX("EF_fire_mouth");
    local yb = unit:getSkeleton():getBoneWorldPositionY("EF_fire_mouth");
    shot:setPosition(x+xb,y+yb);
    -- getDeg(x+xb,y+yb,unit:getTargetUnit():getAnimationPositionX(),unit:getTargetUnit():getAnimationPositionY());
    shot:setRotation(-self.neckAngle);
    self.shotAngle = self.neckAngle;
    shot:setZOrder(unit:getZOrder() -1);
    self.isFireEnd = true
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
        self:MultipleSummon(self.gameUnit,self.summonUnitID,self.GD.attackSummon)  --召喚
        self:showMessage(self.SUMMON_MESSAGE_LIST)
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

    self:MultipleSummon(self.gameUnit,self.summonUnitID,self.GD.skillSummon)  --召喚
    self:showMessage(self.SUMMON_MESSAGE_LIST)
    if event.index == 1 then
        self:addSkill1Buff()
        self:showMessage(self.SKILL_MESSAGE_LIST,1)
    elseif event.index == 2 then
        self:addSkill2Buff()
        self:showMessage(self.SKILL_MESSAGE_LIST,2)
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

function class:addSkill1Buff()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if i == self.targetIndex then
                self:execAddBuff(myTeamUnit,self.ICE_BUFF_LIST[1])
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
                        self:execAddBuff(teamUnit,self.BUFF_LIST[3])
                        self:execAddBuff(teamUnit,self.BUFF_LIST[4])
                    end
                end
            end
        end
    else
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,self.BUFF_LIST[3])
                self:execAddBuff(teamUnit,self.BUFF_LIST[4])
            end
        end
    end

    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            if i ~= self.targetIndex then
                self:execAddBuff(teamUnit,self.ICE_BUFF_LIST[2])
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

    ---ダメージ補正
    local burn = event.unit:getTeamUnitCondition():findConditionWithType(97);
    if burn ~= nil then
        event.value = event.value * self.GD.deBuffDmgVal
    else
        event.value = event.value * self.GD.dmgVal
    end

    ---ターゲット処理
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
    if self.targetUnitList[index] == nil then
        table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value})
    else
        self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value
    end
    ---ホストのみ---
    if megast.Battle:getInstance():isHost() then
        --ヘイトは全部手動で設定する
        local target = self:checkTargetUnit()
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex())---ゲストにターゲットを送る
        event.unit:setHateTarget(target)
        event.unit:updateHateTarget();
        --ターゲットにバフ
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
            if i == target:getIndex() then
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
            else
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
            end
        end
    end
    return 1
end

---最大HPが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil
    local targetHP = -1
    local targetTeam = megast.Battle:getInstance():getTeam(true)
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if targetHP < myTeamUnit:getCalcHPMAX() then
                self.targetIndex = myTeamUnit:getIndex()
                targetHP = myTeamUnit:getCalcHPMAX()
                target = myTeamUnit
            end
        end
    end
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

function class:execAddBuff2(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = math.floor(oldBuff:getValue() / 10)
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

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end
end

function class:execAddTimeBuff(unit,buffBox)
    local flg  = true;
    local buff  = nil;
    local oldBuff = nil
    local buffValue = buffBox.VALUE
    local count = 0
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            buffValue = oldBuff:getValue() + buffBox.VALUE
            count = math.floor(oldBuff:getValue() / 10)
            if count > buffBox.MAX then
                count = buffBox.MAX
            end

            if count <= 0 then
                flg = false
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffValue,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffValue,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffValue,buffBox.DURATION,buffBox.ICON);
    end

    if count == 0 then flg = false end
    if flg then
        if buffBox.MAX ~= nil then
            buff:setMaxConditionIconNumber(buffBox.MAX);
            buff:setNumber(count)
            megast.Battle:getInstance():updateConditionView()
        end
    end
end

function class:execAddTimeBuff2(unit,buffBox)
    local flg  = true;
    local buff  = nil;
    local oldBuff = nil
    local buffValue = buffBox.VALUE
    local count = 0
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            buffValue = oldBuff:getValue() + buffBox.VALUE
            count = math.floor(oldBuff:getValue() / 10 * -1)
            if count > buffBox.MAX then
                count = buffBox.MAX
            end

            if count <= 0 then
                flg = false
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffValue,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffValue,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffValue,buffBox.DURATION,buffBox.ICON);
    end

    if count == 0 then flg = false end
    if flg then
        if buffBox.MAX ~= nil then
            buff:setMaxConditionIconNumber(buffBox.MAX);
            buff:setNumber(count)
            megast.Battle:getInstance():updateConditionView()
        end
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