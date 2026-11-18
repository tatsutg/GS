bgOrbit = nil;
wordOrbit = nil;
orbitNumber = 0;
function new(id)
    -- print("10000 new ");
    local instance = {
        uID = id,
        
        mode = kElementType_Aqua;

        --共通変数
        param = {
          version = 1.5
          ,isUpdate = 1
        },


        endless = function(this,unit)
            -- this.removeBGOrbit(this,unit);
            -- this.removewordOrbit(this,unit);
            if orbitNumber == 0 then
                orbitNumber = uID;
                bgOrbit= unit:addOrbitSystem("skill2BG",0);
                bgOrbit:setPositionX(0);
                bgOrbit:setPositionY(0);
            end
            

            return 1;
        end,

        registWord = function(this,unit)
            if orbitNumber == uID then
                wordOrbit = unit;

                local scale = unit:getisPlayer() and 1 or -1;--三項演算子の代わり

                wordOrbit:getSkeleton():setScaleX(scale);
            else
                unit:takeAnimation(0,"empty",false);
            end


            return 1;
        end,

        removewordOrbit = function(this,unit)
            if orbitNumber ~= 0 and orbitNumber == uID then

                if nil == wordOrbit then
                    return 1;
                end
                wordOrbit:takeAnimation(0,"empty",false);
                wordOrbit = nil;
            end
            return 1;
        end,

        removeBGOrbit = function(this,unit)
            if orbitNumber ~= 0 and orbitNumber == uID then
                if nil == bgOrbit then
                    return 1;
                end
                bgOrbit:takeAnimation(0,"empty",false);
                bgOrbit = nil;
                orbitNumber = 0;
            end
            return 1;
        end,


        setElementFire = function(this,unit)
            local skill = unit:getActiveBattleSkill();
            if skill ~= nil then
                skill:setElementType(1);
            end
            return 1;
        end,

        setElementAqua = function(this,unit)
            local skill = unit:getActiveBattleSkill();
            if skill ~= nil then
                skill:setElementType(2);
            end
            return 1;
        end,

        setElementEarth = function(this,unit)
            local skill = unit:getActiveBattleSkill();
            if skill ~= nil then
                skill:setElementType(3);
            end
            return 1;
        end,

        setElementNone = function(this,unit)
            local skill = unit:getActiveBattleSkill();
            if skill ~= nil then
                skill:setElementType(0);
            end
            return 1;
        end,

        utill = {

            showMessage = function(message,rgb,duration,iconid,player)
                if player ~= nil  and player == true then
                    if iconid ~= nil and iconid ~= 0 then
                        BattleControl:get():pushInfomationWithConditionIcon(message,iconid,rgb.r,rgb.g,rgb.b,duration);
                    else
                        BattleControl:get():pushInfomation(message,rgb.r,rgb.g,rgb.b,duration);
                    end
                    return;
                end
                if iconid ~= nil and iconid ~= 0 then
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(message,iconid,rgb.r,rgb.g,rgb.b,duration);
                else
                    BattleControl:get():pushEnemyInfomation(message,rgb.r,rgb.g,rgb.b,duration);
                end
            end
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
            if str == "endless" then return this.endless(this,unit) end
            if str == "registWord" then return this.registWord(this,unit) end
            if str == "removewordOrbit" then return this.removewordOrbit(this,unit) end
            if str == "removeBGOrbit" then return this.removeBGOrbit(this,unit) end
            if str == "setElementFire" then return this.setElementFire(this,unit) end
            if str == "setElementAqua" then return this.setElementAqua(this,unit) end
            if str == "setElementEarth" then return this.setElementEarth(this,unit) end
            if str == "setElementNone" then return this.setElementNone(this,unit) end
            return 1;
        end,

        --共通処理
        attackElementRate = function (this,unit,enemy,value)
            return value;
        end,

        takeElementRate = function (this,unit,enemy,value)
            return value;
        end,

        --version 1.4
        takeIn = function (this,unit)
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
            this.removeBGOrbit(this,unit);
            this.removewordOrbit(this,unit);
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
             if megast.Battle:getInstance():getBattleState() == kBattleState_none then
                wordOrbit = nil;
                bgOrbit = nil;
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
            if orbitNumber ~= 0 and orbitNumber == uID then
                orbitNumber = 0;
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
            if orbitNumber ~= 0 and orbitNumber == uID then
                orbitNumber = 0;
            end
            return 1;
        end,

        dead = function (this , unit)
            if orbitNumber ~= 0 and orbitNumber == uID then
                orbitNumber = 0;
            end
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

