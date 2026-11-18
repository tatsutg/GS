-- 自動生成: セティスギミック草案.md 断照の鬼武者セティス【EX2】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "断照の鬼武者セティス", version = 1.2, id = 2084170 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSPはAttackSPGainで加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: attack_delay=8（Lua）／開始INFO
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ color = C.Color.cyan, key = "START_MESSAGE1", text = "進軍開始だ" }, C.Say{ text = "奥義ゲージ低下耐性" } })

-- 出典: スキル：スキル1 -> スキル2 -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 繰り返し。奥義3は奥義カットイン、奥義4は真奥義カットインで発動
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, cutin = { [3] = C.Cutin.Arts, [4] = C.Cutin.TrueArts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: HP50%：真奥義カットインで奥義4を発動（ブレイクスルーなし＝ラインで必ず固定）
boss:add(C.Phases{
  { at = 50, stop = true, actions = { C.UseSkill{ index = 4, cutin = C.Cutin.TrueArts }, C.Say{ color = C.Color.cyan, key = "HP50_MESSAGE1", text = "道を切り拓く！" } } },
})

-- 出典: 戦闘不能時（青）：セリフ
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.cyan, key = "DEAD_MESSAGE1", text = "くっ…ここまでか…" } } })

-- [データ] 奥義ゲージ低下耐性100%、毒・燃焼・病気耐性0%、暗闇耐性30%、その他状態異常耐性100%、break_capacity 100000、damage_drop_sp 20 は本番マスタ側（enemy_master.csv id=2084170）（マスタ設定・Choreo外）

boss:publish()
