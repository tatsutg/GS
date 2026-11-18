-- 自動生成: lua_claude_tool Phase1 JSON → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "フェン（サマー）", version = 1.2, id = 2082760 }

-- 出典: gd_config.hitStop
boss:add(C.NoHitStop{})

-- 出典: 旧テンプレ規約: addSP 運用時は自然上昇0
boss:add(C.SPGain{ value = 0 })

-- 出典: gd_config.addSP=30（通常攻撃ごとSP加算・奥義直後スキップ）
boss:add(C.AttackSPGain{ value = 30 })

-- 出典: gd_config / start_skill / 開幕INFO / start適用バフ
boss:add(C.Start{ C.SetAttackDelay{ 6 }, C.Say{ key = "START_MESSAGE1", text = "来い、遊んでやろう。", color = C.Color.cyan }, C.Say{ key = "START_MESSAGE2", text = "わくわくウキウキ♪", color = C.Color.red } })

-- 出典: attack_patterns（DEFAULT）
boss:add(C.Attack{ sets = { { 1 }, { 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: skill_patterns（DEFAULT）/ cut_in_skills。sets値=スロット番号(need_level)に統一・activeSkills廃止
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: hp_triggers
boss:add(C.Phases{
  { at = 50, stop = true, actions = { C.UseSkill{ index = 5 }, C.Say{ key = "HP50_MESSAGE1", text = "この波を待っていた！", color = C.Color.cyan } } },
})

-- 出典: 死亡時INFO / 撃破でクリア（clearWave=残存敵も倒す）
boss:add(C.Dead{ clearWave = true, actions = { C.Say{ key = "DEAD_MESSAGE1", text = "遊び過ぎたか…", color = C.Color.cyan } } })

boss:publish()
