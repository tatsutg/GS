local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="被験体", version=1.3, id=1202015});
class:inheritFromUnit("unitBossBase");

-- 使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {}

class.ATTACK_WEIGHTS_LIST = {
    [1] = {
        ATTACK1 = 50,
        ATTACK2 = 50
    },
    [2] = {
        ATTACK1 = 25,
        ATTACK2 = 25,
        ATTACK3 = 25
    },
    [3] = {
        ATTACK3 = 50,
        ATTACK4 = 50
    }
}

-- 使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 50
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 5,
    SKILL1 = 5,
    SKILL2 = 6
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 201632012,
            BUFF_ID = 13, -- 攻撃力
            VALUE = 35,
            DURATION = 999999,
            ICON = 5
        },
        [2] = {
            ID = 201632011,
            BUFF_ID = 17, -- ダメージ
            VALUE = 35,
            DURATION = 999999,
            ICON = 26
        }
    }

    self.BUFF_BOX_LIST2 = {
        [1] = {
            ID = 201632021,
            BUFF_ID = 28, -- 行動速度
            VALUE = 20,
            DURATION = 999999,
            ICON = 7,
            EFFECT = 9
        },
        [2] = {
            ID = 201632022,
            BUFF_ID = 27, -- ブレイク耐性
            VALUE = -80,
            DURATION = 999999,
            ICON = 9
        }
    }

    -- 掴み時に自身にかかるバフ内容
    self.GRAB_SELF_BUFF_ARGS = {
        {
            ID = -11,
            BUFF_ID = 113,
            VALUE = 500,
            DURATION = 2000,
            ICON = 0
        }
    }

    -- 掴み時に対象にかかるバフ内容
    self.GRAB_TARGET_BUFF_ARGS = {
        {
            ID = -10,
            BUFF_ID = 89,
            VALUE = 1,
            DURATION = 14,
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
        DURATION = messageBox.DURATION or 10,
        isPlayer = messageBox.isPlayer or false
    }
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "闇属性耐性・クリティカル耐性"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "ブレイク中被ダメージアップ"
        })
    }

    self.HP65_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP65_MESSAGE1 or "攻撃力・与ダメージアップ"
        })
    }
    self.HP35_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP35_MESSAGE1 or "行動速度・ブレイク耐性アップ"
        })
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp65(status) end,
            HP = 65,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp35(status) end,
            HP = 35,
            used = false
        }
    }

    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
        end
    end
end

function class:hp65(status)
    if status == "use3" then
        self.gameUnit:setBurstPoint(0)
        self.gameUnit:setInvincibleTime(6)
        self.furyCount = 1
        self.isShowed = true
        self.gameUnit:takeAnimation(0,"attack6",false)
        self.gameUnit:takeAnimationEffect(0,"1-attack6",false)
        self:addBuff(self.gameUnit,self.BUFF_BOX_LIST)
        self:showMessage(self.HP65_MESSAGE_LIST)
    end
end

function class:hp35(status)
    if status == "use3" then
        self.gameUnit:setBurstPoint(0)
        self.gameUnit:setInvincibleTime(6)
        self.furyCount = 2
        self.isRage = true
        self.isShowed = true
        self.gameUnit:takeAnimation(0,"attack5",false)
        self.gameUnit:takeAnimationEffect(0,"1-attack5",false)
        self:addBuff(self.gameUnit,self.BUFF_BOX_LIST2)
        self:showMessage(self.HP35_MESSAGE_LIST)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false
    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()
    -- self:showMessage(self.START_MESSAGE_LIST)

    self.hitStop = 1
    self.count = 1
    self.furyCount = 0
    self.isShowed = false
    -- self.gameUnit:addSP(60)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    -- event.unit:setReduceHitStop(2,self.hitStop)
    -- self:HPTriggersCheck(event.unit)
    self:updateGlab(event.unit);

    if self.furyCount > 0 and self.isShowed2 then event.unit:addSP(100) end
    return 1
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

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "glabCheckStart" then return self:glabCheckStart(); end
    if event.spineEvent == "tryGlab" then return self:tryGlab(event.unit); end
    if event.spineEvent == "glabEnd" then return self:glabEnd(event.unit); end
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end
    return 1;
end

function class:glabCheckStart()
    self.checkGlab = true;
    self.hitList = {};
    return 1;
end

function class:tryGlab(unit)
    self.checkGlab = false;
    if not self:getIsHost() then
        return 1;
    end

    local targetIndex = Random.sample(self.hitList);

    if targetIndex ~= nil then
        self:execGlab(unit,targetIndex);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,targetIndex);
    end
    return 1;
end

function class:execGlab(unit,targetIndex)
    local target = self:getPlayerUnit(targetIndex);
    if target == nil then
        return;
    end

    --self:addBuff(unit,self.GRAB_SELF_BUFF_ARGS);
    self:addBuff(target,self.GRAB_TARGET_BUFF_ARGS);

    self.glabIndex = targetIndex;
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
    orbitHit:setActiveSkill(self.ACTIVE_SKILLS.ATTACK4);

    self:removeBuffs(target,self.GRAB_TARGET_BUFF_ARGS);
    self.glabIndex = nil;
    return 1;
end


function class:getPlayerUnit(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if not self.isRage then event.unit:setNextAnimationName("zcloneNidle"); end
    return 1;
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    if not self.isRage then event.unit:setNextAnimationName("zcloneNback"); end
    return 1;
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    self:glabEnd(event.unit);
    return 1;
end
---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.checkGlab then self:checkHit(event.enemy:getIndex()); end
    return event.value;
end

function class:checkHit(enemyIndex)
    for i = 1, #self.hitList do
        if self.hitList[i] == enemyIndex then return; end
    end
    table.insert(self.hitList,enemyIndex);
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
    self:attackActiveSkillSetter(event.unit,event.index);
    if not self.isRage then event.unit:setNextAnimationName("zcloneNattack" .. event.index); end
    return 1
end

function class:attackReroll(unit)
    self.ATTACK_WEIGHTS = self.ATTACK_WEIGHTS_LIST[self.count]
    if self.count < 3 then
        self.count = self.count + 1
    else
        self.count = 1
    end

    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");

    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:addSP(unit)
    if self.isShowed then
        unit:addSP(100)
        self.isShowed2 = true
    else
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

    if event.index == 3 and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(3,1);
        return 0;
    end

    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    if not self.isRage then event.unit:setNextAnimationName("zcloneNskill" .. event.index); end
    return 1
end

function class:skillReroll(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if self.furyCount > 0 then
        skillIndex = 2
        self.furyCount = self.furyCount - 1
        if self.furyCount == 0 then
            self.isShowed = false
            self.isShowed2 = false
        end
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
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

    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

function class:receive3(args)
    self.TRIGGERS[args.arg].action("use3")
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
    for i,messageBox in ipairs(messageBoxList) do
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
-- バフ関係
--===================================================================================================================
function class:addBuff(unit,buffBoxList)
    for i,buffBox in ipairs(buffBoxList) do
        self:execAddBuff(unit,buffBox)
    end
end

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

class:publish();

return class;
