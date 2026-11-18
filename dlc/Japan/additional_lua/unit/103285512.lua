local class = summoner.Bootstrap.createUnitClass({label="闇ハルト", version=1.9, id=103285512});


function class:run(event)
    if event.spineEvent == "shot" then
        local orbit = event.unit:addOrbitSystem("shot",0)
        orbit:setDamageRateOffset(0.25)
        orbit:setBreakRate(0.25)
        orbit:setHitCountMax(1)
        orbit:setEndAnimationName("skill2_hit")
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    return 1
end
---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    if event.index == 2 then
        event.unit:setDamageRateOffset(0.25)
        event.unit:setBreakRate(0.25)
    end
    -- 【MEGA_D-9761】ボスの技の予告に、この技で Lua が作る弾（addOrbitSystem）の取り分を入れる（本体の取り分を下げた残り。表示専用。古いアプリには無いので確かめてから呼ぶ）
    if (event.index == 2) and event.unit.announceSkillDamage then event.unit:announceSkillDamage(3, 0.25, 3) end
    return 1
end


class:publish();

return class;