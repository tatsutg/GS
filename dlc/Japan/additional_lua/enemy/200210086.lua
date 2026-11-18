--@additionalItem,101062510,101531310,101631510,100732510,101031510,101824410,103193500,101402500,103205300,103215300
--ユニットボス　大型イベント用フェンのlua

function new(id)
    print("10000 new ");
    local instance = {
        thisID = id,
        attackChecker = false,
        skillChecker = false,
        fromHost = false,
        myself = nil,
        spValue = 20,
        badStatusCureFlg = false,--フォスケラトを使用するかどうかのフラグ
        badStatusRejectFlg = false,--ラーズを使用するかどうかのフラグ
        isRage = false,
        talkCounter = 0,
        

        --通常時の行動重み　合計１００じゃなくても正規化されます
        weightsNormal = {
            {key = 1,value = 20}
        },


        --スキルの行動重み　合計１００じゃなくても正規化されます
        weightsSkill = {
            {key = 2,value = 30}
        },

        --initalの中で必要なものを判断して突っ込んでいくため宣言時は空っぽ
        weightsItemGroup1 = {
        },

        recasts = {
            group1 = 0,
            group2 = 0,
            group3 = 0,
            group4 = 0
        },


        consts = {
            group1Recast = 15,
            group2Recast = 10,
            group3Recast = 60,
            group4Recast = 40
        },

        items = {
            101062510,--0:アルマス
            101531310,--1:ドラケウスボルト
            101631510,--2:焔獄
            100732510,--3:エビルサイス
            101031510,--4:ゲルメド
            101824410,--5:フォスケラト
            103193500,--6:ラーズ             
            101402500,--7:キュクノス
            103205300,--8:クリューゼの懐中時計   
            103215300 --9:魔獣召喚             
        },

        --行動不能以外の状態異常
        badStatusIDs = {
            90,--毒
            92,--沈黙
            93,--暗闇
            97,--燃焼
            131--ナイトメア
        },

        --行動不能系状態異常
        incapacitatedIDs = {
            91,--麻痺
            96--氷結
        },

        --ルゥの行動状態
        ruState = {
            idle = 0,
            front = 1,
            back = 2,
            cast = 3,
            outside = 4
        },

        --オービットシステムとして出すルゥ
        ru = {
            orbit = nil,
            posx = 0,
            state = 0
        },

        colors = {
            red = {r = 255,g = 0,b = 28},
            yellow = {r = 220,g = 255,b = 0},
            green = {r = 50,g = 255,b = 0},
            cyan = {r = 0,g = 255,b = 255},
            magenta = {r = 255,g = 0,b = 255},
            white = {r = 255,g = 255,b = 255}
        },

        messages = summoner.Text:fetchByEnemyID(200210086),
        talk = {
            {text = summoner.Text:fetchByEnemyID(200210086).talk1,color = {r = 220,g = 255,b = 0},isPlayer = true},
            {text = summoner.Text:fetchByEnemyID(200210086).talk2,color = {r = 50,g = 255,b = 0},isPlayer = false},
            {text = summoner.Text:fetchByEnemyID(200210086).talk3,color = {r = 220,g = 255,b = 0},isPlayer = true}
        },

        delayItems = {

        },


        initialize = function (this,unit)
            this.myself = unit;
            unit:setSPGainValue(0);
            this.spValue = 20;
            for i=1,table.maxn(this.items) do
                unit:setItemSkill(i-1,this.items[i]);
            end
            local elements = {
                kElementType_Fire,
                kElementType_Aqua,
                kElementType_Earth,
                kElementType_Light,
                kElementType_Dark
            }
            for i = 1,5 do
                local conditionFunc = function (this,target) 
                    return target:getElementType() == elements[i];
                end
                local units = this.utill.findAllUnit(conditionFunc,true);
                local unitNum = table.maxn(units);
                if unitNum > 0 then
                    table.insert(this.weightsItemGroup1,{key = i - 1,value = 10 * unitNum});
                end
            end

            --ルゥを出す
            -- this.ru.orbit = unit:addOrbitSystemWithFile("../../effect/itemskill/itemskill6002","front");
            -- this.ru.orbit:setPosition(-800,150);
            -- this.ru.orbit:enableShadow(true);
            -- this.ru.orbit:setZOrder(3);
            -- this.ru.orbit:setItemSkill(0,this.items[8]);
            -- this.setRuState(this,this.ruState.front);

        end,

        takeAttackFromHost = function (this,unit,intparam)
            this.fromHost = true;
            unit:takeAttack(intparam);
        end,

        takeSkillFromHost = function (this,unit,intparam)
            this.fromHost = true;
            if intparam == 3 then
                unit:takeSkillWithCutin(3,1);
            else
                unit:takeSkill(intparam);
            end
        end,

        attackBranch = function (this,unit)

            if this.utill.getHPParcent(unit) <= 50 and not this.isRage then
                this.isRage = true;
                
                this.utill.sendEvent(this,5,0);
                this.useItem(this,unit,9);
                this.getRage(this,unit);
                return 0;
            end

            --自分が状態異常にかかっているならばフォスケラトで治療
            if this.recasts.group2 <= 0 and this.badStatusCureFlg then
                this.useItem(this,unit,5);
                this.recasts.group2 = this.consts.group2Recast;
                return 0;
            end

            --麻痺か氷結をかけられていたらラーズでそれ以降すべての状態異常を受け付けない
            if this.recasts.group2 <= 0 and this.badStatusRejectFlg then
                this.useItem(this,unit,6);
                unit:getTeamUnitCondition():addCondition(500381,113,100,99999,67);
                this.recasts.group2 = this.consts.group2Recast;
                this.badStatusRejectFlg = false;
                return 0;
            end

            --クリューゼの懐中時計のリキャストが溜まっていたら発動
            if this.recasts.group4 <= 0 then
                this.useItem(this,unit,8);
                this.recasts.group4 = this.consts.group4Recast;
                return 0;
            end

            --アイテムリキャストが溜まっていたらその中からランダムで使用
            if this.recasts.group1 <= 0 then
                local itemTable = this.utill.randomPickItem(this,this.weightsItemGroup1);
                this.useItem(this,unit,itemTable.key);
                this.recasts.group1 = this.consts.group1Recast;
                return 0;
            end

            local attackTable = this.utill.randomPickItem(this,this.weightsNormal);

            unit:takeAttack(attackTable.key);
            this.utill.sendEvent(this,1,attackTable.key);
            return 0;
        end,

        skillBranch = function (this,unit)
            
            local skillTable = this.utill.randomPickItem(this,this.weightsSkill);

            --怒りなら真奥義しかださない
            if this.isRage then
                unit:takeSkillWithCutin(3,1);
                this.utill.sendEvent(this,2,3);
                return 0;
            end
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
            end
        end,

        skillActiveSkillSetter = function (this,unit,index)
            if index == 2 then
                unit:setActiveSkill(4);
            elseif index == 3 then
                unit:setActiveSkill(6);
            end
        end,

        countDownRecast = function (this,unit,deltatime)
            for i,v in pairs(this.recasts) do
               this.recasts[i] = this.recasts[i] - deltatime;
            end
        end,

        useItem = function (this,unit,index)
            if this.utill.isHost() then
                this.utill.sendEvent(this,3,index);
            end
            unit:takeItemSkill(index);

            if index == 0 then
                this.utill.showMessage(this.messages.mess1,this.colors.cyan,5);
            elseif index == 1 then
                this.utill.showMessage(this.messages.mess2,this.colors.green,5);
            elseif index == 2 then
                this.utill.showMessage(this.messages.mess3,this.colors.red,5);
            elseif index == 3 then
                this.utill.showMessage(this.messages.mess4,this.colors.magenta,5);
            elseif index == 4 then
                this.utill.showMessage(this.messages.mess5,this.colors.yellow,5);
            elseif index == 5 then
                this.utill.showMessage(this.messages.mess6,this.colors.green,5);
                this.utill.showMessage(this.messages.mess7,this.colors.green,5);
            elseif index == 6 then
                this.utill.showMessage(this.messages.mess8,this.colors.cyan,5);
                this.utill.showMessage(this.messages.mess9,this.colors.cyan,5);  
                unit:getTeamUnitCondition():addCondition(500381,113,100,99999,67);
            elseif index == 8 then
                this.utill.showMessage(this.messages.mess11,this.colors.yellow,5);
                this.utill.showMessage(this.messages.mess12,this.colors.yellow,5); 
            elseif index == 9 then
                this.utill.showMessage(this.messages.mess13,this.colors.yellow,5);
                this.utill.showMessage(this.messages.mess14,this.colors.yellow,5);
            end

        end,


        setRuState = function (this,state)
            this.ru.state = state;
            if state == this.ruState.idle then
                this.ru.orbit:takeAnimation(0,"idle",true);
            elseif state == this.ruState.front then
                this.ru.orbit:takeAnimation(0,"front",true);
                this.ru.posx = this.ru.orbit:getPositionX();
            elseif state == this.ruState.back then
                this.ru.orbit:takeAnimation(0,"back",true);
                this.ru.posx = this.ru.orbit:getPositionX();
            elseif state == this.ruState.cast then
                this.ru.orbit:takeAnimation(0,"cast",true);
                local orbit = this.myself:addOrbitSystemWithFile("../../effect/itemskill/itemskill2007","attack3");
                orbit:setActiveSkill(5);
                this.ru.orbit:showPopText(this.messages.mess20,"ActionInfo",1,0,1,0,50);
                this.ru.orbit:takeBattleEffectAnimation("item5");
                this.utill.showMessage(this.messages.mess10,this.colors.green,5);
                this.recasts.group3 = this.consts.group3Recast;
            elseif state == this.ruState.outside then
                this.ru.orbit:takeAnimation(0,"idle",true);
            end

        end,

        ruControll = function (this,deltatime)
            local condition = function(this,unit)
                return unit:getBurstState() == kBurstState_active;
            end
            local isSkill = this.utill.findAllUnit(condition,true);
            if table.maxn(isSkill) > 0 and this.ru.state == this.ruState.idle then
                if this.utill.isHost() then
                    this.setRuState(this,this.ruState.cast);
                    this.utill.sendEvent(this,4,3);
                end
                
            end

            if this.ru.state == this.ruState.outside and this.recasts.group3 <= 0 then
                if this.utill.isHost() then
                    this.setRuState(this,this.ruState.front);
                    this.utill.sendEvent(this,4,1);
                end
                
            end


            if this.ru.state == this.ruState.front then
                
               if this.ru.posx < -100 then
                    this.ru.posx = this.ru.posx + 200 * deltatime;
                    this.ru.orbit:setPosition(this.ru.posx,150);
               else
                    this.setRuState(this,this.ruState.idle);
               end
            elseif this.ru.state == this.ruState.back then
                if this.ru.posx > -800 then
                    this.ru.posx = this.ru.posx - 200 * deltatime;
                    this.ru.orbit:setPosition(this.ru.posx,150);
               else
                    this.setRuState(this,this.ruState.outside);
               end
            end
        end,

        ruItemUseEnd = function (this)
            this.setRuState(this,this.ruState.back);
            return 1;
        end,

        getRage = function (this,unit)
            unit:getTeamUnitCondition():addCondition(500382,17,50,9999,26,17);
            
        end,

        showTalk = function (this,unit)
            this.talkCounter = this.talkCounter + 1;
            local talkTable = this.talk[this.talkCounter];
            this.utill.showMessage(talkTable.text,talkTable.color,3,0,talkTable.isPlayer);
        end,



        setDelayItems = function (this,method,delay)
            table.insert(this.delayItems,{method,delay});
        end,

        updateDelayItems = function (this,deltatime)
            for i = 1,table.maxn(this.delayItems) do
                if this.delayItems[i] ~= nil then
                    this.delayItems[i][2] = this.delayItems[i][2] - deltatime;
                    if this.delayItems[i][2] <= 0 then
                        this.executeDelayItem(this,this.delayItems[i][1]);
                        this.delayItems[i] = nil;
                    end
                end
            end
        end,

        executeDelayItem = function(this,item)
            item(this,this.myself);
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
                return nil;        
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
                megast.Battle:getInstance():sendEventToLua(this.thisID,index,intparam);
            end,

            showMessage = function(message,rgb,duration,iconid,player)
                if true == player then
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
            this.takeAttackFromHost(this,this.myself,intparam);
            return 1;
        end,

        receive2 = function (this , intparam)
            this.takeSkillFromHost(this,this.myself,intparam);
            return 1;
        end,

        receive3 = function (this , intparam)
            this.useItem(this,this.myself,intparam);
            return 1;
        end,

        receive4 = function (this,intparam)
            this.setRuState(this,intparam);
            return 1;
        end,

        receive5 = function (this,intparam)
            this.getRage(this,this.myself);
            return 1;
        end,


        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "ruItemUseEnd" then return this.ruItemUseEnd(this,unit) end
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
            -- if this.utill.findUnitByBaseID(101,true) ~= nil then
            --     this.showTalk(this,unit);
            --     this.setDelayItems(this,this.showTalk,3);
            --     this.setDelayItems(this,this.showTalk,6);
            --     this.recasts.group1 = 9;
            --     this.recasts.group2 = 9;
            --     this.recasts.group3 = 9;
            --     this.recasts.group4 = 9;
            -- end
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            -- this.countDownRecast(this,unit,deltatime);
            -- this.ruControll(this,deltatime);
            this.badStatusCureFlg = false; --状態異常の有無を毎フレーム判断し直したいので
            for i=1,table.maxn(this.badStatusIDs) do
                if this.utill.findConditionWithType(unit,this.badStatusIDs[i]) ~= nil then
                    this.badStatusCureFlg = true;
                    break;
                end
            end

            --麻痺と氷結は、一瞬でも入ったらフラグは立てっぱなしにする。
            for i=1,table.maxn(this.incapacitatedIDs) do
                if this.utill.findConditionWithType(unit,this.incapacitatedIDs[i]) ~= nil then
                    this.badStatusRejectFlg = true;
                    break;
                end
            end

            this.updateDelayItems(this,deltatime);
            
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

            if this.utill.isHost() and not this.attackChecker then
                this.attackChecker = true;
                return this.attackBranch(this,unit);
            end
            this.attackChecker = false;

            if not this.utill.isHost and not this.fromHost then
                unit:takeIdle();
                return 0;
            end
            this.fromHost = false;
            this.attackActiveSkillSetter(this,unit,index)
            unit:addSP(20);
            return 1;
        end,

        takeSkill = function (this,unit,index)
            

            if this.utill.isHost() and not this.skillChecker then
                this.skillChecker = true;
                return this.skillBranch(this,unit);
            end
            this.skillChecker = false;

            if not this.utill.isHost and not this.fromHost then
                unit:takeIdle();
                return 0;
            end
            this.fromHost = false;
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

