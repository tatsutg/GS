------
-- ロギング関連の処理
------
local ipairs = ipairs
local pairs = pairs
--local print = print -- for Cocos2d-x APIs
local select = select
local setmetatable = setmetatable
local string = string
local table = table
local tostring = tostring

local TABLE_TYPE = type({})

local _NAME = "summoner.Logger"
local _M = {}
local _G = _G

_M.DEBUG = 1
_M.INFO = 2
_M.NOTICE = 3
_M.WARN = 4
_M.ERROR = 5
_M.DEFAULT_LOG_LEVEL = _M.NOTICE
_M.LOG_LEVEL = _M.DEFAULT_LOG_LEVEL

_M.DIVIDER = ("-"):rep(64)


------
-- ログレベルを変更する
-- Logger.DEBUG、Logger.INFO、Logger.NOTICE、Logger.WARN、Logger.ERRORを指定する
-- 
-- @param number level
------
function _M:setLogLevel(level)
    self.LOG_LEVEL = level
end


------
-- コンストラクタ
-- 
-- @param string label
------
function _M:new(label)
    local self = setmetatable({}, {__index=self})
    self.label = label or nil
    return self
end


------
-- 標準出力に改行付きで出力する
-- 2つ目以降の引数はstring.formatの引数として渡される
-- 
-- @param mixed message
-- @param mixed(optional, variadic)
------
function _M:writeln(message, ...)
    if self.label == nil then
        print(("Lua: %s"):format(message):format(...))
    else
        print(((("Lua(%s): "):format(self.label) .. "%s"):format(message)):format(...))
    end
end


------
-- 変数の内容を出力する
-- 
-- @param mixed x
-- @param number(optional) indentLevel
------
function _M:dump(x, indentLevel)
    if indentLevel == nil then
        indentLevel = 0
    end

    local indent = string.rep("    ", indentLevel)
    if type(x) ~= TABLE_TYPE then
        print(indent .. tostring(x))
        return
    end

    local classes = {}
    for name, cls in pairs(_G.package.loaded) do
        classes[cls] = name
    end

    local keys = {}
    for key, _ in pairs(x) do
        table.insert(keys, key)
    end
    local count = table.maxn(keys)
    if count == 0 then
        print(indent .. "empty table")
        return
    end

    table.sort(keys)
    for i, key in ipairs(keys) do
        if type(x[key]) ~= TABLE_TYPE then
            print(indent .. ("%s -> %s"):format(key, x[key]))
        else
            local moduleName = nil
            if classes[ x[key] ] ~= nil then
                moduleName = ("module: %s"):format(classes[ x[key] ])
            else
                moduleName = tostring(x[key])
            end
            print(indent .. ("%s -> %s"):format(key, moduleName))
            self:dump(x[key], indentLevel + 1)
        end
    end
end


------
-- ログレベルがLogger.DEBUGより小さいときに出力する
------
function _M:debug(...)
    if _M.LOG_LEVEL <= _M.DEBUG then
        self:writeln(...)
    end
end


------
-- ログレベルがLogger.INFOより小さいときに出力する
------
function _M:info(...)
    if _M.LOG_LEVEL <= _M.INFO then
        self:writeln(...)
    end
end


------
-- ログレベルがLogger.NOTICEより小さいときに出力する
------
function _M:notice(...)
    if _M.LOG_LEVEL <= _M.NOTICE then
        self:writeln(...)
    end
end

------
-- ログレベルがLogger.WARNより小さいときに出力する
------
function _M:warn(...)
    if _M.LOG_LEVEL <= _M.WARN then
        self:writeln(...)
    end
end


------
-- ログレベルがLogger.ERRORより小さいときに出力する
------
function _M:error(...)
    if _M.LOG_LEVEL <= _M.ERROR then
        self:writeln(...)
    end
end


------
-- noticeのエイリアス
------
_M.LOG = _M.NOTICE
_M.log = _M.notice


_G.package.loaded[_NAME] = _M
return _M
