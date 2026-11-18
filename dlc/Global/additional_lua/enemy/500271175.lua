--@additionalItem,100691499
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
    -- castに必要なクールタイム
    instance.coolTime = { cast = 30 }
    -- クールタイム経過時間
    instance.elapsed = { cast = 0 }
    -- 所持アイテムリスト
    instance.inventory = { index = 0, id = 100691499 }
    -- 遷移状態と結びつくキーの管理テーブル
    instance.keyNames = { attack1 = "attack1", attack3 = "attack3", skill1 = "skill1", skill2 = "skill2" }
    -- 遷移状態管理テーブル
    instance.transitions = { attack1 = false, attack3 = false, skill1 = false, skill2 = false }
    -- アクション名管理テーブル
    instance.actions = { cast = "cast", attack = "attack" }
    -- 通常攻撃のindex管理テーブル
    instance.attackIndexes = { attack1 = 1, attack3 = 3 }
    -- skillのindex管理テーブル
    instance.skillIndexes = { skill1 = 1, skill2 = 2 }
    -- 行動ごとの発生確率管理テーブル
    instance.behaviorProbs = { { value = "cast", prob = 60 }, { value = "attack", prob = 40 } }
    -- 津城攻撃ごとの発生確率管理テーブル
    instance.attackProbs = { { key = "attack1", prob = 50 }, { key = "attack3", prob = 50 } }
    -- HPのボーダーライン。これを下回ると該当アクションを行うようになる
    instance.healthBorder = { attack3 = 1.0, skill2 = 0.6 }
    -- 攻撃アクションによるSP増加量
    instance.addSPValue = 20
    -- 吸引実行フラグ
    instance.isRunningVacuum = false
    -- 吸引ターゲット管理テーブル
    instance.vacuumTargetUnits = {}
    -- 吸引スピード
    instance.vacuumSpeed = 300
    -- 一度きりのskill実行フラグ
    instance.onceShotSkill = false
    -- activeSkillのリスト
    instance.activeSkillList = { attack1 = 1, attack2 = 2, attack3 = 3, skill1 = 4, skill2 = 5 }

    -- 初期化
    instance.initialize = function (this, unit)
        unit:setSPGainValue(0)
        unit:setBurstPoint(0)
        unit:setItemSkill(this.inventory.index, this.inventory.id)
        this:setActiveSkill(unit)
        this.hpMarkers = {
            {
                HP = 50,isUsed = false,MARKER = unit:addNumHpMarker(0.5)
            }
        }
    end

    -- activeSkillのセット
    instance.setActiveSkill = function (this, unit)
        for k, v in ipairs(this.activeSkillList) do
            unit:setActiveSkill(v)
        end
    end

    -- SP付与
    instance.addSP = function (this, unit)
        unit:addSP(this.addSPValue)
    end

    -- cast実行
    instance.takeCast = function (this, unit)
        this:resetCastCoolTime()
        unit:takeAnimation(0, "cast", false)
        -- setしたアイテムスキルを発動
        unit:takeItemSkill(this.inventory.index)
        -- 元々の行動はキャンセル
        return 0
    end

    -- castのクールタイムリセット
    instance.resetCastCoolTime = function (this)
        this.elapsed.cast = 0
    end

    -- HP低下状態かどうか
    instance.isDegradedHealth = function (this, unit, key)
        local perOfHealth = unit:getHP() / unit:getCalcHPMAX()
        return this.healthBorder[key] > perOfHealth
    end

    -- 行動の遷移
    instance.transitionBehavior = function (this, unit, index)
        local item = this:randomPickItem(this.behaviorProbs)
        -- cast可能ならcast
        if this.elapsed.cast >= this.coolTime.cast and this:anyTransition() == false then
            if item.value == this.actions.cast then return this:takeCast(unit) end
        end

        -- それ以外なら通常攻撃に遷移
        return this:activateAttack(unit, index)
    end

    -- 通常攻撃の遷移
    instance.transitionAttack = function (this, unit, index)
        local item = nil
        if this:isDegradedHealth(unit, this.keyNames.attack3) then
            -- HP低下状態なら確率でattack1もしくはattack3に遷移
            item = this:randomPickItem(this.attackProbs)
            for _,marker in pairs(this.hpMarkers) do
                local hpPercent = 100 * unit:getHP()/unit:getCalcHPMAX();
                if not marker.isUsed and hpPercent < marker.HP then
                    marker.isUsed = true
                    unit:removeHpMarker(marker.MARKER)
                end
            end
        else
            item = unpack(this.attackProbs)
        end

        if item ~= nil then
            this.transitions[item.key] = true
            unit:takeAttack(this.attackIndexes[item.key])
        end
    end

    -- 通常攻撃の有効化
    instance.activateAttack = function (this, unit, index)
        local key = string.format("attack%d", index)
        if this.transitions[key] then
            this.transitions[key] = false
            -- タイミング的にここでsetActiveSkillして問題ないのか、検証できないので分からない。
            -- activeSkillは使い捨てとのことなので、まとめてリセットするのはたぶん問題ないはず
            this:setActiveSkill(unit)
            return 1
        end

        this:transitionAttack(unit, index)

        return 0
    end

    -- skillの遷移
    instance.transitionSkill = function (this, unit, index)
        unit:setBurstPoint(0)
    -- HPが60パーセント以下でskill2を発動していなければskill2発動
        if this:isDegradedHealth(unit, this.keyNames.skill2) and this.onceShotSkill == false then
            this.onceShotSkill = true
            this.transitions.skill2 = true
            unit:takeSkill(this.skillIndexes.skill2)
            return
        end

        this.transitions.skill1 = true
        unit:takeSkill(this.skillIndexes.skill1)
    end

    -- skillの有効化
    instance.activateSkill = function (this, unit, index)
        local key = string.format("skill%d", index)
        -- ループ防止
        if this.transitions[key] then
            this.transitions[key] = false
            -- タイミング的にここでsetActiveSkillして問題ないのか、検証できないので分からない。
            -- activeSkillは使い捨てとのことなので、まとめてリセットするのはたぶん問題ないはず
            this:setActiveSkill(unit)
            return 1
        end

        this:transitionSkill(unit, index)

        return 0
    end

    -- 現在遷移中の状態があるかどうか
    instance.anyTransition = function (this)
        for k, v in ipairs(this.transitions) do
            if v then return true end
        end

        return false
    end

    -- 遷移状態のリセット
    instance.resetTransition = function (this)
        for k, v in ipairs(this.transitions) do
            this.transitions[k] = false
        end
    end

    -- ランダム選択
    instance.randomPickItem = function (this, ...)
        local total = 0

        for i, obj in pairs(...) do
            total = total + obj.prob
        end

        local randv = LuaUtilities.rand(0,total)

        for i, obj in pairs(...) do
            randv = randv - obj.prob

            if randv < 0 then
                return obj
            end
        end

        local item = unpack(...)

        return item
    end

    -- バキューム開始トリガ
    instance.onStartVacuum = function (this, unit)
        this.isRunningVacuum = true
        local megastInstance = nil
        local team = nil

        megastInstance = megast.Battle:getInstance()
        if megastInstance ~= nil then
            team = megastInstance:getTeam(not unit:getisPlayer())
        end

        for i = 0, 5 do
            targetUnit = nil
            if team ~= nil then
                targetUnit = team:getTeamUnit(i)
            end
            if unit ~= nil then
                table.insert(this.vacuumTargetUnits, targetUnit)
            end
        end
    end

    -- バキューム完了トリガ
    instance.onCompleteVacuum = function (this, unit)
        this.isRunningVacuum = false
        this.vacuumTargetUnits = {}
    end

    -- バキューム実行
    instance.takeVacuum = function (this, unit, deltatime)
        for i, targetUnit in pairs(this.vacuumTargetUnits) do
            if targetUnit ~= nil then
                local currentPosX = unit:getPositionX()

                local targetPosX = targetUnit:getPositionX()
                local targetPosY = targetUnit:getPositionY()

                local heading = Vector2.new(currentPosX - targetPosX, 0)

                if math.abs(heading.x) <= 200 then
                    local direction = heading:normalized()

                    local movePos = Vector2.new(targetPosX + direction.x * this.vacuumSpeed * deltatime, targetPosY)

                    targetUnit:setPosition(movePos.x, movePos.y)
                end
            end
        end
    end

    --共通変数
    instance.param = {
          version = 1.2,
          isUpdate = true
    }

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

        local arg = nil

        arg = string.match(str, "onStartVacuum")
        if arg ~= nil then this:onStartVacuum(unit) end

        arg = string.match(str, "onCompleteVacuum")
        if arg ~= nil then this:onCompleteVacuum(unit) end

        arg = string.match(str, "addSP")
        if arg ~= nil then this:addSP(unit) end

        return 1
    end

    instance.endWave = function (this , unit , waveNum)
        return 1
    end

    instance.startWave = function (this , unit , waveNum)
        return 1
    end

    instance.update = function (this , unit , deltatime)
        this.elapsed.cast = this.elapsed.cast + deltatime
        if this.isRunningVacuum then this:takeVacuum(unit, deltatime) end
        return 1
    end

    instance.attackDamageValue = function (this , unit , enemy , value)
        return value
    end

    instance.takeDamageValue = function (this , unit , enemy , value)
        return value
    end

    instance.start = function (this , unit)
        this:initialize(unit)
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
        --次に出る攻撃のactiveSkillを設定
        if index == 1 then
            unit:setActiveSkill(this.activeSkillList.attack1);
        elseif index == 2 then
            unit:setActiveSkill(this.activeSkillList.attack2);
        else
            unit:setActiveSkill(this.activeSkillList.attack3);
        end
        return this:transitionBehavior(unit, index)
    end

    instance.takeSkill = function (this,unit,index)
        --次に出る攻撃のactiveSkillを設定
        if index == 1 then
            unit:setActiveSkill(this.activeSkillList.skill1);
        elseif index == 2 then
            unit:setActiveSkill(this.activeSkillList.skill2);
        end
        return this:activateSkill(unit, index)
    end

    instance.takeDamage = function (this , unit)
        -- のけ反ったらすべての遷移状態をオフにする
        this:resetTransition()
        -- のけ反ったらバキューム中断
        if this.isRunningVacuum then
            this:onCompleteVacuum()
        end

        return 1
    end

    instance.dead = function (this , unit)
        return 1
    end

    register.regist(instance,id,instance.param.version)
    return 1
end