local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超神級_炎怪鳥（熾紅フロガスピサ）", version=1.3, id=2040701});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK4 = 50, ATTACK5 = 50},
        { ATTACK5 = 50, ATTACK6 = 50},
        { ATTACK4 = 50, ATTACK6 = 50}
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
    ATTACK6 = 6,
    SKILL1 = 7,
    SKILL2 = 8,
    SKILL3 = 9
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.SUMMON_BUFF_LIST = {
        ID = 204070100,   --召喚フラグ用バフ
        BUFF_ID = 0,
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
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性",
            COLOR = Color.yellow
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "ダメージ無効化無効",
            COLOR = Color.yellow
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "グロヴォーグとサイクロプスの数に応じてダメージ・回避率アップ",
            COLOR = Color.yellow
        })
    }
    self.HP70_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP70_MESSAGE1 or "奥義ゲージ上昇量アップ",
            COLOR = Color.yellow
        })
    }
    self.HP40_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE1 or "奥義ゲージ上昇量アップ",
            COLOR = Color.yellow
        })
    }
    self.HP20_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP20_MESSAGE1 or "物理耐性アップ",
            COLOR = Color.yellow
        })
    }
    self.SUMMON_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "グロヴォーグが加勢した！毒で被ダメージアップ",
            COLOR = Color.red
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.SUMMON_MESSAGE2 or "サイクロプスが加勢した！病気で被ダメージアップ",
            COLOR = Color.green
        })
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp70(status) end,
            HP = 70,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false
        },
        [3] = {
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

function class:hp70(status)
    if self.hpTriggerFlg1 then
        if status == "use3" then
            self.stateName = "FURY"
            self.isFury = true
            self.hpFLG = true
            self.burstPoint = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
            self.gameUnit:setInvincibleTime(12)
            self:allRefresh(self.gameUnit)
            self.spValue = 40;---addSPの量
            self:hpEnemySummon(1)
            self:showMessage(self.HP70_MESSAGE_LIST)
        end
    end
end

function class:hp40(status)
    if self.hpTriggerFlg2 then
        if status == "use3" then
            self.stateName = "FURY"
            self.isFury = true
            self.hpFLG = true
            self.burstPoint = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
            self.gameUnit:setInvincibleTime(12)
            self:allRefresh(self.gameUnit)
            self.spValue = 50;---addSPの量
            self.gameUnit:setAttackDelay(6);---アタックディレイ
            self:hpEnemySummon(2)
            self:showMessage(self.HP40_MESSAGE_LIST)
        end
    end
end

function class:hp20(status)
    if self.hpTriggerFlg3 then
        if status == "use3" then
            self.stateName = "FURY"
            self.isFury = true
            self.hpFLG = true
            self.hp20Flg = true
            self.burstPoint = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
            self.gameUnit:setInvincibleTime(12)
            self:allRefresh(self.gameUnit)
            self.gameUnit:setAttackDelay(5);---アタックディレイ
            self:hpEnemySummon(3)
            self:showMessage(self.HP20_MESSAGE_LIST)
        end
    end
end

function class:hpEnemySummon(num)
    for i = 1,num do
        self:findFriend()
        if self.friendCount ~= 6 then
            self:enemySummon(1)
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
    self.spValue = 30;---addSPの量
    event.unit:setAttackDelay(7);---アタックディレイ
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

    self.hpFLG = false
    self.burstPoint = 0
    self.hp20Flg = false
    self.friendCount = 0
    self.skillFlg = false
    self.startFlg = true

    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.startFlg then self:nowHPCalc(event) end
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(10,1)---ヒットストップ無効or時止め無効
    self:findFriend()
    self:friendCountAddBuff(event.unit,self.friendCount)
    return 1
end

function class:nowHPCalc(event)   --継戦クエストHPトリガー対策
    self.hpTriggerFlg1 = true
    self.hpTriggerFlg2 = true
    self.hpTriggerFlg3 = true
    local nowHP = event.unit:getHP()
    local HP70 = event.unit:getCalcHPMAX() * 0.7 ---最大体力の70%
    local HP40 = event.unit:getCalcHPMAX() * 0.4 ---最大体力の40%
    local HP20 = event.unit:getCalcHPMAX() * 0.2 ---最大体力の20%

    if nowHP < HP70 then
        self.hpTriggerFlg1 = false
        self.spValue = 40;---addSPの量
    end

    if nowHP < HP40 then
        self.hpTriggerFlg2 = false
        self.spValue = 50;---addSPの量
        self.gameUnit:setAttackDelay(6);---アタックディレイ
    end

    if nowHP < HP20 then
        self.hpTriggerFlg3 = false
        self.hp20Flg = true
        self.gameUnit:setAttackDelay(5);---アタックディレイ
    end
    self.startFlg = false
    return 1
end

function class:findFriend()   --雑魚の監視
    self.friendCount = 0
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getUnitID() == 100213111 then   --グロヴォーグの数
                self.friendCount = self.friendCount + 1
            elseif myTeamUnit:getUnitID() == 100233311 then   --サイクロプスの数
                self.friendCount = self.friendCount + 1
            end
        end
    end
end

function class:friendCountAddBuff(unit,friendCount)   --与ダメージUPと回避率UPの計算をする
    self:buffRefresh(unit)
    if friendCount ~= 0 then
        self:addDamageBuff(unit,friendCount)
        self:addEvasionBuff(unit,friendCount)
    end
end

function class:buffRefresh(unit)
    local badStatusIDs = {204070110,204070120};
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

function class:addDamageBuff(unit,friendCount)
    local valueCalc = 5 * friendCount^2
    local DAMAGE_BUFF_LIST = {
        ID = 204070110,
        BUFF_ID = 17,   --与ダメージUP
        VALUE = valueCalc,
        DURATION = 999999,
        ICON = 26,
        COUNT = friendCount,
        MAX = 10
    }
    self:execAddBuff(unit,DAMAGE_BUFF_LIST)
end

function class:addEvasionBuff(unit,friendCount)
    --local calc = (friendCount * 20) + (math.log(1 + friendCount, 10) * 100)
    local calc = (friendCount * 20) + ((math.log(friendCount + 1) / math.log(10)) * 100)
    local valueCalc = math.floor(calc)
    local EVASION_BUFF_LIST = {
        ID = 204070120,
        BUFF_ID = 31,   --回避率UP
        VALUE = valueCalc,
        DURATION = 999999,
        ICON = 16,
        COUNT = friendCount,
        MAX = 10
    }
    self:execAddBuff(unit,EVASION_BUFF_LIST)
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

    self.skillFlg = true

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
    self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
    end

    self:attackActiveSkillSetter(event.unit,event.index);
    if self.hpFLG then
        self.hpFLG = false
        event.unit:addSP(self.burstPoint)---奥義ゲージ引き継ぎ
        self.burstPoint = 0
    end

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

    if (event.index == 1 or event.index == 2) and self.skillFlg then
        self.skillFlg = false
        self:findFriend()
        self:friendObservation(self.friendCount)
    end

    if event.index == 3 and self.isFury then
        self.isFury = false
        event.unit:takeSkillWithCutin(event.index,1);
        return 0;
    end

    if event.index == 3 then
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("1-skill3") ---EFのアニメーション名に気をつける
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

    if self.isRage then
        skillIndex = 2
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

function class:friendObservation(friendCount)   --雑魚の監視召喚
    local rand = math.random(0,9)
    if friendCount == 6 then
        --何もしない
    elseif friendCount == 0 then   --0体の場合は20%の確率で1体を召喚、80%の確率で2体を召喚。
        if rand <= 1 then
            self:enemySummon(1)
        else
            self:enemySummon(2)
        end

    elseif friendCount == 1 then   --1体の場合は50%の確率で1体を召喚、50%の確率で2体を召喚。
        if rand <= 4 then
            self:enemySummon(1)
        else
            self:enemySummon(2)
        end

    elseif friendCount >= 2 then   --2体以上の場合は、100%の確率で1体を召喚。
        self:enemySummon(1)
    end
end

---召喚系
function class:enemySummon(Num)   --召喚回数
    for i = 1,Num do
        local rand = math.random(1,2)
        if rand == 1 then
            self:MultipleSummon(self.gameUnit,2040702,1)   --グロヴォーグ召喚
            self:showMessage(self.SUMMON_MESSAGE_LIST,1)
        else
            self:MultipleSummon(self.gameUnit,2040703,1)   --サイクロプス召喚
            self:showMessage(self.SUMMON_MESSAGE_LIST,2)
        end
    end
    self:friendAddBuff()
end

function class:friendAddBuff()   --召喚されたやつにバフをかける
    local myTeam = megast.Battle:getInstance():getTeam(false);
    ---バフがあるか確認
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(204070100);
            if cond == nil then
                if myTeamUnit:getUnitID() == 100213111 then   --グロヴォーグ
                    self:execAddBuff(myTeamUnit,self.SUMMON_BUFF_LIST)
                elseif myTeamUnit:getUnitID() == 100233311 then   --サイクロプス
                    self:execAddBuff(myTeamUnit,self.SUMMON_BUFF_LIST)
                end
            end
        end
    end
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.hp20Flg then   --物理ダメージ補正
        local attribute = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 1 then
            event.value = event.value * 0.2
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
            if myTeamUnit:getUnitID() == 100213111 then   --グロヴォーグ
                myTeamUnit:setHP(0)
            elseif myTeamUnit:getUnitID() == 100233311 then   --サイクロプス
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

---全状態異常除去---
function class:allRefresh(unit)
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