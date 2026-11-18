local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ラビッツ4_デイリーEX_アリステラ・オルビス", version=2.5, id=2075191});
class:inheritFromUnit("unitBossBase");

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if string.find(event.spineEvent,"10368ice_") ~= nil then
        local strN = string.sub(event.spineEvent,10)
        local num = tonumber(strN)
        if num ~= nil then
            local ice = event.unit:addOrbitSystemInsightRotation("SHOT","HIT",1,-50,num,0,0)
            if event.unit:getUnitState() == kUnitState_attack then
                ---通常攻撃：attackDelay分の特殊系補正を入れる
                ice:setDamageRateOffset(event.unit:getAttackDelay());
            elseif event.unit:getUnitState() == kUnitState_skill then
                ---スキル：4ヒットなのでダメージ・ブレイク値を1/4にする
                ice:setDamageRateOffset(0.25)
                ice:setBreakRate(1/4)
            end
        end
    end
    return 1
end

class:publish();

return class;