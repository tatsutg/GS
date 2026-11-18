local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒オイカッツォ", version=1.3, id=107897112});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.bpUp = 200
    ---FLG管理
    if event.unit:getParameter("abilityFlg") == "" then
        event.unit:setParameter("abilityFlg","true")
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---瀕死時
    if event.unit:getParameter("abilityFlg") == "true" and summoner.Utility.getUnitHealthRate(event.unit) < 0.4 then
        event.unit:setParameter("abilityFlg","false")
        event.unit:takeHeal(event.unit:getCalcHPMAX())
        event.unit:addSPWithPvpCorrection(self.bpUp)
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
    end
    return 1
end

function class:receive1(args)
    if self.gameUnit:getParameter("abilityFlg") == "true" then
        self.gameUnit:setParameter("abilityFlg","false")
        self.gameUnit:takeHeal(self.gameUnit:getCalcHPMAX())
        self.gameUnit:addSPWithPvpCorrection(self.bpUp)
    end
    return 1;
end


class:publish();

return class;