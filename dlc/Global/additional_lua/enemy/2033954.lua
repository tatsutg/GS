local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="無職闇ヴァルザンデス ", version=1.3, id=2033954});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50, ATTACK3 = 50},
        { ATTACK1 = 50},
        { ATTACK2 = 50},
        { ATTACK3 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL1 = 4,
    SKILL2 = 5
}


--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        ID = 0,
        BUFF_ID = 112,
        VALUE = -25,
        DURATION = 99999,
        ICON = 77
    }
    self.ANTI_BAD_CONDITION_BUFF_LIST = {
        ID = 20336541,
        BUFF_ID = 113, ---状態異常耐性(状態異常回避率)
        VALUE = 999999,
        DURATION = 999999,
        ICON = 67
    }
    self.ANTI_BAD_CONDITION_BUFF_LIST2 = {
        ID = 20336541,
        BUFF_ID = 0,
        VALUE = 0,
        DURATION = 0,
        ICON = 0
    }
    self.STUN_BUFF_LIST = {
        ID = 20336541,
        BUFF_ID = 89,
        VALUE = 100,
        DURATION = 1,
        ICON = 79
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "光属性・庇うキラー"})
    }
    self.CHARGE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.CHARGE_MESSAGE1 or "シャドウライトニングの構え",
                             COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.CHARGE_MESSAGE2 or "ダメージを与えるほど威力減少",
                             COLOR = Color.red})
    }
    self.SUB_HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUB_HP0_MESSAGE1 or "ダメージでシャドウライトニング解除成功！",
                             COLOR = Color.red})
    }
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
            action = function (status) self:hp20(status) end,
            HP = 20,
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
        self.SUB_HP = self.subHp1
        self.damage = 0
        self.isCharging = true
        self.isBarrier = true
        self.afterSkillFLG = true
        self.count10 = self.chargeTime
        self.gameUnit:setBurstPoint(0)
        self.gameUnit:takeAnimation(0,"charge_loop",true);
        self.gameUnit:takeAnimationEffect(0,"charge_short",true);
        self:execAddBuff(self.gameUnit,self.ANTI_BAD_CONDITION_BUFF_LIST)
        self:showMessage(self.CHARGE_MESSAGE_LIST)
    end
end

function class:hp20(status)
    if status == "use3" then
        self.SUB_HP = self.subHp2
        self.damage = 0
        self.isCharging = true
        self.isBarrier = true
        self.afterSkillFLG = true
        self.count10 = self.chargeTime
        self.gameUnit:setBurstPoint(0)
        self.gameUnit:takeAnimation(0,"charge_loop",true);
        self.gameUnit:takeAnimationEffect(0,"charge_short",true);
        self:execAddBuff(self.gameUnit,self.ANTI_BAD_CONDITION_BUFF_LIST)
        self:showMessage(self.CHARGE_MESSAGE_LIST)
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
    event.unit:setAttackDelay(5);---アタックディレイ
    event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
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
    ---ここまでいつもの

    ---サブHP表示用
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = 0---サブバーのHP
    self.damage = 0---サブバー表示時のダメージ

    ---下記変更で数値を修正---
    self.chargeTime = 15---チャージ時間
    self.subHp1 = 150000---サブHP1回目
    self.subHp2 = 350000---サブHP2回目

    ---チャージ用
    self.count10 = self.chargeTime---20秒カウント
    self.count2 = 0---6秒ごとのカウント
    self.isCharging = false---チャージフラグ
    self.isBarrier = false---バリアフラグ
    self.point = 0---1回目のバフ量保存

    self.skill2FLG = -1
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---奥義中、チャージ中、ブレイク中はトリガーを発動しない(体力もトリガー以下にならない)
    if event.unit.m_breaktime == 0 and not self.afterSkillFLG then
        self:HPTriggersCheck(event.unit)
    end
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効

    self:subBarControll(event.unit,self.damage);---サブバー表示
    self:charge(event.deltaTime)---チャージ
    self:subRun(event.deltaTime)
    return 1
end

---サブHP表示
function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage)/self.SUB_HP);
    ---ゲージ0になった場合非表示
    if self.SUB_HP - damage <= 0 then
        self.subBar:setVisible(false);
        ---サブHPが0になった場合の処理
        if self.isCharging then
            self.gameUnit:takeAttack(1)
            self.gameUnit:setBurstPoint(0)
            self.isCharging = false---チャージFLGオフ
            self:showMessage(self.SUB_HP0_MESSAGE_LIST)
            self:execAddBuff(self.gameUnit,self.ANTI_BAD_CONDITION_BUFF_LIST2)
            self:execAddBuff(self.gameUnit,self.STUN_BUFF_LIST)
        end
    end
end

---チャージ中のカウント
function class:charge(deltaTime)
    if self.isCharging then
        self.count10 = self.count10 - deltaTime
        ---二秒ごとに奥義玉1つアップ
        if self.gameUnit:getBurstPoint() < 80 then
            self.count2 = self.count2 + deltaTime
            local chargeTime5 = self.chargeTime / 5
            if self.count2 > chargeTime5 then
                self.count2 = 0
                self.gameUnit:addSP(20)
            end
        end
        ---サブHPが時間内に0にならなかった場合の処理
        if self.count10 < 0 then
            ---奥義発動
            self.gameUnit:addSP(100)
            self.isRage = true
            self.isCharging = false---チャージFLGオフ
            ---バフ付与
            local restHP = self.SUB_HP - self.damage
            local point = self:calcPoint(restHP)
            self:splitBuff(point)
            ---サブHPリセット
            self.SUB_HP = 0
            self.damage = 0
        end

    end
end

---バフ付与量計算
function class:calcPoint(restHP)
    local x = restHP / self.SUB_HP * 100
    x = math.ceil(x)
    if x < 10 then
        x = x + 5
    elseif x < 50 then
        x = x + 15
    else
        x = x + 50
    end
    x = math.floor(x)
    return x
end

---バフを分割して付与
function class:splitBuff(point)
    ---一旦バフ全除去
    self:removePowerUp()
    self:removeDamageUp()
    ---バフ量を保存
    local localPoint = point + self.point
    self.point = self.point + point
    ---アイコン数を計算など
    local rest = localPoint % 20
    local times = (localPoint / 20) - (rest / 20)
    ---バフ変数作成
    local buffBox = {
        ID = -20339541,
        BUFF_ID = 17,
        VALUE = 20,
        DURATION = 99999,
        ICON = 26
    }
    local buffBox2 = {
        ID = -20339542,
        BUFF_ID = 21,
        VALUE = 20,
        DURATION = 99999,
        ICON = 139
    }
    ---必要な回数分付与
    for i = 0,times do
        ---与ダメアップ
        if i == times then
            buffBox.VALUE = rest
            if buffBox.VALUE > 0 then
                self:execAddBuff(self.gameUnit,buffBox)
            end
        else
            self:execAddBuff(self.gameUnit,buffBox)
        end
        ---被ダメアップ
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for n = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(n)
            if myTeamUnit ~= nil then
                if i == times then
                    buffBox2.VALUE = rest
                    if buffBox2.VALUE > 0 then
                        self:execAddBuff(myTeamUnit,buffBox2)
                    end
                else
                    self:execAddBuff(myTeamUnit,buffBox2)
                end
            end
        end
    end
end

---一旦バフ全除去
function class:removePowerUp()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    local count = 1
    local limit = 0
    while count > 0 do
        count = 0
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(-20339541) ~= nil then
                    myTeamUnit:getTeamUnitCondition():removeCondition(myTeamUnit:getTeamUnitCondition():findConditionWithID(-20339541))
                    count = count + 1
                end
            end
        end
        limit = limit + 1
        if limit > 100 then
            break
        end
    end
end
function class:removeDamageUp()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local count = 1
    local limit = 0
    while count > 0 do
        count = 0
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(-20339542) ~= nil then
                    myTeamUnit:getTeamUnitCondition():removeCondition(myTeamUnit:getTeamUnitCondition():findConditionWithID(-20339542))
                    count = count + 1
                end
            end
        end
        limit = limit + 1
        if limit > 100 then
            break
        end
    end
end

---runイベントの代わり
function class:subRun(deltaTime)
    if self.skill2FLG >= 0 then
        self.skill2FLG = self.skill2FLG + deltaTime
        if self.skill2FLG >= 1.5 then
            self:skill2Damage()
            self.skill2FLG = -1
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

function class:skill2Damage()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local maxHp = myTeamUnit:getCalcHPMAX()
            local halfHp = maxHp / 2
            local hp = myTeamUnit:getHP() - halfHp
            if hp < 0 then hp = 0 end
            myTeamUnit:setHP(hp)
            self:execAddBuff(myTeamUnit,self.BUFF_LIST)
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

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        self.isBarrier = false
        self:execAddBuff(self.gameUnit,self.ANTI_BAD_CONDITION_BUFF_LIST2)
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
    if not self.isCharging then
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

    if event.index == 1 and self.isRage then
        self.isRage = false
    elseif event.index == 3 and self.isFury then
        self.isFury = false
    end

    if event.index == 2 then
        self.skill2FLG = 0
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
        skillIndex = 1
    elseif self.isFury then
        skillIndex = 3
    else
        if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_SKILL.actCount,7,Color.magenta); end
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end
    unit:takeSkill(skillIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
    return 0;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.isBarrier then
        event.value = event.value * 0.05
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

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    ---チャージ中ダメージ0
    if self.isCharging then
        return 0
    end
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
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    self.skill2FLG = -1
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