------
-- Class for making Unit|Enemy Lua-Script easy to write
-- @example
--     local enemy = summoner.Bootstrap.createEnemyClass({label="Enemy name", version=1.3, id=12345})
--     enemy:inheritFromEnemy(123)
--
--     function enemy:init()
--         self.name = "foo"
--     end
--
--     function enemy:takeAttack(event)
--         self:log(self.foo)
--         self:parent().takeAttack(self, event)
--         return 1
--     end
--
--     enemy:publish()
--     return enemy
------
local _NAME = "summoner.Bootstrap"
local _M = {}
local _G = _G

local Logger = require("summoner.Logger")
local Text = require("summoner.Text")

_M.VARIABLE_NAME = "new"
_M.UNIT_CLASS_PREFIX = "unit."
_M.ENEMY_CLASS_PREFIX = "enemy."

------
-- Create Unit class
------
function _M.createUnitClass(param)
    local name = _M.UNIT_CLASS_PREFIX .. param.id
    local cls = _M.createClass(name, param.label, param.version, param.id, _M.UnitEventDispatcher.UNIT_TYPE)
    cls.TEXT = Text:fetchByUnitID(cls.ID)
    return cls
end

------
-- Create Enemy class
------
function _M.createEnemyClass(param)
    local name = _M.ENEMY_CLASS_PREFIX .. param.id
    local cls = _M.createClass(name, param.label, param.version, param.id, _M.UnitEventDispatcher.ENEMY_TYPE)
    cls.TEXT = Text:fetchByEnemyID(cls.ID)
    return cls
end

------
-- Create class from UnitEventDispatcher
------
function _M.createClass(className, label, version, id, type_)
    if _G.package.loaded[className] == nil then
        local cls = _M.UnitEventDispatcher:prototype()
        cls._NAME = className
        cls.LABEL = label
        cls.API_VERSION = version
        cls.ID = id
        cls.TYPE = type_
        _G.package.loaded[className] = cls
    end
    return _G.package.loaded[className]
end

------
-- Class for listening C++ event
------
local UnitEventListener = {}

------
-- Create a hook function
------
function UnitEventListener.create(eventName, args, func, context)
    local eventMaker = UnitEventListener.makeEventMaker(eventName, args)
    local hookFunction = function(self, ...)
        local event = eventMaker(...)
        return func(context, event)
    end
    return hookFunction
end

------
-- Create a function that making an event table
------
function UnitEventListener.makeEventMaker(eventName, args)
    local eventMaker = function(...)
        local event = {name=eventName}
        for i, name in ipairs(args) do
            local value = select(i, ...)
            event[name] = value
        end
        return event
    end
    return eventMaker
end

------
-- Class for dispatching event
------
local UnitEventDispatcher = {}
UnitEventDispatcher.UNIT_TYPE = 1
UnitEventDispatcher.ENEMY_TYPE = 2
UnitEventDispatcher.API_VERSION = 0
UnitEventDispatcher.TYPE = 0
UnitEventDispatcher.ID = 0
UnitEventDispatcher.LABEL = ""
UnitEventDispatcher._NAME = ""

UnitEventDispatcher.HOOK_FUNCTIONS = {
    takeCastItem = {args={"unit"}, default=function(self, unit) return 1 end},
    runAddOrbitSystem = {args={"unit","orbit","animation"}, default=function(self, unit, orbit, animation) return 1 end},
    avoidDead = {args={"unit"}, default=function(self, unit) return 1 end},
    changeIn = {args={"unit"}, default=function(self, unit) return 1 end},
    extraTimerOneRound = {args={"unit","index","count"}, default=function(self, unit, index, count) return count end},
    takeMultiDamageValue = {args={"unit","value"}, default=function(self, unit, value) return value end},
    takeOut = {args={"unit"}, default=function(self, unit) return 1 end},
    takeTransIn = {args={"unit"}, default=function(self, unit) return 1 end},
    takeTransStart = {args={"unit"}, default=function(self, unit) return 1 end},
    takeTransOut = {args={"unit"}, default=function(self, unit) return 1 end},
    run = {args={"unit", "spineEvent"}, default=function(self, unit, spineEvent) return 1 end},
    castItem = {args={"unit", "item"}, default=function(self, unit, item) return 1 end},
    attackElementRate = {args={"unit", "enemy", "value"}, default=function(self, unit, enemy, value) return value end},
    takeElementRate = {args={"unit", "enemy", "value"}, default=function(self, unit, enemy, value) return value end},
    firstIn = {args={"unit"}, default=function(self, unit) return 1 end},
    takeIn = {args={"unit"}, default=function(self, unit) return 1 end},
    takeBreakeDamageValue = {args={"unit", "enemy", "value"}, default=function(self, unit, enemy, value) return value end},
    takeBreake = {args={"unit"}, default=function(self, unit) return 1 end},
    endWave = {args={"unit", "waves"}, default=function(self, unit, waves) return 1 end},
    startWave = {args={"unit", "waves"}, default=function(self, unit, waves) return 1 end},
    update = {args={"unit", "deltaTime"}, default=function(self, unit, deltaTime) return 1 end},
    attackDamageValue = {args={"unit", "enemy", "value"}, default=function(self, unit, enemy, value) return value end},
    attackDamageValue_OrbitSystem = {args={"unit", "enemy", "value"}, default=function(self, unit, enemy, value) return value end},
    takeDamageValue = {args={"unit", "enemy", "value", "isMiss"}, default=function(self, unit, enemy, value, isMiss) return value end},
    takeHeal = {args={"unit", "heal_origin", "heal_value"}, default=function(self, unit, heal_origin, heal_value) return heal_origin end},
    receive1 = {args={"arg"}, default=function(self, arg) return 1 end},
    receive2 = {args={"arg"}, default=function(self, arg) return 1 end},
    receive3 = {args={"arg"}, default=function(self, arg) return 1 end},
    receive4 = {args={"arg"}, default=function(self, arg) return 1 end},
    receive5 = {args={"arg"}, default=function(self, arg) return 1 end},
    receive6 = {args={"arg"}, default=function(self, arg) return 1 end},
    receive7 = {args={"arg"}, default=function(self, arg) return 1 end},
    receive8 = {args={"arg"}, default=function(self, arg) return 1 end},
    receive9 = {args={"arg"}, default=function(self, arg) return 1 end},
    receive10 = {args={"arg"}, default=function(self, arg) return 1 end},
    start = {args={"unit"}, default=function(self, unit) return 1 end},
    excuteAction = {args={"unit"}, default=function(self, unit) return 1 end},
    takeIdle = {args={"unit"}, default=function(self, unit) return 1 end},
    takeFront = {args={"unit"}, default=function(self, unit) return 1 end},
    takeBack = {args={"unit"}, default=function(self, unit) return 1 end},
    takeAttack = {args={"unit", "index"}, default=function(self, unit, index) return 1 end},
    takeSkill = {args={"unit", "index"}, default=function(self, unit, index) return 1 end},
    takeDamage = {args={"unit"}, default=function(self, unit) return 1 end},
    dead = {args={"unit"}, default=function(self, unit) return 1 end},
    changeOut = {args={"unit"}, default=function(self, unit) return 1 end},
    enableChangeBuff = {args={"unit", "index"}, default=function(self, unit, index) return 1 end},
}

------
-- Construct UnitEventDispatcher object from Script-ID
------
function UnitEventDispatcher:new(id)
    local self_ = setmetatable({
        scriptID = id,
        logger = nil
    }, {__index=self})
    self_.logger = Logger:new(self_.LABEL)
    if self_.init ~= nil then
        self_:init()
    end
    return self_
end

------
-- Get parent class
------
function UnitEventDispatcher:parent()
    return getmetatable(self).__index
end

------
-- Inherit Unit class
------
function UnitEventDispatcher:inheritFromUnit(unitID)
    local name = _M.UNIT_CLASS_PREFIX .. unitID
    local parent = require(name)
    getmetatable(self).__index = parent
end

------
-- Inherit Enemy class
------
function UnitEventDispatcher:inheritFromEnemy(enemyID)
    local name = _M.ENEMY_CLASS_PREFIX .. enemyID
    local parent = require(name)
    getmetatable(self).__index = parent
end

------
-- Publish a function to global that named `new`
------
function UnitEventDispatcher:publish()
    _G[_M.VARIABLE_NAME] = function(id)
        local dispatcher = self:new(id)
        print("Publish by <summoner.Bootstrap>")
        print(("    Label: %s"):format(self.LABEL))
        print(("    Class: %s"):format(self._NAME))
        print(("    Script ID: %s"):format(id))
        print(("    API Version: %s"):format(self.API_VERSION))
        register.regist(dispatcher:generate(), id, self.API_VERSION)
        return 1
    end
end

------
-- Put a message to console
------
function UnitEventDispatcher:log(...)
    self.logger:log(...)
end

------
-- Put a debug message to console
------
function UnitEventDispatcher:debug(...)
    self.logger:debug(...)
end

------
-- Put a dump message to console
------
function UnitEventDispatcher:dump(...)
    self.logger:dump(...)
end

------
-- Generate a class
------
function UnitEventDispatcher:prototype()
    local cls = setmetatable({}, {__index=self})
    return cls
end

------
-- Make an event map
------
function UnitEventDispatcher:generate()
    local listeners = {}
    for eventName, hook in pairs(UnitEventDispatcher.HOOK_FUNCTIONS) do
        if self[eventName] == nil then
            listeners[eventName] = hook.default
        else
            listeners[eventName] = _M.UnitEventListener.create(eventName, hook.args, self[eventName], self)
        end
    end
    return listeners
end

_M.UnitEventListener = UnitEventListener
_M.UnitEventDispatcher = UnitEventDispatcher

_G.package.loaded[_NAME] = _M
return _M
