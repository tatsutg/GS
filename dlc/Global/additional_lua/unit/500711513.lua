--黒ヴァルザンデス
function new(id)
    print("10000 new ");
    local instance = {
        thisID = id,            --生成時に渡されたidを保持しておく（マルチの同期に使う）
        skillChecker = false,
        attackChecker = false,
        skillExecFlag = false,
        myself = nil,
        chargeSkillFlag = false,
        phase = 0,
        skillphase1 = 0.4, --チャージ攻撃確定のHP閾値（％）
        skillphase2 = 0.25, --チャージ攻撃確定のHP閾値（％）
        chargecooltime = 12, --チャージ攻撃のクールタイム
        ct_timer       = 0, 
        messages = summoner.Text:fetchByUnitID(500711513),

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
            return 1;
        end,

        chargeEnd2 = function (this,unit)
            unit:takeAnimation(0,"charge_loop",true);
            unit:takeAnimationEffect(0,"charge_short",true);

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
          version = 1.2
          ,isUpdate = 1
        },
        thisid = id,

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            this.chargeskill(this,this.myself);
            return 1;
        end,
        receive2 = function (this , intparam)
            this.charge(this);
            return 1;
        end,
        
        --version 1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
           
            if this.wall ~= nil then
                value = 0;
            end 

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
            BattleControl:get():pushEnemyInfomation(this.messages.mess1,255,0,255,4);
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            this.ct_timer = this.ct_timer - deltatime;
        
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
            this.chargeSkillFlag = false;

            return 1;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
         
            return 1;
        end,

        takeAttack = function (this , unit , index)    
            this.chargeSkillFlag = false;                
            if index == 1 then
                unit:setActiveSkill(2);
            elseif index == 2 then
                unit:setActiveSkill(3);
            elseif index == 3 then
                unit:setActiveSkill(4);
            elseif index == 4 then
                this.chargeskill(this,unit);
                this.ct_timer = this.chargecooltime;
                return 0;
            end
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                local target = unit:getTargetUnit() 
                local distance = BattleUtilities.getUnitDistance(unit,target)
                    
                    --CT中はチャージスキルはうたない            
                    --HPが一定値以下になるとチャージ攻撃が確定
                    if this.ct_timer <= 0 and this.phase == 0 and unit:getHPPercent() < this.skillphase1 then
                        this.attackChecker = true
                        unit:takeAttack(4);
                        this.phase = 1;
                        return 0;
                    end

                    if this.ct_timer <= 0 and this.phase == 1 and unit:getHPPercent() < this.skillphase2 then
                        this.attackChecker = true
                        unit:takeAttack(4);
                        this.phase = 2;
                        return 0;
                    end

                if distance > 400 and this.attackChecker == false then
                    this.attackChecker = true
                    unit:takeAttack(3)
                    return 0;
                elseif this.attackChecker == false then
                    this.attackChecker = true;
                    local rand = LuaUtilities.rand(0,100);
                                        
                    if rand <= 40 then
                        unit:takeAttack(1);
                    elseif  rand < 60 then
                        unit:takeAttack(2);
                    elseif rand < 85 then
                        unit:takeAttack(3);
                    elseif this.ct_timer <= 0 then
                        unit:takeAttack(4);
                    else
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
                unit:setActiveSkill(1);
            end
            if index == 2 then
                unit:setActiveSkill(5);
            end
            ishost = megast.Battle:getInstance():isHost();
            if ishost and this.skillChecker == false then
                this.skillChecker = true;
                if this.chargeSkillFlag == true then
                    print("takeskill1");
                    unit:takeSkill(1);
                    return 0;
                else
                    print("takeskill2");
                    unit:takeSkill(2);
                    return 0;       
                end
            end

            this.skillChecker = false;
            return 1;
        end,

        takeDamage = function (this , unit)
            this.chargeSkillFlag = false;
            this.skillChecker = false;
            return 1;
        end,

        dead = function (this , unit)
            unit:setNextAnimationName("out");
            return 1;
        end,
        
        chargeskill = function (this , unit)
            if megast.Battle:getInstance():isHost() == true then
                megast.Battle:getInstance():sendEventToLua(this.thisID,1,0);
            end
            unit:setBurstPoint(0);
            unit:takeAnimation(0,"charge_short",true);
            unit:takeAnimationEffect(0,"charge_short",true);
            this.chargeSkillFlag = true;
            unit:setUnitState(kUnitState_attack);
            
            BattleControl:get():pushEnemyInfomation(this.messages.mess2,255,0,255,3);
            
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return 1;
end

