function new(id)
    print("10000 new ");
    local instance = {

        --ソフィクラス
        Class = 
        {
            --Values
            --各アタックのレート
            attackRates = 
            {
                 --アタックレート1
                rate_attack1 = 20,
    
                --アタックレート2
                rate_attack2 = 35,


                --遠距離攻撃判定距離
                longAttackRange_Boomerang = 150,
                longAttackRange_Humicomi = 150
    
                --アタックレート3
                --rate_skill1 = 45,
    
                --アタックレート4
                --rate_attack4 = 30
            },

            --各スキルのクールタイム設定
            delayMaxTimers = 
            {
                attack4_Ct = 8,
                skill1_Ct = 20
            },
            delayCounterTimers = 
            {
                attack4_Ct = 0,
                skill1_Ct = 0
            },

            --アタックチェック
            isAttackChecker = false,

            --スキルチェック
            isSkillChecker = false,

            --HP減少時のスキル発動パーセント
            limitHpPercent = 75,

            --HP減少時にスキル発動確率
            limitSkillRate = 50,

            --バックステップを行う　X　座標
            takeBackStepRange = 150,

            --Functions
            runScriptUpdate = function(this , unit , str)

                if str == "addSP" then return this.Class.addSP(this,unit) end

                return 1;
            end,


            addSP = function (this,unit)
                unit:addSP(20);
                return 1;
            end,

            getTargetDistance = function(this,unit)
                if unit ~= nil then

                    local targetUnit = unit:getTargetUnit();
                    if targetUnit == nil then
                        return 1;
                    end
    
                    local tUX = targetUnit:getAnimationPositionX();
                    local zUX = unit:getAnimationPositionX();

                    tUX = math.floor(tUX);
                    zUX = math.floor(zUX);

                    --print("敵X = ",tUX);
                    --print("自分 X = ",zUX);
    
                    local distance = math.abs(tUX - zUX);

                    distance = math.floor(distance);

                    --print("distance = ",distance);

                    return distance;
                end

                return 1;
            end,

            --アタック分岐用
            takeAttackBranch = function(this,unit,index)
                if unit ~= nil then

                    --遠距離時、近距離時でいろいろ挙動が変わる。またCTなどもあるため、それによって様々な挙動を見せる。
                    local targetDistance = this.Class.getTargetDistance(this,unit);

                    --距離が 300 以上離れていたらブーメランで攻撃する
                    if this.Class.attackRates.longAttackRange_Boomerang < targetDistance then

                        --残念CT中だった
                        if this.Class.delayCounterTimers.attack4_Ct >= this.Class.delayMaxTimers.attack4_Ct then 
                            unit:takeAttack(4);

                            this.Class.delayCounterTimers.attack4_Ct = 0;
    
                            return 0;
                        end
                    end

                    --longAttackRange_Humicomi ~ longAttackRange_Boomerang の範囲距離だった場合は前進攻撃
                    if this.Class.attackRates.longAttackRange_Humicomi < targetDistance then
                        unit:takeAttack(3);
                        this.Class.resetAttackTime(this,unit);

                        return 0;
                    end

                    --それ以外はランダム。ランダムは 百分率。アタック1,アタック2,の確率合計を 100 から引いた値が 確率になります。
                    --スキルのdelayがまだあった場合はそれ抜きでランダム、あればそれアリでランダムで、もし攻撃がでたらCTを初期化する
                    local random = math.random(this.Class.attackRates.rate_attack1 + this.Class.attackRates.rate_attack2);
                    if this.Class.delayCounterTimers.skill1_Ct >= this.Class.delayMaxTimers.skill1_Ct then
                        random = math.random(100);
                    end

                    if random <= this.Class.attackRates.rate_attack1 then
                        unit:takeAttack(1);
                        return 0;
                    elseif random <= this.Class.attackRates.rate_attack1 + this.Class.attackRates.rate_attack2 then
                        unit:takeAttack(2);
                        return 0;
                    elseif random <= 100 then
                        this.Class.delayCounterTimers.skill1_Ct = 0;
                        unit:takeSkill(1);
                        print("☆☆☆☆☆☆☆☆☆☆☆☆☆☆　unit TakeSkill 1 Start ☆☆☆☆☆☆☆☆☆☆☆☆☆☆");
                        return 0;
                    end
                end

                return 1;
            end,

            --スキル分岐用
            takeSkillBranch = function(this,unit,index)
                local random = math.random(100);
                local curHpParcent = 100 * unit:getHP() / unit:getCalcHPMAX();
                if curHpParcent < this.Class.limitHpPercent then
                    if random <= this.Class.limitSkillRate then
                        unit:takeSkillWithCutin(2);
                        return 0;
                    end
                end

                unit:takeSkill(3);
                print("☆☆☆☆☆☆☆☆☆☆☆☆☆☆　unit TakeSkill 3 Start　☆☆☆☆☆☆☆☆☆☆☆☆☆☆");
                this.Class.resetAttackTime(this,unit);

                return 0;
            end,

            --アイドル分岐用
            takeIdleBranch = function(this,unit)

                if this.Class.takeBackStepRange <= unit:getAnimationPositionX() then
                    this.takeBack();
                    this.Class.resetAttackTime(this,unit);

                end

                return 1;
            end,

            --初期化
            Initialize = function(this,unit)

                return 1;
            end,

            --アップデート
            Update = function(this,unit,deltatime)
                this.Class.delayCounterTimers.attack4_Ct = this.Class.delayCounterTimers.attack4_Ct + deltatime;
                this.Class.delayCounterTimers.skill1_Ct = this.Class.delayCounterTimers.skill1_Ct + deltatime;
                return 1;
            end,

            --アタックタイマーをリセットする
            resetAttackTime = function(this,unit)
                if unit ~= nil then
                    unit:setAttackTimer(0);
                end
            end
        },






        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆





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
            return this.Class.runScriptUpdate(this,unit,str);
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
            return this.Class.Update(this,unit,deltatime);
        end,

        attackDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        --version1.0
        start = function (this , unit)

            return this.Class.Initialize(this,unit);

        end,

        excuteAction = function (this , unit)
            return 1;
        end,

        takeIdle = function (this , unit)

            return this.Class.takeIdleBranch(this,unit);

        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
         
            return 1;
        end,

        takeAttack = function (this , unit , index)
            local isHost = megast.Battle:getInstance():isHost();
            if isHost then

                if this.Class.isAttackChecker == false then
                    this.Class.isAttackChecker = true;
                    return this.Class.takeAttackBranch(this,unit,index);
                end
                this.Class.isAttackChecker = false;
            
            end
            return 1;
        end,

        takeSkill = function (this,unit,index)
            local isHost = megast.Battle:getInstance():isHost();
            if isHost then

                if this.Class.isAttackChecker then
                    return 1;
                end

                if this.Class.isSkillChecker == false then
                    this.Class.isSkillChecker = true;
                    return this.Class.takeSkillBranch(this,unit,index);
                end
                this.Class.isSkillChecker = false;

            end
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

