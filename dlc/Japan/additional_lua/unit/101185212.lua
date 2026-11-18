function new(id)
    print("10000 new ");
    local instance = {

        attackChecker = false,

        Borders = 
        {
            frontBorder = 400,
            backBorder = 300
        },


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
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
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

            if not this.attackChecker then

                this.attackChecker = true;

                local targetUnit = unit:getTargetUnit();
                
                if targetUnit == nil then
                    return 1;
                end
                
                local offset = 0;
                if targetUnit:getSize() == 3 then
                    offset = 250;
                end

                local tUX = targetUnit:getPositionX();
                local zUX = unit:getPositionX();

                local distance = math.abs(tUX - zUX);

                if distance < this.Borders.backBorder + offset then
                    
                    unit:takeAttack(3);
                    
                    return 0;

                elseif this.Borders.frontBorder + offset < distance then

                    unit:takeAttack(2);

                    return 0;

                end
            end

            this.attackChecker = false;

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
    return 1;
end

