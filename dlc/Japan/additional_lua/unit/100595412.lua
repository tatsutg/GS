function new(id)
    print("100595412 new ");
    local instance = {

        myself = nil,
        target = nil,
        bullets = {},
        bulletinfo = {
            new = function (_bullet,_targetUnit,_uniqueID)
                return {
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
            end
        },

        shot = function(this,unit)
            --ターゲット不在なら球は出せない
            if unit:getTargetUnit() == nil then
                return 0;
            end
            
            local shot = unit:addOrbitSystem("3shine",1)
            local oneShotRate = 1/4
            shot:setDamageRateOffset(oneShotRate * 6)
            shot:setBreakRate(oneShotRate)
            shot:setHitCountMax(1)
            shot:setEndAnimationName("hit")
            -- shot:EnabledFollow = true;
            local x = unit:getPositionX();
            local y = unit:getPositionY();
            local xb = unit:getSkeleton():getBoneWorldPositionX("EF_spack");
            local yb = unit:getSkeleton():getBoneWorldPositionY("EF_spack");
            shot:setPosition(x,y+yb);
            shot:takeAnimation(0,"3shine",true);
            local tama = this.bulletinfo.new(shot,unit:getTargetUnit():getIndex(),0);
            tama.isPlayer = unit:getisPlayer();
            table.insert(this.bullets,tama)

            return 1;
        end,

        onDestroy = function (this,unit)
            local  atari = 0;
            for i = 1,table.maxn(this.bullets) do
                if this.bullets[i].bullet == unit then
                    atari = i
                end

            end
            if atari ~= 0 then
                table.remove(this.bullets,atari);
            end
            return 1;
        end,

        --共通変数
        param = {
          version = 1.2
          ,isUpdate = 1
        },

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "shot" then return this.shot(this,unit) end
            if str == "onDestroy" then return this.onDestroy(this,unit) end
            return 1;
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            for i = 1,table.maxn(this.bullets) do
                this.bullets[i].bullet:takeAnimation(0,"hit",false); 
            end
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            if table.maxn(this.bullets) > 0 then
                for i = 1,table.maxn(this.bullets) do
                    bulletControll100595412(this.bullets[i]);
                end
            end
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        --version1.0
        start = function (this , unit)
            return 1;
        end,

        excuteAction = function (this , unit)
            return 1;
        end,

        takeIdle = function (this , unit)
            return 1;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
         
            return 1;
        end,

        takeAttack = function (this , unit , index)
            return 1;
        end,

        takeSkill = function (this,unit,index)
            return 1;
        end,

        takeDamage = function (this , unit)
            return 1;
        end,

        dead = function (this , unit)
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end


function getDeg(startx,starty,targetx,targety)
    return radToDeg(getRad(startx,starty,targetx,targety))

end

function getRad(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx)
end

function degToRad(deg)
    return deg * 3.14/180;
end

function radToDeg(rad)
    return rad * 180/3.14;
end

function bulletControll100595412(bulletinstance)
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
       bulletinstance.bullet:takeAnimation(0,"hit",false);  
    end
    
    moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp * unitManagerDeltaTime/0.016666667),calcYDir(degToRad(bulletinstance.angle),sp * unitManagerDeltaTime/0.016666667));   
end

function calcXDir(rad,speed)
    return math.cos(rad)*speed;
end

function calcYDir(rad,speed)
    return math.sin(rad)*speed;
end

function move(node,movex,movey)
    node:setPosition(node:getPositionX()+movex,node:getPositionY()+movey);
    return 1;
end

function moveByFloat(_bulletinstance,xdistance,ydistance)
    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;
    return true;
end

