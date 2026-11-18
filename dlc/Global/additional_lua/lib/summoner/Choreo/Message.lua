------
-- summoner.Choreo.Message
--
-- バトル中メッセージ（ボスの台詞など）の値オブジェクト。
-- Message{text=...}:show() で敵側に、:showPlayerSide() でプレイヤー側に表示する。
--
-- 注: Action.Say はこの Message をラップして宣言面を提供する。
------
local _NAME = 'summoner.Choreo.Message'
local _M = {}
local _G = _G

local Color = require('summoner.Color')
local Utility = require('summoner.Utility')

-- 既定の表示秒数。旧形式ボスの setMessageInfo（DURATION 既定 7）に合わせている。
_M.DEFAULT_TIME = 7
_M.DEFAULT_COLOR = Color.yellow
_M.DEFAULT_ICON = 0

------
-- summoner.Choreo.Message のインスタンスを作る
-- @param table parameters
--     string text
--     number(optional) time
--     summoner.Color(optional) color
--     number(optional) icon
-- @return summoner.Choreo.Message
------
setmetatable(_M, {__call=function(self, parameters)
    assert(type(parameters) == 'table', "bad argument #1 to 'Message' (table expected, got " .. type(parameters) .. ')')
    assert(type(parameters.text) == 'string', "bad argument #1 at 'text' to 'Message' (string expected, got " .. type(parameters.text) .. ')')

    local message = setmetatable({}, {__index=self})
    message.text = parameters.text
    message.time = parameters.time or _M.DEFAULT_TIME
    message.color = parameters.color or _M.DEFAULT_COLOR
    message.icon = parameters.icon or _M.DEFAULT_ICON
    return message
end})

------
-- 敵側にメッセージを表示する（既定）
------
function _M:showEnemySide()
    if self.icon == 0 then
        Utility.messageByEnemy(self.text, self.time, self.color)
    else
        Utility.messageByEnemy(self.text, self.time, self.color, self.icon)
    end
end
_M.show = _M.showEnemySide

------
-- プレイヤー側にメッセージを表示する
------
function _M:showPlayerSide()
    if self.icon == 0 then
        Utility.messageByPlayer(self.text, self.time, self.color)
    else
        Utility.messageByPlayer(self.text, self.time, self.color, self.icon)
    end
end

_G.package.loaded[_NAME] = _M
return _M
