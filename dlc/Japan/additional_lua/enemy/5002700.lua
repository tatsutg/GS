-- 自動生成: ハロウィンジュノーお試しクエストギミック草案.md 冥蝕竜マヴロスギア／お試しクエスト → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "おためしクエスト_冥蝕竜マヴロスギア_ハロウィンジュノー", version = 2.8, id = 5002700 }

-- 出典: 戦闘開始時: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 戦闘開始時: addSP=20（Lua。spine addSP イベント同期・大型ボス定型）
boss:add(C.SpineSPGain{ value = 20 })

-- 出典: 竜種の共有ギミック。火球は attack1 用（今回のローテでは attack1 を使わないので発火しない）
boss:add(C.KindDragon{ fire = {  } })

-- 出典: ギミック: HPは常に自然回復する／60秒間死なない（修行の間の自由訓練 100151201 の setHP(myHP) 方式）
boss:add(C.SuperRegen{})

-- 出典: 戦闘開始時: attack_delay=6（Lua）/ 開幕INFO（黄）2種（表示秒数は既定の7秒）
boss:add(C.Start{ C.SetAttackDelay{ 6 }, C.Say{ key = "START_MESSAGE1", text = "超回復" }, C.Say{ key = "START_MESSAGE2", text = "60秒で耐久してクリア" } })

-- 出典: スキル：スキル3 -> スキル1 or スキル2 -> 繰り返し
boss:add(C.Attack{ sets = { { 3 }, { 1, 2 } }, anim = { [1] = "attack2", [2] = "attack3", [3] = "attack4", [4] = "skill1", [5] = "skill2" } })

-- 出典: 奥義：奥義4 -> 奥義5 -> 繰り返し
boss:add(C.Smash{ sets = { { 4 }, { 5 } }, anim = { [1] = "attack2", [2] = "attack3", [3] = "attack4", [4] = "skill1", [5] = "skill2" } })

-- 出典: ギミック: 60秒経過でクエストクリア（修行の間の自由訓練 100151201 の時限処理。表示位置はサンドバッグ実績値＝先例と同一）
boss:add(C.SurviveClear{ seconds = 60, redtime = 10, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

-- [データ] HP 100,000,000、攻撃力2,000、**防御力2,000**、break_capacity 200,000、break_power 50、damage_drop_sp 20 は本番マスタ側（確認済み: enemy_master.csv id=5002700。草案と全て一致。防御力は 2026-10-26 に 500 から修正済み）。skill_relation_master は relation_type=2 が5本登録済み・relation_type=4（アビリティ）は0件。（マスタ設定・Choreo外）

boss:publish()
