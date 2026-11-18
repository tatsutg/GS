local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="32Fギアベール", version=1.3, id=2000689});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK3 = 50,ATTACK4 = 50,ATTACK5 = 50}
    },
    CHANGED = {
        { ATTACK7 = 50},
        { ATTACK6 = 50},
        { ATTACK9 = 50},
        { ATTACK7 = 50,ATTACK8 = 50,ATTACK9 = 50}
    },
    EXTRA = {
        { ATTACK1 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 }
    },
    CHANGED = {
        { SKILL2 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 0,
    ATTACK3 = 1,
    ATTACK4 = 2,
    ATTACK5 = 3,
    ATTACK6 = 4,
    ATTACK7 = 5,
    ATTACK8 = 6,
    ATTACK9 = 7,
    SKILL1 = 9,
    SKILL2 = 10,
    SKILL3 = 9,
    SKILL4 = 10,
    SKILL5 = 8
}

class.cutInSkill = {
    [3] = 1,
    [4] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        ID = 0,
        BUFF_ID = 28,---攻撃速度
        VALUE = 10,
        DURATION = 99999,
        ICON = 7
    }
    self.BUFF_LIST2 = {
        ID = 0,
        BUFF_ID = 132,---ダメージ無効化無効
        VALUE = 100,
        DURATION = 99999,
        ICON = 0
    }
    self.BUFF_LIST3 = {
        ID = 500821,
        BUFF_ID = 13,---攻撃力ダウン
        VALUE = -20,
        DURATION = 99999,
        ICON = 4,
        MAX = 10
    }
    self.BUFF_LIST4 = {
        ID = 500822,
        BUFF_ID = 21,---被ダメージアップ
        VALUE = 15,
        DURATION = 99999,
        ICON = 139,
        MAX = 10
    }
    self.BUFF_LIST5 = {
        ID = 500823,
        BUFF_ID = 126,---被回復量
        VALUE = -1000,
        DURATION = 99999,
        ICON = 162
    }
    self.BUFF_LIST6 = {
        ID = 500823,
        BUFF_ID = 0,---被回復量
        VALUE = 0,
        DURATION = 0,
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
            MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "庇うキラー・魔族からのダメージ軽減"
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "状態異常でないユニットの被回復量ダウン"
        })
    }

    self.EXTRA_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.EXTRA_MESSAGE1 or "蛇神モード:被ダメージ軽減・奥義上昇量アップ"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.EXTRA_MESSAGE2 or "一定ダメージで蛇神モード解除"
        })
    }

    self.EXTRA_END_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.EXTRA_END_MESSAGE1 or "蛇神モード解除成功！"
        })
    }

    self.CHANGE_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.CHANGE_MESSAGE1 or "来たれ…満たせ…永劫の蛇……",
            COLOR = Color.red
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.CHANGE_MESSAGE2 or "状態異常を回復"
        })
    }

    self.HP80_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP80_MESSAGE1 or "闇へと…沈め…",
            COLOR = Color.red
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP80_MESSAGE2 or "攻撃速度アップ"
        })
    }

    self.HP30_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP30_MESSAGE1 or "滅せよ…滅せよ…滅せよ…",
            COLOR = Color.red
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP30_MESSAGE2 or "与ダメージ＆攻撃速度アップ・ダメージ無効化無効"
        })
    }

    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "蛇よ…まだ…往くな……",
            COLOR = Color.red
        })
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp80(status) end,
            HP = 80,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
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

function class:hp80(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 3
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(30)
        self.gameUnit:setAttackDelay(9.5);---アタックディレイ
        self:execAddBuff(self.gameUnit,self.BUFF_LIST)
        self:showMessage(self.HP80_MESSAGE_LIST)
    end
end

function class:hp50(status)
    if status == "use3" then
        self.hpSkill = 5
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(30)
    end
end

function class:hp30(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 4
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(30)
        self.spValue = 30;---addSPの量
        self.gameUnit:setAttackDelay(8);---アタックディレイ
        self:execAddBuff(self.gameUnit,self.BUFF_LIST2)
        self:showMessage(self.HP30_MESSAGE_LIST)
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
    event.unit:setAttackDelay(10);---アタックディレイ
    event.unit:addSP(20)---戦闘開始時の奥義ゲージ量
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

    self.mode = 1

    self.timer3 = 0

    self.stunFLG = -1
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if not self.subBarMode then
        self:HPTriggersCheck(event.unit)
    end
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    self:enemyBadCondition(event.unit)
    self:subBarControll(event.unit);---サブバー表示
    if self.subBarMode and event.unit:getUnitState() ~= kUnitState_skill then
        self.timer3 = self.timer3 + event.deltaTime
        if self.timer3 > 1.5 then
            self.timer3 = 0
            event.unit:addSP(20)
        end
    end
    if self.stunFLG >= 0 then
        self.stunFLG = self.stunFLG + event.deltaTime
        if self.stunFLG >= 1.7 then
            self.stunFLG = -1
            self:stun(event.unit)
        end
    end
    return 1
end

function class:enemyBadCondition(unit)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if self:findBadCondition(myTeamUnit) then
                self:execAddBuff(myTeamUnit,self.BUFF_LIST6)
            else
                self:execAddBuff(myTeamUnit,self.BUFF_LIST5)
            end
        end
    end
end

function class:findBadCondition(unit)
    local cnt = 0;
    local badStatusList = {
        89,
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97
    }
    for k,v in pairs(badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return true;
        end
    end
    return false;
end

---サブHP表示
function class:subBarControll(unit)
    if self.subBarFirst == nil then
        self.subBarFirst = true
        self.subBar =  BattleControl:get():createSubBar();
        self.subBar:setWidth(200); ---バーの全体の長さを指定
        self.subBar:setHeight(13);---バーの幅を指定
        self.subBar:setPercent(0); ---バーの残量を0%に指定
        self.subBar:setVisible(false);
        self.SUB_HP = 0---サブバーのHP
        self.damage = 0---サブバー表示時のダメージ
        self.subBarMode = false
    end
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - self.damage)/self.SUB_HP);
    ---ゲージ0になった場合非表示
    if self.SUB_HP - self.damage <= 0 then
        self.subBar:setVisible(false);
        self:endSubBar(unit)
    end
end

function class:initSubBar(unit,percent)
    if not self.subBarMode then
        self.subBarMode = true
        self:initAttackWeight({EXTRA = 100})
        self.SUB_HP = self.gameUnit:getCalcHPMAX() * percent
        self.damage = 0---サブバー表示時のダメージ
        self:showMessage(self.EXTRA_MESSAGE_LIST)
    end
end

function class:endSubBar(unit)
    if self.subBarMode then
        self.subBarMode = false
        if self.mode == 1 then
            self:initAttackWeight({DEFAULT = 100})
        elseif self.mode == 2 then
            self:initAttackWeight({CHANGED = 100})
        end
        self.SUB_HP = 0
        self.damage = 0---サブバー表示時のダメージ
        self.gameUnit:setBurstPoint(0)
        self.gameUnit:getTeamUnitCondition():addCondition(0,89,100,5,79);
        self.timer3 = 0
        self:showMessage(self.EXTRA_END_MESSAGE_LIST)
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "rage" then return self:change(event.unit) end
    return 1;
end

function class:change(unit)
    self:initAttackWeight({CHANGED = 100})
    self:initSkillWeight({CHANGED = 100})
    self.mode = 2
    unit:setSetupAnimationName("idle2");
    self.stunFLG = 0
    self:showMessage(self.CHANGE_MESSAGE_LIST)
    return 1;
end

function class:stun(unit)
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:getTeamUnitCondition():addCondition(0,89,100,3,79);
            myTeamUnit:setPosition((x + 480 + math.random(-50,50)),(y + math.random(-50,50)))
        end
    end
    return 1
end

function class:takeIdle(event)
    if self.afterSkillFLG then
        self.gameUnit:setInvincibleTime(0)
    end
    if self.mode == 2 then
        event.unit:setNextAnimationName("idle2")
    end
    return 1;
end

function class:takeDamage(event)
    if self.mode == 2 then
        event.unit:setNextAnimationName("damage2")
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

    if event.index == 1 then
        if self.mode == 1 then
            event.unit:setNextAnimationName("idle")
            event.unit:setNextAnimationEffectName("empty")
        elseif self.mode == 2 then
            event.unit:setNextAnimationName("idle2")
            event.unit:setNextAnimationEffectName("empty")
        end
    end

    if event.index == 5 then
        event.unit:setNextAnimationName("attack5-2")
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
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

    if event.index == 1 or event.index == 3 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("1-skill1")
        self:enemyAddBuff(event.unit,self.BUFF_LIST3)
        self:initSubBar(event.unit,0.09)
        self.gameUnit:setInvincibleTime(10)
    elseif event.index == 2 or event.index == 4 then
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("1-skill2")
        self:enemyAddBuff(event.unit,self.BUFF_LIST4)
        self:initSubBar(event.unit,0.09)
        self.gameUnit:setInvincibleTime(10)
    elseif event.index == 5 then
        event.unit:setNextAnimationName("attack10")
        event.unit:setNextAnimationEffectName("1-attack10")
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

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---魔族からのダメージはtakeDamageValueで1にする
    if self:isRaceTypeX(event.enemy,8) then
        event.value = 1
    end
    self.damage = self.damage + event.value
    if self.subBarMode then
        event.value = event.value * 0.02
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
    ---魔族からのブレイクはtakeBreakeDamageValueで0にする
    if self:isRaceTypeX(event.enemy,8) then
        event.value = 0
    end
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end
    return event.value
end

function class:isRaceTypeX(unit,x)
    if unit:getRaceType() == x then
        return true;
    end
    if unit:getParentTeamUnit() ~= nil then
        if unit:getParentTeamUnit():getRaceType() == x then
            return true;
        end
    end
    return false;
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
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self:showMessage(self.DEAD_MESSAGE_LIST)
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
    local count = 1
    if buffBox.MAX ~= nil then
        local olfBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if olfBuff ~= nil then
            count = olfBuff:getNumber()
            if count < buffBox.MAX then
                count = count + 1
            end
        end
    end
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
        buff:setNumber(count);
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

function class:enemyAddBuff(unit,buffBox)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

class:publish();

return class;