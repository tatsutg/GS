function new(id)
    print("101064411 new ")
    local instance = {}
    -- スキル1の発動回数
    instance.skillCount = 0
    -- スキルインデックス管理テーブル
    instance.skillIndexes = {skill1 = 1, skill2 = 2, skill3 = 3}

    instance.activateSkill = function (this, unit, index)
        -- -- スキル1以外ならそのまま制御を返す
        -- if index ~= 1 then
        --     return 1
        -- end

        -- this.skillCount = this.skillCount + 1

        -- -- skill1とskill3を交互に発動する
        -- if this.skillCount % 2 == 0 then
        --     unit:takeSkill(this.skillIndexes.skill3)
        --     return 0
        -- end

        return 1
    end

    --共通変数
    instance.param = {
          version = 1.2,
          isUpdate = 0
    }

    --マルチでキャストされてきたものを受け取るメソッド
    --receive + 番号　という形式で
    --引数にはintが渡る
    instance.receive1 = function (this , intparam)
        return 1;
    end

    --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
    --共通処理以外のものを書いたらここに登録して分岐
    -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
    --分岐先でのreturnは必須です。
    instance.run = function (this , unit , str)
        return 1;
    end

    instance.endWave = function (this , unit , waveNum)
        return 1;
    end

    instance.startWave = function (this , unit , waveNum)
        return 1;
    end

    instance.update = function (this , unit , deltatime)
        return 1;
    end

    instance.attackDamageValue = function (this , unit , enemy , value)
        return value;
    end

    instance.takeDamageValue = function (this , unit , enemy , value)
        return value;
    end

    instance.start = function (this , unit)
        return 1;
    end

    instance.excuteAction = function (this , unit)
        return 1;
    end

    instance.takeIdle = function (this , unit)
        return 1;
    end

    instance.takeFront = function (this , unit)
        return 1;
    end

    instance.takeBack = function (this , unit)
        return 1;
    end

    instance.takeAttack = function (this , unit , index)
        return 1;
    end

    instance.takeSkill = function (this,unit,index)
        return this:activateSkill(unit, index)
    end

    instance.takeDamage = function (this , unit)
        return 1;
    end

    instance.dead = function (this , unit)
        return 1;
    end

    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end