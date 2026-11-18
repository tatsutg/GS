--@additionalItem,100691499
function new(id)
    local instance = {}
    -- castに必要なクールタイム
    instance.coolTime = { cast = 10, skill = 10 }
    -- 経過時間
    instance.elapsed = { cast = 0, skill = 0 }
    -- 所持アイテムリスト
    instance.inventory = { index = 0, id = 100691499 }
    -- 遷移状態と結びつくキーの管理テーブル
    instance.keyNames = { attack1 = "attack1", skill1 = "skill1", skill3 = "skill3" }
    -- 遷移状態管理テーブル
    instance.transitions = { attack1 = false, skill1 = false, skill3 = false }
    -- アクション名管理テーブル
    instance.actions = { cast = "cast", attack = "attack", skill = "skill" }
    -- 通常攻撃のindex管理テーブル
    instance.attackIndexes = { attack1 = 1 }
    -- skillのindex管理テーブル
    instance.skillIndexes = { skill1 = 1, skill3 = 3 }
    -- アクションごとの発生確率管理テーブル
    instance.behaviorProbs = { { value = "attack", prob = 40 }, { value = "cast", prob = 30 }, { value = "skill", prob = 30 } }
    -- 攻撃アクションによるSP増加量
    instance.addSPValue = 20
    -- 通常skillの発動回数
    instance.skillCount = 0
    -- activeSkillのリスト
    instance.activeSkillList = { attack1 = 1, skill1 = 2, skill2 = 3, skill3 = 4 }

    -- 初期化
    instance.initialize = function (this, unit)
        unit:setSPGainValue(0)
        unit:setBurstPoint(0)
        unit:setItemSkill(this.inventory.index, this.inventory.id)
        this:setActiveSkill(unit)
    end

    -- activeSkillのセット
    instance.setActiveSkill = function (this, unit)
        for k, v in ipairs(this.activeSkillList) do
            unit:setActiveSkill(v)
        end
    end

    -- SP付与
    instance.addSP = function (this, unit)
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

    -- skillのクールタイムリセット
    instance.resetSkillCoolTime = function (this)
        this.elapsed.skill = 0
    end

    -- 行動の遷移
    instance.transitionBehavior = function (this, unit, index)
        local item = this:randomPickItem(this.behaviorProbs)
        -- cast可能ならcastに遷移
        if this.elapsed.cast >= this.coolTime.cast and this:anyTransition() == false then
            if item.value == this.actions.cast then return this:takeCast(unit) end
        end

        -- skill発動可能ならSkillに遷移
        if this.elapsed.skill >= this.coolTime.skill and this:anyTransition() == false then
            if item.value == this.actions.skill then

                this.skillCount = this.skillCount + 1
                -- skill1とskill2を交互に発動する
                local skillIndex = 3
                if this.skillCount % 2 > 0 then
                    skillIndex = 1
                end

                local  key = string.format("skill%d", skillIndex)
                this.transitions[key] = true
                this:resetSkillCoolTime()
                unit:takeSkill(skillIndex)
                return 0
            end
        end

        return this:activateAttack(unit, index)
    end

    -- 通常攻撃の遷移
    instance.transitionAttack = function (this, unit, index)
        -- バリエーションがひとつしかないのでattack1で決め打ち
        this.transitions.attack1 = true
        unit:takeAttack(this.attackIndexes.attack1)
    end

    -- 通常攻撃の有効化
    instance.activateAttack = function (this, unit, index)
        local key = string.format("attack%d", index)
        if this.transitions[key] then
            this.transitions[key] = false
            -- タイミング的にここでsetActiveSkillして問題ないのか、検証できないので分からない。
            -- activeSkillは使い捨てとのことなので、まとめてリセットするのはたぶん問題ないはず
            --this:setActiveSkill(unit)
            return 1
        end

        this:transitionAttack(unit, index)

        return 0
    end

    -- skillの遷移
    instance.transitionSkill = function (this, unit, index)
    end

    -- skillの有効化
    instance.activateSkill = function (this, unit, index)
        local key = string.format("skill%d", index)
        -- ループ防止
        if this.transitions[key] then
            this.transitions[key] = false
            -- タイミング的にここでsetActiveSkillして問題ないのか、検証できないので分からない。
            -- activeSkillは使い捨てとのことなので、まとめてリセットするのはたぶん問題ないはず
            -- this:setActiveSkill(unit)
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
        this.elapsed.skill = this.elapsed.skill + deltatime
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
       local posx = unit:getAnimationPositionX();
       if posx > 50 and unit:getUnitState() ~= kUnitState_move then
           unit:takeBack();
           return 0;
       end
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
        if index == 1 then
            unit:setActiveSkill(this.activeSkillList.attack1);
        end
        return this:transitionBehavior(unit, index)
    end

    instance.takeSkill = function (this,unit,index)
        if index == 1 then
            unit:setActiveSkill(this.activeSkillList.skill1);
        elseif index == 2 then
            unit:setActiveSkill(this.activeSkillList.skill2);
        else
            unit:setActiveSkill(this.activeSkillList.skill3);
        end
        return this:activateSkill(unit, index)
    end

    instance.takeDamage = function (this , unit)
        -- のけ反ったらすべての遷移状態をオフにする
        this:resetTransition()
        return 1
    end

    instance.dead = function (this , unit)
        return 1
    end

    register.regist(instance,id,instance.param.version)
    return 1
end