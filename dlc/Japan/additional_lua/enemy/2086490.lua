-- 自動生成: サイバーマンシー5_EX1～真EX極.md 剣客怪盗ヘリオルド【真EX・極】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "剣客怪盗ヘリオルド", version = 1.3, id = 2086490 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）。HP70% を踏むと SetAttackSPGain{30}
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: unit/104407412.lua run: Magan（奥義5 真域・百刃曼荼羅の魔眼の演出）
boss:add(C.Timeline{ Magan = { function(self, e) local u = (e ~= nil and e.unit) or self.unit; local m = u:addOrbitSystemWithFile('Magan_Herold', 'Activation'); if m == nil then return end; m:setAutoZOrder(true); m:setZOderOffset(-5000); local vec = u:getisPlayer() and 1 or -1; local sk = u:getSkeleton(); m:setPosition(u:getPositionX() + sk:getBoneWorldPositionX('root') * vec, u:getPositionY() + sk:getBoneWorldPositionY('root')) end } })

-- 出典: attack_delay=7（Lua）／開始INFO（黄4行）。見切り状態は下の Mode の初期状態で始まる
boss:add(C.Start{ C.SetAttackDelay{ 7 }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE1", text = "斬らざるを得んか…" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE3", text = "光属性・人族ユニットからの被ダメージアップ" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE4", text = "見切り：魔法回避率アップ・CRI以外の被ダメージ軽減：暗闇で解除" }, function(self, e) self:addEventListener('takeBreakeDamageValue', function(d, ev) if d._hpTrigActive == true then ev.value = 0 end end) end, C.After{ seconds = 0.5, actions = { function(self, e) megast.Battle:getInstance():updateConditionView() end } } })

-- 出典: 見切り状態（mikiri）で開始／ボスが暗闇の間だけ見切りが解ける（open）
boss:add(C.Mode{ initial = "mikiri", states = { mikiri = { onEnter = { C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208649001, type = 31, value = 80, time = 999999, icon = 16, group = -1, script = { id = 3 } }, function(self, e) megast.Battle:getInstance():updateConditionView() end }, onExit = { C.RemoveBuff{ id = 208649001 }, function(self, e) megast.Battle:getInstance():updateConditionView() end } }, open = {  } } })

-- 出典: 自身が暗闇状態の間だけ見切りが解ける／暗闇が解けるたびに暗闇耐性20%アップ（アイコンにカウント）
boss:add(C.OnStatus{ key = "blind", types = { 93 }, actions = { C.SetMode{ "open" }, C.Say{ color = C.Color.yellow, key = "BLIND_MESSAGE1", text = "見切り解除" } }, onEnd = { C.StackBuff{ id = 208649002, type = 56, value = 20, icon = 62 }, C.StackBuff{ id = 208649003, type = 105, value = 20, icon = 0 }, C.SetMode{ "mikiri" }, C.Say{ color = C.Color.yellow, key = "BLIND_MESSAGE2", text = "暗闇耐性アップ" } } })

-- 出典: 見切り状態：クリティカル以外の被ダメージ×0.3／HP50%トリガー中（発動から撃ち終わるまで）TakeDamageValue×0.05
boss:add(C.Defense{
  { mult = 0.3, when = function(self, e)
  if self._mode ~= 'mikiri' then return false end
  local a = e.enemy
  local info = nil
  if a ~= nil then
    while a:getParentTeamUnit() ~= nil do a = a:getParentTeamUnit() end
    info = a:getTeamUnitCondition():getDamageAffectInfo()
  elseif e.unit ~= nil then
    info = e.unit:getTeamUnitCondition():getDamageAffectInfo()
  end
  return info == nil or not info.critical
end },
  { mult = 0.05, when = function(self, e) return self._hpTrigActive == true end },
})

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 繰り返し／奥義3のたびに与ダメージ15%アップ（最大10）／奥義4のたびにヒットに関係なく敵全体の物理ダメージ30%ダウン（最大3）
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, onUse = { [3] = { C.StackBuff{ id = 208649005, type = 17, value = 15, max = 10, icon = 26 }, C.IfUseCount{ count = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }, actions = { C.Say{ color = C.Color.yellow, key = "SKILL3_MESSAGE1", text = "与ダメージアップ" } } } }, [4] = { C.StackDebuff{ id = 208649004, type = 17, value = -30, max = 3, icon = 344, group = -1, script = { id = 4 } }, C.Say{ color = C.Color.red, side = "player", key = "SKILL4_MESSAGE1", text = "物理ダメージダウン" } } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: HP70%：奥義カットインで奥義3＆addSP=30（ブレイクスルー）／HP50%：状態異常回復＆見切り状態＆真奥義カットインで奥義4（スキップ不可・TakeDamageValue×0.05・状態異常耐性1000%・ゲージ引き継ぎ）／HP20%：状態異常回復＆見切り状態＆超奥義カットインで奥義5＆attack_delay=5（スキップ不可・無敵・ゲージ引き継ぎ）
boss:add(C.Phases{
  { at = 70, stop = true, breakthrough = true, actions = { function(self, e) local u = self.unit; if u.m_breaktime ~= nil and u.m_breaktime > 0 then return end; (C.UseSkill{ index = 3, cutin = C.Cutin.Arts })(self, e); (C.SetAttackSPGain{ 30 })(self, e); (C.Say{ color = C.Color.yellow, key = 'HP70_MESSAGE1', text = '躱せるかよ' })(self, e); (C.Say{ color = C.Color.yellow, key = 'HP70_MESSAGE2', text = '奥義ゲージ上昇量アップ' })(self, e) end } },
  { at = 50, stop = true, deferWhileSkill = true, actions = { C.CureStatus{}, C.SetMode{ "mikiri" }, function(self, e) self._hpTrigPending = true; self._hpTrigActive = true end, function(self, e) local u = self.unit; if u:getBreakPoint() <= 0 then u:setBreakPoint(u:getBaseBreakCapacity()) end end, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208649011, type = 112, value = 1000 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208649012, type = 113, value = 1000 }, C.UseSkill{ index = 4, cutin = C.Cutin.TrueArts, keepGauge = true }, C.Say{ color = C.Color.yellow, key = "HP50_MESSAGE1", text = "陰ノ剣" } } },
  { at = 20, stop = true, deferWhileSkill = true, actions = { C.CureStatus{}, C.SetMode{ "mikiri" }, function(self, e) self._hpTrigPending = true; self._hpTrigActive = true end, C.SetAttackDelay{ 5 }, C.UseSkill{ index = 5, cutin = C.Cutin.SuperArts, invincible = 30, keepGauge = true }, C.Say{ color = C.Color.yellow, key = "HP20_MESSAGE1", text = "アーク・解放" }, C.Say{ color = C.Color.yellow, key = "HP20_MESSAGE2", text = "行動速度アップ" } } },
})

-- 出典: HP50% の奥義4・HP20% の奥義5を撃ち終わったら窓を閉じる（TakeDamageValue×0.05・状態異常耐性1000%・無敵を外す）
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = { C.Invincible{ seconds = 0 }, C.RemoveBuff{ id = 208649011 }, C.RemoveBuff{ id = 208649012 } } })

-- 出典: 戦闘不能時（黄）：しくじった…！
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.yellow, key = "DEAD_MESSAGE1", text = "しくじった…！" } } })

-- [データ] 反射耐性100%・奥義ゲージ低下耐性100%・HP吸収耐性100%・人族ユニット/光属性ユニットからの被ダメージ50%アップ・命中率50%アップ（アビリティ 60006700／60006800／60006600／60030000／60028600／60013200。skill_relation_master relation_type=4 に未登録）、燃焼・病気・毒耐性0%・暗闇耐性10%・麻痺・氷結・気絶耐性300%・その他200%、break_capacity 800,000・damage_drop_sp 18 は本番マスタ側（enemy_master.csv id=2086490。⚠ HP・防御力・暗闇耐性・麻痺/氷結/気絶耐性がマスタと草案で違う）。被ダメUPは Lua 側に入れると二重適用になるため入れない。天暁剣・虚蝉の奥義ゲージ10アップ、明星一閃の暗闇（100%・20秒・命中率50%ダウン）、天暁逆流れの攻撃力30%ダウン（10秒）、百刃曼荼羅のこの奥義中クリティカル率30%アップと奥義ゲージ50ダウンもデータの技効果（マスタ設定・Choreo外）

boss:publish()
