function new(id)
    print("100364111 new ")
    local instance = {}
    -- 入力受け付けの可否
    instance.waitingForKeyIn = false
    -- クールタイム
    instance.coolTime = 0
    -- 入力受け付け中のロスしたクールタイム
    instance.coolTimeLoss = 0
    -- バフの持続時間
    instance.conditionTime = 120.0
    -- 入力受け付け制御用バフのベースID
    instance.baseConditionId = -10
    -- セットしたバフを管理するテーブル
    instance.conditionIds = {}
    -- セット可能なバフの最大数
    instance.maxCondition = 3
    -- アイコンのID
    instance.iconType = 3
    -- カウンター用クロージャ
    instance.countfunc = nil
    -- 追加入力スキル再生フラグ
    instance.playingAdditionalSkill = false
    -- 追加入力スキルのダメージレート
    instance.damageRate = { 0.25, 0.5, 1.0 }

    --共通変数
    instance.param = {
        version = 1.2,
        isUpdate = 1
    }

    -- バフ管理テーブルのダンプ用デバッグ関数
    instance.dumpTable = function (this)
        local m = table.maxn(this.conditionIds)
        print("付与されているバフの件数 : " .. m)
        for k, v in ipairs(this.conditionIds) do
            print("key :" .. k)
            print("value :" .. v)
        end
    end

    instance.triggerFirstSkill = function (this, unit)
        local currentConditions = table.maxn(this.conditionIds)

        if this.waitingForKeyIn == false then
            -- 付与されているバフが最大数以下であれば新しくバフを付与する
            if (currentConditions < this.maxCondition) then
                local c = this.countfunc(this)
                local buffid = this.baseConditionId - c
                table.insert(this.conditionIds, buffid)
                unit:getTeamUnitCondition():addCondition(buffid, 0, 0, this.conditionTime, this.iconType)
            end
        -- 入力受け付け中であれば派生スキルを発動する
        elseif this.waitingForKeyIn == true then
            this:activateAdditionalSkill(unit, currentConditions)
        end
    end

    -- バフID制御用のカウンター
    instance.counter = function (this)
        local i = 0
        return function ()
            i = i + 1
            if i > this.maxCondition then
                i = 1
            end
            return i
        end
    end

    -- 派生スキルの発動
    instance.activateAdditionalSkill = function (this, unit, currentConditions)
        this.playingAdditionalSkill = true
        if currentConditions == 1 then
            unit:takeSkill(3)
        elseif currentConditions == 2 then
            unit:takeSkill(4)
        elseif currentConditions == 3 then
            unit:takeSkill(5)
        end
    end

    instance.onCompleteAdditionalSkill = function (this, unit)
        this.playingAdditionalSkill = false
        this:removeAllConditions(unit)
        this:finishWaitingForKeyIn(unit)
    end

    -- 派生スキル用に設定したバフを全て解除する
    instance.removeAllConditions = function (this, unit)
        for i = table.maxn(this.conditionIds), 1, -1 do
            if this.conditionIds[i] then
                local condition = unit:getTeamUnitCondition():findConditionWithID(this.conditionIds[i])
                if (condition ~= nil) then
                    unit:getTeamUnitCondition():removeCondition(condition)
                end
                table.remove(this.conditionIds, i)
            end
        end
    end

    -- 入力受け付けを可能にする
    instance.startWaitingForKeyIn = function (this, unit)
        unit:setSkillCoolTime(this.coolTime)
        this.waitingForKeyIn = true
        return 1
    end

    -- 入力受け付けを終了する
    instance.finishWaitingForKeyIn = function (this, unit)
        this.waitingForKeyIn = false
        -- クールタイムをリセットする
        unit:resetSkillCoolTime()
        unit:setSkillCoolTime(unit:getSkillCoolTime() - this.coolTimeLoss);
        return 1
    end

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

        arg = string.match(str, "startWaitingForKeyIn")
        if arg ~= nil then this:startWaitingForKeyIn(unit) end

        arg = string.match(str, "finishWaitingForKeyIn")
        if arg ~= nil then this:finishWaitingForKeyIn(unit) end

        arg = string.match(str, "onCompleteAdditionalSkill")
        if arg ~= nil then this:onCompleteAdditionalSkill(unit) end

        return 1
    end

    instance.endWave = function (this , unit , waveNum)
        return 1
    end

    instance.startWave = function (this , unit , waveNum)
        return 1
    end

    instance.update = function (this , unit , deltatime)
        this.coolTimeLoss = this.coolTimeLoss + deltatime;
        return 1
    end

    instance.attackDamageValue = function (this , unit , enemy , value)
        local damageValue = value
        local conditions = table.maxn(this.conditionIds)
        if this.playingAdditionalSkill and conditions > 0 then
            local rate = this.damageRate[conditions]
            damageValue = damageValue * rate
        end

        return damageValue
    end

    instance.takeDamageValue = function (this , unit , enemy , value)
        return value
    end

    instance.start = function (this , unit)
        this.countfunc = this.counter(this)
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
        if index == 1 then
            this:triggerFirstSkill(unit)
            this.coolTimeLoss = 0;

            if this.waitingForKeyIn then
                return 0
            end
        end

        return 1
    end

    instance.takeDamage = function (this , unit)
        -- 追加入力スキル発動中に仰け反りが発生したら、Spine上から呼んでいるonCompleteAdditionalSkillが呼ばれなくなる恐れがあるので明示的にリセットする
        if this.playingAdditionalSkill then
            this:onCompleteAdditionalSkill(unit)
        end

        -- 追加入力受け付け中に仰け反りが発生したら追加入力受け付けのみキャンセルする
        if this.waitingForKeyIn then
            this:finishWaitingForKeyIn(unit)
        end

        return 1
    end

    instance.dead = function (this , unit)
        return 1
    end

    register.regist(instance,id,instance.param.version)
    return instance.param.isUpdate;
end