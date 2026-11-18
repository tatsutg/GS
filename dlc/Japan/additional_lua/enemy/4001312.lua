local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランガロード", version=1.3, id=4001312});

function class:start(event)
    event.unit:getSkeleton():setScaleX(1.5)
    event.unit:getSkeleton():setScaleY(1.5)
    summoner.Utility.messageByEnemy(self.TEXT.START_MESSAGE1 or "グランガロード：燃焼時被ダメージアップ", 7, Color:new(205,205,205));
    return 1
end

function class:takeSkill(event)
    if event.index == 2 then
        summoner.Utility.messageByEnemy(self.TEXT.SKILL_MESSAGE1 or "ゼンリョクデ…イクゾ！", 5, Color:new(205,205,205));
    end
    return 1
end

function class:update(event)
    event.unit:setReduceHitStop(2,1)
    return 1
end

class:publish();

return class;
