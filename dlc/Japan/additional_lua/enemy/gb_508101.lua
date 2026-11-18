local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="GB百獣姫レン", version=1.3, id="gb_508101"});
class:inheritFromEnemy("gbBossBase");

---------------------------------------------------------------------------------
-- GB_start
---------------------------------------------------------------------------------
function class:GB_start(event)
    self.funnel = nil
    self.orbitSystemFileName = "100434312_lion"
    --summoner.Utility.messageByEnemy(self.orbitSystemFileName)


    -- 簡易的なVector2クラスを定義
    self.Vector2 = {}
    self.Vector2.new = function (x, y)
        local instance = {}
        instance.x = x or 0
        instance.y = y or 0

        instance.normalized = function (this)
            return self.Vector2.Normalize(this)
        end

        return instance
    end

    -- 正規化したベクトルを取得
    self.Vector2.Normalize = function (_Vector2)
        local num = self.Vector2.Magnitude(_Vector2)

        if num > 1e-05 then
            return self.Vector2.new(_Vector2.x / num, _Vector2.y / num)
        end

        return self.Vector2.new(0, 0)
    end

    -- 2点間の距離を取得
    self.Vector2.Magnitude = function (_Vector2)
        return math.sqrt(_Vector2.x * _Vector2.x + _Vector2.y * _Vector2.y)
    end

    -- x座標の距離を取得
    self.Vector2.DistanceX = function (startPositionX, endPositionX)
        local diff = endPositionX - startPositionX
        return math.sqrt(diff * diff)
    end

    -- y座標の距離を取得
    self.Vector2.DistanceY = function (startPositionY, endPositionY)
        local diff = endPositionY - startPositionY
        return math.sqrt(diff * diff)
    end

    self.Funnel = {}
    self.Funnel.new = function (funnelUnit, ownerUnit)
        local funnel = {}
        -- 親に追従する子ユニット
        funnel.unit = funnelUnit
        -- 親のユニット
        funnel.ownerUnit = ownerUnit

        -- 攻撃目標のユニット
        funnel.targetUnit = function ()
            local isPlayer = funnel.ownerUnit:getisPlayer();

            return megast.Battle:getInstance():getTeam(not isPlayer):getTeamUnit(funnel.targetNum);
        end
        --ターゲットユニットの番号
        funnel.targetNum = 0
        -- 経過時間
        funnel.elapsed = 0
        -- 移動スピード
        funnel.speed = 150
        -- 攻撃状態遷移までのインターバル
        funnel.interval = 3.0
        -- 攻撃可能な間合い
        funnel.attackRange =400
        -- ターゲットとの距離の制限。これ以上近づくとbackする
        funnel.limitRange = 250
        -- モーションの遷移状態
        funnel.motionState = { attack = false, back = false, front = false, idle = false, skill = false, appearance = false}
        -- ステートと対応するキー名
        funnel.stateName = { attack = "attack", back = "back", front = "front", idle = "idle", skill = "skill", appearance = "appearance"}
        -- モーション名
        funnel.motionName = {
            attack = "attack", back = "back", front = "front", idle = "idle",
            skill = "skill", appearance = "appearance", exit = "exit"
        }
        -- z軸の自動補正のためy軸の補正値
        funnel.correctPosY = 3
        -- x座標補正値
        funnel.correctPosX = 55

        -- 各モーションの遷移条件。updateでフラグ判定するとif文のネストだらけでカオスになりそう
        funnel.transitionalCondition = {}
        funnel.transitionalCondition.idle = function (this)
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
        funnel.transitionalCondition.back = function (this)
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
        funnel.transitionalCondition.front = function (this)
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
        funnel.transitionalCondition.attack = function (this)
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
        funnel.checkState = function (this)
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
        funnel.isPlayingSomeMotion = function (this)
            for k, v in pairs(this.motionState) do
                if v then
                    return true
                end
            end

            return false
        end

        -- モーションの遷移状態をリセット
        funnel.ResetMotionState = function (this)
            for k, v in pairs(this.motionState) do
                this.motionState[k] = false
            end
        end

        -- 後退可能かどうか
        funnel.Backable = function (this)
            local distX = self.Vector2.DistanceX(this.unit:getPositionX(), this.targetUnit():getPositionX())
            local isPlayer = this.ownerUnit:getisPlayer();
            local isOutside = (this.unit:getPositionX() > 300 and isPlayer) or (this.unit:getPositionX() < -300 and not isPlayer)
            return distX <= math.abs(this.limitRange) and not isOutside
        end

        -- 攻撃可能かどうか
        funnel.Attackable = function (this)
            local distX = self.Vector2.DistanceX(this.unit:getPositionX(), this.targetUnit():getPositionX())
            local distY = self.Vector2.DistanceY(this.unit:getPositionY(), this.ownerUnit:getPositionY())

            local isPlayer = this.ownerUnit:getisPlayer();
            local isOutside = (this.unit:getPositionX() > 300 and isPlayer) or (this.unit:getPositionX() < -300 and not isPlayer)

            return (distX >= math.abs(this.limitRange) or isOutside)and distX <= math.abs(this.attackRange) + 1e-1 and distY >= -10 and distY <= 10 and this:targetUnit():getInvincibleTime() <= 0
        end

        -- 擬似的なstart関数
        funnel.start = function (this, animationIndex)
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

            this.unit:setPosition(spawnPosX + correctPosX, spawnPosY + correctPosY)

            this:takeAppearance(animationIndex)
        end

        -- 擬似的なupdate関数
        funnel.update = function (this, deltatime)
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
        funnel.takeAppearance = function (this, index)
            if not this.motionState.appearance then
                local motionName = string.format("%s%d", this.motionName.appearance, index)
                this.motionState.appearance = true
                this.unit:takeAnimation(0, motionName, true)
            end
        end

        -- appearanceモーション完了
        funnel.onCompleteAppearance = function (this, index)
            local motionName = string.format("%s%d", this.motionName.appearance, index)
            this.motionState.appearance = false
            this:takeIdle()
        end

        -- idleモーションの再生
        funnel.takeIdle = function (this)
            if not this.motionState.idle then
                this.motionState.idle = true
                this.unit:takeAnimation(0, this.motionName.idle, true)
            end
        end

        -- idleモーション完了
        funnel.onCompleteIdle = function (this)
            this.motionState.idle = false
        end

        -- frontモーションの再生
        funnel.takeFront = function (this, deltatime)
            this:moveToTarget(deltatime)

            if this.motionState.front == false then
                this:ResetMotionState()
                this.unit:takeAnimation(0, this.motionName.front, true)
                this.motionState.front = true
            end
        end

        -- frontモーション完了
        funnel.onCompleteFront = function (this)
            this.motionState.front = false
        end

        -- backモーションの再生
        funnel.takeBack = function (this)
            -- backモーションが再生中でなければ再生する
            if not this.motionState.back then
                -- backモーションはidleモーションからしか遷移せず、モーション終了を待たず再生されるので明示的にリセット
                this:ResetMotionState()
                this.motionState.back = true
                this.unit:takeAnimation(0, this.motionName.back, true)
            end
        end

        -- backモーション完了
        funnel.onCompleteBack = function (this)
            this.motionState.back = false
        end

        -- attackモーションの再生
        funnel.takeAttack = function (this, index)
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
        funnel.onCompleteAttack = function (this, index)
            this.motionState.attack = false
        end

        -- skillモーションの再生
        funnel.takeSkill = function (this, index)
            local motionName = string.format("%s%d", this.motionName.skill, index)
            this.unit:takeAnimation(0, motionName, true)
            -- skill発動時は強制的にアニメーションを再生させるので、他の遷移状態はクリアする
            this:ResetMotionState()
            this.motionState.skill = true
        end

        -- skillモーションの完了
        funnel.onCompleteSkill  = function (this, index)
            this.motionState.skill = false
        end

        funnel.takeExit = function (this)
            this.unit:takeAnimation(0, this.motionName.exit, false)
        end

        -- 子ユニットに追従するorbitSystemを生成する
        funnel.addOrbit = function (this, str)
            -- addOrbitSystemWithFile()で呼び出したユニットからはaddOrbitSystem()が呼び出せないっぽい
            -- 他に解決法がないので親ユニットから呼び出す
            local orbit = this.ownerUnit:addOrbitSystem(str, 0)
            local  x = this.unit:getPositionX()
            local y = this.unit:getPositionY()

            orbit:setPosition(x, y)
            --通常攻撃ならスキルをリセット
            if str == "lion2attack1" then
                orbit:setActiveSkill(10);
            end
            --skill1なら威力配分
            if str == "lion2skill1" then
                orbit:setDamageRateOffset(1/2);
                orbit:setBreakRate(1/2);
            end
        end

        -- ターゲットへの移動
        funnel.moveToTarget = function (this, deltatime)
            local currentPosX = this.unit:getPositionX()
            local currentPosY = this.unit:getPositionY()

            local targetPosX = this.targetUnit():getPositionX()
            local targetPosY = this.ownerUnit:getPositionY()

            local isPlayer = this.ownerUnit:getisPlayer()
            local attackRange = this.attackRange
            if isPlayer == false then
                attackRange = attackRange * -1
            end

            local heading = self.Vector2.new(targetPosX - currentPosX + attackRange, targetPosY - currentPosY)
            local direction = heading:normalized()

            local movePos = self.Vector2.new(currentPosX + direction.x * this.speed * deltatime, currentPosY + direction.y * this.speed * deltatime)

            this.unit:setPosition(movePos.x, movePos.y)
        end

        -- 座標をリセット
        funnel.resetPosition = function (this)
            local x = this.ownerUnit:getPositionX()
            local y = this.ownerUnit:getPositionY()

            this.unit:setPosition(x, y)
        end
        return funnel
    end
    return;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    local arg = nil
    arg = string.match(event.spineEvent, "onCompleteAppearance(%w+)")
    if arg ~= nil then
        self.funnel:onCompleteAppearance(tonumber(arg))
    end

    arg = string.match(event.spineEvent, "onCompleteIdle")
    if arg ~= nil then
        self.funnel:onCompleteIdle()
    end

    arg = string.match(event.spineEvent, "onCompleteFront")
    if arg ~= nil then
        self.funnel:onCompleteFront()
    end

    arg = string.match(event.spineEvent, "onCompleteAttack(%w+)")
    if arg ~= nil then
        self.funnel:onCompleteAttack(tonumber(arg))
    end

    arg = string.match(event.spineEvent, "onCompleteBack")
    if arg ~= nil then
        self.funnel:onCompleteBack()
    end

    arg = string.match(event.spineEvent, "onCompleteSkill(%w+)")
    if arg ~= nil then
        self.funnel:onCompleteSkill(tonumber(arg))
    end

    arg = string.match(event.spineEvent, "addOrbit(%w+)")
    if arg ~= nil then
        self.funnel:addOrbit(arg)
    end

    arg = string.match(event.spineEvent, "startFunnel")
    if arg ~= nil then
        self:startFunnel(event.unit)
    end
    return 1
end

---------------------------------------------------------------------------------
-- GB_endWave
---------------------------------------------------------------------------------
function class:endWave(event)
    if event.unit:getisPlayer() then
        self.funnel.unit:takeAnimation(0, self.funnel.motionName.exit, false)
        self.funnel.unit:setEndAnimationName("");
        self.funnel = nil
    end
    return 1;
end
---------------------------------------------------------------------------------
-- GB_startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:createFunnel(event.unit, 1)
    return 1;
end

---------------------------------------------------------------------------------
-- GB_update
---------------------------------------------------------------------------------
function class:GB_update(event)
    if self.funnel ~= nil then
        self.funnel:update(event.deltaTime)
    end
    return;
end

function class:startFunnel(unit)
    self:createFunnel(unit, 1)
    return;
end

function class:createFunnel(unit,number)
    if self.funnel ~= nil then
        return
    end

    local funnelUnit = unit:addOrbitSystemWithFile(self.orbitSystemFileName, "idle")

    if funnelUnit == nil then
        return 1
    end

    self.funnel = self.Funnel.new(funnelUnit, unit)

    local isPlayer = unit:getisPlayer()
    self.funnel:start(number)
    return;
end

---------------------------------------------------------------------------------
-- GB_takeAttack
---------------------------------------------------------------------------------
function class:GB_takeAttack(event)
    local target = event.unit:getTargetUnit()

    if target ~= nil and self.funnel ~= nil then
        self.funnel.targetNum = target:getIndex();
    end
    return;
end

---------------------------------------------------------------------------------
-- GB_takeSkill
---------------------------------------------------------------------------------
function class:GB_takeSkill(event)
    if self.funnel ~= nil then
        self.funnel:takeSkill(event.index)
        if event.index == 1 then
            event.unit:setDamageRateOffset(1/2);
            event.unit:setBreakRate(1/2);
            -- 【MEGA_D-9763】ボスの技の予告に、技 1 で子のライオン（ファンネル）が出す弾 lion2skill1 の取り分（1/2・1 本）を入れる（本体の取り分を下げた残り。表示専用。古いアプリには無いので確かめてから呼ぶ）
            if event.unit.announceSkillDamage then event.unit:announceSkillDamage(3, 1/2, 1) end
        end
    end
    return;
end

---------------------------------------------------------------------------------
-- GB_dead
---------------------------------------------------------------------------------
function class:GB_dead(event)
    self:destroyFunnel()
    return;
end

function class:destroyFunnel(event)
    if self.funnel ~= nil then
        self.funnel:takeExit()
    end

    self.funnel = nil
    return;
end

class:publish();

return class;