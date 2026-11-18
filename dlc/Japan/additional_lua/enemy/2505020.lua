local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX1_超シーリア", version=2.0, id=2505020});
class:inheritFromEnemy("2505021");

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 103550,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 30,
            ICON = 0
        },
        [2] = {
            ID = 103551,
            BUFF_ID = 17,
            VALUE = 20,
            DURATION = 99999,
            ICON = 26,
            MAX = 30
        }
    }
    self.BUFF_LIST = {
        [1] = {
            ID = 25050200,
            BUFF_ID = 15, --防御力UP
            VALUE = 10,
            DURATION = 999999,
            ICON = 5,
            COUNT = 0,
            MAX = 4
        }
    }
end



class:publish();

return class;