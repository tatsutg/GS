local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="魔族の遺跡／天魔帥ゼ＝レムナ hard", version=1.3, id=2064535});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        {ATTACK4=50},
        {ATTACK1=50, ATTACK2=50},
        {ATTACK1=50, ATTACK3=50},
        {ATTACK2=50, ATTACK3=50}
    }
}
--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        {SKILL1=50}
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL1 = 6,
    SKILL2 = 7,
    SKILL3 = 8
}

class.cutInSkill = {
    [2] = 1,
    [3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.STUN_BUFF_LIST = {
        [1] = {
            ID = 20645351,
            BUFF_ID = 89,
            VALUE = 100,
            DURATION = 99999,
            ICON = 79
        },
        [2] = {
            ID = 20645351,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [3] = {
            ID = 0,
            BUFF_ID = 89,
            VALUE = 100,
            DURATION = 3,
            ICON = 79
        }
    }
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 32,---命中率DOWN
            VALUE = self.GD.buffValue_32,
            DURATION = 999999,
            ICON = 15
        },
        [2] = {
            ID = 20645352,
            BUFF_ID = 17,
            VALUE = 0,
            DURATION = 99999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
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
    self.elementName = {
        [0] = self.TEXT.ELEMENT0 or "無",
        [1] = self.TEXT.ELEMENT1 or "炎",
        [2] = self.TEXT.ELEMENT2 or "水",
        [3] = self.TEXT.ELEMENT3 or "樹",
        [4] = self.TEXT.ELEMENT4 or "光",
        [5] = self.TEXT.ELEMENT5 or "闇"
    }
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "ダメージの大きいユニットをターゲット", COLOR = Color.yellow})
    }
    self.LOCK_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.LOCK_MESSAGE1 or "%s属性をロック", COLOR = Color.red}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.LOCK_MESSAGE2 or "ロックされたユニットの命中率ダウン", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp80(status) end,
            HP = 80,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp80(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp80(status) end,
            HP = 20,
            used = false,
            isEnableSkip = false
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

function class:hp80(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 2
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
    end
end

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 3
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(10)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        attackDelay = 8,
        hitStop = 100,
        buffValue_32 = -30,
        damageUpBase = 20,
        damageUpMultiplication = 5,
        damageUpToThePowerOf = 2
    })
    self:dump(self.GD)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
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

    ---ダメージターゲット系
    self.damageBox = {}
    for i = 0,6 do
        self.damageBox[i] = 0
    end
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();

    ---ファンタズムロック関係
    self.phantasmTable = {}
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self.phantasmTable[i] = false
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    self:phantasmLockUpdate()
    ---バックループ防止
    local x = event.unit:getPositionX();
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local unitPosition = myTeamUnit:getPositionX();
            if x >= unitPosition then
                myTeamUnit:setPositionX(myTeamUnit:getPositionX() + 50)
            end
        end
    end
    ---死亡時処理
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.lastSkillFLG == nil then self.lastSkillFLG = false end
        if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
            event.unit:getTeam():deadUnit(event.unit:getIndex());
            megast.Battle:getInstance():waveEnd(true);
        end
        if self.TRIGGERS[4].used then
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

function class:phantasmLockUpdate()
    local count = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if self.phantasmTable[i] ~= nil then
                if self.phantasmTable[i] then
                    count = count + 1
                    --self:itemCtReset(myTeamUnit)
                    --myTeamUnit:getNormalSkill():resetCooltime()
                    --myTeamUnit:setBurstPoint(0)
                    if myTeamUnit:getPositionX() < self.gameUnit:getPositionX() + 100 then
                        myTeamUnit:setPositionX(self.gameUnit:getPositionX() + 100)
                    end
                else
                    myTeamUnit:takeGrayScale(1);
                end
            end
        else
            if self.phantasmTable[i] ~= nil then
                self.phantasmTable[i] = false
            end
        end
    end
    return 1;
end

function class:phantasmLock()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local target = self:checkDamageTargetUnit(self.gameUnit)
    local element = -1
    if target ~= nil then
        element = target:getElementType()
        self:showFormatMessage(self.LOCK_MESSAGE_LIST[1],self.elementName[element])
        self:execShowMessage(self.LOCK_MESSAGE_LIST[2])
    end
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getElementType() == element then
                self:phantasmLockBuff(myTeamUnit:getIndex());
            end
        end
    end
    return 1;
end

function class:phantasmLockBuff(rand)
    ---ターゲットにロック状態バフなど付与
    local myTeam = megast.Battle:getInstance():getTeam(true);
    self.phantasmTable[rand] = true
    local myTeamUnit = myTeam:getTeamUnit(rand)
    if myTeamUnit ~= nil then
        myTeamUnit:takeGrayScale(0.1);
        self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[1])
        self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[1])
        self:lockPosition(self.gameUnit,myTeamUnit)
    end
end

function class:lockPosition(unit,target)
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    target:setPosition((x + 480 + math.random(-50,50)),(y + math.random(-50,50)))
    return 1
end

function class:initPhantasmLock()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self.phantasmTable[i] = false
            self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[2])
            myTeamUnit:takeGrayScale(1);
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
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
        event.unit:setNextAnimationName("attack4")
        event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-attack4")
    elseif event.index == 4 then
        event.unit:setNextAnimationName("attack5")
        event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-attack5")
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.hpFlg = false
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        ---生存ユニットが全員ロック状態の場合強制敗北
        local myTeam = megast.Battle:getInstance():getTeam(true);
        local FLG = false
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if not self.phantasmTable[i] then
                    FLG = true
                end
            end
        end
        if not FLG then
            event.unit:setNextAnimationName("idle");
            event.unit:setNextAnimationEffectName("1-skill2")
            self:initPhantasmLock()
            self:allDead()
        end
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

function class:allDead()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:setHP(0)
            myTeamUnit:getTeam():deadUnit(myTeamUnit:getIndex());
        end
    end

    megast.Battle:getInstance():waveEnd(false);
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
        self.BUFF_BOX_LIST[2].COUNT = self.BUFF_BOX_LIST[2].COUNT + 1
        self.BUFF_BOX_LIST[2].VALUE = (self.BUFF_BOX_LIST[2].COUNT^self.GD.damageUpToThePowerOf * self.GD.damageUpMultiplication) + self.GD.damageUpBase
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[2])
    elseif event.index == 2 then
        ---前回の対象が残っている場合は気絶解除
        self:initPhantasmLock()
        ---今回の対象をロック
        self:phantasmLock()
        ---ダメージリセット
        for i = 0,6 do
            self.damageBox[i] = 0
        end
    elseif event.index == 3 then
        self.gameUnit:setInvincibleTime(30)
        self.lastSkillFLG = true
    end
    
    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    if self.saveInvincibleTime > 0 then
        event.unit:setInvincibleTime(self.saveInvincibleTime)---無敵掛け直し
        self.saveInvincibleTime = 0
    end
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

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    local enemyUnit = self:getAncestorUnit(event.enemy)
    event.value = self:adjustHpFlg(event.unit,event.value)
    ---ダメージターゲット処理
    self.damageBox[enemyUnit:getIndex()] = self.damageBox[enemyUnit:getIndex()] + event.value
    local target = self:checkDamageTargetUnit(event.unit)
    if target ~= nil and megast.Battle:getInstance():isHost()  then
        event.unit:setHateTarget(target)
        event.unit:updateHateTarget();
        megast.Battle:getInstance():sendEventToLua(self.scriptID,8,target:getIndex());
    end
    return event.value
end

---与ダメが最も大きいやつをターゲットにする
function class:checkDamageTargetUnit(unit)
    local target = nil
    local damage = 0
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil and myTeamUnit:getHP() > 0 then
            if damage < self.damageBox[myTeamUnit:getIndex()] then
                damage = self.damageBox[myTeamUnit:getIndex()]
                target = myTeamUnit
            end
        end
    end
    return target
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
    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index)
        return;
    end

    self.hpFlg = true
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

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT)
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

class:publish();

return class;