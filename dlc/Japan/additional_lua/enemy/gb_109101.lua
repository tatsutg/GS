local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="GB巨兵煌姫ファロン", version=1.3, id="gb_109101"});
class:inheritFromEnemy("gbBossBase");

---------------------------------------------------------------------------------
-- GB_start
---------------------------------------------------------------------------------
function class:GB_start(event)
    self.isPlayer = event.unit:getisPlayer();
    return;
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

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "aim" then
        return self:aim(event.unit)
    end
    if event.spineEvent == "explode" then
        return self:explode(event.unit)
    end
    if event.spineEvent == "shot" then
        return self:shot(event.unit)
    end
    return 1;
end

function class:aim(unit)
    unit:setPosition(unit:getPositionX(),unit:getPositionY()+150);
    local tgt = unit:getTargetUnit();
    if tgt == nil then
        return 0;
    end
    local deg = self:getDeg(unit:getPositionX(),unit:getPositionY(),tgt:getPositionX(),tgt:getPositionY()+50);
    if self.isPlayer == false then
        deg = 270 - deg - 90;
    end
    if deg < 0 then
        deg = 360 + deg;
    end

    print(deg);

    if deg <= 180 then
        return 1
    end

    if deg <= 190 then
        unit:takeAnimation(0,"Fire1",false);
    elseif deg <= 200 then
        unit:takeAnimation(0,"Fire2",false);
    elseif deg <= 210 then
        unit:takeAnimation(0,"Fire3",false);
    elseif deg <= 220 then
        unit:takeAnimation(0,"Fire4",false);
    elseif deg <= 230 then
        unit:takeAnimation(0,"Fire5",false);
    elseif deg <= 240 then
        unit:takeAnimation(0,"Fire6",false);
    else
        unit:takeAnimation(0,"Fire7",false);
    end
    return 1;
end

function class:explode(unit)
    local x = unit:getSkeleton():getBoneWorldPositionX("ExplodeCore");
    local y = unit:getSkeleton():getBoneWorldPositionY("ExplodeCore");
    if self.isPlayer then
        unit:setPosition(unit:getPositionX() + x,unit:getPositionY() + y);
    else
        unit:setPosition(unit:getPositionX() + x * -1,unit:getPositionY() + y);
    end
    return 1;
end

function class:shot(unit)
    local tama = unit:addOrbitSystem("Fire",1);
    tama:setHitCountMax(1);
    tama:setEndAnimationName("Explode")
    return 1;
end

class:publish();

return class;