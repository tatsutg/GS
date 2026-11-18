-- 自動生成: quest_md/9900047_シャルヴァレ真EX.md → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "魔法少女シャル＆ヴァレリー（サマーver）", version = 1.2, id = 2082780 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSPはAttackSPGainで加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=10（Lua）
boss:add(C.AttackSPGain{ value = 10 })

-- 出典: attack_delay=4（Lua）／ 開幕INFO4種
boss:add(C.Start{ C.SetAttackDelay{ 4 }, C.Say{ key = "START_MESSAGE1", text = "魔法少女、見参！", color = C.Color.red }, C.Say{ key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE3", text = "人族・炎属性ユニットからの被ダメージアップ" }, C.Say{ key = "START_MESSAGE4", text = "バーニング・ユニゾンハート：発動回数に応じて効果量アップ" } })

-- 出典: スキル：スキル1 -> スキル2 -> スキル3 -> スキル2 -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 3 }, { 2 } }, onUse = { [3] = { C.Say{ key = "SKILL3_MESSAGE1", text = "HP回復", color = C.Color.green }, C.StackBuff{ target = C.Targeting{ pick = "self" }, id = 990473, type = 0, value = 0, time = 999999, icon = 36, max = 3 }, function(self, e) local u = self.unit or e.unit; self._s3 = (self._s3 or 0) + 1; self._attackSPGainBonus = math.min(self._s3, 3) * 5; local mx = u:getCalcHPMAX(); local hp = u:getHP() + mx * (self._s3 * 0.01); if hp > mx then hp = mx end; u:setHP(hp) end } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 奥義：奥義4 -> 繰り返し（奥義5はHP50%トリガー専用）。動く実例(竜牙兵/女神)に倣い activeSkills廃止＝sets値=スロット番号=奥義番号(skill_relation.need_level)。UseSkill.indexもこのスロット番号に一致させる
boss:add(C.Smash{ sets = { { 4 } }, onUse = { [4] = { C.Say{ key = "SKILL4_MESSAGE1", text = "攻撃力・防御力アップ", color = C.Color.yellow }, C.StackBuff{ target = C.Targeting{ pick = "self" }, id = 990474, type = 13, value = 20, time = 999999, icon = 3, max = 5 }, C.StackBuff{ target = C.Targeting{ pick = "self" }, id = 990475, type = 15, value = 20, time = 999999, icon = 5, max = 5 } } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: HP50%：状態異常回復＆超奥義カットインで奥義5発動。発動〜撃ち終わりまで状態異常無効・被ダメ×0.1・直前ゲージ引継(keepGauge)
boss:add(C.Phases{
  { at = 50, stop = true, actions = { C.CureStatus{}, function(self, e) self._hpTrigActive = true; self._hpTrigPending = true end, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 990476, type = 112, value = 100 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 990477, type = 113, value = 100 }, C.UseSkill{ index = 5, cutin = C.Cutin.SuperArts, keepGauge = true }, C.Say{ key = "HP50_MESSAGE1", text = "だいっ放出奥義！", color = C.Color.red }, C.Say{ key = "HP50_MESSAGE2", text = "だいっ放出奥義！", color = C.Color.cyan } } },
})

-- 出典: HPトリガー窓の解除: 奥義5撃ち終わり(getUnitState skill→終了)で被ダメ×0.1フラグを下ろし状態異常耐性バフを除去
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = function(self, e) local u = self.unit or e.unit; if u == nil or u == false then return end; local c = u:getTeamUnitCondition(); local a = c:findConditionWithGroupID(112); if a ~= nil then c:removeCondition(a) end; local b = c:findConditionWithGroupID(113); if b ~= nil then c:removeCondition(b) end end })

-- 出典: HP50トリガー中は被ダメ×0.1（takeDamageValue）。通常時は炎属性・人族からの被ダメ+50%
boss:add(C.Defense{
  { mult = 0.1, when = function(self, e) return self._hpTrigActive == true end },
  { mult = 1.5, when = function(self, e) if self._hpTrigActive then return false end; local a = e.enemy; return a ~= nil and a:getElementType() == 1 end },
  { mult = 1.5, when = function(self, e) if self._hpTrigActive then return false end; local a = e.enemy; if a == nil then return false end; if a:getRaceType() == 16 then return true end; local p = a:getParentTeamUnit(); return p ~= nil and p:getRaceType() == 16 end },
})

-- 出典: 戦闘不能時（赤）：や～ら～れ～た～（単体ボス＝clearWave不要）
boss:add(C.Dead{ actions = { C.Say{ key = "DEAD_MESSAGE1", text = "や～ら～れ～た～", color = C.Color.red } } })

-- [データ] 反射/奥義ゲージ低下/HP吸収耐性100%、燃焼・病気・毒・暗闇0%/氷結30%/気絶80%/その他200%、break_capacity 150,000・damage_drop_sp 20 は本番マスタ側（マスタ設定・Choreo外）

boss:publish()
