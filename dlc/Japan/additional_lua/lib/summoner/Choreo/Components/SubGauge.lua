------
-- summoner.Choreo.Components.SubGauge
--
-- サブゲージ／エクストラゲージ（[12] ギャップ #6）。本体HPと別の独立ゲージを
-- 蓄積ダメージで破壊する。ゲージ表示中は本体HPを守り(value=1)、破壊時に効果を発動。
-- 出典: 実ボス(2004556 等) の BattleControl:createSubBar + ダメージ蓄積 + 破壊判定。
--
-- ⚠ takeDamageValue / update を使うため boss version >= 1.1。
--
-- 構成:
--   SubGauge{...}                  … 1本のゲージ（key で識別）。複数 add で複数ゲージ。
--   Action: ShowSubGauge/HideSubGauge/ResetSubGauge … 出現/消滅/リセット（トリガーから）
--
-- @example
--     boss:add(SubGauge{
--         key = "rage", hpRate = 0.18, color = {220,20,60},
--         only = "critical",                       -- クリティカルダメージのみで削れる
--         onBreak = { Say{"怒り解除"}, AttachBuff{...} },   -- 破壊時(怒り解除+気絶 等)
--     })
--     -- スキル3使用で出現:
--     boss:add(Smash{ ..., onUse = { [3] = { ShowSubGauge{ "rage" } } } })
--
-- 設定:
--   key       string  ゲージ識別子（Show/Hide/Reset と対応。既定 "sub"）
--   hpRate    number  最大値 = getCalcHPMAX * hpRate（既定0.2）
--   max       number  固定の最大値（hpRate の代わり）
--   width/height number  バーのサイズ（既定 200/13）
--   color     {r,g,b}  バー色（任意。指定時のみ白テクスチャ＋着色。未指定=ゲーム標準の見た目）
--   texture/plist string  バーテクスチャの明示上書き（任意。通常は不要）
--   offsetY   number  ボスからのバー縦オフセット（既定25）
--   only      string  削れるダメージ: "critical"/"noncritical"/"magic"/"physical"/"all"（既定all）
--   rates     table   **攻撃者条件つきの蓄積倍率**ルール列。`only` を通ったヒットに掛ける倍率を
--                     「誰の攻撃か」で変える（上から評価し、最初に一致した1つを採用。未一致は等倍）。
--                     ルール: { mult = 倍率, <条件>, negate = bool }
--                       mult       number|function(self,event)  ゲージへの蓄積倍率
--                       条件（when > attackerLeader > attackerBaseID の順に **1つだけ** 評価。
--                             条件なし＝常時一致）:
--                         when           function(self,event)->bool  任意条件（エスケープ）
--                         attackerLeader bool     攻撃側がリーダーか（true=リーダー / false=リーダー以外）
--                         attackerBaseID number|table  攻撃側の getBaseID3（リストはいずれか一致）
--                       negate     bool     条件成立を反転（「◯◯以外」）
--                     ⚠ `only` は「乗るか」、`rates` は「いくら乗るか」で役割が別（併用可）。
--                     ⚠ 倍率はゲージへの蓄積だけに掛かる。**本体HPへのダメージは変えない**
--                        （本体側は `protect` が決める）。
--   protect   bool|number  ゲージ中の本体ダメージ: true=1固定（既定）/ 数値=倍率（例 0.01）/ false=守らない
--   active    bool    start から有効（既定false → ShowSubGauge で起動）
--   onBreak   Action|list  破壊時のアクション
--   pos       {x,y}   バーの画面固定座標（未指定＝ボス追従。出典 200360080 は固定座標 -300,250）
--   mirror    table   { conditionType = N } … **表示専用モード**。自前で蓄積せず、その condition の
--                     残量（findConditionValue）をバーへ映す。実効はエンジンが持つ。
--   interval  number  mirror の更新間隔秒（既定 0.2。出典 200360080 の barrierUpdateTimer）
--
-- ⚠ mirror 指定時は takeDamageValue に一切干渉しない（`protect` も `rates` も効かない）。ダメージ軽減/吸収は
--    engine 側の condition（例: BARRIER type 98）が行い、こちらは残量バーを描くだけ。
--    max 未指定なら「観測したピーク値」を最大値とする（明示 max のほうが確実）。
--
-- @example 無効化バリア（type 98）の残量をエクストラゲージとして描く。
--          ⚠ engine の BarrierGauge はプレイヤー側 BattleStatus にしか出ないためボスでは自前描画が要る。
--     boss:add(SubGauge{ key = "barrier", mirror = { conditionType = 98 }, max = 1000000,
--                        onBreak = { HideSubGauge{"barrier"}, RemoveExtraTimer{ key = "B" } } })
--     boss:add(Smash{ onUse = { [4] = {
--         AttachBuff{ id = ..., type = 98, value = 1000000, time = 20, icon = 24 },
--         ShowSubGauge{ "barrier" },
--     } } })
--
-- @example 決闘法廷（エチカ真EX）: ボス最大HPの50%のエクストラゲージ。本体HPは通常どおり削れ、
--          **リーダーユニットからのダメージだけ3倍**でゲージに乗る。
--     boss:add(SubGauge{
--         key = "court", hpRate = 0.5, color = {255,255,0},
--         protect = false,                             -- ゲージ表示中も本体HPは通常どおり削れる
--         rates = { { mult = 3, attackerLeader = true } },
--         onBreak = { AttachBuff{ target = Targeting{pick="self"}, type = 89, time = 1 },
--                     GainSP{ value = 300, target = Targeting{side="player", pick="leader"} } },
--     })
------
local _NAME = 'summoner.Choreo.Components.SubGauge'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

-- このヒットがゲージに乗るか（only フィルタ: getDamageAffectInfo() の critical / skillAttribute）
local function hitCounts(event, only)
    if only == nil or only == 'all' then return true end
    local enemy = event.enemy
    if enemy == nil then return only == 'noncritical' end   -- 攻撃元情報なし＝判定不能は数えない（旧挙動と同値）
    local info = enemy:getTeamUnitCondition():getDamageAffectInfo()
    if only == 'critical' then return info.critical and true or false end
    if only == 'noncritical' then return not info.critical end
    if only == 'magic' then return info.skillAttribute == 2 end      -- attribute: 物理1/魔法2
    if only == 'physical' then return info.skillAttribute == 1 end
    return true
end

-- 攻撃側ユニット（オービット弾なら祖先ユニットまで遡る）。
-- ⚠ これをやらないと「オービット経由で攻撃したリーダー」の分に倍率が乗らない。
--    Defense.attackerUnit / HateTarget.attackerIndex と同形（出典 2004556 の getAncestorUnit）。
local function attackerUnit(event)
    local a = event.enemy
    if a == nil then return nil end
    while a:getParentTeamUnit() ~= nil do
        a = a:getParentTeamUnit()
    end
    return a
end

-- rates の1ルールが成立するか。
-- 条件は Defense と同じ規約で **1つだけ** 評価する（when > attackerLeader > attackerBaseID）。
-- 条件無指定＝常時一致（＝既定倍率の上書き）。negate で反転。
local function rateMatches(self, event, rule)
    local matched
    if rule.when ~= nil then
        matched = rule.when(self, event) and true or false
    elseif rule.attackerLeader ~= nil then
        local a = attackerUnit(event)
        local isLeader = (a ~= nil and a:getIsLeader()) and true or false
        -- attackerLeader は「期待する真偽」を書く（false = リーダー以外）。
        matched = (isLeader == (rule.attackerLeader and true or false))
    elseif rule.attackerBaseID ~= nil then
        local a = attackerUnit(event)
        if a == nil then
            matched = false
        else
            local ids = rule.attackerBaseID
            if type(ids) == 'number' then ids = { ids } end
            local baseID = a:getBaseID3()
            matched = false
            for i = 1, #ids do
                if baseID == ids[i] then
                    matched = true
                    break
                end
            end
        end
    else
        matched = true
    end
    if rule.negate then
        return not matched
    end
    return matched
end

-- ゲージへの蓄積倍率（最初に一致したルールの mult。rates 無し/未一致は等倍）。
-- ⚠ protect が event.value を書き換える**前**に評価すること（onDamage の順序に依存）。
local function gaugeRate(self, event, rates)
    if rates == nil then return 1 end
    for i = 1, #rates do
        local rule = rates[i]
        if rateMatches(self, event, rule) then
            local m = rule.mult
            if type(m) == 'function' then m = m(self, event) end
            return m or 1
        end
    end
    return 1
end

local function get(self, key)
    return self._subGauges ~= nil and self._subGauges[key] or nil
end

local makeSubGauge

local SubGauge = setmetatable({}, {
    __call = function(_, config) return makeSubGauge(config) end
})

-- バーの配置（pos 指定＝画面固定 / 未指定＝ボス追従）
local function placeBar(config, bar, unit)
    if config.pos ~= nil then
        bar:setPositionX(config.pos[1] or config.pos.x or 0)
        bar:setPositionY(config.pos[2] or config.pos.y or 0)
    else
        bar:setPositionX(unit:getPositionX())
        bar:setPositionY(unit:getPositionY() + (config.offsetY or 25))
    end
end

function makeSubGauge(config)
    local key = config.key or 'sub'
    local mirror = config.mirror
    local component = { name = 'SubGauge:' .. key }

    local function onLoad(self, event)
        self._subGauges = self._subGauges or {}
        local bar = BattleControl:get():createSubBar()
        bar:setWidth(config.width or 200)
        bar:setHeight(config.height or 13)
        bar:setPercent(0)
        bar:setVisible(false)
        -- 色未指定 = createSubBar 素の見た目（ゲーム標準のデフォルト）。
        -- color 指定時のみ、着色用の白テクスチャ（実ボス慣用 2004556）をロードして色を乗せる。
        -- texture/plist の明示指定があればそれを優先。
        if config.texture ~= nil then
            if config.plist ~= nil then
                bar:loadBarTexture(config.texture, config.plist)
            else
                bar:loadBarTexture(config.texture)
            end
        elseif config.color ~= nil then
            bar:loadBarTexture('battle_barrier_gauge_white.png', 'CocoStudio/Battle/resource/Battle_UI.plist')
        end
        if config.color ~= nil then
            bar:setBarColor(config.color[1], config.color[2], config.color[3])
        end
        -- mirror は「observed ピーク or 明示 max」を基準にする（hpRate 既定は使わない）
        local max
        if mirror ~= nil then
            max = config.max
        else
            max = config.max or (event.unit:getCalcHPMAX() * (config.hpRate or 0.2))
        end
        self._subGauges[key] = {
            bar = bar, max = max, damage = 0, timer = 0, seen = false, config = config,
            active = config.active and true or false, broken = false,
        }
    end

    local function onDamage(self, event)
        if mirror ~= nil then
            return                             -- 表示専用モード: ダメージには一切干渉しない
        end
        local g = get(self, key)
        if g == nil or not g.active or g.broken then return end
        if hitCounts(event, config.only) then
            -- ⚠ 倍率はここ（protect が event.value を書き換える前）で掛ける。
            --    ゲージへの蓄積だけに効き、本体HPへのダメージは変えない。
            g.damage = g.damage + event.value * gaugeRate(self, event, config.rates)
        end
        if type(config.protect) == 'number' then
            event.value = event.value * config.protect   -- 倍率指定（例 0.01 = 本体ダメージ×0.01）
        elseif config.protect ~= false then
            event.value = 1                    -- 既定: ゲージ中は本体HPを value=1 で守る
        end
    end

    -- condition の残量をバーへ映す（実効は engine 側。ここは描画だけ）。
    -- 更新間隔は既定 0.2 秒（出典 200360080: barrierUpdateTimer > 0.2 で subBar:setPercent）。
    -- 端末ローカルの表示なのでマルチで多少ズレても表示のみに留まる（ゲームプレイに影響しない）。
    local function mirrorUpdate(self, event, g, unit)
        g.timer = (g.timer or 0) + (event.deltaTime or 0)
        if g.timer < (config.interval or 0.2) then return end
        g.timer = 0
        local value = unit:getTeamUnitCondition():findConditionValue(mirror.conditionType) or 0
        if value > 0 then
            g.seen = true
            if g.max == nil or value > g.max then g.max = value end
        end
        local bar = g.bar
        placeBar(config, bar, unit)
        bar:setVisible(true)
        if g.max ~= nil and g.max > 0 then
            bar:setPercent(100 * value / g.max)
        else
            bar:setPercent(0)
        end
        -- 一度でも残量があった後に 0 になった＝削り切られた（時間切れでの消滅も同じ経路を通る）
        if g.seen and value <= 0 then
            g.broken = true
            g.active = false
            bar:setVisible(false)
            if config.onBreak ~= nil then
                Action.runActions(self, event, config.onBreak)
            end
        end
    end

    local function onUpdate(self, event)
        local g = get(self, key)
        if g == nil or not g.active or g.broken then return end
        local unit = event.unit or self.unit
        if unit == nil or unit == false then return end
        if mirror ~= nil then
            return mirrorUpdate(self, event, g, unit)
        end
        local bar = g.bar
        placeBar(config, bar, unit)
        bar:setVisible(true)
        bar:setPercent(100 * (g.max - g.damage) / g.max)
        if g.damage >= g.max then
            g.broken = true
            g.active = false
            bar:setVisible(false)
            if config.onBreak ~= nil then
                Action.runActions(self, event, config.onBreak)
            end
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
        dispatcher:addEventListener(Events.takeDamageValue, onDamage)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

------
-- Action: ゲージ出現 / 消滅 / リセット（key 指定）
------
SubGauge.Show = Action.define('ShowSubGauge', function(a, d, e)
    local g = get(d, a.key or a[1])
    if g ~= nil then
        g.active = true
        g.broken = false
        g.damage = 0
        g.timer = 0
        if g.config ~= nil and g.config.mirror ~= nil then
            g.seen = false              -- 再表示ごとに「残量を見た」状態を戻す（即 onBreak を防ぐ）
            g.max = g.config.max        -- max 未指定なら次の観測ピークで埋め直す
        end
    end
end)

SubGauge.Hide = Action.define('HideSubGauge', function(a, d, e)
    local g = get(d, a.key or a[1])
    if g ~= nil then
        g.active = false
        if g.bar ~= nil then g.bar:setVisible(false) end
    end
end)

SubGauge.Reset = Action.define('ResetSubGauge', function(a, d, e)
    local g = get(d, a.key or a[1])
    if g ~= nil then g.damage = 0 end
end)

_G.package.loaded[_NAME] = SubGauge
return SubGauge
