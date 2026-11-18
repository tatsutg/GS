local class = summoner.Bootstrap.createUnitClass({label="でぃーゔぁ", version=1.3, id=4000442});

function class:start(event)
    self.skillCheckFlg = false;
    return 1;
end

function class:takeSkill(event)
 
    if event.index == 2 and not self.skillCheckFlg then
        self.skillCheckFlg = true;
        event.unit:takeSkillWithCutin(2);
        return 0;
    end
    self.skillCheckFlg = false;


    return 1
end

class:publish();

return class;