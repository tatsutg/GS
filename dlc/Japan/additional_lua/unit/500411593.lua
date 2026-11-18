--@additionalEnemy,500411050,500411050,500411050,500411050,500411050
function new(id)
    print("10000 new ");
    local instance = {
        isStop = false,
        allUnits = {},
        coolTimes = {},
        coolTimeMemory = {},
        summonIDs = {500411050,500411050,500411050,500411050,500411050},
        summonUnits = {},
        summonCounter = 1,
        attackChecker = false,
        skillChecker = false,

        summon = function(this,unit)

            if this.checkSummonUnitsLive(this,unit) then
                return 0;
            end

            if this.isStop then
                this.isStop = false;
                megast.Battle:getInstance():pauseUnit(0.001);
            end

            for i = 0,1 do
                local gaul = unit:getTeam():addUnit(this.summonCounter,this.summonIDs[this.summonCounter]);
                -- if this.summonCounter > 5 then
                --     this.summonCounter = 0;
                -- end
                this.summonCounter = this.summonCounter + 1;
                
                print(gaul);
                if gaul == nil then
                else
                    print("召喚");
                    table.insert(this.summonUnits,gaul);
                    -- gaul:setBurstPoint(100);
                end
            end

            return 1;
        end,


        theWorld = function (this,unit)

            this.isStop = true;
            for i = 0,6 do
                local uni = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
                if uni ~= nil then
                    print("target is not nil");
                    table.insert(this.allUnits,uni);
                    uni:takeGrayScale(0);
                end
                local partyUni =  megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i);
                if partyUni ~= nil and partyUni ~= unit then
                    print("target is not nil");
                    table.insert(this.allUnits,partyUni);
                    partyUni:takeGrayScale(0);
                end
            end
            megast.Battle:getInstance():pauseUnit(3);
            megast.Battle:getInstance():setBattleState(kBattleState_menu);  --バトルステータスを停止状態にする
            unit:resumeUnit();
            return 1;
        end,
        worldEnd = function (this,unit)

            for i = 1,table.maxn(this.allUnits) do
                local uni = this.allUnits[i];
                if uni ~= nil then
                    uni:takeGrayScale(1);
                end
            end
            this.allUnits = {};
            megast.Battle:getInstance():pauseUnit(0.001);
            this.isStop = false;
            return 1;
        end,

        move = function (this,unit)
            for i = 1,table.maxn(this.allUnits) do
                local uni = this.allUnits[i];
                if uni ~= nil and uni:getisPlayer() ~= unit:getisPlayer() then
                    uni:getSkeleton():setPosition(0,uni:getPositionY() + 300);
                    uni:setPosition(unit:getPositionX() + LuaUtilities.rand(0,350) *-1 - 250,uni:getPositionY());
                end
            end
            return 1;
        end,

        onDestroy = function (this,self)
            local  atari = 0;
             for i = 1,table.maxn(this.summonUnits) do
         
                if this.summonUnits[i] == self then
                    atari = i
                end

            end
            if atari ~= 0 then
                table.remove(this.summonUnits,atari);
            end
            return 1;
        end,

        checkSummonUnitsLive = function(this,unit)
            for i=1,table.maxn(this.summonUnits) do
                if this.summonUnits[i] == nil or this.summonUnits[i]:getHP() <= 0 then
                    this.onDestroy(this,this.summonUnits[i]);
                end
            end
            if table.maxn(this.summonUnits) <= 0 then
                return false;
            end
            return true;
        end,

        addSP = function (this,unit)
            print("めりあ　addSP");
            unit:addSP(20);
            return 1;
        end,

        --共通変数
        param = {
          version = 1.2
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
            print("run Script めりあ");
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "theWorld" then return this.theWorld(this,unit) end
            if str == "worldEnd" then return this.worldEnd(this,unit) end
            if str == "move" then return this.move(this,unit) end
            if str == "summon" then return this.summon(this,unit) end
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
            unit:setSPGainValue(0);
            table.insert(this.coolTimeMemory,os.time() -15);
            table.insert(this.coolTimes,15);
            this.hpMarkers = {
                {
                    HP = 70,isUsed = false,MARKER = unit:addNumHpMarker(0.7)
                },
                {
                    HP = 30,isUsed = false,MARKER = unit:addNumHpMarker(0.3)
                }
            }
            return 1;
        end,

        excuteAction = function (this , unit)
            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if hpParcent <= 70 and this.summonCounter < 3 then
                
                unit:takeAttack(5);
                megast.Battle:getInstance():pauseUnit(3);
                unit:resumeUnit();
                this.isStop = true;
                return 0;
            elseif hpParcent <= 30 and this.summonCounter < 5 then
                unit:takeAttack(5);
                megast.Battle:getInstance():pauseUnit(3);
                unit:resumeUnit();
                this.isStop = true;
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
            if index == 2 then
                unit:setActiveSkill(2);
            elseif index == 3 then
                unit:setActiveSkill(3);
            elseif index == 4 then
                unit:setActiveSkill(4);
            else
                unit:setActiveSkill(5);
            end
            if not this.attackChecker and index ~= 5 then
                
                local distance = BattleUtilities.getUnitDistance(unit,unit:getTargetUnit());
                this.attackChecker = true;
                if distance < 50 then
                    unit:takeAttack(2);
                else
                    local rand = LuaUtilities.rand(0,100);
                    if rand <= 30 then
                        unit:takeAttack(2);
                    elseif rand <= 60 then
                        unit:takeAttack(3);
                    else
                        unit:takeAttack(4);
                    end
                end
                local attacktimerRand = LuaUtilities.rand(0,100);
                if attacktimerRand <= 50 then
                    unit:setAttackTimer(0);
                end
                return 0;
            end
            this.attackChecker = false;
            return 1;
        end,

        takeSkill = function (this,unit,index)
            if not this.skillChecker then
                this.skillChecker = true;
                unit:takeSkill(1);
                return 0;
            end
            unit:setActiveSkill(6);
            this.skillChecker = false;
            return 1;
        end,

        takeDamage = function (this , unit)
            if this.isStop then
                for i = 1,table.maxn(this.allUnits) do
                    local uni = this.allUnits[i];
                    if uni ~= nil then
                        uni:takeGrayScale(1);
                    end
                end
                this.allUnits = {};
                megast.Battle:getInstance():pauseUnit(0.001);
                this.isStop = false;
            end
            return 1;
        end,

        dead = function (this , unit)
            if this.isStop then
                for i = 1,table.maxn(this.allUnits) do
                    local uni = this.allUnits[i];
                    if uni ~= nil then
                        uni:takeGrayScale(1);
                    end
                end
                this.allUnits = {};
                megast.Battle:getInstance():pauseUnit(0.001);
                this.isStop = false;
            end
            
            --残存ユニットを全滅させる
            for i = 0 , 6 do
                teamunit = unit:getTeam():getTeamUnit(i);
                if teamunit ~= nil then
                    teamunit:setHP(0);
                end
            end
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

