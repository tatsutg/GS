-- 自動生成: 新規ギミックシート 2026-08-21（enemy 5000300） → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "おためしクエスト_緑命竜エルプネウマス", version = 1.2, id = 5000300 }

-- 出典: 戦闘開始時: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 戦闘開始時: addSP=30（Lua。spine addSP イベント同期・大型ボス定型。5000215 の実績値を踏襲）
boss:add(C.SpineSPGain{ value = 30 })

-- 出典: 竜種の共有ギミック。火球=スキル1（attack1 の spine fire イベント）。エルプネウマスの発射角は既定321（出典2064490）
boss:add(C.KindDragon{ fire = {  } })

-- 出典: 60秒間死なない／超回復（他のおためしクエストと同じ SuperRegen。開幕HPへ常に回復）
boss:add(C.SuperRegen{})

-- 出典: 戦闘開始時: attack_delay=4（Lua）/ 開幕INFO（黄）2種（表示秒数は既定の7秒）
boss:add(C.Start{ C.SetAttackDelay{ 4 }, C.Say{ key = "START_MESSAGE1", text = "超回復" }, C.Say{ key = "START_MESSAGE2", text = "60秒で耐久してクリア" } })

-- 出典: スキル: スキル3 -> スキル4 -> (スキル1 or スキル2) -> 繰り返し
boss:add(C.Attack{ sets = { { 3 }, { 4 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "skill1", [6] = "skill2", [7] = "skill3" } })

-- 出典: 奥義: 奥義5 -> 奥義6 -> 奥義7 -> 繰り返し
boss:add(C.Smash{ sets = { { 5 }, { 6 }, { 7 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "skill1", [6] = "skill2", [7] = "skill3" } })

-- 出典: 60秒経過でクエストクリア（修行の間の自由訓練 100151201 の時限処理を Component 化。表示位置もサンドバッグ実績値）
boss:add(C.SurviveClear{ seconds = 60, redtime = 10, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

boss:publish()
