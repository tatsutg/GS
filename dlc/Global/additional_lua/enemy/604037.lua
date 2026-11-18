function new(id)
    print("10000 new ");
    local instance = {
        skillChecker = false,
        attackChecker = false,
        skillExecFlag = false,
        myself = nil,
        isRage = false,

        buffArgs1 = {
            id = 604037,
            efID = 10,
            value = 10,
            duration = 20,
            icon = 36
        },

        buffArgs2 = {
            id = 6040372,
            efID = 28,
            value = 20,
            duration = 999999,
            icon = 7
        },

        buffArgs3 = {
            id = 6040373,
            efID = 21,
            value = -50,
            duration = 999999,
            icon = 5,
            animation = 50009
        },

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
            this.skillChecker = true;
            unit:takeSkill(1);
            unit:setBurstPoint(0);
            return 1;
        end,

        chargeEnd2 = function (this,unit)
            this.attackChecker = true;
            unit:takeAttack(4);
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

        getRage = function (this,unit)
            this.isRage = true;
            unit:setAttackDelay(0);
            unit:getTeamUnitCondition():addCondition(this.buffArgs2.id,this.buffArgs2.efID,this.buffArgs2.value,this.buffArgs2.duration,this.buffArgs2.icon);
            unit:getTeamUnitCondition():addCondition(this.buffArgs3.id,this.buffArgs3.efID,this.buffArgs3.value,this.buffArgs3.duration,this.buffArgs3.icon,this.buffArgs3.animation);
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
          version = 1.1
          ,isUpdate = 0
        },
        thisid = id,

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            this.skillExecFlag = true;
            return 1;
        end,
        receive2 = function (this , intparam)
            this.charge(this);
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
            for _,marker in pairs(this.hpMarkers) do
                local hpPercent = 100 * unit:getHP()/unit:getCalcHPMAX();
                if not marker.isUsed and hpPercent < marker.HP then
                    marker.isUsed = true
                    unit:removeHpMarker(marker.MARKER)
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
            this.hpMarkers = {
                {
                    HP = 50,isUsed = false,MARKER = unit:addNumHpMarker(0.5)
                }
            }
            this.myself = unit;
            
            unit:setSPGainValue(0);
            return 1;
        end,

        excuteAction = function (this , unit)
            if unit:getHP() <= unit:getCalcHPMAX()/2 and not this.isRage then
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
            if index == 1 then
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            elseif index == 3 then
                unit:setActiveSkill(3);
            elseif index == 4 then
                unit:setActiveSkill(4);
                unit:getTeamUnitCondition():addCondition(this.buffArgs1.id,this.buffArgs1.efID,this.buffArgs1.value,this.buffArgs1.duration,this.buffArgs1.icon);
                
                summoner.Utility.messageByEnemy(summoner.Text:fetchByEnemyID(604037).mess1,5,summoner.Color.magenta,36);
            end
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                local target = unit:getTargetUnit() 
                local distance = BattleUtilities.getUnitDistance(unit,target)
                print(distance);
                if distance > 400 and this.attackChecker == false then
                    this.attackChecker = true
                    unit:takeAttack(3)
                    return 0;
                elseif this.attackChecker == false then
                    print("kita");
                    this.attackChecker = true;
                    rand = LuaUtilities.rand(0,100);
                    if rand <= 25 then
                        unit:takeAttack(1);
                    elseif  rand < 25 then
                        unit:takeAttack(2);
                    elseif rand < 50 then
                        unit:takeAttack(3);
                    else
                        if unit:getTeamUnitCondition():findConditionWithID(this.buffArgs1.id) ~= nil then
                            unit:takeAttack(1);
                        else
                            unit:takeAnimation(0,"charge_short",false);
                            unit:takeAnimationEffect(0,"charge_short",false);
                        end
                    end
                    return 0;
                end
                this.attackChecker = false
            end
            return 1;
        end,

        takeSkill = function (this,unit,index)
            local buff = unit:getTeamUnitCondition():findConditionWithID(this.buffArgs1.id);
            if buff ~= nil then
                   unit:getTeamUnitCondition():removeCondition(buff); 
            end
            if index == 1 then
                unit:setActiveSkill(5);
            end
            ishost = megast.Battle:getInstance():isHost();
            if ishost then
                rand = LuaUtilities.rand(0,100);
                if not this.skillChecker then
                    unit:setBurstPoint(99);
                    local posx = unit:getPositionX();
                    
                    unit:takeAnimation(0,"charge_long",false);
                    unit:takeAnimationEffect(0,"charge_long",false);
                    megast.Battle:getInstance():sendEventToLua(this.thisid,2,1);
                    
                    return 0;
                end
            elseif not this.skillChecker then
                return 0;
            end

            this.skillChecker = false;
            return 1;
        end,

        takeDamage = function (this , unit)
            this.skillChecker = false;
            return 1;
        end,

        dead = function (this , unit)
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

