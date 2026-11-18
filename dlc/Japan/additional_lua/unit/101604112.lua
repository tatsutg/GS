--[[
    ラサオウ星５
]]

local print = print
local table = table

local register = register
local megast = megast
local LuaUtilities = LuaUtilities
local BattleControl = BattleControl

function new(id)
    local DEBUG = true
    local LOG_LABEL = "ラサオウ星５"
    local log = function(str, ...) print((("Lua(%s): "):format(LOG_LABEL) .. str):format(...)) end
    local debug = function(...) if DEBUG then log(...) end end

    log("Called `new` with `%s`", id)

    local returnOne = function() return 1 end
    local returnDamage = function(self, unit, enemy, value) return value end
    local cls = {
        param = {
            version = 1.5,
            isUpdate = true
        },

        --====================================================================================================
        --メンバ変数的なものはここて定義する
        --====================================================================================================
        gameUnit = nil,
        uniqueID = id,
        buffCount = 0,
        buffUsed = false,
        --====================================================================================================
        --定数的なものはここで定義する。全て大文字のスネーク記法で
        --====================================================================================================
        ICONS = {
            140,
            141,
            142,
            143,
            144,
            145,
            146,
            147,
            148,
            149,
            149
        },

        BUFF_ID = 10160,

        BUFF_EFFECT_ID = 22,

        BUFF_VALUE = 3,

        BUFF_DURATION = 9999,

        ATTACK_BUFF_ID = 101601,

        ATTACK_BUFF_EFFECTID = 17,

        ATTACK_BUFF_VALUE = 100,

        ATTACK_BUFF_DURATION = 20,

        ATTACK_BUFF_ICON = 0,

        BREAK_BUFF_ID = 101602,

        BREAK_BUFF_EFFECTID = 25,

        BREAK_BUFF_VALUE = 200,

        BREAK_BUFF_DURATION = 20,

        BREAK_BUFF_ICON = 0


        
    }

    -- デフォルトのイベントハンドラに関数を割り当てる
    for i, name in ipairs({
        "receive1",
        "start", "update", "dead", "run",
        "startWave", "endWave",
        "excuteAction",
        "takeIdle", "takeFront", "takeDamage", "takeBack", "takeBreake", "takeAttack", "takeSkill",
        "takeIn"
    }) do
        cls[name] = returnOne
    end
    for i, name in ipairs({"takeDamageValue","attackDamageValue", "takeBreakeDamageValue","takeElementRate"}) do
        cls[name] = returnDamage
    end

    function cls:sendEvent(index,intparam)
        megast.Battle:getInstance():sendEventToLua(self.uniqueID,index,intparam);
    end

    --スキルや奥義を打つたびに心眼カウンターがたまるやつ
    function cls:countUp(unit)
        local isControll = unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
        if not isControll then
            return;
        end
        if self.buffCount > 10 then
            return;
        end
        
        self.buffCount = self.buffCount + 1;
        self:updateBuffIcon(unit,self.buffCount);
        self:sendEvent(1,self.buffCount);
    end

    function cls:resetBuff(unit)
        self.buffCount = 0;
        self:updateBuffIcon(unit,0);
        local isControll = unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
        if not isControll then
            return;
        end
        self:sendEvent(1,self.buffCount);
    end

    function cls:updateBuffIcon (unit,intparam)
        if intparam > 0 then
            local _buffValue = self.BUFF_VALUE * intparam;
            if intparam >= 10 then
                _buffValue = 100;
            end
            unit:getTeamUnitCondition():addCondition(self.BUFF_ID,self.BUFF_EFFECT_ID,_buffValue,self.BUFF_DURATION,self.ICONS[intparam]);
        
        else
         
            local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_ID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            end
        end
    end

    function cls:attackElementRate (unit,enemy,value)
        --奥義かどうか判定
        local skillType = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
        if skillType ~= 2 then
            return value;
        end

        --敵の属性を判断　光属性なら倍率追加
        local el = enemy:getElementType();
        if el == kElementType_Light then
            value = megast.Battle:getInstance():getElementalRate(5,4)
        end
        

        
        return value;
    end

    function cls:showEffect(unit)
        
        local orbit = self.gameUnit:addOrbitSystem("break",0);
        orbit:setPosition(unit:getAnimationPositionX(),unit:getAnimationPositionY());
        orbit:getSkeleton():setScaleX(1.5);
        orbit:getSkeleton():setScaleY(1.5);
    end

    function cls:attackDamageValue(unit,enemy,value)
        
        local condition1 = unit:getBurstState() == kBurstState_active;
        local condition2 = self.buffCount >= 10; 

        if condition1 and condition2 then
            self:showEffect(enemy); 
        end

        --奥義かどうか判定
        local skillType = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
        if skillType ~= 2 then
            return value;
        end

        --敵の闇耐性の分だけ倍率を減算
        value = value - value * (enemy:getTeamUnitCondition():findConditionValue(65) / 100);

        if value < 1 then
            value = 1;
        end

        return value;
    end

    function cls:takeSkill(unit,index)
        self:countUp(unit);
        if index == 2 and self.buffCount > 10 then
            unit:getTeamUnitCondition():addCondition(self.ATTACK_BUFF_ID,self.ATTACK_BUFF_EFFECTID,self.ATTACK_BUFF_VALUE,self.ATTACK_BUFF_DURATION,self.ATTACK_BUFF_ICON);
            unit:getTeamUnitCondition():addCondition(self.BREAK_BUFF_ID,self.BREAK_BUFF_EFFECTID,self.BREAK_BUFF_VALUE,self.BREAK_BUFF_DURATION,self.BREAK_BUFF_ICON);
            self.buffUsed = true;
        end
        self:animationSwitcher(unit,"skill"..index);
        return 1;
    end

    function cls:excuteAction(unit)
        if self.buffUsed then
            self.buffUsed = false;
            self:resetBuff(unit);
            local cond = unit:getTeamUnitCondition():findConditionWithID(self.ATTACK_BUFF_ID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            end

            local cond2 = unit:getTeamUnitCondition():findConditionWithID(self.BREAK_BUFF_ID);
            if cond2 ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond2);
            end
        end
        return 1;
    end


    function cls:start(unit)
        self.gameUnit = unit;
        return 1;
    end

    function cls:receive1(intparam)
        self.buffCount = intparam;
        self:updateBuffIcon(self.gameUnit,intparam);
        return 1;
    end
    

    -- function cls:receive2(intparam)
    --     local unit = megast.Battle:getInstance():getTeam(false):getTeamUnit(intparam);
    --     self:showEffect(unit);
    --     return 1;
    -- end

--=======================================================================================================================
--ここから心眼の見た目関係のみ 
--=======================================================================================================================

    function cls:takeIdle(unit)
        self:animationSwitcher(unit,"idle");
        return 1;
    end

    function cls:takeFront(unit)
        self:animationSwitcher(unit,"front");
        return 1;
    end

    function cls:takeDamege(unit)
        self:animationSwitcher(unit,"damege");
        return 1;
    end

    function cls:takeBack(unit)
        self:animationSwitcher(unit,"back");
        return 1;
    end


    function cls:takeAttack(unit,index)
        self:animationSwitcher(unit,"attack"..index);
        return 1;
    end

    function cls:animationSwitcher(unit,name)
        if self.buffCount < 10 then
            unit:setNextAnimationName("zcloneN"..name);
        end
    end

    register.regist(cls, id, cls.param.version)
    return 1
end

