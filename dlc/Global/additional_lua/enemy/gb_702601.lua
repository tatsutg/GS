--@additionalEnemy,702103
-- 自動生成: quest_md/9900052_EP7プルートゥ.md → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "グランドバトルEP7_エリアボス_闇玉精プルートゥ", version = 2.5, id = "gb_702601" }

-- 出典: 戦闘開始時: addSP=30（Lua）。spine の runScript-addSP は attack1-4 にある
boss:add(C.SpineSPGain{ value = 30 })

-- 出典: 戦闘開始時: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 戦闘開始時: attack_delay=8.0（Lua）＋ INFO（黄）
boss:add(C.Start{ C.SetAttackDelay{ 8 }, C.Say{ key = "START_MESSAGE1", text = "反射・HP吸収・奥義ゲージ低下耐性" }, C.Say{ key = "START_MESSAGE2", text = "全体付与のCRI率アップ・防御無視効果無効" }, C.Say{ key = "START_MESSAGE3", text = "CRI耐性ダウン無効" }, C.Say{ key = "START_MESSAGE4", text = "一定時間マールム召喚：燃焼時遅延" } })

-- 出典: EP 共通ギミック: 180秒の時間制限。タイムアップで敗北（表示は gb_605601 と同じ）
boss:add(C.TimeLimit{ seconds = 180, redtime = 30, png = "unit/animation/timeLimit.png", x = 620, y = -100, scale = 0.8 })

-- 出典: 行動パターン: スキル1 → 2 → 3 → 4 → 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 2 }, { 3 }, { 4 } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "skill1", [6] = "skill2", [7] = "skill2" } })

-- 出典: 行動パターン: 奥義5 → 6 → 繰り返し ／ 奥義5・6のたびに与ダメージ10%UP（グラバト共通 6000100）
boss:add(C.Smash{ sets = { { 5 }, { 6 } }, onUse = { [5] = { C.Say{ key = "SKILL5_MESSAGE1", text = "マールムの数に応じて固定ダメージアップ", color = C.Color.white }, function(self, e) local n = 0; local team = self.unit:getTeam(); for i = 0, 7 do local u = team:getTeamUnit(i); if u ~= nil and u:getEnemyID() == 702103 then n = n + 1 end end; self._plutoMarum = n; local dmg = 2000 + n * megast.Battle:getInstance():getCurrentGrandBattleFloor() * 10; local text = string.format(self.TEXT and self.TEXT.SKILL5_MESSAGE2 or 'ダークネスガンマ：%d の固定ダメージ', dmg); C.Message{ text = text, color = C.Color.red }:show() end, C.FixedDamage{ side = "player", amount = function(self, e) return 2000 + (self._plutoMarum or 0) * megast.Battle:getInstance():getCurrentGrandBattleFloor() * 10 end }, function(self, e) local down = (self._plutoMarum or 0) * 10; if down <= 0 then return end; local team = megast.Battle:getInstance():getTeam(true); for i = 0, 7 do local u = team:getTeamUnit(i); if u ~= nil then local bp = u:getBurstPoint() - down; if bp < 0 then bp = 0 end; u:setBurstPoint(bp) end end end, C.StackBuff{ id = 6000100, type = 17, value = 10, max = 99, icon = 26 } }, [6] = { C.StackBuff{ id = 6000100, type = 17, value = 10, max = 99, icon = 26 } } }, anim = { [1] = "attack1", [2] = "attack2", [3] = "attack3", [4] = "attack4", [5] = "skill1", [6] = "skill2", [7] = "skill2" } })

-- 出典: ギミック②: 召喚タイマー（アイコン181・10秒一周）／燃焼で1/2・マールム6体・ブレイク中・無敵中は停止
boss:add(C.ExtraTimer{ key = "summon", maxTime = 10, loopLimit = 999, icon = { 181, 0 }, onRound = { C.SpawnEnemy{ enemy = 702103, counts = { [1] = 60, [2] = 40 }, max = 6 }, C.Say{ key = "SUMMON_MESSAGE1", text = "マールム：物理耐性" } }, speedRules = { { when = { invincible = true }, speed = 0 }, { when = { breaking = true }, speed = 0 }, { when = { enemies = { id = 702103, min = 6 } }, speed = 0 }, { when = { status = { 97 } }, speed = 0.5 } } })

-- 出典: HPトリガーは発動から打ち終わるまでブレイク不可（無敵中ロック）
boss:add(C.Break{ lockWhileInvincible = true })

-- 出典: HP20%: 真奥義カットインで奥義7＋防御力[700+階層×30]%UP／スキップ不可・直前の奥義ゲージを引き継ぐ
boss:add(C.Phases{
  { at = 20, stop = true, deferWhileSkill = true, actions = { C.Invincible{ seconds = 30 }, C.AttachBuff{ id = 70260102, type = 15, value = { base = 700, perFloor = 30 }, time = 99999, icon = 5 }, C.Say{ key = "HP20_MESSAGE1", text = "防御力アップ" }, C.UseSkill{ index = 7, cutin = C.Cutin.TrueArts, keepGauge = true } } },
})

-- 出典: ボス撃破でクリア（マールムが残っていても倒す＝clearWave）
boss:add(C.Dead{ clearWave = true })

-- 出典: HPフラグ奥義（奥義7）を打ち終わったら無敵解除
boss:add(C.SkillFinishWatch{ onSkill = { 7 }, onFinish = { C.Invincible{ seconds = 0 } } })

boss:publish()
