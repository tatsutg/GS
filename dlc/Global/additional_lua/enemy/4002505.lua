local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="超新星級_HARD_醒魔槍神アルヴィナ", version=2.8, id=4002505});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
--- スキル1 -> スキル2 -> (スキル1 or スキル2) -> 繰り返し
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    }
};

--使用する奥義とその確率
--- 奥義3 -> 繰り返し
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 }---奥義3 アイシクルレイド
    }
};

--- takeSkill(N) は spine の "skillN" を再生し、ACTIVE_SKILLS["SKILLN"] を setActiveSkill する。
--- 同キャラの enemy/5041322.lua と同じく奥義のアニメは skill2 / skill3 を使う
class.ACTIVE_SKILLS = {
    ATTACK1 = 1,---スキル1 通常攻撃
    ATTACK2 = 2,---スキル2 アイスクレイブ
    SKILL2 = 3, ---奥義3 アイシクルレイド（spine skill2）
    SKILL3 = 4  ---奥義4 ヴァイオレッドドラグーン（spine skill3）
};

--- 0=奥義カットイン / 1=真奥義カットイン
class.cutInSkill = {
    [2] = 0,---奥義3
    [3] = 1 ---奥義4
};

function class:setBuffBoxList()
    ---奥義3発動ごとにプレイヤー全体の装備CTをDOWN（アイコンに数値表示・累積）
    self.SKILL3_BUFF_LIST = {
        [1] = {
            ID = 400250501,
            BUFF_ID = 30,---装備CT
            VALUE = self.GD.buffVal_30,
            DURATION = 999999,
            ICON = 183,
            MAX = self.GD.buffMax_30
        }
    };
    self.BUFF_LIST = {
        [1] = {
            ID = 400250502,
            BUFF_ID = 0,---樹属性耐性アイコン表示用
            VALUE = 0,
            DURATION = 999999,
            ICON = 40
        }
    };
    ---奥義4発動時にプレイヤー全体を氷衰状態にする（強制＝耐性判定を通さない）
    self.SKILL4_BUFF_LIST = {
        [1] = {
            ID = 400250503,
            BUFF_ID = 207,---上位氷結効果(氷衰)
            VALUE = self.GD.buffVal_207,
            DURATION = self.GD.freezeTimeSkill,
            ICON = 307
        }
    };
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
    local message = {
        MESSAGE = messageBox.MESSAGE or "メッセージ",
        COLOR = messageBox.COLOR or Color.yellow,
        DURATION = messageBox.DURATION or 7,
        isPlayer = messageBox.isPlayer or false
    };
    return message;
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "CRIダメージ・樹属性耐性", COLOR = Color.yellow}),
    };
    self.SKILL3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "奥義上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL3_MESSAGE2 or "装備CT速度ダウン", COLOR = Color.red})
    };
    self.SKILL4_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL4_MESSAGE1 or "パーティユニットを氷衰", COLOR = Color.red})
    };
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = true---ブレイクスルー（青のHPマーカー。ブレイク中に踏むとスルー）
        }
    };
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
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;---奥義4 ヴァイオレッドドラグーン（cutInSkill[3]=1で真奥義カットイン）
            self.saveBP = self.gameUnit:getBurstPoint();---直前の奥義ゲージを引き継ぐ
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(10);
        ---INFOの記載が無いのでメッセージは出さない
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 10,
        startAddSP = 40,---戦闘開始時奥義ゲージ
        attackDelay = 6,
        hitStop = 100,

        --- カスタムギミック値
        earthTakeDamageRate = 0.1,---樹属性ダメージへの被ダメージ補正
        critTakeDamageRate = 0.01,---クリティカルの被ダメージ補正（樹属性と掛け算で重なる）
        skill3AddSP = 5,          ---奥義3を発動するたびに増える addSP の量
        buffVal_30 = -10,         ---奥義3ごとの装備CT DOWN量(%)
        buffMax_30 = 10,          ---装備CT DOWNの最大段数
        buffVal_207 = 10,         ---氷衰の効果量（氷衰後遺症の値にも使う）
        freezeTimeSkill = 3,      ---奥義4でパーティ全体を氷衰にする秒数
        freezeSequelaeFlg = 1     ---氷衰後遺症（type234）を付けるか（1=付ける / 0=付けない）
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

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false;
    self.hpSkill = 0;
    self.saveBP = 0;

    ---ボスギミック（タイマーギミックは無いのでExtraTimerは作らない）

    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    -- self:execAddBuff(event.unit,self.BUFF_LIST[1]);
    return 1;
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
-- run
---------------------------------------------------------------------------------
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
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    ---死亡時のINFOは仕様書に記載が無いのでメッセージは出さない
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    return 1;
end

function class:receive4(args)
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

    ---スキル2 アイスクレイブ：ユニットに attack2 が無いので skill1 のアニメを流す
    if event.index == 2 then
        event.unit:setNextAnimationName("skill1");
        event.unit:setNextAnimationEffectName("2-skill1"); ---EFのアニメーション名に気をつける
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

    ---奥義3発動時：addSP増加＆プレイヤー全体の装備CT DOWN
    if event.index == 2 then
        self.spValue = self.spValue + self.GD.skill3AddSP;
        self:unitAddBuff(self.SKILL3_BUFF_LIST[1]);
        self:showMessage(self.SKILL3_MESSAGE_LIST);
    end

    ---奥義4発動時：プレイヤー全体を強制で氷衰状態にする
    ---※INFOはHPトリガー側ではなく奥義が実際に出たここで表示する
    if event.index == 3 then
        self:execFreezeUpward();
        self:showMessage(self.SKILL4_MESSAGE_LIST);
    end

    self.skillCheckFlg = false;
    self.cutInFLG = false;
    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1;
end

--===================================================================================================================
-- 氷衰ギミック（奥義4でパーティ全体を強制で氷衰状態にする）
-- ※execAddBuff は addCondition を直接呼ぶので状態異常耐性の判定を通らない＝「強制」になる
-- ※氷衰は後遺症（type234）とセット。207側の付与成功判定が動かないので手動で積む
--===================================================================================================================
function class:execFreezeUpward()
    local buffBox = self.SKILL4_BUFF_LIST[1];
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
            if self.GD.freezeSequelaeFlg == 1 then
                self:setFreezeSequelae(myTeamUnit,buffBox.VALUE);
            end
        end
    end
    megast.Battle:getInstance():updateConditionView();
end

---氷衰後遺症（type234）を1段積む
function class:setFreezeSequelae(target,value)
    local ntype = 234;
    local icon = 326;
    local cond = target:getTeamUnitCondition():findConditionWithType(ntype);
    if cond == nil then
        local buff = target:getTeamUnitCondition():addCondition(-1,ntype,value,-1,icon,0);
        if buff ~= nil then
            buff:setNumber(1);
            buff:setValue( buff:getValue() );
            buff:setScriptID(603);
            target:setParameter("234_Sequelae_Freeze",""..1);
        end
    else
        local num = cond:getNumber() + 1;
        if num <= 10 then
            cond:setNumber(num);
            target:setParameter("234_Sequelae_Freeze",""..num);
        end
    end
end

---パーティ全員にバフを付与する
function class:unitAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
        end
    end
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
    ---攻撃の種類による被ダメージ補正（樹属性 / クリティカル）
    event.value = event.value * self:getAttackTypeRate(enemyUnit);
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    end
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    ---攻撃の種類による被ダメージ補正（マルチ経路でもすり抜けないよう同じ補正を掛ける）
    event.value = event.value * self:getAttackTypeRate(enemyUnit);
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

--===================================================================================================================
-- 攻撃の種類による被ダメージ補正
--   樹属性     : 樹属性ダメージを軽減（ユニットの属性ではなく攻撃の属性で判定する）
--   クリティカル: クリティカルダメージを軽減
--   ※掛け算で重なるので「樹属性のクリティカル」は自動的に 0.1×0.01=0.001 になる
--===================================================================================================================
function class:getAttackTypeRate(enemyUnit)
    local rate = 1;
    local info = enemyUnit:getTeamUnitCondition():getDamageAffectInfo();
    if info == nil then
        return rate;
    end

    ---樹属性ダメージ（0=無/1=炎/2=水/3=樹/4=光/5=闇）
    if info.skillElementType == kElementType_Earth then
        rate = rate * self.GD.earthTakeDamageRate;
    end

    ---クリティカルダメージ
    if info.critical == true then
        rate = rate * self.GD.critTakeDamageRate;
    end

    return rate;
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
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
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

function class:showFormatMessage(messageBox,str)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
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

---トリガー時状態異常除去---
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

function class:deBuffRefresh(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97};
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

--- チーム取得
function class:getMyTaem(unit,teamFlg)
    local unitTeam = unit:getTeam();
    local targetTeam = nil;
    if teamFlg then
        --自分PTからみて味方PTを取る
        if unitTeam == megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(true);
        else
            targetTeam = megast.Battle:getInstance():getTeam(false);
        end
    else
        --自分PTからみて敵PTを取る
        if unitTeam == megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(false);
        else
            targetTeam = megast.Battle:getInstance():getTeam(true);
        end
    end
    return targetTeam;
end


class:publish();

return class;
