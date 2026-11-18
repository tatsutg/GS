local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星12_氷塊砦オ＝ザグン", version=2.0, id="gb_900530011"});
class:inheritFromEnemy("gb_901030011");


function class:setSkillIDTbl()
    --星12 データskill_id
    self.skillIDs = {
        60035200,  --麻痺耐性
        60035300   --気絶耐性
    }
end


class:publish();

return class;