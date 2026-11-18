function new(id)
    print("create instance 100392411")
    local instance = {

        SetHevnPanish = function (unit)
            -- unit:getTeamUnitCondition():addCondition(-12,0,0,2000,4);
            -- unit:getTeamUnitCondition():addCondition(-13,0,0,2000,0);
            -- unit:getTeamUnitCondition():addCondition(-14,0,0,2000,0);
            -- unit:getTeamUnitCondition():addCondition(-15,0,0,2000,0);
            return 1;
        end,

        ResetHevnPanish = function (unit)
            -- local conditon = unit:getTeamUnitCondition():findConditionWithID(-12);
            -- unit:getTeamUnitCondition():removeCondition(conditon);
            return 1;
        end,

        Execution1 = function (node)
            local tenbatu = node:addOrbitSystem("HevnPanish");
            tenbatu:setPosition(50,0);
            tenbatu:setDamageRateOffset(1/4);
            tenbatu:setBreakRate(1/4);

            return 1;
        end,

        Execution2 = function (node)
            local tenbatu = node:addOrbitSystem("HevnPanish");
            tenbatu:setPosition(200,-90);
            tenbatu:setDamageRateOffset(1/4);
            tenbatu:setBreakRate(1/4);
            return 1;
        end,

        Execution3 = function (node)
            local tenbatu = node:addOrbitSystem("HevnPanish");
            tenbatu:setPosition(-100,90);
            tenbatu:setDamageRateOffset(1/4);
            tenbatu:setBreakRate(1/4);
            return 1;
        end,

        Execution4 = function (node)
            local tenbatu = node:addOrbitSystem("HevnPanish");
            tenbatu:setPosition(-250,-120);
            tenbatu:setDamageRateOffset(1/4);
            tenbatu:setBreakRate(1/4);
            return 1;
        end,

        Execution5 = function (node)
            local buff =  node:getTeamUnitCondition():findConditionWithID(-12);
            if not(buff == nil) then
                local conditon = node:getTeamUnitCondition():findConditionWithID(-12);
                node:getTeamUnitCondition():removeCondition(conditon);
                local tenbatu = node:addOrbitSystem("HevnPanish");
                tenbatu:setPosition(-100,0);
            end
            return 1;
        end,

        Execution6 = function (node)
            local buff =  node:getTeamUnitCondition():findConditionWithID(-13);
            if not(buff == nil) then
                local conditon = node:getTeamUnitCondition():findConditionWithID(-13);
                node:getTeamUnitCondition():removeCondition(conditon);
                local tenbatu = node:addOrbitSystem("HevnPanish");
                tenbatu:setPosition(100,-80);
            end
            return 1;
        end,

        Execution7 = function (node)
            local buff =  node:getTeamUnitCondition():findConditionWithID(-14);
            if not(buff == nil) then
                local conditon = node:getTeamUnitCondition():findConditionWithID(-14);
                node:getTeamUnitCondition():removeCondition(conditon);
                local tenbatu = node:addOrbitSystem("HevnPanish");
                tenbatu:setPosition(300,50);
            end
            return 1;
        end,

        Execution8 = function (node)
            local buff =  node:getTeamUnitCondition():findConditionWithID(-15);
            if not(buff == nil) then
                local conditon = node:getTeamUnitCondition():findConditionWithID(-15);
                node:getTeamUnitCondition():removeCondition(conditon);
                local tenbatu = node:addOrbitSystem("HevnPanish");
                tenbatu:setPosition(0,-10);
            end
            return 1;
        end,

        ExecutionEx1 = function (node)
            local tenbatu = node:addOrbitSystem("HevnPanish");
            tenbatu:setPosition(250,0);
            tenbatu:setDamageRateOffset(1/4);
            tenbatu:setBreakRate(1/4);
            return 1;
        end,

        ExecutionEx2 = function (node)
            local tenbatu = node:addOrbitSystem("HevnPanish");
            tenbatu:setPosition(-10,0);
            tenbatu:setDamageRateOffset(1/4);
            tenbatu:setBreakRate(1/4);
            return 1;
        end,

        --共通変数
        param = {
          version = 1.2
          ,isUpdate = 0
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
            if str == "SetHevnPanish" then
                return this.SetHevnPanish(unit)
            end

            if str == "ResetHevnPanish" then
                return this.ResetHevnPanish(unit)
            end

            if str == "Execution1" then
                return this.Execution1(unit)
            end

            if str == "Execution2" then
                return this.Execution2(unit)
            end

            if str == "Execution3" then
                return this.Execution3(unit)
            end

            if str == "Execution4" then
                return this.Execution4(unit)
            end

            if str == "Execution5" then
                return this.Execution5(unit)
            end

            if str == "Execution6" then
                return this.Execution6(unit)
            end

            if str == "Execution7" then
                return this.Execution7(unit)
            end

            if str == "Execution8" then
                return this.Execution8(unit)
            end

            if str == "ExecutionEx1" then
                return this.ExecutionEx1(unit)
            end

            if str == "ExecutionEx2" then
                return this.ExecutionEx2(unit)
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
            return 1;
        end,

        excuteAction = function (this , unit)
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
