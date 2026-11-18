--[[
    試練の回廊 ２０階/霹翠トニトゥルス

    アビリティ
        クリティカル無効
        状態異常無効
        光ダメージ無効
        光属性キラー

    スキル
        衝撃波 -> 魔法、15%
        ついばみ -> 物理、10%
        ハウリング -> 魔法、20%、SP減少5ずつ5秒間
        羽飛ばし -> 物理、30%、麻痺9秒
        爪ひっかき -> 物理、25%、麻痺5秒
        強制暴風モード -> 未使用

    奥義
        ネポスフルトゥーナ -> 魔法、20%
        プテラボルト -> 魔法、30%、麻痺30秒
        テュノスブランテー -> 物理、50%、麻痺20秒、大ダメージ

    状態
        HP40%
            与ダメージアップ
            攻撃速度アップ

    その他
        戦闘開始時にテュノスブランテーを使う
]]
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local enemy = Bootstrap.createEnemyClass({label="霹翠トニトゥルス", version=1.3, id=2000659})

-- SPの最大値
enemy.SP_MAX_VALUE = 100

-- SPの増加量
enemy.SP_RISE_VALUE = 20

-- (スキル|奥義)効果番号 => アニメーション番号
enemy.ANIMATION_NUMBERS = {
    -- attack[N]
    [1] = 1, -- 衝撃波
    [2] = 2, -- ついばみ
    [3] = 3, -- ハウリング
    [4] = 4, -- 羽飛ばし
    [5] = 5, -- 爪ひっかき
    [6] = 6, -- 強制暴風モード 
    -- skill[N]
    [7] = 1, -- ネポスフルトゥーナ
    [8] = 2, -- プテラボルト
    [9] = 3, -- テュノスブランテー
}

-- スキル確率
enemy.ATTACK_NUMBERS = {
    [1] = 15,
    [2] = 10,
    [3] = 20,
    [4] = 30,
    [5] = 25,
}

-- 奥義確率
enemy.SKILL_NUMBERS = {
    [7] = 20,
    [8] = 30,
    [9] = 50,
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
        HEALTH = 0.4,
        MESSAGES = {
            {COLOR=Color.green, TIME=5, TEXT=enemy.TEXT.BUFF_MESSAGE1},
            {COLOR=Color.green, TIME=5, TEXT=enemy.TEXT.BUFF_MESSAGE2},
        },
        BUFFS = {
            -- 与ダメージアップ
            {ID=200065901, TYPE=17, VALUE=30, TIME=9999, ICON=26, ANIMATION=50009},
            -- 攻撃速度アップ
            {ID=200065902, TYPE=28, VALUE=30, TIME=9999, ICON=7},
        },
    },
}

-- 戦闘開始時に使う奥義
enemy.FIRST_SKILL_NUMBER = 9

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

    event.unit:setSPGainValue(0)
    self.hpMarkers = {
        {
            HP = 40,isUsed = false,MARKER = event.unit:addNumHpMarker(0.4)
        }
    }
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
