--@additionalEnemy,2000647,2000648
--@additionalItem,102432500
--[[
    試練の回廊 １８階/被験体γ−２
]]

local ipairs = ipairs
local print = print
local table = table

local register = register
local megast = megast
local LuaUtilities = LuaUtilities
local BattleControl = BattleControl

function new(id)
    local DEBUG = false
    local LOG_LABEL = "被験体γ−２"
    local log = function(str, ...) print((("Lua(%s): "):format(LOG_LABEL) .. str):format(...)) end
    local debug = function(...) if DEBUG then log(...) end end

    log("Called `new` with `%s`", id)

    local returnOne = function() return 1 end
    local returnDamage = function(self, unit, enemy, value) return value end
    local cls = {
        param = {
            version = 1.3,
            isUpdate = true
        },
        -- メッセージ
        MESSAGES = {
            START = {
                {R=0, G=196, B=196, TIME=5, TEXT=summoner.Text:fetchByEnemyID(2000646).mess1},
                {R=0, G=196, B=196, TIME=5, TEXT=summoner.Text:fetchByEnemyID(2000646).mess2},
                {R=0, G=196, B=196, TIME=5, TEXT=summoner.Text:fetchByEnemyID(2000646).mess3},
            },
            BUFF1 = {
                {R=0, G=196, B=196, TIME=5, TEXT=summoner.Text:fetchByEnemyID(2000646).mess4},
            },
            BUFF2 = {
                {R=0, G=196, B=196, TIME=5, TEXT=summoner.Text:fetchByEnemyID(2000646).mess5},
                {R=0, G=196, B=196, TIME=5, TEXT=summoner.Text:fetchByEnemyID(2000646).mess6},
            },
        },
        -- 強化バフ
        BUFFS = {
            BUFF1 = {
                -- 与ダメージアップ
                {ID=200064601, TYPE=17, VALUE=125, TIME=9999, ICON=26, ANIMATION=50009},
            },
            BUFF2 = {
                -- 被ダメージダウン
                {ID=200064602, TYPE=21, VALUE=-65, TIME=9999, ICON=20},
                -- 攻撃速度アップ
                {ID=200064603, TYPE=28, VALUE=30, TIME=9999, ICON=7},
            },
        },
        ENEMY_ID_TABLE = {
            [1] = 2000647, -- コールド
            [2] = 2000647, -- コールド
            [3] = 2000648, -- ゴルネコキング
        },
        MAX_ENEMY_INDEX = 6,
        -- スキル効果番号
        ATTACK_NUMBERS = {1, 2, 3},
        -- 奥義効果番号
        SKILL_NUMBERS = {6, 7},
        -- (スキル|奥義)効果番号 => アニメーション番号
        ANIMATION_NUMBERS = {
            -- attack[N]
            [1] = 1, -- アッパー
            [2] = 2, -- ３連爪
            [3] = 3, -- 大噛みつき
            [4] = 4, -- キャッチ投げ
            [5] = 5, -- 怒りモーション
            -- skill[N]
            [6] = 1, -- マッドプレデター
            [7] = 2, -- クリムゾンビーティング
        },
        -- 怒り状態になるHP
        BUFF1_HP = 0.6,
        BUFF2_HP = 0.2,
        -- SPの増加量
        SP_RISE_VALUE = 20,
        -- アイテムスキルID
        ITEM_ID = 102432500, -- 吹雪
        -- 何回攻撃したらアイテムを使うか
        ITEM_INTERVAL = 8,
        -- 何回攻撃したらキャッチ投げするか
        SLAM_INTERVAL = 5,
        -- アイテムを使うときのアニメーション
        ANIMATION_TO_USE_ITEM = "attack5",
        -- 捕まえるときの最小ダメージ
        GRAB_MIN_DAMAGE = 31,
        -- 捕まえるときの最大ダメージ
        GRAB_MAX_DAMAGE = 99,
        -- キャッチ投げのヒットタイプ
        SLAM_HIT_TYPE = 2,
        -- キャッチ投げの効果番号
        SLAM_EFFECT_NUMBER = 4,
        -- 怒りモーションの効果番号
        ANGRY_EFFECT_NUMBER = 5,
        -- 怒り状態かどうか
        buffed1 = false,
        buffed2 = false,
        -- アイテムスキルのインスタンス
        equipment = nil,
        -- 再帰呼び出しのコントロール
        propagation = {
            takeAttack = false,
            takeSkill = false,
        },
        -- 再帰呼び出しへ渡すパラメータ
        dataTransfer = {
            takeAttack = {effectNumber = 0},
            takeSkill = {effectNumber = 0},
        },
        -- キャッチ投げインスタンス
        grab = nil,
        -- 攻撃した回数
        numAttacks = 0,
    }

    -- デフォルトのイベントハンドラに関数を割り当てる
    for i, name in ipairs({
        "receive1",
        "start", "update", "dead", "run",
        "startWave", "endWave",
        "excuteAction",
        "takeIdle", "takeFront", "takeDamage", "takeBack", "takeBreake", "takeAttack", "takeSkill"
    }) do
        cls[name] = returnOne
    end
    for i, name in ipairs({"takeDamageValue", "attackDamageValue", "takeBreakeDamageValue"}) do
        cls[name] = returnDamage
    end

    -- キャッチ投げクラス
    -- @using megast.Battle
    local Grab = {
        STATUS_BEGAN = 1, -- キャッチ投げ開始
        STATUS_GRABBED = 2, -- キャッチ投げ成功、ユニットを1体捕まえた状態
        STATUS_FAILED = 3, -- キャッチ投げ失敗
        STATUS_ENDED = 4, -- キャッチ投げ終了

        MAIN_BONE_NAME = "MAIN",
        HAND_BONE_NAME = "R_hand_attack4",

        SLAM_ORBIT_NAME = "GrowndHit",
        SLAM_LOCK_TIME = 1,

        DEBUFFS = {
            {ID=-10, TYPE=89, VALUE=1, TIME=10, ICON=0},
        },
    }

    -- キャッチ投げクラス/コンストラクタ
    function Grab:new(grabber, slamHitType, slamEffectNumber)
        local self_ = setmetatable({
            status = self.STATUS_BEGAN,
            grabber = grabber,
            slamHitType = slamHitType,
            slamEffectNumber = slamEffectNumber,
            grabbedUnit = nil,
            grabbedUnitIndex = nil,
            targets = {},
        }, {__index=self})
        return self_
    end

    -- 状態を変更する
    function Grab:setStatus(status)
        self.status = status
    end

    -- ターゲットを追加する
    function Grab:addTarget(unit)
        self.targets[unit] = true
    end

    -- 何もせず終了する
    function Grab:release()
        if self.grabbedUnit ~= nil then
            local grabbedUnitConditions = self.grabbedUnit:getTeamUnitCondition()
            for i, debuff in ipairs(self.DEBUFFS) do
                local foundDebuff = grabbedUnitConditions:findConditionWithID(debuff.ID)
                if foundDebuff ~= nil then
                    grabbedUnitConditions:removeCondition(foundDebuff)
                end
            end
        end
        self:setStatus(self.STATUS_ENDED)
    end

    -- キャッチ投げがヒットしたユニットの中からランダムに捕まえる
    function Grab:grabRandom()
        debug("Called `grabRandom`")
        local hitUnits = {}
        for unit, _ in pairs(self.targets) do
            if unit:getHP() > 0 then
                table.insert(hitUnits, unit)
            end
        end
        local lastIndex = table.maxn(hitUnits)
        if lastIndex < 1 then
            -- ヒットしたユニットがいない場合
            self:setStatus(self.STATUS_FAILED)
        else
            -- ヒットしたユニットがいたら、その中からランダムに捕まえる
            local sampleIndex = LuaUtilities.rand(lastIndex) + 1
            local grabbedUnit = hitUnits[sampleIndex]
            self.grabbedUnit = grabbedUnit
            self.grabbedUnitIndex = grabbedUnit:getIndex()

            -- 捕まえたユニットにデバフを追加する
            local grabbedUnitConditions = grabbedUnit:getTeamUnitCondition()
            for i, debuff in ipairs(self.DEBUFFS) do
                grabbedUnitConditions:addCondition(debuff.ID, debuff.TYPE, debuff.VALUE, debuff.TIME, debuff.ICON)
            end

            self:setStatus(self.STATUS_GRABBED)
        end
    end

    -- 捕まえたユニットの位置を更新する
    function Grab:updateGrabbedUnitPos(dt)
        --debug("Called `updateGrabbedUnitPos`")
        local handPosX = self.grabber:getSkeleton():getBoneWorldPositionX(self.HAND_BONE_NAME) + self.grabber:getPositionX()
        local handPosY = self.grabber:getSkeleton():getBoneWorldPositionY(self.HAND_BONE_NAME) + self.grabber:getPositionY()
        local mainBonePosX = self.grabbedUnit:getSkeleton():getBoneWorldPositionX(self.MAIN_BONE_NAME)
        local mainBonePosY = self.grabbedUnit:getSkeleton():getBoneWorldPositionY(self.MAIN_BONE_NAME)
        local posY = self.grabbedUnit:getPositionY()
        self.grabbedUnit:setPosition(handPosX - mainBonePosX, handPosY - mainBonePosY)
        self.grabbedUnit:getSkeleton():setPosition(0, 0)
    end

    -- ダメージを与える
    function Grab:applyDamage()
        local slamEffect = self.grabber:addOrbitSystem(self.SLAM_ORBIT_NAME, 0)
        local grabbedUnitPosX = self.grabbedUnit:getPositionX()
        local grabbedUnitPosY = self.grabbedUnit:getPositionY()
        local grabbedUnitConditions = self.grabbedUnit:getTeamUnitCondition()
        -- ヒットストップ
        self.grabber:takeHitStop(self.SLAM_LOCK_TIME)
        -- ダメージを与える
        slamEffect:setPosition(grabbedUnitPosX, grabbedUnitPosY)
        slamEffect:setTargetUnit(self.grabbedUnit)
        slamEffect:setHitType(self.slamHitType)
        slamEffect:setActiveSkill(self.slamEffectNumber)
        -- デバフを解除する
        for i, debuff in ipairs(self.DEBUFFS) do
            local foundDebuff = grabbedUnitConditions:findConditionWithID(debuff.ID)
            if foundDebuff ~= nil then
                grabbedUnitConditions:removeCondition(foundDebuff)
            end
        end
        self:setStatus(self.STATUS_ENDED)
    end

    -- event/開始時
    -- アイテムをセットする
    -- @using BattleControl
    debug("Listening to event `start`")
    function cls:start(unit)
        debug("Called `start`")
        self.equipment = unit:setItemSkill(0, self.ITEM_ID)
        unit:setSPGainValue(0)
        unit:setAttackDelay(0)
        self:message(self.MESSAGES.START)
        self.hpMarkers = {
            {
                HP = 60,isUsed = false,MARKER = unit:addNumHpMarker(0.6)
            },
            {
                HP = 20,isUsed = false,MARKER = unit:addNumHpMarker(0.2)
            }
        }
        return 1
    end

    -- event/スキルを使ったとき
    -- ATTACK_NUMBERSの中からランダムでスキルを発動する
    debug("Listening to event `takeAttack`")
    function cls:takeAttack(unit, index)
        debug("Called `takeAttack` with index `%s`", index)
        if self.propagation.takeAttack then
            self.propagation.takeAttack = false
            unit:setActiveSkill(self.dataTransfer.takeAttack.effectNumber)
            debug("numAttacks %s -> %s", self.numAttacks, self.numAttacks + 1)
            self.numAttacks = self.numAttacks + 1
            return 1
        elseif self:tryToBoost(unit) then
            -- 怒り状態
            self.propagation.takeAttack = true
            local effectNumber = self.ANGRY_EFFECT_NUMBER
            local animationNumber = self.ANIMATION_NUMBERS[effectNumber]
            debug("Effect `%s`, Animation `attack%s`", effectNumber, animationNumber)
            self.dataTransfer.takeAttack.effectNumber = effectNumber
            unit:takeAttack(animationNumber)
            return 0
        elseif self.numAttacks > 0 and self.numAttacks%self.ITEM_INTERVAL == 0 then
            -- 吹雪＆エネミー召喚
            self:useEquipment(unit)
            self:summonEnemies()
            unit:takeAnimation(0, self.ANIMATION_TO_USE_ITEM, false)
            unit:takeAnimationEffect(0, self.ANIMATION_TO_USE_ITEM, false)
            self.numAttacks = self.numAttacks + 1
            return 0
        elseif self.numAttacks > 0 and self.numAttacks%self.SLAM_INTERVAL == 0 then
            -- キャッチ投げ
            self.propagation.takeAttack = true
            local effectNumber = self.SLAM_EFFECT_NUMBER
            local animationNumber = self.ANIMATION_NUMBERS[effectNumber]
            debug("Effect `%s`, Animation `attack%s`", effectNumber, animationNumber)
            self.dataTransfer.takeAttack.effectNumber = effectNumber
            unit:takeAttack(animationNumber)
            return 0
        else
            -- 通常攻撃
            self.propagation.takeAttack = true
            local effectNumber = self:getSample(self.ATTACK_NUMBERS)
            local animationNumber = self.ANIMATION_NUMBERS[effectNumber]
            debug("Effect `%s`, Animation `attack%s`", effectNumber, animationNumber)
            self.dataTransfer.takeAttack.effectNumber = effectNumber
            unit:takeAttack(animationNumber)
            return 0
        end
    end

    -- event/奥義を使ったとき
    -- SKILL_NUMBERSの中からランダムで奥義を発動する
    debug("Listening to event `takeSkill`")
    function cls:takeSkill(unit, index)
        debug("Called `takeSkill` with index `%s`", index)
        if self.propagation.takeSkill then
            self.propagation.takeSkill = false
            unit:setActiveSkill(self.dataTransfer.takeSkill.effectNumber)
            return 1
        else
            self.propagation.takeSkill = true
            local effectNumber = self:getSample(self.SKILL_NUMBERS)
            local animationNumber = self.ANIMATION_NUMBERS[effectNumber]
            debug("Effect `%s`, Animation `skill%s`", effectNumber, animationNumber)
            self.dataTransfer.takeSkill.effectNumber = effectNumber
            unit:takeSkill(animationNumber)
            return 0
        end
    end

    -- event/ダメージを与えるとき
    function cls:attackDamageValue(unit, enemy, value)
        if self.grab ~= nil and self.grab.status == Grab.STATUS_BEGAN then
            -- キャッチ投げ中ならヒットしたユニットを追加する
            self.grab:addTarget(enemy)
            return LuaUtilities.rand(self.GRAB_MIN_DAMAGE, self.GRAB_MAX_DAMAGE + 1)
        end
        return value
    end

    -- event/フレーム毎の処理
    function cls:update(unit, dt)
        if self.grab ~= nil and self.grab.status == Grab.STATUS_GRABBED then
            -- キャッチ投げ中ならヒットしたユニットを追加する
            self.grab:updateGrabbedUnitPos(dt)
        end
        for _,marker in pairs(self.hpMarkers) do
            local hpPercent = 100 * unit:getHP()/unit:getCalcHPMAX();
            if not marker.isUsed and hpPercent < marker.HP then
                marker.isUsed = true
                unit:removeHpMarker(marker.MARKER)
            end
        end
        return 1
    end

    -- event/Spineなど外部からの呼び出し
    debug("Listening to event `run`")
    function cls:run(unit, name)
        debug("Called `run` with `%s`", name)
        if self[name] == nil then
            debug("Ignored `%s`", name)
        else
            self[name](self, unit)
        end
        return 1
    end

    -- SPを増加させる
    function cls:addSP(unit)
        debug("Called `addSP`")
        unit:addSP(self.SP_RISE_VALUE)
        return 1
    end

    -- キャッチ投げ/開始
    function cls:glabCheckStart(unit)
        debug("Called `glabCheckStart`")
        self.grab = Grab:new(unit, self.SLAM_HIT_TYPE, self.SLAM_EFFECT_NUMBER)
        return 1
    end

    -- キャッチ投げ/ヒットしたユニットを捕まえる
    function cls:tryGlab(unit)
        debug("Called `tryGlab`")
        if self.grab ~= nil and self.grab.status == Grab.STATUS_BEGAN then
            self.grab:grabRandom()
        end
        return 1
    end

    -- キャッチ投げ/終了
    function cls:glabEnd(unit)
        debug("Called `glabEnd`")
        if self.grab ~= nil then
            if self.grab.status == Grab.STATUS_GRABBED then
                self.grab:applyDamage()
            elseif self.grab.status == Grab.STATUS_FAILED then
                self.grab:release()
            end
        end
        return 1
    end

    function cls:takeDamage(unit)
        --ブレイクや気絶などで投げが中断されたらグラブしているユニットを手放す。
        if self.grab ~= nil and self.grab.status == Grab.STATUS_GRABBED then
            self.grab:release()
        end
        return 1;
    end

    -- 配列の数値の中からランダムで１つ取得する
    -- 配列が空の場合はnilを返す
    -- @using LuaUtilities
    function cls:getSample(numbers)
        local lastIndex = table.maxn(numbers)
        if lastIndex < 1 then
            return nil
        end
        local sampleIndex = LuaUtilities.rand(lastIndex) + 1
        local sampleNumber = numbers[sampleIndex]
        return sampleNumber
    end

    -- ランダムに装備を使う
    -- @using LuaUtilities
    function cls:useEquipment(unit)
        debug("Called `useRandomEquipment`")
        unit:takeItemSkill(0)
        self.equipment:setCoolTimer(0)
        return true
    end

    -- エネミーを召喚する
    -- @using megast.Battle
    function cls:summonEnemies()
        local enemyIndex = nil
        local enemyTeam = megast.Battle:getInstance():getEnemyTeam()
        local numSummonedEnemies = 0
        -- 空いてるindexにエネミーを割り当てる
        for i = 0, self.MAX_ENEMY_INDEX do
            local enemy = enemyTeam:getTeamUnit(i)
            local enemyId = self.ENEMY_ID_TABLE[numSummonedEnemies + 1]
            if enemy == nil and enemyId ~= nil then
                enemyTeam:addUnit(i, enemyId)
                numSummonedEnemies = numSummonedEnemies + 1
            end
        end
    end

    -- 条件によって強化する
    function cls:tryToBoost(unit)
        local currentHPRate = unit:getHP()/unit:getCalcHPMAX()
        if not self.buffed1 and currentHPRate <= self.BUFF1_HP then
            self:buff(unit, self.BUFFS.BUFF1)
            self:message(self.MESSAGES.BUFF1)
            self.buffed1 = true
            return true
        end
        if not self.buffed2 and currentHPRate <= self.BUFF2_HP then
            self:buff(unit, self.BUFFS.BUFF2)
            self:message(self.MESSAGES.BUFF2)
            self.buffed2 = true
            return true
        end
        return false
    end

    -- バフ
    function cls:buff(unit, buffs)
        local conditions = unit:getTeamUnitCondition()
        for i, buff in ipairs(buffs) do
            if buff.ANIMATION then
                conditions:addCondition(buff.ID, buff.TYPE, buff.VALUE, buff.TIME, buff.ICON, buff.ANIMATION)
            else
                conditions:addCondition(buff.ID, buff.TYPE, buff.VALUE, buff.TIME, buff.ICON)
            end
        end
    end

    -- メッセージ
    function cls:message(messages)
        for i, message in ipairs(messages) do
            BattleControl:get():pushEnemyInfomation(message.TEXT, message.R, message.G, message.B, message.TIME)
        end
    end

    register.regist(cls, id, cls.param.version)
    return 1
end
