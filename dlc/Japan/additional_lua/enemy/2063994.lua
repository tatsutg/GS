--@additionalEnemy,2063991, 2063992, 2063993
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="神族の遺跡_10層_NORMAL_タイマー用", version=2.5, id=2063994});
class:inheritFromEnemy("2063999");

function class:setIDs(event)
    self.summonEnemyID1 = 2063991;  --Normal/ハイゴブル
    self.summonEnemyID2 = 2063992;  --Normal/ブルースケルトン
    self.summonEnemyID3 = 2063993;  --Normal/ハーモナー
    return 1
end

class:publish()
return class