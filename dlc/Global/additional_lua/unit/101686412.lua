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
        especialBreakTimer = 0,

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

        ESPECIAL_BREAK_RATE = 0.9,
        ESPECIAL_BREAK_DURATION = 20,

        RECAST_BUFFID = 101682,
        RECAST_EFID = 29,
        RECAST_DURATION = 999999,
        RECAST_ICONID = 0,

        BUFF_ARGS = {
            [0] = {
                 ID = 101686412,
                 BUFF_ID = 0,
                 VALUE = 1,
                 DURATION = 20,
                 ICON = 187
            }
        },

        REDUCE_BREAKPOINT_CONSTANT = 10000,
        REDUCE_BREAKPOINT_CONSTANT_CROSS = 10000,

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
        unit:setDamageRateOffset(1)
        unit:setBreakRate(1)
        return 1;
    end

    function cls:takeSkill(unit,index)
        unit:setDamageRateOffset(1)
        unit:setBreakRate(1)
        return 1;
    end



    function cls:run(unit,str)
        local isControll = unit:isMyunit() or not unit:getisPlayer() and self.utill.isHost();
        if str == "addEspecialBreak" then
            self.especialBreakTimer = self.ESPECIAL_BREAK_DURATION;
            self:execAddBuff(unit,self.BUFF_ARGS[0]);
        end
        if str == "skill3RateSetting" then
            unit:setDamageRateOffset(0.01)
            unit:setBreakRate(0.01)
        end

        if str == "skill3RateSettingOrbit" then
            unit:setDamageRateOffset(0.99)
            unit:setBreakRate(0.99)
        end

        if str == "especialBreak" and isControll then
            if self.especialBreakTimer > 0 then
                self:excuteEspecialBrake(unit);
                self.utill.sendEvent(self,2,0);
            end
        end
        return 1;
    end

    function cls:update(unit,delta)

        self:timersControll(delta);
        

        local isControll = unit:isMyunit() or not unit:getisPlayer() and self.utill.isHost();


        if self.updateTimer > 0.16 and megast.Battle:getInstance():getBattleState() == kBattleState_active then
            self.updateTimer = 0;
            local breakBuffValue = unit:getTeamUnitCondition():findConditionValueIgnoreOther(25);
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


    function cls:timersControll(delta)
        if megast.Battle:getInstance():getBattleState() == kBattleState_pause then
            return;
        end
        self.recastTimer = self.recastTimer + delta;
        self.updateTimer = self.updateTimer + delta;

        if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
            return;
        end
        self.especialBreakTimer = self.especialBreakTimer - delta;
    end

    function cls:excuteEspecialBrake(unit)
        local boss = megast.Battle:getInstance():getTeam(false):getBoss();
        if boss == nil then
            return;
        end
        if megast.Battle:getInstance():isRaid() then
            --megast.Battle:getInstance():recAddBreakPoint(unit, boss, boss:getBreakPoint() - (boss:getBreakPoint() - this.REDUCE_BREAKPOINT_CONSTANT));
            --boss:setBreakPoint(boss:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT);
            boss:fixedBreakDamage(self.REDUCE_BREAKPOINT_CONSTANT,unit)
            RaidControl:get():addBreakPool(self.REDUCE_BREAKPOINT_CONSTANT);
        elseif megast.Battle:getInstance():isCrossBattle() then
            --megast.Battle:getInstance():recAddBreakPoint(unit, boss, boss:getBreakPoint() - (boss:getBreakPoint() - this.REDUCE_BREAKPOINT_CONSTANT_CROSS));
            --boss:setBreakPoint(boss:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT_CROSS);
            boss:fixedBreakDamage(self.REDUCE_BREAKPOINT_CONSTANT_CROSS,unit)
        else
            --megast.Battle:getInstance():recAddBreakPoint(unit, boss, boss:getBreakPoint() - (boss:getBreakPoint() * self.ESPECIAL_BREAK_RATE));
            --boss:setBreakPoint(boss:getBreakPoint()*self.ESPECIAL_BREAK_RATE);
            boss:fixedBreakDamage(boss:getBreakPoint() * 0.1,unit)
        end
    end


    function cls:receive1(unit,intparam)
        self:autoBarrier(self.gameUnit);
        return 1;
    end

    function cls:receive2(unit,intparam)
        self:excuteEspecialBrake(self.gameUnit);
        return 1;
    end

    -- バフ処理実行
    function cls:execAddBuff(unit,buffBox)
      if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
          if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        end
        self:addConditionWithGroup(unit,buffBox);
        return;
      end

        local buff  = nil;
        if buffBox.EFFECT ~= nil then
            buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
        else
            buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
        end
        if buffBox.SCRIPT ~= nil then
            buff:setScriptID(buffBox.SCRIPT);
        end
        if buffBox.SCRIPTVALUE1 ~= nil then
            buff:setValue1(buffBox.SCRIPTVALUE1);
        end

    end

    --グループIDつきバフ
    function cls:addConditionWithGroup(unit,buffBox)
      
        local newCond = nil;
        if buffBox.EFFECT ~= nil then
            newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
        else
            newCond = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
        end
        newCond:setGroupID(buffBox.GROUP_ID);
        newCond:setPriority(buffBox.PRIORITY);
        if buffBox.SCRIPT_ID ~= nil then
           newCond:setScriptID(buffBox.SCRIPT_ID)
        end
        if buffBox.SCRIPTVALUE1 ~= nil then
            buff:setValue1(buffBox.SCRIPTVALUE1);
        end
     
    end

    

    register.regist(cls, id, cls.param.version)
    return 1
end

