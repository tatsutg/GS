------
-- summoner.Choreo.Targeting
--
-- Action の target= に渡すターゲット指定子。
-- getTeam / getTeamUnit ループ（[06] §探索）を隠蔽する。
--
-- @example
--     AttachBuff{ ..., target = Targeting{ side="player", pick="lowestHP" } }
--     GainSP{ value = 300, target = Targeting{ side="player", pick="leader" } }
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
        -- 累計ダメ最大（HateTarget Component と併用）。
        -- ⚠ 自動蘇生で同じ枠が**別のユニットオブジェクトとして再登録される**実装があり、その場合
        --    engine の getHateTarget() は死亡前の実体を返し続ける（累計は枠番号で持っているので
        --    フォーカス表示は蘇生後のユニットに出たまま）。その実体に addCondition しても何も起きない。
        --    そこで**枠番号で今のユニットを取り直す**。戦闘不能なら getTeamUnit が nil を返す。
        --    死亡前の実体へのメソッド呼び出しが安全とは限らないので getIndex は pcall で包む。
        local t = dispatcher.unit:getHateTarget()
        if t == nil or t == false then
            return nil
        end
        local ok, idx = pcall(t.getIndex, t)
        if not ok or idx == nil then
            return nil
        end
        return megast.Battle:getInstance():getTeam(true):getTeamUnit(idx)
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

    -- リーダーユニット。engine の TeamUnit::getIsLeader() で判定する（TeamUnit.pkg に公開済み。
    --   実ボス慣用: enemy/2064545.lua:564 / 2078896.lua:721-732 ほか）。
    --   getTeamUnit は戦闘不能の枠に nil を返すため、
    --     ・リーダーが戦闘不能 → 生存している中で一番左（＝最小 index）へ自動でフォールバック
    --     ・蘇生 → 次の解決で自動的にリーダーへ戻る
    --   ＝追従の状態を Lua 側に持たなくてよい（評価のたびに引き直す）。
    --   フォールバックの規約は engine の Team::getLeader()（リーダー不在なら最小 index）と同じ。
    -- ⚠ マルチプレイでは getIsLeader() が **index==0 固定**になる（TeamUnit.cpp の isMultiPlay 分岐）。
    --    プレイヤーチームは全プレイヤーのユニットが1つの index 空間に入るため、
    --    全端末が同じ1体を指す（同期はズレない）が、**ゲストのリーダーは対象にならない**。
    if pick == 'leader' then
        local first = nil
        for i = 0, _M.MAX_INDEX do
            local u = team:getTeamUnit(i)
            if u ~= nil then
                if u:getIsLeader() then
                    return u
                end
                if first == nil then
                    first = u
                end
            end
        end
        return first
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
