------
-- summoner.Choreo.Components.SurviveClear
--
-- 耐久クリア: 制限時間まで生存 → クエストクリア（時間切れ = 勝ち。TimeLimit の逆）。
-- 出典: enemy/100151201.lua（修行の間_サンドバッグ_自由訓練）の時限処理
--   （clearTime 到達で setBattleState(kBattleState_none) + waveEnd(true)。表示は showCountDownTime）。
-- 内部は TimeLimit の計時・カウントダウンUIをそのまま使い、時間切れ時の動作をクリア儀式に固定する。
--
-- ⚠ update を使うため boss version >= 1.1（TimeLimit と同じ）。クリア（waveEnd）はホストのみ実行。
--
-- 設定（seconds 以外は TimeLimit と同じ表示パラメータ）:
--   seconds  number  耐久秒数
--   redtime  number  赤表示になる残り秒（既定 seconds の 1/10）
--   png      string  タイマー画像パス（例 "unit/animation/timeLimit.png"）
--   x/y      number  表示位置（既定 0/0）
--   scale    number  表示倍率（既定 1）
--   onClear  Action|list  クリア直前の追加アクション（任意。全端末で実行）
--
-- @example
--     boss:add(SurviveClear{ seconds = 60, redtime = 10, png = "unit/animation/timeLimit.png", y = 200 })
------
local _NAME = 'summoner.Choreo.Components.SurviveClear'
local _G = _G

local TimeLimit = require('summoner.Choreo.Components.TimeLimit')
local Action = require('summoner.Choreo.Action')

-- クリア儀式（サンドバッグ 100151201 準拠）: バトルを止めて Wave 勝利終了
local function clearQuest(self, event)
    if not self.isHostPlayer then
        return
    end
    megast.Battle:getInstance():setBattleState(kBattleState_none)
    megast.Battle:getInstance():waveEnd(true)
end

local function SurviveClear(config)
    config = config or {}
    local component = { name = 'SurviveClear' }

    function component.initialize(dispatcher)
        dispatcher:add(TimeLimit{
            seconds = config.seconds,
            redtime = config.redtime,
            png = config.png,
            x = config.x,
            y = config.y,
            scale = config.scale,
            onExpire = {
                function(self, event) Action.runActions(self, event, config.onClear) end,
                clearQuest,
            },
        })
    end

    return component
end

_G.package.loaded[_NAME] = SurviveClear
return SurviveClear
