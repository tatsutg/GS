-- 自動生成: 2026-11-16 ユーザー連絡（クエスト10のボスがヘリオルドに変更）。真EX 2086480 の技構成からギミックを外した形 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "剣客怪盗ヘリオルド", version = 1.2, id = 2086445 }

-- 出典: ヒットストップ・時止め無効（真EX と同じ）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=10（真EX と同じ。2026-11-16 ユーザー決定）
boss:add(C.AttackSPGain{ value = 10 })

-- 出典: attack_delay=8（真EX と同じ。2026-11-16 ユーザー決定）
boss:add(C.Start{ C.SetAttackDelay{ 8 } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し（真EX と同じ）
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 繰り返し（真EX と同じ）
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- [データ] HP 5,000,000・攻撃力500・防御力800・break_capacity 15,000・damage_drop_sp 20・level 70・size 1・状態異常耐性0 は本番マスタ側（確認済み: enemy_master.csv id=2086445）。耐性・被ダメージアップのアビリティ（relation_type=4）も未登録＝データ側（マスタ設定・Choreo外）

boss:publish()
