-- 自動生成: CML④ギミックFIX版.md CODE XTF:ERASER【EX2】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "CODE XTF:ERASER", version = 2.8, id = 2085570 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（通常時。待機中だけ SetSPGain で 6.667/秒 に上げる）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua。spine addSP イベント同期・大型ボス定型）
boss:add(C.SpineSPGain{ value = 20 })

-- 出典: 常に攻撃モード・形態変化などは行わない（草案）。待機/後退/被弾/退場のアニメ名を攻撃モードのものに固定する
boss:add(C.XtfForm{ initial = "normal", modes = { normal = { idle = "idle2", back = "back2", damage = "damage_S", out = "out2", effectIdle = false, setup = "setUp2", setupEffect = "", enter = false, enterEffect = false, pop = false }, wait = { idle = "idle2", back = "back2", damage = "damage_S", out = "out2", effectIdle = false, setup = "setUp2", setupEffect = "", enter = false, enterEffect = false, pop = false } } })

-- 出典: スキル1 ミサイル（attack4 の spine missile イベントで主砲からミサイル。当たり判定は弾側）
boss:add(C.XtfMissile{})

-- 出典: スキル3 サブアームビーム（attack5 の aim で砲身照準 → laserHit2 で着弾オービット。当たり判定は着弾側）
boss:add(C.XtfLaser{})

-- 出典: normal=通常戦闘／wait=待機状態（HP0% で移行）
boss:add(C.Mode{ initial = "normal", states = { normal = {  }, wait = { onEnter = { C.GainSP{ -9999 }, C.SetSPGain{ 6.667 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208557001, type = 27, value = -100000, icon = 0, group = -1 }, C.SetAttackDelay{ 999 }, C.ShowSubGauge{ "extra" }, C.Say{ key = "HP0_MESSAGE1", text = "自爆しようとしている！：一定ダメージで阻止" } } } } })

-- 出典: スキン Nomal 適用（装甲・両腕・バリアハンドの描画に必須）／attack_delay=8（Lua）／INFO 戦闘開始時（黄）：奥義ゲージ低下耐性
boss:add(C.Start{ C.SetSkin{ "Nomal" }, C.SetAttackDelay{ 8 }, C.Say{ key = "START_MESSAGE1", text = "奥義ゲージ低下耐性" } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2 or スキル3） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2, 3 } }, anim = { [1] = "attack4", [2] = "attack6", [3] = "attack5", [4] = "skill5", [5] = "skill7" } })

-- 出典: 奥義：奥義4 -> 繰り返し／待機中は奥義5（フィニス=マキナ）をカットインなしで発動
boss:add(C.Smash{ byMode = { normal = { sets = { { 4 } } }, wait = { sets = { { 5 } } } }, onUse = { [5] = { C.Invincible{ seconds = 20 }, C.Say{ color = C.Color.red, key = "SKILL5_MESSAGE1", text = "強力な自爆攻撃！" } } }, anim = { [1] = "attack4", [2] = "attack6", [3] = "attack5", [4] = "skill5", [5] = "skill7" } })

-- 出典: HP50%：奥義カットインで奥義4を発動（※このトリガーはスキップ可）
boss:add(C.Phases{
  { at = 50, actions = { C.UseSkill{ index = 4, cutin = C.Cutin.Arts } } },
  { at = 0.01, stop = true, actions = { C.SetMode{ "wait" } } },
})

-- 出典: 待機状態: エクストラゲージを表示（ボスの最大HPの10%）。削り切ると即戦闘不能＋BE玉20個ドロップ
boss:add(C.SubGauge{ key = "extra", hpRate = 0.1, active = false, protect = 0, onBreak = { C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208557002, type = 173, value = 185, icon = 0, group = -1 }, C.SetHP{ 0 } } })

-- 出典: 奥義5（自爆）の撃ち終わり → 発動後戦闘不能になる
boss:add(C.SkillFinishWatch{ onSkill = { 5 }, onFinish = { C.Invincible{ seconds = 0 }, C.SetHP{ 0 } } })

-- [データ] HP 1,600,000、攻撃力2,000、break_capacity 100,000、damage_drop_sp 20 は本番マスタ側（確認済み: enemy_master.csv id=2085570）。奥義ゲージ低下耐性100%、毒/病気/燃焼/暗闇耐性0%・氷結30%・気絶50%・その他200% もデータ側。⚠ 防御力は草案 100 に対し本番マスタ 500（要確認）（マスタ設定・Choreo外）

boss:publish()
