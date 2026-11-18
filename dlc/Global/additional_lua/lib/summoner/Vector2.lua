------
-- Representation of 2D vectors and points
-- @example
--     local v = summoner.Vector2:new(3, 4)
--     print(v.magnitude)
--     print(v.normalized.x)
--     print(v.normalized.y)
--     print(v*2)
--     print(v + summoner.Vector2:new(5, -5))
--     print(summoner.Vector2.distance(v, summoner.Vector2:new(10, 20)))
--     print(summoner.Vector2.left*10)
------
local math = math
local setmetatable = setmetatable

local _NAME = "summoner.Vector2"
local _M = {}
local _G = _G

------
-- x: X component of the vector
-- y: Y component of the vector
-- magnitude: Length of this vector
-- normalized: Vector with a magnitude of 1
-- @constructor
-- @param number x
-- @param number y
------
function _M:new(x, y)
    if x == nil then
        x = 0
    end
    if y == nil then
        y = 0
    end
    local self_ = setmetatable({
        x = x,
        y = y,
        magnitude = math.sqrt(x*x + y*y),
        normalized = {x=0, y=0}
    }, {
        __index = self,
        __tostring = self.toString,
        __add = self.adds,
        __sub = self.subtracts,
        __mul = self.multiplies,
        __div = self.divides
    })
    if self_.magnitude ~= 0 then
        self_.normalized = {
            x = x/self_.magnitude,
            y = y/self_.magnitude
        }
    end
    return self_
end

------
-- Set x and y components of an existing Vector2
-- @param number x
-- @param number y
-- @return summoner.Vector2
------
function _M:set(x, y)
    self.x = x
    self.y = y
    self.magnitude = math.sqrt(x*x + y*y)
    if self.magnitude == 0 then
        self.normalized = {x=0, y=0}
    else
        self.normalized = {
            x = x/self.magnitude,
            y = y/self.magnitude
        }
    end
end

------
-- Makes this vector have a magnitude of 1
-- @return summoner.Vector2
------
function _M:normalize()
    if self.magnitude ~= 0 then
        return _M:new(self.x/self.magnitude, self.y/self.magnitude)
    end
    return _M:new(0, 0)
end

------
-- Returns a nicely formatted string for this vector
-- @return string
------
function _M:toString()
    local str = "Vector2(" .. self.x .. ", " .. self.y .. ")"
    return str
end

------
-- Returns the distance between a and b
-- @static
-- @param summoner.Vector2 a
-- @param summoner.Vector2 b
-- @return number
------
function _M.distance(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local distance = math.sqrt(dx*dx + dy*dy)
    return distance
end

------
-- Adds two vectors
-- @static
-- @param summoner.Vector2 a
-- @param summoner.Vector2 b
-- @return summoner.Vector2
------
function _M.adds(a, b)
    return _M:new(a.x + b.x, a.y + b.y)
end

------
-- Subtracts one vector from another
-- @static
-- @param summoner.Vector2 a
-- @param summoner.Vector2 b
-- @return summoner.Vector2
------
function _M.subtracts(a, b)
    return _M:new(a.x - b.x, a.y - b.y)
end

------
-- Multiplies a vector by a number
-- @static
-- @param summoner.Vector2 vector
-- @param number number
-- @return summoner.Vector2
------
function _M.multiplies(vector, number)
    return _M:new(vector.x*number, vector.y*number)
end

------
-- Divides a vector by a number
-- @static
-- @param summoner.Vector2 vector
-- @param number number
-- @return summoner.Vector2
------
function _M.divides(vector, number)
    return _M:new(vector.x/number, vector.y/number)
end

------
-- Static variables
------
_M.down  = _M:new(0, -1)
_M.left  = _M:new(-1, 0)
_M.one   = _M:new(1, 1)
_M.right = _M:new(1, 0)
_M.up    = _M:new(0, 1)
_M.zero  = _M:new(0, 0)

_G.package.loaded[_NAME] = _M
return _M
