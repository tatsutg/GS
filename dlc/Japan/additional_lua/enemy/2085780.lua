-- 自動生成: ハロウィンジュノー_ギミック.md 聖女ジュノー【真EX】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "聖女ジュノー（ハロウィンver）", version = 2.5, id = 2085780 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）。HP30% 以降は SetAttackSPGain{30}
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: CreateExtraTimer を使うためのマネージャ宣言（⚠ これが無いと onRound が配線されない）
boss:add(C.ExtraTimer{})

-- 出典: attack_delay=7（Lua）／開始INFO／ハッピーハロウィン（10秒タイマー）開始
boss:add(C.Start{ C.SetAttackDelay{ 7 }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE1", text = "ハッピーハロウィーン！！" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE3", text = "光属性・魔族ユニットからの被ダメージアップ" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE4", text = "HP80％以上のユニットにお菓子、HP80％未満のユニットにイタズラ" }, function(self, e)
  self._hwTreatFirst = true
  self._hwTrickFirst = true
  local sayTreat = C.Say{ color = C.Color.yellow, key = 'TREAT_MESSAGE1', text = 'ハッピーハロウィン！' }
  local sayTrick = C.Say{ color = C.Color.yellow, key = 'TRICK_MESSAGE1', text = 'イタズラしちゃうぞ～' }
  local sayTreatInfo = C.Say{ color = C.Color.yellow, key = 'TREAT_MESSAGE2', text = 'お菓子：HPが80％以上のユニットにクリティカル率アップ' }
  local sayTrickInfo = C.Say{ color = C.Color.yellow, key = 'TRICK_MESSAGE2', text = 'イタズラ：HPが80％未満のユニットに呪い付与' }
  self._hwApply = function(d, code)
    local team = megast.Battle:getInstance():getTeam(true)
    local treat, trick = false, false
    for i = 0, 7 do
      local c = math.floor(code / 4 ^ i) % 4
      local u = team:getTeamUnit(i)
      if c == 1 then
        treat = true
        if u ~= nil then
          C.AttachBuff{ target = u, id = 208578001, type = 22, value = 30, time = 10, icon = 11, group = 208578001 }(d, e)
        end
      elseif c >= 2 then
        trick = true
        if c == 2 and u ~= nil then
          C.AttachBuff{ target = u, id = 208578002, type = 95, value = 1, time = 10, icon = 85, group = 208578002 }(d, e)
        end
      end
    end
    megast.Battle:getInstance():updateConditionView()
    if treat then sayTreat(d, e) end
    if trick then sayTrick(d, e) end
    if treat and d._hwTreatFirst then
      d._hwTreatFirst = false
      sayTreatInfo(d, e)
    end
    if trick and d._hwTrickFirst then
      d._hwTrickFirst = false
      sayTrickInfo(d, e)
    end
  end
  if self._syncChannels ~= nil and self._syncChannels.halloween == nil then
    self:openChannel('halloween', function(d, code)
      if d._hwApply ~= nil then d._hwApply(d, code) end
    end)
  end
end, C.CreateExtraTimer{ key = "halloween", maxTime = 10, loopLimit = 999, icon = { 0, 0 }, onRound = { function(self, e)
  if not self.isHostPlayer or self._hwApply == nil then return end
  local Random = require('summoner.Random')
  local team = megast.Battle:getInstance():getTeam(true)
  local code = 0
  for i = 0, 7 do
    local u = team:getTeamUnit(i)
    if u ~= nil then
      local c = 1
      if u:getHP() / u:getCalcHPMAX() < 0.8 then
        local cond = u:getTeamUnitCondition()
        local avoid = cond:findConditionValue(107) + cond:findConditionValue(113)
        if avoid < 0 then avoid = 0 elseif avoid > 100 then avoid = 100 end
        if Random.range(0, 100) < 80 * (100 - avoid) / 100 then c = 2 else c = 3 end
      end
      code = code + c * 4 ^ i
    end
  end
  self._hwApply(self, code)
  if self._syncChannels ~= nil and self._syncChannels.halloween ~= nil then
    self:broadcast('halloween', code)
  end
end }, speedRules = { { when = { breaking = true }, speed = 0 } } } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 繰り返し
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, cutin = { [3] = C.Cutin.Arts, [4] = C.Cutin.Arts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: trigger=HP30%トリガー中（状態異常耐性1000%アップ・TakeDamageValue×0.2）
boss:add(C.Mode{ initial = "normal", states = { normal = {  }, trigger = { onEnter = { C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208578011, type = 112, value = 1000 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208578012, type = 113, value = 1000 } }, onExit = { C.RemoveBuff{ id = 208578011 }, C.RemoveBuff{ id = 208578012 } } } } })

-- 出典: HP30%トリガー中（発動から撃ち終わるまで）は TakeDamageValue×0.2
boss:add(C.Defense{
  { mult = 0.2, mode = "trigger" },
})

-- 出典: HP30%：状態異常回復＆AddSP=30＆超奥義カットインで奥義5（ブレイク中でも発動・スキップ不可・ゲージ引き継ぎ）
boss:add(C.Phases{
  { at = 30, stop = true, deferWhileSkill = true, actions = { C.CureStatus{}, function(self, e) self._hpTrigPending = true; self._hpTrigActive = true end, C.SetMode{ "trigger" }, C.SetAttackSPGain{ 30 }, C.UseSkill{ index = 5, cutin = C.Cutin.SuperArts, keepGauge = true }, C.Say{ color = C.Color.yellow, key = "HP30_MESSAGE1", text = "これが聖義の必殺技！" }, C.Say{ color = C.Color.yellow, key = "HP30_MESSAGE2", text = "奥義ゲージ上昇量アップ" } } },
})

-- 出典: HP30% の奥義5を撃ち終わったら trigger を解除（TakeDamageValue×0.2・状態異常耐性を外す）
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = { C.SetMode{ "normal" } } })

-- 出典: 死亡時（黄）：やられたー！　あなた、強いのね！
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.yellow, key = "DEAD_MESSAGE1", text = "やられたー！　あなた、強いのね！" } } })

-- [データ] 反射耐性100%・奥義ゲージ低下耐性100%・HP吸収耐性100%（skill_relation_master relation_type=4: 60006700/60006800/60006600）、光属性・魔族ユニットからの被ダメージ50%アップ（60028600/60026900）、燃焼・病気・毒耐性0%、麻痺・氷結・気絶耐性80%、その他の状態異常耐性200%、break_capacity 200000、damage_drop_sp 20 は本番マスタ側（enemy_master.csv id=2085780）。被ダメUPは Lua 側に入れると二重適用になるため入れない（マスタ設定・Choreo外）

boss:publish()
