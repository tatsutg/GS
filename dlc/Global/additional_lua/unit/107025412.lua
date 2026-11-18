function new(id)
    print("10102411 new "); -- イリスLua
    local instance = {


        --Values
        isFirstStepUpdate = false,
        --uniqueID
        ThisUniqueId = id,
        --ThisUnit
        ThisUnit = nil,

        rinascita_icon_ID = 37,
        rinascita_Buff_ID = 0,
        rinascita_Buff_Value = 0,


        myself = nil,
        target = nil,
        bullets = {},
        isPlayerUnit = true,
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
            local targetindex = 0;
            local target = unit:getTargetUnit();
            if target ~= nil then
               targetindex = unit:getTargetUnit():getIndex();
            else
                return 0;
            end
        
            local shot = unit:addOrbitSystem("sphere",0)
            local oneShotRate = 1/10;
            shot:setDamageRateOffset(oneShotRate);
            shot:setBreakRate(oneShotRate);
            --shot:setHitCountMax(1)
            --shot:setEndAnimationName("explosion")
            -- shot:EnabledFollow = true;
            local x = unit:getPositionX();
            local y = unit:getPositionY();
            local xb = unit:getSkeleton():getBoneWorldPositionX("MAIN");
            local yb = unit:getSkeleton():getBoneWorldPositionY("MAIN");
            shot:setPosition(x + xb,y+yb);

            local tama = this.bulletinfo.new(shot,targetindex,0);
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
               
                local rand = math.random(360);
                bulletinstance.angle = rand;
                bulletinstance.speedkeisuu = math.random(100,130)/100;
                sp = speedOrigin;
                bulletinstance.posx = bulletinstance.bullet:getPositionX();
                bulletinstance.posy = bulletinstance.bullet:getPositionY();
            end
            
            bulletinstance.frame = bulletinstance.frame + 1 * unitManagerDeltaTime/0.016666667;

            
            if framecnt < 120 then
                sp = 8 + framecnt/2;

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
                    local targetangle = getDeg(currentbullet:getPositionX(),currentbullet:getPositionY(),targetx,targety);
                    if targetangle < 0 then
                        targetangle = 360 + targetangle;
                    end

                    local dir = targetangle - bulletinstance.angle;

                    if dir > 180 then
                        dir = -(360 - dir);
                    end

                    if dir < -180 then
                        dir = (360 + dir);
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


        --アップデート最初の一度のみ実行される。
        FirstUpdateInitialize = function(this,unit)
            this.ThisUnit = unit;
            --空文字だったら初回生成なので値を代入する
            if unit:getParameter("isRinascita") == "" then
                unit:getTeamUnitCondition():addCondition(-44,this.rinascita_Buff_ID,this.rinascita_Buff_Value,2000,this.rinascita_icon_ID);
                unit:setParameter("isRinascita","FALSE");
            elseif unit:getParameter("isRinascita") == "FALSE" then
                unit:getTeamUnitCondition():addCondition(-44,this.rinascita_Buff_ID,this.rinascita_Buff_Value,2000,this.rinascita_icon_ID);
            end
            return 1;
        end,

        isDeadUnit = function (this,unit)
            for i = 0,3 do
                local teamUnit = unit:getTeam():getTeamUnit(i,true);
                if teamUnit ~= nil then
                    if teamUnit:getHP() <= 0 then
                        return true;   --死んでた、誰かが
                    end
                end
            end
            return false;
        end,

        --sendEventToLua
        RequestSendEventToLua = function(this,unit,requestIndex,intparam)
            if unit:isMyunit() == true or this.isEnemyType(this,unit) == true then
                print("----------リクエストを受付開始 ID == ",intparam);
                megast.Battle:getInstance():sendEventToLua(this.ThisUniqueId,requestIndex,intparam);
            end
            return 1;
        end,

        isEnemyType = function (this,unit)
            local isHost = megast.Battle:getInstance():isHost();
            local isPlayer = unit:getisPlayer();
            if isPlayer == false and isHost == true then
                return true;
            end
            return false;
        end,

        Rinascita = function (this , unit)

            if unit:isMyunit() == true or this.isEnemyType(this,unit) == true then
                for i = 0,3 do
                    local teamUnit = unit:getTeam():getTeamUnit(i,true);
                    if teamUnit ~= nil then
                        if teamUnit:getHP() <= 0 then
                            unit:getTeam():reviveUnit(teamUnit:getIndex());
                            local targetHP = teamUnit:getCalcHPMAX()/3 >= 1 and teamUnit:getCalcHPMAX()/3 or 1;
                            teamUnit:setHP(targetHP);
    
                            unit:setParameter("isRinascita","TRUE");   --復活！
                            
                            local buff =  unit:getTeamUnitCondition():findConditionWithID(-44);
                            if not(buff == nil) then
                                local conditon = unit:getTeamUnitCondition():findConditionWithID(-44);
                                unit:getTeamUnitCondition():removeCondition(conditon);
                            end
                            this.RequestSendEventToLua(this,unit,2,teamUnit:getIndex());
    
                            return 0;
                        end
                    end
                end
            end

            return 1;
        end,

         --receive分岐用
        receiveBranch_1 = function(this,intparam)
            print("----------リクエストを受付中 ID == ",intparam);
            return 1;
        end,

        receiveBranch_2 = function(this,intparam)
            print("----------リクエストを受付中 ID == ",intparam);
            this.ThisUnit:getTeam():reviveUnit(intparam);
            local teamUnit = this.ThisUnit:getTeam():getTeamUnit(intparam,true);
            local targetHP = teamUnit:getCalcHPMAX()/3 >= 1 and teamUnit:getCalcHPMAX()/3 or 1;
            teamUnit:setHP(targetHP);
            this.ThisUnit:setParameter("isRinascita","TRUE");   --復活！
            local buff =  this.ThisUnit:getTeamUnitCondition():findConditionWithID(-44);
            if not(buff == nil) then
                local conditon = this.ThisUnit:getTeamUnitCondition():findConditionWithID(-44);
                this.ThisUnit:getTeamUnitCondition():removeCondition(conditon);
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
            return this.receiveBranch_1(this,intparam);
        end,

        receive2 = function (this , intparam)
            return this.receiveBranch_2(this,intparam);
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addShot" then return this.shot(this,unit) end
            if str == "onDestroy" then return this.onDestroy(this,unit) end

            if str == "Rinascita" then return this.Rinascita(this,unit) end

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

            if this.isFirstStepUpdate == false then
                this.FirstUpdateInitialize(this,unit);
                this.isFirstStepUpdate = true;
            end

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
            if not this.isPlayerUnit then
                this.muki = -1;
            end
            return 1;
        end,

        excuteAction = function (this , unit)

            if unit:getParameter("isRinascita") == "FALSE" then
                if this.isDeadUnit(this,unit) then
                    unit:takeAnimation(0,"Rinascita",false);
                    unit:takeAnimationEffect(0,"1_Rinascita",false);
                    unit:setUnitState(kUnitState_skill);
                    unit:setBurstState(kBurstState_active);
                    return 0;
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