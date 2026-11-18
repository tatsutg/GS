-- 自動生成: CML2ギミック草案.md 爆走記者セレスタ【真EX・極】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "爆走記者セレスタ", version = 2.8, id = 2083790 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: attack_delay=8（Lua）／開幕INFO（赤セリフ＋黄4本）
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ color = C.Color.red, key = "START_MESSAGE1", text = "陰謀の匂いがするわ！" }, C.Say{ key = "START_MESSAGE2", text = "人族・炎属性ユニットからの被ダメージアップ" }, C.Say{ key = "START_MESSAGE3", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE4", text = "爆走状態：行動速度・奥義上昇量アップ、被ダメージ軽減" }, C.Say{ key = "START_MESSAGE5", text = "爆走状態：ブレイクで解除" } })

-- 出典: 戦闘開始時と HP10% トリガーで爆走状態／爆走状態中 Add SP=30・Attack_Delay=5・オーラ＋アイコン20,230
boss:add(C.Mode{ initial = "dash", states = { dash = { onEnter = { C.SetAttackDelay{ 5 }, C.SetAttackSPGain{ 30 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208379001, type = 0, value = 0, time = 999999, icon = 20, group = -1, aura = true }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208379002, type = 0, value = 0, time = 999999, icon = 230, group = -1 } }, onExit = { C.SetAttackDelay{ 8 }, C.SetAttackSPGain{ 20 }, C.RemoveBuff{ id = 208379001 }, C.RemoveBuff{ id = 208379002 } } }, normal = {  } } })

-- 出典: 戦闘開始時の爆走状態アイコンがボスHPバーに表示されない不具合の対策
boss:add(C.Start{ function(self, e) if self._condViewHooked then return end; self._condViewHooked = true; self:addEventListener('startWave', function(s, ev) megast.Battle:getInstance():updateConditionView() end) end })

-- 出典: 爆走状態中、TakeDamageValue補正×0.2
boss:add(C.Defense{
  { mult = 0.2, mode = "dash" },
})

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 奥義4 -> 繰り返し
boss:add(C.Smash{ sets = { { 3 }, { 4 }, { 4 } }, cutin = { [5] = C.Cutin.SuperArts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 爆走状態は一度ブレイクすると解除される／爆走状態解除時（赤）ぎゃっ！（黄）ブレイク成功！爆走状態解除
boss:add(C.Break{ onBreak = { function(self, e) if self._mode ~= 'dash' then return end; (C.SetMode{ 'normal' })(self, e); (C.Say{ color = C.Color.red, key = 'BREAK_MESSAGE1', text = 'ぎゃっ！' })(self, e); (C.Say{ key = 'BREAK_MESSAGE2', text = 'ブレイク成功！爆走状態解除' })(self, e) end } })

-- 出典: HP70%（ブレイクスルー）：防御力200%アップ＆クリティカル率50%アップ／HP30%（ブレイクスルー）：攻撃力100%アップ＆クリティカル率100%アップ（合計150%）／HP10%：自身の状態異常を回復＆超奥義カットインで奥義5を発動＆発動後、爆走状態になる
boss:add(C.Phases{
  { at = 70, stop = true, breakthrough = true, actions = { function(self, e) local u = self.unit; if u.m_breaktime ~= nil and u.m_breaktime > 0 then return end; (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208379003, type = 15, value = 200, time = 999999, icon = 5, group = -1 })(self, e); (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208379004, type = 22, value = 50, time = 999999, icon = 11, group = -1 })(self, e); (C.Say{ key = 'HP70_MESSAGE1', text = '防御力・クリティカル率アップ' })(self, e) end } },
  { at = 30, stop = true, breakthrough = true, actions = { function(self, e) local u = self.unit; if u.m_breaktime ~= nil and u.m_breaktime > 0 then return end; (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208379005, type = 13, value = 100, time = 999999, icon = 3, group = -1 })(self, e); (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208379006, type = 22, value = 100, time = 999999, icon = 11, group = -1 })(self, e); (C.Say{ key = 'HP30_MESSAGE1', text = '攻撃力・クリティカル率アップ' })(self, e) end } },
  { at = 10, stop = true, actions = { C.CureStatus{}, C.UseSkill{ index = 5, cutin = C.Cutin.SuperArts, invincible = 10, keepGauge = true }, C.Say{ color = C.Color.red, key = "HP10_MESSAGE1", text = "超フルスロットルッ！" }, C.SetMode{ "dash" }, C.Say{ key = "HP10_MESSAGE2", text = "爆走状態：行動速度・奥義上昇量アップ、被ダメージ軽減" }, C.Say{ key = "HP10_MESSAGE3", text = "爆走状態：ブレイクで解除" } } },
})

-- 出典: ※HPトリガーは発動から奥義を撃ち終わるまで無敵
boss:add(C.SkillFinishWatch{ onSkill = { 5 }, onFinish = { C.Invincible{ seconds = 0 } } })

-- 出典: 戦闘不能時（赤）：きゃああああ！
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.red, key = "DEAD_MESSAGE1", text = "きゃああああ！" } } })

-- [データ] 反射耐性100%、奥義ゲージ低下耐性100%、HP吸収耐性100%、人族・炎属性ユニットからの被ダメージ50%アップ、燃焼/病気/毒耐性0%、暗闇/氷結耐性30%、気絶耐性80%、その他200%、break_capacity 125,000、damage_drop_sp 18、防御力2,000 は本番マスタ側（確認済み: enemy_master.csv id=2083790。被ダメUPは Lua 側に入れると二重適用になるため入れない＝2083480.yaml の修正履歴に準拠）（マスタ設定・Choreo外）

boss:publish()
