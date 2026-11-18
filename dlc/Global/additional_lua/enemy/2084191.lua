-- 自動生成: セティスギミック草案.md 幻想士ミズキ【デイリーEX】 → codegen。出典コメントを消さない。穴(TODO)は補足YAMLで埋める。
local C = require('summoner.Choreo')
local boss = C.createEnemyClass{ label = "幻想士シュリ", version = 1.2, id = 2084191 }

boss:add(C.NoHitStop{})

boss:add(C.SPGain{ value = 0 })

boss:add(C.AttackSPGain{ value = 10 })

boss:add(C.Start{ C.SetAttackDelay{ 5 }, C.Say{ color = C.Color.magenta, key = "INFO_START1", text = "会敵" }, C.Say{ color = C.Color.magenta, key = "INFO_START2", text = "シュリ：ダメージを大幅軽減" } })

boss:add(C.Attack{ sets = { { 1 }, { 2 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2" } })

boss:add(C.Smash{ sets = { { 3 } }, anim = { [1] = "attack1", [2] = "skill1", [3] = "skill2" } })

-- 出典: 常時 TakeDamageValue=1（被ダメージ固定）
boss:add(C.Defense{
  { set = 1 },
})

-- 出典: シュリ戦闘不能時セリフ：magenta
boss:add(C.Dead{ actions = { C.Say{ color = C.Color.magenta, key = "INFO_DEAD1", text = "認めんぞ…" } } })

-- [データ] 奥義ゲージ低下耐性100% は本番マスタ側（enemy_master.csv id=2084191）（マスタ設定・Choreo外）

boss:publish()
