------
-- summoner.Choreo.Components.XtfFunnel
--
-- CODE XTF 系の共有ギミック「ファンネル」: 小型オービットを召喚してボスの上空を周回させ、
-- 号令で一斉にレーザー（照準 → 着弾オービット）かビームサーベル（突撃）を行わせる。
--   召喚 → 登場移動(enter) → 周回(idle) ⇄ 攻撃(laser / saber) → 寿命が尽きたら deadAnim で消える
-- 出典: unit/500161013.lua（CODE XTF:SEEKER）の funnel / funnelAttack / funnelControll /
--   laserHit / funnelStateEnd / onDestroyfunnel / excuteAction の召喚抽選。
--   ERASER（unit/500721013.lua）も同一の弾道実装。
--
-- 発火経路（どれも同じ召喚 / 攻撃処理を呼ぶ）:
--   1. spine（既定で有効）: 本体アニメの runScript-funnel で召喚、runScript-funnelAttack で一斉攻撃。
--      spine 500161013 では funnel = skill1 30f・zclone<色>skill1 30f・funnelSummon 0f、
--      funnelAttack = funnelAttackCommand 0f。本体アニメは全端末で再生されるので同期は要らない。
--   2. Action: XtfFunnelSummon{} / XtfFunnelAttack{}。呼ばれた端末で実行するだけなので、
--      onUse / Start / Phases など全端末で走る文脈から呼ぶ（ホストだけで走る文脈から呼ばない）。
--   3. auto（XtfFunnel 単体では opt-in。KindSeeker では既定で有効）: 行動のたび（excuteAction）に
--      ホストが抽選し、summon% で召喚、外れたら一斉攻撃。ホストはその場で適用して Sync で配信し、
--      ゲストは受信して適用する。
--
-- 攻撃の種別: 引数（"laser" / "saber"）で明示されればそれ。無ければ Mode が saberMode のいずれかなら
--   saber、それ以外（Mode 未使用を含む）は laser。
-- 攻撃の対象: 各ファンネルの攻撃1フレーム目（号令の後の最初の update）に決める。直近に成立した行動
--   （takeAttack / takeSkill の @commit）のターゲットが生存していればそれ、居なければその時点のボスの
--   ターゲット。レーザーの向きとサーベルの追尾は毎フレーム同じ規則で引き直し、レーザーの着弾は
--   1フレーム目に決めた相手に置く（auto や onUse の Action は @commit より前に走るため、号令の時点では決めない）。
--
-- ⚠ update を使うため boss version >= 1.1。
-- ⚠ spine 側の前提: エフェクト spine（50016ef）の funnelLaser 12f に runScript-laserHit、
--    funnelLaser 24f / funnelAttack 54f に runScript-funnelStateEnd、funnelDead 0f に runScript-onDestroyfunnel。
--    これらの event.unit はファンネル自身（親の uniqueID を継承するのでボスの Lua に届く）。
-- ⚠ 当たり判定: レーザーは着弾オービット hitAnim（laserHit 1f〜 に DAMAGEAREA）が laserSkill で当たる
--    （1斉射につき1発。damageRateOffset はその時点のファンネル数）。サーベルはファンネル自身の
--    funnelAttack（28〜52f に DAMAGEAREA）が saberSkill で当たる。funnelIdle / funnelLaser には当たり判定が無い。
-- ⚠ laserSkill / saberSkill は弾に直接設定する効果スロット番号。YAML の skills にその番号（既定 2 / 7）の
--    効果を定義すること（未定義の番号では弾の ActiveSkill が空になり、スキルの倍率・属性が乗らない）。
--    false にすると設定せず、弾は生成時のボスの ActiveSkill を引き継ぐ。着弾オービットは funnelLaser 12f
--    時点のボスの値（auto で号令した場合は、その後に始まった行動のスキルになりうる）、サーベルのファンネルは
--    召喚時点のボスの値のまま。
-- ⚠ orbitType=2 のファンネルはプレイヤーが撃墜できる。撃墜時は C++ が deadAnim を流し、
--    その 0f の onDestroyfunnel で一覧から外す。
-- ⚠ C++ 側で消滅処理（playEnd: 撃墜・ヒット・親の死亡）に入ったファンネルは、次の update・号令・攻撃の終わりで
--    一覧から外し、以後触らない。playEnd は終了アニメ名を空にしてから終了アニメを流すので、一覧にあるのに
--    終了アニメ名が空なら playEnd 済み（同じフレームの号令で消滅アニメを上書きしないため）。
--    そのため deadAnim は空にできない。
-- ⚠ 寿命切れの消滅は Lua から deadAnim を流す。C++ の playEnd と同じく、終了アニメ名を空にし、
--    Lazer 型・最大ヒット数1にしてから流す（Unit 型のままだと消滅中も被弾対象に残る）。
-- ⚠ ボスの退場が確定している（getIsDead）間は、召喚・攻撃・auto の抽選・update をしない。死亡時はエンジンが
--    全弾に playEnd を掛けるので、deadAnim 0f の onDestroyfunnel で一覧から外れる。
-- ⚠ 2回宣言すると assert で止まる。KindSeeker と併用するなら KindSeeker{ funnel = {...} } で設定する。
-- ⚠ Start や Mode の初期 onEnter から XtfFunnelSummon を呼ぶなら、XtfFunnel（または KindSeeker）を先に宣言する
--    （ファンネルの一覧は XtfFunnel の start で作られ、start のリスナは宣言順に走る）。
-- ⚠ summonMode / saberMode は Choreo 共通のモード（self._mode）で判定する（XtfForm{ lock } で形態を固定して
--    いればそのモード）。モードが無い（Mode も XtfForm も無い）ときは召喚を制限せず、攻撃はレーザーになる。
-- ⚠ 設定の型が違う（false に意味の無い設定への false を含む）と、ボス定義の読み込み時に assert で止まる。
-- ⚠ サーベルの狙いの散らしは端末ローカルの乱数（見た目のみ）。
-- ⚠ auto を有効にすると Sync の receive ポートを1本使う（上限10本）。
--
-- 設定（nil は既定値。false は下に書いた設定でだけ使える）:
--   anim        string        周回アニメ。召喚時の生成アニメも兼ねる（既定 "funnelIdle"。ループ再生）
--   deadAnim    string        消滅アニメ。終了アニメにも設定する（既定 "funnelDead"。空は不可）
--   orbitType   number        addOrbitSystem の type（既定 2＝撃墜可能。ERASER 系は 0）
--   life        number        寿命。登場移動の終わりと攻撃の終わりごとに1減り、0 で消える（既定 10）
--   max         number|false  同時に出せる数の上限（既定 nil＝無制限。false も無制限）
--   spawnX      number        召喚位置のボス位置からの X オフセット（既定 -80）
--   spawnY      number        召喚位置のボス位置からの Y オフセット（既定 400）
--   centerY     number        周回中心のボス位置からの高さ（既定 300）
--   radius      number        周回半径（既定 200）
--   laserAnim   string        レーザー攻撃アニメ（既定 "funnelLaser"）
--   hitAnim     string        レーザー着弾オービットのアニメ（既定 "laserHit"）
--   laserSkill  number|false  着弾オービットの ActiveSkill（既定 2。false で設定しない＝ボスの値を引き継ぐ）
--   saberAnim   string        サーベル攻撃アニメ（既定 "funnelAttack"）
--   saberSkill  number|false  サーベル時にファンネルへ設定する ActiveSkill
--                             （既定 7。false で設定しない＝召喚時のボスの値のまま）
--   saberSpread number|false  サーベルの狙いの散らし幅。ターゲットの足元から X / Y それぞれ
--                             [1 - 幅, 幅] の整数（既定 200。0 / false で散らさない）
--   saberMode   string|table|false  この Mode の間は攻撃がサーベルになる
--                             （状態名かその配列。既定 nil＝常にレーザー。false も同じ）
--   summonMode  string|table|false  auto の召喚をこの Mode の間に限る（既定 nil＝常に。false も同じ）。
--                             抽選が召喚に当たって Mode が外れていたら、その行動では何もしない（モードが無ければ制限しない）
--   spine       bool          runScript-funnel / funnelAttack で発火させる（既定 true。false で発火させない）
--   auto        table|bool    { summon = N }: 行動ごとにホストが抽選し、N% で召喚・残りで一斉攻撃
--                             （既定 nil＝無効。false も無効。true と {} は summon 49）。
--                             召喚はバトル状態が active のときだけで、それ以外は一斉攻撃になる
--
-- Action:
--   XtfFunnelSummon{}            召喚（start 前・XtfFunnel 未搭載・max 到達時・ボス退場後は何もしない）
--   XtfFunnelAttack{ "saber" }   一斉攻撃（"laser" / "saber"。kind = でも可。省略時は saberMode で決める）。
--                                それ以外の文字列はボス定義の読み込み時（Action の構築時）に assert で止まる
--
-- @example
--     boss:add(XtfFunnel{})
--     boss:add(XtfFunnel{ saberMode = "attack", summonMode = "shield", auto = { summon = 49 } })
--     boss:add(Smash{ sets = { { 1 } }, onUse = { [1] = { XtfFunnelAttack{ "saber" } } } })
------
local _NAME = 'summoner.Choreo.Components.XtfFunnel'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')
local Sync = require('summoner.Choreo.Components.Sync')

local ONE_FRAME = 0.016666667
local PI = 3.14              -- 度⇔ラジアン換算。出典の弾道と同じ軌跡にするため 3.14 で計算する
local HITS = 999             -- サーベルの多段ヒット（funnelAttack は resetHitList を12回打つ）
local ORBIT_LAZER = 0        -- kOrbitType_Lazer（被弾対象にならず、ヒットしても playEnd されない型）
local ENTER_FRAMES = 46      -- 登場移動のフレーム数（60fps 換算）
local ENTER_BOOST = 10       -- 登場移動の速度 = 1 + 残り割合 × ENTER_BOOST
local CORE_SPEED = 1.5       -- 周回の基準角の回転（度/フレーム）
local IDLE_TURN = 4          -- 周回中の旋回上限（度/フレーム）
local IDLE_SHRINK = 3        -- 周回半径へ寄る速さ（px/フレーム）
local SABER_SPEED = 10       -- サーベル突撃の速度（px/フレーム）
local DEFAULT_SUMMON = 49    -- auto の既定の召喚確率（%）

local CHANNEL = 'xtfFunnel'
local CODE_SUMMON, CODE_LASER, CODE_SABER = 0, 1, 2
local KINDS = { laser = true, saber = true }

-- 設定値を読む: nil だけ既定値にし（false を既定値で潰さない）、型が違えばボス定義の読み込み時に止める
local function setting(key, value, default, kind)
    if value == nil then
        return default
    end
    assert(type(value) == kind,
        'Choreo.XtfFunnel: ' .. key .. ' は ' .. kind .. '（実際: ' .. tostring(value) .. '）')
    return value
end

-- false に「使わない」の意味がある設定: false はそのまま返し、それ以外は setting と同じ
local function optional(key, value, default, kind)
    if value == false then
        return false
    end
    return setting(key, value, default, kind)
end

local function battle()
    return megast.Battle:getInstance()
end

local function toRad(deg)
    return deg * PI / 180
end

-- 始点から終点への角度（度）
local function getDeg(sx, sy, tx, ty)
    return math.atan2(ty - sy, tx - sx) * 180 / PI
end

-- angle を goal へ最短回りで最大 maxStep 度だけ回す。戻り値は [0,360)
local function turnToward(angle, goal, maxStep)
    local dir = (goal - angle) % 360
    if dir > 180 then
        dir = dir - 360
    end
    if dir > maxStep then
        dir = maxStep
    elseif dir < -maxStep then
        dir = -maxStep
    end
    return (angle + dir) % 360
end

-- ユニットの位置＋MAIN ボーン（照準点）
local function aimPoint(unit)
    local sk = unit:getSkeleton()
    return unit:getPositionX() + sk:getBoneWorldPositionX('MAIN'),
           unit:getPositionY() + sk:getBoneWorldPositionY('MAIN')
end

local function playerUnit(index)
    if index == nil then
        return nil
    end
    return battle():getTeam(true):getTeamUnit(index)
end

-- 攻撃の対象 index: 直近に成立した行動のターゲットが生存していればそれ、居なければ今のボスのターゲット
local function currentTarget(self)
    local index = self._xtfTarget
    if index ~= nil and playerUnit(index) ~= nil then
        return index
    end
    local unit = self.unit
    if unit == nil or unit == false then
        return nil
    end
    local t = unit:getTargetUnit()
    if t == nil then
        return nil
    end
    return t:getIndex()
end

-- ボスが居ない（start 前）か、退場が確定している
local function isGone(unit)
    return unit == nil or unit == false or unit:getIsDead()
end

-- 散らしの乱数: [1 - width, width] の整数（LuaUtilities.rand は [min, max)）。幅 0 以下は散らさない
local function spread(width)
    if width <= 0 then
        return 0
    end
    return LuaUtilities.rand(1, width * 2 + 1) - width
end

-- ループ中に一覧が縮んでも回せるよう、走査は複製に対して行う
-- （終了アニメの 0f の runScript は takeAnimation の中で同期発火しうる）
local function snapshot(list)
    local copy = {}
    for i = 1, #list do
        copy[i] = list[i]
    end
    return copy
end

local function findByOrbit(list, orbit)
    for i = 1, #list do
        if list[i].orbit == orbit then
            return list[i]
        end
    end
    return nil
end

local function removeEntry(list, entry)
    for i = 1, #list do
        if list[i] == entry then
            table.remove(list, i)
            return
        end
    end
end

-- C++ 側で消滅処理（playEnd）に入っている: playEnd は終了アニメ名を空にしてから終了アニメを流す。
-- 一覧に残っている弾の終了アニメ名は、Lua 主導で終わらせるまで deadAnim のまま
local function endedByEngine(e)
    return e.orbit:getEndAnimationName() == ''
end

-- 一覧から外すだけで弾には触らない（終了アニメは C++ が最後まで流して remove する）
local function drop(list, e)
    e.done = true
    removeEntry(list, e)
end

-- Mode の状態名（文字列かその配列）を配列に揃える。nil / false は指定なし
local function modeList(v, key)
    if v == nil or v == false then
        return nil
    end
    if type(v) == 'string' then
        v = { v }
    end
    assert(type(v) == 'table' and #v > 0,
        'Choreo.XtfFunnel: ' .. key .. ' は Mode の状態名（文字列）か、その配列')
    return v
end

-- 今のモード: XtfForm{ lock } で形態を固定していればそのモード、無ければ Choreo 共通の self._mode
local function currentMode(self)
    return self._xtfFormLock or self._mode
end

local function inModes(self, modes)
    local mode = currentMode(self)
    for i = 1, #modes do
        if mode == modes[i] then
            return true
        end
    end
    return false
end

local makeXtfFunnel

local XtfFunnel = setmetatable({}, {
    __call = function(_, config) return makeXtfFunnel(config) end
})

function makeXtfFunnel(config)
    config = config or {}
    local anim = setting('anim', config.anim, 'funnelIdle', 'string')
    local deadAnim = setting('deadAnim', config.deadAnim, 'funnelDead', 'string')
    assert(deadAnim ~= '', 'Choreo.XtfFunnel: deadAnim は空にできない（C++ の消滅処理の検知に使う）')
    local orbitType = setting('orbitType', config.orbitType, 2, 'number')
    local life = setting('life', config.life, 10, 'number')
    local maxCount = optional('max', config.max, nil, 'number')
    if maxCount == false then
        maxCount = nil
    end
    local spawnX = setting('spawnX', config.spawnX, -80, 'number')
    local spawnY = setting('spawnY', config.spawnY, 400, 'number')
    local centerY = setting('centerY', config.centerY, 300, 'number')
    local radius = setting('radius', config.radius, 200, 'number')
    local laserAnim = setting('laserAnim', config.laserAnim, 'funnelLaser', 'string')
    local hitAnim = setting('hitAnim', config.hitAnim, 'laserHit', 'string')
    local laserSkill = optional('laserSkill', config.laserSkill, 2, 'number')
    local saberAnim = setting('saberAnim', config.saberAnim, 'funnelAttack', 'string')
    local saberSkill = optional('saberSkill', config.saberSkill, 7, 'number')
    local saberSpread = optional('saberSpread', config.saberSpread, 200, 'number')
    if saberSpread == false then
        saberSpread = 0
    end
    local saberModes = modeList(config.saberMode, 'saberMode')
    local summonModes = modeList(config.summonMode, 'summonMode')
    local useSpine = setting('spine', config.spine, true, 'boolean')
    local auto = config.auto
    if auto == true then
        auto = {}
    elseif auto == false then
        auto = nil
    end
    assert(auto == nil or type(auto) == 'table', 'Choreo.XtfFunnel: auto は { summon = N } のテーブルか true / false')
    local summonRate = DEFAULT_SUMMON
    if auto ~= nil then
        summonRate = setting('auto.summon', auto.summon, DEFAULT_SUMMON, 'number')
    end

    local component = { name = 'XtfFunnel' }

    local function onLoad(self, event)
        self._xtfFunnels = {}
        self._xtfFunnelCore = 0
        self._xtfLaserFired = false
        self._xtfTarget = nil
    end

    -- Lua 主導の消滅: 先に一覧から外し、C++ の playEnd と同じ状態（終了アニメ名を空・Lazer 型・
    -- 最大ヒット数1）にしてから deadAnim を流す。終了名を空にしないと消滅アニメが2回流れる
    local function finish(self, e)
        e.done = true
        removeEntry(self._xtfFunnels, e)
        local orbit = e.orbit
        orbit:setEndAnimationName('')
        orbit:setOrbitType(ORBIT_LAZER)
        orbit:setHitCountMax(1)
        orbit:takeAnimation(0, deadAnim, false)
    end

    -- 登場移動・攻撃の終わり: 寿命を1減らし、残っていれば周回へ戻す（回転は戻さない）
    local function stateEnd(self, e)
        if endedByEngine(e) then
            drop(self._xtfFunnels, e)
            return
        end
        e.frame = 0
        e.life = e.life - 1
        if e.life <= 0 then
            finish(self, e)
            return
        end
        e.state = 'idle'
        e.orbit:takeAnimation(0, anim, true)
    end

    local function summon(self)
        local funnels = self._xtfFunnels
        local unit = self.unit
        if funnels == nil or isGone(unit) then
            return
        end
        if maxCount ~= nil and #funnels >= maxCount then
            return
        end
        local orbit = unit:addOrbitSystem(anim, orbitType)
        if orbit == nil then
            return
        end
        orbit:setHitCountMax(HITS)
        orbit:setEndAnimationName(deadAnim)
        orbit:takeAnimation(0, anim, true)      -- 生成時のアニメは非ループなのでループで掛け直す
        local x = unit:getPositionX() + spawnX
        local y = unit:getPositionY() + spawnY
        orbit:setPosition(x, y)
        table.insert(funnels, {
            orbit = orbit, x = x, y = y, angle = 0, dist = 0, frame = 0,
            state = 'enter', life = life, target = nil, ox = 0, oy = 0,
        })
    end

    local function pickKind(self)
        if saberModes ~= nil and inModes(self, saberModes) then
            return 'saber'
        end
        return 'laser'
    end

    -- 一斉攻撃（登場移動中のファンネルも含む）。対象は各ファンネルの攻撃1フレーム目に決める
    local function attack(self, kind)
        local funnels = self._xtfFunnels
        if funnels == nil or isGone(self.unit) then
            return
        end
        if kind == nil then
            kind = pickKind(self)
        end
        self._xtfLaserFired = false
        local list = snapshot(funnels)
        for i = 1, #list do
            local e = list[i]
            if not e.done then
                if endedByEngine(e) then
                    drop(funnels, e)
                else
                    e.frame = 0
                    e.target = nil
                    if kind == 'saber' then
                        e.state = 'saber'
                        -- 弾の ActiveSkill は生成時の親の値のコピーなので、ファンネル自身に設定する
                        -- （false なら設定せず、召喚時のボスの値のまま）
                        if saberSkill ~= false then
                            e.orbit:setActiveSkill(saberSkill)
                        end
                        e.orbit:takeAnimation(0, saberAnim, false)
                    else
                        e.state = 'laser'
                        e.orbit:takeAnimation(0, laserAnim, false)
                    end
                end
            end
        end
    end

    -- レーザーの着弾: 1斉射につき1発だけ、1フレーム目に決めた相手の照準点に着弾オービットを置く
    local function laserHit(self, orbit)
        local funnels = self._xtfFunnels
        local e = findByOrbit(funnels, orbit)
        if e == nil or self._xtfLaserFired then
            return
        end
        local index = e.target
        if e.frame == 0 then
            index = currentTarget(self)          -- 号令の後まだ update が来ていない
        end
        local t = playerUnit(index)
        local unit = self.unit
        if t == nil or isGone(unit) then
            return
        end
        self._xtfLaserFired = true
        local hit = unit:addOrbitSystem(hitAnim, 0)
        if hit == nil then
            return
        end
        hit:setPosition(aimPoint(t))
        hit:setDamageRateOffset(#funnels)
        if laserSkill ~= false then
            hit:setActiveSkill(laserSkill)       -- false なら生成時（この時点）のボスの値を引き継ぐ
        end
    end

    local function moveBy(e, distance)
        local rad = toRad(e.angle)
        e.x = e.x + math.cos(rad) * distance
        e.y = e.y + math.sin(rad) * distance
        e.orbit:setPosition(e.x, e.y)
    end

    -- 登場移動: 角度 0 の方向へ減速しながら進む。ENTER_FRAMES で周回へ移り、そのフレームは速度1で進む
    local function updateEnter(self, e, frameRate)
        local f = e.frame
        e.frame = f + frameRate
        local speed = 1
        if f < ENTER_FRAMES then
            speed = 1 + (ENTER_FRAMES - f) / ENTER_FRAMES * ENTER_BOOST
        else
            stateEnd(self, e)
            if e.done then
                return
            end
        end
        moveBy(e, speed * frameRate)
    end

    -- 周回: 中心からの距離を radius まで縮めつつ、等間隔の目標角（基準角が回る）へ旋回する
    local function updateIdle(self, e, rank, count, cx, cy, frameRate)
        if e.frame == 0 then
            local dx, dy = e.x - cx, e.y - cy
            e.dist = math.sqrt(dx * dx + dy * dy)
            e.angle = getDeg(cx, cy, e.x, e.y) % 360
        end
        e.frame = e.frame + frameRate
        if e.dist > radius then
            e.dist = e.dist - IDLE_SHRINK * frameRate
        end
        local goal = (rank - 1) * 360 / count + self._xtfFunnelCore
        e.angle = turnToward(e.angle, goal, IDLE_TURN * frameRate)
        local rad = toRad(e.angle)
        e.x = cx + math.cos(rad) * e.dist
        e.y = cy + math.sin(rad) * e.dist
        e.orbit:setPosition(e.x, e.y)
    end

    -- レーザー: 1フレーム目に着弾の相手を決め、毎フレーム攻撃対象の照準点へ向く（不在なら向きを保つ）
    local function updateLaser(self, e, frameRate)
        local index = currentTarget(self)
        if e.frame == 0 then
            e.target = index
        end
        e.frame = e.frame + frameRate
        local t = playerUnit(index)
        if t == nil then
            return
        end
        local tx, ty = aimPoint(t)
        e.angle = getDeg(e.x, e.y, tx, ty) % 360
        e.orbit:setRotation(360 - e.angle)
    end

    -- サーベル: 攻撃対象の足元を散らした点へ向きを合わせながら直進する（不在なら直進を続ける）
    local function updateSaber(self, e, frameRate)
        local index = currentTarget(self)
        if e.frame == 0 then
            e.target = index
            e.ox = spread(saberSpread)
            e.oy = spread(saberSpread)
        end
        e.frame = e.frame + frameRate
        local t = playerUnit(index)
        if t ~= nil then
            e.angle = getDeg(e.x, e.y, t:getPositionX() + e.ox, t:getPositionY() + e.oy) % 360
            e.orbit:setRotation(360 - e.angle)
        end
        moveBy(e, SABER_SPEED * frameRate)
    end

    local function onUpdate(self, event)
        local funnels = self._xtfFunnels
        local unit = self.unit
        if funnels == nil or isGone(unit) then
            return
        end
        local frameRate = (event.deltaTime or 0) / ONE_FRAME
        self._xtfFunnelCore = (self._xtfFunnelCore + CORE_SPEED * frameRate) % 360
        local count = #funnels
        if count == 0 then
            return
        end
        local cx = unit:getPositionX()
        local cy = unit:getPositionY() + centerY
        local list = snapshot(funnels)
        for i = 1, #list do
            local e = list[i]
            if not e.done then
                if endedByEngine(e) then
                    drop(funnels, e)
                elseif e.state == 'enter' then
                    updateEnter(self, e, frameRate)
                elseif e.state == 'idle' then
                    updateIdle(self, e, i, count, cx, cy, frameRate)
                elseif e.state == 'laser' then
                    updateLaser(self, e, frameRate)
                elseif e.state == 'saber' then
                    updateSaber(self, e, frameRate)
                end
            end
        end
    end

    local function onRun(self, event)
        local funnels = self._xtfFunnels
        if funnels == nil then
            return
        end
        local ev = event.spineEvent
        if ev == 'laserHit' then
            laserHit(self, event.unit)
        elseif ev == 'funnelStateEnd' then
            self._xtfLaserFired = false
            local e = findByOrbit(funnels, event.unit)
            if e ~= nil then
                stateEnd(self, e)
            end
        elseif ev == 'onDestroyfunnel' then
            -- 撃墜・消滅アニメの 0f。Lua 主導で消したもの・外したものは一覧に無いので何もしない
            local e = findByOrbit(funnels, event.unit)
            if e ~= nil then
                drop(funnels, e)
            end
        elseif useSpine and ev == 'funnel' then
            summon(self)
        elseif useSpine and ev == 'funnelAttack' then
            attack(self, nil)
        end
    end

    -- 行動が成立した回のターゲットを、一斉攻撃の対象として覚えておく
    local function recordTarget(self, event)
        local unit = event.unit or self.unit
        if unit == nil or unit == false then
            return
        end
        local t = unit:getTargetUnit()
        if t == nil then
            self._xtfTarget = nil
        else
            self._xtfTarget = t:getIndex()
        end
    end

    local function apply(self, code)
        if code == CODE_SUMMON then
            summon(self)
        elseif code == CODE_SABER then
            attack(self, 'saber')
        else
            attack(self, 'laser')
        end
    end

    -- auto: ホストが抽選してその場で適用し、ゲストへは結果だけ配信する
    -- （hostDecide の handler 経由でエンジン操作をすると実機でクラッシュするため使わない）
    local function onExecute(self, event)
        if not self.isHostPlayer or self._xtfFunnels == nil or isGone(self.unit) then
            return
        end
        local code
        if LuaUtilities.rand(0, 100) < summonRate
                and battle():getBattleState() == kBattleState_active then
            if summonModes ~= nil and currentMode(self) ~= nil and not inModes(self, summonModes) then
                return
            end
            code = CODE_SUMMON
        elseif pickKind(self) == 'saber' then
            code = CODE_SABER
        else
            code = CODE_LASER
        end
        apply(self, code)
        self:broadcast(CHANNEL, code)
    end

    -- Action（XtfFunnelSummon / XtfFunnelAttack）の呼び出し口
    component.xtfFunnelSummon = function(self)
        summon(self)
    end
    component.xtfFunnelAttack = function(self, kind)
        attack(self, kind)
    end

    function component.initialize(dispatcher)
        local declared = 0
        for _, name in ipairs(dispatcher.components) do
            if name == 'XtfFunnel' then
                declared = declared + 1
            end
        end
        assert(declared <= 1, 'Choreo: XtfFunnel が2回宣言されています。'
            .. 'KindSeeker と併用するなら KindSeeker{ funnel = {...} } で設定してください')
        if auto ~= nil then
            if not dispatcher:hasComponent('Sync') then
                dispatcher:add(Sync.create())
            end
            dispatcher:openChannel(CHANNEL, function(self, code) apply(self, code) end)
            dispatcher:addEventListener(Events.excuteAction, onExecute)
        end
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnTimeline, onRun)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
        dispatcher:addEventListener(Events.OnAttackCommit, recordTarget)
        dispatcher:addEventListener(Events.OnSmashCommit, recordTarget)
    end

    return component
end

------
-- XtfFunnelSummon Action: ファンネルを1機召喚する
-- XtfFunnel 未搭載・start 前は何もしない。決定的な処理なので同期しない（全端末で走る文脈から呼ぶ）。
------
XtfFunnel.Summon = Action.define('XtfFunnelSummon', function(a, d, e)
    if d._xtfFunnels == nil then
        return
    end
    d:xtfFunnelSummon()
end)

------
-- XtfFunnelAttack Action: 全ファンネルで一斉攻撃する
--   kind  string  "laser" / "saber"（位置引数可）。省略時は XtfFunnel の saberMode で決める
-- 種別の打ち間違いは、ボス定義の読み込み時（Action の構築時）に assert で止める（戦闘中には落とさない）。
------
local AttackAction = Action.define('XtfFunnelAttack', function(a, d, e)
    if d._xtfFunnels == nil then
        return
    end
    d:xtfFunnelAttack(a.kind or a[1])
end)

XtfFunnel.Attack = setmetatable({ meta = AttackAction.meta, actionName = AttackAction.actionName }, {
    __call = function(_, params)
        local kind = nil
        if params ~= nil then
            kind = params.kind or params[1]
        end
        assert(kind == nil or KINDS[kind],
            'Choreo.XtfFunnelAttack: 種別は "laser" か "saber"（実際: ' .. tostring(kind) .. '）')
        -- __call を持つテーブル（AttackAction）を末尾呼び出し（return X(...)）すると、実機の LuaJIT が
        -- lj_vmeta_callt → lj_BC_TGETS で EXC_BAD_ACCESS になる。いったん受けてから返す
        local action = AttackAction(params)
        return action
    end,
})

_G.package.loaded[_NAME] = XtfFunnel
return XtfFunnel
