------
-- summoner.Choreo.Actions
--
-- Action カタログ。仕様: _WORK/lua/docs/09-action-catalog.md
-- 各 Action は Action.define で生成された callable 値オブジェクト。
-- トリガー Component から Action.runActions(dispatcher, event, {...}) で実行される。
------
local _NAME = 'summoner.Choreo.Actions'
local _M = {}
local _G = _G

local Action = require('summoner.Choreo.Action')
local Buff = require('summoner.Choreo.Buff')
local Message = require('summoner.Choreo.Message')
local Random = require('summoner.Random')
local Party = require('summoner.Choreo.Party')

local resolveTarget = Action.resolveTarget

------
-- 動的な値の解決（AttachBuff / StackBuff / StackDebuff の value と time）。
-- 数値はそのまま。テーブルなら宣言に従って実行時に算出する（「パーティの属性数×10%」等）。
--
--   value = 30                                          -- 静的
--   value = { countParty = 'element', per = 10 }        -- 生存プレイヤーの属性数 × 10
--   value = { countParty = 'race', per = 25 }           -- 種族数 × 25
--   value = { countParty = 'element', per = 10, base = 5, max = 50 }
--   value = { base = 100, perFloor = 30 }               -- 階層比例（グラバト・鉱山）: 100 + 階層×30
--   value = { base = 3, perFloor = 0.05, inverse = true } -- 逆数: 1 ÷ (3 + 階層×0.05)（Defense の mult 等）
--   time  = { base = 1, perUse = 2 }                    -- 使用回数比例: 1 + 使用回数×2（onUse の中で使う）
--   value = function(d, e) return n end                 -- エスケープ
--
--   countParty  'element'(既定) | 'race' | { by = 'element'|'race' }
--   per         1カウントあたりの値（既定1）
--   base        カウントに依らない加算（既定0）
--   min / max   クランプ（任意）
--   perFloor    1階層あたりの値（鉱山は getCurrentMineFloor、それ以外は getCurrentGrandBattleFloor。どちらでもなければ階層1）
--   inverse     true で perFloor の算出値の逆数を返す
--   perUse      使用1回あたりの値。回数は onUse の event.useCount（その index の通算・今回を含む・1始まり）。
--               onUse の外（event.useCount が無い）では 0 回として base だけになる
--
-- ⚠ 数えるのは**生存**ユニットのみ（engine の getTeamUnit が死亡枠に nil を返すため）。
-- ⚠ 符号は呼び出し側で決める（デバフ方向は per を負に。docs/21 の value 符号規約）。
-- 同期不要: 全端末が同じチーム状態から同じ数を得る決定的処理（summoner.Choreo.Party）。
------
local function clampValue(v, n)
    if v.max ~= nil and n > v.max then n = v.max end
    if v.min ~= nil and n < v.min then n = v.min end
    return n
end

------
-- 現在の階層。鉱山は getCurrentMineFloor、それ以外は getCurrentGrandBattleFloor（グラバト外は engine が 1 を返す）。
------
function _M.currentFloor()
    local b = megast.Battle:getInstance()
    if b.isMine ~= nil and b:isMine() then
        return b:getCurrentMineFloor()
    end
    return b:getCurrentGrandBattleFloor()
end

local function resolveValue(v, d, e)
    if v == nil then return nil end
    local t = type(v)
    if t == 'number' then return v end
    if t == 'function' then return v(d, e) end
    if t ~= 'table' then return v end

    if v.perFloor ~= nil then             -- 階層比例: base + 階層×perFloor（通常クエストは階層1）。min/max は逆数化の前に適用
        local floor = _M.currentFloor()
        local n = clampValue(v, (v.base or 0) + floor * v.perFloor)
        if v.inverse then
            return 1 / n
        end
        return n
    end

    if v.perUse ~= nil then               -- 使用回数比例: base + 使用回数×perUse（onUse の event.useCount）
        local uses = (e ~= nil and e.useCount) or 0
        return clampValue(v, (v.base or 0) + uses * v.perUse)
    end

    local spec = v.countParty
    if spec == nil then return v end      -- countParty を持たないテーブルは触らない（後方互換）
    local by = spec
    if type(spec) == 'table' then by = spec.by end
    local count = Party.countDistinct(by == 'race' and 'race' or 'element')
    return clampValue(v, (v.base or 0) + count * (v.per or 1))
end

_M.resolveValue = resolveValue

------
-- OrbitType（C++ の enum 宣言順。Classes/Team/OrbitSystem.h）。名前でも数値でも書けるようにする。
--   aura は「本体に纏わせる常駐エフェクト」用の専用タイプ（実ボス慣用 setOrbitType(4)）。
------
local ORBIT_TYPES = { lazer = 0, shot = 1, unit = 2, linkburst = 3, aura = 4 }

local function resolveOrbitType(v)
    if v == nil then return nil end
    if type(v) == 'string' then return ORBIT_TYPES[v] end
    return v
end

------
-- Z オーダーの名前（Classes/Battle/BattleConf.h の定数）。数値を直接書いてもよい。
--
-- ⚠ オービットの既定は ZORDER_ORBIT = **8000 の固定値**（OrbitSystem::init が _autoZoder=false にするため
--    以後エンジンは再計算しない）。一方ボス本体の Z は状態で変わる:
--      通常時          -getPositionY() + ZORDER_FRONT(3000)          … 3000未満
--      奥義発動中      **ZORDER_CASTSKILL(8000) の固定値**（size!=3,5。_autoZoder も false になる）
--      小型ボスの行動中 ZORDER_STAGE_OVER-1 = 9099
--    つまり **奥義中はボスと同値の 8000 になり、後から setLocalZOrder したボスが手前に来る**
--    （cocos は localZOrder が同値なら arrival order 順で描画するため）。
--    オーラを常に手前に出したいときは **'top'（9100 = ZORDER_STAGE_OVER）** を指定する
--    ⚠ 'unitfront'(3000) はエンジンの ZORDER_FRONT で「手前」の意味ではない（ユニットの通常帯）。
------
local ZORDERS = {
    back = 100, boss = 2000, unitfront = 3000, takereaction = 6000,
    orbit = 8000, castskill = 8000, dead = 8800, hiteffect = 9000,
    top = 9100,
}

local function resolveZOrder(v)
    if v == nil then return nil end
    if type(v) == 'string' then return ZORDERS[v] end
    return v
end

------
-- 常駐オービットの登録簿（key => orbit）。SpawnOrbit{key} が入れ、RemoveOrbit{key} が消す。
-- ⚠ Action には OnLoad が無いので、**self.unit の同一性**で戦闘の切り替わりを検出して捨てる
--    （generate() が start ごとに self.unit を張り替えるため、リトライ/2戦目では必ず別インスタンスになる）。
--    これをしないと前戦闘の解放済み orbit を掴んだまま remove して落ちる（規約 §6-3 の per-instance）。
------
local function orbitRegistry(d)
    if d._orbits == nil or d._orbitUnit ~= d.unit then
        d._orbits = {}
        d._orbitUnit = d.unit
    end
    return d._orbits
end

------
-- Chance — p% の確率で actions を実行。
--   乱数はホストが実行時に決め、結果(成功/失敗)を全端末へ配信し、両端末で actions を実行する。
--   （condition は端末ローカル決定的＝AttachBuff は両端末で走らせる必要がある。host だけで実行すると
--    ゲストに condition が付かず desync する。レガシー isHost→Random→sendEventToLua→receiveN と同思想。）
--   チャンネルは Component の initialize で `Action.preregisterChances` により**静的に宣言順 pre-open**
--   される（per-instance・port 決定的。到達順や host 限定文脈に依存しない）。
--   ⚠ 前提: Chance は preregisterChances を呼ぶ Component の actions（Selector onUse / Phases stage）に
--      置くこと。未登録の場所で使うと assert で弾く。⚠ マルチ実機未検証（host/guest 2台の実証が別途必要）。
------
_M.Chance = Action.define('Chance', function(a, d, e)
    -- チャンネルは initialize の preregisterChances で dispatcher に開設済み（per-instance）。
    local name = d._chanceChannels and d._chanceChannels[a]
    assert(name ~= nil,
        'Choreo: Chance が未登録です。onUse / Phases など preregisterChances を呼ぶ同期文脈で使うこと')
    d._chanceEvents = d._chanceEvents or {}
    d._chanceEvents[a] = e   -- fire 時の event を handler へ渡す（per-instance）
    if d.isHostPlayer then
        local hit = (Random.range(0, 100) < (a.p or 0)) and 1 or 0
        d:hostDecide(name, hit)   -- 自分で handler(成功時 actions)実行 + 全端末へ配信
    end
    -- ゲストは待機（broadcast 受信時に handler が actions を実行）
end)

------
-- 1. AttachBuff — バフ/デバフ付与（addCondition + group/priority + script + aura）
--   aura: condition に spine を纏わせる（オーラ演出）。
--     aura = true                                → 実ボス最頻の既定 effect/aura1.json の "aura2"
--     aura = { file = "...json", anim = "..." }  → 任意の spine/アニメ
--   出典: 実ボス慣用 `FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end`
--   （enemy/ 68ファイル。BUFF_ID=0・ICON=0 の「見た目だけのバフ」に付けるのが定型）。
--   target = Targeting{ side = 'player', pick = 'all' } のように配列を返す指定では、生存ユニット全員へ付与する
--   （「パーティを永続で燃焼状態にする（HIT関係なく）」等。HIT・耐性の判定を通さず直接付く）。
------
local function attachOne(a, unit, value, time)
    local cond = unit:getTeamUnitCondition()

    -- group 規約: 省略時 = 効果タイプ（同種=同グループ）/ priority 省略時 = value（強い方が勝つ）。
    -- 重複あり（並存）にしたい場合のみ group=-1 を明示。
    local group = a.group
    if group == nil then group = a.type end
    local priority = a.priority
    if priority == nil then priority = value or 0 end

    -- グループ上書き制御（-1=無所属は対象外）
    if group ~= -1 then
        local existing = cond:findConditionWithGroupID(group)
        if existing ~= nil then
            if existing:getPriority() <= priority then
                cond:removeCondition(existing)
            else
                return   -- 既存が強い → 付与しない
            end
        end
    end

    -- aura: condition に纏わせる spine（true=定型の effect/aura1.json "aura2" / table=任意指定）
    local auraFile, auraName
    local aura = a.aura
    if aura ~= nil and aura ~= false then
        if type(aura) == 'table' then
            auraFile = aura.file or 'effect/aura1.json'
            auraName = aura.anim or 'aura2'
        else
            auraFile = 'effect/aura1.json'
            auraName = 'aura2'
        end
    end

    local script = a.script
    return Buff{
        id = a.id,
        type = a.type,
        value = value,
        time = time or 99999,
        icon = a.icon,
        group = group,
        priority = priority,
        effect = a.effect,
        scriptID = script and script.id or nil,
        scriptValue1 = script and script.v1 or nil,
        scriptValue2 = script and script.v2 or nil,
        scriptValue3 = script and script.v3 or nil,
        scriptValue4 = script and script.v4 or nil,
        scriptValue5 = script and script.v5 or nil,
        animationFile = auraFile,
        animationName = auraName,
    }:attach(unit)
end

_M.AttachBuff = Action.define('AttachBuff', function(a, d, e)
    local target = resolveTarget(a, d, e)
    local value = resolveValue(a.value, d, e)   -- countParty 等の動的値をここで確定させる（全員同じ値）
    local time = resolveValue(a.time, d, e)     -- 秒数も動的値可（{ base, perUse } で使用回数比例 等）
    if type(target) == 'table' and target.getTeamUnitCondition == nil then
        -- Targeting{ pick = 'all' } は TeamUnit の配列を返す
        for i = 1, #target do
            attachOne(a, target[i], value, time)
        end
        megast.Battle:getInstance():updateConditionView()
        return
    end
    return attachOne(a, target, value, time)
end)

------
-- 2. GainSP — SP加算（正準は value または位置引数。amount も受ける＝silent no-op の罠を防ぐ）
------
_M.GainSP = Action.define('GainSP', function(a, d, e)
    if a.hostOnly and not d.isHostPlayer then
        return
    end
    local unit = resolveTarget(a, d, e)
    unit:addSP(a.value or a[1] or a.amount or 0)
end)

------
-- 3. Say — 台詞/メッセージ
------
_M.Say = Action.define('Say', function(a, d, e)
    local text = a.text or a[1]
    -- locale: key 指定があり d.TEXT に登録があれば多言語定数を引く（未登録なら text=リテラルがフォールバック）。
    -- key 未指定でも text 自体がキーなら従来どおり解決する（後方互換）。
    local key = a.key
    if key ~= nil and d.TEXT ~= nil and d.TEXT[key] ~= nil then
        text = d.TEXT[key]
    elseif d.TEXT ~= nil and d.TEXT[text] ~= nil then
        text = d.TEXT[text]
    end
    local message = Message{
        text = text,
        time = a.time,
        color = a.color,
        icon = a.icon,
    }
    if a.side == 'player' then
        message:showPlayerSide()
    else
        message:show()
    end
end)

------
-- 標準の状態異常タイプ列（refresh / 状態異常回復で除去する対象）
------
_M.BadStatus = { 89, 90, 91, 92, 93, 94, 95, 96, 97 }

-- 同タイプの condition を全インスタンス除去（refresh 相当・無限ループ防止つき）
local function removeAllOfType(cond, t)
    local c = cond:findConditionWithType(t)
    local guard = 0
    while c ~= nil and guard < 50 do
        cond:removeCondition(c)
        c = cond:findConditionWithType(t)
        guard = guard + 1
    end
end

------
-- 4. RemoveBuff — バフ除去（types[全インスタンス] / id / group）
------
_M.RemoveBuff = Action.define('RemoveBuff', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    local cond = unit:getTeamUnitCondition()
    if a.types ~= nil then
        for i = 1, #a.types do
            removeAllOfType(cond, a.types[i])
        end
    end
    if a.id ~= nil then
        local c = cond:findConditionWithID(a.id)
        if c ~= nil then cond:removeCondition(c) end
    end
    if a.group ~= nil then
        local c = cond:findConditionWithGroupID(a.group)
        if c ~= nil then cond:removeCondition(c) end
    end
end)

------
-- ResetHate — ヘイト（累計ダメージ）をリセットして再ターゲット（奥義時リセット等）
--   scope = 'all'（既定） … 全員の累計を消す（engine の resetHate も呼ぶ）
--   scope = 'target'      … 現ターゲットの累計だけ消す。他のユニットの累計は残るので、
--                           2番手が次の判定ですぐターゲットになる（前例 enemy/2068885.lua の resetHateDamage・
--                           enemy/2078890.lua の targetStun。どちらもターゲットの dps だけ 0 にしている）
--   ⚠ 再判定は HateTarget のホストが次の update で行い、ゲストへ配信する（Action 自体は全端末で走ってよい）。
--   scope の打ち間違いはボス定義の読み込み時（Action の構築時）に assert で止める（戦闘中には落とさない）。
--
-- @example 奥義3でターゲットを封圧状態にし、ターゲットの累計だけリセット
--     onUse = { [3] = { AttachBuff{ target = Targeting{ pick = 'hate' }, ... }, ResetHate{ scope = 'target' } } }
------
local ResetHateAction = Action.define('ResetHate', function(a, d, e)
    -- HateTarget は累計を Lua 側（dispatcher._hateTotals）で持つのでそれをクリアする。
    -- ⚠ engine の updateHateTarget() は呼ばない（毎フレーム呼んだ際に実機クラッシュ signal 11 を確認）。
    --    resetHate() は _HateList を clear するだけなので engine 側も併せてクリアしておく。
    local unit = resolveTarget(a, d, e)
    if (a.scope or a[1]) == 'target' then
        -- 現ターゲットの枠: HateTarget が決めた index（ホストは判定時・ゲストは受信時に入る）。
        -- 未確定（初被弾前・休止中）なら engine のヘイトターゲットで代用する。
        local idx = d._hateTargetIndex
        if idx == nil or idx < 0 then
            local t = unit:getHateTarget()
            idx = t ~= nil and t:getIndex() or nil
        end
        if idx ~= nil and idx >= 0 and d._hateTotals ~= nil then
            d._hateTotals[idx] = nil
            d._hateSentIndex = nil   -- 次の update で首位を再判定・再配信させる
        end
        return
    end
    unit:resetHate()
    if d._hateTotals ~= nil then
        d._hateTotals = {}
        d._hateSentIndex = nil   -- 次の update で首位を再判定・再配信させる
    end
end)

_M.ResetHate = setmetatable({ meta = ResetHateAction.meta, actionName = ResetHateAction.actionName }, {
    __call = function(_, params)
        local scope = params ~= nil and (params.scope or params[1]) or nil
        assert(scope == nil or scope == 'all' or scope == 'target',
            'Choreo.ResetHate: scope は "all"（既定）か "target"（実際: ' .. tostring(scope) .. '）')
        -- __call を持つテーブル（ResetHateAction）を末尾呼び出し（return X(...)）すると、実機の LuaJIT が
        -- lj_vmeta_callt → lj_BC_TGETS で EXC_BAD_ACCESS になる。いったん受けてから返す
        local action = ResetHateAction(params)
        return action
    end,
})

------
-- InvertBuffs — ステータスアップ効果を反転する（強化を消して、同じ量のデバフに置き換える）
--   出典: enemy/2005951.lua（真EX極 針目縫）の BuffReverseStatus / checkCondition。
--   各ユニットの types の condition のうち「値が正（getValue() > 0）・パッシブ由来でない（not getIsPassive()）」
--   ものを値0・効果時間0・アイコン無しにして消し、**グループごと**に合計した値の負値で同じ type のデバフを付ける。
--   デバフのグループは元のまま、プライオリティは |合計| × priorityRate。engine は同じグループでは優先度の高い方を
--   残して低い付与を弾く（TeamUnitCondition::groupIDCheck）ので、効果中は同じグループのバフを掛け直せない。
--
--   types        反転する condition type の配列（既定 { 1, 2, 12, 13, 14, 15 }＝最大HP・攻撃力・防御力の
--                固定値/割合。原典と同じ）
--   time         デバフの効果時間（既定 30）
--   priorityRate プライオリティ倍率（既定 100）
--   icons        { [type] = icon }。書いた type だけ既定を上書きする
--                （既定 最大HPダウン 2 / 攻撃力ダウン 4 / 防御力ダウン 6。どちらにも無い type は 0＝アイコン無し）
--   id           デバフの condition ID（既定 -type）。負の ID は engine の同 ID 上書きを通らないので、
--                同じ type でグループ違いのデバフが並存できる（正の ID だとグループ違いが上書きし合う）
--   target       対象（既定 プレイヤー全員。Targeting 可）
--
--   ⚠ condition は端末ローカルなので全端末で実行する（AttachBuff と同じ。Phases / onUse の actions に置く）。
--      バフの到着が端末間でずれていると反転量もずれうる（原典も各端末で反転している）。
--
-- @example HP0.5% で全ステータスアップ効果反転（30秒）
--     Phases{ { at = 0.5, stop = true, actions = { InvertBuffs{ time = 30 } } } }
------
local INVERT_TYPES = { 1, 2, 12, 13, 14, 15 }                                       -- 最大HP/攻撃力/防御力 の固定値・割合
local INVERT_ICONS = { [1] = 2, [2] = 2, [12] = 4, [13] = 4, [14] = 6, [15] = 6 }  -- 最大HP/攻撃力/防御力 ダウン

-- 1ユニット分: type ごとに正の非パッシブを消してグループ別に合計し、同じグループへ負値のデバフを付ける
local function invertUnit(a, unit, types, time, rate)
    local cond = unit:getTeamUnitCondition()
    for ti = 1, #types do
        local t = types[ti]
        local sums, groups = {}, {}            -- グループ => 合計 / 出現順（端末間で同じ順に付ける）
        local size = cond:getAllConditionsSize()
        for i = 0, size - 1 do
            local c = cond:getAllConditionsAt(i)
            if c ~= nil and c:getConditionTypeAsInt() == t and c:getValue() > 0 and not c:getIsPassive() then
                local g = c:getGroupID()
                if sums[g] == nil then
                    sums[g] = 0
                    groups[#groups + 1] = g
                end
                sums[g] = sums[g] + c:getValue()
                c:setValue(0)
                c:setThumbnailID(0)
                c:setTime(0)
            end
        end
        local icon = (a.icons ~= nil and a.icons[t]) or INVERT_ICONS[t] or 0
        for k = 1, #groups do
            local g = groups[k]
            local value = -sums[g]
            local priority = math.floor(-value * rate + 0.5)
            cond:addConditionWithGroupID(a.id or -t, t, value, time, icon, g, priority)
        end
    end
end

_M.InvertBuffs = Action.define('InvertBuffs', function(a, d, e)
    local units = {}
    if a.target ~= nil then
        local target = resolveTarget(a, d, e)
        if type(target) == 'table' and target.getTeamUnitCondition == nil then
            units = target                                  -- Targeting{ pick = 'all' } は配列
        elseif target ~= nil then
            units = { target }
        end
    else
        local team = megast.Battle:getInstance():getTeam(true)
        for i = 0, 7 do
            local u = team:getTeamUnit(i)                   -- 戦闘不能の枠は nil
            if u ~= nil then units[#units + 1] = u end
        end
    end
    local types = a.types or INVERT_TYPES
    local time = resolveValue(a.time, d, e) or 30
    local rate = a.priorityRate or 100
    for i = 1, #units do
        invertUnit(a, units[i], types, time, rate)
    end
    megast.Battle:getInstance():updateConditionView()
end)

------
-- CureStatus — 状態異常回復（自分の状態異常を全除去）。types 省略時は BadStatus。
------
_M.CureStatus = Action.define('CureStatus', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    local cond = unit:getTeamUnitCondition()
    local types = a.types or _M.BadStatus
    for i = 1, #types do
        removeAllOfType(cond, types[i])
    end
end)

------
-- 5. Invincible — 無敵時間
------
_M.Invincible = Action.define('Invincible', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    unit:setInvincibleTime(a.seconds or a[1] or 0)
end)

------
-- 6. SetAttackDelay — 攻撃間隔変更
------
_M.SetAttackDelay = Action.define('SetAttackDelay', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    unit:setAttackDelay(a.seconds or a[1] or 0)
end)

------
-- 7. SpawnOrbit — 弾/分離体生成 ＋ 常駐オーラ
--
-- 常駐オーラ（本体に纏わせ続けるエフェクト）に使う引数:
--   orbitType : 'aura'|'lazer'|'shot'|'unit'|'linkburst' or 数値。file 経路でも効く
--   follow    : true で本体追従（EnabledFollow。C++ が毎フレーム親ユニット位置へ置く）
--   chain     : { after=, anim=, loop=, track= } or その配列。
--               `after` のアニメが終わったら `anim` へ遷移させる（setChainAnimationData）
--   key       : 登録簿に載せる。RemoveOrbit{key} で消せる
--   zOrder    : 描画順。数値 or 名前（'top'=9100 等。既定はエンジンの ZORDER_ORBIT=8000）。
--               **奥義中はボスも 8000 になり後勝ちで前に出る**ので、常に手前へ出すなら 'top'(9100) を指定する
--
-- ⚠ **オーラは chain か loop が無いと消える**。addOrbitSystemWithFile は init が
--    `setAnimation(0, anim, false)`（非ループ）で再生し、OrbitSystem::setAnimation が仕込む
--    completeListener が「チェーン定義が無く、現在アニメが非ループ」なら playEnd() → remove() する。
--    つまり導入アニメ1本だけ渡すと、それが終わった瞬間にオーラごと消滅する。
--    completeListener は **チェーン定義を最優先で見る**ので、chain を張れば remove に落ちない。
--
-- @example 魔血開眼オーラ（導入 → ループへ遷移して残り、本体に追従）
--     SpawnOrbit{ key = 'kaigan', file = 'BloodKaigan2', anim = 'Kaigan_in',
--                 orbitType = 'aura', follow = true,
--                 chain = { after = 'Kaigan_in', anim = 'Kaigan_loop', loop = true } }
--     RemoveOrbit{ 'kaigan' }
--
-- ⚠ `file` は **拡張子・パス無しの素の名前**（Utilities::getUnitAnimationFilePath が
--    dlc/unit/animation/<name>.json へ解決する）。AttachBuff{aura.file} の dlc 相対パスとは書式が違う。
------
_M.SpawnOrbit = Action.define('SpawnOrbit', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    local orbit
    if a.file ~= nil then
        orbit = unit:addOrbitSystemWithFile(a.file, a.anim)
    else
        orbit = unit:addOrbitSystem(a.anim, a.type or 0)
    end
    if orbit == nil then
        return                      -- ファイル未検出等（C++ が CheatWindow に警告を出す）
    end

    -- オーラ用: 型 / 追従 / アニメ遷移 / 登録簿
    local orbitType = resolveOrbitType(a.orbitType)
    if orbitType ~= nil then orbit:setOrbitType(orbitType) end
    if a.follow then orbit.EnabledFollow = true end
    local zOrder = resolveZOrder(a.zOrder)
    if zOrder ~= nil then orbit:setZOrder(zOrder) end
    local chain = a.chain
    if chain ~= nil then
        if chain.after ~= nil then chain = { chain } end     -- 単体指定もリスト扱いに揃える
        for i = 1, #chain do
            local c = chain[i]
            orbit:setChainAnimationData(c.track or 0, c.anim, c.after, c.loop ~= false)
        end
    end
    if a.key ~= nil then orbitRegistry(d)[a.key] = orbit end

    if a.skill ~= nil then orbit:setActiveSkill(a.skill) end
    if a.hits ~= nil then orbit:setHitCountMax(a.hits) end
    if a.endAnim ~= nil then orbit:setEndAnimationName(a.endAnim) end
    if a.element ~= nil then orbit:setElementType(a.element) end
    if a.damageRate ~= nil then orbit:setDamageRateOffset(a.damageRate) end
    if a.breakRate ~= nil then orbit:setBreakRate(a.breakRate) end

    -- 位置: "caster" | ボーン名 | {x=,y=}
    local at = a.at or 'caster'
    if type(at) == 'table' then
        orbit:setPosition(at.x or 0, at.y or 0)
    elseif at == 'caster' then
        orbit:setPosition(unit:getPositionX(), unit:getPositionY())
    else
        local sk = unit:getSkeleton()
        local x = unit:getPositionX() + sk:getBoneWorldPositionX(at)
        local y = unit:getPositionY() + sk:getBoneWorldPositionY(at)
        orbit:setPosition(x, y)
    end
    return orbit
end)

------
-- RemoveOrbit — SpawnOrbit{key} で登録した常駐オービットを消す
--   ⚠ remove() 後の userdata は解放済みになり得るので、**先に登録簿から外してから** remove を呼ぶ。
--     二度呼ばれても登録簿に無ければ何もしない。
------
_M.RemoveOrbit = Action.define('RemoveOrbit', function(a, d, e)
    local key = a.key or a[1]
    if key == nil then return end
    local registry = orbitRegistry(d)
    local orbit = registry[key]
    if orbit == nil then return end
    registry[key] = nil
    orbit:remove()
end)

------
-- SetDamageRate — 本体のダメージ/ブレイクの取り分を設定（残りをオービットへ委譲するときの本体側）
--   出典: 107426512 / 108507112 の takeSkill で setDamageRateOffset + setBreakRate を掛ける定型。
--   ⚠ 省略したキーは 1（等倍）に戻る。宣言＝その時点の取り分の**全体像**。
--   ⚠ setDamageRateOffset は resetStates() で戻らない（sticky）。行動 index ごとに切り替えるなら
--      単発の本 Action ではなく Component の DamageRate を使う（未宣言 index を毎行動 1 に戻す）。
------
_M.SetDamageRate = Action.define('SetDamageRate', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    unit:setDamageRateOffset(a.damageRate or 1)
    unit:setBreakRate(a.breakRate or 1)
end)

------
-- 8. PlayAnimation — 任意アニメ再生
------
_M.PlayAnimation = Action.define('PlayAnimation', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    unit:takeAnimation(a.track or 0, a.name or a[1], a.loop or false)
end)

------
-- 9. SetHP — HP直接操作（value 絶対値 or rate 割合）
------
_M.SetHP = Action.define('SetHP', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    if a.rate ~= nil then
        unit:setHP(math.floor(unit:getCalcHPMAX() * a.rate))
    else
        unit:setHP(a.value or a[1] or 0)
    end
end)

------
-- 10a. PlayEffect — エフェクトアニメ
------
_M.PlayEffect = Action.define('PlayEffect', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    unit:takeAnimationEffect(a.track or 0, a.name or a[1], a.loop or false)
end)

------
-- StackDebuff — チーム全員へスタックするデバフを付与（アイコンに数値・MAX上限・庇い加算）
--   実ボス慣用: condition を find by ID → スタック数 count → addCondition(value*count) + setNumber(count)。
--   value はスタック数ぶん増加し、condition の getNumber がアイコン数値になる。
--   例: 奥義使用ごとにプレイヤー全体の暗闇耐性を 10% ずつ DOWN（MAX10）。
--
--   引数: id, type, value, max, icon, side('player'/'enemy'), time, effect
--   cover (任意): 庇いマーカーの condition type（例 128）。指定すると庇い加算が有効:
--     庇うユニット（cover type を持つ）がいる場合、そのユニットがパーティ全員ぶんを被り（+人数）、
--     被庇護側（cover を持たない）には付与しない。
--     ※ 庇いは clean な API が無く実装がボス毎に揺れる。本実装は仕様記述準拠の前提（要実機確認）。
------
-- baseValue: 1スタックあたりの値。省略時は a.value（呼び出し側で resolveValue 済みの値を渡す）。
-- time     : 効果時間。呼び出し側で resolveValue 済みの値を渡す（nil なら 99999）。
local function applyStacks(a, cond, addN, baseValue, time)
    local existing = cond:findConditionWithID(a.id)
    local old = (existing ~= nil and existing:getNumber()) or 0
    local count = old + addN
    if a.max ~= nil and count > a.max then
        count = a.max
    end
    if baseValue == nil then baseValue = a.value end
    local value = (baseValue or 0) * count
    local c
    if a.effect ~= nil then
        c = cond:addCondition(a.id, a.type, value, time or 99999, a.icon or 0, a.effect)
    else
        c = cond:addCondition(a.id, a.type, value, time or 99999, a.icon or 0)
    end
    if c ~= nil then
        -- group 規約: 省略時 = 効果タイプ（同種=同グループ）/ priority 省略時 = 現在の累積 value（強い方が勝つ）。
        -- 重複あり（並存）は group=-1 を明示。addCondition 既定の group 0 は放置しない。
        local group = a.group
        if group == nil then group = a.type end
        c:setGroupID(group)
        local priority = a.priority
        if priority == nil then priority = value end
        c:setPriority(priority)
        if a.max ~= nil then
            c:setMaxConditionIconNumber(a.max)   -- アイコン数値の上限表示（実ボス慣用 1605015）
        end
        c:setNumber(count)   -- アイコン数値を正確に（capped）
        local script = a.script   -- script 付き condition（AttachBuff と同形。例: 与ダメ17+script22=クリティカルダメージ）
        if script ~= nil and script.id ~= nil then
            c:setScriptID(script.id)
            if script.v1 ~= nil then c:setValue1(script.v1) end
            if script.v2 ~= nil then c:setValue2(script.v2) end
            if script.v3 ~= nil then c:setValue3(script.v3) end
            if script.v4 ~= nil then c:setValue4(script.v4) end
            if script.v5 ~= nil then c:setValue5(script.v5) end
        end
        -- 再描画: engine は同一ID再付与で旧 condition を削除→新規追加し、その時点で表示を描き直す。
        -- setNumber は追加後に呼ぶため明示再描画しないと数値が次の再描画まで出ない（実ボス慣用 1605015）。
        megast.Battle:getInstance():updateConditionView()
    end
    return c
end

_M.StackDebuff = Action.define('StackDebuff', function(a, d, e)
    local team = megast.Battle:getInstance():getTeam(a.side ~= 'enemy')
    local baseValue = resolveValue(a.value, d, e)   -- countParty 等の動的値
    local time = resolveValue(a.time, d, e)
    local units = {}
    for i = 0, 7 do
        local u = team:getTeamUnit(i)
        if u ~= nil then units[#units + 1] = u end
    end

    if a.cover ~= nil then
        -- 庇うユニット（cover type を持つ）を抽出
        local coverers = {}
        for _, u in ipairs(units) do
            if u:getTeamUnitCondition():findConditionWithType(a.cover) ~= nil then
                coverers[#coverers + 1] = u
            end
        end
        if #coverers > 0 then
            -- 庇うユニットがパーティ全員ぶんを被る（例: 4人で1人庇い → +4）
            for _, u in ipairs(coverers) do
                applyStacks(a, u:getTeamUnitCondition(), #units, baseValue, time)
            end
            return  -- 被庇護側には付与しない
        end
    end

    -- 通常: 全員 +1
    for _, u in ipairs(units) do
        applyStacks(a, u:getTeamUnitCondition(), 1, baseValue, time)
    end
end)

------
-- StackBuff — 単体（既定 self）へスタックするバフを付与（アイコンに数値・MAX上限）。
--   StackDebuff の単体対象版。出典: 実ボス慣用（2000694 憂月: extraTimerOneRound ごとに
--   execAddBuff で自身へ与ダメUP を ID 固定でスタック、setNumber でアイコン数値）。
--   引数: id, type, value, max, icon, time, effect, target（既定 self）, stacks
--   stacks: 1回で積む数（既定1）。明示の a.stacks > event.stacks > 1 の順で採用する。
--     event.stacks は「同時撃破ぶんを1回にまとめて積む」ための経路（Minions の onKill が入れる）。
--     ⚠ addCondition にはクールタイムがあり、同フレームに複数回叩くと1回ぶんしか乗らない。
--       確定数を合算して**1フレーム1回**で積むこと（実績: unit/103907112 の撃破カウント方式）。
------
_M.StackBuff = Action.define('StackBuff', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    local addN = a.stacks or (e ~= nil and e.stacks) or 1
    applyStacks(a, unit:getTeamUnitCondition(), addN, resolveValue(a.value, d, e), resolveValue(a.time, d, e))
end)

------
-- FixedDamage — 固定ダメージ（軽減/無効化/庇い 無視）。直接 setHP で HP を削る。
--   rate    : 最大HPの割合（getCalcHPMAX * rate を減算）
--   amount  : 固定値（rate の代わり）。動的な value と同じく関数・{ base, perFloor } も可
--   target  : 対象（Targeting 等。既定 self ＝ボスなので通常は明示する）
--   side    : 'player'/'enemy' でチーム全員（target より優先）
--   canKill : false なら最低HP1で止める（既定 true ＝ 0で死亡）
------
_M.FixedDamage = Action.define('FixedDamage', function(a, d, e)
    local amount = resolveValue(a.amount, d, e)
    local function hit(u)
        if u == nil then return end
        local dmg = amount or (u:getCalcHPMAX() * (a.rate or 0))
        local newHP = u:getHP() - dmg
        if a.canKill == false and newHP < 1 then newHP = 1 end
        if newHP < 0 then newHP = 0 end
        u:setHP(math.floor(newHP))
    end
    if a.side ~= nil then
        local team = megast.Battle:getInstance():getTeam(a.side ~= 'enemy')
        for i = 0, 7 do hit(team:getTeamUnit(i)) end
    else
        hit(resolveTarget(a, d, e))
    end
end)

------
-- SpawnEnemy — 敵ユニットを召喚（空き枠へ addUnit、ホスト限定で engine が同期）
--   ⚠ 召喚する enemyID は boss Lua の1行目に `--@additionalEnemy,<id>,...` で宣言が必要
--     （ビルドのプリロード指示。Choreo 外の規約）。
--
-- 正準形（召喚テーブル）:
--   spawns table  { { enemy=, counts=, weight=, max=, hp= }, ... }
--   mode   string 'each'（既定: 全エントリを独立判定）/ 'pick'（weight で1エントリ抽選）/
--                 'cycle'（event.count で巡回＝交互召喚）
--   counts table  体数 => 重み。{ [0]=20, [1]=50, [2]=30 } で「なし20% / 1体50% / 2体30%」
--
-- 簡易記法（下の正準形へ展開される）:
--   enemy   = id                        … 1種類（従来どおり）
--   enemy   = { idA, idB }              … mode='cycle' 既定（交互召喚）
--   weights = { [idA]=70, [idB]=30 }    … mode='pick' 既定
--   count   = n | function(現在数)->n   … counts 未指定時の体数
--   chance  = 0..100                    … counts = { [0]=100-chance, [1]=chance } 相当
--
-- 共通引数:
--   max   : 対象 enemyID の**合計**上限（entry.max はその ID 単体の上限）
--   slots : 走査するチーム枠数（既定8。クエストの敵枠数に合わせる）
--   hp    : (任意) 召喚体の最大HP（数値 or function(召喚後の総数)。個数依存スケール）
--
-- @example 交互に1体ずつ（エクストラタイマーの onRound から。event.count は engine の周回数=1始まり）
--     ExtraTimer.Create{ key="A", maxTime=10, loopLimit=999,
--                        onRound = { SpawnEnemy{ enemy = { 4000801, 4000802 } } } }
-- @example ID ごとに体数分布を持たせ、各IDを独立判定（合計0〜4体）
--     SpawnEnemy{ spawns = {
--         { enemy = 4000801, counts = { [0]=20, [1]=50, [2]=30 } },
--         { enemy = 4000802, counts = { [0]=40, [1]=40, [2]=20 } },
--     } }
--
-- ⚠ 抽選はホストのみで走る（先頭で isHostPlayer を見て return）。実体は engine が同期するため
--    Sync/hostDecide は不要（Chance Action と違い、ここでは配信経路を作らない）。
-- ⚠ `max` は「対象 enemyID の数」で数える。ボス自身や無関係のユニットは数えない
--    （旧実装は占有枠を全部数えていたためボスが1体ぶん食っていた）。
-- ⚠ 抽選で決まった体数より空き枠 / max が少ない場合は**出せた分だけ**（切り捨て）。戻り値は実召喚数。
------

-- 簡易記法 → spawns の正規化。
-- weights はキー昇順に並べる（pairs 順に依存させない＝mode を cycle に上書きされても順序が安定する）。
local function normalizeSpawns(a)
    if a.spawns ~= nil then
        return a.spawns, a.mode or 'each'
    end
    local counts = a.counts
    if counts == nil and a.chance ~= nil then
        counts = { [0] = 100 - a.chance, [1] = a.chance }
    end
    if a.weights ~= nil then
        local ids = {}
        for id in pairs(a.weights) do ids[#ids + 1] = id end
        table.sort(ids)
        local list = {}
        for i = 1, #ids do
            list[i] = { enemy = ids[i], weight = a.weights[ids[i]], counts = counts }
        end
        return list, a.mode or 'pick'
    end
    if type(a.enemy) == 'table' then
        local list = {}
        for i = 1, #a.enemy do
            list[i] = { enemy = a.enemy[i], counts = counts }
        end
        return list, a.mode or 'cycle'
    end
    return { { enemy = a.enemy, counts = counts } }, a.mode or 'each'
end

-- 指定 enemyID 集合に一致するユニット数（max のカウント基準）
local function countEnemies(team, slots, ids)
    local n = 0
    for i = 0, slots - 1 do
        local u = team:getTeamUnit(i)
        if u ~= nil and ids[u:getEnemyID()] then n = n + 1 end
    end
    return n
end

-- そのエントリの召喚体数（counts があれば重み抽選 / 無ければ count）
local function resolveSpawnCount(entry, a, current)
    if entry.counts ~= nil then
        return Random.sampleWeighted(entry.counts) or 0
    end
    local n = entry.count or a.count or 1
    if type(n) == 'function' then n = n(current) end
    return n or 0
end

_M.SpawnEnemy = Action.define('SpawnEnemy', function(a, d, e)
    if not d.isHostPlayer then
        return                                  -- ホストのみ召喚（engine が同期）
    end
    local boss = (e ~= nil and e.unit) or d.unit
    local team = boss:getTeam()
    local slots = a.slots or 8
    local spawns, mode = normalizeSpawns(a)
    if #spawns == 0 then
        return 0
    end

    -- 対象 enemyID の集合（max のカウント基準）
    local targetIds = {}
    for i = 1, #spawns do targetIds[spawns[i].enemy] = true end

    -- 実行するエントリを決める
    local order = {}
    if mode == 'cycle' then
        local round = (e ~= nil and e.count) or 1        -- extraTimerOneRound の周回数（1始まり）
        order[1] = spawns[(round - 1) % #spawns + 1]
    elseif mode == 'pick' then
        local weights = {}
        for i = 1, #spawns do weights[i] = spawns[i].weight or 1 end
        local index = Random.sampleWeighted(weights)
        if index ~= nil then order[1] = spawns[index] end
    else
        for i = 1, #spawns do order[i] = spawns[i] end   -- each: 全エントリを独立判定
    end

    local total = countEnemies(team, slots, targetIds)
    local spawned = 0
    for k = 1, #order do
        local entry = order[k]
        local n = resolveSpawnCount(entry, a, total)
        if entry.max ~= nil then                          -- その ID 単体の上限
            local own = countEnemies(team, slots, { [entry.enemy] = true })
            if own + n > entry.max then n = entry.max - own end
        end
        if a.max ~= nil and total + n > a.max then        -- 対象 ID 合計の上限
            n = a.max - total
        end
        local placed = 0
        for i = 0, slots - 1 do
            if placed >= n then break end
            if team:getTeamUnit(i) == nil then
                local u = team:addUnit(i, entry.enemy)
                placed = placed + 1
                total = total + 1
                spawned = spawned + 1
                local hp = entry.hp or a.hp
                if hp ~= nil and u ~= nil then
                    if type(hp) == 'function' then hp = hp(total) end
                    u:setBaseHP(hp)
                    u:setHP(hp)
                end
            end
        end
    end
    return spawned
end)

------
-- 10b. Burst — バースト（奥義）状態切替
------
_M.Burst = Action.define('Burst', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    local active = a.active
    if active == nil then active = true end
    unit:setBurstState(active and kBurstState_active or kBurstState_none)
end)

------
-- SetSkin — spine スキン切替（TeamUnit::setSkin ＝ setSkinName + Skeleton::setSkin）
--   ボスによっては **spine 既定スキンが本体の一部しか出さない**ため、開幕に正しいスキンを
--   当てないと見た目が欠ける（例: ベルギラス種は setSkin("normal") 必須。enemy/ の実装に
--   「ベルギラスはこのメソッドを使用しないと全身が表示されない」というコメントが残っている）。
--   怒り形態への切替（"rage"）にも使う。
--   name  : スキン名（spine の skins に実在する名前。位置引数可）
--   target: 対象（既定 self＝ボス）
--   出典: enemy/ 154ファイル（"normal" / "rage" / "1" / "2" 等）。
--   ⚠ spine に無いスキン名を渡すと該当パーツが一切描かれない（Skeleton::setSkin は失敗しても無言）。
--   同期不要（全端末で同じ見た目にする決定的処理）。
------
_M.SetSkin = Action.define('SetSkin', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    unit:setSkin(a.name or a[1])
end)

------
-- Scale — スケルトンのサイズ拡縮（任意タイミング）。
--   旧 Component（開幕 start 固定）を Action 化。Start / Phases / Timeline 等の actions に置けば
--   任意タイミングで getSkeleton():setScaleX/Y を呼べる。
--   value : スケール倍率（既定1.0＝等倍）
--   flip  : 向き（既定 nil＝現在の向きを自動検出して保持。左右反転ボスは現状の符号を維持）
--   target: 対象（既定 self＝ボス）
--   出典: 実ボス慣用（start 内 event.unit:getSkeleton():setScale(1.5) ―― サイズ拡縮）。
------
_M.Scale = Action.define('Scale', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    local skeleton = unit:getSkeleton()
    local value = a.value or 1.0
    local flip = a.flip or (skeleton:getScaleX() < 0 and -1 or 1)
    skeleton:setScaleX(flip * value)
    skeleton:setScaleY(value)
end)

------
-- SetHPBarHeightOffset — HPバーの表示位置を縦にずらす（TeamUnit::setHPBarHeightOffset）
--   engine の updateHPBar が毎フレーム「HPバー基準位置 + offset」に置くので、一度設定すれば次の設定まで持続する。
--   Start に置けば開幕の高さ調整、Phases / Timeline 等に置けば任意タイミングで隠す／戻す。
--   value : 縦オフセット（px・正で上。位置引数可。既定0＝基準位置へ戻す）。C++ 側で int に切り捨て。
--   target: 対象（既定 self＝ボス）
--   出典: 実ボス慣用（start 内 event.unit:setHPBarHeightOffset(n)。enemy/ unit/ 38箇所）。
--     10000 = 画面外へ飛ばして HP バーを隠す定型（2059745 等）／250 = GB ボスの高さ調整（gb_401602 等）。
--     途中で戻す例: 2037806（退避中 10000 → 復帰で 10）。
--   同期不要（見た目のみ・全端末で同じ位置にする決定的処理）。
------
_M.SetHPBarHeightOffset = Action.define('SetHPBarHeightOffset', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    unit:setHPBarHeightOffset(a.value or a[1] or 0)
end)

------
-- SetBackgroundGrayScale / ResetBackgroundGrayScale — 背景LWFのグレースケール化
--   C++: Battle::setBackGroundGrayScale(rate) / resetBackGroundGrayScale()
--   rate: **0.0 = 完全グレースケール / 1.0 = 元の色**（Lua 仕様。C++ 側で u_desaturate = 1-rate に変換）
--   出典: unit/103617312.lua（奥義3で setBackGroundGrayScale(0)、奥義5で reset）。
--   ⚠ 背景 LWF を RenderTexture 経由で描き替える演出。ボスの見た目ではなくステージ全体に効く。
--   ⚠ 出したら必ず戻す（reset を呼ばないとクエスト終了まで灰色のまま）。
--   同期不要（見た目のみ・全端末で同じ演出になる決定的処理）。
------
_M.SetBackgroundGrayScale = Action.define('SetBackgroundGrayScale', function(a, d, e)
    local rate = a.rate or a.value or a[1] or 0
    megast.Battle:getInstance():setBackGroundGrayScale(rate)
end)

_M.ResetBackgroundGrayScale = Action.define('ResetBackgroundGrayScale', function(a, d, e)
    megast.Battle:getInstance():resetBackGroundGrayScale()
end)

------
-- After — seconds 秒後に actions を実行（例: HPトリガーで idle 1秒待ってから奥義）
--   After{ seconds = 1, actions = { UseSkill{ index = 4, cutin = Choreo.Cutin.TrueArts } } }
--   同期は呼び出し元に従う（Phases の actions なら全端末で同じ時刻に積まれる）。
------
local function runAfterQueue(d, e)
    local queue = d._afterQueue
    local dt = e.deltaTime or 0
    local i = 1
    while i <= #queue do
        local q = queue[i]
        q.left = q.left - dt
        if q.left <= 0 then
            table.remove(queue, i)
            Action.runActions(d, q.event, q.actions)
        else
            i = i + 1
        end
    end
end

_M.After = Action.define('After', function(a, d, e)
    if d._afterQueue == nil then
        d._afterQueue = {}
        d:addEventListener('update', runAfterQueue)
    end
    table.insert(d._afterQueue, { left = a.seconds or a[1] or 0, actions = a.actions, event = e })
end)

------
-- IfUseCount — onUse で、そのスキル/奥義の使用回数が count のときだけ actions を実行する
--   （「奥義3初回発動時だけ INFO」等）。
--   count   : 回数（数値）またはその配列（位置引数可）。onUse の event.useCount（その index の通算・
--             今回を含む・1始まり）と比べる
--   actions : 実行する Action 列
--   ⚠ Attack / Smash の onUse の中で使う。event.useCount が無い場所では何もしない。
--   同期は呼び出し元に従う（onUse は全端末の pass2 で走り、回数も全端末で同じ）。
--   中の Chance は Selector が initialize で事前登録する（Action.preregisterChances が辿る）。
--
-- @example 奥義3の初回だけ説明の INFO を出す
--     Smash{ sets = { {3}, {4} }, onUse = { [3] = {
--         IfUseCount{ count = 1, actions = { Say{ text = "封圧：封印効果に加え、効果中装備CTダウン" } } },
--     } } }
------
_M.IfUseCount = Action.define('IfUseCount', function(a, d, e)
    local uses = e ~= nil and e.useCount or nil
    if uses == nil then
        return
    end
    local want = a.count or a[1]
    local hit = false
    if type(want) == 'table' then
        for i = 1, #want do
            if want[i] == uses then
                hit = true
                break
            end
        end
    else
        hit = (want == uses)
    end
    if hit then
        Action.runActions(d, e, a.actions)
    end
end)

_G.package.loaded[_NAME] = _M
return _M
