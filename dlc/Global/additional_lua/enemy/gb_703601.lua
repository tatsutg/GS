-- 自動生成: quest_md/9900053_EP7デグルマグナ.md → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "グランドバトルEP7_エリアボス_神焔竜デグルマグナ", version = 2.5, id = "gb_703601" }

-- 出典: 戦闘開始時: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 戦闘開始時: addSP=25（Lua）
boss:add(C.SpineSPGain{ value = 25 })

-- 出典: 奥義6/8 は HP20% まで zcloneNskill1/2、以降 skill1/2（通常形態→炎形態）
boss:add(C.AnimVariant{ initial = "normal", variants = { normal = { prefix = "zcloneN", setup = "setUpNormal" }, fire = { setup = "setUpFire" } }, setupAtStart = true })

-- 出典: スキル1 火球: spine の fire イベントで火球オービットを発射
boss:add(C.KindDragon{ fire = { neckAngle = 295 } })

-- 出典: 戦闘開始時: attack_delay=8.0（Lua）＋ INFO（黄）＋ 燃焼状態の相手に対してクリティカル率[20+階層×0.5]%UP
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.AttachBuff{ id = 99053011, type = 22, value = { base = 20, perFloor = 0.5 }, script = { id = 19, v1 = 97 }, time = 99999, icon = 0, group = -1 }, C.Say{ key = "START_MESSAGE1", text = "反射・HP吸収・奥義ゲージ低下耐性・樹属性ダメージ耐性" }, C.Say{ key = "START_MESSAGE2", text = "全体付与のCRI率アップ・防御無視効果無効" }, C.Say{ key = "START_MESSAGE3", text = "CRI耐性ダウン無効" }, C.Say{ key = "START_MESSAGE4", text = "一定時間でCRIダメージアップ：氷結状態で効果リセット" }, C.Say{ key = "START_MESSAGE5", text = "燃焼状態の敵に対してCRI率アップ" } })

-- 出典: EP 共通ギミック: 180秒の時間制限。タイムアップで敗北（表示は gb_605601 と同じ）
boss:add(C.TimeLimit{ seconds = 180, redtime = 30, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

-- 出典: ギミック②: 樹属性(3)のダメージに対して takeDamageValue補正×[1÷(3+階層×0.05)]
boss:add(C.Defense{
  { attackerElement = 3, mult = { base = 3, perFloor = 0.05, inverse = true } },
})

-- 出典: 行動パターン: スキル1 → スキル2 → スキル3 → スキル4 → 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 3 }, { 4 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "attack5", [6] = "skill1", [7] = "skill1", [8] = "skill2" }, noVariant = { [5] = true } })

-- 出典: 行動パターン: 奥義6 → 奥義8 → 繰り返し ／ 奥義6・8のたびに与ダメージ10%UP（グラバト共通 6000100）
boss:add(C.Smash{ sets = { { 6 }, { 8 } }, onUse = { [6] = { C.StackBuff{ id = 6000100, type = 17, value = 10, max = 99, icon = 26 } }, [8] = { C.StackBuff{ id = 6000100, type = 17, value = 10, max = 99, icon = 26 } } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "attack5", [6] = "skill1", [7] = "skill1", [8] = "skill2" }, noVariant = { [5] = true } })

-- 出典: ギミック②: CRIダメージアップタイマー（アイコン26・20秒一周）／ブレイク中・無敵中（HPフラグ奥義中）は停止
boss:add(C.ExtraTimer{ key = "critdmg", maxTime = 20, loopLimit = 999, icon = { 26, 0 }, onRound = { C.StackBuff{ id = 99053012, type = 17, script = { id = 22 }, value = { base = 20, perFloor = 0.2 }, max = 99, icon = 26, group = -1 } }, speedRules = { { when = { invincible = true }, speed = 0 }, { when = { breaking = true }, speed = 0 } } })

-- 出典: ギミック②: 氷結で一度のみリセット可能／一度氷結にかかると氷結耐性500%UP
boss:add(C.OnStatus{ key = "freeze", types = { 96 }, once = true, actions = { C.RemoveBuff{ id = 99053012 }, C.AttachBuff{ id = 99053013, type = 59, value = 500, time = 99999, icon = 65, group = -1 }, C.AttachBuff{ id = 99053014, type = 108, value = 500, time = 99999, icon = 0, group = -1 }, C.Say{ key = "FREEZE_MESSAGE1", text = "CRIダメージアップリセット", color = C.Color.red }, C.Say{ key = "FREEZE_MESSAGE2", text = "氷結耐性アップ" } } })

-- 出典: HPトリガーは発動から打ち終わるまでブレイク不可（無敵中ロック）
boss:add(C.Break{ lockWhileInvincible = true })

-- 出典: HP20%: 防御力[700+階層×30]%UP・クリティカル率[20+階層×0.2]%UP・setUpFire・真奥義カットインで奥義7（パーティ永続燃焼は奥義7のデータ側）／スキップ不可・直前の奥義ゲージを引き継ぐ
boss:add(C.Phases{
  { at = 20, stop = true, deferWhileSkill = true, actions = { C.Invincible{ seconds = 30 }, C.SetAnimVariant{ "fire" }, C.AttachBuff{ id = 99053015, type = 15, value = { base = 700, perFloor = 30 }, time = 99999, icon = 5 }, C.AttachBuff{ id = 99053016, type = 22, value = { base = 20, perFloor = 0.2 }, time = 99999, icon = 11, group = -1 }, C.Say{ key = "HP20_MESSAGE1", text = "防御力アップ・CRI率アップ" }, C.UseSkill{ index = 7, cutin = C.Cutin.TrueArts, keepGauge = true } } },
})

-- 出典: HPフラグ奥義（奥義7）を打ち終わったら無敵解除
boss:add(C.SkillFinishWatch{ onSkill = { 7 }, onFinish = { C.Invincible{ seconds = 0 } } })

boss:publish()
