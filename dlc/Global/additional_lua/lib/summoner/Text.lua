------
-- バトル中のメッセージなどの定数群
-- 言語によってロードするファイルを切り替える
-- 言語の判別はグローバル変数の locale を使う
------
local _NAME = "summoner.Text"
local _M = {}
local _G = _G

------
-- デフォルト言語
------
_M.DEFAULT_LOCALE = "ja_jp"

------
-- ロードするモジュールの接頭語
------
_M.MODULE_PREFIX = "summoner.locale."

------
-- 言語によってロードするファイルを切り替える
-- UNITS、ENEMIES、QUESTSのキーがなければ空のテーブルをセットする
------
local moduleName = _M.MODULE_PREFIX .. LuaUtilities.getLanguage()
_M.TEXTS = require(moduleName)
for key in ipairs({"UNITS", "ENEMIES", "QUESTS"}) do
    if _M.TEXTS[key] == nil then
        _M.TEXTS[key] = {}
    end
end

------
-- ユニットIDから定数群を取得する
------
function _M:fetchByUnitID(unitID)
    local texts = self.TEXTS.UNITS[unitID]
    if texts == nil then
        texts = {}
    end
    return texts
end

------
-- エネミーIDから定数群を取得する
------
function _M:fetchByEnemyID(enemyID)
    local texts = self.TEXTS.ENEMIES[enemyID]
    if texts == nil then
        texts = {}
    end
    return texts
end

------
-- クエストIDから定数群を取得する
------
function _M:fetchByQuestID(questID)
    local texts = self.TEXTS.QUESTS[questID]
    if texts == nil then
        texts = {}
    end
    return texts
end

------
-- クエストIDから定数群を取得する
------
function _M:fetchByMapThemeID(mapThemeID)
    local texts = self.TEXTS.MAP_THEME[mapThemeID]
    if texts == nil then
        texts = {}
    end
    return texts
end

_G.package.loaded[_NAME] = _M
return _M
