local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="魔導見習バレンティア", version=1.3, id="mine_10035"})

function class:start(event)
    self.skillFlg = false;

    -- 開幕メッセージ
    self.START_MESSAGES = {
        {
            MESSAGE = self.TEXT.START_MESSAGE1,
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    -- 死亡時メッセージ
    self.DEAD_MESSAGES = {
        {
            MESSAGE = self.TEXT.DEAD_MESSAGE1,
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

   return 1;
end

function class:startWave(event)
    event.unit:addSP(100);
    event.unit:setRange_Max(1000);
    self:showMessages(event.unit,self.START_MESSAGES);
    return 1;
end

function class:update(event)
    if event.unit:getHP() > 0 and event.unit:getUnitState() ~= kUnitState_skill and self.skillFlg then
        self:escape(event.unit);
    end
    return 1;
end

function class:dead(event)
    if self.skillFlg then
        self:showMessages(event.unit,self.DEAD_MESSAGES);
    end
    return 1;
end

function class:takeSkill(event)
    self.skillFlg = true;
    return 1;
end

function class:escape(unit)
    unit:setHP(0);
end

function class:showMessages(unit,messages)
    for k,v in pairs(messages) do
        if v.ICON == nil then
            Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR);
        else
            Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR,v.ICON);
        end
    end
end

class:publish();

return class;