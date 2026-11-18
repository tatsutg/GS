-- 自動生成: ハロウィンジュノー_ギミック.md 「暴食」のリヴィエラ【真EX・極】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "「暴食」のリヴィエラ", version = 1.2, id = 2085795 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: attack_delay=6（Lua）。開始INFO は竜（ボス）側にまとめている
boss:add(C.Start{ C.SetAttackDelay{ 6 } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3_2" }, animeff = { [4] = "2skill3_2" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 繰り返し
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, cutin = { [3] = C.Cutin.Arts, [4] = C.Cutin.Arts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3_2" }, animeff = { [4] = "2skill3_2" } })

-- 出典: クリティカル以外のダメージをtakeDamageValue補正で1にする
boss:add(C.Defense{
  { set = 1, when = function(self, e)
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
})

-- 出典: リヴィエラ戦闘不能時（緑）：油断した～！　エルプネ君、あとはお願い！（緑命竜の怒りの INFO は竜側の Mode anger が出す）
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.green, key = "DEAD_MESSAGE1", text = "油断した～！　エルプネ君、あとはお願い！" } } })

-- [データ] 反射耐性100%・奥義ゲージ低下耐性100%・HP吸収耐性100%（skill_relation_master relation_type=4: 60006700/60006800/60006600）、光属性・魔族ユニットからの被ダメージ50%アップ（60028600/60026900）、与えたダメージの300%をHP吸収（60003600）、HP80％以下のユニットへのダメージ50％UP（60044400）、燃焼・病気・毒耐性0%、麻痺・氷結・気絶耐性300%、その他の状態異常耐性200%、break_capacity 250000、damage_drop_sp 18 は本番マスタ側（enemy_master.csv id=2085795）（マスタ設定・Choreo外）

boss:publish()
