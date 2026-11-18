local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒デミウルゴス", version=1.3, id=107917112});

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill3_orbit" then
        if self.skill3orbit == nil then
            self.skill3orbit = event.unit:addOrbitSystem("skill3_orbit",0)
            self.skill3orbit:setChainAnimationData(0,"empty","skill3_orbit",true)
        else
            self.skill3orbit:takeAnimation(0,"skill3_orbit",true);
        end
    end
    return 1
end

class:publish();

return class;