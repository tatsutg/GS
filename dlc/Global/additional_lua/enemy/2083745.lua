-- 自動生成: CML2ギミック草案.md 魔獣ベルギラス【EX1】の行動ルーティンのみ → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "魔獣ベルギラス", version = 2.8, id = 2083745 }

-- 出典: 実装33本共通: start の setSkin("normal")
boss:add(C.KindBelgirus{})

-- 出典: EX1 の行動ルーティン: スキル2 -> スキル1 -> スキル4 -> スキル3 -> 繰り返し
boss:add(C.Attack{ sets = { { 2 }, { 1 }, { 4 }, { 3 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "skill1", [6] = "skill2" } })

-- 出典: EX1 の行動ルーティン: 奥義5 -> 奥義6 -> 繰り返し
boss:add(C.Smash{ sets = { { 5 }, { 6 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "skill1", [6] = "skill2" } })

boss:publish()
