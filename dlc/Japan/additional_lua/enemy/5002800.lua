-- 自動生成: ハロウィンヴォックスお試しクエストギミック草案.md フォスラディウス／お試しクエスト（2026-11-05 改訂版 第2版） → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "おためしクエスト_光耀竜フォスラディウス_ハロウィンヴォックス", version = 2.8, id = 5002800 }

-- 出典: 戦闘開始時: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 戦闘開始時: addSP=40（Lua。spine addSP イベント同期・大型ボス定型）
boss:add(C.SpineSPGain{ value = 40 })

-- 出典: 竜種の共有ギミック。火球=スキル1（attack1 の spine fire イベントで火球オービットを発射）
boss:add(C.KindDragon{ fire = { neckAngle = 295 } })

-- 出典: ギミック: HPは常に自然回復する／60秒間死なない（修行の間の自由訓練 100151201 の setHP(myHP) 方式）
boss:add(C.SuperRegen{})

-- 出典: 戦闘開始時: attack_delay=4（Lua）/ 戦闘開始時奥義ゲージ60（Lua）/ 開幕INFO（黄）2種（表示秒数は既定の7秒）
boss:add(C.Start{ C.SetAttackDelay{ 4 }, C.GainSP{ 60 }, C.Say{ key = "START_MESSAGE1", text = "超回復" }, C.Say{ key = "START_MESSAGE2", text = "60秒で耐久してクリア" } })

-- 出典: スキル：スキル1 -> スキル3 or スキル2 -> 繰り返し（2026-11-05 改訂 第2版・草案表記どおり）
boss:add(C.Attack{ sets = { { 1 }, { 3, 2 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "skill1", [5] = "skill2" } })

-- 出典: 奥義：奥義5 -> 奥義4 -> 繰り返し（2026-11-05 改訂 第2版・草案表記どおり）
boss:add(C.Smash{ sets = { { 5 }, { 4 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "skill1", [5] = "skill2" } })

-- 出典: ギミック: 60秒経過でクエストクリア（修行の間の自由訓練 100151201 の時限処理。表示位置はサンドバッグ実績値＝先例と同一）
boss:add(C.SurviveClear{ seconds = 60, redtime = 10, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

-- [データ] HP 100,000,000、攻撃力2,000、防御力500、break_capacity 200,000、break_power 50、damage_drop_sp 20、2wave構成（wave1 ピキュオン×2 unit100091411 / wave2 ボス）は本番マスタ側（確認済み: enemy_master.csv / battle_relation_master 5002801。2026-11-05 の改訂版書き出し済み）。アビリティ（relation_type=4）は0件。★草案 第2版で HP が 40,000,000 → 100,000,000 に改められ、マスタと完全一致（要確認事項は解消）。燃焼の付き先（火球・40秒・値7000）も草案どおり。（マスタ設定・Choreo外）

boss:publish()
