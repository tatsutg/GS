function new(id)
    print("101074511 new ");    --メリア進化前
    local instance = {
        uniqueID = id,
        myself = nil,
        isStop = false,
        allUnits = {},
        coolTimer = 60,
        coolTimeDefalut = 60,
        theWorld = function (this,unit)
            for i = 0,7 do
                local teamUnit = unit:getTeam():getTeamUnit(i);
                if teamUnit ~= nil then
                    teamUnit:playSummary(summoner.Text:fetchByUnitID(101074511).text1,true);
                    local cond = teamUnit:getTeamUnitCondition():findConditionWithGroupID(3097);
                    if cond ~= nil and cond:getPriority() <= 50 then
                        teamUnit:getTeamUnitCondition():removeCondition(cond);
                        local newCond = teamUnit:getTeamUnitCondition():addCondition(3097,11,50,4,36);
                        newCond:setGroupID(3097);
                    elseif cond == nil then
                        local newCond = teamUnit:getTeamUnitCondition():addCondition(3097,11,50,4,36);
                        newCond:setGroupID(3097);
                    end
             
                end
            end
          
            this.isStop = true;
            
            return 1;
        end,
        worldEnd = function (this,unit)
            for i = 1,table.maxn(this.allUnits) do
                local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(this.allUnits[i],true);
                if uni ~= nil then
                    uni:takeGrayScale(0.99);
                end
            end
            this.allUnits = {};

            this.isStop = false;
            return 1;
        end,

        move = function (this,unit)
            for i = 1,table.maxn(this.allUnits) do
                local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(this.allUnits[i],true);
                if uni ~= nil and uni:getisPlayer() ~= unit:getisPlayer() then
                    uni:getSkeleton():setPosition(0,uni:getPositionY() + 300);
                    uni:setPosition(unit:getPositionX() + math.random(350)*-1 - 250,uni:getPositionY());
                end
            end
            return 1;
        end,

        isControllTarget = function(this,unit)
            if unit:isMyunit() then
                return true;
            end
            if not unit:getisPlayer() then
                return megast.Battle:getInstance():isHost();
            end

        end,

        --共通変数
        param = {
          version = 1.2
          ,isUpdate = 0
        },

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            this.myself:playSummary(summoner.Text:fetchByUnitID(101074511).text2,true);
            this.myself:getTeamUnitCondition():addCondition(-101074511,98,2000,10,24,1);
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "theWorld" then return this.theWorld(this,unit) end
            if str == "worldEnd" then return this.worldEnd(this,unit) end
            if str == "move" then return this.move(this,unit) end
            return 1;
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            this.allUnits = {};
            this.isStop = false;
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            this.coolTimer = this.coolTimer + deltatime;
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            if this.isStop and enemy:getParentTeamUnit() == nil then
                enemy:takeGrayScale(0.01);
                table.insert(this.allUnits,enemy:getIndex());
            end
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if this.isControllTarget(this,unit) then
                if hpParcent <= 40 and this.coolTimer >= this.coolTimeDefalut then
                    this.coolTimer = 0;
                    unit:playSummary(summoner.Text:fetchByUnitID(101074511).text2,true);
                    unit:getTeamUnitCondition():addCondition(-101075511,98,2000,10,24,1);
                    megast.Battle:getInstance():sendEventToLua(this.uniqueID,1,1);
                end
            end
            return value;
        end,

        --version1.0
        start = function (this , unit)
            this.myself = unit;
            if this.isStop then
                unit:setSPGainValue(0);
            end
            return 1;
        end,

        excuteAction = function (this , unit)
            this.allUnits = {};
            this.isStop = false;
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
            if this.isStop then
                for i = 1,table.maxn(this.allUnits) do
                local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(this.allUnits[i],true);
                    if uni ~= nil then
                        uni:takeGrayScale(0.99);
                    end
                end
                this.allUnits = {};
                this.isStop = false;
            end
            return 1;
        end,

        dead = function (this , unit)
            if this.isStop then
                for i = 1,table.maxn(this.allUnits) do
                local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(this.allUnits[i],true);
                    if uni ~= nil then
                        uni:takeGrayScale(0.99);
                    end
                end
                this.allUnits = {};
                this.isStop = false;
            end
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

