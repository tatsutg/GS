-- 自動生成: CML③ギミック草案.md 熾紅フロガスピサ【EX1】から HPトリガーを除外した派生（quest 2084410 / enemy 2084445） → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "幻炎の大鳥", version = 2.8, id = 2084445 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=15（Lua）。EX1(2084460) と同値
boss:add(C.AttackSPGain{ value = 15 })

-- 出典: attack_delay=8（Lua）。EX1 と同値
boss:add(C.Start{ C.SetAttackDelay{ 8 } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2 or スキル3） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2, 3 } }, anim = { [1] = "attack4", [2] = "attack5", [3] = "attack6", [4] = "skill2", [5] = "skill3" } })

-- 出典: 奥義：奥義4 -> 繰り返し
boss:add(C.Smash{ sets = { { 4 } }, anim = { [1] = "attack4", [2] = "attack5", [3] = "attack6", [4] = "skill2", [5] = "skill3" } })

-- [データ] break_capacity 15,000、damage_drop_sp 20、攻撃力500、防御力800、HP 5,000,000、level 70、size 1 は本番マスタ側（確認済み: enemy_master.csv id=2084445）。⚠ 状態異常耐性は全て0（EX1 の暗闇/麻痺/病気200・気絶50・氷結30 とは異なる）。⚠ 奥義ゲージ低下耐性(60006800)は 2084445 には未登録なので abilities に載せていない（マスタ設定・Choreo外）

boss:publish()
