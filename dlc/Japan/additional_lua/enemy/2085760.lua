-- 自動生成: ハロウィンジュノー_ギミック.md 聖女ジュノー【EX1】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "聖女ジュノー（ハロウィンver）", version = 1.2, id = 2085760 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=15（Lua）
boss:add(C.AttackSPGain{ value = 15 })

-- 出典: attack_delay=8（Lua）／開始INFO
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE1", text = "ハッピーハロウィーン！！" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下耐性" } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 奥義：奥義3 -> 繰り返し
boss:add(C.Smash{ sets = { { 3 } }, cutin = { [3] = C.Cutin.Arts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: HP50%：奥義カットインで奥義4を発動（スキップ可）
boss:add(C.Phases{
  { at = 50, actions = { C.UseSkill{ index = 4, cutin = C.Cutin.Arts }, C.Say{ color = C.Color.yellow, key = "HP50_MESSAGE1", text = "激しく行くわよっ！" } } },
})

-- 出典: 死亡時（黄）：やられたー！　あなた、強いのね！
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.yellow, key = "DEAD_MESSAGE1", text = "やられたー！　あなた、強いのね！" } } })

-- [データ] 反射耐性100%・奥義ゲージ低下耐性100%・HP吸収耐性100%（skill_relation_master relation_type=4: 60006700/60006800/60006600）、毒・病気・燃焼・暗闇耐性0%、氷結耐性30%、気絶耐性50%、その他の状態異常耐性200%、break_capacity 60000、damage_drop_sp 20 は本番マスタ側（enemy_master.csv id=2085760）（マスタ設定・Choreo外）

boss:publish()
