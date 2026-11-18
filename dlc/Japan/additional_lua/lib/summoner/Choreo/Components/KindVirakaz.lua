------
-- summoner.Choreo.Components.KindVirakaz
--
-- ボス種プリセット: ヴィラカーズ種（base_unit_id 40125・unit 501251513）。
-- spine 501251513 由来の種の定型を、設定を書いたものだけ内部で add する薄い皿（全部 opt-in）。
-- 出典: enemy/ のヴィラカーズ実装 6 本（2064525 魔族遺跡hard / 2064520 normal / 2005537 闇冥の遺跡11層 /
--   5041200 影天景 / mine_5014・mine_6011 鉱山）＋ spine 実測。
--
-- spine の性質（種の注意点）:
--   - runScript-addSP は attack1-3 にしか無い（skill1-5・attack4 には無い）＝奥義中はゲージが伸びない。
--   - attack4 と skill5 は「倒れ込む」モーション（3.97秒・末尾に runScript-forceDead）。
--     forceDead を拾うのは selfDestruct を書いたときだけなので、通常ローテで attack4/skill5 を使っても死なない。
--   - out アニメは長さ0（イベントも無し）。退場の見た目が要るなら outAnim で差し替える。
--   - スキンは default のみ（2005537 の setSkin("rage") は空振り）。
--   - エフェクト spine 50125ef のループは charge_loop（2064525 が指定する charge_short は ef に存在しない）。
--
-- 設定（すべて省略可＝既定 OFF）:
--   spineSP       number|table   SpineSPGain の設定（数値＝addSP イベント1回の加算量）。
--                                出典: 2064525 / 5041200 の run `if event.spineEvent == "addSP"`。
--   selfDestruct  true|table     forceDead イベントで自身の HP を 0 にする（ホストのみ・HPはホスト権威）。
--                                { actions = {...} } で HP0 の直前に Action を実行。
--                                出典: 2005537 の run `if event.spineEvent == "forceDead" then setHP(0)`（HP1%の最後の自爆）。
--   outAnim       true|string    退場時(takeOut)の本体アニメを差し替える（true＝"skill5"）。
--                                出典: 2064525 の takeOut `setNextAnimationName("skill5")`。
--                                ⚠ takeOut は version 2.3 のイベント。codegen は outAnim 指定時に 2.3 へ引き上げる。
--
-- @example
--     boss:add(KindVirakaz{ spineSP = 20 })
--     boss:add(KindVirakaz{ spineSP = 20, outAnim = true })                 -- 退場で倒れ込む（2064525）
--     boss:add(KindVirakaz{ selfDestruct = true })                          -- attack4/skill5 の最後で HP0（2005537）
------
local _NAME = 'summoner.Choreo.Components.KindVirakaz'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')
local SpineSPGain = require('summoner.Choreo.Components.SpineSPGain')

local function KindVirakaz(config)
    config = config or {}
    local component = { name = 'KindVirakaz' }

    function component.initialize(dispatcher)
        local sp = config.spineSP
        if sp ~= nil then
            dispatcher:add(SpineSPGain(type(sp) == 'table' and sp or { value = sp }))
        end

        local destruct = config.selfDestruct
        if destruct ~= nil and destruct ~= false then
            local actions = type(destruct) == 'table' and destruct.actions or nil
            dispatcher:addEventListener(Events.OnTimeline, function(self, event)
                if event.spineEvent ~= 'forceDead' then return end
                Action.runActions(self, event, actions)
                if not self.isHostPlayer then return end   -- ゲストはホストからの HP 同期で死ぬ
                local unit = event.unit or self.unit
                unit:setHP(0)
            end)
        end

        local out = config.outAnim
        if out ~= nil and out ~= false then
            local name = type(out) == 'string' and out or 'skill5'
            dispatcher:addEventListener(Events.takeOut, function(self, event)
                local unit = event.unit or self.unit
                unit:setNextAnimationName(name)
            end)
        end
    end

    return component
end

_G.package.loaded[_NAME] = KindVirakaz
return KindVirakaz
