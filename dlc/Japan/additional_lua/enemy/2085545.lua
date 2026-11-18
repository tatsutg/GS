-- 自動生成: 【EX1】2085560 の行動順のみ（草案なし） → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "CODE XTF:ERASER", version = 2.8, id = 2085545 }

-- 出典: ヒットストップ・時止め無効（Lua。EX1 と同じボス定型）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は SpineSPGain で加算。EX1 と同じ）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=15（Lua。spine addSP イベント同期・大型ボス定型。EX1 と同じ）
boss:add(C.SpineSPGain{ value = 15 })

-- 出典: 常に攻撃モード・形態変化なし（EX1 と同じ）。待機/後退/被弾/退場のアニメ名を攻撃モードのものに固定する
boss:add(C.XtfForm{ initial = "attack" })

-- 出典: スキル1 ミサイル（attack4 の spine missile イベントで主砲からミサイル。当たり判定は弾側）
boss:add(C.XtfMissile{})

-- 出典: スキル3 サブアームビーム（attack5 の aim で砲身照準 → laserHit2 で着弾オービット。当たり判定は着弾側）
boss:add(C.XtfLaser{})

-- 出典: スキン Nomal 適用（装甲・両腕・バリアハンドの描画に必須）／attack_delay=8（EX1 と同じ行動間隔）
boss:add(C.Start{ C.SetSkin{ "Nomal" }, C.SetAttackDelay{ 8 } })

-- 出典: EX1 の行動順: スキル1 -> スキル2 -> （スキル1 or スキル2 or スキル3） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2, 3 } }, anim = { [1] = "attack4", [2] = "attack6", [3] = "attack5", [4] = "skill5" } })

-- 出典: EX1 の行動順: 奥義4 -> 繰り返し
boss:add(C.Smash{ sets = { { 4 } }, anim = { [1] = "attack4", [2] = "attack6", [3] = "attack5", [4] = "skill5" } })

-- [データ] HP 5,000,000、攻撃力500、防御力800、break_capacity 15,000、break_power 50、damage_drop_sp 20、skill_invocation_weight 50、need_sp 100 はすべて本番マスタ側（確認済み: enemy_master.csv id=2085545）。状態異常耐性はすべて0。アビリティ（relation_type=4）は0件＝耐性アビリティ無し。（マスタ設定・Choreo外）

boss:publish()
