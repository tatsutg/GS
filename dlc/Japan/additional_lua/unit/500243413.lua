function new(id)
    print("10000 new ");
    local instance = {
        forms = {
            none = 0,
            sword = 1,
            spear = 2,
            bow = 3
        },
        animationNames = {
            idleNone = "idle",
            idleSword = "idle2",
            idleSpear = "idle3",
            idleBow = "idle4",
            backNone = "back1",
            backSword = "back2",
            backSpear = "back3",
            backBow = "back4",
            teleportNone = "teleport1",
            teleportSword = "teleport2",
            teleportSpear = "teleport3",
            teleportBow = "teleport4",
            setUpNormal = "setUpNormal",
            setUpSword = "setUpSword",
            setUpSpear = "setUpSpear",
            setUpBow = "setUpBow"
        },
        rates = {
            skill1 = 35,
            skill2 = 35,
            skill3 = 30
        },
        consts = {
            formResetTurn = 2,
            backDistance = 250,
            spGainValue = 20,
            endlessHP1 = 75,
            endlessHP2 = 50,
            endlessHP3 = 25
            
        },
        endressPositions = {
            firstX = 100,
            firstY = 80,
            
            secondX = 200,
            secondY = 25,
            
            thirdX = 120,
            thirdY = -20,

            fourthX = 220,
            fourthY = -80
        },
        endlessOrbits = {
            ef1 = nil,
            ef2 = nil,
            ef3 = nil,
            ef4 = nil
        },


        form = 0,
        formTurns = 0,
        skillChecker = false,
        attackChecker = false,
        teleportChecker = false,
        teleportAction = nil,
        nextAction = nil,
        beforTargetUnitIndex = 0,
        positionYDefault = 0,
        endless1flag = false,
        endless2flag = false,
        endless3flag = false,
        skill2CameraTimer = 0,


        isBacume = false,--現在吸引中かどうか
        bacumeSpeed = 5,--１フレームあたりの吸引距離


        back = function(this,unit)
            unit:setPosition(unit:getPositionX() - this.consts.backDistance,this.positionYDefault);
            return 1;
        end,

        askNext = function(this,unit)
            if this.nextAction == this.attack then
                local distance = 0;
                if this.form == this.forms.none then
                    distance = -200;
                elseif this.form == this.forms.sword then
                    distance = -250;
                elseif this.form == this.forms.spear then
                    distance = -250;
                elseif this.form == this.forms.bow then
                    distance = - 400;
                end
                local isPlayerTeam = true;
                local targetUnit = megast.Battle:getInstance():getTeam(isPlayerTeam):getTeamUnit(this.beforTargetUnitIndex);

                if targetUnit ~= nil then
                    unit:setPosition(targetUnit:getPositionX() + distance,this.positionYDefault);
                end
            else
                if this.teleportAction == change then
                    this.change(this,unit);
                    this.randomPosition(this,unit);
                    this.teleportAction = nil;
                end
            end
            
            

            return 1;
        end,

        executeNext = function(this,unit)
            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if this.nextAction ~= nil and hpParcent < 30 then
                this.nextAction(this,unit);
            end
            return 1;
        end,

        executeNext2 = function(this,unit)
            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if this.nextAction ~= nil and hpParcent < 60 then
                this.nextAction(this,unit);
            end
            return 1;
        end,

        executeNext3 = function(this,unit)
            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if this.nextAction ~= nil then
                this.nextAction(this,unit);
                this.nextAction = nil;
            end
            return 1;
        end,

        addSP = function(this,unit)
            unit:addSP(this.consts.spGainValue);
            return 1;
        end,


        attack = function(this,unit)
            unit:takeAttack(1);
            return 1;
        end,

        change = function(this,unit)
            if this.form == this.forms.none then
                unit:takeAnimation(0,"tpAppear1",false);
                unit:takeAnimationEffect(0,"tpAppear",false);
            elseif this.form == this.forms.sword then
                unit:takeAnimation(0,"tpAppear2",false);
                unit:takeAnimationEffect(0,"tpAppear",false);
            elseif this.form == this.forms.spear then
                unit:takeAnimation(0,"tpAppear3",false);
                unit:takeAnimationEffect(0,"tpAppear",false);
            elseif this.form == this.forms.bow then
                unit:takeAnimation(0,"tpAppear4",false);
                unit:takeAnimationEffect(0,"tpAppear",false);
            end
            return 1;
        end,

        releace = function(this,unit)
            unit:takeAnimation(0,"release",false);
            unit:takeAnimationEffect(0,"release",false);
            unit:setSetupAnimationName(this.animationNames.setUpNormal);
            return 1;
        end,

        weaponAppear = function(this,unit)
            if this.form == this.forms.sword then
                unit:takeAnimation(0,"weaponAppearSword",false);
                unit:takeAnimationEffect(0,"weaponAppearSword",false);
            elseif this.form == this.forms.spear then
                unit:takeAnimation(0,"weaponAppearSpear",false);
                unit:takeAnimationEffect(0,"weaponAppearSpear",false);
            elseif this.form == this.forms.bow then
                unit:takeAnimation(0,"weaponAppearBow",false);
                unit:takeAnimationEffect(0,"weaponAppearBow",false);
            end
            unit:setSetupAnimationName("setUpHide");
            return 1;
        end,

        weaponAppearEnd = function(this,unit)
            this.change(this,unit);
            return 1;
        end,

        getTeleportAnimationName = function(this,unit)
            local animName = "";
            if this.form == this.forms.none then
               animName = this.animationNames.teleportNone;
            elseif this.form == this.forms.sword then
               animName = this.animationNames.teleportSword;
            elseif this.form == this.forms.spear then
                animName = this.animationNames.teleportSpear;
            elseif this.form == this.forms.bow then
               animName = this.animationNames.teleportBow;
            end
            return animName;
        end,

        setUpPoseRegistger = function(this,unit)
            if this.form == this.forms.none then
                unit:setSetupAnimationName(this.animationNames.setUpNormal);
            elseif this.form == this.forms.sword then
                unit:setSetupAnimationName(this.animationNames.setUpSword);
            elseif this.form == this.forms.spear then
                unit:setSetupAnimationName(this.animationNames.setUpSpear);
            elseif this.form == this.forms.bow then
                unit:setSetupAnimationName(this.animationNames.setUpBow);
            end
            
            return 1;
        end,

        randomPosition = function(this,unit)
            unit:setPosition(LuaUtilities.rand(600) - 300,LuaUtilities.rand(300) - 150);
            return 1;
        end,

        --吸引開始
        Suction = function (this,unit)
           
            this.isBacume = true;
            return 1;
        end,
        

        --吸引終了
        SuctionEnd = function (this,unit)
            --吸引フラグを折る　
            this.isBacume = false;
            return 1;
        end,
        
        silence = function(this,unit)
                --全員沈黙させる
                for i = 0,6 do
                    local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
                    if uni ~= nil then
                        uni:getTeamUnitCondition():addCondition(-12,92,100,20,0);    
                    end
                end
            return 1;
        end,

        endless = function(this,unit)
            this.endlessOrbits.ef1 = unit:addOrbitSystemWithFile("50024Skill4Ef","skill4");
            this.endlessOrbits.ef2 = unit:addOrbitSystemCameraWithFile("50024Skill4Ef2","skill4",false);
            this.endlessOrbits.ef3 = unit:addOrbitSystemWithFile("50024Skill4Ef3","skill4");
            this.endlessOrbits.ef4 = unit:addOrbitSystem("skill4Effect",0);

            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            --エンドレス１回目を実行しましたフラグを立てる。
            if hpParcent <= this.consts.endlessHP1 and hpParcent > this.consts.endlessHP2 and not this.endless1flag then
                this.endless1flag = true;
                
            end

            --２回目
            if hpParcent <= this.consts.endlessHP2 and hpParcent > this.consts.endlessHP3 and not this.endless2flag then
                this.endless2flag = true;
            end

            --３回目
            if hpParcent <= this.consts.endlessHP3 and not this.endless3flag then
                this.endless3flag = true;
            end
            
            return 1;
        end,


        criticalHit = function(this,unit)
            unit:getTeamUnitCondition():addCondition(22,22,200,15,0);
            return 1;
        end,

       

        skill2camera = function(this,unit,time)
            this.skill2CameraTimer = time;
            return 1;
        end,




        --共通変数
        param = {
          version = 1.3
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
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "back" then return this.back(this,unit) end
            if str == "askNext" then return this.askNext(this,unit) end
            if str == "executeNext" then return this.executeNext(this,unit) end
            if str == "executeNext2" then return this.executeNext2(this,unit) end
            if str == "executeNext3" then return this.executeNext3(this,unit) end
            if str == "weaponAppearEnd" then return this.weaponAppearEnd(this,unit) end
            if str == "randomPosition" then return this.randomPosition(this,unit) end
            if str == "Suction" then return this.Suction(this,unit) end
            if str == "endless" then return this.endless(this,unit) end
            if str == "SuctionEnd" then return this.SuctionEnd(this,unit) end
            if str == "criticalHit" then return this.criticalHit(this,unit) end
            if str == "silence" then return this.silence(this,unit) end

            arg = string.match(str, "skill2camera(%w+)")
            if arg ~= nil then this.skill2camera(this,unit,tonumber(arg)) end
            return 1;
        end,

        --version1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
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
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            



            --吸引中ならアップデートで吸引する
            if this.isBacume then
                --自分から見て敵側のユニットを全部取得(ユニットは最大でも６体までなので６回)
                for i = 0,6 do
                    --指定されたインデックスでユニットを取得
                    local targetUnit = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
                    if targetUnit ~= nil then
                        local targetx = targetUnit:getPositionX();
                        local targety = targetUnit:getPositionY();
                        local thisx = unit:getPositionX();
                        local thisy = unit:getPositionY();


                        --ターゲットのPTインデックスによって吸引先を変える
                        if i == 0 then
                            thisx = thisx + this.endressPositions.firstX;
                            thisy = thisy + this.endressPositions.firstY;
                        elseif i == 1 then
                            thisx = thisx + this.endressPositions.secondX;
                            thisy = thisy + this.endressPositions.secondY;
                        elseif i == 2 then
                            thisx = thisx + this.endressPositions.thirdX;
                            thisy = thisy + this.endressPositions.thirdY;
                        else
                            thisx = thisx + this.endressPositions.fourthX;
                            thisy = thisy + this.endressPositions.fourthY;
                        end


                        local distance = (targetx-thisx)*(targetx-thisx)+(targety-thisy)*(targety-thisy);--sqrtは重いため距離は二乗したままつかう
                        local oneFrame = 0.016666666;
                        local moveSpeed = this.bacumeSpeed * deltatime/oneFrame; --フレームレートで吸引距離が変わらないようにするためdeltaを60fpsで割って掛け算
                        local radius = 20; --この半径以下以下の距離ならば吸引処理はしないでよし
                        
                        
                        if distance > radius*radius then
                            local rad = getRad(targetx,targety,thisx,thisy);

                            targetUnit:setPosition(targetx + calcXDir(rad,moveSpeed),targety + calcYDir(rad,moveSpeed));       
                        end
                        
                        
                             
                    end
                end
                
            end

            if this.skill2CameraTimer > 0 then
                this.skill2CameraTimer = this.skill2CameraTimer - deltatime;
                local xb = unit:getSkeleton():getBoneWorldPositionX("CAMERA");
                local yb = unit:getSkeleton():getBoneWorldPositionY("CAMERA");
                unit:cameraLock(0,0.1,xb,yb);
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
           
            unit:setSPGainValue(0);
            this.positionYDefault = unit:getPositionY();
            return 1;
        end,

        excuteAction = function (this , unit)
            local buff =  unit:getTeamUnitCondition():findConditionWithID(50024);
            if not(buff == nil) then
                local conditon = unit:getTeamUnitCondition():findConditionWithID(50024);
                unit:getTeamUnitCondition():removeCondition(conditon);
            end

            --エンドレス判定
            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            local isEndless = false;

            --エンドレス１回目
            if hpParcent <= this.consts.endlessHP1 and hpParcent > this.consts.endlessHP2 and not this.endless1flag then
                isEndless = true;
                
            end

            --２回目
            if hpParcent <= this.consts.endlessHP2 and hpParcent > this.consts.endlessHP3 and not this.endless2flag then
                isEndless = true;
                
            end

            --３回目
            if hpParcent <= this.consts.endlessHP3 and not this.endless3flag then
                isEndless = true;
                
            end
            
            if isEndless then
                if unit:getPositionX() > 0 then
                    unit:takeBack();
                    return 0;
                end
          
                this.skillChecker = true;
                unit:takeSkill(4);
                this.nextAction = nil; --次の行動に通常攻撃とかが予約されていたらまずいので予約を消す
                this.form = this.forms.none;--素手モードにしておく           
                
                
                return 0;
            end

            unit:getTeamUnitCondition():addCondition(50024,28,50 - hpParcent/2,1050,0);

            
            this.setUpPoseRegistger(this,unit);
            if this.formTurns >= this.consts.formResetTurn then
                this.formTurns = 0;
                unit:takeAnimation(0,this.getTeleportAnimationName(this,unit),false);
                unit:takeAnimationEffect(0,"back",false);
                if this.form == this.forms.none then
                    local rand = LuaUtilities.rand(0,100);
                    if rand <= 35 then
                        this.form = this.forms.sword;
                    elseif rand <= 75 then
                        this.form = this.forms.spear;
                    else
                        this.form = this.forms.bow;
                    end
                    this.weaponAppear(this,unit);
                    this.formTurns = 0;
                    this.nextAction = this.setUpPoseRegistger;
                else
                    this.form = this.forms.none;
                    this.formTurns = this.consts.formResetTurn/2;
                    this.teleportAction = this.change;
                    this.nextAction = this.releace;
                end
                return 0;
            end
            this.formTurns = this.formTurns + 1;
            return 1;
        end,

        takeIdle = function (this , unit)
            if this.form == this.forms.none then
                unit:setNextAnimationName(this.animationNames.idleNone);
            elseif this.form == this.forms.sword then
                unit:setNextAnimationName(this.animationNames.idleSword);
            elseif this.form == this.forms.spear then
                unit:setNextAnimationName(this.animationNames.idleSpear);
            elseif this.form == this.forms.bow then
                unit:setNextAnimationName(this.animationNames.idleBow);
            end
            return 1;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
            if this.form == this.forms.none then
                unit:setNextAnimationName(this.animationNames.backNone);
            elseif this.form == this.forms.sword then
                unit:setNextAnimationName(this.animationNames.backSword);
            elseif this.form == this.forms.spear then
                unit:setNextAnimationName(this.animationNames.backSpear);
            elseif this.form == this.forms.bow then
                unit:setNextAnimationName(this.animationNames.backBow);
            end
            unit:takeAnimationEffect(0,"back",false);
            return 1;
        end,

        takeAttack = function (this , unit , index)
            if index == 1 then
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            elseif index == 3 then
                unit:setActiveSkill(3);
            elseif index == 4 then
                unit:setActiveSkill(4);
            end

            this.beforTargetUnitIndex = unit:getTargetUnit():getIndex();
            if not this.teleportChecker then
                this.teleportChecker = true;
                this.nextAction = this.attack;
                unit:takeAnimation(0,this.getTeleportAnimationName(this,unit),false);
                unit:takeAnimationEffect(0,"back",false);
                return 0;
            end
            
            if not this.attackChecker then
                this.attackChecker = true;
                if this.form == this.forms.none then
                    unit:takeAttack(1);
                elseif this.form == this.forms.sword then
                    unit:takeAttack(2);
                elseif this.form == this.forms.spear then
                    unit:takeAttack(3);
                elseif this.form == this.forms.bow then
                    unit:takeAttack(4);
                end
                return 0;
            end
            this.teleportChecker = false;
            this.attackChecker = false;
            return 1;
        end,

        takeSkill = function (this,unit,index)
            if index == 1 then
                unit:setActiveSkill(5);
            elseif index == 2 then
                unit:setActiveSkill(6);
            elseif index == 3 then
                unit:setActiveSkill(7);
            elseif index == 4 then
                unit:setActiveSkill(8);
            end

            if not this.skillChecker then
                this.skillChecker = true;
                if this.form == this.forms.none then
                    local rand = LuaUtilities.rand(0,100);
                    if rand <= this.rates.skill1 then
                        unit:takeSkill(1);
                        this.form = this.forms.sword;
                    elseif rand <= this.rates.skill1 + this.rates.skill2 then
                        unit:takeSkill(2);
                        this.form = this.forms.spear;
                    else
                        unit:takeSkill(3);
                        this.form = this.forms.bow;
                    end
                elseif this.form == this.forms.sword then
                    unit:takeSkill(1);
                elseif this.form == this.forms.spear then
                    unit:takeSkill(2);
                elseif this.form == this.forms.bow then
                    unit:takeSkill(3);
                end
                
                return 0;
            end
            this.skillChecker = false;
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

