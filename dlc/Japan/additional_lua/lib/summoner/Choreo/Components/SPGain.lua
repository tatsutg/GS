------
-- summoner.Choreo.Components.SPGain
--
-- SP（奥義ゲージ）の上昇率 = addSP を宣言する（unit:setSPGainValue）。0 で奥義封印。
-- 上昇率は SetSPGain アクションで実行時に変更できる（HPフェーズで後半から上げる /
-- Mode の onEnter で状態別に変える 等。Regen/SetRegen と同じ setter Action 規約）。
-- 出典: 実ボス慣用（setSPGainValue。docs/06 §4-A、炎怪鳥 99030001 の Mode onEnter）。
--
-- ⚠ 「今すぐ N 加算」は GainSP アクション（別物・即時加算）。本 Component は上昇率の宣言。
-- 同期: 全クライアント同一の決定的セットなので host 分岐不要（SP の加算/消費は engine が同期）。
--
-- @example
--     boss:add(SPGain{ value = 30 })           -- addSP=30
--     -- HP50% から上昇率を上げる（絶対値 / 現在値からの相対）:
--     boss:add(Phases{ { at = 50, actions = { SetSPGain{ 60 } } },
--                      { at = 30, actions = { SetSPGain{ add = 20 } } } })
--
-- 設定:
--   value  number  SP上昇率（既定0 = 奥義ゲージ停止）。SetSPGain で変更可。
-- SetSPGain 引数:
--   value / 位置引数  絶対値セット ／ add  現在値(getSPGainValue)からの相対（負も可・下限0）
------
local _NAME = 'summoner.Choreo.Components.SPGain'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local makeSPGain

local SPGain = setmetatable({}, {
    __call = function(_, config) return makeSPGain(config) end
})

function makeSPGain(config)
    config = config or {}
    local value = config.value or config[1] or 0
    local component = { name = 'SPGain' }

    local function onLoad(self, event)
        local unit = event.unit or self.unit
        unit:setSPGainValue(value)
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
    end

    return component
end

-- 上昇率を実行時に変更（HPフェーズ・Mode onEnter 等から）。add で現在値からの相対指定。
SPGain.Set = Action.define('SetSPGain', function(a, d, e)
    local unit = Action.resolveTarget(a, d, e)
    if a.add then
        local v = unit:getSPGainValue() + a.add
        unit:setSPGainValue(v > 0 and v or 0)      -- 下限0（負の上昇率を作らない）
    else
        unit:setSPGainValue(a.value or a[1] or 0)
    end
end)

_G.package.loaded[_NAME] = SPGain
return SPGain
