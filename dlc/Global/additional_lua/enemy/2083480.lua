-- 自動生成: プリヤ後半ギミック草案.md 衛宮士郎（英霊エミヤver）真EX → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "衛宮士郎（英霊エミヤver）", version = 2.5, id = 2083480 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSPはAttackSPGainで加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: attack_delay=9（Lua）／戦闘開始時奥義ゲージ100（Lua）／開幕INFO
boss:add(C.Start{ C.SetAttackDelay{ 9 }, C.GainSP{ 100 }, C.Say{ color = C.Color.red, key = "START_MESSAGE1", text = "投影開始" }, C.Say{ key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE3", text = "人族からの被ダメージ・被ブレイクダメージアップ" }, C.Say{ key = "START_MESSAGE4", text = "一定時間経過毎に超奥義発動：CRIダメージで遅延" } })

-- 出典: 衛宮士郎（英霊エミヤver）の真奥義オービット
boss:add(C.Timeline{ Library_shot = { C.SpawnOrbit{ anim = "shot", type = 1, endAnim = "hit", hits = 1, damageRate = 0.1, breakRate = 0.1 } } })

-- 出典: 奥義4(真奥義)は本体0.9・残り0.1をshotオービットへ委譲（プレイヤー版 108507112.lua takeSkill index==3 と同配分）
boss:add(C.DamageRate{ smash = { [4] = { damageRate = 0.9, breakRate = 0.9 } } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 奥義4 -> 繰り返し。奥義4は真奥義カットインで発動する
boss:add(C.Smash{ sets = { { 3 }, { 4 }, { 4 } }, cutin = { [4] = C.Cutin.TrueArts, [5] = C.Cutin.SuperArts }, onUse = { [3] = { function(self, e) if self._ctDownApplied then return end; self._ctDownApplied = true; local team = megast.Battle:getInstance():getTeam(true); for i=0,7 do local u = team:getTeamUnit(i); if u ~= nil then local c = u:getTeamUnitCondition(); c:addCondition(208348001, 29, -50, 99999, 8); c:addCondition(208348002, 30, -50, 99999, 183) end end end, C.Say{ color = C.Color.red, key = "SKILL3_MESSAGE1", text = "スキル・装備CT速度ダウン：ブレイクで解除" } } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 衛宮士郎をブレイクで解除（奥義3のCTダウン効果を除去）
boss:add(C.Break{ onBreak = { function(self, e) self._ctDownApplied = false; local team = megast.Battle:getInstance():getTeam(true); for i=0,7 do local u = team:getTeamUnit(i); if u ~= nil then local c = u:getTeamUnitCondition(); local a = c:findConditionWithID(208348001); if a ~= nil then c:removeCondition(a) end; local b = c:findConditionWithID(208348002); if b ~= nil then c:removeCondition(b) end end end end, C.Say{ color = C.Color.red, key = "BREAK_MESSAGE1", text = "クッ！" }, C.Say{ color = C.Color.red, key = "BREAK_MESSAGE2", text = "スキル・装備CT速度ダウン効果解除！" } } })

-- 出典: エクストラタイマー表示。30秒ごとに奥義5を発動（超奥義カットイン・keepGauge）。ブレイク中・奥義発動中は停止
boss:add(C.ExtraTimer{ key = "true_arts_timer", maxTime = 30, loopLimit = 999, icon = { 0, 0 }, onRound = { C.UseSkill{ index = 5, cutin = C.Cutin.SuperArts, keepGauge = true } }, speedRules = { { when = { breaking = true }, speed = 0 }, { when = { smashing = true }, speed = 0 } } })

-- 出典: クリティカル攻撃を受けると、2秒間タイマーの速度が1/2になる。重複しない・再度クリティカルで上書きされ2秒に戻る
boss:add(C.OnTakeCritical{ actions = { C.SetExtraTimerSpeed{ key = "true_arts_timer", speed = 0.5, duration = 2 } } })

-- 出典: HP50%（ブレイクスルー）：超奥義カットインで奥義5を発動。発動〜撃ち終わりまで状態異常無効・takeDamageValue×0.01。ブレイク中に踏むと発動せずスルー
boss:add(C.Phases{
  { at = 50, stop = true, breakthrough = true, actions = { function(self, e) local u = self.unit; if u.m_breaktime ~= nil and u.m_breaktime > 0 then return end; self._hpTrigActive = true; self._hpTrigPending = true; (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208348003, type = 112, value = 1000 })(self, e); (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208348004, type = 113, value = 1000 })(self, e); (C.UseSkill{ index = 5, cutin = C.Cutin.SuperArts, keepGauge = true })(self, e); (C.Say{ color = C.Color.red, key = 'HP50_MESSAGE1', text = 'お前の技は見飽きたよ' })(self, e) end } },
})

-- 出典: HPトリガー窓の解除: 奥義5撃ち終わりでtakeDamageValue×0.01フラグ・状態異常耐性バフを解除
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = function(self, e) local u = self.unit or e.unit; if u == nil or u == false then return end; local c = u:getTeamUnitCondition(); local a = c:findConditionWithGroupID(112); if a ~= nil then c:removeCondition(a) end; local b = c:findConditionWithGroupID(113); if b ~= nil then c:removeCondition(b) end end })

-- 出典: HP50%ブレイクスルートリガー中はtakeDamageValue×0.01
boss:add(C.Defense{
  { mult = 0.01, when = function(self, e) return self._hpTrigActive == true end },
})

-- 出典: 戦闘不能時（赤）：セリフ
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.red, key = "DEAD_MESSAGE1", text = "ぐああああっ！" } } })

-- [データ] 反射耐性100%、奥義ゲージ低下耐性100%、HP吸収耐性100%、燃焼/病気/毒/暗闇耐性0%、氷結耐性30%、気絶耐性80%、その他200%、break_capacity 150,000、damage_drop_sp 20 は本番マスタ側（確認済み: enemy_master.csv id=2083480）（マスタ設定・Choreo外）

boss:publish()
