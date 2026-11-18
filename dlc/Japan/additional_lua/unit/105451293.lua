function new(id)
    print("105451293 new ");
    local instance = {
        attackChecker = false,
        isExplosion = false,
        --自爆
        explosion = function (this,unit)
            print("RUN SCRIPT : 400 explosion")
            unit:getSkeleton():setOpacity(0)--自爆したらSceletonの透過度をゼロにする
            unit:setHP(0)
            return 1;
        end,


        --巨大化
        zoom = function (this,unit)
            print("RUN SCRIPT : 400 zoom")
            local skeleton = unit:getSkeleton();
            if skeleton:getScaleX() < 1.5 then
                skeleton:runAction(cc.ScaleTo:create(0.2,skeleton:getScaleX() * 1.1))
            end
            return 1;
        end,

        --共通変数
        param = {
          version = 1.2
          ,isUpdate = 0
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
            if str == "explosion" then return this.explosion(this,unit) end
            if str == "zoom" then return this.zoom(this,unit) end
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
            --もし自爆中なら
            if this.isExplosion then
                --hp割合
                local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();

                value = value * (100 + hpParcent)* 0.01;--(基礎倍率１００％　＋　自身の残りHP)/100　を倍率としてかける　なんのためにわざわざ１００分率にしてしまったのか
            end
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
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
            local skeleton = unit:getSkeleton();
            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            local rateByHP = 40 * hpParcent/100;--残りHPによる爆発のしづらさ　残りHPが高いと爆発しにくい 最大で４０
            local rateBySize = 30 * (skeleton:getScaleX() - 1)/0.5;--サイズによる爆発のしやすさ　最大１．５なので最大サイズから元のサイズを減算　大きければ大きいほど爆発しやすい　最大で３０
            local limit = 50 - rateByHP + rateBySize;--基礎倍率５０％　-　HPの割合による自爆のしづらさ　+　サイズによる自爆のしやすさ　全部条件が整ってたら80％
            local rand = math.random(100);

           if rand < limit and not this.attackChecker and not unit:getisPlayer() then
--           if rand < limit and not this.attackChecker then--not unit:getisPlayer()の条件文を外した場合
                this.attackChecker = true;--無限ループ防止フラグ
                this.isExplosion = true;
                unit:takeSkill(2)
                return 0;
            end
            this.attackChecker = false
            return 1;
        end,

        takeDamage = function (this , unit)
        --ダメージで怯んだ時は自爆実行中のフラグを折る
            this.isExplosion = false;
            return 1;
        end,

        dead = function (this , unit)
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

