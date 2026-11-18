-- 自動生成: quest_md/9900055_EP7スティーリア.md → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "グランドバトルEP7_エリアボス_氷玉精スティーリア", version = 1.3, id = "gb_704601" }

-- 出典: 戦闘開始時: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 戦闘開始時: addSP=30（Lua）
boss:add(C.SpineSPGain{ value = 30 })

-- 出典: 戦闘開始時: attack_delay=8.0（Lua）＋ INFO
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ key = "START_MESSAGE1", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE2", text = "全体付与のCRI率アップ・防御無視効果無効" }, C.Say{ key = "START_MESSAGE3", text = "CRI耐性ダウン無効" }, C.Say{ key = "START_MESSAGE4", text = "HP減少でオーブが点灯：毒状態時消灯", color = C.Color.white } })

-- 出典: EP 共通ギミック: 180秒の時間制限。タイムアップで敗北（表示は gb_605601 と同じ）
boss:add(C.TimeLimit{ seconds = 180, redtime = 30, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

-- 出典: 行動パターン: スキル1 → スキル2 → スキル3 → スキル4 → 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 3 }, { 4 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "skill1", [6] = "skill2", [7] = "skill2" } })

-- 出典: 行動パターン: 奥義5 → 奥義6 → 繰り返し ／ 奥義5・6のたびに与ダメージ10%UP（グラバト共通 6000100）
boss:add(C.Smash{ sets = { { 5 }, { 6 } }, onUse = { [5] = { C.StackBuff{ id = 6000100, type = 17, value = 10, max = 99, icon = 26 } }, [6] = { C.StackBuff{ id = 6000100, type = 17, value = 10, max = 99, icon = 26 } } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "skill1", [6] = "skill2", [7] = "skill2" } })

-- 出典: ギミック②: 自身のHPが5%減ると3つの玉のうち1つが点灯（MAX3）／一定時間内に15%以上削れた場合3つすべて点灯
boss:add(C.Orbs{ positions = { { -200, 360 }, { 200, 360 }, { 0, 410 } }, hpStep = 5, burst = { percent = 15, seconds = 10 }, levels = { [1] = { onEnter = { C.SetAttackDelay{ 4 }, C.AttachBuff{ id = 70460101, type = 61, value = { base = 50, perFloor = 1 }, time = 99999, icon = 38, group = -1 }, C.Say{ key = "ORB1_MESSAGE1", text = "行動速度アップ・炎属性耐性アップ" } }, onExit = { C.SetAttackDelay{ 8 }, C.RemoveBuff{ id = 70460101 }, C.Say{ key = "ORB1_MESSAGE2", text = "行動速度アップ・炎属性耐性アップ：解除", color = C.Color.red } } }, [2] = { onEnter = { C.AttachBuff{ id = 70460102, type = 23, value = { base = -20, perFloor = -0.2 }, time = 99999, icon = 188, group = -1 }, C.SetSpineSPGain{ 35 }, C.Say{ key = "ORB2_MESSAGE1", text = "被CRI率耐性・奥義ゲージ上昇量アップ" } }, onExit = { C.RemoveBuff{ id = 70460102 }, C.SetSpineSPGain{ 30 }, C.Say{ key = "ORB2_MESSAGE2", text = "被CRI率耐性・奥義ゲージ上昇量アップ：解除", color = C.Color.red } } }, [3] = { onEnter = { C.AttachBuff{ id = 70460103, type = 17, value = { base = 30, perFloor = 1 }, time = 99999, icon = 26, group = -1 }, C.AttachBuff{ id = 70460104, type = 7, value = { base = 50000, perFloor = 5000 }, time = 99999, icon = 35, group = -1 }, C.Say{ key = "ORB3_MESSAGE1", text = "ダメージアップ・HP自然回復" } }, onExit = { C.RemoveBuff{ id = 70460103 }, C.RemoveBuff{ id = 70460104 }, C.Say{ key = "ORB3_MESSAGE2", text = "ダメージアップ・HP自然回復：解除", color = C.Color.red } } } } })

-- 出典: ギミック②: 自身が毒状態になる度に3つの玉のうち1つが消灯
boss:add(C.OnStatus{ key = "poison", types = { 90 }, actions = { C.UnlightOrbs{ 1 } } })

-- 出典: ギミック②: 自身が毒状態になる度に毒耐性5%アップ（最大10回まで）
boss:add(C.OnStatus{ key = "poisonResist", types = { 90 }, max = 10, actions = { C.StackBuff{ id = 70460105, type = 53, value = 5, max = 10, icon = 59, group = -1 }, C.StackBuff{ id = 70460106, type = 102, value = 5, max = 10, icon = 0, group = -1 }, C.Say{ key = "POISON_MESSAGE1", text = "毒耐性アップ" } } })

-- 出典: HPトリガーは発動から打ち終わるまでブレイク不可（無敵中ロック）
boss:add(C.Break{ lockWhileInvincible = true })

-- 出典: HP20%: 防御力[700+階層×30]%UP・真奥義カットインで奥義7／スキップ不可・直前の奥義ゲージを引き継ぐ
boss:add(C.Phases{
  { at = 20, stop = true, deferWhileSkill = true, actions = { C.Invincible{ seconds = 30 }, C.AttachBuff{ id = 70460107, type = 15, value = { base = 700, perFloor = 30 }, time = 99999, icon = 5 }, C.Say{ key = "HP20_MESSAGE1", text = "防御力アップ" }, C.UseSkill{ index = 7, cutin = C.Cutin.TrueArts, keepGauge = true } } },
})

-- 出典: HPフラグ奥義（奥義7）を打ち終わったら無敵解除
boss:add(C.SkillFinishWatch{ onSkill = { 7 }, onFinish = { C.Invincible{ seconds = 0 } } })

boss:publish()
