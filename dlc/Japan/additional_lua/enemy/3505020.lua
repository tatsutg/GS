local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="35章_EX1_焔神官カロン", version=2.5, id=3505020});
class:inheritFromEnemy("3505023");


function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "どれ、ゼルム様が相手してやろう", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "ヒョッヒョッヒョッ！", COLOR = Color.red})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "ワシの六魔将帥への道がぁあああ…！", COLOR = Color.red})
    }
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    for i = 1,3 do
        if event.spineEvent == "orbit"..i then
            local orbit = event.unit:addOrbitSystemWithFile("50017ef",event.spineEvent);
            orbit:setZOrder(99999);
            orbit:setPositionY(200);
            orbit:setPositionX(-215);
            orbit:setActiveSkill(i + 1);
        end
    end
    return 1;
end


class:publish();

return class;