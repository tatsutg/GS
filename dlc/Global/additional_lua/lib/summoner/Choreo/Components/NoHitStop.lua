------
-- summoner.Choreo.Components.NoHitStop
--
-- ヒットストップ／時止め無効。update ごとに setReduceHitStop を呼ぶ
-- （エンジンが毎フレームリセットするため、1回では効かず update 継続が必要）。
-- 出典: 実ボス慣用（update 内 `unit:setReduceHitStop(100, 1)` ---ヒットストップ無効or時止め無効）。
--
-- ⚠ update を使うため boss version >= 1.1。
--
-- @example
--     boss:add(NoHitStop{})              -- 既定 setReduceHitStop(100, 1)（無効）
--     boss:add(NoHitStop{ value = 2 })   -- 軽減率を変える場合
--
-- 設定:
--   value  number  軽減値（既定100＝無効）
--   type   number  種別（既定1）
------
local _NAME = 'summoner.Choreo.Components.NoHitStop'
local _G = _G

local Events = require('summoner.Choreo.Events')

local function NoHitStop(config)
    config = config or {}
    local value = config.value or 100
    local htype = config.type or 1
    local component = { name = 'NoHitStop' }

    local function onUpdate(self, event)
        event.unit:setReduceHitStop(value, htype)
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = NoHitStop
return NoHitStop
