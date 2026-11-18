local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="夢幻級_ギリアム", version=1.3, id=200080904});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50,ATTACK2 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

class.cutInSkill = {
    [2] = 0,
    [3] = 1
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 2089401,
            BUFF_ID = 89, --気絶
            VALUE = 100,
            DURATION = 20,
            ICON = 79
        },
        [2] = {
            ID = 2089402,
            BUFF_ID = 17, --与ダメUP
            VALUE = 30,
            DURATION = 999999,
            ICON = 26,
            COUNT = 1,
            MAX = 20
        },
        [3] = {
            ID = 2089403,
            BUFF_ID = 30, --装備CT速度
            VALUE = -90,
            DURATION = 999999,
            ICON = 183
        },
        [4] = {
            ID = 2089404,
            BUFF_ID = 21, --物理耐性
            VALUE = -70,
            DURATION = 999999,
            ICON = 21,
            SCRIPT = {
                SCRIPT_ID = 2
            }
        },
        [5] = {
            ID = 2089405,
            BUFF_ID = 23, --クリティカル耐性
            VALUE = -150,
            DURATION = 999999,
            ICON = 188
        },
        [6] = {
            ID = 2089406,
            BUFF_ID = 21, --物理耐性
            VALUE = -50,
            DURATION = 999999,
            ICON = 21,
            SCRIPT = {
                SCRIPT_ID = 2
            }
        },
        [7] = {
            ID = 2089407,
            BUFF_ID = 0, --オーラ用
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        }
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 2089410,
        BUFF_ID = 23,---被クリティカル率
        VALUE = 100,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 2089410,
        BUFF_ID = 0,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "ダメージ無効化無効", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "燃焼・病気状態のとき、被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ダメージの大きい者をターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ターゲットへのクリティカル率アップ", COLOR = Color.yellow})
    }
    self.SKILL1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE1 or "ターゲットを気絶", COLOR = Color.red})
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "ターゲットの装備CT速度低下", COLOR = Color.red})
    }
    self.HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE1 or "どうした？ビビってんのか！？", COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE2 or "物理耐性アップ", COLOR = Color.yellow})
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "ドンとぶつかってこい！", COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE2 or "クリティカル耐性アップ", COLOR = Color.yellow})
    }
    self.HP40_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP40_MESSAGE1 or "もっと全力で打ち込んでこい！", COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP40_MESSAGE2 or "物理耐性アップ", COLOR = Color.yellow})
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "今度は俺からいくぜ！", COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE2 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "いい仕事だったぜ", COLOR = Color.green})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp80(status) end,
            HP = 80,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp60(status) end,
            HP = 60,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false
        },
        [4] = {
            tag = "HP_FLG",
            action = function (status) self:hp20(status) end,
            HP = 20,
            used = false
        }
    }
    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

function class:hp80(status)
    if status == "use3" then
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:showMessage(self.HP80_MESSAGE_LIST)
        self.hpSkill = 3
        self:removeBadCondition(self.gameUnit)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
    end
end

function class:hp60(status)
    if status == "use3" then
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:showMessage(self.HP60_MESSAGE_LIST)
        self.hpSkill = 3
        self:removeBadCondition(self.gameUnit)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[5])
        self.hp60Flg = true
    end
end

function class:hp40(status)
    if status == "use3" then
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:showMessage(self.HP40_MESSAGE_LIST)
        self.hpSkill = 3
        self:removeBadCondition(self.gameUnit)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[6])
    end
end

function class:hp20(status)
    if status == "use3" then
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:showMessage(self.HP20_MESSAGE_LIST)
        self.hpSkill = 3
        self:removeBadCondition(self.gameUnit)
        self.spValue = 10;---addSPの量
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[7])
    end
end

--状態異常回復
function class:removeBadCondition(unit)
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            for k,typeId in pairs(self:getBadStatusList()) do
                if cond:getConditionTypeAsInt() == typeId then
                    cond:setTime(0) --バフ除去
                end
            end
        end
    end
end

function class:getBadStatusList()
    local badStatusList = {
        89, 90, 91, 92, 93, 94, 95, 96, 97, 129, 131, 135,
        201, 202, 203, 204, 205, 206, 207, 208, 233, 234
    }
    return badStatusList
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 5;---addSPの量
    event.unit:setAttackDelay(2);---アタックディレイ
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

    self.hateFlg = true
    self.hpSkillFlg = false
    self.hp60Flg = false
    self.damageRate = 0.1
    self.burningDamageRate = 0.4
    self.diseaseDamageRate = 0.8
    self.deBuffDamageRate = 1.2
    self.skillDamageRate = 0.01
    self.unitPositionXList = {}
    self.unitPositionYList = {}

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
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i,true)
        if myTeamUnit ~= nil then
            self.unitPositionXList[i] = myTeamUnit:getPositionX()
            self.unitPositionYList[i] = myTeamUnit:getPositionY()
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1,true)---ヒットストップ無効or時止め無効
    self:HPTriggersCheck(event.unit)

    --奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill and self.hpSkillFlg then
        self.hpSkillFlg = false
    end
    return 1
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

    if event.index == 2 then
        if megast.Battle:getInstance():isHost() then
            self:targetUnitStan(self.BUFF_BOX_LIST[1])
        end

        self:showMessage(self.SKILL1_MESSAGE_LIST)
        if self.hp60Flg then
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
        end
    elseif event.index == 3 then
        self.hpSkillFlg = true
        self:addTargetBuff(self.BUFF_BOX_LIST[3])
        self:showMessage(self.SKILL2_MESSAGE_LIST)
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

    if skillIndex then
        self.cutInFLG = true
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

function class:targetUnitStan(buffBox)
    self.gameUnit:updateHateTarget();
    local targetUnit = self.gameUnit:getHateTarget();
    local targetIndex = nil
    local flg = true
    if targetUnit == nil then
        flg = false
    else
        targetIndex = targetUnit:getIndex()
    end

    local myTeam = megast.Battle:getInstance():getTeam(true);
    if flg then
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if i == targetIndex then
                    myTeamUnit:setPosition(self.unitPositionXList[targetIndex],self.unitPositionYList[targetIndex])
                    self:execAddBuff(myTeamUnit,buffBox)
                    local enemyUnit = self:getAncestorUnit(myTeamUnit)
                    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
                    self.targetUnitList[index].dps = 0
                    if megast.Battle:getInstance():isHost() then
                        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,targetIndex)---ゲストにターゲットを送る
                    end
                end
            end
        end

        local hateCheckFlg = self:unitHateDamageCheck()
        if not hateCheckFlg then
            ---ヘイトは全部手動で設定する
            local target = self:checkTargetUnit()
            self.gameUnit:setHateTarget(target)
            self.gameUnit:updateHateTarget();
            if megast.Battle:getInstance():isHost() then
                megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex())---ゲストにターゲットを送る
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
        else
            self.hateFlg = false
            self.gameUnit:setHateTarget(nil)
            BattleControl:get():visibleHateTarget(false);
            BattleControl:get():setHateTargetIcon(0);
            self.gameUnit:setEnableHate(false);
            self.gameUnit:updateHateTarget();
            for i = 0,3 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
                end
            end
        end
    else
        --ターゲットが居ない場合
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                myTeamUnit:setPosition(self.unitPositionXList[myTeamUnit:getIndex()],self.unitPositionYList[myTeamUnit:getIndex()])
                self:execAddBuff(myTeamUnit,buffBox)
                return
            end
        end
    end
end

function class:addTargetBuff(baffBox)
    self.gameUnit:updateHateTarget();
    local targetUnit = self.gameUnit:getHateTarget();
    local targetIndex = nil
    local flg = true
    if targetUnit == nil then
        flg = false
    else
        targetIndex = targetUnit:getIndex()
    end

    local myTeam = megast.Battle:getInstance():getTeam(true);
    if flg then
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if i == targetIndex then
                    self:execAddBuff(myTeamUnit,baffBox)
                end
            end
        end
    else
        --ターゲットが居ない場合
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                self:execAddBuff(myTeamUnit,baffBox)
                return
            end
        end
    end
end

function class:unitHateDamageCheck()
    local count = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local enemyUnit = self:getAncestorUnit(myTeamUnit)
            local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
            if self.targetUnitList[index] == nil then
                count = count + 1
            elseif self.targetUnitList[index].dps == 0 then
                count = count + 1
            end
        end
    end

    if count == 4 then
        return true
    else
        return false
    end
end

function class:receive7(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if i == args.arg then
                myTeamUnit:setPosition(self.unitPositionXList[args.arg],self.unitPositionYList[args.arg])
                self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[1])
                local enemyUnit = self:getAncestorUnit(myTeamUnit)
                local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
                self.targetUnitList[index].dps = 0
            end
        end
    end
    return 1
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if not self.hateFlg then
        self.hateFlg = true
        ---自動ヘイトは使わない
        BattleControl:get():visibleHateTarget(true);
        BattleControl:get():setHateTargetIcon(14);
        event.unit:setEnableHate(true);
        event.unit:updateHateTarget();
    end

    ---ダメージ軽減ギミック
    local burning = event.unit:getTeamUnitCondition():findConditionWithType(97)  --燃焼
    local disease = event.unit:getTeamUnitCondition():findConditionWithType(94)  --病気
    if self.hpSkillFlg then
        event.value = event.value * self.skillDamageRate
    elseif burning ~= nil and disease ~= nil then
        event.value = event.value * self.deBuffDamageRate
    elseif burning ~= nil then
        event.value = event.value * self.burningDamageRate
    elseif disease ~= nil then
        event.value = event.value * self.diseaseDamageRate
    else
        event.value = event.value * self.damageRate
    end

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
    self.TRIGGERS[index].action(action)
    self.TRIGGERS[index].used = true
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
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
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