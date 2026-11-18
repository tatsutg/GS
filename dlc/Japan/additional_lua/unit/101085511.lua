function new(id)
    print("10000 new ");
    local instance = {
        hpDecriment = false,
        decrimentTimer = 0,
        decrimentTargetHP = 0,
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
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "hpDecriment" then 
                this.hpDecriment = true;
                this.decrimentTargetHP = unit:getCalcHPMAX()/5;
            end
            return 1;
        end,


        --共通処理
        castItem = function (this,unit,battleSkill)
            return 1;
        end,

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
            if this.hpDecriment then
                if this.decrimentTimer < 1 and this.decrimentTargetHP > 0 then
                    this.decrimentTimer = this.decrimentTimer + deltatime;
                    local tmp = unit:getCalcHPMAX()/5 * deltatime;
                    
                    -- unit:takeHeal(math.ceil(tmp));
                    local tmp2 = this.decrimentTargetHP - math.ceil(tmp);
                    if tmp2 < 0 then
                        unit:setHP(unit:getHP() - this.decrimentTargetHP);
                        this.decrimentTargetHP = 0;
                        this.decrimentTimer = 0;
                        this.hpDecriment = false;
                    else
                        unit:setHP(unit:getHP() - math.ceil(tmp));
                    end
                    this.decrimentTargetHP = this.decrimentTargetHP - math.ceil(tmp);
                    local damage = math.ceil(tmp)
                    if unit:getHP() < 1 then
                        damage = math.ceil(tmp) + (unit:getHP() - 1)
                        unit:setHP(1);
                        this.decrimentTargetHP = 0;
                        this.decrimentTimer = 0;
                        this.hpDecriment = false;
                    end
                    ---GB_EXボス用対応
                    if megast.Battle:getInstance():isGrandBattleExBoss() then
                        local rate = megast.Battle:getInstance():getGBExBossSPBonusRate()
                        local sp = damage / rate
                        unit:addSP(sp,false,false,true)
                    end
                else
                    this.decrimentTimer = 0;
                    this.hpDecriment = false;
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
            return 1;
        end,

        dead = function (this , unit)
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

