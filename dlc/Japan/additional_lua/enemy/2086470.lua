-- 自動生成: サイバーマンシー5_EX1～真EX極.md 葬魂神オルデウス【EX2】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "葬魂神オルデウス", version = 1.2, id = 2086470 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は SpineSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua。spine の addSP イベントに合わせて加算）
boss:add(C.SpineSPGain{ value = 20 })

-- 出典: 奥義5 骸骨魂の骸骨弾（spine skill2 の runScript-skull。1回2発・HPなし・弾の技は奥義5）
boss:add(C.KindOrdeus{ skull = { count = 2, orbitHP = 0, skill = 5 } })

-- 出典: attack_delay=8（Lua）／開始INFO（黄）：反射・奥義ゲージ低下耐性
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE1", text = "反射・奥義ゲージ低下耐性" } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2 or スキル3） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2, 3 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack4", [4] = "skill1", [5] = "skill2" } })

-- 出典: 奥義：奥義4 -> 繰り返し（奥義5はHP50%でだけ発動する）
boss:add(C.Smash{ sets = { { 4 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack4", [4] = "skill1", [5] = "skill2" } })

-- 出典: HP50%：真奥義カットインで奥義5を発動（スキップ可）
boss:add(C.Phases{
  { at = 50, actions = { C.UseSkill{ index = 5, cutin = C.Cutin.TrueArts } } },
})

-- [データ] 反射耐性100%・奥義ゲージ低下耐性100%（アビリティ 60006700／60006800 は skill_relation_master relation_type=4 に未登録）、毒・病気・燃焼・暗闇耐性0%・氷結耐性30%・気絶耐性50%・その他の状態異常耐性200%、HP 1,600,000・break_capacity 100,000・damage_drop_sp 20 は本番マスタ側（enemy_master.csv id=2086470。⚠ 防御力はマスタ 100 ／ 草案 500）。地面衝撃（30%・10秒）・千魂共鳴（50%・10秒）の暗闇（命中率30%ダウン）はデータの技効果（マスタ設定・Choreo外）

boss:publish()
