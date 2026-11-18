local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EP7_GB冥葬鎌妃神リリー", version=1.3, id="gb_720201"});
class:inheritFromEnemy("gbBossBase");

-- 背後の死神はユニットLuaのサブスケルトンで出しているため同じ処理を入れる
function class:GB_start(event)
    event.unit:addSubSkeleton("100655512_Reaper",-3);
    event.unit:takeAnimation(0,"first",true);
end

class:publish();

return class;
