-- 簡易的なVector2クラスを定義
local Vector2 = {}
Vector2.new = function (x, y)
    local instance = {}
    instance.x = x or 0
    instance.y = y or 0

    instance.normalized = function (this)
        return Vector2.Normalize(this)
    end

    return instance
end

-- 正規化したベクトルを取得
Vector2.Normalize = function (_Vector2)
    local num = Vector2.Magnitude(_Vector2)

    if num > 1e-05 then
        return Vector2.new(_Vector2.x / num, _Vector2.y / num)
    end

    return Vector2.new(0, 0)
end

-- 2点間の距離を取得
Vector2.Magnitude = function (_Vector2)
    return math.sqrt(_Vector2.x * _Vector2.x + _Vector2.y * _Vector2.y)
end

-- x座標の距離を取得
Vector2.DistanceX = function (startPositionX, endPositionX)
    local diff = endPositionX - startPositionX
    return math.sqrt(diff * diff)
end

-- y座標の距離を取得
Vector2.DistanceY = function (startPositionY, endPositionY)
    local diff = endPositionY - startPositionY
    return math.sqrt(diff * diff)
end

function new(id)
    print("100433312 new ")
    local instance = {}

-- Funnelクラスを定義
    instance.Funnel = {}
    instance.Funnel.new = function (funnelUnit, ownerUnit)
        local instance = {}
        -- 親に追従する子ユニット
        instance.unit = funnelUnit
        -- 親のユニット
        instance.ownerUnit = ownerUnit
        -- 攻撃目標のユニット
        instance.targetUnit = function ()
            local isPlayer = instance.ownerUnit:getisPlayer();
            
            return megast.Battle:getInstance():getTeam(not isPlayer):getTeamUnit(instance.targetNum);
        end
        --ターゲットユニットの番号
        instance.targetNum = 0
        -- 経過時間
        instance.elapsed = 0
        -- 移動スピード
        instance.speed = 150
        -- 攻撃状態遷移までのインターバル
        instance.interval = 3.0
        -- 攻撃可能な間合い
        instance.attackRange =400
        -- ターゲットとの距離の制限。これ以上近づくとbackする
        instance.limitRange = 250
        -- モーションの遷移状態
        instance.motionState = { attack = false, back = false, front = false, idle = false, skill = false, appearance = false}
        -- ステートと対応するキー名
        instance.stateName = { attack = "attack", back = "back", front = "front", idle = "idle", skill = "skill", appearance = "appearance"}
        -- モーション名
        instance.motionName = {
            attack = "attack", back = "back", front = "front", idle = "idle",
            skill = "skill", appearance = "appearance", exit = "exit"
        }
        -- z軸の自動補正のためy軸の補正値
        instance.correctPosY = 3
        -- x座標補正値
        instance.correctPosX = 55

        -- 各モーションの遷移条件。updateでフラグ判定するとif文のネストだらけでカオスになりそう
        instance.transitionalCondition = {}
        instance.transitionalCondition.idle = function (this)
            if this.motionState.appearance then return false end
            if this.motionState.attack then return false end
            if this.motionState.back then return false end
            if this.motionState.front then return false end
            if this.motionState.skill then return false end

            if this.elapsed < this.interval then
                return true
            end

            return false
        end
        instance.transitionalCondition.back = function (this)
            if this.motionState.appearance then return false end
            if this.motionState.attack then return false end
            if this.motionState.front then return false end
            if this.motionState.skill then return false end

            if this.targetUnit() == nil then return false end

            if this:Backable() then
                return true
            end

            return false
        end
        instance.transitionalCondition.front = function (this)
            if this.motionState.appearance then return false end
            if this.motionState.attack then return false end
            if this.motionState.back then return false end
            if this.motionState.skill then return false end

            if this.targetUnit() == nil then return false end

            if this.elapsed >= this.interval  and not this:Attackable() then
                return true
            end

            return false
        end
        instance.transitionalCondition.attack = function (this)
            if this.motionState.appearance then return false end
            if this.motionState.back then return false end
            if this.motionState.skill then return false end

            if this.targetUnit() == nil then return false end

            if this.elapsed >= this.interval and this:Attackable() then
                return true
            end

            return false
        end

        -- モーションの遷移状態
        instance.checkState = function (this)
            local currentState = nil
            for k, v in pairs(this.motionState) do
                if v then
                    currentState = k
                    break
                end
            end

            return currentState or this.stateName.idle
        end

        -- 再生中のモーションの有無
        instance.isPlayingSomeMotion = function (this)
            for k, v in pairs(this.motionState) do
                if v then
                    return true
                end
            end

            return false
        end

        -- モーションの遷移状態をリセット
        instance.ResetMotionState = function (this)
            for k, v in pairs(this.motionState) do
                this.motionState[k] = false
            end
        end

        -- 後退可能かどうか
        instance.Backable = function (this)
            local distX = Vector2.DistanceX(this.unit:getPositionX(), this.targetUnit():getPositionX())
            local isPlayer = this.ownerUnit:getisPlayer();
            local isOutside = (this.unit:getPositionX() > 300 and isPlayer) or (this.unit:getPositionX() < -300 and not isPlayer)

            return distX <= math.abs(this.limitRange) and not isOutside
        end

        -- 攻撃可能かどうか
        instance.Attackable = function (this)
            local distX = Vector2.DistanceX(this.unit:getPositionX(), this.targetUnit():getPositionX())
            local distY = Vector2.DistanceY(this.unit:getPositionY(), this.ownerUnit:getPositionY())
            local isPlayer = this.ownerUnit:getisPlayer();

            local isOutside = (this.unit:getPositionX() > 300 and isPlayer) or (this.unit:getPositionX() < -300 and not isPlayer)

            return (distX >= math.abs(this.limitRange) or isOutside) and distX <= math.abs(this.attackRange) + 1e-1 and distY >= -10 and distY <= 10 and this:targetUnit():getInvincibleTime() <= 0
        end

        -- 擬似的なstart関数
        instance.start = function (this, animationIndex)
            -- 画面端の強制的な位置補完をオフにする
            this.unit._ignoreBorder = true
            -- 重力制御下におく
            this.unit.EnabledGravity = true
            this.unit:enableShadow(true)
            this.unit:setAutoZOrder(true)
            this.unit:setZOderOffset(-5000);
            
            local isPlayer = this.ownerUnit:getisPlayer()

            local correctPosX = this.correctPosX
            local correctPosY = this.correctPosY

            if isPlayer == false then
                correctPosX = correctPosX * -1
            end

            local spawnPosX = this.ownerUnit:getPositionX()
            local spawnPosY = this.ownerUnit:getPositionY()

            print("spawnPosX : " .. spawnPosX)

            this.unit:setPosition(spawnPosX + correctPosX, spawnPosY + correctPosY)

            this:takeAppearance(animationIndex)
        end

        -- 擬似的なupdate関数
        instance.update = function (this, deltatime)
            if this.unit == nil then return end
            if this.ownerUnit == nil then return end

            local currentState = this:checkState()

            if this.unit ~= nil then
                local currentPosX = this.unit:getPositionX()
            end

            if currentState == this.stateName.idle then
                this.elapsed = this.elapsed + deltatime
            end

            if this.transitionalCondition.back(this) then
                return this:takeBack()
            end

            if this.transitionalCondition.idle(this) then
                return this:takeIdle()
            end

            if this.transitionalCondition.front(this) then
                return this:takeFront(deltatime)
            end

            if this.transitionalCondition.attack(this) then
                return this:takeAttack()
            end
        end

        -- appearanceモーションの再生
        instance.takeAppearance = function (this, index)
            if not this.motionState.appearance then
                local motionName = string.format("%s%d", this.motionName.appearance, index)
                this.motionState.appearance = true
                this.unit:takeAnimation(0, motionName, true)
            end
        end

        -- appearanceモーション完了
        instance.onCompleteAppearance = function (this, index)
            local motionName = string.format("%s%d", this.motionName.appearance, index)
            this.motionState.appearance = false
            this:takeIdle()
        end

        -- idleモーションの再生
        instance.takeIdle = function (this)
            if not this.motionState.idle then
                this.motionState.idle = true
                this.unit:takeAnimation(0, this.motionName.idle, true)
            end
        end

        -- idleモーション完了
        instance.onCompleteIdle = function (this)
            this.motionState.idle = false
        end

        -- frontモーションの再生
        instance.takeFront = function (this, deltatime)
            this:moveToTarget(deltatime)

            if this.motionState.front == false then
                this:ResetMotionState()
                this.unit:takeAnimation(0, this.motionName.front, true)
                this.motionState.front = true
            end
        end

        -- frontモーション完了
        instance.onCompleteFront = function (this)
            this.motionState.front = false
        end

        -- backモーションの再生
        instance.takeBack = function (this)
        -- backモーションが再生中でなければ再生する
            
            if not this.motionState.back then
                -- backモーションはidleモーションからしか遷移せず、モーション終了を待たず再生されるので明示的にリセット
                this:ResetMotionState()
                this.motionState.back = true
                this.unit:takeAnimation(0, this.motionName.back, true)
            end
        end

        -- backモーション完了
        instance.onCompleteBack = function (this)
            this.motionState.back = false
        end

        -- attackモーションの再生
        instance.takeAttack = function (this, index)
        -- attackモーションが再生中でなければ再生する
            if not this.motionState.takeAttack then
                local animationIndex = index or 1
                local motionName = string.format("%s%d", this.motionName.attack, animationIndex)
                -- attackモーションは他のモーションの終了を待たず遷移するので、明示的にリセット
                this:ResetMotionState()
                this.elapsed = 0
                this.motionState.attack = true
                this.unit:takeAnimation(0, motionName, true)
            end
        end

        -- attackモーションの完了
        instance.onCompleteAttack = function (this, index)
            this.motionState.attack = false
        end

        -- skillモーションの再生
        instance.takeSkill = function (this, index)
            local motionName = string.format("%s%d", this.motionName.skill, index)
            this.unit:takeAnimation(0, motionName, true)
            -- skill発動時は強制的にアニメーションを再生させるので、他の遷移状態はクリアする
            this:ResetMotionState()
            this.motionState.skill = true
        end

        -- skillモーションの完了
        instance.onCompleteSkill  = function (this, index)
            this.motionState.skill = false
        end

        instance.takeExit = function (this)
            this.unit:takeAnimation(0, this.motionName.exit, false)
        end

        -- 子ユニットに追従するorbitSystemを生成する
        instance.addOrbit = function (this, str)
            -- addOrbitSystemWithFile()で呼び出したユニットからはaddOrbitSystem()が呼び出せないっぽい
            -- 他に解決法がないので親ユニットから呼び出す
            local orbit = this.ownerUnit:addOrbitSystem(str, 0)
            local  x = this.unit:getPositionX()
            local y = this.unit:getPositionY()

            orbit:setPosition(x, y)
            --通常攻撃ならステートを指定
            if str == "lion1attack1" then
                orbit:setActiveSkill(10);
            end
            
            --skill1なら威力配分
            if str == "lion1skill1" then
                orbit:setDamageRateOffset(1/2);
                orbit:setBreakRate(1/2);
            end
        end

        -- ターゲットへの移動
        instance.moveToTarget = function (this, deltatime)
            local currentPosX = this.unit:getPositionX()
            local currentPosY = this.unit:getPositionY()

            local targetPosX = this.targetUnit():getPositionX()
            local targetPosY = this.ownerUnit:getPositionY()

            local isPlayer = this.ownerUnit:getisPlayer()
            local attackRange = this.attackRange
            if isPlayer == false then
                attackRange = attackRange * -1
            end

            local heading = Vector2.new(targetPosX - currentPosX + attackRange, targetPosY - currentPosY)
            local direction = heading:normalized()

            local movePos = Vector2.new(currentPosX + direction.x * this.speed * deltatime, currentPosY + direction.y * this.speed * deltatime)

            this.unit:setPosition(movePos.x, movePos.y)
        end

        -- 座標をリセット
        instance.resetPosition = function (this)
            local x = this.ownerUnit:getPositionX()
            local y = this.ownerUnit:getPositionY()

            this.unit:setPosition(x, y)
        end

        return instance
    end

    instance.funnel = nil

    --共通変数
    instance.param = {
          version = 1.2,
          isUpdate = true
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

        local arg = nil

        arg = string.match(str, "onCompleteAppearance(%w+)")
        if arg ~= nil then this.funnel:onCompleteAppearance(tonumber(arg)) end

        arg = string.match(str, "onCompleteIdle")
        if arg ~= nil then this.funnel:onCompleteIdle() end

        arg = string.match(str, "onCompleteFront")
        if arg ~= nil then this.funnel:onCompleteFront() end

        arg = string.match(str, "onCompleteAttack(%w+)")
        if arg ~= nil then this.funnel:onCompleteAttack(tonumber(arg)) end

        arg = string.match(str, "onCompleteBack")
        if arg ~= nil then this.funnel:onCompleteBack() end

        arg = string.match(str, "onCompleteSkill(%w+)")
        if arg ~= nil then this.funnel:onCompleteSkill(tonumber(arg)) end

        arg = string.match(str, "addOrbit(%w+)")
        if arg ~= nil then this.funnel:addOrbit(arg) end

        arg = string.match(str, "startFunnel")
        if arg ~= nil then this:startFunnel(unit) end

        return 1;
    end

    instance.endWave = function (this , unit , waveNum)
        if unit:getisPlayer() then
            this.funnel.unit:takeAnimation(0, this.funnel.motionName.exit, false)
            this.funnel.unit:setEndAnimationName("");
            this.funnel = nil
        end
        return 1;
    end

    instance.startWave = function (this , unit , waveNum)
        this:createFunnel(unit, 1)
        return 1;
    end

    instance.update = function (this , unit , deltatime)
        if this.funnel ~= nil then
            this.funnel:update(deltatime)
        end

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

    instance.startFunnel = function (this , unit)
        this:createFunnel(unit, 1)
        return 1;
    end

    instance.createFunnel = function (this, unit, animationIndex)
        if this.funnel ~= nil then
            return
        end

        local funnelUnit = unit:addOrbitSystemWithFile("100433312_lion","idle")

        if funnelUnit == nil then
            return 1
        end

        this.funnel = this.Funnel.new(funnelUnit, unit)

        local isPlayer = unit:getisPlayer()
        this.funnel:start(animationIndex)
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
        local target= unit:getTargetUnit()

        if target ~= nil and this.funnel ~= nil then
            this.funnel.targetNum = target:getIndex();
        end

        return 1;
    end

    instance.takeSkill = function (this,unit,index)
        if this.funnel ~= nil then
            this.funnel:takeSkill(index)
            if index == 1 then
                unit:setDamageRateOffset(1/2);
                unit:setBreakRate(1/2);
            end
        end
        return 1;
    end

    instance.takeDamage = function (this , unit)
        return 1;
    end

    instance.dead = function (this , unit)
        this:destroyFunnel()
        return 1;
    end

    instance.destroyFunnel = function (this)
        if this.funnel ~= nil then
            this.funnel:takeExit()
        end

        this.funnel = nil
    end

    register.regist(instance,id,instance.param.version);
    return 1;
end