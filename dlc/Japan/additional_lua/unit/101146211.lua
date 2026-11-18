function new(id)
    print("10000 new ");
    local instance = {

        colors = {
            red = {r = 255,g = 0,b = 28},
            yellow = {r = 220,g = 255,b = 0},
            blue = {r = 0,g = 255,b = 255},
            white = {r = 255,g = 255,b = 255}
        },
        REDUCE_BREAKPOINT_CONSTANT = 20000,
        REDUCE_BREAKPOINT_CONSTANT_CROSS = 20000,
        messages = summoner.Text:fetchByUnitID(101146211),

        searchOtherDaunt = function(this,unit)
            if this.utill.getIsBoss() and unit:getisPlayer() then
                --威圧フラグ用バフがPTに居るか確認
                local myTeam = megast.Battle:getInstance():getTeam(true);
                for i = 0,7 do
                    local myTeamUnit = myTeam:getTeamUnit(i)
                    if myTeamUnit ~= nil then
                        local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(1040499);
                        if buff ~= nil then
                            return 1
                        else
                            myTeamUnit:getTeamUnitCondition():addCondition(1040499,0,0,999999,0)
                        end
                    end
                end

                this.executeEffect(this,unit);
            end
        end,

        executeEffect = function(this,unit)
            local boss = megast.Battle:getInstance():getTeam(false):getBoss();
            if megast.Battle:getInstance():isRaid() then
            	megast.Battle:getInstance():recAddBreakPoint(unit, boss, boss:getBreakPoint() - (boss:getBreakPoint() - this.REDUCE_BREAKPOINT_CONSTANT));
                boss:setBreakPoint(boss:getBreakPoint() - this.REDUCE_BREAKPOINT_CONSTANT);
                RaidControl:get():addBreakPool(this.REDUCE_BREAKPOINT_CONSTANT);
            elseif megast.Battle:getInstance():isCrossBattle() then
            	megast.Battle:getInstance():recAddBreakPoint(unit, boss, boss:getBreakPoint() - (boss:getBreakPoint() - this.REDUCE_BREAKPOINT_CONSTANT_CROSS));
                boss:setBreakPoint(boss:getBreakPoint() - this.REDUCE_BREAKPOINT_CONSTANT_CROSS);
            else
            	megast.Battle:getInstance():recAddBreakPoint(unit, boss, boss:getBreakPoint() - (boss:getBreakPoint()/2));
                boss:setBreakPoint(boss:getBreakPoint()/2);
            end
            this.utill.showMessage(this.messages.mess1,this.colors.blue,5,0,true);
        end,

        utill = {

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

            getIsBoss = function()
                local boss = megast.Battle:getInstance():getTeam(false):getBoss();
                if boss == nil then
                    return false;
                end
                return boss:getSize() == 3;
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
            end
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
            this.checkDauntBuffFlg(this,unit);
            return 1;
        end,

        checkDauntBuffFlg = function (this , unit , waveNum)
            --威圧フラグ用バフがPTに居るか確認
            local myTeam = megast.Battle:getInstance():getTeam(true);
            for i = 0,7 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(1040499);
                    if buff ~= nil then
                        myTeamUnit:getTeamUnitCondition():removeCondition(buff);
                    end
                end
            end
        end,

        startWave = function (this , unit , waveNum)
            this.searchOtherDaunt(this,unit);
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
            return 1;
        end,

        excuteAction = function (this , unit)
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

