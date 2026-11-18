function new(id)
    print("105141193 new ");    --sx602進化前
    local instance = {
        --共通変数
        param = {
          version = 1.2
          ,isUpdate = 1
        },

        bullets = {},
        bulletsIDCounter = 0,
        bulletinfo = {
            new = function (_bullet,_targetUnit,_uniqueID)
                return {
                    bullet = _bullet,
                    targetUnit = _targetUnit,
                    uniqueID = _uniqueID,
                    frame = 0,
                    posx = 0,
                    posy = 0,
                    limitx = 0,
                    limity = 0,
                    parent = _bullet:getTeamUnit(),
                    yield = true
                }
            end
        },

        lock = function (this,unit)

            local lock = unit:addOrbitSystem("LockOn")
            lock:setHitCountMax(1)
            local x = unit:getPositionX()
            local y = unit:getPositionY()
            lock:setPosition(x-100,y)
            local tama = this.bulletinfo.new(lock,unit:getTargetUnit():getIndex(),0)

            table.insert(this.bullets,tama)
            return 1;
        end,


        lockCompleat = function (this,unit)
            local  atari = 1
            for i = 1,table.maxn(this.bullets) do
                    print("Destroy on lock compleat")
                    if this.bullets[i].bullet == unit then
                        this.bullets[i].yield = false;
                    end

                end
            return 1;
        end,

        explosion = function (this,unit)
            local  atari = 0
            local  x = 0;
            local  y = 0;
            for i = 1,table.maxn(this.bullets) do
                
                if this.bullets[i].bullet == unit then
                    atari = i
                end

            end
            print(atari);
            if atari == 0 then
                return 0;
            end
            local explode = unit:getTeamUnit():addOrbitSystem("Explode");
                x = unit:getPositionX();
            local target = explode:getTargetUnit();
            if target ~= nil then
                y = target:getPositionY();
            end
            explode:setPosition(x,y);
            return 1;
        end,

        missile = function (this,unit)
            print("missile");
            local  atari = 0
            for i = 1,table.maxn(this.bullets) do
                
                if this.bullets[i].bullet == unit then
                    atari = i
                end

            end
            print(atari);
            if atari == 0 then
                return 0;
            end
            local  parentx = unit:getTeamUnit():getPositionX();
            local  parenty = unit:getTeamUnit():getPositionY();
            local  thisx = unit:getPositionX();
            local thisy = unit:getPositionY();
            local distance = thisx - parentx;
            local hight = thisy - parenty;
            local miso = nil;

            if not unit:getTeamUnit():getisPlayer() then
                distance = distance * -1;
            end

            print(distance);
            if distance >= -128 then
                miso = unit:getTeamUnit():addOrbitSystem("Missile0");
            elseif distance >= -192 then
                miso = unit:getTeamUnit():addOrbitSystem("Missile1");
            elseif distance >= -256 then
                miso = unit:getTeamUnit():addOrbitSystem("Missile2");
            elseif distance >= -320 then
                miso = unit:getTeamUnit():addOrbitSystem("Missile3");
            elseif distance >= -384 then
                miso = unit:getTeamUnit():addOrbitSystem("Missile4");
            elseif distance >= -448 then
                miso = unit:getTeamUnit():addOrbitSystem("Missile5");
            elseif distance >= -512 then
               miso = unit:getTeamUnit():addOrbitSystem("Missile6");
            elseif distance >= -576 then
                miso = unit:getTeamUnit():addOrbitSystem("Missile7");
            elseif distance >= -640 then
                miso = unit:getTeamUnit():addOrbitSystem("Missile8");
            elseif distance >= -704 then
                miso = unit:getTeamUnit():addOrbitSystem("Missile9");
            else
                miso = unit:getTeamUnit():addOrbitSystem("Missile10");
            end

            if not(miso == nil) then
                if unit:getTeamUnit():getisPlayer() then
                    miso:setPosition(parentx+distance%64,parenty+hight);
                else
                    miso:setPosition(parentx-distance%64,parenty+hight);
                end
            end

            return 1;

        end,

        onDestroy = function (this,unit)
            local  atari = 1
             for i = 1,table.maxn(this.bullets) do
                    print("onDestroy")
                    if this.bullets[i].bullet == unit then
                        atari = i
                    end

                end
                table.remove(this.bullets,atari);
            return 1;
        end,

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
            if str == "lock" then return this.lock(this,unit) end
            if str == "lockCompleat" then return this.lockCompleat(this,unit) end
            if str == "explosion" then return this.explosion(this,unit) end
            if str == "missile" then return this.missile(this,unit) end
            if str == "onDestroy" then return this.onDestroy(this,unit) end
            return 1;
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            if table.maxn(this.bullets) > 0 then
                for i = 1,table.maxn(this.bullets) do
                    bulletControll(this.bullets[i]);
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
            local  atari = 1
            for i = 1,table.maxn(this.bullets) do
                print("Destroy by damage")
                if this.bullets[i].bullet:getTeamUnit() == unit then
                    atari = i
                    this.bullets[i].bullet:remove();
                end

            end
            table.remove(this.bullets,atari);
            return 1;
        end,

        dead = function (this , unit)
            local  atari = 1
            for i = 1,table.maxn(this.bullets) do
                print("Destroy by dead")
                if this.bullets[i].bullet:getTeamUnit() == unit then
                    atari = i
                    this.bullets[i].bullet:takeAnimation(0,"animation",false);
                    this.bullets[i].bullet:remove();
                end

            end
            table.remove(this.bullets,atari);
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return 1;
end

function bulletControll(bulletinstance)
    bulletinstance.frame = bulletinstance.frame + 1;
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local xdir = 0;
    local ydir = 0;
    print(bulletinstance.posx);
    local bullettarget = megast.Battle:getInstance():getTeam(not bulletinstance.bullet:getTeamUnit():getisPlayer()):getTeamUnit(bulletinstance.targetUnit);
    local reversalFLG = bullettarget:getisPlayer(); 
    if bullettarget ~= nil and bulletinstance.yield then
        local thisx = currentbullet:getPositionX();
        local thisy = currentbullet:getPositionY();
        local targetx = bullettarget:getPositionX();

        --相手ユニットが敵側ならX軸の移動量を反転させる
        if reversalFLG then
            targetx = targetx + bullettarget:getSkeleton():getBoneWorldPositionX("MAIN");
        else
            targetx = targetx + bullettarget:getSkeleton():getBoneWorldPositionX("MAIN") * -1;
        end

        local targety = bullettarget:getPositionY() + bullettarget:getSkeleton():getBoneWorldPositionY("MAIN") + bullettarget:getSkeleton():getPositionY();

        xdir = targetx - thisx;
        ydir = targety - thisy;


        bulletinstance.limitx = bulletinstance.limitx + xdir;
        bulletinstance.limity = bulletinstance.limity + ydir;


    end
    
    moveByFloat(bulletinstance,xdir,ydir);   
    return 1;
end


function moveByFloat(_bulletinstance,xdistance,ydistance)
    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;
    return 1;
end

