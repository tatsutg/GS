function new(id)
    --このスクリプトは　ユニットボス　コピーイリスのluaです
    print("500311493 new ");
    local instance = {
        attackChecker = false,
        isRage = false,
        isHost = false,
        isChangedRange = false,
        myself = nil,
        beforTarget = nil,
        bullets = {},
        RangeOrigin = 0,
        isPlayerUnit = true,
        bulletSpan = os.time(),
        muki = 1;
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
            local shot = unit:addOrbitSystem("sphere",0)
            --shot:setHitCountMax(1)
            --shot:setEndAnimationName("explosion")
            -- shot:EnabledFollow = true;
            local x = unit:getPositionX();
            local y = unit:getPositionY();
            local xb = unit:getSkeleton():getBoneWorldPositionX("MAIN");
            local yb = unit:getSkeleton():getBoneWorldPositionY("MAIN");
            shot:setPosition(x + xb,y+yb);
            shot:setDamageRateOffset(1/7);
            shot:setActiveSkill(3);

            local tama = this.bulletinfo.new(shot,unit:getTargetUnit():getIndex(),0);
            tama.isPlayer = unit:getisPlayer();
            
            table.insert(this.bullets,tama)
            return 1;
        end,

        onDestroy = function (this,unit)
            local  atari = 0;
            for i = 1,table.maxn(this.bullets) do
                print("Destroy")
                if this.bullets[i].bullet == unit then
                    atari = i
                end

            end
            if atari ~= 0 then
                table.remove(this.bullets,atari);
            end
            return 1;
        end,

        bulletControll10102411 = function (this,bulletinstance)
            local framecnt = bulletinstance.frame;
            local currentbullet = bulletinstance.bullet;
            local sp = 1;
            local speedOrigin = 1;

            if framecnt == 0 then
               
                local rand = LuaUtilities.rand(0,360);
                bulletinstance.angle = rand;
                bulletinstance.speedkeisuu = LuaUtilities.rand(100,130)/100;
                sp = speedOrigin;
                bulletinstance.posx = bulletinstance.bullet:getPositionX();
                bulletinstance.posy = bulletinstance.bullet:getPositionY();
            end
            
            bulletinstance.frame = bulletinstance.frame + 1 * unitManagerDeltaTime/0.016666667;

            
            if framecnt < 120 then
                sp = 1 + framecnt/2;

                if sp > 30 then
                    sp = 30;
                end
                
                print(framecnt);
                local bullettarget = megast.Battle:getInstance():getTeam(not this.isPlayerUnit):getTeamUnit(bulletinstance.targetUnit);
                if bullettarget ~= nil then
                    local bulletx = bulletinstance.bullet:getPositionX();
                    local bullety = bulletinstance.bullet:getPositionY();
                    local targetx = bullettarget:getPositionX() -this.muki * (bullettarget:getSkeleton():getBoneWorldPositionX("MAIN"));
                    local targety = bullettarget:getPositionY() + bullettarget:getSkeleton():getBoneWorldPositionY("MAIN");
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
                        local maxdir = 0;
                        if framecnt > 15 then
                            maxdir = (1 + framecnt/5) * unitManagerDeltaTime/0.016666667;
                        end
                        
                        if dir > maxdir then
                            dir = maxdir;
                        elseif dir < -maxdir then
                            dir = -maxdir;
                        end
                        bulletinstance.angle = bulletinstance.angle + dir;
                    end
                    local distance = math.sqrt((bulletx - targetx)*(bulletx - targetx) + (bullety - targety)*(bullety - targety));
                    if distance > 100 then
                        sp = sp * unitManagerDeltaTime/0.016666667;
                        if sp > distance then
                            sp = distance;
                        end
                        moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp),calcYDir(degToRad(bulletinstance.angle),sp));
                    else
                        --近接信管
                        -- sp = distance;
                        -- moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp),calcYDir(degToRad(bulletinstance.angle),sp));
                        bulletinstance.bullet:takeAnimation(0,"explosion",false); 
                    end 

                else
                    --ターゲットがいなかったらその場で爆発
                    bulletinstance.bullet:takeAnimation(0,"explosion",false); 
                end

            else
                --時間切れで爆発
               bulletinstance.bullet:takeAnimation(0,"explosion",false);  
            end

             
        end,

        addSP = function (this,unit)
            unit:addSP(20);
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
            if str == "addShot" then return this.shot(this,unit) end
            if str == "onDestroy" then return this.onDestroy(this,unit) end
            if str == "addSP" then return this.addSP(this,unit) end
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
                    this.bulletControll10102411(this,this.bullets[i]);
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
            this.isPlayerUnit = unit:getisPlayer();
            this.isHost = megast.Battle:getInstance():isHost();
            if not this.isPlayerUnit then
                this.muki = -1;
            end
            this.RangeOrigin = unit:getRange_Max();
            unit:setRange_Min(0);
            unit:setSPGainValue(0);
            return 1;
        end,

        excuteAction = function (this , unit)
            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if this.bulletSpan - os.time() <= -10 and hpParcent < 50 then
                    this.bulletSpan = os.time();
                    unit:takeSkill(1);
                    return 0;
            end
            
            if not this.isChangedRange and this.beforTarget ~= nil then
                local distance = BattleUtilities.getUnitDistance(unit,this.beforTarget);
                this.isChangedRange = true;
                
                local rand = LuaUtilities.rand(0,100);

                if rand < 30 and distance < 200 then
                    print("maxrange=10");
                    unit:setRange_Max(50);
                    unit:setRange_Min(0);
                else
                    print("maxrange=max");
                    unit:setRange_Max(400);
                end
                
            end
            
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
            this.isChangedRange = false;
            this.beforTarget =  unit:getTargetUnit();
            if index == 1 then
                unit:setActiveSkill(1);
            else
                unit:setActiveSkill(2);
            end
            if this.isHost and not this.attackChecker then
                
                local distance = BattleUtilities.getUnitDistance(unit,unit:getTargetUnit());
                this.attackChecker = true;
                if distance < 100 then
                    unit:takeAttack(2);
                else
                    unit:takeAttack(1);
                end
                return 0;
            end
            this.attackChecker = false;
            return 1;
        end,

        takeSkill = function (this,unit,index)
            if index == 1 then
                --skill1はorbitSystemで攻撃するためそちらの方にsetActiveSkillしてます。
            else
                unit:setActiveSkill(4);
            end
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