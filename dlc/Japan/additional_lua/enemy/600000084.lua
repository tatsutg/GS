local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_天魔帥ゼ＝レムナ", version=1.3, id=600000084});
class:inheritFromEnemy("600000085");

--------[[バフ]]--------
function class:setBuffBoxList()
    self.STUN_BUFF_LIST = {
        [1] = {
            ID = 60008501,
            BUFF_ID = 89,  --気絶効果
            VALUE = 100,
            DURATION = 99999,
            ICON = 79
        },
        [2] = {
            ID = 60008501,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [3] = {
            ID = 0,
            BUFF_ID = 89,  --気絶効果
            VALUE = 100,
            DURATION = 3,
            ICON = 79
        }
    }
    self.DAMAGE_BUFF_LIST = {
        [1] = {
            ID = 60008502,
            BUFF_ID = 129,  --継続ダメージ
            VALUE = 2,
            DURATION = 99999,
            ICON = 180,
            SCRIPT = {
                SCRIPT_ID = 228
            }
        },
        [2] = {
            ID = 60008502,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }
    self.BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 13,  --攻撃力割合
            VALUE = -50,
            DURATION = 10,
            ICON = 4
        }
    }
end

class:publish();

return class;