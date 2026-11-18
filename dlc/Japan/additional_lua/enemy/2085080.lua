-- 自動生成: ガチアクタ後半ギミック.md エチカ【真EX】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "エチカ", version = 1.2, id = 2085080 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: attack_delay=7（Lua）／開始INFO
boss:add(C.Start{ C.SetAttackDelay{ 7 }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE1", text = "すべては、剣によって！" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下・CRI耐性" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE3", text = "人族・水・樹属性ユニットからの被ダメージアップ" } })

-- 出典: ロードオブフェザー状態で待機/後退/被弾/前進モーションを変化後のものに差し替える
boss:add(C.AnimVariant{ initial = "normal", variants = { normal = "", feather = "2" }, apply = { idle = "idle", back = "back", damage = "damage", front = "front" } })

-- 出典: スキル：スキル1 -> スキル2 -> スキル1 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1 }, { 1, 2 } }, noVariant = { [1] = true, [2] = true }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill2_2", [5] = "skill3", [6] = "skill3_2", [7] = "skill5", [8] = "skill5_2" } })

-- 出典: 奥義（ロードオブフェザー前）：奥義3 -> 奥義5 ／（後）：奥義4 -> 奥義6 -> 奥義8
boss:add(C.Smash{ byMode = { normal = { sets = { { 3 }, { 5 } } }, feather = { sets = { { 4 }, { 6 }, { 8 } } }, court = { sets = { { 4 }, { 6 }, { 8 } } } }, cutin = { [7] = C.Cutin.SuperArts }, noVariant = { [3] = true, [4] = true, [5] = true, [6] = true, [7] = true, [8] = true }, onUse = { [4] = { C.SetMode{ "court" } }, [6] = { C.SetMode{ "court" } }, [8] = { C.SetMode{ "court" } } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill2_2", [5] = "skill3", [6] = "skill3_2", [7] = "skill5", [8] = "skill5_2" } })

-- 出典: feather=ロードオブフェザー（HP70%直後〜奥義7撃ち終わり。被ダメ×0.01・状態異常耐性1000%）／court=決闘法廷
boss:add(C.Mode{ initial = "normal", states = { normal = {  }, feather = { onEnter = { C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208508011, type = 112, value = 1000 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208508012, type = 113, value = 1000 }, C.SetAnimVariant{ "feather" }, C.SetSetupAnim{ "idle2" } }, onExit = { C.RemoveBuff{ id = 208508011 }, C.RemoveBuff{ id = 208508012 } } }, court = { onEnter = { C.ShowSubGauge{ "court" }, C.Say{ color = C.Color.yellow, key = "FEATHER_MESSAGE1", text = "我らは誓う！『さだめ』を遵守しこの場に入ると！" }, C.Say{ color = C.Color.yellow, key = "FEATHER_MESSAGE2", text = "決闘法廷：リーダーユニットをターゲット：一定ダメージで勝利" }, C.Say{ color = C.Color.yellow, key = "FEATHER_MESSAGE3", text = "ターゲットユニットの攻撃が特に有効" } } } } })

-- 出典: HP70%トリガー中（mode=feather）は TakeDamageValue×0.01
boss:add(C.Defense{
  { mult = 0.01, mode = "feather" },
})

-- 出典: HP70%：自身の状態異常を回復＋超奥義カットインで奥義7発動＋ロードオブフェザー状態へ
boss:add(C.Phases{
  { at = 70, stop = true, deferWhileSkill = true, actions = { C.CureStatus{}, function(self, e) self._hpTrigPending = true; self._hpTrigActive = true end, C.SetMode{ "feather" }, C.UseSkill{ index = 7, cutin = C.Cutin.SuperArts, keepGauge = true }, C.Say{ color = C.Color.yellow, key = "HP70_MESSAGE1", text = "これは精霊国、伝説の剣――" }, C.Say{ color = C.Color.yellow, key = "HP70_MESSAGE2", text = "ロードオブフェザー状態：行動パターン変化" } } },
})

-- 出典: 奥義7を撃ち終わったらダメージ窓を閉じ、決闘法廷（court）を開く
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = { C.SetMode{ "court" } } })

-- 出典: 決闘法廷: リーダーをターゲットにする（戦闘不能なら最左・蘇生で復帰）。HP70% 以降だけ
boss:add(C.HateTarget{ rule = "leader", icon = 14, mode = "court", targetBuff = { id = 208508031, type = 0, icon = 210, group = -1 } })

-- 出典: エクストラゲージ（黄）。ボス最大HPの50%。本体HPは通常どおり削れる。リーダーからは×3
boss:add(C.SubGauge{ key = "court", hpRate = 0.5, color = { 255, 255, 0 }, protect = false, rates = { { mult = 3, attackerLeader = true } }, active = false, onBreak = { C.HideSubGauge{ "court" }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208508021, type = 89, value = 1, time = 1 }, C.GainSP{ value = 300, target = C.Targeting{ side = "player", pick = "leader" } }, C.AttachBuff{ target = C.Targeting{ side = "player", pick = "leader" }, id = 208508022, type = 22, value = 500, time = 999999, icon = 11, group = -1 }, C.AttachBuff{ target = C.Targeting{ side = "player", pick = "leader" }, id = 208508023, type = 142, value = 100, time = 999999, icon = 229, group = -1 }, C.Say{ color = C.Color.yellow, key = "COURT_WIN_MESSAGE1", text = "決闘法廷勝利！" }, C.Say{ color = C.Color.yellow, side = "player", key = "COURT_WIN_MESSAGE2", text = "ターゲットの奥義ゲージアップ！" }, C.Say{ color = C.Color.yellow, side = "player", key = "COURT_WIN_MESSAGE3", text = "ターゲットの攻撃は確定でSCRI！" } } })

-- 出典: 戦闘不能時（黄）：セリフ
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.yellow, key = "DEAD_MESSAGE1", text = "イヤぁああああああああッ！！" } } })

-- [データ] 反射耐性100%、奥義ゲージ低下耐性100%、HP吸収耐性100%、クリティカル耐性300%、毒・燃焼・病気・暗闇耐性30%、その他の状態異常耐性200%、break_capacity 300000、damage_drop_sp 12 は本番マスタ側（enemy_master.csv id=2085080）。⚠ マスタは現在 break_capacity=150000 / damage_drop_sp=20 で仕様書と不一致。別途修正が必要（マスタ設定・Choreo外）

boss:publish()
