function new(id)
    print("10000 new ");
    local instance = {
        thisID = id,
        skillChecker = false,
        attackChecker = false,
        isLockOn = false,
        isRage = false,
        isFireEnd = false,
        rageCoolTurnCount = 0,
        neckAngle = 0,
        neckAngleDeffault = 321,
        shotAngle = 0,
        myself = nil,
        attackdelayOriginal = 0,
        rageTimer = 0,
        rageSPUpValue = 20,
        messages = summoner.Text:fetchByUnitID(500133313),


        rates = {
            --通常攻撃の確率　アタック３は使わない
            attack1 = 20,
            attack2 = 35,
            attack4 = 45,

            --スキルの確率
            skill1 = 50,
            skill2 = 50
        },

        consts = {
            rageHP = 75, --怒り状態に移行するHP １００分率
            rageCoolTurn = 6, --怒りが収まってから次の怒り状態に移行するまでの必要行動数
            rageRivision = 3, --HP減少による怒りやすさ
            HPRegenationBuffID = 7,
            HPRegenationBuffValue = 500,
            HPRegenationBuffTime = 2000,
            HPRegenationBuffIcon = 35,
            rageHealBreakValue = 600,
            barnBreakDamageParSecond = 200,--燃焼を受けた時のブレイクダメージ/秒
            barnDown = 100 --怒り時の燃焼耐性低下率
        },

        targetLock = function (this,unit)
            this.isLockOn = true;
            this.neckAngle = 321;
            return 1;
        end,

        fire = function (this,unit)
            local shot = unit:addOrbitSystem("fireball",1)
            shot:setActiveSkill(1);
            shot:setHitCountMax(1);
            shot:setEndAnimationName("explosion")
            -- shot:EnabledFollow = true;
            local x = unit:getPositionX();
            local y = unit:getPositionY();
            local xb = unit:getSkeleton():getBoneWorldPositionX("EF_fire_mouth");
            local yb = unit:getSkeleton():getBoneWorldPositionY("EF_fire_mouth");
            shot:setPosition(x+xb,y+yb);
            -- getDeg(x+xb,y+yb,unit:getTargetUnit():getAnimationPositionX(),unit:getTargetUnit():getAnimationPositionY());
            shot:setRotation(-this.neckAngle);
            this.shotAngle = this.neckAngle;
            shot:setZOrder(unit:getZOrder() -1);
            this.isFireEnd = true;

            return 1;
        end,

        setFire = function (this,unit)
            if not this.isRage then
                return 1;
            end
            local shot = unit:addOrbitSystem("firePiller",2)
            shot:setHitCountMax(999);
            shot:setEndAnimationName("fireEnd");
            -- shot:EnabledFollow = true;
            local x = unit:getPositionX();
            local y = unit:getPositionY();
            local xb = 0;
            local yb = 0;

            local rand = math.random(5);

            if rand == 1 then
                xb = 300;
            elseif rand == 2 then
                xb = 350;
                yb = -100;
            elseif rand == 3 then
                xb = 400;
                yb = 50;
            elseif rand == 4 then
                xb = 500;
            elseif rand == 5 then
                xb = 600;
                yb = 100;
            end

            
            shot:setPosition(x+xb,y+yb);
            shot:setAutoZOrder(true);
            shot:setZOderOffset(-5000);

            return 1;
        end,

        explosion = function (this,unit)
            -- local shot = this.myself:addOrbitSystem("explosion",0)
            -- -- shot:EnabledFollow = true;
            -- local x = unit:getPositionX();
            -- local y = unit:getPositionY();
            -- -- local xb = this.myself:getSkeleton():getBoneWorldPositionX("head");
            -- -- local yb = this.myself:getSkeleton():getBoneWorldPositionY("head");
            
            -- shot:setPosition(x + math.cos(degToRad(this.shotAngle))*321,y + math.sin(degToRad(this.shotAngle))*321);
            -- shot:setActiveSkill(1);
            return 1;
        end,

        attack5ArmControll = function(this,unit)
            this.boneRotation(this,unit,"head");
            return 1;
        end,

        boneRotation = function (this,unit,boneName)
            if not this.isFireEnd then
                unit:getSkeleton():setBoneRotation(boneName,this.calcDeg(this,unit,boneName));
            else
                unit:getSkeleton():setBoneRotation(boneName,this.calcDegForEnd(this,unit,boneName));
            end
            return 1;
        end,

        addSP = function (this , unit)
            print("addSP");
            unit:addSP(this.rageSPUpValue);
            return 1;
        end,

        calcDeg = function(this,unit,boneName)
            local target = unit:getTargetUnit();
            if target ~= nil then
                local x = unit:getPositionX();
                local y = unit:getPositionY();
                local xb = unit:getSkeleton():getBoneWorldPositionX(boneName);
                local yb = unit:getSkeleton():getBoneWorldPositionY(boneName);
                local tx = target:getPositionX();
                local ty = target:getPositionY();
                local txb = target:getSkeleton():getBoneWorldPositionX("MAIN");
                local tyb = target:getSkeleton():getBoneWorldPositionY("MAIN");
                local targetangle = getDeg(x+xb,y+yb,tx+txb,ty+tyb) + 18;

                if targetangle < 0 then
                    targetangle = 360 + targetangle;
                end


                local dir = targetangle - this.neckAngle;

                if dir > 180 then
                    dir = -(360 - dir);
                end

                if dir < -180 then
                    dir = (360 + dir);
                end

                if dir ~= 0 then
                    local maxdir = 1 * unitManagerDeltaTime/0.016666667;
                    if dir > maxdir then
                        dir = maxdir;
                    elseif dir < -maxdir then
                        dir = -maxdir;
                    end
                end
                this.neckAngle = this.neckAngle + dir;

                if this.neckAngle > 360 then
                    this.neckAngle = this.neckAngle % 360;
                end

                if this.neckAngle < 0 then
                    this.neckAngle = 360 - this.neckAngle;
                end

                if this.neckAngle < 270  and this.neckAngle > 180 then
                    this.neckAngle = 270;
                elseif this.neckAngle > 90 and this.neckAngle <= 180 then
                    this.neckAngle = 90;
                end

                return this.neckAngle;
            end
            return 0;
        end,

        calcDegForEnd = function(this,unit,boneName)

            local targetangle = this.neckAngleDeffault;
            -- local angle = unit:getSkeleton():getBoneRotation(boneName);
        
            --local angle = this.neckAngle;
            if targetangle < 0 then
                targetangle = 360 + targetangle;
            end


            local dir = targetangle - this.neckAngle;

            if dir > 180 then
                dir = -(360 - dir);
            end

            if dir < -180 then
                dir = (360 + dir);
            end

            if dir ~= 0 then
                local maxdir = 1 * unitManagerDeltaTime/0.016666667;
                if dir > maxdir then
                    dir = maxdir;
                elseif dir < -maxdir then
                    dir = -maxdir;
                end
            end
            this.neckAngle = this.neckAngle + dir;

            if this.neckAngle > 360 then
                this.neckAngle = this.neckAngle % 360;
            end

            if this.neckAngle < 0 then
                this.neckAngle = 360 - this.neckAngle;
            end

            -- if this.neckAngle < 270  and this.neckAngle > 180 then
            --     this.neckAngle = 270;
            -- elseif this.neckAngle > 90 and this.neckAngle <= 180 then
            --     this.neckAngle = 90;
            -- end
            print(dir);
            return this.neckAngle;
        end,

        startFire = function(this,unit)
            local headangle = unit:getSkeleton():getBoneRotation("head");

            this.neckAngle = headangle;
            this.neckAngleDeffault = headangle;
            print("start fire");
            return 1;
        end,

        addBuff = function(this,unit)
            unit:getTeamUnitCondition():addCondition(this.consts.HPRegenationBuffID,this.consts.HPRegenationBuffID,this.consts.HPRegenationBuffValue,this.consts.HPRegenationBuffTime,this.consts.HPRegenationBuffIcon);
            unit:getTeamUnitCondition():addCondition(-11,25,10,2000,9);
            unit:getTeamUnitCondition():addCondition(-12,24,20,2000,0);
            unit:getTeamUnitCondition():addCondition(-13,109,-this.consts.barnDown,2000,76);
            -- unit:getTeamUnitCondition():addCondition(-14,97,this.consts.barnDown,30,76);--燃焼テスト用
            this.isRage = true;

            local mess1Color = {
                r = 50,
                g = 255,
                b = 0
            };
            local mess2Color = {
                r = 50,
                g = 255,
                b = 0
            };
            local mess3Color = {
                r = 255,
                g = 0,
                b = 28
            };

            local messageDuration = 7;

            BattleControl:get():pushEnemyInfomation(this.messages.mess1,mess1Color.r,mess1Color.g,mess1Color.b,messageDuration);
            BattleControl:get():pushEnemyInfomation(this.messages.mess2,mess2Color.r,mess2Color.g,mess2Color.b,messageDuration);
            BattleControl:get():pushEnemyInfomation(this.messages.mess3,mess3Color.r,mess3Color.g,mess3Color.b,messageDuration);

            return 1;
        end,

        rageEnd = function(this,unit)
            
            if this.isRage then
                this.isRage = false;
                this.rageTimer = 0;
                this.rageSPUpValue = 20;
                unit:setAttackDelay(this.attackdelayOriginal);
                unit:setSetupAnimationName("setUpNormal");
                unit:takeAnimation(1,"empty",false);

                local randomRange = 2;
                local hpRivision = 5 - (5 * unit:getHP()/unit:getCalcHPMAX());

                this.rageCoolTurnCount = hpRivision + math.random(randomRange) - randomRange/2 ;

                local buff =  unit:getTeamUnitCondition():findConditionWithID(-12);
                if not(buff == nil) then
                    local conditon = unit:getTeamUnitCondition():findConditionWithID(-12);
                    unit:getTeamUnitCondition():removeCondition(conditon);
                end
                local buff2=  unit:getTeamUnitCondition():findConditionWithID(this.consts.HPRegenationBuffID);
                if not(buff2== nil) then
                    local conditon = unit:getTeamUnitCondition():findConditionWithID(this.consts.HPRegenationBuffID);
                    unit:getTeamUnitCondition():removeCondition(conditon);
                end
                local buff3 =  unit:getTeamUnitCondition():findConditionWithID(-11);
                if not(buff3 == nil) then
                    local conditon = unit:getTeamUnitCondition():findConditionWithID(-11);
                    unit:getTeamUnitCondition():removeCondition(conditon);
                end
                local buff4 =  unit:getTeamUnitCondition():findConditionWithID(-13);
                if not(buff4 == nil) then
                    local conditon = unit:getTeamUnitCondition():findConditionWithID(-13);
                    unit:getTeamUnitCondition():removeCondition(conditon);
                end
            end

            local message1 = this.messages.mess4;

            local mess1Color = {
                r = 255,
                g = 255,
                b = 255
            };
            

            local messageDuration = 4;

            BattleControl:get():pushEnemyInfomation(message1,mess1Color.r,mess1Color.g,mess1Color.b,messageDuration);

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
            this.rageEnd(this,this.myself);
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "targetLock" then return this.targetLock(this,unit) end
            if str == "fire" then return this.fire(this,unit) end
            if str == "setFire" then return this.setFire(this,unit) end
            if str == "explosion" then return this.explosion(this,unit) end
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "startFire" then return this.startFire(this,unit) end
            if str == "addBuff" then return this.addBuff(this,unit) end
            return 1;
        end,

                --version 1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
            return value;
        end,

        takeBreake = function (this,unit)
            this.rageEnd(this,unit);
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
            if this.isLockOn then
                this.attack5ArmControll(this,unit);
            end

            local condValue = unit:getTeamUnitCondition():findConditionValue(97);

            if condValue ~= 0 then
                unit:setBreakPoint(unit:getBreakPoint() - this.consts.barnBreakDamageParSecond * deltatime);
            end

            if this.isRage then


                if condValue == 0 then

                    local buff_ =  unit:getTeamUnitCondition():findConditionWithID(this.consts.HPRegenationBuffID);
                    if buff_ == nil then
                        local message1 = this.messages.mess5;

                        local mess1Color = {
                            r = 50,
                            g = 255,
                            b = 0
                        };
                        

                        local messageDuration = 4;

                        BattleControl:get():pushEnemyInfomation(message1,mess1Color.r,mess1Color.g,mess1Color.b,messageDuration);
                        unit:getTeamUnitCondition():addCondition(this.consts.HPRegenationBuffID,this.consts.HPRegenationBuffID,this.consts.HPRegenationBuffValue,this.consts.HPRegenationBuffTime,this.consts.HPRegenationBuffIcon);
                    end
                    unit:setBreakPoint(unit:getBreakPoint() + this.consts.rageHealBreakValue * deltatime);

                else

                    local buff_ =  unit:getTeamUnitCondition():findConditionWithID(this.consts.HPRegenationBuffID);
                    if not(buff_ == nil) then
                        
                        local message1 = this.messages.mess6;

                        local mess1Color = {
                            r = 255,
                            g = 0,
                            b = 0
                        };
                        

                        local messageDuration = 3;

                        BattleControl:get():pushEnemyInfomation(message1,mess1Color.r,mess1Color.g,mess1Color.b,messageDuration);

                        local conditon = unit:getTeamUnitCondition():findConditionWithID(this.consts.HPRegenationBuffID);
                        unit:getTeamUnitCondition():removeCondition(conditon);
                    end

                end

                local ishost = megast.Battle:getInstance():isHost();
                if ishost then
                    this.rageTimer = this.rageTimer + deltatime;
                    if this.rageTimer > 60 then
                        this.rageEnd(this,unit);
                        megast.Battle:getInstance():sendEventToLua(this.thisID,1,1);
                    end
                end
                
            end

            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)

            if this.isRage then

            end

            return value;
        end,

        --version1.0
        start = function (this , unit)
            unit:setSPGainValue(0);
            this.attackdelayOriginal = unit:getAttackDelay();
            this.myself = unit;
            unit:setSetupAnimationName("setUpNormal");

            unit:takeAnimation(1,"empty",false);
            this.rageSPUpValue = 20;

            this.rageCoolTurnCount = this.consts.rageCoolTurn;--初回怒りは５０％切ればスタート直後からでも発動するようにしておく
            unit:setZOderOffset(-100);--若干後ろに表示させたい
            return 1;
        end,

        excuteAction = function (this , unit)
            this.isLockOn = false;
            this.isFireEnd = false;
            
            return 1;
        end,

        takeIdle = function (this , unit)
            if not this.isRage then
                unit:setNextAnimationName("zcloneNidle");
            end
            return 1;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
            if not this.isRage then
                unit:setNextAnimationName("zcloneNback");
            end
            return 1;
        end,

        takeAttack = function (this , unit , index)
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                local target = unit:getTargetUnit() 
                local distance = BattleUtilities.getUnitDistance(unit,target)

                local hpparcent = 100 * unit:getHP()/unit:getCalcHPMAX();

                if this.attackChecker == false and hpparcent < this.consts.rageHP and not this.isRage and this.rageCoolTurnCount > this.consts.rageCoolTurn then
                    this.attackChecker = true;
                    unit:takeAttack(5);
                   return 0;
                end
        
                if distance > 400 and this.attackChecker == false then
                    this.attackChecker = true
                    unit:takeAttack(3)
                    return 0;
                elseif this.attackChecker == false then

                    this.attackChecker = true;
                    local rand = math.random(100);
                    if rand <= this.rates.attack1 then
                        unit:takeAttack(1);
                    elseif  rand <=  this.rates.attack1 + this.rates.attack2 then
                        unit:takeAttack(2);
                    elseif rand <= 100 then
                        unit:takeAttack(4);
                    end
                    return 0;
                end
                this.attackChecker = false;
            end
            
            this.rageCoolTurnCount = this.rageCoolTurnCount + 1;

            if index == 1 then
                if not this.isRage then
                    --なぜかsetNextAnimationNameだと角度計算がおかしくなるためここだけtakeAnimationで対処
                    unit:takeAnimation(0,"zcloneNattack1",false);
                end
            elseif index == 2 then
                if not this.isRage then
                    unit:setNextAnimationName("zcloneNattack2");
                end
                unit:setActiveSkill(2);
            elseif index == 3 then
                if not this.isRage then
                    unit:setNextAnimationName("zcloneNattack3");
                end
                unit:setActiveSkill(3);
            elseif index == 4 then
                if not this.isRage then
                    unit:setNextAnimationName("zcloneNattack4");
                end
                unit:setActiveSkill(4);
            elseif index == 5 then
                --怒り移行時に行う処理はこっちに持ってきました（ホストゲストともに通る場所なので攻撃さえ同期されていればいい）-----
                unit:setSetupAnimationName("setUpFire");
                unit:takeAnimation(1,"reaf",true);
                this.rageSPUpValue = 40;
                unit:setAttackDelay(this.attackdelayOriginal/2);
                -------------------------------------------------
                if not this.isRage then
                    unit:setNextAnimationName("zcloneNattack5");
                    unit:setActiveSkill(5);
                end
            end

            return 1;
        end,

        takeSkill = function (this,unit,index)
            if index == 1 then
                unit:setActiveSkill(7);
                if not this.isRage then
                    unit:setNextAnimationName("zcloneNskill1");
                    unit:setActiveSkill(6);
                end
                
            elseif index == 2 then
                if not this.isRage then
                    unit:setNextAnimationName("zcloneNskill2");
                end
                unit:setActiveSkill(8);
            elseif index == 3 then
                unit:setActiveSkill(4);
            elseif index == 4 then
                unit:setActiveSkill(5);
            end
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                if this.skillChecker == false then
                    this.skillChecker = true;
                    local rand = math.random(100);
                    if rand <= this.rates.skill1 then
                        unit:takeSkill(1);
                    elseif rand <= 100 then
                        unit:takeSkill(2);
                    end
                    return 0;
                end
                this.skillChecker = false;
            end            
            return 1;
        end,

        takeDamage = function (this , unit)
            if not this.isRage then
                
            end
            return 1;
        end,

        dead = function (this , unit)
            if not this.isRage then
                unit:setNextAnimationName("zcloneNout");
            end
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

