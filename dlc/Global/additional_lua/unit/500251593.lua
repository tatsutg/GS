--@additionalItem,100071199
function new(id)
    print("500251593 new ");    --ボスユニット：ラグシェルム[1]
    local instance = {
        uniqueID = id,
        attackChecker = false,
        skillChecker = false,
        coolTimes = {},
        coolTimeMemory = {},
        isRage = false,
        isSkill2 = false,

                --通常攻撃の重み　合計１００じゃなくても正規化されます
        weightsAttack = {
            {key = 1,value = 20},
            {key = 2,value = 20},
            {key = 3,value = 20}
        },

        --奥義の重み　合計１００じゃなくても正規化されます
        weightsSkill = {
            {key = 1,value = 20}
        },

        consts = {
            DEFBuffID = 15,
            DEFBuffEFID = 15,
            DEFBuffEF = 50,
            DEFBuffTime = 3000,
            DEFBuffIcon = 5,

            SPEEDBuffID = 28,
            SPEEDBuffEFID = 28,
            SPEEDBuffEF = 50,
            SPEEDBuffTime = 3000,
            SPEEDBuffIcon = 7,

            ATTACKBuffID = 13,
            ATTACKBuffEFID = 13,
            ATTACKBuffEF = 150,
            ATTACKBuffTime = 3000,
            ATTACKBuffIcon = 3,

            rageHPParcent = 75
        },
        barrier = nil,

        --アタック分岐
        takeAttackBranch = function(this,unit,index)
            local attackTable = this.utill.randomPickItem(this,this.weightsAttack);
            
            unit:takeAttack(attackTable.key);
    
            return 0;
        end,

        takeSkillBranch = function(this,unit,index)
            -- local skillTable = this.utill.randomPickItem(this,this.weightsSkill);
            if this.isDPSCheck then
                this.isDPSCheck = false;
                unit:takeSkill(2);
            else
                unit:takeSkill(1);
            end
            return 0;
        end,

        addBuff = function(this,unit)
            --unit:getTeamUnitCondition():addCondition(this.consts.SPEEDBuffID,this.consts.SPEEDBuffEFID,this.consts.SPEEDBuffEF,this.consts.SPEEDBuffTime,this.consts.SPEEDBuffIcon); 
            unit:getTeamUnitCondition():addCondition(this.consts.DEFBuffID,
                                                     this.consts.DEFBuffEFID,
                                                     this.consts.DEFBuffEF,
                                                     this.consts.DEFBuffTime,
                                                     this.consts.DEFBuffIcon); 
            this.barrier = unit:addOrbitSystem("barrier",0);
            this.barrier:takeAnimation(0,"barrier",true);
            return 1;
        end,

        addSP = function (this,unit)
            
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
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "addBuff" then return this.addBuff(this,unit) end
            return 1;
        end,


        --version1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
            -- if this.isRage then
            --     value = 0;
            -- end
            return value;
        end,

        takeBreake = function (this,unit)
            
            if this.barrier ~= nil then
                this.barrier:takeAnimation(0,"none",false);
                this.barrier = nil;
                local buff = unit:getTeamUnitCondition():findConditionWithID(this.consts.DEFBuffID);
                if buff ~= nil then
                    unit:getTeamUnitCondition():removeCondition(buff);
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
            if this.barrier ~= nil then
                local xb = unit:getSkeleton():getBoneWorldPositionX("MAIN");
                local yb = unit:getSkeleton():getBoneWorldPositionY("MAIN") - 60;
                local sy = unit:getSkeleton():getPositionY();
                this.barrier:setPosition(unit:getPositionX()-xb,unit:getPositionY()+yb+sy);
            end
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            -- if this.isSkill2 then
            --     value = 9999;
            -- end
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        --version1.0
        start = function (this , unit)
            unit:setSPGainValue(0);
            
            unit:setItemSkill(0,100071199);


            return 1;
        end,

        excuteAction = function (this , unit)
            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if not this.isRage and hpParcent <  this.consts.rageHPParcent then
                unit:takeAnimation(0,"guard",false);
                unit:takeAnimationEffect(0,"guard",false);
                this.isRage = true;
                unit:setBreakPoint(unit:getBreakPoint()+2000);
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
            local isHost = this.utill.isHost();
            if isHost then
                if this.isAttackChecker == false then
                    this.isAttackChecker = true;
                    return this.takeAttackBranch(this,unit,index);
                end
                this.isAttackChecker = false;
            end
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

