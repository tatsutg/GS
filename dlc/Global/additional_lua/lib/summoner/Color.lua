------
-- Representation of RGB colors
------
local _NAME = "summoner.Color"
local _M = {}
local _G = _G

_M.ZERO = 0
_M.MAX = 255

------
-- red, r: Red component of the color
-- green, g: Green component of the color
-- blue, b: Blue component of the color
-- @constructor
-- @param number red
-- @param number green
-- @param number blue
------
function _M:new(red, green, blue)
    red = math.floor(red)
    green = math.floor(green)
    blue = math.floor(blue)
    local self_ = setmetatable({
        red = red,
        green = green,
        blue = blue,
        r = red,
        g = green,
        b = blue
    }, {
        __index = self,
        __tostring = self.toString
    })
    return self_
end

------
-- Returns a nicely formatted string for this color
-- @return string
------
function _M:toString()
    local str = "Color(" .. self.r .. ", " .. self.g .. ", " .. self.b .. ")"
    return str
end

------
-- Static variables
------
_M.black   = _M:new(_M.ZERO, _M.ZERO, _M.ZERO)
_M.blue    = _M:new(_M.ZERO, _M.ZERO, _M.MAX)
_M.cyan    = _M:new(_M.ZERO, _M.MAX, _M.MAX)
_M.gray    = _M:new((_M.MAX + 1)*0.5 - 1, (_M.MAX + 1)*0.5 - 1, (_M.MAX + 1)*0.5 - 1)
_M.green   = _M:new(_M.ZERO, _M.MAX, _M.ZERO)
_M.grey    = _M.gray
_M.magenta = _M:new(_M.MAX, _M.ZERO, _M.MAX)
_M.red     = _M:new(_M.MAX, _M.ZERO, _M.ZERO)
_M.white   = _M:new(_M.MAX, _M.MAX, _M.MAX)
_M.yellow  = _M:new(_M.MAX, (_M.MAX + 1)*0.92 - 1, (_M.MAX + 1)*0.016 - 1)
_M.orange  = _M:new((_M.MAX + 1)*0.91 - 1, (_M.MAX + 1)*0.63 - 1, (_M.MAX + 1)*0.05 - 1)

_G.package.loaded[_NAME] = _M
return _M
