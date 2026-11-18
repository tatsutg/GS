-- 自動生成: CML2ギミック草案.md 爆走記者セレスタ【真EX】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "爆走記者セレスタ", version = 2.8, id = 2083780 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: attack_delay=9（Lua）／開幕INFO（赤セリフ＋黄4本）
boss:add(C.Start{ C.SetAttackDelay{ 9 }, C.Say{ color = C.Color.red, key = "START_MESSAGE1", text = "陰謀の匂いがするわ！" }, C.Say{ key = "START_MESSAGE2", text = "人族・炎属性ユニットからの被ダメージアップ" }, C.Say{ key = "START_MESSAGE3", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE4", text = "爆走状態：行動速度・奥義上昇量アップ、被ダメージ軽減" }, C.Say{ key = "START_MESSAGE5", text = "爆走状態：ブレイクで解除" } })

-- 出典: 戦闘開始時、セレスタは爆走状態から始まる／爆走状態中 Add SP=30・Attack_Delay=7・オーラ＋アイコン20,230
boss:add(C.Mode{ initial = "dash", states = { dash = { onEnter = { C.SetAttackDelay{ 7 }, C.SetAttackSPGain{ 30 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208378001, type = 0, value = 0, time = 999999, icon = 20, group = -1, aura = true }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208378002, type = 0, value = 0, time = 999999, icon = 230, group = -1 } }, onExit = { C.SetAttackDelay{ 9 }, C.SetAttackSPGain{ 20 }, C.RemoveBuff{ id = 208378001 }, C.RemoveBuff{ id = 208378002 } } }, normal = {  } } })

-- 出典: 戦闘開始時の爆走状態アイコンがボスHPバーに表示されない不具合の対策
boss:add(C.Start{ function(self, e) if self._condViewHooked then return end; self._condViewHooked = true; self:addEventListener('startWave', function(s, ev) megast.Battle:getInstance():updateConditionView() end) end })

-- 出典: 爆走状態中、TakeDamageValue補正×0.5
boss:add(C.Defense{
  { mult = 0.5, mode = "dash" },
})

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 繰り返し
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, cutin = { [5] = C.Cutin.SuperArts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 爆走状態は一度ブレイクすると解除される／初回ブレイク時（赤）ぎゃっ！（黄）ブレイク成功！爆走状態解除
boss:add(C.Break{ onBreak = { function(self, e) if self._dashCleared then return end; self._dashCleared = true; (C.SetMode{ 'normal' })(self, e); (C.Say{ color = C.Color.red, key = 'BREAK_MESSAGE1', text = 'ぎゃっ！' })(self, e); (C.Say{ key = 'BREAK_MESSAGE2', text = 'ブレイク成功！爆走状態解除' })(self, e) end } })

-- 出典: HP30%（ブレイクスルー）：超奥義カットインで奥義5を発動。発動から打ち終わるまで状態異常無効・takeDamageValue×0.01。ブレイク中に踏むと発動せずスルー
boss:add(C.Phases{
  { at = 30, stop = true, breakthrough = true, actions = { function(self, e) local u = self.unit; if u.m_breaktime ~= nil and u.m_breaktime > 0 then return end; self._hpTrigActive = true; self._hpTrigPending = true; (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208378003, type = 112, value = 1000 })(self, e); (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208378004, type = 113, value = 1000 })(self, e); (C.UseSkill{ index = 5, cutin = C.Cutin.SuperArts, keepGauge = true })(self, e); (C.Say{ color = C.Color.red, key = 'HP30_MESSAGE1', text = '超フルスロットルッ！' })(self, e) end } },
})

-- 出典: HPトリガー窓の解除: 奥義5の撃ち終わりで takeDamageValue×0.01 フラグ・状態異常耐性バフを解除
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = function(self, e) local u = self.unit or e.unit; if u == nil or u == false then return end; local c = u:getTeamUnitCondition(); local a = c:findConditionWithGroupID(112); if a ~= nil then c:removeCondition(a) end; local b = c:findConditionWithGroupID(113); if b ~= nil then c:removeCondition(b) end end })

-- 出典: HP30%ブレイクスルートリガー中は takeDamageValue×0.01
boss:add(C.Defense{
  { mult = 0.01, when = function(self, e) return self._hpTrigActive == true end },
})

-- 出典: 戦闘不能時（赤）：暴力…反対…
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.red, key = "DEAD_MESSAGE1", text = "暴力…反対…" } } })

-- [データ] 反射耐性100%、奥義ゲージ低下耐性100%、HP吸収耐性100%、人族・炎属性ユニットからの被ダメージ50%アップ、燃焼/病気/毒/暗闇耐性0%、氷結耐性30%、気絶耐性80%、その他200%、break_capacity 100,000、damage_drop_sp 20 は本番マスタ側（確認済み: enemy_master.csv id=2083780。被ダメUPは Lua 側に入れると二重適用になるため入れない＝2083480.yaml の修正履歴に準拠）（マスタ設定・Choreo外）

boss:publish()
