------
-- summoner.Choreo.Components.StageEffect
--
-- 画面（カメラ）に貼り付く常設オービットを1枠だけ持ち、再生アニメを差し替える Component。
-- 背景の天候・オーラ・結界のような「ボスの状態を表す全画面演出」用。
-- 弾/分離体（都度使い捨て）の SpawnOrbit とは別物: **1枠を作り直さず使い回す**のが要点。
--
-- 出典: 皇雅(unit/501811213) の天候エフェクト
--       （`addOrbitSystemCameraWithFile("50181ef", "StageEF".._天候.._強化", false)` を初回だけ生成し、
--        以降は同じオービットへ `takeAnimation` でアニメを差し替える）。
--       常設オーラの `addOrbitSystemCameraWithFile("50191ef","Pile_camera",true)`（501921150 他）も同型。
--
-- アニメ名の組み立て: `anim .. バリアントサフィックス .. レベル`
--   - バリアントサフィックス: `variant = true` のとき AnimVariant の現サフィックス（`_animSuffix`）
--   - レベル: SetStageLevel で設定する追加サフィックス（初期値は `level`）。強化版 `StageEF_R2` 等
--
-- 更新契機:
--   - `spineEvent` に spine イベント名を指定すると、その発火（Timeline と同じ run イベント）で更新
--   - `atStart = true` で開幕に1回
--   - ShowStageEffect アクションで任意のタイミング
--
-- 同期不要: spine イベントは全端末で同一に発火し、アニメ名は決定的な状態から組み立てるだけ
--           （行動選択の同期は Attack/Smash が済ませている）。
--
-- ⚠ 組み立てたアニメ名が spine に無いと演出が出ない（例: 皇雅は `StageEF_N` が無く、無天候では
--    そもそも weather イベントが飛ばない設計）。variants × level の全組み合わせを spine で確認する。
-- ⚠ `file` は `dlc/unit/animation/<file>.json` のファイル名（拡張子なし）。省略時は本体 spine の
--    アニメを `addOrbitSystemCamera(anim, type)` で再生する。
--
-- 設定:
--   file      string  オービット spine のファイル名（例 '50181ef'）。省略で本体 spine
--   anim      string  ベースアニメ名（例 'StageEF'）
--   variant   bool    AnimVariant の現サフィックスを後置する（既定 false）
--   level     string  追加サフィックスの初期値（既定 ''）。SetStageLevel で変更
--   loop      bool    ループ再生（既定 true）
--   track     number  takeAnimation のトラック（既定 0）
--   orbitType number  file 省略時の addOrbitSystemCamera の orbittype（既定 0）
--                     ※ `type` は YAML のコンポーネント種別キーと衝突するので使わない
--   spineEvent string この spine イベントで更新する（例 'weather'）。
--                     ※ キー名 `on` は YAML 1.1 で true に化けるため使わない
--   atStart   bool    開幕(start)に1回出す（既定 false）
--
-- @example
--     boss:add(StageEffect{ file = '50181ef', anim = 'StageEF', variant = true, spineEvent = 'weather' })
--     boss:add(Phases{ { at = 40, stop = true, actions = { SetStageLevel{ '2' } } } })  -- 次の更新で強化版へ
------
local _NAME = 'summoner.Choreo.Components.StageEffect'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local makeStageEffect   -- 前方宣言

local StageEffect = setmetatable({}, {
    __call = function(_, config) return makeStageEffect(config) end
})

function makeStageEffect(config)
    config = config or {}
    local file = config.file
    local anim = config.anim or ''
    local useVariant = config.variant
    local initialLevel = config.level or ''
    local loop = config.loop
    if loop == nil then
        loop = true
    end
    local track = config.track or 0
    local orbitType = config.orbitType or 0
    local onEvent = config.spineEvent
    local atStart = config.atStart

    local component = { name = 'StageEffect' }

    -- 1枠のオービットを（無ければ生成して）指定アニメへ差し替える
    local function play(self, event, baseOverride)
        local unit = self.unit
        if unit == nil or unit == false then
            unit = event ~= nil and event.unit or nil
        end
        if unit == nil or unit == false then
            return
        end
        local suffix = ''
        if useVariant then
            suffix = self._animSuffix or ''
        end
        local name = (baseOverride or anim) .. suffix .. (self._stageLevel or '')
        if self._stageOrbit == nil or self._stageOrbit == false then
            -- 生成時は loop=false。直後の takeAnimation でループ指定ごと再生し直す（出典の慣用）。
            if file ~= nil then
                self._stageOrbit = unit:addOrbitSystemCameraWithFile(file, name, false)
            else
                self._stageOrbit = unit:addOrbitSystemCamera(name, orbitType)
            end
        end
        if self._stageOrbit ~= nil and self._stageOrbit ~= false then
            self._stageOrbit:takeAnimation(track, name, loop)
        end
    end

    -- start: per-instance 状態を初期化（規約 §6-3。前回戦闘のオービット参照を持ち越さない）
    local function onLoad(self, event)
        self._stageOrbit = nil
        self._stageLevel = initialLevel
        if atStart then
            play(self, event)
        end
    end

    local function onRun(self, event)
        if event.spineEvent == onEvent then
            play(self, event)
        end
    end

    -- 消去: 枠ごと remove（既定）／ blankAnim 指定時は枠を残して空アニメへ差し替え
    local function hide(self, blankAnim)
        local orbit = self._stageOrbit
        if orbit == nil or orbit == false then
            return
        end
        if blankAnim ~= nil then
            orbit:takeAnimation(track, blankAnim, loop)   -- 枠は残す（次の更新で作り直さない）
            return
        end
        orbit:remove()          -- C++ 側は getSkeleton() ガードつきで二重呼び出しも安全
        self._stageOrbit = nil  -- 破棄済み参照を掴み続けない（次の更新契機で作り直す）
    end

    -- アクションから呼ぶ更新メソッド（dispatcher のメソッドとして合流する）
    component.playStageEffect = function(self, event, baseOverride)
        play(self, event, baseOverride)
    end
    component.hideStageEffect = function(self, blankAnim)
        hide(self, blankAnim)
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        if onEvent ~= nil then
            dispatcher:addEventListener(Events.OnTimeline, onRun)   -- OnTimeline == 'run'
        end
    end

    return component
end

------
-- ShowStageEffect Action: 今のバリアント/レベルでオービットを更新する
--   anim  string  (任意) ベースアニメ名の上書き（位置引数可）
------
StageEffect.Show = Action.define('ShowStageEffect', function(a, d, e)
    if d.playStageEffect == nil then
        return
    end
    d:playStageEffect(e, a.anim or a[1])
end)

------
-- HideStageEffect Action: 出しっぱなしの全画面演出を消す
--   anim  string  (任意) 空アニメ名（位置引数可）。指定すると**枠を残して**そのアニメへ差し替える。
--                 省略時はオービットごと remove（次の更新契機で作り直される）
--
-- ⚠ StageEffect は更新契機（spineEvent / Action）でしかアニメを差し替えない。
--    「演出を持たない状態」へ戻すときは明示的にこれを呼ぶこと。
--    例: 皇雅は無天候 `_N` に対応する `StageEF_N` が spine に無いため、`_N` へ戻すなら
--        `SetAnimVariant{'N'}` と一緒に `HideStageEffect{}` が要る
--        （エフェクト spine に空アニメがあるなら `HideStageEffect{'empty'}` でもよい）。
------
StageEffect.Hide = Action.define('HideStageEffect', function(a, d, e)
    if d.hideStageEffect == nil then
        return
    end
    d:hideStageEffect(a.anim or a[1])
end)

------
-- SetStageLevel Action: 追加サフィックス（強化段階）を変える
--   level  string  後置する文字列（位置引数可。'' で解除）
--   show   bool    即時に描き替える（既定 false = 次の更新契機で反映。出典の挙動）
------
StageEffect.SetLevel = Action.define('SetStageLevel', function(a, d, e)
    local level = a.level or a[1] or ''
    d._stageLevel = level
    if a.show and d.playStageEffect ~= nil then
        d:playStageEffect(e)
    end
end)

_G.package.loaded[_NAME] = StageEffect
return StageEffect
