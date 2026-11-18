local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local enemy = Bootstrap.createEnemyClass({label="巨大ダキュオン１", version=1.7, id=200200004})
local math = math

function enemy:start(event)
    self.ATTACK_TIMER = 7
    self.MIN_ATTACK_DELAY = 5
    self.MAX_ATTACK_DELAY = 13
    self.POS_X = nil
    self.LIMIT_X = 280
    self.MIN_SPEED = 10
    self.MAX_SPEED = 18

    event.unit:setUnitName(self.TEXT.UNIT_NAME)
    event.unit:getSkeleton():setScale(2.4)
    event.unit:setHPBarHeightOffset(10000)
    event.unit.m_IgnoreHitStopTime = 999999
    event.unit:setSkillInvocationWeight(0)
    event.unit:setNeedSP(9999999)
    event.unit:setAttackDelay(1)
    event.unit:setAutoZoder(false)
    event.unit:setLocalZOrder(9000 + event.unit:getIndex())

    event.unit:getTeamUnitCondition():addCondition(2002000, 7, 300, 99999, 35)

    return 1
end

function enemy:excuteAction(event)
    local stun = event.unit:getTeamUnitCondition():findConditionValue(89)
    local para = event.unit:getTeamUnitCondition():findConditionValue(91)
    local freeze = event.unit:getTeamUnitCondition():findConditionValue(96)

    if stun > 0 or para > 0 or freeze > 0 then
        return 0
    end

    event.unit.m_IgnoreHitStopTime = 999999
    event.unit:takeFront()
    event.unit:setUnitState(kUnitState_none)
    return 0
end

function enemy:update(event)
    event.unit:setLocalZOrder(9000 + event.unit:getIndex())
    event.unit:setSize(3)
    if self.POS_X == nil then
        self.POS_X = event.unit:getPositionX()
    end

    -- 行動不能時はカウントを進めない
    local stun = event.unit:getTeamUnitCondition():findConditionValue(89)
    local para = event.unit:getTeamUnitCondition():findConditionValue(91)
    local freeze = event.unit:getTeamUnitCondition():findConditionValue(96)

    if event.unit:getUnitState() == kUnitState_damage or stun > 0 or para > 0 or freeze > 0 then
        self:log(self.POS_X)
        event.unit:setPositionX(self.POS_X)
        return 1
    end

    -- 攻撃の処理
    if self.ATTACK_TIMER < 0 then
        local rand = LuaUtilities.rand(100)
        local target = event.unit:getTargetUnit()
        if target ~= nil and target:getPositionX() - event.unit:getPositionX() < 130 then
            rand = 0
        end
        if rand <= 50 then
            event.unit:takeAttack(2)
            event.unit:getTeamUnitCondition():addCondition(-1, 22, 100, 99999)
        elseif rand <= 75 then
            event.unit:takeAttack(3)
            event.unit:setActiveSkill(2)
        else
            event.unit:takeAttack(3)
            event.unit:setActiveSkill(3)
        end
        self.ATTACK_TIMER = math.random(self.MIN_ATTACK_DELAY, self.MAX_ATTACK_DELAY)
        if self.POS_X >= self.LIMIT_X then
            self.ATTACK_TIMER = 3
        end
    end
    self.ATTACK_TIMER = self.ATTACK_TIMER - event.deltaTime

    -- 移動の処理
    if event.unit:getUnitState() == kUnitState_none and self.POS_X < self.LIMIT_X then
        self.POS_X = self.POS_X + math.random(self.MIN_SPEED, self.MAX_SPEED) * event.deltaTime
    end
    self:log(self.POS_X)
    event.unit:setPositionX(self.POS_X)

    return 1
end

function enemy:attackDamageValue(event)
    if event.unit:getActiveBattleSkill() == nil then
        megast.Battle:getInstance():shakeGround()
        return 9999
    else
        return event.value
    end
end

function enemy:takeDamage(event)
    self.POS_X = self.POS_X - math.random(1, 3)
    return 1
end

function enemy:takeDamageValue(event)
    event.unit:setSize(1)
    return event.value > 999 and 999 or event.value
end

enemy:publish()
return enemy
