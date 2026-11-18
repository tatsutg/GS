--@additionalItem,100801500,102901500
--[[
    ラ＝リズ魔導研究所/望まぬ決戦/ゼイオルグ★5

    ソロ専用
    開幕時すぐに奥義を使う
    attack1とattack2を使った後は後退し、装備スキルを使う
    フェンが死ぬと怒り状態になる
    怒り状態になると、与ダメージ、攻撃速度、クリティカル率が増加する
]]

local ipairs = ipairs
local print = print
local table = table

local register = register
local megast = megast
local LuaUtilities = LuaUtilities
local BattleControl = BattleControl

function new(id)
    local DEBUG = true
    local LOG_LABEL = "ゼイオルグ"
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
                {R=196, G=196, B=0, TIME=5, TEXT=summoner.Text:fetchByEnemyID(70615).mess1},
            },
            BOOST = {
                {R=196, G=196, B=0, TIME=5, TEXT=summoner.Text:fetchByEnemyID(70615).mess2},
                {R=196, G=196, B=0, TIME=5, TEXT=summoner.Text:fetchByEnemyID(70615).mess3},
                {R=196, G=196, B=0, TIME=5, TEXT=summoner.Text:fetchByEnemyID(70615).mess4},
            },
        },
        -- 強化バフ
        BOOST = {
            ANGRY = {
                -- 与ダメージ
                {ID=7061501, TYPE=17, VALUE=360, TIME=9999, ICON=26, ANIMATION=9},
                -- 攻撃速度
                {ID=7061502, TYPE=28, VALUE=20, TIME=9999, ICON=7},
                -- クリティカル率
                {ID=7061503, TYPE=22, VALUE=70, TIME=9999, ICON=11},
            },
        },
        MAX_ENEMY_INDEX = 6,
        -- スキル効果番号
        ATTACK_NUMBERS = {1, 2, 3},
        -- 奥義効果番号
        SKILL_NUMBERS = {5},
        SPECIAL_SKILL_NUMBERS = {4, 6},
        -- (スキル|奥義)効果番号 => アニメーション番号
        ANIMATION_NUMBERS = {
            -- attack[N]
            [1] = 1,
            [2] = 2,
            [3] = 3,
            -- skill[N]
            [4] = 1,
            [5] = 2,
            [6] = 3,
        },
        -- SPの最大値
        SP_MAX_VALUE = 100,
        -- SPの増加量
        SP_RISE_VALUE = 20,
        -- アイテムスキルID
        ITEM_ID_TABLE = {
            100801500, -- 宝剣『リュード・マグス』 強化度0
            102901500, -- 玩飾剣『シャルロット』 強化度0
        },
        -- 終了時に後退する攻撃
        BACK_WHEN_ENDED = {
            [1] = true,
            [2] = true,
        },
        -- アイテムを使うときのアニメーション
        ANIMATION_TO_USE_ITEM = "attack3",
        -- 怒り状態かどうか
        isAngry = false,
        -- 後退するかどうか
        toGoBack = false,
        -- アイテムを使えるかどうか
        readyToUse = false,
        -- アイテムスキルのインスタンス
        equipments = {},
        -- 再帰呼び出しのコントロール
        propagation = {
            takeAttack = false,
            takeSkill = false,
        },
        -- 再帰呼び出しへ渡すパラメータ
        dataTransfer = {
            takeAttack = {effectNumber = 0},
            takeSkill = {effectNumber = 0},
        }
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

    -- event/開始時
    -- アイテムをセットする
    -- @using BattleControl
    debug("Listening to event `start`")
    function cls:start(unit)
        debug("Called `start`")
        for i, itemId in ipairs(self.ITEM_ID_TABLE) do
            debug("Item-Skill-Index is `%s`", i - 1)
            debug("Item ID is `%s`", itemId)
            self.equipments[i] = unit:setItemSkill(i - 1, itemId)
        end
        unit:setSPGainValue(0)
        for i, message in ipairs(self.MESSAGES.START) do
            BattleControl:get():pushEnemyInfomation(message.TEXT, message.R, message.G, message.B, message.TIME)
        end
        return 1
    end

    -- event/Wave開始時
    -- 戦闘開始時に奥義を打つためにSPを最大値にする
    debug("Listening to event `startWave`")
    function cls:startWave(unit, waveNum)
        debug("Called `startWave`")
        unit:addSP(self.SP_MAX_VALUE)
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
            return 1
        else
            self.propagation.takeAttack = true
            local effectNumber = self:getSample(self.ATTACK_NUMBERS)
            local animationNumber = self.ANIMATION_NUMBERS[effectNumber]
            debug("Effect `%s`, Animation `attack%s`", effectNumber, animationNumber)
            self.dataTransfer.takeAttack.effectNumber = effectNumber
            if self.BACK_WHEN_ENDED[effectNumber] then
                self.toGoBack = true
            end
            unit:takeAttack(animationNumber)
            return 0
        end
    end

    -- event/奥義を使ったとき
    -- カットインありで、SKILL_NUMBERSの中からランダムで奥義を発動する
    debug("Listening to event `takeSkill`")
    function cls:takeSkill(unit, index)
        debug("Called `takeSkill` with index `%s`", index)
        if self.propagation.takeSkill then
            self.propagation.takeSkill = false
            unit:setActiveSkill(self.dataTransfer.takeSkill.effectNumber)
            return 1
        else
            self.propagation.takeSkill = true
            local effectNumber = nil
            if index == 2 then
                effectNumber = self:getSample(self.SKILL_NUMBERS)
            else
                effectNumber = self:getSample(self.SPECIAL_SKILL_NUMBERS)
            end
            local animationNumber = self.ANIMATION_NUMBERS[effectNumber]
            debug("Effect `%s`, Animation `skill%s`", effectNumber, animationNumber)
            self.dataTransfer.takeSkill.effectNumber = effectNumber
            if index == 2 then
                unit:takeSkillWithCutin(animationNumber)
            else
                unit:takeSkill(animationNumber)
            end
            return 0
        end
    end

    -- event/待機時
    debug("Listening to event `takeIdle`")
    function cls:takeIdle(unit)
        debug("Called `takeIdle`")
        if self.toGoBack then
            unit:takeBack()
            return 0
        elseif self.readyToUse then
            self:useRandomEquipment(unit)
            unit:takeAnimation(0, self.ANIMATION_TO_USE_ITEM, false)
            unit:takeAnimationEffect(0, self.ANIMATION_TO_USE_ITEM, false)
            self.readyToUse = false
            return 0
        end
        return 1
    end

    -- event/後退時
    debug("Listening to event `takeBack`")
    function cls:takeBack(unit)
        debug("Called `takeBack`")
        if self.toGoBack then
            self.toGoBack = false
            self.readyToUse = true
        end
        return 1
    end

    -- event/全ての行動
    debug("Listening to event `excuteAction`")
    function cls:excuteAction(unit)
        debug("Called `excuteAction`")
        if self:tryToBoost(unit) then
            for i, message in ipairs(self.MESSAGES.BOOST) do
                BattleControl:get():pushEnemyInfomation(message.TEXT, message.R, message.G, message.B, message.TIME)
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
    -- @using LuaUtilities
    function cls:addSP(unit)
        debug("Called `addSP`")
        unit:addSP(self.SP_RISE_VALUE)
        return 1
    end

    -- 条件によって強化する
    function cls:tryToBoost(unit)
        if self.isAngry then
            return false
        end
        local numEnemies = self:getNumEnemies()
        debug("%s enemies", numEnemies)
        if numEnemies > 1 then
            return false
        end
        -- 自分一人になったら怒り状態になる
        local conditions = unit:getTeamUnitCondition()
        for i, boost in ipairs(self.BOOST.ANGRY) do
            if boost.ANIMATION then
                conditions:addCondition(boost.ID, boost.TYPE, boost.VALUE, boost.TIME, boost.ICON, boost.ANIMATION)
            else
                conditions:addCondition(boost.ID, boost.TYPE, boost.VALUE, boost.TIME, boost.ICON)
            end
        end
        self.isAngry = true
        debug("Got angry")
        return true
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
    function cls:useRandomEquipment(unit)
        debug("Called `useRandomEquipment`")
        local lastIndex = table.maxn(self.equipments)
        if lastIndex < 1 then
            return false
        end
        local sampleIndex = LuaUtilities.rand(lastIndex) + 1
        local equipment = self.equipments[sampleIndex]
        debug("Use item `%s`", sampleIndex)
        unit:takeItemSkill(sampleIndex - 1)
        equipment:setCoolTimer(0)
        return true
    end

    -- エネミーの数を取得する
    -- @using megast
    function cls:getNumEnemies()
        local numEnemies = 0
        local enemyTeam = megast.Battle:getInstance():getEnemyTeam()
        for i = 0, self.MAX_ENEMY_INDEX do
            local target = enemyTeam:getTeamUnit(i)
            if target ~= nil then
                numEnemies = numEnemies + 1
            end
        end
        return numEnemies
    end

    register.regist(cls, id, cls.param.version)
    return 1
end
