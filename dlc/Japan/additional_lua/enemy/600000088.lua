--@additionalEnemy,2047501,2047503
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_緑命竜エルプネウマス", version=1.3, id=600000088});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK2 = 50, ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK3 = 50 },
        { ATTACK4 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
        { SKILL2 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL1 = 6,
    SKILL2 = 7
}

class.cutInSkill = {
    --[3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        [1] = {
            ID = 6008903,
            BUFF_ID = 89, -- 気絶
            VALUE = 100,
            DURATION = 10,
            ICON = 79
        },
        [2] = {
            ID = 6008906,
            BUFF_ID = 21, --被ダメUP
            VALUE = 20,
            DURATION = 10,
            ICON = 139
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "HPが高いユニットの与ダメージアップ", COLOR = Color.yellow})
    }
    self.START_SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_SUMMON_MESSAGE1 or "ライトコロック：魔法耐性", COLOR = Color.yellow})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "猛毒の霧が立ち込める", COLOR = Color.yellow})
    }
    self.SKILL6_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL6_MESSAGE1 or "毒竜のダメージアップ", COLOR = Color.yellow})
    }
    self.SKILL7_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL7_MESSAGE1 or "ガイアグリーフ：ダメージ無効化無効", COLOR = Color.yellow})
    }
    self.SUMMON1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON1_MESSAGE1 or "ライトコロックが加勢した", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON1_MESSAGE2 or "ライトコロック：魔法耐性", COLOR = Color.yellow})
    }
    self.SUMMON2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON2_MESSAGE1 or "ダークコロックが加勢した", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON2_MESSAGE2 or "ダークコロック：物理耐性", COLOR = Color.magenta})
    }
    self.EXTRA_GAUGE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EXTRA_GAUGE_MESSAGE1 or "必要ダメージ蓄積量増加", COLOR = Color.red})
    }
    self.GAUGE_REPAIR_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GAUGE_REPAIR_MESSAGE1 or "クリティカル耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.GAUGE_REPAIR_MESSAGE2 or "防御力アップ", COLOR = Color.yellow})
    }
    self.GAUGE_BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GAUGE_BREAK_MESSAGE1 or "毒竜がひるんでいる！", COLOR = Color.red}),
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
    self.spValue = 20;---addSPの量
    event.unit:setAttackDelay(8);---アタックディレイ
    event.unit:addSP(60)---戦闘開始時の奥義ゲージ量
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

    self.isLockOn = false
    self.isFireEnd = false
    self.shotAngle = 0
    self.neckAngle = 0
    self.neckAngleDefault = 321

    ---サブHP表示用
    self.SubHpRate = 0.08---サブバーのHP(最大体力の8%)
    self.subBar = BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = event.unit:getCalcHPMAX() * self.SubHpRate
    self.damage = 0---サブバー表示時のダメージ
    self.subHPRepair = false

    self.reStartCount = 0
    self.gaugeGimmickFlg = true
    self.attack5Flg = false
    self.lightFriendCount = 0
    self.darkFriendCount = 0
    self.stanDamageRate = 1.2

    return 1
end

-------------------------------------------------------------------------------
-- startWave
-------------------------------------------------------------------------------
function class:startWave(event)
    self:MultipleSummon(self.gameUnit,2047501,2)   --ライトコロック召喚
    self:showMessage(self.START_SUMMON_MESSAGE_LIST)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効

    --気絶復帰後、スキルを打つ
    if self.attack5Flg then
        local buff = event.unit:getTeamUnitCondition():findConditionWithID(6008903)
        if buff == nil then
            self:takeAttack(event)
            self:showMessage(self.SKILL_MESSAGE_LIST)
        end
    end

    self:subBarControll(event.unit,self.damage);---サブバー表示
    return 1
end

---サブHP表示
function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を全回復
    if self.subHPRepair then
        self.subHPRepair = false
        self.attack5Flg = false
        self.gaugeGimmickFlg = true
        self.damage = 0
        self.reStartCount = self.reStartCount + 1
        self:setBuffList(unit)
        if self.SubHpRate < 0.13 then
            self.SubHpRate = self.SubHpRate + 0.01
            self.SUB_HP = unit:getCalcHPMAX() * self.SubHpRate
        end
    end
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - self.damage)/self.SUB_HP);
    ---ゲージ0%になった場合の処理
    if self.SUB_HP - self.damage <= 0 then
        if self.gaugeGimmickFlg then
            self.gaugeGimmickFlg = false
            self.attack5Flg = true
            unit:setBurstPoint(0)
            self:execAddBuff(self.gameUnit,self.BUFF_LIST[1])
            self:execAddBuff(self.gameUnit,self.BUFF_LIST[2])
            self:showMessage(self.GAUGE_BREAK_MESSAGE_LIST)
        end
    end
end

function class:setBuffList(unit)
    local BUFF_LIST1 = {
        ID = 6008904,
        BUFF_ID = 23,   --クリティカル耐性
        VALUE = -300,
        DURATION = 999999,
        ICON = 188
    }

    local buff = unit:getTeamUnitCondition():findConditionWithID(6008905)
    local buffCount = 1
    if buff ~= nil then
        buffCount = buff:getNumber() + 1
    end
    if buffCount >= 11 then buffCount = 10 end
    local valueCalc = 20 * buffCount
    local BUFF_LIST2 = {
        ID = 6008905,
        BUFF_ID = 15,  --防御力UP
        VALUE = valueCalc,
        DURATION = 999999,
        ICON = 5,
        COUNT = buffCount,
        MAX = 11
    }

    if self.reStartCount == 1 then
        self:execAddBuff(unit,BUFF_LIST1)
        self:showMessage(self.GAUGE_REPAIR_MESSAGE_LIST,1)
    else
        self:buffRefresh(unit,BUFF_LIST2.ID)
        self:execAddBuff(self.gameUnit,BUFF_LIST2)
        self:showMessage(self.GAUGE_REPAIR_MESSAGE_LIST,2)
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "targetLock" then self:targetLock() end
    if event.spineEvent == "fire" then self:fire(event.unit) end
    --if event.spineEvent == "setFire" then self:setFire(event.unit) end
    --if event.spineEvent == "startFire" then self:startFire(event.unit) end
    return 1;
end

function class:targetLock()
    self.isLockOn = true
    self.neckAngle = 321
end

function class:fire(unit)
    local shot = unit:addOrbitSystem("fireball",1)
    shot:setActiveSkill(1);
    shot:setHitCountMax(1);
    shot:setEndAnimationName("explosion")

    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = unit:getSkeleton():getBoneWorldPositionX("EF_fire_mouth");
    local yb = unit:getSkeleton():getBoneWorldPositionY("EF_fire_mouth");
    shot:setPosition(x+xb,y+yb);
    shot:setRotation(-self.neckAngle);
    self.shotAngle = self.neckAngle;
    shot:setZOrder(unit:getZOrder() -1);
    self.isFireEnd = true;
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
        local friendCount = self:findFriendCount()
        self:friendObservation(friendCount)
    elseif event.index == 5 then
        self.subHPRepair = true
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
    if self.attack5Flg then
        self.attack5Flg = false
        attackIndex = 5
    end

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

function class:findFriendCount()
    self.lightFriendCount = 0
    self.darkFriendCount = 0
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getUnitID() == 105071493 then   --ライトコロック
                self.lightFriendCount = self.lightFriendCount + 1
            elseif myTeamUnit:getUnitID() == 105321593 then   --ダークコロック
                self.darkFriendCount = self.darkFriendCount + 1
            end
        end
    end
    return self.lightFriendCount + self.darkFriendCount
end

function class:friendObservation(friendCount)   --雑魚の監視召喚
    --数判定
    local rand = math.random(0,9)
    if friendCount == 6 then
        --何もしない
    elseif friendCount == 0 then   --合計0体の場合は50%の確率で1体を召喚、50%の確率で2体を召喚。
        if rand <= 4 then
            self:enemySummon(1)
        else
            self:enemySummon(2)
        end
    elseif friendCount == 1 then   --合計1体の場合は70%の確率で1体を召喚、30%の確率で2体を召喚。
        if rand <= 6 then
            self:enemySummon(1)
        else
            self:enemySummon(2)
        end
    elseif friendCount == 2 then   --合計2体の場合は90%の確率で1体を召喚、10%の確率で2体を召喚。
        if rand <= 8 then
            self:enemySummon(1)
        else
            self:enemySummon(2)
        end
    elseif friendCount >= 3 then   --合計3体以上の場合は、100%の確率で1体を召喚。
        self:enemySummon(1)
    end
end

---召喚系
function class:enemySummon(Num)   --召喚回数
    --種類判定
    local kindRand = 0
    if self.lightFriendCount == self.darkFriendCount then
        kindRand = math.random(0,4)  --ライトコロックの確率50%
    elseif self.lightFriendCount > self.darkFriendCount then
        kindRand = math.random(0,2)  --ライトコロックの確率30%
    elseif self.lightFriendCount < self.darkFriendCount then
        kindRand = math.random(0,6)  --ライトコロックの確率70%
    end

    local rand = math.random(0,9)
    if rand <= kindRand then
        self:MultipleSummon(self.gameUnit,2047501,Num)   --ライトコロック召喚
        self:showMessage(self.SUMMON1_MESSAGE_LIST)
    else
        self:MultipleSummon(self.gameUnit,2047503,Num)   --ダークコロック召喚
        self:showMessage(self.SUMMON2_MESSAGE_LIST)
    end
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

    self:addDamageBuff(event.unit)
    local friendCount = self:findFriendCount()
    self:skillFriendObservation(friendCount)

    if event.index == 1 then
        self:showMessage(self.SKILL6_MESSAGE_LIST)
    elseif event.index == 2 then
        self:showMessage(self.SKILL_MESSAGE_LIST)
        self:showMessage(self.SKILL7_MESSAGE_LIST)
        self:showMessage(self.SKILL6_MESSAGE_LIST)
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
function class:addDamageBuff(unit)
    local buff = unit:getTeamUnitCondition():findConditionWithID(6008901)
    local buffCount = 1
    if buff ~= nil then
        buffCount = buff:getNumber() + 1
    end
    if buffCount >= 11 then buffCount = 10 end
    local valueCalc = 15 * buffCount
    local BUFF_LIST = {
        ID = 6008901,
        BUFF_ID = 17,---与ダメUP
        VALUE = valueCalc,
        DURATION = 999999,
        ICON = 26,
        COUNT = buffCount,
        MAX = 11
    }
    self:buffRefresh(unit,BUFF_LIST.ID)
    self:execAddBuff(unit,BUFF_LIST)
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

function class:skillFriendObservation(friendCount)   --雑魚の監視召喚
    --数判定
    local rand = math.random(0,9)
    if friendCount == 6 then
        --何もしない
    elseif friendCount == 5 then   --合計5体の場合は50%の確率で1体を召喚。
        if rand <= 4 then
            self:MultipleSummon(self.gameUnit,2047501,1)   --ライトコロック召喚
            self:showMessage(self.SUMMON1_MESSAGE_LIST)
        else
            self:MultipleSummon(self.gameUnit,2047503,1)   --ダークコロック召喚
            self:showMessage(self.SUMMON2_MESSAGE_LIST)
        end
    else
        self:MultipleSummon(self.gameUnit,2047501,1)   --ライトコロック召喚
        self:MultipleSummon(self.gameUnit,2047503,1)   --ダークコロック召喚
        self:showMessage(self.SUMMON1_MESSAGE_LIST)
        self:showMessage(self.SUMMON2_MESSAGE_LIST)
    end
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---ダメージ計算
    local unitHP = event.enemy:getHP() / event.enemy:getCalcHPMAX() * 100
    local fix = 0
    if 50 < unitHP then
        fix = 1 - 0.14 * (100 -unitHP) / 10
    else
        fix = 0.3 - 0.04 * (50 - unitHP) / 10
    end
    --summoner.Utility.messageByEnemy(fix);
    event.value = event.value * fix

    self.damage = self.damage + event.value
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
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:friendDead()
    return 1
end

function class:friendDead()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getUnitID() == 105071493 then   --ライトコロック
                myTeamUnit:setHP(0)
            elseif myTeamUnit:getUnitID() == 105321593 then   --ダークコロック
                myTeamUnit:setHP(0)
            end
        end
    end
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