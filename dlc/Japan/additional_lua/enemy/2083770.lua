-- 自動生成: CML2ギミック草案.md 魔獣ベルギラス【EX2】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "魔獣ベルギラス", version = 2.8, id = 2083770 }

-- 出典: addSP=30（Lua）／実装33本共通: start の setSkin("normal")
boss:add(C.KindBelgirus{ spineSP = 30 })

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: attack_delay=6（Lua）／INFO 戦闘開始時（黄）：奥義ゲージ低下耐性
boss:add(C.Start{ C.SetAttackDelay{ 6 }, C.Say{ key = "START_MESSAGE1", text = "奥義ゲージ低下耐性" } })

-- 出典: スキル：スキル2 -> スキル1 -> スキル4 -> スキル3 -> 繰り返し
boss:add(C.Attack{ sets = { { 2 }, { 1 }, { 4 }, { 3 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "skill1", [6] = "skill2" } })

-- 出典: 奥義：奥義5 -> 奥義6 -> 繰り返し
boss:add(C.Smash{ sets = { { 5 }, { 6 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "skill1", [6] = "skill2" } })

-- 出典: HP50%：真奥義カットインで奥義6を発動（※上記のトリガーはスキップ可）
boss:add(C.Phases{
  { at = 50, actions = { C.UseSkill{ index = 6, cutin = C.Cutin.TrueArts } } },
})

-- [データ] 奥義ゲージ低下耐性100%（下の abilities で紐づけ）、毒/病気/燃焼/暗闇耐性0%、氷結耐性30%、気絶耐性50%、その他200%、break_capacity 100,000、damage_drop_sp 20 は本番マスタ側（確認済み: enemy_master.csv id=2083770）（マスタ設定・Choreo外）

boss:publish()
