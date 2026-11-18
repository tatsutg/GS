--@additionalItem,101561410,101622410,101531310
--[[
    ラ＝リズ魔導研究所/望まぬ決戦/フェン★4

    ソロ専用
    開幕時すぐに奥義を使う
    addSPがコールされたときに33%確率でSPが20たまる、最大値は100
    スキルを使った直後の待機モーションで３種類のアイテムの中からランダムで１つを使う
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
    local LOG_LABEL = "フェン"
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
                {R=0, G=160, B=0, TIME=5, TEXT=summoner.Text:fetchByEnemyID(70614).mess1},
                {R=0, G=160, B=0, TIME=5, TEXT=summoner.Text:fetchByEnemyID(70614).mess2},
            },
        },
        -- スキル効果番号
        ATTACK_NUMBERS = {1, 2, 3},
        -- 奥義効果番号
        SKILL_NUMBERS = {5},
        -- (スキル|奥義)効果番号 => アニメーション番号
        ANIMATION_NUMBERS = {
            -- attack[N]
            [1] = 1,
            [2] = 2,
            [3] = 3,
            -- skill[N]
            [5] = 2,
        },
        -- アイテムを使うときのアニメーション
        ANIMATION_TO_USE_ITEM = "cast",
        -- SPの最大値
        SP_MAX_VALUE = 100,
        -- SPの増加量
        SP_RISE_VALUE = 20,
        -- SPの増加しにくさ
        SP_RISE_WEIGHT = 3,
        -- アイテムスキルID
        ITEM_ID_TABLE = {
            101561410, -- 破塞鎚ダルタリオン 強化度10
            101622410, -- 風樹矛レイ＝ヴィー 強化度10
            101531310, -- ドラケウスボルト 強化度10
        },
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
            self.readyToUse = true
            return 1
        else
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
            local effectNumber = self:getSample(self.SKILL_NUMBERS)
            local animationNumber = self.ANIMATION_NUMBERS[effectNumber]
            debug("Effect `%s`, Animation `skill%s`", effectNumber, animationNumber)
            self.dataTransfer.takeSkill.effectNumber = effectNumber
            unit:takeSkillWithCutin(animationNumber)
            return 0
        end
    end

    -- event/待機時
    -- アイテムが使えるときは使う
    debug("Listening to event `takeIdle`")
    function cls:takeIdle(unit)
        debug("Called `takeIdle`")
        if self.readyToUse then
            self:useRandomEquipment(unit)
            unit:takeAnimation(0, self.ANIMATION_TO_USE_ITEM, false)
            unit:takeAnimationEffect(0, self.ANIMATION_TO_USE_ITEM, false)
            self.readyToUse = false
            return 0
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
        if LuaUtilities.rand(self.SP_RISE_WEIGHT) == 0 then
            unit:addSP(self.SP_RISE_VALUE)
        end
        return 1
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

    register.regist(cls, id, cls.param.version)
    return 1
end
