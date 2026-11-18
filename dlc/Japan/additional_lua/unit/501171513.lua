function new(id)
    local instance = {
        attackChecker = false,  --takeAttackが無限ループしないようにするためのフラグ
        skillChecker = false,   --takeskillが無限ループしないようにするためのフラグ
        summonedNumber = 0,     --自分が今どのインデックスまでユニットを召喚したか覚えておく
        isRage = false,         --怒り状態かどうかのフラグ
        actionCounter = 0,      --ガウル召喚用のカウンター　executeActionごとに増加
        nextSummonCounter = 10, --次にガウルを召喚するまでの行動数
        consts = {
            HPRegenationBuffID = 7,
            HPRegenationBuffValue = 0.5,
            HPRegenationBuffTime = 120,
            HPRegenationBuffIcon = 35,
            speedBuffID = 28,
            speedBuffValue = 50,
            speedBuffTime = 120,
            speedBuffIcon = 7,
            summonEnemyID = 100111010    --召喚するガウルのエネミーID
        },
        messages = summoner.Text:fetchByUnitID(501171513),

        --咆哮での召喚　イベントに打たれたキーから呼ばれる
        summon = function (this,unit)
        
            return 1;
        end,


        addSP = function (this,unit)
            unit:addSP(20);
            return 1;
        end,
        
        --共通変数
        param = {
          version = 1.3
          ,isUpdate = 0
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
            if str == "summon" then return this.summon(this,unit) end
            if str == "addSP" then return this.addSP(this,unit) end
            return 1;
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            BattleControl:get():pushEnemyInfomation(this.messages.mess1,255,0,255,5);
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
            unit:setSkin("normal");--通常時のスキンをセット　これがないとスキンが無しとなって見えなくなってしまう
            
            unit:setSPGainValue(0);--大型ボスはsp自然増加はなし
            
            return 1;
        end,

        excuteAction = function (this , unit)
            this.actionCounter = this.actionCounter + 1;

            --怒り移行判定
            local hpparcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if hpparcent < 50 and not this.isRage then
               this.isRage = true;
               unit:setSkin("rage");

               --怒り移行時は咆哮をする
               this.attackChecker = true;
               unit:takeAttack(5);

               --自分にバフをかける
               --unit:getTeamUnitCondition():addCondition(this.consts.HPRegenationBuffID,this.consts.HPRegenationBuffID,unit:getCalcHPMAX() * this.consts.HPRegenationBuffValue/100,this.consts.HPRegenationBuffTime,this.consts.HPRegenationBuffIcon);
               --unit:getTeamUnitCondition():addCondition(this.consts.speedBuffID,this.consts.speedBuffID,this.consts.speedBuffValue,this.consts.speedBuffTime,this.consts.speedBuffIcon);
               
               return 0;
            end
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
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            elseif index == 3 then
                unit:setActiveSkill(3);
            elseif index == 4 then
                unit:setActiveSkill(4);
            end


            local target = unit:getTargetUnit() 
            local distance = BattleUtilities.getUnitDistance(unit,target)
            local ishost = megast.Battle:getInstance():isHost();
            print(distance);
            if ishost then
                --距離判定
                if distance > 400 and this.attackChecker == false then
                    this.attackChecker = true;
                    unit:takeAttack(4)
                    return 0;
                elseif this.attackChecker == false then
                    print("kita");
                    this.attackChecker = true;
                    rand = LuaUtilities.rand(0,100);
                    if rand <= 33 then
                        unit:takeAttack(1);
                    elseif rand < 66 then
                        unit:takeAttack(2);
                    else
                        unit:takeAttack(3);
                    end
                    return 0;
                end
            end
            this.attackChecker = false;
            return 1;
        end,

        takeSkill = function (this,unit,index)
            if index == 1 then
                unit:setActiveSkill(5);
            elseif index == 2 then
                unit:setActiveSkill(6);
            elseif index == 3 then
                unit:setActiveSkill(3);
            end
            local target = unit:getTargetUnit()
            local distance = BattleUtilities.getUnitDistance(unit,target)
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                --距離判定
                if distance > 400 and not this.skillChecker then
                    this.skillChecker = true
                    unit:takeSkill(2)
                    return 0;
                elseif not this.skillChecker then
                    this.skillChecker = true;
                    rand = LuaUtilities.rand(0,100);
                    if rand <= 50 then
                        unit:takeSkill(1);
                    elseif  rand <= 100 then
                        unit:takeSkill(2);
                    else
                        unit:takeSkill(3);
                    end
                    return 0;
                end
            end
            this.skillChecker = false
            return 1;
        end,

        takeDamage = function (this , unit)
            return 1;
        end,

        dead = function (this , unit)
            for i = 0, 5 do
                local enemy = unit:getTeam():getTeamUnit(i);
                if not(enemy == nil )then
                    enemy:setHP(0);
                end
            end
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

