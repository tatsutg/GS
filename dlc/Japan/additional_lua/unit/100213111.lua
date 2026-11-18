function new(id)
    print("create instance 100212111 ")
    local instance = {

        meteor1 = function (unit)
            local meteo = unit:addOrbitSystem("Meteor");
            local tgt = unit:getTargetUnit();
            if tgt ~= nil then
                meteo:setPosition(tgt:getPositionX()+60,tgt:getPositionY()-20);
            end
            return 1;
        end,

        meteor2 = function (unit)
            local meteo = unit:addOrbitSystem("Meteor");
            local tgt = unit:getTargetUnit();
            if tgt ~= nil then
                meteo:setPosition(tgt:getPositionX()-50,tgt:getPositionY());
            end
            return 1;
        end,

        meteor3 = function (unit)
            local meteo = unit:addOrbitSystem("Meteor");
            local tgt = unit:getTargetUnit();
            if tgt ~= nil then
                meteo:setPosition(tgt:getPositionX()+50,tgt:getPositionY()+50);
            end
            return 1;
        end,

        meteor4 = function (unit)
            local meteo = unit:addOrbitSystem("Meteor");
            local tgt = unit:getTargetUnit();
            if tgt ~= nil then
                meteo:setPosition(tgt:getPositionX(),tgt:getPositionY()-40);
            end
            return 1;
        end,

        meteor5 = function (unit)
            local meteo = unit:addOrbitSystem("Meteor");
            local tgt = unit:getTargetUnit();
            if tgt ~= nil then
                meteo:setPosition(tgt:getPositionX()-100,tgt:getPositionY()+50);
            end
            return 1;
        end,

        meteor6 = function (unit)
            local meteo = unit:addOrbitSystem("Meteor");
            local tgt = unit:getTargetUnit();
            if tgt ~= nil then
                meteo:setPosition(tgt:getPositionX()+100,tgt:getPositionY()-50);
            end
            return 1;
        end,

        meteor7 = function (unit)
            local meteo = unit:addOrbitSystem("Meteor");
            local tgt = unit:getTargetUnit();
            if tgt ~= nil then
                meteo:setPosition(tgt:getPositionX()-50,tgt:getPositionY()-50);
            end
            return 1;
        end,

        meteor8 = function (unit)
            local meteo = unit:addOrbitSystem("Meteor");
            local tgt = unit:getTargetUnit();
            if tgt ~= nil then
                meteo:setPosition(tgt:getPositionX(),tgt:getPositionY());
            end
            return 1;
        end,

        meteorFinal = function (unit)
            local meteo = unit:addOrbitSystem("MeteorFinal");
            local tgt = unit:getTargetUnit();
            if tgt ~= nil then
                meteo:setPosition(tgt:getPositionX(),tgt:getPositionY());
            end
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
            if str == "meteor1" then
                return this.meteor1(unit)
            end

            if str == "meteor2" then
                return this.meteor2(unit)
            end

            if str == "meteor3" then
                return this.meteor3(unit)
            end

            if str == "meteor4" then
                return this.meteor4(unit)
            end

            if str == "meteor5" then
                return this.meteor5(unit)
            end

            if str == "meteor6" then
                return this.meteor6(unit)
            end

            if str == "meteor7" then
                return this.meteor7(unit)
            end

            if str == "meteor8" then
                return this.meteor8(unit)
            end

            if str == "meteorFinal" then
                return this.meteorFinal(unit)
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

