--[[
    ダッキュオン
]]

local print = print
local table = table

local register = register
local megast = megast
local LuaUtilities = LuaUtilities
local BattleControl = BattleControl

function new(id)
    print(("Lua: Called `new` with `%s`"):format(id))

    local returnOne = function() return 1 end
    local returnDamage = function(self, unit, enemy, value) return value end
    local cls = {
        param = {
            version = 1.3,
            isUpdate = true
        },
        ATTACK_TIMER = 12,
        ATTACK_DELAY = 24,
        POS_X= 0,
        LIMIT_X = 300,
        SPEED= 8,
        TEXT = summoner.Text:fetchByEnemyID(200200000)
    }

    -- デフォルトのイベントハンドラに関数を割り当てる
    for i, name in ipairs({
        "receive1",
        "start", "update", "dead", "run",
        "startWave", "endWave",
        "excuteAction",
        "takeIdle", "takeFront", "takeDamage", "takeBack", "takeBreake", "takeAttack", "takeSkill"
    }) do
        cls[name] = returnOne
    end
    for i, name in ipairs({"attackDamageValue", "takeBreakeDamageValue"}) do
        cls[name] = returnDamage
    end

    function cls:start(unit)
        unit:setUnitName(self.TEXT.UNIT_NAME);
        unit:getSkeleton():setScale(2.2);
        unit:setHPBarHeightOffset(10000);
        unit.m_IgnoreHitStopTime = 999999;
        unit:setSkillInvocationWeight(0);
        unit:setNeedSP(9999999);
        unit:setAttackDelay(1);
        unit:setAutoZoder(false);
        unit:setLocalZOrder(9000);
        return 1;
    end

    function cls:startWave(unit)
        summoner.Utility.messageByEnemy(self.TEXT.START_MESSAGE,5,summoner.Color.magenta);
        return 1;
    end
    
    function cls:excuteAction(unit)
        local stun = unit:getTeamUnitCondition():findConditionValue(89);
        local para = unit:getTeamUnitCondition():findConditionValue(91);
        local freeze = unit:getTeamUnitCondition():findConditionValue(96);

        if stun > 0 or para > 0 or freeze > 0 then
            return 0;
        end   
    
        unit.m_IgnoreHitStopTime = 999999;
        unit:takeFront();
        unit:setUnitState(kUnitState_none);
        return 0;
    end

    function cls:update(unit , deltatime)
        unit:setLocalZOrder(9000 + unit:getIndex());
        unit:setSize(3);

        --行動不能時はカウントを進めない
        local stun = unit:getTeamUnitCondition():findConditionValue(89);
        local para = unit:getTeamUnitCondition():findConditionValue(91);
        local freeze = unit:getTeamUnitCondition():findConditionValue(96);

        if unit:getUnitState() == kUnitState_damage or stun > 0 or para > 0 or freeze > 0 then
            unit:setPositionX(self.POS_X);
            return 1;
        end
        --攻撃の処理
        if self.ATTACK_TIMER < 0 then
            local rand = LuaUtilities.rand(100);
            local target = unit:getTargetUnit();
            if target ~= nil and target:getPositionX() - unit:getPositionX() < 130 then
                rand = 0;
            end
            if rand <= 50 then
                unit:takeAttack(2);
                unit:getTeamUnitCondition():addCondition(-1,22,100,10);
            elseif rand <= 75 then
                unit:takeAttack(3);
                unit:setActiveSkill(2);
            else
                unit:takeAttack(3);
                unit:setActiveSkill(3);
            end
            self.ATTACK_TIMER = self.ATTACK_DELAY;
            if self.POS_X >= self.LIMIT_X then
                self.ATTACK_TIMER = 3;
            end
        end
        self.ATTACK_TIMER = self.ATTACK_TIMER - deltatime;
        
        --移動の処理
        if self.POS_X == 0 then
            self.POS_X = unit:getPositionX();
        end
        if unit:getUnitState() == kUnitState_none and self.POS_X < self.LIMIT_X then
            self.POS_X = self.POS_X + self.SPEED * deltatime;
        end
        unit:setPositionX(self.POS_X);
        return 1;
    end

    function cls:attackDamageValue(unit,enemy,value)
        if unit:getActiveBattleSkill() == nil then
            megast.Battle:getInstance():shakeGround();
            return 9999;
        end
    
        return value;
    end
    
    function cls:takeDamage(unit)
        self.POS_X = self.POS_X - 1.0;
        return 1
    end
    
    function cls:takeAttack(unit, index)
        --unit.m_IgnoreHitStopTime = 0;
        return 1
    end
   
    -- スキルか奥義を使ったとき
    function cls:takeSkill(unit, index)

        return 1
    end
    
    function cls:takeDamageValue(unit,enemy,value)
        unit:setSize(1);
        return value > 999 and 999 or value;
    end


    register.regist(cls, id, cls.param.version)
    return 1
end
