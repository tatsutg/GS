--@additionalEnemy,600000105
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_光耀竜フォスラディウス（弱）", version=1.3, id=600000103});
class:inheritFromEnemy("600000104");


function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下・クリティカル耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "パーティーの属性数が少ないほど、ボスの被ダメージアップ", COLOR = Color.yellow})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "光竜のダメージアップ", COLOR = Color.yellow})
    }
    self.GAUGE_ON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GAUGE_ON_MESSAGE1 or "シャイニングクライ:ダメージで解除", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.GAUGE_ON_MESSAGE2 or "シャイニングクライ:被ダメージ軽減・奥義上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.GAUGE_ON_MESSAGE3 or "シャイニングクライ:ボスが毒・病気・燃焼・暗闇状態のときダメージアップ", COLOR = Color.yellow})
    }
    self.GAUGE_OFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GAUGE_OFF_MESSAGE1 or "光竜がひるんでいる！", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.GAUGE_OFF_MESSAGE2 or "ボスの被ダメージ軽減解除", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.GAUGE_OFF_MESSAGE3 or "クリティカル耐性ダウン", COLOR = Color.yellow})
    }
    self.RETURN_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.RETURN_MESSAGE1 or "クリティカル耐性アップ", COLOR = Color.yellow})
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "ダークコロックが加勢した", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE2 or "ダークコロック：物理耐性", COLOR = Color.magenta})
    }
end

function class:enemySummon(unit,subBarCount)
    local Num = 0
    if subBarCount >= 4 then
        Num = subBarCount - 3
    end

    if Num >= 4 then
        Num = 4
    end

    if Num >= 1 then
        self:MultipleSummon(unit,600000105,Num)   --ダークコロック召喚
        self:showMessage(self.SUMMON_MESSAGE_LIST)
    end
end


class:publish();

return class;