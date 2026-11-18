local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="鉱山炎玉精イグニス", version=2.5, id="mine_5027"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK2 = 100 },
        { ATTACK1 = 100 },
        { ATTACK4 = 100 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK3 = 100 },
    },
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL1 = 100 },
    },
    LAMP3 = {
        { SKILL2 = 100 },
    },
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 6,
}

class.cutInSkill = {
    [3] = 1,
}

---炎玉ランプ（クリスタル玉オービット）。出典: gb_502601
class.CRYSTAL_NUM = 3;
class.CRYSTAL_POSITIONS = {
    {x = -300,y = 500},
    {x = 300,y = 500},
    {x = 0,y = 530}
}
class.CRYSTAL_STATES = {
    start = 0,
    deactive = 1,
    activation = 2,
    active = 3,
    out = 4,
    hide = 5,
    start2 = 6
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---炎玉ランプ: クリティカル率アップ（VALUEはlampCritBuffUpdateが都度設定）
    self.LAMP_BUFF_LIST = {
        [1] = { ID = 990001, BUFF_ID = 22, VALUE = self.GD.lampCritVal0, DURATION = 99999, ICON = 11 },
    }

    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 1001,
            BUFF_ID = 97,
            VALUE = self.GD.buffVal_97,
            DURATION = 999999,
            ICON = 87,
        },
        [2] = {
            ID = 1002,
            BUFF_ID = 132,
            VALUE = self.GD.buffVal_132,
            DURATION = 99999,
            ICON = 0,
        },
    }
    self.TG_BUFF_LIST = {
        [1] = { ID = 0001, BUFF_ID = 0, VALUE = 0, DURATION = 1, ICON = 0 },
    }

    ---鉱山ギミック（制限時間経過強化。出典: mine_6025 の TIMEUP_BUFF_BOX_LIST）
    self.TIMEUP_BUFF_BOX_LIST = {
        [1] = {
            ID = 502791,
            BUFF_ID = 17,      --ダメージ
            VALUE = self.GD.timeUpVal,
            DURATION = 9999999,
            ICON = 26
        },
        [2] = {
            ID = 502792,
            BUFF_ID = 13,      --攻撃力
            VALUE = self.GD.timeUpVal,
            DURATION = 9999999,
            ICON = 3
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
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下・樹属性耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "一定時間経過でイグニスが燃焼状態になる", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "イグニスが燃焼状態のとき、ダメージ軽減", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "点灯しているランプが多いほど、イグニスのクリティカル率アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "イグニスが氷結・気絶状態になるたびランプが消灯", COLOR = Color.red}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "炎玉ランプがすべて点灯", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "奥義上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE3 or "ダメージ無効化無効", COLOR = Color.red}),
    }
    self.TIMEUP_BUFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE1 or "攻撃力アップ",COLOR=Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE2 or "ダメージアップ",COLOR=Color.red})
    }
end


--------[[特殊行動]]--------
function class:setTriggerList()
    self.TIME_UP_ID = 2
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        },
        [self.TIME_UP_ID] = {
            tag = "TIME_UP",
            action = function (status) self:timeUp(status) end,
            used = false
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





function class:hp50(status)
    if status == "use3" then
        self:refreshAll(self.gameUnit);
        self.stateName = "FURY";
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.spValue = 40;
        self.gameUnit:setInvincibleTime(10);
        self.hpSkillFLG = true;
        self:showMessage(self.HP50_MESSAGE_LIST);
        self:execAddBuff(self.gameUnit, self.BUFF_LIST[2]);
        ---炎玉ランプ: 全点灯
        self:forceLamp(3);
        ---TODO: 炎玉ランプがすべて点灯 / 奥義上昇量アップ / ダメージ無効化無効
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 30,
        startAddSP = 70,
        attackDelay = 7,
        hitStop = 100,

        tgTimer = 20,
        tgLimit = 99,
        tgIconNum1 = 1,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        deBuffTimeSpeed = 0,

        --- カスタムギミック値
        buffVal_97 = 10,
        buffVal_132 = 100,
        tgTimer1 = 20.0,
        skill4SpReduce = 50,
        lampCritVal0 = 20,
        lampCritVal1 = 50,
        lampCritVal2 = 80,
        lampCritVal3 = 200,
        skill4SpReduceLamp = 50,
        timeUpLimit = 300,
        timeUpVal = 500,
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
    self.afterSkillFLG = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    ---炎玉ランプ初期化
    self.lampCount = 0;
    self.lampDownPrev = {};
    self.crystals = {};
    self:initCrystals(event.unit);
    self:lampCritBuffUpdate();

    self.stateName = "NORMAL";
    self.breakSkip = true;
    self.hpSkill = 0;
    self.saveBP = 0;

    ---経過時間ギミック
    self.breakFlg = false;
    self.hpSkillFLG = false;
    self.timeIndex1 = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer1, 99999, 87, 0, 0, 0, 1);
    self.timeSpeed1 = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex1);

    ---ボスギミック


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
    self:extraTimerOperation(event.unit);
    self:lampDownCheck(event.unit);
    self:setTimeUp();
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    return 1;
end

---制限時間（デフォルト300秒）経ったらタイムアップ（鉱山共通ギミック。出典: mine_6025）
function class:setTimeUp()
    if BattleControl:get():getTime() > self.GD.timeUpLimit and not self.TRIGGERS[self.TIME_UP_ID].used then
        self:execTrigger(self.TIME_UP_ID)
    end
end

function class:timeUp(status)
    if status == "use3" then
        self:showMessage(self.TIMEUP_BUFF_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[1])
        self:execAddBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[2])
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    if event.index == self.timeIndex1 then
        if megast.Battle:getInstance():isHost() then
            self:execAddBuff(self.gameUnit, self.BUFF_LIST[1])
        end
    end
    return event.count
end


function class:extraTimerOperation(unit)
    if self.timeIndex1 ~= nil then
        local _flg1 = 0
        if unit:getTeamUnitCondition():findConditionWithType(97) ~= nil then _flg1 = 1 end
        if unit:isBreak() or unit:getUnitState() == kUnitState_skill then _flg1 = 2 end
        if _flg1 == 2 then
            self.timeSpeed1 = 0
        elseif _flg1 == 1 then
            self.timeSpeed1 = 1 * self.GD.deBuffTimeSpeed
        else
            self.timeSpeed1 = 1
        end
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex1) ~= self.timeSpeed1 then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex1, self.timeSpeed1)
            self.timeSpeed1 = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex1)
        end
    end
end


---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end
    if event.spineEvent == "crystalActionEnd" then self:crystalStateEnd(event.unit); end
    if event.spineEvent == "skill2Start" then self:excutionCrystals(); end
    if event.spineEvent == "skill2Compleat" then self:restertCrystals(); end
    if event.spineEvent == "skill3Start" then self:excutionCrystals(); end
    if event.spineEvent == "skill3Compleat" then self:restertCrystals(); end
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

    --if event.index == 1 then
    --    event.unit:setNextAnimationName("attack1");
    --    event.unit:setNextAnimationEffectName("1-attack1");
    --end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit); ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0);
        self.hpSkillFLG = false;
        self.afterSkillFLG = false;
        event.unit:addSP(self.saveBP);
        self.saveBP = 0;
    end

    if event.index == 4 then
        if megast.Battle:getInstance():isHost() then
            local _team = megast.Battle:getInstance():getTeam(true)
            for _i = 0, 6 do
                local _u = _team:getTeamUnit(_i)
                if _u ~= nil then
                    _u:setBurstPoint(math.max(0, _u:getBurstPoint() - (self.GD.skill4SpReduce + self.lampCount * self.GD.skill4SpReduceLamp)))
                end
            end
        end
    end

    self:attackActiveSkillSetter(event.unit,event.index);
    return 1;
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex();
    if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK);
    unit:takeAttack(attackIndex);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,attackIndex);
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

    --if event.index == 1 and self.cutInFLG then
    --    self.cutInFLG = false;
    --    event.unit:takeSkillWithCutin(event.index,1);
    --    return 0;
    --end

    --if event.index == 5 then
    --    event.unit:setNextAnimationName("skill4");
    --    event.unit:setNextAnimationEffectName("1-skill4");
    --end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    ---炎玉ランプ: 奥義使用で+1点灯（状態異常97中は+2）
    local _lampAdd = 1;
    if event.unit:getTeamUnitCondition():findConditionWithType(97) ~= nil then _lampAdd = 2; end
    self:addLamp(_lampAdd);
    self:skillActiveSkillSetter(event.unit,event.index);
    if event.index == 3 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-skill2");
    end
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
    local isCond97 = self.gameUnit:getTeamUnitCondition():findConditionWithType(97) ~= nil;
    if isCond97 then
        event.value = event.value * 0.1;
    else
        event.value = event.value * 1.0;
    end
    ---TODO: ここにギミックロジックを実装してください
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
    --オービット判定
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

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.afterSkillFLG then
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
    if self.timeIndex1 ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex1, 1, 0, true);
        self.timeIndex1 = nil
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 4, 1)
    return 1
end


function class:receive4(args)
    if self.timeIndex1 ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex1, 1, 0, true);
        self.timeIndex1 = nil
    end
    return 1
end


--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList);
        return
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

class.STATE_ATTACK = {};
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



--===================================================================================================================
-- 炎玉ランプ（クリスタル玉オービット）。出典: gb_502601
--===================================================================================================================
function class:initCrystals(unit)
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i] = self:createCrystal(unit,self.CRYSTAL_POSITIONS[i].x,self.CRYSTAL_POSITIONS[i].y);
    end
end

function class:createCrystal(unit,x,y)
    local crystal = {}
    crystal.orbit = unit:addOrbitSystem("crystal_idle_off");
    crystal.orbit:takeAnimation(0,"crystal_idle_off",true);
    crystal.orbit:setPosition(x,y);
    crystal.orbit:setZOrder(8999);
    crystal.state = self.CRYSTAL_STATES.deactive;

    crystal.endState = function(class,this)
        if this.state == class.CRYSTAL_STATES.start then
            this.switchState(class,this,class.CRYSTAL_STATES.deactive);
        elseif this.state == class.CRYSTAL_STATES.activation then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
        elseif this.state == class.CRYSTAL_STATES.out then
            this.switchState(class,this,class.CRYSTAL_STATES.hide);
        elseif this.state == class.CRYSTAL_STATES.start2 then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
        end
    end

    crystal.switchState = function(class,this,targetState)
        this.state = targetState;
        if targetState == class.CRYSTAL_STATES.active then
            this.orbit:takeAnimation(0,"crystal_idle_on",true);
        end
        if targetState == class.CRYSTAL_STATES.deactive then
            this.orbit:takeAnimation(0,"crystal_idle_off",true);
        end
        if targetState == class.CRYSTAL_STATES.activation then
            this.orbit:takeAnimation(0,"crystal_activate",true);
        end
        if targetState == class.CRYSTAL_STATES.start then
            this.orbit:takeAnimation(0,"crystal_in",true);
        end
        if targetState == class.CRYSTAL_STATES.start2 then
            this.orbit:takeAnimation(0,"crystal_in2",true);
        end
        if targetState == class.CRYSTAL_STATES.out then
            this.orbit:takeAnimation(0,"crystal_out",true);
        end
        if targetState == class.CRYSTAL_STATES.hide then
            this.orbit:takeAnimation(0,"crystal_hide",true);
        end
    end

    return crystal;
end

function class:crystalStateEnd(unit)
    for i=1,self.CRYSTAL_NUM do
        if self.crystals[i].orbit == unit then
            self.crystals[i].endState(self,self.crystals[i]);
            return;
        end
    end
end

---ランプ数を増減（addLamp）/強制設定（forceLamp）。玉演出・クリ率バフ・奥義パターンを追従更新
function class:addLamp(num)
    self:setLampCount(self.lampCount + num);
end

function class:forceLamp(num)
    self:setLampCount(num);
end

function class:setLampCount(count)
    if count > self.CRYSTAL_NUM then count = self.CRYSTAL_NUM; end
    if count < 0 then count = 0; end
    if count == self.lampCount then return; end
    self.lampCount = count;
    for i=1,self.CRYSTAL_NUM do
        if i <= count then
            if self.crystals[i].state == self.CRYSTAL_STATES.deactive then
                self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.activation);
            end
        else
            if self.crystals[i].state == self.CRYSTAL_STATES.active or self.crystals[i].state == self.CRYSTAL_STATES.activation then
                self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.deactive);
            end
        end
    end
    self:lampCritBuffUpdate();
    if self.lampCount >= self.CRYSTAL_NUM then
        self:initSkillWeight({LAMP3 = 100});
    else
        self:initSkillWeight({DEFAULT = 100});
    end
end

---ランプ数に応じたクリティカル率バフを付け直す（アイコンにランプ数をスタック表示・MAX3）
function class:lampCritBuffUpdate()
    local old = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.LAMP_BUFF_LIST[1].ID);
    if old ~= nil then
        self.gameUnit:getTeamUnitCondition():removeCondition(old);
    end
    self.LAMP_BUFF_LIST[1].VALUE = self.GD["lampCritVal" .. self.lampCount];
    self:execAddBuff(self.gameUnit, self.LAMP_BUFF_LIST[1]);
    local buff = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.LAMP_BUFF_LIST[1].ID);
    if buff ~= nil then
        buff:setMaxConditionIconNumber(self.CRYSTAL_NUM);
        buff:setNumber(self.lampCount);
        megast.Battle:getInstance():updateConditionView();
    end
end

---消灯トリガー: 対象状態異常の付与エッジで-1（update から毎フレーム呼ぶ）
function class:lampDownCheck(unit)
    local downIDs = {96,207,89,135};
    for i=1,table.maxn(downIDs) do
        local cid = downIDs[i];
        local now = unit:getTeamUnitCondition():findConditionWithType(cid) ~= nil;
        if now and not self.lampDownPrev[cid] then
            self:addLamp(-1);
        end
        self.lampDownPrev[cid] = now;
    end
end

---奥義アニメが演出として玉を描く間、既存オービットを退場させて二重表示を防ぐ（spineイベント {anim}Start/{anim}Compleat から呼ぶ）
function class:excutionCrystals()
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.out);
    end
end

---退場した玉を現在のランプ数に応じた点灯/消灯状態で復帰させる
function class:restertCrystals()
    for i=1,self.CRYSTAL_NUM do
        if i <= self.lampCount then
            self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.start2);
        else
            self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.start);
        end
    end
end

class:publish();

return class;