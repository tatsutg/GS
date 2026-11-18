------
-- summoner.Choreo.Events
--
-- イベント名の定数群。
-- HOOK_FUNCTIONS の生イベント名（takeAttack 等）に加え、
-- 読みやすい意味的エイリアス（OnAttack 等）を提供する。
-- addEventListener / Component から参照する。
------
local _NAME = "summoner.Choreo.Events"
local _M = {}
local _G = _G

local Bootstrap = require("summoner.Bootstrap")

-- 生イベント名をそのまま定数として公開（_M.takeAttack == "takeAttack" 等）
for name, fn in pairs(Bootstrap.UnitEventDispatcher.HOOK_FUNCTIONS) do
    _M[name] = name
end

-- 意味的エイリアス
_M.OnLoad = 'start'
_M.OnCombat = 'startWave'
_M.OnWave = 'startWave'
_M.OnWaveEnd = 'endWave'
_M.OnAttack = 'takeAttack'
_M.OnSmash = 'takeSkill'
_M.OnCast = 'castItem'
_M.OnUpdate = 'update'
_M.OnDrop = 'dead'
_M.OnEnterTimeline = 'run'
_M.OnTimeline = 'run'

-- コミット系: prevent されずに完走した発火のみ（UnitEventDispatcher.COMMIT_SUFFIX と同期）。
-- Attack/Smash(Selector) の二段発火では pass1(抽選) を除外し、行動が成立する発火だけ受ける。
_M.OnAttackCommit = 'takeAttack@commit'
_M.OnSmashCommit = 'takeSkill@commit'

-- OnReceive1, OnReceive2, ...（マルチプレイ受信ポート）
_M.ON_RECEIVE_SUFFIX = 'receive'
_M.MAX_PORT_NUMBER = 10
_M.OnReceive = function(portNumber) return _M.ON_RECEIVE_SUFFIX .. tostring(portNumber) end
for portNumber = 1, _M.MAX_PORT_NUMBER do
    _M['OnReceive' .. tostring(portNumber)] = _M.OnReceive(portNumber)
end

_G.package.loaded[_NAME] = _M
return _M
