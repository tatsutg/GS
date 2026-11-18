-- 自動生成: シャルヴァレサマーギミック草案.md デイリー節 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "虚月のマ女", version = 1.2, id = 2082795 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 旧テンプレ規約: addSP 運用時は自然上昇0
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=25（Lua）
boss:add(C.AttackSPGain{ value = 25 })

-- 出典: attack_delay=7（Lua）／ 開幕INFO
boss:add(C.Start{ C.SetAttackDelay{ 7 }, C.Say{ key = "START_MESSAGE1", text = "……", color = C.Color.yellow } })

-- 出典: スキル：スキル3 -> スキル2 -> スキル1 -> 繰り返し
boss:add(C.Attack{ sets = { { 3 }, { 2 }, { 1 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 奥義：奥義4 -> 繰り返し。sets値=スロット番号(need_level)
boss:add(C.Smash{ sets = { { 4 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 虚月のマ女戦闘不能時（黄）
boss:add(C.Dead{ actions = { C.Say{ key = "DEAD_MESSAGE1", text = "……", color = C.Color.yellow } } })

boss:publish()
