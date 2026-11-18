function new(id)
    print("101225112 new ");
    local instance = {

        --ソレイユクラス
        Class = 
        {
            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Values
            isFirstStepUpdate = false,

            --uniqueID
            ThisUniqueId = id,

            --ThisUnit
            ThisUnit = nil,

            --burstBurningの確率
            burstBurning_Skill1_Probability = 100,
            burstBurning_Skill2_Probability = 100,

            burstBurning_Buff_ID = 97,

            --バーストばーにんぐかうんたー Skillはこのカウンターを基準にしてオーバーヒートする
            burstBurning_cur_Counter = 0,
            burstBurning_Maxmum = 3,

            --バーストばーにんぐアイコンID
            burstBurning_icon_ID_Stage_1 = 104,
            burstBurning_icon_ID_Stage_2 = 105,

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆


            --初期化
            Initialize = function(this,unit)
                return 1;
            end,

            --アップデート
            Update = function(this,unit,deltatime)

                if this.Class.isFirstStepUpdate == false then
                    this.Class.FirstUpdateInitialize(this,unit);
                    this.Class.isFirstStepUpdate = true;
                end

                return 1;
            end,

            --LunScript
            --if str == "runSkillAttack" then return this.Class.runSkillAttack(this,unit) end
            runScriptUpdate = function(this , unit , str)

                if str == "skill1Shot" then return this.Class.skill1Shot(this,unit) end

                if str == "BurstBurningSkill1" then return this.Class.BurstBurning_Skill1(this,unit) end
                if str == "BurstBurningSkill2" then return this.Class.BurstBurning_Skill2(this,unit) end

                return 1;
            end,

            --アタック分岐
            takeAttackBranch = function(this,unit,index)
                return 1;
            end,

            --スキル分岐用
            takeSkillBranch = function(this,unit,index)
                return 1;
            end,

            --アイドル分岐用
            takeIdleBranch = function(this,unit)
                return 1;
            end,

            --だめーじ分岐用
            takeDamageBranch = function(this,unit)
                return 1;
            end,

            --死亡分岐用
            takeDeadBranch = function(this,unit)
                return 1;
            end,

            --ブレイク分岐用
            takeBreakeBranch = function(this,unit)
                return 1;
            end,

            --excureAction分岐用
            excuteActionBranch = function(this,unit)
                return 1;
            end,

            --receive分岐用
            receiveBranch_1 = function(this,intparam)

                if intparam == 1 then
                    this.Class.ThisUnit:getNormalSkill():runSkillEffect(0);
                end

                return 1;
            end,

            receiveBranch_2 = function(this,intparam)

                this.Class.burstBurning_cur_Counter = intparam;
                this.Class.burstBurningIconSetUp(this,this.Class.ThisUnit);

                return 1;
            end,

            --attackDamageValue分岐用
            attackDamageValueBranch = function(this , unit , enemy , value)
                return value;
            end,

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Functions

            --アップデート最初の一度のみ実行される。
            FirstUpdateInitialize = function(this,unit)

                this.Class.ThisUnit = unit;

                return 1;
            end,

            skill1Shot= function(this,unit)
                unit:addOrbitSystemInsightRotation("2_skill1_boll","2_skill1_explosion",1,-60,100,180,0);

                return 1;
            end,

            BurstBurning_Skill1 = function(this,unit)
                this.Class.requestSkillBurstBurning(this,unit);
                return 1;
            end,

            BurstBurning_Skill2 = function(this,unit)
                this.Class.BurstBurning(this,unit,this.Class.burstBurning_Skill2_Probability);
                return 1;
            end,

            BurstBurning = function(this,unit,probability)

                if unit:isMyunit() == true or this.Class.isEnemyType(this,unit) == true then

                    local randPro = math.random(0,100);

                    if randPro <= probability then

                        unit:getNormalSkill():runSkillEffect(0);

                        print("runSkillEffect(0)");
    
                        this.Class.RequestSendEventToLua(this,unit,1,1);
                    end
                end

                return 1;
            end,

            --isPlayer == false だったら敵、敵だった場合は isHost が 処理を行う。
            isEnemyType = function (this,unit)

                local isHost = megast.Battle:getInstance():isHost();
                local isPlayer = unit:getisPlayer();

                if isPlayer == false and isHost == true then
                    return true;
                end
                return false;
            end,

            --sendEventToLua
            RequestSendEventToLua = function(this,unit,requestIndex,intparam)

                if unit:isMyunit() == true or this.Class.isEnemyType(this,unit) == true then
                    print("----------リクエストを受付開始 ID == ",intparam);
                    megast.Battle:getInstance():sendEventToLua(this.Class.ThisUniqueId,requestIndex,intparam);
                end

                return 1;
            end,

            --スキルバーストバーニングカウンターのアップデート
            --指定リクエスト回数を超えたら発動する
            requestSkillBurstBurning = function(this,unit)

                if unit:isMyunit() == true or this.Class.isEnemyType(this,unit) == true then

                    this.Class.burstBurning_cur_Counter = this.Class.burstBurning_cur_Counter + 1;
                    this.Class.RequestSendEventToLua(this,unit,2,this.Class.burstBurning_cur_Counter);
                    this.Class.burstBurningIconSetUp(this,unit);

                    if this.Class.burstBurning_Maxmum <= this.Class.burstBurning_cur_Counter then
                        this.Class.BurstBurning(this,unit,this.Class.burstBurning_Skill1_Probability);
                        this.Class.burstBurningIconSetUp(this,unit);
                        this.Class.burstBurning_cur_Counter = 0;
                    end

                end

                return 1;
            end,

            burstBurningIconSetUp = function(this,unit)

                local condition = unit:getTeamUnitCondition():findConditionWithID(-51);
                if not(condition == nil) then
                    unit:getTeamUnitCondition():removeCondition(condition);
                end

                if this.Class.burstBurning_cur_Counter == 0 then

                elseif this.Class.burstBurning_cur_Counter == 1 then
                    unit:getTeamUnitCondition():addCondition(-51,0,0,2000,this.Class.burstBurning_icon_ID_Stage_1);
                elseif this.Class.burstBurning_cur_Counter == 2 then
                    unit:getTeamUnitCondition():addCondition(-51,0,0,2000,this.Class.burstBurning_icon_ID_Stage_2);
                end

                return 1;
            end,

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
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
            return this.Class.receiveBranch_1(this,intparam);
        end,
        receive2 = function (this , intparam)
            return this.Class.receiveBranch_2(this,intparam);
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
            return this.Class.takeBreakeBranch(this,unit);
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
            return this.Class.attackDamageValueBranch(this,unit,enemy,value);
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        --version1.0
        start = function (this , unit)
            return this.Class.Initialize(this,unit);
        end,

        excuteAction = function (this , unit)
            local buff = unit:getTeamUnitCondition():addCondition(10122,19,50,999999,0);
            buff:setScriptID(42);
            buff:setValue1(97);
            buff:setValue2(1);
            return this.Class.excuteActionBranch(this,unit);
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
            local buff = unit:getTeamUnitCondition():addCondition(10122,19,50,999999,0);
            buff:setScriptID(42);
            buff:setValue1(97);
            buff:setValue2(1);
            return this.Class.takeAttackBranch(this,unit,index);
        end,

        takeSkill = function (this,unit,index)
            local buff = unit:getTeamUnitCondition():addCondition(10122,19,50,999999,0);
            buff:setScriptID(42);
            buff:setValue1(97);
            buff:setValue2(1);
            return this.Class.takeSkillBranch(this,unit,index);
        end,

        takeDamage = function (this , unit)
            return this.Class.takeDamageBranch(this,unit);
        end,

        dead = function (this , unit)
            return this.Class.takeDeadBranch(this,unit);
        end
    }
    register.regist(instance,id,instance.param.version);
    return 1;
end

