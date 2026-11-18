local class = summoner.Bootstrap.createUnitClass({label="初音ミク", version=1.9, id=107456212});

function class:run(event)
    if event.spineEvent == "BGM" then
		-- BGM再生
		BattleControl:get():playBGMOneShot("MIKU_SHORT_MELT")
    end
    return 1
end

function class:start(event)
    self.isSkill3 = false
    return 1
end

function class:update(event)
    if self.isSkill3 then
        event.unit:setReduceHitStop(2,1)
    end
    return 1
end

function class:excuteAction(event)
    self.isSkill3 = false
    return 1
end

function class:takeAttack(event)
    self.isSkill3 = false
    return 1
end

function class:takeSkill(event)
    self.isSkill3 = false
    if event.index == 3 then
        self.isSkill3 = true
    end
    return 1
end

class:publish();

return class;
