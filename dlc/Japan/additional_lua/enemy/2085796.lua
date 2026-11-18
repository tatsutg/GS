-- 自動生成: チャレンジクエスト／幻炎竜メテオヘイズ_ 1029_02.md → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "幻炎竜メテオヘイズ", version = 1.3, id = 2085796 }

-- 出典: 戦闘開始時: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 戦闘開始時: addSP=20（Lua）
boss:add(C.SpineSPGain{ value = 20 })

-- 出典: スキル1 火球: spine の fire イベントで火球オービット（fireball2）を発射
boss:add(C.KindDragon{ fire = { anim = "fireball2", neckAngle = 295 } })

-- 出典: 奥義7/8 インフェルノヴィジョン: skill3 の skill3_orbit で炎の場
boss:add(C.KindMeteorHaze{ inferno = {  } })

-- 出典: 幻炎の段階（リーダー → HP50%からリーダー以外 → HP0%で停止）／スキル4・奥義5発動時（初回のみ）のINFO
boss:add(C.Mode{ initial = "dormant", states = { dormant = {  }, leader = { onEnter = { C.Say{ color = C.Color.red, key = "GENEN_MESSAGE1", text = "幻炎：猛炎状態が長引くほどリーダーユニットの最大HPダウン" } } }, others = {  }, stopped = {  } } })

-- 出典: 幻炎: 猛炎状態が1秒続くごとにリーダーユニットの最大HP2%ダウン（HP50%トリガーまで）
boss:add(C.StatusErosion{ key = "genenLeader", types = { 208 }, icon = 308, units = "leader", buffs = { { id = 208579601, type = 2, value = -2, icon = 2 } } })

-- 出典: 幻炎: HP50%トリガーからHP0%トリガーまで、リーダーユニット以外の最大HP1%ダウン
boss:add(C.StatusErosion{ key = "genenOthers", active = false, types = { 208 }, icon = 308, units = "others", buffs = { { id = 208579601, type = 2, value = -1, icon = 2 } } })

-- 出典: 戦闘開始時: attack_delay=6（Lua）＋ INFO（黄）×3 ＋ HP0% トリガーのマーカー
boss:add(C.Start{ C.SetAttackDelay{ 6 }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE1", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "HP自然回復キラー" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE3", text = "幻炎の守護：ブレイク中以外は被ダメージ軽減" }, function(self, e) self._hp0Marker = self.unit:addNumHpMarker(0) end })

-- 出典: 行動パターン: スキル4 → スキル1 → スキル3 → (スキル1 or スキル3) → スキル2 → 繰り返し／スキル4発動時（初回のみ）の幻炎INFO
boss:add(C.Attack{ sets = { { 4 }, { 1 }, { 3 }, { 1, 3 }, { 2 } }, onUse = { [4] = { function(self, e) if self._mode == 'dormant' then C.SetMode{ 'leader' }(self, e) end end } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "skill1", [6] = "skill2", [7] = "skill3", [8] = "skill3" } })

-- 出典: 行動パターン: 奥義5 → 奥義6 → 繰り返し／すべての奥義は真奥義カットイン／奥義5・6発動時のINFO／奥義5発動時（初回のみ）の幻炎INFO
boss:add(C.Smash{ sets = { { 5 }, { 6 } }, cutin = { [5] = C.Cutin.TrueArts, [6] = C.Cutin.TrueArts }, onUse = { [5] = { function(self, e) if self._mode == 'dormant' then C.SetMode{ 'leader' }(self, e) end end, C.Say{ color = C.Color.red, key = "SKILL5_MESSAGE1", text = "イグナイトブレス：庇う無効" } }, [6] = { C.Say{ color = C.Color.red, key = "SKILL6_MESSAGE1", text = "フレイムクライ：庇う無効" } } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "skill1", [6] = "skill2", [7] = "skill3", [8] = "skill3" } })

-- 出典: ブレイク中でないとき、ボスへのダメージは TakeDamageValue 補正×0.01（ブレイクダメージには掛けない）／ブレイク中は×1.0／HP0%以降は解除
boss:add(C.Defense{
  { mult = 0.01, breaking = false, mode = "stopped", negate = true },
})

-- 出典: HPトリガーは発動から撃ち終わり（炎が消える）までブレイク不可（無敵中ロック）
boss:add(C.Break{ lockWhileInvincible = true })

-- 出典: HP0%: HPを30%まで回復＆状態異常を回復＆真奥義カットインで奥義8＆addSP=40＆以降ダメージ無効化無効＆以降ブレイク中以外の被ダメージ軽減を解除／幻炎の低下を止める
boss:add(C.Reraise{ times = 1, actions = { function(self, e) if self._hp0Marker ~= nil then self.unit:removeHpMarker(self._hp0Marker); self._hp0Marker = nil end end, C.SetHP{ rate = 0.3 }, C.CureStatus{}, C.StopStatusErosion{ "genenLeader" }, C.StopStatusErosion{ "genenOthers" }, C.SetMode{ "stopped" }, C.SetSpineSPGain{ 40 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208579613, type = 132, value = 100, time = 999999, icon = 0, group = -1 }, C.Say{ color = C.Color.yellow, key = "HP0_MESSAGE1", text = "幻炎竜が激高し、幻炎の守護を解除" }, C.Say{ color = C.Color.red, key = "HP0_MESSAGE2", text = "インフェルノヴィジョン：庇う無効" }, C.Say{ color = C.Color.red, key = "HP0_MESSAGE3", text = "ダメージ無効化無効" }, C.Say{ color = C.Color.yellow, key = "HP0_MESSAGE4", text = "奥義上昇量アップ" }, C.UseSkill{ index = 8, cutin = C.Cutin.TrueArts, invincible = 30, keepGauge = true } } })

-- 出典: HP50%: 状態異常を回復＆真奥義カットインで奥義7＆回避率70%UP＆ブレイク耐性15%UP／無敵・ブレイク不可・スキップ不可・ゲージ引き継ぎ
boss:add(C.Phases{
  { at = 50, stop = true, deferWhileSkill = true, actions = { C.CureStatus{}, C.StopStatusErosion{ "genenLeader" }, C.StartStatusErosion{ "genenOthers" }, C.SetMode{ "others" }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208579611, type = 27, value = -15, time = 999999, icon = 9 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208579612, type = 31, value = 70, time = 999999, icon = 16 }, C.Say{ color = C.Color.red, key = "HP50_MESSAGE1", text = "幻炎：猛炎状態が長引くほどリーダーユニット以外の最大HPダウン" }, C.Say{ color = C.Color.red, key = "HP50_MESSAGE2", text = "インフェルノヴィジョン：庇う無効" }, C.Say{ color = C.Color.yellow, key = "HP50_MESSAGE3", text = "回避率・ブレイク耐性アップ" }, C.UseSkill{ index = 7, cutin = C.Cutin.TrueArts, invincible = 30, keepGauge = true } } },
})

-- 出典: HP50%: 奥義7 の炎が消えたら無敵解除
boss:add(C.SkillFinishWatch{ onSkill = { 7 }, hold = "_meteorInfernoAlive", onFinish = { C.Invincible{ seconds = 0 } } })

-- 出典: HP0%: 奥義8 の炎が消えたら無敵解除
boss:add(C.SkillFinishWatch{ onSkill = { 8 }, hold = "_meteorInfernoAlive", onFinish = { C.Invincible{ seconds = 0 } } })

-- [データ] 反射耐性100%・奥義ゲージ低下耐性100%・HP吸収耐性100%・命中率50%UP・毒/病気耐性0%・その他の状態異常耐性300%・HP自然回復キラー（与ダメージ5000%UP／相手の被ダメージ5000%UP）、スキル1の燃焼・スキル4/奥義5の猛炎（effect_type 208／target 3／effect_time 99999／script_id 602・script_value 1/5／effect_value 300／アイコン308）・奥義7/8の継続ダメージ・奥義5〜8の庇う無効（168・script 8）は本番マスタ側（skill_effect_master / skill_relation_master。develop 2091c75df1f で登録済み）（マスタ設定・Choreo外）

boss:publish()
