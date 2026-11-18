------
-- Class for making MapTheme Lua-Script easy to write
-- @example
--     local mapTheme = summoner.MapThemeEventDispatcher.createClassMapTheme({label="紅蓮の大地", version=1.3, id=12345})
--
--     function mapTheme:init()
--         self.name = "foo"
--     end
--
--     function mapTheme:init(event)
--         self:log(self.foo)
--         return 1
--     end
--
--     mapTheme:publish()
--     return mapTheme
------
local _NAME = "summoner.MapThemeEventDispatcher"
local _M = {}
local _G = _G

local Bootstrap = require("summoner.Bootstrap")
local Logger = require("summoner.Logger")
local Text = require("summoner.Text")

_M.VARIABLE_NAME = "newMapTheme"
_M.MAPTHEME_CLASS_PREFIX = "mapTheme."

------
-- Create MapTheme class
------
function _M.createMapThemeClass(param)
    local name = _M.MAPTHEME_CLASS_PREFIX .. param.id
    local cls = _M.createClass(name, param.label, param.version, param.id, _M.MapThemeEventDispatcher.MAPTHEME)
    cls.TEXT = Text:fetchByMapThemeID(cls.ID)
    return cls
end

function _M.createClass(className, label, version, id, type_)
    if _G.package.loaded[className] == nil then
        local cls = _M.MapThemeEventDispatcher:prototype()
        cls._NAME = className
        cls.LABEL = label
        cls.API_VERSION = version
        cls.ID = id
        cls.TYPE = type_
        _G.package.loaded[className] = cls
    end
    return _G.package.loaded[className]
end

local MapThemeEventListener = setmetatable({}, {__index=Bootstrap.UnitEventListener})

------
-- Class for dispatching event
------
local MapThemeEventDispatcher = setmetatable({}, {__index=Bootstrap.UnitEventDispatcher})

-- 使わない関数
function MapThemeEventDispatcher:inheritFromUnit(_id)
    print("inheritFromUnit : This function cannot be used here")
end
function MapThemeEventDispatcher:inheritFromEnemy(_id)
    print("inheritFromEnemy : This function cannot be used here")
end

MapThemeEventDispatcher.MAPTHEME = 1
MapThemeEventDispatcher.API_VERSION = 0
MapThemeEventDispatcher.TYPE = 0
MapThemeEventDispatcher.ID = 0
MapThemeEventDispatcher.LABEL = ""
MapThemeEventDispatcher._NAME = ""

MapThemeEventDispatcher.HOOK_FUNCTIONS = {
    update = {args={"deltaTime","playerTeam","enemyTeam","customParameter"}, default=function(self, deltaTime, playerTeam, enemyTeam, customParameter) return 1 end},
    waveRun = {args={"playerTeam","enemyTeam","customParameter"}, default=function(self, playerTeam, enemyTeam, customParameter) return 1 end},
    waveEnd = {args={"playerTeam","enemyTeam","customParameter"}, default=function(self, playerTeam, enemyTeam, customParameter) return 1 end},
    takeDamageValue = {args={"target","caster","power","customParameter"}, default=function(self, target, caster, power, customParameter) return 1 end},
    takeBreakeDamageValue = {args={"target","caster","breakpower","customParameter"}, default=function(self, target, caster, breakpower, customParameter) return 1 end},
}

------
-- Inherit MapTheme class
------
function MapThemeEventDispatcher:inherit(mapThemeID)
    local name = _M.MAPTHEME_CLASS_PREFIX .. mapThemeID
    local parent = require(name)
    getmetatable(self).__index = parent
end

------
-- Publish a function to global that named `new`
------
function MapThemeEventDispatcher:publish()
    _G[_M.VARIABLE_NAME] = function(id)
        local dispatcher = self:new(id)
        print("Publish by <summoner.MapThemeEventDispatcher>")
        print(("    Label: %s"):format(self.LABEL))
        print(("    Class: %s"):format(self._NAME))
        print(("    Script ID: %s"):format(id))
        print(("    API Version: %s"):format(self.API_VERSION))
        mapThemeRegister.regist(dispatcher:generate(), id, self.API_VERSION)
        return 1
    end
end

------
-- Make an event map
------
function MapThemeEventDispatcher:generate()
    local listeners = {}
    for eventName, hook in pairs(MapThemeEventDispatcher.HOOK_FUNCTIONS) do
        if self[eventName] == nil then
            listeners[eventName] = hook.default
        else
            listeners[eventName] = _M.MapThemeEventListener.create(eventName, hook.args, self[eventName], self)
        end
    end
    return listeners
end

_M.MapThemeEventListener = MapThemeEventListener
_M.MapThemeEventDispatcher = MapThemeEventDispatcher

_G.package.loaded[_NAME] = _M
return _M
