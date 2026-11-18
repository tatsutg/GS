function new(id)
    print("10000 new ");
    local instance = {
        consts = {
            unitHight = 100,
            curseBuffID = 95,
            fogBuffID = 31,
            fogBuffEffectID = 31,
            fogBuffIconID = 16,
            fogBuffValue = 300,
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
            skill3FixedDamage = 99999,
            doomTimer = 20,
            doomThreshold = 500
        },

        rates = {
            --通常攻撃の確率 この中で合計１００になるようにしてください
            attack1Rate = 30,
            attack2Rate = 30,
            attack4Rate = 40,
            --呪われたユニットが存在しない場合のスキルの確率 この中で合計１００になるようにしてください
            skill1Rate = 50,
            skill3Rate = 50,

            --呪われたユニットが存在する場合のスキルの確率 この中で合計１００になるようにしてください
            skill1RateC = 50,
            skill2RateC = 0,
            skill3Rate = 50
        },

        myself = nil,
        deathTarget = nil,
        blackMist = nil,
        attackChecker = false,
        skillChecker = false,
        updateStarted = false,
        BeforetargetUnitIndex = 0,
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
        doomFlag = false,
        doomUpdateTimer = 0,
        fogFlag = false,
        afterExcution = false,

        deathExcuteFlg = false,

        hpTriggers = {
            [100] = "doom",
            [30] = "lastFog"
        },

        doomUnits = {},





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
                this.deathTarget = this.findMostTaffUnit(this);
                if this.deathTarget ~= nil then
                    megast.Battle:getInstance():sendEventToLua(this.thisID,1,this.deathTarget:getIndex());
                end
            end
            this.fadeOutAll(this,this.deathTarget);
            return 1;
        end,

        findMostTaffUnit = function(this)
            local unit = nil;
            for i = 0,4 do
                local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
                if uni ~= nil then
                    if unit == nil or unit:getHP() < uni:getHP() then
                        unit = uni;
                    end
                end
            end
            return unit;
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

        receive2 = function (this , intparam)
            this.doom(this,intparam);
            return 1;
        end,

        receive3 = function (this , intparam)
            this.addLastBuff(this.myself);
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "generalPause" then return this.generalPause(this,unit) end
            if str == "target" then return this.target(this,unit) end
            if str == "death" then return this.death(this,unit) end
            if str == "fadeInTarget" then return this.fadeInTarget(this,unit) end
            if str == "mistIn" then return this.mistIn(this,unit) end
            if str == "specialUpdate" then return this.specialUpdate(this,unit) end
            if str == "doom" then
                if this.lastDoom then
                    this.lastDoom = false;
                    if megast.Battle:getInstance():isHost() then
                        megast.Battle:getInstance():sendEventToLua(this.thisID,3,0);
                        this.choiceDoomTarget(this);
                        this.addLastBuff(unit);
                    end
                else
                    this.choiceDoomTarget(this);
                end
            end
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

            return 1;
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            local message = summoner.Text:fetchByEnemyID(4000217);
            summoner.Utility.messageByEnemy(message.mess3,5,summoner.Color.yellow);
            summoner.Utility.messageByEnemy(message.mess4,5,summoner.Color.magenta);
            summoner.Utility.messageByEnemy(message.mess5,5,summoner.Color.red);
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2　10割軽減
            this.updateStarted = true;
            if megast.Battle:getInstance():getBattleState() == kBattleState_active then
                this.HPTriggersCheck(this,unit);
                this.countDown(this,deltatime);
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
            return value;
        end,

        --version1.0
        start = function (this , unit)

            unit:setSPGainValue(0);
           
            this.myself = unit;
            this.lastDoom = false;

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
            this.hpMarkers = {
                [30] = unit:addNumHpMarker(0.3)
            }
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
                unit:setActiveSkill(4);
            end
            if unit:getTargetUnit() ~= nil then
                this.BeforetargetUnitIndex = unit:getTargetUnit():getIndex();
            end
            
            if this.ishost then
                if this.doomFlag then
                    this.doomFlag = false;
                    this.skillChecker = true;
                    unit:takeSkill(2);
                    return 0;
                end
                if this.fogFlag and unit.m_breaktime <= 0 then
                    this.fogFlag = false;
                    this.attackChecker = true;
                    unit:takeAttack(3);
                    return 0;
                end
                if this.afterExcution then
                    this.afterExcution = false;
                    this.attackChecker = true;
                    unit:takeAttack(2);
                    return 0;
                end
                if not this.attackChecker then
                    
                    local rand = LuaUtilities.rand(0,100);
                    this.attackChecker = true;
                    if rand < this.rates.attack1Rate then
                        unit:takeAttack(1);
                    elseif rand < this.rates.attack1Rate + this.rates.attack2Rate then
                        unit:takeAttack(2);
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
            
            if unit:getTargetUnit() ~= nil then
                this.BeforetargetUnitIndex = unit:getTargetUnit():getIndex();
            end
            
            if this.ishost then
                if not this.skillChecker then
                    local target = unit:getTargetUnit()
                    local distance = BattleUtilities.getUnitDistance(unit,target)
                    local rand = LuaUtilities.rand(100);
                    this.skillChecker = true;
             
                    if rand < this.rates.skill1Rate then
                        unit:takeSkill(1);
                    else
                        unit:takeSkill(3);
                    end
                    
                    return 0;
                end
            end
            if index == 1 then
                unit:setActiveSkill(5);
                unit:setNextAnimationName(this.getToPlayAnimeName(this,"skill1"));
            elseif index == 2 then
                unit:setActiveSkill(7);
                unit:setNextAnimationName(this.getToPlayAnimeName(this,"skill2"));
            else
                this.afterExcution = true;
                 unit:setActiveSkill(6);
                 unit:setInvincibleTime(3);
                 --一時的に霧は消しておく
                if this.blackMist ~= nil then
                    this.blackMist:takeAnimation(0,"blackmist_out",false);    
                end
                this.blackMist = nil;
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
            return 1;
        end,

    ---------------------------------------------------------------------------------------------------------
    --HPフラグ関連

        HPTriggersCheck = function(this,unit)
            local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

            for i,v in pairs(this.hpTriggers) do

                if i >= hpRate and this.hpTriggers[i] ~= nil then
                    if hpRate < 100 then unit:removeHpMarker(this.hpMarkers[i]) end
                    
                    this.excuteTrigger(this,unit,this.hpTriggers[i]);
                    this.hpTriggers[i] = nil;
                end
            end

        end,

        excuteTrigger = function(this,unit,trigger)

            if trigger == "doom" then
                this.doomFlag = true;
            end
            if trigger == "fog" then
                this.fogFlag = true;
            end
            if trigger == "lastFog" then
                this.lastDoom = true;
                this.fogFlag = true;
            end
        end,

    ---------------------------------------------------------------------------------------------------------

    ---------------------------------------------------------------------------------------------------------
    --死の宣告周り
        choiceDoomTarget = function(this)
            if not megast.Battle:getInstance():isHost() then
                return;
            end
            local target = this.findLiveUnitAtRandom(this);
            if target ~= nil then
                this.doom(this,target:getIndex());
                megast.Battle:getInstance():sendEventToLua(this.thisID,2,target:getIndex());
            end
        end,

        findLiveUnitAtRandom = function(this)
            local live = {};
            for i = 0,4 do
                local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
                if uni ~= nil then
                    -- uni:setHP(uni:getHP() - uni:getCalcHPMAX()/3);
                    if summoner.Utility.getUnitHealthRate(uni) > 0 then
                        table.insert(live,uni);                   
                    end
                end
            end
            if table.maxn(live) > 0 then                          
                local hit = LuaUtilities.rand(table.maxn(live));
                return live[hit + 1];
            else
                print("即死対象なし");
                return nil;
            end
        end,

        doom = function(this,targetIndex)
            local message = summoner.Text:fetchByEnemyID(4000217);
            summoner.Utility.messageByEnemy(message.mess1,5,summoner.Color.magenta);
            table.insert(this.doomUnits,this.createDoomTaegetTable(this,targetIndex));
        end,

        doomAll = function (this)
             for i = 0,4 do
                local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
                if uni ~= nil then
                    -- uni:setHP(uni:getHP() - uni:getCalcHPMAX()/3);
                    if summoner.Utility.getUnitHealthRate(uni) > 0 then
                        table.insert(this.doomUnits,this.createDoomTaegetTable(this,uni:getIndex()));                   
                    end
                end
            end
        end,

        getHPFromIndex = function(index)
            local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
            if uni ~= nil then
                return uni:getHP();
            end
            return 0;
        end,

        createDoomTaegetTable = function(this,unitIndex)
            local hp = this.getHPFromIndex(unitIndex);
            local unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(unitIndex);
            unit:getTeamUnitCondition():addCondition(50006,0,1,99999,181);
            local _orbit = this.myself:addOrbitSystemWithFile("deathCountDown","0");
        
            _orbit:takeAnimation(0,"none",true);
            _orbit:takeAnimation(1,"none2",true);
            _orbit:takeAnimation(2,"auraIn",true);
            _orbit:setZOrder(10011);
            local structure = {
                index = unitIndex,
                time = this.consts.doomTimer,
                beforeHP = hp,
                orbit = _orbit,
                healPoint = 0,
                isLoopAnimation = false,
                doomSucsess = false
            }
            return structure;
        end,

        countDown = function(this,deltaTime)
            this.doomUpdateTimer = this.doomUpdateTimer + deltaTime;
            if this.doomUpdateTimer < 0.1 then
                return;
            end
            for i,v in pairs(this.doomUnits) do
                if not v.doomSucsess then
                    v.time = v.time - this.doomUpdateTimer;
                    local hp = this.getHPFromIndex(v.index);

                    -- if hp >= v.beforeHP then
                    --     v.healPoint = v.healPoint + hp - v.beforeHP;
                    -- end

                    if hp <= 0 then
                        this.removeDoomCondition(this,v.index);
                        this.auraVanish(this,i);
                        return;
                    else
                        v.beforeHP = hp;
                        this.numbersControll(this,v);
                    end

                    if v.time <= 0 then
                        this.removeDoomCondition(this,v.index);
                        this.doomSucsess = true;
                        this.excuteDoom(this,v.index);
                        this.removeDoomUnit(this,i);
                        return;
                    end
          
                end
                
            end
            this.doomUpdateTimer = 0;
        end,

        excuteDoom = function(this,index)
            local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
            if uni ~= nil then
                uni:setHP(0);
            end
        end,

        removeDoomUnit = function(this,index)
  
            this.doomUnits[index].orbit:takeAnimation(0,"auraOut",false);
            this.doomUnits[index].orbit = nil;
            table.remove(this.doomUnits,index);
        end,

        auraVanish = function(this,index)
            this.doomUnits[index].orbit:takeAnimation(0,"auraRelease",false);
            this.doomUnits[index].orbit = nil;
            table.remove(this.doomUnits,index);
        end,

        numbersControll = function(this,targetTable)
            local unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(targetTable.index);
            if unit == nil then
                return;
            end
            local xpos = unit:getAnimationPositionX()+20 < 400 and unit:getAnimationPositionX() or 400;

            targetTable.orbit:setPosition(xpos,unit:getAnimationPositionY()+70);
            if targetTable.time > this.consts.doomTimer - 0.5 then
                return;
            end
            if not targetTable.isLoopAnimation then
                targetTable.isLoopAnimation = true;
                targetTable.orbit:takeAnimation(2,"auraLoop",true);
            end
            targetTable.orbit:takeAnimation(0,this.intToAnimationNameOne(targetTable.time),true);
            targetTable.orbit:takeAnimation(1,this.intToAnimationNameTen(targetTable.time),true);             
        end,

        intToAnimationNameOne = function(int,unit)
            local temp = math.floor(int%10);
            if temp == 0 then
                return "0";
            end
            return ""..temp;
        end,

        intToAnimationNameTen = function(int)
            local temp = math.floor(int/10);

            return ""..temp.."0";
        end,

        removeDoomCondition = function(this,index)
            local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
            if uni ~= nil then
                local cond = uni:getTeamUnitCondition():findConditionWithID(50006);
                if cond ~= nil then
                    uni:getTeamUnitCondition():removeCondition(cond);
                end
            end
        end,

        addLastBuff = function(unit)
            local message = summoner.Text:fetchByEnemyID(4000217);
            summoner.Utility.messageByEnemy(message.mess2,5,summoner.Color.magenta);
            unit:getTeamUnitCondition():addCondition(500062,28,30,99999,7);
            unit:getTeamUnitCondition():addCondition(500063,17,100,99999,26);
            unit:setAttackDelay(0);
        end

    }
    register.regist(instance,id,instance.param.version);
    return 1;
end