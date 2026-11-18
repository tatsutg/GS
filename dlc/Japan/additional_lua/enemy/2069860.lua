local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="とある_インデックス(EX1)", version=2.4, id=2069860});
class:inheritFromEnemy("2069870");

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 206987001,
            BUFF_ID = 89,   -- 気絶効果
            VALUE = 100,
            DURATION = 1,
            ICON = 79,
            WEIGHT = 15,
        }
    }
end

class:publish();

return class;