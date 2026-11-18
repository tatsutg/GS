local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EP7_GB闇術師オグナード", version=2.5, id="gb_710101"});
class:inheritFromEnemy("gb_103401");

-- 処理は暗黒魔導(gb_103401)と同じで、オービット名だけユニット100403511用に差し替える
function class:GB_start(event)
    self.orbitNames = { magic = "2skill2magic", sword = "2skill2sword", attackStart = "2attack1sword", attackFinish = "2attack1explode" }
    self.targetUnitPos = { x = nil, y = nil }
    return;
end

class:publish();

return class;
