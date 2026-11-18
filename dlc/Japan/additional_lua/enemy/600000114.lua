local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_炎玉精イグニス（強）", version=2.0, id=600000114});
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
        { SKILL1 = 50 }
    },
    EXTRA = {
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

class.CRYSTAL_NUM = 3;
class.CRYSTAL_POSITIONS = {
    {x = -300,y = 500},
    {x = 300,y = 500},
    {x = 0,y = 530}
}
class.CRYSTAL_STATES = {
    start = 0,
    deactive = 1,
    activation = 2,
    active = 3,
    out = 4,
    hide = 5,
    start2 = 6
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 600001140,
            BUFF_ID = 208,  --猛炎(上位燃焼)
            VALUE = self.GD.buffValue_208,
            DURATION = 9999999,
            ICON = 308,
            SCRIPT = {
                SCRIPT_ID = 602,
                VALUE1 = 2,
                VALUE2 = 5
            }
        },
        [2] = {
            ID = 6000011410,
            BUFF_ID = 89,  --気絶
            VALUE = 100,
            DURATION = self.GD.buffTime_89,
            ICON = 79
        },
        [3] = {
            ID = 600001144,
            BUFF_ID = 59,  --氷結耐性
            VALUE = self.GD.buffVal_59,
            DURATION = 9999999,
            ICON = 65,
            COUNT = 0,
            MAX = 5
        },
        [4] = {
            ID = 600001145,
            BUFF_ID = 108,  --氷結回避率
            VALUE = self.GD.buffVal_59,
            DURATION = 9999999,
            ICON = 0,
            COUNT = 0,
            MAX = 5
        }
    }
    self.SKILL_BUFF = {
        [1] = {
            ID = 600001141,
            BUFF_ID = 17,  --与ダメ
            VALUE = self.GD.buffValue_17,
            DURATION = 9999999,
            ICON = 26,
            COUNT = 0,
            MAX = 10
        },
        [2] = {
            ID = 600001142,
            BUFF_ID = 60,  --燃焼耐性Down
            VALUE = self.GD.buffValue_60,
            DURATION = 9999999,
            ICON = 76,
            COUNT = 0,
            MAX = 10
        },
        [3] = {
            ID = 600001143,
            BUFF_ID = 109,  --燃焼回避率
            VALUE = self.GD.buffValue_60,
            DURATION = 9999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "クリティカル・反射・奥義ゲージ低下耐性", COLOR = Color.yellow})
    }
    self.EX_GAUGE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_MESSAGE1 or "炎破状態：ダメージで解除、被ダメージ軽減・奥義上昇量アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_MESSAGE2 or "炎破状態：ボスが氷結状態のとき、ダメージアップ", COLOR = Color.red})
    }
    self.GAUGE_DESTROY_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GAUGE_DESTROY_MESSAGE1 or "炎精霊がひるんでいる！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.GAUGE_DESTROY_MESSAGE2 or "炎破状態解除：被ダメージ軽減解除", COLOR = Color.red})
    }
    self.GAUGE_REVIVAL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GAUGE_REVIVAL_MESSAGE1 or "氷結耐性アップ", COLOR = Color.red})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "ブレイジングインパクト：ダメージ無効化無効", COLOR = Color.red})
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
        startAddSP = 60,
        attackDelay = 5,
        hitStop = 100,

        exGaugeHpRate1 = 0.015,
        exGaugeHpRate2 = 0.022,
        exGaugeHpRate3 = 0.03,
        subBarPlsRate = 0.01,
        exAttackDelay = 8,

        exGaOnDmgVal = 0.02,
        iceBuffDmgRate = 5,

        addSPTimeLimit = 4,
        timeAddSP = 20,

        buffValue_17 = 20,
        buffValue_60 = 20,
        buffVal_59 = 20,
        buffValue_208 = 600,
        buffTime_89 = 15
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
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
    self.buffCount = 0
    self.battleTime = 0
    self.subBarCount = 0
    self.subBarHpNum = -1
    self.subHpList = {
        [0] = self.GD.exGaugeHpRate1,
        [1] = self.GD.exGaugeHpRate2,
        [2] = self.GD.exGaugeHpRate3
    }
    self.bossHP = event.unit:getHP()

    ---サブHP表示用
    self.subBarFlg = false
    self.damage = 0---サブバー表示時のダメージ
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = self.bossHP * self.subHpList[0] ---サブバーのHP(最大体力の1.5%)

    --ボス固有ギミック
    self.crystalBuffs = {};
    self.crystals = {};
    self.crystalCounter = 0;
    self.crystalExcutionFlg = false;
    self:initCrystals(event.unit);
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:hpTriggersCheck(event.unit)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効

    ---エクストラゲージ関係
    self:checkSubBarFlg(event.unit)
    if self.subBarFlg then
        self:checkAddSPTime(event.unit,event.deltaTime)
        self:subBarControl(event.unit,self.damage);---サブバー表示
    end
    return 1
end

function class:checkSubBarFlg(unit)
    if self.subBarCount >= 2 and not self.subBarFlg then
        self.subBarFlg = true
        self.subBarCount = 0
        self.subBarHpNum = self.subBarHpNum + 1
        unit:setBurstPoint(0)
        unit:setAttackDelay(self.GD.exAttackDelay)
        self:initSkillWeight({EXTRA = 100})
        self:showMessage(self.EX_GAUGE_MESSAGE_LIST)
        --ゲージ表示２回目以降
        if self.subBarHpNum >= 1 then
            self:execAddBuff(unit,self.BUFF_LIST[3])  --氷結耐性
            self:execAddBuff(unit,self.BUFF_LIST[4])  --氷結回避率
            self.buffCount = self.buffCount + 1
            if self.buffCount < 6 then
                self:showMessage(self.GAUGE_REVIVAL_MESSAGE_LIST)
            end

            if self.subBarHpNum > 2 then
                self.subBarHpNum = 2
                self.subHpList[self.subBarHpNum] = self.subHpList[self.subBarHpNum] + self.GD.subBarPlsRate
            end
            self.SUB_HP = self.bossHP * self.subHpList[self.subBarHpNum] ---サブバーのHP(最大体力の1.5%)
        end
    end
end

function class:checkAddSPTime(unit,time)
    --奥義中か確認
    if unit:getUnitState() ~= kUnitState_skill then
        self.battleTime = self.battleTime + time
        if self.battleTime >= self.GD.addSPTimeLimit then
            self.battleTime = 0
            unit:addSP(self.GD.timeAddSP);
        end
    end
end

---サブHP表示
function class:subBarControl(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage)/self.SUB_HP);
    --テスト表示
    --summoner.Utility.messageByEnemy(self.SUB_HP  - damage);

    ---ゲージ0%になった場合の処理
    if self.SUB_HP - damage <= 0 then
        --ゲージ非表示
        self.subBarFlg = false
        self.damage = 0
        self.subBar:setVisible(false);
        --ボスギミック
        self.spValue = self.GD.addSP;---addSPの量
        unit:setBurstPoint(0)
        unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
        self:initSkillWeight({DEFAULT = 100})
        self:execAddBuff(unit,self.BUFF_LIST[2])  --気絶
        self:showMessage(self.GAUGE_DESTROY_MESSAGE_LIST)
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "crystalActionEnd" then self:crystalStateEnd(event.unit) end
    if event.spineEvent == "skill2Start" then self:skill2Start() end
    if event.spineEvent == "skill2Compleat" then self:skill2Compleat() end
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

    if event.index == 4 then
        --self:addSkill1Buff()
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
    if not self.subBarFlg then
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

    if event.index == 1 then
        self.subBarCount = self.subBarCount + 1
        self:execAddBuff(event.unit,self.SKILL_BUFF[1])
    elseif event.index == 2 then
        self:addSkill2Buff()
        self:showMessage(self.SKILL_MESSAGE_LIST)
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
    local team = megast.Battle:getInstance():getTeam(true)
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[1].ID);
            if cond == nil then
                self:execAddBuff(teamUnit,self.BUFF_LIST[1])
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
                        self:execAddBuff(teamUnit,self.SKILL_BUFF[2])
                        self:execAddBuff(teamUnit,self.SKILL_BUFF[3])
                    end
                end
            end
        end
    else
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,self.SKILL_BUFF[2])
                self:execAddBuff(teamUnit,self.SKILL_BUFF[3])
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
    --エクストラゲージ関係
    if self.subBarFlg then
        local ice = event.unit:getTeamUnitCondition():findConditionWithType(96);
        if ice then
            local dmgCalc = event.value * self.GD.iceBuffDmgRate
            self.damage = self.damage + dmgCalc
        else
            self.damage = self.damage + event.value
        end
        event.value = event.value * self.GD.exGaOnDmgVal
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



--====================================================================================================================================
--クリスタル関係

function class:initCrystals(unit)
    for i=1,3 do
        self.crystals[i] = self:createCrystal(unit,self.CRYSTAL_POSITIONS[i].x,self.CRYSTAL_POSITIONS[i].y);
    end
end

function class:createCrystal(unit,x,y)
    local crystal = {}
    crystal.orbit = unit:addOrbitSystem("crystal_idle_off");
    crystal.orbit:takeAnimation(0,"crystal_idle_off",true);
    crystal.orbit:setPosition(x,y);
    crystal.orbit:setZOrder(8999);
    crystal.state = self.CRYSTAL_STATES.deactive;

    crystal.endState = function(class,this)
        if this.state == class.CRYSTAL_STATES.start then
            this.switchState(class,this,class.CRYSTAL_STATES.deactive);
        elseif this.state == class.CRYSTAL_STATES.activation then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
        elseif this.state == class.CRYSTAL_STATES.out then
            this.switchState(class,this,class.CRYSTAL_STATES.hide);
        elseif this.state == class.CRYSTAL_STATES.start2 then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
        end
    end

    crystal.switchState = function(class,this,targetState)
        this.state = targetState;
        if targetState == class.CRYSTAL_STATES.active then
            this.orbit:takeAnimation(0,"crystal_idle_on",true);
        end
        if targetState == class.CRYSTAL_STATES.deactive then
            this.orbit:takeAnimation(0,"crystal_idle_off",true);
        end
        if targetState == class.CRYSTAL_STATES.activation then
            this.orbit:takeAnimation(0,"crystal_activate",true);
        end
        if targetState == class.CRYSTAL_STATES.start then
            this.orbit:takeAnimation(0,"crystal_in",true);
        end

        if targetState == class.CRYSTAL_STATES.start2 then
            this.orbit:takeAnimation(0,"crystal_in2",true);
        end

        if targetState == class.CRYSTAL_STATES.out then
            this.orbit:takeAnimation(0,"crystal_out",true);
        end

        if targetState == class.CRYSTAL_STATES.hide then
            this.orbit:takeAnimation(0,"crystal_hide",true);
        end
    end

    return crystal;
end

function class:crystalStateEnd(unit)
    for i=1,self.CRYSTAL_NUM do
        if self.crystals[i].orbit == unit then
            self.crystals[i].endState(self,self.crystals[i]);
            return;
        end
    end
end

function class:lightUp(unit,num)
    if num > self.CRYSTAL_NUM then
        return;
    end

    if self.crystalBuffs[num] ~= nil then
        self.crystalBuffs[num].action(self,unit);
        self.crystalBuffs[num] = nil;
    end


    for i=1,num do
        if self.crystals[i].state == self.CRYSTAL_STATES.deactive then
            self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.activation);
        end
    end
end

function class:excutionCrystals()
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.out);
    end
end

function class:restertCrystals()
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.start2);
    end
end

function class:skill2Start()
    self.crystalExcutionFlg = true;
    self:excutionCrystals();
end

function class:skill2Compleat()
    self.crystalExcutionFlg = false;
    -- self.crystalCounter = 0;
    self:restertCrystals();
end

function class:takeHPReduce(unit,deltaTime)
    self.hpReduceCheckTimer = self.hpReduceCheckTimer + deltaTime;
    if self.hpReduceCheckTimer < 0.2 then
        return;
    end
    self.hpReduceCheckTimer = self.hpReduceCheckTimer - 0.2;
    for i=0,4 do
        local teamUnit = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
        if teamUnit ~= nil then
            if teamUnit:getTeamUnitCondition():findConditionWithID(501314) == nil then
                self:addBuffs(teamUnit,self.HP_REDUCE_BUFF_ARGS);
            end
        end
    end
end




class:publish();

return class;