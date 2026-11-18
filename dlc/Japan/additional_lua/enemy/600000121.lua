--@additionalEnemy,600000128, 600000129, 600000130
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_VeryHard_大型シーリア", version=2.6, id=600000121});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK3 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 50 },
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
    SKILL3 = 7,
    SKILL4 = 4
}

class.cutInSkill = {
    --[3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = {
            ID = 0001,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 1,
            ICON = 0,
            --COUNT = 0,
            --MAX = 10
        }
    }
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 60012110,
            BUFF_ID = 17,  --与ダメ
            VALUE = self.GD.skillBuffVal_17_1,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 60012111,
            BUFF_ID = 17,  --クリティカルダメージ
            VALUE = self.GD.skillBuffVal_17_2,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99,
            SCRIPT = {
                SCRIPT_ID = 22,
                VALUE1 = 0,
                VALUE2 = 0
            }
        }
    }
    self.STUN_BUFF_LIST = {
        [1] = {
            ID = 60012120,
            BUFF_ID = 89,  --気絶効果
            VALUE = 100,
            DURATION = 14,
            ICON = 79
        },
        [2] = {
            ID = 60012121,
            BUFF_ID = 89,  --気絶効果
            VALUE = 100,
            DURATION = self.GD.buffTime_89,
            ICON = 79
        }
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 60012150,
        BUFF_ID = 21, -- 被ダメージ
        VALUE = self.GD.targetBuffVal_21,
        DURATION = 99999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 60012150,
        BUFF_ID = 0, -- 被ダメージ
        VALUE = 0,
        DURATION = 99999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST2 = {
        ID = 60012160,
        BUFF_ID = 13, -- 攻撃力
        VALUE = self.GD.targetBuffVal_13,
        DURATION = 999999,
        ICON = 4,
        COUNT = 0,
        MAX = 99
    }
end

function class:setSummonBuffBox()
    self.SUMMON_BUFF_LIST = {
        [1] = {
            ID = 600121100,   --竜牙兵召喚フラグ用バフ
            BUFF_ID = 0,
            VALUE = self.summonCountA,
            DURATION = 999999,
            ICON = 0
        },
        [2] = {
            ID = 600121200,   --翼仰騎士エルザ召喚フラグ用バフ
            BUFF_ID = 0,
            VALUE = self.summonCountB,
            DURATION = 999999,
            ICON = 0
        },
        [3] = {
            ID = 600121300,   --凶戦士ダラン召喚フラグ用バフ
            BUFF_ID = 0,
            VALUE = self.summonCountC,
            DURATION = 999999,
            ICON = 0
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性・男性ユニットからのダメージ軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "封印状態の相手に対してダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "一定ダメージでディシジョン発動", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "一定時間でエンドレス発動：暗闇状態で遅延", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ダメージの大きい者をターゲット：ターゲットへのダメージアップ", COLOR = Color.yellow})
    }
    self.ATTACK4_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.ATTACK4_MESSAGE1 or "状態異常回復", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.ATTACK4_MESSAGE2 or "を気絶・奥義ゲージ・攻撃力ダウン", COLOR = Color.red})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE2 or "エンドレス：庇い無効", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE3 or "クリティカルダメージアップ", COLOR = Color.yellow})
    }
    self.SUMMON_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "竜牙兵：魔族・竜族 以外からのダメージを軽減", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE2 or "エルザ：神族・精霊族 以外からのダメージを軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMON_MESSAGE3 or "ダラン：人族・巨人族 以外からのダメージを軽減", COLOR = Color.cyan})
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
        addSP = 25,
        startAddSP = 100,
        attackDelay = 8,
        hitStop = 100,

        tgTimer = 45,
        tgLimit = 99,
        tgIconNum1 = 0,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        tgDeBuffTimeSpeed = 0.4,

        atk4TDmgVal = 0.05,
        tDmgVal = 0.5,
        subBarHP = 1000000,

        buffTime_89 = 5,
        skillBuffVal_17_1 = 20,
        skillBuffVal_17_2 = 30,
        targetBuffVal_13 = -30,
        targetBuffVal_21 = 50,
        friendsDmgValTbl = {
            1,
            0.6,
            0.4,
            0.2,
            0.1,
            0.05,
            0.01
        }
    });
    self:dump(self.GD);

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

    ---経過時間ギミック
    self.breakFlg = false;
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);

    ---召喚ギミック
    self.friendCount = 0;
    self.summonCountA = 0;  --竜牙兵召喚カウント
    self.summonCountB = 0;  --翼仰騎士エルザ召喚カウント
    self.summonCountC = 0;  --凶戦士ダラン召喚カウント
    self.summonIDA = 600000130;  --竜牙兵のEnemyID
    self.summonIDB = 600000129;  --翼仰騎士エルザのEnemyID
    self.summonIDC = 600000128;  --凶戦士ダランのEnemyID
    self:setSummonBuffBox();

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0);
    event.unit:setHateRate_Damage(0);
    self.targetUnitList = {};
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    self.targetUnitIndex = nil;

    ---サブHPギミック
    self.subBarFlg = true;
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = self.GD.subBarHP;---サブバーのHP
    self.damage = 0;---サブバー表示時のダメージ
    self.attack4Flg = false;

    ---ボスギミック
    self.friendsDmgValTbl = {};
    for i = 0,6 do
        self.friendsDmgValTbl[i] = self.GD.friendsDmgValTbl[i + 1];
    end

    --巨大シーリア
    self.gridIndex = nil;
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end
    ---単体突き刺し時
    if megast.Battle:getInstance():isHost() then
        self:updateGlab(event.unit,event.deltaTime);
    end
    ---経過時間ギミック
    if not self.attack4Flg then
        self:extraTimerOperation(event.unit);
    end
    ---召喚ギミック
    self:findFriend();
    ---attack4発動中か確認
    if self.attack4Flg and not event.unit:isBreak() and event.unit:getUnitState() ~= kUnitState_skill then
        self.attack4Flg = false;
        self.subBarFlg = true;
        self.damage = 0;
        self:extraTimer("change" ,self.timeIndex ,self.timeSpeed ,1);
    end
    ---サブバーギミック
    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);
    end

    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    return 1
end

function class:extraTimerOperation(unit)
    -- 暗闇状態かどうか
    local flg = false;
    local cond1 = unit:getTeamUnitCondition():findConditionWithType(93);  --暗闇
    if cond1 ~= nil then
        flg = true;
    end

    -- タイマー速度変更
    local nowSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
    if flg and nowSpeed == 1 then
        self:extraTimer("change" ,self.timeIndex ,self.timeSpeed ,self.GD.tgDeBuffTimeSpeed);
    elseif not flg and nowSpeed ~= 1 then
        self:extraTimer("change" ,self.timeIndex ,self.timeSpeed ,1);
    end

    -- ブレイク中は止める
    if unit:isBreak() and self.breakFlg then
        self:extraTimer("stop" ,self.timeIndex);
    elseif not unit:isBreak() and self.breakFlg then
        self.breakFlg = false;
        self:extraTimer("change" ,self.timeIndex ,self.timeSpeed ,1);
    end
end

function class:updateGlab(unit,deltaTime)
    if self.gridIndex == nil then
        return;
    end

    local target = self:getPlayerUnit(self.gridIndex);
    if target == nil then
        return;
    end

    local x = unit:getSkeleton():getBoneWorldPositionX("DAMAGEAREA") + unit:getPositionX();
    local y = unit:getSkeleton():getBoneWorldPositionY("DAMAGEAREA") + unit:getPositionY();
    local targetWorldPositionX = target:getSkeleton():getBoneWorldPositionX("MAIN");
    local targetWorldPositionY = target:getSkeleton():getBoneWorldPositionY("MAIN");
    unit:setZOrder(10000);
    target:setZOrder(unit:getZOrder() + 1);
    target:setPosition(x - targetWorldPositionX,target:getPositionY());
    target:getSkeleton():setPosition(0,y - target:getPositionY() - targetWorldPositionY);
    --megast.Battle:getInstance():sendEventToLua(self.scriptID,7,self.gridIndex);
end

function class:receive7(args)
    local unit = self.gameUnit
    local target = self:getPlayerUnit(args.arg);
    local x = unit:getSkeleton():getBoneWorldPositionX("DAMAGEAREA") + unit:getPositionX();
    local y = unit:getSkeleton():getBoneWorldPositionY("DAMAGEAREA") + unit:getPositionY();
    local targetWorldPositionX = target:getSkeleton():getBoneWorldPositionX("MAIN");
    local targetWorldPositionY = target:getSkeleton():getBoneWorldPositionY("MAIN");
    unit:setZOrder(10000);
    target:setZOrder(unit:getZOrder() + 1);
    target:setPosition(x - targetWorldPositionX,target:getPositionY());
    target:getSkeleton():setPosition(0,y - target:getPositionY() - targetWorldPositionY);
    return 1;
end

function class:findFriend()   --雑魚の監視
    self.friendCount = 0;
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getEnemyID() == self.summonIDA then   --竜牙兵召の数
                self.friendCount = self.friendCount + 1;
            elseif myTeamUnit:getEnemyID() == self.summonIDB then   --翼仰騎士エルザの数
                self.friendCount = self.friendCount + 1;
            elseif myTeamUnit:getEnemyID() == self.summonIDC then   --凶戦士ダランの数
                self.friendCount = self.friendCount + 1;
            end
        end
    end
end

---サブHP表示
function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage) / self.SUB_HP);
    --summoner.Utility.messageByEnemy(self.SUB_HP - damage);
    ---ゲージ0%になった場合の処理
    if self.SUB_HP - damage <= 0 then
        if not unit:isBreak() and unit:getUnitState() ~= kUnitState_skill then
            self.subBarFlg = false;
            self.subBar:setVisible(false);
            self:extraTimer("stop" ,self.timeIndex);
            self.hpSkill = 4;
            unit:addSP(100);
        end
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    event.unit:addSP(100);
    self.hpSkill = 2;
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
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "glabStart" then return self:tryGlab(); end
    if event.spineEvent == "glabEnd" then return self:glabEnd(); end
    return 1;
end

function class:tryGlab()
    if not self:getIsHost() then
        return 1;
    end

    self.gridIndex = self:checkTarget();
    if self.gridIndex ~= nil then
        self:targetUnitStan(self.gridIndex);
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,8,self.gridIndex);
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,7,self.gridIndex);
    end
    return 1;
end

function class:glabEnd()
    if self.gridIndex == nil then
        return 1;
    end

    local target = self:getPlayerUnit(self.gridIndex);
    if target == nil then
        self.gridIndex = nil;
        return 1;
    end

    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.STUN_BUFF_LIST[1].ID);
            if cond ~= nil then
                myTeamUnit:getTeamUnitCondition():removeCondition(cond);
                --megast.Battle:getInstance():sendEventToLua(self.scriptID,9,i)
            end
        end
    end

    --ターゲットへの処理
    if self.gridIndex ~= nil then
        self:targetEndBuff(self.gridIndex);
    end

    self.gridIndex = nil;
    return 1;
end

function class:checkTarget()
    local index = nil;
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == self.targetUnitIndex then
                index = self.targetUnitIndex;
            end
        end
    end
    return index;
end

function class:targetUnitStan(targetIndex)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == targetIndex then
                self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[1]);
            end
        end
    end
end

function class:targetEndBuff(targetIndex)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == targetIndex then
                myTeamUnit:setBurstPoint(0);
                myTeamUnit:setPositionX(myTeamUnit:getPositionX() + 200);
                self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[2]);
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST2);
            end
        end
    end
end

function class:getPlayerUnit(index)
    self.targetUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

function class:receive8(args)
    self:targetUnitStan(args.arg);
    self.gridIndex = args.arg;
    return 1;
end

function class:receive9(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.STUN_BUFF_LIST[1].ID);
            if cond ~= nil then
                myTeamUnit:getTeamUnitCondition():removeCondition(cond);
            end
        end
    end
    self.gridIndex = nil;
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

    --召喚ギミック
    self:findFriend();
    self:friendSummon(self.friendCount);

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

---召喚系
function class:friendSummon(friendCount)  --雑魚の監視召喚
    local rand = math.random(0,9)
    if friendCount == 6 then  --召喚上限
        --何もしない
    elseif friendCount == 0 then  --0体の場合は70%の確率で召喚。
        if rand >= 3 then
            self:enemySummon(1);
        end
    elseif friendCount == 1 then  --1体の場合は40%の確率で召喚。
        if rand >= 6 then
            self:enemySummon(1);
        end
    elseif friendCount >= 2 then  --2体の場合は20%の確率で召喚。
        if rand >= 8 then
            self:enemySummon(1);
        end
    end
end
---召喚系
function class:enemySummon(Num)   --召喚回数
    local infoFlg1 = false;
    local infoFlg2 = false;
    local infoFlg3 = false;
    for i = 1,Num do
        local rand = math.random(1,3);
        if rand == 1 then
            infoFlg1 = true;
            self.summonCountA = self.summonCountA + 1;
            self:MultipleSummon(self.gameUnit,self.summonIDA,1);   --竜牙兵召喚
        elseif rand == 2 then
            infoFlg2 = true;
            self.summonCountB = self.summonCountB + 1;
            self:MultipleSummon(self.gameUnit,self.summonIDB,1);   --翼仰騎士エルザ召喚
        elseif rand == 3 then
            infoFlg3 = true;
            self.summonCountC = self.summonCountC + 1;
            self:MultipleSummon(self.gameUnit,self.summonIDC,1);   --凶戦士ダラン召喚
        end
    end

    if infoFlg1 then
        self:showMessage(self.SUMMON_MESSAGE_LIST,1);
    end
    if infoFlg2 then
        self:showMessage(self.SUMMON_MESSAGE_LIST,2);
    end
    if infoFlg3 then
        self:showMessage(self.SUMMON_MESSAGE_LIST,3);
    end
    self:friendAddBuff();
end

function class:friendAddBuff()   --召喚されたやつにバフをかける
    self:setSummonBuffBox();  --召喚用バフの更新
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getEnemyID() == self.summonIDA then   --竜牙兵
                local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.SUMMON_BUFF_LIST[1].ID);
                if cond == nil then
                    self:execAddBuff(myTeamUnit,self.SUMMON_BUFF_LIST[1]);
                end
            elseif myTeamUnit:getEnemyID() == self.summonIDB then   --翼仰騎士エルザ
                local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.SUMMON_BUFF_LIST[2].ID);
                if cond == nil then
                    self:execAddBuff(myTeamUnit,self.SUMMON_BUFF_LIST[2]);
                end
            elseif myTeamUnit:getEnemyID() == self.summonIDC then   --凶戦士ダラン
                local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.SUMMON_BUFF_LIST[3].ID);
                if cond == nil then
                    self:execAddBuff(myTeamUnit,self.SUMMON_BUFF_LIST[3]);
                end
            end
        end
    end
end

function class:deBuffRefresh(unit)
    self.badStatusList = { 89,90,91,92,93,94,95,96,97 };
    for k,v in pairs(self.badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            local cond = unit:getTeamUnitCondition():findConditionWithType(v);
            cond:setValue(0);
            cond:setTime(0);
            cond:setThumbnailID(0);
        end
    end
    megast.Battle:getInstance():updateConditionView();
end

function class:setAttackInfo()
    local unitName = nil;
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getIndex() == self.targetUnitIndex then
                unitName = myTeamUnit:getUnitName();
            end
        end
    end

    if unitName == nil then return; end
    self:showMessage(self.ATTACK4_MESSAGE_LIST,1);
    self:execShowFixedMessage(self.ATTACK4_MESSAGE_LIST[2],unitName);
end

function class:execShowFixedMessage(messageBox,str)
    local fixedMessage = str..messageBox.MESSAGE
    summoner.Utility.messageByEnemy(fixedMessage,messageBox.DURATION,messageBox.COLOR);
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

    if event.index == 1 then
        self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[1]);
        self:showMessage(self.SKILL_MESSAGE_LIST,1);
    elseif event.index == 2 then
        self:execAddBuff(event.unit,self.SKILL_BUFF_LIST[2]);
        self:showMessage(self.SKILL_MESSAGE_LIST,2);
        self:showMessage(self.SKILL_MESSAGE_LIST,3);
    elseif event.index == 4 then
        event.unit:setNextAnimationName("attack4");
        event.unit:setNextAnimationEffectName("1-attack4");
        self.attack4Flg = true;
        self:deBuffRefresh(event.unit);
        self:setAttackInfo();
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
    local enemyUnit = self:getAncestorUnit(event.enemy)
    ---エクストラゲージへのダメージ
    if self.subBarFlg then
        self.damage = self.damage + event.value;
    end
    ---attack4行動中はダメージ軽減
    if self.attack4Flg then
        event.value = event.value * self.GD.atk4TDmgVal;
    end
    ---男性ユニットからのダメージ軽減
    if enemyUnit:getSexuality() == 1 then
        event.value = event.value * self.GD.tDmgVal;
    end
    ---召喚ギミックダメージ補正
    self:findFriend();
    event.value = event.value * self.friendsDmgValTbl[self.friendCount];

    ---ターゲット処理
    if event.enemy:getIndex() == 4 then return event.value end
    ---ユニットのダメージをテーブルに格納
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
    if self.targetUnitList[index] == nil then
        table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value})
    else
        self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value
    end
    ---ホストのみ---
    if megast.Battle:getInstance():isHost() then
        ---ヘイトは全部手動で設定する
        local target = self:checkTargetUnit()
        --megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex())---ゲストにターゲットを送る
        event.unit:setHateTarget(target)
        event.unit:updateHateTarget();
        ---ターゲットにバフ
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if i == target:getIndex() then
                    self.targetUnitIndex = target:getIndex();
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
                else
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
                end
            end
        end
    end
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
        return unit;
    else
        return self:getAncestorUnit(unit:getParentTeamUnit());
    end
end

---与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil;
    local targetTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            target = myTeamUnit;
            break;
        end
    end
    local val = 0
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

function class:checkDamage(target)
    for i,v in pairs(self.targetUnitList) do
        if v.unit == target then
            return v.dps;
        end
    end
    return 0;
end

function class:receive6(args)
    ---ヘイトは全部手動で設定する
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local target = myTeam:getTeamUnit(args.arg);
    self.gameUnit:setHateTarget(target);
    self.gameUnit:updateHateTarget();
    return 1;
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
    megast.Battle:getInstance():waveEnd(true);
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

---召喚系
---------------------------
function class:summon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                unit:getTeam():addUnit(i,unitID)--指定したインデックスの位置に指定したエネミーIDのユニットを出す
                break
            end
        end
    end
end

function class:MultipleSummon(unit,unitID,Num)
    for i = 1,Num do
        self:summon(unit,unitID)
    end
end


class:publish();

return class;