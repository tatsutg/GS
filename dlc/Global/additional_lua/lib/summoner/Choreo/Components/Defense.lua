------
-- summoner.Choreo.Components.Defense
--
-- 被ダメージ補正（takeDamageValue）を「ルール列」で宣言する Component。
-- 各ルール: 条件が成立すれば mult（倍率）か set（固定値）で event.value を補正。上から順に適用。
--
-- ⚠ takeDamageValue を使うため boss version >= 1.1。
-- ⚠ 魔法/物理ダメージ軽減は Lua からクリーンに判定できない → データのバフ（魔法耐性等）= AttachBuff で行う。
--
-- @example
--     boss:add(Defense{
--         { mult = 0.2, bossStatus = {89,90,91,92,93,94,95,96} },  -- 自分が状態異常中は被ダメ×0.2
--         { mult = 0.1, attackerRace = 8 },                        -- 攻撃側が種族8 なら×0.1（親種族も判定）
--         { mult = 0.01, attackerElement = 1 },                    -- 攻撃側が火属性 なら×0.01
--         { set = 1, when = function(self, e) return self.btActive end }, -- 任意条件でダメージ1
--         { mult = 0.5 },                                          -- 条件なし＝常時×0.5
--     })
--     -- 指定キャラ（コラボユニット等）以外からのダメージを半減:
--     boss:add(Defense{ { mult = 0.5, attackerBaseID = { 352, 353, 354 }, negate = true } })
--     -- 編成の属性数で倍率（編成時固定・死亡しても不変）:
--     boss:add(Defense{ { byCount = {[1]=0.5,[2]=0.8,[3]=1.0,[4]=1.2}, countPartyElements = true } })
--     -- 編成の種族数で倍率＋死亡で減少（live）:
--     boss:add(Defense{ { byCount = {[1]=0.5,[2]=0.8,[3]=1.0,[4]=1.2}, countParty = { by='race', live=true } } })
--
-- ルールのキー:
--   効果: mult=倍率 / set=固定値（set 優先）
--   カウント依存倍率:
--     byCount        table    count(0,1,2,...) -> 倍率。countStatus / countParty(Elements) と併用。
--     byCountOver    number   byCount にキーが無いとき（上限超過）の倍率
--     countStatus    table    自分が持つ condition type の配列（成立数を count とする）
--     countParty     table    プレイヤー編成の distinct 数を count とする（汎用形）:
--                               by    'element'(属性/getElementType) | 'race'(種族/getRaceType)  既定 'element'
--                               live  true=被弾ごとに生存ユニットのみ再カウント（死亡で減少）
--                                     false/省略=編成が揃った時点で確定・以降不変（編成時固定）
--                                       ⚠ 編成時固定はホストが数を決定し全端末へ配信する（Sync）。
--                                          OnLoad(=TeamUnit::onEnter) は addChild が _TeamUnits.insert より
--                                          先に走るため、その時点ではパーティが揃っておらず、マルチでは
--                                          端末ごとに数がずれる。確定は update でホストが行う。
--     countPartyElements bool  countParty = { by='element', live=false } の従来別名（編成時固定の属性数）。
--   条件（複数指定時は when > attackerBaseID > attackerRace > attackerElement > bossStatus の順で1つだけ評価）:
--     when           function(self, event) -> bool   任意条件（エスケープ）
--     attackerBaseID number|table  攻撃側のキャラ識別ID（getBaseID3。リストはいずれか一致）
--                                  ⚠ getBaseID3 = unit_id / 10000 - 10000（例 unit_id 103527112 → 352）。
--                                     実ボス慣用（`getBaseID3() == 407` 等）と Targeting{pick='byBaseID'} と同じ次元。
--     attackerRace   number   攻撃側(event.enemy)の種族（親 TeamUnit の種族も判定）
--     attackerElement number  攻撃側の属性（getElementType）
--     bossStatus     number|table  自分が持つ condition type（いずれか）
--     （無指定）      常時
--   条件の反転:
--     negate         bool     true で条件の成立を反転（「◯◯以外」）。条件無指定に付けると常に不成立。
--                             例: { mult = 0.5, attackerBaseID = {352,353,354}, negate = true }
--                                 ＝ 指定キャラ**以外**からのダメージを半減（コラボユニット優遇 等）
------
local _NAME = 'summoner.Choreo.Components.Defense'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Sync = require('summoner.Choreo.Components.Sync')

-- 編成時固定(live=false)のカウントを同期するチャンネル名（次元ごとに1本＝数値1つを配信）。
local FROZEN_CHANNEL = { element = 'defPartyElement', race = 'defPartyRace' }

-- ルールの「パーティ数カウント」指定を正規化して返す（無ければ nil）。
--   戻り: { by = 'element'|'race', live = bool }
local function partyCountSpec(rule)
    local cfg = rule.countParty
    if cfg ~= nil then
        return {
            by = (cfg.by == 'race') and 'race' or 'element',
            live = cfg.live == true,
        }
    end
    if rule.countPartyElements then
        return { by = 'element', live = false }   -- 従来別名（属性・編成時固定）
    end
    return nil
end

-- パーティ（プレイヤー側）の distinct な属性数 / 種族数を数える。
--   by: 'race' → getRaceType, それ以外 → getElementType
-- ⚠ engine の Team::getTeamUnit は死亡ユニットに NULL を返す（force=false 既定）ため、
--   ここで数えられるのは常に「生存ユニット」。死亡で数は自然に減る。
--   編成時固定(live=false)はこの値をホストが1回だけ確定・配信して固定する（下の frozen 経路）。
local function countPartyDistinct(by)
    local team = megast.Battle:getInstance():getTeam(true)
    local seen = {}
    local c = 0
    for i = 0, 7 do
        local u = team:getTeamUnit(i)
        if u ~= nil then
            local key
            if by == 'race' then
                key = u:getRaceType()
            else
                key = u:getElementType()
            end
            if not seen[key] then
                seen[key] = true
                c = c + 1
            end
        end
    end
    return c
end

-- カウントを計算（状態異常の数 / パーティの属性数・種族数）
--   cachedFrozen: 編成時固定(live=false)用にホストが確定・配信した数。{ element = n, race = n }
local function computeCount(self, event, rule, cachedFrozen)
    if rule.countStatus ~= nil then
        local cond = (event.unit or self.unit):getTeamUnitCondition()
        local c = 0
        for i = 1, #rule.countStatus do
            if cond:findConditionWithType(rule.countStatus[i]) ~= nil then
                c = c + 1
            end
        end
        return c
    end
    local spec = partyCountSpec(rule)
    if spec ~= nil then
        if spec.live then
            -- 被弾ごとに再カウント（死亡で変化）。端末ローカルで決定的なので同期不要。
            return countPartyDistinct(spec.by)
        end
        -- 編成時固定: ホストが確定して配信した数を使う（全端末で同一）。
        -- 未確定（配信前に被弾した等）の場合のみその場で数える（ホスト/ゲストで同値になる想定の保険）。
        local cached = cachedFrozen[spec.by]
        if cached ~= nil then
            return cached
        end
        return countPartyDistinct(spec.by)
    end
    return 0
end

-- 攻撃側ユニット（オービット弾なら祖先ユニットまで遡る。出典 2004556 の getAncestorUnit）
local function attackerUnit(event)
    local a = event.enemy
    if a == nil then return nil end
    while a:getParentTeamUnit() ~= nil do
        a = a:getParentTeamUnit()
    end
    return a
end

local function conditionMatches(self, event, rule)
    if rule.when ~= nil then
        return rule.when(self, event) and true or false
    end
    if rule.attackerBaseID ~= nil then
        local a = attackerUnit(event)
        if a == nil then return false end
        local ids = rule.attackerBaseID
        if type(ids) == 'number' then ids = { ids } end
        local baseID = a:getBaseID3()
        for i = 1, #ids do
            if baseID == ids[i] then return true end
        end
        return false
    end
    if rule.attackerRace ~= nil then
        local a = event.enemy
        if a == nil then return false end
        if a:getRaceType() == rule.attackerRace then return true end
        local p = a:getParentTeamUnit()
        return p ~= nil and p:getRaceType() == rule.attackerRace
    end
    if rule.attackerElement ~= nil then
        local a = event.enemy
        return a ~= nil and a:getElementType() == rule.attackerElement
    end
    if rule.bossStatus ~= nil then
        local cond = (event.unit or self.unit):getTeamUnitCondition()
        local types = rule.bossStatus
        if type(types) == 'number' then types = { types } end
        for i = 1, #types do
            if cond:findConditionWithType(types[i]) ~= nil then return true end
        end
        return false
    end
    return true   -- 条件なし＝常時
end

-- negate=true で条件成立を反転（「◯◯以外」）。
local function ruleMatches(self, event, rule)
    local matched = conditionMatches(self, event, rule)
    if rule.negate then
        return not matched
    end
    return matched
end

local function Defense(rules)
    local component = { name = 'Defense' }

    -- 編成時固定(live=false)で使う次元(element/race)を洗い出す。
    -- （live=true のルールは毎回その場で数えるため同期・キャッシュ不要）
    local frozenDims = {}   -- 宣言順の配列（チャンネル open 順を決定的にするため配列で持つ）
    local seenDim = {}
    for i = 1, #rules do
        local spec = partyCountSpec(rules[i])
        if spec ~= nil and not spec.live and not seenDim[spec.by] then
            seenDim[spec.by] = true
            table.insert(frozenDims, spec.by)
        end
    end
    local anyFrozen = #frozenDims > 0

    local cachedFrozen = {}   -- { element = n, race = n }（ホスト決定→全端末で埋まる）

    -- 編成が揃ったか。OnLoad(TeamUnit::onEnter) は addChild が _TeamUnits.insert より先に走るため
    -- その時点では 0〜途中までしか見えない。1体以上見えたら「揃った」とみなして確定する。
    -- （ホストのみが判定し、結果を配信するのでゲストの見え方には依存しない）
    local function partyReady()
        local team = megast.Battle:getInstance():getTeam(true)
        for i = 0, 7 do
            if team:getTeamUnit(i) ~= nil then return true end
        end
        return false
    end

    -- ホストが update で1回だけ各次元の数を確定し、全端末へ配信する。
    local function onUpdate(self, event)
        if self._defFrozenDone then return end
        if not self.isHostPlayer then return end
        if not partyReady() then return end
        for i = 1, #frozenDims do
            local by = frozenDims[i]
            self:hostDecide(FROZEN_CHANNEL[by], countPartyDistinct(by))
        end
        self._defFrozenDone = true
    end

    local function onDamage(self, event)
        for i = 1, #rules do
            local rule = rules[i]
            if ruleMatches(self, event, rule) then
                if rule.byCount ~= nil then
                    -- カウント依存倍率（状態異常数 / 属性数 / 種族数 → テーブル）
                    local count = computeCount(self, event, rule, cachedFrozen)
                    local m = rule.byCount[count]
                    if m == nil then m = rule.byCountOver end
                    if m ~= nil then
                        event.value = event.value * m
                    end
                elseif rule.set ~= nil then
                    event.value = rule.set
                elseif rule.mult ~= nil then
                    local m = rule.mult
                    if type(m) == 'function' then m = m(self, event) end   -- 関数倍率（任意）
                    event.value = event.value * m
                end
            end
        end
    end

    function component.initialize(dispatcher)
        if anyFrozen then
            -- 編成時固定はホストが決めて全端末へ配信する（Phases と同じ Sync 経路）。
            if not dispatcher:hasComponent('Sync') then
                dispatcher:add(Sync.create())
            end
            -- 次元ごとに1チャンネル（1チャンネル＝数値1つ）。宣言順に open してポートを決定的にする。
            for i = 1, #frozenDims do
                local by = frozenDims[i]
                dispatcher:openChannel(FROZEN_CHANNEL[by], function(self, value)
                    cachedFrozen[by] = value   -- ホストは hostDecide 時、ゲストは受信時に同じ値が入る
                end)
            end
            dispatcher:addEventListener(Events.OnUpdate, onUpdate)
        end
        dispatcher:addEventListener(Events.takeDamageValue, onDamage)
    end

    return component
end

_G.package.loaded[_NAME] = Defense
return Defense
