local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="夢幻級ヴィシャス", version=2.8, id=2006915});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK2 = 100 },
    },
    PHASE_HP10 = {
        { ATTACK3 = 100 },
        { ATTACK4 = 100 },
        { ATTACK5 = 100 },
    },
    PHASE_HP5 = {
        { ATTACK7 = 100 },
        { ATTACK8 = 100 },
        { ATTACK9 = 100 },
    },
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 },
    },
    PHASE_HP10 = {
        { SKILL3 = 100 },
    },
    PHASE_HP5 = {
        { SKILL20 = 100 },
        { SKILL3 = 100 },
    },
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL2 = 6,
    SKILL20 = 7,
    SKILL3 = 8,
    SKILL30 = 9,
    ATTACK7 = 10,
    ATTACK8 = 11,
    ATTACK9 = 12
}

class.cutInSkill = {
    --[3] = 1
}

function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 3002,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
        },
    }
    self.TG_BUFF_BOX_LIST = {
        [1] = {
            ID = 200691510,
            BUFF_ID = 17,
            VALUE = self.GD.tgBuffVal_17,
            DURATION = 999999,
            ICON = 27,
            COUNT = 0,
            MAX = 99
        }
    }
    ---ターゲットギミック
    self.TARGET_BUFF_LIST1 = {
        ID = 200691550,
        BUFF_ID = 29,---スキルCT
        VALUE = self.GD.targetBuff_29,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 200691550,
        BUFF_ID = 0,---
        VALUE = 0,
        DURATION = 999999,
        ICON = 0
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
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下・物理耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "庇う無効・神族キラー", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "累計ダメージの最も大きいユニットをターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ターゲットのスキルCT速度ダウン", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "晴朗：属性倍率アップ", COLOR = Color.yellow}),
    }
    self.HP10_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP10_MESSAGE1 or "行動速度アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP10_MESSAGE2 or "一定時間経過で敵全体の与ダメージダウン：燃焼で遅延", COLOR = Color.yellow}),
    }
    self.HP5_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP5_MESSAGE1 or "奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP5_MESSAGE2 or "ヴィシャス：%s属性耐性アップ", COLOR = Color.yellow}),
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "ヴィシャス：再起：一定時間戦闘不能回避", COLOR = Color.yellow}),
    }
    self.ELEMENT_MESSAGE_LIST = {
        [0] = self:setMessageInfo({MESSAGE = self.TEXT.ELEMENT_MESSAGE1 or "無", COLOR = Color.yellow}),
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.ELEMENT_MESSAGE2 or "炎", COLOR = Color.yellow}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.ELEMENT_MESSAGE3 or "水", COLOR = Color.yellow}),
        [3] = self:setMessageInfo({MESSAGE = self.TEXT.ELEMENT_MESSAGE4 or "樹", COLOR = Color.yellow}),
        [4] = self:setMessageInfo({MESSAGE = self.TEXT.ELEMENT_MESSAGE5 or "光", COLOR = Color.yellow}),
        [5] = self:setMessageInfo({MESSAGE = self.TEXT.ELEMENT_MESSAGE6 or "闇", COLOR = Color.yellow})
    }
end


--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp10(status) end,
            HP = 10,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp5(status) end,
            HP = 5,
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

function class:hp10(status)
    if status == "use3" then
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 30;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setAttackDelay(self.GD.hp10AttackDelay);
        self.gameUnit:setInvincibleTime(15);
        self.hpSkillFLG = true;
        self:showMessage(self.HP10_MESSAGE_LIST);
        self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * self.GD.hp10HpRate);
        --タイマーギミック
        self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
        self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
        self:initAttackWeight({PHASE_HP10 = 100});
        self:initSkillWeight({PHASE_HP10 = 100});
    end
end

function class:hp5(status)
    if status == "use3" then
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 30;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.spValue = self.GD.hp5AddSP;
        self.gameUnit:setInvincibleTime(15);
        self.hpSkillFLG = true;
        self.resistTargetElement = self:checkElementDamage();
        self:showMessage(self.HP5_MESSAGE_LIST,1);
        self:showFormatMessage(self.HP5_MESSAGE_LIST[2],self.ELEMENT_MESSAGE_LIST[self.resistTargetElement].MESSAGE);
        self:initAttackWeight({PHASE_HP5 = 100});
        self:initSkillWeight({PHASE_HP5 = 100});
        self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * self.GD.hp10HpRate);
    end
end

function class:checkElementDamage()
    local tagetIndex = nil;
    local maxDmgNum = -1;
    for i = 0,5 do
        if maxDmgNum < self.elementDmgTbl[i] then
            tagetIndex = i;
            maxDmgNum = self.elementDmgTbl[i];
        end
    end
    return tagetIndex;
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 25,
        hp5AddSP = 35,
        startAddSP = 0,
        attackDelay = 6,
        hp10AttackDelay = 3,
        hitStop = 100,

        tgTimer = 10,
        tgLimit = 99,
        tgIconNum1 = 182,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        deBuffTimeSpeed = 0.333,

        --- カスタムギミック値
        tDmgVal = 0.01,
        targetBuff_29 = -100,
        tgBuffVal_17 = -50,
        deadCount = 10,
        hp10HpRate = 1.0,
    })
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

    -- 経過時間ギミック
    self.breakFlg = false;
    self.hpSkillFLG = false;

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnitList = {}
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();

    ---ボスギミック
    self.deadInfoFlg = true;
    self.resistTargetElement = nil;
    self.elementDmgTbl = {};
    for i = 0,5 do
        self.elementDmgTbl[i] = 0;
    end
    
    self.lastFlg = false;
    self.deadCount = 0;

    self.skill20Flg = false;
    self.auraFlg = false;
    self.aura = nil;
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
    --タイマーギミック
    self:extraTimerOperation(event.unit);
    ---死亡判定
    if self.lastFlg then
        event.unit:setInvincibleTime(1);
        if self:unitCheck() then
            self.deadCount = self.deadCount + event.deltaTime;
            if self.deadCount >= self.GD.deadCount then
                self:auraEnd(event.unit);
                event.unit:getTeam():deadUnit(event.unit:getIndex());
                megast.Battle:getInstance():waveEnd(true);
            end
        end
    end
    ---オーラ演出
    self:auraControl(event.unit);
    if self.skill20Flg and event.unit:getUnitState() ~= kUnitState_skill then
        self.skill20Flg = false;
        if self.aura == nil and self.auraFlg then
            self:overHeat(event.unit);
        end
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

function class:unitCheck()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            return true;
        end
    end
    return false;
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    if event.index == self.timeIndex then
        self:unitAddBuff(self.TG_BUFF_BOX_LIST[1]);
    end
    return event.count;
end

function class:extraTimerOperation(unit)
    if self.timeIndex ~= nil then
        local _flg1 = 0;
        if unit:getTeamUnitCondition():findConditionWithType(97) ~= nil then _flg1 = 1; end
        if unit:isBreak() or unit:getInvincibleTime() > 0 or self.hpSkillFLG == true then _flg1 = 2; end
        if _flg1 == 2 then
            self.timeSpeed = 0;
        elseif _flg1 == 1 then
            self.timeSpeed = 1 * self.GD.deBuffTimeSpeed;
        else
            self.timeSpeed = 1;
        end
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= self.timeSpeed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex, self.timeSpeed);
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "takeOverHeat" and self.auraFlg then
        self:overHeat(event.unit);
	end

	if event.spineEvent == "auraLoopStart" and self.auraFlg then
        self.auraFlg = false;
        self:auraLoopStart(event.unit);
	end
    return 1;
end

function class:overHeat(unit)
	self.aura = unit:addOrbitSystem("auraIn");
	self.aura:setOrbitType(4)
	self.aura:takeAnimation(0,"auraIn",true);
	local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetx,targety);
    self.aura:setAutoZOrder(true);
end

function class:auraLoopStart(unit)
	self.aura:takeAnimation(0,"auraLoop",true);
end

function class:auraControl(unit)
	if self.aura == nil then
		return;
	end
	local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetx,targety);
    self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY());
end

function class:auraEnd(unit)
    if self.aura == nil then
		return;
	end
	self.aura:takeAnimation(0,"auraEnd",false);
	self.aura = nil;
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
function class:dead(event)
    self.lastFlg = true;
    event.unit:setHP(1);
    if self.deadInfoFlg then
        event.unit:takeAttack(7);
        self.deadInfoFlg = false;
        self:auraEnd(event.unit);
        if megast.Battle:getInstance():isHost() then
            self:showMessage(self.HP0_MESSAGE_LIST);
            megast.Battle:getInstance():sendEventToLua(self.scriptID, 4, 1);
        end
    end
    return 0;
end

function class:receive4(args)
    self:showMessage(self.HP0_MESSAGE_LIST);
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

    if event.index == 7 then
        event.unit:setNextAnimationName("attack3");
        event.unit:setNextAnimationEffectName("2-attack3");
    elseif event.index == 8 then
        event.unit:setNextAnimationName("attack4");
        event.unit:setNextAnimationEffectName("2-attack4");
    elseif event.index == 9 then
        event.unit:setNextAnimationName("attack5");
        event.unit:setNextAnimationEffectName("2-attack5");
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

    if event.index == 20 then
        self.skill20Flg = true;
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("2-skill2");
    elseif event.index == 30 then
        event.unit:setNextAnimationName("skill3");
        event.unit:setNextAnimationEffectName("2-skill3");
    end

    if self.TRIGGERS[2].used then
        self.auraFlg = true;
        self:auraEnd(event.unit);
    end

    self.skillCheckFlg = false;
    self.cutInFLG = false;
    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    --self:initAttackWeight({DEFAULT = 100});---奥義使用後はリセットでスキル1からスタート
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
    local attackType = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
    if attackType == 1 then
        event.value = event.value * self.GD.tDmgVal;
    end

    local attackElement = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType;
    if self.resistTargetElement == nil then
        --属性ダメージを保存
        self.elementDmgTbl[attackElement] = self.elementDmgTbl[attackElement] + event.value;
    else
        --属性ダメージ補正
        if self.resistTargetElement == attackElement then
            event.value = 1;
        end
    end

    ---ターゲットギミック
    ---ユニットのダメージをテーブルに格納
    local targetIndex = enemyUnit:getIndex();
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10);
    if self.targetUnitList[index] == nil then
        table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value});
    else
        self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value;
    end
    ---ホストのみ---
    if megast.Battle:getInstance():isHost() then
        ---ヘイトは全部手動で設定する
        local target = self:checkTargetUnit();
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex());---ゲストにターゲットを送る
        event.unit:setHateTarget(target);
        event.unit:updateHateTarget();
        ---ターゲットにバフ
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                if i == target:getIndex() then
                    self.targetIndex = i
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1);
                else
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0);
                end
            end
        end
    end

    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

-- 与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil;
    local val = 0;
    for i,v in pairs(self.targetUnitList) do
        if v.unit == nil or v.unit:getHP() < 1 then
            --v.dps = 0
        elseif v.dps >= val then
            val = v.dps;
            target = v.unit;
        end
    end
    return target;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用
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


function class:execSkill2(event)
end

function class:unitAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true)
    for i = 0, 3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit, buffBox)
        end
    end
end

class:publish();

return class;