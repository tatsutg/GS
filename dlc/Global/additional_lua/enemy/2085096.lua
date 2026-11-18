-- 自動生成: ガチアクタ後半ギミック.md ダメージバトル／巨大ジエン → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "巨大ジエン", version = 1.2, id = 2085096 }

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=10（Lua）
boss:add(C.AttackSPGain{ value = 10 })

-- 出典: attack_delay=12.0（Lua）／見た目2倍／開始INFO
boss:add(C.Start{ C.SetAttackDelay{ 12.0 }, C.Scale{ value = 2 }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE1", text = "超回復" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "コラボユニットのダメージアップ" } })

-- 出典: 超回復（ダメージで死ぬことはない）
boss:add(C.SuperRegen{})

-- 出典: 60秒経過でクエストクリア
boss:add(C.SurviveClear{ seconds = 60, redtime = 10, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

-- 出典: スキル：スキル1 -> スキル2 -> スキル3 -> スキル2 -> スキル4 -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 3 }, { 2 }, { 4 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 奥義：奥義5 -> 繰り返し
boss:add(C.Smash{ sets = { { 5 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: ガチアクタコラボユニット以外のダメージは takeDamageValue×0.5
boss:add(C.Defense{
  { mult = 0.5, attackerBaseID = { 851, 852, 853, 854 }, negate = true },
})

-- [データ] break_capacity 100000、need_sp 100、damage_drop_sp 20、size 3 は本番マスタ側（enemy_master.csv id=2085096）（マスタ設定・Choreo外）

boss:publish()
