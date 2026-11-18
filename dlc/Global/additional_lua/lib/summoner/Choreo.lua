------
-- summoner.Choreo
--
-- ボス/ユニット実装を「Component + Action」の宣言で記述するフレームワーク層。
-- summoner.Bootstrap の上に乗り、生のイベントハンドラ方式を
-- addEventListener / Component 合成へ作り替える。
--
-- 旧称: summoner.Workless（~/Dev/codes/summoner/Workless）
-- 設計: _WORK/lua/docs/08-choreo-design.md / 拡張ガイド: _WORK/lua/docs/13-extending-choreo.md
--
-- @example
--     local boss = summoner.Choreo.createEnemyClass{ label="ボス名", version=2.6, id=599990000 }
--     -- boss:add(Component{...}) で組み立てる
--     boss:publish()
------
local _NAME = 'summoner.Choreo'
local _M = {}
local _G = _G

local Bootstrap = require('summoner.Bootstrap')

_M.Color = require('summoner.Color')
_M.Buff = require('summoner.Choreo.Buff')
_M.BuffType = _M.Buff.Types
_M.Message = require('summoner.Choreo.Message')
_M.Events = require('summoner.Choreo.Events')
_M.UnitEventDispatcher = require('summoner.Choreo.UnitEventDispatcher')

-- Action 層
_M.Action = require('summoner.Choreo.Action')
_M.Targeting = require('summoner.Choreo.Targeting')
_M.Actions = require('summoner.Choreo.Actions')

-- 各 Action 動詞を Choreo 直下にも展開（boss側で summoner.Choreo.SpawnOrbit 等で参照可能）
for name, action in pairs(_M.Actions) do
    _M[name] = action
end

-- Component 層
_M.Start = require('summoner.Choreo.Components.Start')        -- 戦闘開始時 Action 実行
_M.Sync = require('summoner.Choreo.Components.Sync')          -- 内部用（同期プリミティブ）
_M.Attack = require('summoner.Choreo.Components.Attack')      -- 通常攻撃の抽選
_M.Smash = require('summoner.Choreo.Components.Smash')        -- 奥義の抽選（カットイン対応）
_M.UseSkill = _M.Smash.UseSkill                              -- 任意奥義の強制発動 Action
_M.Cutin = { Arts = 0, TrueArts = 1, SuperArts = 4 }        -- カットイン種別(BurstType): Arts(奥義)/TrueArts(真奥義)/SuperArts(超覚醒奥義=kBurstType_3)
_M.Phases = require('summoner.Choreo.Components.Phases')      -- HPフェーズ（HPトリガー）
_M.Defense = require('summoner.Choreo.Components.Defense')    -- 被ダメージ補正(takeDamageValue)
_M.DamageRate = require('summoner.Choreo.Components.DamageRate')  -- 行動ごとの与ダメ/ブレイクの取り分(オービットへの委譲)
_M.Break = require('summoner.Choreo.Components.Break')        -- ブレイク回数による段階補正テーブル
_M.HateTarget = require('summoner.Choreo.Components.HateTarget')  -- 累計ダメ最大ターゲティング(ヘイト)
_M.SubGauge = require('summoner.Choreo.Components.SubGauge')  -- サブゲージ/エクストラゲージ
_M.ShowSubGauge = _M.SubGauge.Show
_M.HideSubGauge = _M.SubGauge.Hide
_M.ResetSubGauge = _M.SubGauge.Reset
_M.Regen = require('summoner.Choreo.Components.Regen')        -- 毎秒HP回復
_M.SetRegen = _M.Regen.Set
_M.SPGain = require('summoner.Choreo.Components.SPGain')      -- SP上昇率(addSP)の宣言
_M.SetSPGain = _M.SPGain.Set
_M.TimeLimit = require('summoner.Choreo.Components.TimeLimit') -- 制限時間→全滅
_M.ResetTimeLimit = _M.TimeLimit.Reset
_M.NoHitStop = require('summoner.Choreo.Components.NoHitStop')  -- ヒットストップ/時止め無効
-- Scale は Action 化（Choreo.Actions.Scale）。Component 公開は廃止 ―― Start/Phases 等の actions で使う。
_M.AttackSPGain = require('summoner.Choreo.Components.AttackSPGain')  -- 通常攻撃ごとSP加算
_M.Reraise = require('summoner.Choreo.Components.Reraise')    -- 復活/HP0トリガー(avoidDead)
_M.Dead = require('summoner.Choreo.Components.Dead')          -- 死亡時アクション(clearWave=ボス撃破でクリア)
_M.Mode = require('summoner.Choreo.Components.Mode')          -- 名前付きサブステート(状態マシン)
_M.SetMode = _M.Mode.Set
_M.OnStatus = require('summoner.Choreo.Components.OnStatus')  -- 状態異常になったら発火(エッジ)
_M.OnTakeCritical = require('summoner.Choreo.Components.OnTakeCritical')  -- 被クリティカルで発火(takeDamageValue)
_M.Timeline = require('summoner.Choreo.Components.Timeline')  -- spine イベント連動
_M.AnimVariant = require('summoner.Choreo.Components.AnimVariant')  -- アニメ名バリアント(形態/天候別サフィックス)＋setup切替
_M.SetAnimVariant = _M.AnimVariant.Set
_M.SetSetupAnim = _M.AnimVariant.SetSetup                     -- セットアップアニメ(静止ポーズ)を直接指定
_M.StageEffect = require('summoner.Choreo.Components.StageEffect')  -- 常設カメラオービット(全画面演出)の1枠管理
_M.ShowStageEffect = _M.StageEffect.Show
_M.HideStageEffect = _M.StageEffect.Hide
_M.SetStageLevel = _M.StageEffect.SetLevel
_M.LockPosition = require('summoner.Choreo.Components.LockPosition')  -- 立ち位置を開幕位置に固定
_M.Wave = require('summoner.Choreo.Components.Wave')          -- Wave 進行
_M.Tests = require('summoner.Choreo.Components.Tests')        -- テスト/デバッグ出力
_M.ExtraTimer = require('summoner.Choreo.Components.ExtraTimer')  -- engine タイマー（マネージャ + Action）
_M.SkillFinishWatch = require('summoner.Choreo.Components.SkillFinishWatch')  -- スキル撃ち終わり(getUnitState)監視→onFinish
_M.SpineSPGain = require('summoner.Choreo.Components.SpineSPGain')  -- 大型ボス定型: spine addSP イベント同期のゲージ加算
_M.SurviveClear = require('summoner.Choreo.Components.SurviveClear') -- 耐久クリア: 制限時間まで生存→クエストクリア
_M.SuperRegen = require('summoner.Choreo.Components.SuperRegen')   -- 超回復: HPを常に基準値へ戻す（死なない）
_M.ReviveFull = require('summoner.Choreo.Components.ReviveFull')   -- 不死＋全快: HP0で死なず最大HPへ戻す（バーは削れる）
_M.OrdeusSkull = require('summoner.Choreo.Components.OrdeusSkull')  -- オルデウス種: 壊魂振動（ホーミング弾）
_M.OrdeusDeathScene = require('summoner.Choreo.Components.OrdeusDeathScene')  -- オルデウス種: 滅魂宿世（全停止→掴み→Hit効果）
_M.KindOrdeus = require('summoner.Choreo.Components.KindOrdeus')    -- オルデウス種プリセット（種の共有ギミック束ね）
_M.DragonFire = require('summoner.Choreo.Components.DragonFire')            -- 竜種: 火球
_M.DragonFirePillar = require('summoner.Choreo.Components.DragonFirePillar')  -- 竜種: 火柱
_M.KindDragon = require('summoner.Choreo.Components.KindDragon')            -- 竜種プリセット（火球・火柱）
_M.MavrosGravity = require('summoner.Choreo.Components.MavrosGravity')      -- マヴロスギア種: 時空追放（重力吸引）
_M.KindMavros = require('summoner.Choreo.Components.KindMavros')            -- マヴロスギア種プリセット（時空追放）
-- ExtraTimer の Action を直下にも展開
_M.CreateExtraTimer = _M.ExtraTimer.Create
_M.RemoveExtraTimer = _M.ExtraTimer.Remove
_M.SetExtraTimerSpeed = _M.ExtraTimer.SetSpeed

-- Bootstrap の createUnitClass 等をそのまま引き継ぐ
setmetatable(_M, {__index=Bootstrap})

------
-- Unit クラスを生成し、Choreo の UnitEventDispatcher へ昇格させる
------
function _M.createUnitClass(...)
    local dispatcher = Bootstrap.createUnitClass(...)
    _M.UnitEventDispatcher.initialize(dispatcher)
    return dispatcher
end

------
-- Enemy クラスを生成し、Choreo の UnitEventDispatcher へ昇格させる
------
function _M.createEnemyClass(...)
    local dispatcher = Bootstrap.createEnemyClass(...)
    _M.UnitEventDispatcher.initialize(dispatcher)
    return dispatcher
end

_G.package.loaded[_NAME] = _M
return _M
