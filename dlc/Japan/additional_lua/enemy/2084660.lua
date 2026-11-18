-- 自動生成: ガチアクタ前半ギミック.md ヒューマ【EX1】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "鉄砕風紀委員長ヒューマ", version = 1.2, id = 2084660 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=10（Lua）
boss:add(C.AttackSPGain{ value = 10 })

-- 出典: attack_delay=8（Lua）／開始INFO
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ color = C.Color.magenta, key = "START_MESSAGE1", text = "法規は金剛石よりも硬く！" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "奥義ゲージ低下耐性" } })

-- 出典: スキル：スキル1 -> スキル2 -> スキル3 -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 3 } }, onUse = { [3] = { C.Say{ color = C.Color.magenta, key = "SKILL3_MESSAGE1", text = "これぞ、正義の翼である！！" }, C.Say{ color = C.Color.yellow, key = "SKILL3_MESSAGE2", text = "一定時間、回避率アップ" } } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 奥義：奥義4 -> 繰り返し
boss:add(C.Smash{ sets = { { 4 } }, cutin = { [4] = C.Cutin.Arts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: HP50%：真奥義カットインで奥義4発動（スキップ可・直前の奥義ゲージを引き継ぐ）
boss:add(C.Phases{
  { at = 50, actions = { C.UseSkill{ index = 4, cutin = C.Cutin.TrueArts, keepGauge = true }, C.Say{ color = C.Color.magenta, key = "HP50_MESSAGE1", text = "秩序こそが世界のすべてだ！！" } } },
})

-- 出典: 戦闘不能時（紫）：セリフ
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.magenta, key = "DEAD_MESSAGE1", text = "私が負ければ、学園…は……" } } })

-- [データ] 奥義ゲージ低下耐性100%、毒・病気・燃焼・暗闇耐性0%、氷結耐性30%、気絶耐性50%、その他の状態異常耐性200%、break_capacity 60000、damage_drop_sp 20 は本番マスタ側（enemy_master.csv id=2084660）（マスタ設定・Choreo外）

boss:publish()
