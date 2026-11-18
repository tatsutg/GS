-- 自動生成: CML③ギミック草案.md 色泥棒オニキス【真EX・極】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "色泥棒オニキス", version = 2.8, id = 2084490 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: attack_delay=8（Lua）／開幕INFO（紫1本＋黄3本）
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ color = C.Color.magenta, key = "START_MESSAGE1", text = "今宵も全部奪ってあげる" }, C.Say{ key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE3", text = "状態異常のユニットの全ステータスダウン" }, C.Say{ key = "START_MESSAGE4", text = "オニキスが状態異常を付与する度に、状態異常に応じた属性耐性アップ" } })

-- 出典: 状態異常のプレイヤーユニットの全ステータス40%ダウン（重複しない）／状態異常を付与するたび対応属性耐性10%アップ（アイコンにカウント・最大20・付与した数だけ上昇）
boss:add(C.PlayerStatus{ onEnter = { C.AttachBuff{ id = 208449001, type = 2, value = -40, icon = 211, group = -1 }, C.AttachBuff{ id = 208449002, type = 13, value = -40, icon = 0, group = -1 }, C.AttachBuff{ id = 208449003, type = 15, value = -40, icon = 0, group = -1 } }, onExit = { C.RemoveBuff{ id = 208449001 }, C.RemoveBuff{ id = 208449002 }, C.RemoveBuff{ id = 208449003 } }, onInflict = { [97] = { C.StackBuff{ id = 208449011, type = 61, value = 10, max = 20, icon = 38 }, C.Say{ color = C.Color.red, key = "BURN_MESSAGE1", text = "炎属性耐性アップ" } }, [94] = { C.StackBuff{ id = 208449012, type = 62, value = 10, max = 20, icon = 39 }, C.Say{ color = C.Color.cyan, key = "SICK_MESSAGE1", text = "水属性耐性アップ" } }, [90] = { C.StackBuff{ id = 208449013, type = 63, value = 10, max = 20, icon = 40 }, C.Say{ color = C.Color.green, key = "POISON_MESSAGE1", text = "樹属性耐性アップ" } }, [91] = { C.StackBuff{ id = 208449014, type = 64, value = 10, max = 20, icon = 41 }, C.Say{ key = "PARALYSIS_MESSAGE1", text = "光属性耐性アップ" } }, [95] = { C.StackBuff{ id = 208449015, type = 65, value = 10, max = 20, icon = 42 }, C.Say{ color = C.Color.magenta, key = "CURSE_MESSAGE1", text = "闇属性耐性アップ" } } } })

-- 出典: unit/104357512.lua run: Library_skill2_orbit（蝶オービット）／Magan（魔眼＋背景モノクロ）／grayLwfOff（モノクロ解除）
boss:add(C.Timeline{ Library_skill2_orbit = { function(self, e) local u = self.unit or e.unit; if u == nil or u == false then return end; local t = megast.Battle:getInstance():getTeam(false); if t == nil or t == false then return end; for i = 0, 7 do local m = t:getTeamUnit(i); if m ~= nil and m ~= false then local o = u:addOrbitSystem('skill2_orbit', 0); if o ~= nil and o ~= false then local sk = m:getSkeleton(); if sk ~= nil and sk ~= false then local vec = m:getisPlayer() and 1 or -1; o:setPosition(m:getPositionX() + sk:getBoneWorldPositionX('MAIN') * vec, m:getPositionY() + sk:getBoneWorldPositionY('MAIN')); local oskel = o:getSkeleton(); if oskel ~= nil and oskel ~= false then oskel:setPosition(0, sk:getPositionY()) end else o:setPosition(m:getPositionX(), m:getPositionY()) end end end end end }, Magan = { function(self, e) local u = self.unit or e.unit; if u == nil or u == false then return end; local o = u:addOrbitSystemWithFile('Magan_Onyx', 'Activation'); if o == nil or o == false then return end; o:setAutoZOrder(true); o:setZOderOffset(-5000); o:setPosition(u:getPositionX(), u:getPositionY()) end, C.SetBackgroundGrayScale{ 0 } }, grayLwfOff = { C.ResetBackgroundGrayScale{} } })

-- 出典: スキル：スキル1 -> （スキル2〜6のいずれか） -> （スキル2〜6のいずれか） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2, 3, 4, 5, 6 }, { 2, 3, 4, 5, 6 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill1", [4] = "skill1", [5] = "skill1", [6] = "skill1", [7] = "skill2", [8] = "skill3", [9] = "skill5" } })

-- 出典: 奥義：奥義8 -> 奥義9 -> 繰り返し
boss:add(C.Smash{ sets = { { 8 }, { 9 } }, cutin = { [9] = C.Cutin.SuperArts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill1", [4] = "skill1", [5] = "skill1", [6] = "skill1", [7] = "skill2", [8] = "skill3", [9] = "skill5" } })

-- 出典: HP75%：奥義7を発動（カットインなどはなし）、Add SP = 30、与ダメージ20%アップ／HP25%：超奥義カットインで奥義9を発動
boss:add(C.Phases{
  { at = 75, actions = { C.UseSkill{ index = 7 }, C.SetAttackSPGain{ 30 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208449004, type = 17, value = 20, time = 999999, icon = 26, group = -1 }, C.Say{ color = C.Color.magenta, key = "HP75_MESSAGE1", text = "ビードロの蝶たちよ" }, C.Say{ key = "HP75_MESSAGE2", text = "奥義上昇量・与ダメージアップ" } } },
  { at = 25, stop = true, deferWhileSkill = true, actions = { function(self, e) self._hpTrigPending = true; self._hpTrigActive = true end, C.UseSkill{ index = 9, cutin = C.Cutin.SuperArts, invincible = 30, keepGauge = true }, function(self, e) local t = megast.Battle:getInstance():getTeam(true); if t == nil or t == false then return end; for i = 0, 7 do local u = t:getTeamUnit(i); if u ~= nil and u ~= false then (C.AttachBuff{ target = u, id = 208449005, type = 21, script = { id = 3 }, icon = 175, value = { countParty = 'element', per = 25 }, time = 999999, group = -1 })(self, e) end end end, C.Say{ color = C.Color.magenta, key = "HP25_MESSAGE1", text = "開け、グリザイユの世界――" }, C.Say{ key = "HP25_MESSAGE2", text = "ユニットの属性数が多い程魔法耐性ダウン" } } },
})

-- 出典: ※HP25%トリガーは発動から奥義を撃ち終わるまで無敵／奥義9の撃ち終わり・中断で背景モノクロを必ず解除
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = { C.Invincible{ seconds = 0 }, C.ResetBackgroundGrayScale{} } })

-- 出典: 戦闘不能時（紫）：セリフ
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.magenta, key = "DEAD_MESSAGE1", text = "きゃああああ…！" }, C.ResetBackgroundGrayScale{} } })

-- [データ] 反射耐性100%、奥義ゲージ低下耐性100%、HP吸収耐性100%、人族・闇属性ユニットからの被ダメージ50%アップ、燃焼/病気/毒耐性0%、麻痺/氷結/気絶耐性80%、その他200%、break_capacity 800,000、damage_drop_sp 18、防御力2,000 は本番マスタ側（確認済み: enemy_master.csv id=2084490。被ダメUPは Lua 側に入れると二重適用になるため入れない＝2083480.yaml の修正履歴に準拠）／HP25% の「魔法耐性を生存プレイヤーの属性数×25%ダウン」は **Lua 側（Phases HP25% の escape + AttachBuff）に移した**ので、本番マスタの奥義9 にある `21 value25 time99999 target3 script_id=534` の行は **削除が必須**（残すと二重適用、かつ奥義9 は通常ローテにも入っているので HP25% 以外でも発火する）（マスタ設定・Choreo外）

boss:publish()
