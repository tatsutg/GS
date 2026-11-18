--@additionalEnemy,500382150,500351150,500391150,500411150
--@additionalItem,100071100
--ラグシェルム２回目
function new(id)
    print("10000 new ");
    local instance = {
        attackChecker = false,
        skillChecker = false,
        coolTimes = {},
        coolTimeMemory = {},
        summonIDs = {500382150,500351150,500391150,500411150},--フェン　ミラ　ゼイオルグ　メリアの順
        summonUnits = {},
        summonCounter = 1,
        barrierRecast = 0,
        isRage = false,
        isHide = false,
        isTryGlab = false,
        isGlab = false,
        glabUnit = nil,
        isUsedHundredSowrd = false,
        consts = {
            DEFBuffID = 15,
            DEFBuffEFID = 15,
            DEFBuffEF = 50,
            DEFBuffTime = 3000,
            DEFBuffIcon = 5,
            SPEEDBuffID = 28,
            SPEEDBuffEFID = 28,
            SPEEDBuffEF = 50,
            SPEEDBuffTime = 3000,
            SPEEDBuffIcon = 7,
            barrierRecastTurn = 10 --バリアを破壊されてから再度発動するまでの行動数
        },
        barrier = nil,

        summon = function(this,unit)
            if this.summonCounter > 5 then
                this.summonCounter = 0;
            end

            local gaul = unit:getTeam():addUnit(this.summonCounter,this.summonIDs[this.summonCounter]);
            this.summonCounter = this.summonCounter + 1;
            print(gaul);
            if gaul == nil then
            else
                print("召喚");
                table.insert(this.summonUnits,gaul);
                gaul:takeGrayScale(0.01);
                -- gaul:setBurstPoint(100);
            end
            return 1;
        end,

        hide = function(this,unit)
            
            unit:setSetupAnimationName("setUpHide");
            megast.Battle:getInstance():pauseUnit(0.001);
            return 1;
        end,

        glab = function(this,unit)
            this.isTryGlab = true;
            return 1;
        end,

        glabSarchEnd = function(this,unit)
            this.isTryGlab = false;
            if this.glabUnit ~= nil then
                this.glabUnit:takeDamage();
                this.glabUnit:getTeamUnitCondition():addCondition(89,89,1,10,0);
                this.isGlab = true;
            end
            return 1;
        end,

        glabEnd = function(this,unit)
            this.isGlab = false;
            if this.glabUnit ~= nil then
                local condition = this.glabUnit:getTeamUnitCondition():findConditionWithID(89);
                if condition ~= nil then
                    this.glabUnit:getTeamUnitCondition():removeCondition(condition);
                end
            end
            this.glabUnit = nil;

            return 1;
        end,

        resume = function(this,unit)
            megast.Battle:getInstance():pauseUnit(0.001);
            return 1;
        end,

        addBuff = function(this,unit)
            --unit:getTeamUnitCondition():addCondition(this.consts.SPEEDBuffID,this.consts.SPEEDBuffEFID,this.consts.SPEEDBuffEF,this.consts.SPEEDBuffTime,this.consts.SPEEDBuffIcon); 
            unit:getTeamUnitCondition():addCondition(this.consts.DEFBuffID,this.consts.DEFBuffEFID,this.consts.DEFBuffEF,this.consts.DEFBuffTime,this.consts.DEFBuffIcon); 
            this.barrier = unit:addOrbitSystem("barrier",0);
            this.barrier:takeAnimation(0,"barrier",true);
            return 1;
        end,

        onDestroy = function (this,self)
            local  atari = 0;
             for i = 1,table.maxn(this.summonUnits) do
         
                if this.summonUnits[i] == self then
                    atari = i
                end

            end
            if atari ~= 0 then
                table.remove(this.summonUnits,atari);
            end
            return 1;
        end,

        addSP = function (this,unit)
            
            unit:addSP(20);
            
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
            if str == "addBuff" then return this.addBuff(this,unit) end
            -- if str == "summon" then return this.summon(this,unit) end
            if str == "hide" then return this.hide(this,unit) end
            if str == "glab" then return this.glab(this,unit) end
            if str == "glabSarchEnd" then return this.glabSarchEnd(this,unit) end
            if str == "glabEnd" then return this.glabEnd(this,unit) end
            if str == "resume" then return this.resume(this,unit) end
            return 1;
        end,


        --version1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
            -- if this.isRage then
            --     value = 0;
            -- end
            return value;
        end,

        takeBreake = function (this,unit)
            
            if this.barrier ~= nil then
                this.barrier:takeAnimation(0,"none",false);
                this.barrier = nil;
                this.barrierRecast = this.consts.barrierRecastTurn;
            end
            local buff = unit:getTeamUnitCondition():findConditionWithID(this.consts.DEFBuffID);
            if buff ~= nil then
                unit:getTeamUnitCondition():removeCondition(buff);
            end

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
            if this.barrier ~= nil then
                local xb = unit:getSkeleton():getBoneWorldPositionX("MAIN");
                local yb = unit:getSkeleton():getBoneWorldPositionY("MAIN") - 60;
                if this.isHide then
                    this.barrier:setPosition(10000,10000);
                else
                    this.barrier:setPosition(unit:getPositionX()-xb,unit:getPositionY() + yb);
                end
            end
            if this.isGlab then

                local thisx = unit:getPositionX();
                local thisy = unit:getPositionY();
                local xbone = unit:getSkeleton():getBoneWorldPositionX("DAMAGEAREA");
                local ybone = unit:getSkeleton():getBoneWorldPositionY("DAMAGEAREA");
                local unitx = this.glabUnit:getPositionX();
                local unity = this.glabUnit:getPositionY();
                --local distanceby2 = (thisx - xbone - unitx)*(thisx - xbone - unitx) + (thisy + ybone - unity)*(thisy + ybone - unity);
                -- if distanceby2 <= 2500 then
                    this.glabUnit:setPosition(thisx-xbone,this.glabUnit:getPositionY());
                    this.glabUnit:getSkeleton():setPosition(0,thisy+ybone-this.glabUnit:getPositionY()-50);
                -- else

                --     local speed = 500 * deltatime;
                --     local rad = getRad(unitx,unity,thisx-xbone,thisy+ybone);
                --     local newX = unitx + calcXDir(rad,speed);
                --     local newY = unity + calcYDir(rad,speed);
                --     this.glabUnit:setPosition(newX,newY);
                -- end
                
            end
            if this.isHide then
                for i=1,table.maxn(this.summonUnits) do
                    if this.summonUnits[i] == nil or this.summonUnits[i]:getHP() <= 0 then
                        this.onDestroy(this,this.summonUnits[i]);
                    end
                end
                if table.maxn(this.summonUnits) <= 0 then
                    this.isHide = false;
                    unit:setSetupAnimationName("");
                    unit:takeAnimation(0,"event3",false);
                    megast.Battle:getInstance():pauseUnit(3);
                    unit:resumeUnit();
                end
            end

            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            if this.isTryGlab then
                if unit:getTargetUnit() == enemy then
                    this.targetHitFlag = true;
                end

                if not this.targetHitFlag or this.glabUnit == nil  then
                    this.glabUnit = enemy;
                    this.isTryGlab = false;
                end
            end
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        --version1.0
        start = function (this , unit)
            unit:setSPGainValue(0);
            
            unit:setItemSkill(0,100071100);
            table.insert(this.coolTimeMemory,os.time() -15);
            table.insert(this.coolTimeMemory,os.time() -15);
            table.insert(this.coolTimes,15);
            table.insert(this.coolTimes,15);


            return 1;
        end,

        excuteAction = function (this , unit)
            this.barrierRecast = this.barrierRecast- 1;
            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if this.barrier == nil and hpParcent < 75 and this.barrierRecast <= 0 then
                unit:takeAnimation(0,"event1",false);
                unit:takeAnimationEffect(0,"event1",false);
                this.isRage = true;
                unit:setBreakPoint(unit:getBreakPoint()+2000);
                return 0;
            end

            if hpParcent <= 50 and this.summonCounter < 3 then
                unit:takeAnimation(0,"event2",false);
                unit:takeAnimationEffect(0,"event2",false);
                this.summon(this,unit);
                this.summon(this,unit);
                megast.Battle:getInstance():pauseUnit(3);
                unit:resumeUnit();
                this.isHide = true;
                return 0;
            elseif hpParcent <= 25 and this.summonCounter < 5 then
                unit:takeAnimation(0,"event2",false);
                unit:takeAnimationEffect(0,"event2",false);
                this.summon(this,unit);
                this.summon(this,unit);
                megast.Battle:getInstance():pauseUnit(3);
                unit:resumeUnit();
                this.isHide = true;
                return 0;
            end

            if this.isHide then
                return 0;
            end

            return 1;
        end,

        takeIdle = function (this , unit)
            if this.isHide then
                unit:setNextAnimationName("hide");
            end
            return 1;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
            if this.isHide then
                return 0;
            end
            return 1;
        end,

        takeAttack = function (this , unit , index)
            if index == 1 then
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            else
                unit:setActiveSkill(3);
            end
            if not this.attackChecker then


                local itemUseRand = LuaUtilities.rand(0,100);
                if itemUseRand < 50 then
                    local itemIndexes = {};
                    for i = 1,table.maxn(this.coolTimeMemory)do
                        if this.coolTimeMemory[i] - os.time() <= -this.coolTimes[i] then
                            
                            --attack3はHPが75%を切って怒っている時だけ
                            if i == 2 then
                                if this.isRage then
                                    table.insert(itemIndexes,i);
                                end
                            else
                                table.insert(itemIndexes,i);
                            end
                        end
                    end

                    if table.maxn(itemIndexes) > 0 then
                        local randForItem = LuaUtilities.rand(table.maxn(itemIndexes));
                            if itemIndexes[randForItem] == 1 then
                                unit:takeItemSkill(0);
                                this.attackChecker = false;
                            else
                                unit:takeSkill(1);
                            end
                            this.coolTimeMemory[itemIndexes[randForItem + 1]] = os.time();
                            
                        return 0;
                    end
                end
                
                local distance = BattleUtilities.getUnitDistance(unit,unit:getTargetUnit());
                this.attackChecker = true;
                if distance < 50 then
                    unit:takeAttack(1);
                else
                    local rand = LuaUtilities.rand(0,100);
                    if rand <= 30 then
                        unit:takeAttack(1);
                    elseif rand <= 60 then
                        unit:takeAttack(2);
                    else
                        unit:takeAttack(3);
                    end
                end
                local attacktimerRand = LuaUtilities.rand(0,100);
                if attacktimerRand <= 50 then
                    unit:setAttackTimer(0);
                end
                return 0;
            end
            this.attackChecker = false;
            return 1;
        end,

        takeSkill = function (this,unit,index)
            if index == 1 then
                unit:setActiveSkill(4);
            elseif index == 2 then
                unit:setActiveSkill(5);
            else
                unit:setActiveSkill(6);
            end
            if not this.skillChecker and index ~= 1 then
                this.skillChecker = true;
                if this.isRage and not this.isUsedHundredSowrd then
                    this.isUsedHundredSowrd = true;
                    unit:takeSkill(3);
                elseif this.isRage then
                    local rand = LuaUtilities.rand(0,100);
                    if rand <= 50 then
                        unit:takeSkill(2);
                    else
                        unit:takeSkill(3);
                    end
                else
                    unit:takeSkill(2);
                end
                return 0;
            end
            this.skillChecker = false;
            return 1;
        end,

        takeDamage = function (this , unit)
            if this.isHide then
                return 0;
            end
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
