local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="36章_HARD_フォンギオン", version=2.5, id=3605014});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK4 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    }
}
--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7,
    SKILL4 = 8
}

class.cutInSkill = {
    [1] = 1,
    [3] = 1,
    --[4] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.BUFF_LIST = {
        [1] = {
            ID = 36051401,
            BUFF_ID = 17,  --与ダメージ
            VALUE = self.GD.buffVal_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 10
        }
    }
    self.HP_BUFF_LIST = {
        [1] = {
            ID = 36051405,
            BUFF_ID = 23,  --クリティカル耐性
            VALUE = self.GD.hpBuffVal_23,
            DURATION = 999999,
            ICON = 188
        },
        [2] = {
            ID = 36051406,
            BUFF_ID = 112,  --状態異常耐性
            VALUE = self.GD.hpBuffVal_112,
            DURATION = 999999,
            ICON = 67
        },
        [3] = {
            ID = 36051407,
            BUFF_ID = 113,  --状態異常回避率
            VALUE = self.GD.hpBuffVal_112,
            DURATION = 999999,
            ICON = 0
        }
    }
    self.TIME_BUFF_LIST = {
        [1] = {
            ID = 36051410,
            BUFF_ID = 22,  --クリティカル率
            VALUE = self.GD.tgBuffVal_22,
            DURATION = 999999,
            ICON = 11,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 36051420,
            BUFF_ID = 1,  --最大HP固定値
            VALUE = self.GD.tgBuffValue_1,
            DURATION = 999999,
            ICON = 2,
            COUNT = 0,
            MAX = 99
        },
        [3] = {
            ID = 36051430,
            BUFF_ID = 0, --被ダメージUPアイコン用
            VALUE = 0,
            DURATION = 999999,
            ICON = 139,
            COUNT = 0,
            MAX = 99
        }
    }
    self.STUN_BUFF_LIST = {
        ID = 36051430,
        BUFF_ID = 89,
        VALUE = 100,
        DURATION = 60,
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
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "時間経過でボスの被ダメージアップ：毒で加速", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "時間経過でボスのクリティカル率アップ：燃焼で遅延", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "時間経過でリバースエンド発動：ブレイクで経過時間リセット", COLOR = Color.white})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "クリティカル耐性・奥義上昇量・全状態異常耐性アップ", COLOR = Color.yellow})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "ダークレイ：ダメージ無効化無効", COLOR = Color.yellow})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
            used = false,
            isEnableSkip = false
        }
    }
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

function class:hp30(status)
    if status == "use3" then
        self.stateName = "FURY";
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 1;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(20);
        self:showMessage(self.HP30_MESSAGE_LIST);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[1]);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[2]);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[3]);
        self.spValue = self.GD.hp30AddSP;
    end
end

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY";
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(20);
        self.hp0Flg = true;
        self:extraTimer("delete" ,self.timeIndexA);
        self:extraTimer("delete" ,self.timeIndexB);
        self:extraTimer("delete" ,self.timeIndexC);
    end
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
        hp30AddSP = 40,

        buffVal_17 = 25,
        hpBuffVal_23 = 100,
        hpBuffVal_112 = 20,

        dmgVal_1 = 0.01,
        dmgVal_2 = 0.04,
        dmgVal_3 = 2,
        tgTimer_A = 45,
        tgLimit_A = 99,
        tgIconNum1_A = 139,
        tgIconNum2_A = 0,
        tgPosX_A = -70,
        tgPosY_A = 0,
        tgScale_A = 1,
        tgDeBuffSpeed_A = 2,

        tgBuffVal_22 = 10,
        tgTimer_B = 30,
        tgLimit_B = 99,
        tgIconNum1_B = 11,
        tgIconNum2_B = 0,
        tgPosX_B = 0,
        tgPosY_B = 0,
        tgScale_B = 1,
        tgDeBuffSpeed_B = 0.3,

        tgBuffValue_1 = -1000,
        tgTimer_C = 60,
        tgLimit_C = 99,
        tgIconNum1_C = 2,
        tgIconNum2_C = 0,
        tgPosX_C = 70,
        tgPosY_C = 0,
        tgScale_C = 1,
        tgPlusTime_C = 30
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP)---戦闘開始時の奥義ゲージ量
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
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"
    self.breakSkip = true
    self.hpSkill = 0
    self.saveBP = 0

    -- 経過時間ギミック
    self.breakFlg = false;
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    self.timeIndexA = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer_A, self.GD.tgLimit_A ,self.GD.tgIconNum1_A, self.GD.tgIconNum2_A, self.GD.tgPosX_A, self.GD.tgPosY_A, self.GD.tgScale_A);
    self.timeSpeedA = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexA);
    self.timeIndexB = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer_B, self.GD.tgLimit_B ,self.GD.tgIconNum1_B, self.GD.tgIconNum2_B, self.GD.tgPosX_B, self.GD.tgPosY_B, self.GD.tgScale_B);
    self.timeSpeedB = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexB);
    self.timeIndexC = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer_C, self.GD.tgLimit_C ,self.GD.tgIconNum1_C, self.GD.tgIconNum2_C, self.GD.tgPosX_C, self.GD.tgPosY_C, self.GD.tgScale_C);
    self.timeSpeedC = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexC);

    ---ボスギミック
    self.hp0Flg = false;
    self.endlessFlg = 0;
    self.battleTime = 0;
    self.timeStopFlg = 0;
    self.timeACount = 0;
    self.timeCCount = 0;
    self.tgHealRate = event.unit:getCalcHPMAX();

    --ボス固有
    event.unit:setSize(3);
    ---フォンギオンで使用する変数たち
    self.stopOrbit = nil;
    self.isStop = false;
    self.reverceMode = false;
    self.hitStopRegection = true;
    self.forceSkillNumber = 0;
    self.isReady = false
    self.Clock = nil;
    self:createClock(event.unit);
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self.posX = event.unit:getPositionX()
    self.posY = event.unit:getPositionY()
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
    ---奥義後の処理
    self:removeUnitStun(event.unit);
    if self.endlessFlg == 1 then
        self.battleTime = self.battleTime + event.deltaTime
        if self.battleTime >= 10.6 then
            self.endlessFlg = 2;
            self:stunAll(event.unit,false,5);
        end
    end

    ---extraTimerギミック
    if not self.hp0Flg and not self.lastSkillFLG then
        self:extraTimerOperation(event.unit);
    end
    ---死亡時処理
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.lastSkillFLG == nil then self.lastSkillFLG = false end
        if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
            self:removeUnitStun(event.unit);
            event.unit:getTeam():deadUnit(event.unit:getIndex());
            megast.Battle:getInstance():waveEnd(true);
        end
        if self.TRIGGERS[2].used then
            if self.deadCount == nil then self.deadCount = 0 end
            self.deadCount = self.deadCount + event.deltaTime;
            if self.deadCount >= 40 then
                self:removeUnitStun(event.unit);
                event.unit:getTeam():deadUnit(event.unit:getIndex());
                megast.Battle:getInstance():waveEnd(true);
            end
        end
    end

    if self.posX ~= nil then
        event.unit:setPosition(self.posX,self.posY)
    end
    return 1
end

function class:removeUnitStun(unit)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getTeamUnitCondition():findConditionWithID(-12) ~= nil then
                --myTeamUnit:takeGrayScale(0.1)
                if myTeamUnit:getTeamUnitCondition():findConditionWithID(self.STUN_BUFF_LIST.ID) == nil then
                    self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST)
                end
            else
                myTeamUnit:takeGrayScale(1)
                myTeamUnit:getTeamUnitCondition():removeConditionWithID(self.STUN_BUFF_LIST.ID)
                if self.lastSkillFLG then
                    if self.endlessFlg == 0 then
                        self.endlessFlg = 1;
                    end
                end
            end
        end
    end
end

function class:extraTimerOperation(unit)
    --奥義中か確認
    if self.timeStopFlg == 2 and unit:getUnitState() == kUnitState_skill then
        self.timeStopFlg = 1;
        self:extraTimer("stop" ,self.timeIndexB ,self.timeSpeedB);
        self:extraTimer("stop" ,self.timeIndexC ,self.timeSpeedC);
    end

    --毒状態かどうか
    local cond1 = unit:getTeamUnitCondition():findConditionWithType(90);  --毒
    local nowSpeed1 = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexA);
    if cond1 ~= nil  and nowSpeed1 == 1 then
        self:extraTimer("change" ,self.timeIndexA ,self.timeSpeedA ,self.GD.tgDeBuffSpeed_A);
    elseif cond1 == nil and nowSpeed1 ~= 1 then
        self:extraTimer("change" ,self.timeIndexA ,self.timeSpeedA ,1);
    end

    if self.timeStopFlg == 0 then
        --燃焼状態かどうか
        local cond2 = unit:getTeamUnitCondition():findConditionWithType(97);  --燃焼
        local nowSpeed2 = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexB);
        if cond2 ~= nil and nowSpeed2 == 1 then
            self:extraTimer("change" ,self.timeIndexB ,self.timeSpeedB ,self.GD.tgDeBuffSpeed_B);
        elseif cond2 == nil and nowSpeed2 ~= 1 and not unit:isBreak() then
            self:extraTimer("change" ,self.timeIndexB ,self.timeSpeedB ,1);
        end
        -- ブレイクで停止・タイマーリセット
        if unit:isBreak() and self.breakFlg then
            self:extraTimer("stop" ,self.timeIndexB ,self.timeSpeedB);
            self:extraTimer("reset" ,self.timeIndexC);
            self:extraTimer("stop" ,self.timeIndexC ,self.timeSpeedC);
        elseif not unit:isBreak() and self.breakFlg then
            self.breakFlg = false;
            self:extraTimer("change" ,self.timeIndexB ,self.timeSpeedB ,1);
            self:extraTimer("change" ,self.timeIndexC ,self.timeSpeedC ,1);
        end
    end
end

--extraTimer操作系
function class:extraTimer(str,timeIndex,timeSpeed,changeSpeed,buffIcon,skillIndex)
    if str == "start" then
        --setExtraTimerSpeed(int index,float speed);
        megast.Battle:getInstance():setExtraTimerSpeed(timeIndex ,timeSpeed);
    elseif str == "change" then
        megast.Battle:getInstance():setExtraTimerSpeed(timeIndex ,timeSpeed * changeSpeed);
    elseif str == "stop" then
        megast.Battle:getInstance():setExtraTimerSpeed(timeIndex ,0);
    elseif str == "reset" then
        --setExtraTimerSpeed(int index,float speed);
        megast.Battle:getInstance():setExtraTimerPercentage(timeIndex ,0);
    elseif str == "delete" then
        --removeExtraTimer(int index,float fadeTime,float delayTime,bool isAnimation);
        megast.Battle:getInstance():removeExtraTimer(timeIndex ,1 ,1 ,true);
    elseif str == "iconChange" then
        --setExtraTimerBuffIcon(int index,int iconNumber,int iconNumber2);
        megast.Battle:getInstance():setExtraTimerBuffIcon(timeIndex ,buffIcon ,0);
    elseif str == "setSkill" then
        --setExtraTimerBattleSkill(int index,int skillIndex);
        megast.Battle:getInstance():setExtraTimerBattleSkill(timeIndex ,skillIndex);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    if event.index == self.timeIndexA then
        self.timeACount = self.timeACount + 1;
        self:execAddBuff(event.unit,self.TIME_BUFF_LIST[3]);
    elseif event.index == self.timeIndexB then
        self:execAddBuff(event.unit,self.TIME_BUFF_LIST[1]);
    elseif event.index == self.timeIndexC then
        self.hpSkill = 4;
        event.unit:addSP(100);
        --event.unit:takeHeal(self.tgHealRate);
        self:unitHpDeBuff();
        self.timeCCount = self.timeCCount + 1;
        local timeCalc = self.GD.tgTimer_C + self.GD.tgPlusTime_C * self.timeCCount;
        megast.Battle:getInstance():setExtraTimerMaxTime(self.timeIndexC, timeCalc);
    end
    return event.count
end

function class:unitHpDeBuff()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.TIME_BUFF_LIST[2])
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "endless" then self:endless(event.unit); end
    if event.spineEvent == "cameraControll" then self:cameraControll(event.unit); end
    if event.spineEvent == "showStopOrbit" then self:showStopOrbit(event.unit); end
    if event.spineEvent == "stop" then self:stop(event.unit); end
    if event.spineEvent == "reStart" then
        self:restart(event.unit);
        self.timeStopFlg = 0;
        self:extraTimer("start" ,self.timeIndexB ,self.timeSpeedB);
        self:extraTimer("start" ,self.timeIndexC ,self.timeSpeedC);
    end

    if event.spineEvent == "clockAttack" then self.Clock:takeAttack(); end
    if event.spineEvent == "tickEnd" then self.Clock:tick(); end
    if event.spineEvent == "clockActionEnd" then self.Clock:takeBaseAnimation(); end
    if event.spineEvent == "reverce" then
        self.Clock:setVector(-1);
        self.Clock:takeSkill4();
    end

    if event.spineEvent == "reInit" then
        event.unit:setBreakPoint(event.unit:getBaseBreakCapacity());
        self.reverceMode = false;
        self.Clock:setVector(1);
        local HP = event.unit:getCalcHPMAX()
        if self.buffNumber == 3 then HP = HP / 2 end
        event.unit:setHP(HP);
    end

    if event.spineEvent == "reverceEnd" then
        --self.Clock:setVector(1);
        --self.hpSkill = 1
        --self.gameUnit:addSP(100)
        self.timeStopFlg = 0;
        self:extraTimer("start" ,self.timeIndexB ,self.timeSpeedB);
        self:extraTimer("start" ,self.timeIndexC ,self.timeSpeedC);
        event.unit:setHP(self.tgHealRate);
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

    if event.index == 4 then
        if megast.Battle:getInstance():isHost() then
            local target = self:randomPick()
            self:stun(event.unit,target,false,5)
            target:setBurstPoint(0)
            megast.Battle:getInstance():sendEventToLua(self.scriptID,4,target:getIndex())
        end
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

function class:randomPick()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local teamTable = {};
    local count = 0;
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            count = count + 1;
            teamTable[count] = myTeamUnit;
        end
    end
    local result = math.random(1,count);
    return teamTable[result];
end

function class:receive4(args)
    local target = nil
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == args.arg then
                target = myTeamUnit;
            end
        end
    end
    self:stun(self.gameUnit,target,false,5)
    target:setBurstPoint(0)
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
    --    self.cutInFLG = false
    --    event.unit:takeSkillWithCutin(event.index,1);
    --    return 0
    --end

    if self.hp0Flg then
        self.hp0Flg = false;
        self.lastSkillFLG = true;
    end

    if event.index == 1 or event.index == 3 then
        self:stunAll(event.unit,false,10);
        event.unit:setInvincibleTime(15);
    elseif event.index == 4 then
        self:moveAll(event.unit);
        self.gameUnit:setInvincibleTime(10);
    end

    if event.index == 2 or event.index == 3 then
        self:execAddBuff(event.unit,self.BUFF_LIST[1])
    end

    if event.index == 2 then
        self:showMessage(self.SKILL_MESSAGE_LIST);
    elseif event.index == 1 or event.index == 3 or event.index == 4 then
        self.timeStopFlg = 2;
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
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

function class:stun(unit,target,FLG,time)
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    target:getTeamUnitCondition():addCondition(-12,92,100,time,0);
    if FLG then
        target:setPosition((x + 350 + math.random(-50,50)),(y + math.random(-50,50)));
    end
end

function class:stunAll(unit,FLG,time)
    local targetTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:stun(unit,myTeamUnit,FLG,time);
        end
    end
end

function class:moveAll(unit)
    local targetTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local x = unit:getPositionX();
            local y = unit:getPositionY();
            myTeamUnit:setPosition((x + 350 + math.random(-50,50)),(y + math.random(-50,50)));
        end
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    return event.value
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
    --ダメージ補正
    event.value = event.value * (self.GD.dmgVal_1 + self.GD.dmgVal_2 * self.timeACount^self.GD.dmgVal_3)
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
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
    self.breakFlg = true;
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
    return 0
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

    ---スキップ可でブレイク中の場合はHPギミック発動しない
    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP],true)
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,index)
        return;
    end

    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
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
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP],true)
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
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
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



--=====================================================================================================================================
--エンドレスの演出関連
function class:endless(unit)
    local bg = unit:addOrbitSystemWithFile("50086endless","BG_ENDLESS");
    bg:setZOrder(2);
    unit:addOrbitSystemCameraWithFile("50086endless","FONT_ENDLESS",false);
    unit:addOrbitSystemWithFile("50086endless","CutIN_ENDLESS");
    local ef = unit:addOrbitSystem("endlessEF",0);
    ef:setDamageRateOffset(0.001);
    ef:setZOrder(9000);
    self.Clock:takeEndless();
end

function class:cameraControll(unit)
    unit:cameraLock(0,0.2,unit:getSkeleton():getBoneWorldPositionX("MAIN"),unit:getSkeleton():getBoneWorldPositionY("MAIN") -250);
end
--=====================================================================================================================================
--時止め関連
function class:showStopOrbit(unit)
    self.stopOrbit = unit:addOrbitSystem("skill1orbit",0);
    self.stopOrbit:setZOrder(2);
    self.hitStopRegection = true;
end

function class:stop(unit)
    self.isStop = true;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i,true);
        if uni ~= nil then
            uni:getTeamUnitCondition():addCondition(-12,92,100,13,0);
            uni:takeGrayScale(0.1);
            uni:takeHitStop(13);
        end
    end
end

function class:theWorld(unit)
    unit:takeGrayScale(0.1);
end

function class:canselled()
    self.isStop = false;
    if self.stopOrbit ~= nil then
        self.stopOrbit:takeAnimation(0,"skill1orbitCansel",false);
        self.stopOrbit = nil;
    end
    self:restart();
end

function class:restart()
    self.hitStopRegection = true;
    self.stopOrbit = nil;
    self.isStop = false;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i,true);
        if uni ~= nil then
            uni:takeGrayScale(0.99);
        end
    end
end

--=====================================================================================================================================
--背後の時計関係
function class:createClock(unit)
    self.Clock = {
        object = nil,
        vector = 1,
        count = 0,

        setUp = function(clock)
            clock.object:takeAnimation(0,"base",true);
            clock.object:setZOrder(3);
            clock.object:setPosition(-260,-30);
        end,

        takeBaseAnimation = function(clock)
            clock.object:takeAnimation(0,"base",true);
        end,

        setVector = function(clock,vec)
            clock.vector = vec;
        end,

        tick = function(clock)
            local clockTime = clock.count%12;
            local nextClockTime = (clock.count + clock.vector)%12;
            clock.object:setSetupAnimationName(""..clockTime.."to"..nextClockTime);
            clock.object:takeAnimation(1,""..clockTime.."to"..nextClockTime,false);
            clock.count = clock.count + clock.vector;
        end,

        takeAttack = function(clock)
            clock.object:takeAnimation(0,"attack3",true);
        end,

        takeEndless = function(clock)
            clock.object:takeAnimation(0,"skill3",true);
        end,

        takeSkill4 = function(clock)
            clock.object:takeAnimation(0,"skill4",true);
        end

    }
    self.Clock.object = unit:addOrbitSystemWithFile("50086Clock","base");
    self.Clock:setUp();
    self.Clock:tick();
end
--=====================================================================================================================================



class:publish();

return class;