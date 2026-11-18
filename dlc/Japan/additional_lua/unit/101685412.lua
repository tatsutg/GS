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
        uniqueID = id,
        gameUnit = nil,
        updateTimer = 0,--毎フレーム監視は重すぎるかなと思ったので0.16秒おきくらいに判定できるようにタイマーを置いておく
        recastTimer = 0,

        --====================================================================================================
        --定数的なものはここで定義する。全て大文字のスネーク記法で
        --====================================================================================================
        DYING_THRESHOLD = 40,--瀕死と判断されるHP％の閾値
        RECAST = 70,--自動結界のリキャスト

        BARRIER_BUFFID = 101681,
        BARRIER_EFID = 98,
        BARRIER_VALUE = 3000,
        BARRIER_DURATION = 20,
        BARRIER_ICONID = 24,
        BARRIER_ANIMAITON = 1,

        RECAST_BUFFID = 101682,
        RECAST_EFID = 29,
        RECAST_DURATION = 999999,
        RECAST_ICONID = 0,


        MESSAGE1 = "一定ダメージ無効",



        utill = {
            getHPParcent = function(unit)
                return 100 * unit:getHP() / unit:getCalcHPMAX();
            end,

            isHost = function ()
                return megast.Battle:getInstance():isHost();
            end,

            findConditionWithType = function (unit,conditionTypeID)
                return unit:getTeamUnitCondition():findConditionWithType(conditionTypeID);
            end,

            removeCondition = function (unit,buffID)
                local buff = unit:getTeamUnitCondition():findConditionWithID(buffID);
                if buff ~= nil then
                    unit:getTeamUnitCondition():removeCondition(buff);
                end
            end,


            sendEvent = function(this,index,intparam)
                megast.Battle:getInstance():sendEventToLua(this.uniqueID,index,intparam);
            end,
        },

        
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
        unit:setRange_Max(100);
        unit:setRange_Min(0);
        self.gameUnit = unit;
        self.recastTimer = 70;--初回はいきなり自動結界発動できるように
        return 1;
    end

    function cls:startWave(unit)
        -- self.updateTimer = -1;
        return 1;
    end

    function cls:takeAttack(unit)
        return 1;
    end



    function cls:run(unit,str)
        
        return 1;
    end

    function cls:update(unit,delta)
        self.recastTimer = self.recastTimer + delta;
        self.updateTimer = self.updateTimer + delta;

        local isControll = unit:isMyunit() or not unit:getisPlayer() and self.utill.isHost();


        if self.updateTimer > 0.16 and megast.Battle:getInstance():getBattleState() == kBattleState_active then
            self.updateTimer = 0;
            local breakBuffValue = unit:getTeamUnitCondition():findConditionValue(25);
            if breakBuffValue > 0 then
                self:addRecastBuff(unit,breakBuffValue);
            end


            if self:lookAtDyingUnit(unit) and self.recastTimer > self.RECAST and isControll then
                self.recastTimer = 0;
                self:autoBarrier(unit);
                self.utill.sendEvent(self,1,0);
            end
        end

        return 1;
    end

    function cls:lookAtDyingUnit(unit)
        for i = 0,4 do
            local target = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i);
            if target ~= nil and self.utill.getHPParcent(target) < self.DYING_THRESHOLD then
                return true;
            end
        end
        return false;
    end


    function cls:autoBarrier(unit)
        
        for i = 0,4 do
            local target = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i);
            if target ~= nil then
                target:getTeamUnitCondition():addCondition(self.BARRIER_BUFFID,self.BARRIER_EFID,self.BARRIER_VALUE,self.BARRIER_DURATION,self.BARRIER_ICONID,self.BARRIER_ANIMAITON);
                self:removeAllBadstatus(target);
            end
        end            
        
    end



    --状態異常剥がし
    function cls:removeAllBadstatus(unit)
        local badStatusIDs = {90,91,92,93,94,95,96,97};
        for i=1,table.maxn(badStatusIDs) do
            local targetID = badStatusIDs[i];
            local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
            while flag do
                local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
                if cond ~= nil then
                    unit:getTeamUnitCondition():removeCondition(cond);
                else
                    flag = false;
                end
            end
        end
    end

    function cls:addRecastBuff(unit,value)
        unit:getTeamUnitCondition():addCondition(self.RECAST_BUFFID,self.RECAST_EFID,value,self.RECAST_DURATION,self.RECAST_ICONID);
    end


    function cls:receive1(unit,intparam)
        self:autoBarrier(self.gameUnit);
        return 1;
    end



    

    register.regist(cls, id, cls.param.version)
    return 1
end

