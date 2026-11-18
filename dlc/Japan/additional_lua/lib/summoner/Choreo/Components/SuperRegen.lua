------
-- summoner.Choreo.Components.SuperRegen
--
-- 超回復: HP を常に基準値へ戻す（削られても即座に満タンへ回復し、結果として死なない）。
-- 出典: enemy/100151201.lua（修行の間_サンドバッグ_自由訓練）の
--   `start` で `self.myHP = event.unit:getHP()` を保持し、`update` 毎に `event.unit:setHP(self.myHP)`。
--
-- ⚠ update を使うため boss version >= 1.1。回復はホストのみ実行（HP は engine が同期）。
-- ⚠ 1発で基準値ぶんを削られると update より先に戦闘不能になる（原作同様、HP 量で担保する）。
--
-- 設定:
--   hp  number  戻す基準HP（省略時は戦闘開始時のHP＝実質満タン）
--
-- @example
--     boss:add(SuperRegen{})              -- 開幕HPへ常に回復
--     boss:add(SuperRegen{ hp = 500000 }) -- 指定値へ常に回復
------
local _NAME = 'summoner.Choreo.Components.SuperRegen'
local _G = _G

local Events = require('summoner.Choreo.Events')

local function SuperRegen(config)
    config = config or {}

    local component = { name = 'SuperRegen' }

    local function onLoad(self, event)
        self._superRegenHP = config.hp or config[1] or event.unit:getHP()
    end

    local function onUpdate(self, event)
        if not self.isHostPlayer then
            return
        end
        local hp = self._superRegenHP
        if hp == nil then
            return
        end
        if event.unit:getHP() < hp then
            event.unit:setHP(hp)
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = SuperRegen
return SuperRegen
