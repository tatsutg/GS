--[[
    ミーズィナ
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
        local controll = unit:isMyunit() or unit:getisPlayer() == false;
        if controll and not megast.Battle:getInstance():isPvp() then
            unit:addSPWithPvpCorrection(100);
            if unit:getParameter("add") == "" then
                cls.isAdd = true
            end
        end
        return 1;
    end

    function cls:startWave(unit)
        local controll = unit:isMyunit() or unit:getisPlayer() == false;
        if controll and not self.isAdd and not megast.Battle:getInstance():isPvp() then
            unit:addSPWithPvpCorrection(100);
            unit:setParameter("add","true")
        end
        cls.isAdd = false
        return 1;
    end


    register.regist(cls, id, cls.param.version)
    return 1
end

