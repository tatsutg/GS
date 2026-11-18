function new(id)
    print("10000 new ");
    local instance = {
        skillChecker = false,
        attackChecker = false,
        isSkill3 = false,
        myself = nil,
        seeds = {},
        thisid = id,
        randL = 0,
        randR = 0,
        consts = {
            attack1Rate = 30,
            attack2Rate = 30,
            attack3Rate = 40,
            seedRate = 30, --種を飛ばす確率の基礎％　ここに現在のHPの減少割合/2の値が足される
            seedHP = 4000
        },
        isRuHolding = true,
        RuTimer = 0,


        seedR = function (this,unit)
            
            local orbitsystemName = "seedRtype1";
            
            if this.randR <= 30 then
                orbitsystemName = "seedRtype1";
            elseif this.randR < 60 then
                orbitsystemName = "seedRtype2";
            else
                orbitsystemName = "seedRtype3";
            end
            local seed = unit:addOrbitSystem(orbitsystemName,2);
            seed:setHitCountMax(999);
            seed:setEndAnimationName("seedEnd");
            seed:setActiveSkill(4);
            seed:setBaseHP(this.consts.seedHP);
            seed:setHP(this.consts.seedHP);
            table.insert(this.seeds,seed);
            
            return 1;
        end,

        seedL = function (this,unit)
            
            local orbitsystemName = "seedLtype1";
            
            if this.randL <= 30 then
                orbitsystemName = "seedLtype1";
            elseif this.randL < 60 then
                orbitsystemName = "seedLtype2";
            else
                orbitsystemName = "seedLtype3";
            end
            local seed = unit:addOrbitSystem(orbitsystemName,2);
            seed:setHitCountMax(999);
            seed:setEndAnimationName("seedEnd");
            seed:setActiveSkill(4);
            seed:setBaseHP(this.consts.seedHP);
            seed:setHP(this.consts.seedHP);
            table.insert(this.seeds,seed);
            return 1;
        end,


        setSeedZOrder = function (this,unit)
            unit:setZOrder(-(unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN")) + 3000);

            unit:enableShadow(true);
            return 1;
        end,

        skill3Start = function (this,unit)
            this.isSkill3 = true;
            return 1;
        end,

        skill3End = function(this,unit)
            this.isSkill3 = false;
            return 1;
        end,

        addSP = function (this,unit)
            unit:addSP(20);
            return 1;
        end,

        seedEnd = function (this,unit)
            local  atari = 0;
            for i = 1,table.maxn(this.seeds) do
                print("Destroy")
                if this.seeds[i] == unit then
                    atari = i
                end

            end
            if atari ~= 0 then
                table.remove(this.seeds,atari);
            end
            return 1;
        end,

        ruEnd = function (this,unit)
            this.RuTimer = 0;
            return 1;
        end,

        --共通変数
        param = {
          version = 1.3
          ,isUpdate = 1
        },

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            this.randL = intparam;
            return 1;
        end,

        receive2 = function (this , intparam)
            this.randR = intparam;
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "seedR" then return this.seedR(this,unit) end
            if str == "seedL" then return this.seedL(this,unit) end
            if str == "skill3Start" then return this.skill3Start(this,unit) end
            if str == "skill3End" then return this.skill3End(this,unit) end
            if str == "addSP" then return this.addSP(this,unit) end 
            if str == "seedEnd" then return this.seedEnd(this,unit) end
            if str == "setSeedZOrder" then return this.setSeedZOrder(this,unit) end
            if str == "ruEnd" then return this.ruEnd(this,unit) end 
            return 1;
        end,

        --version 1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
            return value;
        end,

        takeBreake = function (this,unit)
            if this.isRuHolding and unit == this.myself then
                unit:takeAnimation(1,"holdEnd",false);
                unit:takeAnimation(0,"ru_falldown",false);
                unit:setSetupAnimationName("");
                this.isRuHolding = false;
                this.RuTimer = 3;
                unit:setAttackTimer(5);
                return 0;
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
            if this.RuTimer > 0 then
                this.RuTimer = this.RuTimer - deltatime;
            end
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            if this.isSkill3 then
                
                if unit:getActiveBattleSkill() ~= nil then
                    unit:getActiveBattleSkill():runSkillEffect(0);
                end
                return 55;
            end
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        --version1.0
        start = function (this , unit)
            unit:setSPGainValue(0);
            this.myself = unit;
            unit:takeAnimation(1,"ru_hold",true);
            unit:setSetupAnimationName("setUpRu");
            
            return 1;
        end,

        excuteAction = function (this , unit)
            if this.RuTimer > 0 then
                return 0;
            end
            return 1;
        end,

        takeIdle = function (this , unit)
            if this.RuTimer > 0 then
                return 0;
            end
            local hpparcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if hpparcent < 60 then
                unit:setNextAnimationName("idle1");
            elseif hpparcent < 30 then
                unit:setNextAnimationName("idle2");
            end
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
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            elseif index == 3 then
                unit:setActiveSkill(3);
            elseif index == 4 then
                
            end
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                local target = unit:getTargetUnit() 
                local distance = BattleUtilities.getUnitDistance(unit,target)
                print(distance);
                if distance > 450 and this.attackChecker == false then
                    this.attackChecker = true
                    unit:takeAttack(3)
                    return 0;
                elseif this.attackChecker == false then
                    print("kita");
                    this.attackChecker = true;
                    local rand = LuaUtilities.rand(0,100);
                    
                    --種がない場合はまず先に種飛ばし判定
                    if table.maxn(this.seeds) <= 0 then
                        local rand2 = LuaUtilities.rand(0,100);
                        local hpparcent = 100 * unit:getHP()/unit:getCalcHPMAX();

                        --HPが少なければ少ないほど種を飛ばしやすくなる
                        if rand2 <= this.consts.seedRate + (100 - hpparcent)/2 then
                            unit:takeAttack(4);
                            this.randR = LuaUtilities.rand(0,100);
                            this.randL = LuaUtilities.rand(0,100);
                            megast.Battle:getInstance():sendEventToLua(this.thisid,1,this.randL);
                            megast.Battle:getInstance():sendEventToLua(this.thisid,2,this.randR);
                            return 0;
                        end
                    end

                    --どの攻撃を出すのか判定
                    if rand <= this.consts.attack1Rate then
                        unit:takeAttack(1);
                    elseif  rand < this.consts.attack1Rate + this.consts.attack2Rate then
                        unit:takeAttack(2);
                    elseif rand <= 100 then
                        unit:takeAttack(3);
                    end
                    return 0;
                end
                this.attackChecker = false
            end
            return 1;
        end,

        takeSkill = function (this,unit,index)
            if index == 1 then
                unit:setActiveSkill(6);
            elseif index == 2 then
                unit:setActiveSkill(5);
            elseif index == 3 then
                unit:setActiveSkill(7);
            elseif index == 4 then
                unit:setActiveSkill(5);
            end
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                -- local target = unit:getTargetUnit() 
                -- local distance = BattleUtilities.getUnitDistance(unit,target)

               if this.skillChecker == false then
                    print("kita");
                    this.skillChecker = true;
                    rand = LuaUtilities.rand(0,100);
                    if rand <= 30 then
                        unit:takeSkill(1);
                    elseif  rand < 60 then
                        unit:takeSkill(2);
                    elseif rand <= 100 then
                        unit:takeSkill(3);
                    end
                    return 0;
                end
                this.skillChecker = false
            end
            return 1;
        end,

        takeDamage = function (this , unit)
            if this.RuTimer > 0  and unit == this.myself then
                return 0;
            end
            return 1;
        end,

        dead = function (this , unit)
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

