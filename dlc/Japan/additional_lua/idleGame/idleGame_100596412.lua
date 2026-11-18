local class = summoner.IdleGameEventDispatcher.createIdleGameClass({label="idleGame 覚醒EDEN", version=1.0, id="idleGame_100596412"});
class:inherit("idleGameBase")
local json = summoner.Json;

-- event {unit, instance }
--SpineがAddChildされた直後に呼ばれる
function class:start(event)
    self.bulletCount = 0
    self.bullets = {}
    self.gameUnit = event.unit;
end

function class:waveEndUnit(event)
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i] then
            self.bullets[i].bullet:setEndAnimationName("");
            self.bullets[i].bullet:takeAnimation(0,"hit",false);
        end
    end
end

-- event {unit,index}
function class:run(event)
    if event.spineEvent == "shot" then self:shot(event.unit) end
    if event.spineEvent == "onDestroy" then self:onDestroy(event.unit) end
    return 1;
end

function class:shot(unit)
    --ターゲット不在なら球は出せない
    if unit:getTargetAlbumUnit() == nil then
        return 0;
    end
    self.bulletCount = self.bulletCount + 1
    if self.bulletCount > 12 then
        self.bulletCount = 1
    end
    local shot = unit:IG_addOrbitSystem("4shine",1)
    shot:setParameter("shotNumber",""..self.bulletCount)
    shot:setHitCountMax(1)
    shot:setEndAnimationName("hit")
    shot:setDamageRateOffset(1/4)
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = unit:getSkeleton():getBoneWorldPositionX("EF_spack");
    local yb = unit:getSkeleton():getBoneWorldPositionY("EF_spack");
    shot:setPosition(x,y+yb);
    shot:takeAnimation(0,"3shine",true);
    local tama = self:setBulletInfo(shot,unit:getTargetAlbumUnit():getIndex(),0);
    tama.isPlayer = unit:getisPlayer();
    ---初期化
    if self.bullets[self.bulletCount] ~= nil then
        self.bullets[self.bulletCount].bullet:takeAnimation(0,"hit",false);
    end
    self.bullets[self.bulletCount] = tama;
end

function class:setBulletInfo(_bullet,_targetUnit,_uniqueID)
    local bulletInfo = {
        bullet = _bullet,
        targetUnit = _targetUnit,
        uniqueID = _uniqueID,
        frame = 0,
        angle = 0,
        posx = 0,
        posy = 0,
        speedkeisuu = 1,
        isPlayer = false
    }
    return bulletInfo
end

-- event {unit,index}
function class:takeAttack(event)
    print("takeAttackPlayer");
    event.unit:setNextAnimationName("attack1");
    event.unit:setNextAnimationEffectName("4-attack1");
    return 1;
end

-- event {unit, instance,deltaTime}
function class:updateUnit(event)
    for i = 1,12 do
        if self.bullets[i] then
            self:bulletControll(self.bullets[i]);
        end
    end
end

function class:bulletControll(bulletinstance)
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local sp = 1;
    local speedOrigin = 1;

    if framecnt == 0 then

        local rand = math.random(360);
        bulletinstance.angle = rand;
        bulletinstance.speedkeisuu = math.random(100,130)/100;
        sp = speedOrigin;
        bulletinstance.posx = bulletinstance.bullet:getPositionX();
        bulletinstance.posy = bulletinstance.bullet:getPositionY();
    end
    bulletinstance.frame = bulletinstance.frame + 1 * IdleGameManagerDeltaTime/0.016666667;

    if framecnt <= 1 then


    elseif framecnt < 30 then
        sp = 1 + math.abs(30 - framecnt)/30 * speedOrigin*3;
    end
    if framecnt < 600 then
        sp = 2;
        local bullettarget = self.gameUnit:getTargetAlbumUnit();
        if bullettarget ~= nil then
            local targetangle = self:getDeg(currentbullet:getPositionX(),currentbullet:getPositionY(),bullettarget:getPositionX(),bullettarget:getPositionY());
            if targetangle < 0 then
                targetangle = 360 + targetangle;
            end

            local dir = targetangle - bulletinstance.angle;

            if dir > 180 then
                dir = -(360 - dir);
            end

            if dir < -180 then
                dir = (360 - dir);
            end
            if dir ~= 0 then
                local maxdir = 1 * IdleGameManagerDeltaTime/0.016666667;
                if dir > maxdir then
                    dir = maxdir;
                elseif dir < -maxdir then
                    dir = -maxdir;
                end
                bulletinstance.angle = bulletinstance.angle + dir;
            end
        end
    else
        bulletinstance.bullet:takeAnimation(0,"hit",false);
        --self:onDestroy(bulletinstance.bullet)
    end
    self:moveByFloat(bulletinstance,self:calcXDir(self:degToRad(bulletinstance.angle),sp * IdleGameManagerDeltaTime/0.016666667),self:calcYDir(self:degToRad(bulletinstance.angle),sp * IdleGameManagerDeltaTime/0.016666667));
end

function class:onDestroy(unit)
    local number = tonumber(unit:getParameter("shotNumber"))
    if number ~= 0 then
        self.bullets[number] = nil;
    end
end

function class:calcXDir(rad,speed)
    return math.cos(rad)*speed;
end

function class:calcYDir(rad,speed)
    return math.sin(rad)*speed;
end

function class:move(node,movex,movey)
    node:setPosition(node:getPositionX()+movex,node:getPositionY()+movey);
    return 1;
end

function class:moveByFloat(_bulletinstance,xdistance,ydistance)
    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;
    return true;
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
