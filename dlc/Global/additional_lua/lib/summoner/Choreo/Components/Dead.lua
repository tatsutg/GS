------
-- summoner.Choreo.Components.Dead
--
-- 死亡時（dead イベント）に Action 群を実行する Component。死亡は許可したまま（returnValue は触らない）。
-- 死亡回避・復活は Reraise（avoidDead）の担当で、こちらは「死んだとき」の演出・後始末用。
--
-- マルチプレイ（死亡はホスト権威に一本化）:
--   ボスHP・死亡はホスト権威（HPは STATUSSYNC_BOSS で host が配信、死亡は DEADENEMY で host→guest 同期）。
--   ゲストがローカルで殺すと desync するため、**ゲストは dead フックで event:prevent()（戻り値0）して自分では死なせない**。
--   ホスト権威の DEADENEMY→Team::deadUnit は dead フックを経由しないので prevent では止まらない＝ゲストは host 経由でのみ死ぬ。
--   ダメージ値は変えないのでホストは全ダメージを受け取れる（ホスト全滅でもホストがHP0を確定できる）。
--   死亡演出(Say等)は host が Sync チャンネルで全端末へ配信して表示（host 実行＋配信 → guest 受信で再生）。
--   clearWave(残敵 setHP=0)は host 権威操作なので host のみ実行（guest の HP/死亡は host から同期される）。
--
-- clearWave = true で、自分の死亡時に残存する自チーム（敵チーム）全員の HP を 0 にする。
-- 「ボスを倒したら相方が残っていてもクリア」ギミックの実体（エンジンの Wave 終了条件は
-- 全敵死亡のみ＝Battle::waveEndCheck。ボス死亡での終了はエンジンに存在しないため Lua 側で残敵を倒す）。
-- 出典: 実ボス慣用（dead() 内 showMessage ＋ creanUpEnemy: getTeam():getTeamUnit(i,true):setHP(0)。2000666 等）。
--
-- ⚠ dead イベントは version 1.0（無条件）。
--
-- @example
--     boss:add(Dead{ clearWave = true, actions = { Say{ "DEAD_MESSAGE1", color = Color.blue } } })
--     boss:add(Dead{ actions = { Say{ "DEAD_MESSAGE1" } } })   -- セリフのみ（相方は倒さない）
--
-- 設定:
--   actions    Action|list  死亡時に実行（Say 等）
--   clearWave  boolean      true で残存する自チーム全員の HP を 0 に（既定 false）
------
local _NAME = 'summoner.Choreo.Components.Dead'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')
local Sync = require('summoner.Choreo.Components.Sync')

local DEAD_CHANNEL = 'Dead'

local function Dead(config)
    config = config or {}
    local actions = config.actions
    local clearWave = config.clearWave
    local component = { name = 'Dead' }

    -- 死亡演出(Say 等)を実行する。マルチではゲスト側で dead フックが発火しないため、
    -- Sync チャンネル経由で host/guest 両方でこのハンドラを走らせる（下記 hostDecide）。
    local function runDeathActions(self)
        if actions ~= nil then
            -- pcall で保護：例外が出ても dead リスナが中断せず戦闘不能処理が保たれる。
            pcall(function() Action.runActions(self, { unit = self.unit }, actions) end)
        end
    end

    local function onLoad(self, event)
        self._deadFired = false
    end

    local function onDead(self, event)
        -- ゲストはボスをローカルで殺さない＝死亡はホスト権威に一本化する。
        -- dead フックで prevent すると戻り値0＝エンジンは死亡をスキップ(Team.cpp: if(!runScript)continue)。
        -- ホスト権威の死亡同期(DEADENEMY→Team::deadUnit)は dead フックを経由しないため、この prevent では止まらない。
        -- → ゲストが致死ダメージを与えても自分では死なせず、ホストがHP0を検知して死亡確定＋DEADENEMYで全端末を殺す。
        --   ダメージ値には触らないのでホストは全ダメージを受け取れる（ホスト全滅でもホストが確定できる）。
        if not self.isHostPlayer then
            event:prevent()
            return
        end
        if self._deadFired then
            return
        end
        self._deadFired = true
        -- unit は start で捕捉した self.unit を優先（dead イベントの event.unit 取り違えを防ぐ）
        local unit = self.unit or event.unit
        -- 演出(Say等)は host が実行＋全端末へ配信（Sync）。guest は配信受信で表示（guest では dead は prevent 済み）。
        pcall(function() self:hostDecide(DEAD_CHANNEL, 1) end)
        -- clearWave(残敵 setHP=0)は host 権威操作。guest 側の残敵 HP/死亡は host から同期される。
        if clearWave and unit ~= nil then
            pcall(function()
                local team = unit:getTeam()
                if team ~= nil then
                    for i = 0, 7 do
                        local enemy = team:getTeamUnit(i, true)   -- 無敵・出現中でも取得（第二引数 true）
                        if enemy ~= nil and enemy ~= unit then
                            enemy:setHP(0)
                        end
                    end
                end
            end)
        end
    end

    function component.initialize(dispatcher)
        -- 死亡演出を guest にも届けるため Sync チャンネルを確保（Selector と同作法）。
        -- openChannel は host/guest 双方の initialize で同順に呼ばれ port が一致する。
        if not dispatcher:hasComponent('Sync') then
            dispatcher:add(Sync.create())
        end
        dispatcher:openChannel(DEAD_CHANNEL, function(self, value)
            runDeathActions(self)
        end)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnDrop, onDead)   -- OnDrop == 'dead'
    end

    return component
end

_G.package.loaded[_NAME] = Dead
return Dead
