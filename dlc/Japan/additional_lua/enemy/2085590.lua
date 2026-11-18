-- 自動生成: CML④ギミックFIX版.md ヴォルフリート【真EX・極】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "ヴォルフリート", version = 2.8, id = 2085590 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=25（Lua）
boss:add(C.AttackSPGain{ value = 25 })

-- 出典: unit/104377312.lua run: Library_efskill5（奥義5のエフェクトオービット）
boss:add(C.Timeline{ Library_efskill5 = { C.SpawnOrbit{ anim = "efskill5", type = 0, damageRate = 0.5, breakRate = 0.5 } } })

-- 出典: 【MEGA_D-9763】奥義5（skill5）で efskill5 オービット（取り分 0.5）を 1 本出す分を、ボスの技の予告に知らせる（表示専用。本体は 1.0 のまま＝合計 1.5。直すかは企画の判断待ち）
boss:add(C.AnnounceOrbit{ smash = { [5] = { rate = 0.5, count = 1 } } })

-- 出典: attack_delay=8（Lua）／開幕INFO（緑1本＋黄3本）
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ color = C.Color.green, key = "START_MESSAGE1", text = "武器を捨て投降しなさい" }, C.Say{ key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE3", text = "樹属性・人族ユニットからの被ダメージアップ" }, C.Say{ key = "START_MESSAGE4", text = "累計ダメージの大きいユニットをターゲット" } })

-- 出典: 累計ダメージの一番大きいユニットをターゲットにする（フォーカス表示あり）
boss:add(C.HateTarget{ rule = "hate", icon = 14 })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 奥義：奥義3 -> 奥義3 -> 奥義4 -> 繰り返し／奥義3発動時に封圧＋累計リセット／奥義5発動時のINFO
boss:add(C.Smash{ sets = { { 3 }, { 3 }, { 4 } }, onUse = { [3] = { function(self, e) local team = megast.Battle:getInstance():getTeam(true); local t = self.unit:getHateTarget(); if t ~= nil and t ~= false then local ok, ti = pcall(t.getIndex, t); t = (ok and ti ~= nil) and team:getTeamUnit(ti) or nil end; if t == nil or t == false then local idx = self._hateTargetIndex; if idx ~= nil and idx >= 0 then t = team:getTeamUnit(idx) end; if t == nil or t == false then local best, bestVal = nil, 0; local totals = self._hateTotals; if totals ~= nil then for i = 0, 7 do local u = team:getTeamUnit(i); local v = totals[i]; if u ~= nil and u ~= false and v ~= nil and v > bestVal then best, bestVal = u, v end end end; t = best end; if t == nil or t == false then for i = 0, 7 do local u = team:getTeamUnit(i); if u ~= nil and u ~= false then t = u; break end end end end; if t == nil or t == false then return end; local sec = 8 + ((e and e.useCount) or 1) * 2; (C.AttachBuff{ target = t, id = 208559001, type = 92, value = 100, time = sec, icon = 303, group = -1 })(self, e); (C.AttachBuff{ target = t, id = 208559002, type = 30, value = -100, time = sec, icon = 0, group = -1 })(self, e) end, C.ResetHate{ scope = "target" }, C.Say{ color = C.Color.red, side = "player", key = "SKILL3_MESSAGE1", text = "ターゲットを封圧状態" }, C.IfUseCount{ count = 1, actions = { C.Say{ color = C.Color.red, side = "player", key = "SKILL3_MESSAGE2", text = "封圧：封印効果に加え、効果中装備CTダウン" } } } }, [5] = { C.Say{ color = C.Color.red, key = "SKILL5_MESSAGE1", text = "アイゼン・フォルシュトレッカー：ダメージ無効化無効" }, C.After{ seconds = 1, actions = { C.Say{ color = C.Color.green, key = "SKILL5_MESSAGE2", text = "みせてやろう――" }, C.Say{ color = C.Color.green, key = "SKILL5_MESSAGE3", text = "『鋼鉄』たる所以を！" } } } } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 封圧の連動解除: 封印回復などで封印(92)が消えたら、同時に付けた装備CTダウン(30)も外す
boss:add(C.PlayerStatus{ types = { 92 }, onExit = { C.RemoveBuff{ id = 208559002 } } })

-- 出典: HP75%：奥義3（スキップ可）／HP25%：状態異常回復＋真奥義で奥義4＋ゲージ100＋回復量90%ダウン／HP0.5%：状態異常回復＋オーラ＋HP30%回復＋超奥義で奥義5＋全ステータスUP効果反転
boss:add(C.Phases{
  { at = 75, actions = { C.UseSkill{ index = 3, cutin = C.Cutin.Arts }, C.Say{ color = C.Color.green, key = "HP75_MESSAGE1", text = "現行犯を確認" } } },
  { at = 25, stop = true, deferWhileBreak = true, deferWhileSkill = true, actions = { function(self, e) self._hpTrigActive = true; self._hpTrigPending = true; self._gaugeAfterSkill = true; (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208559003, type = 112, value = 1000 })(self, e); (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208559004, type = 113, value = 1000 })(self, e) end, C.CureStatus{}, C.UseSkill{ index = 4, cutin = C.Cutin.TrueArts }, C.AttachBuff{ target = C.Targeting{ pick = "all" }, id = 208559005, type = 110, value = -90, time = 999999, icon = 162, group = -1 }, C.Say{ color = C.Color.green, key = "HP25_MESSAGE1", text = "君たちは包囲されている" }, C.Say{ color = C.Color.red, side = "player", key = "HP25_MESSAGE2", text = "回復量大幅ダウン" } } },
  { at = 0.5, stop = true, deferWhileBreak = true, deferWhileSkill = true, actions = { function(self, e) self._hpTrigActive = true; self._hpTrigPending = true end, C.CureStatus{}, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208559006, type = 0, value = 0, time = 999999, icon = 0, group = -1, aura = true }, C.SetHP{ rate = 0.3 }, C.InvertBuffs{ time = 30 }, C.UseSkill{ index = 5, cutin = C.Cutin.SuperArts, invincible = 10, keepGauge = true }, C.Say{ color = C.Color.green, key = "HP05_MESSAGE1", text = "忘れるな…この身を…賭した…選択を……" }, C.Say{ color = C.Color.red, key = "HP05_MESSAGE2", text = "全ステータスアップ効果反転" } } },
})

-- 出典: HPトリガー窓の解除: 奥義の撃ち終わりで被ダメ補正フラグ・状態異常耐性・無敵を解除／HP25%なら奥義ゲージ100アップ
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = { C.Invincible{ seconds = 0 }, function(self, e) (C.RemoveBuff{ target = C.Targeting{ pick = 'self' }, id = 208559003 })(self, e); (C.RemoveBuff{ target = C.Targeting{ pick = 'self' }, id = 208559004 })(self, e) end, function(self, e) if self._gaugeAfterSkill then self._gaugeAfterSkill = nil; (C.GainSP{ 100 })(self, e) end end } })

-- 出典: ※HP25%トリガーは発動から奥義を撃ち終わるまで TakeDamageValue補正×0.005
boss:add(C.Defense{
  { mult = 0.005, when = function(self, e) return self._hpTrigActive == true end },
})

-- 出典: プレイヤーユニット全滅時（緑）：セリフ
boss:add(C.OnPartyWipe{ actions = { C.Say{ color = C.Color.green, key = "WIPE_MESSAGE1", text = "貴方には黙秘権と、弁護人を選任する権利があります。" } } })

-- 出典: 戦闘不能時（緑）：セリフ
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.green, key = "DEAD_MESSAGE1", text = "この…私…がっ……！？" } } })

-- [データ] HP 26,000,000、攻撃力2,000、防御力4,500、break_capacity 800,000、damage_drop_sp 18 は本番マスタ側（確認済み: enemy_master.csv id=2085590。草案と全て一致）。反射耐性100%・奥義ゲージ低下耐性100%・HP吸収耐性100%・人族/樹属性ユニットからの被ダメージ50%アップ・燃焼/病気/毒耐性0%・麻痺/氷結/気絶耐性80%・その他200% もデータ側（被ダメUPは Lua 側に入れると二重適用になるため入れない）（マスタ設定・Choreo外）

boss:publish()
