------
-- summoner.Choreo.Components.DamageRate
--
-- 行動（index）ごとに「本体側のダメージ/ブレイクの取り分」を宣言する Component。
-- オービットへ一部を委譲するとき、本体に残す倍率をここで宣言する（残りは SpawnOrbit 側で宣言）。
--
-- 出典: 107426512(正月リムル) / 108507112(超覚醒衛宮士郎) の定型 ――
--       `takeAttack`/`takeSkill` の冒頭で `setDamageRateOffset(1)` + `setBreakRate(1)` に戻し、
--       特定 index だけ 0.5 / 0.9 を掛ける。オービット側は `orbit:setDamageRateOffset(0.5/0.1)`。
--       100605512(アバドン) も同型（本体 0.5 / オービット 0.5）。
--
-- ⚠ `setDamageRateOffset` は engine の `resetStates()` で 1 に戻らない（**sticky**）。
--    一方 `setBreakRate` は `resetStates()` が毎行動 1 に戻す（TeamUnit::resetStates）。
--    そのため「宣言のない index では 1 に戻す」処理を本 Component が毎行動行う。
--    手書きで 1箇所 `setDamageRateOffset(0.9)` するだけでは、以降の全行動が 0.9 のままになる。
-- ⚠ `takeAttack` と `takeSkill` の index 空間は**別**（C++ の `attack<N>` / `skill<N>`）。
--    `attack` と `smash` に分けて宣言する（両方 1.. で重なるボスが実在する。例 2007272）。
-- ⚠ 取り分は「1ヒットあたりの分け前」に掛かる（BattleLogic:
--    `AnimationDamageRate / AnimationDamageRateSum * DamageRateOffset`）。
--    Lua から生成したオービットは Sum に加算されない（spine の event string で
--    `addOrbitSystem...` と書いた場合だけ加算される）ので、本体 0.9 ＋ オービット 0.1 = 1.0 になる。
-- ⚠ 行動が成立した回だけ適用するため `takeAttack@commit` / `takeSkill@commit` を購読する
--    （Selector の二段発火で pass1 に食われない。docs/13 §6-6）。boss version は 1.0 で足りる。
--
-- 同期: 各端末で同じ index に同じ倍率を掛けるだけの決定的処理（host 分岐不要）。
--
-- 設定:
--   attack   table  takeAttack の index => { damageRate = , breakRate = }
--   smash    table  takeSkill  の index => { damageRate = , breakRate = }
--   default  table  宣言のない index に使う値（既定 { damageRate = 1, breakRate = 1 }）
--
-- @example 奥義4 は本体 0.9・残り 0.1 を shot オービットへ委譲（108507112 と同じ配分）
--     boss:add(DamageRate{ smash = { [4] = { damageRate = 0.9, breakRate = 0.9 } } })
--     boss:add(Timeline{ Library_shot = SpawnOrbit{ anim = 'shot', type = 1, endAnim = 'hit',
--                                                   hits = 1, damageRate = 0.1, breakRate = 0.1 } })
------
local _NAME = 'summoner.Choreo.Components.DamageRate'
local _G = _G

local Events = require('summoner.Choreo.Events')

local UNITY = { damageRate = 1, breakRate = 1 }

local function DamageRate(config)
    config = config or {}
    local default = config.default or UNITY
    local component = { name = 'DamageRate' }

    -- 指定 index の取り分を適用する listener を作る（attack / smash で別テーブル）。
    -- 宣言のない index は default（=等倍）へ戻す ＝ sticky な setDamageRateOffset の後始末。
    local function applier(rates)
        return function(self, event)
            local unit = event.unit or self.unit
            if unit == nil or unit == false then
                return
            end
            local rate = default
            if rates ~= nil and event.index ~= nil and rates[event.index] ~= nil then
                rate = rates[event.index]
            end
            local damage = rate.damageRate
            if damage == nil then damage = 1 end
            local brk = rate.breakRate
            if brk == nil then brk = 1 end
            unit:setDamageRateOffset(damage)
            unit:setBreakRate(brk)
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnAttackCommit, applier(config.attack))
        dispatcher:addEventListener(Events.OnSmashCommit, applier(config.smash))
    end

    return component
end

_G.package.loaded[_NAME] = DamageRate
return DamageRate
