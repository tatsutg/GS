-- 自動生成: ガチアクタ後半ギミック.md モルク【EX1】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "モルク", version = 1.2, id = 2085060 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=10（Lua）
boss:add(C.AttackSPGain{ value = 10 })

-- 出典: attack_delay=8（Lua）／開始INFO
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ color = C.Color.cyan, key = "START_MESSAGE1", text = "喧嘩の時間だよ。夜露死苦ゥ！" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "奥義ゲージ低下耐性" } })

-- 出典: スキル：スキル1 -> スキル2 -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 奥義4（anim skill3）は本体 0.5・残り 0.5 を skill3_orbit へ委譲（味方版 takeSkill index==3 と同配分）
boss:add(C.DamageRate{ smash = { [4] = { damageRate = 0.5, breakRate = 0.5 } } })

-- 出典: 【MEGA_D-9763】奥義4（skill3）で skill3_orbit（取り分 0.5）を 1 本出す分を、ボスの技の予告に知らせる（表示専用）
boss:add(C.AnnounceOrbit{ smash = { [4] = { rate = 0.5, count = 1 } } })

-- 出典: unit/104237212.lua run: Library_skill3_orbit（奥義4のオービット）
boss:add(C.Timeline{ Library_skill3_orbit = { C.SpawnOrbit{ anim = "skill3_orbit", damageRate = 0.5, breakRate = 0.5 } } })

-- 出典: 奥義：奥義3 -> 繰り返し。奥義4 は HP50% トリガー専用（ローテには入れない）
boss:add(C.Smash{ sets = { { 3 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: HP50%：カットインなしで奥義4発動（ブレイク中でも発動・スキップ可）
boss:add(C.Phases{
  { at = 50, actions = { C.UseSkill{ index = 4, keepGauge = true }, C.Say{ color = C.Color.cyan, key = "HP50_MESSAGE1", text = "ボクらの愛の巣――" }, C.Say{ color = C.Color.cyan, key = "HP50_MESSAGE2", text = "蜘蛛の巣だ！" } } },
})

-- 出典: 戦闘不能時（水）：セリフ
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.cyan, key = "DEAD_MESSAGE1", text = "フーン、悔しくないよ。フンフンフーンだ。" } } })

-- [データ] 奥義ゲージ低下耐性100%、毒・病気・暗闇耐性0%、氷結耐性30%、気絶耐性50%、その他の状態異常耐性200%、break_capacity 60000、damage_drop_sp 20 は本番マスタ側（enemy_master.csv id=2085060）（マスタ設定・Choreo外）

boss:publish()
