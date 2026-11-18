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
        numbersOrbit = nil,
        hitCount = 0,
        uniqueID = id,
        gameunit = nil,
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

    function cls:receive1(intparam)
        self.hitCount = intparam;
        self:setParam(self.gameunit,intparam);
        return 1;
    end

    function cls:receive2(intparam)
        self:innerResetHit(self.gameunit,intparam);
        return 1;
    end

    function cls:start(unit)
        self.gameunit = unit;
        
        return 1;
    end

    function cls:startWave(unit)
        
        return 1;
    end

    function cls:takeAttack(unit)

        return 1;
    end

    function cls:attackBranch(unit)

        return 0;
    end



    function cls:attackDamageValue(unit,enemy,value)
        local activeBattleSkill = unit:getActiveBattleSkill();
        if activeBattleSkill ~= nil and self.hitCount < 99 then
            self.hitCount = self.hitCount + 1;
            self:setParam(unit,self.hitCount);
        end

        return value;
    end

    function cls:run(unit,str)
        if str == "sendHit" then self:sendHit(unit) end
        if str == "resetHit" then self:resetHit(unit) end
        if str == "showSummary" then self:showSummary(unit) end
        return 1;
    end

    function cls:update(unit)
        if self.numbersOrbit == nil then
            self.numbersOrbit = unit:addOrbitSystemWithFile("10179num","0");
            self.numbersOrbit:takeAnimation(0,"none",true);
            self.numbersOrbit:takeAnimation(1,"none2",true);
            self.numbersOrbit:setZOrder(10011);
        end
        if self.numbersOrbit ~= nil then
            self:numbersControll(unit);
        end
        
        return 1;
    end

    function cls:numbersControll(unit)
        local isPlayer = unit:getisPlayer();
        local xpos = unit:getAnimationPositionX()+20 < 400 and unit:getAnimationPositionX()+20 or 400;
        if not isPlayer then
            xpos = unit:getAnimationPositionX()-70 > -400 and unit:getAnimationPositionX()-70 or -400;
            self.numbersOrbit:getSkeleton():setScaleX(-1);
        end
        self.numbersOrbit:setPosition(xpos,unit:getAnimationPositionY()+50);
        self.numbersOrbit:takeAnimation(0,self:intToAnimationNameOne(self.hitCount),true);
        self.numbersOrbit:takeAnimation(1,self:intToAnimationNameTen(self.hitCount),true);
    end

    function cls:intToAnimationNameOne(int)
        local temp = int%10;
        if int == 0 then
            return "none";
        end
        return ""..temp;
    end

    function cls:intToAnimationNameTen(int)
        local temp = math.floor(int/10);
        if temp == 0 then
            return "none2";
        end
        return ""..temp.."0";
    end

    function cls:sendHit(unit)
        if self:isControll(unit) then
            megast.Battle:getInstance():sendEventToLua(self.uniqueID,1,self.hitCount);
        end
    end

    function cls:resetHit(unit)
        if self:isControll(unit) then
            megast.Battle:getInstance():sendEventToLua(self.uniqueID,2,self.hitCount);
            self:innerResetHit(unit,self.hitCount);          
        end
    end

    function cls:innerResetHit(unit,int)
        self:setParam(unit,0);
        for i = 0,7 do
            local teamUnit = unit:getTeam():getTeamUnit(i);
            if teamUnit ~= nil then
                
                
                local controll = teamUnit:isMyunit() or teamUnit:getisPlayer() == false;
                if controll then
                    teamUnit:addSPWithPvpCorrection(int);
                    teamUnit:playSummary(summoner.Text:fetchByUnitID(101796112).text1,true);
                end
            end
        end
        self.hitCount = 0;
        self:setParam(unit,0);
    end

    function cls:setParam(unit,int)
        unit:setParameter("179_HitCounter",""..int);
    end

    function cls:showSummary(unit)
        unit:playSummary(summoner.Text:fetchByUnitID(101796112).text2,true);
    end

    function cls:isControll(unit)
        if unit:isMyunit() then
            return true;
        end
        if not unit:getisPlayer() then
            return megast.Battle:getInstance():isHost();
        end

    end
    

    register.regist(cls, id, cls.param.version)
    return 1
end

