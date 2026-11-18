local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ダキュオンチャレンジ_超ダキュオン", version=2.7, id=502031511});
class:inheritFromUnit("unitBossBase");

local math = math

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 },
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL2 = 1,
    SKILL3 = 1,
}

class.cutInSkill = {
    --[5] = 1
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 208030001,
            BUFF_ID = 32,   -- 命中率
            VALUE = self.GD.hp50BuffValue_32 + self.fesLevel * (-1),
            DURATION = self.GD.hp50BuffTime_32,
            ICON = 15,
        },
        [2] = {
            ID = 208030002,
            BUFF_ID = 89,   -- 気絶
            VALUE = 100,
            DURATION = self.GD.hp50BuffTime_89,
            ICON = 79,
        },
        [3] = {
            ID = 208030003,
            BUFF_ID = 56,   -- 暗闇耐性
            VALUE = self.GD.BuffValue_56 * self.fesLevel,
            DURATION = 999999,
            ICON = 62,
        },
        [4] = {
            ID = 208030004,
            BUFF_ID = 105,   -- 暗闇回避率
            VALUE = self.GD.BuffValue_105 * self.fesLevel,
            DURATION = 999999,
            ICON = 0,
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
    return message
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下・暗闇・ブレイク耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "1HITあたりのダメージ上限 9999", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "お供撃破時、ボスへのダメージ上限アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ボス暗闇時、ボスへのダメージ上限2倍", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ダキュオンは奥義、真ダキュオンは真奥義、ボスは超奥義で倒せ！", COLOR = Color.yellow}),
    }
    self.TGSTART_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.TGSTART_MESSAGE1 or "一定時間でお供召喚", COLOR = Color.yellow}),
    }
    self.SUMMONDEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMONDEAD_MESSAGE1 or "ダキュオン%d体撃破！！ボスへのダメージ上限 %d", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.SUMMONDEAD_MESSAGE2 or "真ダキュオン%d体撃破！！ボスへのダメージ上限 %d", COLOR = Color.yellow}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "超威嚇：気絶状態・命中率ダウン", COLOR = Color.yellow}),
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
            isEnableSkip = false
        },
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

function class:hp50(status)
    if status == "use3" then
        self.hpSkill = 3
        self.hpTriggerState = 1
        --self.saveBP = self.gameUnit:getBurstPoint()
        --self.gameUnit:addSP(100)
        self:refresh(self.gameUnit)
        self:stun()
        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end

---ユニット気絶,初期位置移動
function class:stun()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local x = myTeamUnit:getPositionX();
            local y = myTeamUnit:getPositionY();
            self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[1])
            self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[2])
            myTeamUnit:setPosition((x + 480 + math.random(-50,50)),(y + math.random(-50,50)))
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 0,
        attackDelay = 10,
        hitStop = 100,
        startAddSP = 0,
        hp50BuffValue_32 = -10,
        hp50BuffTime_32 = 15,
        hp50BuffTime_89 = 2,
        BuffValue_56 = 0.7,
        BuffValue_105 = 0.7,
        normalDamageMaxValue = 9999,
        spCriDamageMaxValue = 30000,
        dakyuonDeadCountRate = 0.3,
        sindakyuonDeadCountRate = 0.5,
        burstBaseTakeDamageValue = 0.5,
        burstRateTakeDamageValue = 0.05,
        blindTakeDamageValue = 2.0,

        dakyuonBaseHP = 100000,
        dakyuonPlusHP = 10000,
        dakyuonPowerHP = 2000,
        sindakyuonBaseHP = 100000,
        sindakyuonPlusHP = 10000,
        sindakyuonPowerHP = 4000,

        tgTimer = 10,
        tgLimit = 999,
        tgIconNum1 = 0,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
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
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    -- クエストレベル退避（ユニットのレベルをみる）
    self.fesLevel = self.gameUnit:getLevel()

    self.hpMarkers = {}
    self.isRage = false
    self.isFury = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false
    self.hpSkill = 0
    self.saveBP = 0

    -- チャレンジ用
    -- 攻撃カウントダウン
    self.ATTACK_TIMER = 7
    -- 攻撃までの時間
    self.ATTACK_DELAY = 60
    -- 現在位置
    self.POS_X = nil
    -- スタート地点の位置
    self.START_X = nil
    -- 後退時の後退距離
    self.BACK_LIMIT = 0
    -- 最高到達地点
    self.LIMIT_X = 260
    -- 速度
    self.MAX_SPEED = 0
    -- 現在の状態（1:接近中 2:攻撃中 3:後退中）
    self.MOVE_STATE = 1
    -- ループカウント
    self.LOOP_COUNT = 0
    -- 最大ループ数
    self.LOOP_COUNT_MAX = 3
    -- ループ回数に応じた後退距離補正
    self.BACK_DISTANCE_RATE = {
        0.25,
        0.5,
        0.75,
        0.75
    }

    --event.unit:setUnitName(self.TEXT.UNIT_NAME)
    event.unit:getSkeleton():setScale(5)
    event.unit:setHPBarHeightOffset(10000)
    event.unit.m_IgnoreHitStopTime = 999999
    event.unit:setSkillInvocationWeight(0)
    event.unit:setNeedSP(100)
    event.unit:setAttackDelay(1)
    event.unit:setAutoZoder(false)
    event.unit:setLocalZOrder(9000 + event.unit:getIndex())

    -- お供撃破数
    self.dakyuonDeadCount = 0
    self.sindakyuonDeadCount = 0
    self.summonEnemyID1 = 2080301
    self.summonEnemyID2 = 2080302
    self.summonState = math.random(1,2);
    self.friendCount = 0;
    self.hpTriggerState = 0

    -- ダメージ上限初期値
    self.normalDamageMaxValue = self.GD.normalDamageMaxValue
    self.spCriDamageMaxValue = self.GD.spCriDamageMaxValue

    -- 経過時間ギミック
    self.timeIndex = nil;
    self.timeSpeeddefault = 1
    self.timeSpeed = self.timeSpeeddefault

    -- HP再定義（データでやるのでなし
    --local HP = self.fesLevel^2 * self.GD.choudakyuonPowerHP + self.GD.choudakyuonBaseHP
    --event.unit:setBaseHP(HP);
    --event.unit:setHP(HP);

    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
    -- お供のHP再定義
    self:findUnitBysetHP()
    -- 開始時の座標を退避
    self.POS_X = event.unit:getPositionX()
    self.START_X = event.unit:getPositionX()
    -- 到達時間と座標との距離で速度を決める
    local distance = math.abs(self.START_X - self.LIMIT_X)
    self.MAX_SPEED = math.floor(distance / self.ATTACK_DELAY)
    -- 後退時の距離を入れる（開始座標からゴールまでの距離の4分の1の位置）
    self.BACK_LIMIT = self.START_X + (distance * self.BACK_DISTANCE_RATE[self.LOOP_COUNT + 1])
    --summoner.Utility.messageByEnemy(self.POS_X .. " " ..self.BACK_LIMIT .. " " .. distance)
    return 1
end

function class:findUnitBysetHP()
    for i = 0,7 do
        local target = megast.Battle:getInstance():getTeam(false):getTeamUnit(i);
        -- 真ダキュオン
        if target ~= nil and target:getEnemyID() == self.summonEnemyID1 then
            local HP = self.fesLevel^2 * self.GD.sindakyuonPowerHP + self.GD.sindakyuonPlusHP * self.fesLevel + self.GD.sindakyuonBaseHP
            target:setBaseHP(HP);
            target:setHP(HP);
        end
        -- 通常ダキュオン
        if target ~= nil and target:getEnemyID() == self.summonEnemyID2 then
            local HP = self.fesLevel^2 * self.GD.dakyuonPowerHP + self.GD.dakyuonPlusHP * self.fesLevel + self.GD.dakyuonBaseHP
            target:setBaseHP(HP);
            target:setHP(HP);
        end
    end
end

---------------------------------------------------------------------------------
-- excuteAction
---------------------------------------------------------------------------------
function class:excuteAction(event)

    local stun = event.unit:getTeamUnitCondition():findConditionValue(89)
    local para = event.unit:getTeamUnitCondition():findConditionValue(91)
    local freeze = event.unit:getTeamUnitCondition():findConditionValue(96)

    if stun > 0 or para > 0 or freeze > 0 then
        return 0
    end

    event.unit.m_IgnoreHitStopTime = 999999
    event.unit:takeFront()
    event.unit:setUnitState(kUnitState_none)
    return 0
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    self:HPTriggersCheck(event.unit)

    -- 経過時間ギミック
    self:timeGimmick(event.unit)

    event.unit:setLocalZOrder(9000 + event.unit:getIndex())
    event.unit:getSkeleton():setScaleX(5);
    event.unit:getSkeleton():setScaleY(5);
    event.unit:setSize(3)
    if self.POS_X == nil then
        self.POS_X = event.unit:getPositionX()
    end

    -- HPトリガー
    if self.hpTriggerState == 1 and event.unit:getUnitState() == kUnitState_none then
        event.unit:takeAttack(2)
        event.unit:setActiveSkill(2)
        self.hpTriggerState = 2
    end

    -- 行動不能時はカウントを進めない
    local stun = event.unit:getTeamUnitCondition():findConditionValue(89)
    local para = event.unit:getTeamUnitCondition():findConditionValue(91)
    local freeze = event.unit:getTeamUnitCondition():findConditionValue(96)

    if event.unit:getUnitState() == kUnitState_damage or stun > 0 or para > 0 or freeze > 0 then
        --self:log(self.POS_X)
        event.unit:setPositionX(self.POS_X)
        return 1
    end

    -- 攻撃後、後退モード
    if event.unit:getUnitState() ~= kUnitState_attack and self.MOVE_STATE == 2 then
        self.MOVE_STATE = 3
        -- ここでユニットの死亡判定を入れる
        self:unitDeath()
    end

    -- 攻撃の処理
    -- 指定の距離にたどり着いたら噛み付く
    if event.unit:getUnitState() == kUnitState_none and self.POS_X >= self.LIMIT_X and self.MOVE_STATE == 1 then
        event.unit:takeAttack(1)
        event.unit:setActiveSkill(1)
        self.MOVE_STATE = 2
    end

    -- 後退完了時
    if event.unit:getUnitState() == kUnitState_none and self.POS_X <= self.BACK_LIMIT and self.MOVE_STATE == 3 then
        self.MOVE_STATE = 1
        -- 次の後退距離を決める
        local distance = math.abs(self.START_X - self.LIMIT_X)
        self.BACK_LIMIT = self.START_X + (distance * self.BACK_DISTANCE_RATE[self.LOOP_COUNT + 1])
        self.LOOP_COUNT = self.LOOP_COUNT + 1
        if self.LOOP_COUNT > self.LOOP_COUNT_MAX then
            self.LOOP_COUNT = self.LOOP_COUNT_MAX
        end
    end

    -- 後退の処理
    if event.unit:getUnitState() == kUnitState_none and self.POS_X > self.BACK_LIMIT and self.MOVE_STATE == 3 then
        self.POS_X = self.POS_X - 500 * event.deltaTime
        event.unit:getSkeleton():setScaleX(-5);
    end

    -- 移動の処理
    if event.unit:getUnitState() == kUnitState_none and self.POS_X < self.LIMIT_X and self.MOVE_STATE == 1 then
        self.POS_X = self.POS_X + self.MAX_SPEED * event.deltaTime
    end

    --self:log(self.POS_X)
    --summoner.Utility.messageByEnemy(self.POS_X)
    event.unit:setPositionX(self.POS_X)

    return 1
end

function class:timeGimmick(unit)
    if self.timeIndex ~= nil then

        local FLG = 0

        -- 燃焼、毒、病気、暗闇、麻痺の時、タイマーの速度を2.5倍
        --if dbuff > 0 then
        --    FLG = 1
        --end

        -- ブレイク中か無敵中は停止
        if unit:isBreak() or unit:getInvincibleTime() > 0 then
            FLG = 2
        end

        if FLG == 2 then
            self.timeSpeed = 0
        elseif FLG == 1 then
            --self.timeSpeed = self.timeSpeeddefault * self.GD.tgFastSpeed
        else
            self.timeSpeed = self.timeSpeeddefault
        end

        -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= self.timeSpeed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , self.timeSpeed)
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
        end

    end
end

function class:unitDeath()
    local deathcnt = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:setHP(0)
            deathcnt = deathcnt + 1
        end
        if deathcnt >= self.LOOP_COUNT + 1 then
            break;
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    self:findFriend()
    self:friendSummonCheck(self.friendCount)
    return event.count
end

function class:findFriend()   --雑魚の監視
    self.friendCount = 0;
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getEnemyID() == self.summonEnemyID1 then
                -- ダキュオンのID
                self.friendCount = self.friendCount + 1;
            end
            if myTeamUnit:getEnemyID() == self.summonEnemyID2 then
                -- 真ダキュオンのID
                self.friendCount = self.friendCount + 1;
            end
        end
    end
    if self.friendCount > 6 then
        self.friendCount = 6
    end
end

--雑魚の監視召喚_(既に場にいる敵の数)
function class:friendSummonCheck(eIDcount)
    local rtn = false
    if eIDcount == 6 then  --何もしない
    else
        if self.summonState == 1 then
            self:MultipleSummon(self.summonEnemyID1, 1);
        else
            self:MultipleSummon(self.summonEnemyID2, 1);
        end
    end
end

--召喚するエネミーID、召喚回数
function class:MultipleSummon(eID, Num)
    for i = 1,Num do
        local summonEnemyUnit = self:Summon(self.gameUnit,eID)
        if summonEnemyUnit ~= nil then
            -- 真ダキュオン
            if eID == self.summonEnemyID1 then
                local HP = self.fesLevel^2 * self.GD.sindakyuonPowerHP + self.GD.sindakyuonPlusHP * self.fesLevel + self.GD.sindakyuonBaseHP
                summonEnemyUnit:setBaseHP(HP);
                summonEnemyUnit:setHP(HP);
            end
            -- 通常ダキュオン
            if eID == self.summonEnemyID2 then
                local HP = self.fesLevel^2 * self.GD.dakyuonPowerHP + self.GD.dakyuonPlusHP * self.fesLevel + self.GD.dakyuonBaseHP
                summonEnemyUnit:setBaseHP(HP);
                summonEnemyUnit:setHP(HP);
            end
            --各々の倒した回数を渡したいのでそれ用の空バフを付与
            local buff = summonEnemyUnit:getTeamUnitCondition():addCondition(208030011,0,0,999999,0);
            buff:setValue1(tonumber(self.dakyuonDeadCount));
            buff:setValue2(tonumber(self.sindakyuonDeadCount));
            megast.Battle:getInstance():updateConditionView();
            -- 召喚はローテーション
            self.summonState = self.summonState == 1 and 2 or 1
        end
    end
end

---召喚系
---------------------------
function class:Summon(unit,unitID)
    if megast.Battle:getInstance():isHost() then
        for i = 0, 6 do
            if unit:getTeam():getTeamUnit(i) == nil then
                local addUnit = unit:getTeam():addUnit(i,unitID)
                return addUnit
            end
        end
    end
    return nil
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "summonDead" then return self:summonDead(event.unit, 1) end
    if event.spineEvent == "summonDead_sin" then return self:summonDead(event.unit, 2) end
    return 1;
end

function class:summonDead(unit, index)
    if index == 1 then
        -- ダキュオン倒した数
        self.dakyuonDeadCount = self.dakyuonDeadCount + 1
        -- ダメージ上限更新
        self.normalDamageMaxValue = self.GD.normalDamageMaxValue * (1 + self.dakyuonDeadCount * self.GD.dakyuonDeadCountRate + self.sindakyuonDeadCount * self.GD.sindakyuonDeadCountRate)
        self.spCriDamageMaxValue = self.GD.spCriDamageMaxValue * (1 + self.dakyuonDeadCount * self.GD.dakyuonDeadCountRate + self.sindakyuonDeadCount * self.GD.sindakyuonDeadCountRate)
        self:showFormatMessage(self.SUMMONDEAD_MESSAGE_LIST[1],self.dakyuonDeadCount, math.ceil(self.normalDamageMaxValue))
    elseif index == 2 then
        -- 真ダキュオン倒した数
        self.sindakyuonDeadCount = self.sindakyuonDeadCount + 1
        -- ダメージ上限更新
        --上限値はダキュオンを倒した数＝a　真ダキュオンを倒した数=b
        -- (1+a×0.2+b×0.3)*α
        self.normalDamageMaxValue = self.GD.normalDamageMaxValue * (1 + self.dakyuonDeadCount * self.GD.dakyuonDeadCountRate + self.sindakyuonDeadCount * self.GD.sindakyuonDeadCountRate)
        self.spCriDamageMaxValue = self.GD.spCriDamageMaxValue * (1 + self.dakyuonDeadCount * self.GD.dakyuonDeadCountRate + self.sindakyuonDeadCount * self.GD.sindakyuonDeadCountRate)
        self:showFormatMessage(self.SUMMONDEAD_MESSAGE_LIST[2],self.sindakyuonDeadCount, math.ceil(self.normalDamageMaxValue))
    end

    -- 撃破回数を他のキュオンにも伝える
    self:updateDeadCount()

    --初回撃破の場合は時計を出す
    if self.timeIndex == nil then
        self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit, self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
        self.timeSpeeddefault = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
        self.timeSpeed = self.timeSpeeddefault
        self:showMessage(self.TGSTART_MESSAGE_LIST)
    end

    return 1;
end

function class:updateDeadCount()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getEnemyID() == self.summonEnemyID1 or myTeamUnit:getEnemyID() == self.summonEnemyID2 then
                local buff = myTeamUnit:getTeamUnitCondition():addCondition(208030011,0,0,999999,0);
                buff:setValue1(tonumber(self.dakyuonDeadCount));
                buff:setValue2(tonumber(self.sindakyuonDeadCount));
                megast.Battle:getInstance():updateConditionView();
            end
        end
    end
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0)
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    --お供も一緒に倒す
    self:friendDead()
    return 1
end

function class:friendDead()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getEnemyID() == self.summonEnemyID1 or myTeamUnit:getEnemyID() == self.summonEnemyID2 then
                myTeamUnit:setHP(0)
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

    if self.hpTriggerState == 1 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("2-skill1") ---EFのアニメーション名に気をつける
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
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

    --if self.cutInFLG then
    --    self.cutInFLG = false
    --    event.unit:takeSkillWithCutin(event.index,1);
    --    return 0
    --end

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

function class:receive6(args)
    return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    return 0
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

    -- 上限補正 スパクリとで上限値を分ける
    local spCritical = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().superCritical;
    if not spCritical then
        event.value = event.value > self.normalDamageMaxValue and self.normalDamageMaxValue or event.value
    else
        event.value = event.value > self.spCriDamageMaxValue and self.spCriDamageMaxValue or event.value
    end

    -- 超奥義以外は補正をかける
    local skill = enemyUnit:getActiveBattleSkill();
    if skill == nil then
        local skill2 = event.enemy:getActiveBattleSkill();
        if skill2 == nil then
            -- 通常攻撃は取れないのでここ
            event.value = event.value * (self.GD.burstBaseTakeDamageValue - self.GD.burstRateTakeDamageValue * self.fesLevel)
            event.value = event.value < 1 and 1 or event.value
        else
            if not skill2:isBurst3() and not skill2:isSuperPhantomBullet() then
                event.value = event.value * (self.GD.burstBaseTakeDamageValue - self.GD.burstRateTakeDamageValue * self.fesLevel)
                event.value = event.value < 1 and 1 or event.value
            end
        end
    else
        if not skill:isBurst3() and not skill:isSuperPhantomBullet() then
            event.value = event.value * (self.GD.burstBaseTakeDamageValue - self.GD.burstRateTakeDamageValue * self.fesLevel)
            event.value = event.value < 1 and 1 or event.value
        end
    end

    -- 暗闇状態の場合２倍
    local cond1 = event.unit:getTeamUnitCondition():findConditionWithType(93);  --暗闇
    local cond2 = event.unit:getTeamUnitCondition():findConditionWithType(131);  --ナイトメア
    if cond1 ~= nil or cond2 ~= nil then
        event.value = event.value * self.GD.blindTakeDamageValue
    end

    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value

    --event.unit:setSize(1)
    --return event.value > 999 and 999 or event.value
end

function class:takeDamage(event)
    self.POS_X = self.POS_X - math.random(1, 3)
    return 1
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
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
    -- ブレイクしないようにする
    return 0
    --if self.breakSkip then
    --    self.breakSkip = false
    --    return 0
    --end
    -----オービット判定
    --local enemyUnit = self:getAncestorUnit(event.enemy)
    --return event.value
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

    -- ブレイクしないようにする
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

function class:showFormatMessage(messageBox,str1, str2)
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(string.format(messageBox.MESSAGE,str1, str2),messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(string.format(messageBox.MESSAGE,str1, str2),messageBox.DURATION,messageBox.COLOR);
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

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
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

function class:checkDbuff(unit)
    local badStatusIDs = {89,91,96};
    local rtn = false
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
        if cond ~= nil then
            rtn = true;
        end
    end
    return rtn
end

class:publish();

return class;