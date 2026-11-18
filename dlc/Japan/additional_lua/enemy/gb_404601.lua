local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="GB4エリアボス_ジオ＝ザグナス", version=2.4, id="gb_404601"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        {ATTACK1=50, ATTACK2=50},
        {ATTACK3=50},
        {ATTACK1=50, ATTACK2=50}
    }
}
--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        {SKILL2=50}
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL2 = 7
}

class.cutInSkill = {
    [2] = 1
}

---
class.BONE_NAMES = {
    FIRST = "L_arm3_hand_4",
    SECOND = "Glab"
}

class.ORBIT_ARGS = {
    AX = {
        start = "goblin_ax",
        finish = "goblin_axEnd",
        activeSkill = 4
    },
    BONE = {
        start = "goblin_bone",
        finish = "goblin_bone_bound",
        activeSkill = 4
    },
    IRON = {
        start = "goblin_iron-ball",
        finish = "goblin_iron-ballEnd",
        activeSkill = 4
    },
    POIZON = {
        start = "goblin_poison",
        finish = "goblin_poison_dusty",
        activeSkill = 5
    }
}

class.WEAPON_STATES = {
    NONE = 0,
    HUMMER = 1,
    BREAKED = 2
}


--===============================================================================================================================================
--定数
class.STAN_BUFFID = -10;
class.STAN_BUFFEFID = 89;
class.STAN_BUFFEFVALUE = 100;
class.STAN_BUFFEFDURATION = 1;

class.GRENADE_RECAST = 10;

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 4046011,
            BUFF_ID = 17,
            VALUE = self.GD.buffValue_17,
            DURATION = 99999,
            ICON = 26,
            MAX = 99
        },
        [2] = {
            ID = 4046012,
            BUFF_ID = 89,
            VALUE = 100,
            DURATION = 0,
            ICON = 79
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "与ダメージの大きい者へのダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "HP自然回復・病気耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "状態異常のとき、ブレイク耐性ダウン", COLOR = Color.yellow})
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "飛びかかる：ダメージ無効化無効", COLOR = Color.yellow})
    }
    self.GRAB_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GRAB_MESSAGE1 or "奥義ゲージの高い者をホールド", COLOR = Color.yellow})
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp60(status) end,
            HP = 60,
            used = false,
            isEnableSkip = true
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
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

function class:hp60(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.spValue = self.spValue + 10
        self.hpSkill = 2
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(7)
        self:showMessage(self.HP60_MESSAGE_LIST)
    end
end

function class:hp30(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.spValue = self.spValue + 10
        self.hpSkill = 2
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(7)
        self:showMessage(self.HP30_MESSAGE_LIST)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 30,
        attackDelay = 5,
        hitStop = 100,
        timeLimit = 180,
        hateGimmickRate = 1.5,
        hateGimmickBase = 50,
        grenadeRecast = 12,
        stunBase = 10,
        stunRate = 0.05,
        bpMinusBase = 70,
        takeDamageValue = 2,
        buffValue_17 = 25
    })
    self:dump(self.GD)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    self.gbAreaNumber = megast.Battle:getInstance():getCurrentGrandBattleFloor();
    event.unit:addSP(self.gbAreaNumber)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;

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

    self.saveInvincibleTime = 0

    self.hpFlg = false
    self.attack3Flg = true

    ---バトルタイム
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.GD.timeLimit ,30, 620 , -100 ,0.8);

    ---ヘイトギミック
    event.unit:setEnableGBHate(true);

    ---つかみ関連の変数たち
    self.glabTargetIndex = nil;
    self.glabBoneName = "";
    self.tryGlab = false;
    self.isGlab = false;
    ---投擲物関連の変数たち
    self.grenadeTimer = 0;
    self.granedeTargetIndex = 0;
    ---足関係
    event.unit:addSubSkeleton("50103_leg",-30);
    event.unit:setSkin("1");
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    self:grenadeCheck(event.deltaTime);
    if self.isGlab and self.glabTargetIndex ~= nil then
        self:glabControll(event.unit);
    end

    --掴み時に奥義発動した場合の対策
    if event.unit:getUnitState() == kUnitState_skill and self.isGlab and self.glabTargetIndex ~= nil then
        self:throwEnd(event.unit)
    end

    ---バトルタイム
    self:countDown()
    return 1
end

function class:countDown()
    if BattleControl:get():getTime() > self.GD.timeLimit then
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

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "glab" then self:glab(event.unit) end
    if event.spineEvent == "throw" then self:throw(event.unit) end
    if event.spineEvent == "throwEnd" then self:throwEnd(event.unit) end
    if event.spineEvent == "lunchPoisonGrenade" then self:lunchPoisonGrenade(event.unit) end
    if event.spineEvent == "checkGlabSucsess" and self.tryGlab then self:checkGlabSucsess(event.unit) end
    if event.spineEvent == "lunchOther" then self:lunchOther(event.unit) end
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
        self.attack3Flg = true
        event.unit:setNextAnimationName("attack5");
        event.unit:setNextAnimationEffectName("1-attack5");
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.hpFlg = false
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
    elseif event.unit:getSize() ~= 3 then
        event.unit:addSP(self.spValue)
    end
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    if unit:getSize() == 3 then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
    else
        ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時、movePatternState()を動かさない---
        if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
            if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
            self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
        end
        --------------------------------------------------------------------------------------
    end
    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end

function class:takeIdle(event)
    if self.afterSkillFLG then
        self.hpFlg = false
        self.gameUnit:setInvincibleTime(0)
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

    self.attack3Flg = false
    if event.index == 2 then
        self:showMessage(self.SKILL2_MESSAGE_LIST)
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
    end
    
    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    if self.saveInvincibleTime > 0 then
        event.unit:setInvincibleTime(self.saveInvincibleTime)---無敵掛け直し
        self.saveInvincibleTime = 0
    end
    self:skillActiveSkillSetter(event.unit,event.index);
    -- 【MEGA_D-9761】ボスの技の予告に、attackDamageValue の GB のヘイトの割合の倍率（(割合 × hateGimmickRate + hateGimmickBase) ÷ 100。弾も同じ）を入れる（表示専用。予測のたびに今の割合で出す。係数が数のときだけ呼ぶ。古いアプリには無いので確かめてから呼ぶ）
    do local gd = self.GD; if event.unit.announceSkillRateBy and gd and type(gd.hateGimmickRate) == "number" and type(gd.hateGimmickBase) == "number" then event.unit:announceSkillRateBy(3, gd.hateGimmickRate, gd.hateGimmickBase) end end
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
    if self.tryGlab then
        if self.glabTargetIndex == nil then
            self.glabTargetIndex = self:checkTarget(event.unit)
            self:checkGlabSucsess(event.unit);
        end
    end
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local gbHatePercent = event.unit:getGBHatePercent(enemyUnit:getIndex())
    local rate = ((gbHatePercent * self.GD.hateGimmickRate) + self.GD.hateGimmickBase) / 100
    --summoner.Utility.messageByEnemy(gbHatePercent.."/"..rate)
    event.value = event.value * rate
    return event.value
end

function class:checkTarget(unit)
    local index = 0
    local bp = 0
    for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if localUnit ~= nil then
            if bp < localUnit:getBurstPoint() then
                index = i
                bp = localUnit:getBurstPoint()
            end
        end
    end
    return index
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local gbHatePercent = event.unit:getGBHatePercent(enemyUnit:getIndex())
    local rate = ((gbHatePercent * self.GD.hateGimmickRate) + self.GD.hateGimmickBase) / 100
    --summoner.Utility.messageByEnemy(gbHatePercent.."/"..rate)
    event.value = event.value * rate
    return event.value
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    local enemyUnit = self:getAncestorUnit(event.enemy)
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

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local condValue = 0
    for k,typeId in pairs(self:getBadStatusList()) do
        condValue = condValue + event.unit:getTeamUnitCondition():findConditionValue(typeId)
    end
    if condValue > 0 then
        event.value = event.value * self.GD.takeDamageValue
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
            ---無敵値保存
            self.saveInvincibleTime = self.gameUnit:getInvincibleTime()
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

    self.hpFlg = true
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
    self.hpFlg = true
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
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

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
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
        89,
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97,
        129,
        131,
        135,
        201,
        202,
        203,
        204,
        205,
        206,
        207,
        208,
        233,
        234
    }
    return badStatusList
end

--===============================================================================================================================================
--掴み投げ関連のメソッド/
--------------------
function class:glab(unit)
    self.tryGlab = true;
end



function class:checkGlabSucsess(unit)
    if not self:isHost() then
        return;
    end
    self.tryGlab = false;
    if self.glabTargetIndex ~= nil then
        self:glabExecute(unit,self.glabTargetIndex);
        self:showMessage(self.GRAB_MESSAGE_LIST)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,self.glabTargetIndex);
    else
        self:glabFaild(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,8,0);
    end
end

function class:glabExecute(unit,index)
    self.glabBoneName = self.BONE_NAMES.FIRST;
    self.isGlab = true;
    unit:setAnimation(0,"skill1_throw",false);
    self:getUnitByIndex(index):getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFID,self.STAN_BUFFEFDURATION,0);
end

function class:throw(unit)
    self.glabBoneName = self.BONE_NAMES.SECOND;
end

function class:throwEnd(unit)
    self.isGlab = false;
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    self.glabTargetIndex = nil;
    if glabUnit == nil then
        return;
    end
    local hit = unit:addOrbitSystem("GrowndHit");
    self.gameUnit:takeHitStop(0.5);

    hit:setPosition(glabUnit:getPositionX(),glabUnit:getPositionY());
    hit:setTargetUnit(glabUnit);
    hit:setHitType(2);
    hit:setActiveSkill(6);

    glabUnit:setBurstPoint(glabUnit:getBurstPoint() - (self.gbAreaNumber + self.GD.bpMinusBase))
    self.BUFF_BOX_LIST[2].DURATION = (self.gbAreaNumber * self.GD.stunRate) + self.GD.stunBase
    self:execAddBuff(glabUnit,self.BUFF_BOX_LIST[2])

    if self.attack3Flg then
        self.attack3Flg = false
        self:addSP(self.gameUnit)
    end
end

function class:glabFaild(unit)
    unit:setAnimation(0,"skill1_miss",false);
end

function class:glabControll(unit)
    local x = unit:getSkeleton():getBoneWorldPositionX(self.glabBoneName);
    local y = unit:getSkeleton():getBoneWorldPositionY(self.glabBoneName);
    local glabUnit = self:getUnitByIndex(self.glabTargetIndex);
    if glabUnit == nil then
        return;
    end
    glabUnit:getTeamUnitCondition():addCondition(self.STAN_BUFFID,self.STAN_BUFFEFID,self.STAN_BUFFEFID,self.STAN_BUFFEFDURATION,0);
    glabUnit:setPosition(x + unit:getPositionX(),0);
    glabUnit:getSkeleton():setPosition(0,y + unit:getPositionY() - 50);
    glabUnit._autoZorder = false;
    glabUnit:setZOrder(unit:getZOrder()+1);
end
--===============================================================================================================================================
--投擲物関連のメソッド/
------------------

function class:grenadeCheck(deltaTime)
    self.grenadeTimer = self.grenadeTimer + deltaTime;
    if self.grenadeTimer > self.GD.grenadeRecast and self:isHost() then
        self.grenadeTimer = 0;
        self:takePoizonGrenadeAnimation(self.gameUnit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,9,0);
        --[[
        local rand = LuaUtilities.rand(0,100);
        if rand < 100 then
            self:takePoizonGrenadeAnimation(self.gameUnit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,9,0);
        else
            self:takeOtherAnimation(self.gameUnit,rand);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,9,1);
        end
        ]]--
    end
end

function class:takePoizonGrenadeAnimation(unit)
    unit:setAnimation(1,"goblin_attack",false);
end

function class:takeOtherAnimation(unit)
    unit:setAnimation(1,"goblin_attack2",false);
end

function class:lunchPoisonGrenade(unit)
    self:lunch(unit,self.ORBIT_ARGS.POIZON);
end

function class:lunchOther(unit)
    --何を投げるかランダムで決定
    local rand = LuaUtilities.rand(0,100);
    local arg = {};


    if rand < 33 then
        arg = self.ORBIT_ARGS.AX;
    elseif rand < 66 then
        arg = self.ORBIT_ARGS.BONE;
    else
        arg = self.ORBIT_ARGS.IRON;
    end

    self:lunch(unit,arg);
end

function class:lunch(unit,arg)
    local bullet = unit:addOrbitSystem(arg.start,1);
    bullet:setHitCountMax(1);
    bullet:setEndAnimationName(arg.finish);
    bullet:setActiveSkill(arg.activeSkill);

    local x = unit:getPositionX()
    local y = unit:getPositionY()
    local xb = unit:getSkeleton():getBoneWorldPositionX("gobul_top");
    local yb = unit:getSkeleton():getBoneWorldPositionY("gobul_top");
    bullet:setPosition(x+xb,y+yb);

    local counter = 0;
    local tgt = nil;
    while counter < 4 and tgt == nil do
        counter = counter + 1;
        tgt = self:getUnitByIndex(self.granedeTargetIndex%4);
        self.granedeTargetIndex = self.granedeTargetIndex + 1;
    end

    local targetx = 0;
    local targety = 0;


    if tgt ~= nil then
        targetx = tgt:getAnimationPositionX();
        targety = tgt:getAnimationPositionY();
    end


    LuaUtilities.runJumpTo(bullet,3,targetx , targety,400,1);
end

--===============================================================================================================================================
--マルチ同期/
----------

function class:receive7(args)
    self.glabTargetIndex = args.arg;
    self:glabExecute(self.gameUnit,args.arg);
    self:showMessage(self.GRAB_MESSAGE_LIST)
    return 1;
end

function class:receive8(args)
    self:glabFaild(self.gameUnit);
    return 1;
end

function class:receive9(args)
    if args.arg == 0 then
        self:takePoizonGrenadeAnimation(self.gameUnit);
    else
        self:takeOtherAnimation(self.gameUnit);
    end
    return 1;
end

function class:takeDamage(event)
    self.isGlab = false;
    self.glabTargetIndex = nil;
    return 1;
end

--===============================================================================================================================================

function class:getUnitByIndex(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

function class:isHost()
    return megast.Battle:getInstance():isHost();
end

class:publish();

return class;