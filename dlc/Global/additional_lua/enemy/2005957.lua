local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="真EX極_針目縫", version=1.3, id=2005957});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL13 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL13 = 3,
    SKILL14 = 4
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = -1,
            BUFF_ID = 1,  ---HP固定値
            VALUE = 0,
            DURATION = 99999,
            ICON = 2      ---HPDown
        },
        [2] = {
            ID = -2,
            BUFF_ID = 2,  ---HP割合
            VALUE = 0,
            DURATION = 99999,
            ICON = 2
        },
        [3] = {
            ID = -30,
            BUFF_ID = 12,  ---攻撃力固定値
            VALUE = 0,
            DURATION = 99999,
            ICON = 4       ---攻撃力Down
        },
        [4] = {
            ID = -40,
            BUFF_ID = 13,  ---攻撃力割合
            VALUE = 0,
            DURATION = 99999,
            ICON = 4
        },
        [5] = {
            ID = -500,
            BUFF_ID = 14,  ---防御力固定値
            VALUE = 0,
            DURATION = 99999,
            ICON = 6       ---防御力down
        },
        [6] = {
            ID = -600,
            BUFF_ID = 15,  ---防御力割合
            VALUE = 0,
            DURATION = 99999,
            ICON = 6
        },
        [7] = {
            ID = 20059511,
            BUFF_ID = 31,  ---回避率
            VALUE = 70,
            DURATION = 2.7,
            ICON = 16
        },
        [8] = {
            ID = 20059511,
            BUFF_ID = 0,  ---回避率
            VALUE = 0,
            DURATION = 99999,
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
            MESSAGE = self.TEXT.START_MESSAGE1 or "キミは面白そうなことしてるね。ボクとも遊んでよ。",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性",
            COLOR = Color.yellow
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "装備ダメージ軽減・人族キラー",
            COLOR = Color.yellow
        })
    }

    self.HP70_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP70_MESSAGE1 or "キミって意外とテクニシャンだね",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP70_MESSAGE2 or "ステータスアップ効果を反転",
            COLOR = Color.yellow
        })
    }

    self.HP40_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE1 or "ボクの分身が相手してあげるよ",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE2 or "ステータスアップ効果を反転",
            COLOR = Color.yellow
        })
    }

    self.HP10_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP10_MESSAGE1 or "裸のキミがみたいなー",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP10_MESSAGE2 or "ステータスアップ効果を反転",
            COLOR = Color.yellow
        })
    }

    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "ムカツクムカツクムカツクー！",
            COLOR = Color.magenta
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
            used = false,
            R = 0,
            G = 255,
            B = 255
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false,
            R = 0,
            G = 255,
            B = 255
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp10(status) end,
            HP = 10,
            used = false
        }
    }

    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        --[[
            if self.TRIGGERS[index].R ~= nil then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],self.TRIGGERS[index].R,self.TRIGGERS[index].G,self.TRIGGERS[index].B)
                if self.TRIGGERS[index].HP == 80 then
                    self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_gray_1.png","battle_marker_hp_marker_gray_2.png","unit/animation/battle_marker_gray.plist")
                elseif self.TRIGGERS[index].HP == 50 then
                    self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist")
                end
            end
        --]]
        end
    end
end

function class:hp70(status)
    if status == "use3" then
        self.isRage = true
        self.saveSP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:showMessage(self.HP70_MESSAGE_LIST)
        self.gameUnit:setInvincibleTime(7)
    end
end

function class:hp40(status)
    if status == "use3" then
        self.isRage = true
        self.saveSP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:showMessage(self.HP40_MESSAGE_LIST)
        self.gameUnit:setInvincibleTime(7)
    end
end

function class:hp10(status)
    if status == "use3" then
        self.isRage = true
        self.saveSP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:showMessage(self.HP10_MESSAGE_LIST)
        self.gameUnit:setInvincibleTime(7)
        self.gameUnit:setAttackDelay(3)
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
    self.bugCheckFLG = false
    self.saveSP = 0

    self.FindBuffIDTable = {
        [1] = 1,   ---HP固定
        [2] = 2,   ---HP割合
        [3] = 12,  ---AT固定
        [4] = 13,  ---AT割合
        [5] = 14,  ---DF固定
        [6] = 15   ---DF割合
    }

    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(10,1)---ヒットストップ無効or時止め無効
    self:HPTriggersCheck(event.unit)
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "skill3" then self:skill3Orbit(event.unit) end
    if event.spineEvent == "skill1" then self:skill1(event.unit) end
    return 1;
end

function class:skill3Orbit(unit)
    local orbit = unit:addOrbitSystem("Center_BG",0);
    orbit:setDamageRateOffset(0.5)
    orbit:setBreakRate(0.5)
    return 1;
end

function class:skill1(unit)
    self:execAddBuff(unit,self.BUFF_BOX_LIST[7])
    return 1;
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
    ---初期化
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[8])
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)

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
        event.unit:setActiveSkill(2)
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        event.unit:addSP(self.saveSP)
        self.saveSP = 0
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
        if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
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
    ---初期化
    self:execAddBuff(event.unit,self.BUFF_BOX_LIST[8])
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)

    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if event.index == 14 and not self.cutInFLG and self.isRage then
        self.isRage = false
        self.cutInFLG = true;
        event.unit:takeSkillWithCutin(event.index,1);
        self:BuffReverseStatus()
        return 0;
    end

    if event.index == 13 then
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("skill2")
    elseif event.index == 14 then
        event.unit:setDamageRateOffset(0.5)
        event.unit:setBreakRate(0.5)
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("skill3")
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

    if self.isRage then
        skillIndex = 14
    else
        if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_SKILL.actCount,7,Color.magenta); end
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end


------------------------------
---ステータスアップ反転---
function class:BuffReverseStatus()
    local SumVal = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for l = 1,#self.FindBuffIDTable do
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                local condition = myTeamUnit:getTeamUnitCondition():findConditionWithType(self.FindBuffIDTable[l])
                if condition ~= nil then
                    SumVal = SumVal + self:checkCondition(myTeamUnit,self.FindBuffIDTable[l])
                end
            end

            if SumVal ~= 0 then
                self.BUFF_BOX_LIST[l].VALUE = - SumVal
                self:debuff(i,l)
                SumVal = 0
            end
        end
    end
end

function class:checkCondition(unit,condType)
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize()
    local condValue = 0
    if conditionSize == 0 then return 0 end
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            if cond:getValue() > 0 and not cond:getIsPassive() then
                if cond:getConditionTypeAsInt() == condType then
                    condValue = condValue + cond:getValue()
                    cond:setValue(0)
                    cond:setThumbnailID(0)
                    cond:setTime(0)
                end
            end
        end
    end
    return condValue
end

function class:debuff(unitIndex,buffIndex)
    for i = 0,7 do
        local unit = megast.Battle:getInstance():getTeam(not self.gameUnit:getisPlayer()):getTeamUnit(i);
        if unit ~= nil and unitIndex == i then
            self:execAddBuff(unit,self.BUFF_BOX_LIST[buffIndex])
        end
    end
end
------------------------------

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    event.value = self:adjustHpFlg(event.unit,event.value)
    local type = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillType
    if type == 3 or type == 6 then
        return event.value * 0.2
    end
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

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end

    local type = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillType
    if type == 3 or type == 6 then
        return event.value * 0.1
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