-- 自動生成: ガチアクタ後編お試しクエストギミック草案.md デグルマグナ／お試しクエスト → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "おためしクエスト_神焔竜デグルマグナ", version = 2.8, id = 5002210 }

-- 出典: 戦闘開始時: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 戦闘開始時: addSP=20（Lua。spine addSP イベント同期・大型ボス定型）
boss:add(C.SpineSPGain{ value = 20 })

-- 出典: 竜種の共有ギミック。火球=スキル1（attack1 の spine fire イベントで火球オービットを発射）
boss:add(C.KindDragon{ fire = { neckAngle = 295 } })

-- 出典: 60秒間死なない／HP1になったとき、100%まで回復する（草案。HPバーが削れる形にするため SuperRegen ではなく ReviveFull）
boss:add(C.ReviveFull{})

-- 出典: 戦闘開始時: attack_delay=6（Lua）/ 開幕INFO（黄）3種（表示秒数は既定の7秒）
boss:add(C.Start{ C.SetAttackDelay{ 6 }, C.Say{ key = "START_MESSAGE1", text = "HPが1になると回復" }, C.Say{ key = "START_MESSAGE2", text = "60秒で耐久してクリア" }, C.Say{ key = "START_MESSAGE3", text = "クリティカル耐性" } })

-- 出典: スキル：スキル3 -> スキル4 -> スキル1 or スキル2 -> 繰り返し
boss:add(C.Attack{ sets = { { 3 }, { 4 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "attack5", [6] = "skill1", [7] = "skill2" } })

-- 出典: 奥義：奥義5 -> 奥義6 -> 奥義7 -> 繰り返し
boss:add(C.Smash{ sets = { { 5 }, { 6 }, { 7 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "attack5", [6] = "skill1", [7] = "skill2" } })

-- 出典: 60秒経過でクエストクリア（修行の間の自由訓練 100151201 の時限処理。表示位置はサンドバッグ実績値＝先例と同一）
boss:add(C.SurviveClear{ seconds = 60, redtime = 10, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

-- [データ] HP 40,000,000、攻撃力2,000、防御力2,000、break_capacity 200,000、damage_drop_sp 20 は本番マスタ側（確認済み: enemy_master.csv id=5002210。草案と全て一致）。クリティカル耐性400%UP もデータ側（草案に（Lua）注記なし）＝Lua では実装せず INFO のみ（マスタ設定・Choreo外）

boss:publish()
