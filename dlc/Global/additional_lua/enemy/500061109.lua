function new(id)
    print("10000 new ");
    local instance = {
        consts = {
            unitHight = 100,
            curseBuffID = 95,
            fogBuffID = 31,
            fogBuffEffectID = 31,
            fogBuffIconID = 16,
            fogBuffValue = 70,
            fogBuffTime = 9999,
            fogCoolTurn = 5, --Breakされてから再度霧を展開することが可能になるまでの行動数
            breakDebuffID = 27,
            breakDebuffEffectID = 27,
            breakDebuffIconID = 0,
            breakDebuffValue = 100,
            breakDebuffTime = 9999,
            fadeOutTime = 0.3,
            fadeInTime = 0.3,
            powerBorderOfDeath = 10000,
            skill3FixedDamage = 9999
        },

        rates = {
            --通常攻撃の確率 この中で合計１００になるようにしてください
            attack1Rate = 35,
            attack2Rate = 40,
            attack3Rate = 25,--霧を再度展開することができるタイミングだとattack4が発動

            --呪われたユニットが存在しない場合のスキルの確率 この中で合計１００になるようにしてください
            skill1Rate = 100,
            skill2Rate = 0,

            --呪われたユニットが存在する場合のスキルの確率 この中で合計１００になるようにしてください
            skill1RateC = 50,
            skill2RateC = 0,
            skill3Rate = 50
        },

        myself = nil,
        myNode = nil,
        deathTarget = nil,
        blackMist = nil,
        attackChecker = false,
        skillChecker = false,
        updateStarted = false,
        bullets = {},
        skullCnt = 0,
        BeforetargetUnitIndex = 0,
        bulletsIDCounter = 0,
        thisID = id,
        isMist = true,
        ishost = true,
        mistCounter = 0,
        fadeOutFlag = false,
        targetFadeInFlag = false,
        fadeInFlag = false,
        fadeOutFrame = 0,
        targetFadeInFrame = 0,
        fadeInFrame = 0,
        bulletSpan = os.time(),
        bleakTimer = os.time(), --bleakしたらしばらくは玉を出さないためのタイマー
        deathExcuteFlg = false,
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
                    speedkeisuu = 1
                }
            end
        },



        skullSpawnByDamage = function (this,enemy,unit)
            if unit == this.myself then
                local hpParcent = 100 * this.myself:getHP()/this.myself:getCalcHPMAX();
                local rand = LuaUtilities.rand(0,60);
                local spawnRate = rand - hpParcent;
                

                --前回から0.2秒以上経っているときに一定確率で　または骸骨玉が一個も出ていなければ確実に出す
                if (spawnRate > 0 and this.bulletSpan - os.time() <= -0.2) or table.maxn(this.bullets) <= 0 then
                    if this.bleakTimer - os.time() >= -1 then
                        return 1;
                    end
                    this.bulletSpan = os.time();
                    local s = this.myself:addOrbitSystem("skullBase",2)
                    s:setHitCountMax(1)
                    s:setEndAnimationName("explosion")
                    -- s:takeAnimation(0,"skullBase",true);
                   
                    local x = this.myself:getPositionX()
                    local y = this.myself:getPositionY()
                    local offsety = 350;
                    s:setPosition(x,y+offsety)
                    s:setActiveSkill(6);
                    s:setOpacity(0);
                    s:runAction(cc.FadeIn:create(1));
                    local t = this.bulletinfo.new(s,enemy:getIndex(),0);
                    table.insert(this.bullets,t)
                end
            end

            return 1;
        end,



        skull = function (this,unit)
            local hpratio = this.myself:getHP()/this.myself:getCalcHPMAX();

            local bulletCount = 4 - hpratio * 3;

            for i = 0,bulletCount do
                local s = unit:addOrbitSystem("skullBase",2)
                s:setHitCountMax(1)
                s:setEndAnimationName("explosion")
                local x = unit:getPositionX()
                local y = unit:getPositionY()

                --玉の出る座標をちょっとランダムにばらけさせたい
                local amplitude = 100;
                local rand = LuaUtilities.rand(0,amplitude);
                local rand2 = LuaUtilities.rand(0,amplitude);

                s:setPosition(x + rand - 50,y+350 + rand2 - 50);
                s:setActiveSkill(6);
                -- s:takeAnimation(0,"skullBase",true);
                s:setOpacity(0);
                s:runAction(cc.FadeIn:create(1));
                local tama = this.bulletinfo.new(s,unit:getTargetUnit():getIndex(),0);
                table.insert(this.bullets,tama)
            end
            return 1;
        end,


        onDestroy = function (this,unit)
            local  atari = 1
             for i = 1,table.maxn(this.bullets) do
                print("Destroy")
                if this.bullets[i].bullet == unit then
                    atari = i
                end

            end
                this.bullets[atari].bullet:setEndAnimationName("");
                table.remove(this.bullets,atari);
            return 1;
        end,

        suesideShot = function (this,unit)
            print("Sueside Shot");
            for i = 1,table.maxn(this.bullets) do
                this.bullets[i].bullet:stopAllActions();
                this.bullets[i].bullet:takeAnimation(0,"explosion",false);
            end

            return 1;
        end,


        generalPause = function (this,unit)
            this.deathExcuteFlg = true;
            --まずヒットストップ中のユニットのヒットストップを解除　そして全員気絶
            for i = 0,6 do
                local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
                if uni ~= nil then
                    uni:resumeUnit();
                    uni:getTeamUnitCondition():addCondition(-12,89,100,0.5,0);
                end
            end
            --全員停止
            megast.Battle:getInstance():pauseUnit(2);
            --死神だけ動く
            unit:resumeUnit();
            unit.m_IgnoreHitStopTime = 10;

            return 1;
        end,

        target = function (this,unit)
            if this.ishost then
                this.deathTarget = this.findCursedAtRandom(this);
                if this.deathTarget ~= nil then
                    megast.Battle:getInstance():sendEventToLua(this.thisID,1,this.deathTarget:getIndex());
                end
            end
            this.fadeOutAll(this,this.deathTarget);
            return 1;
        end,

        findCursedAtRandom = function(this)
            local curses = {};
            for i = 0,4 do
                local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
                if uni ~= nil then
                    print("まあここは来るわな");

                    local curse = uni:getTeamUnitCondition():findConditionWithType(this.consts.curseBuffID);

                    if curse ~= nil then
                        print("きてるんだなこっちも");
                        table.insert(curses,uni);                   
                    end
                end
            end
            if table.maxn(curses) > 0 then                          
                local hit = LuaUtilities.rand(0,table.maxn(curses));
                return curses[hit + 1];
            else
                print("即死対象なし");
                return nil;
            end
        end,

        fadeOutAll = function (this)
            this.fadeOutFrame = 0;
            this.fadeOutFlag = true;
            return 1;
        end,

        fadeInAll = function (this)
            this.fadeInFrame = 0;
            this.fadeInFlag = true;
            return 1;
        end,

        fadeInTarget = function (this,unit)
            if this.deathTarget ~= nil then
                this.targetFadeInFrame = 0;
                this.targetFadeInFlag = true;
                this.glab(this,unit);
                local fire = unit:addOrbitSystem("skill3player",0);
                local targetx = this.deathTarget:getPositionX() + this.deathTarget:getSkeleton():getBoneWorldPositionX("MAIN");
                local targety = this.deathTarget:getPositionY() + this.deathTarget:getSkeleton():getPositionY() + this.deathTarget:getSkeleton():getBoneWorldPositionY("MAIN") + this.consts.unitHight;
                fire:setPosition(targetx,targety);
                fire:pauseUnit(0.01);
            end
            return 1;
        end,

        death = function(this,unit)
            this.deathExcuteFlg = false;
            -- megast.Battle:getInstance():pauseUnit(0);
            this.fadeInAll(this);
            unit:resumeUnit();
            unit.m_IgnoreHitStopTime = 0;
            megast.Battle:getInstance():setBattleState(kBattleState_active);
            unit:setInvincibleTime(0);
            for i = 0,4 do
                local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
                if uni ~= nil then
                    
                    uni:excuteAction();
                end
            end
            
            if this.deathTarget ~= nil then
                local rand = LuaUtilities.rand(0,100);

                local baseRate = 100;
                -- local rateByAttack = 100 * this.deathTarget:getCalcPower()/this.consts.powerBorderOfDeath;

                if rand <= baseRate then
                    if this.deathTarget:isMyunit() then
                        this.deathTarget:setHP(1);
                    end
                    this.deathTarget:takeDamagePopup(unit,this.consts.skill3FixedDamage);
                end

                this.deathTarget = nil;
            end

            --霧モードなら霧を再展開
            if this.isMist and this.blackMist == nil  then
                this.blackMist = unit:addOrbitSystemCamera("blackmist_in",0);
                this.blackMist:takeAnimation(0,"blackmist_in",true);
                this.blackMist:setZOrder(8000);
            end
            return 1;
        end,

        addSP = function (this,unit)
            unit:addSP(20);
            return 1;
        end,

        bulletControll = function (bulletinstance)
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

            if framecnt <= 1 then
                

            elseif framecnt < 30 then
                sp = 1 + math.abs(30 - framecnt)/30 * speedOrigin*3;
            elseif framecnt < 600 then
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
               bulletinstance.bullet:takeAnimation(0,"explosion",false);  
            end

            local oneFrame = 0.016666666;

            moveByFloat(
                bulletinstance,
                calcXDir(degToRad(bulletinstance.angle),sp * unitManagerDeltaTime/oneFrame),
                calcYDir(degToRad(bulletinstance.angle),sp * unitManagerDeltaTime/oneFrame)
            );   

        end,

        getToPlayAnimeName = function(this,animename)
            if not this.isMist then
                if animename == "attack1" then
                    return "zcloneN"..animename;
                elseif animename == "attack2" then
                    return "zcloneN"..animename;
                elseif animename == "attack4" then
                    return "zcloneN"..animename;
                elseif animename == "damage" then
                    return "zcloneN"..animename;
                elseif animename == "out" then
                    return "zcloneN"..animename;
                elseif animename == "skill1" then
                    return "zcloneN"..animename;
                elseif animename == "skill2" then
                    return "zcloneN"..animename;
                elseif animename == "idle" then
                    return "zcloneN"..animename;
                end
            end
            return animename;
        end,

        bacume = function(this,unit)
            local targetUnit = this.deathTarget;
            if targetUnit ~= nil then
                local targetx = targetUnit:getPositionX();
                local destination = unit:getPositionX() + 400;
                local distance = destination - targetx;
                local limitX = 500;
                local oneFrame = 0.016666666;
                local moveSpeed = 7 * deltatime/oneFrame;
                local sign = distance/math.abs(distance); --距離が正か負かを判断する 1か-1になる

                --目的地を通り過ぎないようにするため、距離が移動速度より小さければ移動速度を距離と同じに
                if math.abs(distance) < moveSpeed then
                    moveSpeed = math.abs(distance);
                end

                targetUnit:setPosition(targetx + moveSpeed * sign,targetUnit:getPositionY());
                
            end
        end,


        glab = function(this,unit)
            local targetUnit = this.deathTarget;
            if targetUnit ~= nil then
                local destinationX = unit:getPositionX() + 400;
                local destinationY = unit:getPositionY() + 250;
                local targetMainX = targetUnit:getSkeleton():getBoneWorldPositionX("MAIN");
                local targetMainY = targetUnit:getSkeleton():getBoneWorldPositionY("MAIN");
                targetUnit:setPosition(destinationX - targetMainX,targetUnit:getPositionY());
                targetUnit:getSkeleton():setPositionY(destinationY - (targetMainY + targetUnit:getPositionY()));
            end
            return 1;
        end,


        findCurseForGuest = function(this,index)
            this.deathTarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
            return 1;
        end,

        mistIn = function(this,unit)
            this.blackMist:takeAnimation(0,"blackmist",true);
            return 1;
        end,

        fadeInUpdate = function(this,unit)
            frameRate = unitManagerDeltaTime/0.016666667;
            for i = 0,6 do
                local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
                if uni ~= nil then
                    opa = uni:getOpacity() + 6 * frameRate;
                    if opa > 255 then--オーバーフローさせないため
                        opa = 255;
                    end
                    uni:setOpacity(opa);
                end
            end
            this.fadeInFrame = this.fadeInFrame + 1 * frameRate;
            if this.fadeInFrame > 255/6 then
                this.fadeInFlag = false;
            end
            return 1;
        end,

        fadeInTargetUpdate = function(this,unit)
            frameRate = unitManagerDeltaTime/0.016666667;
            if this.deathTarget ~= nil then
                opa = this.deathTarget:getOpacity() + 6;
                if opa > 255 then--オーバーフローさせないため
                    opa = 255;
                end
                this.deathTarget:setOpacity(opa);

            end
            this.targetFadeInFrame = this.targetFadeInFrame + frameRate;
            if this.targetFadeInFrame > 255/6 then
                this.targetFadeInFlag = false;
            end
            return 1;
        end,

        fadeOutUpdate = function(this,unit)
            frameRate = unitManagerDeltaTime/0.016666667;
            for i = 0,6 do
                local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
                if uni ~= nil then
                    opa = uni:getOpacity() - 10 * frameRate;
                    if opa < 0 then--アンダーフローさせないため
                        opa = 0;
                    end
                    uni:setOpacity(opa);
                end
            end
            this.fadeOutFrame = this.fadeOutFrame + 1 * frameRate;
            if this.fadeOutFrame > 255/10 then
                this.fadeOutFlag = false;
            end
            return 1;
        end,

        specialUpdate = function(this,unit)
            if this.deathExcuteFlg then

                --全員停止
                megast.Battle:getInstance():pauseUnit(0.5);
                --死神だけ動く
                unit:resumeUnit();
                unit:setInvincibleTime(1);
            end

            if this.fadeOutFlag then
                this.fadeOutUpdate(this,unit);
            elseif this.targetFadeInFlag then
                this.fadeInTargetUpdate(this,unit);
            elseif this.fadeInFlag then
                this.fadeInUpdate(this,unit);
            end

            return 1;
        end,

        --共通変数
        param = {
          version = 1.3
          ,isUpdate = true
        },

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            this.findCurseForGuest(this,intparam);
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "skull" then return this.skull(this,unit) end
            if str == "onDestroy" then return this.onDestroy(this,unit) end
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "generalPause" then return this.generalPause(this,unit) end
            if str == "target" then return this.target(this,unit) end
            if str == "death" then return this.death(this,unit) end
            if str == "fadeInTarget" then return this.fadeInTarget(this,unit) end
            if str == "mistIn" then return this.mistIn(this,unit) end
            if str == "specialUpdate" then return this.specialUpdate(this,unit) end
            return 1;
        end,

        --version1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
            return value;
        end,

        takeBreake = function (this,unit)
            this.isMist = false;
            this.mistCounter = 0;
            local fog = unit:getTeamUnitCondition():findConditionWithID(this.consts.fogBuffID);
            if fog ~= nil then
                unit:getTeamUnitCondition():removeCondition(fog);
            end
            local breakDebuff = unit:getTeamUnitCondition():findConditionWithID(this.consts.breakDebuffID);
            if breakDebuff ~= nil then
                unit:getTeamUnitCondition():removeCondition(breakDebuff);
            end
            
            if this.blackMist ~= nil then
                this.blackMist:takeAnimation(0,"blackmist_out",false);    
            end
                megast.Battle:getInstance():setBackGroundColor(3000,255,255,255);
            this.blackMist = nil;
            this.bleakTimer = os.time();
            this.suesideShot(this,unit);
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
            this.updateStarted = true;
            if table.maxn(this.bullets) > 0 then
                for i = 1,table.maxn(this.bullets) do
                    this.bulletControll(this.bullets[i]);
                end
            end
            if this.fadeOutFlag then
                this.fadeOutUpdate(this,unit);
            elseif this.targetFadeInFlag then
                this.fadeInTargetUpdate(this,unit);
            elseif this.fadeInFlag then
                this.fadeInUpdate(this,unit);
            end

            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            -- if LuaUtilities.rand(0,100) < 10 then
            --     enemy:getTeamUnitCondition():addCondition(this.consts.curseBuffID,this.consts.curseBuffID,1,2000,0);
            -- end
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            print("takedamage");
            --this.skullSpawnByDamage(this,enemy,unit);
            return value;
        end,

        --version1.0
        start = function (this , unit)
            -- unit:setMix("attack1","idle" , 0.2);
            -- unit:setMix("attack2","idle" , 0.2);
            -- unit:setMix("skill1" ,"idle", 0.2);
            -- unit:setMix("in" ,"idle", 0.2);
            unit:setSPGainValue(0);
           
            this.myself = unit;

            this.ishost = megast.Battle:getInstance():isHost();
            
            unit:getTeamUnitCondition():addCondition(
                this.consts.fogBuffID,
                this.consts.fogBuffEffectID,
                this.consts.fogBuffValue,
                this.consts.fogBuffTime,
                this.consts.fogBuffIconID
            );
            
            unit:getTeamUnitCondition():addCondition(
                this.consts.breakDebuffID,
                this.consts.breakDebuffEffectID,
                this.consts.breakDebuffValue,
                this.consts.breakDebuffTime,
                this.consts.breakDebuffIconID
            );
            
            if this.isMist and this.blackMist == nil  then
                this.blackMist = unit:addOrbitSystemCamera("blackmist_in",0);
                this.blackMist:takeAnimation(0,"blackmist_in",true);
                megast.Battle:getInstance():setBackGroundColor(3000,230,230,150);
                this.blackMist:setZOrder(8000);
            end

            return 1;
        end,

        excuteAction = function (this , unit)
            this.deathExcuteFlg = false;
            local rand = LuaUtilities.rand(0,100);
            if rand <= 25 and unit:getAnimationPositionX() > -100 then
                unit:takeBack();
                return 0;
            end
            unit.m_IgnoreHitStopTime = 0;
            return 1;
        end,

        takeIdle = function (this , unit)
            unit:takeAnimation(0,this.getToPlayAnimeName(this,"idle"),true);
            --unit:setNextAnimationName(this.getToPlayAnimeName(this,"idle"));
            return 0;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
         
            return 1;
        end,

        takeAttack = function (this , unit , index)
            if index == 1 then
                unit:setActiveSkill(1);
                unit:setNextAnimationName(this.getToPlayAnimeName(this,"attack1"));
            elseif index == 2 then
                unit:setActiveSkill(2);
                unit:setNextAnimationName(this.getToPlayAnimeName(this,"attack2"));
            elseif index == 3 then
                this.isMist = true;

                unit:getTeamUnitCondition():addCondition(
                    this.consts.fogBuffID,
                    this.consts.fogBuffEffectID,
                    this.consts.fogBuffValue,
                    this.consts.fogBuffTime,
                    this.consts.fogBuffIconID
                );
                
                unit:getTeamUnitCondition():addCondition(
                    this.consts.breakDebuffID,
                    this.consts.breakDebuffEffectID,
                    this.consts.breakDebuffValue,
                    this.consts.breakDebuffTime,
                    this.consts.breakDebuffIconID
                );

                if this.isMist and this.blackMist == nil  then
                    this.blackMist = unit:addOrbitSystemCamera("blackmist_in",0);
                    this.blackMist:takeAnimation(0,"blackmist_in",true);
                    megast.Battle:getInstance():setBackGroundColor(3000,230,230,150);
                    this.blackMist:setZOrder(8000);
                end
            elseif index == 4 then
                unit:setNextAnimationName(this.getToPlayAnimeName(this,"attack4"));
            end
            if unit:getTargetUnit() ~= nil then
                this.BeforetargetUnitIndex = unit:getTargetUnit():getIndex();
            end
            
            if this.ishost then
                if not this.attackChecker then
                    
                    local rand = LuaUtilities.rand(0,100);
                    this.attackChecker = true;
                    if rand < this.rates.attack1Rate then
                        unit:takeAttack(1);
                    elseif rand < this.rates.attack1Rate + this.rates.attack2Rate then
                        unit:takeAttack(2);
                    elseif not this.isMist and this.mistCounter > this.consts.fogCoolTurn then
                        unit:takeAttack(3);
                    else
                        unit:takeAttack(4);
                    end
                    return 0;
                    
                end
                this.attackChecker = false;
            end
            
            this.mistCounter = this.mistCounter +1;
            return 1;
        end,

        takeSkill = function (this,unit,index)
            if index == 1 then
                unit:setActiveSkill(4);
                unit:setNextAnimationName(this.getToPlayAnimeName(this,"skill1"));
            elseif index == 2 then
                 unit:setActiveSkill(6);
                unit:setNextAnimationName(this.getToPlayAnimeName(this,"skill2"));
            else
                 unit:setActiveSkill(5);
                 unit:setInvincibleTime(3);
                 --一時的に霧は消しておく
                if this.blackMist ~= nil then
                    this.blackMist:takeAnimation(0,"blackmist_out",false);    
                end
                this.blackMist = nil;
            end
            if unit:getTargetUnit() ~= nil then
                this.BeforetargetUnitIndex = unit:getTargetUnit():getIndex();
            end
            
            if this.ishost then
                if not this.skillChecker then
                    local target = unit:getTargetUnit()
                    local distance = BattleUtilities.getUnitDistance(unit,target)
                    local rand = LuaUtilities.rand(100);
                    this.skillChecker = true;
                    if this.findCursedAtRandom(this) ~= nil then
                        if rand < this.rates.skill1RateC then
                            unit:takeSkill(1);
                        else 
                            unit:takeSkill(3);
                            
                        end
                    else
                        if rand < this.rates.skill1Rate then
                            unit:takeSkill(1);
                        else
                            unit:takeSkill(2);
                        end
                    end
                    return 0;
                end
            end
            this.skillChecker = false;
            return 1;
        end,

        takeDamage = function (this , unit)
            unit:setNextAnimationName(this.getToPlayAnimeName(this,"damage"));
        
            if megast.Battle:getInstance():getBattleState() == kBattleState_pause then
                this.fadeInAll(this);
                unit.m_IgnoreHitStopTime = 0;
                megast.Battle:getInstance():setBattleState(kBattleState_active);
                unit:setInvincibleTime(0);
            end            
            return 1;
        end,

        dead = function (this , unit)
            unit:setNextAnimationName(this.getToPlayAnimeName(this,"dead"));
            this.suesideShot(this,unit);
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
