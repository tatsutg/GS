------
-- summoner.Choreo.Components.PlayerStatus
--
-- 相手チーム（既定＝プレイヤー）を1体ずつ監視し、状態異常の変化を2つの粒度でアクションへ流す。
--   1. `onEnter` / `onExit` … 「**状態異常を持っているか**」の 0/1 エッジ（type をまとめて1つ扱い）
--   2. `onInflict`          … 「**その type が新規に付いた人数**」を type ごとに数える（1フレーム分を合算）
-- [[OnStatus]] が「自分（ボス）」を見るのに対し、こちらは相手側の各ユニットを見る。
--
-- アクションは Action.runActions 経由なので**バフ付与に限らない**。被ダメ補正の窓を開ける・
-- メッセージ・固定ダメージ・Mode 遷移・エスケープ関数まで、どの Action でも書ける。
--
-- ⚠ update を使うため boss version >= 1.1。
--
-- 出典: 実ボス慣用（プレイヤー各体を getTeamUnit で走査し findConditionWithType / findConditionValue で
--   状態異常を判定する。2081580 の findDeBuffFlg / mine_5026 の状態別補正）の「継続監視 ＋ エッジ検出」への宣言化。
--   付与数カウントは実ボスの撃破カウント方式（unit/103907112・[[Minions]] の onKill）と同じ
--   「そのフレームぶんを合算して1回で積む」規約に揃えてある。
--
-- 同期: 状態異常は engine が全端末へ同じものを見せ、付与する condition も端末ローカル決定的なので
--   host 分岐しない（全端末で同じ判定 → 同じ付与）。ホスト限定にすると**ゲストに condition が付かず
--   desync する**（Chance の設計注記と同じ理由）。⚠ 実機マルチ未検証。
--
-- 重複しない（1ユニット1セット）: `onEnter` は立ち上がりで1回だけ実行するため、状態異常が複数重なっても
--   効果は重ならない（仕様書の「状態異常が複数重複してもこの効果は重複しない」がそのまま満たされる）。
--
-- ⚠ 戦闘不能（getTeamUnit が nil）になった枠は監視対象から外し、フラグを捨てる。
--    復活すると「状態異常あり」で再度 onEnter が走り、残っている状態異常は onInflict でも数え直される。
--
-- @example 状態異常のプレイヤーユニットは全ステータス20%ダウン（重複しない）
--     boss:add(PlayerStatus{
--         onEnter = {
--             AttachBuff{ id = 28100001, type = 2,  value = -20, icon = 211, group = -1 },  -- 最大HP
--             AttachBuff{ id = 28100002, type = 13, value = -20, icon = 0,   group = -1 },  -- 攻撃力
--             AttachBuff{ id = 28100003, type = 15, value = -20, icon = 0,   group = -1 },  -- 防御力
--         },
--         onExit = { RemoveBuff{ id = 28100001 }, RemoveBuff{ id = 28100002 }, RemoveBuff{ id = 28100003 } },
--     })
--
-- @example 状態異常を付与するたび、対応する属性耐性が付与人数ぶん上がる（アイコンにカウント・最大20）
--     boss:add(PlayerStatus{
--         onInflict = {   -- [監視する condition type] = そのとき実行する Action 群
--             [97] = { StackBuff{ id = 28100011, type = 61, value = 10, max = 20, icon = 30 } },  -- 燃焼→炎属性耐性
--             [94] = { StackBuff{ id = 28100012, type = 62, value = 10, max = 20, icon = 31 } },  -- 病気→水属性耐性
--             [90] = { StackBuff{ id = 28100013, type = 63, value = 10, max = 20, icon = 32 } },  -- 毒  →樹属性耐性
--         },
--     })
--     -- スキル1発で3体に燃焼が付けば event.stacks = 3 ＝ カウント +3（＝炎属性耐性 +30%）。
--
-- 設定:
--   types      table        onEnter/onExit が監視する condition type（既定 Choreo.BadStatus = 89..97 の全状態異常）
--   onEnter    Action|list  「状態異常なし → あり」の立ち上がりで1回（event.unit = そのユニット）
--   onExit     Action|list  「あり → なし」の立ち下がりで1回
--   onInflict  table        { [condition type] = Action|list }。その type が新規付与された時に1回
--                           （event.unit = **ボス自身** / event.stacks = そのフレームの付与人数 /
--                            event.status = type / event.units = 付与されたユニットの配列）
--   side       string       監視するチーム 'player'(既定) | 'enemy'
--   slots      number       走査する枠数（既定8）
--   key        string       複数の PlayerStatus を併用するとき状態キーを分ける（任意）
--
-- ⚠ `onInflict` の対象 type は **onInflict のキーだけ**（`types` とは独立）。
-- ⚠ 同フレームの複数人ぶんは **1回にまとめて** `event.stacks` で渡す（addCondition のクールタイムで
--    複数回叩くと1回ぶんしか乗らないため。[[Minions]] の onKill と同じ規約）。
-- ⚠ 「誰が付与したか」は engine から取れないため、**ボス以外の要因で付いた状態異常も数える**
--    （味方の自傷・フィールド効果など）。厳密に自分の付与だけを数えたい場合は onUse 側で絞ること。
------
local _NAME = 'summoner.Choreo.Components.PlayerStatus'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')
local Actions = require('summoner.Choreo.Actions')

local function PlayerStatus(config)
    config = config or {}
    local types = config.types or Actions.BadStatus
    local slots = config.slots or 8
    local isPlayerSide = config.side ~= 'enemy'
    local flagKey = '_playerStatus' .. (config.key or '')
    local infKey = flagKey .. 'Inflict'
    local component = { name = 'PlayerStatus' }

    -- onInflict のキー（監視する type）を昇順で固定する。
    -- pairs の列挙順は不定なので、そのまま回すと端末ごとにアクションの実行順が変わりうる。
    local inflictTypes = {}
    if config.onInflict ~= nil then
        for t in pairs(config.onInflict) do
            inflictTypes[#inflictTypes + 1] = t
        end
        table.sort(inflictTypes)
    end

    -- 状態は per-instance（規約 §6-3）。クロージャに持つと同ID複数体・リトライで共有される。
    local function onLoad(self, event)
        self[flagKey] = {}       -- 枠番号 => 状態異常を持っているか
        local inf = {}
        for i = 1, #inflictTypes do
            inf[inflictTypes[i]] = {}   -- type => { 枠番号 => その type を持っているか }
        end
        self[infKey] = inf
    end

    local function onUpdate(self, event)
        local flags = self[flagKey]
        if flags == nil then return end
        local team = megast.Battle:getInstance():getTeam(isPlayerSide)
        if team == nil then return end
        local boss = event.unit or self.unit
        local inf = self[infKey]

        -- そのフレームに新規付与された人数（type ごと）。1回にまとめて積むため先に集計する。
        local gained, gainedUnits = nil, nil
        if #inflictTypes > 0 then
            gained, gainedUnits = {}, {}
            for i = 1, #inflictTypes do
                gained[inflictTypes[i]] = 0
                gainedUnits[inflictTypes[i]] = {}
            end
        end

        for i = 0, slots - 1 do
            -- 第2引数なし＝戦闘不能ユニットは nil。死んでいる間は監視対象外にする。
            local u = team:getTeamUnit(i)
            local cond = (u ~= nil) and u:getTeamUnitCondition() or nil

            -- 1. 状態異常を持っているかの 0/1 エッジ（onEnter / onExit）
            if u == nil then
                flags[i] = nil
            else
                local hit = nil
                for k = 1, #types do
                    if cond:findConditionWithType(types[k]) ~= nil then
                        hit = types[k]
                        break
                    end
                end
                local has = hit ~= nil
                if has ~= (flags[i] == true) then
                    flags[i] = has
                    local actions
                    if has then
                        actions = config.onEnter
                    else
                        actions = config.onExit
                    end
                    if actions ~= nil then
                        Action.runActions(self, {
                            unit = u, index = i, status = hit, boss = boss,
                            name = 'OnPlayerStatus',
                        }, actions)
                    end
                end
            end

            -- 2. type ごとの新規付与カウント（onInflict）
            for k = 1, #inflictTypes do
                local t = inflictTypes[k]
                local seen = inf[t]
                if u == nil then
                    seen[i] = nil                     -- 戦闘不能で捨てる（復活後は付け直し扱い）
                elseif cond:findConditionWithType(t) ~= nil then
                    if seen[i] ~= true then
                        seen[i] = true
                        gained[t] = gained[t] + 1
                        gainedUnits[t][#gainedUnits[t] + 1] = u
                    end
                else
                    seen[i] = false                   -- 解除。次に付いたらまた数える
                end
            end
        end

        -- 集計ぶんを type ごとに1回で流す（event.stacks が StackBuff の加算数になる）
        for k = 1, #inflictTypes do
            local t = inflictTypes[k]
            if gained[t] > 0 then
                Action.runActions(self, {
                    unit = boss, boss = boss, status = t,
                    stacks = gained[t], units = gainedUnits[t],
                    name = 'OnStatusInflict',
                }, config.onInflict[t])
            end
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = PlayerStatus
return PlayerStatus
