------
-- summoner.Choreo.Action
--
-- Action（宣言的な動詞）の基底。
-- トリガー Component（Timeline/Phases/Wave 等）が発火したときに実行される値オブジェクト。
--
-- 設計原則（codegen-aware）:
--   - 引数は純粋なデータ（テーブル）。
--   - 生成時は無副作用。発火時に self.unit（または対象）へ作用する。
--   - エスケープハッチ: Action の代わりに function(dispatcher, event) も受け付ける。
--
-- 使い方（カタログは Actions.lua）:
--   local Hit = Action.define('Hit', function(action, dispatcher, event) ... end)
--   Action.runActions(dispatcher, event, { Hit{...}, function(d,e) ... end })
------
local _NAME = 'summoner.Choreo.Action'
local _M = {}
local _G = _G

------
-- x が Action インスタンスか
------
function _M.isAction(x)
    return type(x) == 'table' and x.__choreoAction == true
end

------
-- Action 型を定義し、コンストラクタを返す
--
-- @param string name
-- @param function applyFn  function(action, dispatcher, event)
-- @return function constructor  function(params) -> action instance（callable）
------
function _M.define(name, applyFn)
    local meta = {}
    meta.__index = meta
    meta.__choreoAction = true
    meta.actionName = name
    meta.apply = applyFn

    function meta:run(dispatcher, event)
        return self:apply(dispatcher, event)
    end

    -- インスタンスを callable にする: action(dispatcher, event)
    meta.__call = function(self, dispatcher, event)
        return self:apply(dispatcher, event)
    end

    local constructor = setmetatable({ meta = meta, actionName = name }, {
        __call = function(_, params)
            return setmetatable(params or {}, meta)
        end
    })
    return constructor
end

------
-- 対象ユニットを解決する
-- 既定は event.unit（無ければ dispatcher.unit）。action.target に Targeting や TeamUnit を渡せる。
------
function _M.resolveTarget(action, dispatcher, event)
    local t = action.target
    if t == nil then
        if event ~= nil and event.unit ~= nil then
            return event.unit
        end
        return dispatcher.unit
    end
    if type(t) == 'table' and t.__choreoTargeting == true then
        return t:resolve(dispatcher, event)
    end
    return t  -- TeamUnit を直接渡したとみなす
end

------
-- Action（またはそのリスト、または素の関数＝エスケープハッチ）を順次実行する
--
-- @param dispatcher
-- @param event
-- @param list  Action | function | array of (Action|function)
------
function _M.runActions(dispatcher, event, list)
    if list == nil then
        return
    end
    -- 単体の Action / 関数を渡された場合はリスト化
    if type(list) == 'function' or _M.isAction(list) then
        list = { list }
    end
    for i = 1, #list do
        local item = list[i]
        local t = type(item)
        if t == 'function' then
            item(dispatcher, event)          -- エスケープハッチ
        elseif _M.isAction(item) then
            item:run(dispatcher, event)
        end
    end
end

------
-- actions ツリー内の Chance を dispatcher に「宣言順」で静的 pre-open する。
--
-- Chance は実行時に乱数をホスト決定→配信するため、両端末で同名・同 port のチャンネルが要る。
-- チャンネルは **dispatcher インスタンス**に持つ（config テーブル `a` は全インスタンス共有なので、
-- そこに `_chanceChannel` を書くと 2体目/リトライで「開設済み扱い→未開設チャンネルへ hostDecide」で
-- クラッシュする＝per-instance 違反 docs/13 §6-3）。
-- Sync を持つ Component の initialize から、決定的な順序（map はキー昇順）で呼ぶこと。これにより
-- 到達順依存・per-instance・port 決定性が一括で解消し、host 限定文脈でも安全になる。
--
-- @param dispatcher
-- @param actions  Action | function | array of (Action|function)
------
function _M.preregisterChances(dispatcher, actions)
    if actions == nil or type(actions) == 'function' then
        return
    end
    if _M.isAction(actions) then
        actions = { actions }
    end
    for i = 1, #actions do
        local item = actions[i]
        if _M.isAction(item) and item.actionName == 'Chance' then
            dispatcher._chanceChannels = dispatcher._chanceChannels or {}
            if dispatcher._chanceChannels[item] == nil then
                dispatcher._chanceSeq = (dispatcher._chanceSeq or 0) + 1
                local name = 'chance' .. dispatcher._chanceSeq
                dispatcher._chanceChannels[item] = name
                dispatcher:openChannel(name, function(self, success)
                    if success == 1 then
                        _M.runActions(self, (self._chanceEvents or {})[item], item.actions)
                    end
                end)
                _M.preregisterChances(dispatcher, item.actions)   -- ネストした Chance も
            end
        elseif _M.isAction(item) and item.actionName == 'IfUseCount' then
            _M.preregisterChances(dispatcher, item.actions)       -- 回数条件の中の Chance も
        end
    end
end

_G.package.loaded[_NAME] = _M
return _M
