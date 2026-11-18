local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超ハズキ(覚醒)", version=1.3, id=103546412});
class:inheritFromUnit("103547412");

function class:setSurfaceBoxList()
    self.beforeMD = 0
    self.afterMD = 1
    self.beforeMD2 = 2
    self.SURFACE_BOX_LIST = {
        [self.beforeMD] = {
            ACTIVE_SKILL = 3,
            VOICE = "VOICE_FULLARTS_CUTIN_KAIGAN",
            SKILL_NAME = self.TEXT.BEFORE_MD or "カイガン",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        },
        [self.afterMD] = {
            ACTIVE_SKILL = 3,
            VOICE = "VOICE_FULLARTS_CUTIN_B",
            SKILL_NAME = self.TEXT.AFTER_MD or "異忍律急式「弦解」",
            SE = "SE_BATTLE_040_UNIT_CALL"
        },
        [self.beforeMD2] = {
            ACTIVE_SKILL = 3,
            VOICE = "VOICE_FULLARTS_CUTIN_SINKAIGAN",
            SKILL_NAME = self.TEXT.BEFORE_MD2 or "シンカイガン",
            SE = "SE_BATTLE_012_FULLARTS_SHOOT2"
        }
    }
end

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        ---タイマー用
        [1] = {
            ID = 1035271121,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = self.AURA_INTERVAL,
            ICON = 0
        },
        [2] = {
            ID = 1035271122,
            BUFF_ID = 17,   ---与ダメージ
            VALUE = 100,
            DURATION = self.AURA_INTERVAL,
            ICON = 26
        },
        [3] = {
            ID = 1035271123,
            BUFF_ID = 10, ---奥義ゲージ自然上昇
            VALUE = 5,
            DURATION = self.AURA_INTERVAL,
            ICON = 36
        },
        [4] = {
            ID = 1035271124,
            BUFF_ID = 13,   ---攻撃力
            VALUE = 100,
            DURATION = self.AURA_INTERVAL,
            ICON = 3
        },
        [5] = {
            ID = 1035271125,
            BUFF_ID = 32,---命中率
            VALUE = 100,
            DURATION = self.AURA_INTERVAL,
            ICON = 14
        },
        [6] = {
            ID = 1035271126,
            BUFF_ID = 17,---奥義ダメージアップ
            VALUE = 130,
            DURATION = 20,
            ICON = 31,
            SCRIPT = {
                SCRIPT_ID = 58
            },
            GROUP_ID  = 3430,
            PRIORITY = 130
        },
        [7] = {
            ID = 1035271127,
            BUFF_ID = 21,---被ダメージ軽減
            VALUE = -30,
            DURATION = 30,
            ICON = 20,
            GROUP_ID  = 6,
            PRIORITY = 30
        }
    }
end

function class:setAura(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"Kaigan_in",true);
        self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
        return
    end
    self.aura = unit:addOrbitSystemWithFile("Kaigan4","Kaigan_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"Kaigan_in",true);
    self:auraPosition(unit)
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
end

function class:shinSetAura(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"Kaigan2_in",true);
        self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
        return
    end
    self.aura = unit:addOrbitSystemWithFile("Kaigan4","Kaigan2_in");
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"Kaigan2_in",true);
    self:auraPosition(unit)
    self.loopStart1FLG = false---MD1オーラが出なかった場合のフラグ
end

class:publish();

return class;