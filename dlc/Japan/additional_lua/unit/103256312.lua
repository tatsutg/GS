local class = summoner.Bootstrap.createUnitClass({label="変身グロイツ", version=2.2, id=103256312});


function class:startWave(event)
    if self:findWeapon(event.unit,50268600) then
        self.isWeapon = true
    end
    return 1
end

function class:findWeapon(unit,weaponId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
    return buff ~= nil
end

function class:takeTransIn(event)
    event.unit:addOrbitSystemWithFile("103256312transef","transin2")
    return 1
end

function class:takeTransOut(event)
    if self.isWeapon then
        self.endTrans = true
    end
    return 1
end

function class:update(event)
    if self.endTrans and event.unit:getNowTransTime() == 0 then
        self.endTrans = false
        event.unit:addSPWithPvpCorrection(50)
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "skill1orbit" then
        event.unit:addOrbitSystemWithFile("103256312transef","skill1Orbit")
        return 1
    end
    return 1
end

class:publish();

return class;
