-- 自動生成: 草案_ハロウィンKoB後編_EX1～真EX極.md ラグシェルム・ファントム【真EX・極】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "ラグシェルム・ファントム", version = 2.5, id = 2086090 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 奥義ゲージ自然上昇オフ（addSP は AttackSPGain で加算）
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）。HP20% 以降は SetAttackSPGain{40}
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: CreateExtraTimer を使うためのマネージャ宣言（⚠ これが無いと onRound が配線されない）
boss:add(C.ExtraTimer{})

-- 出典: 旧 Lua skill3Light（エンドオブヘルの光の演出）
boss:add(C.Timeline{ skill3Light1 = { function(self, e) local u = e.unit or self.unit; if u == nil or u == false then return end; local o = u:addOrbitSystemWithFile('../../effect/itemskill/itemskill6001', 'attack1'); if o == nil or o == false then return end; o:setPositionX(200); o:setPositionY(0); o:setZOrder(u:getZOrder() - 400) end }, skill3Light2 = { function(self, e) local u = e.unit or self.unit; if u == nil or u == false then return end; local o = u:addOrbitSystemWithFile('../../effect/itemskill/itemskill6001', 'attack1'); if o == nil or o == false then return end; o:setPositionX(400); o:setPositionY(-100); o:setZOrder(u:getZOrder() - 400) end }, skill3Light3 = { function(self, e) local u = e.unit or self.unit; if u == nil or u == false then return end; local o = u:addOrbitSystemWithFile('../../effect/itemskill/itemskill6001', 'attack1'); if o == nil or o == false then return end; o:setPositionX(-200); o:setPositionY(100); o:setZOrder(u:getZOrder() - 400) end }, skill3Light4 = { function(self, e) local u = e.unit or self.unit; if u == nil or u == false then return end; local o = u:addOrbitSystemWithFile('../../effect/itemskill/itemskill6001', 'attack1'); if o == nil or o == false then return end; o:setPositionX(-400); o:setPositionY(-150); o:setZOrder(u:getZOrder() + 400) end }, glabEnd = { function(self, e) if self._grabEnd ~= nil then self._grabEnd(self) end end } })

-- 出典: attack_delay=6（Lua）／開始INFO／魔鎧の呪詛の同期チャンネル
boss:add(C.Start{ C.SetAttackDelay{ 6 }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE1", text = "反射・奥義ゲージ低下耐性" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "闇属性・魔族ユニットからの被ダメージアップ" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE3", text = "暗闇状態の間、被ダメージアップ" }, function(self, e)
  self._curseFloor = 0
  -- HP50%・HP20% の順番待ち（2026-11-06 の不具合対応。Mode の p50 の注記）。
  --   チャージ中（curse）と、チャージ失敗の奥義8を撃ち終わるまで（lose）は、Phases が発火しても効果に入らず待たせる。
  --   Phases の発火はホストが決めて全端末へ配り、チャージの結果もホストが配るので、待ちの中身と順番は全端末で同じになる。
  self._phaseQueue = {}
  self._enterPhase = function(d, ev, name)
    if d._mode == 'curse' or d._mode == 'lose' then
      d._phaseQueue[#d._phaseQueue + 1] = name
      return
    end
    C.SetMode{ name }(d, ev)
  end
  self._drainPhase = function(d, ev, from)
    if d._mode ~= from then return end
    local name = table.remove(d._phaseQueue, 1)
    if name == nil then name = 'normal' end
    C.SetMode{ name }(d, { unit = d.unit })
  end
  -- チャージの構え（スキル6 ナイトメア構え＝attack6・EF 1-attack6 を setUnitState(attack) で直接再生）。
  --   ブレイク中は触らない（ブレイクの状態を壊さないため）。Mode curse の onEnter と、下の update（待機に戻っていたら構え直す）から呼ぶ。
  --   構えを取れたら _stanceOn を立てる（チャージ中のブレイクで怯みを止めるかの判定に使う。チャージ開始時に下ろす）。
  self._stance = function(d)
    local u = d.unit
    if u == nil or u == false then return end
    if u.m_breaktime ~= nil and u.m_breaktime > 0 then return end
    u:setUnitState(kUnitState_attack)
    u:takeAnimation(0, 'attack6', false)
    u:takeAnimationEffect(0, '1-attack6', false)
    d._stanceOn = true
  end
  -- トゥルーナイトメアの掴み（原作 unit/500741513.lua の executeGlab／glabControll／glabEnd を移植）。全端末で同じに動かす。
  --   引き寄せ先＝skill2 の当たり判定の中心。骨 DAMAGEAREA の (150, 465) に、当たり判定と同じ倍率（getScaleY×skeleton の
  --   getScaleY）と向き（getScaleX×skeleton の getScaleX が負なら左右反転）を掛ける（BattleUtilities::spineBoundingBoxToRect と同じ）。
  --   原作は秒速300で寄せるが、時間切れからトゥルーナイトメアの当たり（skill2 の1.17秒）までに間に合わせるため、0.8秒で寄せる。
  --   掴んでいる間は気絶（離すときに外す。念のため5秒で切れる）。離したら、持ち上げた見た目（skeleton の位置）を元に戻す。
  self._grabStart = function(d)
    local idx = d._grabIndex
    d._grabIndex = nil
    if idx == nil or idx < 0 or d._grab ~= nil then return end
    local t = megast.Battle:getInstance():getTeam(true):getTeamUnit(idx)
    local u = d.unit
    if t == nil or u == nil or u == false then return end
    local bsk = u:getSkeleton()
    local sc = u:getScaleY() * bsk:getScaleY()
    local fx = 1
    if u:getScaleX() * bsk:getScaleX() < 0 then fx = -1 end
    local toX = u:getPositionX() + bsk:getPositionX() + 150 * sc * fx
    local toY = u:getPositionY() + bsk:getPositionY() + 465 * sc
    local fromX, fromY = t:getAnimationPositionX(), t:getAnimationPositionY()
    local orbit = u:addOrbitSystem('lock-on')
    if orbit ~= nil and orbit ~= false then
      orbit:takeAnimation(0, 'lock-on', true)
      orbit:setPosition(fromX, fromY)
    end
    t:getTeamUnitCondition():addCondition(208609013, 89, 1, 5, 0)
    local tsk = t:getSkeleton()
    d._grab = { unit = t, orbit = orbit, fromX = fromX, fromY = fromY, toX = toX, toY = toY, time = 0, dur = 0.8,
                skX = tsk:getPositionX(), skY = tsk:getPositionY() }
  end
  self._grabUpdate = function(d, dt)
    local g = d._grab
    local t = g.unit
    if t == nil or t:getHP() <= 0 then d._grabEnd(d); return end
    g.time = g.time + (dt or 0)
    local r = g.time / g.dur
    if r > 1 then r = 1 end
    local x = g.fromX + (g.toX - g.fromX) * r
    local y = g.fromY + (g.toY - g.fromY) * r
    if g.orbit ~= nil and g.orbit ~= false then g.orbit:setPosition(x, y) end
    local sk = t:getSkeleton()
    t:setPosition(x - sk:getBoneWorldPositionX('MAIN'), t:getPositionY())
    sk:setPosition(0, y - t:getPositionY() - sk:getBoneWorldPositionY('MAIN'))
  end
  self._grabEnd = function(d)
    local g = d._grab
    if g == nil then return end
    d._grab = nil
    local t = g.unit
    if t ~= nil then
      local cond = t:getTeamUnitCondition()
      local c = cond:findConditionWithID(208609013)
      if c ~= nil then cond:removeCondition(c) end
      t:getSkeleton():setPosition(g.skX or 0, g.skY or 0)
    end
    if g.orbit ~= nil and g.orbit ~= false then g.orbit:takeAnimation(0, 'none', false) end
  end
  self._curseApply = function(d, code)
    if d._mode ~= 'curse' then return end
    local ev = { unit = d.unit }
    if code == 1 then
      C.SetMode{ 'win' }(d, ev)
    else
      -- 時間切れ：コード 2＋10×(枠+1)。掴むユニットの枠（-1＝掴まない）を覚えてから lose へ（lose の onEnter で掴む）
      d._grabIndex = math.floor(code / 10) - 1
      C.SetMode{ 'lose' }(d, ev)
    end
  end
  self._curseDecide = function(d, code)
    if not d.isHostPlayer or d._mode ~= 'curse' then return end
    if code == 2 then
      -- 掴む相手＝チャージ中に一番ダメージを出したユニット（HateTarget の累計。チャージ開始時に ResetHate 済み）。
      --   生存している枠だけ。同値は枠の小さい方。誰も当てていなければ、生存している一番左の枠。
      --   HateTarget の首位の決め方（topIndex）と同じなので、チャージ中に表示しているターゲットを掴む。
      local team = megast.Battle:getInstance():getTeam(true)
      local best, bestVal = -1, 0
      for i = 0, 7 do
        local v = d._hateTotals ~= nil and d._hateTotals[i] or nil
        if v ~= nil and v > bestVal and team:getTeamUnit(i) ~= nil then best, bestVal = i, v end
      end
      if best < 0 then
        for i = 0, 7 do
          if team:getTeamUnit(i) ~= nil then best = i; break end
        end
      end
      code = 2 + 10 * (best + 1)
    end
    d._curseApply(d, code)
    if d._syncChannels ~= nil and d._syncChannels.curse ~= nil then
      d:broadcast('curse', code)
    end
  end
  if self._syncChannels ~= nil and self._syncChannels.curse == nil then
    self:openChannel('curse', function(d, code)
      if d._curseApply ~= nil then d._curseApply(d, code) end
    end)
    -- ブレイク中に始まったチャージ（構えをまだ取れていない＝_stanceOn が下りている）で、怯み（damage）や攻撃のモーションが
    --   終わったときは待機（takeIdle）へ流す（2026-11-06。報告：ブレイク中にチャージが始まると止まったままになる）。
    --   ホストは非ループのモーションが終わると excuteAction だけを呼ぶ（TeamUnit.cpp 2155〜2172行。ゲストは先に takeIdle を呼ぶ）ので、
    --   ここで止めるだけだと最後のコマで固まり、状態も待機に戻らないため、下の update の構え直しも働かなかった。
    --   takeIdle は下の keepStance を通る：ブレイク中は溜めのループ（skill_loop）、ブレイクが明けていれば構える。
    --   ブレイク中の被弾の怯みは今までどおり（構えを取るまでは takeDamage を止めない）。ブレイクが明けたら update で構える。
    --   ゲスト（すでに待機）と、構えを取れているとき（attack6 の最中）は何もしない。
    self:addEventListener('excuteAction', function(d, ev)
      if d._mode ~= 'curse' then return end
      ev:prevent()
      local u = ev.unit or d.unit
      if not d._stanceOn and u ~= nil and u ~= false and u:getUnitState() ~= kUnitState_idle then
        u:takeIdle()
      end
    end)
    -- 掴んでいる間、毎フレーム引き寄せる（原作の update → glabControll）
    -- チャージ中に待機（idle）へ戻っていたら構え直す（2026-11-06。報告：2回目のチャージが待機モーションになる）。
    --   奥義8の撃ち終わり（takeIdle などの最中）や怯み・ブレイクの明けにチャージへ入ると、その直後にエンジンが待機モーションで
    --   上書きする。update で待機に戻っていたら構え直す。毎フレーム叩かないよう、構えてから0.3秒は見ない。
    self:addEventListener('update', function(d, ev)
      if d._grab ~= nil then d._grabUpdate(d, ev.deltaTime) end
      if d._mode == 'curse' then
        d._stanceWait = (d._stanceWait or 0) - (ev.deltaTime or 0)
        local u = ev.unit or d.unit
        if d._stanceWait <= 0 and u ~= nil and u ~= false and not (u.m_breaktime ~= nil and u.m_breaktime > 0)
           and u:getUnitState() == kUnitState_idle then
          d._stanceWait = 0.3
          d._stance(d)
        end
      end
    end)
    -- チャージ中にブレイクしても構えを崩さない（2026-11-06 ユーザー指示）。構えを取れているチャージ中だけ、怯み（takeDamage）を止める。
    --   ブレイク（BREAK 表示・演出・ダメージ1.2倍・ブレイク時間）はそのまま。ブレイク中の被弾の怯みも止まる。
    --   エンジンは takeDamage の Lua を呼ぶ前にボスの状態を被弾中（kUnitState_damage）にするが、Lua が止めるとモーションの切り替え
    --   （setAnimation）はしない（TeamUnit.cpp 3080〜3125行）ので、構え（attack6）が続く。
    --   ブレイク中に始まったチャージ（構えをまだ取れていない）は今までどおり（ユーザー指示）。ブレイクが明けて構えたあとは止める。
    --   止めたとき（win）の気絶はチャージを抜けてから付くので、今までどおり怯みで構えが解ける。
    self:addEventListener('takeDamage', function(d, ev)
      if d._mode == 'curse' and d._stanceOn then ev:prevent() end
    end)
    -- チャージ中に待機（takeIdle）・戻り（takeBack）が来たら、エンジンに待機・戻りのモーションを再生させず、構えを取り直す
    --   （2026-11-06。報告：トゥルーナイトメアが続いたとき、2回目のチャージが溜めのモーションにならない）。
    --   奥義8の撃ち終わりでエンジンは excuteAction → takeWait → takeIdle（または takeBack）を呼び、その中の SkillFinishWatch で
    --   2回目のチャージに入る。以前はこのあと待機アニメを skill_loop に差し替えていたため、構え（attack6）が skill_loop のループで
    --   上書きされ、状態は attack のままなので update の構え直しも働かなかった。
    --   Lua が止めると、takeIdle／takeBack はモーションの再生だけを飛ばす（TeamUnit.cpp 2889〜2925・3044〜3078行。状態の設定は先に済む）。
    --   ブレイク中は今までどおり（待機アニメを skill_loop に。ブレイクが明けたら update か次の takeIdle で構える）。
    local function keepStance(d, ev, isIdle)
      local u = ev.unit or d.unit
      if d._mode ~= 'curse' or u == nil or u == false then return end
      if u.m_breaktime ~= nil and u.m_breaktime > 0 then
        if isIdle then u:setNextAnimationName('skill_loop') end
        return
      end
      ev:prevent()
      d._stanceWait = 0.3
      d._stance(d)
    end
    self:addEventListener('takeIdle', function(d, ev) keepStance(d, ev, true) end)
    self:addEventListener('takeBack', function(d, ev) keepStance(d, ev, false) end)
    -- チャージ中は通常攻撃（takeAttack）もさせず、構えを取り直す（2026-11-06。報告：トゥルーナイトメアが続いたとき2回目のチャージで棒立ち）。
    --   奥義8の撃ち終わりで攻撃の間隔が空いていなければ、engine は excuteAction → takeAttack に進む（TeamUnit.cpp 7119〜7300行）。
    --   その takeAttack（Selector の pass2）の SkillFinishWatch で2回目のチャージに入っても、engine はそのまま attackN を再生して構えを上書きし、
    --   撃ち終わると excuteAction（チャージ中は止めている）で次の動きが無く、最後のコマで止まっていた。
    --   Lua が止めると、takeAttack は attackN の再生・攻撃間隔のリセット・状態の設定をすべて飛ばす（TeamUnit.cpp 2940〜3000行）。
    --   ブレイク中は攻撃を止めるだけで構えない（明けたら update か takeIdle で構える）。
    --   ⚠ Selector の pass2 はこの前に走るので、通常攻撃のローテは1つ進む（チャージ中に1回だけ）。
    self:addEventListener('takeAttack', function(d, ev)
      if d._mode ~= 'curse' then return end
      ev:prevent()
      local u = ev.unit or d.unit
      if u ~= nil and u ~= false and not (u.m_breaktime ~= nil and u.m_breaktime > 0) then
        d._stanceWait = 0.3
        d._stance(d)
      end
    end)
  end
end })

-- 出典: スキル：スキル1 -> スキル2 ->（スキル1 or スキル4）-> （スキル2 or スキル4 or スキル5）-> スキル3 -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 4 }, { 2, 4, 5 }, { 3 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "attack5", [6] = "attack6", [7] = "skill1", [8] = "skill2", [9] = "skill3" } })

-- 出典: 奥義：奥義7 -> 繰り返し
boss:add(C.Smash{ sets = { { 7 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "attack5", [6] = "attack6", [7] = "skill1", [8] = "skill2", [9] = "skill3" } })

-- 出典: curse=魔鎧の呪詛のチャージ中／win=止めた／lose=止められなかった／p50・p20=HP50%・HP20%の効果（入ってすぐ curse・final へ）／final=HP20%トリガー中／last=HP20%の奥義9の後
boss:add(C.Mode{ initial = "normal", states = { normal = {  }, curse = { onEnter = { C.ResetHate{}, C.ShowSubGauge{ "curse" }, C.CreateExtraTimer{ key = "curse", maxTime = 15, loopLimit = 1, icon = { 0, 0 }, onRound = { function(self, e) if self._curseDecide ~= nil then self._curseDecide(self, 2) end end } }, function(self, e) self._stanceOn = false; self._stanceWait = 0.3; if self._stance ~= nil then self._stance(self) end end }, onExit = { C.HideSubGauge{ "curse" } } }, win = { onEnter = { C.RemoveExtraTimer{ key = "curse" }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208609004, type = 89, value = 1, time = 1 }, C.Say{ color = C.Color.yellow, key = "WIN_MESSAGE1", text = "トゥルーナイトメアを解除" }, C.After{ seconds = 1, actions = { function(self, e) if self._drainPhase ~= nil then self._drainPhase(self, e, 'win') end end } } } }, lose = { onEnter = { function(self, e) if self._grabStart ~= nil then self._grabStart(self) end end, C.UseSkill{ index = 8, cutin = C.Cutin.TrueArts, invincible = 30, keepGauge = true }, C.StackBuff{ id = 208609005, type = 17, value = 30, max = 2, icon = 26 }, C.Say{ color = C.Color.red, key = "LOSE_MESSAGE1", text = "トゥルーナイトメア：命中率・クリティカル率アップ" }, C.Say{ color = C.Color.red, key = "LOSE_MESSAGE2", text = "与ダメージアップ" } } }, final = { onEnter = { C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208609011, type = 112, value = 1000 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208609012, type = 113, value = 1000 } }, onExit = { C.RemoveBuff{ id = 208609011 }, C.RemoveBuff{ id = 208609012 } } }, p50 = { onEnter = { function(self, e) self._curseFloor = 0.2 end, C.StackBuff{ id = 208609002, type = 56, value = 20, max = 3, icon = 62 }, C.StackBuff{ id = 208609003, type = 105, value = 20, max = 3, icon = 0 }, C.SetMode{ "curse" }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208609007, type = 31, value = 50, time = 999999, icon = 16 }, C.Say{ color = C.Color.red, key = "CURSE_MESSAGE1", text = "トゥルーナイトメア：一定ダメージで解除" }, C.Say{ color = C.Color.yellow, key = "CURSE_MESSAGE2", text = "トゥルーナイトメア準備中、ダメージの大きいものをターゲット" }, C.Say{ color = C.Color.yellow, key = "HP50_MESSAGE1", text = "回避率・暗闇耐性アップ" } } }, p20 = { onEnter = { C.CureStatus{}, C.StackBuff{ id = 208609002, type = 56, value = 20, max = 3, icon = 62 }, C.StackBuff{ id = 208609003, type = 105, value = 20, max = 3, icon = 0 }, C.SetMode{ "final" }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208609006, type = 17, value = 50, time = 999999, icon = 26, group = -1, aura = true }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208609008, type = 23, value = -80, time = 999999, icon = 188, group = -1 }, C.SetAttackDelay{ 5 }, C.SetAttackSPGain{ 40 }, C.UseSkill{ index = 9, cutin = C.Cutin.TrueArts, keepGauge = true }, C.Say{ color = C.Color.magenta, key = "HP20_MESSAGE1", text = "巨神の干渉により《深淵強化》が発動" }, C.Say{ color = C.Color.red, key = "HP20_MESSAGE2", text = "与ダメージ・行動速度・奥義ゲージ上昇量・クリティカル耐性アップ" }, C.Say{ color = C.Color.yellow, key = "HP20_MESSAGE3", text = "暗闇耐性アップ" } } }, last = {  } } })

-- 出典: エクストラゲージ中、ボスへのダメージが一番多いユニットをターゲット（フォーカス表示）。トゥルーナイトメアで掴む相手（素のダメージの累計。チャージ開始時に ResetHate）
boss:add(C.HateTarget{ rule = "hate", icon = 14, mode = "curse" })

-- 出典: 魔鎧の呪詛のゲージ（最大HPの20%。ゲージには素のダメージ、本体HPには×0.2）
boss:add(C.SubGauge{ key = "curse", hpRate = 0.2, protect = 0.2, onBreak = { function(self, e) if self._curseDecide ~= nil then self._curseDecide(self, 1) end end } })

-- 出典: チャージ中は次のHPラインを割らない（結果が出てから次を発動）／HP20%トリガー中は TakeDamageValue×0.1
boss:add(C.Defense{
  { mode = "curse", mult = function(self, e) local u = self.unit; local floor = u:getCalcHPMAX() * (self._curseFloor or 0) + 1; local room = u:getHP() - floor; if room <= 0 then return 0 end; if e.value > room then return room / e.value end; return 1 end },
  { mult = 0.1, mode = "final" },
})

-- 出典: HP80%・HP50%：魔鎧の呪詛（チャージ）／HP20%：魔鎧崩壊（ブレイク中でも発動・スキップ不可・ゲージ引き継ぎ）
boss:add(C.Phases{
  { at = 80, stop = true, deferWhileSkill = true, actions = { function(self, e) self._curseFloor = 0.5 end, C.StackBuff{ id = 208609002, type = 56, value = 20, max = 3, icon = 62 }, C.StackBuff{ id = 208609003, type = 105, value = 20, max = 3, icon = 0 }, C.SetMode{ "curse" }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208609001, type = 21, value = -70, script = { id = 2 }, time = 999999, icon = 21, group = -1 }, C.Say{ color = C.Color.red, key = "CURSE_MESSAGE1", text = "トゥルーナイトメア：一定ダメージで解除" }, C.Say{ color = C.Color.yellow, key = "CURSE_MESSAGE2", text = "トゥルーナイトメア準備中、ダメージの大きいものをターゲット" }, C.Say{ color = C.Color.yellow, key = "HP80_MESSAGE1", text = "物理・暗闇耐性アップ" } } },
  { at = 50, stop = true, deferWhileSkill = true, actions = { function(self, e) if self._enterPhase ~= nil then self._enterPhase(self, e, 'p50') end end } },
  { at = 20, stop = true, deferWhileSkill = true, actions = { function(self, e) if self._enterPhase ~= nil then self._enterPhase(self, e, 'p20') end end } },
})

-- 出典: 奥義8（トゥルーナイトメア）を撃ち終わったら無敵解除
boss:add(C.SkillFinishWatch{ onSkill = { 8 }, onFinish = { C.Invincible{ seconds = 0 }, function(self, e) if self._grabEnd ~= nil then self._grabEnd(self) end end, function(self, e) if self._drainPhase ~= nil then self._drainPhase(self, e, 'lose') end end } })

-- 出典: HP20% の奥義9（エンドオブヘル）を撃ち終わったら final を解除
boss:add(C.SkillFinishWatch{ onSkill = { 9 }, onFinish = { C.SetMode{ "last" } } })

-- [データ] 反射耐性100%・奥義ゲージ低下耐性100%（HP吸収耐性は 2026-11-05 にやめた）、闇属性・魔族ユニットからの被ダメージ50%アップ（60028000/60026900）、暗闇状態のとき被ダメージ50%アップ（60019800）、燃焼・病気・毒耐性0%、暗闇耐性20%、麻痺・氷結・気絶耐性300%、その他の状態異常耐性200%、break_capacity 400000、damage_drop_sp 18、技の効果（パワーダンク・魔剣コンビネーション・魔剣撃の暗闇、咆哮の奥義ゲージ50ダウン、ヘルグロリアの被ダメージアップ、トゥルーナイトメアの命中率・クリティカル率・HP吸収5000%、エンドオブヘルの命中率・最大HPダウン）は本番マスタ側（enemy_master.csv id=2086090 ／ skill_effect_master）。⚠ 技・アビリティは skill_relation_master に未登録、防御力・暗闇耐性はマスタと草案が違う（マスタ設定・Choreo外）

boss:publish()
