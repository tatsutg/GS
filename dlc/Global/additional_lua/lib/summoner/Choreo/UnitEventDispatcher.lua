------
-- summoner.Choreo.UnitEventDispatcher
--
-- プリミティブなイベント処理クラス。
-- 1イベントに複数リスナを登録でき、Component を add して機能を合成する。
--
-- メソッド解決順: components < Choreo.UnitEventDispatcher < Bootstrap.UnitEventDispatcher
-- Component の追加は add（= addComponent）で行う。
------
local _NAME = 'summoner.Choreo.UnitEventDispatcher'
local _M = {}
local _G = _G

local Bootstrap = require('summoner.Bootstrap')

setmetatable(_M, {__index=Bootstrap.UnitEventDispatcher})

------
-- Event クラス
--
-- prevent() を呼ぶと、そのイベントの戻り値は 0（中断）になる。
-- 値変換系イベント（RETURNS_VALUE）は returnKey 経由で値を運ぶ。
------
_M.Event = {
    returnValue = 1,
    returnKey = 'returnValue',
    getReturnValue = function(self) return self[self.returnKey] end,
    setReturnValue = function(self, value) self[self.returnKey] = value end,
    prevent = function(self) self.prevented = true end,
    prevented = false
}

------
-- コミットイベントの名前サフィックス。
-- `<eventName>@commit` に登録したリスナは、その発火が誰にも prevent() されず
-- 完走したときだけ呼ばれる（= C++ 側で行動が実際に成立する発火）。
-- Attack/Smash(Selector) の二段発火では pass1(抽選→prevent) は対象外、pass2 のみ発火する。
-- Events.OnAttackCommit / OnSmashCommit と対応（値は同期させること）。
------
_M.COMMIT_SUFFIX = '@commit'

------
-- 戻り値が 1/0 ではなく「値」を返すイベント（[03] 値変換系）と、その値キー。
-- unitManager.lua の既定戻り値に一致させること（未実装時の素通しを正しくするため）。
------
_M.RETURNS_VALUE = {
    attackElementRate = 'value',
    takeElementRate = 'value',
    takeBreakeDamageValue = 'value',
    attackDamageValue = 'value',
    attackDamageValue_OrbitSystem = 'value',
    takeDamageValue = 'value',
    takeMultiDamageValue = 'value',      -- ver2.4: 既定 value
    takeHeal = 'heal_origin',            -- ver1.7: 既定 heal_origin（未加工時の素通し）
    extraTimerOneRound = 'count',        -- ver2.5: 既定 count（エンジンのループ計数）
}

------
-- 初期化処理
--
-- table: components       追加済み Component 名の配列
-- table: eventListeners   イベント名 => リスナ配列
------
function _M.initialize(dispatcher)
    local meta = {}
    setmetatable(dispatcher, {__index=setmetatable(meta, {__index=_M})})
    dispatcher.components = {}
    dispatcher.eventListeners = {}
    dispatcher.isHostPlayer = megast.Battle:getInstance():isHost()
    dispatcher.isGuestPlayer = not dispatcher.isHostPlayer
    dispatcher.unit = false

    dispatcher.addComponent = function(self, vendor)
        table.insert(self.components, vendor.name)
        local initialize = vendor.initialize
        vendor.name, vendor.initialize = nil, nil

        for memberName, member in pairs(vendor) do
            meta[memberName] = member
        end

        if initialize ~= nil then
            initialize(self)
        end
        return self
    end

    -- 主 API。boss:add(Component{...}) で組み立てる。
    dispatcher.add = dispatcher.addComponent
end

------
-- Component を持っていれば true
--
-- @param string name
-- @return boolean
------
function _M:hasComponent(name)
    for i, component in ipairs(self.components) do
        if component == name then
            return true
        end
    end
    return false
end

------
-- イベントリスナを追加する
--
-- @param string eventName
-- @param function listener  function(self, event)
------
function _M:addEventListener(eventName, listener)
    assert(type(eventName) == 'string', "bad argument #1 to 'addEventListener' (string expected, got " .. type(eventName) .. ')')
    assert(type(listener) == 'function', "bad argument #2 to 'addEventListener' (function expected, got " .. type(listener) .. ')')

    if self.eventListeners[eventName] == nil then
        self.eventListeners[eventName] = {}
    end
    table.insert(self.eventListeners[eventName], listener)
    return self
end

------
-- イベントリスナを削除する
--
-- @param string eventName
-- @param function listener
------
function _M:removeEventListener(eventName, listener)
    assert(type(eventName) == 'string', "bad argument #1 to 'removeEventListener' (string expected, got " .. type(eventName) .. ')')
    assert(type(listener) == 'function', "bad argument #2 to 'removeEventListener' (function expected, got " .. type(listener) .. ')')

    if self.eventListeners[eventName] ~= nil then
        local found = nil
        for i, listener_ in ipairs(self.eventListeners[eventName]) do
            if listener_ == listener then
                found = i
                break
            end
        end
        if found ~= nil then
            table.remove(self.eventListeners[eventName], found)
        end
    end
    return self
end

------
-- ゲーム（C++）とのインターフェース（listeners テーブル）を生成する
--
-- 各イベントについて、登録済みリスナを順次呼ぶ。
-- いずれかが event:prevent() を呼べば 0（中断）を返す。
-- start イベント時に self.unit を捕捉する。
------
function _M:generate()
    local listeners = {}
    for eventName, hook in pairs(Bootstrap.UnitEventDispatcher.HOOK_FUNCTIONS) do
        local eventMaker = self.makeEventMaker(eventName, hook.args, _M.RETURNS_VALUE[eventName] or _M.Event.returnKey)
        listeners[eventName] = function(_, ...)
            local event = eventMaker(...)
            if eventName == 'start' then
                self.unit = event.unit
                -- 毎戦闘 host/guest を再取得（クラス時固定だと永続 VM で 2戦目以降・ホスト移譲時にずれる）
                self.isHostPlayer = megast.Battle:getInstance():isHost()
                self.isGuestPlayer = not self.isHostPlayer
            end
            if self.eventListeners[eventName] ~= nil then
                for i, listener in ipairs(self.eventListeners[eventName]) do
                    listener(self, event)
                    if event.prevented == true then
                        return 0
                    end
                end
            end
            -- コミット: prevent されずに完走 = 行動が実際に成立する発火のみ通知
            local commitListeners = self.eventListeners[eventName .. _M.COMMIT_SUFFIX]
            if commitListeners ~= nil then
                for i, listener in ipairs(commitListeners) do
                    listener(self, event)
                end
            end
            return event:getReturnValue()
        end
    end
    return listeners
end

------
-- Event オブジェクトを作る関数を作る
--
-- @param string eventName
-- @param array of string args
-- @param string returnKey
------
function _M.makeEventMaker(eventName, args, returnKey)
    local eventMaker = function(...)
        local event = setmetatable({name=eventName}, {__index=_M.Event})
        event.returnKey = returnKey
        for i, name in ipairs(args) do
            local value = select(i, ...)
            event[name] = value
        end
        return event
    end
    return eventMaker
end

_G.package.loaded[_NAME] = _M
return _M
