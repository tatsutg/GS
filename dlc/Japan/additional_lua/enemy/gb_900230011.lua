local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星9_氷塊砦オ＝ザグン", version=2.0, id="gb_900230011"});
class:inheritFromEnemy("gb_901030011");


function class:setSkillIDTbl()
    --星9 データskill_id
    self.skillIDs = {
        40002200,  --麻痺耐性
        40112000   --気絶耐性
    }
end


class:publish();

return class;