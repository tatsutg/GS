--@additionalEnemy,4001312,4001313
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="黒ヴァルザンデス", version=1.9, id=4001317});
class:inheritFromUnit("bossPreparation");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK3 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50 },
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50 }
    },
    DEAD = {
        {ATTACK4 = 100}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 }
    },
    DEAD = {
        {SKILL1 = 100}
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 1,
    SKILL1  = 4,
    SKILL2  = 5,
    SKILL3  = 4
}

function class:setMessageBoxList(event)
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({ MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性"}),
        self:setMessageInfo({ MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカル耐性"})
    }
    self.HP70_MESSAGE_LIST = {
        self:setMessageInfo({ MESSAGE = self.TEXT.HP70_MESSAGE1 or "与ダメージ＆攻撃速度アップ"}),
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({ MESSAGE = self.TEXT.HP30_MESSAGE1 or "奥義増加量＆攻撃速度アップ"}),
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({ MESSAGE = self.TEXT.HP0_MESSAGE1 or "シャドウライトニングの構え",Color.magenta}),
    }
end

function class:setBuffBoxList(event)
    self.BUFF_LIST = {
        [1] = {
            ID = 20157501,
            BUFF_ID = 17, -- 与ダメ
            VALUE = 30,
            DURATION = 999999,
            ICON = 26
        }
    }
end

function class:setTriggerList(event)
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp70(status) end,
            HP = 70,
            stop = true
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            stop = true
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0,
            stop = true
        }
    }
end

function class:hp70(status)
    if status == "use3" then
        self:execAddBuff(self.gameUnit,self.BUFF_LIST[1])
        self.gameUnit:addSP(100)
        self:showMessage(self.HP70_MESSAGE_LIST)
        self.gameUnit:setAttackDelay(4)
    end
end

function class:hp30(status)
    if status == "use3" then
        self.spValue = 30
        self.gameUnit:addSP(100)
        self:showMessage(self.HP30_MESSAGE_LIST)
        self.gameUnit:setAttackDelay(2.5)
    end
end

function class:hp0(status)
    if status == "use3" then
        self.isDead = true
        self.spValue = 0
        self.gameUnit:setHP(1)
        self.gameUnit:setBurstPoint(0)
        self.gameUnit:setAttackDelay(9999)
        self.gameUnit:setInvincibleTime(40)
        self.gameUnit:takeAnimation(0,"charge_long",false);
        self.gameUnit:takeAnimationEffect(0,"charge_long",false);
        self:initAttackWeight({DEAD = 100})
        self:initSkillWeight({DEAD = 100})
        self.gameUnit:removeHpMarker(self.TRIGGERS[3].hpMarker)

        if not self.showedLastMessage then
            self.showedLastMessage = true
            self:showMessage(self.HP0_MESSAGE_LIST)
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start_outer(event)
    self.deadCount = 0
    self.deadTimer = 0
    self.deadTimer2 = 0
    self.INTERVAL = 2
    self:showMessage(self.START_MESSAGE_LIST)
    self.gameUnit:addSP(40)
    self.gameUnit:setAttackDelay(5)
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run_outer(event)
    if event.spineEvent == "chargeEnd" then self:chargeEnd(event.unit) end
    if event.spineEvent == "charge" then self:charge(event.unit) end
end
function class:chargeEnd(unit)
    self.chargeStart = true
    self:initAttackWeight({DEAD = 100})
    self:initSkillWeight({DEAD = 100})
    unit:takeAnimation(0,"charge_loop",true);
    unit:takeAnimationEffect(0,"charge_short",true);
end
function class:charge(unit)
    unit:takeAnimation(0,"charge_long",false);
    unit:takeAnimationEffect(0,"charge_long",false);
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update_outer(event)
    event.unit:setReduceHitStop(100,1)
    if self.isDead and not self.usedLast then
        self.gameUnit:setHP(1)
    end
    if self.isDead and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if not self.showedLastMessage then
            self.showedLastMessage = true
            self:showMessage(self.HP0_MESSAGE_LIST)
        end
        self:checkTimer(event.deltaTime)
    end
    if self.gameUnit:getBurstPoint() >= 100 and self.deadTimer2 > 8 then
        self.INTERVAL = 99
        self.deadTimer2 = -100
        if  megast.Battle:getInstance():isHost() then
            self.gameUnit:takeSkill(1)
        end
    end
end

function class:checkTimer(deltaTime)
    self.deadTimer2 = self.deadTimer2 + deltaTime
    if self.deadTimer < self.INTERVAL then
        self.deadTimer = self.deadTimer + deltaTime
        return
    end

    -- HP0踏んでも死なない時は強制的に殺す
    if self.deadTimer > 30 or self.deadCount > 15 then
        self.deadEnd = true
        self.gameUnit:setInvincibleTime(0)
        self:death(self.gameUnit)
        self.gameUnit:setHP(0)
    end

    self.deadTimer = self.deadTimer - self.INTERVAL
    self.deadCount = self.deadCount + 1
    self.gameUnit:addSP(20)
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if not self.usedLast then
        self:hp0("use3")
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
        return 0
    end
    if not self.deadEnd then
        self.gameUnit:setHP(1)
        return 0
    end
    self:death(event.unit)
    return 1
end

function class:receive5(args)
    self:hp0("use3")
    return 1
end

---------------------------------------------------------------------------------
-- excuteAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
    if self.usedLast then
        self.deadEnd = true
        self.gameUnit:setInvincibleTime(0)
        self:death(event.unit)
        self.gameUnit:setHP(0)
    end
    return 1
end

function class:death(unit)
    for i = 0, 6 do
        local teamUnit = unit:getTeam():getTeamUnit(i)
        if teamUnit ~= nil then
            teamUnit:setHP(0)
        end
    end
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill_outer(event)
    if self.chargeStart then
        self.usedLast = true
    end
    if event.index == 2 then
        self:summon(event.unit)
    end
end

class.ENEMIES = {
    [4001312] = 50,
    [4001313] = 50
}
function class:summon(unit)
    if not megast.Battle:getInstance():isHost() then return end

    local used = false
    for i = 0, 6 do
        if unit:getTeam():getTeamUnit(i) == nil then
            local enemyID = summoner.Random.sampleWeighted(self.ENEMIES)
            unit:getTeam():addUnit(i,enemyID)--指定したインデックスの位置に指定したエネミーIDのユニットを出す

            if used then break end
            used = true
        end
    end
end

function class:receive4(args)
    self.gameUnit:getTeam():addUnit(args.arg%10,math.floor(args.arg/10))
    return 1;
end

class:publish();

return class;