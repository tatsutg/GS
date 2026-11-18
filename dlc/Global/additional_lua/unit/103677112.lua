local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒バレンタインプリシラ", version=1.3, id=103677112});

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "heart" then
        local heart = event.unit:addOrbitSystemInsightRotation("SHOT","HIT",1,-50,70,0,0)
        if event.unit:getUnitState() == kUnitState_attack then
            ---通常攻撃：attackDelay分の特殊系補正を入れる
            heart:setDamageRateOffset(event.unit:getAttackDelay());
        elseif event.unit:getUnitState() == kUnitState_skill then
            ---スキル：2ヒットなのでブレイク値を1/2にする
            heart:setBreakRate(1/2)
        end
    end

    if event.spineEvent == "skill5_orbit" then
        event.unit:addOrbitSystem("skill5_orbit",0)
    end
    return 1
end

class:publish();

return class;