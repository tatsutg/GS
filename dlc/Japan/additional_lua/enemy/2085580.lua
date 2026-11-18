-- 自動生成: CML④ギミックFIX版.md ヴォルフリート【真EX】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "ヴォルフリート", version = 2.8, id = 2085580 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: attack_delay=9（Lua）／開幕INFO（緑1本＋黄3本）
boss:add(C.Start{ C.SetAttackDelay{ 9 }, C.Say{ color = C.Color.green, key = "START_MESSAGE1", text = "武器を捨て投降しなさい" }, C.Say{ key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE3", text = "樹属性・人族ユニットからの被ダメージアップ" }, C.Say{ key = "START_MESSAGE4", text = "累計ダメージの大きいユニットをターゲット" } })

-- 出典: 累計ダメージの一番大きいユニットをターゲットにする（フォーカス表示あり）
boss:add(C.HateTarget{ rule = "hate", icon = 14 })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 繰り返し／奥義3発動時にターゲットを封圧＋累計ダメージリセット
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, onUse = { [3] = { function(self, e) local team = megast.Battle:getInstance():getTeam(true); local t = self.unit:getHateTarget(); if t ~= nil and t ~= false then local ok, ti = pcall(t.getIndex, t); t = (ok and ti ~= nil) and team:getTeamUnit(ti) or nil end; if t == nil or t == false then local idx = self._hateTargetIndex; if idx ~= nil and idx >= 0 then t = team:getTeamUnit(idx) end; if t == nil or t == false then local best, bestVal = nil, 0; local totals = self._hateTotals; if totals ~= nil then for i = 0, 7 do local u = team:getTeamUnit(i); local v = totals[i]; if u ~= nil and u ~= false and v ~= nil and v > bestVal then best, bestVal = u, v end end end; t = best end; if t == nil or t == false then for i = 0, 7 do local u = team:getTeamUnit(i); if u ~= nil and u ~= false then t = u; break end end end end; if t == nil or t == false then return end; local sec = 1 + ((e and e.useCount) or 1) * 2; (C.AttachBuff{ target = t, id = 208558001, type = 92, value = 100, time = sec, icon = 303, group = -1 })(self, e); (C.AttachBuff{ target = t, id = 208558002, type = 30, value = -50, time = sec, icon = 0, group = -1 })(self, e) end, C.ResetHate{ scope = "target" }, C.Say{ color = C.Color.red, side = "player", key = "SKILL3_MESSAGE1", text = "ターゲットを封圧状態" }, C.IfUseCount{ count = 1, actions = { C.Say{ color = C.Color.red, side = "player", key = "SKILL3_MESSAGE2", text = "封圧：封印効果に加え、効果中装備CTダウン" } } } } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 封圧の連動解除: 封印回復などで封印(92)が消えたら、同時に付けた装備CTダウン(30)も外す
boss:add(C.PlayerStatus{ types = { 92 }, onExit = { C.RemoveBuff{ id = 208558002 } } })

-- 出典: HP75%：奥義カットインで奥義3（スキップ可）／HP25%：状態異常回復＋真奥義カットインで奥義4＋奥義ゲージ100アップ
boss:add(C.Phases{
  { at = 75, actions = { C.UseSkill{ index = 3, cutin = C.Cutin.Arts }, C.Say{ color = C.Color.green, key = "HP75_MESSAGE1", text = "現行犯を確認" } } },
  { at = 25, stop = true, deferWhileBreak = true, deferWhileSkill = true, actions = { function(self, e) self._hpTrigActive = true; self._hpTrigPending = true; self._gaugeAfterSkill = true; (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208558003, type = 112, value = 1000 })(self, e); (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208558004, type = 113, value = 1000 })(self, e) end, C.CureStatus{}, C.UseSkill{ index = 4, cutin = C.Cutin.TrueArts }, C.Say{ color = C.Color.green, key = "HP25_MESSAGE1", text = "君たちは包囲されている" } } },
})

-- 出典: HP25%トリガー窓の解除: 奥義4の撃ち終わりで TakeDamageValue×0.1 フラグ・状態異常耐性バフを解除／奥義ゲージ100アップ
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = { function(self, e) (C.RemoveBuff{ target = C.Targeting{ pick = 'self' }, id = 208558003 })(self, e); (C.RemoveBuff{ target = C.Targeting{ pick = 'self' }, id = 208558004 })(self, e) end, function(self, e) if self._gaugeAfterSkill then self._gaugeAfterSkill = nil; (C.GainSP{ 100 })(self, e) end end } })

-- 出典: ※HP25%トリガーは発動から奥義を撃ち終わるまで TakeDamageValue補正×0.1
boss:add(C.Defense{
  { mult = 0.1, when = function(self, e) return self._hpTrigActive == true end },
})

-- 出典: 戦闘不能時（緑）：セリフ
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.green, key = "DEAD_MESSAGE1", text = "ぐおおおおおお！！" } } })

-- [データ] HP 10,000,000、攻撃力2,000、防御力2,500、break_capacity 450,000、damage_drop_sp 20 は本番マスタ側（確認済み: enemy_master.csv id=2085580。草案と全て一致）。反射耐性100%・奥義ゲージ低下耐性100%・HP吸収耐性100%・人族/樹属性ユニットからの被ダメージ50%アップ・燃焼/病気/毒耐性0%・麻痺/氷結/気絶耐性80%・その他200% もデータ側（被ダメUPは Lua 側に入れると二重適用になるため入れない）（マスタ設定・Choreo外）

boss:publish()
