function new(id)
    print("10000 new ");
    local instance = {
        uniqueID = id,
        myself = nil,
        --アタックチェック
        isAttackChecker = false,

        --スキルチェック
        isSkillChecker = false,
        forceSkillIndex = 0,


        --通常攻撃の重み　合計１００じゃなくても正規化されます
        weightsAttack = {
            {key = 1,value = 40},
            {key = 2,value = 40},
            {key = 4,value = 20}
        },

        weightsRage = {
            {key = 2,value = 33},
            {key = 3,value = 33},
            {key = 4,value = 33}
        },

        --奥義の重み　合計１００じゃなくても正規化されます
        weightsSkill = {
            {key = 1,value = 40}
        },

        consts = {
            rageHP = 50
        },

        isGlabCheck = false,
        isGlab = false,
        glabTrgetIndex = nil,
        hitList = {},

        isRage = false,

        beforeAttackNum = 0,




 
        glabPositionMemory = {
            position = nil
        },

        messages = summoner.Text:fetchByEnemyID(4000847),

        colors = {
            red = {r = 255,g = 0,b = 28},
            yellow = {r = 220,g = 255,b = 0},
            green = {r = 50,g = 255,b = 0},
            blue = {r = 0,g = 255,b = 255},
            white = {r = 255,g = 255,b = 255},
            magenta = {r = 255,g = 0,b = 255}
        },


        --アタック分岐
        takeAttackBranch = function(this,unit,index)
            if this.utill.getHPPercent(unit) < this.consts.rageHP and not this.isRage then
                unit:takeAttack(5);
                this.getRage(this,unit);
                this.utill.sendEvent(this,3,0);
                return 0;
            end

            local attackTable = this.utill.randomPickItem(this,this.weightsAttack);

            if this.isRage then
                attackTable = this.utill.randomPickItem(this,this.weightsRage);
            end

            if this.beforeAttackNum == attackTable.key then
                return this.takeAttackBranch(this,unit,index);
            end
            this.beforeAttackNum = attackTable.key;
            unit:takeAttack(attackTable.key);
    
            return 0;
        end,

        takeSkillBranch = function(this,unit,index)
            
            local skillTable = this.utill.randomPickItem(this,this.weightsSkill);


            if this.forceSkillIndex ~= 0 then
                forceSkillIndex = 0;
                unit:takeSkill(this.forceSkillIndex);
            else
                unit:takeSkill(skillTable.key);
            end
            
            
            
            return 0;
        end,

        glabCheckStart = function (this,unit)
            this.isGlabCheck = true;
            this.hitList = {};
            return 1;
        end,

        hitCheck = function (this,unit,index)
            for i=1,table.maxn(this.hitList) do
                if index == this.hitList[i] then
                    return 0;
                end
            end
            table.insert(this.hitList,index);
        end,

        tryGlab = function (this,unit)
            this.isGlabCheck = false;
            if not this.utill.isHost() then
                return 1;
            end

            local distance = 9999;--とりあえず遠くから始めて近いもので上書きしていく
            local targetIndex = nil;

            for i=1,table.maxn(this.hitList) do
                local target = this.utill.getTeamUnitByIndex(this.hitList[i],true);
                if target ~= nil then
                    local tempDistance = target:getAnimationPositionX() - unit:getAnimationPositionX();

                    if tempDistance < distance then
                        targetIndex = this.hitList[i];
                    end
                end
            end


            if targetIndex ~= nil then
                this.utill.sendEvent(this,1,targetIndex);
                this.executeGlab(this,unit,targetIndex);
            end
            
            return 1;
        end,

        --ゲストはここから
        executeGlab = function (this,unit,index)
            this.glabTrgetIndex = index;
            local glabTrget = this.utill.getTeamUnitByIndex(index,true);
            if glabTrget == nil then
                return 1;
            end
            unit:getTeamUnitCondition():addCondition(-11,113,500,2000,0);
            this.isGlab = true;

            this.glabPositionMemory.position = this.utill.Vector2.new(glabTrget:getAnimationPositionX(),glabTrget:getAnimationPositionY());

            glabTrget:getTeamUnitCondition():addCondition(-10,89,1,14,0);
            return 1;
        end,

        glabControll = function (this,unit,deltatime)
            if this.glabTrgetIndex == nil then
                return 0;
            end
            local glabTrget = this.utill.getTeamUnitByIndex(this.glabTrgetIndex,true);
            if glabTrget ~= nil then
                local x = unit:getSkeleton():getBoneWorldPositionX("R_hand_attack4") + unit:getPositionX();
                local y = unit:getSkeleton():getBoneWorldPositionY("R_hand_attack4") + unit:getPositionY();
                local targetVector = this.utill.Vector2.new(x - this.glabPositionMemory.position.x,y - this.glabPositionMemory.position.y);
                local normalized = this.utill.Vector2.Normalize(this,targetVector);
                local speed = 300;
                -- if normalized.x * speed * deltatime <  targetVector.x then
                --     normalized.x = targetVector.x/deltatime;
                -- end
                -- if normalized.y * speed * deltatime <  targetVector.y then
                --     normalized.y = 0;
                -- end

               
                this.glabPositionMemory.position.x = this.glabPositionMemory.position.x + normalized.x * speed * deltatime;
                this.glabPositionMemory.position.y = this.glabPositionMemory.position.y + normalized.y * speed * deltatime;

                -- glabTrget:setPosition(this.glabPositionMemory.position.x - glabTrget:getSkeleton():getBoneWorldPositionX("MAIN"),glabTrget:getPositionY());
                -- glabTrget:getSkeleton():setPosition(0,this.glabPositionMemory.position.y - glabTrget:getPositionY() - glabTrget:getSkeleton():getBoneWorldPositionY("MAIN"));
                glabTrget:setPosition(x - glabTrget:getSkeleton():getBoneWorldPositionX("MAIN"),glabTrget:getPositionY());
                glabTrget:getSkeleton():setPosition(0,y - glabTrget:getPositionY() - glabTrget:getSkeleton():getBoneWorldPositionY("MAIN"));
            end
        end,

        glabEnd = function (this,unit)
            if not this.isGlab then
                return 1;
            end

            if this.glabTrgetIndex ~= nil then
                local glabTrget = this.utill.getTeamUnitByIndex(this.glabTrgetIndex,true);

                local hit = unit:addOrbitSystem("GrowndHit",0);
                this.myself:takeHitStop(0.5);
                -- glabTrget:takeHitStop(0.5);
                hit:setPosition(glabTrget:getPositionX(),glabTrget:getPositionY() + glabTrget:getSkeleton():getBoneWorldPositionY("MAIN"));
                hit:setTargetUnit(glabTrget);
                hit:setHitType(2);
                hit:setActiveSkill(4);

                this.utill.removeCondition(glabTrget,-10);
                this.glabTrgetIndex = nil;
            end

            this.isGlab = false;

            return 1;
        end,

        getRage = function(this,unit)
            unit:getTeamUnitCondition():addCondition(-11,28,35,2000,7,50009);
            unit:getTeamUnitCondition():addCondition(-50077,17,35,2000,26);
            unit:setAttackDelay(0);
            this.isRage = true;
            this.utill.showMessage(this.messages.mess3,this.colors.red,5,7);
        end,



        addSP = function (this , unit)
            unit:addSP(20);
            return 1;
        end,

        utill = {
            Vector2 = {
                new = function (_x,_y)
                    local vec = {
                        x = _x or 0,
                        y = _y or 0,
                    };
                    return  vec;
                end,
                magnitude = function(vec2) 
                    return math.sqrt(vec2.x * vec2.x + vec2.y * vec2.y);
                end,
                -- 正規化したベクトルを取得
                Normalize = function (this,vec2)

                    local num = this.utill.Vector2.magnitude(vec2);

                    if num > 0 then
                        return this.utill.Vector2.new(vec2.x / num, vec2.y / num);
                    end

                    return this.utill.Vector2.new(0, 0);
                end,
                distance = function(this,from,to)
                    local x = to.x - from.x;
                    local y = to.y - from.y;
                    return this.utill.Vector2.magnitude(this.utill.Vector2.new(x,y));
                end

            },

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

            getTeamUnitByIndex = function (index,isPlayerTeam)
                return megast.Battle:getInstance():getTeam(isPlayerTeam):getTeamUnit(index);
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
            this.executeGlab(this,this.myself,intparam);
            return 1;
        end,

        receive2 = function (this , intparam)
            this.myself:takeDamage();
            return 1;
        end,

        receive3 = function (this , intparam)
            this.getRage(this,this.myself);
            return 1;
        end,
        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "glabCheckStart" then return this.glabCheckStart(this,unit) end
            if str == "tryGlab" then return this.tryGlab(this,unit) end
            if str == "glabEnd" then return this.glabEnd(this,unit) end

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
            unit:addSP(unit:getNeedSP());
            this.forceSkillIndex = 1;
            this.utill.showMessage(this.messages.mess1,this.colors.red,5);
            this.utill.showMessage(this.messages.mess2,this.colors.red,5);
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            unit:setReduceHitStop(2,1);
            if this.isGlab then
                this.glabControll(this,unit,deltatime);
            end
            
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            if this.isGlabCheck then
                this.hitCheck(this,unit,enemy:getIndex());
            end
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        --version1.0
        start = function (this , unit)
            this.myself = unit;
            unit:setSPGainValue(0);
            return 1;
        end,

        excuteAction = function (this , unit)

            return 1;
        end,

        takeIdle = function (this , unit)
            if not this.isRage then
                unit:setNextAnimationName("zcloneNidle");
            end
            return 1;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
            if not this.isRage then
                unit:setNextAnimationName("zcloneNback");
            end
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
            if index == 1 then
                unit:setActiveSkill(1);
                if not this.isRage then
                    unit:setNextAnimationName("zcloneNattack1");
                end
            elseif index == 2 then
                unit:setActiveSkill(2);
                if not this.isRage then
                    unit:setNextAnimationName("zcloneNattack2");
                end
            elseif index == 3 then
                unit:setActiveSkill(3);
                if not this.isRage then
                    unit:setNextAnimationName("zcloneNattack3");
                end
            elseif index == 4 then
                unit:setActiveSkill(1);
                if not this.isRage then
                    unit:setNextAnimationName("zcloneNattack4");
                end
            elseif index == 5 then
                
                unit:setActiveSkill(5);
                
            end
            return 1;
        end,

        takeSkill = function (this,unit,index)
            local isHost = this.utill.isHost();
            if isHost then
                -- if this.weightsAttack[3].value < 90 then
                --     this.weightsAttack[3].value = this.weightsAttack[3].value + 10;
                --     this.weightsRage[3].value = this.weightsRage[3].value + 10;
                -- end
                if this.isSkillChecker == false then
                    this.isSkillChecker = true;
                    return this.takeSkillBranch(this,unit,index);
                end
                this.isSkillChecker = false;
            end
            this.isDPSCheck = false;
            if index == 1 then
                unit:setActiveSkill(6);
                if not this.isRage then
                    unit:setNextAnimationName("zcloneNskill1");
                end
            elseif index == 2 then
                unit:setActiveSkill(7);
                if not this.isRage then
                    unit:setNextAnimationName("zcloneNskill2");
                end
            end
            return 1;
        end,

        takeDamage = function (this , unit)
            if this.isGlab then
                this.glabEnd(this,unit);
            end
            
            return 1;
        end,

        dead = function (this , unit)
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

