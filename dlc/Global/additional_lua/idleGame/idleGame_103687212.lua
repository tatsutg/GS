local class = summoner.IdleGameEventDispatcher.createIdleGameClass({label="idleGame 超覚醒アリステラ・オルビス", version=1.0, id="idleGame_103687212"});
class:inherit("idleGameBase")
local json = summoner.Json;

-- event {unit, instance }
--SpineがAddChildされた直後に呼ばれる
function class:start(event)
    self.gameUnit = event.unit;
end

-- event {unit,index}
function class:takeAttack(event)
    event.unit:setNextAnimationName("attack1");
    event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-attack1");
    return 1;
end

--event {unit,index}
function class:run(event)
    if string.find(event.spineEvent,"10368ice_") ~= nil then
        local strN = string.sub(event.spineEvent,10)
        local num = tonumber(strN)
        if num ~= nil then
            local ice = event.unit:IG_addOrbitSystemInsightRotation("SHOT","HIT",1,-50,num,0,0)
            if event.unit:getUnitState() == kUnitState_attack then
                ---通常攻撃：attackDelay分の特殊系補正を入れる
                --ice:setDamageRateOffset(event.unit:getAttackDelay());
            end
        end
    end
    return 1;
end

class:publish();

return class;
