-- 自動生成: CML③ギミック草案.md 熾紅フロガスピサ【EX2】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "熾紅フロガスピサ", version = 2.8, id = 2084470 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: attack_delay=8（Lua）／INFO 戦闘開始時（黄）：奥義ゲージ低下耐性
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ key = "START_MESSAGE1", text = "奥義ゲージ低下耐性" } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2 or スキル3） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2, 3 } }, anim = { [1] = "attack4", [2] = "attack5", [3] = "attack6", [4] = "skill2", [5] = "skill3" } })

-- 出典: 奥義：奥義4 -> 繰り返し
boss:add(C.Smash{ sets = { { 4 } }, anim = { [1] = "attack4", [2] = "attack5", [3] = "attack6", [4] = "skill2", [5] = "skill3" } })

-- 出典: HP50%：真奥義カットインで奥義5を発動（※上記のトリガーはスキップ可）
boss:add(C.Phases{
  { at = 50, actions = { C.UseSkill{ index = 5, cutin = C.Cutin.TrueArts } } },
})

-- [データ] 奥義ゲージ低下耐性100%（下の abilities で紐づけ）、毒/病気/燃焼/暗闇耐性0%、氷結耐性30%、気絶耐性50%、その他200%、break_capacity 100,000、damage_drop_sp 20 は本番マスタ側（確認済み: enemy_master.csv id=2084470）（マスタ設定・Choreo外）

boss:publish()
