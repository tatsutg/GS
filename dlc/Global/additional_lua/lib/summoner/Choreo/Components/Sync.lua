------
-- summoner.Choreo.Components.Sync
--
-- マルチプレイ同期の内部プリミティブ。
-- 「ホストが値を決定 → 全端末で同じ処理を再生」を、書き手に見えない形で提供する。
-- Attack/Smash/Phases が内部で利用する。
--
-- 概念:
--   - チャンネル: 名前付きの同期経路。receive ポート(1..10)を自動採番して割り当てる。
--   - openChannel(name, handler): チャンネルを開く。handler(dispatcher, value) は
--       ホストでは hostDecide 時に、ゲストでは broadcast 受信時に呼ばれる。
--   - hostDecide(name, value): ホストのみ。handler を自分で実行し、全端末へ value を配信。
--   - broadcast(name, value): ホストのみ。配信だけ（handler は呼ばない）。
--
-- これにより上位 Component は isHost / sendEventToLua / receiveN を直接書かずに済む。
------
local _NAME = 'summoner.Choreo.Components.Sync'
local _M = {}
local _G = _G

local Events = require('summoner.Choreo.Events')

------
-- Sync コンポーネントを生成する（dispatcher:add(Sync.create()) で合成）
------
function _M.create()
    local component = { name = 'Sync' }
    component.openChannel = _M.openChannel
    component.broadcast = _M.broadcast
    component.hostDecide = _M.hostDecide

    function component.initialize(dispatcher)
        dispatcher._syncChannels = {}     -- name => { port=, handler= }
        dispatcher._syncNextPort = 0
        -- 全 receive ポートを購読し、ポート一致するチャンネルへ振り分ける
        for port = 1, Events.MAX_PORT_NUMBER do
            dispatcher:addEventListener(Events.OnReceive(port), _M.makeReceiver(port))
        end
    end

    return component
end

------
-- ある receive ポート用の受信リスナを作る（ゲスト側で発火）
------
function _M.makeReceiver(port)
    return function(self, event)
        for name, ch in pairs(self._syncChannels) do
            if ch.port == port then
                ch.handler(self, event.arg)
            end
        end
    end
end

------
-- チャンネルを開く（receive ポートを自動採番）
-- @param string name
-- @param function handler  function(dispatcher, value)
------
function _M.openChannel(self, name, handler)
    self._syncNextPort = self._syncNextPort + 1
    assert(self._syncNextPort <= Events.MAX_PORT_NUMBER,
        "Choreo.Sync: receive ポート(" .. Events.MAX_PORT_NUMBER .. ")を使い切りました")
    self._syncChannels[name] = { port = self._syncNextPort, handler = handler }
    return self
end

------
-- ホストが value を全端末へ配信する（handler は呼ばない）
------
function _M.broadcast(self, name, value)
    if not self.isHostPlayer then
        return self
    end
    local ch = self._syncChannels[name]
    if value == nil then value = 0 end
    megast.Battle:getInstance():sendEventToLua(self.scriptID, ch.port, tonumber(value))
    return self
end

------
-- ホストが value を決定 → 自分で handler を実行し、全端末へ配信する
-- ゲスト側では何も起きず、配信受信時に handler が走る。
------
function _M.hostDecide(self, name, value)
    if not self.isHostPlayer then
        return self
    end
    -- handler と broadcast で同じ値を使う（ゲストは broadcast の tonumber 値を受けるので、
    -- ここで正規化しないと host=生値 / guest=数値 で乖離する。sync チャンネルは数値前提）。
    value = tonumber(value) or 0
    local ch = self._syncChannels[name]
    ch.handler(self, value)
    self:broadcast(name, value)
    return self
end

_G.package.loaded[_NAME] = _M
return _M
