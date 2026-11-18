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

local resolveTarget = Action.resolveTarget

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
-- 1. AttachBuff — バフ/デバフ付与（addCondition + group/priority + script）
------
_M.AttachBuff = Action.define('AttachBuff', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    local cond = unit:getTeamUnitCondition()

    -- group 規約: 省略時 = 効果タイプ（同種=同グループ）/ priority 省略時 = value（強い方が勝つ）。
    -- 重複あり（並存）にしたい場合のみ group=-1 を明示。
    local group = a.group
    if group == nil then group = a.type end
    local priority = a.priority
    if priority == nil then priority = a.value or 0 end

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

    local script = a.script
    return Buff{
        id = a.id,
        type = a.type,
        value = a.value,
        time = a.time or 99999,
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
    }:attach(unit)
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
------
_M.ResetHate = Action.define('ResetHate', function(a, d, e)
    -- HateTarget は累計を Lua 側（dispatcher._hateTotals）で持つのでそれをクリアする。
    -- ⚠ engine の updateHateTarget() は呼ばない（毎フレーム呼んだ際に実機クラッシュ signal 11 を確認）。
    --    resetHate() は _HateList を clear するだけなので engine 側も併せてクリアしておく。
    local unit = resolveTarget(a, d, e)
    unit:resetHate()
    if d._hateTotals ~= nil then
        d._hateTotals = {}
        d._hateSentIndex = nil   -- 次の update で首位を再判定・再配信させる
    end
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
-- 7. SpawnOrbit — 弾/分離体生成
------
_M.SpawnOrbit = Action.define('SpawnOrbit', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    local orbit
    if a.file ~= nil then
        orbit = unit:addOrbitSystemWithFile(a.file, a.anim)
    else
        orbit = unit:addOrbitSystem(a.anim, a.type or 0)
    end

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
local function applyStacks(a, cond, addN)
    local existing = cond:findConditionWithID(a.id)
    local old = (existing ~= nil and existing:getNumber()) or 0
    local count = old + addN
    if a.max ~= nil and count > a.max then
        count = a.max
    end
    local value = (a.value or 0) * count
    local c
    if a.effect ~= nil then
        c = cond:addCondition(a.id, a.type, value, a.time or 99999, a.icon or 0, a.effect)
    else
        c = cond:addCondition(a.id, a.type, value, a.time or 99999, a.icon or 0)
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
                applyStacks(a, u:getTeamUnitCondition(), #units)
            end
            return  -- 被庇護側には付与しない
        end
    end

    -- 通常: 全員 +1
    for _, u in ipairs(units) do
        applyStacks(a, u:getTeamUnitCondition(), 1)
    end
end)

------
-- StackBuff — 単体（既定 self）へスタックするバフを付与（アイコンに数値・MAX上限）。
--   StackDebuff の単体対象版。出典: 実ボス慣用（2000694 憂月: extraTimerOneRound ごとに
--   execAddBuff で自身へ与ダメUP を ID 固定でスタック、setNumber でアイコン数値）。
--   引数: id, type, value, max, icon, time, effect, target（既定 self）
------
_M.StackBuff = Action.define('StackBuff', function(a, d, e)
    local unit = resolveTarget(a, d, e)
    applyStacks(a, unit:getTeamUnitCondition(), 1)
end)

------
-- FixedDamage — 固定ダメージ（軽減/無効化/庇い 無視）。直接 setHP で HP を削る。
--   rate    : 最大HPの割合（getCalcHPMAX * rate を減算）
--   amount  : 固定値（rate の代わり）
--   target  : 対象（Targeting 等。既定 self ＝ボスなので通常は明示する）
--   side    : 'player'/'enemy' でチーム全員（target より優先）
--   canKill : false なら最低HP1で止める（既定 true ＝ 0で死亡）
------
_M.FixedDamage = Action.define('FixedDamage', function(a, d, e)
    local function hit(u)
        if u == nil then return end
        local dmg = a.amount or (u:getCalcHPMAX() * (a.rate or 0))
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
--   enemy : 召喚する enemyID
--   count : 召喚数（数値 or function(現在の敵数)->n。確率判定もここで）
--   max   : チーム上限（既定: 空き枠まで）
--   slots : 走査するチーム枠数（既定8。クエストの敵枠数に合わせる）
--   hp    : (任意) 召喚体の最大HP（数値 or function(召喚後の総数)。個数依存スケール）
------
_M.SpawnEnemy = Action.define('SpawnEnemy', function(a, d, e)
    if not d.isHostPlayer then
        return                                  -- ホストのみ召喚（engine が同期）
    end
    local boss = (e ~= nil and e.unit) or d.unit
    local team = boss:getTeam()
    local slots = a.slots or 8

    -- 現在の敵数をカウント
    local current = 0
    for i = 0, slots - 1 do
        if team:getTeamUnit(i) ~= nil then current = current + 1 end
    end

    -- 召喚数（function なら現在の敵数を渡す＝確率/敵数条件）
    local n = a.count or 1
    if type(n) == 'function' then n = n(current) end

    local spawned = 0
    for i = 0, slots - 1 do
        if spawned >= n then break end
        if a.max ~= nil and current >= a.max then break end
        if team:getTeamUnit(i) == nil then
            local u = team:addUnit(i, a.enemy)
            current = current + 1
            spawned = spawned + 1
            if a.hp ~= nil and u ~= nil then
                local hp = a.hp
                if type(hp) == 'function' then hp = hp(current) end
                u:setBaseHP(hp)
                u:setHP(hp)
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

_G.package.loaded[_NAME] = _M
return _M
