------
-- summoner.Choreo.Components.Tests
--
-- 単体確認の土台。主要イベントを console に出力し、実機/シミュでの挙動追跡を助ける。
-- 開発時に boss:add(Tests{}) しておくと、start/attack/skill/wave/dead の発火が
-- /tmp/megast_console.log で確認できる（[11] の実機ループと併用）。
--
-- @example
--     boss:add(Tests{})                                   -- 既定イベントを出力
--     boss:add(Tests{ prefix = "2007272", events = {...} })
--
-- opts:
--     prefix  string  ログ接頭辞（既定 "Choreo.Tests"）
--     events  table   監視するイベント名の配列（既定: 主要イベント）
------
local _NAME = 'summoner.Choreo.Components.Tests'
local _G = _G

local Events = require('summoner.Choreo.Events')

local function Tests(opts)
    opts = opts or {}
    local prefix = opts.prefix or "Choreo.Tests"
    local events = opts.events or {
        Events.OnLoad, Events.OnWave, Events.OnAttack, Events.OnSmash, Events.OnDrop,
    }

    local component = { name = 'Tests' }

    local function makeLogger(eventName)
        return function(self, event)
            local extra = ""
            if event.index ~= nil then extra = extra .. " index=" .. tostring(event.index) end
            if event.waves ~= nil then extra = extra .. " wave=" .. tostring(event.waves) end
            if event.spineEvent ~= nil then extra = extra .. " spine=" .. tostring(event.spineEvent) end
            print(("[%s] %s%s"):format(prefix, eventName, extra))
        end
    end

    function component.initialize(dispatcher)
        for i = 1, #events do
            dispatcher:addEventListener(events[i], makeLogger(events[i]))
        end
    end

    return component
end

_G.package.loaded[_NAME] = Tests
return Tests
