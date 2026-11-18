function new(id)
    print("10102411 new "); -- 覚醒フィーナ
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
        isPlayerUnit = true,



        --アップデート最初の一度のみ実行される。
        FirstUpdateInitialize = function(this,unit)
            this.ThisUnit = unit;
            --空文字だったら初回生成なので値を代入する
            if unit:getParameter("isRinascita") == "" and unit:getLevel() >= 90 then
                unit:getTeamUnitCondition():addCondition(-44,this.rinascita_Buff_ID,this.rinascita_Buff_Value,2000,this.rinascita_icon_ID);
                unit:setParameter("isRinascita","FALSE");
            elseif unit:getParameter("isRinascita") == "FALSE" and unit:getLevel() >= 90 then
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
                            local targetHP = teamUnit:getCalcHPMAX() / 3 >= 1 and teamUnit:getCalcHPMAX() / 3 or 1;
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
            local targetHP = teamUnit:getCalcHPMAX() / 3 >= 1 and teamUnit:getCalcHPMAX() / 3 or 1;
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

            if str == "Rinascita" then return this.Rinascita(this,unit) end

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

            if this.isFirstStepUpdate == false then
                this.FirstUpdateInitialize(this,unit);
                this.isFirstStepUpdate = true;
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

            return 1;
        end,

        excuteAction = function (this , unit)

            if unit:getParameter("isRinascita") == "FALSE" then
                if this.isDeadUnit(this,unit) and unit:getLevel() >= 90 then
                    unit:takeAnimation(0,"Rinascita",false);
                    unit:takeAnimationEffect(0,"2_Rinascita",false);
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