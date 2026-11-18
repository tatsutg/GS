----------------------------------------------------------------------
-- boss_skill_warning_model.lua
-- 【MEGA_D-9762】ボスの技の予告（ダメージ予測）のための模型。
--
-- ■ これは何か
--   アプリは、バトルの Lua とは別の Lua（予測専用の lua_State）に、skill_effect.lua とこのファイルを読み込む。
--   予測で Lua の条件（skill_effect_master の script_id が 0 でない効果）の値が要るときは、
--   本物のユニット・条件の代わりに、この模型（アプリが写した値）を渡して、skill_effect.lua の id_<番号> をそのまま呼ぶ。
--   バトルの Lua・本物のユニットには触れないので、バトルには影響しない。
--
-- ■ 決まり
--   ・ここで本物のバトルに届く口（megast.* の本物・tolua）は使えない。予測専用の Lua には登録されていない。
--   ・模型に無いメソッドを呼ぶと、Lua のエラーにする（__index）。アプリはエラーを受けて、その条件を「危ない向き」の扱いにする。
--     新しい script が新しいメソッドを使うときは、ここに足す（アプリが写している値で答えられるなら、アプリの更新は要らない）。
--   ・set* は模型の中の値を変えるだけ。1 回の評価（BSW.eval）が終わったら元に戻す。
--   ・バトルの Lua と違い、ゴミ集めはアプリが止めている。評価のたびにテーブルを作らないこと（模型は使い回す）。
--
-- ■ アプリとの約束（アプリが入れるもの）
--   BSW.units[uid] = {
--     race, element, baseID3, hp, baseHP, isPlayer, isPvpPlayer, isBoss, isLeader, level, index, unitState,
--     breakPoint, baseBreakCapacity, burstPoint, burstState, needSP, size, sexuality, isBreak,
--     parent = 親の uid（無ければ nil）, teamIsPlayer,
--     calcAttack, calcDefence, calcPower（無ければ nil。nil のときに読む script はエラー＝危ない向きの扱い）,
--     skill = { skillType, index, burst2, burst3, phantomAny } または nil,
--     items = { [0..2] = 装備の技の元のアイテムの番号（無ければ nil） },
--     info = { skillAttribute, skillElementType, skillType, critical, superCritical, other = uid, caster = uid } または nil,
--     conds = { { type, id, group, script, value, v1, v2, v3, v4, v5, time, timeMax, passive, priority, number }, ... },
--   }
--   BSW.teams[true / false] = { indexMax, boss = uid, units = { [index] = uid } }   -- true がプレイヤーのチーム
--   BSW.battle = { isPvp, isRaid, isArena, isGrandBattle, isGrandBattleExBoss, isCrossBattle, isMultiPlay,
--                  mineFloor, grandBattleFloor, waveNum, waveMax, time, battleState, boss = uid }
--   評価: BSW.eval(holderUid, condIndex) → 値（Lua のエラーはそのまま上げる。アプリが pcall で受ける）
--
-- 設計: cocos-megast の claudedocs/battle/boss-skill-warning-refresh/design.md
----------------------------------------------------------------------

BSW = BSW or {}
BSW.units = BSW.units or {}
BSW.teams = BSW.teams or {}
BSW.battle = BSW.battle or {}

local MAX_DEPTH = 4            -- findConditionValue の入れ子の上限
local depth = 0
local touched = {}             -- 1 回の評価で set* された条件（終わったら戻す）
local NIL = {}                 -- 戻すときの「元は無かった」の印

local function strict(name)
    return function(_, key)
        error("BSW: model has no method " .. name .. ":" .. tostring(key), 2)
    end
end

----------------------------------------------------------------------
-- 条件
----------------------------------------------------------------------
local CondMT = {}
local condCache = setmetatable({}, {__mode = "k"})

local function condOf(data)
    if data == nil then return nil end
    local c = condCache[data]
    if not c then
        c = setmetatable({_d = data}, CondMT)
        condCache[data] = c
    end
    return c
end

local function set(self, key, value)
    local d = self._d
    if d._saved == nil then
        d._saved = {}
        touched[#touched + 1] = d
    end
    if d._saved[key] == nil then
        if d[key] == nil then d._saved[key] = NIL else d._saved[key] = d[key] end
    end
    d[key] = value
end

local CondMethods = {
    getValue = function(self) return self._d.value end,
    getValue1 = function(self) return self._d.v1 end,
    getValue2 = function(self) return self._d.v2 end,
    getValue3 = function(self) return self._d.v3 end,
    getValue4 = function(self) return self._d.v4 end,
    getValue5 = function(self) return self._d.v5 end,
    getTime = function(self) return self._d.time end,
    getTimeMax = function(self) return self._d.timeMax end,
    getID = function(self) return self._d.id end,
    getGroupID = function(self) return self._d.group end,
    getScriptID = function(self) return self._d.script end,
    getPriority = function(self) return self._d.priority end,
    getNumber = function(self) return self._d.number end,
    getIsPassive = function(self) return self._d.passive end,
    getConditionTypeAsInt = function(self) return self._d.type end,
    getConditionType = function(self) return self._d.type end,
    -- 【MEGA_D-9763】庇う（PROTECT / PROTECT_FIX）の相手の番号（Condition::getProtectTarget）。アプリが写していなければ nil
    getProtectTarget = function(self) return self._d.protectTarget end,
    setValue = function(self, v) set(self, "value", v) end,
    setValue1 = function(self, v) set(self, "v1", v) end,
    setValue2 = function(self, v) set(self, "v2", v) end,
    setValue3 = function(self, v) set(self, "v3", v) end,
    setValue4 = function(self, v) set(self, "v4", v) end,
    setValue5 = function(self, v) set(self, "v5", v) end,
    setTime = function(self, v) set(self, "time", v) end,
    setID = function(self, v) set(self, "id", v) end,
    setGroupID = function(self, v) set(self, "group", v) end,
    setScriptID = function(self, v) set(self, "script", v) end,
    setPriority = function(self, v) set(self, "priority", v) end,
    setNumber = function(self, v) set(self, "number", v) end,
    setIsPassive = function(self, v) set(self, "passive", v) end,
    -- 予測に関係しない見た目・後始末の印（本物では残り時間のリセットなどに効く）。値は変えない
    setRemoveOnResetState = function(self, v) end,
    setThumbnailID = function(self, v) end,
}
CondMT.__index = function(self, key)
    local m = CondMethods[key]
    if m then return m end
    strict("Condition")(self, key)
end

-- 【MEGA_D-9763】Lua の中で付ける条件（id_274 の addCondition など）の受け皿。予測では付けない（本物の状態を変えない・模型の一覧にも入れない）。
-- 読めば付けたときの値を返し、書いても何も起きない
local PlannedCondMT = {}
PlannedCondMT.__index = function(self, key)
    if type(key) == "string" and key:sub(1, 3) == "set" then return function() end end
    local m = CondMethods[key]
    if m then return m end
    strict("Condition")(self, key)
end
local function plannedCond(id, condType, value, time)
    return setmetatable({_d = {id = id, type = condType, value = value, time = time, timeMax = time,
                               v1 = 0, v2 = 0, v3 = 0, v4 = 0, v5 = 0, script = 0, group = 0, priority = 0, number = 0, passive = false}}, PlannedCondMT)
end

----------------------------------------------------------------------
-- ユニット・条件の一覧・技・チーム・バトル
----------------------------------------------------------------------
local UnitMT, ListMT, SkillMT, TeamMT, BattleMT, ItemMT = {}, {}, {}, {}, {}, {}
-- 装備の技と、そのアイテム（同じ模型で両方に答える: item:getBattleItem():getBaseItemNo()）
local ItemMethods = {
    getBattleItem = function(self) return self end,
    getBaseItemNo = function(self) return self._no end,
}
ItemMT.__index = function(self, key)
    local m = ItemMethods[key]
    if m then return m end
    error("BSW: model has no method BattleItem:" .. tostring(key), 2)
end
local unitCache = {}

local function unitOf(uid)
    if uid == nil then return nil end
    local d = BSW.units[uid]
    if d == nil then return nil end
    local u = unitCache[uid]
    if not u or u._d ~= d then
        u = setmetatable({_uid = uid, _d = d}, UnitMT)
        unitCache[uid] = u
    end
    return u
end

local evalCond   -- 下で定義

local ListMethods = {
    getDamageAffectInfo = function(self)
        local info = self._u._d.info
        if info == nil then error("BSW: no DamageAffectInfo for unit " .. tostring(self._u._uid), 2) end
        return info
    end,
    findConditionWithType = function(self, t)
        for _, c in ipairs(self._u._d.conds) do if c.type == t then return condOf(c) end end
        return nil
    end,
    findConditionWithID = function(self, id)
        for _, c in ipairs(self._u._d.conds) do if c.id == id then return condOf(c) end end
        return nil
    end,
    findConditionWithGroupID = function(self, g)
        for _, c in ipairs(self._u._d.conds) do if c.group == g then return condOf(c) end end
        return nil
    end,
    -- 【MEGA_D-9763】本物は条件を付ける（効くときの関数の中で付ける script: 274 など）。予測では付けず、受け皿だけ返す
    addCondition = function(self, id, condType, value, time) return plannedCond(id, condType, value, time) end,
    getAllConditionsSize = function(self) return #self._u._d.conds end,
    getAllConditionsAt = function(self, i) return condOf(self._u._d.conds[i + 1]) end,
    -- TeamUnitCondition::findConditionValue（TeamUnitCondition.cpp:1226）と同じく、同じ種類の条件の値を足す。Lua の条件は id_<番号> を模型で呼ぶ
    findConditionValue = function(self, t, defaultValue)
        local value = defaultValue or 0
        for i, c in ipairs(self._u._d.conds) do
            if c.type == t then
                if c.script ~= 0 then
                    value = value + evalCond(self._u._uid, i)
                else
                    value = value + c.value
                end
            end
        end
        return value
    end,
}
ListMT.__index = function(self, key)
    local m = ListMethods[key]
    if m then return m end
    strict("TeamUnitCondition")(self, key)
end

local SkillMethods = {
    getSkillType = function(self) return self._s.skillType end,
    getIndex = function(self) return self._s.index end,
    isBurst2 = function(self) return self._s.burst2 end,
    isBurst3 = function(self) return self._s.burst3 end,
    isPhantomBulletAny = function(self) return self._s.phantomAny end,
}
SkillMT.__index = function(self, key)
    local m = SkillMethods[key]
    if m then return m end
    strict("BattleSkill")(self, key)
end

local teamCache = {}
local function teamOf(isPlayer)
    local t = BSW.teams[isPlayer]
    if t == nil then return nil end
    local m = teamCache[isPlayer]
    if not m then
        m = setmetatable({}, TeamMT)
        teamCache[isPlayer] = m
    end
    m._t = t
    return m
end
local TeamMethods = {
    getIndexMax = function(self) return self._t.indexMax end,
    getTeamUnit = function(self, i) return unitOf(self._t.units[i]) end,
    getBoss = function(self) return unitOf(self._t.boss) end,
}
TeamMT.__index = function(self, key)
    local m = TeamMethods[key]
    if m then return m end
    strict("Team")(self, key)
end

-- C++ の float（32 ビット）に丸める（仮数 24 ビット・同じ距離なら偶数のほう＝IEEE と同じ。割合・最大 HP の境目で本物とそろえるため）
local function f32(x)
    if x == 0 or x ~= x or x == math.huge or x == -math.huge then return x end
    local m, e = math.frexp(x)
    local r = m * 16777216
    local fl = math.floor(r)
    local diff = r - fl
    if diff > 0.5 or (diff == 0.5 and fl % 2 == 1) then fl = fl + 1 end
    return math.ldexp(fl / 16777216, e)
end

-- C++ の int64_t への代入と同じく、0 の向きに切り捨てる
local function trunc(x)
    if x >= 0 then return math.floor(x) end
    return math.ceil(x)
end

-- TeamUnit::getCalcHPMAX（TeamUnit.cpp:2337）と同じ式。条件の値は findConditionValue（Lua の条件は id_<番号>）で足す。
-- アリーナ・PvP の倍率は写さない（予告を出さない）
-- 本物は float で計算する（int64 + float、int64 *= float）ので、途中を f32 で丸める（倍精度のままだと最大 HP が 1 ずれることがある）
local function calcHPMaxOf(unit)
    local list = unit:getTeamUnitCondition()
    local value = unit._d.baseHP or 0
    value = trunc(f32(f32(value) + f32(list:findConditionValue(1))))                    -- HPMAX_FLAT
    value = trunc(f32(f32(value) * f32(1.0 + f32(f32(list:findConditionValue(2)) / 100))))  -- HPMAX_PERCENT
    local rate = f32(f32(list:findConditionValue(233)) / 100)                           -- SEQUELAE_PARALYZE
    if rate > 0 then
        value = trunc(f32(f32(value) * f32(1.0 - rate)))
    end
    if value < 1 then value = 1 end
    return value
end

local UnitMethods = {
    getRaceType = function(self) return self._d.race end,
    getElementType = function(self) return self._d.element end,
    getBaseID3 = function(self) return self._d.baseID3 end,
    getHP = function(self) return self._d.hp end,
    getCalcHPMAX = function(self) return calcHPMaxOf(self) end,
    -- TeamUnit::getHPPercent（TeamUnit.cpp:2359）と同じく割合（0〜1）。百分率ではない（script 側で * 100 する）
    getHPPercent = function(self)
        local max = calcHPMaxOf(self)
        if max == nil or max <= 0 then return 0 end
        -- 本物は (float)getHP() / (float)getCalcHPMAX()。32 ビットで割らないと、境目（例: 40%）で本物と逆になることがある（T2 で 1 回）
        local per = f32(f32(self._d.hp) / f32(max))
        if per < 0 then per = 0 end
        return per
    end,
    getisPlayer = function(self) return self._d.isPlayer end,
    getisPvpPlayer = function(self) return self._d.isPvpPlayer end,
    getIsBoss = function(self) return self._d.isBoss end,
    getIsLeader = function(self) return self._d.isLeader end,
    getLevel = function(self) return self._d.level end,
    getIndex = function(self) return self._d.index end,
    getUnitState = function(self) return self._d.unitState end,
    getBreakPoint = function(self) return self._d.breakPoint end,
    getBaseBreakCapacity = function(self) return self._d.baseBreakCapacity end,
    getBurstPoint = function(self) return self._d.burstPoint end,
    getBurstState = function(self) return self._d.burstState end,
    getNeedSP = function(self) return self._d.needSP end,
    getSize = function(self) return self._d.size end,
    getSexuality = function(self) return self._d.sexuality end,
    isBreak = function(self) return self._d.isBreak end,
    getParentTeamUnit = function(self) return unitOf(self._d.parent) end,
    getActiveBattleSkill = function(self)
        local s = self._d.skill
        if s == nil then return nil end
        local m = rawget(self, "_skill")
        if not m then
            m = setmetatable({}, SkillMT)
            rawset(self, "_skill", m)
        end
        m._s = s
        return m
    end,
    -- 装備の技。予測に要るのは元のアイテムの番号だけ（findBaseWeaponId が item:getBattleItem():getBaseItemNo() を読む）
    getItemSkill = function(self, slot)
        local items = self._d.items
        local no = items and items[slot]
        if no == nil then return nil end
        local cache = rawget(self, "_items")
        if not cache then
            cache = {}
            rawset(self, "_items", cache)
        end
        local m = cache[slot]
        if not m then
            m = setmetatable({}, ItemMT)
            cache[slot] = m
        end
        m._no = no
        return m
    end,
    getTeamUnitCondition = function(self)
        local m = rawget(self, "_list")
        if not m then
            m = setmetatable({_u = self}, ListMT)
            rawset(self, "_list", m)
        end
        return m
    end,
    getTeam = function(self) return teamOf(self._d.teamIsPlayer) end,
    getCalcAttack = function(self) return self._d.calcAttack or error("BSW: no calcAttack", 2) end,
    getCalcDefence = function(self) return self._d.calcDefence or error("BSW: no calcDefence", 2) end,
    getCalcPower = function(self) return self._d.calcPower or error("BSW: no calcPower", 2) end,
    -- SP はダメージに関係しない（本物では SP が増える）。予測では何もしない
    addSP = function(self) end,
    addSPWithPvpCorrection = function(self) end,
}
UnitMT.__index = function(self, key)
    local m = UnitMethods[key]
    if m then return m end
    strict("TeamUnit")(self, key)
end

local BattleMethods = {
    getInstance = function(self) return self end,
    isPvp = function(self) return BSW.battle.isPvp end,
    isRaid = function(self) return BSW.battle.isRaid end,
    isArena = function(self) return BSW.battle.isArena end,
    getBattleState = function(self) return BSW.battle.battleState end,
    getBoss = function(self) return unitOf(BSW.battle.boss) end,
    getTeam = function(self, isPlayer) return teamOf(isPlayer) end,
    getEnemyTeam = function(self) return teamOf(false) end,
    isGrandBattle = function(self) return BSW.battle.isGrandBattle end,
    isGrandBattleExBoss = function(self) return BSW.battle.isGrandBattleExBoss end,
    isCrossBattle = function(self) return BSW.battle.isCrossBattle end,
    isMultiPlay = function(self) return BSW.battle.isMultiPlay end,
    getCurrentMineFloor = function(self) return BSW.battle.mineFloor end,
    getCurrentGrandBattleFloor = function(self) return BSW.battle.grandBattleFloor end,
    getWaveNum = function(self) return BSW.battle.waveNum end,
    getWaveMax = function(self) return BSW.battle.waveMax end,
    -- PvP では予告を出さない。PvP 以外の補正は 1（Battle::getPvpCorrectionValue）
    getPvpCorrectionValue = function(self, conditionType, value)
        if BSW.battle.isPvp then error("BSW: pvp correction is not modeled", 2) end
        return value
    end,
}
BattleMT.__index = function(self, key)
    local m = BattleMethods[key]
    if m then return m end
    strict("Battle")(self, key)
end

-- バトルの Lua ではアプリ（tolua_constant）が登録する定数。予測専用の Lua には無いので、同じ値で置く（無いと nil のまま比べ、エラーにならずに値がずれる）
-- 値は C++ の enum（Team/UnitState.h・Battle/types/MegastTypes.h・Battle/Battle.h）。skill_effect.lua が使うのはこの 9 つ（2026-10-31）
kUnitState_attack = 3
kUnitState_skill = 4
kBurstState_active = 1
kElementType_Fire = 1
kElementType_Aqua = 2
kElementType_Earth = 3
kElementType_Light = 4
kElementType_Dark = 5
kBattleState_active = 2

-- 予測専用の Lua には本物の megast が無い。skill_effect.lua が使う分だけを模型で置く
megast = setmetatable({Battle = setmetatable({}, BattleMT)}, {__index = strict("megast")})
summoner = setmetatable({}, {__index = strict("summoner")})
-- BattleControl:get():getTime()（バトルの経過時間。時間で効果が育つ script が読む）
local ControlMT = {__index = function(self, key)
    if key == "get" then return function(c) return c end end
    if key == "getTime" then return function() return BSW.battle.time end end
    strict("BattleControl")(self, key)
end}
BattleControl = setmetatable({}, ControlMT)

----------------------------------------------------------------------
-- 評価
----------------------------------------------------------------------
evalCond = function(holderUid, condIndex)
    local d = BSW.units[holderUid]
    local c = d and d.conds[condIndex]
    if c == nil then error("BSW: no condition " .. tostring(condIndex), 2) end
    local f = _G["id_" .. c.script]
    -- 本物でも id_<番号> が無いと Lua のエラーになり、runScript は -1 を返す（BattleUtilities.cpp の runScript）。同じ値にする
    if f == nil then return -1 end
    if depth >= MAX_DEPTH then error("BSW: too deep", 2) end
    depth = depth + 1
    local holder = unitOf(holderUid)
    local info = d.info
    local other = info and unitOf(info.other) or nil
    -- TeamUnitCondition::runSkillEffectScript（TeamUnitCondition.cpp:1138）と同じ引数
    local ok, v = pcall(f, holder, other, condOf(c), c.value, c.v1, c.v2, c.v3, c.v4, c.v5, nil)
    depth = depth - 1
    if not ok then error(v, 0) end
    if type(v) ~= "number" then error("BSW: id_" .. c.script .. " returned " .. type(v), 0) end
    return v
end

local function restore()
    for i = #touched, 1, -1 do
        local d = touched[i]
        for k, v in pairs(d._saved) do
            if v == NIL then d[k] = nil else d[k] = v end
        end
        d._saved = nil
        touched[i] = nil
    end
end

function BSW.eval(holderUid, condIndex)
    depth = 0
    local ok, v = pcall(evalCond, holderUid, condIndex)
    restore()
    if not ok then error(v, 0) end
    return v
end

-- 写した値を捨てる（ウェーブの切り替え・バトルの終わり）
function BSW.reset()
    BSW.units = {}
    BSW.teams = {}
    BSW.battle = {}
    unitCache = {}
    teamCache = {}
end
