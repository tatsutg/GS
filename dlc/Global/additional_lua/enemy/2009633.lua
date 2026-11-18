function new(id)
    print("500081213 new ");
    local instance = {

        --怪鳥さん氷クラス
        Class = 
        {
            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Values
            isFirstStepUpdate = false,

            --uniqueID
            ThisUniqueId = id,

            --ThisUnit
            ThisUnit = nil,


            --アタックチェック
            isAttackChecker = false,

            --スキルチェック
            isSkillChecker = false,

            --風圧時の移動量
            windPowerValue = 1,

            --最初のフライではオーラを纏わない
            isFirstFlyWind = true,

            --Update一回目のみ呼ばれるフラグ
            isFirstUpdateStep = false,

            --地上から飛び立ってattack6を出すためのフラグ
            hpBorderFlag = false,

            --地上から飛び立ってスキルを出しましたよ　というフラグ
            fromGround = false,

            --最初の一撃は同期ズレを起こすため捨てる
            isFirstAttack = true,
            takeFirstAction = true,
            forceSkillIndex = 0,

            advanceAction = nil;

            --この怪鳥のモード
            Kaityo_Mode = 
            {
                Sky = 8111,
                Ground = 8112
            },

            rates = 
            {
                --通常攻撃の確率 by Ground
                attack1 = 20,
                attack2 = 35,
                attack3 = 45,
    
                --通常攻撃の確率 by Sky
                attack4 = 20,
                attack5 = 20,
                wind   = 20,
                skill2 = 40
            },

            consts = {
                --強制で暴風モードになるHP１回目
                windBorderHP = 60,
                --強制で暴風モードになるHP２回目
                windBorderHP2 = 30,
                windBuffID = 31,
	            windBuffEffectID = 31,
	            windBuffIconID = 16,
	            windBuffValue = 30,
	            windBuffTime = 9999
            },

            --Defaultはお空から、in Animationが空から始まるため
            curKaityoMode = 8111,--this.Class.Kaityo_Mode.Ground,


            --飛んでる時のオーラ
            WindAura = nil,

            coolTimeLimits = 
            {
                skill2 = 20,
                wind = 20
            },
            coolTimeCurs = 
            {
                skill2 = 0,
                wind = 0
            },
            coolTimeAttackFlags = 
            {
                skill2 = false,
                wind = false
            },
            windBorderFlags =
            {
                --一定HP以下になった時に発動する強制暴風モードのためのフラグ
                border1 = false,
                border2 = false
            },

            messages = summoner.Text:fetchByUnitID(501221213),

            windMessagesRGB = 
            {
                r = 220,
                g = 220,
                b = 0
            },




            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆


            --初期化
            Initialize = function(this,unit)
                unit:setSPGainValue(0);
                return 1;
            end,

             --アップデート最初の一度のみ実行される。
            FirstUpdateInitialize = function(this,unit)

                this.Class.ThisUnit = unit;


                
                this.Class.setDefaultMainPosition(this,unit,-46,263);
                unit:setDefaultPosition(-260,20);
                unit:setPositionY(0);
                unit:setSetupAnimationName("idle");
                
                return 1;
            end,

            --アップデート
            Update = function(this,unit,deltatime)

                unit:setReduceHitStop(2,1)

                if this.Class.isFirstStepUpdate == false then

                    this.Class.FirstUpdateInitialize(this,unit);
                    this.Class.isFirstStepUpdate = true;
                
                end



                if this.Class.curKaityoMode == this.Class.Kaityo_Mode.Sky then
                    if this.Class.WindAura ~= nil then
                        this.Class.WindAura:setPositionX(unit:getAnimationPositionX());
                        this.Class.WindAura:setPositionY(unit:getAnimationPositionY() - 50);
                        this.Class.WindAura:setLocalZOrder(unit:getZOrder() + 1);

                        --オーラまとっている時はユニットは風圧によって下がる
                        this.Class.windPowerMovedUpdate(this,unit);
                    end
                end

                this.Class.updateAttackCoolTimers(this,unit,deltatime);



                return 1;
            end,

            --LunScript
            --if str == "runSkillAttack" then return this.Class.runSkillAttack(this,unit) end
            runScriptUpdate = function(this , unit , str)

                if str == "addSP" then return this.Class.addSP(this,unit) end
                if str == "takeOffEnd" then return this.Class.takeOffEnd(this,unit) end
                if str == "hideWindAura" then return this.Class.hideWindAura(this,unit) end
                if str == "showWindAura" then return this.Class.showWindAura(this,unit) end

                return 1;
            end,

            --アタック分岐
            takeAttackBranch = function(this,unit,index)
                
                if this.Class.curKaityoMode == this.Class.Kaityo_Mode.Ground then
                    return this.Class.randAtkAnimGro(this,unit,index);

                elseif this.Class.curKaityoMode == this.Class.Kaityo_Mode.Sky then
                    return this.Class.randAtkAnimSky(this,unit,index);

                end

                return 1;
            end,

            --スキル分岐用
            takeSkillBranch = function(this,unit,index)
                --地上にいた場合は take_off で空飛んでからスキルを放つ
                if this.Class.curKaityoMode == this.Class.Kaityo_Mode.Ground then
                    this.Class.fromGround = true;
                    unit:setNextAnimationName("take_off");
                    unit:setNextAnimationEffectName("enpty");
                    this.Class.curKaityoMode = this.Class.Kaityo_Mode.Sky;
                    this.Class.startSkyMode(this,unit);
                    
                elseif this.Class.curKaityoMode == this.Class.Kaityo_Mode.Sky then
                    return this.Class.randSkillAnimHIOUGI(this,unit);
                end

                return 1;
            end,

            --アイドル分岐用
            takeIdleBranch = function(this,unit)

                if this.Class.curKaityoMode == this.Class.Kaityo_Mode.Ground then
                    print("takeIdleBranch idle2");
                    unit:setNextAnimationName("idle2");

                elseif this.Class.curKaityoMode == this.Class.Kaityo_Mode.Sky then
                    print("takeIdleBranch idle");
                    unit:setNextAnimationName("idle");

                end

                return 1;
            end,

            --だめーじ分岐用
            takeDamageBranch = function(this,unit)

                if this.Class.curKaityoMode == this.Class.Kaityo_Mode.Ground then
                    print("takeDamageBranch damage2");
                    unit:setNextAnimationName("damage2");
                elseif this.Class.curKaityoMode == this.Class.Kaityo_Mode.Sky then
                    print("takeDamageBranch damage");
                    unit:setNextAnimationName("damage");
                end

                return 1;
            end,

            --死亡分岐用
            takeDeadBranch = function(this,unit)

                if this.Class.curKaityoMode == this.Class.Kaityo_Mode.Ground then
                    print("takeDeadBranch out2");
                    unit:setNextAnimationName("out2");
                elseif this.Class.curKaityoMode == this.Class.Kaityo_Mode.Sky then
                    print("takeDeadBranch out");
                    unit:setNextAnimationName("out");
                end

                return 1;
            end,

            --ブレイク分岐用
            takeBreakeBranch = function(this,unit)

                if this.Class.curKaityoMode == this.Class.Kaityo_Mode.Ground then

                elseif this.Class.curKaityoMode == this.Class.Kaityo_Mode.Sky then

                    --空に居た場合にブレイクしたら地上モードに戻る
                    this.Class.curKaityoMode = this.Class.Kaityo_Mode.Ground;
                    this.Class.startGroundMode(this,unit);

                end

                return 1;
            end,

            --excureAction分岐用
            excuteActionBranch = function(this,unit)

                if this.Class.curKaityoMode == this.Class.Kaityo_Mode.Ground then

                elseif this.Class.curKaityoMode == this.Class.Kaityo_Mode.Sky then

                end

                return 1;
            end,

            --receive分岐用
            receiveBranch_1 = function(this,intparam)
            	this.Class.ThisUnit:takeAnimation(0,"take_off",false);
            	print("kitaaaaaaaaaaaaaaaaa");
                this.Class.curKaityoMode = this.Class.Kaityo_Mode.Sky;
                this.Class.startSkyMode(this,this.Class.ThisUnit);
                return 1;
            end,

            receiveBranch_2 = function(this,intparam)
                return 1;
            end,

            --attackDamageValue分岐用
            attackDamageValueBranch = function(this , unit , enemy , value)
                if this.Class.advanceAction ~= nil then
                    this.Class.advanceAction(this,unit,enemy);
                end
                return value;
            end,

            --takeDamageValue分岐用
            takeDamageValueBranch = function(this , unit , enemy , value)

                if this.Class.PhoenixSwitch == true then
                    return 0;
                end

                return value;
            end,

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Functions

            --sendEventToLua
            RequestSendEventToLua = function(this,unit,requestIndex,intparam)

                
                print("----------リクエストを受付開始 ID == ",intparam);
                megast.Battle:getInstance():sendEventToLua(this.Class.ThisUniqueId,requestIndex,intparam);
                

                return 1;
            end,

            addSP = function (this , unit)
                if this.Class.WindAura ~= nil then
                    unit:addSP(40);
                else
                    unit:addSP(20);
                end
                return 1;
            end,

            takeOffEnd = function (this , unit)

                --take_Off終わった後setUpAnimationを切り替える。
                unit:setSetupAnimationName("idle");
                if this.Class.hpBorderFlag then
                    this.Class.hpBorderFlag = false;
                    return this.Class.takeAttackBranch(this,unit);
                end
                return this.Class.randSkillAnimHIOUGI(this,unit);
            end,

            hideWindAura = function(this,unit)

               
                this.Class.drawingAuraEffect(this,unit,false);
                

                return 1;
            end,

            showWindAura = function(this,unit)

               
                this.Class.drawingAuraEffect(this,unit,true);
                

                return 1;
            end,

             --ユニットのDefalutMainPositionを設定する
            setDefaultMainPosition = function(this,unit,valueX,valueY)
                unit:setDefaultMainPositionX(valueX);
                unit:setDefaultMainPositionY(valueY);

                return 1;
            end,

            --オーラのエフェクト表示非表示を切り替える
            drawingAuraEffect = function (this,unit,isDrawing)

                if isDrawing == true then
                    if this.Class.WindAura == nil then
                        this.Class.WindAura = unit:addOrbitSystem("wind_roop");
                        this.Class.WindAura:setAnimation(0,"wind_roop",true);
                        this.Class.WindAura:setPositionX(unit:getAnimationPositionX());
                        this.Class.WindAura:setPositionY(unit:getAnimationPositionY() - 50);
                        this.Class.WindAura:setLocalZOrder(unit:getZOrder() + 1);

                        BattleControl:get():pushEnemyInfomation(this.Class.messages.messageWind1,this.Class.windMessagesRGB.r,this.Class.windMessagesRGB.g,this.Class.windMessagesRGB.b,7);
                        BattleControl:get():pushEnemyInfomation(this.Class.messages.messageWind2,this.Class.windMessagesRGB.r,this.Class.windMessagesRGB.g,this.Class.windMessagesRGB.b,7);
                        unit:getTeamUnitCondition():addCondition(-12, 0, 1, 20000, 36);
                        
                        unit:getTeamUnitCondition():addCondition(
                            this.Class.consts.windBuffID,
                            this.Class.consts.windBuffEffectID,
                            this.Class.consts.windBuffValue,
                            this.Class.consts.windBuffTime,
                            this.Class.consts.windBuffIconID
                        );
                    end
                else
                    if this.Class.WindAura ~= nil then
                        this.Class.WindAura:remove();
                        this.Class.WindAura = nil;
                        BattleControl:get():pushEnemyInfomation(this.Class.messages.messageWindEnd,255,255,255,5);
                        local buff = unit:getTeamUnitCondition():findConditionWithID(-12);
                        if buff ~= nil then
                            unit:getTeamUnitCondition():removeCondition(buff);
                        end
                        local windBuff = unit:getTeamUnitCondition():findConditionWithID(this.Class.consts.windBuffID);
                        if windBuff ~= nil then
                            unit:getTeamUnitCondition():removeCondition(windBuff);
                        end
                    end
                end

                return 1;
            end,

            --風圧処理、全てのユニットを後方へ少しずつ移動する
            windPowerMovedUpdate = function (this , unit)
                local t_Unit = unit:getTargetUnit();
                if t_Unit == nil then
                    return 0;
                end
                local t_Team = t_Unit:getTeam();

                for i = 0,3 do
                    local t_TeamUnit = t_Team:getTeamUnit(i,true);
                    if t_TeamUnit ~= nil then
                        local heavyBuffID = 34;
                        local buff = t_TeamUnit:getTeamUnitCondition():findConditionWithType(heavyBuffID);
                        if buff == nil then
                            t_TeamUnit:setPosition(t_TeamUnit:getPositionX() + this.Class.windPowerValue , t_TeamUnit:getPositionY());
                        end
                    end
                end

                return 1;
            end,

            --クールタイムの計算を行う
            updateAttackCoolTimers = function (this,unit,deltatime)

                -- if this.Class.coolTimeAttackFlags.skill2 == false then
                --     this.Class.coolTimeCurs.skill2 = this.Class.coolTimeCurs.skill2 + deltatime;
                --     if this.Class.coolTimeLimits.skill2 <= this.Class.coolTimeCurs.skill2 then
                --         this.Class.coolTimeAttackFlags.skill2 = true;
                --         this.Class.coolTimeCurs.skill2 = 0;
                --     end
                -- end

                -- if this.Class.coolTimeAttackFlags.wind == false then
                --     this.Class.coolTimeCurs.wind = this.Class.coolTimeCurs.wind + deltatime;
                --     if this.Class.coolTimeLimits.wind <= this.Class.coolTimeCurs.wind then
                --         this.Class.coolTimeAttackFlags.wind = true;
                --         this.Class.coolTimeCurs.wind = 0;
                --     end
                -- end

                return 1;
            end,

            --飛び立つ処理直前に呼ばれる(切替時)
            startSkyMode = function (this , unit)

                this.Class.setDefaultMainPosition(this,unit,-46,313);

                -- this.Class.drawingAuraEffect(this,unit,true);

                return 1;
            end,

            --地面につく処理直前に呼ばれる(切替時)
            startGroundMode = function (this , unit)
                

                this.Class.setDefaultMainPosition(this,unit,0,225);
                unit:setSetupAnimationName("idle2");

                this.Class.drawingAuraEffect(this,unit,false);

                return 1;
            end,

            --地上にいるときのみの攻撃を制御する。
            randAtkAnimGro = function(this,unit,index)

                local rand = math.random(100);

                local hpparcent = 100 * unit:getHP()/unit:getCalcHPMAX();

                if hpparcent < this.Class.consts.windBorderHP and not this.Class.windBorderFlags.border1 then
                	--空中に移ったら次の行動で風を纏うので、ここではwindBorderFlagは立てない（空中での最初の攻撃分岐で立つため
                    this.Class.hpBorderFlag = true;
                    unit:setNextAnimationName("take_off");
                    unit:setNextAnimationEffectName("enpty");
                    this.Class.curKaityoMode = this.Class.Kaityo_Mode.Sky;
                    this.Class.startSkyMode(this,unit);
                    this.Class.RequestSendEventToLua(this,unit,1,0);
                    return 1;
                end

                if hpparcent < this.Class.consts.windBorderHP2 and not this.Class.windBorderFlags.border2 then
                	--空中に移ったら次の行動で風を纏うので、ここではwindBorderFlagは立てない（空中での最初の攻撃分岐で立つため
                    this.Class.hpBorderFlag = true;
                    unit:setNextAnimationName("take_off");
                    unit:setNextAnimationEffectName("enpty");
                    this.Class.curKaityoMode = this.Class.Kaityo_Mode.Sky;
                    this.Class.startSkyMode(this,unit);
                    this.Class.RequestSendEventToLua(this,unit,1,0);
                    return 1;
                end

                if rand <= this.Class.rates.attack1 then
                    print("takeAttack 1");
                    unit:takeAttack(1);
                elseif rand <= this.Class.rates.attack1 + this.Class.rates.attack2 then
                    print("takeAttack 2");
                    unit:takeAttack(2);
                elseif rand <= 100 then
                    print("takeAttack 3");
                    unit:takeAttack(3);
                end

                return 0;
            end,

            --お空にいるときのみの攻撃を制御する。
            randAtkAnimSky = function(this,unit,index)

                local rand = math.random(100);

                local hpparcent = 100 * unit:getHP()/unit:getCalcHPMAX();

                if hpparcent < this.Class.consts.windBorderHP and not this.Class.windBorderFlags.border1 then
                    this.Class.windBorderFlags.border1 = true;
                    unit:takeAttack(6);
                    return 0;
                end

                if hpparcent < this.Class.consts.windBorderHP2 and not this.Class.windBorderFlags.border2 then
                    this.Class.windBorderFlags.border2 = true;
                    unit:takeAttack(6);
                    return 0;
                end

                if rand <= this.Class.rates.attack4 then
                    print("takeAttack 4");
                    unit:takeAttack(4);
                elseif rand <= this.Class.rates.attack4 + this.Class.rates.attack5 then
                    print("takeAttack 5");
                    unit:takeAttack(5);
                elseif rand <= 100 then
                    print("takeAttack 5");
                    unit:takeAttack(5);
                end

                return 0;
            end,

            --必殺技の制御
            randSkillAnimHIOUGI = function(this,unit)
                local rand = math.random(100);

                if this.Class.forceSkillIndex ~= 0 then
                    unit:takeSkill(this.Class.forceSkillIndex);
                    this.Class.forceSkillIndex = 0;
                    return 0;
                end

                local hpparcent = 100 * unit:getHP()/unit:getCalcHPMAX();

                if hpparcent <= 50 then
                    unit:takeSkill(3);
                    return 0;
                end


                if this.Class.fromGround then
                    this.Class.fromGround = false;
                    if rand <= 50 then
                        print("takeSkill 1");
                        unit:takeSkill(1);
                    elseif rand <= 100 then
                        print("takeSkill 2");
                        unit:takeSkill(2);
                    end
                    return 0;
                end

                if this.Class.curKaityoMode == this.Class.Kaityo_Mode.Sky and this.Class.WindAura ~= nil then
                    if rand <= 30 then
                        print("takeSkill 1");
                        unit:takeSkill(1);
                    elseif rand <= 60 then
                        print("takeSkill 2");
                        unit:takeSkill(2);
                    else
                        print("takeSkill 3");
                        unit:takeSkill(3);
                    end
                elseif this.Class.curKaityoMode == this.Class.Kaityo_Mode.Sky then
                    --以前はレイジングブリザード確定だったが空中モードは共通にした
                    if rand <= 30 then
                        print("takeSkill 1");
                        unit:takeSkill(1);
                    elseif rand <= 60 then
                        print("takeSkill 2");
                        unit:takeSkill(2);
                    else
                        print("takeSkill 3");
                        unit:takeSkill(3);
                    end
                    
                end

                
                return 0;
            end,

            advanceActionAttack4 = function(this,unit,enemy)
                enemy:getTeamUnitCondition():addCondition(501221,30,-50,10,183);
            end,

            advanceActionSkill3 = function(this,unit,enemy)
                enemy:getTeamUnitCondition():addCondition(501222,28,-50,15,8);
                enemy:getTeamUnitCondition():addCondition(501223,29,-50,15,88);
            end


            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        },




        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

        firstAction = function(this,unit)
            unit:addSP(unit:getNeedSP());
            this.Class.forceSkillIndex = 2;
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
        	print("RECEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEIVE");
            return this.Class.receiveBranch_1(this,intparam);
        end,
        receive2 = function (this , intparam)
            return this.Class.receiveBranch_2(this,intparam);
        end,
        receive3 = function (this , intparam)
            return this.firstAction(this,this.Class.ThisUnit);
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            return this.Class.runScriptUpdate(this,unit,str);
        end,

        --version1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
            return value;
        end,

        takeBreake = function (this,unit)
            return this.Class.takeBreakeBranch(this,unit);
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            BattleControl:get():pushEnemyInfomation(this.Class.messages.messageCritical,255,0,0,7);
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            return this.Class.Update(this,unit,deltatime);
        end,

        attackDamageValue = function (this , unit , enemy , value)
            return this.Class.attackDamageValueBranch(this,unit,enemy,value);
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return this.Class.takeDamageValueBranch(this,unit,enemy,value);
        end,

        --version1.0
        start = function (this , unit)
            return this.Class.Initialize(this,unit);
        end,

        excuteAction = function (this , unit)
            return this.Class.excuteActionBranch(this,unit);
        end,

        takeIdle = function (this , unit)
            return this.Class.takeIdleBranch(this,unit);

        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
         
            return 1;
        end,

        takeAttack = function (this , unit , index)
            this.Class.advanceAction = nil;

            local isHost = megast.Battle:getInstance():isHost();
            if isHost then
                -- if this.Class.isFirstAttack then
                --     this.Class.isFirstAttack = false;
                --     unit:takeIdle();
                --     this:firstAction(unit);
                --     megast.Battle:getInstance():sendEventToLua(this.Class.ThisUniqueId,3,0);
                --     return 0;
                -- end
                if this.Class.isAttackChecker == false then
                    this.Class.isAttackChecker = true;
                    return this.Class.takeAttackBranch(this,unit,index);
                end
                this.Class.isAttackChecker = false;
            end

            if index == 4 then
                this.Class.advanceAction = this.Class.advanceActionAttack4;
            end

            unit:setActiveSkill(index);

            return 1;
        end,

        takeSkill = function (this,unit,index)
            this.Class.advanceAction = nil;
            local isHost = megast.Battle:getInstance():isHost();
            if isHost then
                if this.Class.isAttackChecker then
                    this.Class.isAttackChecker = false;
                    return 1;
                end
                if this.Class.isSkillChecker == false then
                    this.Class.isSkillChecker = true;
                    return this.Class.takeSkillBranch(this,unit,index);
                end
                this.Class.isSkillChecker = false;
            else
            	if this.Class.curKaityoMode == this.Class.Kaityo_Mode.Ground then
                    
                    unit:setNextAnimationName("take_off");
                    unit:setNextAnimationEffectName("enpty");
                    this.Class.curKaityoMode = this.Class.Kaityo_Mode.Sky;
                    this.Class.startSkyMode(this,unit);
                    return 0;
                end
            end
            
            if index == 1 then
                unit:setActiveSkill(7);
            elseif index == 2 then
                unit:setActiveSkill(8);
            else
                unit:setActiveSkill(9);
                this.Class.advanceAction = this.Class.advanceActionSkill3;
            end
            unit:setBurstState(kBurstState_active);
            return 1;
        end,

        takeDamage = function (this , unit)
            return this.Class.takeDamageBranch(this,unit);
        end,

        dead = function (this , unit)
            return this.Class.takeDeadBranch(this,unit);
        end
    }
    register.regist(instance,id,instance.param.version);
    return 1;
end

