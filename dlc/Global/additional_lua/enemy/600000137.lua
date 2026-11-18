local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="レイド_HARD_ハイゴブル", version=2.6, id=600000137});
class:inheritFromEnemy("600000140");

---レイド_HARD_炎テネブディウス(600000132.Lua)の召喚用


function class:setVariables(unit)
    --ダメージ補正関係
    self.targetElement = 1;  --炎属性
    self.targetDmgRate = 0.1;
    --召喚回数ステータス補正
    self.setHPFlg = true;
    self.nowHP = unit:getCalcHPMAX();
    self.buffID = 600133100;
end


class:publish();

return class;