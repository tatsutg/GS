------
-- summoner.Choreo.Components.OrdeusSkull
--
-- オルデウス種の共有ギミック「壊魂振動」: spine イベント skull でホーミング弾（骸骨弾）を
-- 生成し、update で自前追尾させ、弾の explosion アニメの spine イベント onDestroy で後始末する。
-- 出典: enemy/4002402.lua（超新星級オルデウス・絶）の skull/onDestroy/bulletControll 一式。
--
-- ⚠ update を使うため boss version >= 1.1。
-- ⚠ spine 側の前提: ボスの奥義アニメに runScript-skull、弾側 explosion に runScript-onDestroy
--    （オルデウス spine 500061513/50006ef で確認済み。skill2 は skull を4回発火する）。
-- ⚠ 生成座標・旋回角の乱数は端末ローカル（原作準拠。弾の見た目はローカル演出）。
--
-- 設定:
--   count     number  skull イベント1回で出す弾数（既定 2 = 原作値）
--   anim      string  弾オービットのアニメ名（既定 "skullBase"）
--   endAnim   string  ヒット/寿命時のアニメ名（既定 "explosion"）
--   orbitType number  addOrbitSystem の type（既定 2 = 原作値）
--   orbitHP   number  弾の HP（既定 1000000 = 原作値。攻撃して破壊できる弾。0 で HP なし）
--   offsetY   number  生成位置の Y オフセット（既定 350）
--   amplitude number  生成位置の乱数ばらけ幅（既定 100）
--   skill     number  弾に紐付ける ActiveSkill 番号（省略可。原作は未設定）
--   onFire    Action|list  skull イベント時の追加アクション（割合ダメ等。エスケープ可）
--
-- @example
--     boss:add(OrdeusSkull{ count = 2, orbitHP = 1000000 })
------
local _NAME = 'summoner.Choreo.Components.OrdeusSkull'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local ONE_FRAME = 0.016666667

------
-- 弾1発の追尾制御（原作 bulletControll の移植）
-- frame < 30: 加速 / frame < 600: 角度制限つきでターゲットへ旋回 / それ以降: endAnim で爆発
------
local function controlBullet(b, deltaTime, endAnim)
    local framecnt = b.frame
    local frameRate = deltaTime / ONE_FRAME
    local sp = 1
    if framecnt == 0 then
        b.angle = LuaUtilities.rand(0, 360)
        b.posx = b.bullet:getPositionX()
        b.posy = b.bullet:getPositionY()
    end
    b.frame = b.frame + 1 * frameRate

    if framecnt <= 1 then
        sp = 1
    elseif framecnt < 30 then
        sp = 1 + math.abs(30 - framecnt) / 30 * 3
    elseif framecnt < 600 then
        sp = 2
        local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(b.targetIndex)
        if target ~= nil then
            local targetangle = math.atan2(
                target:getPositionY() - b.bullet:getPositionY(),
                target:getPositionX() - b.bullet:getPositionX()) * 180 / 3.14
            if targetangle < 0 then
                targetangle = 360 + targetangle
            end
            local dir = targetangle - b.angle
            if dir > 180 then
                dir = -(360 - dir)
            end
            if dir < -180 then
                dir = (360 - dir)
            end
            if dir ~= 0 then
                local maxdir = 1 * frameRate
                if dir > maxdir then
                    dir = maxdir
                elseif dir < -maxdir then
                    dir = -maxdir
                end
                b.angle = b.angle + dir
            end
        end
    else
        b.bullet:takeAnimation(0, endAnim, false)   -- 追尾時間切れ → 爆発
    end

    local rad = b.angle * 3.14 / 180
    b.posx = b.posx + math.cos(rad) * sp * frameRate
    b.posy = b.posy + math.sin(rad) * sp * frameRate
    b.bullet:setPosition(b.posx, b.posy)
end

local function OrdeusSkull(config)
    config = config or {}
    local count = config.count or 2
    local anim = config.anim or 'skullBase'
    local endAnim = config.endAnim or 'explosion'
    local orbitType = config.orbitType or 2
    local orbitHP = config.orbitHP or 1000000
    local offsetY = config.offsetY or 350
    local amplitude = config.amplitude or 100

    local component = { name = 'OrdeusSkull' }

    local function onLoad(self, event)
        self._ordeusBullets = {}
    end

    local function fire(self, event)
        for i = 1, count do
            local s = event.unit:addOrbitSystem(anim, orbitType)
            s:setHitCountMax(1)
            s:setEndAnimationName(endAnim)
            if config.skill ~= nil then
                s:setActiveSkill(config.skill)
            end
            local rx = LuaUtilities.rand(0, amplitude) - amplitude / 2
            local ry = LuaUtilities.rand(0, amplitude) - amplitude / 2
            s:setPosition(event.unit:getPositionX() + rx, event.unit:getPositionY() + offsetY + ry)
            s:setOpacity(0)
            s:runAction(cc.FadeIn:create(1))
            if orbitHP > 0 then
                s:setBaseHP(orbitHP)
                s:setHP(orbitHP)
            end
            local target = event.unit:getTargetUnit()
            table.insert(self._ordeusBullets, {
                bullet = s,
                targetIndex = target ~= nil and target:getIndex() or 0,
                frame = 0, angle = 0, posx = 0, posy = 0,
            })
        end
        Action.runActions(self, event, config.onFire)
    end

    -- 爆発した弾を配列から除去（event.unit = 弾オービット。一致した時だけ除去）
    local function destroy(self, event)
        local bullets = self._ordeusBullets
        for i = 1, table.maxn(bullets) do
            if bullets[i] ~= nil and bullets[i].bullet == event.unit then
                bullets[i].bullet:setEndAnimationName("")
                table.remove(bullets, i)
                break
            end
        end
    end

    local function onRun(self, event)
        if event.spineEvent == 'skull' then
            fire(self, event)
        elseif event.spineEvent == 'onDestroy' then
            destroy(self, event)
        end
    end

    local function onUpdate(self, event)
        local bullets = self._ordeusBullets
        if bullets == nil then
            return
        end
        for i = 1, table.maxn(bullets) do
            if bullets[i] ~= nil then
                controlBullet(bullets[i], event.deltaTime, endAnim)
            end
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnTimeline, onRun)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = OrdeusSkull
return OrdeusSkull
