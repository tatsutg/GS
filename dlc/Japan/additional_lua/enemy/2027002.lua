local Bootstrap, Color, Random, Utility, Vector2 = summoner.import("Bootstrap", "Color", "Random", "Utility", "Vector2")
local class = Bootstrap.createEnemyClass({label="ラグシェルムX／初級", version=1.9, id=2027002})
class:inheritFromUnit("unitBossBase")

-- 使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK5 = 100 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK4 = 100 },
        { ATTACK1 = 50, ATTACK5 = 50 },
    }
}

-- 使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL3 = 100 },
        { SKILL1 = 100 },
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 3,
    ATTACK7 = 3,
    SKILL1  = 6,
    SKILL2  = 7,
    SKILL3  = 8,
    SKILL4  = 8,
}

class.STATE_SKILL = {}

--------[[ create ]]--------
function class:createTable()
    self.glabEffect = {
        orbitSystem = nil,
        position = nil,
    }
end

--------[[ バフ ]]--------
function class:setBuffBoxList()
    self.HP20_BUFF_LIST = {}
end

----------[[ メッセージ ]]----------
function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.START_MESSAGE1 or "最大HPが高いユニットへのダメージUP",
            COLOR = Color.yellow,
            DURATION = 7,
        },
        {
            MESSAGE = self.TEXT.START_MESSAGE2 or "闇属性耐性・反射耐性",
            COLOR = Color.yellow,
            DURATION = 7,
        }
    }
    self.GRAB_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.GRAB_MESSAGE1 or "祈れ…懺悔ノ時間ダ",
            COLOR = Color.magenta,
            DURATION = 7,
        },
        {
            MESSAGE = self.TEXT.GRAB_MESSAGE2 or "HPの高い者をホールド",
            COLOR = Color.yellow,
            DURATION = 7,
        },
        {
            MESSAGE = self.TEXT.GRAB_MESSAGE3 or "一定ダメージを与えると解除",
            COLOR = Color.yellow,
            DURATION = 7,
        }
    }
    self.GRAB_BREAK_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.GRAB_BREAK_MESSAGE1 or "何ぃいィイイ！？",
            COLOR = Color.magenta,
            DURATION = 7,
        }
    }
    self.OGI_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.OGI_MESSAGE1 or "消え失セロォォオオオ！！",
            COLOR = Color.magenta,
            DURATION = 7,
        }
    }
    self.DEAD_MESSAGE_LIST = {
        {
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "消えヌ…我ガ怒りハ…決し…テ……",
            COLOR = Color.magenta,
            DURATION = 7,
        }
    }
end

function class:subBars()
    self.subBar = BattleControl:get():createSubBar()
    self.subBar:setWidth(200) -- バーの全体の長さを指定
    self.subBar:setHeight(13)
    self.subBar:setPercent(0) -- バーの残量を0%に指定
    self.subBar:setVisible(false)
    self.subBar:setPositionX(0)
    self.subBar:setPositionY(150)
end

--------[[ 特殊行動 ]]--------
function class:setTriggersList()
    self.TRIGGERS = {}
end

-- status = use + receive番号
function class:hp20(status)
end

function class:tryGlab(unit)
    if not self.isDPSCheck then
        self.spCount = 1
        self.isSpCount = false
        self:glabEnd(unit)
        unit:takeDamage()
        return
    end
    local index = self:selectTarget()
    self:executeGlab(unit, index)
end

function class:selectTarget()
    local index = 0
    local hp = 0
    for i =  0,3 do
        local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if target ~= nil and hp < target:getHP() then
            hp = target:getHP()
            index = i
        end
    end
    return index
end

function class:executeGlab(unit,index)
    self.glabTarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(index)
    if self.glabTarget == nil then
        return
    end

    unit:getTeamUnitCondition():addCondition(-11, 113, 500, 2000, 0)
    self.isGlab = true
    self.isGlabBefore = true
    self.glabEffect.orbitSystem = unit:addOrbitSystem("lock-on")
    self.glabEffect.orbitSystem:takeAnimation(0, "lock-on", true)
    self.glabEffect.position = Vector2:new(self.glabTarget:getAnimationPositionX(),self.glabTarget:getAnimationPositionY())
    self.glabEffect.orbitSystem:setPosition(self.glabEffect.position.x,self.glabEffect.position.y)
    self.glabTarget:getTeamUnitCondition():addCondition(-10, 89, 1, 16, 0)
end

function class:glabEnd(unit)
    if not self.isGlab then
        return
    end
    if self.glabTarget ~= nil then
        self:removeCondition(self.glabTarget, -10)
        self.glabTarget = nil
    end
    self:removeCondition(unit, -11)
    self.dpsCounter = 0
    self.isGlab = false
    self.isGlabBefore = false
    if self.glabEffect ~= nil then
        self.glabEffect.orbitSystem:takeAnimation(0, "none", false)
        self.glabEffect.orbitSystem = nil
    end

    self.spCount = 1
    self.isSpCount = false
end

function class:glabControll(unit,deltaTime)
    if self.glabTarget ~= nil then
        local x = 150 + unit:getPositionX()
        local y = 464 + unit:getPositionY()
        local distance = Vector2.subtracts(Vector2:new(x, y), self.glabEffect.position)

        if self.SPEED * deltaTime >= math.abs(distance.magnitude) then
            self.glabEffect.position = self.glabEffect.position + distance
        else
            self.glabEffect.position = self.glabEffect.position + distance:normalize()*self.SPEED*deltaTime
        end

        self.glabEffect.orbitSystem:setPosition(self.glabEffect.position.x, self.glabEffect.position.y)
        self.glabTarget:setPosition(self.glabEffect.position.x - self.glabTarget:getSkeleton():getBoneWorldPositionX("MAIN"),self.glabTarget:getPositionY())
        self.glabTarget:getSkeleton():setPosition(0, self.glabEffect.position.y - self.glabTarget:getPositionY() - self.glabTarget:getSkeleton():getBoneWorldPositionY("MAIN"))

    end
end

function class:setSP0(unit)
    unit:setBurstPoint(0)
    self.isDPSCheck  = true
    self.dpsStartHP = unit:getHP()
    self.subBar:setVisible(true)

    self.damageParSecond = self:setDamageParSecond(unit, self.parCount)
    self.parCount = self.parCount + 1
    self.spCount = 1
    self.isSpCount = true
    self:showMessage(self.GRAB_MESSAGE_LIST)
end

function class:removeCondition(unit,buffID)
    local buff = unit:getTeamUnitCondition():findConditionWithID(buffID)
    if buff ~= nil then
        unit:getTeamUnitCondition():removeCondition(buff)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:initializeParameters(event.unit)
    self:initializeUnit(event.unit)
    return 1
end

function class:initializeParameters(unit)
    self.fromHost = false
    self.gameUnit = nil
    self.spValue = 20
    self.attackCheckFlg = false
    self.skillCheckFlg = false
    self.skillCheckFlg2 = false
    self.gameUnit = unit

    self:createTable()
    self:setBuffBoxList()
    self:setMessageBoxList()
    self:subBars()
    self.hitStop = 1
    self.isGlab = false
    self.isDPSCheck = false
    self.glabTarget = nil
    self.dpsStartHP = 0
    self.dpsCounter = 0

    self.SPEED = 300
    self.hateTargetRate = 1.4
    self.startSp = 40
    self.attackDelay = 4
    self:initAttackWeight({DEFAULT=100})
    self:initSkillWeight({DEFAULT=100})

    self.parCount = 1
    self.damageParSecond = self:setDamageParSecond(unit, self.parCount)
    self.spCount = 1
    self.isGlabBefore = false

    self:setTriggersList()
    self.HP_TRIGGERS = {}
    for index, trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
        end
    end
end

function class:initializeUnit(unit)
    unit:setSPGainValue(0)
    unit:setSkillInvocationWeight(0)
    unit:addSP(self.startSp)
    unit:setAttackDelay(self.attackDelay)
end

function class:setDamageParSecond(unit,count)
    local needHP = 0

    if     count == 1 then needHP = unit:getCalcHPMAX() * 0.05
    elseif count == 2 then needHP = unit:getCalcHPMAX() * 0.08
    elseif count == 3 then needHP = unit:getCalcHPMAX() * 0.12
    elseif count == 4 then needHP = unit:getCalcHPMAX() * 0.15
                      else needHP = unit:getCalcHPMAX() * 0.20 end
    return needHP
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:showMessage(self.START_MESSAGE_LIST)
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    -- 気絶解除
    for i = 0 , 3 do
        local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if target ~= nil then
            self:removeCondition(target,-10)
        end
    end

    self:showMessage(self.DEAD_MESSAGE_LIST)
    self.subBar:setVisible(false)
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP"   then self:addSP(event.unit) end
    if event.spineEvent == "tryGlab" then self:tryGlab(event.unit) end
    if event.spineEvent == "glabEnd" then self:glabEnd(event.unit) end
    if event.spineEvent == "setSP0"  then self:setSP0(event.unit) end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100, self.hitStop)
    self:HPTriggersCheck(event.unit)

    if self.isGlab then
        self:glabControll(event.unit, event.deltaTime)
    end

    if self.isDPSCheck then
        self:dpsChecker(event.unit)
    end
    if self.isGlabBefore and (self.glabTarget == nil or self.glabTarget:getHP() <= 0) then
        self:glabEnd(event.unit)
        self.isRage = true
        event.unit:takeAttack(6)
    end

    return 1
end

function class:dpsChecker(unit)
    self.dpsCounter = self.dpsStartHP - unit:getHP()
    if self.dpsCounter >= self.damageParSecond then
        self.dpsCounter = 0
        self:showMessage(self.GRAB_BREAK_MESSAGE_LIST)
        if self.isGlab then
            unit:setBurstPoint(0)
            unit:getTeamUnitCondition():addCondition(-10, 89, 1, 2, 0)
            self:glabEnd(unit)
        end
        if self.isDPSCheck then
            self.isDPSCheck = false
            self.dpsCounter = 0
            self.subBar:setVisible(false)
        end
    end

    self.subBar:setPositionX(unit:getPositionX())
    self.subBar:setPositionY(unit:getPositionY() + 250)
    self.subBar:setPercent(100*(self.damageParSecond - self.dpsCounter)/self.damageParSecond)

end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    if self.isGlab then
        event.unit:setBurstPoint(0)
        self:glabEnd(event.unit)
    end
    if self.isDPSCheck then
        self.isDPSCheck = false
        self.dpsCounter = 0
        self.subBar:setVisible(false)
    end

    return 1
end
---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.isDPSCheck then
        self.dpsCounter = self.dpsStartHP - event.unit:getHP()
        if event.value > event.unit:getHP() then
            self.dpsCounter = self.damageParSecond + 1
            self.subBar:setVisible(false)
        end
        if self.dpsCounter >= self.damageParSecond then
            self:showMessage(self.GRAB_BREAK_MESSAGE_LIST)
            if self.isGlab then
                event.unit:setBurstPoint(0)
                event.unit:getTeamUnitCondition():addCondition(-10, 89, 1, 2, 0)
                self:glabEnd(event.unit)
            end
            self.isDPSCheck = false
            self.dpsCounter = 0
            self.subBar:setVisible(false)
        end
    end
    return event.value
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    return event.value * self:multiDamage(event.enemy)
end

function class:multiDamage(unit)
    return unit:getCalcHPMAX() < 8000 and 1 or ((unit:getCalcHPMAX() - 4000)/4000)^2.5
end

---------------------------------------------------------------------------------
-- executeAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    if not self.isGlab then
        if self.glabTarget ~= nil then
            self:removeCondition(self.glabTarget, -10)
            self.glabTarget = nil
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true
        return self:attackReroll(event.unit)
    end

    self.attackCheckFlg = false
    self.fromHost = false
    self:attackActiveSkillSetter(event.unit, event.index)
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()

    if self.isRage then
        self.isRage = false
        attackIndex = 6
        self.gameUnit:setAttackDelay(self.attackDelay)
    else
        self:movePatternState(self.ATTACK_SET_LIST, self.STATE_ATTACK)
    end

    unit:takeAttack(attackIndex)
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 1, attackIndex)
    return 0
end

function class:addSP(unit)
    if self.isSpCount then
        if     self.spCount >= 1 and self.spCount <= 4 then unit:addSP(20)
        elseif self.spCount == 5 then unit:addSP(40)
        elseif self.spCount == 6 then unit:addSP(60)
        elseif self.spCount == 7 then unit:addSP(80)
        else   unit:addSP(100)
        end
        self.spCount = self.spCount + 1
    else
        unit:addSP(self.spValue)
    end

    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)

    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true
        return self:skillReroll(event.unit)
    end
    self.isDPSCheck = false
    self.subBar:setVisible(false)

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle()
        return 0
    end

    self.skillCheckFlg = false
    self.fromHost = false

    if event.index == 3 then
        event.unit:setBurstPoint(0)
        self.isRage = true
        self.gameUnit:setAttackDelay(0)
        return 0
    end
    if event.index == 1 then
        self:showMessage(self.OGI_MESSAGE_LIST)
    end
    self:skillActiveSkillSetter(event.unit, event.index)
    -- 【MEGA_D-9761】ボスの技の予告に、attackDamageValue の倍率（相手の最大 HP が 8000 以上なら ((最大 HP − 4000) ÷ 4000) ^ 2.5）を入れる（表示専用。予測のたびに今の値で出す。古いアプリには無いので確かめてから呼ぶ）
    if event.unit.announceSkillRateBy then event.unit:announceSkillRateBy(1, 8000, 4000, 4000, 2.5) end
    return 1
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()



    if self.isGlab then
        self.isGlabBefore = false
        skillIndex = 2
    else
        self:movePatternState(self.SKILL_SET_LIST, self.STATE_SKILL)
    end

    unit:takeSkill(skillIndex)
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 2, skillIndex)
    return 0
end

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return
    end

    local hpRate = Utility.getUnitHealthRate(unit) * 100

    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            self:execTrigger(index)
        end
    end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index, receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3

    local action = "use" .. receiveNumber

    self.TRIGGERS[index].action(action)
    self.TRIGGERS[index].used = true

    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID, receiveNumber, index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost()
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList, index)
    if index == nil then
        self:showMessageAll(messageBoxList)
        return
    end
    self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
    for i,messageBox in pairs(messageBoxList) do
        self:execShowMessage(messageBox)
    end
end

function class:showMessageRange(messageBoxList, start, finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i])
    end
end

function class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        Utility.messageByPlayer(messageBox.MESSAGE, messageBox.DURATION, messageBox.COLOR)
    else
        Utility.messageByEnemy(messageBox.MESSAGE, messageBox.DURATION, messageBox.COLOR)
    end
end

--===================================================================================================================
-- バフ関係
--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit, buffBoxList, index)
    if index == nil then
        self:addBuffAll(unit, buffBoxList)
        return
    end
    self:execAddBuff(unit, buffBoxList[index])
end

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit, buffBoxList, start, finish)
    for i = start, finish do
        self:execAddBuff(unit, buffBoxList[i])
    end
end

function class:addBuffAll(unit, buffBoxList)
    for i,buffBox in pairs(buffBoxList) do
        self:execAddBuff(unit,buffBox)
    end
end

-- バフ処理実行
function class:execAddBuff(unit, buffBox)
    local buff  = nil
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT)
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON)
    end
    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT)
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1)
    end

    if buffBox.COUNT ~= nil then
        if buffBox.COUNT < buffBox.COUNT_MAX then
            buff:setNumber(buffBox.COUNT)
            megast.Battle:getInstance():updateConditionView()
            buffBox.COUNT = buffBox.COUNT + 1
            buffBox.VALUE = self.ougiBuffValue * buffBox.COUNT
        else
            buff:setNumber(10)
            megast.Battle:getInstance():updateConditionView()
        end
    end
end


function class:movePatternState(SET_LIST, stateBox)
    stateBox.actCount = stateBox.actCount + 1
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1
        stateBox.setCount = stateBox.setCount + 1
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1
        end
        stateBox.setChar = Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount])
    end
end

class.STATE_ATTACK = {}
function class:initAttackWeight(...)
    --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
    local attackList = {...}
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

function class:getAttackIndex()
    local attackStr = Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount])
    local attackIndex = string.gsub(attackStr, "ATTACK", "")
    return tonumber(attackIndex)
end

function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
    local skillStr = Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount])
    local skillIndex = string.gsub(skillStr, "SKILL", "")
    return tonumber(skillIndex)
end

function class:initState(weightList)
    local state = {}
    state.SET_WEIGHT = weightList
    state.actCount = 1
    state.setCount = 1
    state.setChar = Random.sampleWeighted(state.SET_WEIGHT[state.setCount])
    return state
end

class:publish()
return class
