local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ゴルネコゴッド", version=1.3, id="mine_10034"})

class.TIME_LIMIT = 20;
class.DEAD_DROP_SP = 800;

function class:start(event)
    self.timer = self.TIME_LIMIT;
    self.bonusFlg = true;

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
    self:showMessages(event.unit,self.START_MESSAGES);
    return 1;
end

function class:update(event)
    if event.unit:getHP() > 0 then
        if self.timer > 0 then
            self.timer = self.timer - event.deltaTime;
        else
            self:escape(event.unit);
        end
    end
    return 1;
end

function class:dead(event)
    if self.bonusFlg then
        event.unit:setDeadDropSp(self.DEAD_DROP_SP);
    else
        self:showMessages(event.unit,self.DEAD_MESSAGES);
    end
    return 1;
end

function class:escape(unit)
    unit:setHP(0);
    self.bonusFlg = false;
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