function new(id)
    print("レム luaをinstantiate ");
    local instance = {
        targetElement = nil,
        buffValue = 0,
        buffAdded = false,
        gameUnit = nil,
        groupID = 10116,
        random = nil,

        colors = {
            red = {r = 255,g = 0,b = 28},
            green = {r = 50,g = 255,b = 0},
            yellow = {r = 220,g = 220,b = 0},
            blue = {r = 0,g = 255,b = 255},
            magenta = {r = 183,g = 0,b = 255},
            white = {r = 255,g = 255,b = 255}
        },

        randomSeed = function(seed)
            local randomClass = {
                rand = seed;

                randomRange = function(this,min,max)

                    this.rand =  this.rand * 1378653;
                    this.rand = this.rand + 129;

                    local range = max - min;

                    local result = min + this.rand % range;

                    return result;
                end
            }
            return randomClass;
        end,
      

        messages = summoner.Text:fetchByUnitID(101165511),

        askElementColor = function (this,element)
            if element == kElementType_Fire then
                return this.colors.red;
            end

            if element == kElementType_Aqua then
                return this.colors.blue;
            end

            if element == kElementType_Earth then
                return this.colors.green;
            end

            if element == kElementType_Light then
                return this.colors.yellow;
            end

            if element == kElementType_Dark then
                return this.colors.magenta;
            end

            return this.colors.white;
        end,

        askElementMesage = function (this,element)
            if element == kElementType_Fire then
                return this.messages.mess1..this.buffValue..this.messages.mess8;
            end

            if element == kElementType_Aqua then
                return this.messages.mess2..this.buffValue..this.messages.mess8;
            end

            if element == kElementType_Earth then
                return this.messages.mess3..this.buffValue..this.messages.mess8;
            end

            if element == kElementType_Light then
                return this.messages.mess4..this.buffValue..this.messages.mess8;
            end

            if element == kElementType_Dark then
                return this.messages.mess5..this.buffValue..this.messages.mess8;
            end

            return this.messages.mess6;
        end,

        askBuffIDForDef = function (this,element)
            if element == kElementType_Fire then
                return 61;
            end

            if element == kElementType_Aqua then
                return 62;
            end

            if element == kElementType_Earth then
                return 63;
            end

            if element == kElementType_Light then
                return 64;
            end

            if element == kElementType_Dark then
                return 65;
            end

            return 0;
        end,

        --ショット
        attack2 = function (this, unit)
            print("☆☆☆ 通常攻撃処理 ☆☆☆");
            unit:addOrbitSystemInsightRotation("attack1Shot2","attack1Hit2",1,0,217,180,0);
            return 1;
        end,

        skill1 = function (this, unit)
            print("☆☆☆ スキル発動 ☆☆☆");
            unit:addOrbitSystemInsightRotation("skill1Shot2","skill1Hit2",1,-14.41,242.8,180,0)
            return 1;
        end,

        sarchOtherRem = function(this,unit)
            
            local condition = function (this,unit)
                return (unit:getBaseID3() == 116);
            end
            if this.utill.findUnit(condition,unit:getisPlayer()) == unit then
                this.executeEffect(this,unit);
            end
            
        end,


        executeEffect = function(this,unit)

            local week = BattleControl:get():getDayOfWeek();
            print("今日の曜日は"..week);
            
            this.stargazer(this,unit);

            --土日以外は決められた属性になる
            if week == 1 then
                this.targetElement = kElementType_Dark;
            elseif week == 2 then
                this.targetElement = kElementType_Fire;
            elseif week == 3 then
                this.targetElement = kElementType_Aqua;
            elseif week == 4 then
                this.targetElement = kElementType_Earth;
            elseif week == 5 then
                this.targetElement = kElementType_Light;
            end

            this.utill.processAllUnit(this,this.addBuff,unit:getisPlayer());
            this.utill.showMessage(this.messages.mess7..this.askElementMesage(this,this.targetElement),this.askElementColor(this,this.targetElement),5,0,unit:getisPlayer());
        end,

        addBuff = function(this,unit)
            local buff = unit:getTeamUnitCondition():addCondition(-11651,17,this.buffValue,-1);
            buff:setScriptID(14);
            buff:setValue1(this.targetElement);

            local buff2 = unit:getTeamUnitCondition():addCondition(-11652,this.askBuffIDForDef(this,this.targetElement),this.buffValue,-1);

        end,

        heal = function(this,unit)
            local cond = this.gameUnit:getTeamUnitCondition():findConditionValue(1160);
            local rate = (100 + this.gameUnit:getTeamUnitCondition():findConditionValue(115) + unit:getTeamUnitCondition():findConditionValue(110))/100;
            local healValue = unit:getCalcHPMAX() * 0.02
            if cond > 0 then
                healValue = unit:getCalcHPMAX() * 0.03
                unit:takeHeal(healValue*rate,this.gameUnit);
            else
                unit:takeHeal(healValue * rate,this.gameUnit);
            end            
        end,

        stargazer = function(this,unit)
            local day = BattleControl:get():getDay();
            
            local month = BattleControl:get():getMonth();
            local year = BattleControl:get():getYear() + 1900;
            print("今日は"..year.."年"..month.."月"..day.."日です");
            local moonAge = this.getMoonAge(day,month,year);
            print("今日の月齢は"..moonAge.."です");

            local seed = year+month+day;
            this.random = this.randomSeed(seed);
            local rand = this.random:randomRange(20,30+moonAge%15);
            if rand > 40 then
                rand = 40;
            end

            local el = (day + moonAge)%5;

            if el == 0 then
                this.targetElement = kElementType_Fire;
            elseif el == 1 then
                this.targetElement = kElementType_Aqua;
            elseif el == 2 then
                this.targetElement = kElementType_Earth;
            elseif el == 3 then
                this.targetElement = kElementType_Light;
            elseif el == 4 then
                this.targetElement = kElementType_Dark;
            end

            this.buffValue = rand;

            -- this.stargazerTester(this,unit);

        end,

        --月齢計算用
        getMoonAge = function(day,month,year)
            local moonConst = 0;
            if month == 2 or month == 4 or month == 5 then
                moonConst = 2;
            elseif month ~= 1 and month ~= 3 then
                moonConst = month -2;
            end

            local temp1 = ((year - 11)%19)*11;
            local temp2 = temp1 + moonConst + day;

            return temp2 % 30;

        end,

        stargazerTester = function(this,unit)
            local low = 0;
            local middle = 0;
            local high = 0;
            local super = 0;

            for i=120,220 do
                local year = 2017 + math.floor(i/365);
                local month = 1;
                local day = i%365;
                if i <= 31 then
                    month = 1;
                elseif i <= 59 then
                    month = 2;
                    day = day - 31;
                elseif i <= 90 then
                    month = 3;
                    day = day - 59;
                elseif i <= 120 then
                    month = 4;
                    day = day - 90;
                elseif i <= 151 then
                    month = 5;
                    day = day - 120;
                elseif i <= 181 then
                    month = 6;
                    day = day - 151;
                elseif i <= 212 then
                    month = 7;
                    day = day - 181;
                elseif i <= 243 then
                    month = 8;
                    day = day - 212;
                elseif i <= 273 then
                    month = 9;
                    day = day - 243;
                elseif i <= 304 then
                    month = 10;
                    day = day - 273;
                elseif i <= 334 then
                    month = 11;
                    day = day - 304;
                else
                    month = 12;
                    day = day - 334;
                end

                local moonAge = this.getMoonAge(day,month,year);
                local seed = year+month+day;
                this.random = this.randomSeed(seed);
                local rand = this.random:randomRange(20,30+moonAge%15);
                if rand > 40 then
                    rand = 40;
                end
                -- print(month.."月"..day.."日の乱数は"..rand);
                if rand <= 25 then
                    low = low + 1;
                elseif rand <= 30 then
                    middle = middle + 1;
                elseif rand <= 35 then
                    high = high + 1;
                else
                    super = super + 1;
                end

            end
            this.utill.showMessage("５〜１０％補正は"..low.."回でした("..100 * low/(low+middle+high+super).."％）",this.colors.red,5,0,false);
            this.utill.showMessage("１１〜１５％補正は"..middle.."回でした("..100 * middle/(low+middle+high+super).."％）",this.colors.red,5,0,false);
            this.utill.showMessage("１６〜２０％補正は"..high.."回でした("..100 * high/(low+middle+high+super).."％）",this.colors.red,5,0,false);
            this.utill.showMessage("２１〜２５％補正は"..super.."回でした("..100 * super/(low+middle+high+super).."％）",this.colors.red,5,0,false);
            print("５〜１０％補正は"..low.."回でした("..100 * low/(low+middle+high+super).."％）");
            print("１１〜１５％補正は"..middle.."回でした("..100 * middle/(low+middle+high+super).."％）");
            print("１６〜２０％補正は"..high.."回でした("..100 * high/(low+middle+high+super).."％）");
            print("２１〜２５％補正は"..super.."回でした("..100 * super/(low+middle+high+super).."％）");
        end,


        utill = {

            --指定された条件に当てはまるユニット１体を返します　
            --この関数に渡すconditionFuncは真偽値を返す関数にしてください。引数にthis,TeamUnitを渡しますのでそれを使って関数内で判断してください。
            findUnit = function (conditionFunc,isPlayerTeam)
                for i = 0,7 do
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
                for i = 0,7 do
                    local target = megast.Battle:getInstance():getTeam(isPlayerTeam):getTeamUnit(i);
                    if target ~= nil and conditionFunc(this,target) then
                        table.insert(resultTable,target);
                    end
                end
                return resultTable;          
            end,

            --ユニット全てに指定された処理をします。引数にthis,TeamUnitを渡しますのでそれを使ってできる範囲で何かしてください
            processAllUnit = function (this,process,isPlayerTeam)
                for i = 0,7 do
                    local target = megast.Battle:getInstance():getTeam(isPlayerTeam):getTeamUnit(i);
                    if target ~= nil then
                        process(this,target);
                    end
                end         
            end,

            sendEvent = function(this,index,intparam)
                megast.Battle:getInstance():sendEventToLua(this.uniqueID,index,intparam);
            end,

            showMessage = function(message,rgb,duration,iconid,player)
                if player ~= nil  and player == true then
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
            addConditionWithPriority = function(unit,buffID,buffEFID,value,duration,iconID,groupID,priority)
                if groupID ~= nil then
                  local cond = unit:getTeamUnitCondition():findConditionWithGroupID(groupID);
                  if cond ~= nil and cond:getPriority() <= priority then
                     unit:getTeamUnitCondition():removeCondition(cond);
                    local newCond = unit:getTeamUnitCondition():addCondition(buffID,buffEFID,value,duration,iconID);
                     newCond:setGroupID(groupID);
                     newCond:setPriority(priority);
                  elseif cond == nil then
                     local newCond = unit:getTeamUnitCondition():addCondition(buffID,buffEFID,value,duration,iconID);
                     newCond:setGroupID(groupID);
                     newCond:setPriority(priority); 
                  end
                end
            end
        },

        --共通変数
        param = {
          version = 1.6
          ,isUpdate = true
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
            if str == "attack2" then return this.attack2(this,unit) end
            if str == "skill1" then return this.skill1(this,unit) end

            return 1;
        end,

        castItem = function (this,unit,battleSkill)
            this.utill.processAllUnit(this,this.heal,unit:getisPlayer());
            return 1;
        end,

        attackElementRate = function (this,unit,enemy,value)
            return value;
        end,

        takeElementRate = function (this,unit,enemy,value)
            return value;
        end,

        --version 1.4
        takeIn = function (this,unit)
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
            if this.buffAdded == false then
                this.buffAdded = true;
                this.sarchOtherRem(this,unit);
            end
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            return 1;
        end,
        
        attackDamageValue = function (this , unit , enemy , value)
            local cond = enemy:getTeamUnitCondition():findConditionWithID(101165511);
            if cond == nil then
                if enemy:getElementType() == 1 then
                    this.utill.addConditionWithPriority(enemy,101165511,62,-40,15,44,this.groupID,30);
                    
                elseif enemy:getElementType() == 2 then
                    this.utill.addConditionWithPriority(enemy,101165511,63,-40,15,45,this.groupID,30);
                elseif enemy:getElementType() == 3 then
                    this.utill.addConditionWithPriority(enemy,101165511,61,-40,15,43,this.groupID,30);
                elseif enemy:getElementType() == 4 then
                    this.utill.addConditionWithPriority(enemy,101165511,65,-40,15,47,this.groupID,30);
                elseif enemy:getElementType() == 5 then
                    this.utill.addConditionWithPriority(enemy,101165511,64,-40,15,46,this.groupID,30);
                end
            end
            
            return value;
        end,
        takeDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        --version1.0
        start = function (this , unit)
            this.gameUnit = unit;
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
    return 1;
end

