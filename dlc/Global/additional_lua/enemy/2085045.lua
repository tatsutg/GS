-- 自動生成: 2026-09-24 サイズ拡大指示 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "ジエン", version = 1.0, id = 2085045 }

-- 出典: 見た目を2倍に拡大（2026-09-24 指示）
boss:add(C.Start{ C.Scale{ value = 2 } })

boss:publish()
