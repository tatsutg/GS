-- 自動生成: 仕様書 冥蝕竜マヴロスギア.md → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "おためしクエスト_冥蝕竜マヴロスギア", version = 1.2, id = 5000205 }

-- 出典: 戦闘開始時: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 戦闘開始時: addSP=20（Lua。spine addSP イベント同期・大型ボス定型）
boss:add(C.SpineSPGain{ value = 20 })

-- 出典: 竜種の共有ギミック。火球は attack1 用（今回のローテでは未使用）
boss:add(C.KindDragon{ fire = {  } })

-- 出典: HPは常に自然回復する／60秒間死なない（修行の間の自由訓練 100151201 の setHP(myHP) 方式）
boss:add(C.SuperRegen{})

-- 出典: 戦闘開始時: attack_delay=6（Lua）/ 開幕INFO（黄）3種（表示秒数は既定の7秒）
boss:add(C.Start{ C.SetAttackDelay{ 6 }, C.Say{ key = "START_MESSAGE1", text = "超回復" }, C.Say{ key = "START_MESSAGE2", text = "60秒で耐久してクリア" }, C.Say{ key = "START_MESSAGE3", text = "クリティカル耐性" } })

-- 出典: スキル: スキル3 -> (スキル1 or スキル2) -> 繰り返し
boss:add(C.Attack{ sets = { { 3 }, { 1, 2 } }, anim = { [1] = "attack2", [2] = "attack3", [3] = "attack4", [4] = "skill1", [5] = "skill2" } })

-- 出典: 奥義: 奥義4 -> 奥義5 -> 繰り返し
boss:add(C.Smash{ sets = { { 4 }, { 5 } }, anim = { [1] = "attack2", [2] = "attack3", [3] = "attack4", [4] = "skill1", [5] = "skill2" } })

-- 出典: 60秒経過でクエストクリア（修行の間の自由訓練 100151201 の時限処理を Component 化）
boss:add(C.SurviveClear{ seconds = 60, redtime = 10, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

boss:publish()
