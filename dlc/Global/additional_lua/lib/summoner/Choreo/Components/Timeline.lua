------
-- summoner.Choreo.Components.Timeline
--
-- Spine アニメのフレームイベント（run の spineEvent）を Action へルーティングする Component。
-- [06] パターン7。`if event.spineEvent == ...` の連鎖を消す。
--
-- 同期は不要: spine アニメは各端末で同一に再生されるため、同じ spineEvent が
-- 全端末で発火する（行動選択の同期は Attack/Smash 側で済んでいる）。
--
-- @example
--     boss:add(Timeline{
--         fire  = SpawnOrbit{ anim="fireball", skill=3, hits=1 },
--         addSP = GainSP{ 20 },
--         glab  = function(self, event) --[[ 固有処理（エスケープハッチ） ]] end,
--     })
--
-- map: spineEvent名 => Action | function(self,event) | それらのリスト
------
local _NAME = 'summoner.Choreo.Components.Timeline'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local function Timeline(map)
    local component = { name = 'Timeline' }

    local function onRun(self, event)
        local handler = map[event.spineEvent]
        if handler ~= nil then
            Action.runActions(self, event, handler)
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnTimeline, onRun)   -- OnTimeline == 'run'
    end

    return component
end

_G.package.loaded[_NAME] = Timeline
return Timeline
