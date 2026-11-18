-- 自動生成: シャルヴァレサマーギミック草案.md デイリー節 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "ムーマ王", version = 2.5, id = 2082790 }

-- 出典: ヒットストップ・時止め無効（Lua）
boss:add(C.NoHitStop{})

-- 出典: 旧テンプレ規約: addSP 運用時は自然上昇0
boss:add(C.SPGain{ value = 0 })

-- 出典: addSP=20（Lua）
boss:add(C.AttackSPGain{ value = 20 })

-- 出典: attack_delay=7（Lua）／ 開幕INFO ／ 開幕プレイヤー強化
boss:add(C.Start{ C.SetAttackDelay{ 7 }, C.Say{ key = "START_MESSAGE1", text = "我が野望の前に立ち塞がるか。", color = C.Color.red }, C.Say{ key = "START_MESSAGE2", text = "氷結耐性ダウン・氷結付与で戦闘不能", color = C.Color.yellow }, C.Say{ key = "START_MESSAGE3", text = "一定時間経過で戦闘不能", color = C.Color.yellow }, C.Say{ key = "START_MESSAGE4", text = "奥義ゲージ・CT速度超アップ", color = C.Color.white, side = "player" }, function(self, e) local team = megast.Battle:getInstance():getTeam(true); for i=0,7 do local u = team:getTeamUnit(i); if u ~= nil then local c = u:getTeamUnitCondition(); c:addCondition(20827901, 10, 300, 999999, 0); c:addCondition(20827902, 29, 500, 999999, 0); c:addCondition(20827903, 30, 500, 999999, 0) end end end })

-- 出典: ドゥーム自滅: 奥義5撃ち終わり(takeAttack/takeIdle・takeSkill gate)で deadUnit＋waveEnd
boss:add(C.SkillFinishWatch{ arm = "_doomPending", onFinish = function(self, e) local u = self.unit or e.unit; if u == nil or u == false then return end; if megast.Battle:getInstance():isHost() then u:getTeam():deadUnit(u:getIndex()); megast.Battle:getInstance():waveEnd(true) end end })

-- 出典: ムーマ王は常にTakeDamageValue補正×0.1（無条件）
boss:add(C.Defense{
  { mult = 0.1 },
})

-- 出典: スキル：スキル1 -> スキル3 -> スキル2 -> 繰り返し
boss:add(C.Attack{ sets = { { 1 }, { 3 }, { 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: 奥義：奥義4 -> 繰り返し。sets値=スロット番号(need_level)。奥義5(doom)発動INFOは実発動に同期させるためonUseに置く
boss:add(C.Smash{ sets = { { 4 } }, onUse = { [5] = { C.Say{ key = "SKILL5_MESSAGE1", text = "フン、そろそろ終わりにするか。", color = C.Color.red } } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2", [4] = "skill3", [5] = "skill5" } })

-- 出典: ムーマ王に氷結付与で戦闘不能→クエストクリア（虚月が残っていてもクリア）
boss:add(C.OnStatus{ types = { 96 }, actions = { function(self, e) local u = self.unit or e.unit; if megast.Battle:getInstance():isHost() then u:getTeam():deadUnit(u:getIndex()); megast.Battle:getInstance():waveEnd(true) end end } })

-- 出典: 戦闘開始時からアイコン348・20秒で1周。1周で超奥義カットインで奥義5発動→戦闘不能→クリア
boss:add(C.ExtraTimer{ key = "doom", maxTime = 20, loopLimit = 1, icon = { 348, 0 }, onRound = { function(self, e) self._doomPending = true end, C.UseSkill{ index = 5, cutin = C.Cutin.SuperArts } } })

-- [データ] 反射/奥義ゲージ低下/HP吸収耐性100%、氷結耐性0%(＋氷結耐性-30%アイコン表示)、毒/燃焼/暗闇/病気30%、その他300% は本番マスタ側。break_capacity 50,000,000・damage_drop_sp 8 も本番マスタ（マスタ設定・Choreo外）

boss:publish()
