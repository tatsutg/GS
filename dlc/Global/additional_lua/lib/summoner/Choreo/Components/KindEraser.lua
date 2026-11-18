------
-- summoner.Choreo.Components.KindEraser
--
-- ボス種プリセット: CODE XTF:ERASER（unit_id 500721013 / spine 500721013 + 50072ef）。
-- spine は SEEKER（500161013 / 50016ef）と同じアニメ名・runScript 一式に attack8 / skill7 / transform2 を足した上位互換なので、
-- スキン・形態・弾4系統・addSP は KindSeeker の部品をそのまま使い、ERASER の原典で値が違うところと
-- 最後の攻撃（自爆）だけを足す。
-- 出典: unit/500721013.lua の start（setSkin("Nomal")・setSPGainValue(0)）・funnel（addOrbitSystem("funnelIdle", 0)・寿命5）・
--   excuteAction（funnels <= 10 のときだけ召喚＝同時11機まで）・ball（setDamageRateOffset(0.2)）・dead（最後の攻撃）。
--
-- KindSeeker（SEEKER の原典）との違い＝この種の既定値:
--   1. 退場: ERASER の out は全身が消える（70 スロット中 63 が α0）、out2 はバリアハンドが外れるだけで本体が残る
--      （SEEKER と中身が逆）。原典は takeOut を差し替えず、どのモードでも out で消えるので、盾・攻撃モードとも out にする。
--      エフェクト out（爆発・4秒）は C++ の takeOut が既定で流す（spine out 0f の runScript-playOutEF も同じエフェクトなので処理しない）。
--   2. ポップテキスト: 原典の切替表示は INFO（mess1 / mess2）でポップテキストは出さない → 盾・攻撃とも pop = false。
--   3. ファンネル: orbitType 0（撃墜できない）・寿命 5・同時 11 機まで。
--   4. ボール: setDamageRateOffset(0.2)。
--   5. 最後の攻撃（XtfLastAttack・既定で有効）: 初回の HP0 で死亡を取り消し、奥義 index 20（skill7＝フィニス＝マキナ）を
--      撃ち終えたら倒れる（原典は takeSkill(7) で効果スロット 20。7 はファンネルのサーベル）。
--   6. 奥義ゲージの自然上昇: 0 にする（原典 start の setSPGainValue(0)。C++ の既定は 1/秒）。
--   その他（スキン Nomal・弾の当たり判定の所在・runScript-addSP の位置・照準の index 5）は SEEKER と同じ。KindSeeker のヘッダ参照。
--
-- ⚠ 形態（XtfForm）が takeOut を使うため boss version >= 2.3。
-- ⚠ KindSeeker と併用しない（内包する Xtf* が2重宣言の assert で止まる）。弾や形態の設定は KindEraser{ funnel = {...} } で渡す。
-- ⚠ 最後の攻撃は Dead より前に宣言する必要がある → KindEraser をボス YAML の先頭に置く。
--    Smash を宣言し、skills に 20（anim: skill7）を定義すること（lastAttack = { skill = N } で変えられる）。
-- ⚠ HP0 で別のこと（待機状態など）をするボスは lastAttack = false にする（Phases の at 0 付近の stop 等と併用しない）。
-- ⚠ 「常に攻撃モード」なら form = { lock = "attack", entry = "shield" }。Mode をボス側の別の状態（通常／待機など）に使っても形態は動かない。
--    登場アニメ in は盾モードの見た目で終わるので、entry が無いと登場直後に攻撃モードの見た目へパッと切り替わる
--    （entry = "shield" で盾の見た目のまま登場し、最初の行動の頭で barrier_off を流して変形する）。
-- ⚠ 範囲外（原典にあるが入れていない）: 属性エネルギーとモードの自動切替（attack8 の elementModeChecker / barrierRestart と
--    transform2 を含む）・属性の被ダメ軽減・ブレイク段階スキン・サブゲージ・ブレイク中にファンネルの一斉攻撃をしない条件。
--
-- 設定（KindSeeker と同じキー＋下の2つ。書いたキーが ERASER の既定値より優先される）:
--   skin / form / funnel / ball / missile / laser / spineSP   KindSeeker と同じ（既定値は上の 1〜4 を重ねたもの）
--   lastAttack  table|true|false  XtfLastAttack の設定（省略・true で既定値のまま有効。false で無効）
--   spGain      number|false      奥義ゲージの自然上昇（既定 0。false で触らない）
--
-- @example
--     boss:add(KindEraser{ spineSP = 20 })                                         -- 原典の再現（盾モードから・最後の攻撃あり）
--     boss:add(KindEraser{ spineSP = 15, form = { lock = "attack", entry = "shield" }, lastAttack = false })
--                                                                     -- 常に攻撃モード（盾の見た目で登場して変形）・自爆なし
------
local _NAME = 'summoner.Choreo.Components.KindEraser'
local _G = _G

local KindSeeker = require('summoner.Choreo.Components.KindSeeker')
local XtfLastAttack = require('summoner.Choreo.Components.XtfLastAttack')
local SPGain = require('summoner.Choreo.Components.SPGain')

local TEXT_UNIT = 500721013

-- ERASER の既定値（KindSeeker の既定の上に重ねる）
local ERASER_MODES = {
    shield = { out = 'out', pop = false },
    attack = { out = 'out', pop = false },
}
local ERASER_FUNNEL = { orbitType = 0, life = 5, max = 11 }
local ERASER_BALL = { damageRate = 0.2 }

local function copy(t)
    local c = {}
    for k, v in pairs(t) do
        c[k] = v
    end
    return c
end

-- base の上に user を重ねた複製（宣言の表はクラスで共有されるので書き換えない）
local function overlay(base, user)
    local merged = copy(base)
    for k, v in pairs(user or {}) do
        merged[k] = v
    end
    return merged
end

-- 内包する部品の設定: false は無効のまま、nil / true は ERASER の既定、table はその上に重ねる
local function part(key, user, base)
    assert(user == nil or type(user) == 'boolean' or type(user) == 'table',
        'Choreo.KindEraser: ' .. key .. ' は設定のテーブルか true / false')
    if user == false then
        return false
    end
    if user == nil or user == true then
        return copy(base)
    end
    return overlay(base, user)
end

-- 形態: modes はモードごとに ERASER の既定を下に敷く（書いたキーが勝つ）
local function formConfig(user)
    assert(user == nil or type(user) == 'boolean' or type(user) == 'table',
        'Choreo.KindEraser: form は設定のテーブルか true / false')
    if user == false then
        return false
    end
    local form = {}
    if type(user) == 'table' then
        form = copy(user)
    end
    local modes = {}
    for name, t in pairs(ERASER_MODES) do
        modes[name] = copy(t)
    end
    local userModes = form.modes
    assert(userModes == nil or type(userModes) == 'table', 'Choreo.KindEraser: form.modes はモード名 => 表 のテーブル')
    for name, t in pairs(userModes or {}) do
        assert(type(t) == 'table', 'Choreo.KindEraser: form.modes.' .. tostring(name) .. ' はテーブル')
        modes[name] = overlay(modes[name] or {}, t)
    end
    form.modes = modes
    if form.textUnit == nil then
        form.textUnit = TEXT_UNIT
    end
    return form
end

local function KindEraser(config)
    config = config or {}
    local lastAttack = config.lastAttack
    assert(lastAttack == nil or type(lastAttack) == 'boolean' or type(lastAttack) == 'table',
        'Choreo.KindEraser: lastAttack は XtfLastAttack の設定のテーブルか true / false')
    local spGain = config.spGain
    if spGain == nil then
        spGain = 0
    end
    assert(spGain == false or type(spGain) == 'number', 'Choreo.KindEraser: spGain は数値か false')

    -- KindSeeker に渡す設定（ERASER の既定値を重ねる。型の検査は KindSeeker が構築時に行う）
    local seeker = copy(config)
    seeker.lastAttack = nil
    seeker.spGain = nil
    seeker.form = formConfig(config.form)
    seeker.funnel = part('funnel', config.funnel, ERASER_FUNNEL)
    seeker.ball = part('ball', config.ball, ERASER_BALL)
    local seekerComponent = KindSeeker(seeker)
    local lastAttackComponent = nil
    if lastAttack ~= false then
        lastAttackComponent = XtfLastAttack(type(lastAttack) == 'table' and lastAttack or nil)
    end

    local component = { name = 'KindEraser' }

    function component.initialize(dispatcher)
        -- 最後の攻撃は先に add する（dead で死亡を取り消して、後ろの dead リスナ＝Dead の撃破 INFO 等を止めるため）
        if lastAttackComponent ~= nil then
            dispatcher:add(lastAttackComponent)
        end
        if spGain ~= false then
            dispatcher:add(SPGain{ value = spGain })
        end
        dispatcher:add(seekerComponent)
    end

    return component
end

_G.package.loaded[_NAME] = KindEraser
return KindEraser
