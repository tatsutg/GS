------
-- グランドサマナーズ用モジュール詰め合わせ
-- 使い方は各モジュールのコメントを参照
--
-- @module Color
-- @module Logger
-- @module Random
-- @module Text
-- @module Utility
-- @module Vector2
------
local pairs = pairs
local require = require
local select = select
local table = table
local type = type
local unpack = unpack

local TABLE_TYPE = type({})

local _NAME = "summoner"
local _M = {}
local _G = _G

------
-- 指定したモジュールを読み込む
-- 
-- @example
--     local Class, Logger = summoner.import("Class", "Logger") -- importing `Class` and `Logger` into local
--     summoner.import(_G, "Unit", "Utility") -- importing `Unit` and `Utility` into global
-- 
-- @param string|table(optional, variadic)
------
function _M.import(...)
    local modules = {}
    local args = select("#", ...)
    if args >= 1 then
        local env = ...
        local start = 2
        if type(env) ~= TABLE_TYPE then
            env = nil
            start = 1
        end
        for i = start, args do
            local moduleName = select(i, ...)
            local module_ = _M[moduleName]
            table.insert(modules, module_)
            if env ~= nil then
                env[moduleName] = module_
            end
        end
    end
    return unpack(modules)
end

_M.AI = require("summoner.AI")
_M.Bootstrap = require("summoner.Bootstrap")
_M.Color = require("summoner.Color")
_M.FieldEventDispatcher = require("summoner.FieldEventDispatcher")
_M.MapThemeEventDispatcher = require("summoner.MapThemeEventDispatcher")
_M.DungeonEventDispatcher = require("summoner.DungeonEventDispatcher")
_M.IdleGameEventDispatcher = require("summoner.IdleGameEventDispatcher")
_M.Json = require("summoner.Json")
_M.Logger = require("summoner.Logger")
_M.Random = require("summoner.Random")
_M.Text = require("summoner.Text")
_M.Utility = require("summoner.Utility")
_M.Vector2 = require("summoner.Vector2")

_G.package.loaded[_NAME] = _M
return _M
