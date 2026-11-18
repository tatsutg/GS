function new(id)
    print("101015411 new ");    --レイアス★5
    local instance = {
        originPosX_player = 0; 
        originPosY_player = 0;
        originPosX_target = 0;
        originPosY_target = 0;

        --共通変数
        param = {
          version = 1.1
          ,isUpdate = 0
        },

        upperSlash = function(this, unit)
            print("◆　◆◆◆◆◆ ◆◆◆ ◆◆◆◆◆　UPPER SLASH!!　◆◆◆◆◆◆◆◆ ◆◆ ◆◆◆◆ ◆◆◆　◆");
            local target = unit:getTargetUnit();
            this.originPosX_target = target:getPositionX();
            this.originPosY_target = target:getPositionY();
            target:superMove(1,1100,1800);
            return 1;
        end,

        highJump = function(this,unit)
            print("★★　★★★　★★★　★★★　★★★　★★★　HIGH JUMP!!　★★★　★★★　★★★　★★★　★★★　★★★　★");
            local target = unit:getTargetUnit();
            local x = target:getPositionX();
            local y = target:getPositionY();
            unit:superMove(1,x+120,y);
            -- if unit:getisPlayer() then
            --     unit:superMove(1,x+120,y);
            -- else
            --     unit:superMove(1,x-120,y);
            -- end
            return 1;
        end,

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "upperSlash" then
                return this.upperSlash(this,unit);
            end

            if str == "highJump" then
                return this.highJump(this,unit);
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
            print("start");
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

