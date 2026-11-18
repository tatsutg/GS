local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ヴェルドラ", version=1.3, id=108097312});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---FLG管理
    if event.unit:getParameter("once") == "" then
        event.unit:setParameter("once","TRUE")
    end
    ---瀕死時HP回復&バフ
    if event.unit:getParameter("once") == "TRUE" and summoner.Utility.getUnitHealthRate(event.unit) < 0.4 then
        event.unit:setParameter("once","FALSE")
        self:teamHeal(event.unit)
        self:teamBurstHeal(event.unit)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
    end
    return 1
end

function class:receive1(args)
    if self.gameUnit:getParameter("once") == "TRUE" then
        self.gameUnit:setParameter("once","FALSE")
        self:teamHeal(self.gameUnit)
        self:teamBurstHeal(self.gameUnit)
    end
    return 1;
end

function class:teamBurstHeal(unit)
    for i = 0,6 do
        local myTeamUnit = unit:getTeam():getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:addSPWithPvpCorrection(150)
        end
    end
end

function class:teamHeal(unit)
    for i = 0,6 do
        local myTeamUnit = unit:getTeam():getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:takeHeal(myTeamUnit:getCalcHPMAX(),unit)
        end
    end
end

class:publish();

return class;