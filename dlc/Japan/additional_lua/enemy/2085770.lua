-- 自動生成: ハロウィンジュノー_ギミック.md 聖女ジュノー【EX2】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "聖女ジュノー（ハロウィンver）", version = 2.5, id = 2085770 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: CreateExtraTimer を使うためのマネージャ宣言（⚠ これが無いと onRound が配線されない）
boss:add(C.ExtraTimer{})

-- 出典: attack_delay=8（Lua）／開始INFO／ハッピーハロウィン（20秒タイマー）開始
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE1", text = "ハッピーハロウィーン！！" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE3", text = "HP50％以上のユニットにお菓子、HP50％未満のユニットにイタズラ" }, function(self, e)
  self._hwTreatFirst = true
  self._hwTrickFirst = true
  local sayTreat = C.Say{ color = C.Color.yellow, key = 'TREAT_MESSAGE1', text = 'ハッピーハロウィン！' }
  local sayTrick = C.Say{ color = C.Color.yellow, key = 'TRICK_MESSAGE1', text = 'イタズラしちゃうぞ～' }
  local sayTreatInfo = C.Say{ color = C.Color.yellow, key = 'TREAT_MESSAGE2', text = 'お菓子：HPが50％以上のユニットにクリティカル率アップ' }
  local sayTrickInfo = C.Say{ color = C.Color.yellow, key = 'TRICK_MESSAGE2', text = 'イタズラ：HPが50％未満のユニットに呪い付与' }
  self._hwApply = function(d, code)
    local team = megast.Battle:getInstance():getTeam(true)
    local treat, trick = false, false
    for i = 0, 7 do
      local c = math.floor(code / 4 ^ i) % 4
      local u = team:getTeamUnit(i)
      if c == 1 then
        treat = true
        if u ~= nil then
          C.AttachBuff{ target = u, id = 208577001, type = 22, value = 10, time = 5, icon = 11, group = 208577001 }(d, e)
        end
      elseif c >= 2 then
        trick = true
        if c == 2 and u ~= nil then
          C.AttachBuff{ target = u, id = 208577002, type = 95, value = 1, time = 5, icon = 85, group = 208577002 }(d, e)
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
end, C.CreateExtraTimer{ key = "halloween", maxTime = 20, loopLimit = 999, icon = { 0, 0 }, onRound = { function(self, e)
  if not self.isHostPlayer or self._hwApply == nil then return end
  local Random = require('summoner.Random')
  local team = megast.Battle:getInstance():getTeam(true)
  local code = 0
  for i = 0, 7 do
    local u = team:getTeamUnit(i)
    if u ~= nil then
      local c = 1
      if u:getHP() / u:getCalcHPMAX() < 0.5 then
        local cond = u:getTeamUnitCondition()
        local avoid = cond:findConditionValue(107) + cond:findConditionValue(113)
        if avoid < 0 then avoid = 0 elseif avoid > 100 then avoid = 100 end
        if Random.range(0, 100) < 50 * (100 - avoid) / 100 then c = 2 else c = 3 end
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
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: 奥義：奥義3 -> 繰り返し
boss:add(C.Smash{ sets = { { 3 } }, cutin = { [3] = C.Cutin.Arts }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3" } })

-- 出典: HP50%：奥義カットインで奥義4を発動（スキップ可）
boss:add(C.Phases{
  { at = 50, actions = { C.UseSkill{ index = 4, cutin = C.Cutin.Arts }, C.Say{ color = C.Color.yellow, key = "HP50_MESSAGE1", text = "激しく行くわよっ！" } } },
})

-- 出典: 死亡時（黄）：やられたー！　あなた、強いのね！
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.yellow, key = "DEAD_MESSAGE1", text = "やられたー！　あなた、強いのね！" } } })

-- [データ] 反射耐性100%・奥義ゲージ低下耐性100%・HP吸収耐性100%（skill_relation_master relation_type=4: 60006700/60006800/60006600）、毒・病気・燃焼・暗闇耐性0%、氷結耐性30%、気絶耐性50%、その他の状態異常耐性200%、break_capacity 100000、damage_drop_sp 20 は本番マスタ側（enemy_master.csv id=2085770）。⚠ 防御力はマスタ 100／草案 500（草案が正。マスタは後で修正）（マスタ設定・Choreo外）

boss:publish()
