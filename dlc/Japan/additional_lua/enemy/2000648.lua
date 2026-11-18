--[[
    試練の回廊 １８階/ゴルネコゴッド
]]

local ipairs = ipairs
local print = print
local table = table

local register = register
local megast = megast
local LuaUtilities = LuaUtilities
local BattleControl = BattleControl

function new(id)
    local DEBUG = false
    local LOG_LABEL = "ゴルネコゴッド"
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
        MESSAGES = {
            END = {
                {R=196, G=196, B=0, TIME=3, TEXT=summoner.Text:fetchByEnemyID(2000648).mess1},
            },
        },
        MAX_ENEMY_INDEX = 6,
        timeUp = false,
        ended = false,
        remainingTime = 10,
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
    for i, name in ipairs({"takeDamageValue", "attackDamageValue", "takeBreakeDamageValue"}) do
        cls[name] = returnDamage
    end

    -- event/開始時
    debug("Listening to event `start`")
    function cls:start(unit)
        debug("Called `start`")
        unit:setDeadDropSp(250)
        return 1
    end

    -- event/スキルを使ったとき
    debug("Listening to event `takeAttack`")
    function cls:takeAttack(unit, index)
        debug("Called `takeAttack` with index `%s`", index)
        if self.timeUp or LuaUtilities.rand(2) < 1 then
            unit:takeBack()
        else
            unit:takeIdle()
        end
        return 0
    end

    -- event/奥義を使ったとき
    debug("Listening to event `takeSkill`")
    function cls:takeSkill(unit, index)
        debug("Called `takeSkill` with index `%s`", index)
        unit:takeIdle()
        return 0
    end

    -- event/後退時
    debug("Listening to event `takeBack`")
    function cls:takeBack(unit)
        debug("Called `takeBack`")
        if self.timeUp and not self.ended then
            for i, message in ipairs(self.MESSAGES.END) do
                BattleControl:get():pushEnemyInfomation(message.TEXT, message.R, message.G, message.B, message.TIME)
            end
            unit:setDeadDropSp(0)
            self.ended = true
        end
        return 1
    end

    -- event/フレーム毎の処理
    debug("Listening to event `update`")
    function cls:update(unit, dt)
        if not self.timeUp then
            self.remainingTime = self.remainingTime - dt
            debug("remainingTime %s", self.remainingTime)
            if self.remainingTime <= 0 then
                self.timeUp = true
            end
        elseif self.ended then
            unit:setHP(0)
        end
        return 1
    end

    -- event/死んだとき
    debug("Listening to event `dead`")
    function cls:dead(unit)
        debug("Called `dead`")
        if self.ended then
            unit:setNextAnimationName("takeBack")
            unit:setNextAnimationEffectName("takeBack")
        end
        return 1
    end

    register.regist(cls, id, cls.param.version)
    return 1
end
