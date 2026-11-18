local Vector2 = summoner.import("Vector2")
local class = summoner.Bootstrap.createUnitClass({label="エリザベス", version=1.3, id=103396112});

function class:start(event)
    self.bulletList = {}
    self.SPEED = 3.5
    self.RADIUS = 140
    self.SEED_VEC = {}
    self:createSeed(self.RADIUS)
    return 1
end

function class:createSeed(radius)
    for i = 1,5 do
        local a = (360/5)*i+18
        self.SEED_VEC[i]={
            x = math.cos((math.pi/180) * a ) * radius,
            y = math.sin((math.pi/180) * a ) * radius
        }
    end
end

function class:run(event)
    if event.spineEvent == "skill3" then
        local bullet = {}
        for i = 1,5 do
            bullet[i] = {
                unit = nil,
                pos = 0,
                target = 0,
                dis = 0,
                time = 0
            }
            self:setAura(event.unit,bullet[i],self.SEED_VEC[i])
            bullet[i].status = 2
        end
        table.insert(self.bulletList,{bullets = bullet,status = 2,isMove = false})
    end

    if event.spineEvent == "loopStart" then
        for _,v in ipairs(self.bulletList) do
            if v.status == 2 then
                for i = 1,5 do
                    v.bullets[i].unit:takeAnimation(0,"skill3_orbit_loop",true);
                    v.bullets[i].isMove = true
                end
                v.status = 3
                v.isMove = true
                return 1
            end
        end
    end
    if event.spineEvent == "toEnd" then
        for _,v in ipairs(self.bulletList) do
            if v.status == 3 and not v.isMove then
                for i = 1,5 do
                    v.bullets[i].unit:takeAnimation(0,"skill3_orbit_end",false);
                end
            end
            v.status = 4
            return 1
        end
    end
    if event.spineEvent == "end" then
        for _,v in ipairs(self.bulletList) do
            if v.status == 4 then
                for i = 1,5 do
                    v.bullets[i].unit = nil;
                end
            end
            v.status = 5
            return 1
        end
    end
    return 1
end

function class:update(event)
    if self.bulletList ~= nil then
        for _,v in ipairs(self.bulletList) do
            for i = 1,5 do
                if v.bullets[i].isMove then
                    self:movePos(v.bullets[i],v)
                end
            end
        end
    end
    return 1
end

function class:movePos(bullet,bulletList)
    if bullet.unit ~= nil and bullet.isMove then
        local distance = Vector2.subtracts(bullet.target,bullet.pos)
        if self.SPEED >= math.abs(distance.magnitude)then
            bullet.pos = bullet.pos + distance
            bullet.unit:takeAnimation(0,"skill3_orbit_stay",false)
            bullet.isMove = false
            bulletList.isMove = false
        else
            bullet.pos = bullet.pos + (distance:normalize() * self.SPEED)
        end
        bullet.unit:setPosition(bullet.pos.x,bullet.pos.y)
    end
end

function class:setAura(unit,bullet,round)
    bullet.unit = unit:addOrbitSystemWithFile("10339ef","skill3_orbit_in");
    bullet.unit:takeAnimation(0,"skill3_orbit_in",true);
    bullet.unit:setDamageRateOffset(1/5)
    bullet.unit:setBreakRate(1/5)

    local xb = unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local yb = unit:getSkeleton():getBoneWorldPositionY("MAIN");
    local xr = round.x
    local yr = round.y
    local vec = unit:getisPlayer() and 1 or -1

    bullet.pos = Vector2:new(unit:getPositionX() + xb + xr,unit:getPositionY() + yb + yr)
    bullet.unit:setPosition(bullet.pos.x,bullet.pos.y);
    bullet.target = Vector2:new((bullet.pos.x-200 + math.random(-100,40)) * vec,bullet.pos.y-310+ math.random(-40,30))
end

class:publish();

return class;