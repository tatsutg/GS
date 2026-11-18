------
-- summoner.Choreo.Components.Attack
--
-- 通常攻撃の行動抽選 Component。Selector 基底 + takeAttack。
-- マルチ同期（ホスト抽選→全端末再生）は内部の Sync が自動処理する。
--
-- @example
--     boss:add(Attack{ weights = { [1]=50, [2]=50 }, activeSkills = { [1]=1, [2]=2 } })
--     boss:add(Attack{ sets = { {1,1}, {2}, {3,4} } })  -- ローテーション（各ステップから一様抽選）
--
-- 設定:
--     weights      table  index => 重み（重み抽選。毎回ランダム）
--     sets         table  array of (index の配列)。ステップを巡回し、各ステップ内を一様抽選
--                         （weights と sets は排他。両方あれば sets 優先）
--     activeSkills table  (任意) 攻撃 index => スキル番号。省略時は index をそのまま使う
------
local _NAME = 'summoner.Choreo.Components.Attack'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Selector = require('summoner.Choreo.Components.Selector')

local function Attack(config)
    return Selector.makeComponent({
        name = 'Attack',
        event = Events.OnAttack,
        channel = 'attack',
        animBase = 'attack',   -- C++ 既定アニメ名（takeAttack → "attack<N>"）
        trigger = function(unit, index) unit:takeAttack(index) end,
        config = config,
    })
end

_G.package.loaded[_NAME] = Attack
return Attack
