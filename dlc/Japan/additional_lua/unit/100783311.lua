function new(id)
    print("100783311 new")
    local instance = {}

    instance.fireBall = function (this, unit)
        local fb = unit:addOrbitSystem("FireBall", 1)
        fb:setHitCountMax(1)
        fb:setEndAnimationName("Empty")
        x = unit:getPositionX()
        y = unit:getPositionY()
        fb:setPosition(x, y)

        return 1
    end

    --共通変数
    instance.param = {
      version = 1.2
      ,isUpdate = 0
    }

    --共通処理

    --マルチでキャストされてきたものを受け取るメソッド
    --receive + 番号　という形式で
    --引数にはintが渡る
    instance.receive1 = function (this , intparam)
        return 1
    end

    --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
    --共通処理以外のものを書いたらここに登録して分岐
    -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return test1(this,unit) end のような感じです。
    --分岐先でのreturnは必須です。
    instance.run = function (this , unit , str)
        if str == "fireBall" then
            return this.fireBall(this, unit)
        end

        return 1
    end

    --versiton1.2
    instance.endWave = function (this , unit , waveNum)
        return 1
    end

    instance.startWave = function (this , unit , waveNum)
        return 1
    end

    --version1.1
    instance.update = function (this , unit , deltatime)
        return 1
    end

    instance.attackDamageValue = function (this , unit , enemy , value)
        return value
    end

    instance.takeDamageValue = function (this , unit , enemy , value)
        return value
    end

    --version1.0
    instance.start = function (this , unit)
        return 1
    end

    instance.excuteAction = function (this , unit)
        return 1
    end

    instance.takeIdle = function (this , unit)
        return 1
    end

    instance.takeFront = function (this , unit)
        return 1
    end

    instance.takeBack = function (this , unit)
        return 1
    end

    instance.takeAttack = function (this , unit , index)
        return 1
    end

    instance.takeSkill = function (this,unit,index)
        return 1
    end

    instance.takeDamage = function (this , unit)
        return 1
    end

    instance.dead = function (this , unit)
        return 1
    end
    register.regist(instance,id,instance.param.version)
    return instance.param.isUpdate;
end