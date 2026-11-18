local class = summoner.Bootstrap.createUnitClass({label="りゅーこ", version=1.5, id=102216112});

--バフカウンター配列


class.BUFF_ID = 10220;





function class:run(event)
    if event.spineEvent == "addOrbit" then
        self:addOrbit(event.unit,"skill2_font");
    end
    if event.spineEvent == "addOrbit2" then
        self:addOrbit(event.unit,"skill3_font");
    end
    return 1;
end

function class:addOrbit(unit,animationName)
    local orbit = unit:addOrbitSystemCamera(animationName,0);
    if not unit:getisPlayer() then
        orbit:getSkeleton():setScaleX(-1);
    end
end



class:publish();

return class;
