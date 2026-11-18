function new(id)
    print("10000 new ");
    local instance = {
        isBacume = false,
        BacumeUnits = {},
        bacumeSpeed = 10,
        BUFF_VALUE = 20,
        BUFF_DURATION = 20,
        -- isDualElement = false,
        messages = summoner.Text:fetchByUnitID(101846112),  

        Suction = function (this,unit)

            print("吸引開始");
            this.isBacume = true;
            for i = 0,6 do
                local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
                if uni ~= nil then
                    print("target is not nil");
                    table.insert(this.BacumeUnits,i);
                end
            end
            return 1;
        end,
        SuctionEnd = function (this,unit)
            this.isBacume = false;
            this.BacumeUnits = {};
            return 1;
        end,

        addBuff = function(this,unit)
            
            --攻撃アップ
            unit:getTeamUnitCondition():addCondition(101841,13,this.BUFF_VALUE,this.BUFF_DURATION,3);
            --防御アップ
            unit:getTeamUnitCondition():addCondition(101842,15,this.BUFF_VALUE,this.BUFF_DURATION,5);
            --最大HPアップ
            unit:getTeamUnitCondition():addCondition(101843,2,this.BUFF_VALUE,this.BUFF_DURATION,1);

            for i = 0,7 do
                local teamUnit = unit:getTeam():getTeamUnit(i);
                if teamUnit ~= nil then       
                    if teamUnit:getElementType() == kElementType_Fire then
                        --攻撃アップ
                        teamUnit:getTeamUnitCondition():addCondition(101844,13,this.BUFF_VALUE,this.BUFF_DURATION,3);
                        --防御アップ
                        teamUnit:getTeamUnitCondition():addCondition(101845,15,this.BUFF_VALUE,this.BUFF_DURATION,5);
                        --最大HPアップ
                        teamUnit:getTeamUnitCondition():addCondition(101846,2,this.BUFF_VALUE,this.BUFF_DURATION,1);
                        teamUnit:playSummary(this.messages.mess1,true);
                    end
                end
            end

            
            return 1;
        end,

 

        -- dualElement = function (this,unit)
        --     this.isDualElement = true;
        --     return 1;
        -- end,

        --共通変数
        param = {
          version = 1.5
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
            if str == "addBuff" then return this.addBuff(this,unit) end
 
            -- if str == "dualElement" then return this.dualElement(this,unit) end
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
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            --吸引中ならアップデートで吸引する
            if this.isBacume then
                for i = 1,table.maxn(this.BacumeUnits) do

                    local targetUnit = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(this.BacumeUnits[i]);
                    if targetUnit ~= nil then
                        local targetx = targetUnit:getPositionX();
                        local thisx = unit:getPositionX();
                        local distance = thisx - targetx;
                        local oneFrame = 0.016666666;
                        local moveSpeed = this.bacumeSpeed * deltatime/oneFrame; --フレームレートで吸引距離が変わらないようにするためdeltaを60fpsで割って掛け算
                        
                        
                        local sign = 1; --距離が＋かーか。１か−１になる
                        if distance < 0 then
                            sign = -1;
                        end
                        
                        
                        targetUnit:setPosition(targetx + moveSpeed * sign,targetUnit:getPositionY());
                        
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

