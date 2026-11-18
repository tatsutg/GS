--バルザンデスのlua
function new(id)
    print("10000 new ");
    local instance = {
        skillChecker = false,
        attackChecker = false,
        skillExecFlag = false,
        myself = nil,


        --プレイヤーとの距離が近すぎる時バックしてからビームを打つ場合に使う
        Exc = function (this,unit)
            if this.skillExecFlag then
                local posx = unit:getPositionX();
                local ishost = megast.Battle:getInstance():isHost();
                if ishost then
                    if posx > 0 then
                        this.skillExecFlag = true;
                        unit:takeBack();
                        megast.Battle:getInstance():sendEventToLua(190011510,1,1);
                        return 1;
                    else
                        this.skillExecFlag = false;
                        unit:takeAnimation(0,"charge_long",false);
                        unit:takeAnimationEffect(0,"charge_long",false);
                        megast.Battle:getInstance():sendEventToLua(190011510,2,1);
                        return 1;
                    end
                end
            end
            return 1;
        end,


        chargeEnd = function (this , unit)
            this.skillChecker = true;--スキルの分岐処理を回避するためのフラグを立てておく
            unit:takeSkill(1);--スキル呼び出し
            unit:setActiveSkill(2);--マスターで設定された威力とか属性とかの情報をセット
            unit:setBurstPoint(0);--sp１００％での発動ではいため、明示的に０を突っ込む必要がある。
            return 1;
        end,

        --今は使ってなかったと思う　咆哮の予備動作としてチャージを入れていた時のもの
        chargeEnd2 = function (this,unit)
            this.attackChecker = true;--攻撃の分岐処理を回避するためのフラグを立てておく
            unit:takeAttack(4);
            unit:setActiveSkill(5);
            return 1;
        end,


        addSP = function (this , unit)
            unit:addSP(20);
            return 1;
        end,

        --マルチのゲスト側がチャージ開始のメッセージを受け取った時のためのメソッド　チャージアニメーションを再生するだけ
        charge = function (this)
            this.myself:takeAnimation(0,"charge_long",false);
            this.myself:takeAnimationEffect(0,"charge_long",false);
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "Exc" then return this.Exc(this,unit) end
            if str == "chargeEnd" then return this.chargeEnd(this,unit) end
            if str == "chargeEnd2" then return this.chargeEnd2(this,unit) end
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "charge" then return this.charge(this) end
            return 1;
        end,

        --共通変数
        param = {
          version = 1.1
          ,isUpdate = 0
        },
        thisid = id,

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            this.skillExecFlag = true;--スキルの距離調整でバックしたことをゲスト側が知るため
            return 1;
        end,
        receive2 = function (this , intparam)
            this.charge(this);--スキルのための
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
            this.myself = unit;
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
            local ishost = megast.Battle:getInstance():isHost();--攻撃の分岐の処理はホストだけで行う（ゲスト側はホストに同期されるため不要
            if ishost then
                local target = unit:getTargetUnit() 
                local distance = BattleUtilities.getUnitDistance(unit,target)
              
                --距離判定　３００以上離れていたら突進
                if distance > 300 and this.attackChecker == false then
                    this.attackChecker = true
                    unit:takeAttack(3)
                    return 0;
                elseif this.attackChecker == false then--攻撃の分岐はこの中　単純に乱数で分岐
                    print("kita");
                    this.attackChecker = true;
                    rand = LuaUtilities.rand(0,100);
                    if rand <= 30 then
                        unit:takeAttack(1);
                        unit:setActiveSkill(2);
                    elseif  rand < 60 then
                        unit:takeAttack(2);
                        unit:setActiveSkill(3);
                    elseif rand < 90 then
                        unit:takeAttack(3);
                        unit:setActiveSkill(4);
                    else
                        unit:takeAnimation(0,"charge_short",false);
                        unit:takeAnimationEffect(0,"charge_short",false);
                    end
                    return 0;
                end
                this.attackChecker = false
            end
            return 1;
        end,

        takeSkill = function (this,unit,index)
            ishost = megast.Battle:getInstance():isHost();
            if ishost then
                rand = LuaUtilities.rand(0,100);
                if not this.skillChecker then
                    unit:setBurstPoint(99);--バックする場合にせよチャージするにせよsp１００だと無限にスキルを打とうとしてしまうため、一度この中に来たら９９で止めておく
                    local posx = unit:getPositionX();

                    --あまり前に出過ぎていた場合はバックする
                    if posx > -150 then
                        this.skillExecFlag = true;--バック終了後の行動はスキルですよーというフラグを立てる。
                        unit:takeBack();
                        megast.Battle:getInstance():sendEventToLua(this.thisid,1,1);
                    else
                        --ビームの予備動作としてチャージが入る
                        unit:takeAnimation(0,"charge_long",false);
                        unit:takeAnimationEffect(0,"charge_long",false);
                        megast.Battle:getInstance():sendEventToLua(this.thisid,2,1);--チャージモーションに入ったことをマルチのゲスト側プレイヤーに伝える
                    end
                    return 0;
                end
            elseif not this.skillChecker then
                return 0;
            end

            this.skillChecker = false;
            return 1;
        end,

        takeDamage = function (this , unit)
            this.skillChecker = false;
            return 1;
        end,

        dead = function (this , unit)
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

