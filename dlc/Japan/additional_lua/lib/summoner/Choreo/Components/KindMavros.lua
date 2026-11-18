------
-- summoner.Choreo.Components.KindMavros
--
-- ボス種プリセット: 冥蝕竜マヴロスギア（闇ドラ）。マヴロスギア固有の共有ギミック
-- （時空追放＝重力吸引）のうち、設定されたものだけを内部で add して束ねる薄い皿。
-- 出典: enemy/2004542.lua（樹木）/ 2054701.lua（超神具）/ 2018143・2020743 等（闇ドラ）。
--
-- ⚠ **火球・火柱は竜種共通のため [[KindDragon]] の管轄**（マヴロスギアでは両方とも
--    KindDragon{ fire = {}, firePillar = {} } を併記して使う）。
-- ⚠ 大型ボス共通の定型（addSP 同期＝SpineSPGain / NoHitStop / attackDelay 等）は種の管轄外。
-- ⚠ gravity 使用時は内包する MavrosGravity が update を使うため boss version >= 1.1。
--    spine 側の前提: attack5 に runScript-gravityStart / hideUnit / gravityEnd。
--
-- 設定:
--   gravity  table  MavrosGravity の設定（省略で時空追放なし。{} で既定値）
--
-- @example
--     boss:add(KindDragon{ fire = {}, firePillar = {} })
--     boss:add(KindMavros{ gravity = { duration = 40 } })
------
local _NAME = 'summoner.Choreo.Components.KindMavros'
local _G = _G

local MavrosGravity = require('summoner.Choreo.Components.MavrosGravity')

local function KindMavros(config)
    config = config or {}
    local component = { name = 'KindMavros' }

    function component.initialize(dispatcher)
        if config.gravity ~= nil then
            dispatcher:add(MavrosGravity(config.gravity))
        end
    end

    return component
end

_G.package.loaded[_NAME] = KindMavros
return KindMavros
