local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超ベリック(覚醒)", version=1.3, id=103636112});
class:inheritFromUnit("103637112");

function class:setSurfaceBoxList()
    self.beforeMD = 0
    self.afterMD = 1
    self.SURFACE_BOX_LIST = {
        [self.beforeMD] = {
            ACTIVE_SKILL = 3,
            VOICE = "VOICE_FULLARTS_CUTIN_B_01",
            SKILL_NAME = self.TEXT.BEFORE_MD or "マギアドライブ",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [self.afterMD] = {
            ACTIVE_SKILL = 3,
            VOICE = "VOICE_FULLARTS_CUTIN_B",
            SKILL_NAME = self.TEXT.AFTER_MD or "抜刀術・緋閃改",
            SE = "SE_BATTLE_040_UNIT_CALL"
        }
    }
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 103636112,
            BUFF_ID = 0, ---MDアイコンのみ
            VALUE = 0,
            DURATION = self.AURA_INTERVAL,
            ICON = 0
        }
    }
    self.SKILL_BUFF_BOX_LIST = {
        [1] = {
            ID = 1036300,
            BUFF_ID = 17, --物理ダメージUP
            VALUE = 150,
            DURATION = 20,
            ICON = 28,
            SCRIPT = {
                SCRIPT_ID = 4,  --物理攻撃
            },
            GROUP_ID = 1066,
            PRIORITY = 150
        }
    }
    self.ABILITY_BOX_LIST = {
        [1] = {
            ID = 1036301,
            BUFF_ID = 13, --攻撃力
            VALUE = 100,
            DURATION = self.AURA_INTERVAL,
            ICON = 3
        },
        [2] = {
            ID = 1036302,
            BUFF_ID = 17, -- 奥義ダメージUP
            VALUE = 300,
            DURATION = self.AURA_INTERVAL,
            ICON = 31,
            SCRIPT = {
                SCRIPT_ID = 58
            }
        },
        --追加効果
        [3] = {
            ID = 1036303,
            BUFF_ID = 10,  --奥義ゲージ自然上昇
            VALUE = 2,
            DURATION = self.AURA_INTERVAL,
            ICON = 36
        }
    }
end

class:publish();

return class;