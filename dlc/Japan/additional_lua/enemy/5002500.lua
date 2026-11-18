-- 自動生成: ヴォルフリートお試しクエストギミック草案.md 静聖神パルラミシア／お試しクエスト → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "おためしクエスト_静聖神パルラミシア_ヴォルフリート", version = 2.8, id = 5002500 }

-- 出典: 戦闘開始時: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 戦闘開始時: addSP=40（Lua。spine addSP イベント同期・大型ボス定型）
boss:add(C.SpineSPGain{ value = 40 })

-- 出典: ギミック: HPは常に自然回復する／60秒間死なない（修行の間の自由訓練 100151201 の setHP(myHP) 方式）
boss:add(C.SuperRegen{})

-- 出典: 戦闘開始時: attack_delay=4（Lua）/ 戦闘開始時奥義ゲージ60（Lua）/ 開幕INFO（黄）2種（表示秒数は既定の7秒）
boss:add(C.Start{ C.SetAttackDelay{ 4 }, C.GainSP{ 60 }, C.Say{ key = "START_MESSAGE1", text = "超回復" }, C.Say{ key = "START_MESSAGE2", text = "60秒で耐久してクリア" } })

-- 出典: スキル：スキル3 -> スキル1 -> スキル2 -> 繰り返し
boss:add(C.Attack{ sets = { { 3 }, { 1 }, { 2 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack9", [4] = "skill1" } })

-- 出典: 奥義：奥義4 -> 繰り返し
boss:add(C.Smash{ sets = { { 4 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack9", [4] = "skill1" } })

-- 出典: ギミック: 60秒経過でクエストクリア（修行の間の自由訓練 100151201 の時限処理。表示位置はサンドバッグ実績値＝先例と同一）
boss:add(C.SurviveClear{ seconds = 60, redtime = 10, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

-- [データ] HP 100,000,000、攻撃力2,000、防御力500、break_capacity 200,000、damage_drop_sp 20 は本番マスタ側（確認済み: enemy_master.csv id=5002500。草案と全て一致）。奥義4の「20秒間、敵の物理耐性20%DOWN」もデータ側（skill_effect_master 88809501: effect_type=21 / value=20 / time=20 / script_id=2 物理攻撃時 / target=4 敵）＝Lua では実装しない。アビリティ（relation_type=4）は0件。（マスタ設定・Choreo外）

boss:publish()
