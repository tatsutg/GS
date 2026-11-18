local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超襲来待機ギンゾウ", version=1.3, id=2037802});
class:inheritFromEnemy("2037806");

function class:setMessageBoxList()

    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "影のシノビを撃破！",
            COLOR = Color.yellow
        })
    }

end

class:publish();

return class;