------
-- summoner.Choreo.Components.Start
--
-- 戦闘開始時（start イベント）に Action 群を実行する Component。
-- 仕様書の「戦闘開始時」セクション（attack_delay / addSP / 初期奥義ゲージ 等）を宣言で書く。
--
-- @example
--     boss:add(Start{
--         SetAttackDelay{ 5.0 },     -- attack_delay=5.0
--         GainSP{ 40 },              -- 戦闘開始時奥義ゲージ40
--     })
--
-- 引数: Action / function のリスト（[09] / runActions）。エスケープ関数も可。
-- 補足: addSP の「演出ごとの加算量(spValue=N)」は Timeline{ addSP = GainSP{N} } で表す（別物）。
------
local _NAME = 'summoner.Choreo.Components.Start'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local function Start(actions)
    local component = { name = 'Start' }

    local function onLoad(self, event)
        Action.runActions(self, event, actions)
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
    end

    return component
end

_G.package.loaded[_NAME] = Start
return Start
