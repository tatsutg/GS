--オージュ第１


function new(id)
    print("10000 new ");
    local instance = {
        ishost = true,
        isRage = false,
        skillChecker = false,
        attackChecker = false,
        useMeteor = false,
        myself = nil,

        addSP = function (this,unit)
            unit:addSP(20);
            return 1;
        end,

        showInEffect = function(this,unit)
            unit:takeAnimationEffect(0,"in1",false);
            return 1;
        end,

        red = function(this,unit)
            megast.Battle:getInstance():setBackGroundColor(15,255,0,0);
            return 1;
        end,

        redEnd = function(this,unit)
            megast.Battle:getInstance():setBackGroundColor(999,255,255,255);
            return 1;
        end,

        transform = function(this,unit)
            unit:takeAnimation(0,"in2",false);
            unit:takeAnimationEffect(0,"in2",false);
            BattleControl:get():playBGM("GS501_LASTBOSS_02");
            print("transform")
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

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "red" then return this.red(this,unit) end
            if str == "redEnd" then return this.redEnd(this,unit) end
            if str == "showInEffect" then return this.showInEffect(this,unit) end
            if str == "transform" then return this.transform(this,unit) end
            if str == "firestart" then return this.firestart(this,unit) end            
            if str == "fireloop" then return this.fireloop(this,unit) end
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
            if not this.isRage and unit:getHPPercent() < 0.7 then
                this.isRage = true;
                unit:takeAnimation(0,"transform",false);
                unit:takeAnimationEffect(0,"empty",false);
                unit:setSetupAnimationName("setUpDown");
                unit:setInvincibleTime(10);
                unit:callLuaMethod("firestart",9);
            end
            for _,marker in pairs(this.hpMarkers) do
                local hpPercent = 100 * unit:getHP()/unit:getCalcHPMAX();
                if not marker.isUsed and hpPercent < marker.HP then
                    marker.isUsed = true
                    unit:removeHpMarker(marker.MARKER)
                end
            end
            return 1;
        end,
        
        firestart = function (this , unit)
                this.fire = BattleControl:get():addAnimation("FIRE","FIRE4_00",true);
                this.fire:setPositionX(unit:getPositionX() -50);
                this.fire:setPositionY(unit:getPositionY() -20);
                this.fire:setZOrder(0);
                unit:callLuaMethod("fireloop",2);
                return 1;
        end,


        fireloop = function (this , unit)
            this.fire:setToSetupPose();
            this.fire:setAnimation(0, "FIRE3_00",true);
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
            this.ishost = megast.Battle:getInstance():isHost();
            this.myself = unit;
            unit:setSPGainValue(0);
            unit:setMiniBreakRate(0);
            this.hpMarkers = {
                {
                    HP = 70,isUsed = false,MARKER = unit:addNumHpMarker(0.7)
                }
            }
            return 1;
        end,

        excuteAction = function (this , unit)
            megast.Battle:getInstance():setBackGroundColor(1,255,255,255);
            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if this.isRage then 
                unit:setSetupAnimationName("setUpRage");
            end
            return 1;
        end,

        takeIdle = function (this , unit)
            if not this.isRage then
                return 0;
            end
            
            if this.isRage then
                unit:setNextAnimationName("idle2");
            end
            return 1;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
            if this.isRage then
                unit:setNextAnimationName("back2");
            end
            return 1;
        end,

        takeAttack = function (this , unit , index)
            if this.ishost and not this.attackChecker then
                this.attackChecker = true;
                if this.isRage then
                    unit:takeAttack(2);
                else
                    unit:takeAttack(1);
                end
                return 0;
            end
            this.attackChecker = false;
            return 1;
        end,

        takeSkill = function (this,unit,index)
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
            elseif index == 10 then
                unit:setActiveSkill(10);
            elseif index == 11 then
                unit:setActiveSkill(11);
            end

            if not this.skillChecker and this.ishost then
                this.skillChecker = true;
                local rand = LuaUtilities.rand(0,100);
                local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
                if not this.useMeteor and this.isRage then
                    unit:takeSkill(11);
                    this.useMeteor = true;
                    return 0;
                end

                if not this.isRage then
                    if rand < 20 then
                        unit:takeSkill(1);
                    elseif rand < 40 then
                        unit:takeSkill(2);
                    elseif rand < 60 then
                        unit:takeSkill(3);
                    elseif rand < 80 then
                        unit:takeSkill(7);
                    else
                        unit:takeSkill(8);
                    end        
                else
                    if rand < 20 then
                        unit:takeSkill(4);
                    elseif rand < 40 then
                        unit:takeSkill(5);
                    elseif rand < 60 then
                        unit:takeSkill(6);
                    elseif rand < 80 then
                        unit:takeSkill(9);
                    else
                        unit:takeSkill(10);
                    end  
                end
                return 0;
            end
            this.skillChecker = false;
            return 1;
        end,

        takeDamage = function (this , unit)
            if this.isRage then
                unit:setNextAnimationName("damage2");
            else
                unit:setNextAnimationName("damage1");
            end
            return 1;
        end,

        dead = function (this , unit)
            if this.fire ~= nil then
                this.fire:removeFromParent();
            end
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

