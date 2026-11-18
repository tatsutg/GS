-- 自動生成: 草案_ハロウィンKoB後編_EX1～真EX極.md 赤月王ヴォックス【真EX】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "赤月王ヴォックス（ハロウィンver）", version = 2.5, id = 2086080 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）。HP30% 以降は SetAttackSPGain{30}
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: CreateExtraTimer を使うためのマネージャ宣言（⚠ これが無いと onRound が配線されない）
boss:add(C.ExtraTimer{})

-- 出典: attack_delay=7（Lua）／開始INFO／ブラッディ・ムーン（20秒タイマー）開始
boss:add(C.Start{ C.SetAttackDelay{ 7 }, C.Say{ color = C.Color.magenta, key = "START_MESSAGE1", text = "かかってくるがよい、勇者たちよ。" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "反射・奥義ゲージ低下耐性" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE3", text = "闇属性・魔族ユニットからの被ダメージアップ" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE4", text = "一定時間ごとに、与えたダメージを吸収" }, C.CreateExtraTimer{ key = "bloodymoon", maxTime = 20, loopLimit = 999, icon = { 0, 0 }, onRound = { C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208608001, type = 70, value = 500, time = 10, icon = 18, group = -1 }, C.GainSP{ target = C.Targeting{ pick = "self" }, value = 100 }, C.Say{ color = C.Color.magenta, key = "MOON_MESSAGE1", text = "暗黒よ、我が敵を喰らえ。" } }, speedRules = { { when = { breaking = true }, speed = 0 } } } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 繰り返し（奥義5はHP30%でだけ発動する）
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, cutin = { [3] = C.Cutin.Arts, [4] = C.Cutin.Arts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: trigger=HP30%トリガー中（状態異常耐性1000%アップ・TakeDamageValue×0.2）
boss:add(C.Mode{ initial = "normal", states = { normal = {  }, trigger = { onEnter = { C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208608011, type = 112, value = 1000 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208608012, type = 113, value = 1000 } }, onExit = { C.RemoveBuff{ id = 208608011 }, C.RemoveBuff{ id = 208608012 } } } } })

-- 出典: HP30%トリガー中（発動から撃ち終わるまで）は TakeDamageValue×0.2
boss:add(C.Defense{
  { mult = 0.2, mode = "trigger" },
})

-- 出典: HP30%：状態異常回復＆AddSP=30＆超奥義カットインで奥義5（ブレイク中でも発動・スキップ不可・ゲージ引き継ぎ）
boss:add(C.Phases{
  { at = 30, stop = true, deferWhileSkill = true, actions = { C.CureStatus{}, function(self, e) self._hpTrigPending = true; self._hpTrigActive = true end, C.SetMode{ "trigger" }, C.SetAttackSPGain{ 30 }, C.UseSkill{ index = 5, cutin = C.Cutin.SuperArts, keepGauge = true }, C.Say{ color = C.Color.magenta, key = "HP30_MESSAGE1", text = "深淵の闇に慄くがいい" }, C.Say{ color = C.Color.yellow, key = "HP30_MESSAGE2", text = "ドラクレア・ソード：与えたダメージを吸収" }, C.Say{ color = C.Color.yellow, key = "HP30_MESSAGE3", text = "奥義ゲージ上昇量アップ" } } },
})

-- 出典: HP30% の奥義5を撃ち終わったら trigger を解除（TakeDamageValue×0.2・状態異常耐性を外す）
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = { C.SetMode{ "normal" } } })

-- 出典: 死亡時（紫）：フハハ…良かろう、今宵はここまでだ…（仮）
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.magenta, key = "DEAD_MESSAGE1", text = "フハハ…良かろう、今宵はここまでだ…" } } })

-- [データ] 反射耐性100%・奥義ゲージ低下耐性100%（HP吸収耐性は 2026-11-05 にやめた）、闇属性・魔族ユニットからの被ダメージ50%アップ（60028000/60026900）、燃焼・病気・毒・暗闇耐性0%、麻痺・氷結・気絶耐性80%、その他の状態異常耐性200%、break_capacity 200000、damage_drop_sp 20、奥義3・4のデバフと奥義5の HP吸収1000%（この奥義中）は本番マスタ側（enemy_master.csv id=2086080 ／ skill_effect_master）。被ダメUPは Lua 側に入れると二重適用になるため入れない。⚠ 技・アビリティは skill_relation_master に未登録、HP・暗闇耐性はマスタと草案が違う（マスタ設定・Choreo外）

boss:publish()
