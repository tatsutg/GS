------
-- summoner.Choreo.Components.AttackSPGain
--
-- 通常攻撃ごとにSPを加算する（奥義直後の1回はスキップ）。
-- 旧テンプレートの addSpSkipFLG / addSP ロジックに相当。
-- SP加算はホストのみ実行（addSP はホスト権限操作）。
--
-- 購読は OnAttackCommit / OnSmashCommit（コミット系）。
-- 生の OnAttack(takeAttack) は Attack(Selector) の二段発火で
-- pass1(抽選)/pass2(再生) の2回流れるため、素朴に購読すると二重加算する。
-- コミット系は prevent されず完走した発火（=行動が実際に成立する回）だけ来るので、
-- Component の宣言順や Attack の有無に依存せず1行動1回になる。
--
-- @example
--     boss:add(AttackSPGain{ value = 30 })            -- 通常攻撃ごとにSP+30（奥義後1回スキップ）
--     boss:add(AttackSPGain{ value = 30, noSkip = true }) -- 奥義後もスキップしない
--     -- 状態/フェーズで加算量そのものを変える（Regen/SetRegen・SPGain/SetSPGain と同じ setter 規約）:
--     boss:add(Mode{ initial = 'normal', states = {
--         normal = { onEnter = { SetAttackSPGain{ 20 } } },
--         dash   = { onEnter = { SetAttackSPGain{ 40 } } },   -- 爆走状態は Add SP=40
--     } })
--
-- 設定:
--   value   number   通常攻撃1回あたりのSP加算量（SetAttackSPGain で実行時に変更可）
--   noSkip  boolean  trueのとき奥義後スキップを無効化（デフォルト: false）
--
-- SetAttackSPGain 引数:
--   value / 位置引数  絶対値セット ／ add  現在値からの相対（負も可・下限0）
--
-- 動的ボーナス:
--   dispatcher の self._attackSPGainBonus（数値・未設定=0）を value に加算する。
--   「スキルで Add SP 自体を底上げし、以降の全通常攻撃に効かせる」用途。
--   例（真EX シャルヴァレ スキル3・最大3回で +15）:
--     escape で self._attackSPGainBonus = math.min(count, 3) * 5 を設定 → 以降 addSP(value+bonus)
------
local _NAME = 'summoner.Choreo.Components.AttackSPGain'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local makeAttackSPGain

local AttackSPGain = setmetatable({}, {
    __call = function(_, config) return makeAttackSPGain(config) end
})

function makeAttackSPGain(config)
    config = config or {}
    local value = config.value or 0
    local noSkip = config.noSkip or false
    local component = { name = 'AttackSPGain' }

    local SKIP_KEY = 'AttackSPGain_skip'

    function component.initialize(dispatcher)
        local bossUnit = nil  -- OnLoad（バトル開始時）でボス自身をキャプチャ

        dispatcher:addEventListener(Events.OnLoad, function(self, event)
            bossUnit = event.unit or self.unit
            -- 加算量は per-instance に持つ（宣言値が初期値。SetAttackSPGain で実行時に変更する）。
            -- クロージャ変数に持つと同じボスIDの複数体・リトライで状態を共有する（docs/13 §6-3）。
            self._attackSPGainValue = value
        end)

        dispatcher:addEventListener(Events.OnSmashCommit, function(self, event)
            if noSkip then return end
            if not bossUnit then return end
            if bossUnit:getParameter(SKIP_KEY) ~= 'true' then
                bossUnit:setParameter(SKIP_KEY, 'true')
            end
        end)

        dispatcher:addEventListener(Events.OnAttackCommit, function(self, event)
            if not bossUnit then return end
            if bossUnit:getParameter(SKIP_KEY) == 'true' then
                bossUnit:setParameter(SKIP_KEY, 'false')
                return  -- 奥義後の最初の通常攻撃: スキップ
            end
            if self.isHostPlayer then
                -- 基本加算量 value ＋ 動的ボーナス（dispatcher の _attackSPGainBonus。未設定なら0）。
                -- 「スキルで Add SP 自体を底上げし以降の全通常攻撃に効く」用途（真EX シャルヴァレのスキル3等）。
                -- 奥義後スキップと同じ addSP 呼び出し内なのでボーナスもスキップに追従する。
                local base = self._attackSPGainValue
                if base == nil then base = value end
                event.unit:addSP(base + (self._attackSPGainBonus or 0))
            end
        end)
    end

    return component
end

-- 加算量を実行時に変更（Mode の onEnter / HPフェーズ 等から）。add で現在値からの相対指定。
-- ⚠ 動的ボーナス(_attackSPGainBonus)とは別枠（こちらは基本量そのもの）。合計 = 基本量 + ボーナス。
AttackSPGain.Set = Action.define('SetAttackSPGain', function(a, d, e)
    if a.add then
        local v = (d._attackSPGainValue or 0) + a.add
        d._attackSPGainValue = v > 0 and v or 0    -- 下限0（負の加算量を作らない）
    else
        d._attackSPGainValue = a.value or a[1] or 0
    end
end)

_G.package.loaded[_NAME] = AttackSPGain
return AttackSPGain
