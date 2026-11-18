local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_葬魂神オルデウス（強）", version=2.0, id=600000108});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK3 = 50, ATTACK4 = 50 },
        { ATTACK2 = 50 },
        { ATTACK3 = 50, ATTACK4 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK5 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
        { SKILL1 = 50 },
        { SKILL2 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL1 = 6,
    SKILL2 = 7
}

class.cutInSkill = {
    [2] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 60010801,
            BUFF_ID = 17,  --与ダメ
            VALUE = self.timeValue,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 60010802,
            BUFF_ID = 95,  --呪い効果
            VALUE = 0,
            DURATION = 999999,
            ICON = 85,
            COUNT = 0,
            MAX = 99
        },
        [3] = {
            ID = -1,
            BUFF_ID = 97,  --燃焼効果
            VALUE = self.GD.buffValue_97,
            DURATION = self.skill2BuffTime,
            ICON = 87,
        },
        [4] = {
            ID = -2,
            BUFF_ID = 90,  --毒効果
            VALUE = self.GD.buffValue_90,
            DURATION = self.skill2BuffTime,
            ICON = 80,
        },
        [5] = {
            ID = -3,
            BUFF_ID = 94,  --病気効果
            VALUE = self.GD.buffValue_94,
            DURATION = self.skill2BuffTime,
            ICON = 84,
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
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "物理回避", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "時間経過で与ダメージアップ", COLOR = Color.yellow})
    }
    self.SCULL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SCULL_MESSAGE1 or "亡霊が冒険者たちに襲いかかる！", COLOR = Color.red})
    }
    self.SKILL1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE1 or "状態異常ユニットの奥義ゲージダウン", COLOR = Color.red})
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "に", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE2 or "の効果", COLOR = Color.red})
    }
    self.BUFF_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BUFF_MESSAGE1 or "燃焼", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.BUFF_MESSAGE2 or "毒", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.BUFF_MESSAGE3 or "病気", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {}
    self.HP_TRIGGERS = {}
    self.hpMarkers = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
            if self.TRIGGERS[index].isEnableSkip then
                self.gameUnit:changeHpMarkerColor(self.hpMarkers[self.TRIGGERS[index].HP],0,255,255)
                self.gameUnit:changeHpMarkerTexture(self.hpMarkers[self.TRIGGERS[index].HP],"battle_marker_hp_marker_white_1.png","battle_marker_hp_marker_white_2.png","unit/animation/battle_marker_white.plist")
            end
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 30,
        attackDelay = 8,
        hitStop = 100,
        buffValue_17_1 = 0.001,
        buffValue_17_2 = 0.3,
        buffValue_97 = 1000,
        buffValue_90 = 1000,
        buffValue_94 = 10,
        buffTime1 = 20,
        buffTime2 = 5,
        orbitHP = 1000000,
        orbitBuffValue = -500,
        downBPValue = 300
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    --event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;
    self.cutInFLG = false;

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"
    self.breakSkip = true
    self.hpSkill = 0
    self.saveBP = 0

    ---ボスギミック
    self.strongBossFlg = true  --弱はfalse
    self.skill1Flg = false
    self.skill2Flg = false
    self.skill2Count = 0
    self.skill2BuffTime = 0
    self.battleTime = 0
    self.timeValue = 0
    self.buffCount = 0
    self.infoTbl = {}
    self:setBuffBoxList()

    --葬魂神オルデウスの共有ギミック
    self.bullets = {}
    self.bulletInfo = {
        new = function (_bullet,_targetUnit,_uniqueID)
            return {
                bullet = _bullet,
                targetUnit = _targetUnit,
                uniqueID = _uniqueID,
                frame = 0,
                angle = 0,
                posx = 0,
                posy = 0,
                speedkeisuu = 1
            }
        end
    }
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:hpTriggersCheck(event.unit)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効

    --時間経過でバフする
    if self.strongBossFlg then
        self:addTimeBuff(event.unit,event.deltaTime)
    end

    --奥義中か確認
    if self.skill2Flg and event.unit:getUnitState() ~= kUnitState_skill then
        self.skill2Flg = false
        event.unit:setInvincibleTime(0)
    end

    --葬魂神オルデウスの共有ギミック
    if table.maxn(self.bullets) > 0 then
        for i = 1,table.maxn(self.bullets) do
            self:bulletControll(self.bullets[i],event.deltaTime)
        end
    end
    return 1
end

function class:addTimeBuff(unit,deltaTime)
    self.battleTime = self.battleTime + deltaTime
    local buffValue = 0
    local buff = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[1].ID)
    if buff ~= nil then
        buffValue = buff:getValue()
    end

    buffValue = math.floor(buffValue / 10)
    if buffValue > self.buffCount then
        self.buffCount = self.buffCount + 1
    end

    self.timeValue = math.ceil(self.GD.buffValue_17_1 * self.battleTime^2 + self.GD.buffValue_17_2 * self.battleTime)
    self:execAddBuff2(unit,self.BUFF_LIST[1],self.timeValue,self.BUFF_LIST[1].DURATION)
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    --葬魂神オルデウスの共有ギミック
    if event.spineEvent == "death" then return self:death() end
    if event.spineEvent == "skull" then return self:skull(event) end
    if event.spineEvent == "onDestroy" then return self:onDestroy(event.unit) end
    return 1;
end

function class:death()
    self.skill2BuffTime = self.GD.buffTime1 + self.skill2Count * self.GD.buffTime2
    local loopCount = 0
    if self.skill2Count >= 11 then
        loopCount = 4
    elseif self.skill2Count >= 4 then
        loopCount = 3
    elseif self.skill2Count >= 2 then
        loopCount = 2
    elseif self.skill2Count == 1 then
        loopCount = 1
    end

    if not self.strongBossFlg then
        loopCount = 1
    end

    --info用テーブルを作成
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            self.infoTbl[i] = {
                flg = false,
                unitName = teamUnit:getUnitName(),
                burn = 0,
                poison = 0,
                disease = 0
            }
        end
    end

    ---庇うユニットが居るか確認
    local target = nil
    local loopNum = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            loopNum = loopNum + 1
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                target = cond:getProtectTarget()
            end
        end
    end

    local rand = 0
    if target ~= nil then
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getIndex() == target then
                    for j = 1,loopCount do
                        for k = 0,loopNum -1 do
                            rand = Random.range(3,6)  --3~5までの数字
                            self:execAddBuff3(teamUnit,self.BUFF_LIST[rand],self.skill2BuffTime)
                            if rand == 3 then
                                self.infoTbl[i].flg = true
                                self.infoTbl[i].burn = self.infoTbl[i].burn + 1
                            elseif rand == 4 then
                                self.infoTbl[i].flg = true
                                self.infoTbl[i].poison = self.infoTbl[i].poison + 1
                            elseif rand == 5 then
                                self.infoTbl[i].flg = true
                                self.infoTbl[i].disease = self.infoTbl[i].disease + 1
                            end
                        end
                    end
                end
            end
        end
    else
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                for j = 1,loopCount do
                    rand = Random.range(3,6)  --3~5までの数字
                    self:execAddBuff3(teamUnit,self.BUFF_LIST[rand],self.skill2BuffTime)
                    if rand == 3 then
                        self.infoTbl[i].flg = true
                        self.infoTbl[i].burn = self.infoTbl[i].burn + 1
                    elseif rand == 4 then
                        self.infoTbl[i].flg = true
                        self.infoTbl[i].poison = self.infoTbl[i].poison + 1
                    elseif rand == 5 then
                        self.infoTbl[i].flg = true
                        self.infoTbl[i].disease = self.infoTbl[i].disease + 1
                    end
                end
            end
        end
    end
    self:strInfoFix()
    return 1
end

function class:strInfoFix()
    local infoStr = ""
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local buffStr = ""
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil and self.infoTbl[i].flg then
            if self.infoTbl[i].burn == 1 then
                buffStr = self.BUFF_MESSAGE_LIST[1].MESSAGE
            elseif self.infoTbl[i].burn >= 2 then  --バフの個数が２以上なら「×」+数字をつける
                buffStr = self.BUFF_MESSAGE_LIST[1].MESSAGE .."×".. tostring(self.infoTbl[i].burn)
            end

            if self.infoTbl[i].poison ~= 0 then
                if buffStr == "" then  --前のバフメッセージがあるか
                    if self.infoTbl[i].poison == 1 then
                        buffStr = self.BUFF_MESSAGE_LIST[2].MESSAGE
                    elseif self.infoTbl[i].poison >= 2 then
                        buffStr = self.BUFF_MESSAGE_LIST[2].MESSAGE .."×".. tostring(self.infoTbl[i].poison)
                    end
                else
                    if self.infoTbl[i].poison == 1 then  --前のバフメッセージがある場合は追加文の前に「、」をつける
                        buffStr = buffStr .."、".. self.BUFF_MESSAGE_LIST[2].MESSAGE
                    elseif self.infoTbl[i].poison >= 2 then
                        buffStr = buffStr .."、".. self.BUFF_MESSAGE_LIST[2].MESSAGE .."×".. tostring(self.infoTbl[i].poison)
                    end
                end
            end

            if self.infoTbl[i].disease ~= 0 then
                if buffStr == "" then
                    if self.infoTbl[i].disease == 1 then
                        buffStr = self.BUFF_MESSAGE_LIST[3].MESSAGE
                    elseif self.infoTbl[i].disease >= 2 then
                        buffStr = self.BUFF_MESSAGE_LIST[3].MESSAGE .."×".. tostring(self.infoTbl[i].disease)
                    end
                else
                    if self.infoTbl[i].disease == 1 then
                        buffStr = buffStr .."、".. self.BUFF_MESSAGE_LIST[3].MESSAGE
                    elseif self.infoTbl[i].disease >= 2 then
                        buffStr = buffStr .."、".. self.BUFF_MESSAGE_LIST[3].MESSAGE .."×".. tostring(self.infoTbl[i].disease)
                    end
                end
            end

            infoStr = self.infoTbl[i].unitName .. self.SKILL2_MESSAGE_LIST[1].MESSAGE .. buffStr ..self.SKILL2_MESSAGE_LIST[2].MESSAGE
            self:showFormatMessage(self.SKILL2_MESSAGE_LIST[1],infoStr)
        end
    end
end

function class:showFormatMessage(messageBox,str)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(string.format(messageBox.MESSAGE,str),messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(str,messageBox.DURATION,messageBox.COLOR);
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

    if event.index == 5 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("1-skill2");
        self:showMessage(self.SCULL_MESSAGE_LIST)
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    end

    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
    self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK)
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

    if event.index == 1 then
        self.skill1Flg = true
        self:execAddBuff(event.unit,self.BUFF_LIST[2])
        self:showMessage(self.SKILL1_MESSAGE_LIST)
    elseif event.index == 2 then
        event.unit:setNextAnimationName("skill3");
        event.unit:setNextAnimationEffectName("1-skill3");
        self.skill2Flg = true
        self.skill2Count = self.skill2Count + 1
        event.unit:setInvincibleTime(30)
        local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[2].ID)
        if buff ~= nil then
            event.unit:getTeamUnitCondition():removeCondition(buff)
        end
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
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

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.skill1Flg then
        self.skill1Flg = false
        self:takeSkill1Buff()
    end
    return event.value
end

function class:takeSkill1Buff()
    local flg = false
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        flg = false
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            for _,v in pairs(self:getBadStatusListOut129()) do
                if teamUnit:getTeamUnitCondition():findConditionValue(v) > 0 then
                    flg = true
                end
            end

            if flg then
                teamUnit:setBurstPoint(teamUnit:getBurstPoint() - self.GD.downBPValue)
            end
        end
    end
end

function class:getBadStatusListOut129()
    local badStatusList = {
        89, 90, 91, 92, 93, 94, 95, 96, 97, --129,
        131, 135, 201, 202, 203, 204, 205, 206, 207, 208, 233, 234
    }
    return badStatusList
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    return event.value
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit) ---停止系状態異常除去(このタイミングでないとたまにバグる)
        return self:calcDamageValue(unit,stopBorder,value)
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
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
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
    --オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy)
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

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
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
                    self:execTrigger(index)
                end
            else
                ---ブレイクスルー
                self:execTrigger(index)
            end
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
    self.TRIGGERS[index].used = true
    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index)
        return;
    end

    self.TRIGGERS[index].action(action)
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

---------------------------------------------------------------------------------
-- receive5(トリガースキップ時ゲスト側)
---------------------------------------------------------------------------------
function class:receive5(args)
    self.TRIGGERS[args.arg].used = true
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
    return 1
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

    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > buffBox.MAX then
                count = buffBox.MAX
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
end

function class:execAddBuff2(unit,buffBox,buffValue,buffTime)
    local buff  = nil;
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

    local oldBuff = nil
    local count = 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1
            if count > buffBox.MAX then
                count = buffBox.MAX
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffValue,buffTime,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffValue,buffTime,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffValue,buffTime,buffBox.ICON);
    end

    if self.buffCount ~= 0 then
        buffBox.COUNT = self.buffCount
        if buffBox.COUNT ~= nil then
            buff:setMaxConditionIconNumber(buffBox.MAX);
            buff:setNumber(buffBox.COUNT);
            megast.Battle:getInstance():updateConditionView();
        end
    end
end

function class:execAddBuff3(unit,buffBox,buffTime)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffTime,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffTime,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffTime,buffBox.ICON);
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


--葬魂神オルデウスの共有ギミック
-- == 壊魂振動 ==
--==========================================
function class:skull(event)
    --local hpRatio = event.unit:getHP()/event.unit:getCalcHPMAX();
    --local bulletCount = 4 - hpRatio * 2;
    local bulletCount = 1
    for i = 0,bulletCount do
        local s = event.unit:addOrbitSystem("skullBase",2)
        s:setHitCountMax(1)
        s:setEndAnimationName("explosion")
        local x = event.unit:getPositionX()
        local y = event.unit:getPositionY()
        --玉の出る座標をちょっとランダムにばらけさせたい
        local amplitude = 100;
        local rand = LuaUtilities.rand(0,amplitude);
        local rand2 = LuaUtilities.rand(0,amplitude);
        s:setPosition(x + rand - 50,y+350 + rand2 - 50);
        --s:setActiveSkill(2);
        -- s:takeAnimation(0,"skullBase",true);
        s:setOpacity(0);
        s:runAction(cc.FadeIn:create(1));
        local tama = self.bulletInfo.new(s,event.unit:getTargetUnit():getIndex(),0);
        table.insert(self.bullets,tama)

        s:setBaseHP(self.GD.orbitHP)
        s:setHP(self.GD.orbitHP)
        local buff = s:getTeamUnitCondition():addCondition(60010810,21,self.GD.orbitBuffValue,99999,0);
        buff:setScriptID(22)
    end
    return 1;
end

function class:onDestroy(unit)
    local atari = 1
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i].bullet == unit then
            atari = i
        end
    end

    self.bullets[atari].bullet:setEndAnimationName("");
    table.remove(self.bullets,atari);
    return 1;
end

function class:bulletControll(bulletinstance,deltaTime)
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local sp = 1;
    local speedOrigin = 1;
    if framecnt == 0 then
        local rand = LuaUtilities.rand(0,360);
        bulletinstance.angle = rand;
        bulletinstance.speedkeisuu = LuaUtilities.rand(100,130)/100;
        sp = speedOrigin;
        bulletinstance.posx = bulletinstance.bullet:getPositionX();
        bulletinstance.posy = bulletinstance.bullet:getPositionY();
    end

    bulletinstance.frame = bulletinstance.frame + 1 * deltaTime/0.016666667;
    if framecnt <= 1 then
    elseif framecnt < 30 then
        sp = 1 + math.abs(30 - framecnt)/30 * speedOrigin*3;
    elseif framecnt < 600 then
        sp = 2;
        local bullettarget = megast.Battle:getInstance():getTeam(not bulletinstance.isPlayer):getTeamUnit(bulletinstance.targetUnit);
        if bullettarget ~= nil then
            local targetangle = self:getDeg(currentbullet:getPositionX(),currentbullet:getPositionY(),bullettarget:getPositionX(),bullettarget:getPositionY());
            if targetangle < 0 then
                targetangle = 360 + targetangle;
            end

            local dir = targetangle - bulletinstance.angle;
            if dir > 180 then
                dir = -(360 - dir);
            end

            if dir < -180 then
                dir = (360 - dir);
            end

            if dir ~= 0 then
                local maxdir = 1 * deltaTime/0.016666667;
                if dir > maxdir then
                    dir = maxdir;
                elseif dir < -maxdir then
                    dir = -maxdir;
                end
                bulletinstance.angle = bulletinstance.angle + dir;
            end
        end
    else
        bulletinstance.bullet:takeAnimation(0,"explosion",false);
    end

    local oneFrame = 0.016666666;
    self:moveByFloat(
            bulletinstance,
            self:calcXDir(self:degToRad(bulletinstance.angle),sp * deltaTime/oneFrame),
            self:calcYDir(self:degToRad(bulletinstance.angle),sp * deltaTime/oneFrame)
    );
end

function class:getDeg(startx,starty,targetx,targety)
    return self:radToDeg(self:getRad(startx,starty,targetx,targety))
end

function class:getRad(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx)
end

function class:degToRad(deg)
    return deg * 3.14/180;
end

function class:radToDeg(rad)
    return rad * 180/3.14;
end

function class:calcXDir(rad,speed)
    return math.cos(rad)*speed;
end

function class:calcYDir(rad,speed)
    return math.sin(rad)*speed;
end

function class:move(node,movex,movey)
    node:setPosition(node:getPositionX()+movex,node:getPositionY()+movey);
    return 1;
end

function class:moveByFloat(_bulletinstance,xdistance,ydistance)
    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;
    return true;
end
--==========================================


class:publish();

return class;