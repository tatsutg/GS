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
--     -- Mode の状態のあいだだけ軽減（例: 爆走状態は被ダメ×0.2）:
--     boss:add(Defense{ { mult = 0.2, mode = 'dash' } })
--     -- 指定キャラ（コラボユニット等）以外からのダメージを半減:
--     boss:add(Defense{ { mult = 0.5, attackerBaseID = { 352, 353, 354 }, negate = true } })
--     -- 編成の属性数で倍率（編成時固定・死亡しても不変）:
--     boss:add(Defense{ { byCount = {[1]=0.5,[2]=0.8,[3]=1.0,[4]=1.2}, countPartyElements = true } })
--     -- 編成の種族数で倍率＋死亡で減少（live）:
--     boss:add(Defense{ { byCount = {[1]=0.5,[2]=0.8,[3]=1.0,[4]=1.2}, countParty = { by='race', live=true } } })
--     -- ブレイク中でないときだけ被ダメ×0.01（ブレイクダメージは takeBreakeDamageValue なので掛からない）:
--     boss:add(Defense{ { mult = 0.01, breaking = false } })
--
-- ルールのキー:
--   効果: mult=倍率 / set=固定値（set 優先）
--         mult は数値・関数・動的値テーブル（Actions.resolveValue と同じ書式）。
--         例: 樹属性の被ダメ ×[1÷(3+階層×0.05)] → { mult = { base = 3, perFloor = 0.05, inverse = true }, attackerElement = 3 }
--   カウント依存倍率:
--     byCount        table    count(0,1,2,...) -> 倍率。countStatus / countBleed / countParty(Elements) と併用。
--                             値は数値のほか動的値テーブルも可（{ perFloor = 4 } ＝ 階層×4。Actions.resolveValue）
--     byCountOver    number   byCount にキーが無いとき（上限超過）の倍率（byCount と同じく動的値も可）
--     countStatus    table    自分が持つ condition type の配列（成立数を count とする）
--     countBleed     bool     自分の出血を Lv の数だけ count に足す（出血 Lv2 なら 2）。
--                             出血は type 21 にグループ 21011 と value5＝Lv を持たせた condition
--                             （skill_effect.lua の出血付与。Lv の読み方は id_257 と同じ getValue5）
--     maxCount       number   count の上限（countStatus / countBleed / countParty 共通）
--     countParty     table    プレイヤー編成の distinct 数を count とする（汎用形）:
--                               by    'element'(属性/getElementType) | 'race'(種族/getRaceType)  既定 'element'
--                               live  true=被弾ごとに生存ユニットのみ再カウント（死亡で減少）
--                                     false/省略=編成が揃った時点で確定・以降不変（編成時固定）
--                                       ⚠ 編成時固定はホストが数を決定し全端末へ配信する（Sync）。
--                                          OnLoad(=TeamUnit::onEnter) は addChild が _TeamUnits.insert より
--                                          先に走るため、その時点ではパーティが揃っておらず、マルチでは
--                                          端末ごとに数がずれる。確定は update でホストが行う。
--     countPartyElements bool  countParty = { by='element', live=false } の従来別名（編成時固定の属性数）。
--   条件（複数指定時は when > mode > attackerBaseID > attackerRace > attackerElement >
--         attackerAttribute > attackerStatus > bossStatus の順で1つだけ評価）:
--     when           function(self, event) -> bool   任意条件（エスケープ）
--     mode           string|table  [[Mode]] の現在状態名（リストはいずれか一致）。
--                                  「怒り/飛行/暴走 状態のあいだだけ被ダメ補正」を escape 無しで書くための条件。
--     attackerBaseID number|table  攻撃側のキャラ識別ID（getBaseID3。リストはいずれか一致）
--                                  ⚠ getBaseID3 = unit_id / 10000 - 10000（例 unit_id 103527112 → 352）。
--                                     実ボス慣用（`getBaseID3() == 407` 等）と Targeting{pick='byBaseID'} と同じ次元。
--     attackerRace   number   攻撃側(event.enemy)の種族（親 TeamUnit の種族も判定）
--     attackerElement number  攻撃側の属性（getElementType）
--     attackerAttribute string|number  攻撃の種別 'physical'(1) / 'magic'(2)（getDamageAffectInfo().skillAttribute。オービット弾は祖先で判定）
--     attackerStatus number|table  攻撃側が持つ condition type（いずれか）。オービット弾は祖先で判定。
--                                  「状態異常の敵からのダメージを軽減」の定型（escape 不要）。
--     bossStatus     number|table  自分が持つ condition type（いずれか）
--     （無指定）      常時
--   条件の反転:
--     negate         bool     true で条件の成立を反転（「◯◯以外」）。条件無指定に付けると常に不成立。
--                             例: { mult = 0.5, attackerBaseID = {352,353,354}, negate = true }
--                                 ＝ 指定キャラ**以外**からのダメージを半減（コラボユニット優遇 等）
--   ブレイク状態での絞り込み（上の条件と AND。negate の対象外）:
--     breaking       bool     true=ブレイク中だけ / false=ブレイク中でないときだけ（unit:isBreak()）。
--                             例: { mult = 0.01, breaking = false } / { mult = 2, attackerElement = 1, breaking = true }
------
local _NAME = 'summoner.Choreo.Components.Defense'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Sync = require('summoner.Choreo.Components.Sync')
local Party = require('summoner.Choreo.Party')
local Actions = require('summoner.Choreo.Actions')

-- 編成時固定(live=false)のカウントを同期するチャンネル名（次元ごとに1本＝数値1つを配信）。
local FROZEN_CHANNEL = { element = 'defPartyElement', race = 'defPartyRace' }

-- 出血の condition のグループ（skill_effect.lua の出血付与が setGroupID(21011) で付ける）
local BLEED_GROUP = 21011

-- 出血 Lv（出血していなければ 0。value5 が入っていなければ 1）
local function bleedLevel(cond)
    local c = cond:findConditionWithGroupID(BLEED_GROUP)
    if c == nil then
        return 0
    end
    local lv = c:getValue5()
    if lv == nil or lv < 1 then
        return 1
    end
    return lv
end

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
--   実体は summoner.Choreo.Party（Action の動的 value = countParty と共有する唯一の実装）。
-- ⚠ engine の Team::getTeamUnit は死亡ユニットに NULL を返す（force=false 既定）ため、
--   ここで数えられるのは常に「生存ユニット」。死亡で数は自然に減る。
--   編成時固定(live=false)はこの値をホストが1回だけ確定・配信して固定する（下の frozen 経路）。
local countPartyDistinct = Party.countDistinct

-- カウントを計算（状態異常の数 / パーティの属性数・種族数）
--   cachedFrozen: 編成時固定(live=false)用にホストが確定・配信した数。{ element = n, race = n }
local function computeCount(self, event, rule, cachedFrozen)
    if rule.countStatus ~= nil or rule.countBleed then
        local cond = (event.unit or self.unit):getTeamUnitCondition()
        local c = 0
        if rule.countStatus ~= nil then
            for i = 1, #rule.countStatus do
                if cond:findConditionWithType(rule.countStatus[i]) ~= nil then
                    c = c + 1
                end
            end
        end
        if rule.countBleed then
            c = c + bleedLevel(cond)
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
    if rule.mode ~= nil then
        -- Mode Component の現在状態（dispatcher._mode）。Mode 未使用なら nil＝常に不成立。
        local modes = rule.mode
        if type(modes) == 'string' then modes = { modes } end
        for i = 1, #modes do
            if self._mode == modes[i] then return true end
        end
        return false
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
    if rule.attackerAttribute ~= nil then
        -- 物理/魔法（出典 gb_601601 物理耐性: getDamageAffectInfo().skillAttribute == 1）
        local a = attackerUnit(event)
        if a == nil then return false end
        local want = rule.attackerAttribute
        if want == 'physical' then want = 1 elseif want == 'magic' then want = 2 end
        return a:getTeamUnitCondition():getDamageAffectInfo().skillAttribute == want
    end
    if rule.attackerStatus ~= nil then
        -- 攻撃側が状態異常か（オービット弾は祖先ユニットで判定）。
        -- 「状態異常の敵からのダメージを軽減」の定型。出典: 2081580 findDeBuffFlg / 炎怪鳥の燃焼判定。
        local a = attackerUnit(event)
        if a == nil then return false end
        local cond = a:getTeamUnitCondition()
        local types = rule.attackerStatus
        if type(types) == 'number' then types = { types } end
        for i = 1, #types do
            if cond:findConditionWithType(types[i]) ~= nil then return true end
        end
        return false
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

-- negate=true で条件成立を反転（「◯◯以外」）。breaking はその外側で AND（反転しない）。
local function ruleMatches(self, event, rule)
    if rule.breaking ~= nil and (event.unit or self.unit):isBreak() ~= rule.breaking then
        return false
    end
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
                    -- カウント依存倍率（状態異常数 / 出血Lv / 属性数 / 種族数 → テーブル）
                    local count = computeCount(self, event, rule, cachedFrozen)
                    if rule.maxCount ~= nil and count > rule.maxCount then
                        count = rule.maxCount
                    end
                    local m = rule.byCount[count]
                    if m == nil then m = rule.byCountOver end
                    if m ~= nil then
                        event.value = event.value * Actions.resolveValue(m, self, event)
                    end
                elseif rule.set ~= nil then
                    event.value = rule.set
                elseif rule.mult ~= nil then
                    -- 数値はそのまま / 関数倍率（任意）/ { base, perFloor, inverse } 等の動的倍率
                    local m = Actions.resolveValue(rule.mult, self, event)
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
