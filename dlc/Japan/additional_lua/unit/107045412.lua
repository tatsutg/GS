function new(id)
    print("101134411 new ");
    local instance = {

        --リーゼクラス
        Class = 
        {
            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Values
            isFirstStepUpdate = false,

            --uniqueID
            ThisUniqueId = id,

            --ThisUnit
            ThisUnit = nil,
            
            --リーゼ攻撃タイプ
            SkillAttackTypes =
            {
                Attack = 40000,
                Heal   = 40001
            },
            --現在のリーゼ攻撃モード(最初はヒールから)
            curSkillType = 40001,

            modeAttack_icon_ID = 92,
            modeHeal_icon_ID = 93,

            modeAttack_Buff_ID = 0,
            modeHeal_Buff_ID = 7,

            modeAttack_Buff_Value = 0,
            modeHeal_Buff_Value = 0,


            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆


            --初期化
            Initialize = function(this,unit)
                this.Class.ThisUnit = unit;
                this.Class.ThisUnit:setParameter("113_HealAttack",""..((this.Class.curSkillType - 40001) * -1))
                return 1;
            end,

            --アップデート
            Update = function(this,unit,deltatime)

                if this.Class.isFirstStepUpdate == false then
                    this.Class.FirstUpdateInitialize(this,unit);
                    this.Class.isFirstStepUpdate = true;
                end

                return 1;
            end,

            --LunScript
            runScriptUpdate = function(this , unit , str)
                if str == "runSkillAttack" then return this.Class.runSkillAttack(this,unit) end
                if str == "CoupDeGrace" then return this.Class.CoupDeGrace(this,unit) end
                if str == "healRunSkillEffect" then return this.Class.healRunSkillEffect(this,unit) end
                return 1;
            end,

            --アタック分岐
            takeAttackBranch = function(this,unit,index)
                return 1;
            end,

            --スキル分岐用
            takeSkillBranch = function(this,unit,index)
                if index == 1 then

                    if unit:isMyunit() == true or this.Class.isEnemyType(this,unit) == true then
                        --自分のユニットだったらタイプを切り替えて sendRequest
                        if this.Class.curSkillType == this.Class.SkillAttackTypes.Heal then
    
                            this.Class.curSkillType = this.Class.SkillAttackTypes.Attack;
                            this.Class.ThisUnit:setParameter("113_HealAttack",""..((this.Class.curSkillType - 40001) * -1))
    
                        elseif this.Class.curSkillType == this.Class.SkillAttackTypes.Attack then
        
                            this.Class.curSkillType = this.Class.SkillAttackTypes.Heal;
                            this.Class.ThisUnit:setParameter("113_HealAttack",""..((this.Class.curSkillType - 40001) * -1))
        
                        end


                        --一度消してから付呪
                        local buff =  unit:getTeamUnitCondition():findConditionWithID(-120);
                        if not(buff == nil) then
                            local conditon = unit:getTeamUnitCondition():findConditionWithID(-120);
                            unit:getTeamUnitCondition():removeCondition(conditon);
                        end
                
                        if this.Class.curSkillType == this.Class.SkillAttackTypes.Attack then
                            unit:getTeamUnitCondition():addCondition(-120,this.Class.modeAttack_Buff_ID,this.Class.modeAttack_Buff_Value,2000,this.Class.modeAttack_icon_ID);
                        elseif this.Class.curSkillType == this.Class.SkillAttackTypes.Heal then
                            unit:getTeamUnitCondition():addCondition(-120,this.Class.modeHeal_Buff_ID,this.Class.modeHeal_Buff_Value,2000,this.Class.modeHeal_icon_ID);
                        end

                        this.Class.RequestSendEventToLua(this,unit,this.Class.curSkillType);
                    end


                end

                return 1;
            end,

            --アイドル分岐用
            takeIdleBranch = function(this,unit)
                return 1;
            end,

            --だめーじ分岐用
            takeDamageBranch = function(this,unit)
                return 1;
            end,

            --死亡分岐用
            takeDeadBranch = function(this,unit)
                return 1;
            end,

            --ブレイク分岐用
            takeBreakeBranch = function(this,unit)
                return 1;
            end,

            --excureAction分岐用
            excuteActionBranch = function(this,unit)
                return 1;
            end,

            --receive分岐用
            receiveBranch = function(this,intparam)
                print("----------リクエストを受付中 ID == ",intparam);
                this.Class.curSkillType = intparam;

                if this.Class.ThisUnit ~= nil then
                    this.Class.ThisUnit:setParameter("113_HealAttack",""..((this.Class.curSkillType - 40001) * -1))
                    --一度消してから付呪
                    local buff =  this.Class.ThisUnit:getTeamUnitCondition():findConditionWithID(-120);
                    if not(buff == nil) then
                        local conditon = this.Class.ThisUnit:getTeamUnitCondition():findConditionWithID(-120);
                        this.Class.ThisUnit:getTeamUnitCondition():removeCondition(conditon);
                    end
            
                    if this.Class.curSkillType == this.Class.SkillAttackTypes.Attack then
                        this.Class.ThisUnit:getTeamUnitCondition():addCondition(-120,this.Class.modeAttack_Buff_ID,this.Class.modeAttack_Buff_Value,2000,this.Class.modeAttack_icon_ID);
                    elseif this.Class.curSkillType == this.Class.SkillAttackTypes.Heal then
                        this.Class.ThisUnit:getTeamUnitCondition():addCondition(-120,this.Class.modeHeal_Buff_ID,this.Class.modeHeal_Buff_Value,2000,this.Class.modeHeal_icon_ID);
                    end
                end
                
                return 1;
            end,

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Functions

             --isPlayer == false だったら敵、敵だった場合は isHost が 処理を行う。
            isEnemyType = function (this,unit)

                local isHost = megast.Battle:getInstance():isHost();
                local isPlayer = unit:getisPlayer();

                if isPlayer == false and isHost == true then
                    return true;
                end
                return false;
            end,

            --sendEventToLua
            RequestSendEventToLua = function(this,unit,intparam)

                if unit:isMyunit() == true or this.Class.isEnemyType(this,unit) == true then
                    print("----------リクエストを受付開始 ID == ",intparam);
                    megast.Battle:getInstance():sendEventToLua(this.Class.ThisUniqueId,1,intparam);
                end

                return 1;
            end,


            --アップデート最初の一度のみ実行される。
            FirstUpdateInitialize = function(this,unit)

                this.Class.ThisUnit = unit;

                unit:getTeamUnitCondition():addCondition(-120,this.Class.modeHeal_Buff_ID,this.Class.modeHeal_Buff_Value,2000,this.Class.modeHeal_icon_ID);

                return 1;
            end,

            CoupDeGrace = function(this,unit)

                if this.Class.curSkillType == this.Class.SkillAttackTypes.Attack then

                    local targetUnit = unit:getTargetUnit();

                    --targetUnitが nil だった場合は TargetのPositionを 0 とする。
                    if targetUnit ~= nil then
                        local attack1 = unit:addOrbitSystemInsightRotation("2-skill2-attack-1","emp",999,(targetUnit:getAnimationPositionX() + 370 * unit:getFlip()) - unit:getPositionX(),(targetUnit:getAnimationPositionY() + 75) - unit:getPositionY(),180,-10);
                        attack1:setDamageRateOffset(1/3);
                        attack1:setBreakRateOffset(1/3);
                        attack1:setSPRateOffset(1/3);
                        attack1:setRotation(attack1:getRotation() + 5);
    
                        local attack2 = unit:addOrbitSystemInsightRotation("2-skill2-attack-2","emp",999,(targetUnit:getAnimationPositionX() + 290 * unit:getFlip()) - unit:getPositionX(),(targetUnit:getAnimationPositionY() + 300) - unit:getPositionY(),180,10);
                        attack2:setDamageRateOffset(1/3);
                        attack2:setBreakRateOffset(1/3);
                        attack2:setSPRateOffset(1/3);
                        attack2:setRotation(attack2:getRotation() + 8);

                        local attack3 = unit:addOrbitSystemInsightRotation("2-skill2-attack-3","emp",999,(targetUnit:getAnimationPositionX() + 455 * unit:getFlip())- unit:getPositionX(),(targetUnit:getAnimationPositionY() + 240)- unit:getPositionY(),180,30);
                        attack3:setDamageRateOffset(1/3);
                        attack3:setBreakRateOffset(1/3);
                        attack3:setSPRateOffset(1/3);
                        attack3:setRotation(attack3:getRotation() + 6);
                    else
                        local attack1 = unit:addOrbitSystemInsightRotation("2-skill2-attack-1","emp",999,100,350,180,0);
                        attack1:setDamageRateOffset(1/3);
                        attack1:setBreakRateOffset(1/3);
                        attack1:setSPRateOffset(1/3);
    
                        local attack2 = unit:addOrbitSystemInsightRotation("2-skill2-attack-2","emp",999,200,250,180,0);
                        attack2:setDamageRateOffset(1/3);
                        attack2:setBreakRateOffset(1/3);
                        attack2:setSPRateOffset(1/3);
    
                        local attack3 = unit:addOrbitSystemInsightRotation("2-skill2-attack-3","emp",999,300,350,180,0);
                        attack3:setDamageRateOffset(1/3);
                        attack3:setBreakRateOffset(1/3);
                        attack3:setSPRateOffset(1/3);
                    end

                elseif this.Class.curSkillType == this.Class.SkillAttackTypes.Heal then

                    unit:addOrbitSystem("2-skill2-heal-1",1);
                    unit:addOrbitSystem("2-skill2-heal-2",1);
                    unit:addOrbitSystem("2-skill2-heal-3",1);
                    
                end

                return 1;
            end,

            --アップデート最初の一度のみ実行される。
            playAttackEffect = function(this,unit,attackType)

                if attackType == this.Class.SkillAttackTypes.Attack then

                    local targetUnit = unit:getTargetUnit();

                    if targetUnit ~= nil then
                        unit:addOrbitSystemInsightRotation("2-skill1-attack","emp",999,(targetUnit:getAnimationPositionX() + 270 * unit:getFlip()) - unit:getPositionX(),(targetUnit:getAnimationPositionY() + 200) - unit:getPositionY(),180,0);
                    else
                        unit:addOrbitSystemInsightRotation("2-skill1-attack","emp",999,200,250,180,0);
                    end

                elseif attackType == this.Class.SkillAttackTypes.Heal then
                    unit:addOrbitSystem("2-skill1-heal",1);
                end
                return 1;
            end,

            runSkillAttack = function (this , unit)

                this.Class.playAttackEffect(this,this.Class.ThisUnit,this.Class.curSkillType);

                return 1;
            end,

            healRunSkillEffect = function(this,unit)

                if this.Class.ThisUnit ~= nil then
                    this.Class.ThisUnit:getBurstSkill():runSkillEffect(0);
                end

                return 1;
            end

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        },




        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆



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
            return this.Class.receiveBranch(this,intparam);
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
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            return this.Class.Update(this,unit,deltatime);
        end,

        attackDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return value;
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
            return this.Class.takeAttackBranch(this,unit,index);
        end,

        takeSkill = function (this,unit,index)
            return this.Class.takeSkillBranch(this,unit,index);
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

