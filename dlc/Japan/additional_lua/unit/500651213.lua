function new(id)
    print("10000 new ");
    local instance = {
        uniqueID = id,
        myself = nil,
        counterAFlag = false,
        counterBFlag = false,
        isRage = false,
        buffCount = 0,
        --アタックチェック
        isAttackChecker = false,

        --スキルチェック
        isSkillChecker = false,


        --通常攻撃の重み　合計１００じゃなくても正規化されます
        weightsAttack = {
            {key = 1,value = 30},
            {key = 2,value = 20},
            {key = 7,value = 10},
            {key = 8,value = 10},
            {key = 9,value = 20}
        },

        --怒り時通常攻撃の重み　合計１００じゃなくても正規化されます
        weightsRageAttack = {
            {key = 1,value = 20},
            {key = 2,value = 20},
            {key = 3,value = 8},
            {key = 4,value = 8},
            {key = 5,value = 8},
            {key = 6,value = 8},
            {key = 9,value = 20}
        },


        --奥義の重み　合計１００じゃなくても正規化されます
        weightsSkill = {
            {key = 2,value = 20}
        },

        --奥義の重み（怒り時）
        weightsSkillRage = {
            {key = 1,value = 20}
        },



        consts = {
            dpsCheckHP1 = 50,
            dpsCheckHP2 = 30,
            dpsCheckHP3 = 15,
            hateTargetRate = 1.1,
            rageHP = 50,
            buffID = 50065,
            buffValue = 1000,
            buffAddRate = 30,
            buffLimit = 10
        },

 
        glabEffect = {
            orbitSystem = nil,
            position = nil
        },

        messages = summoner.Text:fetchByUnitID(500651213),

        colors = {
            red = {r = 255,g = 0,b = 28},
            yellow = {r = 220,g = 255,b = 0},
            green = {r = 50,g = 255,b = 0},
            blue = {r = 0,g = 255,b = 255},
            white = {r = 255,g = 255,b = 255}
        },


        --アタック分岐
        takeAttackBranch = function(this,unit,index)
            
            local attackTable = this.utill.randomPickItem(this,this.weightsAttack);
            if this.isRage then
                attackTable = this.utill.randomPickItem(this,this.weightsRageAttack);
            end
            
            unit:takeAttack(attackTable.key);
    
            return 0;
        end,

        takeSkillBranch = function(this,unit,index)
            local skillTable = this.utill.randomPickItem(this,this.weightsSkill);
            if this.isRage then
                skillTable = this.utill.randomPickItem(this,this.weightsSkillRage);
            end
            unit:takeSkill(skillTable.key);
            return 0;
        end,

        showCounterInfoA = function(this,unit)
            this.utill.showMessage(this.messages.mess2,this.colors.blue,5);
            return 1;
        end,

        showCounterInfoA = function(this,unit)
            this.utill.showMessage(this.messages.mess2,this.colors.blue,5);
            this.counterAFlag = true;
            return 1;
        end,

        startCounterA = function(this,unit)
            unit:takeAnimation(0,"counterA",false);
            unit:takeAnimationEffect(0,"counterA",false);
            return 1;
        end,

        endCounterA = function(this,unit)
            this.counterAFlag = false;
            return 1;
        end,

        showCounterInfoB = function(this,unit)
            this.utill.showMessage(this.messages.mess3,this.colors.blue,5);
            this.counterBFlag = true;
            return 1;
        end,

        startCounterB = function(this,unit)
            unit:takeAnimation(0,"counterB",false);
            unit:takeAnimationEffect(0,"counterB",false);
            return 1;
        end,

        endCounterB = function(this,unit)
            this.counterBFlag = false;
            return 1;
        end,

        setupAnimation = function(this,unit)
            this.myself:setSetupAnimationNameEffect("");
            this.myself:setSetupAnimationName("");
            return 1;
        end,

        getRage = function(this,unit)
            this.isRage = true;
            -- this.utill.showMessage(this.messages.mess2,this.colors.yellow,5);
        end,

        addBuff = function(this,unit)
            local buff = unit:getTeamUnitCondition():findConditionWithID(this.consts.buffID);
            if buff == nil then
                unit:getTeamUnitCondition():addCondition(this.consts.buffID,7,this.consts.buffValue,200000,35);
                unit:playSummary(this.messages.mess4,true);
            else
                this.buffCount = this.buffCount + 1;
                if this.buffCount > this.consts.buffLimit then return 1 end
                buff:setValue(this.consts.buffValue + this.consts.buffValue * this.buffCount * this.consts.buffAddRate/100);
                unit:playSummary(this.messages.mess5,true);
            end
            return 1;
        end,



        addSP = function (this , unit)
            unit:addSP(20);
            return 1;
        end,

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

            --指定された条件に当てはまるユニット１体を返します　
            --この関数に渡すconditionFuncは真偽値を返す関数にしてください。引数にthis,TeamUnitを渡しますのでそれを使って関数内で判断してください。
            findUnit = function (conditionFunc,isPlayerTeam)
                for i = 0,4 do
                    local target = megast.Battle:getInstance():getTeam(isPlayerTeam):getTeamUnit(i);
                    if target ~= nil and conditionFunc(this,target) then
                        return target;
                    end
                end            
            end,

            --指定された条件に当てはまるユニット全てを返します　
            --この関数に渡すconditionFuncは真偽値を返す関数にしてください。引数にthis,TeamUnitを渡しますのでそれを使って関数内で判断してください。
            findAllUnit = function (conditionFunc,isPlayerTeam)
                local resultTable = {};
                for i = 0,4 do
                    local target = megast.Battle:getInstance():getTeam(isPlayerTeam):getTeamUnit(i);
                    if target ~= nil and conditionFunc(this,target) then
                        table.insert(resultTable,target);
                    end
                end
                return resultTable;          
            end,

            sendEvent = function(this,index,intparam)
                megast.Battle:getInstance():sendEventToLua(this.uniqueID,index,intparam);
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
            this.getRage(this,myself);
            return 1;
        end,

        receive2 = function (this , intparam)

            return 1;
        end,

        receive3 = function (this , intparam)
           
            return 1;
        end,
        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "startCounterA" then return this.startCounterA(this,unit) end
            if str == "startCounterB" then return this.startCounterB(this,unit) end
            if str == "endCounterA" then return this.endCounterA(this,unit) end
            if str == "endCounterB" then return this.endCounterB(this,unit) end
            if str == "setupAnimation" then return this.setupAnimation(this,unit) end
            if str == "addBuff" then return this.addBuff(this,unit) end
            if str == "showCounterInfoA" then return this.showCounterInfoA(this,unit) end
            if str == "showCounterInfoB" then return this.showCounterInfoB(this,unit) end
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
            this.utill.showMessage(this.messages.mess1,this.colors.green,5,45);
            this.addBuff(this,unit);
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
            if this.counterAFlag then
                local skillType = enemy:getTeamUnitCondition():getDamageAffectInfo().skillType;
                if skillType == 1 or skillType ==3 or skillType == 6 then
                    this.isSkillChecker = true;
                    this.myself:setSetupAnimationNameEffect("setupA");
                    this.myself:setSetupAnimationName("setupA");
                    unit:setHitStopTimeSelf(0);
                    unit:setInvincibleTime(2);
                    unit:takeSkill(5);
                    this.counterAFlag = false;
                elseif skillType == 2 then
                    unit:takeDamage();
                end
            end
            if this.counterBFlag then
                local skillType = enemy:getTeamUnitCondition():getDamageAffectInfo().skillType;
                if skillType == 1 or skillType ==3 or skillType == 6 then
                    this.isSkillChecker = true;
                    this.myself:setSetupAnimationNameEffect("setupB");
                    this.myself:setSetupAnimationName("setupB");
                    unit:setHitStopTimeSelf(0);
                    unit:setInvincibleTime(2);
                    unit:takeSkill(4);
                    this.counterBFlag = false;
                elseif skillType == 2 then
                    unit:takeDamage();
                end

            end
            return value;
        end,

        --version1.0
        start = function (this , unit)
            this.myself = unit;
            unit:setSPGainValue(0);
            unit:setAttackDelay(0);
            return 1;
        end,

        excuteAction = function (this , unit)
            -- this.myself:setSetupAnimationNameEffect("");
            -- this.myself:setSetupAnimationName("");
            if not this.isRage and this.utill.isHost() and this.utill.getHPPercent(unit) < this.consts.rageHP then
                this.utill.sendEvent(this,1,0);
                this.getRage(this,unit);
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
            local isHost = this.utill.isHost();
            if isHost then
                if this.isAttackChecker == false then
                    this.isAttackChecker = true;
                    return this.takeAttackBranch(this,unit,index);
                end
                this.isAttackChecker = false;
            end
            
            unit:setActiveSkill(index);
            
            return 1;
        end,

        takeSkill = function (this,unit,index)
            local isHost = this.utill.isHost();
            if isHost then
                
                if this.isSkillChecker == false then
                    this.isSkillChecker = true;
                    return this.takeSkillBranch(this,unit,index);
                end
                this.isSkillChecker = false;
            end
            if index == 1 then
                unit:setActiveSkill(10);
            elseif index == 2 then
                unit:setActiveSkill(11);
            elseif index == 3 then
                unit:setActiveSkill(12);
            elseif index == 4 then
                unit:setActiveSkill(13);
            elseif index == 5 then
                unit:setActiveSkill(14);
            end
            return 1;
        end,

        takeDamage = function (this , unit)
            this.myself:setSetupAnimationNameEffect("");
            this.myself:setSetupAnimationName("");
            this.counterAFlag = false;
            this.counterBFlag = false;
            return 1;
        end,

        dead = function (this , unit)
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

