--@additionalEnemy,600000094
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド蒼機士(弱)", version=1.3, id=600000092});
class:inheritFromEnemy("600000093");

--------[[バフ]]--------
function class:setBuffBoxList()
    self.STUN_BUFF_LIST = {
        ID = 600000931,
        BUFF_ID = 89,
        VALUE = 100,
        DURATION = 99999,
        ICON = 79
    }
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 600000933,
            BUFF_ID = 31,---回避率UP
            VALUE = 90,
            DURATION = 99999,
            ICON = 16
        },
        [2] = {
            ID = 600000934,
            BUFF_ID = 23,---クリティカル耐性
            VALUE = -150,
            DURATION = 99999,
            ICON = 188
        },
        [3] = {
            ID = 600000935,
            BUFF_ID = 89,
            VALUE = 100,
            DURATION = 10,
            ICON = 79
        },
        [4] = {
            ID = 600000936,
            BUFF_ID = 17,
            VALUE = 20,
            DURATION = 99999,
            ICON = 26,
            MAX = 10
        },
        [5] = {
            ID = 6000000937,
            BUFF_ID = 22,--- クリティカル率
            VALUE = 10,
            DURATION = 99999,
            ICON = 11,
            MAX = 10
        }
    }
end

class:publish();

return class;