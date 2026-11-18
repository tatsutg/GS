--オージュ第2

function new(id)
    print("500232513 new ");
    local instance = {
        attackChecker   = false,
        skillChecker    = false,
        animPlayTurn = 0,
        skill3CountDown = 0,
        currentTurn = 0,
        thisId = id,
        skill3Flg = false,
        harfHoFlg = false,
        startPositionX = nil,
        startPositionY = nil,
        
        activeSkillNum = {
            attack1 = 1,
            attack2 = 2,
            attack3 = 3,
            attack4 = 4,
            attack5 = 5,
            skill1  = 6,
            skill2  = 7,
            skill3  = 8,
            gimmick = 9
        },
        
        --SP増加用メソッド
        addSP = function (this,unit)
            print("addSP");
            unit:addSP(20);
            return 1;
        end,
        
        --saw1 & saw2のorbitを呼び出すメソッド
        doubleSaw = function(this,unit)
          local saw1 = unit:addOrbitSystemWithFile("skill3_EF","saw1");
          local saw2 = unit:addOrbitSystemWithFile("skill3_EF","saw2");
          saw1:setZOrder(8000);
          saw2:setZOrder(0);
          
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
            unit:takeAnimation(1,"gimmick",false);
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "doubleSaw"   then return this.doubleSaw(this,unit); end
            if str == "addSP"       then return this.addSP(this,unit); end      
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
            unit:getSkeleton():setPosition(0,0);
            if this.startPositionX ~= nil then
	            unit:setPositionX(this.startPositionX);
	            unit:setPositionY(this.startPositionY);
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
            unit:setSPGainValue(0); --巨大系ボスなので自動でSPが増えないように設定
            
            return 1;
        end,

        excuteAction = function (this , unit)
        	if this.startPositionX == nil then
	            this.startPositionX = unit:getPositionX();
            	this.startPositionY = unit:getPositionY();
	        end
        	
            local hpparcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if hpparcent < 70 then this.skill3Flg = true; end
            if hpparcent < 50 then this.harfHoFlg = true; end

            print(this.skill3Flg);
            print(this.skill3CountDown);
            
            --takeAnimation()の処理
            if this.animPlayTurn == 0 then
                 --アニメーション再生ターンの初期化
                 this.animPlayTurn = LuaUtilities.rand(0,3)+ 2;    -- 3~5までのランダム
            end
            
            local ishost = megast.Battle:getInstance():isHost();
            if this.currentTurn == this.animPlayTurn and ishost then
                unit:takeAnimation(1,"gimmick",false);
                megast.Battle:getInstance():sendEventToLua(this.thisId,1,0);
                this.animPlayTurn = 0;
                this.currentTurn = 0;
                return 1;
            else
                this.currentTurn = this.currentTurn + 1;
                return 1;
            end
        end,

        takeIdle = function (this , unit)
            if this.harfHoFlg then unit:setNextAnimationName("idle2"); end
            return 1;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
        
            return 1;
        end,

        takeAttack = function (this , unit , index)
        
            if index == 1 then
                unit:setActiveSkill(this.activeSkillNum.attack1);
            elseif index == 2 then
                unit:setActiveSkill(this.activeSkillNum.attack2);
            elseif index == 3 then
                unit:setActiveSkill(this.activeSkillNum.attack3);
            elseif index == 4 then
                unit:setActiveSkill(this.activeSkillNum.attack4);
            elseif index == 5 then
                unit:setActiveSkill(this.activeSkillNum.attack5);
            end
            
            local ishost = megast.Battle:getInstance():isHost();
            
            if ishost and this.attackChecker == false then
                this.attackChecker = true
                local rand = LuaUtilities.rand(0,100);
                if rand <= 20 then
                    unit:takeAttack(1);
                elseif rand <=  40 then
                      unit:takeAttack(2);
                elseif rand <=  60 then
                    unit:takeAttack(3);
                elseif rand <=  80 then
                   unit:takeAttack(4);
               else
                    unit:takeAttack(5);
                end
                
                if this.skill3CountDown > 0 then this.skill3CountDown = this.skill3CountDown - 1; end

                return 0;
            end
            this.attackChecker = false
            return 1;
        end,

        takeSkill = function (this,unit,index)
        
            if index == 1 then
                unit:setActiveSkill(this.activeSkillNum.skill1);
            elseif index == 2 then
                unit:setActiveSkill(this.activeSkillNum.skill2);
            elseif index == 3 then
                unit:setActiveSkill(this.activeSkillNum.skill3);
            end
            
            local ishost = megast.Battle:getInstance():isHost();
            
            if ishost and not this.skillChecker then
                this.skillChecker = true;
                
                if this.skill3Flg and this.skill3CountDown == 0 then
                    this.skill3CountDown = 18;
                    unit:takeSkill(3);
                    return 0;
                else
                    local rand = LuaUtilities.rand(0,100);
                    if rand <= 50 then
                        unit:takeSkill(1);
                    else
                        unit:takeSkill(2);
                    end
                    
                    if this.skill3CountDown > 0 then this.skill3CountDown = this.skill3CountDown - 1; end
                    
                    return 0;
                end                
            end 
            this.skillChecker = false;
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

