function new(id)
    print("10000 new ");
    local instance = {
        thisID = id,

        --イフリートクラス
        Class = 
        {
            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
            --開始後数秒は動かない
            FirstAttackDelay = 1.0,

            --Values
            --アタックチェック
            isAttackChecker = false,

            --スキルチェック
            isSkillChecker = false,

            --バックステップを行う　X　座標
            takeBackStepRange = 150,

            --Update一回目のみ呼ばれるフラグ
            isFirstUpdateStep = false,

            --燃焼状態に移行したかどうかを監視するためのフラグ
            beforeBurn = false,

            --HP低下時攻撃のフラグ一回目
            skill1First = false,

            --HP低下時攻撃のフラグ２回目
            skill1Second = false,

            --低下時skill1を強制発動するためのフラグ
            isSkill1 = false,

            startWaveFlag = true,

            executeActionParmission = false,

            myself = nil,

            --通常攻撃の重み　合計１００じゃなくても正規化されます
            weightsAttack = {
                {key = 1,value = 20},
                {key = 2,value = 20},
                {key = 3,value = 30},
                {key = 4,value = 30}
            },

            skill1HP = {
                first = 25,
                second = -1
            },

            consts = {
            	burnDamageForPlayer = 1000,
            	burnDamageForBoss = 100,
            	burnDurationForPlayer = 2000,
            	burnDurationForBoss = 9999
            },


            messages = summoner.Text:fetchByEnemyID(4000527),

            colors = {
                red = {r = 255,g = 0,b = 28},
                yellow = {r = 220,g = 255,b = 0},
                blue = {r = 0,g = 255,b = 255},
                white = {r = 255,g = 255,b = 255}
            },

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆


            --初期化
            Initialize = function(this,unit)
                this.Class.myself = unit;
                this.Class.SPValue = 20;
                unit:setSPGainValue(0);
                -- unit:setInvincibleTime(10);
                return 1;
            end,

            --アップデート関数一回目にのみ呼ばれる
            FirstUpdateStep = function(this,unit)
                return 1;
            end,

            --アップデート
            Update = function(this,unit,deltatime)
                unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2　10割軽減
                local burn = this.utill.findConditionWithType(unit,97);
                if this.Class.beforeBurn then
                    if burn == nil then
                        this.Class.endBurn(this,unit);
                        this.Class.beforeBurn = false;
                    end
                else
                    if burn ~= nil then
                        this.Class.startBurn(this,unit);
                        this.Class.beforeBurn = true;
                    end
                end
                
                if megast.Battle:getInstance():getBattleState() == kBattleState_active then
                    this.Class.FirstAttackDelay = this.Class.FirstAttackDelay - deltatime;
                end
                
                return 1;
            end,

            --LunScript
            runScriptUpdate = function(this , unit , str)
                if str == "addSP" then return this.Class.addSP(this,unit) end

                if str == "InTheBurst" then return this.Class.InTheBurst(this,unit) end

                if str == "skill2Burn" then return this.Class.skill2Burn(this,unit) end

                if str == "finishInMotion" then return this.Class.finishInMotion(this,unit) end

                return 1;
            end,

            --アタック分岐
            takeAttackBranch = function(this,unit,index)

                local attackTable = this.utill.randomPickItem(this,this.Class.weightsAttack);
                
                unit:takeAttack(attackTable.key);
        
                return 0;
            end,

            --スキル分岐用
            takeSkillBranch = function(this,unit,index)
                if this.Class.isSkill1 then
                    this.Class.isSkill1 = false;
                    unit:takeSkill(1);
                    return 0;
                end
                local burn = this.utill.findConditionWithType(unit,97);
                
                if burn ~= nil then
                    unit:takeSkill(3);
                else
                    unit:takeSkill(2);
                end

                return 0;
            end,

            --アイドル分岐用
            takeIdleBranch = function(this,unit)

                --HPが三分の１だった場合はちょっと弱ってるidleになる
                if unit:getHPPercent() <= 0.3 then
                    unit:setNextAnimationName("idle2");
                end

                local tUX = unit:getAnimationPositionX();
                local zUX = this.Class.takeBackStepRange;
                tUX = math.floor(tUX);
                zUX = math.floor(zUX);

                local distance = math.abs(tUX - zUX);
                distance = math.floor(distance);

                print("distance == ",distance);

                if distance <= 200 then
                    this.takeBack();
                end

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
                -- if not this.Class.executeActionParmission then
                --     return 0;
                -- end
                local hpParcent = this.utill.getHPPercent(unit);
                if not this.Class.skill1First and hpParcent <= this.Class.skill1HP.first then
                    this.Class.skill1First = true;
                    this.Class.isSkill1 = true;
                    -- this.Class.s();
                end
                if not this.Class.skill1Second and hpParcent <= this.Class.skill1HP.second then
                    this.Class.skill1Second = true;
                    this.Class.isSkill1 = true;
                end
                return 1;
            end,

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Functions
            InTheBurst = function (this , unit)


                print("------------------------");
                print("------------------------");
                print("InTheBurst!!!!!");
                print("------------------------");
                print("------------------------");

                if this.utill.isHost() then
                    this.utill.sendEvent(this,3,1);
                    this.Class.innerInTheBurst(this,unit);
                end
                return 1;
            end,

            innerInTheBurst = function(this,unit)
                local t_Unit = unit:getTargetUnit();
                local t_Team = t_Unit:getTeam();

                for i = 0,3 do
                    local t_TeamUnit = t_Team:getTeamUnit(i,true);
                    if t_TeamUnit ~= nil then
                        t_TeamUnit:setHP(t_TeamUnit:getHP() / 2);
                        t_TeamUnit:getTeamUnitCondition():addCondition(-12,97,this.Class.consts.burnDamageForPlayer,this.Class.consts.burnDurationForPlayer,87);
                    end
                end
                unit:getTeamUnitCondition():addCondition(-12,97,this.Class.consts.burnDamageForBoss,this.Class.consts.burnDurationForBoss,87);
            end,

            finishInMotion = function (this,unit)
                if this.utill.isHost() then
                    this.utill.sendEvent(this,2,0);
                    this.Class.innerFinishInMotion(this,unit);
                end
                return 1;
            end,

            innerFinishInMotion = function (this,unit)
                -- megast.Battle:getInstance():setBattleState(kBattleState_active);
                -- this.Class.startWave = true;
                -- if this.utill.isHost() then
                --     megast.Battle:getInstance():waveRun();
                -- end
                -- megast.Battle:getInstance():setBattleState(kBattleState_active);
                -- unit:setInvincibleTime(0);
                local t_Unit = unit:getTargetUnit();
                local t_Team = t_Unit:getTeam();
                for i = 0,3 do
                    local t_TeamUnit = t_Team:getTeamUnit(i,true);
                    if t_TeamUnit ~= nil then
                        --t_TeamUnit:excuteAction();
                    end
                end
                this.utill.showMessage(this.Class.messages.mess1,this.Class.colors.red,8);
                this.Class.executeActionParmission = true;
                if this.utill.isHost() then
                    --unit:takeAttack(1);
                end
            end,

            skill2Burn = function (this,unit)
                if this.utill.isHost() then
                    this.utill.sendEvent(this,1,1);
                    this.Class.selfBurn(this,unit);
                end
                return 1;
            end,

            selfBurn = function (this , unit)
                unit:getTeamUnitCondition():addCondition(-12,97,this.Class.consts.burnDamageForBoss,this.Class.consts.burnDurationForBoss,87);
                return 1;
            end,


            startBurn = function (this,unit)
                this.utill.showMessage(this.Class.messages.mess2,this.Class.colors.red,8,7);
                -- this.utill.showMessage(this.Class.messages.mess4 or "燃焼中ダメージ軽減",this.Class.colors.red,8);
                this.utill.showMessage(this.Class.messages.mess6 or "燃焼中奥義ゲージ増加速度アップ",this.Class.colors.red,8);
                unit:getTeamUnitCondition():addCondition(-11,28,50,2000,7);
                this.Class.SPValue = 40;
            end,

            endBurn = function (this,unit)
                this.utill.showMessage(this.Class.messages.mess3,this.Class.colors.white,8);
                -- this.utill.showMessage(this.Class.messages.mess5 or "水属性耐性ダウン",this.Class.colors.blue,8);
                this.utill.removeCondition(unit,-11);
                this.Class.SPValue = 20;
            end,


            addSP = function (this , unit)
                unit:addSP(this.Class.SPValue);
                return 1;
            end

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        },

        utill = {
            isHost = function ()
                return megast.Battle:getInstance():isHost();
            end,

            getHPPercent = function(unit)
                return 100 * unit:getHP() / unit:getCalcHPMAX();
            end,

            -- ランダム選択
            randomPickItem = function (this, ...)
                local total = 0;

                for i, obj in pairs(...) do
                    total = total + obj.value;
                end

                local randv = LuaUtilities.rand(0,total)

                for i, obj in pairs(...) do
                    randv = randv - obj.value;

                    if randv < 0 then
                        return obj;
                    end
                end

                local item = unpack(...);

                return item;
            end,


            findConditionWithType = function (unit,conditionTypeID)
                return unit:getTeamUnitCondition():findConditionWithType(conditionTypeID);
            end,

            removeCondition = function (unit,buffID)
                local buff = unit:getTeamUnitCondition():findConditionWithID(buffID);
                if buff ~= nil then
                    unit:getTeamUnitCondition():removeCondition(buff);
                end
            end,

            sendEvent = function(this,index,intparam)
                megast.Battle:getInstance():sendEventToLua(this.thisID,index,intparam);
            end,

            showMessage = function(message,rgb,duration,iconid)
                
                if iconid ~= nil then
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(message,iconid,rgb.r,rgb.g,rgb.b,duration);
                else
                    BattleControl:get():pushEnemyInfomation(message,rgb.r,rgb.g,rgb.b,duration);
                end
            end,
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
            this.Class.selfBurn(this,this.Class.myself);
            return 1;
        end,

        receive2 = function (this , intparam)
            this.Class.innerFinishInMotion(this,this.Class.myself);
            return 1;
        end,

        receive3 = function (this , intparam)
            this.Class.innerInTheBurst(this,this.Class.myself);
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
            return this.Class.takeBreakeBranch(this,unit);
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            if this.Class.startWave then
                -- megast.Battle:getInstance():setBattleState(kBattleState_ready);
                -- this.Class.executeActionParmission = true;
                -- this.Class.startWave = false;
            -- else
            --     return 0;
            end
            
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
            --燃焼中はアタックタイマーを０にする
            local burn = this.utill.findConditionWithType(unit,97);
            if burn ~= nil then
                unit:setAttackTimer(0)
            end
            if this.Class.FirstAttackDelay > 0 then
                unit:setAttackTimer(1.0)
            end
        
            return this.Class.excuteActionBranch(this,unit);
        end,

        takeIdle = function (this , unit)
            return this.Class.takeIdleBranch(this,unit);

        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
            print("------------------------");
            print("------------------------");
            print("takeBack!!!!!");
            print("------------------------");
            print("------------------------");
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
            
            unit:setActiveSkill(index);
	        
            return 1;
        end,

        takeSkill = function (this,unit,index)
            local isHost = megast.Battle:getInstance():isHost();
            unit:setBurstState(kBurstState_active);
            if isHost then
                if this.Class.isAttackChecker then
                    this.Class.isAttackChecker = false;
                    return 1;
                end
                if this.Class.isSkillChecker == false then
                    this.Class.isSkillChecker = true;
                    return this.Class.takeSkillBranch(this,unit,index);
                end
                this.Class.isSkillChecker = false;
            end
	     
            if index == 1 then
                unit:setActiveSkill(5);
	        elseif index == 2 then
                unit:setActiveSkill(6);
	        elseif index == 3 then
                unit:setActiveSkill(7);
	        end
		
            return 1;
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

