local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="超覚醒聖女ジュノー（ハロウィンver）", version=2.8, id=104387412});

-- 鼓舞：瀕死になった時、回数分だけ味方全体のHPを回復する
---解放レベルと回数（Lv75で2回・Lv120で3回）
class.ENCOURAGE_LEVELS = {
    {level = 120, count = 3},
    {level = 75, count = 2}
}
class.ENCOURAGE_HEAL_PERCENT = 100
class.DYING_RATE = 0.4

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    local unit = event.unit;
    local rate = summoner.Utility.getUnitHealthRate(unit);
    ---瀕死を抜けたら次の発動を受け付ける（回復が効かず瀕死のままの時に回数を一度に使い切らないため）
    if rate >= self.DYING_RATE then
        unit:setParameter("encourageArmed", "true");
        return 1;
    end
    if unit:getParameter("encourageArmed") == "false" or unit:getHP() <= 0 then
        return 1;
    end
    local used = self:getEncourageUsed(unit);
    if used >= self:getEncourageCount(unit) then
        return 1;
    end
    self:encourage(unit, used + 1);
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 1, used + 1);
    return 1;
end

function class:receive1(args)
    ---相手端末で同じ回が発動済みなら二重に回復しない
    if self:getEncourageUsed(self.gameUnit) < args.arg then
        self:encourage(self.gameUnit, args.arg);
    end
    return 1;
end

function class:getEncourageCount(unit)
    local level = unit:getLevel();
    for _, entry in ipairs(self.ENCOURAGE_LEVELS) do
        if level >= entry.level then
            return entry.count;
        end
    end
    return 0;
end

function class:getEncourageUsed(unit)
    return tonumber(unit:getParameter("encourageUsed")) or 0;
end

function class:encourage(unit, count)
    unit:setParameter("encourageUsed", "" .. count);
    unit:setParameter("encourageArmed", "false");
    for i = 0, 6 do
        local myTeamUnit = unit:getTeam():getTeamUnit(i);
        if myTeamUnit ~= nil then
            myTeamUnit:takeHeal(myTeamUnit:getCalcHPMAX() * self.ENCOURAGE_HEAL_PERCENT / 100, unit);
        end
    end
end

class:publish();

return class;
