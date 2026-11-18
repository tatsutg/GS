local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="人族遺跡_12層_紅騎士ミルザ", version=2.8, id=2061217});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3
}

class.cutInSkill = {
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1053215931,---リーダー以外
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [2] = {
            ID = 1053215932,---リーダー用
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }
    self.ELEMENT_BUFF_BOX = {
        [1] = {
            ID = 20612171,
            BUFF_ID = 0,  --属性ダメージ補正のギミック用(未使用=条件なし)
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        },
        [2] = {
            ID = 20612172,
            BUFF_ID = 0,  --属性ダメージ補正のギミック用(未使用=条件なし)
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        }
    }
    --各スロットが何番目に付与されたかの通し番号(古い方の判定に使用)
    self.ELEMENT_ORDER_BOX = {
        [1] = {
            ID = 20612174,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        },
        [2] = {
            ID = 20612175,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        }
    }
    --通し番号の現在値(付与の度にインクリメント)
    self.ELEMENT_SEQ_BOX = {
        ID = 20612173,
        BUFF_ID = 0,
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
    return message
end

function class:setMessageBoxList()
    self.DEAD_UP_MESSAGE_LIST = {
        [0] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_UP_MESSAGE0 or "ミルザ：無属性耐性アップ", COLOR = Color.yellow}),
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_UP_MESSAGE1 or "ミルザ：炎属性耐性アップ", COLOR = Color.yellow}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_UP_MESSAGE2 or "ミルザ：水属性耐性アップ", COLOR = Color.yellow}),
        [3] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_UP_MESSAGE3 or "ミルザ：樹属性耐性アップ", COLOR = Color.yellow}),
        [4] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_UP_MESSAGE4 or "ミルザ：光属性耐性アップ", COLOR = Color.yellow}),
        [5] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_UP_MESSAGE5 or "ミルザ：闇属性耐性アップ", COLOR = Color.yellow}),
    }
    self.DEAD_DOWN_MESSAGE_LIST = {
        [0] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_DOWN_MESSAGE0 or "ミルザ：無属性耐性解除", COLOR = Color.yellow}),
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_DOWN_MESSAGE1 or "ミルザ：炎属性耐性解除", COLOR = Color.yellow}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_DOWN_MESSAGE2 or "ミルザ：水属性耐性解除", COLOR = Color.yellow}),
        [3] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_DOWN_MESSAGE3 or "ミルザ：樹属性耐性解除", COLOR = Color.yellow}),
        [4] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_DOWN_MESSAGE4 or "ミルザ：光属性耐性解除", COLOR = Color.yellow}),
        [5] = self:setMessageInfo({MESSAGE = self.TEXT.DEAD_DOWN_MESSAGE5 or "ミルザ：闇属性耐性解除", COLOR = Color.yellow}),
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {}
    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 50;---addSPの量
    --event.unit:setAttackDelay(3);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.hpMarkers = {}
    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false
    self.hpSkill = 0

    event.unit:setInvincibleTime(1);
    self.startBuff = false;
    self.elementDmgTbl = {};
    for i = 0,5 do
        self.elementDmgTbl[i] = 0;
    end
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:findLeader(self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[2])
    local condLeader = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID);
    if condLeader ~= nil and megast.Battle:getInstance():getWaveNum() <= 3 then
        -- self:showMessage(self.START_MESSAGE_LIST);
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    self:HPTriggersCheck(event.unit)
    self:findLeader(self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[2])
    self:findFriends(self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[2])

    if not self.startBuff then
        self.startBuff = true;
        local myTeam = megast.Battle:getInstance():getTeam(false);

        ---既に耐性状態が確定している味方を探す(新規湧き分に状態を引き継ぐため)
        local sourceUnit = nil;
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i);
            if myTeamUnit ~= nil and myTeamUnit:getUnitID() == event.unit:getUnitID() then
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(self.ELEMENT_SEQ_BOX.ID) ~= nil then
                    sourceUnit = myTeamUnit;
                    break;
                end
            end
        end

        if sourceUnit ~= nil then
            for i = 0, 6 do
                local myTeamUnit = myTeam:getTeamUnit(i);
                if myTeamUnit ~= nil and myTeamUnit:getUnitID() == event.unit:getUnitID() then
                    if myTeamUnit:getTeamUnitCondition():findConditionWithID(self.ELEMENT_SEQ_BOX.ID) == nil then
                        ---既に確定している耐性状態(スロット・通し番号)を引き継ぐ
                        local srcCond1 = sourceUnit:getTeamUnitCondition():findConditionWithID(self.ELEMENT_BUFF_BOX[1].ID);
                        local srcCond2 = sourceUnit:getTeamUnitCondition():findConditionWithID(self.ELEMENT_BUFF_BOX[2].ID);
                        local srcOrder1 = sourceUnit:getTeamUnitCondition():findConditionWithID(self.ELEMENT_ORDER_BOX[1].ID);
                        local srcOrder2 = sourceUnit:getTeamUnitCondition():findConditionWithID(self.ELEMENT_ORDER_BOX[2].ID);
                        local srcSeq = sourceUnit:getTeamUnitCondition():findConditionWithID(self.ELEMENT_SEQ_BOX.ID);

                        if srcCond1 ~= nil then
                            self.ELEMENT_BUFF_BOX[1].VALUE = srcCond1:getValue();
                            self:execAddBuff(myTeamUnit,self.ELEMENT_BUFF_BOX[1]);
                        end
                        if srcCond2 ~= nil then
                            self.ELEMENT_BUFF_BOX[2].VALUE = srcCond2:getValue();
                            self:execAddBuff(myTeamUnit,self.ELEMENT_BUFF_BOX[2]);
                        end
                        if srcOrder1 ~= nil then
                            self.ELEMENT_ORDER_BOX[1].VALUE = srcOrder1:getValue();
                            self:execAddBuff(myTeamUnit,self.ELEMENT_ORDER_BOX[1]);
                        end
                        if srcOrder2 ~= nil then
                            self.ELEMENT_ORDER_BOX[2].VALUE = srcOrder2:getValue();
                            self:execAddBuff(myTeamUnit,self.ELEMENT_ORDER_BOX[2]);
                        end
                        self.ELEMENT_SEQ_BOX.VALUE = srcSeq ~= nil and srcSeq:getValue() or 0;
                        self:execAddBuff(myTeamUnit,self.ELEMENT_SEQ_BOX);
                    end
                end
            end
        end
    end
    return 1
end

function class:findXCondition(unit,x)
    local cnt = 0;
    local badStatusList = {
        x
    }
    for k,v in pairs(badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return true;
        end
    end
    return false;
end

function class:findLeader(buffBoxFlg,buffBoxLeader)
    local FLG = false
    local myTeam = megast.Battle:getInstance():getTeam(false);
    ---バフがあるか確認
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getUnitID() == self.gameUnit:getUnitID() then
                local condLeader = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBoxLeader.ID);
                if condLeader ~= nil then
                    FLG = true
                end
            end
        end
    end
    if FLG then
        ---ある場合
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getUnitID() == self.gameUnit:getUnitID() then
                    local condLeader = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBoxLeader.ID);
                    if condLeader ~= nil then
                        myTeamUnit:setInvincibleTime(0)
                        local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBoxFlg.ID);
                        if cond ~= nil then
                            myTeamUnit:getTeamUnitCondition():removeCondition(cond);
                        end
                    end
                    break;
                end
            end
        end
    else
        ---ない場合
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getUnitID() == self.gameUnit:getUnitID() then
                    ---Indexでリーダー決定
                    if myTeamUnit == self.gameUnit then
                        self.gameUnit:setInvincibleTime(0)
                        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(buffBoxFlg.ID);
                        if cond ~= nil then
                            self.gameUnit:getTeamUnitCondition():removeCondition(cond);
                        end
                        self:execAddBuff(self.gameUnit,buffBoxLeader)
                    end
                    break;
                end
            end
        end
    end
end

function class:findFriends(buffBoxFlg,buffBoxLeader)
    local condLeader = self.gameUnit:getTeamUnitCondition():findConditionWithID(buffBoxLeader.ID);
    if condLeader then
        self.gameUnit:setAttackDelay(6)
        local count = 0
        local myTeam = megast.Battle:getInstance():getTeam(false);
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getUnitID() == self.gameUnit:getUnitID() and myTeamUnit ~= self.gameUnit then
                    count = count + 1
                    if count == 1 then
                        myTeamUnit:setAttackDelay(11)
                    elseif count >= 2 then
                        myTeamUnit:setAttackDelay(17)
                    end
                    myTeamUnit:setInvincibleTime(99999)
                    local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBoxFlg.ID);
                    if cond == nil then
                        self:execAddBuff(myTeamUnit,buffBoxFlg)
                    end
                end
            end
        end
        self.nowFriends = count + 1
    end
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(2061215);
    if cond == nil then
        self:takeTeamElementBuff(event.unit);
    end
    -- megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:takeTeamElementBuff(unit)
    local elementDmgNum = self:checkElementDamage();
    if elementDmgNum == nil then
        return;
    end

    local cond1 = unit:getTeamUnitCondition():findConditionWithID(self.ELEMENT_BUFF_BOX[1].ID);
    local cond2 = unit:getTeamUnitCondition():findConditionWithID(self.ELEMENT_BUFF_BOX[2].ID);
    --初回属性耐性(スロット1が未使用)
    if cond1 == nil then
        self:grantElementSlot(unit,1,elementDmgNum,nil);
        return;
    end
    --2回目属性耐性(スロット2が未使用)
    if cond2 == nil then
        self:grantElementSlot(unit,2,elementDmgNum,nil);
        return;
    end

    --3回目以降属性耐性：通し番号が小さい(=古い)方を解除して差し替え
    local orderCond1 = unit:getTeamUnitCondition():findConditionWithID(self.ELEMENT_ORDER_BOX[1].ID);
    local orderCond2 = unit:getTeamUnitCondition():findConditionWithID(self.ELEMENT_ORDER_BOX[2].ID);
    local order1 = orderCond1 ~= nil and orderCond1:getValue() or 0;
    local order2 = orderCond2 ~= nil and orderCond2:getValue() or 0;
    if order1 <= order2 then
        self:grantElementSlot(unit,1,elementDmgNum,cond1:getValue());
    else
        self:grantElementSlot(unit,2,elementDmgNum,cond2:getValue());
    end
end

---指定スロットに属性耐性を付与し、通し番号を更新してチームに共有する
function class:grantElementSlot(unit,slotIndex,elementDmgNum,downNum)
    local seqCond = unit:getTeamUnitCondition():findConditionWithID(self.ELEMENT_SEQ_BOX.ID);
    local nextSeq = (seqCond ~= nil and seqCond:getValue() or 0) + 1;

    self.ELEMENT_BUFF_BOX[slotIndex].VALUE = elementDmgNum;
    self:addTeamBuff(unit,self.ELEMENT_BUFF_BOX[slotIndex]);

    self.ELEMENT_ORDER_BOX[slotIndex].VALUE = nextSeq;
    self:addTeamBuff(unit,self.ELEMENT_ORDER_BOX[slotIndex]);

    self.ELEMENT_SEQ_BOX.VALUE = nextSeq;
    self:addTeamBuff(unit,self.ELEMENT_SEQ_BOX);

    self:showMessage(self.DEAD_UP_MESSAGE_LIST,elementDmgNum);
    if downNum ~= nil then
        self:showMessage(self.DEAD_DOWN_MESSAGE_LIST,downNum);
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

function class:addTeamBuff(unit,buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getUnitID() == unit:getUnitID() and myTeamUnit ~= self.gameUnit then
                self:execAddBuff(myTeamUnit,buffBox);
            end
        end
    end
end

function class:receive4(args)
    return 1
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

    if event.index == 2 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("2-skill1") ---EFのアニメーション名に気をつける
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
    elseif not self.addSpSkipFLG then
        self:addSP(event.unit);
    end
    -----------------------------------
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時、movePatternState()を動かさない---
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
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
    self.cutInFLG = false
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    --self:initAttackWeight({DEFAULT = 100})---奥義使用後はリセットでスキル1からスタート
    return 1
end


function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()

    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill
        self.hpSkill = 0
    else
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
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

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    --属性ダメージ補正ギミック
    local attackElement = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillElementType;
    local buuNum1 = self:getBuffValue(event.unit,self.ELEMENT_BUFF_BOX[1].ID);
    local buuNum2 = self:getBuffValue(event.unit,self.ELEMENT_BUFF_BOX[2].ID);
    if attackElement == buuNum1 then
        event.value = 1;
    elseif attackElement == buuNum2 then
        event.value = 1;
    end

    --属性ダメージを保存
    self.elementDmgTbl[attackElement] = self.elementDmgTbl[attackElement] + event.value;

    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

function class:getBuffValue(unit,buffID)
    local cond = unit:getTeamUnitCondition():findConditionWithID(buffID);
    if cond ~= nil then
        return cond:getValue();
    end
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit) ---停止系状態異常除去(このタイミングでないとたまにバグる)
        return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value)
        end
    end

    return value
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true
    return unit:getHP() - border + 1
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
        self.breakSkip = false
        return 0
    end
    return event.value
end

----// takeBreake //-----------------------------------------------------------------------------
-- 条件 : トリガー条件に到達する攻撃を受けた際、ブレイクしない(スキップ不可が必要)
---------------------------------------------------------------------------------
function class:takeBreake(event)
    for i = 1,table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end
    return 1
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList)
        return
    end
    self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
    for _,messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox)
    end
end

function class:showMessageRange(messageBoxList,start,finish)
    for i = start,finish do
        self:execShowMessage(messageBoxList[i])
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
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for index,trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            self:execTrigger(index)
        end
    end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3

    local action = "use" .. receiveNumber

    self.TRIGGERS[index].action(action)
    self.TRIGGERS[index].used = true
    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

---------------------------------------------------------------------------------
-- receive3(トリガー時ゲスト側)
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    return 1
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end
end

function class:movePatternState(SET_LIST,stateBox)
    stateBox.actCount = stateBox.actCount + 1
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1
        stateBox.setCount = stateBox.setCount + 1
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1
        end
        stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount])
    end
end

class.STATE_ATTACK = {}
function class:initAttackWeight(...)
    --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
    local attackList = {...}
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    return tonumber(attackIndex)
end


class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    return tonumber(skillIndex)
end

function class:initState(weightList)
    local state = {}
    state.SET_WEIGHT = weightList
    state.actCount = 1
    state.setCount = 1
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount])
    return state
end

---トリガー時状態異常除去---
function class:refresh(unit)
    local badStatusIDs = {89,91,96};
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