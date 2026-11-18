------
-- summoner.Choreo.Components.SpineSPGain
--
-- 大型ボス定型: 奥義ゲージの自然上昇を止め、spine の addSP イベント（攻撃モーション内の
-- 特定フレーム）に同期してゲージを加算する。内部は SPGain{0} + Timeline{addSP=GainSP} の合成。
-- 出典: 大型ボス最頻出の run+addSP 慣用（docs/06 §4-A。enemy/ 326ファイル）。
--
-- ⚠ spine 側に runScript-addSP イベントが打たれているボス専用。無い spine で使うと
--    ゲージが一切上がらないボスになる（ユニットボスは AttackSPGain を使うこと）。
-- ⚠ 加算はホストのみ（addSP はホスト権限操作）。
--
-- 設定:
--   value  number  addSP イベント1回のゲージ加算量（既定 20）
--
-- @example
--     boss:add(SpineSPGain{ value = 20 })
------
local _NAME = 'summoner.Choreo.Components.SpineSPGain'
local _G = _G

local SPGain = require('summoner.Choreo.Components.SPGain')
local Timeline = require('summoner.Choreo.Components.Timeline')
local Actions = require('summoner.Choreo.Actions')

local function SpineSPGain(config)
    config = config or {}
    local component = { name = 'SpineSPGain' }

    function component.initialize(dispatcher)
        dispatcher:add(SPGain{ value = 0 })   -- 自然上昇オフ（加算は spine イベント同期のみ）
        dispatcher:add(Timeline{
            addSP = Actions.GainSP{ value = config.value or config[1] or 20, hostOnly = true },
        })
    end

    return component
end

_G.package.loaded[_NAME] = SpineSPGain
return SpineSPGain
