------
-- summoner.Choreo.Components.KindOrdeus
--
-- ボス種プリセット: 葬魂神オルデウス。種の共有ギミック（壊魂振動 = OrdeusSkull /
-- 滅魂宿世 = OrdeusDeathScene）のうち、設定されたものだけを内部で add して束ねる薄い皿。
-- 出典: enemy/4002402.lua ほかオルデウス各個体（claudeDatas/ORDEUS_KIND_AGENT.md の調査）。
--
-- ⚠ 大型ボス共通の定型（addSP 同期＝SpineSPGain / NoHitStop / attackDelay 等）は種の管轄外。
--    ボス YAML 側で汎用 Component を並べること。
-- ⚠ skull/deathScene とも内包 Component が update を使うため boss version >= 1.1。
--
-- 設定:
--   skull       table  OrdeusSkull の設定（省略で壊魂振動なし。{} で既定値）
--   deathScene  table  OrdeusDeathScene の設定（省略で滅魂宿世なし。onHit に個体差効果を書く）
--
-- @example
--     boss:add(KindOrdeus{ skull = { count = 2 }, deathScene = { pick = "none", onHit = { ... } } })
------
local _NAME = 'summoner.Choreo.Components.KindOrdeus'
local _G = _G

local OrdeusSkull = require('summoner.Choreo.Components.OrdeusSkull')
local OrdeusDeathScene = require('summoner.Choreo.Components.OrdeusDeathScene')

local function KindOrdeus(config)
    config = config or {}
    local component = { name = 'KindOrdeus' }

    function component.initialize(dispatcher)
        if config.skull ~= nil then
            dispatcher:add(OrdeusSkull(config.skull))
        end
        if config.deathScene ~= nil then
            dispatcher:add(OrdeusDeathScene(config.deathScene))
        end
    end

    return component
end

_G.package.loaded[_NAME] = KindOrdeus
return KindOrdeus
