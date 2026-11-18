-- 自動生成: ? → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "覚醒ギンゾウ", version = 1.2, id = 2084183 }

boss:add(C.NoHitStop{})

boss:add(C.SPGain{ value = 0 })

boss:add(C.AttackSPGain{ value = 20 })

boss:add(C.Start{ C.SetAttackDelay{ 7 } })

boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3b" }, animeff = { [4] = "skill3b" } })

boss:add(C.Smash{ sets = { { 3 }, { 3 }, { 4 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3b" }, animeff = { [4] = "skill3b" } })

-- [データ] （マスタ設定・Choreo外）

boss:publish()
