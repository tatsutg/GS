-- 自動生成: プリヤ後半ギミック草案.md クロエ（魔血フォーム）EX1 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "クロエ（魔血フォーム）", version = 1.2, id = 2083460 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSPはAttackSPGainで加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=30（Lua）
boss:add(C.AttackSPGain{ value = 30 })

-- 出典: attack_delay=6（Lua）／開幕INFO
boss:add(C.Start{ C.SetAttackDelay{ 6 }, C.Say{ color = C.Color.cyan, key = "START_MESSAGE1", text = "斬決のサビにしてあげる" }, C.Say{ text = "燃焼・奥義ゲージ低下耐性" } })

-- 出典: スキル：スキル1 -> スキル2 -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 奥義：奥義3 -> 繰り返し。奥義3は奥義カットインで発動する
boss:add(C.Smash{ sets = { { 3 } }, cutin = { [3] = C.Cutin.Arts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: HP50%：真奥義カットインで奥義4を発動（※スキップ可）
boss:add(C.Phases{
  { at = 50, actions = { C.UseSkill{ index = 4, cutin = C.Cutin.TrueArts }, C.Say{ color = C.Color.cyan, key = "HP50_MESSAGE1", text = "ここからが真骨頂" } } },
})

-- 出典: 戦闘不能時（青）：セリフ
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.cyan, key = "DEAD_MESSAGE1", text = "レディーに…なんてことを……！" } } })

-- [データ] 奥義ゲージ低下耐性100%、毒/病気/暗闇耐性0%、氷結耐性30%、気絶耐性50%、その他200%、break_capacity 60,000、damage_drop_sp 20 は本番マスタ側（確認済み: enemy_master.csv id=2083460）（マスタ設定・Choreo外）

boss:publish()
