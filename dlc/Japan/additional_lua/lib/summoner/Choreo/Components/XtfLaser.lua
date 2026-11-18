------
-- summoner.Choreo.Components.XtfLaser
--
-- CODE XTF 系の共有ギミック「照準レーザー」:
--   1. 着弾: spine イベント laserHit2 で、ボスのターゲットの照準点（位置＋MAIN ボーン）に着弾オービットを置く。
--   2. 砲身照準: 照準中は update ごとに砲身ボーンをターゲットの照準点へ向ける（ターゲットが居なければ 0 度）。
--      spine イベント aim（または aim.indices の通常攻撃の成立）で始まり、次の行動（excuteAction）で終わる。
-- 出典: unit/500161013.lua（CODE XTF:SEEKER）の laserHit2 / attack5ArmControll / boneRotation / calcDeg と、
--   isAttack5 の立て下げ（takeAttack index 5 で立て、excuteAction で下ろす）。ERASER（unit/500721013.lua）も同一実装。
--
-- ⚠ update を使うため boss version >= 1.1。
-- ⚠ spine 側の前提: 本体アニメに runScript-laserHit2 と runScript-aim
--    （spine 500161013 は attack5・zclone<色>attack5 の 23f / 15f）。
-- ⚠ 当たり判定は着弾オービット（50016ef の laserHit は 1f〜 に DAMAGEAREA）。attack5 本体には当たり判定が無い。
-- ⚠ ターゲットが居なければ着弾オービットを出さない。
-- ⚠ aim.bones は spine に実在する名前にする。C++ の getBoneWorldPositionX/Y は findBone の結果を
--    NULL チェックしないので、無い名前だと実機でクラッシュする。
-- ⚠ ボスの退場が確定している（getIsDead）間は、着弾も砲身照準もしない。
-- ⚠ 2回宣言すると assert で止まる。KindSeeker と併用するなら KindSeeker{ laser = {...} } で設定する。
--
-- 設定:
--   hitAnim    string       着弾オービットのアニメ名（既定 "laserHit"）
--   orbitType  number       addOrbitSystem の type（既定 0）
--   skill      number|false 着弾オービットの ActiveSkill（既定 nil。nil / false は設定せず生成時のボスの値を引き継ぐ）
--   aim        false|table  砲身照準。false で無効。table は
--                           { bones = { ボーン名, ... }, indices = { 通常攻撃 index, ... } }
--                           bones 既定は砲身6本、indices を書くとその通常攻撃の成立時からも照準する
--                           （既定 nil＝砲身6本・spine の aim で開始。indices なし）
--
-- @example
--     boss:add(XtfLaser{})
--     boss:add(XtfLaser{ skill = 5, aim = { indices = { 5 } } })   -- 通常攻撃5の開始から照準
--     boss:add(XtfLaser{ aim = false })
------
local _NAME = 'summoner.Choreo.Components.XtfLaser'
local _G = _G

local Events = require('summoner.Choreo.Events')

local PI = 3.14              -- 度⇔ラジアン換算。出典の照準と同じ向きにするため 3.14 で計算する

-- 砲身ボーン（綴りは spine 500161013 のまま）
local DEFAULT_BONES = {
    'R_weapon_gunbarrel_upper', 'R_weapon_arm_gunbarre_center', 'R_weapon_gunbarrel_lower',
    'L_weapon_gunbarrel_upper', 'L_weapon_gunbarrel_canter', 'L_weapon_gunbarrel_lower',
}

-- 始点から終点への角度（度）
local function getDeg(sx, sy, tx, ty)
    return math.atan2(ty - sy, tx - sx) * 180 / PI
end

-- ユニットの位置＋MAIN ボーン（照準点）
local function aimPoint(unit)
    local sk = unit:getSkeleton()
    return unit:getPositionX() + sk:getBoneWorldPositionX('MAIN'),
           unit:getPositionY() + sk:getBoneWorldPositionY('MAIN')
end

-- ボスが居ない（start 前）か、退場が確定している
local function isGone(unit)
    return unit == nil or unit == false or unit:getIsDead()
end

local function XtfLaser(config)
    config = config or {}
    local hitAnim = config.hitAnim or 'laserHit'
    local orbitType = config.orbitType or 0
    local skill = config.skill
    assert(skill == nil or skill == false or type(skill) == 'number',
        'Choreo.XtfLaser: skill は数値か false')
    local aim = config.aim
    if aim == nil or aim == true then
        aim = {}
    end
    assert(aim == false or type(aim) == 'table',
        'Choreo.XtfLaser: aim は false か { bones = {...}, indices = {...} }')
    local bones = nil            -- nil＝照準しない
    local indices = {}           -- 通常攻撃 index => true
    if aim ~= false then
        bones = aim.bones or DEFAULT_BONES
        for _, index in ipairs(aim.indices or {}) do
            indices[index] = true
        end
    end

    local component = { name = 'XtfLaser' }

    local function onLoad(self, event)
        self._xtfAiming = false
    end

    local function hit(self, unit)
        if isGone(unit) then
            return
        end
        local t = unit:getTargetUnit()
        if t == nil then
            return
        end
        local orbit = unit:addOrbitSystem(hitAnim, orbitType)
        if orbit == nil then
            return
        end
        orbit:setPosition(aimPoint(t))
        if skill then
            orbit:setActiveSkill(skill)
        end
    end

    local function onRun(self, event)
        local ev = event.spineEvent
        if ev == 'laserHit2' then
            hit(self, event.unit)
        elseif ev == 'aim' and bones ~= nil then
            self._xtfAiming = true
        end
    end

    -- 照準中: 各砲身ボーンの根元からターゲットの照準点への角度をボーン回転に入れる（不在なら 0 度）
    local function onUpdate(self, event)
        if not self._xtfAiming then
            return
        end
        local unit = event.unit or self.unit
        if isGone(unit) then
            return
        end
        local sk = unit:getSkeleton()
        local t = unit:getTargetUnit()
        if t == nil then
            for i = 1, #bones do
                sk:setBoneRotation(bones[i], 0)
            end
            return
        end
        local tx, ty = aimPoint(t)
        local ux, uy = unit:getPositionX(), unit:getPositionY()
        for i = 1, #bones do
            local b = bones[i]
            sk:setBoneRotation(b, getDeg(ux + sk:getBoneWorldPositionX(b), uy + sk:getBoneWorldPositionY(b), tx, ty))
        end
    end

    local function onAttackCommit(self, event)
        if indices[event.index] then
            self._xtfAiming = true
        end
    end

    local function stopAiming(self, event)
        self._xtfAiming = false
    end

    function component.initialize(dispatcher)
        local declared = 0
        for _, name in ipairs(dispatcher.components) do
            if name == 'XtfLaser' then
                declared = declared + 1
            end
        end
        assert(declared <= 1, 'Choreo: XtfLaser が2回宣言されています。'
            .. 'KindSeeker と併用するなら KindSeeker{ laser = {...} } で設定してください')
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnTimeline, onRun)
        if bones ~= nil then
            dispatcher:addEventListener(Events.OnUpdate, onUpdate)
            dispatcher:addEventListener(Events.OnAttackCommit, onAttackCommit)
            dispatcher:addEventListener(Events.excuteAction, stopAiming)
        end
    end

    return component
end

_G.package.loaded[_NAME] = XtfLaser
return XtfLaser
