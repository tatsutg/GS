local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星6_氷塊砦オ＝ザグン", version=2.0, id="gb_900130011"});
class:inheritFromEnemy("gb_901030011");


function class:setSkillIDTbl()
    --星6 データskill_id
    self.skillIDs = {
        40001700,  --麻痺耐性
        40111500   --気絶耐性
    }
end


class:publish();

return class;