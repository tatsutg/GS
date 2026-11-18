local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="モキュオンチャレンジ_閃光の文化部長シャウラ(1周目)", version=2.7, id=20851101});
class:inheritFromUnit("unitBossBase");

---層ごとのエネミー（20851101〜20851200、level＝層数）の親。20851102〜20851200 は inheritFromEnemy でこのファイルを継承する
---level＝層数（モキュキュキュオン unit/502041311.lua がこれを a として参照する）。HPはデータ側（層ごと）
---unit_id 104147312 はプレイヤー用Lua（unit/104147312.lua）があるので unit_id 側では共有しない

---モキュキュキュオン（unit/502041311.lua）の unit_id
class.MOKYU_BOSS_UNIT_ID = 502041311;

---EFのアニメーション接頭辞
class.EF_PREFIX = "2-";

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK3 = 100 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL3 = 100 },
        { SKILL5 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,    ---スキル1 通常攻撃（attack1）
    ATTACK2 = 2,    ---スキル2 文化部特製ビーム（skill1）
    ATTACK3 = 3,    ---スキル3 シャウララララビーム（skill2）
    SKILL3 = 4,     ---奥義4 シャウララララ乱射（skill3）
    SKILL5 = 5,     ---奥義5 ハイパー出力ビーム（skill5）
    SKILL6 = 6      ---奥義6 ハイパー出力ビーム（skill5 を流用）
}

---奥義6（HP50%）のみ超奥義カットイン（kBurstType_3）
class.cutInSkill = {
    [6] = 4
}

function class:setBuffBoxList()
    ---奥義6：永続で敵の最大HPダウン（奥義5未発動 / 発動済み で量が変わる）
    self.HP_DOWN_BUFF_BOX_LIST = {
        [1] = {
            ID = 208510001,
            BUFF_ID = 2,    --最大HP割合
            VALUE = self.GD.skill6BuffValue_2,
            DURATION = 999999,
            ICON = 2
        },
        [2] = {
            ID = 208510001,
            BUFF_ID = 2,    --最大HP割合
            VALUE = self.GD.skill6UsedBuffValue_2,
            DURATION = 999999,
            ICON = 2
        }
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
    ---戦闘開始時のINFOはモキュキュキュオン側で出す
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "パーティの最大HPダウン", COLOR = Color.red, isPlayer = true})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "行動速度・奥義ゲージ上昇量アップ", COLOR = Color.yellow})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        }
    }
    self.HP_TRIGGERS = {};
    self.hpMarkers = {};
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger;
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01);
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255);
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist");
            end
        end
    end
end

---HP50%：超奥義カットインで奥義6＆addSP=35＆attack_delay=4（発動から打ち終わるまでブレイク不可・スキップ不可）
function class:hp50(status)
    if status == "use3" then
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 6;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self:refresh(self.gameUnit);
        self.hpSkillFLG = true;
        self.spValue = self.GD.hp50AddSP;
        self.gameUnit:setAttackDelay(self.GD.hp50AttackDelay);
        self:showMessage(self.HP50_MESSAGE_LIST);
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        startAddSP = 0,
        attackDelay = 6,
        hitStop = 100,

        hp50AddSP = 35,
        hp50AttackDelay = 4,

        ---ダメージ上限（α / スパクリβ）と上限アップ率（モキュキュキュオンと同じ挙動）
        normalDamageMaxValue = 9999,
        spCriDamageMaxValue = 30000,
        killCountRate = 0.1,
        setHpCountRate = 0.4,
        ---リーダーは通常ダメージ、リーダー以外はクリティカルの上限をこの倍率にする
        leaderLimitRate = 0.1,

        ---奥義6の最大HPダウン（奥義5未発動 / 発動済み）
        skill6BuffValue_2 = -50,
        skill6UsedBuffValue_2 = -20
    });
    self:dump(self.GD);

    self.fromHost = false;
    self.gameUnit = event.unit;
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

    ---wave1 でチャレンジ全体の持ち越しデータを初期化（1〜10層はシャウラがwave1にいる）
    if megast.Battle:getInstance():getWaveNum() == 1 then
        self:resetChallengeState();
    end

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});

    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false;
    self.hpSkill = 0;
    self.saveBP = 0;

    ---HPトリガー（奥義6）中のブレイク不可
    self.hpSkillFLG = false;
    self.hpSkillRunning = false;
    ---奥義5を一度でも発動したか
    self.isSkill5Used = false;

    ---リーダーのスロット番号（バトル中は変わらないので出現時に1回だけ取る）
    self.leaderIndex = nil;
    self:initLeader();

    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:initLeader();
    return 1;
end

---プレイヤーチームのリーダーを探してスロット番号を覚える（前のwaveで戦闘不能になっていても拾う）
---ソロはデッキでリーダーに設定したユニット、マルチは一番左（index 0）が getIsLeader() で true になる
function class:initLeader()
    if self.leaderIndex ~= nil then
        return;
    end
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 7 do
        local myTeamUnit = myTeam:getTeamUnit(i,true);
        if myTeamUnit ~= nil and myTeamUnit:getIsLeader() then
            self.leaderIndex = myTeamUnit:getIndex();
            return;
        end
    end
end

---攻撃者（オービットは親まで遡った後）がリーダーか
function class:isLeaderUnit(unit)
    self:initLeader();
    if self.leaderIndex == nil then
        return unit:getIsLeader();
    end
    return unit:getisPlayer() and unit:getIndex() == self.leaderIndex;
end

---同じチームのモキュキュキュオン
function class:findMokyuBoss()
    local team = self.gameUnit:getTeam();
    for i = 0, 7 do
        local target = team:getTeamUnit(i);
        if target ~= nil and target:getUnitID() == self.MOKYU_BOSS_UNIT_ID then
            return target;
        end
    end
    return nil;
end

---------------------------------------------------------------------------------
-- チャレンジ全体の持ち越しデータ（wave をまたぐのでグローバルに持つ）
-- モキュキュキュオン unit/502041311.lua・モキュオン enemy/20851211.lua（層別の親）と共有
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

---上限アップ率 [1 + 0.1 × モキュオン撃破数 + 0.4 × setHP回数]
function class:getDamageMaxRate()
    local state = self:getChallengeState();
    return 1 + state.killCount * self.GD.killCountRate + state.setHpCount * self.GD.setHpCountRate;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
-- 前進加速タイマーはモキュキュキュオンのもの。C++ がこちら（getBoss()）に送ってきた場合は転送する
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    local mokyu = self:findMokyuBoss();
    if mokyu ~= nil then
        mokyu:callLuaMethod("mokyuTimerRound", 0);
    end
    return event.count;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill5_orbit" then
        local orbit = event.unit:addOrbitSystem("skill5_orbit",0);
        orbit:setDamageRateOffset(0.5);
        orbit:setBreakRate(0.5);
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
        ---奥義6を打ち終わったらブレイク不可を解除
        if self.hpSkillRunning then
            self.hpSkillRunning = false;
            self.hpSkillFLG = false;
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:killMokyuBoss();
    return 1;
end

---シャウラが倒されたらモキュキュキュオンがいてもクリア扱い
function class:killMokyuBoss()
    self:getChallengeState().allowMokyuDeath = true;
    local mokyu = self:findMokyuBoss();
    if mokyu ~= nil and mokyu:getHP() > 0 then
        mokyu:setHP(0);
    end
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

    event.unit:setDamageRateOffset(1);
    event.unit:setBreakRate(1);

    if event.index == 2 then
        event.unit:setNextAnimationName("skill1");
        event.unit:setNextAnimationEffectName(self.EF_PREFIX .. "skill1"); ---EFのアニメーション名に気をつける
    end

    if event.index == 3 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName(self.EF_PREFIX .. "skill2"); ---EFのアニメーション名に気をつける
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false;
        self:refresh(self.gameUnit); ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
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
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    event.unit:setDamageRateOffset(1);
    event.unit:setBreakRate(1);

    if event.index == 5 then
        event.unit:setDamageRateOffset(0.5);
        event.unit:setBreakRate(0.5);
        self.isSkill5Used = true;
    end

    if event.index == 6 then
        event.unit:setDamageRateOffset(0.5);
        event.unit:setBreakRate(0.5);
        event.unit:setNextAnimationName("skill5");
        event.unit:setNextAnimationEffectName(self.EF_PREFIX .. "skill5"); ---EFのアニメーション名に気をつける
        self:addHpDownBuff();
        self.hpSkillRunning = true;
    end

    ---全ての奥義：パーティの最大HPダウン（奥義4/5の効果はデータ側）
    self:showMessage(self.SKILL_MESSAGE_LIST);

    self.skillCheckFlg = false;
    self.cutInFLG = false;
    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    -- 【MEGA_D-9761】ボスの技の予告に、この技で Lua が作る弾（addOrbitSystem）の取り分を入れる（本体の取り分を下げた残り。表示専用。古いアプリには無いので確かめてから呼ぶ）
    if (event.index == 5 or event.index == 6) and event.unit.announceSkillDamage then event.unit:announceSkillDamage(3, 0.5, 1) end
    return 1
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex();
    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill;
        self.hpSkill = 0;
    else
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL);
    end

    if self.cutInSkill[skillIndex] ~= nil then
        unit:takeSkillWithCutin(tonumber(skillIndex),self.cutInSkill[skillIndex]);
    else
        unit:takeSkill(tonumber(skillIndex));
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

function class:takeSkillFromHost(unit,index)
    self.fromHost = true;
    if self.cutInSkill[index] ~= nil then
        unit:takeSkillWithCutin(index,self.cutInSkill[index]);
    else
        unit:takeSkill(index);
    end
end

---奥義6：奥義5を一度も発動していなければ最大HP50%ダウン、発動していれば20%ダウン（永続・HIT関係なく）
function class:addHpDownBuff()
    local buffBox = self.isSkill5Used and self.HP_DOWN_BUFF_BOX_LIST[2] or self.HP_DOWN_BUFF_BOX_LIST[1];
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
        end
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    return event.value;
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    return event.value;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    if event.value > 0 then
        local info = event.unit:getTeamUnitCondition():getDamageAffectInfo();
        ---1HITのダメージ上限（リーダーギミック込み）
        event.value = self:limitDamageValue(enemyUnit,info,event.value);
    end
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

---リーダーギミック
---リーダー    : クリティカルの上限は規定どおり、通常ダメージの上限は規定の1/10
---リーダー以外 : クリティカルの上限は規定の1/10、通常ダメージの上限は規定どおり
function class:limitDamageValue(enemyUnit,info,value)
    local isCritical = info.critical or info.superCritical;
    local damageMax = self:floorDamageMax((info.superCritical and self.GD.spCriDamageMaxValue or self.GD.normalDamageMaxValue) * self:getDamageMaxRate());
    local isLeader = self:isLeaderUnit(enemyUnit);
    if (isCritical and not isLeader) or (not isCritical and isLeader) then
        damageMax = self:floorDamageMax(damageMax * self.GD.leaderLimitRate);
    end
    return value > damageMax and damageMax or value;
end

---上限値は整数に切り捨てる（0.1刻みの率の浮動小数誤差で 30000×1.8 が 53999.99… になるのを防ぐため微小値を足す）
function class:floorDamageMax(value)
    return math.floor(value + 0.000001);
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用（上限・補正は送信側の takeDamageValue で済んでいる）
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    end
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value;
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01;
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit); ---停止系状態異常除去(このタイミングでないとたまにバグる)
            return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value);
        end
    end
    return value;
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true;
    return unit:getHP() - border + 1;
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
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false;
        return 0;
    end
    ---HPトリガー発動から打ち終わるまでブレイク不可
    if self.hpSkillFLG then
        return 0;
    end
    return event.value;
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    if self.hpSkillFLG then
        return 0;
    end
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01;
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0;
        end
    end
    return 1;
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

function class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i]);
    end
end

function class:execShowMessage(messageBox)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

--===================================================================================================================
--トリガー
--===================================================================================================================
function class:hpTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            if not trigger.isEnableSkip then
                ---通常マーカーはブレイク中は発動しない
                if not unit:isBreak() then
                    self:execTrigger(index);
                end
            else
                ---ブレイクスルー
                self:execTrigger(index);
            end
        end
    end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return;
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3;
    local action = "use" .. receiveNumber;
    self.TRIGGERS[index].used = true;

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP],true);
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index);
        return;
    end

    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP]);
    end

    self.TRIGGERS[index].action(action);
    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index);
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive3(トリガー時ゲスト側)
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true;
    self.TRIGGERS[args.arg].action("use3");
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP]);
    return 1
end

---------------------------------------------------------------------------------
-- receive5(トリガースキップ時ゲスト側)
---------------------------------------------------------------------------------
function class:receive5(args)
    self.TRIGGERS[args.arg].used = true;
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP],true);
    end
    return 1;
end

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


class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...};
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT);
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    return tonumber(skillIndex);
end

function class:initState(weightList)
    local state = {};
    state.SET_WEIGHT = weightList;
    state.actCount = 1;
    state.setCount = 1;
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount]);
    return state;
end

---トリガー時停止系状態異常除去（HPギミックが状態異常で発動できないことを防ぐ）---
function class:refresh(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0;
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1;
            if count > 100 then
                break;
            end
        end
    end
end


class:publish();

return class;
