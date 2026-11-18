local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EP7_GB EDEN", version=1.3, id="gb_701301"});
class:inheritFromEnemy("gbBossBase");

-- 通常攻撃の追尾弾はユニットLua(100593412)の処理を移植

local function getDeg(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx) * 180/3.14;
end

local function degToRad(deg)
    return deg * 3.14/180;
end

local function bulletControll(bulletinstance)
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local sp = 1;
    local speedOrigin = 1;

    if framecnt == 0 then
        bulletinstance.angle = math.random(360);
        bulletinstance.speedkeisuu = math.random(100,130)/100;
        sp = speedOrigin;
        bulletinstance.posx = currentbullet:getPositionX();
        bulletinstance.posy = currentbullet:getPositionY();
    end

    bulletinstance.frame = bulletinstance.frame + 1 * unitManagerDeltaTime/0.016666667;

    if framecnt <= 1 then

    elseif framecnt < 30 then
        sp = 1 + math.abs(30 - framecnt)/30 * speedOrigin*3;
    end
    if framecnt < 600 then
        sp = 2;
        local bullettarget = megast.Battle:getInstance():getTeam(not bulletinstance.isPlayer):getTeamUnit(bulletinstance.targetUnit);
        if bullettarget ~= nil then
            local targetangle = getDeg(currentbullet:getPositionX(),currentbullet:getPositionY(),bullettarget:getPositionX(),bullettarget:getPositionY());
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
                local maxdir = 1 * unitManagerDeltaTime/0.016666667;
                if dir > maxdir then
                    dir = maxdir;
                elseif dir < -maxdir then
                    dir = -maxdir;
                end
                bulletinstance.angle = bulletinstance.angle + dir;
            end
        end
    else
        currentbullet:takeAnimation(0,"hit",false);
    end

    local speed = sp * unitManagerDeltaTime/0.016666667;
    local rad = degToRad(bulletinstance.angle);
    bulletinstance.posx = bulletinstance.posx + math.cos(rad)*speed;
    bulletinstance.posy = bulletinstance.posy + math.sin(rad)*speed;
    currentbullet:setPosition(bulletinstance.posx,bulletinstance.posy);
end

function class:GB_start(event)
    self.bullets = {};
end

function class:GB_update(event)
    for i = 1,table.maxn(self.bullets) do
        bulletControll(self.bullets[i]);
    end
end

---------------------------------------------------------------------------------
-- endWave
---------------------------------------------------------------------------------
function class:endWave(event)
    for i = 1,table.maxn(self.bullets) do
        self.bullets[i].bullet:takeAnimation(0,"hit",false);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "shot" then return self:shot(event.unit) end
    if event.spineEvent == "onDestroy" then return self:onDestroy(event.unit) end
    return 1;
end

function class:shot(unit)
    --ターゲット不在なら球は出せない
    if unit:getTargetUnit() == nil then
        return 0;
    end

    local shot = unit:addOrbitSystem("3shine",1)
    local oneShotRate = 1/2
    shot:setDamageRateOffset(oneShotRate * 6)
    shot:setBreakRate(oneShotRate)
    shot:setHitCountMax(1)
    shot:setEndAnimationName("hit")
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local yb = unit:getSkeleton():getBoneWorldPositionY("EF_spack");
    shot:setPosition(x,y+yb);
    shot:takeAnimation(0,"3shine",true);

    table.insert(self.bullets,{
        bullet = shot,
        targetUnit = unit:getTargetUnit():getIndex(),
        frame = 0,
        angle = 0,
        posx = 0,
        posy = 0,
        speedkeisuu = 1,
        isPlayer = unit:getisPlayer()
    });
    return 1;
end

function class:onDestroy(unit)
    local atari = 0;
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i].bullet == unit then
            atari = i
        end
    end
    if atari ~= 0 then
        table.remove(self.bullets,atari);
    end
    return 1;
end

class:publish();

return class;
