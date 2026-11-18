local class = summoner.IdleGameEventDispatcher.createIdleGameClass({label="idleGame 星4ファロン", version=1.0, id="idleGame_100414112"});
class:inherit("idleGameBase")
-- event {unit,index}
function class:takeAttack(event)
    event.unit:setNextAnimationName("attack1");
    event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-attack1");
    return 1;
end

-- event {unit,index}
function class:run(event)
    if event.spineEvent == "shot" then
        local tama = event.unit:IG_addOrbitSystem("Fire",1);
        tama:setHitCountMax(1);
        tama:setEndAnimationName("Explode")
    end
    if event.spineEvent == "aim" then
        event.unit:setPosition(event.unit:getPositionX(),event.unit:getPositionY()+150);
        local tgt = event.unit:getTargetAlbumUnit();
        if tgt == nil then
            return 0;
        end
        local deg = self:getDeg(event.unit:getPositionX(),event.unit:getPositionY(),tgt:getPositionX(),tgt:getPositionY()+50);
        if event.unit:getisPlayer() == false then
            deg = 270 - deg - 90;
        end
        if deg < 0 then
            deg = 360 + deg;
        end

        if deg <= 180 then
            return 1
        end

        if deg <= 190 then
            event.unit:takeAnimation(0,"Fire1",false);
        elseif deg <= 200 then
            event.unit:takeAnimation(0,"Fire2",false);
        elseif deg <= 210 then
            event.unit:takeAnimation(0,"Fire3",false);
        elseif deg <= 220 then
            event.unit:takeAnimation(0,"Fire4",false);
        elseif deg <= 230 then
            event.unit:takeAnimation(0,"Fire5",false);
        elseif deg <= 240 then
            event.unit:takeAnimation(0,"Fire6",false);
        else
            event.unit:takeAnimation(0,"Fire7",false);
        end
    end
    if event.spineEvent == "explode" then
        local x = event.unit:getSkeleton():getBoneWorldPositionX("ExplodeCore");
        local y = event.unit:getSkeleton():getBoneWorldPositionY("ExplodeCore");
        if event.unit:getisPlayer() then
            event.unit:setPosition(event.unit:getPositionX() + x,event.unit:getPositionY() + y);
        else
            event.unit:setPosition(event.unit:getPositionX() + x * -1,event.unit:getPositionY() + y);
        end
    end
    return 1;
end

function class:getDeg(startx,starty,targetx,targety)
    return self:radToDeg(self:getRad(startx,starty,targetx,targety))

end

function class:getRad(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx)
end

function class:degToRad(deg)
    return deg * 3.14/180;
end

function class:radToDeg(rad)
    return rad * 180/3.14;
end

class:publish();
return class;
