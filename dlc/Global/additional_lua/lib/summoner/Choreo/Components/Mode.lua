------
-- summoner.Choreo.Components.Mode
--
-- 名前付きサブステート（状態マシン）。状態ごとに onEnter/onExit のアクションを実行し、
-- Attack/Smash は `byMode` で状態別の行動ローテを選べる。
-- 状態異常とは別の「ボスの状態」（飛行/怒り/モード切替 等）を表す。
-- 出典: 炎怪鳥(飛行)・紅蓮(怒り)・妖狐(炎/闇モード) 等の行動パターン分岐。
--
-- 遷移は SetMode アクションで行う（onUse での確率遷移や、状態異常検知での復帰は boss 側で配線）。
--
-- @example
--     boss:add(Mode{
--         initial = "normal",
--         states = {
--             normal = { onEnter = { SetAttackDelay{ 12 } } },
--             flying = { onEnter = { SetAttackDelay{ 7 }, AttachBuff{ target=Targeting{pick="self"}, ... } },
--                        onExit  = { RemoveBuff{ ... } } },
--         },
--     })
--     boss:add(Attack{ byMode = {                       -- 状態別の行動ローテ
--         normal = { sets = { {1}, {2} } },
--         flying = { sets = { {1,2}, {2,3}, {1,3} } },
--     } })
--     -- 遷移（例: 攻撃後に飛行へ。確率は boss 側で）:
--     boss:add(Attack{ onUse = { 3 = { SetMode{ "flying" } } } })
--
-- 設定:
--   initial  string  初期状態名（onLoad で onEnter 実行）
--   states   table   name => { onEnter = Action|list, onExit = Action|list }
------
local _NAME = 'summoner.Choreo.Components.Mode'
local _G = _G

local Events = require('summoner.Choreo.Events')
local Action = require('summoner.Choreo.Action')

local makeMode

local Mode = setmetatable({}, {
    __call = function(_, config) return makeMode(config) end
})

function makeMode(config)
    config = config or {}
    local initial = config.initial
    local states = config.states or {}
    local component = { name = 'Mode' }

    local function onLoad(self, event)
        self._mode = initial
        self._modeStates = states
        local s = states[initial]
        if s ~= nil and s.onEnter ~= nil then
            Action.runActions(self, event, s.onEnter)
        end
    end

    function component.initialize(dispatcher)
        dispatcher:addEventListener(Events.OnLoad, onLoad)
    end

    return component
end

-- 状態遷移（旧状態 onExit → 新状態 onEnter）
Mode.Set = Action.define('SetMode', function(a, d, e)
    local name = a.name or a[1]
    if d._mode == name then return end
    local states = d._modeStates or {}
    local old = states[d._mode]
    if old ~= nil and old.onExit ~= nil then
        Action.runActions(d, e, old.onExit)
    end
    d._mode = name
    local new = states[name]
    if new ~= nil and new.onEnter ~= nil then
        Action.runActions(d, e, new.onEnter)
    end
end)

_G.package.loaded[_NAME] = Mode
return Mode
