local class = summoner.FieldEventDispatcher.createFieldClass({label="Burn", version=1.0, id=1});

local json = summoner.Json;

class.DAMAGE_PAR_5SECOND = 500;
class.DAMAGE_SPAN = 5;


-- --ダメ反射
-- class.REFRACTION_BUFF_ARGS = {
--     [1] = {
--         ID = -501,
--         EFID = 84,         --反射
--         VALUE = 2,        --効果量
--         DURATION = 9999999,
--         ICON = 0,
--         SCRIPT = 154,
--         SCRIPTVALUE1 = 2
--     }
-- }

function class:init()
    self.damageTimer = 0;
    self.buffCheckTimer = 0;
    self.fieldArgs = nil;
    return 1
end

-- event { deltaTime,playerTeam,enemyTeam,customParameter }
function class:update(event)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return 1;
    end

    if self.fieldArgs == nil then
    	self.fieldArgs = json.parse(event.customParameter);
        return 1;
	end

    if megast.Battle:getInstance():isPvpSimu() or megast.Battle:getInstance():isArena() then
		-- PVP模擬戦の時
		-- アリーナの時
    	self:countUp2(event.deltaTime,event.enemyTeam);
    	self:countUp(event.deltaTime,event.playerTeam);
        return 1;
	end

    if megast.Battle:getInstance():isPvp() then
	-- PVPの時
        if megast.Battle:getInstance():isPvpHost() then
            if self:countUp(event.deltaTime,event.playerTeam) == 1 then
                self:excuteBurnDamage(event.enemyTeam);
	    end
        else
            self:countUp(event.deltaTime,event.playerTeam);
        end
   	return 1;
    end

    self:countUp(event.deltaTime,event.playerTeam);
    self:refractionGaze(event.deltaTime,event.enemyTeam);

   return 1;
end

-- event { playerTeam,enemyTeam,customParameter }
--Wave開始時に呼ばれる
function class:waveRun(event)
    self.fieldArgs = json.parse(event.customParameter);
    -- self.REFRACTION_BUFF_ARGS.VALUE = self.fieldArgs.refrectValue;
    -- self.REFRACTION_BUFF_ARGS.SCRIPTVALUE1 = self.fieldArgs.refrectValue;
    return 1;
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
    if event.target:getisPlayer() and megast.Battle:getInstance():isPvp() == false then
        return 1;
    end

    if event.power <= 0 then
    	return 1;
    end

    if self.fieldArgs == nil then
        return 1;
	end

    local  targetUnit = event.caster;

    if targetUnit:getParentTeamUnit() ~= nil then
        targetUnit = targetUnit:getParentTeamUnit();
    end

    --耐性チェック
    local damage = event.power * self.fieldArgs.refrectValue/100;
    local condValue = targetUnit:getTeamUnitCondition():findConditionValue(3002);
    damage = damage * (100 - condValue) / 100;

    if damage < 1 then
        damage = 1;
    end

    damage = math.floor(damage);

    --ダメージ表記とHP減算処理
    targetUnit:takeDamagePopup(event.target,damage);
    targetUnit:setHP(targetUnit:getHP() - damage);
    megast.Battle:getInstance():recAddDamage(event.enemy,event.unit,damage);

    print("takeDamageValue");
    return 1;
end

-- event { target,caster,breakpower,customParameter }
--Unit側の takeBreakeDamageValue のあとに呼ばれる
function class:takeBreakeDamageValue(event)
    print("takeBreakeDamageValue");
    return 1;
end

function class:countUp2(deltaTime,playerTeam)
    local damageTimer2 = self.damageTimer + deltaTime;
    if damageTimer2 > self.fieldArgs.span then
        self:excuteBurnDamage(playerTeam);
    	return 1;
    end
    return 0;
end

function class:countUp(deltaTime,playerTeam)
    if megast.Battle:getInstance():isPvp() == true and megast.Battle:getInstance():isPvpHost() == false then
        if megast.Battle:getInstance():getFieldEffectSync() == true then
            megast.Battle:getInstance():setFieldEffectSync(false);
            self:excuteBurnEffect();
            return 1;
        end
        return 0;
    end

    self.damageTimer = self.damageTimer + deltaTime;
    if self.damageTimer > self.fieldArgs.span then
        self:excuteBurnDamage(playerTeam);
        self.damageTimer = self.damageTimer - self.DAMAGE_SPAN;
    	return 1;
    end
    return 0;
end

function class:refractionGaze(deltaTime,enemyTeam)
    -- self.buffCheckTimer = self.buffCheckTimer + deltaTime;
    -- if self.buffCheckTimer < 0.2 then
    --     return;
    -- end
    -- self.buffCheckTimer = self.buffCheckTimer - 0.2;

    -- for i = 0, 7 do
    --     local unit = enemyTeam:getTeamUnit(i);
    --     if unit ~= nil then
    --         local cond = unit:getTeamUnitCondition():findConditionWithID(self.REFRACTION_BUFF_ARGS[1].ID);
    --         if cond == nil then
    --             self:addBuff(unit,self.REFRACTION_BUFF_ARGS[1]);
    --         end
    --     end
    -- end

end

function class:excuteBurnDamage(playerTeam)
    megast.Battle:getInstance():playFieldEffectActive();

    for i = 0, 4 do
        local unit = playerTeam:getTeamUnit(i);
        if unit ~= nil then
            local damageValue = unit:getCalcHPMAX() * self.fieldArgs.damageParcent/100;

            --耐性チェック
            local condValue = unit:getTeamUnitCondition():findConditionValue(3001);
            damageValue = damageValue * (100 - condValue) / 100;

            --ダメージ表記とHP減算処理
            if megast.Battle:getInstance():isPvp() == false then
                unit:takeDamagePopup(unit,damageValue);
                unit:setHP(unit:getHP() - damageValue);
                megast.Battle:getInstance():recAddDamage(nil,unit,damageValue);
            else
                -- PVPのときは死なないようにする
                unit:takeFieldEffectDamage(damageValue, false);
                --megast.Battle:getInstance():recAddDamage(nil,unit,damageValue);
            end
        end
    end
end

function class:excuteBurnEffect()
    megast.Battle:getInstance():playFieldEffectActive();
end


--======================================================================================================================================-
--バフかけ

function class:addBuff(unit,args)
    local buff  = nil;
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
