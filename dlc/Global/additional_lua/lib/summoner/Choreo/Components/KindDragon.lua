------
-- summoner.Choreo.Components.KindDragon
--
-- ボス種プリセット: 竜種。竜で共有される演出ギミック（火球 / 火柱）のうち、
-- 設定されたものだけを内部で add して束ねる薄い皿。
-- 出典: マヴロスギア（2004542 等）・デグルマグナ（2034442 等）・フォスラディウス（gb_501601 等）ほか
--   竜種20体以上が同じ spine イベント（fire / setFire）と同じオービット実装を共有している。
--
-- ⚠ 大型ボス共通の定型（addSP 同期＝SpineSPGain / NoHitStop / attackDelay 等）は種の管轄外。
--    ボス YAML 側で汎用 Component を並べること。
-- ⚠ 各ギミックは spine のイベントで発火する。使わないアニメに紐づくギミックを宣言しても発火しない。
--    例: マヴロスギア spine 500155513 は fire=attack1 / setFire=skill1。
-- ⚠ 竜ごとに固有のギミックは種プリセットを分ける（マヴロスギアの時空追放＝KindMavros）。
--
-- 設定:
--   fire        table  DragonFire の設定（省略で火球なし。{} で既定値）
--   firePillar  table  DragonFirePillar の設定（省略で火柱なし）
--
-- @example
--     boss:add(KindDragon{ fire = {}, firePillar = {} })
--     boss:add(KindDragon{ fire = { bone = "EF_fire_mouth", neckAngle = 321 } })
------
local _NAME = 'summoner.Choreo.Components.KindDragon'
local _G = _G

local DragonFire = require('summoner.Choreo.Components.DragonFire')
local DragonFirePillar = require('summoner.Choreo.Components.DragonFirePillar')

local function KindDragon(config)
    config = config or {}
    local component = { name = 'KindDragon' }

    function component.initialize(dispatcher)
        if config.fire ~= nil then
            dispatcher:add(DragonFire(config.fire))
        end
        if config.firePillar ~= nil then
            dispatcher:add(DragonFirePillar(config.firePillar))
        end
    end

    return component
end

_G.package.loaded[_NAME] = KindDragon
return KindDragon
