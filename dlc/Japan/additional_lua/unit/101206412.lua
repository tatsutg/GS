function new(id)
    print("101205412 new ");
    local instance = {

        --デュランクラス
        Class = 
        {
            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Values
            isFirstStepUpdate = false,

            --uniqueID
            ThisUniqueId = id,

            --ThisUnit
            ThisUnit = nil,

            resurrection_icon_ID = 37,
            resurrection_Buff_ID = 0,
            resurrection_Buff_Value = 0,

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆


            --初期化
            Initialize = function(this,unit)
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
                if str == "resurrection" then return this.Class.Resurrection(this,unit) end
                return 1;
            end,

            --アタック分岐
            takeAttackBranch = function(this,unit,index)
                return 1;
            end,

            --スキル分岐用
            takeSkillBranch = function(this,unit,index)
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

                if unit:getParameter("isResurrection") == "FALSE" then
                    if this.Class.isDeadUnit(this,unit) then
                        unit:takeAnimation(0,"resurrection",false);
                        unit:takeAnimationEffect(0,"resurrection2",false);
                        unit:setUnitState(kUnitState_skill);
                        unit:setBurstState(kBurstState_active);

                        return 0;
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

                this.Class.ThisUnit:getTeam():reviveUnit(intparam);
                local teamUnit = this.Class.ThisUnit:getTeam():getTeamUnit(intparam,true);
                local targetHP = teamUnit:getCalcHPMAX() / 2 >= 1 and teamUnit:getCalcHPMAX() / 2 or 1;
                teamUnit:setReviveHP(targetHP);
                this.Class.ThisUnit:setParameter("isResurrection","TRUE");   --復活！

                local buff =  this.Class.ThisUnit:getTeamUnitCondition():findConditionWithID(-17);
                if not(buff == nil) then
                    local conditon = this.Class.ThisUnit:getTeamUnitCondition():findConditionWithID(-17);
                    this.Class.ThisUnit:getTeamUnitCondition():removeCondition(conditon);
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
            RequestSendEventToLua = function(this,unit,requestIndex,intparam)

                if unit:isMyunit() == true or this.Class.isEnemyType(this,unit) == true then
                    print("----------リクエストを受付開始 ID == ",intparam);
                    megast.Battle:getInstance():sendEventToLua(this.Class.ThisUniqueId,requestIndex,intparam);
                end

                return 1;
            end,


            --アップデート最初の一度のみ実行される。
            FirstUpdateInitialize = function(this,unit)

                this.Class.ThisUnit = unit;

                --空文字だったら初回生成なので値を代入する
                if unit:getParameter("isResurrection") == "" then
                    unit:getTeamUnitCondition():addCondition(-17,this.Class.resurrection_Buff_ID,this.Class.resurrection_Buff_Value,2000,this.Class.resurrection_icon_ID);
                    unit:setParameter("isResurrection","FALSE");
                elseif unit:getParameter("isResurrection") == "FALSE" then
                    unit:getTeamUnitCondition():addCondition(-17,this.Class.resurrection_Buff_ID,this.Class.resurrection_Buff_Value,2000,this.Class.resurrection_icon_ID);
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


            Resurrection = function (this,unit)

                if unit:isMyunit() == true or this.Class.isEnemyType(this,unit) == true then
                    for i = 0,3 do
                        local teamUnit = unit:getTeam():getTeamUnit(i,true);
                        if teamUnit ~= nil then
                            if teamUnit:getHP() <= 0 then
                                unit:getTeam():reviveUnit(teamUnit:getIndex());
                                local targetHP = teamUnit:getCalcHPMAX() / 2 >= 1 and teamUnit:getCalcHPMAX() / 2 or 1;
                                teamUnit:setReviveHP(targetHP);
        
                                unit:setParameter("isResurrection","TRUE");   --復活！

                                
                                local buff =  unit:getTeamUnitCondition():findConditionWithID(-17);
                                if not(buff == nil) then
                                    local conditon = unit:getTeamUnitCondition():findConditionWithID(-17);
                                    unit:getTeamUnitCondition():removeCondition(conditon);
                                end

                                this.Class.RequestSendEventToLua(this,unit,2,teamUnit:getIndex());
        
                                return 0;
                            end
                        end
                    end
                end

                
    
                return 0;
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
            return this.Class.receiveBranch_1(this,intparam);
        end,

        receive2 = function (this , intparam)
            return this.Class.receiveBranch_2(this,intparam);
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addbuff" then
                this.addbuff(this,unit);
            end
        
            return this.Class.runScriptUpdate(this,unit,str);
        end,
        
        addbuff = function (this,unit)

            return value;
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
            local myTeam = megast.Battle:getInstance():getTeam(false);
            if megast.Battle:getInstance():isPvp() then
                local cond = unit:getTeamUnitCondition():findConditionWithType(84);
                if cond ~= nil then
                    if enemy:getHP() < 1 then
                        enemy:setHP(1)
                    end
                    --enemy:setInvincibleTime(0.5)
                    local hp = enemy:getHP() - value
                    if hp < 1 then
                        value = enemy:getHP() - 1
                    end
                end
            end
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            local cond = unit:getTeamUnitCondition():findConditionWithType(84);
            if cond ~= nil then
                unit:addOrbitSystem("reflection",0);
            end

            --夢幻進化：玉夢
            if unit:getFantasyEvolutionType() == 4 then
                --闘争心
                if unit:getTeamUnitCondition():findConditionWithType(98) == nil then
                    this.damage = this.damage + value
                    unit:addSPWithPvpCorrection((math.floor(this.damage/this.spGainTime)) * this.rate)
                    this.damage = this.damage % this.spGainTime
                end
            end
            return value;
        end,

        --version1.0
        start = function (this , unit)
            this.reviveFLG = {}
            for i = 0,6 do
                this.reviveFLG[i] = false
            end
            this.damage = 0;
            this.rate = 5;
            this.spGainTime = math.floor(unit:getCalcHPMAX() * 0.1);
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

