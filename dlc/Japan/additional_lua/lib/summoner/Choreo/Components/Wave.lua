------
-- summoner.Choreo.Components.Wave
--
-- Wave 開始時に、その Wave 番号の Action 群を実行する Component。[06] パターン6-A。
--
-- ⚠ startWave イベントを使うため boss の version は 1.2 以上が必要（[01]）。
--
-- @example
--     boss:add(Wave{
--         [1] = { AttachBuff{ id=-44, type=0, value=0, time=99999, icon=37 } },
--         [3] = Say{ "WAVE3_APPEAR" },
--     })
--
-- map: Wave番号(number) => Action | function(self,event) | それらのリスト
------
local _NAME = 'summoner.Choreo.Components.Wave'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local function Wave(map)
    local component = { name = 'Wave' }

    local function onStartWave(self, event)
        local handler = map[event.waves]
        if handler ~= nil then
            Action.runActions(self, event, handler)
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnWave, onStartWave)   -- OnWave == 'startWave'
    end

    return component
end

_G.package.loaded[_NAME] = Wave
return Wave
