-- 自動生成: ガチアクタ前半ギミック.md ミーナス【真EX】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "爆烈転校生ミーナス", version = 2.5, id = 2084680 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: CreateExtraTimer を使うためのマネージャ宣言
boss:add(C.ExtraTimer{})

-- 出典: attack_delay=6（Lua）／開始INFO／状態異常でない場合クリティカル率50%アップ／エクストラタイマー開始
boss:add(C.Start{ C.SetAttackDelay{ 6 }, C.Say{ color = C.Color.red, key = "START_MESSAGE1", text = "オレの名を知ってるか？" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE3", text = "人族・炎・光属性ユニットからの被ダメージアップ" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE4", text = "状態異常でない場合、ボスのクリティカル率アップ" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE5", text = "一定時間が経過するたびに、ボスのCRIダメージアップ" }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208468001, type = 22, value = 50, time = 999999, icon = 0, group = -1, script = { id = 261, v1 = 0, v2 = 0, v3 = 0 } }, C.CreateExtraTimer{ key = "power", maxTime = 20, loopLimit = 99, icon = { 26, 0 }, onRound = { C.StackBuff{ id = 208468002, type = 17, value = 10, max = 99, icon = 26, group = -1, script = { id = 22, v1 = 0, v2 = 0 } } }, speedRules = { { when = { breaking = true }, speed = 0 }, { when = { smashing = true }, speed = 0 } } } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 繰り返し
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, cutin = { [3] = C.Cutin.Arts, [4] = C.Cutin.TrueArts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: HP50%トリガー中の状態（被ダメージ×0.2・状態異常無効）
boss:add(C.Mode{ initial = "normal", states = { normal = {  }, trigger = { onEnter = { C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208468011, type = 112, value = 1000 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208468012, type = 113, value = 1000 } }, onExit = { C.RemoveBuff{ id = 208468011 }, C.RemoveBuff{ id = 208468012 } } } } })

-- 出典: HP50%：真奥義カットインで奥義4発動（ブレイク中でも発動・直前の奥義ゲージを引き継ぐ）
boss:add(C.Phases{
  { at = 50, actions = { function(self, e) self._hpTrigPending = true; self._hpTrigActive = true end, C.SetMode{ "trigger" }, C.UseSkill{ index = 4, cutin = C.Cutin.TrueArts, keepGauge = true }, C.Say{ color = C.Color.red, key = "HP50_MESSAGE1", text = "テメーのコブシは…“純”じゃねえンだよ！！！" } } },
})

-- 出典: HP50%の奥義4を撃ち終わったら trigger 状態を解除
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = { C.SetMode{ "normal" } } })

-- 出典: HP50%トリガー中（mode=trigger）は TakeDamageValue×0.2
boss:add(C.Defense{
  { mult = 0.2, mode = "trigger" },
})

-- 出典: 戦闘不能時（赤）：セリフ
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.red, key = "DEAD_MESSAGE1", text = "チッ…もうダメか…" } } })

-- [データ] 反射耐性100%、奥義ゲージ低下耐性100%、HP吸収耐性100%、炎・光属性ユニットからの被ダメージ50%アップ、人族ユニットからの被ダメージ50%アップ、麻痺・凍結・気絶・毒・病気0%、暗闇耐性30%、その他状態異常耐性70%、break_capacity 150000、damage_drop_sp 20 は本番マスタ側（enemy_master.csv id=2084680）（マスタ設定・Choreo外）

boss:publish()
