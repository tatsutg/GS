------
-- summoner.Choreo.Targeting
--
-- Action の target= に渡すターゲット指定子。
-- getTeam / getTeamUnit ループ（[06] §探索）を隠蔽する。
--
-- @example
--     AttachBuff{ ..., target = Targeting{ side="player", pick="lowestHP" } }
------
local _NAME = 'summoner.Choreo.Targeting'
local _M = {}
local _G = _G

_M.MAX_INDEX = 7   -- チーム枠 0..7

local meta = {}
meta.__index = meta
meta.__choreoTargeting = true

local function teamOf(side)
    if side == 'enemy' then
        return megast.Battle:getInstance():getTeam(false)
    end
    -- 'player' 既定（プレイヤー側チーム）
    return megast.Battle:getInstance():getTeam(true)
end

------
-- 対象を解決する
-- @return TeamUnit | array of TeamUnit（pick="all" のとき）| nil
------
function meta:resolve(dispatcher, event)
    -- side 指定 × pick 省略は pick='self'(ボス)を返す典型ミス → 弾く（プレイヤー狙いのつもりが自分を返す）
    assert(self.pick ~= nil or self.side == nil or self.side == 'self',
           'Choreo: Targeting に side を指定したら pick も指定すること（pick 省略は self=ボスになる）')
    local pick = self.pick or 'self'

    if pick == 'self' or self.side == 'self' then
        return dispatcher.unit
    end

    if pick == 'hate' then
        return dispatcher.unit:getHateTarget()   -- 累計ダメ最大（HateTarget Component と併用）
    end

    local team = teamOf(self.side or 'player')

    if pick == 'all' then
        local list = {}
        for i = 0, _M.MAX_INDEX do
            local u = team:getTeamUnit(i)
            if u ~= nil then
                table.insert(list, u)
            end
        end
        return list
    end

    if pick == 'byBaseID' then
        for i = 0, _M.MAX_INDEX do
            local u = team:getTeamUnit(i)
            if u ~= nil and u:getBaseID3() == self.baseID then
                return u
            end
        end
        return nil
    end

    -- lowestHP / highestHP
    local best, bestRate = nil, nil
    for i = 0, _M.MAX_INDEX do
        local u = team:getTeamUnit(i)
        if u ~= nil then
            local rate = u:getHP() / u:getCalcHPMAX()
            if bestRate == nil
                or (pick == 'lowestHP' and rate < bestRate)
                or (pick == 'highestHP' and rate > bestRate) then
                best, bestRate = u, rate
            end
        end
    end
    return best
end

setmetatable(_M, {__call = function(self, params)
    return setmetatable(params or {}, meta)
end})

_G.package.loaded[_NAME] = _M
return _M
