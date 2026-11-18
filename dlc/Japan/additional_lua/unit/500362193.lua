function new(id)
    print("10000 new ");
    local instance = {
        thisID = id,
        attackChecker = false,
        skillChecker = false,
        fromHost = false,
        dieFromHost = false,
        myself = nil,
        isRage = false,
        isPhoenix = false,
        spValue = 20,
        phoenixTimer = 0,
        phoenixDuration = 5,
        phoenixCount = 1,
        forceAttackIndex = 0,
        isPhoenixMotion = false,
        phoenixExitTimer = 0,


        --通常時の行動重み　合計１００じゃなくても正規化されます
        weightsNormal = {
            {key = 1,value = 20},
            {key = 2,value = 20},
            {key = 3,value = 20}
        },

        --ど根性時の行動重み　合計１００じゃなくても正規化されます
        weightsRage = {
            {key = 1,value = 30},
            {key = 2,value = 30},
            {key = 4,value = 20},
            {key = 5,value = 20}
        },

        phenixRate = {100,60,10},--不死鳥モードに入る確率　左から１回目,２回目,３回目

        consts = {
            rageHP = 60,
            phoenixHealValue = 30
        },

        colors = {
            red = {r = 255,g = 0,b = 28},
            yellow = {r = 220,g = 255,b = 0},
            green = {r = 50,g = 255,b = 0},
            white = {r = 255,g = 255,b = 255}
        },

        messages = summoner.Text:fetchByUnitID(500362193),

        initialize = function (this,unit)
            this.myself = unit;
            unit:setSPGainValue(0);
            this.spValue = 20;
        end,

        takeAttackFromHost = function (this,unit,intparam)
            this.fromHost = true;
            unit:takeAttack(intparam);
        end,

        takeSkillFromHost = function (this,unit,intparam)
            this.fromHost = true;
            unit:takeSkill(intparam);
        end,

        attackBranch = function (this,unit)
            local attackTable = this.utill.randomPickItem(this,this.weightsNormal);
            if this.isRage then
                attackTable = this.utill.randomPickItem(this,this.weightsRage);
            end
            if this.forceAttackIndex ~= 0 then
                unit:takeAttack(this.forceAttackIndex);
                this.utill.sendEvent(this,1,this.forceAttackIndex);
                this.forceAttackIndex = 0;
            else
                unit:takeAttack(attackTable.key);
                this.utill.sendEvent(this,1,attackTable.key);
            end
            
            return 0;
        end,

        skillBranch = function (this,unit)
            if this.isRage then
                unit:takeSkill(2);
                this.utill.sendEvent(this,2,2);
            else
                unit:takeSkill(3);
                this.utill.sendEvent(this,2,3);
            end
            return 0;
        end,

        attackActiveSkillSetter = function (this,unit,index)
            if index == 1 then
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            elseif index == 3 then
                unit:setActiveSkill(3);
            elseif index == 4 then
                unit:setActiveSkill(4);
            elseif index == 5 then
                unit:setActiveSkill(5);
            end
        end,

        skillActiveSkillSetter = function (this,unit,index)
            if index == 2 then
                unit:setActiveSkill(7);
            elseif index == 3 then
                unit:setActiveSkill(6);
            end
        end,

        startPhoenix = function (this,unit)
            this.isPhoenix = true;
            this.phoenixTimer = 0;
            this.phoenixCount = this.phoenixCount + 1;
            this.isPhoenixMotion = true;

            if this.utill.isHost() then
                this.forceAttackIndex = 7;
                unit:takeAttack(1);
            end
        end,

        executePhoenix = function (this,unit)
            if this.utill.isHost() then
                this.utill.sendEvent(this,6,0);
                this.innerExecutePhenix(this,unit);
            end
            
            return 1;
        end,

        innerExecutePhenix = function (this,unit)
            this.phoenixTimer = 0;
            this.utill.showMessage(this.messages.mess6,this.colors.green,5,107);
            this.utill.showMessage(this.messages.mess7,this.colors.yellow,5,36);
            --this.utill.showMessage(this.messages.mess8,this.colors.green,5,35);
            this.addPhoenixBuff(this,unit);
            this.spValue = 50;
            this.isPhoenixMotion = false;
        end,

        finishPhenix = function (this,unit)
            this.isPhoenix = false;
            this.utill.showMessage(this.messages.mess9,this.colors.white,8);
            this.spValue = 20;
        end,

        startRage = function (this,unit)
            this.utill.showMessage(this.messages.mess3,this.colors.red,8,3);
            this.utill.showMessage(this.messages.mess4,this.colors.red,8,7);
            -- this.utill.showMessage(this.messages.mess5,this.colors.red,8);
            this.forceAttackIndex = 6;
            unit:takeAttack(1);
            unit:setAttackTimer(1);
            this.addRageBuff(this,unit);
            this.isRage = true;
        end,

        addRageBuff = function (this,unit)
            unit:getTeamUnitCondition():addCondition(-12, 13, 30, 20000, 3);
            unit:getTeamUnitCondition():addCondition(-13, 0, 1, 20000, 7);
            unit:setAttackDelay(0);
        end,

        addPhoenixBuff = function (this,unit)
            --２回目以降は回復量を半減させていく
            local div = this.phoenixCount - 1;
            
            unit:getTeamUnitCondition():addCondition(-14, 7, unit:getCalcHPMAX() * this.consts.phoenixHealValue / div / (this.phoenixDuration * 100), this.phoenixDuration, 35);
            unit:getTeamUnitCondition():addCondition(-15, 0, 1, this.phoenixDuration, 36, 17);
        end,


        utill = {
            isHost = function ()
                return megast.Battle:getInstance():isHost();
            end,

            getHPParcent = function(unit)
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

        addSP = function (this,unit)
            if this.utill.isHost() then
                unit:addSP(this.spValue);
                -- this.utill.sendEvent(this,7,this.spValue);
            end
            return 1;
        end,

        onWin = function(this,unit)
            unit:playVoice("VOICE_BATTLEWIN_A");
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
            this.takeAttackFromHost(this,this.myself,intparam);
            return 1;
        end,

        receive2 = function (this,intparam)
            this.takeSkillFromHost(this,this.myself,intparam);
            return 1;
        end,

        receive3 = function (this,intparam)
            this.startRage(this,this.myself);
            return 1;
        end,

        receive4 = function (this,intparam)
            this.startPhoenix(this,this.myself);
            return 1;
        end,

        receive5 = function (this,intparam)
            this.dieFromHost = true;
            this.myself:setHP(0);
            return 1;
        end,

        receive6 = function (this,intparam)
            this.innerExecutePhenix(this,this.myself);
            return 1;
        end,

        -- receive7 = function (this,intparam)
        --     this.myself:addSP(intparam);
        --     return 1;
        -- end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "phoenix" then return this.executePhoenix(this,unit) end
            if str == "onWin" then return this.onWin(this,unit) end
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
            -- if unit:getHP() > 0 then
            unit:callLuaMethod("onWin",1.5);
                
            -- end
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            this.utill.showMessage(this.messages.mess1,this.colors.red,6,26);
            this.utill.showMessage(this.messages.mess2,this.colors.red,6,26);
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            if this.isPhoenix and not this.isPhoenixMotion then
                this.phoenixTimer = this.phoenixTimer + deltatime;

                if this.phoenixTimer > this.phoenixDuration then
                    this.finishPhenix(this,unit);
                end

            end
            if this.isPhoenixMotion then
                this.phoenixExitTimer = this.phoenixExitTimer + deltatime;
                if this.phoenixExitTimer > 20 then
                    unit:setHP(1);
                    this.phoenixExitTimer = 0;
                    unit:excuteAction();
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
            this.initialize(this,unit);
            return 1;
        end,

        excuteAction = function (this , unit)
            if this.isPhoenixMotion then
                if this.utill.isHost() then
                    this.forceAttackIndex = 7;
                    unit:takeAttack(1);
                end
                
                return 0;
            end
            if this.utill.isHost() then
                if this.utill.getHPParcent(unit) < this.consts.rageHP and not this.isRage then
                    this.startRage(this,unit);
                    this.utill.sendEvent(this,3,1);
                    return 0;
                end
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

            if this.utill.isHost() and not this.attackChecker then
                this.attackChecker = true;
                return this.attackBranch(this,unit);
            end
            this.attackChecker = false;

            if not this.utill.isHost() and not this.fromHost then
                unit:takeIdle();
                return 0;
            end
            this.fromHost = false;
            this.attackActiveSkillSetter(this,unit,index)
            return 1;
        end,

        takeSkill = function (this,unit,index)

            if this.utill.isHost() and not this.skillChecker then
                this.skillChecker = true;
                return this.skillBranch(this,unit);
            end
            this.skillChecker = false;

            if not this.utill.isHost() and not this.fromHost then
                unit:takeIdle();
                return 1;
            end
            unit:setBurstState(kBurstState_active);
            this.fromHost = false;
            this.skillActiveSkillSetter(this,unit,index);
            return 1;
        end,

        takeDamage = function (this , unit)
            return 1;
        end,

        dead = function (this , unit)
            if this.utill.isHost() then
                if this.phoenixCount <= 3 and not this.isPhoenix then
                    local rand = LuaUtilities.rand(100);
                    if rand < this.phenixRate[this.phoenixCount] then
                        this.startPhoenix(this,unit);
                        this.utill.sendEvent(this,4,1);
                        this.phoenixExitTimer = 0;
                    end
                end
                
            end
            if this.isPhoenix or (not this.utill.isHost() and not this.dieFromHost) then
                unit:setHP(1);
                unit:getTeam():setBoss(unit);
                return 0;
            end
            if this.utill.isHost() then
                this.utill.sendEvent(this,5,1);
            end
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

