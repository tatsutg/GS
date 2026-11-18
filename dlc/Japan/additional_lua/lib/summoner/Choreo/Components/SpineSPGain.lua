------
-- summoner.Choreo.Components.SpineSPGain
--
-- 大型ボス定型: 奥義ゲージの自然上昇を止め、spine の addSP イベント（攻撃モーション内の
-- 特定フレーム）に同期してゲージを加算する。内部は SPGain{0} + Timeline{addSP=…} の合成。
-- 出典: 大型ボス最頻出の run+addSP 慣用（docs/06 §4-A。enemy/ 326ファイル）。
--
-- 加算量は SetSpineSPGain アクションで実行時に変更できる（HPフェーズで「Add SP = 25」へ上げる 等。
-- Regen/SetRegen・SPGain/SetSPGain・AttackSPGain/SetAttackSPGain と同じ setter Action 規約）。
-- 出典: gb_104601（熾紅フロガスピサ）が HPトリガーで self.spValue を GD.HP30addSP に差し替える慣用。
--
-- ⚠ spine 側に runScript-addSP イベントが打たれているボス専用。無い spine で使うと
--    ゲージが一切上がらないボスになる（ユニットボスは AttackSPGain を使うこと）。
--    ⚠ アニメごとに有無が違う。例: 熾紅フロガスピサ(500071113) は attack1-5 / skill2 にはあるが
--       attack6 / skill1 / skill3 / skill4 には無い＝その行動中はゲージが伸びない（原典どおり）。
-- ⚠ 加算はホストのみ（addSP はホスト権限操作）。
--
-- 設定:
--   value  number  addSP イベント1回のゲージ加算量（既定 20）。SetSpineSPGain で実行時に変更可。
--
-- SetSpineSPGain 引数:
--   value / 位置引数  絶対値セット ／ add  現在値からの相対（負も可・下限0）
--
-- @example
--     boss:add(SpineSPGain{ value = 20 })
--     boss:add(Phases{ { at = 75, actions = { SetSpineSPGain{ 25 } } } })   -- HP75% で Add SP=25
------
local _NAME = 'summoner.Choreo.Components.SpineSPGain'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')
local SPGain = require('summoner.Choreo.Components.SPGain')
local Timeline = require('summoner.Choreo.Components.Timeline')

local makeSpineSPGain

local SpineSPGain = setmetatable({}, {
    __call = function(_, config) return makeSpineSPGain(config) end
})

function makeSpineSPGain(config)
    config = config or {}
    local value = config.value or config[1] or 20
    local component = { name = 'SpineSPGain' }

    function component.initialize(dispatcher)
        dispatcher:add(SPGain{ value = 0 })   -- 自然上昇オフ（加算は spine イベント同期のみ）
        dispatcher:add(Timeline{
            -- 加算量は per-instance に持つ（宣言値が初期値。SetSpineSPGain で実行時に変更する）。
            -- クロージャ変数に持つと同じボスIDの複数体・リトライで状態を共有する（docs/13 §6-3）。
            addSP = function(self, event)
                if not self.isHostPlayer then return end
                local v = self._spineSPGainValue
                if v == nil then v = value end
                local unit = event.unit or self.unit
                unit:addSP(v)
            end,
        })
        dispatcher:addEventListener(Events.OnLoad, function(self, event)
            self._spineSPGainValue = value
        end)
    end

    return component
end

-- 加算量を実行時に変更（HPフェーズ / Mode の onEnter 等から）。add で現在値からの相対指定。
SpineSPGain.Set = Action.define('SetSpineSPGain', function(a, d, e)
    if a.add then
        local v = (d._spineSPGainValue or 0) + a.add
        d._spineSPGainValue = v > 0 and v or 0    -- 下限0（負の加算量を作らない）
    else
        d._spineSPGainValue = a.value or a[1] or 0
    end
end)

_G.package.loaded[_NAME] = SpineSPGain
return SpineSPGain
