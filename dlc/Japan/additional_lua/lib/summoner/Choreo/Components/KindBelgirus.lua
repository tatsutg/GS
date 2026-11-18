------
-- summoner.Choreo.Components.KindBelgirus
--
-- ボス種プリセット: ベルギラス種（base_unit_id 40002 系＝魔獣/迅獣/堕天神獣/幻影魔獣/絶）。
-- 種で共有される「これを書かないと壊れる」定型を1行に畳む薄い皿。
-- 出典: enemy/ の全ベルギラス実装 33 本（2020031 EX1 / 2020037 EX2 / 2054260 シャンフロ /
--   2057675 デイリーEX / 2078396 東方LW / 2081545 リゼロ / 3405032,3405033 34章 / mine_5015 ほか）。
--
-- 種の定型は次の2つだけ（残りは汎用 Component で書く）:
--
--   1. **スキン**: spine 既定スキンでは本体が欠ける。開幕に `setSkin("normal")` が要る。
--      実装 33 本のうち 29 本が自前で `event.unit:setSkin("normal")` を呼び、残る4本も
--      inheritFromEnemy の親が呼ぶ（＝実質全実装）。うち6本には
--      「ベルギラスはこのメソッドを使用しないと全身が表示されない」というコメントが残っている。
--      → **既定で有効**（gimmick ではなく正しく描画するための必須処理）。`skin = false` で無効化。
--      spine 500021313 の skins = `default` / `normal` / `rage`（怒り形態は SetSkin{"rage"} で切替）。
--
--   2. **奥義ゲージ**: run の spineEvent は `addSP` のみ（他の runScript は Lua 側で未使用）。
--      → `spineSP` を書いたときだけ SpineSPGain を合成（opt-in）。
--      ⚠ **addSP イベントは attack1-5 にしか無い**（skill1/2/3 には無い）。
--         奥義モーション中はゲージが伸びない種特性で、原典どおり。
--
-- ⚠ 大型ボス共通の定型（NoHitStop / attackDelay / 行動ローテ 等）は種の管轄外。ボス YAML 側で汎用
--    Component を並べること（[[KindDragon]] と同じ方針）。
--
-- 設定:
--   skin     string|false  開幕に当てるスキン名（既定 "normal"。false で setSkin を呼ばない）
--   spineSP  number|table  SpineSPGain の設定（省略でゲージ加算なし。数値＝1回の加算量）
--
-- @example
--     boss:add(KindBelgirus{ spineSP = 30 })         -- skin=normal ＋ addSP イベントで 30 加算
--     boss:add(KindBelgirus{})                        -- skin だけ（ゲージは別途 SPGain 等で）
--     boss:add(KindBelgirus{ skin = false })          -- スキンも自前で管理する
------
local _NAME = 'summoner.Choreo.Components.KindBelgirus'
local _G = _G

local Start = require('summoner.Choreo.Components.Start')
local SpineSPGain = require('summoner.Choreo.Components.SpineSPGain')
local Actions = require('summoner.Choreo.Actions')

local function KindBelgirus(config)
    config = config or {}
    local component = { name = 'KindBelgirus' }

    function component.initialize(dispatcher)
        local skin = config.skin
        if skin == nil then
            skin = 'normal'
        end
        if skin ~= false then
            dispatcher:add(Start{ Actions.SetSkin{ skin } })
        end

        local sp = config.spineSP
        if sp ~= nil then
            dispatcher:add(SpineSPGain(type(sp) == 'table' and sp or { value = sp }))
        end
    end

    return component
end

_G.package.loaded[_NAME] = KindBelgirus
return KindBelgirus
