function new(id)
    print("10000 new ");
    local instance = {
        uniqueID = id,
        myself = nil,
        --アタックチェック
        isAttackChecker = false,

        --スキルチェック
        isSkillChecker = false,

        dpsCounter = 0,
        damagePar10Second = 100000,
        dpsStartHP = 0,

        --通常攻撃の重み　合計１００じゃなくても正規化されます
        weightsAttack = {
            {key = 1,value = 20},
            {key = 2,value = 20},
            {key = 3,value = 20},
            {key = 4,value = 15},
            {key = 5,value = 20}
        },

        --奥義の重み　合計１００じゃなくても正規化されます
        weightsSkill = {
            {key = 1,value = 20}
        },

        consts = {
            dpsCheckHP1 = 50,
            dpsCheckHP2 = 30,
            dpsCheckHP3 = 15,
            hateTargetRate = 1.1,
        },

        isGlab = false,
        glabTrget = nil,
        isDPSCheck = false,
        subBar = nil,

        firstDPSCheck = false,
        secondDPSCheck = false,
        thirdDPSCheck = false,

 
        glabEffect = {
            orbitSystem = nil,
            position = nil
        },

        messages = summoner.Text:fetchByEnemyID(200070069),

        colors = {
            red = {r = 255,g = 0,b = 28},
            yellow = {r = 220,g = 255,b = 0},
            green = {r = 50,g = 255,b = 0},
            blue = {r = 0,g = 255,b = 255},
            white = {r = 255,g = 255,b = 255}
        },


        --アタック分岐
        takeAttackBranch = function(this,unit,index)
            -- if this.utill.getHPPercent(unit) <= this.consts.dpsCheckHP1 and not this.firstDPSCheck then
            --     this.firstDPSCheck = true;
            --     unit:takeAttack(6);
            --     return 0;
            -- end
            -- if this.utill.getHPPercent(unit) <= this.consts.dpsCheckHP2 and not this.secondDPSCheck then
            --     this.secondDPSCheck = true;
            --     unit:takeAttack(6);
            --     return 0;
            -- end
            -- if this.utill.getHPPercent(unit) <= this.consts.dpsCheckHP3 and not this.thirdDPSCheck then
            --     this.thirdDPSCheck = true;
            --     unit:takeAttack(6);
            --     return 0;
            -- end
            local attackTable = this.utill.randomPickItem(this,this.weightsAttack);
            
            unit:takeAttack(attackTable.key);
    
            return 0;
        end,

        takeSkillBranch = function(this,unit,index)
            -- local skillTable = this.utill.randomPickItem(this,this.weightsSkill);
            if this.isDPSCheck then
                unit:takeSkill(2);
            else
                unit:takeSkill(1);
            end
            return 0;
        end,

        tryGlab = function (this,unit)
            if not this.utill.isHost() then
                return 1;
            end


            local index = unit:getHateTarget():getIndex();
            this.utill.sendEvent(this,1,index);
            this.executeGlab(this,unit,index);
            return 1;
        end,

        --ゲストはここから
        executeGlab = function (this,unit,index)
            
            this.glabTrget = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
            if this.glabTrget == nil then
                return 1;
            end
            unit:getTeamUnitCondition():addCondition(-11,113,500,2000,0);
            this.isGlab = true;
            this.glabEffect.orbitSystem = unit:addOrbitSystem("lock-on");
            this.glabEffect.orbitSystem:takeAnimation(0,"lock-on",true);
            this.glabEffect.position = this.utill.Vector2.new(this.glabTrget:getAnimationPositionX(),this.glabTrget:getAnimationPositionY());
            this.glabEffect.orbitSystem:setPosition(this.glabEffect.position.x,this.glabEffect.position.y);
            this.glabTrget:getTeamUnitCondition():addCondition(-10,89,1,14,0);
            return 1;
        end,

        glabControll = function (this,unit,deltatime)
            if this.glabTrget ~= nil then
                local x = 150 + unit:getPositionX();
                local y = 464 + unit:getPositionY();
                local targetVector = this.utill.Vector2.new(x - this.glabEffect.position.x,y - this.glabEffect.position.y);
                local normalized = this.utill.Vector2.Normalize(this,targetVector);
                local speed = 300;
                -- if normalized.x * speed * deltatime <  targetVector.x then
                --     normalized.x = targetVector.x/deltatime;
                -- end
                -- if normalized.y * speed * deltatime <  targetVector.y then
                --     normalized.y = 0;
                -- end

               
                this.glabEffect.position.x = this.glabEffect.position.x + normalized.x * speed * deltatime;
                this.glabEffect.position.y = this.glabEffect.position.y + normalized.y * speed * deltatime;
                
                this.glabEffect.orbitSystem:setPosition(this.glabEffect.position.x,this.glabEffect.position.y);
                this.glabTrget:setPosition(this.glabEffect.position.x - this.glabTrget:getSkeleton():getBoneWorldPositionX("MAIN"),this.glabTrget:getPositionY());
                this.glabTrget:getSkeleton():setPosition(0,this.glabEffect.position.y - this.glabTrget:getPositionY() - this.glabTrget:getSkeleton():getBoneWorldPositionY("MAIN"));

            end
        end,

        glabEnd = function (this,unit)
            if not this.isGlab then
                return 1;
            end
            if this.glabTrget ~= nil then
                this.utill.removeCondition(this.glabTrget,-10);
                this.glabTrget = nil;
            end

            this.utill.removeCondition(unit,-11);
            this.dpsCounter = 0;
            this.isGlab = false;

            if this.glabEffect ~= nil then
                this.glabEffect.orbitSystem:takeAnimation(0,"none",false);
                this.glabEffect.orbitSystem = nil;
            end
            return 1;
        end,

        setSP0 = function (this , unit)
        	this.isDPSCheck = true;
        	if this.utill.isHost() then
	            unit:setBurstPoint(0);
	            
	            this.dpsStartHP = unit:getHP();
	            this.utill.sendEvent(this,3,this.dpsStartHP);
	        end
            return 1;
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
        	this.dpsStartHP = intparam;
            return 1;
        end,
        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "tryGlab" then return this.tryGlab(this,unit) end
            if str == "glabEnd" then return this.glabEnd(this,unit) end
            if str == "setSP0" then return this.setSP0(this,unit) end
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
            -- this.utill.showMessage(this.messages.mess1,this.colors.red,5,14);
            -- BattleControl:get():visibleHateTarget(true);
            -- BattleControl:get():setHateTargetIcon(14);

            -- unit:setEnableHate(true);

            if this.utill:isHost() then
	            unit:updateHateTarget();
	        end

            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            if this.isGlab then
                this.glabControll(this,unit,deltatime);
            end
            if this.isDPSCheck then
            	if this.isDPSCheck then
	                this.dpsCounter = this.dpsStartHP - unit:getHP();
	                if this.dpsCounter >= this.damagePar10Second and this.utill.isHost() then
	                    this.dpsCounter = 0;
	                    unit:takeDamage();
	                    this.utill.sendEvent(this,2,0);
	                end
	            end
                local bonex = unit:getPositionX();
                local boney = unit:getPositionY() + 250;
                this.subBar:setPositionX(bonex);
                this.subBar:setPositionY(boney);
                
                this.subBar:setPercent(100 * (this.damagePar10Second - this.dpsCounter)/this.damagePar10Second);
                this.subBar:setVisible(true);
            else
                this.subBar:setVisible(false);
            end
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            -- if enemy == unit:getHateTarget() then
            --     value = value * this.consts.hateTargetRate;
            -- end
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        --version1.0
        start = function (this , unit)
            this.myself = unit;
            unit:setSPGainValue(0);
            -- unit:setAttackDelay(0);
            this.subBar =  BattleControl:get():createSubBar();
            this.subBar:setWidth(200); --バーの全体の長さを指定
            this.subBar:setHeight(13);
            this.subBar:setPercent(0); --バーの残量を0%に指定
            this.subBar:setVisible(false);
            this.subBar:setPositionX(0);
            this.subBar:setPositionY(150);
            return 1;
        end,

        excuteAction = function (this , unit)
        	if this.utill:isHost() then
	            unit:updateHateTarget();
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
            this.isDPSCheck = false;
            if index == 1 then
                unit:setActiveSkill(6);
                unit:setBurstState(kBurstState_active);
            elseif index == 2 then
                unit:setActiveSkill(7);
            end
            return 1;
        end,

        takeDamage = function (this , unit)
            if this.isGlab then
            	this.glabEnd(this,unit);
            end
            if this.isDPSCheck then
                this.isDPSCheck = false;
                this.dpsCounter = 0;
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

