function new(id)
    print("100404511 new ")
    local instance = {}
    -- 生成するorbitSystem管理テーブル
    instance.orbitNames = { magic = "3skill2magic", sword = "3skill2sword", attackStart = "3attack1sword", attackFinish = "3attack1explode" }
    -- 敵座標キャッシュ用テーブル
    instance.targetUnitPos = { x = nil, y = nil }

    instance.swordAttack = function (this, unit)
        local orbit = unit:addOrbitSystem(this.orbitNames.attackStart, 1)
        orbit:setHitCountMax(1)
        orbit:setEndAnimationName(this.orbitNames.attackFinish)
        local posX = unit:getPositionX()
        local posY = unit:getPositionY()
        orbit:setPosition(posX, posY)

        return 1
    end

    -- orbitSystemの生成
    instance.addOrbit = function (this, unit, orbitName)
        local addObj = nil
        local setZOrder = 0

        if orbitName == this.orbitNames.magic then
            addObj = unit:addOrbitSystem(this.orbitNames.magic, 0)
            setZOrder = -1
        elseif orbitName == this.orbitNames.sword then
            addObj = unit:addOrbitSystem(this.orbitNames.sword, 0)
            setZOrder = 1
        end

        local targetUnit = unit:getTargetUnit()

        if targetUnit ~= nil  and addObj ~= nil then
            local tagetUnitZOrder = targetUnit:getZOrder()

            local inited = this.targetUnitPos.x or this.targetUnitPos.y or false

            if inited == false then
                local targetPosX = targetUnit:getPositionX()
                local targetPosY = targetUnit:getPositionY()

                this.targetUnitPos.x = targetPosX
                this.targetUnitPos.y = targetPosY
            end

            addObj.autoZorder = false
            addObj:setZOrder(tagetUnitZOrder + setZOrder)
            addObj:setPosition(this.targetUnitPos.x, this.targetUnitPos.y)
        end

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
    -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
    --分岐先でのreturnは必須です。
    instance.run = function (this , unit , str)
        local  arg = nil

        arg = string.match(str, "addOrbit(%w+)")
        if arg ~= nil then
            return  this:addOrbit(unit, arg)
        end

        arg = string.match(str, "swordAttack")
        if arg ~= nil then
            return this:swordAttack(unit)
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
    -- 奥義発動時にキャッシュ用テーブルを初期化
        if index == 2 then
            this.targetUnitPos.x = nil
            this.targetUnitPos.y = nil
        end
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
