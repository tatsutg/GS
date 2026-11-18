function new(id)
    print("10000 new ");
    local instance = {
    	skillDamage = 0,--自分が奥義で受けたダメージを覚えておく
    	healRate = 0.3,--奥義によって受けたダメージの回復倍率

        --共通変数
        param = {
          version = 1.5
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
            return 1;
        end,


        --共通処理
        castItem = function (this,unit,battleSkill)
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
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
        	if this.skillDamage > 0 then
        		local rate = (100 + unit:getTeamUnitCondition():findConditionValue(115) + unit:getTeamUnitCondition():findConditionValue(110))/100;
	        	unit:takeHeal(this.skillDamage * rate);
	        	

        		this.skillDamage = 0;
        	end
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
        	local parent =  enemy:getParentTeamUnit();

        	if parent ~= nil then
        		if parent:getBurstState() == kBurstState_active then
        			local healPoint = value * this.healRate;
        			if healPoint < 1 then
        				healPoint = 1;
        			end
	        		this.skillDamage = this.skillDamage + healPoint;
	        	end
        	else
        		if enemy:getBurstState() == kBurstState_active then
        			local healPoint = value * this.healRate;
        			if healPoint < 1 then
        				healPoint = 1;
        			end
	        		this.skillDamage = this.skillDamage + healPoint;
	        	end
        	end
        	

            --バリアの不具合のための応急処置　todo　バイナリ修正したら消す
            local cond = unit:getTeamUnitCondition():findConditionWithType(98);
            if cond ~= nil then
                local condValue = cond:getValue();
                if condValue <= 0 then
                    unit:getTeamUnitCondition():removeCondition(cond);
                    local cond2 = unit:getTeamUnitCondition():findConditionWithType(98);
                    if cond2 ~= nil then
                        local condValue2 = cond2:getValue();
                        cond2:setValue(condValue2 + condValue);
                        if cond2:getValue() <= 0 then
                            unit:getTeamUnitCondition():removeCondition(cond2);
                        end
                    end
                end
                
            end
            

            return value;
        end,

        --version1.0
        start = function (this , unit)
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
    return instance.param.isUpdate;
end

