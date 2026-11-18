------
-- summoner.Choreo.Components.OnStatus
--
-- 自分が指定の状態異常になった／解除されたら（0/1 のエッジで）アクションを実行する。
-- 例: 飛行中に気絶/麻痺/氷結 → 通常状態へ復帰＋耐性UP。
--     自分に付けた燃焼が外部要因（相手の奥義効果・氷結付与）で消えたら状態を巻き戻す。
-- 出典: 状態異常検知（update で findConditionWithType）。
-- `onEnd` は相手チームを見る [[PlayerStatus]] の `onExit`（立ち下がり）と同じ意味論を自分側にも用意したもの。
--
-- ⚠ update を使うため boss version >= 1.1。
--
-- 同期: **host 分岐しない**（全端末が自分で判定して自分で実行する）。
--   状態異常は engine が全端末へ同じものを見せ、付与/除去する condition も端末ローカル決定的なので、
--   各端末が同じエッジを観測して同じ結果になる。[[PlayerStatus]] と同じ設計。
--   ⚠ **ホスト限定にしてはいけない。** ゲストで Mode/バフが巻き戻らず desync する
--      （2026-09-18 実機で発生: ゲストが氷結を入れるとホストだけ燃焼状態が解けて、
--       ゲストは Mode=burn のまま＝ゲストの攻撃だけ被ダメ補正 1/100 が残り続けた）。
--   ⚠ [[Phases]] が hostDecide 経由なのは **HP がホスト権威**だから。状態異常は engine 同期なので
--      同じ扱いにする必要はなく、Sync チャンネルも要らない。
--   ⚠ 「全体で1回だけ」実行したい副作用（敵召喚など）は、**Action 側が自前でホスト限定にする**
--      規約（`SpawnEnemy` / `GainSP{hostOnly}`）。Component 側では絞らない。
--
-- @example
--     boss:add(OnStatus{ types = { 89, 90, 91 },   -- 気絶/麻痺/氷結 の condition type
--                        actions = { SetMode{ "normal" }, Say{ text = "解除成功" } } })
--
-- @example 自分に付けた燃焼が消えたら燃焼状態を抜ける（後始末は Mode の onExit が持つ）
--     boss:add(OnStatus{ key = "burn", types = { 97 }, onEnd = { SetMode{ "normal" } } })
--
-- 設定:
--   types    table   検知する condition type（いずれか present で発火）
--   actions  Action|list  **立ち上がり**（無し → あり）で1回。別名 `onStart`
--   onEnd    Action|list  **立ち下がり**（あり → 無し）で1回
--   key      string  複数 OnStatus を併用するとき状態キーを分ける（任意）
--   once     bool    true で `actions` / `onEnd` をそれぞれ戦闘中1回だけにする（再武装しない）。
--                    「一度氷結にかかると氷結耐性アップ」「氷結で一度のみリセット可能」の型
--   max      number  `actions` を戦闘中この回数まで実行する（`onEnd` は対象外）。
--                    「毒状態になる度に毒耐性アップ（最大10回まで）」の型
--
-- ⚠ `onEnd` は「一度 present を観測した後」にしか発火しない（開幕から無い状態では発火しない）。
--    そのため `actions` を書かず `onEnd` だけを宣言しても、意図しない初回発火は起きない。
-- ⚠ 後始末（バフ除去・ゲージ非表示・INFO）は **`onEnd` に直接書かず [[Mode]] の `onExit` に集約する**のが定石。
--    解除経路が複数（ゲージ破壊／別の状態異常／当該状態異常の消失）になっても後始末が1箇所で済み、
--    `SetMode` は**同一状態なら無視される**ため、どの経路から来ても二重実行にならない。
-- ⚠ ホスト限定で判定・実行する（`actions` と同じ）。`SetMode` のような **Lua 側だけの状態**を
--    書き換える場合、ゲストは追従しない。condition の付け外しは engine が同期するので揃う。
------
local _NAME = 'summoner.Choreo.Components.OnStatus'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local function OnStatus(config)
    config = config or {}
    local types = config.types or {}
    local actions = config.actions or config.onStart
    local onEnd = config.onEnd
    local once = config.once
    local max = config.max
    local stateKey = '_onStatus' .. (config.key or '')
    local startDoneKey = stateKey .. 'StartDone'   -- once: actions 実行済み
    local endDoneKey = stateKey .. 'EndDone'       -- once: onEnd 実行済み
    local startCountKey = stateKey .. 'StartCount' -- max: actions の実行回数
    local component = { name = 'OnStatus' }

    -- start: per-instance 状態を初期化（規約 §6-3）
    local function onLoad(self, event)
        self[startDoneKey] = false
        self[endDoneKey] = false
        self[startCountKey] = 0
    end

    local function onUpdate(self, event)
        -- ⚠ host 分岐しない（ヘッダの「同期」参照）。ゲストも自分で判定して自分で実行する。
        local cond = event.unit:getTeamUnitCondition()
        local present = false
        for i = 1, #types do
            if cond:findConditionWithType(types[i]) ~= nil then
                present = true
                break
            end
        end
        if present then
            if not self[stateKey] then            -- 立ち上がりエッジ
                self[stateKey] = true
                if actions ~= nil and not (once and self[startDoneKey])
                   and not (max ~= nil and (self[startCountKey] or 0) >= max) then
                    self[startDoneKey] = true
                    self[startCountKey] = (self[startCountKey] or 0) + 1
                    Action.runActions(self, event, actions)
                end
            end
        else
            -- 立ち下がりエッジ（あり → 無し）。一度も present を観測していなければ発火しない。
            if self[stateKey] and onEnd ~= nil and not (once and self[endDoneKey]) then
                self[endDoneKey] = true
                Action.runActions(self, event, onEnd)
            end
            self[stateKey] = false                -- 解除されたら再武装（once は actions / onEnd 側で止める）
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = OnStatus
return OnStatus
