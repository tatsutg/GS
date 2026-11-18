-- 自動生成: 草案_ハロウィンKoB後編_ダメージバトル.md カボシェルム【ダメージバトル】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "カボシェルム", version = 1.2, id = 2086096 }

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=10（Lua）
boss:add(C.AttackSPGain{ value = 10 })

-- 出典: attack_delay=12（Lua）／開始INFO
boss:add(C.Start{ C.SetAttackDelay{ 12.0 }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE1", text = "超回復" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "ハロウィンユニットのダメージアップ" } })

-- 出典: 超回復（ダメージで倒れることはない）
boss:add(C.SuperRegen{})

-- 出典: 60秒経過でクエストクリア
boss:add(C.SurviveClear{ seconds = 60, redtime = 10, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

-- 出典: スキル：スキル1 -> スキル2 -> スキル3 -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 3 } }, anim = { [1] = "attack1", [2] = "attack4", [3] = "attack5", [4] = "skill1", [5] = "skill2" } })

-- 出典: 奥義：奥義4 -> 奥義5 -> 繰り返し
boss:add(C.Smash{ sets = { { 4 }, { 5 } }, anim = { [1] = "attack1", [2] = "attack4", [3] = "attack5", [4] = "skill1", [5] = "skill2" } })

-- 出典: ハロウィンユニット以外のダメージは TakeDamageValue補正×0.5
boss:add(C.Defense{
  { mult = 0.5, attackerBaseID = { 377, 378, 379, 438, 439 }, negate = true },
})

-- [データ] 奥義ゲージ低下耐性100%、状態異常耐性300%、break_capacity 100000、need_sp 100、damage_drop_sp 20、size 3 は本番マスタ側（enemy_master.csv id=2086096）。⚠ 技・アビリティは skill_relation_master に未登録（マスタ設定・Choreo外）

boss:publish()
