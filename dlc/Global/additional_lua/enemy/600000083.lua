local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_フォンギオン", version=1.9, id=600000083});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK4 = 50},
        { ATTACK1 = 50, ATTACK2 = 50},
        { ATTACK2 = 50, ATTACK3 = 50},
        { ATTACK1 = 50, ATTACK3 = 50},
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
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7,
    SKILL4 = 8
}


--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 0,
            VALUE = 0,
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
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "光属性・反射・奥義ゲージ低下耐性",
            COLOR = Color.yellow
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "人族キラー・ダメージ無効化無効",
            COLOR = Color.yellow
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "毒・燃焼・病気状態のとき被ダメージアップ",
            COLOR = Color.yellow
        })
    }
    self.SKILL_INFO_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL_INFO_MESSAGE1 or "時空は、我が手中にある…！",
            COLOR = Color.red
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL_INFO_MESSAGE2 or "燃焼耐性",
            COLOR = Color.yellow
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL_INFO_MESSAGE3 or "燃焼・毒耐性",
            COLOR = Color.yellow
        }),
        [4] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL_INFO_MESSAGE4 or "燃焼・毒・病気耐性",
            COLOR = Color.yellow
        }),
        [5] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL_INFO_MESSAGE5 or "燃焼・毒・病気・クリティカル耐性",
            COLOR = Color.yellow
        })
    }
    self.INFO_MESSAGE_LIST1 = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.INFO_MESSAGE1 or "時空の扉は開かれた",
            COLOR = Color.red
        })
    }
    self.INFO_MESSAGE_LIST2 = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.INFO_MESSAGE2 or "矮小にして脆弱なる者達よ",
            COLOR = Color.red
        })
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        --[1] = {
        --    tag = "HP_FLG",
        --    action = function (status) self:hp50(status) end,
        --    HP = 50,
        --    used = false
        --}
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

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 20;---addSPの量
    event.unit:setAttackDelay(9);---アタックディレイ
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

    self.attackDelayInt = 9
    self.buffIndexInt = 1
    self.skillInfoInt = 1
    self.infoFlg = false
    self.stunFlg = false
    self.operationFlg = false
    self.orbitAttackFlg = false
    self.idleUnitOperation = false
    self.endlessStopFlg = false

    ---フォンギオンで使用する変数たち
    self.stopOrbit = nil;
    self.isStop = false;
    self.reverceMode = false;
    self.hitStopRegection = true;
    self.forceSkillNumber = 0;
    self.isReady = false
    self.posX = 0
    self.posY = 0
    self.Clock = nil;
    self:createClock(event.unit);

    ---サブHP表示用
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = event.unit:getCalcHPMAX() * 0.12---サブバーのHP(最大体力の12%)
    self.damage = 0---サブバー表示時のダメージ
    self.subHPRepair = false

    self.hpPercent1 = self.SUB_HP * 0.66---サブバーのHP(66%)
    self.hpPercent2 = self.SUB_HP * 0.33---サブバーのHP(33%)
    self.gaugeGimmickFlg1 = true
    self.gaugeGimmickFlg2 = true
    self.gaugeGimmickFlg3 = true
    self.subBarFlg = true

    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:getDefaultPosition(event.unit)
    return 1;
end

function class:getDefaultPosition(unit)
    self.posX = unit:getPositionX()
    self.posY = unit:getPositionY()
    self.isReady = true
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    --self:HPTriggersCheck(event.unit)
    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);---サブバー表示
    end
    event.unit:setReduceHitStop(10,1)---ヒットストップ無効or時止め無効
    if self.hitStopRegection then
        event.unit:setReduceHitStop(20,1);
        event.unit:takeGrayScale(0.99);
    end
    if self.isReady then self:lockPosition(event.unit) end

    if self.Clock.object ~= nil then
        self.Clock.object:setPosition(-260,-30)
    end
    return 1
end

function class:lockPosition(unit)
    unit:setPosition(self.posX,self.posY)
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
        self.damage = 0
    end
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage)/self.SUB_HP);
    ---ゲージ66%になった場合の処理
    if self.SUB_HP - damage <= self.hpPercent1 then
        if self.gaugeGimmickFlg1 then
            self.gaugeGimmickFlg1 = false
            self:deBuffRefresh(unit)  --状態異常回復
            self.gameUnit:addSP(100)
            self.isRage = true
        end
    end
    ---ゲージ33%になった場合の処理
    if self.SUB_HP - damage <= self.hpPercent2 then
        if self.gaugeGimmickFlg2 then
            self.gaugeGimmickFlg2 = false
            self:deBuffRefresh(unit)  --状態異常回復
            self.gameUnit:addSP(100)
            self.isRage = true
        end
    end
    ---ゲージ0%になった場合の処理
    if self.SUB_HP - damage <= 0 then
        if self.gaugeGimmickFlg3 then
            self.subBarFlg = false
            self.gaugeGimmickFlg3 = false
            self:deBuffRefresh(unit)  --状態異常回復
            self.gameUnit:addSP(100)
            self.isFury = true
            self.attackDelayInt = self.attackDelayInt - 1
            if self.attackDelayInt >= 4 then
                unit:setAttackDelay(self.attackDelayInt);---アタックディレイ
            end
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "endless" then self:endless(event.unit); end
    if event.spineEvent == "cameraControll" then self:cameraControll(event.unit); end
    if event.spineEvent == "showStopOrbit" then self:showStopOrbit(event.unit); end
    if event.spineEvent == "stop" then self:stop(event.unit); end
    if event.spineEvent == "reStart" then self:restart(event.unit); end
    if event.spineEvent == "clockAttack" then self.Clock:takeAttack(); end
    if event.spineEvent == "tickEnd" then self.Clock:tick(); end
    if event.spineEvent == "clockActionEnd" then self.Clock:takeBaseAnimation(); end

    if event.spineEvent == "reverce" then
        self.Clock:setVector(-1);
        self.Clock:takeSkill4();
        --self:showMessages(event.unit,self.REVERCE_MESSAGES1);
    end

    if event.spineEvent == "reInit" then
        --event.unit:setHP(event.unit:getCalcHPMAX());
        event.unit:setBreakPoint(event.unit:getBaseBreakCapacity());
        --self:setHPTriggers();
        self.reverceMode = false;
        --self:showMessages(event.nit,self.REVERCE_MESSAGES2);
        self.Clock:setVector(1);
    end

    if event.spineEvent == "reverceEnd" then self.Clock:setVector(1); end
    return 1;
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.idleUnitOperation then
        self.idleUnitOperation = false
        self.isReady = true
    end
    self:restart()  --ユニットの色戻し
    self:stunRefresh()  --気絶解除
    if self.infoFlg then  --奥義8後のinfo出し
        self.infoFlg = false
        self:setInfoList()
    end
    return 1;
end

function class:stunRefresh()
    local badStatusIDs = {[1]=89}
    local team = megast.Battle:getInstance():getTeam(true)
    for l = 1,#badStatusIDs do
        for i = 0,7 do
            local target = team:getTeamUnit(i);
            if target ~= nil then
                self:debuffRefresh(target)
            end
        end
    end
end

---デバフ解除
function class:debuffRefresh(unit)
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            for typeId = 89,89 do
                if cond:getValue() < 0 and not cond:getIsPassive() then
                    if cond:getConditionTypeAsInt() == typeId then
                        cond:setTime(0) --バフ除去
                    end
                end
            end
        end
    end
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

    if event.index == 1 then
        self:restart()
        self:stunObservation()
    elseif event.index == 2 then
        self:restart()
        self:stunObservation()
    elseif event.index == 3 then
        self:restart()
        self:stunObservation()
    elseif event.index == 4 then
        self.orbitAttackFlg = true
        self.isStop = true
        self.operationFlg = true
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
    self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
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

function class:stunObservation()
    local team = megast.Battle:getInstance():getTeam(true)
    for i = 0,7 do
        local uni = team:getTeamUnit(i);
        if uni ~= nil then
            local find = uni:getTeamUnitCondition():findConditionWithType(89)
            if find ~= nil then
                uni:takeGrayScale(0.1)   --ユニット白色化
            end
        end
    end
end

function class:attackDamageValue_OrbitSystem(event)
    if self.orbitAttackFlg then
        self.orbitAttackFlg = false
        event.enemy:getTeamUnitCondition():addCondition(-12,89,100,5,0,0);  --強制気絶付与
        event.enemy:takeGrayScale(0.1)   --ユニット白色化
        self.isReady = true   --ユニット初期位置移動
        event.enemy:setBurstPoint(-300)   --奥義ゲージDOWN
    end
    return event.value
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

    if event.index == 3 then
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("1-skill3")
    end

    if event.index == 4 then
        event.unit:setNextAnimationName("skill4")
        event.unit:setNextAnimationEffectName("1-skill4")
        self.gameUnit:setInvincibleTime(4)
    end

    if event.index == 1 then
        self:showMessage(self.INFO_MESSAGE_LIST1)
        self.gameUnit:setInvincibleTime(8)
        self.stunFlg = true
        self.isStop = true
        self.idleUnitOperationFlg = true
    elseif event.index == 2 then
        self.gameUnit:setInvincibleTime(7)
    elseif event.index == 3 and self.isRage then
        self.isRage = false
        self:showMessage(self.INFO_MESSAGE_LIST2)
        self.isReady = true   --ユニット初期位置移動
        self.endlessStopFlg = true
        event.unit:takeSkillWithCutin(event.index,1);   --真奥義カットイン
        return 0
    elseif event.index == 4 and self.isFury then
        self:showMessage(self.SKILL_INFO_MESSAGE_LIST,1)
        self.subBarFlg = true   --エクストラゲージの判定復活
        self.subHPRepair = true   --エクストラゲージ全回復
        self:subBarControll(event.unit,self.damage);---サブバー表示
    self:setBuffList()
        self.isFury = false
        self.isReady = true   --ユニット初期位置移動
        self.gaugeGimmickFlg1 = true
        self.gaugeGimmickFlg2 = true
        self.gaugeGimmickFlg3 = true
        self.infoFlg = true
        self:unitTheWord()
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()

    if self.isRage then
        skillIndex = 3
    elseif self.isFury then
        skillIndex = 4
    else
        if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_SKILL.actCount,7,Color.magenta); end
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end
    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
end

function class:endlessStop()
    self.isStop = true;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i,true);
        if uni ~= nil then
            uni:getTeamUnitCondition():addCondition(-12,89,100,23,0);
            uni:takeGrayScale(0.1);
        end
    end
end

function class:unitTheWord()
    local badStatusIDs = {[1]=89}
    local team = megast.Battle:getInstance():getTeam(true)
    for l = 1,#badStatusIDs do
        for i = 0,7 do
            local target = team:getTeamUnit(i);
            if target ~= nil then
                self.isStop = true
                target:getTeamUnitCondition():addCondition(-12,89,100,13,0);
                --self:stop(target)
                self:theWorld(target);
            end
        end
    end
end

function class:setBuffList()
    local DAMAGE_BUFF_LIST = {
        ID = 0,
        BUFF_ID = 17,  --与ダメージUP
        VALUE = 30,
        DURATION = 900,
        ICON = 26
    }
    local BUFF_LIST1 = {
        ID = 600008301,
        BUFF_ID = 60,  --燃焼耐性
        VALUE = 100,
        DURATION = 999999,
        ICON = 66
    }
    local BUFF_LIST2 = {
        ID = 600008302,
        BUFF_ID = 53,  --毒耐性
        VALUE = 100,
        DURATION = 999999,
        ICON = 59
    }
    local BUFF_LIST3 = {
        ID = 600008303,
        BUFF_ID = 57,  --病気耐性
        VALUE = 100,
        DURATION = 999999,
        ICON = 63
    }
    local BUFF_LIST4 = {
        ID = 600008304,
        BUFF_ID = 23,  --クリティカル耐性
        VALUE = -100,
        DURATION = 999999,
        ICON = 188
    }
    local BUFF_LIST11 = {
        ID = 600008311,
        BUFF_ID = 109,  --燃焼回避率
        VALUE = 100,
        DURATION = 999999,
        ICON = 0
    }
    local BUFF_LIST12 = {
        ID = 600008312,
        BUFF_ID = 102,  --毒回避率
        VALUE = 100,
        DURATION = 999999,
        ICON = 0
    }
    local BUFF_LIST13 = {
        ID = 600008313,
        BUFF_ID = 106,  --病気回避率
        VALUE = 100,
        DURATION = 999999,
        ICON = 0
    }
    self:execAddBuff(self.gameUnit,DAMAGE_BUFF_LIST)  --与ダメUPバフ付与
    if self.buffIndexInt == 1 then
        self.buffIndexInt = self.buffIndexInt + 1
        self:execAddBuff(self.gameUnit,BUFF_LIST1)
        self:execAddBuff(self.gameUnit,BUFF_LIST11)
    elseif self.buffIndexInt == 2 then
        self.buffIndexInt = self.buffIndexInt + 1
        self:execAddBuff(self.gameUnit,BUFF_LIST2)
        self:execAddBuff(self.gameUnit,BUFF_LIST12)
    elseif self.buffIndexInt == 3 then
        self.buffIndexInt = self.buffIndexInt + 1
        self:execAddBuff(self.gameUnit,BUFF_LIST3)
        self:execAddBuff(self.gameUnit,BUFF_LIST13)
    elseif self.buffIndexInt == 4 then
        self:execAddBuff(self.gameUnit,BUFF_LIST4)
    end
end

function class:setInfoList()
    if self.skillInfoInt < 5 then
        self.skillInfoInt = self.skillInfoInt + 1
    end
    self:showMessage(self.START_MESSAGE_LIST)
    self:showMessage(self.SKILL_INFO_MESSAGE_LIST,self.skillInfoInt)
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.stunFlg then   --気絶
        self.stunFlg = false
        self:unitStun(event)
    end

    if self.isStop then   --ユニット白色化
        self:theWorld(event.enemy);
    end

    if self.operationFlg then   --初期位置移動
        self.operationFlg = false
        self.isReady = true   --ユニット初期位置移動
    end

    if self.endlessStopFlg then
        self.endlessStopFlg = false
        self:endlessStop()
    end

    return event.value;
end

function class:unitStun(event)
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i,true);
        if uni ~= nil then
            uni:getTeamUnitCondition():addCondition(-12,89,100,5,0,0);  --強制気絶付与
        end
    end
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    self:canselled();
    return 1;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self:findBadCondition(event.unit) then
        event.value = event.value * 2
    end
    event.value = self:adjustHpFlg(event.unit,event.value)
    self.damage = self.damage + event.value
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

function class:findBadCondition(unit)
    local cnt = 0;
    local badStatusList = {
        90,  --毒
        94,  --病気
        97   --燃焼
    }
    for k,v in pairs(badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return true;
        end
    end
    return false;
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
    self:stopArts(self.gameUnit);
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
    return 1
end

--===================================================================================================================
-- バフ関係
--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit,buffBoxList,index)
    if index == nil then
        self:addBuffAll(unit,buffBoxList)
        return
    end
    self:execAddBuff(unit,buffBoxList[index])
end

function class:addBuffAll(unit,buffBoxList)
    for _,buffBox in ipairs(buffBoxList) do
        self:execAddBuff(unit,buffBox)
    end
end

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end
    unit:getTeamUnitCondition():removeCondition(buff);
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

--=====================================================================================================================================
--エンドレスの演出関連
function class:endless(unit)
    local bg = unit:addOrbitSystemWithFile("50086endless","BG_ENDLESS");
    bg:setZOrder(2);
    unit:addOrbitSystemCameraWithFile("50086endless","FONT_ENDLESS",false);
    unit:addOrbitSystemWithFile("50086endless","CutIN_ENDLESS");
    local ef = unit:addOrbitSystem("endlessEF",0);
    ef:setDamageRateOffset(0.001);
    ef:setZOrder(9000);
    self.Clock:takeEndless();
    unit:takeGrayScale(0.1);
end

function class:cameraControll(unit)
    unit:cameraLock(0,0.2,unit:getSkeleton():getBoneWorldPositionX("MAIN"),unit:getSkeleton():getBoneWorldPositionY("MAIN") -250);
end
--=====================================================================================================================================
--時止め関連
function class:showStopOrbit(unit)
    self.stopOrbit = unit:addOrbitSystem("skill1orbit",0);
    self.stopOrbit:setZOrder(2);
    self.hitStopRegection = true;
end

function class:stop(unit)
    self.isStop = true;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i,true);
        if uni ~= nil then
            uni:getTeamUnitCondition():addCondition(-12,92,100,13,0);
            uni:takeGrayScale(0.1);
            uni:takeHitStop(13);
        end
    end
end

function class:theWorld(unit)
    unit:takeGrayScale(0.1);
end

function class:canselled()
    self.isStop = false;
    if self.stopOrbit ~= nil then
        self.stopOrbit:takeAnimation(0,"skill1orbitCansel",false);
        self.stopOrbit = nil;
    end
    self:restart();
end

function class:restart()
    self.hitStopRegection = true;
    self.stopOrbit = nil;
    self.isStop = false;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            uni:takeGrayScale(0.99);
        end
    end
end

--=====================================================================================================================================
--背後の時計関係
function class:createClock(unit)
    self.Clock = {
        object = nil,
        vector = 1,
        count = 0,

        setUp = function(clock)
            clock.object:takeAnimation(0,"base",true);
            clock.object:setZOrder(3);
            clock.object:setPosition(-260,-30);
        end,

        takeBaseAnimation = function(clock)
            clock.object:takeAnimation(0,"base",true);
        end,

        setVector = function(clock,vec)
            clock.vector = vec;
        end,

        tick = function(clock)
            local clockTime = clock.count%12;
            local nextClockTime = (clock.count + clock.vector)%12;
            clock.object:setSetupAnimationName(""..clockTime.."to"..nextClockTime);
            clock.object:takeAnimation(1,""..clockTime.."to"..nextClockTime,false);
            clock.count = clock.count + clock.vector;
        end,

        takeAttack = function(clock)
            clock.object:takeAnimation(0,"attack3",true);
        end,

        takeEndless = function(clock)
            clock.object:takeAnimation(0,"skill3",true);
        end,

        takeSkill4 = function(clock)
            clock.object:takeAnimation(0,"skill4",true);
        end

    }
    self.Clock.object = unit:addOrbitSystemWithFile("50086Clock","base");
    self.Clock:setUp();
    self.Clock:tick();
end
--=====================================================================================================================================

class:publish();

return class;