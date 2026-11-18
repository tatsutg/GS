local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="覚醒ジエン", version=2.6, id=104256112});
class:inheritFromUnit("104257112");


function class:setSkillBuffBox()
    self.SKILL2_BOX_LIST = {
        [1] = {
            ID = 1042571123,  --炎属性ユニット以外
            BUFF_ID = 13,  --攻撃力
            VALUE = 30,
            DURATION = 25,
            ICON = 3,
            GROUP_ID = 1006,
            PRIORITY = 30
        },
        [2] = {
            ID = 1042571123,  --炎属性ユニット
            BUFF_ID = 13,  --攻撃力
            VALUE = 60,
            DURATION = 25,
            ICON = 3,
            GROUP_ID = 1006,
            PRIORITY = 60
        }
    }
    self.SKILL3_BOX_LIST = {
        [1] = {
            ID = 1042571124,
            BUFF_ID = 80,  --防御力無視
            VALUE = 100,
            DURATION = 20,
            ICON = 89,
            GROUP_ID = 3433,
            PRIORITY = 100
        },
        [2] = {
            ID = 1042571125,
            BUFF_ID = 17,  --与ダメ
            VALUE = 70,
            DURATION = 20,
            ICON = 28,
            GROUP_ID = 1066,
            PRIORITY = 70,
            SCRIPT = {
                SCRIPT_ID = 4
            }
        }
    }
end


class:publish();

return class;