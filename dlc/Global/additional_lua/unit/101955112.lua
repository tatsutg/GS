local class = summoner.Bootstrap.createUnitClass({label="ぼーげん", version=1.5, id=101955112});

function class:start(event)
    self.isVacuum = false;
    return 1;
end


function class:run(event)
    if event.spineEvent == "startVacuum" then
        self.isVacuum = true;
    end

    if event.spineEvent == "endVacuum" then
        self.isVacuum = false;
    end
    return 1;
end

function class:update(event)
    if self.isVacuum then
        self:excuteVacuum(event.unit,event.deltaTime);
    end
    return 1;
end

function class:excuteAction(event)
    self.isVacuum = false;
    return 1;
end

function class:takeDamage(event)
    self.isVacuum = false;
    return 1;
end

function class:excuteVacuum(unit,deltatime)
        for i = 0,6 do
        local targetUnit = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
        if targetUnit ~= nil then
            local targetx = targetUnit:getPositionX();
            local thisx = unit:getPositionX();
            local distance = thisx - targetx;
            local oneFrame = 0.016666666;
            local moveSpeed = 7 * deltatime/oneFrame;

            if distance == 0 then
                distance = 1;
            end
            
            targetUnit:setPosition(targetx + moveSpeed * distance/math.abs(distance),targetUnit:getPositionY());
        end
    end
end





class:publish();

return class;
