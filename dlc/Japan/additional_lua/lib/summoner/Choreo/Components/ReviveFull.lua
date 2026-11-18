------
-- summoner.Choreo.Components.ReviveFull
--
-- 不死＋全快: HP が 0 になっても死なず、その瞬間に HP を最大値まで戻す。
-- プレイヤーから見ると「削り切ると HP バーが満タンに戻る」＝ DPS チェック型の耐久ボスになる。
-- 出典: enemy/2008026.lua（ボロス）・enemy/2025836.lua（闇リーゼ）の `dead` で
--   `event.unit:setHP(N)` してから `return 0`（＝エンジンの死亡処理をスキップ）する慣用句。
--
-- SuperRegen との違い: SuperRegen は update 毎に HP を戻すため**バーが減らない**。
--   こちらは通常どおり削れて、0 になった瞬間だけ全快する。
--
-- ⚠ dead イベントは version 1.0（無条件で発火）。avoidDead(2.6) は使わない。
-- ⚠ 回数無制限。打ち切りは SurviveClear / TimeLimit など時間側の Component で行う。
-- ⚠ ratio を小さくしすぎて回復後 HP が 0 になると次フレームで再び dead ＝無限ループになるため、
--    最低 1 は残す。
--
-- マルチプレイ: 死亡スキップは全端末で行う（ホストが死なない＝DEADENEMY が飛ばないので
--   ゲストも死なないが、ゲスト側のローカル死亡も明示的に止める）。
--   HP 書き換えはホスト権威（STATUSSYNC_BOSS でゲストへ配信される）。
--
-- 設定:
--   ratio    number       回復割合（既定 1.0 ＝ 最大HPの100%）
--   actions  Action|list  全快時に実行（任意。Say 等）
--
-- @example
--     boss:add(ReviveFull{})                                   -- HP0 で常に全快
--     boss:add(ReviveFull{ ratio = 0.5 })                      -- HP0 で最大HPの50%まで回復
--     boss:add(ReviveFull{ actions = { Say{ "REVIVE_MESSAGE1" } } })
------
local _NAME = 'summoner.Choreo.Components.ReviveFull'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local function ReviveFull(config)
    config = config or {}
    local ratio = config.ratio or config[1] or 1.0
    local actions = config.actions

    local component = { name = 'ReviveFull' }

    local function onDead(self, event)
        event:prevent()                  -- 戻り値0＝エンジンは死亡処理をスキップ（Team.cpp: if(!runScript)continue）
        if not self.isHostPlayer then
            return                       -- HP はホスト権威。ゲストは配信を受けるだけ
        end
        local unit = self.unit or event.unit
        if unit == nil then
            return
        end
        local maxHP = unit:getCalcHPMAX()
        if maxHP == nil or maxHP <= 0 then
            return
        end
        local hp = math.floor(maxHP * ratio)
        if hp < 1 then
            hp = 1                       -- 0 にすると次フレームで再び dead ＝無限ループ
        end
        unit:setHP(hp)
        if actions ~= nil then
            Action.runActions(self, event, actions)
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnDrop, onDead)   -- OnDrop == 'dead'
    end

    return component
end

_G.package.loaded[_NAME] = ReviveFull
return ReviveFull
