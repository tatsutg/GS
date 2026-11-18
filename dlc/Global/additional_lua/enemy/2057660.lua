local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX1_エレノア", version=1.3, id=2057660});
class:inheritFromEnemy("2057665");

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

class.cutInSkill = {
    [3] = 1
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "授業を始めるよん♪", COLOR = Color.green})
    }
    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "仲良くしない子は教育的指導ー！", COLOR = Color.green})
    }
    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "自習の時間にしまーす", COLOR = Color.green})
    }
end

function class:hp50(status)
    if status == "use3" then
        self.gameUnit:addSP(100)
        self.hpSkill = 3
        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_smallclock" then
        local sClock = event.unit:addOrbitSystemCamera("smallclock",0)
        if not event.unit:getisPlayer() then
            sClock:getSkeleton():setScaleX(-1);
        end
    end
    if event.spineEvent == "Library_clock" then
        local hour = string.format( "%02d", self.clockTime )---0埋め
        local clock = event.unit:addOrbitSystemCamera("clock"..hour,0)
        if not event.unit:getisPlayer() then
            clock:getSkeleton():setScaleX(-1);
        end
    end
    return 1
end


class:publish();

return class;