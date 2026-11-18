function new(id)
    print("10000 new ");
    local instance = {
        myself = nil,
        uniqueID = id,
        icons = {
            151,
            152,
            153,
            154,
            160,
            120,
            121,
            122,
            123,
            124
        },

        buffCount = 0,
        damageCount = 0,
        isReset = false,

        countUp = function (this,unit)
            if this.buffCount >= 5 then
                return;
            end
            this.buffCount = this.buffCount + 1;
            unit:setParameter("189_Rebellion",""..this.buffCount);
            this.updateBuffIcon(this,unit,this.buffCount);
            this.utill.sendEvent(this,1,this.buffCount);
        end,

        resetCount = function (this,unit)
            this.buffCount = 0;
            unit:setParameter("189_Rebellion",""..this.buffCount);
            this.updateBuffIcon(this,unit,this.buffCount);
            this.utill.sendEvent(this,1,this.buffCount);
        end,

        updateBuffIcon = function (this,unit,intparam)
            if intparam == 0 then
                this.utill.removeCondition(unit,10189);
            else
                unit:getTeamUnitCondition():addCondition(10189,0,1,9999,this.icons[intparam]);
            end
        end,

        utill = {

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

            removeCondition = function (unit,buffID)
                local buff = unit:getTeamUnitCondition():findConditionWithID(buffID);
                if buff ~= nil then
                    unit:getTeamUnitCondition():removeCondition(buff);
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
            this.buffCount = intparam;
            this.myself:setParameter("189_Rebellion",""..intparam);
            this.updateBuffIcon(this,this.myself,intparam);
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addBuff" and this.buffCount > 0 then
                local buff = unit:getTeamUnitCondition():addCondition(101891,17,this.buffCount * 10,10,0);
                buff:setScriptID(58);
                this.isReset = true;
            end

            if str == "addBuff2" then
                if this.buffCount >= 5 then
                    local buff = unit:getTeamUnitCondition():addCondition(101892,17,250,30,31);
                    buff:setScriptID(58);
                    local buff2 = unit:getTeamUnitCondition():addCondition(101891,17,this.buffCount * 10,10,0);
                    buff2:setScriptID(58);
                    this.isReset = true;
                else
                    local buff2 = unit:getTeamUnitCondition():addCondition(101891,17,this.buffCount * 10,10,0);
                    buff2:setScriptID(58);
                end
            end
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
            this.damageCount = this.damageCount + value;
            if unit:isMyunit() or not unit:getisPlayer() then
                if math.floor(this.damageCount/1000) > this.buffCount then
                    this.countUp(this,unit);
                end
            end
            return value;
        end,

        --version1.0
        start = function (this , unit)
            this.myself = unit;
            unit:setParameter("189_Rebellion",""..0);
            return 1;
        end,

        excuteAction = function (this , unit)
            if this.isReset then
                this.damageCount = 0;
                this.resetCount(this,unit);
                this.utill.removeCondition(unit,101891);
                this.isReset = false;
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
            return 1;
        end,

        takeSkill = function (this,unit,index)

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