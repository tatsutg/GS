-- 自動生成: 草案_ハロウィンKoB後編_EX1～真EX極.md 赤月王ヴォックス【EX2】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "赤月王ヴォックス（ハロウィンver）", version = 2.5, id = 2086070 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: CreateExtraTimer を使うためのマネージャ宣言（⚠ これが無いと onRound が配線されない）
boss:add(C.ExtraTimer{})

-- 出典: attack_delay=8（Lua）／開始INFO／ブラッディ・ムーン（30秒タイマー）開始
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ color = C.Color.magenta, key = "START_MESSAGE1", text = "かかってくるがよい、勇者たちよ。" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "反射・奥義ゲージ低下耐性" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE3", text = "一定時間ごとに、与えたダメージを吸収" }, C.CreateExtraTimer{ key = "bloodymoon", maxTime = 30, loopLimit = 999, icon = { 0, 0 }, onRound = { C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208607001, type = 70, value = 100, time = 10, icon = 18, group = -1 }, C.GainSP{ target = C.Targeting{ pick = "self" }, value = 100 }, C.Say{ color = C.Color.magenta, key = "MOON_MESSAGE1", text = "暗黒よ、我が敵を喰らえ。" } }, speedRules = { { when = { breaking = true }, speed = 0 } } } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 奥義：奥義3 -> 繰り返し
boss:add(C.Smash{ sets = { { 3 } }, cutin = { [3] = C.Cutin.Arts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: HP50%：奥義カットインで奥義4を発動（スキップ可）
boss:add(C.Phases{
  { at = 50, actions = { C.UseSkill{ index = 4, cutin = C.Cutin.Arts }, C.Say{ color = C.Color.magenta, key = "HP50_MESSAGE1", text = "赤月の僕たちよ…その身を断罪の刃と化せーー！" } } },
})

-- 出典: 死亡時（紫）：フハハ…良かろう、今宵はここまでだ…（仮）
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.magenta, key = "DEAD_MESSAGE1", text = "フハハ…良かろう、今宵はここまでだ…" } } })

-- [データ] 反射耐性100%・奥義ゲージ低下耐性100%（HP吸収耐性は 2026-11-05 にやめた）、毒・病気・燃焼・暗闇耐性0%、氷結耐性30%、気絶耐性50%、その他の状態異常耐性200%、break_capacity 100000、damage_drop_sp 20 は本番マスタ側（enemy_master.csv id=2086070。反射・ゲージの耐性は skill_relation_master relation_type=4 に未登録）（マスタ設定・Choreo外）

boss:publish()
