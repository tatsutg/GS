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
--   protect   bool|number  ゲージ中の本体ダメージ: true=1固定（既定）/ 数値=倍率（例 0.01）/ false=守らない
--   active    bool    start から有効（既定false → ShowSubGauge で起動）
--   onBreak   Action|list  破壊時のアクション
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

local function get(self, key)
    return self._subGauges ~= nil and self._subGauges[key] or nil
end

local makeSubGauge

local SubGauge = setmetatable({}, {
    __call = function(_, config) return makeSubGauge(config) end
})

function makeSubGauge(config)
    local key = config.key or 'sub'
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
        local max = config.max or (event.unit:getCalcHPMAX() * (config.hpRate or 0.2))
        self._subGauges[key] = {
            bar = bar, max = max, damage = 0,
            active = config.active and true or false, broken = false,
        }
    end

    local function onDamage(self, event)
        local g = get(self, key)
        if g == nil or not g.active or g.broken then return end
        if hitCounts(event, config.only) then
            g.damage = g.damage + event.value
        end
        if type(config.protect) == 'number' then
            event.value = event.value * config.protect   -- 倍率指定（例 0.01 = 本体ダメージ×0.01）
        elseif config.protect ~= false then
            event.value = 1                    -- 既定: ゲージ中は本体HPを value=1 で守る
        end
    end

    local function onUpdate(self, event)
        local g = get(self, key)
        if g == nil or not g.active or g.broken then return end
        local bar = g.bar
        bar:setPositionX(event.unit:getPositionX())
        bar:setPositionY(event.unit:getPositionY() + (config.offsetY or 25))
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
