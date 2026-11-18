--@additionalEnemy,1041
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="鉱山_ツァイバーZ・絶(蒼機士)", version=2.0, id="mine_6021"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK3 = 50 },
        { ATTACK1 = 50 },
        { ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL3 = 50 },
        { SKILL2 = 50 },
        { SKILL3 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL1 = 4,
    SKILL2 = 5,
    SKILL3 = 6
}

class.cutInSkill = {
    --[3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 5002201,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 1,
            ICON = 0,
            COUNT = 0,
            MAX = 10
        },
        [2] = {
            ID = 5002202,
            BUFF_ID = 17, --与ダメUP
            VALUE = 40,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 10
        },
        [3] = {
            ID = 5002203,
            BUFF_ID = 54,  --麻痺耐性ダウン
            VALUE = (40 + self.floor * 0.2) * -1,
            DURATION = 9999999,
            ICON = 70,
            COUNT = 0,
            MAX = 10
        },
        [4] = {
            ID = 5002204,
            BUFF_ID = 103,  --麻痺回避率
            VALUE = (40 + self.floor * 0.2) * -1,
            DURATION = 9999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10
        }
    }
    ---蒼機士ギミック
    self.STUN_BUFF_LIST = {
        ID = 50022100,
        BUFF_ID = 89,
        VALUE = 100,
        DURATION = 99999,
        ICON = 79
    }
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 5002210,
            BUFF_ID = 31,---回避率UP
            VALUE = 50 + self.floor * 0.5,
            DURATION = 99999,
            ICON = 16
        },
        [2] = {
            ID = 5002211,
            BUFF_ID = 7,---自然回復
            VALUE = self.bossHpHealValue,
            DURATION = 99999,
            ICON = 35
        },
        [3] = {
            ID = 5002212,
            BUFF_ID = 89, --気絶
            VALUE = 100,
            DURATION = 3,
            ICON = 79
        },
        [4] = {
            ID = 5002213,
            BUFF_ID = 17,  --クリティカルダメージ
            VALUE = 100,
            DURATION = 99999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 22
            }
        }
    }
    ---鉱山ギミック
    self.TIMEUP_BUFF_BOX_LIST = {
        [1] = {
            ID = 50022201,
            BUFF_ID = 17,      --ダメージ
            VALUE = 500,       --効果量
            DURATION = 9999999,
            ICON = 26
        },
        [2] = {
            ID = 50022202,
            BUFF_ID = 13,      --攻撃力
            VALUE = 500,       --効果量
            DURATION = 9999999,
            ICON = 3
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
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカル耐性", COLOR = Color.yellow})
    }
    self.SKILL1_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE1 or "与ダメージアップ", COLOR = Color.yellow})
    }
    self.PILE_SET_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.PILE_SET_MESSAGE1 or "%sをロック：グラーシーザを破壊して解除", COLOR = Color.red}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.PILE_SET_MESSAGE2 or "グラーシーザ：麻痺状態のとき被ダメージアップ", COLOR = Color.red}),
        [3] = self:setMessageInfo({MESSAGE = self.TEXT.PILE_SET_MESSAGE3 or "ボスの回避率増加・被ダメージ軽減・HP自然回復", COLOR = Color.yellow}),
        [4] = self:setMessageInfo({MESSAGE = self.TEXT.PILE_SET_MESSAGE4 or "クリティカルダメージアップ", COLOR = Color.yellow})
    }
    self.PILE_DESTROY_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.PILE_DESTROY_MESSAGE1 or "グラーシーザ破壊成功！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.PILE_DESTROY_MESSAGE2 or "奥義発動までボスの奥義上昇量ダウン", COLOR = Color.red})
    }
    ---鉱山ギミック
    self.TIMEUP_BUFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE1 or "攻撃力アップ",COLOR=Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE2 or "ダメージアップ",COLOR=Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TIME_UP_ID = 2
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        },
        [self.TIME_UP_ID] = {
            tag = "TIME_UP",
            action = function (status) self:timeUp(status) end,
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
        self.cutInFLG = true
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.hpSkill = 2
        self.gameUnit:setInvincibleTime(15)
    end
end

function class:timeUp(status)
    if status == "use3" then
        self:showMessage(self.TIMEUP_BUFF_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[1])
        self:execAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[2])
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
    event.unit:setAttackDelay(8);---アタックディレイ
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

    ---鉱山ギミック
    self.floor = megast.Battle:getInstance():getCurrentMineFloor();
    ---ボスギミック
    self.skill1FLG = true
    self.chosenUnit = nil
    self.healRate = 0.001
    self.bossHpHealValue = event.unit:getHP() * self.healRate

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
    self.buffDamageValRate = 0.1
    self.raceDamageValRate = 0.1

    ---蒼機士ギミック
    self.pileFLG = false
    self.pileEnemyID = 1041
    self.pileDamageRate = 0.1
    self.count = 0
    self.posX = 0
    self.posY = 0
    --event.unit:setIsPlayFocus(false)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効

    ---蒼機士ギミック
    local pile = self:findUnit(event.unit,501871250)
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID)
    if pile ~= nil then
        if cond == nil then
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[4])
        end
        pile:setPosition(self.posX,self.posY)
        self.pileFLG = false
    else
        if cond ~= nil then
            event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID)
            event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[2].ID)
            event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[4].ID)
            self:removeStun(event.unit)
            self:execAddBuff(event.unit,self.BUFF_BOX_LIST[3])
            event.unit:setBurstPoint(0)
            self.spValue = 20
            self:showMessage(self.PILE_DESTROY_MESSAGE_LIST)
        end
        --パイルが無いかつ奥義発動後
        if self.pileFLG then
            self.pileFLG = false
            self.hpSkill = 1
            event.unit:addSP(100)
        end
    end

    ---鉱山ギミック
    self:setTimeUp()
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

---180秒経ったらタイムアップ
function class:setTimeUp()
    if BattleControl:get():getTime() > 300 and not self.TRIGGERS[self.TIME_UP_ID].used then
        self:execTrigger(self.TIME_UP_ID)
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    ---蒼機士ギミック
    if event.spineEvent == "pileSet" then
        self:stun(event.unit)
        local pile = self:summon(event.unit,self.pileEnemyID)
        self.posX = event.unit:getPositionX() + 180
        self.posY = event.unit:getPositionY()
        pile:setDefaultPosition(self.posX,self.posY)
        self.count = self.count + 1
        local hp = event.unit:getCalcHPMAX() * (0.2 + (self.count * 0.4))
        pile:setBaseHP(hp)
        pile:setHP(hp)
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

    if event.index == 2 and self.cutInFLG then
        self.cutInFLG = false
        event.unit:takeSkillWithCutin(event.index,1);
        return 0
    end

    self.spValue = 30
    if event.index == 1 then
        event.unit:setInvincibleTime(15)
        self:removeBadCondition(event.unit)
        self.skill1FLG = true
        self.chosenUnit = self:randomPick()
        self:showFormatMessage(self.PILE_SET_MESSAGE_LIST[1],self.chosenUnit:getUnitName())
        self:execShowMessage(self.PILE_SET_MESSAGE_LIST[2])
        self:execShowMessage(self.PILE_SET_MESSAGE_LIST[3])
        self:execShowMessage(self.PILE_SET_MESSAGE_LIST[4])
    elseif event.index == 2 or event.index == 3 then
        self.pileFLG = true
        if event.index == 2 then
            self:execAddBuff(event.unit,self.BUFF_LIST[event.index])
            self:showMessage(self.SKILL1_MESSAGE_LIST)
        elseif event.index == 3 then
            self:takeSkillDeBuff()
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

---状態異常回復メソッド
function class:removeBadCondition(unit)
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            for typeId = 89,94,97 do
                if cond:getConditionTypeAsInt() == typeId then
                    cond:setTime(0) --バフ除去
                end
            end
        end
    end
end
---ユニット気絶,初期位置移動
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

---ユニットの中から一体選択
function class:randomPick()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local teamTable = {}
    local count = 0
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            count = count + 1
            teamTable[count] = myTeamUnit
        end
    end
    local result = math.random(1,count)
    return teamTable[result]
end

---一体のみ永続気絶
function class:stun2(unit)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit == self.chosenUnit then
            else
                myTeamUnit:getTeamUnitCondition():addCondition(self.STUN_BUFF_LIST.ID,0,0,0,0);
            end
        end
    end
    ---属性情報を設置兵器に与える
    --local pile = self:findUnit(unit,501871250)
    --if pile ~= nil then
    --    pile:getTeamUnitCondition():addCondition(502250,0,self.chosenElement,99999,0);
    --end
    return 1
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
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getIndex() == target then
                    for l = 1,loopNum do
                        self:execAddBuff(teamUnit,self.BUFF_LIST[3])
                        self:execAddBuff(teamUnit,self.BUFF_LIST[4])
                    end
                end
            end
        end
    else
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,self.BUFF_LIST[3])
                self:execAddBuff(teamUnit,self.BUFF_LIST[4])
            end
        end
    end
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
    ---ダメージ軽減ギミック
    --self:damageValueCalc(event,0,0)  --event,buffID,raceType
    ---蒼機士ギミック
    local pile = self:findUnit(event.unit,501871250)
    if pile ~= nil then
        event.value = event.value * self.pileDamageRate
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

function class:damageValueCalc(event,buffID,raceType)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
    --攻撃ユニットがデバフ状態だった場合ダメージ補正
    if buffID ~= 0 then
        local buffCheck = enemyUnit:getTeamUnitCondition():findConditionValue(buffID)
        if buffCheck ~= 0 then
            event.value = event.value * self.buffDamageValRate
        end
    end

    --○族以外はダメージ補正
    if raceType ~= 0 then
        if enemyUnit:getRaceType() ~= raceType then
            event.value = event.value * self.raceDamageValRate
        end
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

---蒼機士ギミック
function class:summon(unit,unitID)
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

class:publish();

return class;