local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="レイド_NORMAL_雷哮剣鬼ライザー", version=2.6, id=600000135});
class:inheritFromEnemy("600000141");

---レイド_NORMAL_炎テネブディウス(600000132.Lua)の召喚用


function class:setVariables(unit)
    --ダメージ補正関係
    self.targetElement = 4;  --光属性
    self.targetDmgRate = 0.3;
    --召喚回数ステータス補正
    self.setHPFlg = true;
    self.nowHP = unit:getCalcHPMAX();
    self.buffID = 600133100;
end


class:publish();

return class;