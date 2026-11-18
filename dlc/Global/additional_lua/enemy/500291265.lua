--@additionalItem,100691499
function new(id)
    print("500291265 new ");    -- 4−6 ニーア３回目
    local instance = {
        attackChecker   = false,
        skillChecker    = false,
        addPoint        = 20,       --addSP()で加算するSP量
        castCT          = 30,       --アイテム使用のクールタイム(初期値)
        castCTLimit     = 15,       --アイテムCT（２回目以降）
        castChecker     = false,    --アイテム使用フラグ
        partner         = nil,              --同時に出現するユニット
        initative      = true,             --自分が連携攻撃発動の主導権を持っているかどうか

        percentageValues = {
            attack1Per = 40,    --アタック１発生確率
            attack2Per = 70,    --アタック２発生確率
            castPer    = 40	    --アイテム使用確率
        },

        addSP = function(this,unit)
        --連携攻撃発動の主導権を持っているか、あるいは相方がやられて一人になってしまったなら奥義ゲージを増やせる
        if this.initative or not this.isPartnerAlive(this,unit) then
            print("addSP")
            unit:addSP(this.addSPValue)
        end
            return 1;
        end,

        --同時出現するユニットを探す
        findPartnerUnit = function(this,unit)
        
            local partnerUnit = nil;

            local megastInstance = nil
            local team = nil

            megastInstance = megast.Battle:getInstance()
            if megastInstance ~= nil then
               
                team = megastInstance:getTeam(unit:getisPlayer())
            end

            for i = 0, 7 do
                local targetUnit = nil
                if team ~= nil then
                   
                    targetUnit = team:getTeamUnit(i)
                end
                if targetUnit == unit then
                    --連携攻撃発動の主導権はインデックスが後ろ方
                    --先に自分が見つかったので主導権は無し
                    if partnerUnit == nil then
                        this.initative = false;
                    end
             
                elseif targetUnit ~= nil then
                    --そのユニットのidがグラードだったら
                    if targetUnit:getUnitID() == 500271593 then
                        partnerUnit = targetUnit;
                    end
                    
                end
            end
            return partnerUnit;
        end,

        --同時出現するユニットがまだ生きているかどうか
        isPartnerAlive = function(this,unit)
            if this.partner ~= nil and this.partner:getHP() > 0 then
                return true;
            end
            return false;
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

            return 1;
        end,

        excuteAction = function (this , unit)
            if this.partner == nil then
                this.partner = this.findPartnerUnit(this,unit);
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
            elseif index == 3 then
                unit:setActiveSkill(6);
            end

            if not this.skillChecker then
                this.skillChecker = true;
                if this.isPartnerAlive then
                    if this.initative then
                        this.partner:takeSkill(3);
                    end
                    unit:takeSkill(3);
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

