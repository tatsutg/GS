------
-- Class for making IdleGame Lua-Script easy to write
-- @example
--     local IdleGame = summoner.IdleGameEventDispatcher.createClassIdleGame({label="紅蓮の大地", version=1.3, id=12345})
--
--     function IdleGame:init()
--         self.name = "foo"
--     end
--
--     function IdleGame:init(event)
--         self:log(self.foo)
--         return 1
--     end
--
--     IdleGame:publish()
--     return IdleGame
------
local _NAME = "summoner.IdleGameEventDispatcher"
local _M = {}
local _G = _G

local Bootstrap = require("summoner.Bootstrap")
local Logger = require("summoner.Logger")

_M.VARIABLE_NAME = "newIdleGame"
_M.IDLE_GAME_CLASS_PREFIX = "idleGame."

------
-- Create IdleGame class
------
function _M.createIdleGameClass(param)
    local name = _M.IDLE_GAME_CLASS_PREFIX .. param.id
    local cls = _M.createClass(name, param.label, param.version, param.id, _M.IdleGameEventDispatcher.IDLE_GAME)
    return cls
end

function _M.createClass(className, label, version, id, type_)
    if _G.package.loaded[className] == nil then
        local cls = _M.IdleGameEventDispatcher:prototype()
        cls._NAME = className
        cls.LABEL = label
        cls.API_VERSION = version
        cls.ID = id
        cls.TYPE = type_
        _G.package.loaded[className] = cls
    end
    return _G.package.loaded[className]
end

local IdleGameEventListener = setmetatable({}, {__index=Bootstrap.UnitEventListener})

------
-- Class for dispatching event
------
local IdleGameEventDispatcher = setmetatable({}, {__index=Bootstrap.UnitEventDispatcher})

-- 使わない関数
function IdleGameEventDispatcher:inheritFromUnit(_id)
    print("inheritFromUnit : This function cannot be used here")
end
function IdleGameEventDispatcher:inheritFromEnemy(_id)
    print("inheritFromEnemy : This function cannot be used here")
end

IdleGameEventDispatcher.IDLE_GAME = 1
IdleGameEventDispatcher.API_VERSION = 0
IdleGameEventDispatcher.TYPE = 0
IdleGameEventDispatcher.ID = 0
IdleGameEventDispatcher.LABEL = ""
IdleGameEventDispatcher._NAME = ""

IdleGameEventDispatcher.HOOK_FUNCTIONS = {
    run = {args={"unit", "spineEvent"}, default=function(self, unit, spineEvent) return 1 end},
    takeAttack = {args={"unit","index"}, default=function(self,unit,index) return 1 end},
    update = {args={"unit","instance","deltaTime"}, default=function(self,unit, instance, deltaTime) return 1 end},
    began = {args={"unit","instance"}, default=function(self,unit, instance) return 1 end},
    finishedAnimation = {args={"unit","instance","unitId"}, default=function(self,unit, instance, unitId) return 1 end},
    hitAttack = {args={"unit","instance","unitId"}, default=function(self,unit, instance, unitId) return 1 end},
    waveEnd = {args={"unit","instance"}, default=function(self,unit, instance) return 1 end},
}

------
-- Inherit IdleGame class
------
function IdleGameEventDispatcher:inherit(IdleGameID)
    local name = _M.IDLE_GAME_CLASS_PREFIX .. IdleGameID
    local parent = require(name)
    getmetatable(self).__index = parent
end

------
-- Publish a function to global that named `new`
------
function IdleGameEventDispatcher:publish()
    _G[_M.VARIABLE_NAME] = function(id)
        local dispatcher = self:new(id)
        print("Publish by <summoner.IdleGameEventDispatcher>")
        print(("    Label: %s"):format(self.LABEL))
        print(("    Class: %s"):format(self._NAME))
        print(("    Script ID: %s"):format(id))
        print(("    API Version: %s"):format(self.API_VERSION))
        idleGameRegister.regist(dispatcher:generate(), id, self.API_VERSION)
        return 1
    end
end

------
-- Make an event map
------
function IdleGameEventDispatcher:generate()
    local listeners = {}
    for eventName, hook in pairs(IdleGameEventDispatcher.HOOK_FUNCTIONS) do
        if self[eventName] == nil then
            listeners[eventName] = hook.default
        else
            listeners[eventName] = _M.IdleGameEventListener.create(eventName, hook.args, self[eventName], self)
        end
    end
    return listeners
end

_M.IdleGameEventListener = IdleGameEventListener
_M.IdleGameEventDispatcher = IdleGameEventDispatcher

_G.package.loaded[_NAME] = _M
return _M
