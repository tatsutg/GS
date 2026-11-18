------
-- Class for making Field Lua-Script easy to write
-- @example
--     local field = summoner.FieldEventDispatcher.createClassField({label="紅蓮の大地", version=1.3, id=12345})
--
--     function field:init()
--         self.name = "foo"
--     end
--
--     function field:init(event)
--         self:log(self.foo)
--         return 1
--     end
--
--     field:publish()
--     return field
------
local _NAME = "summoner.FieldEventDispatcher"
local _M = {}
local _G = _G

local Bootstrap = require("summoner.Bootstrap")
local Logger = require("summoner.Logger")

_M.VARIABLE_NAME = "newField"
_M.FIELD_CLASS_PREFIX = "field."

------
-- Create Field class
------
function _M.createFieldClass(param)
    local name = _M.FIELD_CLASS_PREFIX .. param.id
    local cls = _M.createClass(name, param.label, param.version, param.id, _M.FieldEventDispatcher.FIELD)
    return cls
end

function _M.createClass(className, label, version, id, type_)
    if _G.package.loaded[className] == nil then
        local cls = _M.FieldEventDispatcher:prototype()
        cls._NAME = className
        cls.LABEL = label
        cls.API_VERSION = version
        cls.ID = id
        cls.TYPE = type_
        _G.package.loaded[className] = cls
    end
    return _G.package.loaded[className]
end

local FieldEventListener = setmetatable({}, {__index=Bootstrap.UnitEventListener})

------
-- Class for dispatching event
------
local FieldEventDispatcher = setmetatable({}, {__index=Bootstrap.UnitEventDispatcher})

-- 使わない関数
function FieldEventDispatcher:inheritFromUnit(_id)
    print("inheritFromUnit : This function cannot be used here")
end
function FieldEventDispatcher:inheritFromEnemy(_id)
    print("inheritFromEnemy : This function cannot be used here")
end

FieldEventDispatcher.FIELD = 1
FieldEventDispatcher.API_VERSION = 0
FieldEventDispatcher.TYPE = 0
FieldEventDispatcher.ID = 0
FieldEventDispatcher.LABEL = ""
FieldEventDispatcher._NAME = ""

FieldEventDispatcher.HOOK_FUNCTIONS = {
    update = {args={"deltaTime","playerTeam","enemyTeam","customParameter"}, default=function(self, deltaTime, playerTeam, enemyTeam, customParameter) return 1 end},
    waveRun = {args={"playerTeam","enemyTeam","customParameter"}, default=function(self, playerTeam, enemyTeam, customParameter) return 1 end},
    waveEnd = {args={"playerTeam","enemyTeam","customParameter"}, default=function(self, playerTeam, enemyTeam, customParameter) return 1 end},
    takeDamageValue = {args={"target","caster","power","customParameter"}, default=function(self, target, caster, power, customParameter) return 1 end},
    takeBreakeDamageValue = {args={"target","caster","breakpower","customParameter"}, default=function(self, target, caster, breakpower, customParameter) return 1 end},
}

------
-- Inherit Field class
------
function FieldEventDispatcher:inherit(fieldID)
    local name = _M.FIELD_CLASS_PREFIX .. fieldID
    local parent = require(name)
    getmetatable(self).__index = parent
end

------
-- Publish a function to global that named `new`
------
function FieldEventDispatcher:publish()
    _G[_M.VARIABLE_NAME] = function(id)
        local dispatcher = self:new(id)
        print("Publish by <summoner.FieldEventDispatcher>")
        print(("    Label: %s"):format(self.LABEL))
        print(("    Class: %s"):format(self._NAME))
        print(("    Script ID: %s"):format(id))
        print(("    API Version: %s"):format(self.API_VERSION))
        fieldRegister.regist(dispatcher:generate(), id, self.API_VERSION)
        return 1
    end
end

------
-- Make an event map
------
function FieldEventDispatcher:generate()
    local listeners = {}
    for eventName, hook in pairs(FieldEventDispatcher.HOOK_FUNCTIONS) do
        if self[eventName] == nil then
            listeners[eventName] = hook.default
        else
            listeners[eventName] = _M.FieldEventListener.create(eventName, hook.args, self[eventName], self)
        end
    end
    return listeners
end

_M.FieldEventListener = FieldEventListener
_M.FieldEventDispatcher = FieldEventDispatcher

_G.package.loaded[_NAME] = _M
return _M
