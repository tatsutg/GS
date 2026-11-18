------
-- Class for making Dungeon Lua-Script easy to write
-- @example
--     local dungeon = summoner.DungeonEventDispatcher.createClassDungeon({label="紅蓮の大地", version=1.3, id=12345})
--
--     function dungeon:init()
--         self.name = "foo"
--     end
--
--     function dungeon:init(event)
--         self:log(self.foo)
--         return 1
--     end
--
--     dungeon:publish()
--     return dungeon
------
local _NAME = "summoner.DungeonEventDispatcher"
local _M = {}
local _G = _G

local Bootstrap = require("summoner.Bootstrap")
local Logger = require("summoner.Logger")

_M.VARIABLE_NAME = "newDungeon"
_M.DUNGEON_CLASS_PREFIX = "dungeon."

------
-- Create Dungeon class
------
function _M.createDungeonClass(param)
    local name = _M.DUNGEON_CLASS_PREFIX .. param.id
    local cls = _M.createClass(name, param.label, param.version, param.id, _M.DungeonEventDispatcher.DUNGEON)
    return cls
end

function _M.createClass(className, label, version, id, type_)
    if _G.package.loaded[className] == nil then
        local cls = _M.DungeonEventDispatcher:prototype()
        cls._NAME = className
        cls.LABEL = label
        cls.API_VERSION = version
        cls.ID = id
        cls.TYPE = type_
        _G.package.loaded[className] = cls
    end
    return _G.package.loaded[className]
end

local DungeonEventListener = setmetatable({}, {__index=Bootstrap.UnitEventListener})

------
-- Class for dispatching event
------
local DungeonEventDispatcher = setmetatable({}, {__index=Bootstrap.UnitEventDispatcher})

-- 使わない関数
function DungeonEventDispatcher:inheritFromUnit(_id)
    print("inheritFromUnit : This function cannot be used here")
end
function DungeonEventDispatcher:inheritFromEnemy(_id)
    print("inheritFromEnemy : This function cannot be used here")
end

DungeonEventDispatcher.DUNGEON = 1
DungeonEventDispatcher.API_VERSION = 0
DungeonEventDispatcher.TYPE = 0
DungeonEventDispatcher.ID = 0
DungeonEventDispatcher.LABEL = ""
DungeonEventDispatcher._NAME = ""

DungeonEventDispatcher.HOOK_FUNCTIONS = {
    update = {args={"instance","deltaTime"}, default=function(self, instance, deltaTime) return 1 end},
    loaded = {args={"instance"}, default=function(self, instance) return 1 end},
    began = {args={"instance"}, default=function(self, instance) return 1 end},
    resolved = {args={"instance","beforeCount","afterCount","beforeReward","afterReward"}, default=function(self, instance, beforeCount, afterCount, beforeReward, afterReward) return 1 end},
    finishedAnimation = {args={"instance","unitId"}, default=function(self, instance, unitId) return 1 end},
    hitAttack = {args={"instance","unitId"}, default=function(self, instance, unitId) return 1 end},
}

------
-- Inherit Dungeon class
------
function DungeonEventDispatcher:inherit(dungeonID)
    local name = _M.DUNGEON_CLASS_PREFIX .. dungeonID
    local parent = require(name)
    getmetatable(self).__index = parent
end

------
-- Publish a function to global that named `new`
------
function DungeonEventDispatcher:publish()
    _G[_M.VARIABLE_NAME] = function(id)
        local dispatcher = self:new(id)
        print("Publish by <summoner.DungeonEventDispatcher>")
        print(("    Label: %s"):format(self.LABEL))
        print(("    Class: %s"):format(self._NAME))
        print(("    Script ID: %s"):format(id))
        print(("    API Version: %s"):format(self.API_VERSION))
        dungeonRegister.regist(dispatcher:generate(), id, self.API_VERSION)
        return 1
    end
end

------
-- Make an event map
------
function DungeonEventDispatcher:generate()
    local listeners = {}
    for eventName, hook in pairs(DungeonEventDispatcher.HOOK_FUNCTIONS) do
        if self[eventName] == nil then
            listeners[eventName] = hook.default
        else
            listeners[eventName] = _M.DungeonEventListener.create(eventName, hook.args, self[eventName], self)
        end
    end
    return listeners
end

_M.DungeonEventListener = DungeonEventListener
_M.DungeonEventDispatcher = DungeonEventDispatcher

_G.package.loaded[_NAME] = _M
return _M
