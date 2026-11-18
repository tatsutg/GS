--@additionalItem,100691400
function new(id)
    print("500302315 new ");    -- 5−5 真ニーア
    local instance = {
        attackChecker   = false,
        skillChecker    = false,
        addPoint        = 10,               --addSP()で加算するSP量
        castCT          = 30,	            --アイテム使用のクールタイム(初期値は30秒に仮設定)
        castCTLimit     = 15,               --２回目以降のアイテムCT（初期値の半分）
        skill1CT        = 40,	            --スキル１のクールタイム(初期値は40秒に仮設定)
        skill1CTLimit   = 20,               --２回目以降のスキル１CT（初期値の半分）
        castChecker     = false,            --アイテム使用フラグ
        skill1Checker   = false,            --スキル１発動フラグ（takeAttackで発動させるので,takeSkillで使うskillCheckerとは別物）

        --攻撃・奥義の発生確率に関する定数テーブル
        percentageValues = {
            attack1Per = 40,    --attack1の発生確率
            attack2Per = 70,    --attack2の発生確率    
            castPer    = 80,    --castの発生確率
            skill1Per  = 60	    --skill1の発生確率（takeAttack()内で分岐させる）
        },

        addSP = function(this,unit)
            unit:addSP(this.addPoint);
            return 1;
        end,

        startSkill1 = function(this,unit)
            this.skill1Checker = false;
            if not this.skillChecker then
                this.skillChecker = true;
                unit:takeSkill(1);
            end
            return 1;
        end,

        startCast = function(this,unit)
            this.castChecker = false;
            unit:takeCast();
            unit:takeItemSkill(0);
            return 1;
        end,

        startAttack = function(this,unit)
            local attackRand = LuaUtilities.rand(0,100);
            if attackRand <= this.percentageValues.attack1Per then
                unit:takeAttack(1);
            elseif attackRand <= this.percentageValues.attack2Per then
                unit:takeAttack(2);
            else
                unit:takeAttack(3);
            end
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
            -- アイテム使用クールタイムの制御
            -- print(this.castCT);
            if this.castCT <= 0 then 
                this.castCT = this.castCTLimit;
                this.castChecker = true;
            end
            if not this.castChecker then
                this.castCT = this.castCT - deltatime;
            end

            -- スキル１発動クールタイムの制御
            print(string.format("スキル１CT＝%d", this.skill1CT));

            if this.skill1CT <= 0 then
                this.skill1CT = this.skill1CTLimit;
                this.skill1Checker = true;
            end
            if not this.skill1Checker then
                this.skill1CT = this.skill1CT - deltatime;
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
            unit:setItemSkill(0,100691400); --アイテムIDは仮としてグラードのものを使用している
            print("START");
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

            if index == 1 then
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            elseif index == 3 then
                unit:setActiveSkill(3);
            end

            if not this.attackChecker then
                this.attackChecker = true;
                -- print("スキル１フラグ＝" , this.skill1Checker);
                if this.skill1Checker and this.castChecker then --スキル１発動フラグ＆アイテム使用フラグが両方立っている場合
                    local rand = LuaUtilities.rand(0,100);
                    if rand <= this.percentageValues.skill1Per then
                        this.startSkill1(this,unit);
                        return 0;
                    elseif rand <= this.percentageValues.castPer then
                        this.startCast(this,unit);
                        return 0;
                    end
                elseif this.skill1Checker then --スキル１発動フラグのみ立っている場合
                    local skill1Rand = LuaUtilities.rand(0,100);
                    if skill1Rand <= this.percentageValues.skill1Per then
                        this.startSkill1(this,unit);
                        return 0;
                    end                
                elseif this.castChecker then --アイテム使用フラグのみ立っている場合
                    local castRand = LuaUtilities.rand(0,100);
                    if castRand <= this.percentageValues.castPer then
                        this.startCast(this,unit);
                        return 0;
                    end
                end

                this.startAttack(this,unit);
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
            elseif index == 3 then
                unit:setActiveSkill(6);
            end

            if not this.skillChecker then
                this.skillChecker = true;
                unit:takeSkill(2);          --現状はスキル２だけ発動するようにする。スキル３の分岐をのちほど追記予定。
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
    return instance.param.isUpdate;
end

