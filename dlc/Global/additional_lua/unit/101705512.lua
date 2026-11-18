--[[
    
]]

local print = print
local table = table

local register = register
local megast = megast
local LuaUtilities = LuaUtilities
local BattleControl = BattleControl

function new(id)
    local DEBUG = true
    local LOG_LABEL = ""
    local log = function(str, ...) print((("Lua(%s): "):format(LOG_LABEL) .. str):format(...)) end
    local debug = function(...) if DEBUG then log(...) end end

    log("Called `new` with `%s`", id)

    local returnOne = function() return 1 end
    local returnDamage = function(self, unit, enemy, value) return value end
    local cls = {
        param = {
            version = 1.3,
            isUpdate = true
        },

        --====================================================================================================
        --メンバ変数的なものはここて定義する
        --====================================================================================================
        badStatusUnits = {},
        targetTable = {
            new = function(_index,_rate)
                return {index = _index,rate = _rate}
            end 
        },
        orbits = {},
        lockOnOrbit = {
            new = function(_index,_orbit)
                return {index = _index,orbit = _orbit}
            end 
        }
        --====================================================================================================
        --定数的なものはここで定義する。全て大文字のスネーク記法で
        --====================================================================================================


        
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
    for i, name in ipairs({"attackDamageValue", "takeBreakeDamageValue","takeDamageValue"}) do
        cls[name] = returnDamage
    end

    function cls:start(unit)

        return 1;
    end

    function cls:startWave(unit)

        return 1;
    end

    function cls:takeAttack(unit)

        return 1;
    end



    function cls:update(unit,delta)
        for i=1,table.maxn(self.orbits) do
            local target = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(self.orbits[i].index);
            if target ~= nil then
                self.orbits[i].orbit:setPositionX(target:getAnimationPositionX());
                self.orbits[i].orbit:setPositionY(target:getAnimationPositionY());
            end
        end
        return 1;
    end

    function cls:run(unit,str)
        if str == "findBadStatus" then self:findBadStatus(unit) end
        if str == "orbitEnd" then self:orbitEnd(unit) end
        return 1;
    end

    function cls:findBadStatus(unit)
        for i = 0,7 do
            local target = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
            if target ~= nil then
                local cnt = self:countBadStatus(target);
                if cnt > 0 then
                    self:addOrbit(unit,target);
                    local  tmp = self.targetTable.new(target:getIndex(),cnt);
                    local buff = unit:getTeamUnitCondition():addCondition(-1,22,100,10,0);
                    buff:setScriptID(84);
                    buff:setValue1(target:getIndex());
                    table.insert(self.badStatusUnits,tmp);
                end
            end
        end
    end

    function cls:countBadStatus(unit)
        local cnt = 0;
        local badStatusIDs = {89,90,91,92,93,94,95,96,97,129,131,135};
        for i=1,table.maxn(badStatusIDs) do
            local targetID = badStatusIDs[i];
           
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                cnt = cnt + 1;
            end
            
        end
        return cnt;
    end

    function cls:addOrbit(unit,target)
        local orbit = unit:addOrbitSystem("target");
        orbit:setPositionX(target:getAnimationPositionX());
        orbit:setPositionY(target:getAnimationPositionY());
        local tmp = self.lockOnOrbit.new(target:getIndex(),orbit);
        table.insert(self.orbits,tmp);
    end

    function cls:bomber(unit,target)
        local orbit = unit:addOrbitSystem("hit");
        orbit:setPositionX(target:getAnimationPositionX());
        orbit:setPositionY(target:getAnimationPositionY());
    end

    function cls:attackDamageValue(unit,enemy,value)
        
        local skillType = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
        if skillType ~= 2 then
            return value;
        end
        for i=1,table.maxn(self.badStatusUnits) do
            if enemy:getIndex() == self.badStatusUnits[i].index then
                self:bomber(unit,enemy);
                local damageRate = 1.5 +  0.25 * (self.badStatusUnits[i].rate - 1);
             
                value = value * damageRate;
               
                
                table.remove(self.badStatusUnits,i);
                break;
            end
        end
        return value;
    end

    function cls:orbitEnd(unit)
        local hit = 0;
        for i=1,table.maxn(self.orbits) do
            if self.orbits[i].orbit == unit then
                hit = i;
            end
        end
        table.remove(self.orbits,hit);
    end
    

    register.regist(cls, id, cls.param.version)
    return 1
end

