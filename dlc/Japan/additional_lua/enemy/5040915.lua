--@additionalItem,108531502
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒クエスト4／被験体γ－２", version=1.3, id=5040915});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50},
        { ATTACK4 = 50},
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50},
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50}
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
    ATTACK4 = 5,
    ATTACK6 = 4,
    SKILL1 = 7,
    SKILL2 = 8,
    SKILL3 = 6,
    SKILL4 = 8
}

class.cutInSkill = {
    [2] = 1,
    [4] = 1
}

--------[[バフ]]--------
-- 掴み時に自身にかかるバフ内容
class.GLAB_SELF_BUFF_ARGS = {
    {
        ID = -11,
        BUFF_ID = 113,
        VALUE = 500,
        DURATION = 2,
        ICON = 0
    }
}

-- 掴み時に対象にかかるバフ内容
class.GLAB_TARGET_BUFF_ARGS = {
    {
        ID = -10,
        BUFF_ID = 89,
        VALUE = 1,
        DURATION = 14,
        ICON = 0
    }
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end ---オーラ
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
            MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "HP自然回復キラー"
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "毒の数が多いユニットからの被ダメージアップ"
        }),
        [4] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE4 or "ジェロノス：クリティカルダメージ無効"
        }),
        [5] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE5 or "ブルースケルトン：毒ダメージ以外無効"
        })
    }

    self.HP30_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP30_MESSAGE1 or "攻撃速度・奥義上昇量アップ"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP30_MESSAGE2 or "毒の数×2000の固定ダメージ",
            COLOR = Color.red
        })
    }

    self.SUMMON1_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SUMMON1_MESSAGE1 or "ジェロノスが加勢した",
            COLOR = Color.cyan
        })
    }

    self.SUMMON2_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SUMMON2_MESSAGE1 or "ブルースケルトンが加勢した",
            COLOR = Color.cyan
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
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
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
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 2
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(7)
    end
end

function class:hp30(status)
    if status == "use3" then
        self.stateName = "FURY"
        self.hpSkill = 3
        self.spValue = 40;---addSPの量
        self.gameUnit:setAttackDelay(7);---アタックディレイ
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(7)
        self.gameUnit:takeItemSkill(0) --吹雪
        self.item:setCoolTimer(0)
        self:enemyDamage(self.gameUnit)
        self:showMessage(self.HP30_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
    end
end

function class:hp0(status)
    if status == "use3" then
        self.gameUnit:setInvincibleTime(30)
        self.hpSkill = 4
        self.gameUnit:addSP(100)
    end
end

function class:enemyDamage(unit)
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
            local hp = myTeamUnit:getHP() - (2000 * self:countPoisonCondition(myTeamUnit))
            if hp < 0 then hp = 0 end
            myTeamUnit:setHP(hp)
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
    event.unit:setAttackDelay(10);---アタックディレイ
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

    self.itemId = 108531502
    self.item = event.unit:setItemSkill(0,self.itemId)

    self.damageTable = {
        [1] = 0.03,
        [2] = 0.1,
        [3] = 0.3,
        [4] = 0.5,
        [5] = 0.7,
        [6] = 0.9
    }

    self.saveBP = 0

    self.lastSkillFLG = false

    self.skill1Count = 0
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    self:updateGlab(event.unit)
    ---死亡時処理
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
            event.unit:getTeam():deadUnit(event.unit:getIndex());
            megast.Battle:getInstance():waveEnd(true);
        end
        if self.TRIGGERS[3].used then
            if self.deadCount == nil then
                self.deadCount = 0
            end
            self.deadCount = self.deadCount + event.deltaTime
            if self.deadCount >= 15 then
                event.unit:getTeam():deadUnit(event.unit:getIndex());
                megast.Battle:getInstance():waveEnd(true);
            end
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "tryGlab" then return self:tryGlab(event.unit); end
    if event.spineEvent == "glabEnd" then return self:glabEnd(event.unit); end
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end
    return 1;
end

function class:tryGlab(unit)
    if not self:getIsHost() then
        return 1;
    end

    local targetIndex = self:checkTarget(unit);

    if targetIndex ~= nil then
        self:execGlab(unit,targetIndex);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,targetIndex);
    end
    return 1;
end

function class:receive4(args)
    self:execGlab(self.gameUnit,args.arg);
    return 1;
end

function class:checkTarget(unit)
    local index = 0
    local poisonCount = 0
    for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if localUnit ~= nil then
            if self:countPoisonCondition(localUnit) > poisonCount then
                index = i
                poisonCount = self:countPoisonCondition(localUnit)
            end
        end
    end
    --summoner.Utility.messageByEnemy(poisonCount)
    return index
end

function class:execGlab(unit,targetIndex)
    local target = self:getPlayerUnit(targetIndex);
    if target == nil then
        return;
    end

    self:addBuff(unit,self.GLAB_SELF_BUFF_ARGS);
    self:addBuff(target,self.GLAB_TARGET_BUFF_ARGS);

    self.glabIndex = targetIndex;
end

function class:getPlayerUnit(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

function class:glabEnd(unit)
    if self.glabIndex == nil then return 1; end

    local target = self:getPlayerUnit(self.glabIndex);
    if target == nil then self.glabIndex = nil; return 1; end

    local orbitHit = unit:addOrbitSystem("GrowndHit",0);
    unit:takeHitStop(0.5);
    orbitHit:setPosition(target:getPositionX(),target:getPositionY() + target:getSkeleton():getBoneWorldPositionY("MAIN"));
    orbitHit:setTargetUnit(target);
    orbitHit:setHitType(2);
    orbitHit:setActiveSkill(self.ACTIVE_SKILLS.ATTACK6);

    self:removeBuffs(target,self.GLAB_TARGET_BUFF_ARGS);
    self.glabIndex = nil;
    return 1;
end

function class:updateGlab(unit)
    if self.glabIndex == nil then return; end

    local target = self:getPlayerUnit(self.glabIndex);
    if target == nil then return; end

    local x = unit:getSkeleton():getBoneWorldPositionX("R_hand_attack4") + unit:getPositionX();
    local y = unit:getSkeleton():getBoneWorldPositionY("R_hand_attack4") + unit:getPositionY();
    local targetWorldPositionX = target:getSkeleton():getBoneWorldPositionX("MAIN");
    local targetWorldPositionY = target:getSkeleton():getBoneWorldPositionY("MAIN");

    target:setPosition(x - targetWorldPositionX,target:getPositionY());
    target:getSkeleton():setPosition(0,y - target:getPositionY() - targetWorldPositionY);
end

function class:addBuff(unit,buffBoxList)
    for i,buffBox in ipairs(buffBoxList) do
        self:execAddBuff(unit,buffBox)
    end
end

function class:removeBuffs(unit,buffs)
    for _,v in pairs(buffs) do
        self:removeBuff(unit,v.ID);
    end
end

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end

    unit:getTeamUnitCondition():removeCondition(buff);
end

----// takeDamage //-----------------------------------------------------------------------------
-- 条件 : ひるみ時。攻撃を受けた時ではない。
-- 引数 : event.unit / 自ユニット
---------------------------------------------------------------------------------
function class:takeDamage(event)
    self:glabEnd(event.unit)
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self:glabEnd(event.unit)
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

function class:takeIdle(event)
    if self.afterSkillFLG then
        self.gameUnit:setInvincibleTime(0)
    end
    return 1;
end


---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self:glabEnd(event.unit)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if event.index == 1 then
        self.skill1Count = self.skill1Count + 1
        local num = self.skill1Count % 2
        if num == 0 then
            if self:MultipleSummon(event.unit,5040916,1) then
                self:showMessage(self.SUMMON1_MESSAGE_LIST)
            end
        else
            if self:MultipleSummon(event.unit,5040917,1) then
                self:showMessage(self.SUMMON2_MESSAGE_LIST)
            end
        end
    end

    if event.index == 3 then
        event.unit:setNextAnimationName("attack5")
        event.unit:setNextAnimationEffectName("1-attack5") ---EFのアニメーション名に気をつける
    end

    if event.index == 4 then
        self.lastSkillFLG = true
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("1-skill2") ---EFのアニメーション名に気をつける
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
    local localEnemy = event.enemy
    if event.enemy:getParentTeamUnit() ~= nil then
        localEnemy = event.enemy:getParentTeamUnit()
    end
    local poisonCount = self:countPoisonCondition(localEnemy)
    if poisonCount == 0 then
        event.value = 1
    elseif poisonCount <= 6 then
        event.value = event.value * self.damageTable[poisonCount]
    else
        event.value = event.value * (0.3 + (0.1 * poisonCount))
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

    if buffBox.FUNC ~= nil then buffBox.FUNC(buff) end
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

function class:countPoisonCondition(unit)
    local cnt = 0;
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize ~= 0 then
        for i = 0,(conditionSize - 1) do
            local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
            if cond ~= nil then
                if cond:getConditionTypeAsInt() == 90 then
                    cnt = cnt + 1
                end
            end
        end
    end
    return cnt
end

function class:summon(unit,unitID)
    local flg = false
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i,unitID)--指定したインデックスの位置に指定したエネミーIDのユニットを出す
                flg = true
                break
            end
        end
    end
    return flg
end

function class:MultipleSummon(unit,unitID,Num)
    local flg = false
    for i = 1,Num do
        flg = self:summon(unit,unitID)
    end
    return flg
end

class:publish();

return class;