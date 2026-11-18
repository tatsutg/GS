-- 自動生成: quest_md/9900052_EP7プルートゥ.md → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "グランドバトルEP7_エリアボス_妖魔マールム", version = 1.1, id = "gb_702103" }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: attack_delay=4.0（Lua）
boss:add(C.Start{ C.SetAttackDelay{ 4 } })

-- 出典: ステータス: HP=ボスのHPの1/20・防御力500
boss:add(C.Start{ function(self, e) local team = megast.Battle:getInstance():getTeam(false); for i = 0, 6 do local u = team:getTeamUnit(i); if u ~= nil and u:getSize() == 3 then local hp = u:getCalcHPMAX() / 20; e.unit:setBaseHP(hp); e.unit:setHP(hp) end end; e.unit:setBaseDefence(500) end })

-- 出典: 行動パターン: スキル2 → スキル3 → 繰り返し（モーションはどちらも skill1。スキル1 は企画回答で除外）
boss:add(C.Attack{ sets = { { 2 }, { 3 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill1" } })

-- 出典: 物理ダメージに対して 被ダメ ×[1÷(3+階層×0.05)]
boss:add(C.Defense{
  { attackerAttribute = "physical", mult = function(self, e) return 1 / (3 + megast.Battle:getInstance():getCurrentGrandBattleFloor() * 0.05) end },
})

boss:publish()
