function new(id)
    print("101045111 new ");
    local instance = {

        --ミラクラス
        Class = 
        {
            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Values
            isFirstStepUpdate = false,

            --uniqueID
            ThisUniqueId = id,

            --ThisUnit
            ThisUnit = nil,

            --瀕死時、ミラは無敵になるのでそれの設定変数軍
            PhoenixSwitch = false,
            isPhoenix = false,
            PhoenixTime = 0,
            PhoenixLimitTime = 5,

            Phoenix_Ready_icon_ID = 107,
            Phoenix_Cur_icon_ID_5 = 112,
            Phoenix_Cur_icon_ID_4 = 111,
            Phoenix_Cur_icon_ID_3 = 110,
            Phoenix_Cur_icon_ID_2 = 109,
            Phoenix_Cur_icon_ID_1 = 108,


            Phoenix_Buff_ID = 0,
            Phoenix_Buff_Value = 0,
            Cur_Phoenix_IconID = 0,

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

                if this.Class.PhoenixSwitch == true then

                    this.Class.PhoenixTime = this.Class.PhoenixTime + deltatime;

                    local floorTime = math.floor(this.Class.PhoenixTime);
                    
                    if floorTime == 0 then
                        if this.Class.Cur_Phoenix_IconID ~= this.Class.Phoenix_Cur_icon_ID_5 then

                            local conditon = unit:getTeamUnitCondition():findConditionWithID(-55);
                            if not(conditon == nil) then
                                unit:getTeamUnitCondition():removeCondition(conditon);
                            end

                            unit:getTeamUnitCondition():addCondition(-55,this.Class.Phoenix_Buff_ID,this.Class.Phoenix_Buff_Value,2000,this.Class.Phoenix_Cur_icon_ID_5);
                            this.Class.Cur_Phoenix_IconID = this.Class.Phoenix_Cur_icon_ID_5;
                        end
                    elseif floorTime == 1 then
                        if this.Class.Cur_Phoenix_IconID ~= this.Class.Phoenix_Cur_icon_ID_4 then

                            local conditon = unit:getTeamUnitCondition():findConditionWithID(-55);
                            if not(conditon == nil) then
                                unit:getTeamUnitCondition():removeCondition(conditon);
                            end
                            
                            unit:getTeamUnitCondition():addCondition(-55,this.Class.Phoenix_Buff_ID,this.Class.Phoenix_Buff_Value,2000,this.Class.Phoenix_Cur_icon_ID_4);
                            this.Class.Cur_Phoenix_IconID = this.Class.Phoenix_Cur_icon_ID_4;
                        end
                    elseif floorTime == 2 then
                        if this.Class.Cur_Phoenix_IconID ~= this.Class.Phoenix_Cur_icon_ID_3 then

                            local conditon = unit:getTeamUnitCondition():findConditionWithID(-55);
                            if not(conditon == nil) then
                                unit:getTeamUnitCondition():removeCondition(conditon);
                            end

                            unit:getTeamUnitCondition():addCondition(-55,this.Class.Phoenix_Buff_ID,this.Class.Phoenix_Buff_Value,2000,this.Class.Phoenix_Cur_icon_ID_3);
                            this.Class.Cur_Phoenix_IconID = this.Class.Phoenix_Cur_icon_ID_3;
                        end
                    elseif floorTime == 3 then
                        if this.Class.Cur_Phoenix_IconID ~= this.Class.Phoenix_Cur_icon_ID_2 then
                            
                            local conditon = unit:getTeamUnitCondition():findConditionWithID(-55);
                            if not(conditon == nil) then
                                unit:getTeamUnitCondition():removeCondition(conditon);
                            end

                            unit:getTeamUnitCondition():addCondition(-55,this.Class.Phoenix_Buff_ID,this.Class.Phoenix_Buff_Value,2000,this.Class.Phoenix_Cur_icon_ID_2);
                            this.Class.Cur_Phoenix_IconID = this.Class.Phoenix_Cur_icon_ID_2;
                        end
                    elseif floorTime == 4 then
                        if this.Class.Cur_Phoenix_IconID ~= this.Class.Phoenix_Cur_icon_ID_1 then

                            local conditon = unit:getTeamUnitCondition():findConditionWithID(-55);
                            if not(conditon == nil) then
                                unit:getTeamUnitCondition():removeCondition(conditon);
                            end

                            unit:getTeamUnitCondition():addCondition(-55,this.Class.Phoenix_Buff_ID,this.Class.Phoenix_Buff_Value,2000,this.Class.Phoenix_Cur_icon_ID_1);
                            this.Class.Cur_Phoenix_IconID = this.Class.Phoenix_Cur_icon_ID_1;
                        end
                    end


                    if this.Class.PhoenixLimitTime < this.Class.PhoenixTime then
                        this.Class.isPhoenix = true;
                        this.Class.PhoenixSwitch = false;
                        this.Class.PhoenixTime = 0;

                        local conditon = this.Class.ThisUnit:getTeamUnitCondition():findConditionWithID(-55);
                        if not(conditon == nil) then
                            this.Class.ThisUnit:getTeamUnitCondition():removeCondition(conditon);
                        end

                    end

                end

                return 1;
            end,

            --LunScript
            --if str == "runSkillAttack" then return this.Class.runSkillAttack(this,unit) end
            runScriptUpdate = function(this , unit , str)
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

                if this.Class.isPhoenix == false then

                    if this.Class.PhoenixSwitch == false then

                        local conditon = unit:getTeamUnitCondition():findConditionWithID(-55);
                        if not(conditon == nil) then
                            unit:getTeamUnitCondition():removeCondition(conditon);
                        end
                        this.Class.PhoenixSwitch = true;
                    end

                    unit:setHP(1);
                    unit:updateStatus();
                    megast.Battle:getInstance():sendEventToLua(this.Class.ThisUniqueId,1,0);

                    return 0;
                end

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
                if this.Class.PhoenixSwitch == false then

                    local conditon = this.Class.ThisUnit:getTeamUnitCondition():findConditionWithID(-55);
                    if not(conditon == nil) then
                        this.Class.ThisUnit:getTeamUnitCondition():removeCondition(conditon);
                    end
                    this.Class.PhoenixSwitch = true;
                end
                return 1;
            end,

            receiveBranch_2 = function(this,intparam)
                return 1;
            end,

            --attackDamageValue分岐用
            attackDamageValueBranch = function(this , unit , enemy , value)
                return value;
            end,

            --takeDamageValue分岐用
            takeDamageValueBranch = function(this , unit , enemy , value)

                if this.Class.PhoenixSwitch == true then
                    return 0;
                end

                return value;
            end,

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Functions

            --アップデート最初の一度のみ実行される。
            FirstUpdateInitialize = function(this,unit)

                this.Class.ThisUnit = unit;

                local conditon = this.Class.ThisUnit:getTeamUnitCondition():findConditionWithID(-55);
                if not(conditon == nil) then
                    this.Class.ThisUnit:getTeamUnitCondition():removeCondition(conditon);
                end
                unit:getTeamUnitCondition():addCondition(-55,this.Class.Phoenix_Buff_ID,this.Class.Phoenix_Buff_Value,2000,this.Class.Phoenix_Ready_icon_ID);
                this.Class.Cur_Phoenix_IconID = this.Class.Phoenix_Ready_icon_ID;
                return 1;
            end,

            --sendEventToLua
            RequestSendEventToLua = function(this,unit,requestIndex,intparam)

                if unit:isMyunit() == true or this.Class.isEnemyType(this,unit) == true then
                    print("----------リクエストを受付開始 ID == ",intparam);
                    megast.Battle:getInstance():sendEventToLua(this.Class.ThisUniqueId,requestIndex,intparam);
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
            return this.Class.takeDamageValueBranch(this,unit,enemy,value);
        end,

        --version1.0
        start = function (this , unit)
            return this.Class.Initialize(this,unit);
        end,

        excuteAction = function (this , unit)
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
            return this.Class.takeAttackBranch(this,unit,index);
        end,

        takeSkill = function (this,unit,index)
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

