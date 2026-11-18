--@additionalItem,160052504
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超新星級_HARD_オルデウス・絶", version=2.7, id=4002402});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK4 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK4 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
        { SKILL2 = 50 }
    },
    HP0 = {
        { SKILL3 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7
}

class.cutInSkill = {
    [1] = 0,
    [2] = 0,
    [3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 400241,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 1,
            ICON = 0,
            --COUNT = 0,
            --MAX = 10
        }
    }
    self.BREAK_BUFF_LIST = {
        [1] = {
            ID = 4002410,  --ブレイク耐性アイコン用
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 9
        }
    }
    self.TIME_BUFF_LIST = {
        [1] = {
            ID = 4002420,
            BUFF_ID = 17,  --与ダメ
            VALUE = self.GD.tgBuffVal_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        }
    }
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 4002410,
            BUFF_ID = 13,  --攻撃力
            VALUE = self.GD.skillBuffVal_13,
            DURATION = 999999,
            ICON = 4,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 4002411,
            BUFF_ID = 0,  --奥義発動カウント表示用
            VALUE = 0,
            DURATION = 999999,
            ICON = self.GD.skillCountIcon,
            COUNT = 0,
            MAX = 99
        }
    }
    self.HP_BUFF_LIST = {
        [1] = {
            ID = 4002430,
            BUFF_ID = 22,   --クリティカル率
            VALUE = self.GD.hpBuffVal_22,
            DURATION = 999999,
            ICON = 11
        },
        [2] = {
            ID = 4002440,
            BUFF_ID = 142,   --スーパークリティカル率
            VALUE = self.GD.hpBuffVal_142,
            DURATION = 999999,
            ICON = 229
        },
        [3] = {
            ID = 4002450,
            BUFF_ID = 23,  --クリティカル耐性
            VALUE = self.GD.hpBuffValue_23,
            DURATION = 999999,
            ICON = 188
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "HP自然回復キラー", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "鉄壁状態：被ダメージ大幅軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ブレイクで鉄壁状態解除", COLOR = Color.yellow})
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "クリティカル率アップ", COLOR = Color.yellow})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "スーパークリティカル率アップ", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "クリティカル耐性・奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ブレイクで鉄壁状態解除！", COLOR = Color.red})
    }
    self.BREAK_END_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_END_MESSAGE1 or "ブレイク耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_END_MESSAGE2 or "呪い状態の敵からの被ダメージ軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_END_MESSAGE3 or "時間経過で与ダメージアップ：徐々に加速", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.BREAK_END_MESSAGE4 or "出血で遅延", COLOR = Color.white})
    }
    self.ITEM_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.ITEM_MESSAGE1 or "闇のオーラ：奥義ゲージ・呪い耐性低下", COLOR = Color.magenta, isPlayer = true})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "%dの固定ダメージ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE2 or "呪い状態ユニットの攻撃力ダウン", COLOR = Color.red})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp60(status) end,
            HP = 60,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false,
            isEnableSkip = false
        },
        [3] = {
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

function class:hp60(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(30);
        self:showMessage(self.HP60_MESSAGE_LIST);
        self:deBuffRefresh(self.gameUnit);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[1]);
    end
end

function class:hp30(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;
            self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(30);
        self:showMessage(self.HP30_MESSAGE_LIST);
        self:deBuffRefresh(self.gameUnit);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[2]);
    end
end

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3;
            --self.saveBP = self.gameUnit:getBurstPoint();
            self.gameUnit:addSP(100);
        end
        self.gameUnit:setInvincibleTime(30);
        self:showMessage(self.HP0_MESSAGE_LIST);
        self:deBuffRefresh(self.gameUnit);
        self:initSkillWeight({HP0 = 100});
        self.gameUnit:setHP(self.setBossHP);
        self.spValue = self.GD.hp0AddSP;
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[3]);
        self.timeIndexB = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimerB, self.GD.tgLimitB ,self.GD.tgIconNum1B, self.GD.tgIconNum2B, self.GD.tgPosXB, self.GD.tgPosYB, self.GD.tgScaleB);
        self.timeSpeedB = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexB);
    end
end

function class:deBuffRefresh(unit)
    self.buffIDList = {89,90,91,92,93,94,95,97,129,131,135};
    local badStatusIDs = self.buffIDList;
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

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 30,
        hp0AddSP = 40,
        startAddSP = 40,
        attackDelay = 6,
        hitStop = 100,

        tgTimerA = 30,
        tgLimitA = 99,
        tgIconNum1A = 26,
        tgIconNum2A = 0,
        tgPosXA = -50,
        tgPosYA = 0,
        tgScaleA = 1,
        deBuffTimeASpeed1 = 0.5,
        deBuffTimeASpeed2 = 0.333,
        deBuffTimeASpeed3 = 0.166,
        downTime = 1,
        downTimeMax = 15,

        tgTimerB = 22,
        tgLimitB = 99,
        tgIconNum1B = 74,
        tgIconNum2B = 0,
        tgPosXB = 50,
        tgPosYB = 0,
        tgScaleB = 1,

        tDmgVal = 0.01,
        tBreDmgVal = 0.1,
        deBuffTDmgVal = 0.01,

        hp0SetHpRate = 0.5,
        skillFixDmg = 5000,
        skillCutDmg = 2000,
        skillCountIcon = 181,

        skill2OrbitHP = 1000000,

        skillBuffVal_13 = 50,
        tgBuffVal_17 = 30,
        hpBuffVal_22 = 150,
        hpBuffVal_142 = 20,
        hpBuffValue_23 = -200
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
    self.breakFlgB = false;
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    self.timeIndexA = nil;
    self.timeIndexB = nil;

    ---装備ギミック
    self.itemFlg = false;
    self.itemId = 160052504;  --Hard
    self.item = event.unit:setItemSkill(0,self.itemId);

    ---ボスギミック
    self.startWaveFlg = false;
    self.isBreak = false;
    event.unit:addNumBreakBadge(1);
    self.timerATime = self.GD.tgTimerA;
    self.setBossHP = event.unit:getCalcHPMAX() * self.GD.hp0SetHpRate;
    self.skill3Count = 0;

    --葬魂神オルデウスの共有ギミック
    self:setConsts();
    self.consts.skill3FixedDamage = self.GD.skillFixDmg;
    self.bullets = {};
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
            };
        end
    };
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self.startWaveFlg = true;
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    if self.timeIndexA ~= nil then
        self:extraTimerAOperation(event.unit);
    end

    if self.timeIndexB ~= nil then
        self:extraTimerBOperation(event.unit);
    end

    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効

    --装備ギミック
    if self.itemFlg and self:attackCheck(event.unit) then
        self.itemFlg = false;
        self:useItem(event.unit,0);
    end

    --初ブレイク終了後の処理
    if self.startWaveFlg then
        if not event.unit:isBreak() and not self.isBreak and event.unit:getNumBreakBadges() == 0 then
            self.isBreak = true;
            self:execAddBuff(event.unit,self.BREAK_BUFF_LIST[1]);
            self.timeIndexA = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimerA, self.GD.tgLimitA ,self.GD.tgIconNum1A, self.GD.tgIconNum2A, self.GD.tgPosXA, self.GD.tgPosYA, self.GD.tgScaleA);
            self.timeSpeedA = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexA);
            self:showMessage(self.BREAK_END_MESSAGE_LIST);
        end
    end

    --葬魂神オルデウスの共有ギミック
    --壊魂振動
    if table.maxn(self.bullets) > 0 then
        for i = 1,table.maxn(self.bullets) do
            self:bulletControll(self.bullets[i],event.deltaTime);
        end
    end
    --滅魂宿世
    self.setDeltaTime = event.deltaTime;
    if self.fadeOutFlag then
        self:fadeOutUpdate(self.setDeltaTime);
    elseif self.targetFadeInFlag then
        self:fadeInTargetUpdate(self.setDeltaTime);
    elseif self.fadeInFlag then
        self:fadeInUpdate(self.setDeltaTime);
    end
    return 1;
end

function class:extraTimerAOperation(unit)
    local flg = "";
    local stage = 0;
    local nowSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexA);
    -- 出血状態かどうか
    local cond = unit:getTeamUnitCondition():findConditionWithGroupID(21011);--出血専用グループID
    if cond ~= nil then
        flg = "changeOn";
    elseif cond == nil and nowSpeed ~= 1 then
        flg = "changeOff";
    end

    -- ブレイク中は止める
    if unit:isBreak() and self.breakFlg then
        flg = "stop";
    elseif not unit:isBreak() and self.breakFlg then
        self.breakFlg = false;
        flg = "changeOff";
    end

    -- 無敵中は止める
    if unit:getInvincibleTime() > 0 then
        flg = "stop";
    end

    if flg == "stop" then
        self:extraTimer("stop" ,self.timeIndexA);
    elseif flg == "changeOn" then
        stage = unit:getParameter("304_Blood");
        if stage == "1" then
            self:extraTimer("change" ,self.timeIndexA ,self.timeSpeedA ,self.GD.deBuffTimeASpeed1);
        elseif stage == "2" then
            self:extraTimer("change" ,self.timeIndexA ,self.timeSpeedA ,self.GD.deBuffTimeASpeed2);
        elseif stage == "3" then
            self:extraTimer("change" ,self.timeIndexA ,self.timeSpeedA ,self.GD.deBuffTimeASpeed3);
        end
    elseif flg == "changeOff" then
        self:extraTimer("change" ,self.timeIndexA ,self.timeSpeedA ,1);
    end
end

function class:extraTimerBOperation(unit)
    local flg = "";
    -- ブレイク中は止める
    if unit:isBreak() and self.breakFlgB then
        flg = "stop";
    elseif not unit:isBreak() and self.breakFlgB then
        self.breakFlgB = false;
        flg = "changeOff";
    end

    if flg == "stop" then
        self:extraTimer("stop" ,self.timeIndexB);
    elseif flg == "changeOff" then
        self:extraTimer("change" ,self.timeIndexB ,self.timeSpeedB ,1);
    end
end

function class:attackCheck(unit)
    local state = unit:getUnitState();
    if state ~= kUnitState_attack and state ~= kUnitState_skill then
        return true;
    end
    return false;
end

function class:useItem(unit,index)
    unit:takeItemSkill(index);
    self.item:setCoolTimer(0);
    self:showMessage(self.ITEM_MESSAGE_LIST);
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    if event.index == self.timeIndexA then
        self.timerATime = self.timerATime - 1;
        if self.timerATime <= self.GD.downTimeMax then
            self.timerATime = self.GD.downTimeMax;
        end

        self:extraTimer("delete" ,self.timeIndexA);
        self.timeIndexA = nil;
        self.timeIndexA = megast.Battle:getInstance():createExtraTimer(self.timerATime, self.GD.tgLimitA ,self.GD.tgIconNum1A, self.GD.tgIconNum2A, self.GD.tgPosXA, self.GD.tgPosYA, self.GD.tgScaleA);
        self.timeSpeedA = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexA);
        self:execAddBuff(event.unit,self.TIME_BUFF_LIST[1]);
    elseif event.index == self.timeIndexB then
        self.itemFlg = true;
    end
    return event.count;
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
        megast.Battle:getInstance():removeExtraTimer(timeIndex ,1 ,1 ,false);
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
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    --葬魂神オルデウスの共有ギミック
    if event.spineEvent == "skull" then return self:skull(event); end
    if event.spineEvent == "onDestroy" then return self:onDestroy(event.unit); end
    if event.spineEvent == "generalPause" then return self:generalPause(event.unit); end
    if event.spineEvent == "target" then return self:targetPick(event.unit); end
    if event.spineEvent == "fadeInTarget" then return self:fadeInTarget(event.unit); end
    if event.spineEvent == "mistIn" then return self:mistIn(event.unit); end
    if event.spineEvent == "specialUpdate" then return self:specialUpdate(event.unit); end
    if event.spineEvent == "death" then return self:death(event.unit); end
    return 1;
end

--滅魂宿世(skill3)
function class:findCursedAtRandom(unit)
    ---ここにターゲットにするユニットの条件を書く
    --全体攻撃の為、ピックしない
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            return nil;
        end
    end
    return nil;
end

function class:death(unit)
    self.deathExcuteFlg = false;
    --megast.Battle:getInstance():pauseUnit(0);
    self:fadeInAll();
    unit:resumeUnit();
    unit.m_IgnoreHitStopTime = 0;
    megast.Battle:getInstance():setBattleState(kBattleState_active);
    unit:setInvincibleTime(0);
    for i = 0,4 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            self:excuteAction(uni);
            uni:getTeamUnitCondition():addCondition(09990,0,0,0.1,0);
        end
    end

    --霧モードなら霧を再展開
    if self.isMist and self.blackMist == nil  then
        self.blackMist = unit:addOrbitSystemCamera("blackmist_in",0);
        self.blackMist:takeAnimation(0,"blackmist_in",true);
        self.blackMist:setZOrder(8000);
    end

    ---skill3Hitタイミングに通る、ここでHit時効果を書く
    if self.deathTarget ~= nil then
        self.deathTarget = nil;
    end
    --PT全体攻撃
    self:execAddBuff(unit,self.SKILL_BUFF_LIST[2]);  --カウント表示用バフ
    self.skill3Count = self.skill3Count + 1;
    local damage = self.consts.skill3FixedDamage + (self.skill3Count * self.GD.skillCutDmg);
    self:takeSkillDamage(self.SKILL_BUFF_LIST[1],damage);
    --info表示
    self:showFormatMessage(self.SKILL_MESSAGE_LIST[1],damage);
    self:showMessage(self.SKILL_MESSAGE_LIST,2);
    return 1;
end

function class:takeSkillDamage(buffBox,damage)
    local team = megast.Battle:getInstance():getTeam(true);
    local FLG = false;
    local buffFLG = false;
    local count = 1;
    local buffCount = 0;
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                FLG = true;
                count = count + 1;
            end

            --状態異常を受けているユニットの数
            local buff = teamUnit:getTeamUnitCondition():findConditionWithType(95);  --呪い
            if buff ~= nil then
                buffFLG = true;
                buffCount = buffCount + 1;
            end
        end
    end
    ---庇うユニットがいる場合
    if FLG then
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
                if cond == nil then
                    for i = 1,count do
                        teamUnit:setHP(teamUnit:getHP() - damage);
                        teamUnit:takeDamagePopup(teamUnit,damage);
                    end
                    --PTの状態異常分デバフ付与
                    if buffFLG then
                        for i = 1,buffCount do
                            self:execAddBuff(teamUnit,buffBox);
                        end
                    end
                end
            end
        end
    else
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                local buff = teamUnit:getTeamUnitCondition():findConditionWithType(95);  --呪い
                if buff ~= nil then
                    self:execAddBuff(teamUnit,buffBox);
                end
                teamUnit:setHP(teamUnit:getHP() - damage);
                teamUnit:takeDamagePopup(teamUnit,damage);
            end
        end
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

    --装備ギミック
    if self.itemFlg then
        self.itemFlg = false;
        self:useItem(event.unit,0);
        return 0;
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

    --装備ギミック
    if self.itemFlg then
        self.itemFlg = false;
        self:useItem(event.unit,0);
        event.unit:setNextAnimationName("skill3");
        event.unit:setNextAnimationEffectName("1-skill3");
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
    local enemyUnit = self:getAncestorUnit(event.enemy);
    ---ブレイクするまではダメージ補正
    if event.unit:getNumBreakBadges() ~= 0 then
        event.value = event.value * self.GD.tDmgVal;
    elseif self.isBreak then
        --呪い状態の敵からのダメージ補正
        local cond = enemyUnit:getTeamUnitCondition():findConditionWithType(95);
        if cond ~= nil then
            event.value = event.value * self.GD.deBuffTDmgVal;
        end
    end

    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
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
        self.breakSkip = false;
        return 0;
    end
    --オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    --ブレイク耐性
    if self.isBreak then
        event.value = event.value * self.GD.tBreDmgVal;
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
    self.breakFlgB = true;
    event.unit:removeNumBreakBadge();
    self:showMessage(self.BREAK_MESSAGE_LIST);
    return 1;
end

---------------------------------------------------------------------------------
-- takeCastItem
---------------------------------------------------------------------------------
function class:takeCastItem(event)
    event.unit:setNextAnimationName("idle");
    return 0;
end

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.afterSkillFLG then
            self.gameUnit:setInvincibleTime(0)
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if not self.TRIGGERS[3].used then
        return 0;
    end
    return 1;
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



--葬魂神オルデウスの共有ギミック
-- == 壊魂振動(skill2) ==
--====================================================================================
function class:skull(event)
    --local hpRatio = event.unit:getHP()/event.unit:getCalcHPMAX();
    --local bulletCount = 4 - hpRatio * 2;
    local bulletCount = 1;
    for i = 0,bulletCount do
        local s = event.unit:addOrbitSystem("skullBase",2);
        s:setHitCountMax(1);
        s:setEndAnimationName("explosion");
        local x = event.unit:getPositionX();
        local y = event.unit:getPositionY();
        --玉の出る座標をちょっとランダムにばらけさせたい
        local amplitude = 100;
        local rand = LuaUtilities.rand(0,amplitude);
        local rand2 = LuaUtilities.rand(0,amplitude);
        s:setPosition(x + rand - 50,y+350 + rand2 - 50);
        --s:setActiveSkill(2);
        --s:takeAnimation(0,"skullBase",true);
        s:setOpacity(0);
        s:runAction(cc.FadeIn:create(1));
        local tama = self.bulletInfo.new(s,event.unit:getTargetUnit():getIndex(),0);
        table.insert(self.bullets,tama);
        s:setBaseHP(self.GD.skill2OrbitHP);
        s:setHP(self.GD.skill2OrbitHP);
    end
    return 1;
end

function class:onDestroy(unit)
    local atari = 1
    for i = 1,table.maxn(self.bullets) do
        if self.bullets[i].bullet == unit then
            atari = i;
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
    return self:radToDeg(self:getRad(startx,starty,targetx,targety));
end

function class:getRad(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx);
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
--====================================================================================


-- == 滅魂宿世(skill3) ==
--====================================================================================
function class:setConsts()
    self.setDeltaTime = 0;
    self.deathExcuteFlg = false;
    self.deathTarget = nil;
    self.blackMist = nil;
    self.isMist = false;
    self.mistCounter = 0;
    self.fadeOutFlag = false;
    self.targetFadeInFlag = false;
    self.fadeInFlag = false;
    self.fadeOutFrame = 0;
    self.targetFadeInFrame = 0;
    self.fadeInFrame = 0;
    self.consts = {
        unitHight = 100,
        curseBuffID = 95,
        fogBuffID = 31,
        fogBuffEffectID = 31,
        fogBuffIconID = 16,
        fogBuffValue = 200,
        fogBuffTime = 9999,
        fogCoolTurn = 5, --Breakされてから再度霧を展開することが可能になるまでの行動数
        breakDebuffID = 27,
        breakDebuffEffectID = 27,
        breakDebuffIconID = 0,
        breakDebuffValue = 100,
        breakDebuffTime = 9999,
        fadeOutTime = 0.3,
        fadeInTime = 0.3,
        powerBorderOfDeath = 10000,
        skill3FixedDamage = 9999
    }
    return 1;
end

function class:generalPause(unit)
    self.deathExcuteFlg = true;
    --まずヒットストップ中のユニットのヒットストップを解除　そして全員気絶
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            uni:resumeUnit();
            uni:getTeamUnitCondition():addCondition(09990,89,100,20,0);
            --全員初期位置へ移動
            uni:setPositionX(uni:getPositionX() + 150);
        end
    end
    --全員停止
    megast.Battle:getInstance():pauseUnit(2);
    --死神だけ動く
    unit:resumeUnit();
    unit.m_IgnoreHitStopTime = 10;
    return 1;
end

function class:targetPick(unit)
    if megast.Battle:getInstance():isHost() then
        self.deathTarget = self:findCursedAtRandom(unit);
        if self.deathTarget ~= nil then
            megast.Battle:getInstance():sendEventToLua(self.scriptID,10,self.deathTarget:getIndex());
        end
    end
    self:fadeOutAll();
    return 1;
end

function class:fadeOutAll()
    self.consts.fadeOutFrame = 0;
    self.consts.fadeOutFlag = true;
    return 1;
end

function class:fadeInAll()
    self.consts.fadeInFrame = 0;
    self.consts.fadeInFlag = true;
    return 1;
end

function class:fadeInTarget(unit)
    if self.deathTarget ~= nil then
        self.targetFadeInFrame = 0;
        self.targetFadeInFlag = true;
        self.glab(unit);
        local fire = unit:addOrbitSystem("skill3player",0);
        local targetx = self.deathTarget:getPositionX() + self.deathTarget:getSkeleton():getBoneWorldPositionX("MAIN");
        local targety = self.deathTarget:getPositionY() + self.deathTarget:getSkeleton():getPositionY() + self.deathTarget:getSkeleton():getBoneWorldPositionY("MAIN") + self.consts.unitHight;
        fire:setPosition(targetx,targety);
        fire:pauseUnit(0.01);
    end
    return 1;
end

function class:glab(unit)
    local targetUnit = self.deathTarget;
    if targetUnit ~= nil then
        local destinationX = unit:getPositionX() + 400;
        local destinationY = unit:getPositionY() + 250;
        local targetMainX = targetUnit:getSkeleton():getBoneWorldPositionX("MAIN");
        local targetMainY = targetUnit:getSkeleton():getBoneWorldPositionY("MAIN");
        targetUnit:setPosition(destinationX - targetMainX,targetUnit:getPositionY());
        targetUnit:getSkeleton():setPositionY(destinationY - (targetMainY + targetUnit:getPositionY()));
    end
end

function class:mistIn(unit)
    self.blackMist:takeAnimation(0,"blackmist",true);
    return 1;
end

function class:specialUpdate(unit)
    if self.deathExcuteFlg then
        --全員停止
        megast.Battle:getInstance():pauseUnit(0.5);
        --死神だけ動く
        unit:resumeUnit();
        unit:setInvincibleTime(1);
    end

    if self.fadeOutFlag then
        self:fadeOutUpdate(self.setDeltaTime);
    elseif self.targetFadeInFlag then
        self:fadeInTargetUpdate(self.setDeltaTime);
    elseif self.fadeInFlag then
        self:fadeInUpdate(self.setDeltaTime);
    end
    return 1;
end

function class:fadeOutUpdate(deltaTime)
    local frameRate = deltaTime/0.016666667;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            local opa = uni:getOpacity() - 10 * frameRate;
            if opa < 0 then--アンダーフローさせないため
                opa = 0;
            end
            uni:setOpacity(opa);
        end
    end
    self.fadeOutFrame = self.fadeOutFrame + 1 * frameRate;
    if self.fadeOutFrame > 255/10 then
        self.fadeOutFlag = false;
    end
    return 1;
end

function class:fadeInTargetUpdate(deltaTime)
    local frameRate = deltaTime/0.016666667;
    if self.deathTarget ~= nil then
        local opa = self.deathTarget:getOpacity() + 6;
        if opa > 255 then--オーバーフローさせないため
            opa = 255;
        end
        self.deathTarget:setOpacity(opa);
    end
    self.targetFadeInFrame = self.targetFadeInFrame + frameRate;
    if self.targetFadeInFrame > 255/6 then
        self.targetFadeInFlag = false;
    end
    return 1;
end

function class:fadeInUpdate(deltaTime)
    local frameRate = deltaTime/0.016666667;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            local opa = uni:getOpacity() + 6 * frameRate;
            if opa > 255 then--オーバーフローさせないため
                opa = 255;
            end
            uni:setOpacity(opa);
        end
    end
    self.fadeInFrame = self.fadeInFrame + 1 * frameRate;
    if self.fadeInFrame > 255/6 then
        self.fadeInFlag = false;
    end
    return 1;
end

function class:excuteAction(unit)
    self.deathExcuteFlg = false;
    local rand = LuaUtilities.rand(0,100);
    if rand <= 25 and self.gameUnit:getAnimationPositionX() > -100 then
        self.gameUnit:takeBack();
        return 0;
    end
    self.gameUnit.m_IgnoreHitStopTime = 0;
    return 1;
end

function class:findCurseForGuest(index)
    self.deathTarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
    return 1;
end

function class:receive10(args)
    self:findCurseForGuest(args.arg);
    return 1;
end
--====================================================================================



class:publish();

return class;