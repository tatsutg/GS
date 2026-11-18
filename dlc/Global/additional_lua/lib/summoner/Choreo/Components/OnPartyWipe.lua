------
-- summoner.Choreo.Components.OnPartyWipe
--
-- プレイヤーユニットが全滅したら actions を実行する（全滅時の INFO 等）。
-- engine は全滅を Lua に知らせるイベントを持たないので、update でプレイヤーの枠を見て判定する。
-- 出典: enemy/2084710.lua（超襲来マリカ 真EX極）の checkPartyWipe
--       （update で「一度はユニットを見ている＋生存0」を全滅とみなし、1回だけメッセージを出す）。
--
-- ⚠ update を使うため boss version >= 1.1。
-- ⚠ バトルステートは条件にしない（全滅を検知する前に切り替わることがある＝原典のコメント）。
-- ⚠ 一度も生存ユニットを見ていない間は判定しない（登場直後の空振りを防ぐ）。
-- ⚠ 戦闘不能の枠は engine が getTeamUnit で nil を返す（交代・リザーブで空いた枠も同じ）。
--
-- 同期不要: 各端末が同じチーム状態を見て同じ結果になる（決定的。メッセージは端末ごとに出す。原典も host 分岐なし）。
--
-- 設定:
--   actions  Action|list  全滅したときに実行する
--   once     bool         true（既定）: 1戦闘1回（原典どおり）。
--                         false: 生存ユニットを再び見たら再武装し、全滅のたびに実行する（コンティニュー後も出す）
--   slots    number       見るプレイヤーの枠数（既定8）
--
-- @example
--     boss:add(OnPartyWipe{ actions = { Say{ key = "PARTY_DEAD_MESSAGE1", text = "…", color = Color.green } } })
------
local _NAME = 'summoner.Choreo.Components.OnPartyWipe'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local function OnPartyWipe(config)
    config = config or {}
    local actions = config.actions
    local once = config.once ~= false
    local slots = config.slots or 8
    local component = { name = 'OnPartyWipe' }

    local function onLoad(self, event)
        self._partySeen = false
        self._partyWiped = false
    end

    local function onUpdate(self, event)
        if self._partyWiped and once then
            return
        end
        local team = megast.Battle:getInstance():getTeam(true)
        for i = 0, slots - 1 do
            if team:getTeamUnit(i) ~= nil then
                self._partySeen = true
                self._partyWiped = false      -- once=false の再武装（生存ユニットを見た）
                return
            end
        end
        if not self._partySeen or self._partyWiped then
            return
        end
        self._partyWiped = true
        Action.runActions(self, event, actions)
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = OnPartyWipe
return OnPartyWipe
