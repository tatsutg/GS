--@additionalItem,100691499
function new(id)
    print("500291195 new ");    -- 3−6 ニーア2回目
    local instance = {
        attackChecker   = false,
        skillChecker    = false,
        addPoint        = 20,       --addSP()で加算するSP量
        castCT          = 30,       --アイテム使用のクールタイム(初期値)
        castCTLimit     = 15,       --アイテムCT（２回目以降）
        castChecker     = false,    --アイテム使用フラグ
        halfHpChecker   = false,    --HP半減フラグ
        skill2Checker   = false,    --skill2発動フラグ（false = 未使用）

        percentageValues = {
            attack1Per = 40,    --アタック１発生確率
            attack2Per = 70,    --アタック２発生確率
            castPer    = 40	    --アイテム使用確率
        },

        addSP = function(this,unit)
            unit:addSP(this.addPoint);
            return 1;
        end,

        --共通変数
        param = {
          version = 1.2
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

            if str == "addSP" then
                return this.addSP(this,unit);
            end
            
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
            -- print(this.castCT);
            if this.castCT <= 0 then 
                this.castCT = this.castCTLimit;
                this.castChecker = true;
            end

            if not this.castChecker then
                this.castCT = this.castCT - deltatime;
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

        attackDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        --version1.0
        start = function (this , unit)
            unit:setSPGainValue(0); --SPの自然増加を無効にする
            unit:setItemSkill(0,100691499); --アイテムIDは仮としてグラードのものを使用している
            this.hpMarkers = {
                {
                    HP = 50,isUsed = false,MARKER = unit:addNumHpMarker(0.5)
                }
            }
            return 1;
        end,

        excuteAction = function (this , unit)
            local hpPercentage = 100 * unit:getHP()/unit:getCalcHPMAX();
            if hpPercentage < 50 then this.halfHpChecker = true; end
            print(unit:getHP());
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

            if index == 1 then
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            elseif index == 3 then
                unit:setActiveSkill(3);
            end

            if not this.attackChecker then
                this.attackChecker = true;

                --アイテム使用フラグが立っていた場合
                if this.castChecker then
                    local castRand = LuaUtilities.rand(0,100);
                    --40%の確率でアイテム使用
                    if castRand <= this.percentageValues.castPer then
                        this.castChecker = false;
                        unit:takeCast();
                        unit:takeItemSkill(0);
                        return 0;
                    end
                end

                local rand = LuaUtilities.rand(0,100);
                if rand <= this.percentageValues.attack1Per then
                    unit:takeAttack(1);
                elseif rand <= this.percentageValues.attack2Per then
                    unit:takeAttack(2);
                else
                    unit:takeAttack(3);
                end

                return 0;
            end

            this.attackChecker = false;
            return 1;
        end,

        takeSkill = function (this,unit,index)

            if index == 1 then
                unit:setActiveSkill(4);
            elseif index == 2 then
                unit:setActiveSkill(5);
            end

            if not this.skillChecker then
                this.skillChecker = true;
                if this.halfHpChecker and not this.skill2Checker then
                    this.skill2Checker = true;
                    unit:takeSkill(2);
                else
                    unit:takeSkill(1);
                end
                return 0;
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
    return 1;
end

