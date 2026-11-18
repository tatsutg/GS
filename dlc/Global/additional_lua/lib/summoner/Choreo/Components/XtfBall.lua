------
-- summoner.Choreo.Components.XtfBall
--
-- CODE XTF 系の共有ギミック「ホーミング弾」: spine イベント ball でバリアハンドのボーンから弾を撃ち、
-- update でターゲットの足元へ少しずつ旋回させながら飛ばす。着弾か寿命切れで endAnim になって消える。
-- 出典: unit/500161013.lua（CODE XTF:SEEKER）の ball / ballControll500161013 / onDestroyball。
--   ERASER（unit/500721013.lua）も同一の弾道実装（弾に setDamageRateOffset(0.2) を掛ける点だけ違う）。
--
-- ⚠ update を使うため boss version >= 1.1。
-- ⚠ spine 側の前提: 本体アニメに runScript-ball（spine 500161013 は skill2・zclone<色>skill2 の 36〜40f に5回）、
--    弾側 endAnim の 0f に runScript-onDestroyball（50016ef の ballExplosion。event.unit は弾自身）。
-- ⚠ 当たり判定は弾の anim（50016ef の ball は 12〜105f に DAMAGEAREA）。skill2 本体には当たり判定が無い。
-- ⚠ bone は spine に実在する名前にする。C++ の getBoneWorldPositionX/Y は findBone の結果を
--    NULL チェックしないので、無い名前だと実機でクラッシュする。
-- ⚠ 寿命切れは Lua から endAnim を流す。C++ の playEnd と同じく、終了アニメ名を空にし、
--    Lazer 型・最大ヒット数1にしてから流す（Shot 型のままだと終了アニメがヒットした時点で即 remove される）。
-- ⚠ C++ 側で消滅処理（playEnd: ヒット・親の死亡）に入った弾は、次の update で一覧から外し、以後触らない。
--    playEnd は終了アニメ名を空にしてから終了アニメを流すので、一覧にあるのに終了アニメ名が空なら playEnd 済み。
--    そのため endAnim は空にできない。
-- ⚠ ボスの退場が確定している（getIsDead）間は、発射も update もしない。死亡時はエンジンが全弾に
--    playEnd を掛けるので、endAnim 0f の onDestroyball で一覧から外れる。
-- ⚠ 2回宣言すると assert で止まる。KindSeeker と併用するなら KindSeeker{ ball = {...} } で設定する。
-- ⚠ 設定の型が違う（false に意味の無い設定への false を含む）と、ボス定義の読み込み時に assert で止まる。
-- ⚠ 初期角の乱数は端末ローカル（見た目のみ）。
--
-- 設定（nil は既定値。false は下に書いた設定でだけ使える）:
--   anim       string        弾オービットのアニメ名（既定 "ball"。ループ再生）
--   endAnim    string        着弾 / 寿命切れのアニメ名（既定 "ballExplosion"。空は不可）
--   orbitType  number        addOrbitSystem の type（既定 1）
--   hits       number        最大ヒット数（既定 1）
--   bone       string        発射位置のボーン名（既定 "L_barrier_hand_root"）
--   offsetX    number        発射位置の X オフセット（既定 -50）
--   skill      number|false  弾の ActiveSkill（既定 nil。nil / false は設定しない＝生成時のボスの値を引き継ぐ）
--   damageRate number|false  弾の setDamageRateOffset（既定 nil。nil / false は設定しない。ERASER は 0.2）
--   life       number        寿命（60fps 換算のフレーム数。既定 600）
--   turn       number        旋回上限（度/フレーム。既定 1）
--   speed      number        速度（px/フレーム。既定 2）
--
-- @example
--     boss:add(XtfBall{})
--     boss:add(XtfBall{ skill = 8, damageRate = 0.2 })
------
local _NAME = 'summoner.Choreo.Components.XtfBall'
local _G = _G

local Events = require('summoner.Choreo.Events')

local ONE_FRAME = 0.016666667
local PI = 3.14              -- 度⇔ラジアン換算。出典の弾道と同じ軌跡にするため 3.14 で計算する
local ORBIT_LAZER = 0        -- kOrbitType_Lazer（被弾対象にならず、ヒットしても playEnd されない型）

-- 設定値を読む: nil だけ既定値にし（false を既定値で潰さない）、型が違えばボス定義の読み込み時に止める
local function setting(key, value, default, kind)
    if value == nil then
        return default
    end
    assert(type(value) == kind,
        'Choreo.XtfBall: ' .. key .. ' は ' .. kind .. '（実際: ' .. tostring(value) .. '）')
    return value
end

-- 弾に設定するかどうかを選べる数値: nil / false は設定しない（false を返す）、数値はそのまま
local function optionalNumber(key, value)
    if value == nil or value == false then
        return false
    end
    return setting(key, value, false, 'number')
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

-- ボスが居ない（start 前）か、退場が確定している
local function isGone(unit)
    return unit == nil or unit == false or unit:getIsDead()
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
-- 一覧に残っている弾の終了アニメ名は、Lua 主導で終わらせるまで endAnim のまま
local function endedByEngine(b)
    return b.orbit:getEndAnimationName() == ''
end

-- 一覧から外すだけで弾には触らない（終了アニメは C++ が最後まで流して remove する）
local function drop(list, b)
    b.done = true
    removeEntry(list, b)
end

local function XtfBall(config)
    config = config or {}
    local anim = setting('anim', config.anim, 'ball', 'string')
    local endAnim = setting('endAnim', config.endAnim, 'ballExplosion', 'string')
    assert(endAnim ~= '', 'Choreo.XtfBall: endAnim は空にできない（C++ の消滅処理の検知に使う）')
    local orbitType = setting('orbitType', config.orbitType, 1, 'number')
    local hits = setting('hits', config.hits, 1, 'number')
    local bone = setting('bone', config.bone, 'L_barrier_hand_root', 'string')
    local offsetX = setting('offsetX', config.offsetX, -50, 'number')
    local skill = optionalNumber('skill', config.skill)
    local damageRate = optionalNumber('damageRate', config.damageRate)
    local life = setting('life', config.life, 600, 'number')
    local turn = setting('turn', config.turn, 1, 'number')
    local speed = setting('speed', config.speed, 2, 'number')

    local component = { name = 'XtfBall' }

    local function onLoad(self, event)
        self._xtfBalls = {}
    end

    -- Lua 主導の終了: 先に一覧から外し、C++ の playEnd と同じ状態（終了アニメ名を空・Lazer 型・
    -- 最大ヒット数1）にしてから endAnim を流す。終了名を空にしないと終了アニメが2回流れる
    local function finish(self, b)
        b.done = true
        removeEntry(self._xtfBalls, b)
        local orbit = b.orbit
        orbit:setEndAnimationName('')
        orbit:setOrbitType(ORBIT_LAZER)
        orbit:setHitCountMax(1)
        orbit:takeAnimation(0, endAnim, false)
    end

    local function fire(self, unit)
        if isGone(unit) then
            return
        end
        local orbit = unit:addOrbitSystem(anim, orbitType)
        if orbit == nil then
            return
        end
        orbit:setHitCountMax(hits)
        orbit:setEndAnimationName(endAnim)
        orbit:takeAnimation(0, anim, true)      -- 生成時のアニメは非ループなのでループで掛け直す
        local sk = unit:getSkeleton()
        local x = unit:getPositionX() + sk:getBoneWorldPositionX(bone) + offsetX
        local y = unit:getPositionY() + sk:getBoneWorldPositionY(bone)
        orbit:setPosition(x, y)
        if skill ~= false then
            orbit:setActiveSkill(skill)
        end
        if damageRate ~= false then
            orbit:setDamageRateOffset(damageRate)
        end
        local target = unit:getTargetUnit()
        table.insert(self._xtfBalls, {
            orbit = orbit, x = x, y = y, angle = 0, frame = 0,
            target = target ~= nil and target:getIndex() or nil,
            side = not unit:getisPlayer(),       -- 撃った側から見た相手チーム
        })
    end

    -- 1発の追尾: 初回に向きを [1,360] の整数の乱数で決め（LuaUtilities.rand は [min, max)）、
    -- 寿命までターゲットの足元へ旋回しながら等速で進む
    local function control(self, b, frameRate)
        local f = b.frame
        if f == 0 then
            b.angle = LuaUtilities.rand(1, 361)
        end
        b.frame = f + frameRate
        if f >= life then
            finish(self, b)
            return
        end
        local t = nil
        if b.target ~= nil then
            t = battle():getTeam(b.side):getTeamUnit(b.target)
        end
        if t ~= nil then
            local goal = getDeg(b.x, b.y, t:getPositionX(), t:getPositionY())
            b.angle = turnToward(b.angle, goal, turn * frameRate)
        end
        local rad = toRad(b.angle)
        b.x = b.x + math.cos(rad) * speed * frameRate
        b.y = b.y + math.sin(rad) * speed * frameRate
        b.orbit:setPosition(b.x, b.y)
    end

    local function onRun(self, event)
        local balls = self._xtfBalls
        if balls == nil then
            return
        end
        local ev = event.spineEvent
        if ev == 'ball' then
            fire(self, event.unit)
        elseif ev == 'onDestroyball' then
            -- 着弾・終了アニメの 0f。Lua 主導で終わらせたもの・外したものは一覧に無いので何もしない
            local b = findByOrbit(balls, event.unit)
            if b ~= nil then
                drop(balls, b)
            end
        end
    end

    local function onUpdate(self, event)
        local balls = self._xtfBalls
        if balls == nil or #balls == 0 or isGone(self.unit) then
            return
        end
        local frameRate = (event.deltaTime or 0) / ONE_FRAME
        local list = snapshot(balls)
        for i = 1, #list do
            local b = list[i]
            if not b.done then
                if endedByEngine(b) then
                    drop(balls, b)
                else
                    control(self, b, frameRate)
                end
            end
        end
    end

    function component.initialize(dispatcher)
        local declared = 0
        for _, name in ipairs(dispatcher.components) do
            if name == 'XtfBall' then
                declared = declared + 1
            end
        end
        assert(declared <= 1, 'Choreo: XtfBall が2回宣言されています。'
            .. 'KindSeeker と併用するなら KindSeeker{ ball = {...} } で設定してください')
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnTimeline, onRun)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = XtfBall
return XtfBall
