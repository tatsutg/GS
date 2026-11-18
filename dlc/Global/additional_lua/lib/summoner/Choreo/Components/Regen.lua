------
-- summoner.Choreo.Components.Regen
--
-- 毎秒HP回復（自然回復）。update の deltaTime を1秒ぶん貯めるごとに takeHeal する。
-- 回復量は SetRegen アクションで実行時に変更できる（HPフェーズで 300→500→700 等）。
-- 出典: 実ボス慣用（update + event.deltaTime 累積 + takeHeal、最大HPは takeHeal が自動キャップ）。
--
-- ⚠ update を使うため boss version >= 1.1。ホスト権限でのみ回復（HP は engine が同期）。
--
-- @example
--     boss:add(Regen{ perSec = 300 })          -- 毎秒300回復
--     -- HPフェーズで回復量を上げる:
--     boss:add(Phases{ { at = 70, actions = { SetRegen{ 500 } } } })
--
-- 設定:
--   perSec  number  毎秒の回復量（既定0）。SetRegen で変更可。
------
local _NAME = 'summoner.Choreo.Components.Regen'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local makeRegen

local Regen = setmetatable({}, {
    __call = function(_, config) return makeRegen(config) end
})

function makeRegen(config)
    config = config or {}
    local perSec = config.perSec or config[1] or 0
    local component = { name = 'Regen' }

    local function onLoad(self, event)
        self._regenPerSec = perSec
        self._regenAccum = 0
    end

    local function onUpdate(self, event)
        if not self.isHostPlayer then return end       -- ホストのみ（HP は engine が同期）
        local rate = self._regenPerSec or 0
        if rate == 0 then return end
        self._regenAccum = (self._regenAccum or 0) + (event.deltaTime or 0)
        while self._regenAccum >= 1.0 do
            event.unit:takeHeal(rate)                  -- 最大HPは takeHeal が自動キャップ
            self._regenAccum = self._regenAccum - 1.0
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

-- 回復量を実行時に変更（HPフェーズ等から）
Regen.Set = Action.define('SetRegen', function(a, d, e)
    d._regenPerSec = a.perSec or a[1] or 0
end)

_G.package.loaded[_NAME] = Regen
return Regen
