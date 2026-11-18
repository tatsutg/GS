-- 自動生成: ガチアクタ前半ギミック.md ミーナス【真EX・極】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "爆烈転校生ミーナス", version = 2.5, id = 2084690 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: CreateExtraTimer を使うためのマネージャ宣言
boss:add(C.ExtraTimer{})

-- 出典: attack_delay=5（Lua）／開始INFO／状態異常(燃焼以外)でない場合クリティカル率80%アップ／エクストラタイマー開始
boss:add(C.Start{ C.SetAttackDelay{ 5 }, C.Say{ color = C.Color.red, key = "START_MESSAGE1", text = "オレの名を知ってるか？" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE3", text = "人族・炎・光属性ユニットからの被ダメージアップ" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE4", text = "ボスのCRI率アップ：燃焼以外の状態異常中、CRI率ダウン" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE5", text = "一定時間が経過するたびに、ボスのCRIダメージアップ" }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208469001, type = 22, value = 80, time = 999999, icon = 0, group = -1, script = { id = 261, v1 = 0, v2 = 0, v3 = 97 } }, C.CreateExtraTimer{ key = "power", maxTime = 17, loopLimit = 99, icon = { 26, 0 }, onRound = { C.StackBuff{ id = 208469002, type = 17, value = 15, max = 99, icon = 26, group = -1, script = { id = 22, v1 = 0, v2 = 0 } } }, speedRules = { { when = { breaking = true }, speed = 0 }, { when = { smashing = true }, speed = 0 } } } })

-- 出典: スキル：スキル3 -> スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 3 }, { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 奥義：奥義4 -> 奥義4 -> 奥義5 -> 繰り返し
boss:add(C.Smash{ sets = { { 4 }, { 4 }, { 5 } }, cutin = { [4] = C.Cutin.TrueArts, [5] = C.Cutin.SuperArts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 燃焼状態中エクストラゲージ（赤）。TDV補正を除いた通常ダメージで削れる。HPはボス最大HPの30%
boss:add(C.SubGauge{ key = "burn", hpRate = 0.3, color = { 220, 20, 60 }, protect = 0.01, active = false, onBreak = { C.SetMode{ "normal" } } })

-- 出典: 氷結付与でも燃焼状態は解除される（立ち上がりエッジで合っている）
boss:add(C.OnStatus{ key = "freeze", types = { 96 }, actions = { C.SetMode{ "normal" } } })

-- 出典: 燃焼が外部要因（相手の奥義効果）で解除されたら燃焼状態を抜ける
boss:add(C.OnStatus{ key = "burn", types = { 97 }, onEnd = { C.SetMode{ "normal" } } })

-- 出典: trigger=HPトリガー中（状態異常無効）／burn=燃焼状態（氷結耐性ダウン・AddSP40・SCRI率アップ）
boss:add(C.Mode{ initial = "normal", states = { normal = {  }, trigger = { onEnter = { C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208469011, type = 112, value = 1000 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208469012, type = 113, value = 1000 } }, onExit = { C.RemoveBuff{ id = 208469011 }, C.RemoveBuff{ id = 208469012 } } }, burn = { onEnter = { C.ShowSubGauge{ "burn" }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208469021, type = 97, value = 5, time = 999999, icon = 87 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208469022, type = 59, value = -150, time = 999999, icon = 0 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208469023, type = 108, value = -150, time = 999999, icon = 0 }, function(self, e) self._attackSPGainBonus = 10 end, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208469024, type = 142, value = 30, time = 999999 } }, onExit = { C.HideSubGauge{ "burn" }, C.RemoveBuff{ id = 208469021 }, C.RemoveBuff{ id = 208469022 }, C.RemoveBuff{ id = 208469023 }, C.RemoveBuff{ id = 208469024 }, function(self, e) self._attackSPGainBonus = 0 end, C.Say{ color = C.Color.red, key = "BURN_OFF_MESSAGE1", text = "やるじゃねえか…けど！！" }, C.Say{ color = C.Color.yellow, key = "BURN_OFF_MESSAGE2", text = "燃焼状態解除！" } } } } })

-- 出典: HP50%／HP20%：自身の状態異常を回復＋カットイン奥義＋追加効果（スキップ不可・ブレイク中でも発動）
boss:add(C.Phases{
  { at = 50, stop = true, deferWhileSkill = true, actions = { C.CureStatus{}, function(self, e) self._hpTrigPending = true; self._hpTrigActive = true end, C.SetMode{ "trigger" }, C.UseSkill{ index = 4, cutin = C.Cutin.TrueArts, invincible = 30, keepGauge = true }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208469031, type = 22, value = 70, time = 999999, icon = 11, group = -1 }, C.Say{ color = C.Color.red, key = "HP50_MESSAGE1", text = "テメーのコブシは…“純”じゃねえンだよ！！！" }, C.Say{ color = C.Color.yellow, key = "HP50_MESSAGE2", text = "クリティカル率アップ" } } },
  { at = 20, stop = true, deferWhileSkill = true, actions = { C.CureStatus{}, function(self, e) self._hpTrigPending = true; self._hpTrigActive = true end, C.SetMode{ "trigger" }, function(self, e) self._burnPending = true end, C.UseSkill{ index = 5, cutin = C.Cutin.SuperArts, invincible = 30, keepGauge = true }, C.Say{ color = C.Color.red, key = "HP20_MESSAGE1", text = "オレの名はミーナス" }, C.Say{ color = C.Color.red, key = "HP20_MESSAGE2", text = "この名前、ぜってえ忘れんなァアアア！！！！" }, C.Say{ color = C.Color.yellow, key = "HP20_MESSAGE3", text = "燃焼中、奥義上昇量・SCRI率アップ、被ダメージ大幅軽減" }, C.Say{ color = C.Color.yellow, key = "HP20_MESSAGE4", text = "一定ダメージ、または燃焼解除で効果解除" } } },
})

-- 出典: HPトリガーの奥義4/5を撃ち終わったら trigger を解除。HP20%側は続けて燃焼状態へ移行
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = { C.Invincible{ seconds = 0 }, function(self, e) if self._burnPending then self._burnPending = false; (C.SetMode{ 'burn' })(self, e) else (C.SetMode{ 'normal' })(self, e) end end } })

-- 出典: 戦闘不能時（赤）：セリフ
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.red, key = "DEAD_MESSAGE1", text = "終わる…何もかも失っちまう……" } } })

-- [データ] 反射耐性100%、奥義ゲージ低下耐性100%、HP吸収耐性100%、炎・光属性ユニットからの被ダメージ50%アップ、人族ユニットからの被ダメージ50%アップ、毒・病気・燃焼耐性0%、麻痺・気絶・暗闇耐性30%、その他状態異常耐性200%、break_capacity 400000、damage_drop_sp 18 は本番マスタ側（enemy_master.csv id=2084690）（マスタ設定・Choreo外）

boss:publish()
