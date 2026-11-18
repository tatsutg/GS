------
-- summoner.Choreo.Components.Minions
--
-- 雑魚（自チーム＝敵チーム側の指定 enemyID）の生存/撃破を監視し、宣言したアクションを実行する。
--   - 0体 → 1体以上 の立ち上がりで onAlive（例: ボスの防御力アップを付与）
--   - 1体以上 → 0体 の立ち下がりで onEmpty（例: そのバフを除去）
--   - 撃破1体につき onKill（同時撃破は event.stacks に合算して**1回**で実行）
--
-- ⚠ update を使うため boss version >= 1.1。
--
-- 出典: 4002300（findFriend / friendCountBuff / findFriendBuff）・gb_601601（雑魚数で軽減）の宣言化。
--
-- 撃破判定（ここを間違えると必ずバグる）:
--   engine の `getTeamUnit(i)` は死亡ユニットに nil を返すため、**第2引数 true** で取得して
--   `getIsDead()` を見る。`getIsDead()` は「HP0フラグ・dead フック・自動蘇生を全部抜けて退場確定」を
--   意味し、`getHP() <= 0` や「枠が nil になった」より正確（HP0フラグ持ちは HP1 で生存する）。
--   同時撃破は `addCondition` のクールタイムに食われるため、そのフレームぶんを合算して1回で積む
--   （実績: unit/103907112 の撃破カウント方式。StackBuff の event.stacks 経路）。
--
-- マルチ:
--   生存フラグ・撃破数は**ホストが判定して配信**する。被ダメージ倍率に効く値なので、端末ごとに
--   数がズレるとダメージ表示が食い違うため。
--   ⚠ `hostDecide` の handler の中でコンディションを触ると実機でクラッシュする（HateTarget で確定）。
--      そのため host は「その場で直接適用 ＋ broadcast（配信のみ）」、guest は「受信 handler で適用」
--      に分けている。`hostDecide` は使わない。
--   ⚠ Sync の receive ポートを2本消費する（上限10本）。Attack/Smash/Phases/Chance と合わせて使い切らないこと。
--
-- @example 雑魚がいる間ボスの防御力100%UP / 撃破ごとに被ダメ10%UP（アイコンにカウント・最大99）
--     boss:add(Minions{
--         enemies = { 4000801, 4000802 },
--         onAlive = { AttachBuff{ id = 900001, type = 15, value = 100, icon = 5 } },
--         onEmpty = { RemoveBuff{ id = 900001 } },
--         onKill  = { StackBuff{ id = 900002, type = 21, value = 10, max = 99, icon = 24 } },
--     })
--
-- 設定:
--   enemies  table        監視する enemyID の配列
--   onAlive  Action|list  0体 → 1体以上 の立ち上がりで実行
--   onEmpty  Action|list  1体以上 → 0体 の立ち下がりで実行
--   onKill   Action|list  撃破時に実行（event.stacks = そのフレームの撃破数）
--   slots    number       走査するチーム枠数（既定8。クエストの敵枠数に合わせる）
------
local _NAME = 'summoner.Choreo.Components.Minions'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')
local Sync = require('summoner.Choreo.Components.Sync')

local ALIVE_CHANNEL = 'minionAlive'
local KILL_CHANNEL = 'minionKill'

local function Minions(config)
    config = config or {}
    local slots = config.slots or 8
    local enemies = config.enemies or {}
    local ids = {}
    for i = 1, #enemies do ids[enemies[i]] = true end
    local component = { name = 'Minions' }

    -- 生存状態の適用（host は判定直後にその場で / guest は受信 handler から）
    local function applyAlive(self, alive)
        local actions
        if alive == 1 then
            actions = config.onAlive
        else
            actions = config.onEmpty
        end
        if actions == nil then return end
        Action.runActions(self, { unit = self.unit, name = 'OnMinionAlive', alive = alive }, actions)
    end

    -- 撃破の適用。stacks に撃破数を載せて渡す（StackBuff が1回で n スタック積む）
    local function applyKills(self, kills)
        if kills == nil or kills <= 0 or config.onKill == nil then return end
        Action.runActions(self, { unit = self.unit, name = 'OnMinionKill', stacks = kills },
                          config.onKill)
    end

    -- 状態は per-instance（規約 §6-3）。クロージャ変数にすると同ID複数体・リトライで共有されてしまう。
    local function onLoad(self, event)
        self._minionSlots = {}        -- slot index => { id = enemyID, dead = bool }
        self._minionsAlive = false
    end

    local function onUpdate(self, event)
        if not self.isHostPlayer then return end
        local unit = event.unit or self.unit
        if unit == nil or unit == false then return end
        local team = unit:getTeam()
        local tracked = self._minionSlots
        if tracked == nil then return end

        local alive, kills = 0, 0
        for i = 0, slots - 1 do
            -- 第2引数 true: 死亡ユニットも取得する（false だと死亡した瞬間に nil になり撃破を取りこぼす）
            local u = team:getTeamUnit(i, true)
            local id = (u ~= nil) and u:getEnemyID() or nil
            if u ~= nil and ids[id] then
                local slot = tracked[i]
                if slot == nil or slot.id ~= id then
                    slot = { id = id, dead = false }      -- 別の雑魚が同じ枠に入った
                    tracked[i] = slot
                end
                local dead = u:getIsDead() and true or false
                if dead and not slot.dead then
                    slot.dead = true
                    kills = kills + 1
                elseif not dead and slot.dead then
                    slot.dead = false                     -- 同じ枠が再召喚で埋まった（or 蘇生した）
                end
                if not dead then alive = alive + 1 end
            else
                tracked[i] = nil
            end
        end

        if kills > 0 then
            applyKills(self, kills)                       -- host は直接適用（handler 経由にしない）
            self:broadcast(KILL_CHANNEL, kills)           -- guest へは配信のみ
        end

        local isAlive = alive > 0
        if isAlive ~= self._minionsAlive then
            self._minionsAlive = isAlive
            local flag = isAlive and 1 or 0
            applyAlive(self, flag)
            self:broadcast(ALIVE_CHANNEL, flag)
        end
    end

    function component.initialize(dispatcher)
        if not dispatcher:hasComponent('Sync') then
            dispatcher:add(Sync.create())
        end
        dispatcher:openChannel(ALIVE_CHANNEL, function(self, value) applyAlive(self, value) end)
        dispatcher:openChannel(KILL_CHANNEL, function(self, value) applyKills(self, value) end)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = Minions
return Minions
