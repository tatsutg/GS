local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超襲来ギンゾウ＜陣備え＞", version=1.3, id=2037804});
class:inheritFromEnemy("2037808");

function class:setMessageBoxList()

    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "…………　……",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性"
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "光属性キラー"
        })
    }

    self.HP70_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP70_MESSAGE1 or "……　……　……",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP70_MESSAGE2 or "編成の左2人で影のシノビに挑め！",
            COLOR = Color.yellow
        })
    }

    self.HP40_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE1 or "……　…………　……　……",
            COLOR = Color.magenta
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE2 or "編成の右2人で影のシノビに挑め！",
            COLOR = Color.yellow
        })
    }

    self.HP20_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP20_MESSAGE1 or "カイガン状態：奥義上昇量アップ・ダメージ無効化無効"
        })
    }

end

function class:shinSetAura(unit)
    unit:addSP(100)
    self.hpSkill = 4
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"Kaigan2_in",true);
        return
    end
    self.aura = unit:addOrbitSystemWithFile("Kaigan6","Kaigan2_in");
    self.aura:takeAnimation(0,"Kaigan2_in",true);
    self:auraPosition(unit)
end

class:publish();

return class;