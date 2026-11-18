function new(id)
    print("100655512 new ");
    local instance = {
        MESSAGE_COLOR = summoner.Color.magenta,
        consts = {
            doomTimer = 20,
            doomThreshold = 2000
        },
        gameUnit = nil,
        doomFlag = false,
        doomUpdateTimer = 0,
        doomUnits = {},
        alsheFlag = false,
        --共通変数
        param = {
          version = 1.2
          ,isUpdate = 0
        },
        messages = summoner.Text:fetchByEnemyID(4000243),

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

        --versiton1.2
        endWave = function (this , unit , waveNum)
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            if megast.Battle:getInstance():getBattleState() == kBattleState_active then
                this.countDown(this,deltatime);
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
            local sub = unit:addSubSkeleton("100655512_Reaper",-3);
            unit:takeAnimation(0,"first",true);
            this.gameUnit = unit;
            unit:addSP(100);
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
            -- if index == 2 then
            --     this:doomAll();
            -- end
            return 1;
        end,

        takeDamage = function (this , unit)
            return 1;
        end,

        dead = function (this , unit)
            -- -- summoner.Utility.messageByEnemy(this.messages.mess2,5,this.MESSAGE_COLOR);
            -- for i,v in pairs(this.doomUnits) do
            --     this.removeDoomCondition(this,v.index);   
            -- end
            return 1;
        end,

            ---------------------------------------------------------------------------------------------------------
    --死の宣告周り
        choiceDoomTarget = function(this)
            local target = this.findLiveUnitAtRandom(this);
            if target ~= nil then
                this.doom(this,target:getIndex());
                megast.Battle:getInstance():sendEventToLua(this.thisID,2,target:getIndex());
            end
        end,

        findLiveUnitAtRandom = function(this)
            local live = {};
            for i = 0,4 do
                local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
                if uni ~= nil then
                    if summoner.Utility.getUnitHealthRate(uni) > 0 then
                        table.insert(live,uni);                   
                    end
                end
            end
            if table.maxn(live) > 0 then                          
                local hit = LuaUtilities.rand(table.maxn(live));
                return live[hit + 1];
            else
                print("即死対象なし");
                return nil;
            end
        end,

        doom = function(this,targetIndex)
            table.insert(this.doomUnits,this.createDoomTaegetTable(this,targetIndex));
        end,

        doomAll = function (this)
            summoner.Utility.messageByEnemy(this.messages.mess1,5,this.MESSAGE_COLOR);
            for i = 0,4 do
                local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
                if uni ~= nil then
                    uni:setHP(uni:getHP() - uni:getCalcHPMAX()/3);
                    if summoner.Utility.getUnitHealthRate(uni) > 0 then
                        table.insert(this.doomUnits,this.createDoomTaegetTable(this,uni:getIndex()));                   
                    end
                end
            end
        end,

        getHPFromIndex = function(index)
            local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
            if uni ~= nil then
                return uni:getHP();
            end
            return 0;
        end,

        createDoomTaegetTable = function(this,unitIndex)
            local hp = this.getHPFromIndex(unitIndex);
            local unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(unitIndex);
            unit:getTeamUnitCondition():addCondition(50006,0,1,99999,181);
            local _orbit = this.gameUnit:addOrbitSystemWithFile("deathCountDown","0");
            _orbit:getSkeleton():setScaleX(-1);
            _orbit:takeAnimation(0,"none",true);
            _orbit:takeAnimation(1,"none2",true);
            _orbit:takeAnimation(2,"auraIn",true);
            _orbit:setZOrder(10011);
            local structure = {
                index = unitIndex,
                time = this.consts.doomTimer,
                beforeHP = hp,
                orbit = _orbit,
                healPoint = 0,
                isLoopAnimation = false,
                doomSucsess = false
            }
            return structure;
        end,

        countDown = function(this,deltaTime)
            this.doomUpdateTimer = this.doomUpdateTimer + deltaTime;
            if this.doomUpdateTimer < 0.1 then
                return;
            end
            for i,v in pairs(this.doomUnits) do
                if not v.doomSucsess then
                    v.time = v.time - this.doomUpdateTimer;
                    local hp = this.getHPFromIndex(v.index);

                    if hp <= 0 then
                        this.removeDoomCondition(this,v.index);
                        this.auraVanish(this,i);
                        return;
                    else
                        v.beforeHP = hp;
                        this.numbersControll(this,v);
                    end

                    if v.time <= 10 and not this.alsheFlag then
                        this.alsheFlag = true;
                        this.callAlsheSkill(this.gameUnit);
                    end

                    if v.time <= 0 then
                        this.doomSucsess = true;
                        this.excuteDoom(this,v.index);
                        this.removeDoomUnit(this,i);
                        return;
                    end
          
                end
                
            end
            this.doomUpdateTimer = 0;
        end,

        excuteDoom = function(this,index)
            local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
            if uni ~= nil then
                uni:setHP(0);
            end
        end,

        removeDoomUnit = function(this,index)
  
            this.doomUnits[index].orbit:takeAnimation(0,"auraOut",false);
            this.doomUnits[index].orbit = nil;
            table.remove(this.doomUnits,index);
        end,

        auraVanish = function(this,index)
            this.doomUnits[index].orbit:takeAnimation(0,"auraRelease",false);
            this.doomUnits[index].orbit = nil;
            table.remove(this.doomUnits,index);
        end,

        numbersControll = function(this,targetTable)
            local unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(targetTable.index);
            if unit == nil then
                return;
            end
            local xpos = unit:getAnimationPositionX()+20 < 400 and unit:getAnimationPositionX() or 400;

            targetTable.orbit:setPosition(xpos,unit:getAnimationPositionY()+70);
            if targetTable.time > this.consts.doomTimer - 0.5 then
                return;
            end
            if not targetTable.isLoopAnimation then
                targetTable.isLoopAnimation = true;
                targetTable.orbit:takeAnimation(2,"auraLoop",true);
            end
            targetTable.orbit:takeAnimation(0,this.intToAnimationNameOne(targetTable.time),true);
            targetTable.orbit:takeAnimation(1,this.intToAnimationNameTen(targetTable.time),true);            
        end,

        intToAnimationNameOne = function(int,unit)
            local temp = math.floor(int%10);
            if temp == 0 then
                return "0";
            end
            return ""..temp;
        end,

        intToAnimationNameTen = function(int)
            local temp = math.floor(int/10);
            return ""..temp.."0";
        end,

        callAlsheSkill = function(unit)
            for i=0,7 do
                local target = unit:getTeam():getTeamUnit(i);
                if target ~= nil and target ~= unit and target:getBaseID3() == 173 then
                    target:callLuaMethod("forceSkill",0.2);
                    return true;
                end
            end
            return false;
        end,

        removeDoomCondition = function(this,index)
            local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
            if uni ~= nil then
                local cond = uni:getTeamUnitCondition():findConditionWithID(50006);
                if cond ~= nil then
                    uni:getTeamUnitCondition():removeCondition(cond);
                end
            end
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

