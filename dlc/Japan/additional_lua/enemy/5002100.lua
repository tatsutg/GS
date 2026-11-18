-- 自動生成: オニキスお試しクエストギミック草案.md フォスラディウス／お試しクエスト → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "おためしクエスト_光耀竜フォスラディウス", version = 2.8, id = 5002100 }

-- 出典: 戦闘開始時: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 戦闘開始時: addSP=30（Lua。spine addSP イベント同期・大型ボス定型）
boss:add(C.SpineSPGain{ value = 30 })

-- 出典: スキル1 火球（attack1 の spine fire イベントで火球オービットを発射）
boss:add(C.KindDragon{ fire = { neckAngle = 295 } })

-- 出典: HPは常に自然回復する／60秒間死なない（修行の間の自由訓練 100151201 の setHP(myHP) 方式）
boss:add(C.SuperRegen{})

-- 出典: 戦闘開始時: attack_delay=4（Lua）／開幕INFO（黄）2種
boss:add(C.Start{ C.SetAttackDelay{ 4 }, C.Say{ key = "START_MESSAGE1", text = "超回復" }, C.Say{ key = "START_MESSAGE2", text = "60秒で耐久してクリア" } })

-- 出典: スキル：スキル3 -> スキル4 -> スキル1 or スキル2 -> 繰り返し
boss:add(C.Attack{ sets = { { 3 }, { 4 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "attack5", [6] = "skill1", [7] = "skill2" } })

-- 出典: 奥義：奥義5 -> 奥義6 -> 奥義7 -> 繰り返し
boss:add(C.Smash{ sets = { { 5 }, { 6 }, { 7 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "attack5", [6] = "skill1", [7] = "skill2" } })

-- 出典: 60秒経過でクエストクリア（修行の間の自由訓練 100151201 の時限処理。表示位置はサンドバッグ実績値＝先例4本と同一）
boss:add(C.SurviveClear{ seconds = 60, redtime = 10, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

-- [データ] break_capacity 200,000、damage_drop_sp 20、攻撃力2,000、防御力500 は本番マスタ側（確認済み: enemy_master.csv id=5002100）。企画意図により防御力を従来の2000から500へ下げている。耐性系の指定は仕様書に無し（特殊ギミックを入れない方針）（マスタ設定・Choreo外）

boss:publish()
