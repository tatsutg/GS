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
        instance.attackRange = 350
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
        -- orbitSystemで生成するアニメーション名
        instance.orbits = {
            attack1 = "attack1spirit", attack1ball = "attack1spiritBall", attack1hit = "attack1spiritExplosion", skill1 = "skill1spirit", skill2 = "skill2spirit"
        }
        -- 通常攻撃時に生成するエフェクトのrootボーン
        instance.orbitParentName = "orbitParentBone"
        --z軸の自動補正のためのy軸補正値
        instance.correctPosY = 10

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
            local isPlayer = this.ownerUnit:getisPlayer()
            local distX = Vector2.DistanceX(this.unit:getPositionX(), this.targetUnit():getPositionX())
            local isOutside = (this.unit:getPositionX() + this.unit:getSkeleton():getBoneWorldPositionX("MAIN") >= 300 and isPlayer) or (this.unit:getPositionX() <= -300 and not isPlayer)
            return distX <= math.abs(this.limitRange) and not isOutside
        end

        -- 攻撃可能かどうか
        instance.Attackable = function (this)
            local isPlayer = this.ownerUnit:getisPlayer()
            local distX = Vector2.DistanceX(this.unit:getPositionX(), this.targetUnit():getPositionX())
            local distY = Vector2.DistanceY(this.unit:getPositionY(), this.ownerUnit:getPositionY())
            local isOutside = (this.unit:getPositionX() >= 300 + this.unit:getSkeleton():getBoneWorldPositionX("MAIN") and isPlayer) or (this.unit:getPositionX() <= -300 and not isPlayer)

            return (distX >= math.abs(this.limitRange) or isOutside) and distX <= math.abs(this.attackRange) + 1e-1 
        end

        -- 擬似的なstart関数
        instance.start = function (this, isPlayer, animationIndex)
            -- 画面端の強制的な位置補完をオフにする
            this.unit._ignoreBorder = true
            -- 重力制御下におく
            this.unit.EnabledGravity = true
            this.unit:enableShadow(true)
            this.unit:setAutoZOrder(true)
            this.unit:setZOderOffset(-5000);
            this:resetPosition()

        -- 敵側で出現するユニットの場合、向きを反転させる
            if not isPlayer then
                this.attackRange = this.attackRange * -1
                this.limitRange = this.limitRange * -1
            end

            this:takeAppearance(animationIndex)
        end

        -- 擬似的なupdate関数
        instance.update = function (this, deltatime)
            if this.unit == nil then return end
            if this.ownerUnit == nil then return end
            this.elapsed = this.elapsed + deltatime

            if this.unit ~= nil then
                local currentPosX = this.unit:getPositionX()
                -- print("funnel-update currentPosX : " .. currentPosX)
            end

            local currentState = this:checkState()

            if currentState == this.stateName.idle then
                
            end
            
            local target = this.unit:getTargetUnit()
            if target == nil then
                this.elapsed = 1.0;
            end
            
            if  megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
                this.elapsed = 1.0;
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
                -- backモーションは他のモーション終了を待たず再生されるので明示的にリセット
                this:ResetMotionState()
                this.motionState.back = true
                this.unit:takeAnimation(0, this.motionName.back, true)
            end
        end

        --back中に画面端に到達してしまわないかどうかのチェック
        instance.checkOutside = function (this)
            local unitx = this.unit:getPositionX();
            local outside = 300;
            --精霊がバックアニメーションで移動する距離
            local backDistance = 140;
            local isPlayer = this.ownerUnit:getisPlayer()

            if not isPlayer then
                backDistance = backDistance * -1;
                outside = outside * -1;
            end

            if isPlayer and unitx + backDistance > outside then
                this.unit:setPosition(unitx + outside - (backDistance + unitx),this.unit:getPositionY());
            elseif not isPlayer and unitx + backDistance < outside then
                this.unit:setPosition(unitx + outside - (backDistance + unitx),this.unit:getPositionY());
            end
        end

        -- backモーション完了
        instance.onCompleteBack = function (this)
            this.motionState.back = false
        end

        -- attackモーションの再生
        instance.takeAttack = function (this, index)
        -- attackモーションが再生中でなければ再生する
            if not this.motionState.takeAttack and not this.motionState.front then
                local animationIndex = index or 1
                local motionName = string.format("%s%d", this.motionName.attack, animationIndex)
                -- attackモーションは他のモーションの終了を待たず遷移するので、明示的にリセット
                this:ResetMotionState()
                this.elapsed = 0
                this.motionState.attack = true
                this.unit:takeAnimation(0, motionName, true)

                if animationIndex == 1 then
                    this:createAttackEffect()
                end
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

        -- funnelユニットは常にモーションをループしなければいけない仕様なので、0フレーム目でLuaからorbitを呼び出すイベントがあったりすると延々と処理がループする危険が...
        -- 遠回りで面倒だけど現在のstateを確認してからorbitSystemを生成する
        instance.activateSkill = function (this, index)
            if this:checkState() ~= this.stateName.skill then return end
            local motionName = string.format("%s%d", this.motionName.skill, index)
            this:addOrbit(this.orbits[motionName]):setDamageRateOffset(0.3);
        end

        -- skillモーションの完了
        instance.onCompleteSkill  = function (this, index)
            this.motionState.skill = false
        end

        -- 退却モーションの再生
        instance.takeExit = function (this)
        -- アニメーションが完了したら自動的にオブジェクト破棄
            this.unit:takeAnimation(0, this.motionName.exit, false)
        end

        -- 通常攻撃時のエフェクト生成
        instance.createAttackEffect = function (this)
            local isPlayer = this.ownerUnit:getisPlayer()
            local skeleton = this.unit:getSkeleton()

            local orbitParentX = skeleton:getBoneWorldPositionX("orbitParentBone")
            local orbitParentY = skeleton:getBoneWorldPositionY("orbitParentBone")

            -- 敵側として出現したユニットの場合は座標を反転
            if isPlayer == false then
                orbitParentX = orbitParentX * -1
            end

            this:addOrbit(this.orbits.attack1)
            local orbit = this:addOrbitSystemInsightRotation(this.orbits.attack1ball, this.orbits.attack1hit, 1, 180, 0, orbitParentX, orbitParentY);
            orbit:setActiveSkill(10);--存在しないスキルを指定して通常攻撃にする
        end

        instance.addOrbitSystemInsightRotation = function (this, startAnimation, endAnimation, hit, angle, offset, orbitParentX, orbitParentY)
            
            local x = this.unit:getPositionX() - this.ownerUnit:getPositionX() + orbitParentX
            local y = this.unit:getPositionY() - this.ownerUnit:getPositionY() + orbitParentY

            local orbit = this.ownerUnit:addOrbitSystemInsightRotation(startAnimation, endAnimation, hit, x, y, angle, offset)
            return orbit;
        end

        -- 子ユニットに追従するorbitSystemを生成する
        instance.addOrbit = function (this, str)
            -- addOrbitSystemWithFile()で呼び出したユニットからはaddOrbitSystem()が呼び出せないっぽい
            -- 他に解決法がないので親ユニットから呼び出す
            local orbit = this.ownerUnit:addOrbitSystem(str, 0)
            orbit:setSPRateOffset(0);	
	        orbit:setBreakRateOffset(0);
            local  x = this.unit:getPositionX()
            local y = this.unit:getPositionY()

            orbit:setPosition(x, y)
            return orbit;
        end

        -- ターゲットへの移動
        instance.moveToTarget = function (this, deltatime)
            local currentPosX = this.unit:getPositionX()
            local currentPosY = this.unit:getPositionY()

            local targetPosX = this.targetUnit():getPositionX()
            local targetPosY = this.ownerUnit:getPositionY()

            local heading = Vector2.new(targetPosX - currentPosX + this.attackRange, targetPosY - currentPosY)
            local direction = heading:normalized()

            local movePos = Vector2.new(currentPosX + direction.x * this.speed * deltatime, currentPosY + direction.y * this.speed * deltatime)

            this.unit:setPosition(movePos.x, movePos.y)
        end

        -- 座標をリセット
        instance.resetPosition = function (this)
            local x = this.ownerUnit:getPositionX()
            local y = this.ownerUnit:getPositionY() + this.correctPosY

            this.unit:setPosition(x, y)
        end

        -- 前進。最小射程距離にワープする
        instance.moveFront = function (this)
            local targetUnit = this.targetUnit();
            if targetUnit == nil then
                return instance
            end
            
            local x = targetUnit:getPositionX()
            local y = this.ownerUnit:getPositionY() + this.correctPosY

            -- 補正値
            local correct = 10

            if this.ownerUnit:getisPlayer() == false then
                correct = correct * -1
            end

            x = x + this.limitRange + correct

            this.unit:setPosition(x, y)
        end

        return instance
    end

    instance.funnel = nil
    -- 生成するfunnelのスケルトン名
    instance.funnelOrbitSkeletonName = "100615112_spirit"

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

        arg = string.match(str, "resetPosition")
        if arg ~= nil then this.funnel:resetPosition() end

        arg = string.match(str, "activateSkill(%w+)")
        if arg ~= nil then this.funnel:activateSkill(tonumber(arg)) end

        arg = string.match(str, "moveFront")
        if arg ~= nil then this.funnel:moveFront() end

        arg = string.match(str, "CheckOutside")
        if arg ~= nil then this.funnel:checkOutside() end

        return 1;
    end

    instance.endWave = function (this , unit , waveNum)
        this:destroyFunnel()
        return 1;
    end

    instance.startWave = function (this , unit , waveNum)
        this:createFunnel(unit, 2)
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

        local funnelUnit = unit:addOrbitSystemWithFile(this.funnelOrbitSkeletonName,"idle")
	    funnelUnit:setSPRateOffset(0);	
	    funnelUnit:setBreakRateOffset(0);	

        if funnelUnit == nil then
            return
        end

        this.funnel = this.Funnel.new(funnelUnit, unit)

        local isPlayer = unit:getisPlayer()
        this.funnel:start(isPlayer, animationIndex)
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
        local target = unit:getTargetUnit()

        -- ターゲットは本体ユニットの攻撃時にしか取得できないっぽいのでその都度キャッシュしておく
        if target ~= nil and this.funnel ~= nil then
            this.funnel.targetNum = target:getIndex();
        end

        return 1;
    end

    instance.takeSkill = function (this,unit,index)
        -- 本体がスキル発動したらfunnelも強制的にスキルを発動させる
        if this.funnel ~= nil then
            this.funnel:takeSkill(index)
            unit:setDamageRateOffset(0.7);
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