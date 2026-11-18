------
-- summoner.Choreo.Components.AnimVariant
--
-- アニメ名の「バリアント（サフィックス）」を状態として持ち、再生アニメ名を差し替える Component。
-- 1体のボスが同じ行動を複数の見た目（形態/天候/属性）で持ち、spine のアニメ名が
-- `idle_N` / `attack1_R` のように **共通ベース名＋サフィックス** で分かれているボス用。
--
-- 出典: 皇雅(unit/501811213) の天候システム。idle/damage/attack/skill が
--       `_N`(無)/`_R`(雷)/`_G`(風)/`_B`(雨) の4系統に分かれ、切替時に setSetupAnimationName で
--       セットアップポーズ（発光パーツの出し分け）も差し替える。
--       接頭辞型: デグルマグナ(unit/500111113・500691113) の通常形態。`zcloneNidle` / `zcloneNskill1` のように
--       **接頭辞＋共通ベース名**で、怒り（炎）形態は接頭辞なし。セットアップは `setUpNormal` / `setUpFire`。
--
-- 効果:
--   1. 生アニメ（takeIdle="idle" / takeBack="back" / takeDamage="damage" 等）を `apply` の
--      ベース名に差し替え、現バリアントの接頭辞を前置・サフィックスを後置する。
--   2. Attack/Smash(Selector) の**本体アニメ**にも同じ接頭辞・サフィックスが乗る。
--      契約は dispatcher の `_animPrefix` / `_animSuffix`（Selector が読む。StageEffect はサフィックスのみ）。
--   3. 切替のたびセットアップを差し替える。バリアントに `setup` があればその名前、
--      無ければ Component の `setup` 指定時に `setSetupAnimationName(setup .. サフィックス)`。
--
-- 切替は SetAnimVariant アクション（Smash の onUse / Phases 等から配線する）。
--
-- ⚠ サフィックスが乗るのは **本体アニメだけ**。エフェクト spine(`<baseID>ef.json`)は
--    バリアントを持たないことが多い（皇雅も `1-attack1` は共通）ため animeff には後置しない。
--    バリアント別のエフェクトが要る index は skills の `animeff` で明示する（例: `Roar_R`）。
-- ⚠ spine に存在しないアニメ名を作ると演出が完了せずボスが停止する。`variants` × `apply` の
--    全組み合わせが実アニメ名に一致することを必ず確認する（docs/23）。
--    `back` アニメを持たないボスは `apply = { back = 'idle' }` のように寄せる。
-- ⚠ `setup` は spine に実在する名前のみ。C++ の setToSetupSlot は spAnimation_apply を
--    null チェックなしで呼ぶため、無い名前を渡すとクラッシュしうる（TeamUnit.cpp）。
-- ⚠ 初期バリアントの setup は既定で **適用しない**（spine 既定のセットアップポーズ＝初期形態、
--    という作りが通例のため）。明示したい場合のみ setupAtStart = true。
--
-- 設定:
--   initial      string  初期バリアント名（variants のキー）
--   variants     table   バリアント名 => サフィックス文字列（例 { N = '_N', R = '_R' }）、
--                        または { prefix = 接頭辞, suffix = サフィックス, setup = セットアップ名 }（各省略可）
--   apply        table   生アニメの差し替え表 key => ベース名。key は idle/back/damage/front/out。
--                        既定 { idle = 'idle', back = 'back', damage = 'damage' }
--   setup        string  セットアップアニメのベース名（例 'Setup'）。バリアントの setup が優先。nil=切替しない
--   setupAtStart bool    開幕にも初期バリアントのセットアップを適用する（既定 false）
--
-- @example
--     boss:add(AnimVariant{
--         initial = 'N',
--         variants = { N = '_N', R = '_R', G = '_G', B = '_B' },
--         apply = { idle = 'idle', back = 'idle', damage = 'damage' },  -- back アニメが無いので idle へ
--         setup = 'Setup',
--     })
--     -- 奥義4 の使用で雷(R)へ切替（本体アニメは切替前のサフィックス、Roar_R は animeff で明示）
--     boss:add(Smash{ sets = { { 3 } }, onUse = { [4] = { SetAnimVariant{ 'R' } } } })
--
-- @example 接頭辞型（通常形態は zcloneN<ベース名>・炎形態は接頭辞なし）
--     boss:add(AnimVariant{
--         initial = 'normal',
--         variants = { normal = { prefix = 'zcloneN', setup = 'setUpNormal' },
--                      fire   = { setup = 'setUpFire' } },
--         setupAtStart = true,
--     })
--     boss:add(Phases{ { at = 20, actions = { SetAnimVariant{ 'fire' } } } })
------
local _NAME = 'summoner.Choreo.Components.AnimVariant'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

-- apply のキー => 差し替え対象の生イベント。C++ の既定アニメ名は
-- takeIdle="idle" / takeBack="back" / takeDamage="damage" / takeFront="front" / takeOut="out"（TeamUnit.cpp）。
local RAW_EVENTS = {
    idle = Events.takeIdle,
    back = Events.takeBack,
    damage = Events.takeDamage,
    front = Events.takeFront,
    out = Events.takeOut,
}
local DEFAULT_APPLY = { idle = 'idle', back = 'back', damage = 'damage' }

-- variants の値（サフィックス文字列 / { prefix, suffix, setup }）を 接頭辞・サフィックス・明示セットアップ名 に分解する
local function variantParts(spec)
    if type(spec) == 'table' then
        return spec.prefix or '', spec.suffix or '', spec.setup
    end
    return '', spec or '', nil
end

-- そのバリアントで当てるセットアップ名。バリアントの setup が優先、無ければ setup ベース名 .. サフィックス
local function setupNameOf(baseSetup, spec)
    local _, suffix, explicit = variantParts(spec)
    if explicit ~= nil then
        return explicit
    end
    if baseSetup ~= nil then
        return baseSetup .. suffix
    end
    return nil
end

local makeAnimVariant   -- 前方宣言

local AnimVariant = setmetatable({}, {
    __call = function(_, config) return makeAnimVariant(config) end
})

function makeAnimVariant(config)
    config = config or {}
    local variants = config.variants or {}
    local initial = config.initial
    local apply = config.apply or DEFAULT_APPLY
    local setup = config.setup
    local setupAtStart = config.setupAtStart
    local component = { name = 'AnimVariant' }

    -- start: per-instance 状態を初期化（規約 §6-3）。Action から参照する設定も dispatcher へ載せる。
    local function onLoad(self, event)
        self._animVariants = variants
        self._animSetup = setup
        self._animVariant = initial
        self._animPrefix, self._animSuffix = variantParts(variants[initial])
        if setupAtStart then
            local name = setupNameOf(setup, variants[initial])
            if name ~= nil then
                event.unit:setSetupAnimationName(name)
            end
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        for key, base in pairs(apply) do
            local eventName = RAW_EVENTS[key]
            assert(eventName ~= nil,
                   'Choreo: AnimVariant.apply の未知キー ' .. tostring(key) ..
                   '（idle/back/damage/front/out）')
            dispatcher:addEventListener(eventName, function(self, event)
                event.unit:setNextAnimationName((self._animPrefix or '') .. base .. (self._animSuffix or ''))
            end)
        end
    end

    return component
end

------
-- SetAnimVariant Action: バリアントを切り替える
--   name  string  variants のキー（位置引数 SetAnimVariant{'R'} でも可）
--
-- 切替は「以降に組み立てるアニメ名」に効く。既に setNextAnimationName 済みの
-- 発火中モーションは変わらない（＝実ボスの「切替モーションは旧サフィックスのまま再生し、
-- 次の idle から新サフィックス」挙動と一致）。
-- 決定的な状態遷移なので同期不要（全端末で同じ onUse / phase から呼ばれる）。
------
AnimVariant.Set = Action.define('SetAnimVariant', function(a, d, e)
    local name = a.name or a[1]
    local variants = d._animVariants
    if variants == nil then
        return                              -- AnimVariant 未搭載（start 前）: 何もしない
    end
    local spec = variants[name]
    if spec == nil then
        return                              -- 未定義バリアント: アニメ名を壊さないため無視
    end
    d._animVariant = name
    d._animPrefix, d._animSuffix = variantParts(spec)
    local unit = d.unit
    if unit == nil or unit == false then
        unit = e ~= nil and e.unit or nil
    end
    local setupName = setupNameOf(d._animSetup, spec)
    if setupName ~= nil and unit ~= nil and unit ~= false then
        unit:setSetupAnimationName(setupName)
    end
end)

------
-- SetSetupAnim Action: セットアップアニメ（静止ポーズ）を直接指定する
--   name    string  本体 spine のアニメ名（位置引数可）。'' を渡すと spine 既定ポーズへ戻る
--   effect  string  (任意) エフェクト spine 側（setSetupAnimationNameEffect）
--
-- バリアント（天候/形態）と**独立したポーズ**を当てるためのもの。
-- 例: 皇雅の `Setup_X` は胴体LEDだけを点ける3スロットのオーバーレイで、天候の
--     `Setup_R/G/B`（角・頭の発光パーツ）とは触るスロットが重ならない別軸のポーズ。
-- ⚠ setSetupAnimationName は **1本しか保持できない**。`Setup_X` を当てている間は
--    天候の `Setup_R/G/B` は適用されない（AnimVariant の切替で上書きされる）。
-- ⚠ spine に実在する名前のみ。C++ の setToSetupSlot は spAnimation_apply を
--    null チェックなしで呼ぶため、無い名前を渡すとクラッシュしうる。
------
AnimVariant.SetSetup = Action.define('SetSetupAnim', function(a, d, e)
    local unit = Action.resolveTarget(a, d, e)
    if unit == nil or unit == false then
        return
    end
    local name = a.name or a[1]
    if name ~= nil then
        unit:setSetupAnimationName(name)
    end
    if a.effect ~= nil then
        unit:setSetupAnimationNameEffect(a.effect)
    end
end)

_G.package.loaded[_NAME] = AnimVariant
return AnimVariant
