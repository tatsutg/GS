--@additionalEnemy,2084183,2084184
-- 自動生成: セティスギミック草案.md 断照の鬼武者セティス【真EX】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "断照の鬼武者セティス", version = 2.5, id = 2084180 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: CreateExtraTimerを使うためにマネージャ宣言が必要
boss:add(C.ExtraTimer{})

-- 出典: attack_delay=7（Lua）／開始INFO／開始時スキル3（魔血開眼）発動／ExtraTimerA開始
boss:add(C.Start{ C.SetAttackDelay{ 7 }, C.Say{ color = C.Color.cyan, key = "START_MESSAGE1", text = "進軍開始だ" }, C.Say{ text = "反射・HP吸収・奥義ゲージ低下・クリティカル耐性" }, C.Say{ text = "魔族・水属性ユニットからの被ダメージアップ" }, C.Say{ text = "一定時間が経過でギンゾウが増援：ギンゾウがいるとセティスの防御力アップ" }, function(self, e) self._startTrigActive = true; (C.UseSkill{ index = 3 })(self, e) end, C.CreateExtraTimer{ key = "A", maxTime = 15, loopLimit = 999, icon = { 0, 0 }, slot = 1, of = 2, onRound = { C.SpawnEnemy{ enemy = { 2084183, 2084184 }, max = 6, slots = 7 } }, speedRules = { { when = { invincible = true }, speed = 0 }, { when = { breaking = true }, speed = 0 } } } })

-- 出典: ギンゾウ監視：生存中→防御力アップ、全滅→解除、撃破毎→被ダメージスタック
boss:add(C.Minions{ enemies = { 2084183, 2084184 }, onAlive = { C.AttachBuff{ id = 208418011, type = 15, value = 100, icon = 5 } }, onEmpty = { C.RemoveBuff{ id = 208418011 } }, onKill = { C.StackBuff{ id = 208418012, type = 21, value = 10, max = 99, icon = 139 }, C.Say{ color = C.Color.yellow, key = "MINION_KILL_MSG", text = "ギンゾウ撃破！セティスの被ダメージアップ" } } })

-- 出典: バリアゲージ表示（type=98吸収量をミラー）：早期破壊時はタイマーB削除＋フラグリセット
boss:add(C.SubGauge{ key = "barrier", mirror = { conditionType = 98 }, max = 750000, offsetY = 0, onBreak = { C.HideSubGauge{ "barrier" }, C.RemoveExtraTimer{ key = "B" }, function(self, e) self._barrierActive = false end } })

-- 出典: スキル：スキル1 -> スキル2 -> スキル1,2同時 -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill5", [4] = "skill2", [5] = "skill3", [6] = "skill5b" }, animeff = { [3] = "skill5kaigan", [4] = "ShieldBuff", [6] = "2-skill5" } })

-- 出典: 奥義：奥義4→5 繰り返し。4=Arts、5=TrueArts、(HP50%突破)6=SuperArts。奥義4発動時バリア展開
boss:add(C.Smash{ sets = { { 4 }, { 5 } }, cutin = { [4] = C.Cutin.Arts, [5] = C.Cutin.TrueArts, [6] = C.Cutin.SuperArts }, onUse = { [3] = { C.Say{ color = C.Color.cyan, key = "START_MESSAGE2", text = "呼び覚ませ、魔血の真の力を" } }, [4] = { function(self, e) if self._barrierActive then return end; self._barrierActive = true; (C.AttachBuff{ id = 208418001, type = 98, value = 750000, time = 15, icon = 24 })(self, e); (C.ShowSubGauge{ 'barrier' })(self, e); (C.CreateExtraTimer{ key = 'B', maxTime = 15, loopLimit = 1, icon = { 24, 0 }, slot = 2, of = 2, onRound = { C.HideSubGauge{ 'barrier' }, function(self, e) self._barrierActive = false end } })(self, e); (C.Say{ color = C.Color.yellow, key = 'SKILL4_MSG', text = '天照を断つ青雷の盾：一定時間、一定ダメージ無効化' })(self, e) end } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill5", [4] = "skill2", [5] = "skill3", [6] = "skill5b" }, animeff = { [3] = "skill5kaigan", [4] = "ShieldBuff", [6] = "2-skill5" } })

-- 出典: 奥義3(魔血開眼)/奥義6(百鬼招来狂嵐無尽)の撃ち終わり検知を1本に集約
boss:add(C.SkillFinishWatch{ onSkill = { 3, 6 }, onFinish = { function(self, e) if self._startTrigActive then self._startTrigActive = false; (C.SpawnOrbit{ target = C.Targeting{ pick = 'self' }, key = 'kaigan', file = 'BloodKaigan2', anim = 'Kaigan_in', orbitType = 'aura', follow = true, zOrder = 'top', chain = { after = 'Kaigan_in', anim = 'Kaigan_loop', loop = true } })(self, e) end if self._hpTrigActive then self._hpTrigActive = false; (C.RemoveBuff{ id = 208418021 })(self, e); (C.RemoveBuff{ id = 208418022 })(self, e) end end } })

-- 出典: HP50%（ブレイクスルー）：超奥義カットインでスキル6発動、型112/113バフ付与、受ダメ0.01倍
boss:add(C.Phases{
  { at = 50, stop = true, actions = { function(self, e) local u = self.unit; if u.m_breaktime ~= nil and u.m_breaktime > 0 then return end; self._hpTrigActive = true; (C.AttachBuff{ id = 208418021, type = 112, value = 1 })(self, e); (C.AttachBuff{ id = 208418022, type = 113, value = 1 })(self, e); (C.UseSkill{ index = 6, cutin = C.Cutin.SuperArts, keepGauge = true })(self, e); (C.Say{ color = C.Color.cyan, key = 'HP50_MESSAGE1', text = '戦場に集いし鬼武者たちよ！' })(self, e); (C.Say{ color = C.Color.yellow, key = 'HP50_MESSAGE2', text = '百鬼招来狂嵐無尽：発動中、防御力アップ' })(self, e) end } },
})

-- 出典: スキル発動中（_startTrigActive || _hpTrigActive）はTakeDamageValue=0.01倍
boss:add(C.Defense{
  { mult = 0.01, when = function(self, e) return self._startTrigActive == true or self._hpTrigActive == true end },
})

-- 出典: 戦闘不能時（青）：セリフ
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.cyan, key = "DEAD_MESSAGE1", text = "リヴィエラ…ボクは…" } } })

-- [データ] 反射・HP吸収・奥義ゲージ低下・クリティカル耐性100%、魔族/水属性からの被ダメージアップ、break_capacity 200000、damage_drop_sp 20 は本番マスタ側（マスタ設定・Choreo外）

boss:publish()
