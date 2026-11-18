-- 自動生成: 前半ギミック.md イリヤ（皇帝フォーム）真EX・極 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "イリヤ（皇帝フォーム）", version = 1.2, id = 2083090 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSPはAttackSPGainで加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: attack_delay=8（Lua）／開幕INFO
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ key = "START_MESSAGE1", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE2", text = "人族・光属性ユニットからの被ダメージアップ" }, C.Say{ key = "START_MESSAGE3", text = "累計ダメージの最も大きいユニットをターゲット" }, C.Say{ key = "START_MESSAGE4", text = "ターゲットの与ダメージダウン・それ以外の与ダメージアップ" }, C.Say{ key = "START_MESSAGE5", text = "ユニットの属性数が多いほど、ボスの被ダメージアップ" } })

-- 出典: 累計ダメージの大きいユニットをターゲットにする。ターゲットの与ダメージ100%ダウン、ターゲット以外の与ダメージ50%アップ
boss:add(C.HateTarget{ damageRate = 1, icon = 14, targetBuff = { id = 20830908, type = 17, value = -100, icon = 27 }, othersBuff = { id = 20830909, type = 17, value = 50, icon = 26 } })

-- 出典: プレイヤーユニットの属性数に応じてtakeDamageValue補正（4属性:1.0／3属性:0.8／2属性:0.5／1属性:0.1）
boss:add(C.Defense{
  { countPartyElements = true, byCount = { [1] = 0.1, [2] = 0.5, [3] = 0.8, [4] = 1.0 } },
})

-- 出典: スキル：スキル1 -> スキル2 -> （スキル3 or スキル4 or スキル5） -> 繰り返し（原文はスキル4/5/6だが、スキル6は奥義のため通常ローテには入らない想定。スキル3/4/5と解釈。要確認）
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 3, 4, 5 } }, onUse = { [3] = { C.StackDebuff{ id = 20830902, type = 32, value = -20, max = 10, icon = 15 }, C.Say{ key = "SKILL3_MESSAGE1", text = "スカイライト：ユニットの命中率ダウン", color = C.Color.red } }, [4] = { C.StackDebuff{ id = 20830903, type = 13, value = -30, max = 10, icon = 4 }, C.Say{ key = "SKILL4_MESSAGE1", text = "グランヴィス：ユニットの攻撃力ダウン", color = C.Color.red } }, [5] = { C.StackDebuff{ id = 20830904, type = 23, value = 25, max = 10, icon = 13 }, C.Say{ key = "SKILL5_MESSAGE1", text = "ダークブリンガー：ユニットのクリティカル耐性ダウン", color = C.Color.red } } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2_1", [4] = "skill2_2", [5] = "skill2_3", [6] = "skill3", [7] = "skill5" } })

-- 出典: 奥義：奥義6 -> 繰り返し。自身のクリティカル率80%アップは本番マスタ側で設定済みのためLua側では付与しない
boss:add(C.Smash{ sets = { { 6 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2_1", [4] = "skill2_2", [5] = "skill2_3", [6] = "skill3", [7] = "skill5" } })

-- 出典: HP60%：真奥義カットインで奥義6発動／HP30%：超奥義カットインで奥義7発動&AddSP=40。両トリガーとも発動〜撃ち終わりまで状態異常無効・TakeDamageValue×0.02・直前の奥義ゲージ引き継ぐ（keepGauge）
boss:add(C.Phases{
  { at = 60, actions = { function(self, e) self._hpTrigActive = true; self._hpTrigPending = true end, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 20830906, type = 112, value = 1000 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 20830907, type = 113, value = 1000 }, C.UseSkill{ index = 6, cutin = C.Cutin.TrueArts, keepGauge = true }, C.Say{ key = "HP60_MESSAGE1", text = "やってみる！" } } },
  { at = 30, actions = { function(self, e) self._hpTrigActive = true; self._hpTrigPending = true end, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 20830906, type = 112, value = 1000 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 20830907, type = 113, value = 1000 }, function(self, e) self._attackSPGainBonus = 20 end, C.UseSkill{ index = 7, cutin = C.Cutin.SuperArts, keepGauge = true }, C.Say{ key = "HP30_MESSAGE1", text = "因果を断て！" }, C.Say{ key = "HP30_MESSAGE2", text = "奥義上昇量アップ" } } },
})

-- 出典: HPトリガー窓の解除: 奥義6/7撃ち終わりでTakeDamageValue×0.02フラグ・状態異常耐性バフを解除。
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = function(self, e) local u = self.unit or e.unit; if u == nil or u == false then return end; local c = u:getTeamUnitCondition(); local a = c:findConditionWithGroupID(112); if a ~= nil then c:removeCondition(a) end; local b = c:findConditionWithGroupID(113); if b ~= nil then c:removeCondition(b) end end })

-- 出典: HP60%/HP30%トリガー中はTakeDamageValue×0.02
boss:add(C.Defense{
  { mult = 0.02, when = function(self, e) return self._hpTrigActive == true end },
})

-- 出典: 戦闘不能時（黄）：セリフ
boss:add(C.Dead{ actions = { C.Say{ key = "DEAD_MESSAGE1", text = "きゃああああ！" } } })

-- [データ] 反射耐性100%、奥義ゲージ低下耐性100%、HP吸収耐性100%、人族ユニット・光属性ユニットからの被ダメージ50%アップ、奥義6発動時の自身クリティカル率80%アップ、燃焼/病気/毒耐性0%、暗闇/氷結耐性30%、気絶耐性80%、その他200%、break_capacity 200,000、damage_drop_sp 18 は本番マスタ側（マスタ設定・Choreo外）

boss:publish()
