-- 自動生成: lua_claude_tool Phase1 JSON → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "イリス（サマー）", version = 1.2, id = 2082763 }

-- 出典: gd_config.hitStop
boss:add(C.NoHitStop{})

-- 出典: 旧テンプレ規約: addSP 運用時は自然上昇0
boss:add(C.SPGain{ value = 0 })

-- 出典: gd_config.addSP=15（通常攻撃ごとSP加算・奥義直後スキップ）
boss:add(C.AttackSPGain{ value = 15 })

-- 出典: gd_config / start_skill / 開幕INFO / start適用バフ
boss:add(C.Start{ C.SetAttackDelay{ 8 } })

-- 出典: attack_patterns（DEFAULT）
boss:add(C.Attack{ sets = { { 2 }, { 1 }, { 1 }, { 1 }, { 1 } }, onUse = { [2] = { C.Say{ key = "SKILL2_MESSAGE1", text = "スキルCT速度大幅アップ", color = C.Color.white, side = "player" } } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: skill_patterns（DEFAULT）/ cut_in_skills。sets値=スロット番号(need_level)に統一・activeSkills廃止
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 死亡時INFO / 撃破でクリア（clearWave=残存敵も倒す）
boss:add(C.Dead{ actions = { C.Say{ key = "DEAD_MESSAGE1", text = "疲れちゃった…", color = C.Color.red } } })

boss:publish()
