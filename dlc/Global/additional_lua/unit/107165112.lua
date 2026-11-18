local class = summoner.Bootstrap.createUnitClass({label="ミリム", version=1.3, id=107166112});

function class:attackDamageValue(event)
   local myTeam = megast.Battle:getInstance():getTeam(false);
   if megast.Battle:getInstance():isPvp() then
      local cond = event.unit:getTeamUnitCondition():findConditionWithType(84);
      if cond ~= nil then
         if event.enemy:getHP() < 1 then
            event.enemy:setHP(1)
         end
         --enemy:setInvincibleTime(0.5)
         local hp = event.enemy:getHP() - event.value
         if hp < 1 then
            event.value = event.enemy:getHP() - 1
         end
      end
   end
   return event.value;
end

class:publish();

return class;