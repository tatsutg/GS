local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="36章_NORMAL_フォンギオン", version=2.5, id=3605013});
class:inheritFromEnemy("3605014");


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

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "時間経過でボスの被ダメージアップ：毒で加速", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "時間経過でボスのクリティカル率アップ：燃焼で遅延", COLOR = Color.white})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "クリティカル耐性アップ", COLOR = Color.yellow})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "ダークレイ：ダメージ無効化無効", COLOR = Color.yellow})
    }
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

        buffVal_17 = 25,
        hpBuffVal_23 = 50,

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
        tgPosX_B = 70,
        tgPosY_B = 0,
        tgScale_B = 1,
        tgDeBuffSpeed_B = 0.3
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
    --self.timeIndexC = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer_C, self.GD.tgLimit_C ,self.GD.tgIconNum1_C, self.GD.tgIconNum2_C, self.GD.tgPosX_C, self.GD.tgPosY_C, self.GD.tgScale_C);
    --self.timeSpeedC = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndexC);

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
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    ---奥義後の処理
    self:removeUnitStun(event.unit);
    ---extraTimerギミック
    if not self.hp0Flg and not self.lastSkillFLG then
        self:extraTimerOperation(event.unit);
    end
    ---死亡時処理
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.lastSkillFLG == nil then self.lastSkillFLG = false end
        if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
            event.unit:getTeam():deadUnit(event.unit:getIndex());
            megast.Battle:getInstance():waveEnd(true);
        end
        if self.TRIGGERS[2].used then
            if self.deadCount == nil then self.deadCount = 0 end
            self.deadCount = self.deadCount + event.deltaTime;
            if self.deadCount >= 40 then
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

function class:extraTimerOperation(unit)
    --奥義中か確認
    if self.timeStopFlg == 2 and unit:getUnitState() == kUnitState_skill then
        self.timeStopFlg = 1;
        self:extraTimer("stop" ,self.timeIndexB ,self.timeSpeedB);
        --self:extraTimer("stop" ,self.timeIndexC ,self.timeSpeedC);
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
            --self:extraTimer("reset" ,self.timeIndexC);
            --self:extraTimer("stop" ,self.timeIndexC ,self.timeSpeedC);
        elseif not unit:isBreak() and self.breakFlg then
            self.breakFlg = false;
            self:extraTimer("change" ,self.timeIndexB ,self.timeSpeedB ,1);
            --self:extraTimer("change" ,self.timeIndexC ,self.timeSpeedC ,1);
        end
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    if event.index == self.timeIndexA then
        self.timeACount = self.timeACount + 1;
        self:execAddBuff(event.unit,self.TIME_BUFF_LIST[2]);
    elseif event.index == self.timeIndexB then
        self:execAddBuff(event.unit,self.TIME_BUFF_LIST[1]);
    end
    return event.count
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
        --self:extraTimer("start" ,self.timeIndexC ,self.timeSpeedC);
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
        event.unit:setHP(self.tgHealRate);
    end
    return 1;
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