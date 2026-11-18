local class = summoner.FieldEventDispatcher.createFieldClass({label="Swamp", version=1.0, id=6});

local json = summoner.Json;

--欲しいjsonはこんな感じ
-- {
--     "spPerSec":（数値）SP増加量毎秒,
--     "spBySkill":（数値）スキル時のSP増加量
-- }


function class:init()
    self.damageTimer = 0;
    self.buffCheckTimer = 0;
    self.fieldArgs = nil;

    self.SPs = {};
    self.skillStates = {};
    self.artsUnits = {};

    self.isInit = false;
    return 1
end

-- event { deltaTime,playerTeam,enemyTeam,customParameter }
function class:update(event)
    if not self.isInit then
        self.fieldArgs = json.parse(event.customParameter);
        self:SPsInit(event.playerTeam);
        self.isInit = true;

    	if megast.Battle:getInstance():isPvp() then
        	self:SPsInit(event.enemyTeam);
		end
    end
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return 1;
    end
    self:skillGaze(event.playerTeam);
    if megast.Battle:getInstance():getDebugSpChargeSpeed() == 0 then
        self:SPGaze(event.playerTeam,event.deltaTime);
    end

    if megast.Battle:getInstance():isPvp() then
    	self:skillGaze(event.enemyTeam);
    	self:SPGaze(event.enemyTeam,event.deltaTime);
	end

   return 1
end


-- event { playerTeam,enemyTeam,customParameter }
--Wave開始時に呼ばれる
function class:waveRun(event)
    
    return 1
end

-- event { playerTeam,enemyTeam,customParameter }
--Wave終了時に呼ばれる
function class:waveEnd(event)
    print("waveEnd");
   return 1
end


--SPの規定値を管理する部分　規定値を超えていれば規定値に合わせ、それ未満であれば規定値をそこに合わせる。
function class:SPGaze(playerTeam,deltaTime)
    for i = 0, 3 do
        local unit = playerTeam:getTeamUnit(i);
        if unit ~= nil then
			local n = i + unit:getSide() * 4;
            if unit:isMyunit() or megast.Battle:getInstance():isPvp() then
                if unit:getBurstPoint() < self.SPs[n] then
                    self.SPs[n] = unit:getBurstPoint();
                end
                --耐性チェック
                local condValue = unit:getTeamUnitCondition():findConditionValue(3003)/100;
                self.SPs[n] = self.SPs[n] + self.fieldArgs.spPerSec * deltaTime * (1 + condValue);
                unit:setBurstPoint(self.SPs[n] + self.fieldArgs.spPerSec * deltaTime * (1 + condValue),true);
            end
        end
    end
end

function class:SPsInit(playerTeam)
    for i = 0, 3 do
        local unit = playerTeam:getTeamUnit(i);
        if unit ~= nil then
			local n = i + unit:getSide() * 4;
            self:SPsRegist(unit,n);
            self.skillStates[n] = 0;
        end
    end
end

function class:skillGaze(playerTeam)
    for i = 0, 3 do
        local unit = playerTeam:getTeamUnit(i);
        if unit ~= nil then
			local n = i + unit:getSide() * 4;
            local skillExcution = self:isSkill(unit);
            if skillExcution and self.skillStates[n] < unit:getSkillCoolTime() then
                self:addSPBySkill(unit,n);
            end
            self.skillStates[n] = unit:getSkillCoolTime();
        end
    end
end

function class:SPsRegist(unit,index)
    self.SPs[index] = 0;
    unit:setBurstPoint(0,true);
end

function class:isSkill(unit)
    return unit:getBurstState() ~= kBurstState_active and unit:getUnitState() == kUnitState_skill;
end

function class:addSPBySkill(unit,index)
    local condValue = unit:getTeamUnitCondition():findConditionValue(3003)/100;
    self.SPs[index] = self.SPs[index] + self.fieldArgs.spBySkill * (1 + condValue);
    unit:setBurstPoint(self.SPs[index] * (1 + condValue),true);
end


class:publish();

return class;
