--白銀ヴァルザンです
function new(id)
    print("500931513 new ");
    local instance = {
        thisID = id,
        attackChecker = false,
        skillChecker = false,
        fromHost = false,
        myself = nil,
        spValue = 20,
        state = 0,
        chargeStartTime = 0,
        breakCounter = 0,
        isRage = false,
        isTarget = false,
        telopTimer = 1,
        telopTimerDelay = 30,


        states = {
            start = 0,
            shadowLightning1 = 1,
            normal1 = 2,
            shadowLightning2 = 3,
            normal2 = 4
        },


        

        --通常時の行動重み　合計１００じゃなくても正規化されます
        weightsNormal = {
            {key = 1,value = 20},
            {key = 2,value = 30},
            {key = 3,value = 20},
            {key = 4,value = 30}
        },

        weightsRage = {
            {key = 3,value = 20}
        },



        --スキルの行動重み　合計１００じゃなくても正規化されます
        weightsSkill = {
            {key = 3,value = 20}
        },

        consts = {
            --ShadowLigtningBuff
            SLBUFF_ID = 50093,
            SLBUFF_EFID = 113,
            SLBUFF_VAUE = 1000,
            SLBUFF_DURATION = 25,
            SLBUFF_ICON = 67,

            --DefenceBuff
            DBUFF1_ID = 500931,
            DBUFF1_EFID = 21,
            DBUFF1_VAUE = -25,
            DBUFF1_DURATION = 99999,
            DBUFF1_ICON = 20,

            DBUFF2_ID = 500932,
            DBUFF2_EFID = 21,
            DBUFF2_VAUE = -25,
            DBUFF2_DURATION = 99999,
            DBUFF2_ICON = 20,

            DBUFF3_ID = 500933,
            DBUFF3_EFID = 21,
            DBUFF3_VAUE = -50,
            DBUFF3_DURATION = 99999,
            DBUFF3_ICON = 20,

            DBUFF4_ID = 500934,
            DBUFF4_EFID = 21,
            DBUFF4_VAUE = 25,
            DBUFF4_DURATION = 99999,
            DBUFF4_ICON = 0,

            DBUFF5_ID = 500938,
            DBUFF5_EFID = 21,
            DBUFF5_VAUE = -25,
            DBUFF5_DURATION = 99999,
            DBUFF5_ICON = 0,

            DBUFF6_ID = 500937,
            DBUFF6_EFID = 21,
            DBUFF6_VAUE = -50,
            DBUFF6_DURATION = 99999,
            DBUFF6_ICON = 20,

            BREAKBUFF_ID = 500935,
            BREAKBUFF_EFID = 27,
            BREAKBUFF_VAUE = -10,
            BREAKBUFF_DURATION = 99999,
            BREAKBUFF_ICON = 0,

            --SPeedBuff
            SPBUFF_ID = 500936,
            SPBUFF_EFID = 28,
            SPBUFF_VAUE = 30,
            SPBUFF_DURATION = 99999,
            SPBUFF_ICON = 7,


        },

        colors = {
            red = {r = 255,g = 0,b = 28},
            yellow = {r = 220,g = 255,b = 0},
            green = {r = 50,g = 255,b = 0},
            cyan = {r = 0,g = 255,b = 255},
            magenta = {r = 255,g = 0,b = 255},
            white = {r = 255,g = 255,b = 255}
        },

        messages = summoner.Text:fetchByUnitID(500931513),        
        telop = {
            mess1 = summoner.Text:fetchByUnitID(500931513).telop1,
            mess2 = summoner.Text:fetchByUnitID(500931513).telop2,
            mess3 = summoner.Text:fetchByUnitID(500931513).telop3,
            mess4 = summoner.Text:fetchByUnitID(500931513).telop4,
            mess5 = summoner.Text:fetchByUnitID(500931513).telop5,
            mess6 = summoner.Text:fetchByUnitID(500931513).telop6
        },


        initialize = function (this,unit)
            this.myself = unit;
            unit:setSPGainValue(0);
            this.spValue = 20;
            this.getState(this);
            this.breakCounter = this.getBreakCount(this);
            
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
            this.getState(this);

            if this.state == this.states.start and this.utill.getHPParcent(unit) <= 80 then
                unit:takeAttack(5);
                this.setTimer();
                this.chargeStartTime = this.getTimer();
                this.startCharge(this,unit);
                this.sendState(this.states.shadowLightning1);
                this.state = this.states.shadowLightning1;
                return 0;
            end
            if this.state == this.states.shadowLightning1 then
                unit:takeAttack(5);
                this.startCharge(this,unit);
                this.chargeStartTime = this.getTimer();
                return 0;
            end
            if this.state == this.states.normal1 and this.utill.getHPParcent(unit) <= 50 then
                unit:takeAttack(5);
                this.setTimer();
                this.chargeStartTime = this.getTimer();
                this.startCharge(this,unit);
                this.sendState(this.states.shadowLightning2);
                this.state = this.states.shadowLightning2;
                return 0;
            end
            if this.state == this.states.shadowLightning2 then
                unit:takeAttack(5);
                this.startCharge(this,unit);
                this.chargeStartTime = this.getTimer();
                return 0;
            end

            if not this.isRage and this.utill.getHPParcent(unit) <= 40 then
                this.getRage(this,unit);
                unit:takeAttack(4);
                return 0;
            end



            local attackTable = this.utill.randomPickItem(this,this.weightsNormal);


            unit:takeAttack(attackTable.key);
            -- this.utill.sendEvent(this,1,attackTable.key);
            return 0;
        end,

        skillBranch = function (this,unit)
            if this.state == this.states.shadowLightning1 then
                unit:takeSkill(1);
                this.state = this.states.normal1;
                this.sendState(this.states.normal1);
                this.utill.removeCondition(unit,this.consts.SLBUFF_ID);
                this.utill.removeCondition(unit,this.consts.DBUFF6_ID);
                return 0;
            end

            if this.state == this.states.shadowLightning2 then
                unit:takeSkill(1);
                this.state = this.states.normal2;
                this.sendState(this.states.normal2);
                this.utill.removeCondition(unit,this.consts.SLBUFF_ID);
                this.utill.removeCondition(unit,this.consts.DBUFF6_ID);
                return 0;
            end
            
            local skillTable = this.utill.randomPickItem(this,this.weightsSkill);

            unit:takeSkill(skillTable.key);
            -- this.utill.sendEvent(this,2,skillTable.key);
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
            end
        end,

        skillActiveSkillSetter = function (this,unit,index)
            if index == 1 then
                unit:setActiveSkill(5);
            elseif index == 2 then
                unit:setActiveSkill(5);
            elseif index == 3 then
                unit:setActiveSkill(6);
            end
        end,

        getTargetDistance = function(this,unit,target)
            return target:getPositionX() - unit:getPositionX();
        end,

        --シャドウライトニングチャージモーション移行時の処理
        startCharge = function(this,unit)
            this.utill.showMessage(this.messages.mess1,this.colors.magenta,5);
            unit:getTeamUnitCondition():addCondition(
                this.consts.SLBUFF_ID,
                this.consts.SLBUFF_EFID,
                this.consts.SLBUFF_VAUE,
                this.consts.SLBUFF_DURATION,
                this.consts.SLBUFF_ICON
            );

            unit:setBurstPoint(0);
        end,

        addStartBuff = function(this,unit)
            if this.breakCounter <= 0 then
                unit:getTeamUnitCondition():addCondition(
                    this.consts.DBUFF1_ID,
                    this.consts.DBUFF1_EFID,
                    this.consts.DBUFF1_VAUE,
                    this.consts.DBUFF1_DURATION,
                    this.consts.DBUFF1_ICON
                );
            end
            if this.breakCounter <= 1 then
                unit:getTeamUnitCondition():addCondition(
                    this.consts.DBUFF2_ID,
                    this.consts.DBUFF2_EFID,
                    this.consts.DBUFF2_VAUE,
                    this.consts.DBUFF2_DURATION,
                    this.consts.DBUFF2_ICON
                );
            end
            if this.breakCounter <= 2 then
                unit:getTeamUnitCondition():addCondition(
                    this.consts.DBUFF3_ID,
                    this.consts.DBUFF3_EFID,
                    this.consts.DBUFF3_VAUE,
                    this.consts.DBUFF3_DURATION,
                    this.consts.DBUFF3_ICON
                );
            end

            if this.breakCounter >= 1 then
                unit:getTeamUnitCondition():addCondition(
                    this.consts.BREAKBUFF_ID,
                    this.consts.BREAKBUFF_EFID,
                    this.consts.BREAKBUFF_VAUE * (this.exponential(2,this.breakCounter)),
                    this.consts.BREAKBUFF_DURATION,
                    this.consts.BREAKBUFF_ICON
                );
            end

            unit:getTeamUnitCondition():addCondition(
                this.consts.DBUFF4_ID,
                this.consts.DBUFF4_EFID,
                this.consts.DBUFF4_VAUE,
                this.consts.DBUFF4_DURATION,
                this.consts.DBUFF4_ICON
            );
            
            
        end,


        --指数関数っぽい結果を返してくれるやつ　ただしx > 0の範囲に限る
        exponential = function(a,x)
            local y = a;
            for i=1,x -1 do
                y = y * a;
            end
            return y;
        end,

        breakBuffCheck = function(this,unit)
            if this.breakCounter >= 1 then
                this.utill.removeCondition(unit,this.consts.DBUFF1_ID);
            end
            if this.breakCounter >= 2 then
                this.utill.removeCondition(unit,this.consts.DBUFF2_ID);
            end
            if this.breakCounter >= 3 then
                this.utill.removeCondition(unit,this.consts.DBUFF3_ID);
            end
            if this.breakCounter >= 1 then
                unit:getTeamUnitCondition():addCondition(
                    this.consts.BREAKBUFF_ID,
                    this.consts.BREAKBUFF_EFID,
                    this.consts.BREAKBUFF_VAUE * (this.exponential(2,this.breakCounter)),
                    this.consts.BREAKBUFF_DURATION,
                    this.consts.BREAKBUFF_ICON
                );
            end
        end,

        getRage = function(this,unit)
            
            this.isRage = true;
            unit:setReduceHitStop(2,0.8);
            unit:setAttackDelay(0);
            this.utill.showMessage(this.messages.mess3,this.colors.magenta,5);
            
            --背景の色変える
            megast.Battle:getInstance():setBackGroundColor(99999,255,50,255);


            local buff = unit:getTeamUnitCondition():addCondition(
                this.consts.SPBUFF_ID,
                this.consts.SPBUFF_EFID,
                this.consts.SPBUFF_VAUE,
                this.consts.SPBUFF_DURATION,
                this.consts.SPBUFF_ICON
            );

            buff:addAnimationWithFile("effect/aura1.json","aura2"); 

            unit:getTeamUnitCondition():addCondition(
                this.consts.DBUFF5_ID,
                this.consts.DBUFF5_EFID,
                this.consts.DBUFF5_VAUE,
                this.consts.DBUFF5_DURATION,
                this.consts.DBUFF5_ICON
            );

        end,

        --シャドウライトニング管理用のステート送信
        sendState = function(state)
            if RaidControl:get() ~= nil then
                RaidControl:get():setCustomValue("state",""..state);
            end
        end,

        --シャドウライトニング管理用のステート取得
        getState = function(this)
            if RaidControl:get() ~= nil then
                local st = tonumber(RaidControl:get():getCustomValue("state"));
                if st ~= "" and st ~= "error" and st ~= nil then
                    this.state = st;
                else
                    this.state = 0;
                end
            end
        end,

        --シャドウライトニング状態に移行した時間を送信　シャドウライトニングの発射は全員ほぼ同タイミングに行われるようにしたいのでチャージ開始からの時間で発動までを計測
        setTimer = function()
            if RaidControl:get() ~= nil then
                RaidControl:get():setCustomValue("startTime",""..RaidControl:get():getCurrentRaidTime());
            end
        end,

        --シャドウライトニング状態に移行した時間を取得
        getTimer = function()
            if RaidControl:get() ~= nil then
                local t = tonumber(RaidControl:get():getCustomValue("startTime"));
                if t ~= "" and t ~= "error" and t ~= nil then
                    return t;
                else
                    return RaidControl:get():getCurrentRaidTime();
                end
            end
            return nil;
        end,

        getBreakCount = function(this)
            if RaidControl:get():getRaidBreakCount() >= 3 then
                return 3;
            end

            --breakCounterは一方通行にしたいので大きい方を返す
            return this.breakCounter < RaidControl:get():getRaidBreakCount() and RaidControl:get():getRaidBreakCount() or this.breakCounter;
        end,

        getIsTarget = function()
            return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > 1000000;
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


            findConditionWithType = function (unit,conditionTypeID)
                return unit:getTeamUnitCondition():findConditionWithType(conditionTypeID);
            end,

            removeCondition = function (unit,buffID)
                local buff = unit:getTeamUnitCondition():findConditionWithID(buffID);
                if buff ~= nil then
                    unit:getTeamUnitCondition():removeCondition(buff);
                end
            end,

            
            findUnitByBaseID = function (targetID,isPlayerTeam)
                for i = 0,4 do
                    local target = megast.Battle:getInstance():getTeam(isPlayerTeam):getTeamUnit(i);
                    if target ~= nil and target:getBaseID3() == targetID then
                        return target;
                    end
                end            
            end,

            findAllUnitByBaseID = function (targetID,isPlayerTeam)
                local resultTable = {};
                for i = 0,4 do
                    local target = megast.Battle:getInstance():getTeam(isPlayerTeam):getTeamUnit(i);
                    if target ~= nil and target:getBaseID3() == targetID then
                        table.insert(resultTable,target);
                    end
                end
                return resultTable;          
            end,

            sendEvent = function(this,index,intparam)
                megast.Battle:getInstance():sendEventToLua(this.thisID,index,intparam);
            end,

            showMessage = function(message,rgb,duration,iconid,player)
                if player ~= nil then
                    if iconid ~= nil and iconid ~= 0 then
                        BattleControl:get():pushInfomationWithConditionIcon(message,iconid,rgb.r,rgb.g,rgb.b,duration);
                    else
                        BattleControl:get():pushInfomation(message,rgb.r,rgb.g,rgb.b,duration);
                    end
                    return;
                end
                if iconid ~= nil and iconid ~= 0 then
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(message,iconid,rgb.r,rgb.g,rgb.b,duration);
                else
                    BattleControl:get():pushEnemyInfomation(message,rgb.r,rgb.g,rgb.b,duration);
                end
            end,
        },

        addSP = function (this,unit)
            if this.utill.isHost() then
                unit:addSP(this.spValue);
            end
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

        receive2 = function (this , intparam)
            this.takeSkillFromHost(this,this.myself,intparam);
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
            if this.state == this.states.shadowLightning1 then
                
                this.state = this.states.normal1;
                this.sendState(this.states.normal1);
                this.utill.removeCondition(unit,this.consts.SLBUFF_ID);
                this.utill.removeCondition(unit,this.consts.DBUFF6_ID);
            end

            if this.state == this.states.shadowLightning2 then
                
                this.state = this.states.normal2;
                this.sendState(this.states.normal2);
                this.utill.removeCondition(unit,this.consts.SLBUFF_ID);
                this.utill.removeCondition(unit,this.consts.DBUFF6_ID);
            end
            --breakcounterが行き過ぎないように、けれどその人の画面でブレイクしていたらすぐにバフが剥がれるように
            if this.breakCounter <= RaidControl:get():getRaidBreakCount() and this.breakCounter <= 3 then
                this.breakCounter = this.breakCounter + 1;
                this.breakBuffCheck(this,unit);
                this.utill.showMessage(this.messages.mess2,this.colors.magenta,5);
            end

            return 1;
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            this.addStartBuff(this,unit);
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            if this.state == this.states.shadowLightning1 or this.state == this.states.shadowLightning2 then
                unit:setBurstPoint((RaidControl:get():getCurrentRaidTime() - this.chargeStartTime)*5);
            end
            
            if this.isRage then
                unit:setReduceHitStop(2,0.8);
            end
            
            --テロップ表示のチェック
            this.telopTimer = this.telopTimer - deltatime;
            if this.telopTimer < 0 then
                this.telopTimer = this.telopTimerDelay;                
                local rand = LuaUtilities.rand(0,4)
                if rand == 0 then
                    if isTarget then
                        RaidControl:get():addPauseMessage(this.telop.mess3 , 2.2);
                    else
                        RaidControl:get():addPauseMessage(this.telop.mess1 , 2.2);
                    end
                elseif rand == 1 then
                    if isRage then
                        RaidControl:get():addPauseMessage(this.telop.mess4 , 2.2);
                    else
                        RaidControl:get():addPauseMessage(this.telop.mess2 , 2.2);
                    end
                elseif rand == 2 then
                        RaidControl:get():addPauseMessage(this.telop.mess5 , 2.2);
                elseif rand == 3 then
                        RaidControl:get():addPauseMessage(this.telop.mess6 , 2.2);
                end
            end
            
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            if this.isTarget then
                value = value * 2.5;
            end
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
            this.breakCounter = this.getBreakCount(this);
            this.breakBuffCheck(this,unit);

            if not this.isTarget and this.getIsTarget() then
                this.utill.showMessage(this.messages.mess4,this.colors.red,5,0,true);
            end
            this.isTarget = this.getIsTarget(); 
            if this.isTarget then
                BattleControl:get():showHateAll();
            else
                BattleControl:get():hideHateAll();
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

            if not this.utill.isHost and not this.fromHost then
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

            if not this.utill.isHost and not this.fromHost then
                unit:takeIdle();
                return 0;
            end

            this.fromHost = false;
            unit:setBurstState(kBurstState_active);
            this.skillActiveSkillSetter(this,unit,index);
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

