local class = summoner.Bootstrap.createUnitClass({label="ジーラ", version=1.5, id=102015212});

-- --バフカウンター配列


-- class.BUFF_ID = 10201;

-- function class:start(event)
--     self.recastTimer = 0;
--     return 1;
-- end


-- function class:update(event)
--     self.recastTimer = self.recastTimer - event.deltaTime;
--     if self.recastTimer <= 0 and self:getIsControll(event.unit) then
--         local hpRate = summoner.Utility.getUnitHealthRate(event.unit) * 100;
--         if hpRate <= 40 then
--             self:addBuff(event.unit);
--             megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
--         end
--     end
--     return 1;
-- end


-- function class:addBuff(unit)
--     local level = unit:getLevel();
--     if level >= 90 then
--         unit:getTeamUnitCondition():addCondition(self.BUFF_ID,98,2200,10,24,1);
--     end
--     self.recastTimer = 60;
-- end


-- function class:getIsControll(unit)
--      return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
-- end

-- function class:receive1(args)
--     self:addBuff(self.gameUnit,args.arg);
--     return 1;
-- end

class:publish();

return class;
