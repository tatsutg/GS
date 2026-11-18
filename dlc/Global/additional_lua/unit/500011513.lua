function new(id)
    print("10000 new ");
    local instance = {
        skillChecker = false,
        attackChecker = false,
        skillExecFlag = false,
        myself = nil,

        Exc = function (this,unit)
            if this.skillExecFlag then
                local posx = unit:getPositionX();
                local ishost = megast.Battle:getInstance():isHost();
                if ishost then
                    if posx > 0 then
                        this.skillExecFlag = true;
                        unit:takeBack();
                        megast.Battle:getInstance():sendEventToLua(190011510,1,1);
                        return 1;
                    else
                        this.skillExecFlag = false;
                        unit:takeAnimation(0,"charge_long",false);
                        unit:takeAnimationEffect(0,"charge_long",false);
                        megast.Battle:getInstance():sendEventToLua(190011510,2,1);
                        return 1;
                    end
                end
            end
            return 1;
        end,

        chargeEnd = function (this , unit)
            this.skillChecker = true;
            unit:takeSkill(1);
            unit:setBurstPoint(0);
            return 1;
        end,

        chargeEnd2 = function (this,unit)
            this.attackChecker = true;
            unit:takeAttack(4);
            return 1;
        end,


        addSP = function (this , unit)
            unit:addSP(20);
            return 1;
        end,

        charge = function (this)
            this.myself:takeAnimation(0,"charge_long",false);
            this.myself:takeAnimationEffect(0,"charge_long",false);
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "Exc" then return this.Exc(this,unit) end
            if str == "chargeEnd" then return this.chargeEnd(this,unit) end
            if str == "chargeEnd2" then return this.chargeEnd2(this,unit) end
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "charge" then return this.charge(this) end
            return 1;
        end,

        --共通変数
        param = {
          version = 1.1
          ,isUpdate = 0
        },
        thisid = id,

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            this.skillExecFlag = true;
            return 1;
        end,
        receive2 = function (this , intparam)
            this.charge(this);
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
            this.myself = unit;
            
            unit:setSPGainValue(0);
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
            if index == 1 then
                unit:setActiveSkill(2);
            elseif index == 2 then
                unit:setActiveSkill(3);
            elseif index == 3 then
                unit:setActiveSkill(4);
            elseif index == 4 then
                unit:setActiveSkill(5);
            end
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                local target = unit:getTargetUnit() 
                local distance = BattleUtilities.getUnitDistance(unit,target)
                print(distance);
                if distance > 400 and this.attackChecker == false then
                    this.attackChecker = true
                    unit:takeAttack(3)
                    return 0;
                elseif this.attackChecker == false then
                    print("kita");
                    this.attackChecker = true;
                    rand = LuaUtilities.rand(0,100);
                    if rand <= 30 then
                        unit:takeAttack(1);
                    elseif  rand < 60 then
                        unit:takeAttack(2);
                    elseif rand < 90 then
                        unit:takeAttack(3);
                    else
                        unit:takeAnimation(0,"charge_short",false);
                        unit:takeAnimationEffect(0,"charge_short",false);
                    end
                    return 0;
                end
                this.attackChecker = false
            end
            return 1;
        end,

        takeSkill = function (this,unit,index)

            if index == 1 then
                unit:setActiveSkill(1);
            end
            ishost = megast.Battle:getInstance():isHost();
            if ishost then
                rand = LuaUtilities.rand(0,100);
                if not this.skillChecker then
                    unit:setBurstPoint(99);
                    local posx = unit:getPositionX();
                    
                    unit:takeAnimation(0,"charge_long",false);
                    unit:takeAnimationEffect(0,"charge_long",false);
                    megast.Battle:getInstance():sendEventToLua(this.thisid,2,1);
                    
                    return 0;
                end
            elseif not this.skillChecker then
                return 0;
            end

            this.skillChecker = false;
            return 1;
        end,

        takeDamage = function (this , unit)
            this.skillChecker = false;
            return 1;
        end,

        dead = function (this , unit)
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

