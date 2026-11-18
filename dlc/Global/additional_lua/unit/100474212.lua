function new(id)
    print("10000 new ");
    local instance = {
        isDison = false,
        disonUnits = {},
        Suction = function (this,unit)

            print("吸引開始");
            this.isDison = true;
            for i = 0,6 do
                local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
                if uni ~= nil then
                    print("target is not nil");
                    table.insert(this.disonUnits,i);
                end
            end
            return 1;
        end,
        SuctionEnd = function (this,unit)
            this.isDison = false;
            this.disonUnits = {};
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
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "Suction" then return this.Suction(this,unit) end
            if str == "SuctionEnd" then return this.SuctionEnd(this,unit) end
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
            if this.isDison then
                for i = 1,table.maxn(this.disonUnits) do
                    local targetUnit = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(this.disonUnits[i]);
                    if targetUnit ~= nil then
                        local targetx = targetUnit:getPositionX();
                        local thisx = unit:getPositionX();
                        local distance = thisx - targetx;
                        local limitX = 500;
                        local oneFrame = 0.016666666;
                        local moveSpeed = 7 * deltatime/oneFrame;
                        
                        targetUnit:setPosition(targetx + moveSpeed * distance/math.abs(distance),targetUnit:getPositionY());
                        
                    end
                end
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
            return 1;
        end,

        excuteAction = function (this , unit)
            this.SuctionEnd(this,unit);
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
            this.SuctionEnd(this,unit);
            return 1;
        end,

        dead = function (this , unit)
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

