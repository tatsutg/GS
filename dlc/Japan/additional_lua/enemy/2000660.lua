--[[
    試練の回廊 ２０階/猛餓獣樹ゴロンドーラ

    アビリティ
        クリティカル無効
        状態異常無効
        闇ダメージ無効
        闇耐性キラー

    スキル
        触手突き -> 物理、15%
        踏みつけ -> 物理、10%
        毒ガス -> 魔法、30%、毒15秒、暗闇10秒、病気5秒
        吸い込み -> 魔法、30%、呪い10秒
        トゲ飛ばし -> 物理、15%、麻痺5秒

    奥義
        チューイングローズ -> 物理、60%、HP吸収、与ダメージアップ
        グランドクライ -> 魔法、40%、与ダメージアップ

    状態
        HP50%
            HP吸収量アップ

    その他
        戦闘開始時にグランドクライを使う
]]
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local enemy = Bootstrap.createEnemyClass({label="猛餓獣樹ゴロンドーラ", version=1.3, id=2000660})

-- SPの最大値
enemy.SP_MAX_VALUE = 100

-- SPの増加量
enemy.SP_RISE_VALUE = 20

-- (スキル|奥義)効果番号 => アニメーション番号
enemy.ANIMATION_NUMBERS = {
    -- attack[N]
    [1] = 1, -- 触手突き
    [2] = 2, -- 踏みつけ
    [3] = 3, -- 毒ガス
    [4] = 4, -- 吸い込み
    [5] = 5, -- トゲ飛ばし
    -- skill[N]
    [6] = 2, -- チューイングローズ
    [7] = 3, -- グランドクライ
    [8] = 2, -- チューイングローズ
}

-- スキル確率
enemy.ATTACK_NUMBERS = {
    [1] = 10,
    [2] = 10,
    [3] = 30,
    [4] = 30,
    [5] = 20,
}

-- 奥義確率
enemy.SKILL_NUMBERS = {
    [6] = 60,
    [7] = 40,
}

-- 怒り状態の奥義確率
enemy.SKILL_NUMBERS2 = {
    [7] = 30,
    [8] = 70,
}

-- 戦闘開始時のメッセージ
enemy.START_MESSAGES = {
    {COLOR=Color.green, TIME=5, TEXT=enemy.TEXT.START_MESSAGE1},
    {COLOR=Color.green, TIME=5, TEXT=enemy.TEXT.START_MESSAGE2},
    {COLOR=Color.green, TIME=5, TEXT=enemy.TEXT.START_MESSAGE3},
    {COLOR=Color.green, TIME=5, TEXT=enemy.TEXT.START_MESSAGE4},
}

-- HPによる状態の変化
enemy.STATUS = {
    [1] = {
        HEALTH = 0.5,
        MESSAGES = {
            {COLOR=Color.green, TIME=5, TEXT=enemy.TEXT.BUFF_MESSAGE1},
            {COLOR=Color.green, TIME=5, TEXT=enemy.TEXT.BUFF_MESSAGE2},
        },
        BUFFS = {
            -- 攻撃速度アップ
            {ID=200066011, TYPE=28, VALUE=60, TIME=9999, ICON=7, ANIMATION=50009},
        },
    },
}

-- 戦闘開始時に使う奥義
enemy.FIRST_SKILL_NUMBER = 7

-- チューイングローズ
enemy.DRAIN_SKILL_NUMBER = 8

-- 奥義を打つ毎に加算されるチューイングローズの重み
enemy.DRAIN_SKILL_RISE_VALUE = 5

function enemy:start(event)
    -- 最初の奥義かどうか
    self.isFirstArts = true

    -- バフの状態
    self.currentProgress = 0

    -- 再帰呼び出しのコントロール
    self.propagation = {
        takeAttack = false,
        takeSkill = false,
    }

    -- 再帰呼び出しへ渡すパラメータ
    self.dataTransfer = {
        takeAttack = {effectNumber = 0},
        takeSkill = {effectNumber = 0},
    }
    self.hpMarkers = {
        {
            HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
        }
    }

    event.unit:setSPGainValue(0)
    return 1
end

function enemy:update(event)
    for _,marker in pairs(self.hpMarkers) do
        local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
        if not marker.isUsed and hpPercent < marker.HP then
            marker.isUsed = true
            event.unit:removeHpMarker(marker.MARKER)
        end
    end
    return 1
end

function enemy:startWave(event)
    event.unit:addSP(self.SP_MAX_VALUE)
    event.unit:setAttackDelay(0)
    for _, message in ipairs(self.START_MESSAGES) do
        Utility.messageByEnemy(message.TEXT, message.TIME, message.COLOR)
    end
    return 1
end

function enemy:takeAttack(event)
    self:log("takeAttack")
    if self.propagation.takeAttack then
        self.propagation.takeAttack = false
        event.unit:setActiveSkill(self.dataTransfer.takeAttack.effectNumber)
        return 1
    else
        self.propagation.takeAttack = true
        local effectNumber = Random.sampleWeighted(self.ATTACK_NUMBERS)
        local animationNumber = self.ANIMATION_NUMBERS[effectNumber]
        self:log("Effect `%s`, Animation `attack%s`", effectNumber, animationNumber)
        self.dataTransfer.takeAttack.effectNumber = effectNumber
        event.unit:takeAttack(animationNumber)
        return 0
    end
end

function enemy:takeSkill(event)
    self:log("takeSkill")
    if self.propagation.takeSkill then
        self.propagation.takeSkill = false
        event.unit:setActiveSkill(self.dataTransfer.takeSkill.effectNumber)
        return 1
    else
        self.propagation.takeSkill = true
        local effectNumber = nil
        if self.isFirstArts then
            effectNumber = self.FIRST_SKILL_NUMBER
            self.isFirstArts = false
        elseif self.currentProgress > 0 then
            effectNumber = Random.sampleWeighted(self.SKILL_NUMBERS2)
            -- 徐々にチューイングローズの確率をあげる
            self.SKILL_NUMBERS2[self.DRAIN_SKILL_NUMBER] = self.SKILL_NUMBERS2[self.DRAIN_SKILL_NUMBER] + self.DRAIN_SKILL_RISE_VALUE
        else
            effectNumber = Random.sampleWeighted(self.SKILL_NUMBERS)
        end
        local animationNumber = self.ANIMATION_NUMBERS[effectNumber]
        self:log("Effect `%s`, Animation `skill%s`", effectNumber, animationNumber)
        self.dataTransfer.takeSkill.effectNumber = effectNumber
        event.unit:takeSkill(animationNumber)
        return 0
    end
end

function enemy:run(event)
    if event.spineEvent == "addSP" then
        event.unit:addSP(self.SP_RISE_VALUE)
    end
    return 1
end

function enemy:excuteAction(event)
    self:log("excuteAction")
    local health = Utility.getUnitHealthRate(event.unit)
    for progress, status in ipairs(self.STATUS) do
        self:log("    self.currentProgress: %s", self.currentProgress)
        self:log("    progress: %s", progress)
        self:log("    status.HEALTH: %s", status.HEALTH)
        self:log("    health: %s", health)
        if self.currentProgress < progress and health <= status.HEALTH then
            local conditions = event.unit:getTeamUnitCondition()
            for _, buff in ipairs(status.BUFFS) do
                if buff.ANIMATION then
                    conditions:addCondition(buff.ID, buff.TYPE, buff.VALUE, buff.TIME, buff.ICON, buff.ANIMATION)
                else
                    conditions:addCondition(buff.ID, buff.TYPE, buff.VALUE, buff.TIME, buff.ICON)
                end
            end
            for _, message in ipairs(status.MESSAGES) do
                Utility.messageByEnemy(message.TEXT, message.TIME, message.COLOR)
            end
            self.currentProgress = progress
            self:log("    Change status to %s", self.currentProgress)
        end
    end
    return 1
end

enemy:publish()
return enemy
