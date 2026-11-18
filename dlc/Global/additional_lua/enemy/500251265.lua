--@additionalItem,100562499
function new(id)
    print("500251265 new ");    --ボスユニット：ラグシェルム[1]
    local instance = {
        attackChecker = false,
        skillChecker = false,
        coolTimes = {},
        coolTimeMemory = {},
        isRage = false,
        isSkill2 = false,
        consts = {
            DEFBuffID = 15,
            DEFBuffEFID = 15,
            DEFBuffEF = 50,
            DEFBuffTime = 3000,
            DEFBuffIcon = 5,
            SPEEDBuffID = 28,
            SPEEDBuffEFID = 28,
            SPEEDBuffEF = 10,
            SPEEDBuffTime = 3000,
            SPEEDBuffIcon = 7,
            ATTACKBuffID = 13,
            ATTACKBuffEFID = 13,
            ATTACKBuffEF = 300,
            ATTACKBuffTime = 3000,
            ATTACKBuffIcon = 3,
            rageHPParcent = 75
        },
        barrier = nil,

        addBuff = function(this,unit)
            unit:getTeamUnitCondition():addCondition(this.consts.SPEEDBuffID,this.consts.SPEEDBuffEFID,this.consts.SPEEDBuffEF,this.consts.SPEEDBuffTime,this.consts.SPEEDBuffIcon); 
            unit:getTeamUnitCondition():addCondition(this.consts.DEFBuffID,this.consts.DEFBuffEFID,this.consts.DEFBuffEF,this.consts.DEFBuffTime,this.consts.DEFBuffIcon); 
            this.barrier = unit:addOrbitSystem("barrier",0);
            this.barrier:takeAnimation(0,"barrier",true);
            return 1;
        end,

        addSP = function (this,unit)
            if this.isRage then
                unit:addSP(20);
            end
            return 1;
        end,

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
            if this.isRage then
                value = 0;
            end
            return value;
        end,

        takeBreake = function (this,unit)
            
            if this.barrier ~= nil then
                this.barrier:takeAnimation(0,"none",false);
                this.barrier = nil;
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
                this.barrier:setPosition(unit:getPositionX()-xb,unit:getPositionY()+yb);
		 this.barrier:setZOrder(unit:getZOrder());
            end
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            if this.isSkill2 then
                -- value = 9999;
                unit:getTeamUnitCondition():addCondition(this.consts.ATTACKBuffID,this.consts.ATTACKBuffEFID,this.consts.ATTACKBuffEF,this.consts.ATTACKBuffTime,this.consts.ATTACKBuffIcon); 
            end
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            if this.isRage then
                value = 10;
            end
            return value;
        end,

        --version1.0
        start = function (this , unit)
            unit:setSPGainValue(0);
            --自分から見て敵側のユニットを全部取得(ユニットは最大でも６体までなので６回)
            
            unit:setItemSkill(0,100562499);
            table.insert(this.coolTimeMemory,os.time() -15);
            table.insert(this.coolTimeMemory,os.time() -15);
            table.insert(this.coolTimes,15);
            table.insert(this.coolTimes,15);


            return 1;
        end,

        excuteAction = function (this , unit)
            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if not this.isRage and hpParcent < this.consts.rageHPParcent then
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
            if index == 1 then
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            else
                unit:setActiveSkill(3);
            end
            if not this.attackChecker then


                local itemUseRand = math.random(100);
                if itemUseRand < 50 then
                    local itemIndexes = {};
                    for i = 1,table.maxn(this.coolTimeMemory)do
                        if this.coolTimeMemory[i] - os.time() <= -this.coolTimes[i] then
                            
                            --attack3はHPが75%を切って怒っている時だけ
                            if i == 2 then
                                if this.isRage then
                                    table.insert(itemIndexes,i);
                                end
                            else
                                table.insert(itemIndexes,i);
                            end
                        end
                    end

                    if table.maxn(itemIndexes) > 0 then
                        local randForItem = math.random(table.maxn(itemIndexes));
                            if itemIndexes[randForItem] == 1 then
                                unit:takeItemSkill(0);
                                this.attackChecker = false;
                            else
                                unit:takeAttack(3);
                            end
                            this.coolTimeMemory[itemIndexes[randForItem]] = os.time();
                            
                        return 0;
                    end
                end
                
                local distance = BattleUtilities.getUnitDistance(unit,unit:getTargetUnit());
                this.attackChecker = true;
                if distance < 50 then
                    unit:takeAttack(1);
                elseif distance > 300 then
                    unit:takeAttack(2);
                else
                    local rand = math.random(100);
                    if rand <= 30 then
                        unit:takeAttack(1);
                    else
                        unit:takeAttack(2);
                    end
                end
                local attacktimerRand = math.random(100);
                if attacktimerRand <= 50 then
                    unit:setAttackTimer(0);
                end
                return 0;
            end
            this.attackChecker = false;
            return 1;
        end,

        takeSkill = function (this,unit,index)
            this.isSkill2 = true;
            if index == 1 then
                unit:setActiveSkill(4);
            else
                unit:setActiveSkill(5);
            end

            if not this.skillChecker then
                this.skillChecker = true;
                unit:takeSkillWithCutin(2);
                return 0;
            end

            this.skillChecker = false;
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

