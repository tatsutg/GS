------
-- summoner.Choreo.Components.OnStatus
--
-- 自分が指定の状態異常になったら（立ち上がりエッジで）アクションを実行する。
-- 例: 飛行中に気絶/麻痺/氷結 → 通常状態へ復帰＋耐性UP。
-- 出典: 状態異常検知（update で findConditionWithType）＋ホスト権限で gameplay 駆動。
--
-- ⚠ update を使うため boss version >= 1.1。ホスト権限で判定・実行（条件はエンジンが同期）。
--
-- @example
--     boss:add(OnStatus{ types = { 89, 90, 91 },   -- 気絶/麻痺/氷結 の condition type
--                        actions = { SetMode{ "normal" }, Say{ text = "解除成功" } } })
--
-- 設定:
--   types    table   検知する condition type（いずれか present で発火）
--   actions  Action|list  立ち上がり時に実行
--   key      string  複数 OnStatus を併用するとき状態キーを分ける（任意）
------
local _NAME = 'summoner.Choreo.Components.OnStatus'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local function OnStatus(config)
    config = config or {}
    local types = config.types or {}
    local actions = config.actions
    local stateKey = '_onStatus' .. (config.key or '')
    local component = { name = 'OnStatus' }

    local function onUpdate(self, event)
        if not self.isHostPlayer then return end
        local cond = event.unit:getTeamUnitCondition()
        local present = false
        for i = 1, #types do
            if cond:findConditionWithType(types[i]) ~= nil then
                present = true
                break
            end
        end
        if present then
            if not self[stateKey] then            -- 立ち上がりエッジ
                self[stateKey] = true
                if actions ~= nil then
                    Action.runActions(self, event, actions)
                end
            end
        else
            self[stateKey] = false                -- 解除されたら再武装
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnUpdate, onUpdate)
    end

    return component
end

_G.package.loaded[_NAME] = OnStatus
return OnStatus
