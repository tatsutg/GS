------
-- summoner.Choreo.Components.Orbs
--
-- 玉精種（氷玉精スティーリア等）の「3つの玉」を常駐オービットで表示し、点灯数で効果を切り替える Component。
-- 点灯数が n へ上がると levels[n].onEnter、n 未満へ下がると levels[n].onExit を実行する（効果は累積）。
--
-- 出典: unit/501291213.lua・enemy/mine_6020.lua のクリスタル
--       （エフェクト spine の crystal_idle_off を常駐させ、点灯は crystal_activate → crystal_idle_on。
--        ボスの skill2 の spine イベント skill2Start で crystal_out → crystal_hide、skill2Compleat で crystal_in。
--        遷移アニメの終わりは玉側の spine イベント crystalActionEnd で受け、次のアニメへ進める）。
--       玉は addOrbitSystem のオービット（ボスと同じ親レイヤーに置かれ、setPosition はそのレイヤー上の座標）。
--       玉側の runScript も uniqueID がボスと同じなのでボスの run に届き、event.unit がその玉になる。
--
-- 点灯・消灯:
--   - hpStep: ボスの HP が最大HPの hpStep% 減るごとに1つ点灯。HP の減少量で数える
--             （毒・燃焼などの DoT や固定ダメージも含む。回復しても戻さない）
--   - burst:  直近 burst.seconds 秒の HP 減少量が最大HPの burst.percent% 以上なら全点灯
--   - LightOrbs / UnlightOrbs Action（例: OnStatus{ types = { 90 }, actions = { UnlightOrbs{ 1 } } }
--     で「毒になるたびに1つ消灯」）
--   全点灯の間は減少量を貯めない（消灯したら次の hpStep% から数え直す）。
--
-- 同期: 点灯数はホストが決めて全端末へ配信する（Sync チャンネル 'orbs'）。HP はホスト権威なので
--   HP の監視はホストだけが行い、LightOrbs / UnlightOrbs もゲストでは何もしない（配信を待つ）。
--   onEnter / onExit は配信を受けた全端末で実行する。玉の見た目は各端末が同じ点灯数から決める。
--
-- ⚠ update を使うため boss version >= 1.1。
-- ⚠ エフェクト spine に crystal_idle_off / crystal_idle_on / crystal_activate / crystal_out / crystal_hide /
--    crystal_in と、遷移アニメ末尾の runScript-crystalActionEnd が要る（50158ef・50129ef にある。50132ef は crystal_hide が無い）。
-- ⚠ skill2Start で退場した玉は skill2Compleat で戻す。ブレイク等で奥義が途切れて skill2Compleat が来なかったときは、
--    奥義状態を抜けた最初の update で戻す。
--
-- 設定:
--   count      number  玉の数（既定 3）
--   positions  table   玉の座標 { {x, y}, ... }（既定 { {-300, 500}, {300, 500}, {0, 530} }＝mine_6020）
--   zOrder     number  玉の描画順（既定 8999）
--   initial    number  開幕の点灯数（既定 0。1 以上なら開幕に levels[1..initial].onEnter を実行）
--   levels     table   [n] = { onEnter = Action列, onExit = Action列 }
--   hpStep     number  HP がこの%減るごとに1つ点灯（省略で無効）
--   burst      table   { percent = 15, seconds = 10 }（省略で無効）
--   outEvent   string  玉を退場させるボスの spine イベント（既定 'skill2Start'。false で無効）
--   inEvent    string  玉を戻すボスの spine イベント（既定 'skill2Compleat'。false で無効）
--
-- @example
--     boss:add(Orbs{ hpStep = 5, burst = { percent = 15, seconds = 10 },
--         levels = {
--             [1] = { onEnter = { SetAttackDelay{ 4 } }, onExit = { SetAttackDelay{ 8 } } },
--         } })
--     boss:add(OnStatus{ key = 'poison', types = { 90 }, actions = { UnlightOrbs{ 1 } } })
------
local _NAME = 'summoner.Choreo.Components.Orbs'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')
local Sync = require('summoner.Choreo.Components.Sync')

local ANIM_OFF = 'crystal_idle_off'
local ANIM_ON = 'crystal_idle_on'
local ANIM_ACTIVATE = 'crystal_activate'
local ANIM_OUT = 'crystal_out'
local ANIM_HIDE = 'crystal_hide'
local ANIM_IN = 'crystal_in'
local END_EVENT = 'crystalActionEnd'

local DEFAULT_POSITIONS = { { -300, 500 }, { 300, 500 }, { 0, 530 } }

local makeOrbs   -- 前方宣言

local Orbs = setmetatable({}, {
    __call = function(_, config) return makeOrbs(config) end
})

-- 奥義中判定（Phases / ExtraTimer と同じ形）
local function isSmashing(unit)
    return unit ~= nil and unit.getUnitState ~= nil and kUnitState_skill ~= nil
       and unit:getUnitState() == kUnitState_skill
end

local function play(orb, anim)
    if orb.orbit ~= nil and orb.orbit ~= false then
        orb.orbit:takeAnimation(0, anim, true)
    end
end

function makeOrbs(config)
    config = config or {}
    local count = config.count or 3
    local positions = config.positions or DEFAULT_POSITIONS
    local zOrder = config.zOrder or 8999
    local initial = config.initial or 0
    local levels = config.levels or {}
    local hpStep = config.hpStep
    local burst = config.burst
    local outEvent = config.outEvent
    if outEvent == nil then
        outEvent = 'skill2Start'
    end
    local inEvent = config.inEvent
    if inEvent == nil then
        inEvent = 'skill2Compleat'
    end

    local component = { name = 'Orbs' }

    -- 各玉の見た目を点灯数に合わせる。退場〜復帰の途中の玉は触らず、復帰の終わりで合わせる。
    --   phase: idle（待機ループ中。on=点灯側か）/ activating（点灯アニメ中）/ out / hidden / back（復帰アニメ中）
    local function refresh(self)
        local orbs = self._orbs or {}
        for i = 1, #orbs do
            local orb = orbs[i]
            local lit = i <= self._orbLit
            if orb.phase == 'idle' then
                if lit and not orb.on then
                    play(orb, ANIM_ACTIVATE)
                    orb.phase = 'activating'
                elseif not lit and orb.on then
                    play(orb, ANIM_OFF)
                    orb.on = false
                end
            elseif orb.phase == 'activating' and not lit then
                play(orb, ANIM_OFF)
                orb.phase = 'idle'
                orb.on = false
            end
        end
    end

    -- 玉側の遷移アニメが終わった（crystalActionEnd）
    local function onOrbEnd(self, orb, index)
        if orb.phase == 'activating' or orb.phase == 'back' then
            local lit = index <= self._orbLit
            play(orb, lit and ANIM_ON or ANIM_OFF)
            orb.on = lit
            orb.phase = 'idle'
        elseif orb.phase == 'out' then
            play(orb, ANIM_HIDE)
            orb.phase = 'hidden'
        end
    end

    local function sendOut(self)
        local orbs = self._orbs or {}
        for i = 1, #orbs do
            play(orbs[i], ANIM_OUT)
            orbs[i].phase = 'out'
        end
        self._orbsAway = true
    end

    local function bringBack(self)
        local orbs = self._orbs or {}
        for i = 1, #orbs do
            local orb = orbs[i]
            if orb.phase == 'out' or orb.phase == 'hidden' then
                play(orb, ANIM_IN)
                orb.phase = 'back'
            end
        end
        self._orbsAway = false
    end

    -- 点灯数を n にする（ホスト即時 / ゲスト受信時の両方で呼ばれる）。
    -- 上がった段の onEnter を下から、下がった段の onExit を上から実行する。
    local function setLit(self, n)
        if n < 0 then
            n = 0
        elseif n > count then
            n = count
        end
        local old = self._orbLit
        if n == old then
            return
        end
        self._orbLit = n
        local event = { unit = self.unit, name = 'OnOrbs', orbs = n, previous = old }
        if n > old then
            for k = old + 1, n do
                local lv = levels[k]
                if lv ~= nil and lv.onEnter ~= nil then
                    Action.runActions(self, event, lv.onEnter)
                end
            end
        else
            for k = old, n + 1, -1 do
                local lv = levels[k]
                if lv ~= nil and lv.onExit ~= nil then
                    Action.runActions(self, event, lv.onExit)
                end
            end
        end
        if n >= count then
            self._orbAccHP = 0
            self._orbWindow = {}
        end
        refresh(self)
    end

    -- ホストが点灯数を決めて配信する（ゲストは何もしない）
    local function request(self, n)
        if not self.isHostPlayer then
            return
        end
        if n < 0 then
            n = 0
        elseif n > count then
            n = count
        end
        if n ~= self._orbLit then
            self:hostDecide('orbs', n)
        end
    end

    -- start: per-instance 状態の初期化と玉の生成（規約 §6-3）
    local function onLoad(self, event)
        self._orbLit = 0
        self._orbAccHP = 0
        self._orbWindow = {}
        self._orbClock = 0
        self._orbPrevHP = nil
        self._orbsAway = false
        self._orbs = {}
        local unit = event.unit
        for i = 1, count do
            local pos = positions[i] or positions[#positions] or { 0, 0 }
            local orbit = unit:addOrbitSystem(ANIM_OFF)
            if orbit ~= nil and orbit ~= false then
                -- 生成時の再生は非ループで、終わると消える。ループ指定で再生し直して常駐させる（出典の慣用）。
                orbit:takeAnimation(0, ANIM_OFF, true)
                orbit:setPosition(pos[1] or 0, pos[2] or 0)
                orbit:setZOrder(zOrder)
            end
            self._orbs[i] = { orbit = orbit, phase = 'idle', on = false }
        end
        if initial > 0 then
            setLit(self, initial)   -- 全端末で同じ初期値（配信不要）
        end
    end

    local function onUpdate(self, event)
        local unit = event.unit
        if self._orbsAway and not isSmashing(unit) then
            bringBack(self)
        end
        if not self.isHostPlayer or (hpStep == nil and burst == nil) then
            return
        end
        self._orbClock = self._orbClock + (event.deltaTime or 0)
        local hp = unit:getHP()
        local prev = self._orbPrevHP
        self._orbPrevHP = hp
        if prev == nil or hp >= prev or self._orbLit >= count then
            return
        end
        local maxHP = unit:getCalcHPMAX()
        if maxHP == nil or maxHP <= 0 then
            return
        end
        local lost = prev - hp
        local n = self._orbLit
        if hpStep ~= nil and hpStep > 0 then
            -- 端数の誤差を避けるため HP の実数で貯め、最大HP×% と比べる
            self._orbAccHP = self._orbAccHP + lost
            local stepHP = maxHP * hpStep / 100
            while n < count and self._orbAccHP >= stepHP do
                self._orbAccHP = self._orbAccHP - stepHP
                n = n + 1
            end
        end
        if burst ~= nil and burst.percent ~= nil then
            local from = self._orbClock - (burst.seconds or 0)
            local kept = {}
            local sum = 0
            local window = self._orbWindow
            window[#window + 1] = { t = self._orbClock, hp = lost }
            for i = 1, #window do
                if window[i].t >= from then
                    kept[#kept + 1] = window[i]
                    sum = sum + window[i].hp
                end
            end
            self._orbWindow = kept
            if sum * 100 >= maxHP * burst.percent then
                n = count
            end
        end
        request(self, n)
    end

    local function onRun(self, event)
        local name = event.spineEvent
        if name == END_EVENT then
            local orbs = self._orbs or {}
            for i = 1, #orbs do
                if orbs[i].orbit == event.unit then
                    onOrbEnd(self, orbs[i], i)
                    return
                end
            end
        elseif outEvent and name == outEvent then
            sendOut(self)
        elseif inEvent and name == inEvent then
            bringBack(self)
        end
    end

    -- LightOrbs / UnlightOrbs から呼ぶ（dispatcher のメソッドとして合流する）
    component.requestOrbs = function(self, n)
        request(self, n)
    end

    function component.initialize(dispatcher)
        if not dispatcher:hasComponent('Sync') then
            dispatcher:add(Sync.create())
        end
        dispatcher:openChannel('orbs', function(self, n) setLit(self, n) end)
        for k = 1, count do
            local lv = levels[k]
            if lv ~= nil then
                Action.preregisterChances(dispatcher, lv.onEnter)
                Action.preregisterChances(dispatcher, lv.onExit)
            end
        end
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
        dispatcher:addEventListener(Events.OnTimeline, onRun)   -- OnTimeline == 'run'
    end

    return component
end

------
-- LightOrbs Action: 玉を点灯させる（ホストが決めて配信。ゲストでは何もしない）
--   count  number  点灯させる数（位置引数可。既定 1）
--   all    bool    true で全点灯
------
Orbs.Light = Action.define('LightOrbs', function(a, d, e)
    if d.requestOrbs == nil or d._orbLit == nil then
        return
    end
    if a.all then
        d:requestOrbs(math.huge)
    else
        d:requestOrbs(d._orbLit + (a.count or a[1] or 1))
    end
end)

------
-- UnlightOrbs Action: 玉を消灯させる（ホストが決めて配信。ゲストでは何もしない）
--   count  number  消灯させる数（位置引数可。既定 1）
--   all    bool    true で全消灯
------
Orbs.Unlight = Action.define('UnlightOrbs', function(a, d, e)
    if d.requestOrbs == nil or d._orbLit == nil then
        return
    end
    if a.all then
        d:requestOrbs(0)
    else
        d:requestOrbs(d._orbLit - (a.count or a[1] or 1))
    end
end)

_G.package.loaded[_NAME] = Orbs
return Orbs
