--kof マイ
function new(id)
    print("instantiate 599980000");
    local instance = {
        uniqueID = id,
        attackChecker = false,
        skillChecker = false,
        myself = nil,
        spValue = 20,
        

        --通常時の行動重み　合計１００じゃなくても正規化されます

        weightsTooNear = {
            {key = 12,value = 20}
        },

        weightsNear = {
            {key = 1,value = 20},
            {key = 2,value = 20},
            {key = 3,value = 20},
            {key = 4,value = 20},
            {key = 5,value = 20},
            {key = 6,value = 20},
            {key = 7,value = 20},
            {key = 8,value = 20},
            {key = 9,value = 20},
            {key = 12,value = 180}
        },

        weightsMiddle = {
            {key = 1,value = 20},
            {key = 3,value = 20},
            {key = 4,value = 20},
            {key = 8,value = 20},
            {key = 9,value = 20},
            {key = 11,value = 20}
        },

        weightsFar = {
            {key = 10,value = 20}
        },

        weightMinusPosition = {
            {key = 7,value = 20},
            {key = 8,value = 20}
        },


        --スキルの行動重み　合計１００じゃなくても正規化されます
        weightsSkill = {
            {key = 1,value = 30},
            {key = 2,value = 30}
        },

        consts = {
            tooNear = 50,
            near = 200,
            middle = 400,
            minusPosBorder = -150
        },

        colors = {
            red = {r = 255,g = 0,b = 28},
            yellow = {r = 220,g = 255,b = 0},
            green = {r = 50,g = 255,b = 0},
            cyan = {r = 0,g = 255,b = 255},
            magenta = {r = 255,g = 0,b = 255},
            white = {r = 255,g = 255,b = 255}
        },

        messages = {
            mess1 = "enemyInfo用メッセージ",
        },


        initialize = function (this,unit)
            this.myself = unit;
            unit:setSPGainValue(0);
            this.spValue = 20;
        end,


        attackBranch = function (this,unit)
            local attackTable = this.utill.randomPickItem(this,this.weightsNear);

            local target = unit:getTargetUnit();

            if target ~= nil then
                local targetDistance = this.getTargetDistance(this,unit,target);
                if targetDistance > this.consts.middle then
                    attackTable = this.utill.randomPickItem(this,this.weightsFar);
                elseif targetDistance > this.consts.near then
                    attackTable = this.utill.randomPickItem(this,this.weightsMiddle);
                elseif targetDistance > this.consts.tooNear then
                    attackTable = this.utill.randomPickItem(this,this.weightsNear);
                else
                    attackTable = this.utill.randomPickItem(this,this.weightsTooNear);
                end
            end

            

            if unit:getPositionX() < this.consts.minusPosBorder then
                attackTable = this.utill.randomPickItem(this,this.weightMinusPosition)
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
            elseif index == 6 then
                unit:setActiveSkill(6);
            elseif index == 7 then
                unit:setActiveSkill(7);
            elseif index == 8 then
                unit:setActiveSkill(8);
            elseif index == 9 then
                unit:setActiveSkill(9);
            end
        end,

        skillActiveSkillSetter = function (this,unit,index)
            if index == 1 then
                unit:setActiveSkill(10);
            elseif index == 2 then
                unit:setActiveSkill(11);
            end
        end,

        moveEnd = function(this,unit)
            if this.utill.isHost() then
                unit.m_attackTimer = 0;
            end
            return 1;
        end,

        getTargetDistance = function(this,unit,target)
            return target:getPositionX() - unit:getPositionX();
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
            
            return 1;
        end,

        receive2 = function (this , intparam)
            
            return 1;
        end,


        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "moveEnd" then return this.moveEnd(this,unit) end
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
            unit:setDefaultPosition(-380,0);
  	        BattleControl:get():playBGM("KOF003_FAIRY");
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
            this.initialize(this,unit);
            --BGMをとめる
  	        BattleControl:get():playBGM("BGM_SOUNDLESS");
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
            if this.utill.isHost() then
                unit:takeAttack(1);
            end
            return 0;
        end,

        takeAttack = function (this , unit , index)

            if this.utill.isHost() and not this.attackChecker then
                this.attackChecker = true;
                return this.attackBranch(this,unit);
            end
            this.attackChecker = false;


            this.attackActiveSkillSetter(this,unit,index)
            return 1;
        end,

        takeSkill = function (this,unit,index)
            

            if this.utill.isHost() and not this.skillChecker then
                this.skillChecker = true;
                return this.skillBranch(this,unit);
            end
            this.skillChecker = false;

            unit:setBurstState(kBurstState_active);
            this.skillActiveSkillSetter(this,unit,index);
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

