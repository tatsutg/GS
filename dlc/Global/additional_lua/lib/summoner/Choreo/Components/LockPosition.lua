------
-- summoner.Choreo.Components.LockPosition
--
-- 立ち位置を開幕位置に固定する Component。update ごとに座標を書き戻す。
-- 演出アニメのルートモーションやヒットバックで大型ボスが少しずつズレていくのを防ぐ。
-- 出典: 実ボス慣用（update 内で初回に getPositionX/Y を控え、以降 setPositionX/Y で戻す。
--       皇雅(501811213) ほか 8 ファイル）。
--
-- ⚠ update を使うため boss version >= 1.1。
-- ⚠ 「ノックバックしないボス」用。移動する演出（突進で位置が変わる等）を持つボスには使わない。
--
-- 設定:
--   x  number  (任意) 固定する X。省略時は開幕の実座標
--   y  number  (任意) 固定する Y。省略時は開幕の実座標
--
-- @example
--     boss:add(LockPosition{})
------
local _NAME = 'summoner.Choreo.Components.LockPosition'
local _G = _G

local Events = require('summoner.Choreo.Events')

local function LockPosition(config)
    config = config or {}
    local fixedX = config.x
    local fixedY = config.y
    local component = { name = 'LockPosition' }

    -- start: per-instance 状態を初期化（規約 §6-3。前回戦闘の座標を持ち越さない）
    local function onLoad(self, event)
        self._lockX = nil
        self._lockY = nil
    end

    -- 初回 update で実座標を控える（start 時点ではまだ配置前のことがあるため update で拾う）。
    -- x/y の明示指定はここで優先する（片方だけの指定も可）。
    local function onUpdate(self, event)
        if self._lockX == nil then
            self._lockX = fixedX or event.unit:getPositionX()
            self._lockY = fixedY or event.unit:getPositionY()
            return
        end
        event.unit:setPositionX(self._lockX)
        event.unit:setPositionY(self._lockY)
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = LockPosition
return LockPosition
