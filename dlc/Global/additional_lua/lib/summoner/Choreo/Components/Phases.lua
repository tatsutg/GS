------
-- summoner.Choreo.Components.Phases
--
-- HP フェーズ Component（[06] パターン2）。
-- HP がしきい値(%)を下回ったら、そのフェーズの Action 群を1度だけ実行する。
-- HPバー上にマーカーを表示し、発火時に消す。発火はホスト権限＋全端末同期（Sync）。
--
-- ⚠ update / takeDamageValue を使うため boss の version は 1.1 以上が必要（[01]）。
--
-- @example
--     boss:add(Phases{
--         { at = 70, actions = { Say{"PHASE2"} } },                           -- スキップ可（既定）
--         { at = 40, stop = true, actions = { Invincible{2} } },              -- スキップ不可
--         { at = 20, stop = true, breakthrough = true, actions = {...} },     -- ブレイク中はスルー
--         { at = 10, stop = true, deferWhileBreak = true, actions = {...} },  -- ブレイク中は保留→明けに発火
--     })
--
-- フェーズ定義（配列の各要素）:
--     at              number  HP しきい値(%)。HP がこれ以下になったら発火
--     actions         table   実行する Action / function のリスト（[09] / runActions）
--     marker          bool    HP マーカーを表示するか（既定 true）
--     stop            bool    スキップ不可: 一撃でラインを割る時 HP をラインで固定（既定 false=スキップ可）
--     breakthrough    bool    stop=true でも、ブレイク中(m_breaktime>0)なら固定せず通過させる
--     deferWhileBreak bool    ブレイク中は発火を保留し、ブレイク明け最初の update で発火（既定 false）
--
-- ⚠ breakthrough と deferWhileBreak は別の軸。breakthrough は「ブレイク中に HP を固定するか」、
--    deferWhileBreak は「ブレイク中に発火するか」を決める（両立するが用途は普通どちらか一方）。
------
local _NAME = 'summoner.Choreo.Components.Phases'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Sync = require('summoner.Choreo.Components.Sync')
local Action = require('summoner.Choreo.Action')
local Utility = require('summoner.Utility')

-- ブレイク中判定。engine の isBreak() は getIsBoss() 前提なので、Choreo は素の m_breaktime を見る
-- （実ボス慣用も `unit.m_breaktime > 0`。例: 500741513 の DPSチェックトリガー）。
local function isBreaking(unit)
    return unit.m_breaktime ~= nil and unit.m_breaktime > 0
end

local function Phases(list)
    -- HP しきい値の高い順に並べる（コピーして破壊しない）
    local phases = {}
    for i = 1, #list do
        phases[i] = list[i]
    end
    table.sort(phases, function(a, b) return (a.at or 0) > (b.at or 0) end)

    -- stop 指定のフェーズがあるか（あれば takeDamageValue を握る）
    local hasStop = false
    for i = 1, #phases do
        if phases[i].stop then hasStop = true end
    end

    -- フェーズ idx を実行（ホスト即時 / ゲスト受信時の両方で呼ばれる）
    local function firePhase(self, idx)
        local phase = phases[idx]
        if phase == nil or self._phaseFired[idx] then
            return
        end
        self._phaseFired[idx] = true
        -- マーカー除去（ブレイクスルー時は既に除去済み＝nil なのでスキップ）
        local marker = self._phaseMarkers[idx]
        if marker ~= nil then
            self.unit:removeHpMarker(marker)
            self._phaseMarkers[idx] = nil
        end
        -- Action 実行
        local event = { unit = self.unit, name = 'OnPhase', phaseIndex = idx, at = phase.at }
        Action.runActions(self, event, phase.actions)
    end

    -- start: インスタンス毎の状態 + HP マーカー設置
    -- 規約: breakthrough(ブレイク中スルー)マーカーのみシアン+白テクスチャ
    --       （実ボスの isEnableSkip 慣用＝breakthrough 専用。skip可/stop はデフォルト色）
    local function onLoad(self, event)
        self._phaseFired = {}
        self._phaseMarkers = {}
        for i = 1, #phases do
            local p = phases[i]
            if p.marker ~= false then
                local id = self.unit:addNumHpMarker((p.at or 0) * 0.01)
                self._phaseMarkers[i] = id

                -- 色: markerColor 個別指定が最優先。無ければ breakthrough のみシアン。
                local color = p.markerColor
                if color == nil and p.breakthrough then
                    color = { 0, 255, 255 }   -- 規約色: シアン
                end
                if color ~= nil then
                    self.unit:changeHpMarkerColor(id, color[1], color[2], color[3])
                end
                -- breakthrough マーカーは白テクスチャ（markerTexture=false で抑止可）
                if p.breakthrough and p.markerTexture ~= false then
                    self.unit:changeHpMarkerTexture(id,
                        "battle_marker_hp_marker_white_1.png",
                        "battle_marker_hp_marker_white_2.png",
                        "unit/animation/battle_marker_white.plist")
                end
            end
        end
    end

    -- update: HP を監視し、ホストがしきい値到達を判定して同期発火
    local function onUpdate(self, event)
        if not self.isHostPlayer then
            return
        end
        local hp = Utility.getUnitHealthRate(event.unit) * 100
        for i = 1, #phases do
            if not self._phaseFired[i] and (phases[i].at or 0) >= hp then
                -- deferWhileBreak: ブレイク中は発火を保留し、ブレイク明けの update で発火する。
                -- 判定は毎フレーム走るので、ブレイクが明けた最初の update で自動的に成立する
                -- （実ボス慣用の「update の条件に m_breaktime <= 0 を並べる」と同じ形）。
                -- ホスト限定＋hostDecide 経由なので、保留してもゲストとの同期は崩れない。
                if not (phases[i].deferWhileBreak and isBreaking(event.unit)) then
                    self:hostDecide('phase', i)   -- firePhase を全端末で実行（配信）
                end
            end
        end
    end

    -- takeDamageValue: stop フェーズの HP クランプ（スキップ不可 / ブレイクスルー）
    -- 値変換イベント: event.value を加工して返す。全端末で決定的に動かす（ホスト限定にしない）。
    local function onDamageValue(self, event)
        local unit = event.unit
        local afterHp = unit:getHP() - event.value
        for i = 1, #phases do
            local p = phases[i]
            if p.stop and not self._phaseFired[i] then
                local border = unit:getCalcHPMAX() * (p.at or 0) * 0.01
                -- crossing: ライン上から、この一撃で割る場合
                -- pinned:   deferWhileBreak の発火保留中（HP がライン上に張り付いている間）。
                --           このとき getHP() > border は成立しないので crossing では拾えず、
                --           放置すると以降のヒットが素通りしてラインを割る＝スキップ不可が破れる。
                --           原典 bossPreparation.adjustHpFlg も HP<=border の間ずっと境界で止め続ける。
                local crossing = unit:getHP() > border and border >= afterHp
                local pinned = p.deferWhileBreak and unit:getHP() <= border
                if crossing or pinned then
                    if p.breakthrough and isBreaking(unit) then
                        -- ブレイク中: 固定せず通過。マーカーを breakthrough で割る。
                        local marker = self._phaseMarkers[i]
                        if marker ~= nil then
                            unit:removeHpMarker(marker, true)
                            self._phaseMarkers[i] = nil
                        end
                        -- 通過 → update で HP<=at を見て発火
                    else
                        -- HP をラインで固定（スキップ不可）。発火は次の update
                        -- （deferWhileBreak ならブレイク明けの update）。
                        if crossing then
                            unit:setHP(border)
                            -- HPトリガー境界の被ブレイクを次1回ロック（原典 TenebriusTemplate calcDamageValue の
                            -- 境界毎 breakSkip 再武装に相当）。Break が無ければ無害。各端末ローカルで決定的。
                            -- pinned（保留中の継続クランプ）では再武装しない＝境界1回きりの原典どおり。
                            self._breakSkip = true
                        end
                        event.value = 0
                        return
                    end
                end
            end
        end
    end

    local component = { name = 'Phases' }

    function component.initialize(dispatcher)
        if not dispatcher:hasComponent('Sync') then
            dispatcher:add(Sync.create())
        end
        dispatcher:openChannel('phase', firePhase)
        -- 各 phase の actions 内の Chance を宣言順(sort 済み phases)で静的 pre-open（per-instance/port 決定性）
        for i = 1, #phases do
            Action.preregisterChances(dispatcher, phases[i].actions)
        end
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
        if hasStop then
            dispatcher:addEventListener(Events.takeDamageValue, onDamageValue)
        end
    end

    return component
end

_G.package.loaded[_NAME] = Phases
return Phases
