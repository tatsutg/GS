function new(id)
    print("10000 new ");
    local instance = {
        thisID = id,
        attackChecker = false,
        skillChecker = false,
        fromHost = false,
        myself = nil,
        spValue = 20,
        isRage = false,
        isRage2 = false,
        summonedNumber = 0,
        summonTimer = 0,
        absorbFlg = false,
        skill2FixedDamage = 350,
        delayItems = {

        },


        

        --通常時の行動重み　合計１００じゃなくても正規化されます
        weightsNormal = {
            {key = 1,value = 20},
            {key = 3,value = 30},
            {key = 5,value = 30}
        },

        weightsRage = {
            {key = 1,value = 30},
            {key = 2,value = 50},
            {key = 4,value = 20}
        },



        --スキルの行動重み　合計１００じゃなくても正規化されます
        weightsSkill = {
            {key = 2,value = 30},
            {key = 3,value = 30}
        },

        consts = {

            SPEED_BUFF_ID = 500471,
            SPEED_BUFF_EFFECT_ID = 28,
            SPEED_BUFF_VALUE = 30,
            SPEED_BUFF_DURATION = 9999,
            SPEED_BUFF_ICON = 7,
            SPEED_BUFF_EFANIMATION = 50009,
            SUMMON_ENEMY_ID = 80310,

            HPREGENATION_BUFF_ID = 500472,
            HPREGENATION_BUFF_EFFECT_ID = 7,
            HPREGENATION_BUFF_VALUE = 7000,
            HPREGENATION_BUFF_DURATION = 9999,
            HPREGENATION_BUFF_ICON = 35,

            ANTIBURN_BUFF_ID = 500473,
            ANTIBURN_BUFF_EFFECT_ID = 60,
            ANTIBURN_BUFF_VALUE = 30,
            ANTIBURN_BUFF_DURATION = 9999,
            ANTIBURN_BUFF_ICON = 66

        },

        colors = {
            red = {r = 255,g = 0,b = 28},
            yellow = {r = 220,g = 255,b = 0},
            green = {r = 50,g = 255,b = 0},
            cyan = {r = 0,g = 255,b = 255},
            magenta = {r = 255,g = 0,b = 255},
            white = {r = 255,g = 255,b = 255}
        },

        messages = summoner.Text:fetchByUnitID(500981313),

        talkFlags = {
            TALK1 = false,
            TALK2 = false,
            TALK3 = false,
            TALK4 = false
        },

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

            if this.utill.getHPParcent(unit) <= 100 and this.utill.getHPParcent(unit) > 80 and not this.isRage then
                this.getRage(this,unit);
                this.utill.sendEvent(this,3,0);
            end

            if this.isRage then
                attackTable = this.utill.randomPickItem(this,this.weightsRage);
            end


            unit:takeAttack(attackTable.key);
            this.utill.sendEvent(this,1,attackTable.key);
            return 0;
        end,

        skillBranch = function (this,unit)
            
            local skillTable = this.utill.randomPickItem(this,this.weightsSkill);

            unit:takeSkill(skillTable.key);
            this.utill.sendEvent(this,2,skillTable.key);
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
                unit:setActiveSkill(6);
                this.absorbFlg = true;
            elseif index == 3 then
                unit:setActiveSkill(7);
            end
        end,

        getTargetDistance = function(this,unit,target)
            return target:getPositionX() - unit:getPositionX();
        end,

        getRage = function(this,unit)
            this.isRage = true;
            this.setDelayItems(this,this.showTalk,5);
            -- this.utill.showMessage(this.messages.RAGE,this.colors.red,5);
            -- this.utill.showMessage(this.messages.mess2,this.colors.red,5);
            this.utill.showMessage(this.messages.ANTIDAMAGE,this.colors.red,5);
            this.utill.showMessage(this.messages.ANTICRITICAL,this.colors.red,5);

            unit:getTeamUnitCondition():addCondition(
                this.consts.SPEED_BUFF_ID,
                this.consts.SPEED_BUFF_EFFECT_ID,
                this.consts.SPEED_BUFF_VALUE,
                this.consts.SPEED_BUFF_DURATION,
                this.consts.SPEED_BUFF_ICON,
                this.consts.SPEED_BUFF_EFANIMATION
            );

            local burn = this.utill.findConditionWithType(unit,97);
            if burn ~= nil then
                unit:getTeamUnitCondition():removeCondition(burn);
            end
        end,

        getRage2 = function(this,unit)
            this.isRage = true;
            this.isRage2 = true;
            -- this.utill.showMessage(this.messages.RAGE,this.colors.red,5);
            -- this.utill.showMessage(this.messages.mess2,this.colors.red,5);
            this.setDelayItems(this,this.showTalk,5);

            unit:getTeamUnitCondition():addCondition(
                this.consts.SPEED_BUFF_ID,
                this.consts.SPEED_BUFF_EFFECT_ID,
                this.consts.SPEED_BUFF_VALUE,
                this.consts.SPEED_BUFF_DURATION,
                this.consts.SPEED_BUFF_ICON,
                this.consts.SPEED_BUFF_EFANIMATION
            );

            this.utill.showMessage(this.messages.ANTIDAMAGE,this.colors.red,5);
            this.utill.showMessage(this.messages.ANTICRITICAL,this.colors.red,5);

            this.utill.showMessage(this.messages.REGENATION,this.colors.green,5);
            unit:getTeamUnitCondition():addCondition(
                this.consts.HPREGENATION_BUFF_ID,
                this.consts.HPREGENATION_BUFF_EFFECT_ID,
                this.consts.HPREGENATION_BUFF_VALUE,
                this.consts.HPREGENATION_BUFF_DURATION,
                this.consts.HPREGENATION_BUFF_ICON
            );

            this.utill.showMessage(this.messages.ANTIBURN,this.colors.red,5);
            unit:getTeamUnitCondition():addCondition(
                this.consts.ANTIBURN_BUFF_ID,
                this.consts.ANTIBURN_BUFF_EFFECT_ID,
                this.consts.ANTIBURN_BUFF_VALUE,
                this.consts.ANTIBURN_BUFF_DURATION,
                this.consts.ANTIBURN_BUFF_ICON
            );
            local burn = this.utill.findConditionWithType(unit,97);
            if burn ~= nil then
                unit:getTeamUnitCondition():removeCondition(burn);
            end
        end,

        rageEnd = function(this,unit)
            this.utill.showMessage(this.messages.BARRIEREND,this.colors.yellow,5);
            this.utill.removeCondition(unit,this.consts.SPEED_BUFF_ID);
            this.isRage = false;
        end,

        showTalk = function (this,unit)
            if not this.talkFlags.TALK1 then
                this.utill.showMessage(this.messages.TALK1,this.colors.yellow,5);
                this.talkFlags.TALK1 = true;
            elseif not this.talkFlags.TALK2 then
                this.utill.showMessage(this.messages.TALK2,this.colors.yellow,5);
                this.talkFlags.TALK2 = true; 
            elseif not this.talkFlags.TALK3 then
                this.utill.showMessage(this.messages.TALK3,this.colors.yellow,5);
                this.talkFlags.TALK3 = true; 
            end
        end,

        onDead = function(this,unit)
            this.utill.showMessage(this.messages.TALK4,this.colors.yellow,5);
            for i = 0, 5 do
                local enemy = unit:getTeam():getTeamUnit(i,true);
                if not(enemy == nil )then
                    enemy:setHP(0);
                end
            end
        end,

        summon = function (this,unit)

            return 1;
        end,

        setDelayItems = function (this,method,delay)
            table.insert(this.delayItems,{method,delay});
        end,

        updateDelayItems = function (this,deltatime)
            for i = 1,table.maxn(this.delayItems) do
                if this.delayItems[i] ~= nil then
                    this.delayItems[i][2] = this.delayItems[i][2] - deltatime;
                    if this.delayItems[i][2] <= 0 then
                        this.executeDelayItem(this,this.delayItems[i][1]);
                        this.delayItems[i] = nil;
                    end
                end
            end
        end,

        executeDelayItem = function(this,item)
            item(this,this.myself);
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

        receive3 = function (this , intparam)
            this.getRage(this,this.myself);
            return 1;
        end,

        receive4 = function (this , intparam)
            this.rageEnd(this,this.myself);
            return 1;
        end,

        receive5 = function (this , intparam)
            this.getRage2(this,this.myself);
            return 1;
        end,

        receive6 = function (this , intparam)
            this.onDead(this,this.myself);
            return 1;
        end,




        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "summon" then return this.summon(this,unit) end
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

        startWave = function (this , unit , waveNum)
            this.utill.showMessage(this.messages.ANTIWATER,this.colors.cyan,5);
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
                return 1;
            end

            if this.utill.isHost() then

                -- this.summonTimer = this.summonTimer + deltatime;
                -- if this.summonTimer >= 30 then
                --     this.summonTimer = 0;
                --     this.summon(this,unit);
                -- end
                if this.utill.getHPParcent(unit) <= 100 and this.utill.getHPParcent(unit) > 80 and not this.isRage then
                    this.getRage(this,unit);
                    this.utill.sendEvent(this,3,0);
                end
                if this.utill.getHPParcent(unit) <= 80 and this.utill.getHPParcent(unit) > 60 and this.isRage then
                    this.rageEnd(this,unit);
                    this.utill.sendEvent(this,4,0);
                end
                if this.utill.getHPParcent(unit) <= 60 and this.utill.getHPParcent(unit) > 40 and not this.isRage then
                    this.getRage(this,unit);
                    this.utill.sendEvent(this,3,0);
                end
                if this.utill.getHPParcent(unit) <= 40 and this.utill.getHPParcent(unit) > 20 and this.isRage then
                    this.rageEnd(this,unit);
                    this.utill.sendEvent(this,4,0);
                end
                if this.utill.getHPParcent(unit) <= 20 and this.utill.getHPParcent(unit) > 0 and not this.isRage then
                    this.getRage2(this,unit);
                    this.utill.sendEvent(this,5,0);
                end

            end

            if this.isRage2 then

                local condValue = unit:getTeamUnitCondition():findConditionValue(97);
                
                if condValue == 0 and this.utill.getHPParcent(unit) < 80 then

                    local buff_ =  unit:getTeamUnitCondition():findConditionWithID(this.consts.HPREGENATION_BUFF_ID);
                    if buff_ == nil then
                        this.utill.showMessage(this.messages.RESTART,this.colors.green,5);
                        unit:getTeamUnitCondition():addCondition(
                            this.consts.HPREGENATION_BUFF_ID,
                            this.consts.HPREGENATION_BUFF_EFFECT_ID,
                            this.consts.HPREGENATION_BUFF_VALUE,
                            this.consts.HPREGENATION_BUFF_DURATION,
                            this.consts.HPREGENATION_BUFF_ICON
                        );
                    end

                else

                    local buff_ =  unit:getTeamUnitCondition():findConditionWithID(this.consts.HPREGENATION_BUFF_ID);
                    if not(buff_ == nil) then
                        this.utill.showMessage(this.messages.BURN,this.colors.red,5);

                        local conditon = unit:getTeamUnitCondition():findConditionWithID(this.consts.HPREGENATION_BUFF_ID);
                        unit:getTeamUnitCondition():removeCondition(conditon);
                    end

                end
            end

            this.updateDelayItems(this,deltatime);
            
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            if this.absorbFlg then
                value = enemy:getHP() - this.skill2FixedDamage > 1 and this.skill2FixedDamage or enemy:getHP() -1;
                unit:takeHeal(value);
            end

            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)

            if this.isRage then
                local condValue = unit:getTeamUnitCondition():findConditionValue(97);
                if condValue ~= 0 and enemy:getTeamUnitCondition():getDamageAffectInfo().critical then
                    return value;
                else
                    return 0;
                end
            end
            return value;
        end,

        --version1.0
        start = function (this , unit)
            this.initialize(this,unit);
            return 1;
        end,

        excuteAction = function (this , unit)
            this.absorbFlg = false;               
            return 1;
        end,

        takeIdle = function (this , unit)
            if this.isRage then
                unit:setNextAnimationName("idle2");
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
            this.onDead(this,unit);
            this.utill.sendEvent(this,6,0);
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

