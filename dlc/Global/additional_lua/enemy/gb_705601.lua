-- 自動生成: quest_md/9900049_EP7ヴィラカーズ.md → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "グランドバトルEP7_エリアボス_ヴィラカーズ", version = 2.5, id = "gb_705601" }

-- 出典: 戦闘開始時: addSP=30（Lua）
boss:add(C.KindVirakaz{ spineSP = 30 })

-- 出典: 戦闘開始時: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 戦闘開始時: attack_delay=8.0・回避率[15+階層×0.2]%UP（MAX200%）（Lua）＋ INFO（黄）
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.AttachBuff{ id = 70560101, type = 31, value = { base = 15, perFloor = 0.2, max = 200 }, time = 99999, icon = 16 }, C.Say{ key = "START_MESSAGE1", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE2", text = "全体付与のCRI率アップ・防御無視効果無効" }, C.Say{ key = "START_MESSAGE3", text = "CRI耐性ダウン無効" }, C.Say{ key = "START_MESSAGE4", text = "暗闇状態の相手に対してダメージアップ" }, C.Say{ key = "START_MESSAGE5", text = "一定時間経過でパーティに暗闇付与：病気で遅延" } })

-- 出典: EP 共通ギミック: 180秒の時間制限。タイムアップで敗北（表示は gb_605601 と同じ）
boss:add(C.TimeLimit{ seconds = 180, redtime = 30, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

-- 出典: 行動パターン: スキル1 → スキル2 → スキル3 → 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 3 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "skill1", [5] = "skill2", [6] = "skill4" } })

-- 出典: 行動パターン: 奥義5 → 奥義6 → 繰り返し ／ 奥義5・6のたびに与ダメージ10%UP（グラバト共通 6000100）
boss:add(C.Smash{ sets = { { 5 }, { 6 } }, onUse = { [4] = { C.Say{ key = "SKILL4_MESSAGE1", text = "暗闇状態の相手に対して被ダメージアップ" } }, [5] = { C.StackBuff{ id = 6000100, type = 17, value = 10, max = 99, icon = 26 } }, [6] = { C.StackBuff{ id = 6000100, type = 17, value = 10, max = 99, icon = 26 } } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "skill1", [5] = "skill2", [6] = "skill4" } })

-- 出典: ギミック②: 暗闇タイマー（アイコン83・10秒一周）／病気で1/2・ブレイク中・無敵中（HPフラグ奥義中）は停止
boss:add(C.ExtraTimer{ key = "blind", maxTime = 10, loopLimit = 999, icon = { 83, 0 }, onRound = { function(self, e) local v = 20 + megast.Battle:getInstance():getCurrentGrandBattleFloor() * 0.2; local team = megast.Battle:getInstance():getTeam(true); for i = 0, 7 do local u = team:getTeamUnit(i); if u ~= nil then u:getTeamUnitCondition():addCondition(705601, 93, v, 99999, 83) end end; megast.Battle:getInstance():updateConditionView() end }, speedRules = { { when = { invincible = true }, speed = 0 }, { when = { breaking = true }, speed = 0 }, { when = { status = { 94 } }, speed = 0.5 } } })

-- 出典: HPトリガーは発動から打ち終わるまでブレイク不可（無敵中ロック）
boss:add(C.Break{ lockWhileInvincible = true })

-- 出典: HP20%: 真奥義カットインで奥義4＋防御力[700+階層×30]%UP／スキップ不可・直前の奥義ゲージを引き継ぐ
boss:add(C.Phases{
  { at = 20, stop = true, deferWhileSkill = true, actions = { C.Invincible{ seconds = 30 }, C.AttachBuff{ id = 99049002, type = 15, value = { base = 700, perFloor = 30 }, time = 99999, icon = 5 }, C.Say{ key = "HP20_MESSAGE1", text = "防御力アップ" }, function(self, e) self.unit:setUnitState(kUnitState_attack); self.unit:takeAnimation(0, 'charge_loop', true) end, C.After{ seconds = 1, actions = { C.UseSkill{ index = 4, cutin = C.Cutin.TrueArts, keepGauge = true } } } } },
})

-- 出典: HPフラグ奥義（奥義4）を打ち終わったら無敵解除
boss:add(C.SkillFinishWatch{ onSkill = { 4 }, onFinish = { C.Invincible{ seconds = 0 } } })

boss:publish()
