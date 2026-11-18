-- 自動生成: グランドバトル仕様スプレッドシート EP7エリアボス／CODE XTF:SEEKER (gid=451810724) → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "グランドバトルEP7_エリアボス_CODE XTF:SEEKER", version = 2.3, id = "gb_701601" }

-- 出典: CODE XTF 種の定型（スキン・形態・ファンネル/ボール/ミサイル/照準レーザー・addSP=25）
boss:add(C.KindSeeker{ spineSP = 25, funnel = { auto = false }, laser = { aim = { indices = { 3 } } } })

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（ゲージは addSP=25 の演出同期加算のみ）
boss:add(C.SPGain{ value = 0 })

-- 出典: attack_delay=8.0（Lua）／階層とパーティ構成の確定／開幕INFO
boss:add(C.Start{ C.SetAttackDelay{ 8.0 }, function(self, e)
  local B = megast.Battle:getInstance()
  self._gbFloor = B:getCurrentGrandBattleFloor() or 0
  self._domElement, self._domRace, self._domDone = nil, nil, false

  self._ensureDom = function(d)
    if d._domDone then return end
    local team = megast.Battle:getInstance():getTeam(true)
    local els, ras, ec, rc = {}, {}, {}, {}
    for i = 0, 7 do
      local u = team:getTeamUnit(i)
      if u ~= nil then
        local el, ra = u:getElementType(), u:getRaceType()
        if el ~= nil then
          if ec[el] == nil then ec[el] = 0; table.insert(els, el) end
          ec[el] = ec[el] + 1
        end
        if ra ~= nil then
          if rc[ra] == nil then rc[ra] = 0; table.insert(ras, ra) end
          rc[ra] = rc[ra] + 1
        end
      end
    end
    if #els == 0 then return end
    d._domDone = true
    local be, bn = nil, 0
    for i = 1, #els do if ec[els[i]] > bn then be, bn = els[i], ec[els[i]] end end
    d._domElement = be
    local br, rn = nil, 0
    for i = 1, #ras do if rc[ras[i]] > rn then br, rn = ras[i], rc[ras[i]] end end
    d._domRace = br
    local ICON = { [1] = { 61, 38 }, [2] = { 62, 39 }, [3] = { 63, 40 }, [4] = { 64, 41 }, [5] = { 65, 42 } }
    local ic = ICON[be]
    if ic ~= nil and d.unit ~= nil and d.unit ~= false then
      d.unit:getTeamUnitCondition():addCondition(70160104, ic[1], 0, 999999, ic[2])
      megast.Battle:getInstance():updateConditionView()
    end
  end

  if self.eventListeners['attackDamageValue'] == nil then
    local hook = function(d, ev)
      d._ensureDom(d)
      local f = d._gbFloor or 0
      local up = f * 10
      local t = ev.enemy
      if t ~= nil then
        while t:getParentTeamUnit() ~= nil do t = t:getParentTeamUnit() end
        if d._domRace ~= nil and t:getRaceType() == d._domRace then
          up = up + 30 + f
        end
      end
      if up <= 0 then return end
      local s2 = 0
      local u = ev.unit or d.unit
      if u ~= nil and u ~= false then
        local sc = u:getTeamUnitCondition():findConditionWithID(70160101)
        if sc ~= nil then s2 = sc:getValue() or 0 end
      end
      ev.value = ev.value * (1 + up / (100 + s2))
    end
    self:addEventListener('attackDamageValue', hook)
    self:addEventListener('attackDamageValue_OrbitSystem', hook)
  end
end, C.Say{ key = "START_MESSAGE1", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE2", text = "全体付与のCRI率アップ・防御無視効果無効" }, C.Say{ key = "START_MESSAGE3", text = "CRI耐性ダウン無効" }, C.Say{ key = "START_MESSAGE4", text = "パーティで一番多い属性のダメージを軽減" }, C.Say{ key = "START_MESSAGE5", text = "パーティで一番多い種族に対してダメージアップ" } })

-- 出典: 180秒の時間制限あり。タイムアップで敗北（表示は他のEP7エリアボス gb_703601/704601/705601 と同一）
boss:add(C.TimeLimit{ seconds = 180, redtime = 30, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

-- 出典: パーティで一番多い属性の属性ダメージに対して takeDamageValue補正×[1÷(3+階層×0.05)]
boss:add(C.Defense{
  { mult = function(self, e) return 1 / (3 + (self._gbFloor or 0) * 0.05) end, when = function(self, e) if self._ensureDom ~= nil then self._ensureDom(self) end; local a = e.enemy; if a == nil or self._domElement == nil then return false end; while a:getParentTeamUnit() ~= nil do a = a:getParentTeamUnit() end; return a:getElementType() == self._domElement end },
})

-- 出典: スキル：スキル1(ヴァルカン)->スキル2(ミサイル)->スキル3(サブアームレーザー)->スキル4(メインアームビーム)->繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 3 }, { 4 } }, anim = { [1] = "attack1", [2] = "attack4", [3] = "attack5", [4] = "attack6", [5] = "skill3", [6] = "skill4", [7] = "skill5" } })

-- 出典: 奥義：奥義5(イレイサーキャノン)->奥義6(ユリ＝バニラ)->繰り返し。奥義7はHP20%トリガー専用（真奥義カットイン）
boss:add(C.Smash{ sets = { { 5 }, { 6 } }, cutin = { [7] = C.Cutin.TrueArts }, onUse = { [5] = { C.StackBuff{ id = 70160101, type = 17, value = 10, max = 99, icon = 26 } }, [6] = { C.StackBuff{ id = 70160101, type = 17, value = 10, max = 99, icon = 26 } } }, anim = { [1] = "attack1", [2] = "attack4", [3] = "attack5", [4] = "attack6", [5] = "skill3", [6] = "skill4", [7] = "skill5" } })

-- 出典: HP20%：真奥義カットインで奥義7を発動＆防御力アップ[700+階層×30]%（パーティへの永続封印はデータ側）
boss:add(C.Phases{
  { at = 20, stop = true, actions = { function(self, e) self._hpTrigActive = true; self._hpTrigPending = true; self.unit:setInvincibleTime(10) end, function(self, e) local v = math.floor(700 + (self._gbFloor or 0) * 30); self.unit:getTeamUnitCondition():addCondition(70160102, 15, v, 999999, 5) end, C.UseSkill{ index = 7, cutin = C.Cutin.TrueArts, keepGauge = true }, C.Say{ key = "HP20_MESSAGE1", text = "防御力アップ" } } },
})

-- 出典: HPトリガー窓の解除: 奥義7撃ち終わりで無敵を解除
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = function(self, e) local u = self.unit or e.unit; if u == nil or u == false then return end; u:setInvincibleTime(0); self._hpTrigActive = false end })

-- [データ] 反射耐性100%・奥義ゲージ低下耐性100%・HP吸収耐性100%・命中率50%UP・攻撃力50%UP（⚠ 与ダメージ[階層×10]%UP は Lua 側へ移管したのでデータ側では付けないこと）、ステータス式は gb_enemy_master id=701601 の実データ準拠（HP 7000a^2+120000a+200000／攻撃 a*10+500／防御 1000+a*10／break_capacity 140a^2+150a+40000／need_sp 100／damage_drop_sp 15）。⚠ 仕様シートは HP 6000a^2+100000a+200000・break_capacity 120a^2+1000a+50000 でマスタと食い違う（要確認）、アビリティ『全体クリティカル率アップ・全体防御無視を無効化』は本番マスタ側（gb_enemy_master id=701601）（マスタ設定・Choreo外）

boss:publish()
