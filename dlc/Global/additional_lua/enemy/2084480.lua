-- 自動生成: CML③ギミック草案.md 色泥棒オニキス【真EX】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "色泥棒オニキス", version = 2.8, id = 2084480 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: attack_delay=9（Lua）／開幕INFO（紫1本＋黄2本）
boss:add(C.Start{ C.SetAttackDelay{ 9 }, C.Say{ color = C.Color.magenta, key = "START_MESSAGE1", text = "今宵も全部奪ってあげる" }, C.Say{ key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE3", text = "状態異常のユニットの全ステータスダウン" } })

-- 出典: 状態異常のプレイヤーユニットの全ステータス20%ダウン（状態異常が複数重複してもこの効果は重複しない）
boss:add(C.PlayerStatus{ onEnter = { C.AttachBuff{ id = 208448001, type = 2, value = -20, icon = 211, group = -1 }, C.AttachBuff{ id = 208448002, type = 13, value = -20, icon = 0, group = -1 }, C.AttachBuff{ id = 208448003, type = 15, value = -20, icon = 0, group = -1 } }, onExit = { C.RemoveBuff{ id = 208448001 }, C.RemoveBuff{ id = 208448002 }, C.RemoveBuff{ id = 208448003 } } })

-- 出典: unit/104357512.lua run: Library_skill2_orbit（蝶オービット）／Magan（魔眼＋背景モノクロ）／grayLwfOff（モノクロ解除）
boss:add(C.Timeline{ Library_skill2_orbit = { function(self, e) local u = self.unit or e.unit; if u == nil or u == false then return end; local t = megast.Battle:getInstance():getTeam(false); if t == nil or t == false then return end; for i = 0, 7 do local m = t:getTeamUnit(i); if m ~= nil and m ~= false then local o = u:addOrbitSystem('skill2_orbit', 0); if o ~= nil and o ~= false then local sk = m:getSkeleton(); if sk ~= nil and sk ~= false then local vec = m:getisPlayer() and 1 or -1; o:setPosition(m:getPositionX() + sk:getBoneWorldPositionX('MAIN') * vec, m:getPositionY() + sk:getBoneWorldPositionY('MAIN')); local oskel = o:getSkeleton(); if oskel ~= nil and oskel ~= false then oskel:setPosition(0, sk:getPositionY()) end else o:setPosition(m:getPositionX(), m:getPositionY()) end end end end end }, Magan = { function(self, e) local u = self.unit or e.unit; if u == nil or u == false then return end; local o = u:addOrbitSystemWithFile('Magan_Onyx', 'Activation'); if o == nil or o == false then return end; o:setAutoZOrder(true); o:setZOderOffset(-5000); o:setPosition(u:getPositionX(), u:getPositionY()) end, C.SetBackgroundGrayScale{ 0 } }, grayLwfOff = { C.ResetBackgroundGrayScale{} } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 奥義：奥義4 -> 繰り返し
boss:add(C.Smash{ sets = { { 4 } }, cutin = { [5] = C.Cutin.SuperArts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: HP75%：奥義3を発動（カットインなどはなし）、Add SP = 25／HP25%：超奥義カットインで奥義5を発動
boss:add(C.Phases{
  { at = 75, actions = { C.UseSkill{ index = 3 }, C.SetAttackSPGain{ 25 }, C.Say{ color = C.Color.magenta, key = "HP75_MESSAGE1", text = "ビードロの蝶たちよ" }, C.Say{ key = "HP75_MESSAGE2", text = "奥義上昇量アップ" } } },
  { at = 25, stop = true, deferWhileSkill = true, actions = { function(self, e) self._hpTrigActive = true; self._hpTrigPending = true; (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208448004, type = 112, value = 1000 })(self, e); (C.AttachBuff{ target = C.Targeting{ pick = 'self' }, id = 208448005, type = 113, value = 1000 })(self, e); (C.UseSkill{ index = 5, cutin = C.Cutin.SuperArts, keepGauge = true })(self, e) end, function(self, e) local t = megast.Battle:getInstance():getTeam(true); if t == nil or t == false then return end; for i = 0, 7 do local u = t:getTeamUnit(i); if u ~= nil and u ~= false then (C.AttachBuff{ target = u, id = 208448006, type = 21, script = { id = 3 }, icon = 175, value = { countParty = 'element', per = 10 }, time = 999999, group = -1 })(self, e) end end end, C.Say{ color = C.Color.magenta, key = "HP25_MESSAGE1", text = "開け、グリザイユの世界――" }, C.Say{ key = "HP25_MESSAGE2", text = "ユニットの属性数が多い程魔法耐性ダウン！" } } },
})

-- 出典: HP25%トリガー窓の解除: 奥義5の撃ち終わりで TakeDamageValue×0.1 フラグ・状態異常耐性バフを解除
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onSkill = { 5 }, onFinish = { function(self, e) local u = self.unit or e.unit; if u == nil or u == false then return end; local c = u:getTeamUnitCondition(); local a = c:findConditionWithGroupID(112); if a ~= nil then c:removeCondition(a) end; local b = c:findConditionWithGroupID(113); if b ~= nil then c:removeCondition(b) end end, C.ResetBackgroundGrayScale{} } })

-- 出典: ※HP25%トリガーは発動から奥義を撃ち終わるまで TakeDamageValue補正×0.1
boss:add(C.Defense{
  { mult = 0.1, when = function(self, e) return self._hpTrigActive == true end },
})

-- 出典: 戦闘不能時（紫）：セリフ
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.magenta, key = "DEAD_MESSAGE1", text = "何も…見えない……" }, C.ResetBackgroundGrayScale{} } })

-- [データ] 反射耐性100%、奥義ゲージ低下耐性100%、HP吸収耐性100%、人族・闇属性ユニットからの被ダメージ50%アップ、燃焼/病気/毒耐性0%、麻痺/氷結/気絶耐性80%、その他200%、break_capacity 450,000、damage_drop_sp 20 は本番マスタ側（確認済み: enemy_master.csv id=2084480。被ダメUPは Lua 側に入れると二重適用になるため入れない＝2083480.yaml の修正履歴に準拠）／HP25% の「魔法耐性を生存プレイヤーの属性数×10%ダウン」は **Lua 側（Phases HP25% の escape + AttachBuff）に移した**ので、本番マスタの奥義5 にある `21 value10 time99999 target3 script_id=534` の行は **削除が必須**（残すと二重適用）（マスタ設定・Choreo外）

boss:publish()
