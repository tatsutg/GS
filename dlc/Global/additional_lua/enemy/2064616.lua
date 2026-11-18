--@additionalEnemy,2064617
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="魔族の遺跡12層_HARD_ハイゴブル", version=2.8, id=2064616});
class:inheritFromUnit("unitBossBase");

---召喚するゴブルのエネミーID（NORMALは子ファイルで上書きする）
class.SUMMON_ENEMY_ID = 2064617;

--使用する通常攻撃とその確率
--スキル1 -> 繰り返し
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK2 = 100 },                              ---スキル1 ヒートスイング
    },
}

--使用する奥義とその確率
--奥義2 -> 繰り返し
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 },                               ---奥義2 サウザンドストライク
    },
}

class.ACTIVE_SKILLS = {
    ATTACK2 = 1,    ---ヒートスイング       (skill1のアニメを流用)
    SKILL2  = 2,    ---サウザンドストライク (skill2)
    SKILL3  = 3,    ---ミリオンズストライク (skill2のアニメを流用／HPフラグ専用)
}

class.cutInSkill = {
}


--------[[バフ]]--------
function class:setBuffBoxList()
    ---ゴブル撃破カウント（ゴブル側の dead() がこのバフの数値を加算する）
    self.GOBURU_COUNT_BUFF = {
        [1] = {
            ID = 206461601,
            BUFF_ID = 0,                        ---効果なし・カウント保持専用
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
            MAX = 99,
        },
    }

    ---ゴブル1体撃破ごとの与ダメージアップ
    self.DMG_UP_BUFF_LIST = {
        [1] = {
            ID = 206461602,
            BUFF_ID = 17,                       ---与ダメージ
            VALUE = self.GD.goburuDeadDmgUp,
            DURATION = 999999,
            ICON = 26,
            MAX = 99,                           ---重複＆アイコンに数字表示
        },
    }

    ---ハイゴブル討伐報酬（VALUEは撃破時に経過時間から算出して上書きする）
    self.REWARD_BUFF_LIST = {
        [1] = {
            ID = 206461603,
            BUFF_ID = 13,                       ---攻撃力
            VALUE = 0,
            DURATION = 999999,
            ICON = 3,
        },
        [2] = {
            ID = 206461604,
            BUFF_ID = 15,                       ---防御力
            VALUE = 0,
            DURATION = 999999,
            ICON = 5,
        },
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
    ---戦闘開始時
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "ゴブルがいると被ダメージ軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ゴブルが倒されるとダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ハイゴブルを早く倒すほどパーティの攻撃力・防御力アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "無効化・庇われているユニット以外からの被ダメージ軽減", COLOR = Color.yellow}),
    }

    ---ハイゴブル撃破時（ユニット側）
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "パーティの攻撃力・防御力%d%%アップ", COLOR = Color.white, isPlayer = true}),
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
            isEnableSkip = true                         ---ブレイクスルー（青のHPマーカー）
        },
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

function class:hp50(status)
    if status == "use3" then
        self:refresh(self.gameUnit);                                ---停止系状態異常除去
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;                                       ---奥義3 ミリオンズストライク
            self.saveBP = self.gameUnit:getBurstPoint();             ---直前の奥義ゲージを引き継ぐ
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(self.GD.hpInvincibleTime);   ---打ち終わるまで無敵
        self.hpSkillFLG = true;
        self:summonGoburu(self.gameUnit,self.GD.hp50SummonNum);      ---ゴブルを4体召喚
    end
end


---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        ---基本
        addSP = 25,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 4,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効

        ---ダメージ耐性
        resistDmgRate = 0.1,        --無効化なし／庇われていないユニットからの被ダメージ倍率
        goburuDmgRate = 0.1,        --ゴブルが場にいる間の被ダメージ倍率（上記と乗算）

        ---召喚ギミック
        summonNum = 1,              --奥義2発動ごとに召喚する数
        summonMax = 6,              --場に維持できるゴブルの最大数
        hp50SummonNum = 4,          --HP50%フラグで召喚するゴブルの数
        goburuDeadDmgUp = 50,       --ゴブル1体撃破ごとの与ダメージアップ%

        ---HPフラグ
        hpInvincibleTime = 10,      --HPフラグ奥義中の無敵時間

        ---討伐報酬（攻撃力・防御力 [rewardBase - 経過秒×rewardDecay]%／最低保証 rewardMin%）
        rewardBase = 200,           --基礎値%
        rewardDecay = 2,            --経過1秒あたりの減少%
        rewardMin = 10,             --最低保証%
    };
end


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, self:getGimmickDefault());
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

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false;
    self.breakFlg = false;
    self.hpSkill = 0;
    self.saveBP = 0;
    self.hpSkillFLG = false;

    ---召喚ギミック
    self.friendCount = 0;
    self.goburuKillCount = 0;               ---与ダメージアップに反映済みの撃破数
    self.rewardDone = false;                ---討伐報酬の二重付与防止

    ---撃破カウント保持バフ（このバフの存在が「カウント対象」の判定になる）
    self:execAddBuff(event.unit,self.GOBURU_COUNT_BUFF[1]);
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.GOBURU_COUNT_BUFF[1].ID);
    if cond ~= nil then
        cond:setNumber(0);
        megast.Battle:getInstance():updateConditionView();
    end

    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    self:findFriend();
    self:goburuKillCheck();

    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end


--===================================================================================================================
-- 召喚ギミック
--===================================================================================================================
function class:summon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i,unitID);
                break;
            end
        end
    end
end

---指定した数だけ召喚する（敵スロットに空きが無い分は召喚されない）
function class:summonGoburu(unit,num)
    for i = 1, num do
        self:summon(unit,self.SUMMON_ENEMY_ID);
    end
end

---奥義2発動時の召喚（場の上限まで）
function class:summonBySkill(unit)
    self:findFriend();
    for i = 1, self.GD.summonNum do
        if self.friendCount + i > self.GD.summonMax then
            break;
        end
        self:summon(unit,self.SUMMON_ENEMY_ID);
    end
end

function class:findFriend()
    self.friendCount = 0;
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil and myTeamUnit:getEnemyID() == self.SUMMON_ENEMY_ID then
            self.friendCount = self.friendCount + 1;
        end
    end
end

---ハイゴブルが倒された場合はゴブルも自動でdead処理
function class:killAllGoburu()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i);
        if u ~= nil and u:getEnemyID() == self.SUMMON_ENEMY_ID then
            u:setHP(0);
        end
    end
end

---撃破カウントをバフから読む（バフが無ければ0）
function class:getGoburuKillCount()
    local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.GOBURU_COUNT_BUFF[1].ID);
    if cond == nil then
        return 0;
    end
    return cond:getNumber();
end

---撃破カウントの増分を与ダメージアップへ反映する
function class:goburuKillCheck()
    local killCount = self:getGoburuKillCount();
    while self.goburuKillCount < killCount do
        self.goburuKillCount = self.goburuKillCount + 1;
        self:execAddBuff(self.gameUnit,self.DMG_UP_BUFF_LIST[1]);
    end
end


--===================================================================================================================
-- ダメージ耐性の判定
--===================================================================================================================
---無効化バリア（状態タイプ98）を持っている、または庇われている
---※状態タイプ128は「庇われている側」が持ち、getProtectTarget() が「庇っている側」のindexを返す
function class:isNullifyOrProtected(unit)
    local cond = unit:getTeamUnitCondition();
    if cond:findConditionWithType(98) ~= nil then
        return true;
    end
    if cond:findConditionWithType(128) ~= nil then
        return true;
    end
    return false;
end


--===================================================================================================================
-- ハイゴブル討伐報酬
--===================================================================================================================
---攻撃力・防御力 [rewardBase - 経過秒×rewardDecay]%（最低保証 rewardMin%）
function class:calcRewardRate()
    local sec = math.floor(BattleControl:get():getTime());
    local rate = self.GD.rewardBase - sec * self.GD.rewardDecay;
    if rate < self.GD.rewardMin then
        rate = self.GD.rewardMin;
    end
    return math.floor(rate);
end

function class:execReward(rate)
    if self.rewardDone then
        return;
    end
    self.rewardDone = true;
    self.REWARD_BUFF_LIST[1].VALUE = rate;
    self.REWARD_BUFF_LIST[2].VALUE = rate;
    self:unitAddBuff(self.REWARD_BUFF_LIST[1]);
    self:unitAddBuff(self.REWARD_BUFF_LIST[2]);
    self:showCountMessage(self.DEAD_MESSAGE_LIST[1],rate);
end


---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
-- SP加算は takeAttack() 側が担当する（Spine側の addSP イベントと二重にならないようにする）
function class:run(event)
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
            self.hpSkillFLG = false;
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
-- 経過時間の判定はホストのみ。効果量をゲストへ配って揃える
function class:dead(event)
    self:removeBuff(event.unit,self.GOBURU_COUNT_BUFF[1].ID);   ---全滅処理でカウントが跳ねないよう先に除去
    self:killAllGoburu();
    if megast.Battle:getInstance():isHost() then
        local rate = self:calcRewardRate();
        self:execReward(rate);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,rate);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- receive6（討伐報酬の効果量同期）
---------------------------------------------------------------------------------
function class:receive6(args)
    self:removeBuff(self.gameUnit,self.GOBURU_COUNT_BUFF[1].ID);
    self:killAllGoburu();
    self:execReward(args.arg);
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

    ---ヒートスイングは skill1 のアニメを使う
    if event.index == 2 then
        event.unit:setNextAnimationName("skill1");
        event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-skill1"); ---EFのアニメーション名に気をつける
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false;
        self:refresh(self.gameUnit); ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0);
        self.hpSkillFLG = false;
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

    self.skillCheckFlg = false;
    self.cutInFLG = false;
    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;

    ---奥義3（ミリオンズストライク）は奥義2と同じ skill2 アニメを使う
    if event.index == 3 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-skill2");
    end

    ---奥義2を発動する度にゴブルを召喚
    if event.index == 2 then
        self:summonBySkill(event.unit);
    end

    self:skillActiveSkillSetter(event.unit,event.index);
    return 1;
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

    ---① 無効化有り又は庇われているユニットからのダメージ以外を軽減
    if not self:isNullifyOrProtected(enemyUnit) then
        event.value = math.floor(event.value * self.GD.resistDmgRate);
    end

    ---② ゴブルが場にいる間は全てのダメージを軽減（①と重複＝乗算）
    if self.friendCount > 0 then
        event.value = math.floor(event.value * self.GD.goburuDmgRate);
    end

    ---③ HPフラグ境界でのダメージ調整（必ず最後）
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用（event.enemy を持たないため無効化／庇うの判定ができない）
-- 判定できない分はダメージが素通りしないよう軽減側に寄せる
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    else
        event.value = math.floor(event.value * self.GD.resistDmgRate);
        if self.friendCount > 0 then
            event.value = math.floor(event.value * self.GD.goburuDmgRate);
        end
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
    ---HPフラグは発動から奥義を打ち終わるまでブレイク0
    if self.hpSkillFLG then
        return 0;
    end
    return event.value;
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01;
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0;
        end
    end
    self.breakFlg = true;
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

---「〇%アップ」のように数値を埋め込むメッセージ用
function class:showCountMessage(messageBox,count)
    local msg = string.format(messageBox.MESSAGE,count);
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(msg,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(msg,messageBox.DURATION,messageBox.COLOR);
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
    return 1;
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


--===================================================================================================================
-- バフ
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
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID);
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

function class:removeBuff(unit,buffID)
    local cond = unit:getTeamUnitCondition():findConditionWithID(buffID);
    if cond ~= nil then
        unit:getTeamUnitCondition():removeCondition(cond);
    end
end

function class:unitAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit, buffBox);
        end
    end
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


--===================================================================================================================
-- 状態異常除去
--===================================================================================================================
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

---HPトリガー時の全状態異常回復（仕様書に「状態異常を回復」とある場合に使用）---
function class:refreshAll(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97,135};
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
