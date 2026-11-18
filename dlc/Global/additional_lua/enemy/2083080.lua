-- 自動生成: 前半ギミック.md イリヤ（皇帝フォーム）真EX → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "イリヤ（皇帝フォーム）", version = 1.2, id = 2083080 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSPはAttackSPGainで加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: attack_delay=9（Lua）／開幕INFO
boss:add(C.Start{ C.SetAttackDelay{ 9 }, C.Say{ key = "START_MESSAGE1", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE2", text = "人族・光属性ユニットからの被ダメージアップ" }, C.Say{ key = "START_MESSAGE3", text = "累計ダメージの最も大きいユニットをターゲット" }, C.Say{ key = "START_MESSAGE4", text = "ターゲットの与ダメージダウン・それ以外の与ダメージアップ" }, C.Say{ key = "START_MESSAGE5", text = "ユニットの属性数が多いほど、ボスの被ダメージアップ" } })

-- 出典: 累計ダメージの大きいユニットをターゲットにする。ターゲットの与ダメージ30%ダウン、ターゲット以外の与ダメージ30%アップ
boss:add(C.HateTarget{ damageRate = 1, icon = 14, targetBuff = { id = 20830805, type = 17, value = -30, icon = 27 }, othersBuff = { id = 20830806, type = 17, value = 30, icon = 26 } })

-- 出典: プレイヤーユニットの属性数に応じてtakeDamageValue補正（4属性:1.2／3属性:1.0／2属性:0.8／1属性:0.5）
boss:add(C.Defense{
  { countPartyElements = true, byCount = { [1] = 0.5, [2] = 0.8, [3] = 1.0, [4] = 1.2 } },
})

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2_2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 繰り返し。奥義3は奥義カットイン、奥義4は真奥義カットインで発動する
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, cutin = { [3] = C.Cutin.Arts, [4] = C.Cutin.TrueArts }, onUse = { [4] = { C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 20830804, type = 22, value = 50, time = 15, icon = 11 } } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2_2", [4] = "skill3", [5] = "skill5" } })

-- 出典: HP50%：超奥義カットインで奥義5発動。発動〜撃ち終わりまで状態異常無効・TakeDamageValue×0.2・直前の奥義ゲージ引き継ぐ（keepGauge）
boss:add(C.Phases{
  { at = 50, actions = { function(self, e) self._hpTrigActive = true; self._hpTrigPending = true end, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 20830802, type = 112, value = 1000 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 20830803, type = 113, value = 1000 }, C.UseSkill{ index = 5, cutin = C.Cutin.SuperArts, keepGauge = true }, C.Say{ key = "HP50_MESSAGE1", text = "紋章剣よ" } } },
})

-- 出典: HPトリガー窓の解除: 奥義5撃ち終わりでTakeDamageValue×0.2フラグ・状態異常耐性バフを解除
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = function(self, e) local u = self.unit or e.unit; if u == nil or u == false then return end; local c = u:getTeamUnitCondition(); local a = c:findConditionWithGroupID(112); if a ~= nil then c:removeCondition(a) end; local b = c:findConditionWithGroupID(113); if b ~= nil then c:removeCondition(b) end end })

-- 出典: HP50%トリガー中はTakeDamageValue×0.2
boss:add(C.Defense{
  { mult = 0.2, when = function(self, e) return self._hpTrigActive == true end },
})

-- 出典: 戦闘不能時（黄）：セリフ
boss:add(C.Dead{ actions = { C.Say{ key = "DEAD_MESSAGE1", text = "失敗…しちゃった……" } } })

-- [データ] 反射耐性100%、奥義ゲージ低下耐性100%、HP吸収耐性100%、人族ユニット・光属性ユニットからの被ダメージ50%アップ、燃焼/病気/毒/暗闇耐性0%、氷結耐性30%、気絶耐性80%、その他200%、break_capacity 150,000、damage_drop_sp 20 は本番マスタ側（マスタ設定・Choreo外）

boss:publish()
