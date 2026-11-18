------
-- summoner.Choreo.Components.KindMeteorHaze
--
-- ボス種プリセット: 幻炎竜メテオヘイズ（spine 502021160）。メテオヘイズ固有のギミック
-- （インフェルノヴィジョンの炎の場）のうち、設定されたものだけを内部で add して束ねる薄い皿。
-- 出典: enemy/600000133.lua（レイド。spine 502021160）。
--
-- ⚠ **火球は竜種共通のため [[KindDragon]] の管轄**。メテオヘイズのエフェクト（50202ef）は
--    fireball に当たり判定が無く fireball2 にだけあるので、KindDragon{ fire = { anim = "fireball2",
--    neckAngle = 295 } } を併記する（既定の fireball のままだと火球がダメージ0）。
--    火柱（setFire）は使わない（50202ef に firePiller が無い）。
-- ⚠ 大型ボス共通の定型（addSP 同期＝SpineSPGain / NoHitStop / attackDelay 等）は種の管轄外。
-- ⚠ inferno 使用時は内包する MeteorInferno が update を使うため boss version >= 1.1。
--    spine 側の前提: skill3 に runScript_skill3_orbit、炎の場のアニメ末尾に runScript_orbitNil。
--
-- 設定:
--   inferno  table  MeteorInferno の設定（省略で炎の場なし。{} で既定値）
--
-- @example
--     boss:add(KindDragon{ fire = { anim = "fireball2", neckAngle = 295 } })
--     boss:add(KindMeteorHaze{ inferno = {} })
------
local _NAME = 'summoner.Choreo.Components.KindMeteorHaze'
local _G = _G

local MeteorInferno = require('summoner.Choreo.Components.MeteorInferno')

local function KindMeteorHaze(config)
    config = config or {}
    local component = { name = 'KindMeteorHaze' }

    function component.initialize(dispatcher)
        if config.inferno ~= nil then
            dispatcher:add(MeteorInferno(config.inferno))
        end
    end

    return component
end

_G.package.loaded[_NAME] = KindMeteorHaze
return KindMeteorHaze
