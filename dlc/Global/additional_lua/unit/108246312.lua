local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒オカルン", version=1.8, id=108246312});
class:inheritFromUnit("108247312");


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    --スーパーダッシュ
    self.SP_VALUE = 200
    if megast.Battle:getInstance():getBattleState() == kBattleState_active and not megast.Battle:getInstance():isPvp() and event.unit:getLevel() >= 90 then
        if not self:checkParametor(event.unit,"superDash") then
            self:superDash(event.unit);
            event.unit:setParameter("superDash","TRUE");
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    return 1
end


class:publish();

return class;