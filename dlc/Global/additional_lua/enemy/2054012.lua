local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="七周年記念デイリークエスト超皇帝", version=1.3, id=2054012});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.skill2Flg = false
    self.weaponNum = 1
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.skill2Flg then
        self.skill2Flg = false
        self.weaponNum = self.weaponNum + 1
        if self.weaponNum > 3 then
            self.weaponNum = 1
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 2 then
        self.skill2Flg = true
        event.unit:setNextAnimationName("skill2_"..self.weaponNum)
        event.unit:setNextAnimationEffectName("2-skill2_"..self.weaponNum)
    elseif event.index == 3 then
        self.skill2Flg = false
    elseif event.index == 5 then
        self.skill2Flg = false
    end
    return 1
end

class:publish();

return class;