-- 自動生成: サイバーマンシー5_EX1～真EX極.md 剣客怪盗ヘリオルド【真EX】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "剣客怪盗ヘリオルド", version = 1.3, id = 2086480 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=10（Lua）。HP70% を踏むと SetAttackSPGain{20}、HP30% で SetAttackSPGain{30}
boss:add(C.AttackSPGain{ value = 10 })

-- 出典: attack_delay=8（Lua）／開始INFO（黄4行）。見切り状態は下の Mode の初期状態で始まる
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE1", text = "斬らざるを得んか…" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE3", text = "光属性・人族ユニットからの被ダメージアップ" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE4", text = "見切り：魔法回避率アップ・CRI以外の被ダメージ軽減：暗闇で解除" }, function(self, e) self:addEventListener('takeBreakeDamageValue', function(d, ev) if d._hpTrigActive == true then ev.value = 0 end end) end, C.After{ seconds = 0.5, actions = { function(self, e) megast.Battle:getInstance():updateConditionView() end } } })

-- 出典: 見切り状態（mikiri）で開始／ボスが暗闇の間だけ見切りが解ける（open）
boss:add(C.Mode{ initial = "mikiri", states = { mikiri = { onEnter = { C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208648001, type = 31, value = 80, time = 999999, icon = 16, group = -1, script = { id = 3 } }, function(self, e) megast.Battle:getInstance():updateConditionView() end }, onExit = { C.RemoveBuff{ id = 208648001 }, function(self, e) megast.Battle:getInstance():updateConditionView() end } }, open = {  } } })

-- 出典: 自身が暗闇状態の間だけ見切りが解ける／暗闇が解けるたびに暗闇耐性20%アップ（アイコンにカウント）
boss:add(C.OnStatus{ key = "blind", types = { 93 }, actions = { C.SetMode{ "open" }, C.Say{ color = C.Color.yellow, key = "BLIND_MESSAGE1", text = "見切り解除" } }, onEnd = { C.StackBuff{ id = 208648002, type = 56, value = 20, icon = 62 }, C.StackBuff{ id = 208648003, type = 105, value = 20, icon = 0 }, C.SetMode{ "mikiri" }, C.Say{ color = C.Color.yellow, key = "BLIND_MESSAGE2", text = "暗闇耐性アップ" } } })

-- 出典: 見切り状態：クリティカル以外の被ダメージ×0.5／HP30%トリガー中（発動から撃ち終わるまで）TakeDamageValue×0.1
boss:add(C.Defense{
  { mult = 0.5, when = function(self, e)
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
  { mult = 0.1, when = function(self, e) return self._hpTrigActive == true end },
})

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 繰り返し
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: HP70%：奥義カットインで奥義3＆addSP=20（ブレイクスルー）／HP30%：状態異常回復＆見切り状態＆真奥義カットインで奥義4＆addSP=30（スキップ不可・ブレイク中も発動・TakeDamageValue×0.1・状態異常耐性1000%・ゲージ引き継ぎ）
boss:add(C.Phases{
  { at = 70, stop = true, breakthrough = true, actions = { function(self, e) local u = self.unit; if u.m_breaktime ~= nil and u.m_breaktime > 0 then return end; (C.UseSkill{ index = 3, cutin = C.Cutin.Arts })(self, e); (C.SetAttackSPGain{ 20 })(self, e); (C.Say{ color = C.Color.yellow, key = 'HP70_MESSAGE1', text = '躱せるかよ' })(self, e); (C.Say{ color = C.Color.yellow, key = 'HP70_MESSAGE2', text = '奥義ゲージ上昇量アップ' })(self, e) end } },
  { at = 30, stop = true, deferWhileSkill = true, actions = { C.CureStatus{}, C.SetMode{ "mikiri" }, function(self, e) self._hpTrigPending = true; self._hpTrigActive = true end, function(self, e) local u = self.unit; if u:getBreakPoint() <= 0 then u:setBreakPoint(u:getBaseBreakCapacity()) end end, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208648011, type = 112, value = 1000 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208648012, type = 113, value = 1000 }, C.SetAttackSPGain{ 30 }, C.UseSkill{ index = 4, cutin = C.Cutin.TrueArts, keepGauge = true }, C.Say{ color = C.Color.yellow, key = "HP30_MESSAGE1", text = "陰ノ剣" }, C.Say{ color = C.Color.yellow, key = "HP30_MESSAGE2", text = "奥義ゲージ上昇量アップ" } } },
})

-- 出典: HP30% の奥義4を撃ち終わったら窓を閉じる（TakeDamageValue×0.1・状態異常耐性1000% を外す）
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = { C.RemoveBuff{ id = 208648011 }, C.RemoveBuff{ id = 208648012 } } })

-- 出典: 戦闘不能時（黄）：しくじった…！
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.yellow, key = "DEAD_MESSAGE1", text = "しくじった…！" } } })

-- [データ] 反射耐性100%・奥義ゲージ低下耐性100%・HP吸収耐性100%・人族ユニット/光属性ユニットからの被ダメージ50%アップ・命中率50%アップ（アビリティ 60006700／60006800／60006600／60030000／60028600／60013200。skill_relation_master relation_type=4 に未登録）、燃焼・病気・毒・暗闇耐性0%・麻痺・氷結・気絶耐性80%・その他200%、HP 10,000,000・break_capacity 450,000・damage_drop_sp 20 は本番マスタ側（enemy_master.csv id=2086480。⚠ 防御力はマスタ 2500 ／ 草案 2000、暗闇耐性はマスタ 200% ／ 草案 0%）。被ダメUPは Lua 側に入れると二重適用になるため入れない。天暁剣・虚蝉の奥義ゲージ10アップと明星一閃の暗闇（80%・10秒・命中率50%ダウン）もデータの技効果（マスタ設定・Choreo外）

boss:publish()
