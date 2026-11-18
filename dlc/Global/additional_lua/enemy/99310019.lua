function new(id)
    print("10000 new ");
    local instance = {
        skillChecker = false,
        attackChecker = false,
        myself = nil,
        wall = nil,
        beforeTargetUnit = 0,
        funnels = {},
        wallHP = 0,
        wallHPFull = 0,
        modeElement = 0,
        barrierCounter = 0,
        thisid = id,
        funnelCounter = 0, -- ファンネルを今までいくつ出したか覚えておく（ファンネルのY座標のライン決定に使う
        subBar = nil,
        
        barrierCoolTime = 7,     --バリア破壊されてから再度バリア出せるようになるまでの行動数
        funnelHPDeffault = 50000, --クモのHP
        wallAddRateBySuction = 0.5,--クモを吸収した時の１匹当たりの倍率

        wallHPDefault = 350000,    --バリアの現在の設定HP
        ConfwallHpFirst = 350000,
        ConfwallHpDef = 50000,


        rates = {
            --バリアない時の攻撃
            attack1 = 40,
            attack4 = 30,
            attack5 = 30,

            --バリア展開時の攻撃
            attack2 = 25,
            attack3 = 35,
            attack6 = 40,

            --バリアある時のスキル
            skill1 = 60,
            skill2 = 40,
            --バリアない時はスキルは１個しかないため確率なし

            --クモが３匹以下の時に召喚する確率（攻撃直前に抽選）
            spawnRate = 30,

            --バリアを展開する確率（行動毎に抽選）
            barrierRate = 15
        },


        funnelInfo = {
            new = function (_bullet,_targetUnit,_otherparam)
                return {
                    bullet = _bullet,
                    targetUnit = _targetUnit,
                    otherParam = _otherparam,
                    frame = 0,
                    angle = 0,
                    posx = 0,
                    posy = 0,
                    yOffset = 0,
                    speedkeisuu = 1,
                    parent = nil,
                    state = 0
                }
            end
        },

        summon = function (this,unit)
            local ishost = megast.Battle:getInstance():isHost();
            

            
            local s = this.myself:addOrbitSystem("funnelIdle",2)
            s:setHitCountMax(999);
            s:setEndAnimationName("funnelDead")
            s:takeAnimation(0,"funnelSpawn",true);

            local x = this.myself:getPositionX()
            local xb = this.myself:getSkeleton():getBoneWorldPositionX("Suction");
            local y = this.myself:getPositionY()
            s:setPosition(x + xb+100,y -100);--ちょっと発生場所を１００づつくらいずらしたかったので＋１００　−１００
            s:setAutoZOrder(true);
            s:enableShadow(true);
            s:setActiveSkill(7);
            s:setBaseHP(this.funnelHPDeffault);
            s:setHP(this.funnelHPDeffault);
            s:setElementType(kElementType_Earth);
            s:setZOderOffset(-5000);
        
            local t = this.funnelInfo.new(s,this.beforeTargetUnit,10);
            t.angle = 0;
            t.parent = unit;
            t.state = 0;
            t.yOffset = -100 + (this.funnelCounter % 3) * 100;--ファンネルの高さは出るたびに１００づつずれるようにする　−１００から＋１００の間で変化
            table.insert(this.funnels,t)

            this.funnelCounter = this.funnelCounter + 1;

            return 1;
        end,

        suction = function (this,unit)
            if table.maxn(this.funnels) > 0 then
                for i = 1,table.maxn(this.funnels) do
                    this.funnels[i].frame = 0;
                    this.funnels[i].state = 5;
                    -- this.funnels[i].bullet:setEndAnimationName("shrink");
                    this.funnels[i].bullet:setAutoZOrder(false);
                    this.funnels[i].bullet:setZOrder(unit:getZOrder() + 1);
                    -- this.funnels[i].bullet:enableShadow(false);
                end
            end
            return 1;
        end,

        absorb = function (this,unit)
            if table.maxn(this.funnels) > 0 then
                for i = 1,table.maxn(this.funnels) do
                    this.wallHP = this.wallHP + this.wallHPDefault * this.wallAddRateBySuction;
                    
                    this.funnels[i].bullet:takeAnimation(0,"funnelballend",false);
                    this.funnels[i].bullet:getSkeleton():runAction(cc.FadeOut:create(0.3));
                    this.funnels[i].bullet:setEndAnimationName("shrink2");
                end
            end
            this.wallHPFull = this.wallHP;
            megast.Battle:getInstance():sendEventToLua(this.thisid,5,this.wallHP);
            return 1;
        end,


        barrier = function (this,unit)
            local ishost = megast.Battle:getInstance():isHost();
            
            if ishost then
                this.modeElement = 4;
                
                local s = this.myself:addOrbitSystem("wallloop",0)
                s:takeAnimation(0,"wallloop",true);

                local x = this.myself:getPositionX()
                local y = this.myself:getPositionY()
                s:setPosition(x,y);
                this.wall = s;
                this.wallHP = this.wallHPDefault;
                this.wallHPFull = this.wallHP;
                megast.Battle:getInstance():setBossCounterElement(this.modeElement);
                megast.Battle:getInstance():sendEventToLua(this.thisid,4,1);
            end
            return 1;
        end,

        funnelStateEnd = function (this,unit)
            print("funnelStateEnd");
            local  atari = 1
             for i = 1,table.maxn(this.funnels) do
         
                if this.funnels[i].bullet == unit then
                    this.innerFunnelStateEnd(this,this.funnels[i]); 
                end

            end
            return 1;
        end,

        innerFunnelStateEnd = function (this,bulletinstance)
            bulletinstance.frame = 0;
             if bulletinstance.state == 0 then
                bulletinstance.state = 1;
            elseif bulletinstance.state == 1 then
                local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);
                if bullettarget ~= nil then
                    bulletinstance.state = 4;
                else
                    bulletinstance.state = 3;
                    bulletinstance.targetUnit = this.beforeTargetUnit;
                end
                
            elseif bulletinstance.state == 2 then
                bulletinstance.state = 1;
            elseif bulletinstance.state == 3 then
                bulletinstance.state = 1;
            elseif bulletinstance.state == 4 then
                bulletinstance.state = 1;
            end 
            return 1;
        end,

        onDestroyFunnel = function (this,unit)
            local  atari = 0;
            for i = 1,table.maxn(this.funnels) do
                print("Destroy")
                if this.funnels[i].bullet == unit then
                    atari = i
                end

            end
            if atari ~= 0 then
                table.remove(this.funnels,atari);
            end
            return 1;
        end,


        funnelBallEnd = function (this,unit)
            for i = 1,table.maxn(this.funnels) do
                if this.funnels[i].bullet == unit then
                    unit:takeAnimation(0,"funnelballloop",true);
                    -- LuaUtilities.runJumpTo(unit,3,targetx , targety,400,1);
                end
            end
            
            return 1;
        end,

        funnelControll = function (this,bulletinstance)
            --ファンネルの状態　
            -- 0 = 初期状態
            -- 1 = 待機状態
            -- 2 = 前進
            -- 3 = 後退
            -- 4 = 攻撃
            -- 5 = 吸収

            if bulletinstance.state == 0 then
                
            elseif bulletinstance.state == 1 then
                this.funnelIdle(this,bulletinstance);
            elseif bulletinstance.state == 2 then
                this.funnelFront(this,bulletinstance);
            elseif bulletinstance.state == 3 then
                this.funnelBack(this,bulletinstance);
            elseif bulletinstance.state == 4 then
                this.funnelAttack(this,bulletinstance);
            elseif bulletinstance.state == 5 then
                this.funnelSuction(this,bulletinstance);
            end

            if bulletinstance.bullet:getPositionY() < - 200 then
                bulletinstance.bullet:setPosition(bulletinstance.bullet:getPositionX(),-200);
                bulletinstance.posy = -200;
            end

            if bulletinstance.bullet:getPositionX() < - 300 then
                bulletinstance.bullet:setPosition(-300,bulletinstance.bullet:getPositionY());
                bulletinstance.posx = -300;
            end

            return 1;
        end,


        funnelIdle = function (this,bulletinstance)
            if bulletinstance.frame == 0 then
                bulletinstance.bullet:takeAnimation(0,"funnelIdle",true);
                bulletinstance.otherParam = 90 + LuaUtilities.rand(0,50);
            end
            bulletinstance.frame = bulletinstance.frame + 1 * unitManagerDeltaTime/0.016666667;
            if bulletinstance.frame >= bulletinstance.otherParam then
                this.innerFunnelStateEnd(this,bulletinstance);
            end
            return 1;
        end,

        funnelFront = function (this,bulletinstance)
            if bulletinstance.frame == 0 then
                bulletinstance.posx = bulletinstance.bullet:getPositionX();
                bulletinstance.posy = bulletinstance.bullet:getPositionY();
                bulletinstance.bullet:takeAnimation(0,"funnelFront",true);
                bulletinstance.otherParam = 90 + LuaUtilities.rand(0,50);
            end
            local sp = 4;
            moveByFloat(bulletinstance,sp* unitManagerDeltaTime/0.016666667,0); 
            bulletinstance.frame = bulletinstance.frame + 1 * unitManagerDeltaTime/0.016666667;

            if bulletinstance.frame >= bulletinstance.otherParam then
                this.innerFunnelStateEnd(this,bulletinstance);
                
            end
            

            return 1;
        end,

        funnelBack = function (this,bulletinstance)
            if bulletinstance.frame == 0 then
                bulletinstance.posx = bulletinstance.bullet:getPositionX();
                bulletinstance.posy = bulletinstance.bullet:getPositionY();
                bulletinstance.bullet:takeAnimation(0,"funnelFront",true);
                bulletinstance.otherParam = 90 + LuaUtilities.rand(0,50);
                bulletinstance.angle = 180;
            end 

             local sp = 4;
            moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp* unitManagerDeltaTime/0.016666667),calcYDir(degToRad(bulletinstance.angle),sp* unitManagerDeltaTime/0.016666667)); 
            bulletinstance.frame = bulletinstance.frame + 1 * unitManagerDeltaTime/0.016666667;

            if bulletinstance.frame >= bulletinstance.otherParam or bulletinstance.posx < 0 then
                this.innerFunnelStateEnd(this,bulletinstance);
                
            end
            

            return 1;
        end,


        funnelRandomWalk = function (this,bulletinstance)
            if bulletinstance.frame == 0 then
                bulletinstance.posx = bulletinstance.bullet:getPositionX();
                bulletinstance.posy = bulletinstance.bullet:getPositionY();
                bulletinstance.bullet:takeAnimation(0,"funnelFront",true);
                bulletinstance.otherParam = 90 + LuaUtilities.rand(0,50);
                bulletinstance.angle = 180;
            end 

            local sp = 4;
            moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp* unitManagerDeltaTime/0.016666667),calcYDir(degToRad(bulletinstance.angle),sp* unitManagerDeltaTime/0.016666667)); 
            bulletinstance.frame = bulletinstance.frame + 1 * unitManagerDeltaTime/0.016666667;

            if bulletinstance.frame >= bulletinstance.otherParam or bulletinstance.posx < 0 then
                this.innerFunnelStateEnd(this,bulletinstance);
                
            end
            return 1;
        end,


        funnelSuction = function (this,bulletinstance)
            local currentbullet = bulletinstance.bullet;
            local sp = 10;
            
            if bulletinstance.frame == 0 then
                bulletinstance.posx = bulletinstance.bullet:getPositionX();
                bulletinstance.posy = bulletinstance.bullet:getPositionY();
                bulletinstance.bullet:takeAnimation(0,"funnelball",true);
                bulletinstance.otherParam = false;
            end


            local targetx = this.myself:getPositionX();
            local targety = this.myself:getPositionY();
            local targetxb = this.myself:getSkeleton():getBoneWorldPositionX("Suction");
            local targetyb = this.myself:getSkeleton():getBoneWorldPositionY("Suction");

            
            
            if bulletinstance.otherParam or (targetx + targetxb - currentbullet:getPositionX())*(targetx + targetxb - currentbullet:getPositionX()) + (targety + targetyb - currentbullet:getPositionY())*(targety + targetyb - currentbullet:getPositionY()) < 400 then
                bulletinstance.otherParam = true;
                bulletinstance.bullet:setPosition(targetx+targetxb,targety+targetyb);
           
                return 1;
            end
            local targetangle = getDeg(currentbullet:getPositionX(),currentbullet:getPositionY(),targetx + targetxb,targety + targetyb);
            
            --微妙に軌道を膨らませたい　２０fを頂点として角度を曲げる
            if bulletinstance.frame <= 20 then
                targetangle = targetangle - bulletinstance.frame * 3;
            elseif bulletinstance.frame <= 40 then
                targetangle = targetangle - (40 - bulletinstance.frame) * 3;
            end

            bulletinstance.angle = targetangle;
            


            moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp* unitManagerDeltaTime/0.016666667),calcYDir(degToRad(bulletinstance.angle),sp* unitManagerDeltaTime/0.016666667)); 
            
           
            bulletinstance.frame = bulletinstance.frame + 1 * unitManagerDeltaTime/0.016666667;

            return 1;
        end,


        funnelAttack = function (this,bulletinstance)
            local currentbullet = bulletinstance.bullet;
            local sp = 4;
            local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);

            if bulletinstance.frame == 0 then
                bulletinstance.posx = bulletinstance.bullet:getPositionX();
                bulletinstance.posy = bulletinstance.bullet:getPositionY();
                bulletinstance.bullet:takeAnimation(0,"funnelFront",true);
                bulletinstance.otherParam = false;

                -- print(bulletinstance.angle);
                    print("kitaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
                    print(bulletinstance.posy);
  
                if bullettarget ~= nil then
                    if bullettarget:getPositionX() - bulletinstance.posx < 0 then
                        bulletinstance.state = 3;
                        bulletinstance.frame = 0;
                    end
                end
            end
    
            bulletinstance.frame = bulletinstance.frame + 1 * unitManagerDeltaTime/0.016666667;

            if bullettarget ~= nil then
                if bullettarget:getPositionX() - bulletinstance.posx < 0 then
                    bulletinstance.state = 3;
                    bulletinstance.frame = 0;
                elseif bullettarget:getPositionX() - bulletinstance.posx > 100 then
                    local targetangle = getDeg(currentbullet:getPositionX(),currentbullet:getPositionY(),bullettarget:getPositionX(),bulletinstance.yOffset);
                    bulletinstance.angle = targetangle;
                    

                    moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp* unitManagerDeltaTime/0.016666667),calcYDir(degToRad(bulletinstance.angle),sp* unitManagerDeltaTime/0.016666667)); 
                elseif not bulletinstance.otherParam then
                    currentbullet:takeAnimation(0,"funnelAttack",true);
                    bulletinstance.otherParam = true;
                end
            end
           
            

            return 1;
        end,

        playStartAwakeBarrier = function(this,unit)
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                this.wallHPDefault = this.ConfwallHpFirst;
                this.barrier(this,unit);
                megast.Battle:getInstance():sendEventToLua(this.thisid,6,1);
            end
            return 1;
        end,


        addSP = function (this,unit)
            unit:addSP(20);
            return 1;
        end,



        --共通変数
        param = {
          version = 1.4
          ,isUpdate = true
        },

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            this.wallHPDefault = this.ConfwallHpDef;
            this.myself:takeAnimation(0,"wall",false);     
            this.myself:takeAnimationEffect(0,"wallCreate",false);
            return 1;
        end,

        receive2 = function (this , intparam)
            this.myself:takeAnimation(0,"damage2",false);
            this.myself:takeAnimationEffect(0,"empty",false);     
            this.wall:takeAnimation(0,"wallBreak",false);
            this.wall = nil;
            this.modeElement = 5;
            megast.Battle:getInstance():setBossCounterElement(this.modeElement);
            this.barrierCounter = this.barrierCoolTime;
            return 1;
        end,

        receive3 = function (this , intparam)
            
            this.wall:takeAnimation(0,"empty",false);
            this.wall = nil;
            this.modeElement = 5;
            return 1;
        end,

        receive4 = function (this , intparam)
                this.modeElement = 4;
                
                local s = this.myself:addOrbitSystem("wallloop",0)
                s:takeAnimation(0,"wallloop",true);

                local x = this.myself:getPositionX()
                local y = this.myself:getPositionY()
                s:setPosition(x,y);
                this.wall = s;
                this.wallHP = this.wallHPDefault;
                this.wallHPFull = this.wallHP;
                megast.Battle:getInstance():setBossCounterElement(this.modeElement);
            return 1;
        end,

        receive5 = function (this , intparam)
            this.wallHP = intparam;
            this.wallHPFull = intparam;
            return 1;
        end,

        receive6 = function (this , intparam)
            this.wallHPDefault = this.ConfwallHpFirst;
            this.barrier(this,this.myself);
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "summon" then return this.summon(this,unit) end
            if str == "funnelStateEnd" then return this.funnelStateEnd(this,unit) end
            if str == "onDestroyFunnel" then return this.onDestroyFunnel(this,unit) end
            if str == "suction" then return this.suction(this,unit) end
            if str == "absorb" then return this.absorb(this,unit) end
            if str == "barrier" then return this.barrier(this,unit) end
            if str == "StartAwakeBarrier" then return this.playStartAwakeBarrier(this,unit) end
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "funnelBallEnd" then return this.funnelBallEnd(this,unit) end
            return 1;
        end,

        --version 1.4
        takeIn = function(this,unit)
            unit:setPositionX(-300);
            unit:setPositionY(70);
            unit:setDefaultPosition(-300,70);
            return 1;
        end,

        --version 1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
           
            if this.wall ~= nil then
                value = 0;
            end 

            return value;
        end,

        takeBreake = function (this,unit)
            return 1;
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            this.subBar =  BattleControl:get():createSubBar();
            
            if this.subBar ~= nil then
                this.subBar:setWidth(350); --バーの全体の長さを指定
                this.subBar:setHeight(17);
                this.subBar:setPercent(0); --バーの残量を50%に指定
                this.subBar:setVisible(false);
                this.subBar:setPositionX(-210);
                this.subBar:setPositionY(150);
            end

            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            if table.maxn(this.funnels) > 0 then
                for i = 1,table.maxn(this.funnels) do
                    this.funnelControll(this,this.funnels[i],i);
                end
            end
            if this.wall ~= nil then
                this.wall:setPosition(unit:getPositionX(),unit:getPositionY());
                if this.subBar ~= nil then
                    this.subBar:setVisible(true);
                    this.subBar:setPercent(100 * this.wallHP/this.wallHPFull);
                end
            elseif this.subBar ~= nil then
                this.subBar:setVisible(false);
            end
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            if this.wall ~= nil then
                
                this.wallHP = this.wallHP - value;
                unit:setHP(unit:getHP() + value);
                local ishost = megast.Battle:getInstance():isHost();
                if this.wallHP < 0 and ishost then
                    unit:takeAnimation(0,"damage2",false);
                    unit:takeAnimationEffect(0,"empty",false);     
                    this.wall:takeAnimation(0,"wallBreak",false);
                    this.wall = nil;
                    this.modeElement = 5;
                    megast.Battle:getInstance():setBossCounterElement(this.modeElement);
                    this.barrierCounter = this.barrierCoolTime;
                    megast.Battle:getInstance():sendEventToLua(this.thisid,2,1);
                end

               
            end
            return value;
        end,

        --version1.0
        start = function (this , unit)
            unit:setZOderOffset(95);
            math.randomseed(os.time());
            this.myself = unit;
            this.modeElement = 5;
            unit:setSPGainValue(0);
      
            return 1;
        end,

        excuteAction = function (this , unit)
            -- if table.maxn(this.funnels) > 0 then
            megast.Battle:getInstance():setBossCounterElement(this.modeElement);
            local ishost = megast.Battle:getInstance():isHost();
            if this.wall == nil and ishost then
                this.barrierCounter = this.barrierCounter - 1;
                local rand = LuaUtilities.rand(0,100)
                if rand <= this.rates.barrierRate and this.barrierCounter <= 0 then
                    this.wallHPDefault = this.ConfwallHpDef;
                    unit:takeAnimation(0,"wall",false);     
                    unit:takeAnimationEffect(0,"wallCreate",false);
                    megast.Battle:getInstance():sendEventToLua(this.thisid,1,1);
                    return 0;
                end
            end
            
            return 1;
        end,

        takeIdle = function (this , unit)
            print("idle kita");
            if this.modeElement == 4 then
                unit:setNextAnimationName("idle1");
            else
                unit:setNextAnimationName("idle2");
            end
            return 1;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
         
            return 1;
        end,

        takeAttack = function (this , unit , index)
            this.beforeTargetUnit = unit:getTargetUnit():getIndex();
            if index == 1 then
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            elseif index == 3 then
                unit:setActiveSkill(4);
            elseif index == 4 then
                unit:setActiveSkill(3);
            elseif index == 5 then
                unit:setActiveSkill(5);
            elseif index == 6 then
                unit:setActiveSkill(6);
            end

            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                local target = unit:getTargetUnit() 
                local distance = BattleUtilities.getUnitDistance(unit,target)
                print(distance);
                if this.modeElement == 4 then
                    if distance > 400 and this.attackChecker == false then
                        this.attackChecker = true
                        unit:takeAttack(3)
                        return 0;
                    elseif this.attackChecker == false then

                        this.attackChecker = true;
                        local rand = LuaUtilities.rand(0,100);
                        if rand <= this.rates.attack2 then
                            unit:takeAttack(2);
                        elseif  rand <= this.rates.attack2 + this.rates.attack3 then
                            unit:takeAttack(3);
                        else
                            unit:takeAttack(6);
                        end
                        return 0;
                    end
                else
                    if this.attackChecker == false then
                        this.attackChecker = true;
                        if table.maxn(this.funnels) < 3 then
                            local randFunnnel = LuaUtilities.rand(0,100);
                            if randFunnnel <= this.rates.spawnRate then
                                unit:takeAttack(7);
                                return 0;
                            end
                        end
                        
                        local rand = LuaUtilities.rand(0,100);
                         if rand <= this.rates.attack1 then
                            unit:takeAttack(1);
                        elseif  rand <= this.rates.attack1 + this.rates.attack4 then
                            unit:takeAttack(4);
                        else
                            unit:takeAttack(5);
                        end

                    
                        return 0;
                    end
                end
                this.attackChecker = false
            end
            return 1;
        end,

        takeSkill = function (this,unit,index)
            if index == 1 then
                unit:setActiveSkill(8);
            elseif index == 2 then
                unit:setActiveSkill(9);
            elseif index == 3 then
                unit:setActiveSkill(10);  
            end
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                -- local target = unit:getTargetUnit() 
                -- local distance = BattleUtilities.getUnitDistance(unit,target)

               if this.skillChecker == false then
                    if this.modeElement == 4 then
                        this.skillChecker = true;
                        rand = LuaUtilities.rand(0,100);
                        if rand <= this.rates.skill1 then
                            unit:takeSkill(1);
                        elseif rand <= 100 then
                            unit:takeSkill(2);
                            if this.wall ~= nil then
                                this.wall:takeAnimation(0,"empty",false);
                                this.wall = nil;
                                this.modeElement = 5;
                                megast.Battle:getInstance():sendEventToLua(this.thisid,3,1);
                            end
                        end
                    else
                        this.skillChecker = true;
                        rand = LuaUtilities.rand(0,100);
                        if rand <= 100 then
                            unit:takeSkill(3);
                        end
                    end
                    
                    return 0;
                end
                this.skillChecker = false
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
    return 1;
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

