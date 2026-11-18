function new(id)
    print("101235212 new ");
    local instance = {

        --ザールクラス
        Class = 
        {
            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Values
            isFirstStepUpdate = false,

            --uniqueID
            ThisUniqueId = id,

            --ThisUnit
            ThisUnit = nil,

            --現在かかっているバフカウンター
            buffCounter = 0,
            --バフ重複上限
            limitBuffCount = 5,

            --バフカウンター配列
            icon_Table = 
            {
                94, --  1
                95, --  2
                96, --  3
                97, --  4
                103, --  5
                99, --  6
                100, --  7
                101, --  8
                102, --  9
                103, --  10
            },

            BurstAura = nil,

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

                this.Class.BurstAuraUpdate(this,unit,deltatime);

                return 1;
            end,

            --LunScript
            --if str == "runSkillAttack" then return this.Class.runSkillAttack(this,unit) end
            runScriptUpdate = function(this , unit , str)

                 if str == "CoupDeGrace" then return this.Class.CoupDeGrace(this,unit) end
                 if str == "CoupDeGraceEnd" then return this.Class.CoupDeGraceEnd(this,unit) end

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

                local conditon = this.Class.ThisUnit:getTeamUnitCondition():findConditionWithID(-53);
                if not(conditon == nil) then
                    this.Class.ThisUnit:getTeamUnitCondition():removeCondition(conditon);
                end

                this.Class.buffCounter = intparam;
                this.Class.ThisUnit:getTeamUnitCondition():addCondition(-53,0,0,10000,this.Class.icon_Table[this.Class.buffCounter]);

                return 1;
            end,

            receiveBranch_2 = function(this,intparam)
                local target = megast.Battle:getInstance():getTeam(not this.Class.ThisUnit:getisPlayer()):getTeamUnit(intparam);
                if target ~= nil then
                    target:getTeamUnitCondition():addCondition(123,32,-30,5,15);
                end
                
                return 1;
            end,

            --attackDamageValue分岐用
            attackDamageValueBranch = function(this , unit , enemy , value)

                local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
                local activeBattleSkill = unit:getActiveBattleSkill();

                --ActiveBattleSkillがnilじゃなくて
                --SkillTypeが 1 (スキル)で
                --今回の攻撃がクリティカルで
                --自分のユニットのときはaddcon!
                if unit:isMyunit() == true then
                if activeBattleSkill ~= nil then
                    if activeBattleSkill:getSkillType() == 1 then
                        if critical == true then
                           enemy:getTeamUnitCondition():addCondition(123,32,-30,5,15);
                           this.Class.RequestSendEventToLua(this,unit,2,enemy:getIndex());
                        end
                    end
                end
                end
                
                return value;
            end,

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Functions

            --アップデート最初の一度のみ実行される。
            FirstUpdateInitialize = function(this,unit)

                this.Class.ThisUnit = unit;

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

            CoupDeGrace = function(this,unit)

                print(">>>>>>CoupDeGrace!!!");

                --奥義発動時はAuraが出ていたら消す
                this.Class.BurstAuraCreation(this,unit,false);

                if unit:isMyunit() == true or this.Class.isEnemyType(this,unit) == true then

                    if this.Class.buffCounter < this.Class.limitBuffCount then

                        if this.Class.buffCounter ~= 0 then
                            local conditon = unit:getTeamUnitCondition():findConditionWithID(-53);
                            if not(conditon == nil) then
                                unit:getTeamUnitCondition():removeCondition(conditon);
                            end
                        end
    
                        this.Class.buffCounter = this.Class.buffCounter + 1;
                        print(">>>>>>>>>>this.Class.buffCounter == ",this.Class.buffCounter);

                        unit:getTeamUnitCondition():addCondition(-53,0,0,10000,this.Class.icon_Table[this.Class.buffCounter]);
                        this.Class.RequestSendEventToLua(this,unit,1,this.Class.buffCounter);
                    end

                end

                return 1;
            end,

            CoupDeGraceEnd = function(this,unit)
            
                --上の条件以外に終了時になった、つまりMAXIMUM！
                if not(this.Class.buffCounter < this.Class.limitBuffCount) then
                    this.Class.BurstAuraCreation(this,unit,true);
                end

                return 1;
            end,


            BurstAuraCreation = function(this,unit,isDraw)

                    if isDraw == true then
                        if this.Class.BurstAura == nil then
                            this.Class.BurstAura = unit:addOrbitSystem("aura");
                            this.Class.BurstAura:setAnimation(0,"aura",true);
                            this.Class.BurstAura:setPositionX(unit:getAnimationPositionX());
                            this.Class.BurstAura:setPositionY(unit:getAnimationPositionY()-65);
                            this.Class.BurstAura:setLocalZOrder(unit:getZOrder() + 1);
                        end
                    else
                        if this.Class.BurstAura ~= nil then
                            this.Class.BurstAura:remove();
                            this.Class.BurstAura = nil;
                        end
                    end

                return 1;
            end,

            BurstAuraUpdate = function(this,unit,deltatime)

                if this.Class.BurstAura ~= nil then
                    this.Class.BurstAura:setPositionX(unit:getAnimationPositionX());
                    this.Class.BurstAura:setPositionY(unit:getAnimationPositionY()-65);
                    this.Class.BurstAura:setLocalZOrder(unit:getZOrder() + 1);
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

