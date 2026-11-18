local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="エリアボス_冥蟲姫ラドアクネ・邪", version=2.0, id="gb_302601"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK3 = 50, ATTACK4 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK3 = 50, ATTACK4 = 50 },
        { ATTACK5 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50, ATTACK4 = 50 },
        { ATTACK6 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 }
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
    [1] = 1,
    [2] = 1,
    [3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 30260101,
            BUFF_ID = 17,  --与ダメ
            VALUE = self.GD.buffValue_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 30260102,
            BUFF_ID = 89,  --気絶
            VALUE = 100,
            DURATION = self.GD.buffTime_89_1,
            ICON = 79
        },
        [3] = {
            ID = 30260103,
            BUFF_ID = 89,  --気絶
            VALUE = 100,
            DURATION = self.GD.buffTime_89_2,
            ICON = 79
        }
    }
    self.ABILITY_BUFF_LIST = {
        [1] = {
            ID = 30260100,
            BUFF_ID = 13,
            VALUE = (self.GD.abilityBuffValue_13_1 + self.gbAreaNumber * self.GD.abilityBuffValue_13_2) * -1,
            DURATION = 999999,
            ICON = 0
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "威嚇：プレイヤーユニットの攻撃力ダウン", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "与ダメージの大きい者へのダメージアップ", COLOR = Color.yellow})
    }
    self.BARRIER_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BARRIER_MESSAGE1 or "バリア展開：被ダメージ軽減", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.BARRIER_MESSAGE2 or "与ダメージが大きい者を気絶＆奥義低下", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.BARRIER_MESSAGE3 or "魔法被ダメージ大幅軽減", COLOR = Color.red})
    }
    self.BARRIER_BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BARRIER_BREAK_MESSAGE1 or "バリア破壊成功！", COLOR = Color.red})
    }
    self.START_BUFF_MESSAGE_LIST = {
        [90] = self:setMessageInfo({MESSAGE = self.TEXT.START_BUFF_MESSAGE1 or "沼地の毒が侵食する", COLOR = Color.magenta, isPlayer = true})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
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

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.gameUnit:addSP(100)
        self.hpSkill = 3
        self.gameUnit:setInvincibleTime(30)
        self:deBuffRefresh(self.gameUnit)
    end
end

--状態異常除去
function class:deBuffRefresh(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97};
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

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 30,
        attackDelay = 8,
        hitStop = 100,
        startAddSP = 1,
        timeLimit = 180,
        abilityBuffValue_13_1 = 8,
        abilityBuffValue_13_2 = 0.5,
        extraGaugeHpRate = 0.25,
        extraGaugeAddSP = 40,
        extraGaugeDamageRate = 0.2,
        extraGaugeMagicDamageRate = 0.01,
        buffValue_17 = 25,
        buffTime_89_1 = 5,
        buffTime_89_2 = 2,
        hateGimmickRate = 1.5,
        hateGimmickBase = 50,
        startBuffType = 0,
        startBuffValue = 0,
        startBuffScriptID = 0,
        startBuffValue1 = 0,
        startBuffValue2 = 0,
        startBuffIcon = 0,
        startBuffTime = 99999,
        startBuffTimer = 20
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;

    self.gbAreaNumber = megast.Battle:getInstance():getCurrentGrandBattleFloor();
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    event.unit:addSP(self.gbAreaNumber * self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
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
    self.timer = self.GD.startBuffTimer

    self.stateName = "NORMAL"
    self.breakSkip = true
    self.hpSkill = 0
    self.saveBP = 0

    ---バトルタイム
    self.TIME_LIMIT = self.GD.timeLimit
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.TIME_LIMIT ,30, 620 , -100 ,0.8);

    ---ヘイトギミック
    self.hateGimmickRate = self.GD.hateGimmickRate
    self.hateGimmickBase = self.GD.hateGimmickBase
    event.unit:setEnableGBHate(true);

    ---サブHP表示用
    self.subBarFlg = false
    self.damage = 0---サブバー表示時のダメージ
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = event.unit:getHP() * self.GD.extraGaugeHpRate ---サブバーのHP(最大体力の10%)

    ---ボスギミック
    self.barrier = nil;
    self.skill1Flg = false
    self.subBarInfoFlg = false
    self.extraGaugeDamageRate = self.GD.extraGaugeDamageRate
    self.extraGaugeMagicDamageRate = self.GD.extraGaugeMagicDamageRate
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:hpTriggersCheck(event.unit)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    ---アビリティ
    --self:addAbilityBuff(self.ABILITY_BUFF_LIST[1])
    ---バトルタイム
    self:countDown()

    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill and self.skill1Flg then
        self.skill1Flg = false
        event.unit:takeAnimation(0,"attack8",false);
        event.unit:takeAnimationEffect(0,"1_attack8",false);
        self:skill1HateEffect(event.unit,self.BUFF_LIST[3])
    end

    ---エクストラゲージ関係
    if self.subBarInfoFlg then
        self.subBarInfoFlg = false
        self.damage = 0
        self.spValue = self.GD.extraGaugeAddSP;---addSPの量
        self:showMessage(self.BARRIER_MESSAGE_LIST)
    end

    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);---サブバー表示
    end

    ---沼地用ギミック
    self.timer = self.timer + event.deltaTime
    if self.timer >= self.GD.startBuffTimer then
        self.timer = self.timer - self.GD.startBuffTimer
        --self:timerBuff()
    end

    ---死亡時処理
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.lastSkillFLG == nil then self.lastSkillFLG = false end
        if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
            event.unit:getTeam():deadUnit(event.unit:getIndex());
            megast.Battle:getInstance():waveEnd(true);
        end
        if self.TRIGGERS[1].used then
            self.gameUnit:setInvincibleTime(1)
            if self.deadCount == nil then self.deadCount = 0 end
            self.deadCount = self.deadCount + event.deltaTime
            if self.deadCount >= 30 then
                event.unit:getTeam():deadUnit(event.unit:getIndex());
                megast.Battle:getInstance():waveEnd(true);
            end
        end
    end
    return 1
end

function class:addAbilityBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
            if buff == nil then
                self:execAddBuff(myTeamUnit,buffBox)
            end
        end
    end
end

function class:countDown()
    if BattleControl:get():getTime() > self.TIME_LIMIT then
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                myTeamUnit:setHP(0)
                myTeam:deadUnit(myTeamUnit:getIndex());
            end
        end
    end
end

---サブHP表示
function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage)/self.SUB_HP);
    ---ゲージ0%になった場合の処理
    if self.SUB_HP - damage <= 0 then
        --ゲージ非表示
        self.subBarFlg = false
        self.damage = 0
        self.subBar:setVisible(false);
        --バリアブレイクアニメーション
        self.barrier:takeAnimation(0,"wallBreak",false);
        self.barrier = nil;
        --ボスギミック
        self.spValue = self.GD.addSP;---addSPの量
        unit:setBurstPoint(0)
        self:execAddBuff(unit,self.BUFF_LIST[2])  --気絶
        self:showMessage(self.BARRIER_BREAK_MESSAGE_LIST)
    end
end

function class:skill1HateEffect(unit,buffBox)
    local targetIndex = 0
    local maxHate = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,7 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local enemyUnit = self:getAncestorUnit(myTeamUnit)
            local gbHatePercent = unit:getGBHatePercent(enemyUnit:getIndex())
            if maxHate < gbHatePercent then
                maxHate = gbHatePercent
                targetIndex = myTeamUnit:getIndex()
            end
        end
    end

    for i = 0,7 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == targetIndex then
                self:execAddBuff(myTeamUnit,buffBox)
                myTeamUnit:setBurstPoint(myTeamUnit:getBurstPoint() - 300)
            end
        end
    end
end

function class:timerBuff()
    ---沼地用ギミック
    if self.GD.startBuffType == 90 and megast.Battle:getInstance():getCurrentGrandBattleFloor() > 10 then
        local BUFF_BOX_LIST = {
            ID = 300102,
            BUFF_ID = self.GD.startBuffType,
            VALUE = self.GD.startBuffValue,
            DURATION =self.GD.startBuffTime,
            ICON = self.GD.startBuffIcon,
            SCRIPT = {
                SCRIPT_ID = self.GD.startBuffScriptID,
                VALUE1 = self.GD.startBuffValue1,
                VALUE2 = self.GD.startBuffValue2 * megast.Battle:getInstance():getCurrentGrandBattleFloor();
            }
        }
        if self:enemyAddBuff(self.gameUnit,BUFF_BOX_LIST) then
            if self.START_BUFF_MESSAGE_LIST[self.GD.startBuffType] ~= nil then
                self:execShowMessage(self.START_BUFF_MESSAGE_LIST[self.GD.startBuffType])
            end
        end
    end
    return;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "barrier" then self:addBarrier(event.unit) end
    return 1;
end

function class:addBarrier(unit)
    self.subBarFlg = true
    self.subBarInfoFlg = true
    self.barrier = unit:addOrbitSystem("wallloop",0);
    self.barrier:takeAnimation(0,"wallloop",true);
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
    if self.subBarFlg then
        self.subBarFlg = false
        self.damage = 0
        self.subBar:setVisible(false);

        self.barrier:takeAnimation(0,"wallBreak",false);
        self.barrier = nil;

        self.spValue = self.GD.addSP;---addSPの量
        self.hpSkill = 2
    end

    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if event.index == 1 then
        self.skill1Flg = true
    elseif event.index == 3 then
        self.lastSkillFLG = true
    end

    if event.index == 1 or event.index == 2 then
        self:execAddBuff(event.unit,self.BUFF_LIST[1])
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    -- 【MEGA_D-9761】ボスの技の予告に、attackDamageValue の GB のヘイトの割合の倍率（(割合 × hateGimmickRate + hateGimmickBase) ÷ 100。弾も同じ）を入れる（表示専用。予測のたびに今の割合で出す。係数が数のときだけ呼ぶ。古いアプリには無いので確かめてから呼ぶ）
    if event.unit.announceSkillRateBy and type(self.hateGimmickRate) == "number" and type(self.hateGimmickBase) == "number" then event.unit:announceSkillRateBy(3, self.hateGimmickRate, self.hateGimmickBase) end
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
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local gbHatePercent = event.unit:getGBHatePercent(enemyUnit:getIndex())
    local rate = ((gbHatePercent * self.hateGimmickRate) + self.hateGimmickBase) / 100
    --summoner.Utility.messageByEnemy(gbHatePercent.."/"..rate)
    event.value = event.value * rate
    return event.value
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local gbHatePercent = event.unit:getGBHatePercent(enemyUnit:getIndex())
    local rate = ((gbHatePercent * self.hateGimmickRate) + self.hateGimmickBase) / 100
    --summoner.Utility.messageByEnemy(gbHatePercent.."/"..rate)
    event.value = event.value * rate
    return event.value
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
    ---ダメージ軽減ギミック
    if self.subBarFlg then
        --魔法判定
        local attribute = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 2 then
            event.value = event.value * self.extraGaugeMagicDamageRate
        else
            event.value = event.value * self.extraGaugeDamageRate
        end
        self.damage = self.damage + event.value
    end

    event.value = self:adjustHpFlg(event.unit,event.value,enemyUnit)
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
    if self.calcDamage == nil then
        self.calcDamage = 1;
    end
    if self.saveHP ~= nil then
        if unit:getHP() == self.saveHP then
            self.calcDamage = self.calcDamage + 1;
        end
    end
    self.breakSkip = true
    local damage = unit:getHP() - border + self.calcDamage
    if damage > 0 then
        self.saveHP = unit:getHP()
    else
        self.saveHP = nil
    end
    return damage
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
    event.unit:setNextAnimationName("idle1")
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 0
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

function class:teamAddBuff(unit,buffBox)
    local myTeam = unit:getTeam()
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

function class:enemyAddBuff(unit,buffBox)
    local flg = false
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil and myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBox.ID) == nil  then
            flg = true;
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
    return flg
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