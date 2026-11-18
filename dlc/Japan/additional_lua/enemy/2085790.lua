-- 自動生成: ハロウィンジュノー_ギミック.md 緑命竜エルプネウマス【真EX・極】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "緑命竜エルプネウマス", version = 1.2, id = 2085790 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: addSP=20（Lua。spine addSP イベント同期・大型ボス定型）。怒り状態で SetSpineSPGain{30}
boss:add(C.SpineSPGain{ value = 20 })

-- 出典: 竜種の共有ギミック。スキル1（火球）= attack1 の spine fire イベントで火球オービットを発射
boss:add(C.KindDragon{ fire = {  } })

-- 出典: 緑命：リヴィエラが生存している間、毎秒100,000回復
boss:add(C.Regen{ perSec = 0 })

-- 出典: attack_delay=6（Lua）／開始INFO（6行。2体ぶんをボス側にまとめる。1〜4行目は開始時、5〜6行目は7秒後）
boss:add(C.Start{ C.SetAttackDelay{ 6 }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE1", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ color = C.Color.yellow, key = "START_MESSAGE2", text = "光属性・魔族ユニットからの被ダメージアップ" }, C.Say{ color = C.Color.green, key = "START_MESSAGE3", text = "緑命竜：魔族以外のダメージ軽減" }, C.Say{ color = C.Color.green, key = "START_MESSAGE4", text = "緑命竜のHPが自然回復：リヴィエラを倒すと解除" }, C.After{ seconds = 7, actions = { C.Say{ color = C.Color.green, key = "START_MESSAGE5", text = "リヴィエラ：クリティカル以外のダメージ無効" }, C.Say{ color = C.Color.green, key = "START_MESSAGE6", text = "暴食：与えたダメージを吸収、HP80％以下のユニットへのダメージアップ" } } } })

-- 出典: スキル：スキル1 -> スキル2 -> （スキル1 or スキル2） -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 1, 2 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "skill1", [4] = "skill2", [5] = "skill3" } })

-- 出典: 奥義：奥義3 -> 奥義4 -> 繰り返し（真奥義カットイン）
boss:add(C.Smash{ sets = { { 3 }, { 4 } }, cutin = { [3] = C.Cutin.TrueArts, [4] = C.Cutin.TrueArts }, anim = { [1] = "attack1", [2] = "attack2", [3] = "skill1", [4] = "skill2", [5] = "skill3" } })

-- 出典: 魔族ユニット以外からのダメージを、TakeDamageValue補正×0.4にする
boss:add(C.Defense{
  { mult = 0.4, attackerRace = 8, negate = true },
})

-- 出典: HP50%：状態異常回復＆真奥義カットインで奥義5＆物理耐性50%アップ＆クリティカル耐性50%アップ（発動から撃ち終わるまで無敵・スキップ不可・ゲージ引き継ぎ）
boss:add(C.Phases{
  { at = 50, stop = true, deferWhileSkill = true, actions = { C.CureStatus{}, function(self, e) self._hpTrigPending = true; self._hpTrigActive = true end, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208579022, type = 21, value = -50, script = { id = 2 }, time = 999999, icon = 21, group = -1 }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208579023, type = 23, value = -50, time = 999999, icon = 188, group = -1 }, C.Say{ color = C.Color.yellow, key = "HP50_MESSAGE1", text = "物理・クリティカル耐性アップ" }, C.UseSkill{ index = 5, cutin = C.Cutin.TrueArts, invincible = 30, keepGauge = true } } },
})

-- 出典: HP50% の奥義5を撃ち終わったら無敵を閉じる
boss:add(C.SkillFinishWatch{ arm = "_hpTrigPending", active = "_hpTrigActive", onFinish = { C.Invincible{ seconds = 0 } } })

-- 出典: 怒り：リヴィエラが戦闘不能になったとき（ブレイク中でも発動。無敵・TakeDamageValue補正は付けない）
boss:add(C.Mode{ initial = "normal", states = { normal = {  }, anger = { onEnter = { C.CureStatus{}, C.UseSkill{ index = 5, cutin = C.Cutin.TrueArts }, C.AttachBuff{ target = C.Targeting{ pick = "self" }, id = 208579021, type = 17, value = 100, time = 999999, icon = 26, group = -1, aura = true }, C.SetAttackDelay{ 5 }, C.SetSpineSPGain{ 30 }, C.Say{ color = C.Color.red, key = "ANGER_MESSAGE1", text = "緑命竜が怒り状態：与ダメージ・行動速度・奥義ゲージ上昇量アップ" } } } } })

-- 出典: リヴィエラが生存している間は緑命。戦闘不能になったら緑命停止＋怒り
boss:add(C.Minions{ enemies = { 2085795 }, onAlive = { C.SetRegen{ 100000 } }, onEmpty = { C.SetRegen{ 0 }, function(self, e) local u = self.unit; if u ~= nil and u ~= false and u:getHP() > 0 then C.SetMode{ 'anger' }(self, e) end end } })

-- 出典: エルプネウマスが死亡したとき、リヴィエラが残っていてもクリアとなる
boss:add(C.Dead{ clearWave = true })

-- [データ] 反射耐性100%・奥義ゲージ低下耐性100%・HP吸収耐性100%（skill_relation_master relation_type=4: 60006700/60006800/60006600）、光属性・魔族ユニットからの被ダメージ50%アップ（60028600/60026900）、燃焼・病気・毒耐性0%、麻痺・氷結・気絶耐性300%、その他の状態異常耐性200%、break_capacity 400000、damage_drop_sp 18 は本番マスタ側（enemy_master.csv id=2085790）。被ダメUPは Lua 側に入れると二重適用になるため入れない（マスタ設定・Choreo外）

boss:publish()
