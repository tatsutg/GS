local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="モキュオンチャレンジ_モキュキュキュオン", version=2.7, id=502041311});
class:inheritFromUnit("unitBossBase");

---unit_id 側のLua。エネミー 20851301 は enemy/20851301.lua を置かず、このファイルを読む
---（超ダキュオン unit/502031511.lua と同じ方式。unit_id 502041311 を使うエネミーはすべてこれを共有する）
---a（層数）は同じwaveにいるシャウラ（層ごとのエネミー、level＝層数）から取り、HPもLuaで再定義する

---シャウラの unit_id（a を取る相手の検索に使う）
class.SHAULA_UNIT_ID = 104147312;

---EFのアニメーション接頭辞（本体spineが 502041311 の1種類なので 1-）
class.EF_PREFIX = "1-";

---気絶・麻痺・氷結の付与で上げる耐性に氷結耐性（59/108）も含めるか
---（112/113 の状態異常耐性は燃焼・氷結を対象外とするため）
class.RESIST_UP_INCLUDES_FREEZE = true;

---プレイヤーが受ける持続ダメージの倍率（設定マスター CONF_DoT_OFFSET_EvP。Lua からは読めないので値を写す）
---毒の秒間ダメージ ＝ 付与値 × この倍率 なので、付与値はこれで割り戻す
class.DOT_OFFSET_EVP = 0.1;

--使用する通常攻撃とその確率（スキル1 50% / スキル2 40% / スキル3 10%）
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 40, ATTACK3 = 10 }
    }
}

--使用する奥義とその確率（奥義なし。takeSkill は待機に戻す）
class.SKILL_SET_LIST  = {
    DEFAULT = {}
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,    ---スキル1 通常攻撃（attack1）
    ATTACK2 = 2,    ---スキル2 ウィンドブロウ（skill1）
    ATTACK3 = 3     ---スキル3 ウィンドブラスト（skill2）
}

class.cutInSkill = {
}

function class:setBuffBoxList()
    ---気絶・麻痺・氷結を付与されるたびに状態異常耐性アップ（重複・アイコンに数字）
    self.RESIST_BUFF_BOX_LIST = {
        [1] = {
            ID = 208510011,
            BUFF_ID = 112,  --状態異常耐性
            VALUE = self.GD.resistUpValue,
            DURATION = 999999,
            ICON = 67,
            MAX = 99
        },
        [2] = {
            ID = 208510012,
            BUFF_ID = 113,  --状態異常回避率
            VALUE = self.GD.resistUpValue,
            DURATION = 999999,
            ICON = 0,
            MAX = 99
        },
        [3] = {
            ID = 208510013,
            BUFF_ID = 59,   --氷結耐性
            VALUE = self.GD.resistUpValue,
            DURATION = 999999,
            ICON = 0,
            MAX = 99
        },
        [4] = {
            ID = 208510014,
            BUFF_ID = 108,  --氷結回避率
            VALUE = self.GD.resistUpValue,
            DURATION = 999999,
            ICON = 0,
            MAX = 99
        }
    }
    ---タイマー1周ごとの前進速度アップ（速度はLuaで管理。アイコンと数字の表示用）
    self.SPEED_UP_BUFF_BOX = {
        ID = 208510015,
        BUFF_ID = 0,
        VALUE = 0,
        DURATION = 999999,
        ICON = 34,
        MAX = 99
    }
    ---スキル3中のダメージ無効化無効
    self.ANTI_BARRIER_BUFF_BOX = {
        ID = 208510016,
        BUFF_ID = 132,  --無効化解除
        VALUE = 100,
        DURATION = 999999,
        ICON = 0
    }
    ---スキル2：永続毒[レベル×30/秒]（VALUE は a が確定してから付与時に入れる）
    self.POISON_BUFF_BOX = {
        ID = 208510017,
        BUFF_ID = 90,   --毒
        VALUE = 0,
        DURATION = 999999,
        ICON = 80
    }
end

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
    ---シャウラの分もここで出す
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下・ブレイク耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "モキュキュキュオンにダメージを与える程ダメージ上限アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "一定時間経過で前進速度アップ：燃焼で遅延、気絶・麻痺・氷結で停止", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "シャウラ：リーダー以外CRIダメージ耐性", COLOR = Color.yellow})
    }
    self.SKILL3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "ウィンドブラスト：ダメージ無効化無効", COLOR = Color.red})
    }
    self.SETHP_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SETHP_MESSAGE1 or "1HITのダメージ上限：%d", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SETHP_MESSAGE2 or "スーパーCRIダメージ上限：%d", COLOR = Color.yellow})
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

        ---HP：100 × a^2 + 80000 × a + 100000
        hpPower2 = 100,
        hpPower1 = 80000,
        hpBase = 100000,

        ---ダメージ上限（α / スパクリβ）と上限アップ率
        normalDamageMaxValue = 9999,
        spCriDamageMaxValue = 30000,
        killCountRate = 0.1,        ---モキュオン1体撃破ごと
        setHpCountRate = 0.4,       ---setHP100 1回ごと

        mokyuScale = 2,             ---サイズ
        hpBarHeightOffset = 0,      ---頭上HPバーの高さ補正（0なら触らない）
        moveSpeed = 5.0,            ---前進速度
        moveSpeedUp = 0.5,          ---タイマー1周ごとの前進速度アップ量
        limitX = 300,               ---前進上限
        kagenX = -300,              ---後退下限
        backMagic = 2.0,            ---魔法ヒット時の後退
        backMagicCri = 2.5,         ---魔法クリティカル時の後退
        backMagicSpCri = 3.0,       ---魔法スーパークリティカル時の後退
        backDead = 10.0,            ---HP0（setHP100）時の後退
        fixDamageLevelDiv = 5,      ---固定ダメージの係数 = レベル / この値（切り上げ）
        poisonRate = 50,            ---スキル2の毒付与率
        poisonValuePerLevel = 300,   ---スキル2の毒ダメージ（レベル × この値 / 秒）
        resistUpValue = 20,         ---気絶・麻痺・氷結付与ごとの状態異常耐性アップ量

        ---前進加速タイマー
        tgTimer = 20,
        tgLimit = 999,
        tgIconNum1 = 34,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        tgBurnSpeed = 0.5           ---燃焼中のタイマー速度
    });
    self:dump(self.GD);

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
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
    self:setBuffBoxList();
    self:initAttackWeight({DEFAULT = 100});

    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.saveBP = 0;
    self.currentAttackIndex = 0;
    self.poisonCheckList = {};

    event.unit:getSkeleton():setScale(self.GD.mokyuScale);
    if self.GD.hpBarHeightOffset ~= 0 then
        event.unit:setHPBarHeightOffset(self.GD.hpBarHeightOffset);
    end
    event.unit.m_IgnoreHitStopTime = 999999;
    ---攻撃は update の attackManager が attackDelay 秒ごとに出す（AIの行動は excuteAction で止めている）
    event.unit:setAttackDelay(self.GD.attackDelay);

    ---a（層数）とHP。同じwaveのシャウラがまだ居ない場合は startWave でやり直す
    self.level = event.unit:getLevel();
    self.levelInitialized = false;
    self:initLevel(event.unit);

    ---前進後退（startWave で開始位置を取る）
    self.moveReady = false;
    self.startX = nil;
    self.posX = nil;
    self.attackTimer = 0;
    self.speedUpCount = 0;

    ---気絶・麻痺・氷結の付与検知
    self.badStatusFlg = {};

    ---スキル3のダメージ無効化無効
    self.skill3Active = false;
    self.skill3Started = false;
    self.skill3Timer = 0;

    ---前進加速タイマー
    self.timeIndex = nil;
    self.timeSpeedDefault = 1;

    self:showMessage(self.START_MESSAGE_LIST);
    return 1;
end

---同じチームのシャウラ（ボス）
function class:findShaula()
    local team = self.gameUnit:getTeam();
    for i = 0, 7 do
        local target = team:getTeamUnit(i);
        if target ~= nil and target:getUnitID() == self.SHAULA_UNIT_ID and target:getIsBoss() then
            return target;
        end
    end
    return nil;
end

---シャウラのレベルをaとして取り、HPを再定義する
function class:initLevel(unit)
    if self.levelInitialized then
        return;
    end
    local shaula = self:findShaula();
    if shaula == nil then
        return;
    end
    self.levelInitialized = true;
    self.level = shaula:getLevel();
    local HP = self.GD.hpPower2 * self.level * self.level + self.GD.hpPower1 * self.level + self.GD.hpBase;
    unit:setBaseHP(HP);
    unit:setHP(HP);
end

---------------------------------------------------------------------------------
-- チャレンジ全体の持ち越しデータ（wave をまたぐのでグローバルに持つ）
-- モキュオン enemy/20851211.lua（層別の親）・シャウラ enemy/20851101.lua と共有
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
    self:initLevel(event.unit);
    self:initMove(event.unit);
    return 1;
end

---開始位置の確定とタイマー生成
function class:initMove(unit)
    if self.moveReady then
        return;
    end
    self.moveReady = true;
    self.startX = unit:getPositionX();
    self.posX = self.startX;
    self.attackTimer = 0;

    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit, self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeedDefault = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
end

---------------------------------------------------------------------------------
-- excuteAction（移動も攻撃もLuaで制御する）
---------------------------------------------------------------------------------
function class:excuteAction(event)
    if self:isStop(event.unit) then
        return 0;
    end
    event.unit.m_IgnoreHitStopTime = 999999;
    event.unit:takeFront();
    event.unit:setUnitState(kUnitState_none);
    return 0;
end

---気絶・麻痺・氷結中か
function class:isStop(unit)
    local condition = unit:getTeamUnitCondition();
    return condition:findConditionWithType(89) ~= nil
        or condition:findConditionWithType(91) ~= nil
        or condition:findConditionWithType(96) ~= nil;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    local unit = event.unit;
    unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    unit:getSkeleton():setPosition(0,0);

    if not self.moveReady then
        ---startWave が来なかった場合の保険
        if megast.Battle:getInstance():getBattleState() == kBattleState_active then
            self:initLevel(unit);
            self:initMove(unit);
        end
        return 1;
    end

    self:checkResistUp(unit);
    self:checkSkill3End(unit, event.deltaTime);
    self:extraTimerOperation(unit);

    ---気絶・麻痺・氷結中と被ダメージ中は進行停止
    if unit:getUnitState() == kUnitState_damage or self:isStop(unit) then
        unit:setPositionX(self.posX);
        return 1;
    end

    self:attackManager(unit, event.deltaTime);
    self:positionManager(unit, event.deltaTime);
    return 1;
end

---一定間隔でその場で攻撃（行動の決定はホストのみ。ゲストは receive1 で受ける）
function class:attackManager(unit, deltaTime)
    if self.attackTimer < self.GD.attackDelay then
        self.attackTimer = self.attackTimer + deltaTime;
        return;
    end
    if not megast.Battle:getInstance():isHost() then
        return;
    end
    if unit:getUnitState() ~= kUnitState_none then
        return;
    end
    self.attackTimer = 0;
    unit:takeAttack(1);
end

function class:positionManager(unit, deltaTime)
    if unit:getUnitState() == kUnitState_none and self.posX < self.GD.limitX then
        self:movePosX(self:getMoveSpeed() * deltaTime);
    end
    unit:setPositionX(self.posX);
end

function class:getMoveSpeed()
    return self.GD.moveSpeed + self.GD.moveSpeedUp * self.speedUpCount;
end

---前進（正）・後退（負）。前進上限と後退下限（どちらも絶対座標）で止める
---（範囲の外にいる場合は、その位置より外へ動かさないだけで範囲内へ引き戻しはしない）
function class:movePosX(value)
    if self.posX == nil then
        return;
    end
    if value > 0 then
        self.posX = math.min(self.posX + value, math.max(self.GD.limitX, self.posX));
    else
        self.posX = math.max(self.posX + value, math.min(self.GD.kagenX, self.posX));
    end
end

---開始位置からの前進距離
function class:getMoveDistance()
    if self.posX == nil or self.startX == nil then
        return 0;
    end
    return self.posX - self.startX;
end

---気絶・麻痺・氷結を付与されるたびに状態異常耐性アップ
function class:checkResistUp(unit)
    local badStatusIDs = {89,91,96};
    for i = 1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local isActive = unit:getTeamUnitCondition():findConditionWithType(targetID) ~= nil;
        if isActive and not self.badStatusFlg[targetID] then
            self:addResistUp(unit);
        end
        self.badStatusFlg[targetID] = isActive;
    end
end

function class:addResistUp(unit)
    self:execAddBuff(unit,self.RESIST_BUFF_BOX_LIST[1]);
    self:execAddBuff(unit,self.RESIST_BUFF_BOX_LIST[2]);
    if self.RESIST_UP_INCLUDES_FREEZE then
        self:execAddBuff(unit,self.RESIST_BUFF_BOX_LIST[3]);
        self:execAddBuff(unit,self.RESIST_BUFF_BOX_LIST[4]);
    end
end

---前進加速タイマー：燃焼で遅延、気絶・麻痺・氷結で停止（重複しても遅延・停止は重ならない）
function class:extraTimerOperation(unit)
    if self.timeIndex == nil then
        return;
    end
    local speed = self.timeSpeedDefault;
    if self:isStop(unit) then
        speed = 0;
    elseif unit:getTeamUnitCondition():findConditionWithType(97) ~= nil or unit:getTeamUnitCondition():findConditionWithType(208) ~= nil then
        speed = self.timeSpeedDefault * self.GD.tgBurnSpeed;
    end

    -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
    if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= speed then
        megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex, speed);
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
-- ※ C++ はチームの getBoss()（ボスのうち index が最大の生存ユニット）に送る。
--   モキュキュキュオンは「通常」なので、通常はシャウラ側から callLuaMethod("mokyuTimerRound") で転送されてくる
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    self:timerRound(event.unit);
    return event.count;
end

---タイマー1周で前進速度アップ
function class:timerRound(unit)
    self.speedUpCount = self.speedUpCount + 1;
    self:execAddBuff(unit,self.SPEED_UP_BUFF_BOX);
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "mokyuTimerRound" then
        self:timerRound(event.unit);
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
-- シャウラ撃破時以外は戦闘不能にならず setHP100
-- （0を返すと C++ が死亡処理を取り消す。直撃・継続ダメージ・マルチの受信ダメージのどれでHP0になっても通る）
---------------------------------------------------------------------------------
function class:dead(event)
    if self:getChallengeState().allowMokyuDeath then
        return 1;
    end
    self:revive(event.unit);
    return 0;
end

---ダメージ上限アップギミック：HP全回復＋状態異常回復＋後退＋上限アップ
function class:revive(unit)
    unit:setHP(unit:getCalcHPMAX());
    self:refreshAll(unit);
    local state = self:getChallengeState();
    state.setHpCount = state.setHpCount + 1;
    self:movePosX(-self.GD.backDead);
    self:showFormatMessage(self.SETHP_MESSAGE_LIST[1], math.floor(self:getNormalDamageMax()));
    self:showFormatMessage(self.SETHP_MESSAGE_LIST[2], math.floor(self:getSpCriDamageMax()));
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

    self.currentAttackIndex = event.index;
    self.poisonCheckList = {};
    if event.index == 2 then
        event.unit:setNextAnimationName("skill1");
        event.unit:setNextAnimationEffectName(self.EF_PREFIX .. "skill1"); ---EFのアニメーション名に気をつける
    end
    if event.index == 3 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName(self.EF_PREFIX .. "skill2"); ---EFのアニメーション名に気をつける
        self:startSkill3(event.unit);
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

---スキル3：このスキル中、敵のダメージ無効化無効（HIT関係なく）
function class:startSkill3(unit)
    self:execAddBuff(unit,self.ANTI_BARRIER_BUFF_BOX);
    self.skill3Active = true;
    self.skill3Started = false;
    self.skill3Timer = 0;
    self:showMessage(self.SKILL3_MESSAGE_LIST);
end

---スキル3の攻撃が終わったら無効化解除を外す
function class:checkSkill3End(unit, deltaTime)
    if not self.skill3Active then
        return;
    end
    if unit:getUnitState() == kUnitState_attack then
        self.skill3Started = true;
        return;
    end
    self.skill3Timer = self.skill3Timer + deltaTime;
    ---攻撃状態を観測できないまま1秒経った場合も外す（保険）
    if self.skill3Started or self.skill3Timer > 1 then
        local cond = unit:getTeamUnitCondition():findConditionWithID(self.ANTI_BARRIER_BUFF_BOX.ID);
        if cond ~= nil then
            unit:getTeamUnitCondition():removeCondition(cond);
        end
        self.skill3Active = false;
    end
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

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    return self:calcAttackDamage(event.enemy, event.value);
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    return self:calcAttackDamage(event.enemy, event.value);
end

---[元のダメージ＋前進距離×レベル係数]。レベル係数は a/5 の切り上げ。距離がマイナスなら通常ダメージのみ
function class:calcAttackDamage(target, value)
    if self.currentAttackIndex == 2 and target ~= nil then
        self:checkPoison(target);
    end
    local distance = self:getMoveDistance();
    if distance > 0 then
        value = value + distance * math.ceil(self.level / self.GD.fixDamageLevelDiv);
    end
    return value;
end

---スキル2：50%の確率で永続毒。1回の攻撃で1ユニットにつき1回だけ抽選する
---（マルチで二重に抽選しないよう、被弾したユニットの持ち主の端末だけが抽選する）
function class:checkPoison(target)
    local targetUnit = self:getAncestorUnit(target);
    if not targetUnit:isMyunit() then
        return;
    end
    local index = targetUnit:getIndex();
    if self.poisonCheckList[index] then
        return;
    end
    self.poisonCheckList[index] = true;
    if math.random(100) <= self.GD.poisonRate then
        self.POISON_BUFF_BOX.VALUE = self.GD.poisonValuePerLevel * self.level / self.DOT_OFFSET_EVP;
        self:execAddBuff(targetUnit,self.POISON_BUFF_BOX);
    end
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if event.value <= 0 then
        return event.value;
    end
    local info = event.unit:getTeamUnitCondition():getDamageAffectInfo();

    ---1HITのダメージ上限（スパクリは別上限）
    local damageMax = info.superCritical and self:getSpCriDamageMax() or self:getNormalDamageMax();
    if event.value > damageMax then
        event.value = damageMax;
    end

    ---魔法ヒットで後退
    if self:isMagicAttribute(info.skillAttribute) then
        self:pushBack(info);
    end
    return event.value;
end

---魔法の判定はデータ側の魔法耐性（skill_effect.lua の id_3）と同じく完全一致
---（物魔スキル kAttributeType_all は含めない。クリティカルは別フラグなので属性はそのまま）
function class:isMagicAttribute(attribute)
    return attribute == kAttributeType_magic;
end

---魔法ヒット時の後退量（通常 / クリティカル / スーパークリティカル）
function class:pushBack(info)
    local back = self.GD.backMagic;
    if info.superCritical then
        back = self.GD.backMagicSpCri;
    elseif info.critical then
        back = self.GD.backMagicCri;
    end
    self:movePosX(-back);
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用（上限・補正は送信側の takeDamageValue で済んでいる。HP0 は dead で拾う）
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    end
    return event.value;
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit;
    else
        return self:getAncestorUnit(unit:getParentTeamUnit());
    end
end

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- ブレイクしない
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    return 0;
end

----// takeBreake //-----------------------------------------------------------------------------
function class:takeBreake(event)
    return 0;
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList);
        return;
    end
    self:execShowMessage(messageBoxList[index]);
end

function class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox);
    end
end

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
-- バフ関係
--===================================================================================================================
-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

    local oldBuff = nil;
    local count = 1;
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1;
            if count > buffBox.MAX then
                count = buffBox.MAX;
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1); end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2); end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3); end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4); end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5); end
    end

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff);
    end

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end
end

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

---setHP100時の全状態異常回復（テンプレの一覧に上位毒201・上位燃焼208を追加）---
function class:refreshAll(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97,135,201,208};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1
            if count > 100 then
                break
            end
        end
    end
end


class:publish();

return class;
