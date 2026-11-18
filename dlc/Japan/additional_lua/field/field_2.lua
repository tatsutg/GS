local class = summoner.FieldEventDispatcher.createFieldClass({label="Freeze", version=1.0, id=2});

local json = summoner.Json;

class.DAMAGE_PAR_5SECOND = 500;
class.SPAN = 5;
class.REGISTID = 3002;
class.SKILL_SPEED = 0.2;


--
class.DEBUFF_ARGS = {
    [1] = {
        ID = -502,
        EFID = 2,         --
        VALUE = -25,        --効果量
        DURATION = 9999999,
        ICON = 2
    },
    [2] = {
        ID = -5021,
        EFID = 13,         --
        VALUE = -25,        --効果量
        DURATION = 9999999,
        ICON = 4
    },
    [3] = {
        ID = -5023,
        EFID = 15,         --
        VALUE = -25,        --効果量
        DURATION = 9999999,
        ICON = 6
    }
}

function class:init()
    self.activeTimer = 0;
    self.buffCheckTimer = 0;
    self.fieldArgs = nil;
    self.units = {}
    self.skillDelayTimer = 5;
    return 1
end

-- event { deltaTime,playerTeam,enemyTeam,customParameter }
function class:update(event)
   if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
       return 1;
   end

   if megast.Battle:getInstance():isPvp() then
        self:countUp2(event.deltaTime,event.enemyTeam);
        self:debuffGaze2(event.deltaTime,event.enemyTeam);
        self:takeSkillDelay(event.enemyTeam,event.deltaTime);

   		self:countUp(event.deltaTime,event.playerTeam);
   		self:debuffGaze(event.deltaTime,event.playerTeam);
   		self:takeSkillDelay(event.playerTeam,event.deltaTime);

   		return 1;
   end

   self:countUp(event.deltaTime,event.playerTeam);

   self:debuffGaze(event.deltaTime,event.playerTeam);

   self:takeSkillDelay(event.playerTeam,event.deltaTime);

   return 1
end

function class:debuffGaze2(deltaTime,playerTeam)
    buffCheckTimer2 = self.buffCheckTimer + deltaTime;
    if buffCheckTimer2 < 0.2 then
        return;
    end

    for i = 0, 4 do
        local unit = playerTeam:getTeamUnit(i);
        if unit ~= nil then
            local cond = unit:getTeamUnitCondition():findConditionWithID(self.DEBUFF_ARGS[1].ID);
            if cond == nil then
                self:addBuff(unit,self.DEBUFF_ARGS[1]);
                self:addBuff(unit,self.DEBUFF_ARGS[2]);
                self:addBuff(unit,self.DEBUFF_ARGS[3]);
            end
        end
    end

end

function class:debuffGaze(deltaTime,playerTeam)
    self.buffCheckTimer = self.buffCheckTimer + deltaTime;
    if self.buffCheckTimer < 0.2 then
        return;
    end
    self.buffCheckTimer = self.buffCheckTimer - 0.2;

    for i = 0, 4 do
        local unit = playerTeam:getTeamUnit(i);
        if unit ~= nil then
            local cond = unit:getTeamUnitCondition():findConditionWithID(self.DEBUFF_ARGS[1].ID);
            if cond == nil then
                self:addBuff(unit,self.DEBUFF_ARGS[1]);
                self:addBuff(unit,self.DEBUFF_ARGS[2]);
                self:addBuff(unit,self.DEBUFF_ARGS[3]);
            end
        end
    end

end

-- event { playerTeam,enemyTeam,customParameter }
--Wave開始時に呼ばれる
function class:waveRun(event)

    if event.customParameter ~= nil and event.customParameter ~= "" then
        self.fieldArgs = json.parse(event.customParameter);
    else
        self.fieldArgs = {
            span = 5,
            debuffValue = -50
        }
    end


    self.DEBUFF_ARGS[1].VALUE = self.fieldArgs.debuffValue;
    self.DEBUFF_ARGS[2].VALUE = self.fieldArgs.debuffValue;
    self.DEBUFF_ARGS[3].VALUE = self.fieldArgs.debuffValue;
    return 1
end

-- event { playerTeam,enemyTeam,customParameter }
--Wave終了時に呼ばれる
function class:waveEnd(event)
    print("waveEnd");
   return 1
end

-- event { target,caster,power,customParameter }
--Unit側の takeDamageValue のあとに呼ばれる
function class:takeDamageValue(event)
  
    return 1;
end

-- event { target,caster,breakpower,customParameter }
--Unit側の takeBreakeDamageValue のあとに呼ばれる
function class:takeBreakeDamageValue(event)
    print("takeBreakeDamageValue");
    return 1;
end

function class:countUp2(deltaTime,playerTeam)
    activeTimer2 = self.activeTimer + deltaTime;
    if activeTimer2 > self.fieldArgs.span then
        self:excution(playerTeam);
    end
end

function class:countUp(deltaTime,playerTeam)
    self.activeTimer = self.activeTimer + deltaTime;
    if self.activeTimer > self.fieldArgs.span then
        self:excution(playerTeam);
        self.activeTimer = self.activeTimer - self.fieldArgs.span;
		return 1;
    end
	return 0;
end


function class:excution(playerTeam)
    megast.Battle:getInstance():playFieldEffectActive();
    self.skillDelayTimer = 0;
    for i = 0, 4 do
        local unit = playerTeam:getTeamUnit(i);
        if unit ~= nil then
            unit:resetSkillCoolTime();
            self.units[i] = unit:getSkillCoolTime();
            --耐性チェック
            local condValue = unit:getTeamUnitCondition():findConditionValue(self.REGISTID);
            if condValue > 0 then
                unit:setSkillCoolTime(self.units[i] - self.units[i] * condValue/100);
                self.units[i] = unit:getSkillCoolTime();
            end
            ---ゼファー対策
            local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
            if conditionSize ~= 0 then
                for index = 0,(conditionSize - 1) do
                    local cond = unit:getTeamUnitCondition():getAllConditionsAt(index);
                    if cond ~= nil and cond:getConditionTypeAsInt() == 238 and cond:getScriptID() == 477 then
                        cond:setValue(unit:getNormalSkill():getCoolTimer());
                    end
                end
            end
        end
    end
end


function class:takeSkillDelay(playerTeam,deltaTime)
    if self.skillDelayTimer >= 5 then
        return;
    end
    self.skillDelayTimer = self.skillDelayTimer + deltaTime;
    for i=0,4 do
        local unit = playerTeam:getTeamUnit(i);
        if unit ~= nil then
            unit:resetSkillCoolTime();
            if self.units[unit:getIndex()] ~= nil then
                unit:setSkillCoolTime(self.units[unit:getIndex()] - self.skillDelayTimer * self.SKILL_SPEED);
            end
            ---ゼファー対策
            local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
            if conditionSize ~= 0 then
                for index = 0,(conditionSize - 1) do
                    local cond = unit:getTeamUnitCondition():getAllConditionsAt(index);
                    if cond ~= nil and cond:getConditionTypeAsInt() == 238 and cond:getScriptID() == 477 then
                        cond:setValue(unit:getNormalSkill():getCoolTimer());
                    end
                end
            end
            --耐性チェック
            local condValue = unit:getTeamUnitCondition():findConditionValue(self.REGISTID);

        end
    end
end

--======================================================================================================================================-
--バフかけ

function class:addBuff(unit,args)

    local buff  = nil;

    --耐性チェック
    local condValue = unit:getTeamUnitCondition():findConditionValue(self.REGISTID);

    if args.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
    if args.SCRIPT ~= nil then
        buff:setScriptID(args.SCRIPT);
    end
    if args.SCRIPTVALUE1 ~= nil then
        buff:setValue1(args.SCRIPTVALUE1);
    end

end


class:publish();

return class;
