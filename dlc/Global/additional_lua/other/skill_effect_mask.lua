----------------------------------------------------------------------
-- skill_effect_mask.lua
-- scriptId＋value値から「このバフが何であるか」を記述する共通データ（SEMANTICS）と、
-- その解釈器（現状はAI判定ビュー getConditionMask のみ）。
--
-- ■ このファイルの構成（上から順に）
--   1. EVAL_METHOD        … 旧方式(Lua実行)/新方式(マスク評価)の切替表【唯一の切替ポイント】
--   2. ヘルパ関数          … ビット演算等の道具（触る必要なし）
--   3. buff()ビルダー      … エントリを書くためのaddメソッドカタログ（語彙の一覧）
--   4. SCRIPT_ID[scriptId] = ...  … scriptIdごとの「事実」データ本体（追記はここ）
--   5. maskFromSemantics  … 事実→AIマスク変換（新しい事実キーを増やす時だけ触る）
--   6. 公開関数            … C++から呼ばれる入口（getConditionMask等。触る必要なし）
--
-- ■ 旧方式/新方式を切り替えたいとき（→ すぐ下の EVAL_METHOD へ）
--   ・発動時(battle)＝ダメージ計算・DoT等でのバフ効果量の評価。
--     "mask"=このファイルの事実からC++が計算 / "lua"=従来どおり skill_effect.lua の id_xxx を実行。
--   ・付与時(grant)＝addCondition時の「付与してよいか」判定。
--     "mask"=このファイルのgrant事実からC++が判定 / "lua"=従来どおりLuaの付与判定を実行。
--   ・scriptId単位で個別に上書きできる。書き方の例はEVAL_METHOD内のコメント参照。
--   ・反映方法: このファイル編集 → dat再生成（_WORK/lua/luac.command）→ 実機へ配置
--     （scripts/mask_parity/deploy_mask_dat.py）→ アプリ再起動。アプリの再ビルドは不要。
--
-- ■ 新しいscriptIdを追加する手順
--   ① skill_effect.lua の実体を読む（付与時 addCondition 分岐＋発動時 id_xxx の両方）
--   ② 下のSEMANTICSセクション「個別定義」に SCRIPT_ID[scriptId] を足す（scriptId昇順の位置へ）。
--      buff() に addメソッド（カタログ参照）を1機能1行でチェーンし、v1〜v5は V1〜V5 で参照する。
--      書式例1「自分のHPがv1%〜v2%のとき効く」:
--        SCRIPT_ID[9999] = buff():addHolderHpRange(V1, V2)
--      書式例2「クリティカル限定で、相手がv1状態のとき効く」:
--        SCRIPT_ID[9998] = buff()
--            :addAttackCritical()
--            :addEnemyCondition(V1)
--      書式例3「v2が1なら物理限定、v3が0でないときだけ経過時間ゲート」（値による分岐は結合子で書く）:
--        SCRIPT_ID[9997] = buff()
--            :when(V2, 1, buff():addAttackAttribute(1))
--            :whenNot(V3, 0, buff():addElapsedTimeMax(V3))
--      よく出る値の規約（0=不問、6=無属性、moveType等）は専用メソッドが吸収する:
--        SCRIPT_ID[9996] = buff():addAttackAttributeOpt(V4)   -- v4=0なら制限なし/1物理/2魔法
--      どうしても表現できないものだけ従来の関数形式で書く（最後のエスケープハッチ。関数がbuff()を返すのも可）
--   ③ scripts/mask_parity/check_mask.sh で自己チェック → dat再生成 → 配置
--
-- ■ 事実の名前空間（SCRIPT_ID[scriptId] が返すテーブルのキー）
--   ・SCRIPT_ID[scriptId] は skill_effect.lua の実体から写した「事実」の記述。
--     特定の消費者（AI/ダメージ計算/スマート編成）の解釈は入れない。
--     grant  = 付与時条件（付与対象target/発動者caster基準。付与された時点で通過済み）
--     holder = 発動時の保持者の状態条件
--     enemy  = 発動時の相手の条件
--     attack = 発動時の攻撃文脈条件（物魔/クリ/技属性/スキル種別ビット）
--     battle = バトル状態条件（アリーナ除外・経過時間）
--     scale  = 効果量スケール（状態で効果量が変わるもの）
--     effect = 冪等な自己フラグ副作用（RoR/パッシブ解除。バトル評価のみ適用・AI判定は不適用）
--     trigger= 効果量を持たない機構script（常に0を返す） / never = 常に不成立
--     sideEffect/approx/special/valueCalc/notes = 注記（解釈器は読まないが、
--       これが付いたscriptはgetBattleExactが自動でfalse＝発動時は旧方式のままになる）
-- ・AIビュー（getConditionMask）の解釈方針:
--     grantは読まない（Conditionが存在する＝付与時チェック通過済み）。
--     attackのスキル種別ビットは記録のみ（判定では「かかっていればUP」として通す）。
--     trigger/neverはどの判定クラスにも属さない扱い（skillAttribute=0）。
-- ・このファイルは純粋なデータ定義。ユニットやバトル状態を参照する関数・
--   副作用のある処理・require は書かないこと（付与時に1回評価されキャッシュされる）。
-- ・エントリを消すと、C++の実行禁止リスト該当以外は id_xxx 実行フォールバックになる。
--   sideEffect付きscript（8/42/228/238/260/423/473等）のエントリは絶対に消さないこと。
-- ・新しいscriptIdを追加したら、skill_effect.lua の実体と対でこの表にも事実を足すこと。
--   将来スマート編成/ダメージ計算を統合する場合は、同じSEMANTICSの上に別ビュー関数を足す。
----------------------------------------------------------------------

----------------------------------------------------------------------
-- EVAL_METHOD: 旧方式(lua)/新方式(mask)の切替表【ここが唯一の切替ポイント】
--   battle_default / grant_default … 個別指定がないscriptの既定
--   battle / grant … scriptId単位の個別上書き（既定と違う方式にしたいものだけ書く）
--   ※注記（sideEffect等）付きscriptは "mask" にしても発動時はLua実行のまま
--    （getBattleExactが注記を優先）。この表は「正確に評価できるもののON/OFF」のみ。
----------------------------------------------------------------------
local EVAL_METHOD = {
    battle_default = "lua",   -- 発動時の既定=旧方式(Lua実行)。単純・代表的なscriptのみ下のbattle{}で新方式にopt-in
    grant_default  = "lua",   -- 付与時の既定。安全側=旧方式。確認できたscriptから個別にmaskへ
    battle = {
        -- 実scriptIdの新方式適用は対応保留（MEGA_D-9403・2026-07-29ユーザー決定「後日にする」）。
        -- 再開時は確認できたIDからここに [id] = "mask" を足す（例: [2] = "mask"）
        [9999998] = "mask",            -- 稼働検知センチネル（テスト基盤・実マスタに存在しないID・luaに戻さないこと）
        [9999999] = "mask",            -- 実機テスト用センチネル（同上）
    },
    grant = {
        -- 個別上書きの例: [50] = "mask", -- scriptId 50 の付与判定を新方式にする
    },
}

local function methodFor(phase, scriptId)
    local o = EVAL_METHOD[phase] and EVAL_METHOD[phase][scriptId]
    if o then return o end
    return EVAL_METHOD[phase .. "_default"]
end

local FLAG_ALL = 255

-- C++ ConditionEffectMask::setBit と同義（tが1〜8以外なら何もしない）
local function setBit(flags, t, effective)
    if t == nil or t <= 0 or t > 8 then return flags end
    local bit = 2 ^ (t - 1)
    local has = math.floor(flags / bit) % 2 == 1
    if effective and not has then return flags + bit end
    if (not effective) and has then return flags - bit end
    return flags
end

-- C++ setAllExcept と同義（t以外の全ビットをeffectiveに）
local function allExcept(flags, t, effective)
    for i = 1, 8 do
        if i ~= t then flags = setBit(flags, i, effective) end
    end
    return flags
end

-- 「type tのみ有効」の定型（t=0や範囲外なら全ビット消灯。C++と同じ）
local function only(t)
    return allExcept(FLAG_ALL, t, false)
end

-- リストのtypeのみ有効（0や範囲外は無視）
local function includeBits(list)
    local f = allExcept(FLAG_ALL, 0, false)
    for _, t in ipairs(list) do f = setBit(f, t, true) end
    return f
end

-- リストのtypeのみ無効
local function excludeBits(list)
    local f = FLAG_ALL
    for _, t in ipairs(list) do f = setBit(f, t, false) end
    return f
end

-- C++ setBaseIds と同義（3桁×3のパック値）
local function baseIds(a, b, c)
    return (a or 0) + (b or 0) * 1000 + (c or 0) * 1000000
end

-- C++ setCategoryWithScriptValue と同義（0=制限なし 1:スキル 2:奥義系(2345) 7:真奥義 8:PB 9:超奥義 10:真or超）
local function categoryWithScriptValue(v)
    if v == 0 then return FLAG_ALL end
    local f = 0
    if v == 1 then f = setBit(f, 1, true)
    elseif v == 2 then
        f = setBit(f, 2, true); f = setBit(f, 3, true)
        f = setBit(f, 4, true); f = setBit(f, 5, true)
    elseif v == 7 then f = setBit(f, 3, true)
    elseif v == 8 then f = setBit(f, 5, true)
    elseif v == 9 then f = setBit(f, 4, true)
    elseif v == 10 then f = setBit(f, 3, true); f = setBit(f, 4, true)
    end
    return f
end

-- 奥義系統(2,3,4,5)のみ有効
local CATEGORY_BURST_ONLY = includeBits({2, 3, 4, 5})

-- ActiveBattleSkill基準の種別スイッチ（id_42/516系: 1スキル/2奥義系/7真奥義/8PB/9超奥義/10真or超）。
-- 該当なし値はLuaのif連鎖をすり抜けて「skillが存在すれば通る」になる挙動まで再現する
local function skillSwitchFacts(v)
    if v == 1 then return { sTypeBits = 2 ^ 1 } end
    if v == 2 then return { sTypeBits = 2 ^ 2 } end
    if v == 7 then return { skillFlag = 1 } end       -- isBurst2
    if v == 8 then return { skillFlag = 3 } end       -- isPhantomBulletAny
    if v == 9 then return { skillFlag = 2 } end       -- isBurst3
    if v == 10 then return { skillFlag = 4 } end      -- isBurst2 or isBurst3
    return { requireSkill = true }
end

-- DamageAffectInfo.skillType == v のゲート（id_14/236/2024系）。v=7は真奥義複合＝isBurst2かつtype2
local function dTypeEqFacts(v)
    if v == 7 then return { dTypeBits = 2 ^ 2, skillFlag = 1 } end
    return { dTypeBits = 2 ^ v }
end

-- 真奥義(3)orアルビオン(6)のDamageAffectInfo種別ゲート（id_59/152/202/452系）
-- DamageAffectInfo.skillType の 3=kSkillType_item(装備) / 6=kSkillType_summon(召喚)
local DTYPE_ITEM_SUMMON = 2 ^ 3 + 2 ^ 6
-- 装備/召喚を除く全種別（攻撃文脈なし=0も通す）
local DTYPE_EXCEPT_ITEM_SUMMON = 0xFFFF - 2 ^ 3 - 2 ^ 6

-- 効果量スケール（C++ eValueScale と同順・同値）
local VS = {
    NONE = 0,
    ENEMY_HP_RATE = 1,        -- 相手HP%がp1〜p2の範囲で0〜1スケール＋p3加算
    SELF_HP_FLAT_ADD = 2,     -- 生値＋保持者HP×p1/1000（上限p2）
    SELF_HP_RATE = 3,         -- 保持者HP%がp1〜p2の範囲で0〜1スケール
    CONDITION_VALUE_RATE = 4, -- 生値×(1＋保持者のコンディションtype p1の値/100)
    ALLY_RACE_COUNT = 5,      -- 生値×自チームの種族p1の数
    SELF_HP_STEP = 6,         -- floor(保持者HP%×p1×0.1)をp3〜p2にクランプした値に置換
    HP_MAX_PERCENT_ADD = 7,   -- (保持者HPMAX×p1% + p2)×rate（プレイヤー/アリーナ/PvPはrate=10。生値不使用・id_405）
    TIME_GROWTH = 8,          -- 生値＋p1×((経過時間/p2)^2)。経過時間=TimeMax-Time（id_601/602）
    HEALTH_RATE = 9,          -- 生値×(保持者HP/HPMAX)（id_293）
    HP_MAX_VALUE_PERCENT = 10,-- 保持者HPMAX×生値/100（id_389のv2=1）
    REFLECT_POWER = 11,       -- 生値＋攻撃者威力×p1/100（バトルのみ計算・AI判定は生値。id_154/244）
    ENEMY_TEAM_BURST_ADD = 12,-- 敵チームの誰かが奥義発動中なら生値+p1（id_395）
    HPMAX_DOT_GUARD = 13,     -- 瀕死ガード付き割合DoT（HPMAX×生値%×rate・死ぬならsetHP(1)で0。バトルのみ・AIは生値。id_228/260）
    GRANDBATTLE_DOT_GUARD = 14,-- グラバト階層依存DoT（(階層×p1%+p2%)×HPMAX・type129は瀕死ガード。バトルのみ・AIは生値。id_423）
    HOLDER_CONDITION_VALUE = 15,-- 生値不使用。保持者のコンディションtype p1 の実効値をそのまま効果量にする（id_171）
}

-- Lua側moveType（0=判定なし/1=物理/2=魔法/3=クリティカル/4以上=常に0）の事実定型
local function moveTypeFacts(v)
    if v == 1 then return { attack = { attribute = 1 } } end
    if v == 2 then return { attack = { attribute = 2 } } end
    if v == 3 then return { attack = { critical = true } } end
    if v == 0 then return {} end
    return { never = true }
end

---------------------------------------------------------------
-- buff()ビルダー: SCRIPT_IDエントリを「1機能1行」のaddチェーンで書く道具
--
--   SCRIPT_ID[87] = buff()
--       :addHolderBaseIds(V1)
--       :addHolderHpMax(V2)
--
-- ・v1〜v5の値は V1〜V5 プレースホルダで参照する（評価時に実値へ置換される）
-- ・値による条件分岐（if v3 == 1 など）が必要なscriptは、従来どおり
--   function(v1..v5) で書く（エスケープハッチ。関数がbuff()を返してもよい）
-- ・未定義のaddメソッドを呼ぶとロード時エラー＝typo即検出
-- ・addメソッド一覧（下のカタログ）が語彙のすべて。新しい事実キーを増やす時は
--   カタログに1行足し、maskFromSemantics にも対応を足すこと
---------------------------------------------------------------

-- v1〜v5プレースホルダ
local V1, V2, V3, V4, V5 = { __slot = 1 }, { __slot = 2 }, { __slot = 3 }, { __slot = 4 }, { __slot = 5 }

local BUFF_METHODS = {}
local BuffMeta = {
    __index = function(_, name)
        local m = BUFF_METHODS[name]
        if m == nil then
            error("buff(): 未定義のメソッド '" .. tostring(name) .. "'（addメソッドカタログを確認）", 2)
        end
        return m
    end,
}

local function buff()
    return setmetatable({ __isBuff = true, facts = {}, ops = {} }, BuffMeta)
end

-- 内部: facts[ns][key] = value して自身を返す（チェーン用）
local function nsSet(b, ns, key, value)
    if value ~= nil then
        local t = b.facts[ns]
        if t == nil then t = {}; b.facts[ns] = t end
        t[key] = value
    end
    return b
end
local function topSet(b, key, value)
    if value ~= nil then b.facts[key] = value end
    return b
end
-- 内部: 遅延op（評価時にv1〜v5の実値を見て事実を合成する関数）を積む
local function pushOp(b, op)
    b.ops[#b.ops + 1] = op
    return b
end
-- 内部: プレースホルダ or 直値 → 実値
local function slotValue(sel, vs)
    if type(sel) == "table" and sel.__slot then return vs[sel.__slot] end
    return sel
end

-- ==== addメソッドカタログ（1メソッド=1機能。b=ビルダー自身） ====
local B = BUFF_METHODS
-- 保持者（発動時の自分）の条件
function B:addHolderCondition(t1, t2) return nsSet(nsSet(self, "holder", "conditionType1", t1), "holder", "conditionType2", t2) end -- 自分がt1(or t2)状態のとき
function B:addHolderBadStatus() return nsSet(self, "holder", "badStatus", true) end                       -- 自分が状態異常のとき
function B:addHolderNoBadStatusExceptType(t) return nsSet(self, "holder", "noBadStatusExceptType", t) end -- t以外の状態異常を持たないとき
function B:addHolderHpMin(p) return nsSet(self, "holder", "hpMin", p) end                                 -- 自分HP%がp以上
function B:addHolderHpMax(p) return nsSet(self, "holder", "hpMax", p) end                                 -- 自分HP%がp以下
function B:addHolderHpRange(minP, maxP) return nsSet(nsSet(self, "holder", "hpMin", minP), "holder", "hpMax", maxP) end -- 自分HP%が範囲内
function B:addHolderHpMaxExclusive() return nsSet(self, "holder", "hpMaxExclusive", true) end             -- HP上限を「未満」にする
function B:addHolderElement(e) return nsSet(self, "holder", "element", e) end                             -- 自分の属性がe
function B:addHolderElementExclude(e) return nsSet(self, "holder", "elementExclude", e) end               -- 自分の属性がe以外
function B:addHolderElementNone() return nsSet(self, "holder", "elementNone", true) end                   -- 自分が無属性
function B:addHolderRace(...) return nsSet(self, "holder", "race", { ... }) end                           -- 自分の種族がいずれか
function B:addHolderRaceExclude(...) return nsSet(self, "holder", "raceExclude", { ... }) end             -- 自分の種族がいずれでもない
function B:addHolderBaseIds(a, b, c) return nsSet(self, "holder", "baseIds", { a, b, c }) end             -- 自分のbaseIdが一致
function B:addHolderTeamBaseIds(a, b, c) return nsSet(self, "holder", "teamBaseIds", { a, b, c }) end     -- 自チームにbaseId該当者がいる
function B:addHolderBreaking() return nsSet(self, "holder", "breaking", true) end                         -- 自分がブレイク中
function B:addHolderGaugeMax(v) return nsSet(self, "holder", "gaugeMax", v) end                           -- 奥義ゲージがv以下
function B:addHolderUnitState(s) return nsSet(self, "holder", "unitState", s) end                         -- 1:攻撃中のみ/2:攻撃中以外/3:スキル状態
-- 相手（発動時の相手）の条件
function B:addEnemyCondition(t1, t2) return nsSet(nsSet(self, "enemy", "conditionType1", t1), "enemy", "conditionType2", t2) end -- 相手がt1(or t2)状態のとき
function B:addEnemyConditionNegate() return nsSet(self, "enemy", "conditionNegate", true) end             -- ↑を「持たないとき」に反転
function B:addEnemyConditionScriptId(id) return nsSet(self, "enemy", "conditionScriptId", id) end         -- ↑の状態のscriptIDがidのとき
function B:addEnemyHpMin(p) return nsSet(self, "enemy", "hpMin", p) end                                   -- 相手HP%がp以上
function B:addEnemyHpMax(p) return nsSet(self, "enemy", "hpMax", p) end                                   -- 相手HP%がp以下
function B:addEnemyHpRange(minP, maxP) return nsSet(nsSet(self, "enemy", "hpMin", minP), "enemy", "hpMax", maxP) end -- 相手HP%が範囲内
function B:addEnemyHpMaxExclusive() return nsSet(self, "enemy", "hpMaxExclusive", true) end               -- HP上限を「未満」にする
function B:addEnemyElement(e) return nsSet(self, "enemy", "element", e) end                               -- 相手の属性がe
function B:addEnemyElementExclude(e) return nsSet(self, "enemy", "elementExclude", e) end                 -- 相手の属性がe以外
function B:addEnemyElementNone() return nsSet(self, "enemy", "elementNone", true) end                     -- 相手が無属性
function B:addEnemyRace(...) return nsSet(self, "enemy", "race", { ... }) end                             -- 相手の種族がいずれか
function B:addEnemyRaceExclude(...) return nsSet(self, "enemy", "raceExclude", { ... }) end               -- 相手の種族がいずれでもない
function B:addEnemyBossBreaking() return nsSet(self, "enemy", "bossBreaking", true) end                   -- 相手（ボス）がブレイク中
function B:addEnemyBreaking() return nsSet(self, "enemy", "breaking", true) end                           -- 相手自身がブレイク中
-- 相手がgroupID=gの状態を保持し、その値(slot: nil/0=getValue / 5=getValue5)がmin以上のとき（出血Lv等・id_222/257）
function B:addEnemyConditionGroupValue(g, minValue, slot)
    return nsSet(nsSet(nsSet(self, "enemy", "conditionGroupId", g), "enemy", "conditionValueMin", minValue), "enemy", "conditionValueSlot", slot)
end
-- Lua側(updateCondition等)が条件の値を実値/0に書き換えるので現在値で判定してよい（id_520のBGM連動）
function B:addDynamicValue() return topSet(self, "dynamicValue", true) end
function B:addEnemySize(n) return nsSet(self, "enemy", "size", n) end                                     -- 相手のサイズがn（3=大型）
function B:addEnemyBurstActive() return nsSet(self, "enemy", "burstActive", true) end                     -- 相手が奥義発動中
function B:addEnemyTeamBurstActive() return nsSet(self, "enemy", "teamBurstActive", true) end             -- 相手チームの誰かが奥義発動中
function B:addEnemyElementAdvantage(mode) return nsSet(self, "enemy", "elementAdvantage", mode) end       -- 属性相性ゲート（1:相手基準/2:自分基準）
function B:addEnemyGaugeMax(v) return nsSet(self, "enemy", "gaugeMax", v) end                             -- 相手の奥義ゲージ%がv以下
function B:addEnemyBossFilter(mode) return nsSet(self, "enemy", "bossFilter", mode) end                   -- 1:ボス限定/2:非ボス限定（grant側とは逆なので注意）
function B:addEnemyDTypeBits(bits) return nsSet(self, "enemy", "dTypeBits", bits) end                     -- 相手のDamageAffectInfo種別ビット
function B:addEnemyDTypeBossExtraBits(bits) return nsSet(self, "enemy", "dTypeBossExtraBits", bits) end   -- ↑相手がボスなら追加許容するビット
-- 攻撃文脈（発動時の攻撃の種類）
function B:addAttackAttribute(a) return nsSet(self, "attack", "attribute", a) end                         -- 1:物理限定/2:魔法限定
function B:addAttackAttributeExclude(a) return nsSet(self, "attack", "attributeExclude", a) end           -- 物魔のa以外
function B:addAttackCritical() return nsSet(self, "attack", "critical", true) end                         -- クリティカル限定
function B:addAttackElement(e) return nsSet(self, "attack", "element", e) end                             -- 攻撃技の属性がe
function B:addAttackElementNone() return nsSet(self, "attack", "elementNone", true) end                   -- 攻撃技が無属性
function B:addAttackCategoryBits(bits) return nsSet(self, "attack", "categoryBits", bits) end             -- スキル種別ビット（記録のみ・AIは判定に使わない）
function B:addAttackDTypeBits(bits) return nsSet(self, "attack", "dTypeBits", bits) end                   -- DamageAffectInfo.skillType のビットゲート
function B:addAttackSTypeBits(bits) return nsSet(self, "attack", "sTypeBits", bits) end                   -- ActiveBattleSkill種別のビットゲート
function B:addAttackSkillFlag(f) return nsSet(self, "attack", "skillFlag", f) end                         -- 1:isBurst2/2:isBurst3/3:PB/4:2or3
function B:addAttackRequireSkill() return nsSet(self, "attack", "requireSkill", true) end                 -- ActiveBattleSkillが存在すれば通す
-- バトル状態
function B:addExcludeArena() return nsSet(self, "battle", "excludeArena", true) end                       -- アリーナでは無効
function B:addElapsedTimeMax(sec) return nsSet(self, "battle", "elapsedTimeMax", sec) end                 -- 経過時間がsec以内
-- 効果量スケール（VS.〇〇と組み合わせる）
function B:addScale(scaleType, p1, p2, p3) return topSet(self, "scale", { type = scaleType, p1 = p1, p2 = p2, p3 = p3 }) end -- 状態で効果量が変わる
-- 効果適用（バトル評価時の冪等副作用）
function B:addEffectRemoveOnReset() return nsSet(self, "effect", "removeOnReset", true) end               -- 評価時に状態リセットで消えるフラグを立てる
function B:addEffectRemoveOnResetOnPass() return nsSet(self, "effect", "removeOnResetOnPass", true) end   -- ゲート成立時のみ↑
function B:addEffectUnsetPassive() return nsSet(self, "effect", "unsetPassive", true) end                 -- 評価時にパッシブ解除
-- 付与時条件（grant。付与された時点で通過済み＝AI/バトル発動判定は読まない）
function B:addGrantTargetElement(e) return nsSet(self, "grant", "targetElement", e) end                   -- 付与対象の属性がe
function B:addGrantTargetElementNegate() return nsSet(self, "grant", "targetElementNegate", true) end     -- ↑を「e以外」に反転
function B:addGrantTargetRace(...) return nsSet(self, "grant", "targetRace", { ... }) end                 -- 付与対象の種族がいずれか
function B:addGrantTargetRaceNegate() return nsSet(self, "grant", "targetRaceNegate", true) end           -- ↑を「いずれでもない」に反転
function B:addGrantTargetSexuality(v) return nsSet(self, "grant", "targetSexuality", v) end               -- 付与対象の性別がv
function B:addGrantTargetHpMin(p) return nsSet(self, "grant", "targetHpMin", p) end                       -- 付与対象HP%がp以上
function B:addGrantTargetHpMax(p) return nsSet(self, "grant", "targetHpMax", p) end                       -- 付与対象HP%がp以下
function B:addGrantTargetBaseIds(a, b, c) return nsSet(self, "grant", "targetBaseIds", { a, b, c }) end   -- 付与対象のbaseIdが一致
function B:addGrantCasterRace(...) return nsSet(self, "grant", "casterRace", { ... }) end                 -- 発動者の種族がいずれか
function B:addGrantCasterElement(e) return nsSet(self, "grant", "casterElement", e) end                   -- 発動者の属性がe
function B:addGrantBossBreak() return nsSet(self, "grant", "bossBreak", true) end                         -- 付与時に敵ボスがブレイク中
function B:addGrantBossNotBreak() return nsSet(self, "grant", "bossNotBreak", true) end                   -- 付与時に敵ボスが非ブレイク
function B:addGrantBossBreakRateMax(v) return nsSet(self, "grant", "bossBreakRateMax", v) end             -- 付与時に敵ボスのブレイク率がv%以下
function B:addGrantTargetBossFilter(mode) return nsSet(self, "grant", "targetBossFilter", mode) end       -- 付与対象が 1:非ボス限定/2:ボス限定
function B:addGrantTargetBreaking() return nsSet(self, "grant", "targetBreaking", true) end               -- 付与対象がブレイク中
function B:addGrantTargetHasCondType(t) return nsSet(self, "grant", "targetHasCondType", t) end           -- 付与対象が状態typeを保持
function B:addGrantTargetLackCondId(id) return nsSet(self, "grant", "targetLackCondId", id) end           -- 付与対象が状態idを未保持
function B:addGrantCasterLackCondId(id) return nsSet(self, "grant", "casterLackCondId", id) end           -- 発動者が状態idを未保持
function B:addGrantCasterNotTarget() return nsSet(self, "grant", "casterNotTarget", true) end             -- 発動者≠付与対象
function B:addGrantTime(threshold, mode) return nsSet(nsSet(self, "grant", "timeThreshold", threshold), "grant", "timeMode", mode) end -- 付与時経過時間（mode 0:以下/1:以上/2:未満/3:より上）
function B:addGrantNote(text) return nsSet(self, "grant", "note", text) end                               -- 付与判定の注記（未モデル部分の記録）
-- 機構・注記
function B:addRefBuffMode(mode) return topSet(self, "refBuffMode", mode) end                              -- 別バフ参照（1:enabling/2:+属性スワップ/3:suppress+index4/4:suppress）
function B:addTrigger() return topSet(self, "trigger", true) end                                          -- 効果量を持たない機構script（常に0）
function B:addNever(reason) return topSet(self, "never", reason or true) end                              -- 常に不成立（reasonは記録用）
function B:addSideEffect(text) return topSet(self, "sideEffect", text) end                                -- 副作用の注記（発動時はLua実行のまま）
function B:addApprox(text) return topSet(self, "approx", text) end                                        -- 近似の注記（発動時はLua実行のまま）
function B:addSpecial(text) return topSet(self, "special", text) end                                      -- 特殊判定の注記（発動時はLua実行のまま）
function B:addValueCalc() return topSet(self, "valueCalc", true) end                                      -- 効果量の独自計算あり（発動時はLua実行のまま）
function B:addNotes(text) return topSet(self, "notes", text) end                                          -- 一般注記
function B:addFact(ns, key, value) return nsSet(self, ns, key, value) end                                 -- 語彙に無いキーの直接指定（乱用しない）
-- ==== 条件結合子（値による分岐を宣言的に書く。subは buff():... のサブ定義） ====
function B:switch(sel, cases, default) return pushOp(self, { k = "switch", sel = sel, cases = cases, default = default }) end -- 値ごとに枝を選ぶ（該当なしはdefault、無ければ何もしない）
function B:when(sel, value, sub) return pushOp(self, { k = "when", sel = sel, value = value, sub = sub }) end                 -- 値が一致したときだけsubを合成
function B:whenNot(sel, value, sub) return pushOp(self, { k = "when", sel = sel, value = value, sub = sub, neg = true }) end  -- 値が不一致のときだけsubを合成
function B:whenPositive(sel, sub) return pushOp(self, { k = "whenPositive", sel = sel, sub = sub }) end                       -- 値が正のときだけsubを合成
function B:pickFirst(branches) return pushOp(self, { k = "pickFirst", branches = branches }) end                              -- 択一: {sel, sub[, values={...}]}の列で最初に該当した枝だけ合成（valuesなし=値が0以外で該当）
-- ==== 値の規約を吸収する語彙（0=不問、6=無属性 等。評価時に実値を見て自動分岐） ====
function B:addAttackAttributeOpt(sel) return pushOp(self, { k = "attrOpt", sel = sel }) end               -- 0=不問/それ以外=物魔限定(1物理/2魔法)
function B:addHolderElementOpt(sel) return pushOp(self, { k = "elemOpt", ns = "holder", sel = sel }) end  -- 0=不問/6=自分が無属性/他=自分がその属性
function B:addEnemyElementOpt(sel) return pushOp(self, { k = "elemOpt", ns = "enemy", sel = sel }) end    -- 0=不問/6=相手が無属性/他=相手がその属性
function B:addAttackElementOpt(sel) return pushOp(self, { k = "elemOpt", ns = "attack", sel = sel }) end  -- 0=不問/6=攻撃技が無属性/他=技がその属性
function B:addAttackPhysMagCrit(sel) return pushOp(self, { k = "physMagCrit", sel = sel }) end            -- 1=物理/2=魔法/3=クリ限定/他=不問
function B:addAttackMoveType(sel) return pushOp(self, { k = "moveType", sel = sel }) end                  -- Lua moveType規約: 0=不問/1物理/2魔法/3クリ/4以上=常に0
function B:addAttackMoveTypeShift6(sel) return pushOp(self, { k = "moveTypeShift6", sel = sel }) end      -- 6以上のとき(v-5)をmoveTypeとして適用/未満=不問
function B:addAttackDTypeEq(sel) return pushOp(self, { k = "dTypeEq", sel = sel }) end                    -- DamageAffectInfo種別==v（0=不問/7=真奥義複合）
function B:addAttackDTypeIs(sel) return pushOp(self, { k = "dTypeIs", sel = sel }) end                    -- DamageAffectInfo種別==v（0ガードなし）
function B:addAttackSkillSwitch(sel) return pushOp(self, { k = "skillSwitch", sel = sel }) end            -- ActiveBattleSkill種別switch（1スキル/2奥義系/7真奥義/8PB/9超奥義/10真or超・該当なし値=skill存在で通る）
function B:addAttackSkillSwitchNo10(sel) return pushOp(self, { k = "skillSwitchNo10", sel = sel }) end    -- 同上だがv=10のcaseが無い実体用（10はskill存在扱い。id_342/414）
function B:addAttackCategoryScript(sel) return pushOp(self, { k = "categoryScript", sel = sel }) end      -- categoryWithScriptValue規約（0=制限なし/1スキル/2奥義系/7真奥義/8PB/9超奥義/10真or超）

-- V1〜V5プレースホルダを実値に置換しながらfactsを複製する（評価は純粋・共有オブジェクトを汚さない）
local function resolveFacts(v, vs)
    if type(v) == "table" then
        if v.__slot then return vs[v.__slot] end
        local out = {}
        for k, x in pairs(v) do out[k] = resolveFacts(x, vs) end
        return out
    end
    return v
end

-- 事実片をマージ（名前空間テーブルはキー単位で合成、スカラーは上書き）
local function mergeFacts(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" and type(dst[k]) == "table" then
            for k2, v2 in pairs(v) do dst[k][k2] = v2 end
        else
            dst[k] = v
        end
    end
end

-- ビルダーを実値で評価して事実テーブルを返す（facts解決 → 遅延opを定義順に適用）
local function resolveBuff(b, vs)
    local out = resolveFacts(b.facts, vs)
    for _, op in ipairs(b.ops or {}) do
        local add = nil
        local k = op.k
        if k == "switch" then
            local branch = op.cases[slotValue(op.sel, vs)]
            if branch == nil then branch = op.default end
            if branch then add = resolveBuff(branch, vs) end
        elseif k == "when" then
            local hit = (slotValue(op.sel, vs) == slotValue(op.value, vs))
            if op.neg then hit = not hit end
            if hit then add = resolveBuff(op.sub, vs) end
        elseif k == "whenPositive" then
            if slotValue(op.sel, vs) > 0 then add = resolveBuff(op.sub, vs) end
        elseif k == "pickFirst" then
            for _, br in ipairs(op.branches) do
                local v = slotValue(br[1], vs)
                local hit
                if br.values then
                    hit = false
                    for _, x in ipairs(br.values) do
                        if v == x then hit = true; break end
                    end
                else
                    hit = (v ~= 0)
                end
                if hit then
                    add = resolveBuff(br[2], vs)
                    break
                end
            end
        elseif k == "attrOpt" then
            local v = slotValue(op.sel, vs)
            if v ~= 0 then add = { attack = { attribute = v } } end
        elseif k == "elemOpt" then
            local v = slotValue(op.sel, vs)
            if v == 6 then add = { [op.ns] = { elementNone = true } }
            elseif v ~= 0 then add = { [op.ns] = { element = v } } end
        elseif k == "physMagCrit" then
            local v = slotValue(op.sel, vs)
            if v == 1 or v == 2 then add = { attack = { attribute = v } }
            elseif v == 3 then add = { attack = { critical = true } } end
        elseif k == "moveType" then
            add = moveTypeFacts(slotValue(op.sel, vs))
        elseif k == "moveTypeShift6" then
            local v = slotValue(op.sel, vs)
            if v >= 6 then add = moveTypeFacts(v - 5) end
        elseif k == "dTypeEq" then
            local v = slotValue(op.sel, vs)
            if v ~= 0 then add = { attack = dTypeEqFacts(v) } end
        elseif k == "dTypeIs" then
            add = { attack = { dTypeBits = 2 ^ slotValue(op.sel, vs) } }
        elseif k == "skillSwitch" then
            add = { attack = skillSwitchFacts(slotValue(op.sel, vs)) }
        elseif k == "skillSwitchNo10" then
            local v = slotValue(op.sel, vs)
            if v == 10 then add = { attack = { requireSkill = true } }
            else add = { attack = skillSwitchFacts(v) } end
        elseif k == "categoryScript" then
            add = { attack = { categoryBits = categoryWithScriptValue(slotValue(op.sel, vs)) } }
        end
        if add then mergeFacts(out, add) end
    end
    return out
end

---------------------------------------------------------------
-- 中立データ（SEMANTICS）
---------------------------------------------------------------

local SCRIPT_ID = {}

-- ==== エントリ定義用の定型ヘルパ ====

-- 状態異常でない(v3は除外)とき。v2で判定切替（0=なし/1=物理/2=魔法/3=クリ）
local function noBadStatusFacts(v2, v3)
    local t = { holder = { noBadStatusExceptType = v3 } }
    if v2 == 1 then t.attack = { attribute = 1 }
    elseif v2 == 2 then t.attack = { attribute = 2 }
    elseif v2 == 3 then t.attack = { critical = true }
    end
    return t
end

local function trigger(desc)
    return function() return { trigger = true, sideEffect = desc } end
end

local function unconditional()
    return {}
end

-- 発動条件は常時だが、Lua側で効果量を独自計算するもの（AI判定は生値近似・バトルではLua実行が必要）
local function valueCalcOnly()
    return { valueCalc = true }
end

-- 副作用あり（実行禁止）の常時扱い群
local function unconditionalWithSideEffect(desc)
    return function() return { sideEffect = desc } end
end

-- ==== 一括定義（常時系）。以降の個別定義があるidは個別定義が優先（後勝ち） ====

-- 常時value（効果量も生値のまま＝バトルでも正確に評価可能）
for _, id in ipairs({
    23, 123, 168, 200, 1702,        -- 常時valueを返す（出し分けは別処理）
    15, 155, 156, 181, 204, 247, 278, 287,
    311, 323, 390, 403, 506,        -- 常時valueを返す（毒/燃焼/DOT等で使用）
    425, 448,                       -- 常時valueを返す
    13, 46, 48, 72, 73, 85, 142, 185, 234, 249, 457,   -- Lua実体は return value のみ（2026-07-24精査で値加工分類から昇格）
    -- テーブル外だった無条件script（2026-07-27）。発動時id_xxxは return value のみ＝バトル/AI評価は無条件で正しい。
    -- ※付与時(if script_id==N)に種族/属性ゲートを持つものが多いが、それは付与済み前提で発動時評価には無関係
    --   （grant事実は maskFromSemantics が読まないためマスク同一）。grant記録は将来スマート編成時の任意拡張。
    387, 359, 341, 2242, 69, 224, 392, 375, 386, 2094, 523, 522, 514, 356, 329,
    199, 198, 385, 384, 383, 381, 382, 50, 39, 180, 485, 336, 319, 163,
    545,                            -- 392の全ステ専用版（付与はLuaで行い発動時は moveType のみ）
}) do
    SCRIPT_ID[id] = unconditional
end

for _, id in ipairs({
    47,                             -- 相手最大HP%換算（対象14型で実マスタ未使用）
    205,                            -- 距離依存の値計算（AI判定に距離文脈が無く保留）
    248,                            -- id_xxx未定義
    354,                            -- 自分最大HP%換算（対象14型で実マスタ未使用）
    314,                            -- HPMAX%の回復量計算のみ（同上）
}) do
    SCRIPT_ID[id] = valueCalcOnly
end

-- ==== 個別定義（scriptId昇順） ====

-- 相手HP%がv1〜v2の範囲で効果量0〜1スケール＋v3加算
SCRIPT_ID[1] = buff():addScale(VS.ENEMY_HP_RATE, V1, V2, V3)
-- 物理攻撃（attribute==1）のとき。※実体は限定型＝攻撃文脈なし(attribute=0)は不成立（除外型だと0で成立してしまう）
SCRIPT_ID[2] = buff():addAttackAttribute(1)
-- 魔法攻撃（attribute==2）のとき
SCRIPT_ID[3] = buff():addAttackAttribute(2)
-- 物理攻撃（attribute==1）のとき。※実体は限定型＝攻撃文脈なし(attribute=0)は不成立（除外型だと0で成立してしまう）
SCRIPT_ID[4] = SCRIPT_ID[2]
-- 魔法攻撃（attribute==2）のとき
SCRIPT_ID[5] = SCRIPT_ID[3]
-- 自HP%がv1〜v2の0〜1スケール×生値＋v3加算。v4≠0はDamageAffectInfo種別ゲート
SCRIPT_ID[6] = buff()
    :addScale(VS.SELF_HP_RATE, V1, V2, V3)
    :addAttackDTypeEq(V4)
-- RoR（評価のたび無条件セット→effectで再現）＋v1=0/8は常時（8はLua実体のif連鎖をすり抜けPB検証なし）。
-- v1=1/2/7はActiveBattleSkill基準のゲート（7=isBurst2かつtype2）。他の値はtype(1/2)と一致し得ず常に0
SCRIPT_ID[8] = buff()
    :addEffectRemoveOnReset()
    :switch(V1, {
        [0] = buff(),                                                       -- 常時
        [8] = buff(),                                                       -- if連鎖すり抜け＝常時（PB検証なし）
        [1] = buff():addAttackSTypeBits(2 ^ 1),
        [2] = buff():addAttackSTypeBits(2 ^ 2),
        [7] = buff():addAttackSTypeBits(2 ^ 2):addAttackSkillFlag(1),       -- 真奥義複合
    }, buff():addNever("getSkillTypeと一致し得ない値"))
-- 副作用あり（実行禁止・分類を値加工から修正 2026-07-24）
-- スキル中（dType1）成立時のみRoR＝使い切り
SCRIPT_ID[10] = buff()
    :addAttackDTypeBits(2 ^ 1)
    :addEffectRemoveOnResetOnPass()
-- 通常攻撃中（unitStateがattack）のみ
SCRIPT_ID[11] = buff():addHolderUnitState(1)
-- 自分の属性がv1のとき（付与時も対象属性v1をチェック。v2種別ゲートは判定未使用）
SCRIPT_ID[12] = buff()
    :addHolderElement(V1)
    :addGrantTargetElement(V1)
-- 相手の属性がv1のとき（v2≠0はDamageAffectInfo種別ゲート）
SCRIPT_ID[14] = buff()
    :addEnemyElement(V1)
    :addAttackDTypeEq(V2)
-- 自分の種族がv1/v2/v3のいずれかのとき（付与時も同条件でチェック）
SCRIPT_ID[16] = buff()
    :addHolderRace(V1, V2, V3)
    :addGrantTargetRace(V1, V2, V3)
-- 相手の種族がv1のとき
SCRIPT_ID[17] = buff():addEnemyRace(V1)
-- 自分がv1(or v2)状態のとき
SCRIPT_ID[18] = buff():addHolderCondition(V1, V2)
-- 相手がv1(or v2)状態のとき
SCRIPT_ID[19] = buff():addEnemyCondition(V1, V2)
-- 相手（攻撃対象）自身がブレイク中のとき（id_20はother基準。絶対エネミーボス基準はid_60/150）
SCRIPT_ID[20] = buff():addEnemyBreaking()
-- HP%がv1〜v2のとき（v4=1で相手側。v3=1なら上限は「未満」）
SCRIPT_ID[21] = buff()
    :switch(V4, { [1] = buff():addEnemyHpRange(V1, V2):when(V3, 1, buff():addEnemyHpMaxExclusive()) },
                  buff():addHolderHpRange(V1, V2):when(V3, 1, buff():addHolderHpMaxExclusive()))
-- クリティカル時（v1=1なら常時扱い。v2のスキル種別ゲートは判定未使用）
SCRIPT_ID[22] = buff():whenNot(V1, 1, buff():addAttackCritical())
-- 付与時に発動者属性v1のとき付与（id_23）
SCRIPT_ID[23] = buff():addGrantCasterElement(V1)
-- 自分の種族がv1のとき（付与時は発動者casterの種族v1をチェック）
SCRIPT_ID[24] = buff()
    :addHolderRace(V1)
    :addGrantCasterRace(V1)
-- 相手属性×相手の攻撃技属性の有利相性（1→2,2→3,3→1,4→5,5→4）のとき
SCRIPT_ID[27] = buff():addEnemyElementAdvantage(1)
-- 自分属性×相手の攻撃技属性の有利相性のとき
SCRIPT_ID[28] = buff():addEnemyElementAdvantage(2)
-- 状態保持ゲート（29: 対象がID未保持 / 39: 対象がtype保持 / 449: 発動者がID未保持(v1≠0時)）
SCRIPT_ID[29] = buff():addGrantTargetLackCondId(V1)
-- 副作用あり（実行禁止・分類を値加工から修正 2026-07-24）
-- スキル中（dType1）成立時のみRoR＝使い切り
SCRIPT_ID[31] = buff():addSideEffect("setRemoveOnResetState")   -- 相手HPレンジスケール
-- 入口RoR（使い切り）＋敵チームの誰かが奥義発動中のとき有効
SCRIPT_ID[34] = buff()
    :addEnemyTeamBurstActive()
    :addEffectRemoveOnReset()
-- baseIdがv1/v2/v3のいずれかのとき
SCRIPT_ID[35] = buff():addHolderBaseIds(V1, V2, V3)
-- 自分がv1状態のとき（スキル種別ゲートは判定未使用）
SCRIPT_ID[36] = buff()
    :addHolderCondition(V1)
    :addSideEffect("setRemoveOnResetState")
-- スキルタイプ1or2かつユニット状態がskillのとき
SCRIPT_ID[37] = buff()
    :addAttackSTypeBits(2 ^ 1 + 2 ^ 2)
    :addHolderUnitState(3)
-- 状態保持ゲート（29: 対象がID未保持 / 39: 対象がtype保持 / 449: 発動者がID未保持(v1≠0時)）
SCRIPT_ID[39] = buff():addGrantTargetHasCondType(V1)
-- 生値＋保持者HP×v1/1000（上限v2）
SCRIPT_ID[40] = buff():addScale(VS.SELF_HP_FLAT_ADD, V1, V2)
-- 相手が状態v1を保持（v3=1なら「非保持」）のとき。v2≠0はスキル種別ゲート＋RoR＝バトルはLua実行
-- v1=0は「存在しない状態0」の検索＝保持条件なら常に不発・非保持(v3=1)なら常時
SCRIPT_ID[42] = buff()
    :switch(V1, { [0] = buff():whenNot(V3, 1, buff():addNever("状態0の保持条件")) },
                  buff():addEnemyCondition(V1):when(V3, 1, buff():addEnemyConditionNegate()))
    :whenNot(V2, 0, buff():addAttackSkillSwitch(V2):addEffectRemoveOnReset())
-- 相手チームの誰かがv1状態のとき（判定は敵ボス代表で近似）
SCRIPT_ID[43] = buff()
    :addEnemyCondition(V1)
    :addApprox("チーム走査→ボス代表")
    :addSideEffect("setRemoveOnResetState")
-- 相手（攻撃対象）ブレイク中かつスキル属性v1のとき
SCRIPT_ID[49] = buff()
    :addAttackElement(V1)
    :addEnemyBreaking()
-- 付与時に対象種族v1のとき付与（発動時は無条件）
SCRIPT_ID[50] = buff():addGrantTargetRace(V1)
-- 相手HP%がv1以下のとき
SCRIPT_ID[51] = buff():addEnemyHpMax(V1)
-- 付与時に対象種族v1のとき付与（発動時は無条件）
SCRIPT_ID[52] = buff():addGrantTargetRace(V1)
-- 物理攻撃かつ相手属性v1のとき
SCRIPT_ID[54] = buff()
    :addEnemyElement(V1)
    :addAttackAttributeExclude(2)
-- 魔法攻撃のとき（v1は不使用）
SCRIPT_ID[55] = buff():addAttackAttribute(2)
-- 相手が大型（サイズ3）のとき＝大型キラー
SCRIPT_ID[56] = buff():addEnemySize(3)
-- 奥義（DamageAffectInfo種別2）のとき
SCRIPT_ID[58] = buff():addAttackDTypeBits(2 ^ 2)
-- 真奥義(3)orアルビオン(6)のとき
SCRIPT_ID[59] = buff():addAttackDTypeBits(DTYPE_ITEM_SUMMON)
-- 敵ボスがブレイク中のとき（id_60は絶対エネミーチームのボス基準）
SCRIPT_ID[60] = buff():addEnemyBossBreaking()
-- 監査正規表現の強化（setIsPassive/setNumber/setParameter/setBurstPoint等）で検出した副作用script（2026-07-24）
-- パッシブ解除トリック（冪等な自己フラグ→effectとして構造化・バトル評価で再現される）
SCRIPT_ID[62] = buff():addEffectUnsetPassive()
-- 奥義中（dType2）成立時のみRoR＝使い切り
SCRIPT_ID[64] = buff()
    :addAttackDTypeBits(2 ^ 2)
    :addEffectRemoveOnResetOnPass()
-- 奥義中かつ自分HP%がv1以上のとき
SCRIPT_ID[65] = buff()
    :addAttackDTypeBits(2 ^ 2)
    :addHolderHpMin(V1)
-- 相手の奥義ゲージ%がv1以下かつDamageAffectInfo種別がv2のとき
SCRIPT_ID[68] = buff()
    :addEnemyGaugeMax(V1)
    :addAttackDTypeIs(V2)
-- 奥義中かつ自分HP%がv1以上のとき
SCRIPT_ID[70] = buff():addAttackElement(V1)
-- 相手が状態v1を保持し、その（typeで最初に見つかる）状態のscriptIDがv2のとき
SCRIPT_ID[71] = buff()
    :addEnemyCondition(V1)
    :addEnemyConditionScriptId(V2)
-- 敵ボスのブレイク状態（72: 非ブレイク時 / 73: ブレイク時 / 83: ブレイク率v1%以下）
SCRIPT_ID[72] = buff():addGrantBossNotBreak()
SCRIPT_ID[73] = buff():addGrantBossBreak()
-- 自分がブレイク中のとき（被ダメ系）
SCRIPT_ID[75] = buff():addHolderBreaking()
-- スキル（DamageAffectInfo種別1）かつ通常攻撃状態でないとき
SCRIPT_ID[76] = buff()
    :addAttackDTypeBits(2 ^ 1)
    :addHolderUnitState(2)
-- 副作用あり（実行禁止・分類を値加工から修正 2026-07-24）
-- スキル中（dType1）成立時のみRoR＝使い切り
SCRIPT_ID[77] = buff():addSideEffect("setGroupID")              -- グループID上書き ※監査正規表現の漏れで検出
-- 自分の属性がv1以外のとき
SCRIPT_ID[79] = buff():addHolderElementExclude(V1)
-- v1属性かつクリティカル時
SCRIPT_ID[80] = buff()
    :addHolderElement(V1)
    :addAttackCritical()
-- 自分の属性がv1かつ相手が奥義発動中のとき
SCRIPT_ID[81] = buff()
    :addHolderElement(V1)
    :addEnemyBurstActive()
-- スキル種別ゲートのみ（付与時に対象種族v1をチェック）
-- 種別（v2==dType/7複合・skill必須）成立時のみRoR＝使い切り（付与時に対象種族v1をチェック）
SCRIPT_ID[82] = buff()
    :addGrantTargetRace(V1)
    :addAttackRequireSkill()
    :addEffectRemoveOnResetOnPass()
    :addAttackDTypeEq(V2)
-- 敵ボスのブレイク状態（72: 非ブレイク時 / 73: ブレイク時 / 83: ブレイク率v1%以下）
SCRIPT_ID[83] = buff():addGrantBossBreakRateMax(V1)
-- 奥義中（dType2）成立時のみRoR＝使い切り
SCRIPT_ID[84] = unconditionalWithSideEffect("setRemoveOnResetState")
-- baseId一致かつHP%がv2以下のとき
SCRIPT_ID[87] = buff()
    :addHolderBaseIds(V1)
    :addHolderHpMax(V2)
-- 相手（ボス）ブレイク中かつ奥義のとき（種別は判定未使用）
SCRIPT_ID[88] = SCRIPT_ID[20]
-- v1属性かつHP%がv2〜v3の範囲で効果量0〜1スケール
SCRIPT_ID[89] = buff()
    :addHolderElement(V1)
    :addScale(VS.SELF_HP_RATE, V2, V3)
-- 相手の属性がv1かつ奥義（DamageAffectInfo種別2）のとき（RoRはゲート成立時のみ→OnPassで再現）
SCRIPT_ID[90] = buff()
    :addEnemyElement(V1)
    :addAttackDTypeBits(2 ^ 2)
    :addEffectRemoveOnResetOnPass()
-- 相手属性×相手の攻撃技属性の有利相性（id_27と同一実体・付与時に対象属性v1をチェック）
SCRIPT_ID[93] = buff()
    :addGrantTargetElement(V1)
    :addEnemyElementAdvantage(1)
-- 相手が大型かつ真奥義(3)orアルビオン(6)のとき（※56と違い種別ゲートあり。2026-07-24全数ソークで検出）
SCRIPT_ID[94] = buff()
    :addEnemySize(3)
    :addAttackDTypeBits(DTYPE_ITEM_SUMMON)
-- 種別（v2==dType/7複合・v2=0はskill不要で常時）＋v3=1で成立時のみRoR＝使い切り
SCRIPT_ID[95] = buff()
    :whenNot(V2, 0, buff():addAttackRequireSkill():addAttackDTypeEq(V2))
    :when(V3, 1, buff():addEffectRemoveOnResetOnPass())
-- アリーナ無効＋相手が非ボスかつHP%がv1以下＋種別（v2==dType/7複合・0=不問）のとき
SCRIPT_ID[96] = buff()
    :addExcludeArena()
    :addEnemyBossFilter(2)
    :addEnemyHpMax(V1)
    :addAttackDTypeEq(V2)
-- 状態異常中かつbaseId一致のとき
SCRIPT_ID[100] = buff()
    :addHolderBadStatus()
    :addHolderBaseIds(V1)
-- 相手の種族がv1/v2/v3のいずれか＋奥義系統のみ
SCRIPT_ID[101] = buff()
    :addEnemyRace(V1, V2, V3)
    :addAttackCategoryBits(CATEGORY_BURST_ONLY)
-- スキル種別ゲート（※移植元のままv1で7判定・v2でカテゴリ指定）
-- 種別（v1==dType/7複合・skill必須）＋v2=1なら成立時のみRoR＝使い切り
SCRIPT_ID[105] = buff()
    :addAttackRequireSkill()
    :addAttackDTypeEq(V1)
    :when(V2, 1, buff():addEffectRemoveOnResetOnPass())
-- 自分の種族がv1かつ奥義（DamageAffectInfo種別2）のとき
SCRIPT_ID[108] = buff()
    :addHolderRace(V1)
    :addAttackDTypeBits(2 ^ 2)
-- 自分の種族がv1かつ相手の攻撃が奥義（相手がボス＝パーツは親判定ならスキルも）のとき
SCRIPT_ID[109] = buff()
    :addHolderRace(V1)
    :addEnemyDTypeBits(2 ^ 2)
    :addEnemyDTypeBossExtraBits(2 ^ 1)
-- 相手の種族がv1以外のとき
SCRIPT_ID[110] = buff():addEnemyRaceExclude(V1)
-- DamageAffectInfo種別がv2（v2=0なら奥義2）のとき（付与時に対象属性v1をチェック）
SCRIPT_ID[114] = buff()
    :addGrantTargetElement(V1)
    :switch(V2, { [0] = buff():addAttackDTypeBits(2 ^ 2) }, buff():addAttackDTypeIs(V2))
-- 付与時に対象性別v1のとき付与（id_115）
SCRIPT_ID[115] = buff():addGrantTargetSexuality(V1)
-- スキル中・相手HP%がv1〜v2の範囲で効果量0〜1スケール＋v3加算
-- スキル中（sType1＋unitState=skill）・相手HP%がv1〜v2で0〜1スケール＋v3加算・成立時のみRoR＝使い切り
SCRIPT_ID[117] = buff()
    :addAttackSTypeBits(2 ^ 1)
    :addHolderUnitState(3)
    :addScale(VS.ENEMY_HP_RATE, V1, V2, V3)
    :addEffectRemoveOnResetOnPass()
-- 奥義中版（sType2）
SCRIPT_ID[118] = buff()
    :addAttackSTypeBits(2 ^ 2)
    :addHolderUnitState(3)
    :addScale(VS.ENEMY_HP_RATE, V1, V2, V3)
    :addEffectRemoveOnResetOnPass()
SCRIPT_ID[120] = buff():addHolderBaseIds(V1, V2, V3)
-- 真奥義(3)orアルビオン(6)かつ技属性がv1のとき
SCRIPT_ID[121] = buff()
    :addAttackDTypeBits(DTYPE_ITEM_SUMMON)
    :addAttackElement(V1)
-- 自分がv1状態を保持しているとき
SCRIPT_ID[122] = buff()
    :addHolderCondition(V1)
    :addEffectRemoveOnReset()
-- 付与時に発動者種族v1のとき付与（id_123/177。177は≠なら不発＝==v1限定で同義）
SCRIPT_ID[123] = buff():addGrantCasterRace(V1)
-- 自HP%がv1〜v2かつ奥義（DamageAffectInfo種別2）のとき
SCRIPT_ID[127] = buff()
    :addHolderHpRange(V1, V2)
    :addAttackDTypeBits(2 ^ 2)
-- 種別（v2==dType/7複合・v2=0はskill不要で常時）＋v3=1で成立時のみRoR＝使い切り
SCRIPT_ID[128] = buff():addEffectRemoveOnReset()   -- 常時（RoRはeffectで再現）
-- 物理魔法がv1かつ自分ブレイク中のとき
SCRIPT_ID[130] = buff()
    :addAttackAttribute(V1)
    :addHolderBreaking()
-- 種別（v2==dType/7複合・v2=0はskill不要で常時）＋v3=1で成立時のみRoR＝使い切り
SCRIPT_ID[131] = unconditionalWithSideEffect("setTime延長(一度きり)")
-- 相手がv1状態かつクリティカル時
SCRIPT_ID[133] = buff()
    :addEnemyCondition(V1)
    :addAttackCritical()
-- 自分のbaseIdがv1かつ相手の種族がv2のとき
SCRIPT_ID[135] = buff()
    :addHolderBaseIds(V1)
    :addEnemyRace(V2)
-- 相手が大型かつ真奥義(3)orアルビオン(6)のとき（※56と違い種別ゲートあり。2026-07-24全数ソークで検出）
SCRIPT_ID[140] = SCRIPT_ID[56]
-- 入口RoR（使い切り）＋自HP%がv1〜v2かつ奥義中（dType2）
SCRIPT_ID[141] = buff()
    :addHolderHpRange(V1, V2)
    :addAttackDTypeBits(2 ^ 2)
    :addEffectRemoveOnReset()
-- HP%がv1〜v2かつクリティカル時
SCRIPT_ID[143] = buff()
    :addHolderHpRange(V1, V2)
    :addAttackCritical()
-- 状態v1保持かつ自分属性×技属性の相性（相性は攻撃文脈。付与時に対象属性v2をチェック）
SCRIPT_ID[144] = buff()
    :addHolderCondition(V1)
    :addGrantTargetElement(V2)
    :addSpecial("属性相性判定")
-- 生値×(1＋保持者のコンディションtype110の値/100)
SCRIPT_ID[145] = buff():addScale(VS.CONDITION_VALUE_RATE, 110)
-- スキル中（sType1＋unitState=skill）クリティカル時、自チームにbaseId v1/v2/v3のユニットがいるとき
SCRIPT_ID[148] = buff()
    :addAttackCritical()
    :addAttackSTypeBits(2 ^ 1)
    :addHolderUnitState(3)
    :addHolderTeamBaseIds(V1, V2, V3)
-- 種別スイッチ（skill必須・v1=0はskill存在のみ）成立時のみRoR＝使い切り
SCRIPT_ID[149] = buff()
    :addAttackSkillSwitch(V1)
    :addEffectRemoveOnResetOnPass()
-- 敵ボスがブレイク中のとき（id_150は絶対エネミーチームのボス基準）
SCRIPT_ID[150] = SCRIPT_ID[60]
-- 魔法攻撃のとき（付与時に対象属性v1をチェック）
SCRIPT_ID[151] = buff()
    :addAttackAttribute(2)
    :addGrantTargetElement(V1)
-- 真奥義(3)orアルビオン(6)のとき（付与時に対象属性v1をチェック）
SCRIPT_ID[152] = buff()
    :addAttackDTypeBits(DTYPE_ITEM_SUMMON)
    :addGrantTargetElement(V1)
-- 反射量=生値＋攻撃者威力×v1/100（アリーナは全体/100）。AI判定は生値のまま（プラス値なら反射持ち）
SCRIPT_ID[154] = buff():addScale(VS.REFLECT_POWER, V1)
-- HP%がv1〜v2のとき
SCRIPT_ID[160] = buff():addHolderHpRange(V1, V2)
-- 常時valueを返す（付与時に対象属性v3をチェック(v3≠0時)＋連動バフ管理）
SCRIPT_ID[161] = buff()
    :whenNot(V3, 0, buff():addGrantTargetElement(V3))
    :addGrantNote("連動バフのstage管理あり")
-- 真奥義中・相手HP%がv1〜v2の範囲で効果量0〜1スケール＋v3加算
-- 真奥義中版（sType2かつisBurst2）
SCRIPT_ID[166] = buff()
    :addAttackSTypeBits(2 ^ 2)
    :addAttackSkillFlag(1)
    :addHolderUnitState(3)
    :addScale(VS.ENEMY_HP_RATE, V1, V2, V3)
    :addEffectRemoveOnResetOnPass()
-- 物理魔法がv4のとき
SCRIPT_ID[167] = buff():addAttackAttributeOpt(V4)
-- 相手属性v2＋物理魔法v3のとき（付与時に対象属性v1をチェック）
SCRIPT_ID[169] = buff()
    :addEnemyElement(V2)
    :addGrantTargetElement(V1)
    :addAttackAttributeOpt(V3)
-- 保持者がv1(orv2)状態のとき有効。効果量は生値ではなく保持者のv3状態の実効値（id_171）
SCRIPT_ID[171] = buff()
    :addHolderCondition(V1, V2)
    :addScale(VS.HOLDER_CONDITION_VALUE, V3)
-- 物理魔法v2のとき（付与時に対象属性v1をチェック）
SCRIPT_ID[172] = buff()
    :addGrantTargetElement(V1)
    :addAttackAttributeOpt(V2)
-- 物魔がv4(0=不問)かつDamageAffectInfo種別がv3(0=不問)のとき（※旧エントリはv3/v4のスロット取り違え。2026-07-24修正）
SCRIPT_ID[173] = buff()
    :addAttackAttributeOpt(V4)
    :addAttackDTypeEq(V3)
-- 自分の種族がv1のとき（パッシブ解除トリック付き・与ダメ17で実使用あり）
SCRIPT_ID[174] = buff()          -- 時間経過の段階値
    :addSideEffect("setNumber")
    :addValueCalc()
-- 物理魔法v2のとき（付与時に対象種族v1をチェック）
SCRIPT_ID[176] = buff()
    :addGrantTargetRace(V1)
    :addAttackAttributeOpt(V2)
-- 付与時に発動者種族v1のとき付与（id_123/177。177は≠なら不発＝==v1限定で同義）
SCRIPT_ID[177] = buff():addGrantCasterRace(V1)
-- 自分の種族がv1のとき（パッシブ解除トリック付き・与ダメ17で実使用あり）
SCRIPT_ID[179] = buff()       -- 直前攻撃者トラッキング
    :addSideEffect("setParameter")
    :addValueCalc()
-- 相手のサイズがv1のとき（v1=3なら大型キラー扱い）
SCRIPT_ID[183] = buff():addEnemySize(V1)
-- 付与対象がブレイク中(185) / 非ボス(v1=0)orボス(v1≠0)限定(294)
SCRIPT_ID[185] = buff():addGrantTargetBreaking()
SCRIPT_ID[187] = trigger("wave管理・自己削除＋再付与")
-- 相手のサイズがv1のとき（v1=3なら大型キラー扱い）
SCRIPT_ID[192] = buff():addEnemyRace(V1)
-- 自分HP%がv1〜v2かつ物理魔法がv3のとき
SCRIPT_ID[197] = buff()
    :addHolderHpRange(V1, V2)
    :addAttackAttributeOpt(V3)
-- ボス限定(v1=1)/非ボス限定(v1=2)＋種別（v2==dType/7複合・0=不問）のとき
SCRIPT_ID[201] = buff()
    :switch(V1, { [1] = buff():addEnemyBossFilter(1), [2] = buff():addEnemyBossFilter(2) })
    :addAttackDTypeEq(V2)
-- 真奥義(3)orアルビオン(6)のとき（※baseId制限なし。253との取り違えを2026-07-24修正）
SCRIPT_ID[202] = buff():addAttackDTypeBits(DTYPE_ITEM_SUMMON)
SCRIPT_ID[206] = trigger("クリ時SP加算(一度きり)")
SCRIPT_ID[207] = trigger("クリ時デバフ転写")
-- 常時valueを返す（付与時=ボスブレイク中かつ対象属性v1のときのみ付与）
-- 常時valueを返す（付与時＝敵ボスがブレイク中かつ対象属性v1のときのみ付与）
SCRIPT_ID[208] = buff()
    :addGrantTargetElement(V1)
    :addGrantBossBreak()
-- v4=物理/魔法の攻撃種別ゲート（0=常時）
SCRIPT_ID[210] = buff():addAttackAttributeOpt(V4)
-- バトル経過時間がv1秒以下のとき
SCRIPT_ID[214] = buff():addElapsedTimeMax(V1)
-- 常時valueを返す（付与時=ボスブレイク中かつ対象属性v1のときのみ付与）
-- 常時valueを返す（付与時＝敵ボスがブレイク中かつ対象属性v1のときのみ付与）
SCRIPT_ID[215] = buff():addAttackElement(V1)
SCRIPT_ID[218] = buff():addAttackElement(V3)
-- 生値×(1＋保持者のコンディションtype110の値/100)
SCRIPT_ID[219] = SCRIPT_ID[145]
-- 常時valueを返す（付与時に対象属性v3をチェック。v4=1で否定）
SCRIPT_ID[221] = buff()
    :addGrantTargetElement(V3)
    :when(V4, 1, buff():addGrantTargetElementNegate())
-- 相手がgroupID v1 の状態を保持し、その値(getValue)がv2以上のとき（出血Lv等・id_222）
SCRIPT_ID[222] = buff():addEnemyConditionGroupValue(V1, V2)
SCRIPT_ID[225] = trigger("奥義ゲージ回復タイマー")
-- 常時valueを返す（付与時に対象属性v3をチェック。v4=1で否定）
SCRIPT_ID[226] = buff()
    :addAttackElement(V1)
    :addAttackAttributeOpt(V2)
-- 生値×自チームの種族v1の数（1体もいなければ0）
SCRIPT_ID[227] = buff():addScale(VS.ALLY_RACE_COUNT, V1)
-- 瀕死ガード付き割合DoT（HPMAX×生値%×rate・死ぬならsetHP(1)で0）＋v1≠0で経過時間ゲート
SCRIPT_ID[228] = buff()
    :addScale(VS.HPMAX_DOT_GUARD)
    :whenNot(V1, 0, buff():addElapsedTimeMax(V1))
-- 種別（v2==dType/7複合・v2=0はskill不要で常時）＋v3=1で成立時のみRoR＝使い切り
SCRIPT_ID[229] = unconditionalWithSideEffect("setRemoveOnResetState")   -- 反射量計算（154/244と同類）
-- 物魔がv3(0=不問)・技属性がv4(0=不問)・DamageAffectInfo種別がv5(0=不問)のとき
SCRIPT_ID[236] = buff()
    :addAttackAttributeOpt(V3)
    :whenNot(V4, 0, buff():addAttackElement(V4))
    :addAttackDTypeEq(V5)
SCRIPT_ID[237] = SCRIPT_ID[236]
-- 相手が状態v1を保持（v3=1なら「非保持」）のとき。v2≠0はスキル種別ゲート＋RoR＝バトルはLua実行
-- v1=0は「存在しない状態0」の検索＝保持条件なら常に不発・非保持(v3=1)なら常時
SCRIPT_ID[238] = unconditionalWithSideEffect("setValue4")               -- HP依存効果量
-- 反射量=生値＋攻撃者威力×v1/100（アリーナは全体/100）。AI判定は生値のまま（プラス値なら反射持ち）
SCRIPT_ID[244] = SCRIPT_ID[154]
-- 物魔がv3(0=不問)・技属性がv4(0=不問)・DamageAffectInfo種別がv5(0=不問)のとき
SCRIPT_ID[250] = buff()
    :addHolderElement(V1)
    :addSideEffect("setValue4")
SCRIPT_ID[252] = buff():addAttackAttributeOpt(V1)
-- baseIdがv1/v2/v3のいずれかかつ真奥義(3)orアルビオン(6)のとき
SCRIPT_ID[253] = buff()
    :addHolderBaseIds(V1, V2, V3)
    :addAttackDTypeBits(DTYPE_ITEM_SUMMON)
-- 物理魔法がv3のとき（0=常時。attribute比較のみでクリ判定なし）
SCRIPT_ID[254] = buff()
    :switch(V3, {
        [0] = buff(),
        [1] = buff():addAttackAttribute(1),
        [2] = buff():addAttackAttribute(2),
    }, buff():addNever())
-- 常時valueを返す（付与時=ボスブレイク中かつ対象属性v1のときのみ付与）
-- 常時valueを返す（付与時＝敵ボスがブレイク中かつ対象属性v1のときのみ付与）
SCRIPT_ID[255] = SCRIPT_ID[215]
-- 相手が出血(groupID 21011)を保持し、そのLv(getValue5)がv1以上のとき（id_257）
SCRIPT_ID[257] = buff():addEnemyConditionGroupValue(21011, V1, 5)
-- 種別（v2==dType/7複合・v2=0はskill不要で常時）＋v3=1で成立時のみRoR＝使い切り
SCRIPT_ID[258] = unconditionalWithSideEffect("setNumber減算・回数制")   -- 回数制バフ（実行すると残回数が減る）
-- v2≠0=瀕死ガード付き割合DoT（v3≠0で経過時間ゲート）、v2=0=生値
SCRIPT_ID[260] = buff()
    :whenNot(V2, 0, buff():addScale(VS.HPMAX_DOT_GUARD):whenNot(V3, 0, buff():addElapsedTimeMax(V3)))
SCRIPT_ID[261] = buff()
    :addHolderNoBadStatusExceptType(V3)
    :addAttackPhysMagCrit(V2)
-- クリティカル時（v1=1なら常時扱い。v2のスキル種別ゲートは判定未使用）
SCRIPT_ID[262] = SCRIPT_ID[22]
-- 真奥義(3)orアルビオン(6)かつ相手の属性がv1のとき
SCRIPT_ID[264] = buff()
    :addAttackCategoryBits(includeBits({ 3, 6 }))
    :addEnemyElement(V1)
-- ⑨連続使用（抑制型 275/276/265）は保留＝Lua実行維持。理由: 副作用setTime(0)が参照バフを消すため
-- DEBUG併走比較が構造的に不成立（C++がsetTime0→Luaが参照消失で別経路）＋ref不在フォールスルーが近似。
-- refBuffMode=3/4のC++実装は残置（inert）。詳細はproject_damageup_ai_cond_5017.md参照。
SCRIPT_ID[265] = unconditionalWithSideEffect("連続使用ギミック(別バフ参照setTime(0))=カテゴリ⑨・保留")
-- 自分が状態v1保持かつ相手の攻撃技属性がv2のとき（被ダメ側）
SCRIPT_ID[269] = buff()
    :addHolderCondition(V1)
    :addAttackElement(V2)
-- 自分の種族がv1以外のとき
SCRIPT_ID[272] = buff():addHolderRaceExclude(V1)
-- 相手の種族がv1/v2/v3のいずれかのとき
SCRIPT_ID[273] = buff()
    :addEnemyRace(V1, V2, V3)
    :addGrantTargetRace(V1, V2, V3)
SCRIPT_ID[274] = trigger("被弾時デバフ付与機構")
-- ⑨連続使用（抑制型 275/276/265）は保留＝Lua実行維持。理由: 副作用setTime(0)が参照バフを消すため
-- DEBUG併走比較が構造的に不成立（C++がsetTime0→Luaが参照消失で別経路）＋ref不在フォールスルーが近似。
-- refBuffMode=3/4のC++実装は残置（inert）。詳細はproject_damageup_ai_cond_5017.md参照。
SCRIPT_ID[275] = unconditionalWithSideEffect("連続使用ギミック(別バフ参照setTime(0))=カテゴリ⑨・保留")
SCRIPT_ID[276] = unconditionalWithSideEffect("連続使用ギミック(別バフ参照setTime(0))=カテゴリ⑨・保留")
SCRIPT_ID[277] = trigger("被弾時デバフ付与機構")
-- 相手の種族がv1/v2/v3のいずれかのとき
SCRIPT_ID[280] = buff():addAttackAttributeOpt(V3)
-- 監査正規表現の強化（setIsPassive/setNumber/setParameter/setBurstPoint等）で検出した副作用script（2026-07-24）
-- パッシブ解除トリック（冪等な自己フラグ→effectとして構造化・バトル評価で再現される）
SCRIPT_ID[282] = buff()   -- 回復量連動の値加工が残るためLua実行
    :addSideEffect("setIsPassive解除")
    :addValueCalc()
SCRIPT_ID[283] = trigger("被弾時デバフ付与機構")
-- 監査正規表現の強化（setIsPassive/setNumber/setParameter/setBurstPoint等）で検出した副作用script（2026-07-24）
-- パッシブ解除トリック（冪等な自己フラグ→effectとして構造化・バトル評価で再現される）
SCRIPT_ID[284] = buff():addEffectUnsetPassive()                    -- time>0ゲートは生存中常に真
-- v2=物理/魔法/クリ、v4=自分属性(6=無属性)、v5=自分種族の択一ゲート
SCRIPT_ID[286] = buff()
    :pickFirst({
        { V2, buff():addAttackPhysMagCrit(V2), values = { 1, 2, 3 } },
        { V4, buff():addHolderElementOpt(V4) },
        { V5, buff():addHolderRace(V5) },
    })
SCRIPT_ID[292] = buff()
    :addHolderRace(V1)
    :addGrantTargetRace(V1)
    :addAttackAttributeOpt(V2)
-- 健康度（HP/HPMAX）×生値×物魔クリ択一v1。v2=1はRoR付き（評価入口で無条件セット）
SCRIPT_ID[293] = buff()
    :addAttackMoveType(V1)
    :addScale(VS.HEALTH_RATE)
    :when(V2, 1, buff():addEffectRemoveOnReset())
-- 付与対象がブレイク中(185) / 非ボス(v1=0)orボス(v1≠0)限定(294)
SCRIPT_ID[294] = buff()
    :switch(V1, { [0] = buff():addGrantTargetBossFilter(1) }, buff():addGrantTargetBossFilter(2))
-- DEBUG併走比較が構造的に不成立（C++がsetTime0→Luaが参照消失で別経路）＋ref不在フォールスルーが近似。
-- refBuffMode=3/4のC++実装は残置（inert）。詳細はproject_damageup_ai_cond_5017.md参照。
SCRIPT_ID[296] = unconditionalWithSideEffect("addCondition仕込み")
SCRIPT_ID[297] = trigger("全体SP付与ワンショット")
-- v5=1で常時。自分HP%がv1〜v2かつ属性v3（v4=1なら自分属性/それ以外は技属性）のとき
SCRIPT_ID[299] = buff()
    :whenNot(V5, 1, buff()
        :addHolderHpRange(V1, V2)
        :switch(V4, { [1] = buff():addHolderElement(V3) }, buff():addAttackElement(V3)))
-- 相手属性v2（6=無属性）ゲート＋v1=物理/魔法/クリの択一
SCRIPT_ID[304] = buff()
    :addAttackMoveType(V1)
    :addEnemyElementOpt(V2)
SCRIPT_ID[306] = trigger("被弾時デバフ付与機構")
-- 相手の攻撃技属性v2（0=不問）＋v1=物理/魔法/クリの択一
SCRIPT_ID[308] = buff()
    :addAttackMoveType(V1)
    :whenNot(V2, 0, buff():addAttackElement(V2))
-- v2=物理/魔法/クリの択一
SCRIPT_ID[312] = buff():addAttackMoveType(V2)
SCRIPT_ID[313] = SCRIPT_ID[312]
-- 相手の属性がv1以外のとき
SCRIPT_ID[316] = buff():addEnemyElementExclude(V1)
-- v2=物理/魔法/クリの択一ゲート（0=常時。v1は判定未使用）
SCRIPT_ID[317] = buff():addAttackPhysMagCrit(V2)
-- 付与時の経過時間ゲート（319: v1以下 / 320: v1より上）
SCRIPT_ID[319] = buff():addGrantTime(V1, 0)
SCRIPT_ID[320] = buff():addGrantTime(V1, 3)
-- 相手の種族がv1/v2/v3のいずれかのとき
SCRIPT_ID[322] = buff():addAttackAttributeOpt(V4)
-- baseId一致かつHP%がv4〜v5かつクリティカル時
SCRIPT_ID[331] = buff()
    :addHolderHpRange(V4, V5)
    :addHolderBaseIds(V1, V2, V3)
    :addAttackCritical()
SCRIPT_ID[332] = trigger("クリ時SP加算(一度きり)")
-- HP%しきい値（v5=1で常時、v1=0自分/1相手、v2=0以上/1以下、v4=しきい値）
SCRIPT_ID[333] = buff()
    :whenNot(V5, 1, buff():switch(V2,
        { [0] = buff():switch(V1, { [0] = buff():addHolderHpMin(V4) }, buff():addEnemyHpMin(V4)) },
        buff():switch(V1, { [0] = buff():addHolderHpMax(V4) }, buff():addEnemyHpMax(V4))))
-- ⑨連続使用（別バフ参照・enabling＋属性スワップ）: v4別バフのvalue2==1で発動＋RoR＋保持者属性一致でvalue3へ
SCRIPT_ID[334] = buff()
    :addRefBuffMode(2)
    :addAttackSkillSwitch(V1)
    :addEffectRemoveOnResetOnPass()
-- baseId一致かつHP%がv4〜v5かつクリティカル時
SCRIPT_ID[335] = buff()
    :addHolderBaseIds(V1)
    :addAttackAttributeOpt(V2)
-- ⑨連続使用（別バフ参照・enabling・347と同型）
SCRIPT_ID[339] = buff()
    :addRefBuffMode(1)
    :addAttackSkillSwitch(V1)
    :addEffectRemoveOnResetOnPass()
-- 種別スイッチ（skill必須・case10なし=10はskill存在のみ）＋v2=1なら入口RoR（ゲート不成立でも使い切り化）
SCRIPT_ID[342] = buff()
    :addAttackSkillSwitchNo10(V1)
    :when(V2, 1, buff():addEffectRemoveOnReset())
-- ⑨連続使用ギミック（別バフ参照）: v4の別バフのvalue2==1で発動＋その別バフにRoR。不在時はskill種別v1ゲート＋自己RoR
SCRIPT_ID[347] = buff()
    :addRefBuffMode(1)
    :addAttackSkillSwitch(V1)
    :addEffectRemoveOnResetOnPass()
    :addGrantTargetElement(V2)
    :when(V5, 1, buff():addGrantTargetElementNegate())
-- 入口RoR（無条件・使い切り）＋id_8型スイッチ（v1: 0/8素通り・1/2/7）＋物魔v2(0=不問)
SCRIPT_ID[350] = buff()
    :addEffectRemoveOnReset()
    :switch(V1, {
        [0] = buff(),
        [8] = buff(),
        [1] = buff():addAttackSTypeBits(2 ^ 1),
        [2] = buff():addAttackSTypeBits(2 ^ 2),
        [7] = buff():addAttackSTypeBits(2 ^ 2):addAttackSkillFlag(1),
    }, buff():addNever("getSkillTypeと一致し得ない値"))
    :addAttackAttributeOpt(V2)
-- 相手属性×相手の攻撃技属性の有利相性（id_27と同一実体・付与時に対象種族v1をチェック。v5=1で否定）
SCRIPT_ID[353] = buff()
    :addGrantTargetRace(V1)
    :when(V5, 1, buff():addGrantTargetRaceNegate())
    :addEnemyElementAdvantage(1)
-- HP%がv1〜v2のとき
SCRIPT_ID[357] = SCRIPT_ID[160]
-- 属性v3ゲート（v2=0:自分/1:相手、v4=1で否定。RoRはeffectで再現。v1≠0はスキル種別ゲート＝バトルはLua実行）
SCRIPT_ID[361] = buff()
    :addEffectRemoveOnReset()
    :switch(V2, { [1] = buff():switch(V4, { [1] = buff():addEnemyElementExclude(V3) }, buff():addEnemyElement(V3)) },
                  buff():switch(V4, { [1] = buff():addHolderElementExclude(V3) }, buff():addHolderElement(V3)))
    :whenNot(V1, 0, buff():addAttackCategoryScript(V1))
-- 自分の種族がv1/v2/v3/v4以外のとき
SCRIPT_ID[363] = buff():addHolderRaceExclude(V1, V2, V3, V4)
-- 監査正規表現の強化（setIsPassive/setNumber/setParameter/setBurstPoint等）で検出した副作用script（2026-07-24）
-- パッシブ解除トリック（冪等な自己フラグ→effectとして構造化・バトル評価で再現される）
SCRIPT_ID[364] = buff()   -- PvP時1/3の値補正が残るためLua実行
    :addSideEffect("setIsPassive解除")
    :addValueCalc()
-- 自分の種族がv1/v2/v3/v4以外のとき
SCRIPT_ID[370] = buff():addAttackAttribute(V2)
-- v2=物理/魔法/クリの択一（v1は判定未使用）
SCRIPT_ID[372] = buff():addAttackMoveType(V2)
-- 自分属性がv1ならvalue、それ以外はv2を返す（else側が0でないためバトルはLua実行。AIは属性ゲート＋生値近似）
SCRIPT_ID[374] = buff()
    :addHolderElement(V1)
    :addValueCalc()
-- 常時valueを返す（付与時はアイテムスロット管理の複雑判定）
SCRIPT_ID[376] = buff():addGrantNote("アイテムスロット使用管理（要個別確認）")
-- 常時valueを返す（付与時に対象属性v1をチェック。v5=1で否定）
SCRIPT_ID[377] = buff()
    :addGrantTargetElement(V1)
    :when(V5, 1, buff():addGrantTargetElementNegate())
-- 同上（v1=1なら常時扱い）
SCRIPT_ID[378] = buff()
    :whenNot(V1, 1, buff():addHolderNoBadStatusExceptType(V3):addAttackPhysMagCrit(V2))
-- v2=1なら自HPMAX×生値%、それ以外は生値
SCRIPT_ID[389] = buff():when(V2, 1, buff():addScale(VS.HP_MAX_VALUE_PERCENT))
-- 相手の種族がv1/v2/v3のいずれかのとき
SCRIPT_ID[394] = SCRIPT_ID[322]
-- 入口RoR（使い切り）＋敵チーム奥義中なら効果量+v1（不成立でも生値）
SCRIPT_ID[395] = buff()
    :addScale(VS.ENEMY_TEAM_BURST_ADD, V1)
    :addEffectRemoveOnReset()
-- v3=物魔クリ、v4=自分属性(6=無属性)、v5=技属性の択一（v3≠0で分岐消費）
SCRIPT_ID[400] = buff()
    :pickFirst({
        { V3, buff():addAttackMoveType(V3) },
        { V4, buff():addHolderElementOpt(V4) },
        { V5, buff():addAttackElementOpt(V5) },
    })
-- 奥義ゲージがv1以下のとき（v2≠0なら常時）
SCRIPT_ID[401] = buff():when(V2, 0, buff():addHolderGaugeMax(V1))
-- floor(保持者HP%×v3×0.1)をv2〜v1にクランプした値に置換
SCRIPT_ID[402] = buff():addScale(VS.SELF_HP_STEP, V3, V1, V2)
-- 持続量=(自HPMAX×v1% + v2)×rate（プレイヤー/アリーナ/PvPは×10。生値不使用）
SCRIPT_ID[405] = buff():addScale(VS.HP_MAX_PERCENT_ADD, V1, V2)
-- 相手がv1状態を保持しているとき
SCRIPT_ID[409] = buff()
    :addEnemyCondition(V1)
    :addEffectRemoveOnReset()
-- 自分の種族がv1のとき（パッシブ解除トリック付き・与ダメ17で実使用あり）
SCRIPT_ID[410] = buff()
    :addAttackMoveType(V3)
    :addSideEffect("setValue/setPriority")
    :addValueCalc()
-- 相手の種族がv1〜v5のいずれかのとき
SCRIPT_ID[412] = buff():addEnemyRace(V1, V2, V3, V4, V5)
-- v3=ActiveBattleSkill基準の種別スイッチ（0=常時。Lua実体に10のcaseが無いため10はskill存在のみ）
SCRIPT_ID[414] = buff():whenNot(V3, 0, buff():addAttackSkillSwitchNo10(V3))
-- 常時valueを返す（付与時に対象種族v1/属性v2＋caster≠targetをチェック）
SCRIPT_ID[416] = buff()
    :whenNot(V1, 0, buff():addGrantTargetRace(V1))
    :whenNot(V2, 0, buff():addGrantTargetElement(V2))
    :addGrantCasterNotTarget()
-- v3が6以上なら物魔クリ択一(6物理/7魔法/8クリ)、それ以外は常時
SCRIPT_ID[419] = buff():addAttackMoveTypeShift6(V3)
-- v3またはv1の物理/魔法/クリ択一（moveTypeそのもの）
SCRIPT_ID[420] = buff():addAttackMoveType(V3)
SCRIPT_ID[423] = buff():addScale(VS.GRANDBATTLE_DOT_GUARD, V1, V2)
-- v3またはv1の物理/魔法/クリ択一（moveTypeそのもの）
SCRIPT_ID[424] = buff():addAttackMoveType(V1)
SCRIPT_ID[426] = SCRIPT_ID[420]
SCRIPT_ID[427] = SCRIPT_ID[420]
-- v3=物理/魔法/クリの択一
SCRIPT_ID[428] = buff():addAttackMoveType(V3)
-- v3またはv1の物理/魔法/クリ択一（moveTypeそのもの）
SCRIPT_ID[429] = SCRIPT_ID[424]
-- v2=物理/魔法/クリの択一（428とは別実体）
SCRIPT_ID[430] = buff():addAttackMoveType(V2)
-- 常時valueを返す（付与時に対象種族v1/属性v2をチェック。v3=1で否定）
SCRIPT_ID[431] = buff()
    :whenNot(V1, 0, buff():addGrantTargetRace(V1))
    :whenNot(V2, 0, buff():addGrantTargetElement(V2))
    :when(V3, 1, buff():addFact("grant", "targetNegate", true))
-- 種別スイッチ＋「相手が状態v2 or 自分が状態v3」＋RoR（自分/相手またぎOR状態は表現不能＝Lua実行）
SCRIPT_ID[432] = buff()
    :addAttackCategoryScript(V1)
    :addSideEffect("setRemoveOnResetState")
-- 常時valueを返す（付与時に対象属性v3(or0)をチェック＋v4=1で自分除外）
-- 付与時＝対象属性v3(0=不問)＋(v4=1でcaster≠target)＋経過時間v1と比較（v2: 0以下/1以上/2未満/他より上）
SCRIPT_ID[442] = buff()
    :whenNot(V3, 0, buff():addGrantTargetElement(V3))
    :when(V4, 1, buff():addGrantCasterNotTarget())
    :addGrantTime(V1, V2)
SCRIPT_ID[444] = buff()
    :addHolderBaseIds(V1)
    :addAttackAttributeOpt(V2)
-- 状態保持ゲート（29: 対象がID未保持 / 39: 対象がtype保持 / 449: 発動者がID未保持(v1≠0時)）
SCRIPT_ID[449] = buff():whenNot(V1, 0, buff():addGrantCasterLackCondId(V1))
-- 真奥義(3)orアルビオン(6)のとき
SCRIPT_ID[452] = buff():addAttackDTypeBits(DTYPE_ITEM_SUMMON)
-- v1>0のとき種別スイッチ＋成立時のみRoR＝使い切り。v1<=0は常時（RoRなし）
SCRIPT_ID[453] = buff():whenPositive(V1, buff():addAttackSkillSwitch(V1):addEffectRemoveOnResetOnPass())
-- 常時valueを返す（付与時はHP範囲v2〜v3＋属性v5の複雑判定）
SCRIPT_ID[454] = buff():addGrantNote("HP範囲＋属性の付与時判定（要個別確認）")
SCRIPT_ID[456] = buff():addAttackAttributeOpt(V2)
-- 物理魔法がv1のとき（0=常時）
SCRIPT_ID[459] = buff():addAttackAttributeOpt(V1)
-- 入口RoR（使い切り）＋敵チーム奥義中なら効果量+v1（不成立でも生値）
SCRIPT_ID[463] = unconditionalWithSideEffect("addCondition仕込み(464)")
SCRIPT_ID[464] = trigger("バフ配布ワンショット")
-- クリティカル時（RoRはeffectで再現。v1≠0はスキル種別ゲート＝バトルはLua実行）
SCRIPT_ID[468] = buff()
    :addAttackCritical()
    :addEffectRemoveOnReset()
    :whenNot(V1, 0, buff():addAttackCategoryScript(V1))
-- v5=物理/魔法/クリの択一（対象v1=自分/相手は保持者近似）
SCRIPT_ID[469] = buff():addAttackMoveType(V5)
-- v1=種別スイッチ＋v2物魔クリ/v3自属性(6=無)/v4技属性(6=無)/v5自種族の択一（516の亜種）
SCRIPT_ID[471] = buff()
    :whenNot(V1, 0, buff():addAttackSkillSwitch(V1))
    :pickFirst({
        { V2, buff():addAttackMoveType(V2) },
        { V3, buff():addHolderElementOpt(V3) },
        { V4, buff():addAttackElementOpt(V4) },
        { V5, buff():addHolderRace(V5) },
    })
-- 516と同型の択一（種別ゲートなし版）: v2=物魔クリ、v3=自分属性(6=無)、v4=技属性(6=無)、v5=自分種族
SCRIPT_ID[472] = buff()
    :pickFirst({
        { V2, buff():addAttackMoveType(V2) },
        { V3, buff():addHolderElementOpt(V3) },
        { V4, buff():addAttackElementOpt(V4) },
        { V5, buff():addHolderRace(V5) },
    })
-- v2が1〜5なら相手属性、6以上は物魔クリ択一(6物理/7魔法/8クリ) ※実行にaddConditionの副作用あり
SCRIPT_ID[473] = buff()
    :pickFirst({
        { V2, buff():addEnemyElement(V2), values = { 1, 2, 3, 4, 5 } },
        { V2, buff():addAttackMoveTypeShift6(V2) },
    })
    :addSideEffect("addCondition")
-- v4≠0: 装備/召喚を除外した上でActiveBattleSkill種別スイッチ（1スキル/2奥義/7真奥義/8PB/9超奥義/10真or超）
-- v4=0かつv5≠0: 装備/召喚のみ　v4=0かつv5=0: ゲートなし（id_476）
SCRIPT_ID[476] = buff()
    :switch(V4, { [0] = buff():whenNot(V5, 0, buff():addAttackDTypeBits(DTYPE_ITEM_SUMMON)) },
                  buff():addAttackDTypeBits(DTYPE_EXCEPT_ITEM_SUMMON):addAttackSkillSwitch(V4))
-- 常時valueを返す（付与時はPvP除外＋wave使用管理）
SCRIPT_ID[478] = buff():addGrantNote("PvP除外＋wave使用管理（要個別確認）")
-- v3が6以上なら物魔クリ択一(6物理/7魔法/8クリ)、それ以外は常時
SCRIPT_ID[482] = buff():addAttackMoveTypeShift6(V3)
-- 入口RoR（使い切り）＋敵チーム奥義中なら効果量+v1（不成立でも生値）
SCRIPT_ID[488] = unconditionalWithSideEffect("addCondition仕込み(238系)")
-- id_xxx未定義（スマート編成由来の記述のまま維持）
SCRIPT_ID[489] = buff()
    :addHolderBaseIds(V4, V5)
    :addNotes("id_xxx未定義")
    :whenNot(V2, 0, buff():addHolderRace(V2))
    :whenNot(V3, 0, buff():addHolderElement(V3))
-- v2=スキル種別ゲート＋相手HP%がv3以上(v4=0)/以下(v4=1)のとき
SCRIPT_ID[511] = buff()
    :addAttackCategoryScript(V2)
    :addSideEffect("setRemoveOnResetState")
    :switch(V4, { [0] = buff():addEnemyHpMin(V3) }, buff():addEnemyHpMax(V3))
-- v2=スキル種別ゲート＋相手（攻撃対象）ブレイク中のとき（id_512はancestorOther:isBreak基準）
SCRIPT_ID[512] = buff()
    :addAttackCategoryScript(V2)
    :addEnemyBreaking()
    :addSideEffect("setRemoveOnResetState")
-- v5=物理/魔法/クリの択一ゲート（v1=1時のHP依存値加工は生値近似）
SCRIPT_ID[513] = buff()
    :addAttackMoveType(V5)
    :addApprox("HP依存値加工は生値")
    :addSideEffect("setRemoveOnResetState")
-- v1=スキル種別ゲート、v2=物魔クリ、v3=自属性(6=無)、v4=技属性(6=無)、v5=自種族の択一
SCRIPT_ID[516] = buff()
    :whenNot(V1, 0, buff():addAttackSkillSwitch(V1))
    :pickFirst({
        { V2, buff():addAttackPhysMagCrit(V2), values = { 1, 2, 3 } },
        { V3, buff():addHolderElementOpt(V3) },
        { V4, buff():addAttackElementOpt(V4) },
        { V5, buff():addHolderRace(V5) },
    })
-- 入口RoR（使い切り）＋敵チーム奥義中なら効果量+v1（不成立でも生値）
SCRIPT_ID[520] = buff():addDynamicValue():addSideEffect("addCondition仕込み(238系)")
-- v1=スキル種別ゲート＋v2=物理/魔法/クリの択一（v2=0は常に0を返すため不成立）
-- v3=2/3で入口RoR（使い切り）＋種別スイッチv1（v1=0はゲートなし）＋物魔クリ択一v2（v2=0は常に0）
SCRIPT_ID[528] = buff()
    :switch(V2, { [0] = buff():addNever("v2=0は常に0") }, buff():addAttackMoveType(V2))
    :whenPositive(V1, buff():addAttackSkillSwitch(V1))
    :switch(V3, { [2] = buff():addEffectRemoveOnReset(), [3] = buff():addEffectRemoveOnReset() })
-- 猛毒/猛炎: 生値＋v1×(経過t/v2)^2（v1,v2>0時のみ。それ以外は生値）
SCRIPT_ID[601] = buff():whenPositive(V1, buff():whenPositive(V2, buff():addScale(VS.TIME_GROWTH, V1, V2)))
SCRIPT_ID[602] = SCRIPT_ID[601]
-- クリティカル時（スキル中ゲートは判定未使用）
SCRIPT_ID[1022] = buff()
    :addAttackCritical()
    :addSideEffect("setRemoveOnResetState")
-- 自分の種族がv1のとき（パッシブ解除トリック付き・与ダメ17で実使用あり）
SCRIPT_ID[1043] = buff()       -- ゲージ加算トリガー
    :addTrigger()
    :addSideEffect("setBurstPoint")
SCRIPT_ID[1872] = trigger("wave管理・自己削除＋再付与")
-- クリティカル時かつ相手（攻撃対象）ブレイク中（id_2022はother基準。限定クラスはクリ優先で不変）
SCRIPT_ID[2022] = buff()
    :addAttackCritical()
    :addEnemyBreaking()
-- クリティカル時かつ自分ブレイク中（被ダメ系）
SCRIPT_ID[2023] = buff()
    :addAttackCritical()
    :addHolderBreaking()
-- 相手自身がブレイク中のとき（other基準！ボス基準ではない。RoRはeffectで再現。v1≠0はDamageAffectInfo種別ゲート）
SCRIPT_ID[2024] = buff()
    :addEnemyBreaking()
    :addEffectRemoveOnReset()
    :addAttackDTypeEq(V1)
-- baseId一致かつクリティカル時
SCRIPT_ID[2235] = buff()
    :addHolderBaseIds(V1)
    :addAttackCritical()
-- 自分の種族がv1のとき（パッシブ解除トリック付き・与ダメ17で実使用あり）
SCRIPT_ID[2262] = buff()
    :addHolderRace(V1)
    :addEffectUnsetPassive()
-- 経過時間がvalue3以内（しきい値は付与時にsetValue3(条件のtime)で書き込まれる）かつ
-- 技属性v1（0=不問）・物魔v2（0=不問）のとき。id_2263
SCRIPT_ID[2263] = buff()
    :addElapsedTimeMax(V3)
    :addAttackElementOpt(V1)
    :addAttackAttributeOpt(V2)
-- バトルfast path稼働検知用の第2センチネル（常時型・Lua実体なし）。
-- fast path稼働中はDEBUG併走が必ず不一致ログを出す（sem=生値 vs lua=0）
SCRIPT_ID[9999998] = unconditional
-- 実機テスト用センチネル（実マスタに存在しないscriptId。このエントリが判定に効いていれば
-- Lua変換表が実機で読めている証明になる。ai_judge_test.py が使用。パリティ検証からは除外）
local SENTINEL_ID = 9999999
SCRIPT_ID[SENTINEL_ID] = buff():addAttackCritical()

-- ==== 備考 ====
-- ※id_470（v4で効果の符号が反転する）は生値符号で判定できないため意図的に未対応＝script実行フォールバック
---------------------------------------------------------------
-- AIビュー: SEMANTICS → ConditionEffectMask のフィールドテーブル
---------------------------------------------------------------

local function maskFromSemantics(f)
    local m = {}
    if f.trigger or f.never then
        m.skillAttribute = 0
    end
    local h = f.holder
    if h then
        if h.element then m.holderElement = only(h.element) end
        if h.elementNone then m.holderElement = only(0); m.holderElementAllowNone = true end
        if h.elementExclude then m.holderElement = setBit(FLAG_ALL, h.elementExclude, false); m.holderElementAllowNone = true end
        if h.race then m.holderRace = includeBits(h.race) end
        if h.raceExclude then m.holderRace = excludeBits(h.raceExclude); m.holderRaceAllowNone = true end
        if h.baseIds then m.holderBaseIds = baseIds(h.baseIds[1], h.baseIds[2], h.baseIds[3]) end
        if h.hpMin then m.holderHpMin = h.hpMin end
        if h.hpMax then m.holderHpMax = h.hpMax end
        if h.hpMaxExclusive then m.hpMaxExclusive = true end
        if h.conditionType1 then m.holderConditionType1 = h.conditionType1 end
        if h.conditionType2 then m.holderConditionType2 = h.conditionType2 end
        if h.badStatus then m.requireHolderBadStatus = true end
        if h.noBadStatusExceptType then m.holderNoBadStatusExceptType = h.noBadStatusExceptType end
        if h.breaking then m.requireHolderBreak = true end
        if h.gaugeMax then m.holderGaugeMax = h.gaugeMax end
        if h.unitState then m.unitStateGate = h.unitState end
        if h.teamBaseIds then m.allyBaseIds = baseIds(h.teamBaseIds[1], h.teamBaseIds[2], h.teamBaseIds[3]) end
    end
    local e = f.enemy
    if e then
        if e.element then m.enemyElement = only(e.element) end
        if e.elementNone then m.enemyElement = only(0); m.enemyElementAllowNone = true end
        if e.elementExclude then m.enemyElement = setBit(FLAG_ALL, e.elementExclude, false); m.enemyElementAllowNone = true end
        if e.race then m.enemyRace = includeBits(e.race) end
        if e.raceExclude then m.enemyRace = excludeBits(e.raceExclude); m.enemyRaceAllowNone = true end
        if e.hpMin then m.enemyHpMin = e.hpMin end
        if e.hpMax then m.enemyHpMax = e.hpMax end
        if e.hpMaxExclusive then m.hpMaxExclusive = true end
        if e.conditionType1 then m.enemyConditionType1 = e.conditionType1 end
        if e.conditionType2 then m.enemyConditionType2 = e.conditionType2 end
        if e.conditionNegate then m.enemyConditionNegate = true end
        if e.bossBreaking then m.requireEnemyBossBreak = true end
        if e.breaking then m.requireEnemyBreak = true end
        if e.size then m.enemySizeOnly = e.size end
        if e.burstActive then m.requireEnemyBurstActive = true end
        if e.elementAdvantage then m.elementAdvantage = e.elementAdvantage end
        if e.gaugeMax then m.enemyGaugeMax = e.gaugeMax end
        if e.teamBurstActive then m.requireEnemyTeamBurstActive = true end
        if e.conditionScriptId then m.enemyConditionScriptId = e.conditionScriptId end
        if e.bossFilter then m.enemyBossFilter = e.bossFilter end
        if e.dTypeBits then m.enemyDTypeBits = e.dTypeBits end
        if e.dTypeBossExtraBits then m.enemyDTypeBossExtraBits = e.dTypeBossExtraBits end
        if e.conditionGroupId then
            m.enemyConditionGroupId = e.conditionGroupId
            m.enemyConditionValueMin = e.conditionValueMin or 0
            m.enemyConditionValueSlot = e.conditionValueSlot or 0
        end
    end
    if f.dynamicValue then m.dynamicValue = true end
    if f.effect then
        if f.effect.removeOnReset then m.effectRemoveOnReset = true end
        if f.effect.removeOnResetOnPass then m.effectRemoveOnResetOnPass = true end
        if f.effect.unsetPassive then m.effectUnsetPassive = true end
    end
    -- 付与判定（grant時）→ apply*。付与対象target/発動者casterの静的属性等をevaluateGrantが評価する。
    local g = f.grant
    if g then
        if g.targetElement then m.applyTargetElement = only(g.targetElement) end
        if g.targetElementNegate then m.applyTargetElementNegate = true end
        if g.targetRace then m.applyTargetRace = includeBits(type(g.targetRace) == "table" and g.targetRace or { g.targetRace }) end
        if g.targetRaceNegate then m.applyTargetRaceNegate = true end
        if g.targetSexuality then m.applyTargetSexuality = g.targetSexuality end
        if g.targetHpMin then m.applyTargetHpMin = g.targetHpMin end
        if g.targetHpMax then m.applyTargetHpMax = g.targetHpMax end
        if g.targetBaseIds then m.applyTargetBaseIds = baseIds(g.targetBaseIds[1], g.targetBaseIds[2], g.targetBaseIds[3]) end
        if g.casterRace then m.applyCasterRace = includeBits(type(g.casterRace) == "table" and g.casterRace or { g.casterRace }) end
        if g.casterElement then m.applyCasterElement = only(g.casterElement) end
        if g.bossBreak then m.applyBossBreak = true end
        if g.bossNotBreak then m.applyBossNotBreak = true end
        if g.bossBreakRateMax then m.applyBossBreakRateMax = g.bossBreakRateMax end
        if g.targetBossFilter then m.applyTargetBossFilter = g.targetBossFilter end
        if g.targetBreaking then m.applyTargetBreaking = true end
        if g.targetHasCondType then m.applyTargetHasCondType = g.targetHasCondType end
        if g.targetLackCondId then m.applyTargetLackCondId = g.targetLackCondId end
        if g.casterLackCondId then m.applyCasterLackCondId = g.casterLackCondId end
        if g.casterNotTarget then m.applyCasterNotTarget = true end
        if g.timeThreshold then m.applyGrantTimeThreshold = g.timeThreshold; m.applyGrantTimeMode = g.timeMode or 0 end
    end
    if f.refBuffMode then m.refBuffMode = f.refBuffMode end
    local a = f.attack
    if a then
        if a.categoryBits then m.skillCategoryType = a.categoryBits end
        if a.attribute then m.skillAttribute = only(a.attribute) end
        if a.attributeExclude then m.skillAttribute = setBit(FLAG_ALL, a.attributeExclude, false) end
        if a.critical then m.criticalOnly = true end
        if a.element then m.skillElement = only(a.element) end
        if a.elementNone then m.skillElement = only(0) end
        if a.dTypeBits then m.attackDTypeBits = a.dTypeBits end
        if a.sTypeBits then m.attackSTypeBits = a.sTypeBits end
        if a.skillFlag then m.attackSkillFlag = a.skillFlag end
        if a.requireSkill then m.requireActiveSkill = true end
    end
    local b = f.battle
    if b then
        if b.excludeArena then m.excludeArena = true end
        if b.elapsedTimeMax then m.elapsedTimeMax = b.elapsedTimeMax end
    end
    if f.scale then
        m.valueScale = f.scale.type
        m.scaleParam1 = f.scale.p1 or 0
        m.scaleParam2 = f.scale.p2 or 0
        m.scaleParam3 = f.scale.p3 or 0
    end
    return m
end

---------------------------------------------------------------
-- 公開関数
---------------------------------------------------------------

-- scriptId＋valueから「このバフが何であるか」の事実テーブルを返す（未対応はnil）。
-- エントリは buff()ビルダー（V1〜V5を実値に置換）か function(v1..v5)（従来形）の2形式。
-- スマート編成/ダメージ計算の統合時はこの関数の上に各自のビューを実装する
function getConditionSemantics(scriptId, v1, v2, v3, v4, v5)
    local f = SCRIPT_ID[scriptId]
    if not f then return nil end
    local vs = { v1 or 0, v2 or 0, v3 or 0, v4 or 0, v5 or 0 }
    if type(f) == "table" and f.__isBuff then
        return resolveBuff(f, vs)
    end
    local sem = f(vs[1], vs[2], vs[3], vs[4], vs[5])
    if type(sem) == "table" and sem.__isBuff then
        return resolveBuff(sem, vs)
    end
    return sem
end

-- AI判定ビュー: scriptId→マスク変換の入口。未対応scriptIdは nil（C++側がフォールバック判断）
function getConditionMask(scriptId, v1, v2, v3, v4, v5)
    local sem = getConditionSemantics(scriptId, v1, v2, v3, v4, v5)
    if not sem then return nil end
    return maskFromSemantics(sem)
end

-- バトル処理（ダメージ計算・DoT等）でLua実行の代わりにマスク評価してよいか。
-- 条件: EVAL_METHODでbattle="mask"かつ、副作用なし・近似なし・特殊判定なし・
-- 効果量が生値orスケール式・スキル種別ゲートなし
-- （スキル種別のランタイム対応は未整備のためcategoryBits付きは対象外）。
-- falseのものは従来通りid_xxxをLua実行する（挙動維持）。
function getBattleExact(scriptId, v1, v2, v3, v4, v5)
    if methodFor("battle", scriptId) == "lua" then return false end
    local sem = getConditionSemantics(scriptId, v1, v2, v3, v4, v5)
    if not sem then return false end
    -- never（moveType範囲外値等の「常に0」）はマスク評価が0を正確に再現するため対象に含める
    if sem.sideEffect or sem.approx or sem.special or sem.trigger or sem.valueCalc then
        return false
    end
    if sem.attack and sem.attack.categoryBits then return false end
    return true
end

-- 付与判定（addCondition）を新方式（grant事実のマスク評価=evaluateGrant）で行ってよいか。
-- EVAL_METHODのgrant設定に従う。falseならC++は従来どおりLuaの付与ディスパッチャを実行する
function getGrantEnabled(scriptId)
    return methodFor("grant", scriptId) == "mask"
end

-- 対応scriptId一覧（パリティ検証・デバッグ用。テスト用センチネルは含めない）
function getConditionMaskScriptIds()
    local ids = {}
    for k in pairs(SCRIPT_ID) do
        if k < 9000000 then ids[#ids + 1] = k end   -- テスト用センチネル(9999998/9999999)は除外
    end
    table.sort(ids)
    return ids
end
