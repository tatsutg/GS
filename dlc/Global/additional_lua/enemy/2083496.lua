-- 自動生成: プリヤ後半ギミック草案.md ダメージバトル／征龍『皇雅』 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "征龍『皇雅』", version = 1.2, id = 2083496 }

-- 出典: 全て語尾が_Nのモーションを使用する
boss:add(C.AnimVariant{ initial = "N", variants = { N = "_N" }, apply = { idle = "idle", back = "idle", damage = "damage" } })

-- 出典: 原典 unit/501811213.lua 準拠（update で立ち位置を開幕位置に固定）
boss:add(C.LockPosition{})

-- 出典: 戦闘開始時: addSP=10（Lua。spine の runScript-addSP で加算・大型ボス定型）
boss:add(C.SpineSPGain{ value = 10 })

-- 出典: 超回復（修行の間 自由訓練のようにダメージで死ぬことはない）
boss:add(C.SuperRegen{})

-- 出典: 戦闘開始時: attack_delay=12.0（Lua）／静止ポーズ Setup_X ／開幕INFO（黄・既定色）2種
boss:add(C.Start{ C.SetAttackDelay{ 12.0 }, C.SetSetupAnim{ "Setup_X" }, C.Say{ key = "START_MESSAGE1", text = "超回復" }, C.Say{ key = "START_MESSAGE2", text = "コラボユニットのダメージアップ" } })

-- 出典: スキル: スキル1 -> スキル2 -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "attack5", [6] = "skill1", [7] = "skill2" }, animeff = { [3] = "Roar_R", [4] = "Roar_G", [5] = "Roar_B" } })

-- 出典: 奥義: 奥義6（喰月夜行）-> 奥義7（朧死々哮）-> 繰り返し
boss:add(C.Smash{ sets = { { 6 }, { 7 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "attack5", [6] = "skill1", [7] = "skill2" }, animeff = { [3] = "Roar_R", [4] = "Roar_G", [5] = "Roar_B" } })

-- 出典: プリヤコラボユニット以外のダメージは takeDamageValue 補正×0.5
boss:add(C.Defense{
  { mult = 0.5, attackerBaseID = { 847, 848, 849, 850, 773, 774, 775, 776, 777, 778, 797, 798, 799, 800, 801, 802 }, negate = true },
})

-- 出典: 60秒経過でクエストクリア
boss:add(C.SurviveClear{ seconds = 60, redtime = 30, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

boss:publish()
