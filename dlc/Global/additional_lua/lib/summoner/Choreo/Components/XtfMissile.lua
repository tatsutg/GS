------
-- summoner.Choreo.Components.XtfMissile
--
-- CODE XTF 系の共有ギミック「ミサイル」: spine イベント missile で主砲のボーンからミサイルを撃ち上げ、
-- 上空でターゲットの真上へ移ってから急降下させる。着弾・地面到達・寿命切れで endAnim になって爆発する。
--   0〜1f: 角度0・速度1 → 〜30f: 45度で減速 → 〜120f: 45度で加速 →
--   120〜125f: ターゲットの真上（x を合わせる）で下向き（-90度）に停止 → 〜600f: 速度40でターゲットへ旋回しながら落下
--   （フレームは 60fps 換算。ターゲットの y を下回ったら、そのフレームの移動を済ませてから爆発。600f でも爆発）
-- 出典: unit/500161013.lua（CODE XTF:SEEKER）の missile / missileControll500161013 / onDestroyMissile。
--   ERASER（unit/500721013.lua）も同一の弾道実装。
--
-- ⚠ update を使うため boss version >= 1.1。
-- ⚠ spine 側の前提: 本体アニメに runScript-missile（spine 500161013 は attack4・zclone<色>attack4 の 71f）、
--    弾側 endAnim の 0f に runScript-onDestroyMissile（50016ef の missileExplosion。event.unit は弾自身）。
-- ⚠ 当たり判定は弾側（50016ef の missile は 22f〜、missileExplosion は 1〜6f に DAMAGEAREA）。
--    attack4 本体には当たり判定が無い。
-- ⚠ bone は spine に実在する名前にする。C++ の getBoneWorldPositionX/Y は findBone の結果を
--    NULL チェックしないので、無い名前だと実機でクラッシュする。
-- ⚠ ターゲットが居なくなったら、真上へ移る区間でも落下中でもその場で爆発する。
-- ⚠ 爆発は Lua から endAnim を流す。C++ の playEnd と同じく、終了アニメ名を空にし、
--    Lazer 型・最大ヒット数1にしてから流す（Shot 型のままだと爆発がヒットした時点で即 remove される）。
-- ⚠ C++ 側で消滅処理（playEnd: ヒット・親の死亡）に入ったミサイルは、次の update で一覧から外し、以後触らない。
--    playEnd は終了アニメ名を空にしてから終了アニメを流すので、一覧にあるのに終了アニメ名が空なら playEnd 済み。
--    そのため endAnim は空にできない。
-- ⚠ ボスの退場が確定している（getIsDead）間は、発射も update もしない。死亡時はエンジンが全弾に
--    playEnd を掛けるので、endAnim 0f の onDestroyMissile で一覧から外れる。
-- ⚠ 2回宣言すると assert で止まる。KindSeeker と併用するなら KindSeeker{ missile = {...} } で設定する。
-- ⚠ 設定の型が違う（false に意味の無い設定への false を含む）と、ボス定義の読み込み時に assert で止まる。
--
-- 設定（nil は既定値。false は下に書いた設定でだけ使える）:
--   anim       string        ミサイルオービットのアニメ名（既定 "missile"。ループ再生）
--   endAnim    string        爆発アニメ名（既定 "missileExplosion"。空は不可）
--   orbitType  number        addOrbitSystem の type（既定 1）
--   hits       number        最大ヒット数（既定 1）
--   bone       string        発射位置のボーン名（既定 "C_weapon_maingun"）
--   zOffset    number        AutoZOrder 時の ZOrder オフセット（既定 -5030＝背面）
--   skill      number|false  ミサイルの ActiveSkill（既定 nil。nil / false は設定しない＝生成時のボスの値を引き継ぐ）
--
-- @example
--     boss:add(XtfMissile{})
--     boss:add(XtfMissile{ skill = 4 })
------
local _NAME = 'summoner.Choreo.Components.XtfMissile'
local _G = _G

local Events = require('summoner.Choreo.Events')

local ONE_FRAME = 0.016666667
local PI = 3.14              -- 度⇔ラジアン換算。出典の弾道と同じ軌跡にするため 3.14 で計算する
local ORBIT_LAZER = 0        -- kOrbitType_Lazer（被弾対象にならず、ヒットしても playEnd されない型）
local RISE_FRAMES = 30       -- 減速して上がる区間の終わり
local ACCEL_FRAMES = 120     -- 加速して上がる区間の終わり＝真上へ移る区間の始まり
local WARP_END = 125         -- 真上へ移って止まる区間の終わり
local LIFE = 600             -- 寿命
local RISE_ANGLE = 45        -- 上昇の角度
local DIVE_ANGLE = -90       -- 真下
local DIVE_SPEED = 40        -- 落下の速度（px/フレーム）
local DIVE_TURN = 3          -- 落下中の旋回上限（度/フレーム）
local BOOST = 12             -- 上昇区間の速度 = 1 + 割合 × BOOST

-- 設定値を読む: nil だけ既定値にし（false を既定値で潰さない）、型が違えばボス定義の読み込み時に止める
local function setting(key, value, default, kind)
    if value == nil then
        return default
    end
    assert(type(value) == kind,
        'Choreo.XtfMissile: ' .. key .. ' は ' .. kind .. '（実際: ' .. tostring(value) .. '）')
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
-- 一覧に残っているミサイルの終了アニメ名は、Lua 主導で爆発させるまで endAnim のまま
local function endedByEngine(m)
    return m.orbit:getEndAnimationName() == ''
end

-- 一覧から外すだけで弾には触らない（終了アニメは C++ が最後まで流して remove する）
local function drop(list, m)
    m.done = true
    removeEntry(list, m)
end

local function XtfMissile(config)
    config = config or {}
    local anim = setting('anim', config.anim, 'missile', 'string')
    local endAnim = setting('endAnim', config.endAnim, 'missileExplosion', 'string')
    assert(endAnim ~= '', 'Choreo.XtfMissile: endAnim は空にできない（C++ の消滅処理の検知に使う）')
    local orbitType = setting('orbitType', config.orbitType, 1, 'number')
    local hits = setting('hits', config.hits, 1, 'number')
    local bone = setting('bone', config.bone, 'C_weapon_maingun', 'string')
    local zOffset = setting('zOffset', config.zOffset, -5030, 'number')
    local skill = optionalNumber('skill', config.skill)

    local component = { name = 'XtfMissile' }

    local function onLoad(self, event)
        self._xtfMissiles = {}
    end

    -- Lua 主導の爆発: 先に一覧から外し、C++ の playEnd と同じ状態（終了アニメ名を空・Lazer 型・
    -- 最大ヒット数1）にしてから endAnim を流す。終了名を空にしないと爆発アニメが2回流れる
    local function explode(self, m)
        m.done = true
        removeEntry(self._xtfMissiles, m)
        local orbit = m.orbit
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
        orbit:setAutoZOrder(true)
        orbit:setZOderOffset(zOffset)
        local sk = unit:getSkeleton()
        local x = unit:getPositionX() + sk:getBoneWorldPositionX(bone)
        local y = unit:getPositionY() + sk:getBoneWorldPositionY(bone)
        orbit:setPosition(x, y)
        if skill ~= false then
            orbit:setActiveSkill(skill)
        end
        local target = unit:getTargetUnit()
        table.insert(self._xtfMissiles, {
            orbit = orbit, x = x, y = y, angle = 0, frame = 0,
            target = target ~= nil and target:getIndex() or nil,
            side = not unit:getisPlayer(),       -- 撃った側から見た相手チーム
        })
    end

    local function targetOf(m)
        if m.target == nil then
            return nil
        end
        return battle():getTeam(m.side):getTeamUnit(m.target)
    end

    -- 1発の弾道（区間はヘッダの通り。f は進める前のフレーム数）
    local function control(self, m, frameRate)
        local f = m.frame
        m.frame = f + frameRate
        local speed
        local landed = false
        if f <= 1 then
            m.angle = 0
            speed = 1
        elseif f < RISE_FRAMES then
            m.angle = RISE_ANGLE
            speed = 1 + (RISE_FRAMES - f) / RISE_FRAMES * BOOST
        elseif f < ACCEL_FRAMES then
            speed = 1 + (f - RISE_FRAMES) / RISE_FRAMES * BOOST
        elseif f <= WARP_END then
            local t = targetOf(m)
            if t == nil then
                explode(self, m)
                return
            end
            m.x = t:getPositionX()
            m.angle = DIVE_ANGLE
            speed = 0
        elseif f < LIFE then
            local t = targetOf(m)
            if t == nil then
                explode(self, m)
                return
            end
            speed = DIVE_SPEED
            m.angle = turnToward(m.angle, getDeg(m.x, m.y, t:getPositionX(), t:getPositionY()), DIVE_TURN * frameRate)
            landed = m.y < t:getPositionY()
        else
            explode(self, m)
            return
        end
        m.orbit:setRotation(360 - m.angle)
        local rad = toRad(m.angle)
        m.x = m.x + math.cos(rad) * speed * frameRate
        m.y = m.y + math.sin(rad) * speed * frameRate
        m.orbit:setPosition(m.x, m.y)
        if landed then
            explode(self, m)                     -- ターゲットの y を下回った: このフレームの移動の後で爆発
        end
    end

    local function onRun(self, event)
        local missiles = self._xtfMissiles
        if missiles == nil then
            return
        end
        local ev = event.spineEvent
        if ev == 'missile' then
            fire(self, event.unit)
        elseif ev == 'onDestroyMissile' then
            -- 着弾・爆発アニメの 0f。Lua 主導で爆発させたもの・外したものは一覧に無いので何もしない
            local m = findByOrbit(missiles, event.unit)
            if m ~= nil then
                drop(missiles, m)
            end
        end
    end

    local function onUpdate(self, event)
        local missiles = self._xtfMissiles
        if missiles == nil or #missiles == 0 or isGone(self.unit) then
            return
        end
        local frameRate = (event.deltaTime or 0) / ONE_FRAME
        local list = snapshot(missiles)
        for i = 1, #list do
            local m = list[i]
            if not m.done then
                if endedByEngine(m) then
                    drop(missiles, m)
                else
                    control(self, m, frameRate)
                end
            end
        end
    end

    function component.initialize(dispatcher)
        local declared = 0
        for _, name in ipairs(dispatcher.components) do
            if name == 'XtfMissile' then
                declared = declared + 1
            end
        end
        assert(declared <= 1, 'Choreo: XtfMissile が2回宣言されています。'
            .. 'KindSeeker と併用するなら KindSeeker{ missile = {...} } で設定してください')
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnTimeline, onRun)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = XtfMissile
return XtfMissile
