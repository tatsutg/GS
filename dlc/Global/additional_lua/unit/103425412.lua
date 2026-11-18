local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="イスリーダ皇帝", version=1.8, id=103425412});
class:inheritFromUnit("103426412");

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        ---スカイライト---
        [1] = {
            ID = 103421,
            BUFF_ID = 32,---命中率
            VALUE = 30,
            DURATION = 15,
            ICON = 14,
            GROUP_ID = 3192,
            PRIORITY = 30
        },
        [4] = {
            ID = 10342,
            BUFF_ID = 17,
            VALUE = 150,
            DURATION = 20,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 17,
                VALUE1 = 7---神族
            },
            GROUP_ID = 1073,
            PRIORITY = 150
        },

        ---グランヴィス---
        [2] = {
            ID = 103422,
            BUFF_ID = 21,---被ダメ軽減
            VALUE = -20,
            DURATION = 15,
            ICON = 20,
            GROUP_ID = 6,
            PRIORITY = 20
        },
        [5] = {
            ID = 10342,
            BUFF_ID = 17,
            VALUE = 150,
            DURATION = 20,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 17,
                VALUE1 = 1---人族
            },
            GROUP_ID = 1073,
            PRIORITY = 150
        },

        ---ダークブリンガー---
        [3] = {
            ID = 103423,
            BUFF_ID = 13,---攻撃力
            VALUE = 50,
            DURATION = 15,
            ICON = 3,
            GROUP_ID = 1006,
            PRIORITY = 50
        },
        [6] = {
            ID = 10342,
            BUFF_ID = 17,
            VALUE = 150,
            DURATION = 20,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 17,
                VALUE1 = 8---魔族
            },
            GROUP_ID = 1073,
            PRIORITY = 150
        },

        ---バフ削除用
        [7] = {
            ID = 10342,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0
        }
    }
    self.ICON_BUFF_BOX_LIST = {
        ---アイコン用
        [1] = {
            ID = 103426412,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [2] = {
            ID = 103426412,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [3] = {
            ID = 103426412,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
    }
end

class:publish();

return class;