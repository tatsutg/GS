function new(id)
    print("10000 new ");
    local instance = {

        --ガナンで使われる変数軍
        localParameter = 
        {
            --アタック中か
            isAttackChecker = false,

            --スキル奥義使用中か
            skillChecker = false,

             --ガナンが怒っているか
            isRage = false,
            isRage2 = false,
            
            --怒り時のアタックディレイ
            isRageAD = 280.0,
            --怒り時のアタックディレイ2
            isRageAD2 = 250.0,
            
             --怒ってる時のSP回復カウンター
            rageHealSpCounter = 0,
            
            --怒る事象のクールタイムカウント
            rageCoolTurnCount = 0,

            --怒る可能性のあるHPリミット
            rageHP = 0,
            
            --怒る可能性のあるHPリミット(2回目)
            rageHP2 = 0,

            --怒るクールタイム
            rageCoolTurn = 0,

            --SP自動回復ディレイ
            rageHealSPDelay = 1,

            --自動回復数
            rageHealSPValue = 10,

            --アタックレート1
            rate_attack1 = 20,

            --アタックレート2
            rate_attack2 = 35,

            --アタックレート3
            rate_attack3 = 45,

            --怒ってる時のattack4攻撃確率
            rate_attack4 = 30,

            --怒ってる時オーラー
            rate_Aura = nil
        },
        messages = summoner.Text:fetchByEnemyID(500431100),

        --共通変数
        param = {
          version = 1.3
          ,isUpdate = true
        },

        addSP = function (this,unit)
            if not this.isRage then
                unit:addSP(20);
            end
            return 1;
        end,

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

            if str == "addSP" then return this.addSP(this,unit) end

            return 1;
        end,

        --version1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
            return value;
        end,

        takeBreake = function (this,unit)
      
            if false and this.localParameter.isRage then
                this.localParameter.isRage = false;
                this.localParameter.rageCoolTurnCount = 0;
                this.localParameter.rageHealSpCounter = 0;

                this.rate_Aura:remove();

                local buff_12 = unit:getTeamUnitCondition():findConditionWithID(-12);
                if not(buff_12 == nil) then
                    local condition_12 = unit:getTeamUnitCondition():findConditionWithID(-12);
                    unit:getTeamUnitCondition():removeCondition(condition_12);
                end
                local buff_11 = unit:getTeamUnitCondition():findConditionWithID(-11);
                if not(buff_11 == nil) then
                    local condition_11 = unit:getTeamUnitCondition():findConditionWithID(-11);
                    unit:getTeamUnitCondition():removeCondition(condition_11);
                end
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
            --ガナンは怒っている時必殺技ゲージが自然回復していく、Updateで回復を行っていく。(怒っていて技を出していない時)
            if this.localParameter.isRage then

                if this.rate_Aura ~= nil then
                    this.rate_Aura:setPositionX(unit:getAnimationPositionX());
                    this.rate_Aura:setPositionY(unit:getAnimationPositionY() - 50);
                end

                this.localParameter.rageHealSpCounter = this.localParameter.rageHealSpCounter + deltatime;
                if this.localParameter.rageHealSPDelay <= this.localParameter.rageHealSpCounter then
                    if not this.localParameter.skillChecker then
                        unit:addSP(this.localParameter.rageHealSPValue);
                    end
                    this.localParameter.rageHealSpCounter = 0;
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
            --怒ってるときはクールタイム 0 怒ってない場合は毎回怒るかチェックを行う。
            --２段階目のチェックも行う
            if this.localParameter.isRage then
                this.localParameter.rageCoolTurnCount = 0;
                local curHpParcent = 100 * unit:getHP() / unit:getCalcHPMAX();
                --怒る２回目
                if this.localParameter.isRage2 == false and curHpParcent < this.localParameter.rageHP2 then  
                        this.localParameter.isRage2 = true;
                        this.localParameter.isAttackChecker = true;
                        unit:getTeamUnitCondition():addCondition(-13,3,0,2000,3);
                        unit:getTeamUnitCondition():addCondition(-14,6,0,2000,6);
                        unit:takeAnimation(0,"rageImpact",false);
                        unit:takeAnimationEffect(0,"rageImpact",false);
                        unit:setUnitState(kUnitState_skill);
                        unit:setAttackDelay(2.5);
                        unit:playVoice("VOICE_CONTINUE_RECEPTION");
                        
                        BattleControl:get():pushEnemyInfomation(this.messages.mess1,255,40,40,4);
                        BattleControl:get():pushEnemyInfomation(this.messages.mess2,255,40,40,4);
                        BattleControl:get():pushEnemyInfomation(this.messages.mess3,0,255,255,4);
                        BattleControl:get():pushEnemyInfomation(this.messages.mess4,255,40,40,4);
                        BattleControl:get():pushEnemyInfomation(this.messages.mess5,255,40,40,4);
                        if this.rate_Aura ~= nil then
                            this.rate_Aura:setScaleX(1.9);
                            this.rate_Aura:setScaleY(1.9);
                        end
                        return 0;
                end              
                
            else
                this.localParameter.rageCoolTurnCount = this.localParameter.rageCoolTurnCount + 1;
                --怒るモードクールタイム終わり
                if this.localParameter.rageCoolTurn < this.localParameter.rageCoolTurnCount then
                    local curHpParcent = 100 * unit:getHP() / unit:getCalcHPMAX();
                    --怒る一回目
                    if curHpParcent < this.localParameter.rageHP then
                        this.localParameter.isRage = true;
                        this.localParameter.isAttackChecker = true;
                        unit:getTeamUnitCondition():addCondition(-12,22,2000,2000,11);
                        unit:getTeamUnitCondition():addCondition(-11,31,0,2000,31);
                        unit:takeAnimation(0,"rageImpact",false);
                        unit:takeAnimationEffect(0,"rageImpact",false);
                        unit:setUnitState(kUnitState_skill);
                        unit:setAttackDelay(2.8);

                        this.rate_Aura = unit:addOrbitSystem("aura");
                        this.rate_Aura:setAnimation(0,"aura",true);
                        this.rate_Aura:setPositionX(unit:getAnimationPositionX());
                        this.rate_Aura:setPositionY(unit:getAnimationPositionY() - 50);
                        this.rate_Aura:setLocalZOrder(9100);
                        
                        BattleControl:get():pushEnemyInfomation(this.messages.mess6,255,40,40,4);
                        BattleControl:get():pushEnemyInfomation(this.messages.mess7,255,40,40,4);
                        BattleControl:get():pushEnemyInfomation(this.messages.mess8,255,40,40,4);
                        unit:playVoice("VOICE_CONTINUE_DECISION");

                        return 0;
                    end
                end
            end
            return 1;
        end,

        takeIdle = function (this , unit)

            --スキル後のidleで フラグを false にする、自動回復させるため
            if this.localParameter.skillChecker then
                this.localParameter.skillChecker = false;
            end

            if unit:getAnimationPositionX() > 200 then
                unit:takeBack();
                return 0;
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
                unit:setActiveSkill(4);
            end
            --ガナンはランダムで技が出る 1~3   怒っているときは 4 が出る可能性もある。
            local isHost = megast.Battle:getInstance():isHost();
            if isHost then
                if this.localParameter.isAttackChecker == false then
                    this.localParameter.isAttackChecker = true;
                    --押されていたら2
                    if unit:getPositionX() < -270 then
                        unit:takeAttack(2);
                        return 0;
                    end
                    
                    --押していたら4
                    if unit:getPositionX() > 200 then
                        unit:takeAttack(4);
                        return 0;
                    end
                    
                    --怒ってるときは attack4 が出る可能性がある
                    if this.localParameter.isRage then
                        local random =math.random(100 + this.localParameter.rate_attack4);
                        if random <= this.localParameter.rate_attack1 then
                            unit:takeAttack(1);
                        elseif random <= this.localParameter.rate_attack1 + this.localParameter.rate_attack2 then
                            unit:takeAttack(2);
                            unit.m_attackTimer = 0;
                        elseif random <= 100 then
                            unit:takeAttack(3);
                        else
                            unit:takeAttack(4);
                        end
                    else
                        --起こってないときは attack4 抜きで計算する
                        local random = math.random(100);
                        if random <= this.localParameter.rate_attack1 then
                            unit:takeAttack(1);
                        elseif random <= this.localParameter.rate_attack1 + this.localParameter.rate_attack2 then
                            unit:takeAttack(2);
                        elseif random <= 100 then
                            unit:takeAttack(3);
                        end
                    end
                    return 0;
                end
                this.localParameter.isAttackChecker = false;
            end

            return 1;
        end,

        takeSkill = function (this,unit,index)           
            if this.localParameter.skillChecker == false then
                this.localParameter.skillChecker = true;
                unit:takeSkillWithCutin(index);
                return 0;
            end
            unit:setActiveSkill(5);
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

