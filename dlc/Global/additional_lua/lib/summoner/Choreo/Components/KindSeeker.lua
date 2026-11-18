------
-- summoner.Choreo.Components.KindSeeker
--
-- ボス種プリセット: CODE XTF:SEEKER（unit_id 500161013 / spine 500161013 + 50016ef）。
-- 種で共有される「これを書かないと壊れる」定型を1行に畳む薄い皿。既定値は出典の挙動を再現する構成
-- （内包する Xtf* を単体で使うときの既定は最小構成のまま）。
-- 出典: unit/500161013.lua の start（setSkin("Nomal")）・takeIdle / takeBack / takeDamage / excuteAction の
--   盾モード／攻撃モードと zclone<色>・run に登録された弾4系統（funnel / ball / missile / laserHit2 と後始末イベント）・
--   excuteAction の召喚抽選・takeAttack index 5 からの砲身照準・addSP（+20）。
--
-- 種の定型:
--   1. スキン（既定で有効）: spine 500161013 の default スキンには、装甲・両腕・バリアハンド等
--      22 スロットのセットアップ用アタッチメントが無く、名前付きスキンを当てないと本体が欠ける。
--      開幕に SetSkin{"Nomal"}（綴りは spine どおり。他に Break_small / Break_large がある）。
--   2. 形態（既定で有効）: XtfForm。最初は盾モード（shield）で、SetMode{ "attack" } / SetMode{ "shield" } で切り替える。
--      切り替えると次の行動の頭で切替アニメ（barrier_off / barrier_in）とポップテキストを出し、
--      待機 idle / idle2・後退 back1 / back2・被弾 damage_B / damage_S・退場 out / out2・待機エフェクト idle1・
--      セットアップ setUp1＋setUpBarrier / setUp2 をモードに合わせて当てる。SetXtfColor{ "red" } 等で属性色
--      （zclone<色> のアニメ）に切り替わる。C++ の既定名 "back" / "damage" は spine に無く、
--      そのままだと再生が完了せず行動が止まりうるので、形態を外す（form = false）なら自前で差し替えること。
--   3. 弾4系統（既定で有効）: XtfFunnel / XtfBall / XtfMissile / XtfLaser。
--      spine で確認した当たり判定（DAMAGEAREA）の所在:
--        attack4 / attack5 / skill1 / skill2（各 zclone<色> 版を含む）の本体アニメと、そのエフェクト
--        1-attack4 / 1-attack5 / 1-skill1 / 1-skill2 には DAMAGEAREA が無い。
--        当たり判定はすべて弾側にある（missile 22f〜・missileExplosion 1〜6f / laserHit 1f〜 /
--        ball 12〜105f / ファンネルの funnelAttack 28〜52f）。弾を外すとこれらの攻撃は当たらない。
--        skill1 は召喚（runScript-funnel 30f）だけでダメージを持たない。
--        attack1 / attack3 / attack6 / skill3 / skill4 / skill5 は本体に DAMAGEAREA がある。
--      funnel は auto（行動ごとに 49% で召喚・残りで一斉攻撃）・summonMode = "shield"（召喚は盾モードだけ）・
--      saberMode = "attack"（攻撃モードではサーベル）を既定で補う。一斉攻撃の号令 runScript-funnelAttack は
--      funnelAttackCommand にしか無く通常の行動では再生されないので、auto が無いと召喚したファンネルは周回し続ける。
--      laser は aim = { indices = { 5 } } を既定で補う（通常攻撃5の成立時から砲身を向ける。spine の aim 15f も併用）。
--   4. 奥義ゲージ（opt-in）: spineSP を書いたときだけ、runScript-addSP でゲージを加算する（ホストのみ）。
--      SPGain は合成しないので自然上昇は止めない。加算量は SpineSPGain と同じ per-instance 値に持つので
--      SetSpineSPGain で実行時に変えられる。
--      ⚠ runScript-addSP は attack1 / attack3 / attack3break / attack4 / attack5 / attack6（と zclone 版）
--         にだけあり、skill には無い。
--
-- ⚠ 形態（XtfForm）が takeOut を使うため boss version >= 2.3（弾の Component は update を使う 1.1）。
-- ⚠ 通常攻撃・奥義のローテはモードでは切り替わらない。Attack / Smash の byMode で書く
--    （盾モード shield: attack1〜3 / skill1〜3、攻撃モード attack: attack4〜6 / skill4〜5）。
-- ⚠ funnel の auto（既定で有効）は Sync の receive ポートを1本使う（上限10本）。
-- ⚠ XtfForm / XtfFunnel / XtfBall / XtfMissile / XtfLaser を KindSeeker と別に add すると、2重宣言の assert で止まる。
--    設定は KindSeeker{ form = {...}, funnel = {...} } のように渡す（個別に並べるなら KindSeeker 側をその系統だけ false にする）。
-- ⚠ AnimVariant と併用しない（形態と同じ生イベントで名前を当て合い、後から宣言した方が勝つ）。
-- ⚠ spineSP と SpineSPGain は併用できない。先に宣言された SpineSPGain は assert で止める。KindSeeker の後に
--    宣言した SpineSPGain は検出できず、後から宣言した方の加算量が2回入り、SpineSPGain が自然上昇も止める。
-- ⚠ Timeline 等で ball / missile / funnel / funnelAttack / laserHit2 / aim / addSP を自前で処理すると二重に発火する。
-- ⚠ Start や Mode の初期 onEnter から XtfFunnelSummon を呼ぶなら、KindSeeker を先に宣言する
--    （ファンネルの一覧は start で作られ、start のリスナは宣言順に走る）。
-- ⚠ Mode を宣言するなら状態名は shield / attack にする（変えるなら form.modes / funnel.summonMode / saberMode も合わせる）。
-- ⚠ funnel.laserSkill / funnel.saberSkill（既定 2 / 7）は弾に直接設定する効果スロット番号。YAML の skills に
--    その番号の効果を定義すること（未定義の番号では弾の ActiveSkill が空になり、スキルの倍率・属性が乗らない）。
-- ⚠ ボーン名（ball.bone / missile.bone / laser.aim.bones）は spine に実在する名前にする。
--    C++ の getBoneWorldPositionX/Y は findBone の結果を NULL チェックしないので、無い名前だと実機でクラッシュする。
-- ⚠ 範囲外: モードの自動切替の条件（盾モードでの属性ダメージ蓄積・攻撃モードでの属性エネルギー消費）、
--    盾モードの被ダメ軽減、ブレイク段階のスキン、サブゲージ。切替はクエストの YAML で SetMode / SetXtfColor を呼ぶ。
-- ⚠ 設定の型が違うと、クラス定義の読み込み時に assert で止める（戦闘中には落とさない）。
-- ⚠ 大型ボス共通の定型（NoHitStop / attackDelay / 行動ローテ / Dead 等）は種の管轄外。
--    ボス YAML 側で汎用 Component を並べること（[[KindDragon]] と同じ方針）。
--
-- 設定:
--   skin     string|false        開幕に当てるスキン名（既定 "Nomal"。false で SetSkin しない）
--   form     table|true|false    XtfForm の設定（省略・true で既定値のまま有効。false で無効）
--   funnel   table|true|false    XtfFunnel の設定（省略・true で有効。false で無効）。auto / summonMode / saberMode を
--                                書かなければ auto = {}（summon 49）/ "shield" / "attack" を補う。auto = false で抽選しない
--   ball     table|true|false    XtfBall の設定（省略・true で既定値のまま有効。false で無効）
--   missile  table|true|false    XtfMissile の設定（省略・true で既定値のまま有効。false で無効）
--   laser    table|true|false    XtfLaser の設定（省略・true で有効。false で無効）。aim を書かなければ
--                                aim = { indices = { 5 } } を補う。aim を書いたらそれに従う
--   spineSP  number|table|true|false
--                                runScript-addSP 1回のゲージ加算量（数値か { value = N }。true と、
--                                table で value 省略時は 20。省略・false で加算しない）
--
-- @example
--     boss:add(KindSeeker{})                       -- スキン＋形態（盾モードから）＋弾4系統
--     boss:add(KindSeeker{ spineSP = 20, form = { modes = { attack = { idle = "idle3" } } } })
--     boss:add(KindSeeker{ ball = { skill = 8 }, laser = { aim = false }, funnel = { auto = false } })
------
local _NAME = 'summoner.Choreo.Components.KindSeeker'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Start = require('summoner.Choreo.Components.Start')
local Timeline = require('summoner.Choreo.Components.Timeline')
local XtfForm = require('summoner.Choreo.Components.XtfForm')
local XtfFunnel = require('summoner.Choreo.Components.XtfFunnel')
local XtfBall = require('summoner.Choreo.Components.XtfBall')
local XtfMissile = require('summoner.Choreo.Components.XtfMissile')
local XtfLaser = require('summoner.Choreo.Components.XtfLaser')
local Actions = require('summoner.Choreo.Actions')

local DEFAULT_SPINE_SP = 20

-- 既定で有効な内包 Component の設定: nil / true は既定値のまま、false は無効（nil を返す）
local function enabled(v)
    if v == false then
        return nil
    end
    if v == nil or v == true then
        return {}
    end
    return v
end

-- key が無ければ value を補った複製を返す（宣言の表はクラスで共有されるので書き換えない）
local function withDefault(t, key, value)
    if t[key] ~= nil then
        return t
    end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    copy[key] = value
    return copy
end

-- 設定の型検査（クラス定義の読み込み時に止め、戦闘中に tolua の引数検査で落ちないようにする）
local function checkName(key, v)
    assert(v == nil or v == false or type(v) == 'string',
        'Choreo.KindSeeker: ' .. key .. ' はアニメ名（文字列）か false')
end

local function checkPart(key, v)
    assert(v == nil or type(v) == 'boolean' or type(v) == 'table',
        'Choreo.KindSeeker: ' .. key .. ' は設定のテーブルか true / false')
end

-- spineSP の加算量（nil / false は加算しない）
local function spineSPValue(sp)
    if sp == nil or sp == false then
        return nil
    end
    local value = sp
    if sp == true then
        value = nil
    elseif type(sp) == 'table' then
        value = sp.value or sp[1]
    end
    if value == nil then
        value = DEFAULT_SPINE_SP
    end
    assert(type(value) == 'number',
        'Choreo.KindSeeker: spineSP は数値か { value = N } か true / false')
    return value
end

-- runScript-addSP でゲージを加算する（ホストのみ）。SPGain は合成しないので自然上昇は止めない。
-- 加算量は SpineSPGain と同じ per-instance 値に持ち、SetSpineSPGain で変えられるようにする
local function addSpineSP(dispatcher, value)
    dispatcher:add(Timeline{
        addSP = function(self, event)
            if not self.isHostPlayer then
                return
            end
            local v = self._spineSPGainValue
            if v == nil then
                v = value
            end
            local unit = event.unit or self.unit
            unit:addSP(v)
        end,
    })
    dispatcher:addEventListener(Events.OnLoad, function(self, event)
        self._spineSPGainValue = value
    end)
end

local function KindSeeker(config)
    config = config or {}
    checkName('skin', config.skin)
    assert(config.back == nil and config.damage == nil,
        'Choreo.KindSeeker: back / damage は form.modes.<モード>.back / damage で指定してください')
    checkPart('form', config.form)
    checkPart('funnel', config.funnel)
    checkPart('ball', config.ball)
    checkPart('missile', config.missile)
    checkPart('laser', config.laser)
    local spValue = spineSPValue(config.spineSP)
    local component = { name = 'KindSeeker' }

    function component.initialize(dispatcher)
        local skin = config.skin
        if skin == nil then
            skin = 'Nomal'
        end
        if skin ~= false then
            dispatcher:add(Start{ Actions.SetSkin{ skin } })
        end

        local funnel = enabled(config.funnel)
        if funnel ~= nil then
            funnel = withDefault(funnel, 'auto', {})
            funnel = withDefault(funnel, 'summonMode', 'shield')
            funnel = withDefault(funnel, 'saberMode', 'attack')
            dispatcher:add(XtfFunnel(funnel))
        end
        local ball = enabled(config.ball)
        if ball ~= nil then
            dispatcher:add(XtfBall(ball))
        end
        local missile = enabled(config.missile)
        if missile ~= nil then
            dispatcher:add(XtfMissile(missile))
        end
        local laser = enabled(config.laser)
        if laser ~= nil then
            dispatcher:add(XtfLaser(withDefault(laser, 'aim', { indices = { 5 } })))
        end

        if spValue ~= nil then
            assert(not dispatcher:hasComponent('SpineSPGain'),
                'Choreo: KindSeeker の spineSP と SpineSPGain は併用できません。どちらか一方にしてください')
            addSpineSP(dispatcher, spValue)
        end

        -- 形態は最後に add する: モード切替の行動の取り消し（excuteAction の prevent）が、
        -- 先に走る他のリスナ（ファンネルの抽選・照準の解除）を止めないようにする
        local form = enabled(config.form)
        if form ~= nil then
            dispatcher:add(XtfForm(form))
        end
    end

    return component
end

_G.package.loaded[_NAME] = KindSeeker
return KindSeeker
