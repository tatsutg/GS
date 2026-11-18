-- 自動生成: ChatWork Lua板 2134119417976860672 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "プリズマイリヤ前編_クロエ（魔血フォーム）", version = 1.2, id = 2083015 }

-- 出典: テンプレ定型: 受動的SP獲得を停止（addSPはAttackSPGainで加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: テンプレ定型: 通常攻撃ごとにaddSP=20（奥義直後スキップ）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: 通常攻撃: attack1 → skill1 → 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2" } })

-- 出典: 奥義: skill2 繰り返し
boss:add(C.Smash{ sets = { { 3 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2" } })

boss:publish()
