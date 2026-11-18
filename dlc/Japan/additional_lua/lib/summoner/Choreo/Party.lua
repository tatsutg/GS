------
-- summoner.Choreo.Party
--
-- プレイヤー編成の「distinct 数」を数える共有ヘルパ（属性数 / 種族数）。
-- Defense の byCount 条件（countParty）と、Action の動的 value（countParty）が
-- 同じ数え方を共有するための唯一の実装。
--
-- ⚠ engine の Team::getTeamUnit(i) は死亡ユニットに NULL を返す（force=false 既定）ため、
--    ここで数えられるのは常に「生存ユニット」。死亡で数は自然に減る。
-- 同期不要: 全端末が同じチーム状態から同じ数を得る決定的処理。
------
local _NAME = 'summoner.Choreo.Party'
local _M = {}
local _G = _G

_M.SLOTS = 8   -- 走査するチーム枠数（engine の最大枠）

------
-- プレイヤー側チームの distinct な属性数 / 種族数を数える。
--
-- @param string by  'race' で種族（getRaceType）、それ以外は属性（getElementType）
-- @return number    生存ユニットの distinct 数
------
function _M.countDistinct(by)
    local team = megast.Battle:getInstance():getTeam(true)
    local seen = {}
    local c = 0
    for i = 0, _M.SLOTS - 1 do
        local u = team:getTeamUnit(i)
        if u ~= nil then
            local key
            if by == 'race' then
                key = u:getRaceType()
            else
                key = u:getElementType()
            end
            if not seen[key] then
                seen[key] = true
                c = c + 1
            end
        end
    end
    return c
end

_G.package.loaded[_NAME] = _M
return _M
