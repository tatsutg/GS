local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="モキュオンチャレンジ_モキュオン(11周目)", version=2.7, id=20851211});
class:inheritFromUnit("unitBossBase");

---層ごとのエネミー（20851211〜20851300、level＝層数、11〜100周目）の親。20851212〜20851300 は inheritFromEnemy でこのファイルを継承する
---a（層数）は自身の level で持つ

--使用する通常攻撃とその確率（通常雑魚と同様に通常攻撃のみ）
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 }
    }
}

--使用する奥義とその確率（奥義なし。takeSkill は待機に戻す）
class.SKILL_SET_LIST  = {
    DEFAULT = {}
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1     ---スキル1 通常攻撃（attack1）
}

class.cutInSkill = {
}

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    }
    return message;
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "1HITのダメージ上限：%d", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "スーパーCRI時、ダメージ上限３倍", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "一定時間内にモキュオン撃破でダメージ上限アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "防御力アップ・CRIダメージ耐性", COLOR = Color.yellow})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "モキュオン%d体撃破！1HITのダメージ上限：%d", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE2 or "スーパーCRIダメージ上限：%d", COLOR = Color.yellow})
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        startAddSP = 0,
        attackDelay = 5,
        hitStop = 100,

        ---ダメージ上限（α / スパクリβ）と上限アップ率
        normalDamageMaxValue = 9999,
        spCriDamageMaxValue = 30000,
        killCountRate = 0.1,        ---モキュオン1体撃破ごと
        setHpCountRate = 0.4,       ---モキュキュキュオンのsetHP100 1回ごと
        ---クリティカルのtakeDamageValue補正 [0.5 - レベル × 0.05]
        reduceBaseRate = 0.5,
        reduceLevelRate = 0.05,

        selfDestructTime = 10       ---wave開始からこの秒数で自滅
    });
    self:dump(self.GD);

    self.fromHost = false;
    self.gameUnit = event.unit;
    ---a（層数）
    self.level = event.unit:getLevel();
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP);---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    ---wave1 でチャレンジ全体の持ち越しデータを初期化
    if megast.Battle:getInstance():getWaveNum() == 1 then
        self:resetChallengeState();
    end

    self:setMessageBoxList();
    self:initAttackWeight({DEFAULT = 100});

    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.saveBP = 0;

    ---自滅までの計測開始時刻（startWave で入れる）
    self.waveStartTime = nil;
    self.isSelfDestruct = false;
    return 1;
end

---------------------------------------------------------------------------------
-- チャレンジ全体の持ち越しデータ（wave をまたぐのでグローバルに持つ）
-- モキュキュキュオン unit/502041311.lua・シャウラ enemy/20851101.lua と共有
---------------------------------------------------------------------------------
function class:resetChallengeState()
    MOKYUON_CHALLENGE_STATE = {
        killCount = 0,              ---10秒以内に倒したモキュオンの累計
        setHpCount = 0,             ---モキュキュキュオンのsetHP100回数
        allowMokyuDeath = false     ---シャウラ撃破時だけ true（モキュキュキュオンの戦闘不能を許可）
    };
end

function class:getChallengeState()
    if MOKYUON_CHALLENGE_STATE == nil then
        self:resetChallengeState();
    end
    return MOKYUON_CHALLENGE_STATE;
end

---上限アップ率 [1 + 0.1 × モキュオン撃破数 + 0.4 × setHP回数]（加算関係）
function class:getDamageMaxRate()
    local state = self:getChallengeState();
    return 1 + state.killCount * self.GD.killCountRate + state.setHpCount * self.GD.setHpCountRate;
end

function class:getNormalDamageMax()
    return self:floorDamageMax(self.GD.normalDamageMaxValue * self:getDamageMaxRate());
end

function class:getSpCriDamageMax()
    return self:floorDamageMax(self.GD.spCriDamageMaxValue * self:getDamageMaxRate());
end

---上限値は整数に切り捨てる（0.1刻みの率の浮動小数誤差で 30000×1.8 が 53999.99… になるのを防ぐため微小値を足す）
function class:floorDamageMax(value)
    return math.floor(value + 0.000001);
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:initWave(event.unit);
    return 1;
end

---自滅の計測開始と開始時INFO
function class:initWave(unit)
    if self.waveStartTime ~= nil then
        return;
    end
    self.waveStartTime = BattleControl:get():getTime();

    ---INFOは同じwaveのモキュオンのうち index が一番小さい1体だけが出す
    if self:isLeadMokyuon(unit) then
        self:execShowMessage(self.START_MESSAGE_LIST[1]);
        self:showFormatMessage(self.START_MESSAGE_LIST[2], math.floor(self:getNormalDamageMax()));
        self:execShowMessage(self.START_MESSAGE_LIST[3]);
        self:execShowMessage(self.START_MESSAGE_LIST[4]);
        self:execShowMessage(self.START_MESSAGE_LIST[5]);
    end
end

function class:isLeadMokyuon(unit)
    local team = unit:getTeam();
    for i = 0, 7 do
        local target = team:getTeamUnit(i);
        if target ~= nil and target:getEnemyID() == unit:getEnemyID() then
            return target:getIndex() == unit:getIndex();
        end
    end
    return true;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    if self.waveStartTime == nil then
        ---startWave が来なかった場合の保険
        if megast.Battle:getInstance():getBattleState() == kBattleState_active then
            self:initWave(event.unit);
        end
        return 1;
    end
    ---一定時間で自滅してwaveクリア（自滅は撃破数に数えない）
    if not self.isSelfDestruct and BattleControl:get():getTime() - self.waveStartTime >= self.GD.selfDestructTime then
        self.isSelfDestruct = true;
        event.unit:setHP(0);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0);
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    ---時間内の撃破を数える（自滅は数えない）
    if not self.isSelfDestruct then
        local state = self:getChallengeState();
        state.killCount = state.killCount + 1;
        self:showFormatMessage(self.DEAD_MESSAGE_LIST[1], state.killCount, math.floor(self:getNormalDamageMax()));
        self:showFormatMessage(self.DEAD_MESSAGE_LIST[2], math.floor(self:getSpCriDamageMax()));
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackReroll(event.unit);
    end
    self.attackCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false;
        self.gameUnit:setInvincibleTime(0);
        event.unit:addSP(self.saveBP);
        self.saveBP = 0;
    elseif not self.addSpSkipFLG then
        self:addSP(event.unit);
    end
    -----------------------------------
    return 1;
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex();
    ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時、movePatternState()を動かさない---
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK);
    end
    --------------------------------------------------------------------------------------
    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:addSP(unit)
    unit:addSP(self.spValue);
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    ---奥義を持たない。ゲージが溜まっても奥義は撃たずに待機へ戻す
    event.unit:setBurstPoint(0);
    event.unit:takeIdle();
    return 0;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if event.value <= 0 then
        return event.value;
    end
    local info = event.unit:getTeamUnitCondition():getDamageAffectInfo();

    ---1HITのダメージ上限（スパクリは別上限）。補正は上限の後にかける
    local damageMax = info.superCritical and self:getSpCriDamageMax() or self:getNormalDamageMax();
    if event.value > damageMax then
        event.value = damageMax;
    end

    ---クリティカルダメージに補正
    if info.critical or info.superCritical then
        event.value = self:calcLevelReduce(event.value);
    end
    return event.value;
end

---[0.5 - レベル × 0.05] の補正。0以下ならダメージを1にする
function class:calcLevelReduce(value)
    local rate = self.GD.reduceBaseRate - self.GD.reduceLevelRate * self.level;
    if rate <= 0 then
        return 1;
    end
    value = value * rate;
    return value < 1 and 1 or value;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用（上限・補正は送信側の takeDamageValue で済んでいる）
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    end
    return event.value;
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

function class:showFormatMessage(messageBox,...)
    local message = {
        MESSAGE = string.format(messageBox.MESSAGE,...),
        COLOR = messageBox.COLOR,
        DURATION = messageBox.DURATION,
        isPlayer = messageBox.isPlayer
    }
    self:execShowMessage(message);
end

--===================================================================================================================
-- 行動パターン
--===================================================================================================================
function class:movePatternState(SET_LIST,stateBox)
    stateBox.actCount = stateBox.actCount + 1;
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1;
        stateBox.setCount = stateBox.setCount + 1;
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1;
        end
        stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount]);
    end
end

class.STATE_ATTACK = {}
function class:initAttackWeight(...)
    --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
    local attackList = {...};
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT);
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    return tonumber(attackIndex);
end

function class:initState(weightList)
    local state = {};
    state.SET_WEIGHT = weightList;
    state.actCount = 1;
    state.setCount = 1;
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount]);
    return state;
end


class:publish();

return class;
