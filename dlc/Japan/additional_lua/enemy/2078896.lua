--@additionalEnemy,2078897
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="スラコラボ跳兎祭後半_猛餓獣樹ゴロンドーラ(チャレンジ)", version=2.7, id=2078896});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK3 = 50 },
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK4 = 50 },
        { ATTACK5 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
    },
    HP20 = {
        { ATTACK6 = 50 },
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 50 },
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL2 = 6,
    SKILL3 = 7,
    SKILL4 = 6,
    ATTACK6 = 8
}

class.cutInSkill = {
    [3] = 1,
    [4] = 0
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = -207889601,
            BUFF_ID = 90,  --毒(壊毒)
            VALUE = self.GD.deepPoisonBuffValue_90,
            DURATION = self.GD.deepPoisonBuffTime_90,
            ICON = 301,
        },
        [2] = {
            ID = 207889602,
            BUFF_ID = 2,  --最大HP
            VALUE = self.GD.deepPoisonBuffValue_2,
            DURATION = 999999,
            ICON = 2,
            MAX = 99
        },
        [3] = {
            ID = 207889603,
            BUFF_ID = 15,  --防御力
            VALUE = self.GD.deepPoisonBuffValue_15,
            DURATION = 60,
            ICON = 6,
            MAX = 99
        },
        [4] = {
            ID = 207889604,
            BUFF_ID = 0, --オーラ用
            VALUE = 0,
            DURATION = 999999,
            ICON = 0,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        },
    }
    self.HP_BUFF_BOX_LIST = {
        [1] = {
            ID = 207889611,
            BUFF_ID = 70,  --HP吸収
            VALUE = self.GD.hp60BuffValue_70,
            DURATION = 999999,
            ICON = 18,
        },
        [2] = {
            ID = 207889612,
            BUFF_ID = 7,  --HP自然回復
            VALUE = self.GD.hp20BuffValue_7,
            DURATION = 999999,
            ICON = 35,
            SCRIPT = {
                SCRIPT_ID = 238,
                VALUE1 = 0
            }
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "うぬらの力、見極めさせてもらうでぇ！", COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "壊毒：効果時間が長い程HP・防御力低下", COLOR = Color.magenta}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "毒の数が多いユニットからの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "魔族ユニットからの被ダメージアップ", COLOR = Color.yellow}),
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "ダメージ吸収", COLOR = Color.yellow}),
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "小休止や！　お前ら、相手してもうたれ！", COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE2 or "モルドーラを撃破するほどユニットの最大HPアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE3 or "一定時間経過か、一定数撃破で打ち止め", COLOR = Color.yellow,}),
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "庇い・ダメージ無効化無効", COLOR = Color.red})
    }
    self.SKILL_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "リーダーに強制で壊毒状態", COLOR = Color.red, isPlayer = true}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE2 or "リーダー以外に強制で壊毒状態", COLOR = Color.red, isPlayer = true}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE3 or "なかなかやるやんけ！　こっちも本気や！", COLOR = Color.green}),
    }
    self.FRIEND_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FRIEND_DEAD_MESSAGE1 or "モルドーラ%s体撃破！", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.FRIEND_DEAD_MESSAGE2 or "ユニットの最大HP%dアップ！", COLOR = Color.white})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "わ、わいの負けやぁーー", COLOR = Color.green}),
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
            action = function (status) self:hp20(status) end,
            HP = 20,
            used = false,
            isEnableSkip = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
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

function class:hp60(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 4
            self.saveBP = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
        end
        --self.cutInFLG = true
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(12)
        self:execAddBuff(self.gameUnit,self.HP_BUFF_BOX_LIST[1])
        self:showMessage(self.HP60_MESSAGE_LIST)
    end
end

function class:hp20(status)
    if status == "use3" then
        self.stateName = "FURY"
        --self.cutInFLG = true
        self:refreshAll(self.gameUnit)
        self.gameUnit:setInvincibleTime(999999)
        self:showMessage(self.HP20_MESSAGE_LIST)
        self:startHide(self.gameUnit)
    end
end

function class:hp0(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 3
            self.saveBP = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
        end
        --self.cutInFLG = true
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(12)
        self:showMessage(self.HP0_MESSAGE_LIST)
    end
end

--===================================================================================================================
--入退場
function class:startHide(unit)
    unit:takeAnimation(0,"back2",false);
    unit:setInvincibleTime(999999);
    unit._ignoreBorder = true;

    self.engage = false
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 25,
        attackDelay = 6,
        hitStop = 100,
        startAddSP = 0,
        hp60BuffValue_70 = 500,
        hp20BuffValue_7 = 5,
        deepPoisonBuffValue_90 = 100,
        deepPoisonBuffTime_90 = 300,
        deepPoisonBuffValue_2 = -0.75,
        deepPoisonBuffValue_15 = -1,
        deepPoisonBuffTime = 1,
        poisonTakeDamageValue = {
            0.05,
            0.1,
            0.3,
            0.5,
            0.7,
            0.9,
        },
        poisonAddTakeDamageValue = 0.1,
        tgTimer = 40,
        tgLimit = 1,
        tgIconNum1 = 0,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        friendDeadCountMax = 10,
        addHPBuffValue_1 = 500
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

    --HP0ギミック
    self.lastSkillFLG = false
    self.deadFlg = false

    --壊毒ギミック
    self.unitTimeBuffTbl = {}
    for i = 0,3 do
        self.unitTimeBuffTbl[i] = 0
    end

    -- 隠れるギミック
    self.isHide = false;
    self.engage = true; --交戦許可　隠れて戻ってくるまでの間は一切攻撃しないためのもの
    self.friendCount = 0
    self.friendDeadCount = 0
    self.summonEnemyID = 2078897

    --ロングジャンプギミック
    self.attack6State = 0
    self.attack6X = 0

    -- 経過時間ギミック
    self.timeIndex = nil;
    self.timeSpeeddefault = 1
    self.timeSpeed = self.timeSpeeddefault

    -- ゴロンドーラのattack3はaddSPしないのでその対策
    self.addSpFLG = false

    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効

    --経過時間ギミック
    self:timeGimmick(event.unit)

    --壊毒ギミック
    self:poisonBuffCheck(event.unit,event.deltaTime)

    --隠れるギミック
    if self.isHide then
        self:hideControll(event.unit,event.deltaTime);

        -- モルドーラの人数を常に監視
        self:findFriend()
        if self.friendCount < 6 and self.isHide then
            -- 満たない場合は召喚する
            self.friendDeadCount = self.friendDeadCount + 1
            if self.friendDeadCount < self.GD.friendDeadCountMax then
                self:MultipleSummon(self.summonEnemyID, 1);
                self:showFormatMessage(self.FRIEND_DEAD_MESSAGE_LIST[1],self.friendDeadCount)
            end
        end
    end

    --ロングジャンプギミック
    --if self.attack6State > 0 then
    --    event.unit:setPosition(-900 + self.attack6X,0);
    --    event.unit:getSkeleton():setPosition(-900 + self.attack6X,0);--見た目上のズレも無くす
    --    if self.attack6X < 800 then
    --        self.attack6X = self.attack6X + 10
    --        event.unit:setPosition(0,0);
    --        event.unit:getSkeleton():setPosition(0,0);--見た目上のズレも無くす
    --        self.attack6State = 2
    --    end
    --end

    ---死亡時処理
    if megast.Battle:getInstance():isHost() then
        if megast.Battle:getInstance():getBattleState() == kBattleState_active then
            if self.lastSkillFLG == nil then self.lastSkillFLG = false end
            if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
                self.deadFlg = true
                event.unit:setHP(0)
                --event.unit:getTeam():deadUnit(event.unit:getIndex());
                --megast.Battle:getInstance():waveEnd(true);
            end
            if self.TRIGGERS[3].used then
                if self.deadCount == nil then self.deadCount = 0 end
                self.deadCount = self.deadCount + event.deltaTime
                if self.deadCount >= 10 then
                    self.deadFlg = true
                    event.unit:setHP(0)
                    --event.unit:getTeam():deadUnit(event.unit:getIndex());
                    --megast.Battle:getInstance():waveEnd(true);
                end
            end
        end
    end

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
        --if unit:isBreak() or unit:getInvincibleTime() > 0 then
        --    FLG = 2
        --end

        --if FLG == 2 then
        --    self.timeSpeed = 0
        --elseif FLG == 1 then
        --    self.timeSpeed = self.timeSpeeddefault * self.GD.tgFastSpeed
        --else
        --    self.timeSpeed = self.timeSpeeddefault
        --end

        -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= self.timeSpeed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , self.timeSpeed)
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
        end

    end
end

function class:poisonBuffCheck(unit,time)
    local team = megast.Battle:getInstance():getTeam(true)
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            local poi = self:deepPoisoncheck(teamUnit)
            if poi > 0 then
                self.unitTimeBuffTbl[i] = self.unitTimeBuffTbl[i] + time
                if self.unitTimeBuffTbl[i] >= self.GD.deepPoisonBuffTime then
                    self.unitTimeBuffTbl[i] = 0
                    self:execAddTimeBuff2(teamUnit,self.BUFF_BOX_LIST[2])  --最大HPバフ
                    self:execAddTimeBuff2(teamUnit,self.BUFF_BOX_LIST[3])  --防御力
                end
            end
        end
    end
end

function class:deepPoisoncheck(unit)
    local count = 0
    local FLG = false
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end

    for i = 0,(conditionSize - 1) do
        FLG = false
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            -- 毒かつ壊毒アイコン
            if cond:getConditionTypeAsInt() == 90 and cond:getThumbnailID() == 301 then
                FLG = true
            end
            if FLG then
                count = count + 1
            end
        end
    end
    return count
end

function class:findFriend()   --雑魚の監視
    self.friendCount = 0
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getEnemyID() == self.summonEnemyID then
                self.friendCount = self.friendCount + 1;
            end
        end
    end
    if self.friendCount > 6 then
        self.friendCount = 6
    end
end

--召喚するエネミーID、召喚回数
function class:MultipleSummon(eID, Num)
    local rtn = false
    for i = 1,Num do
        local summonEnemyUnit = self:Summon(self.gameUnit,eID)
        if summonEnemyUnit ~= nil then
            --summonEnemyUnit:addSP(100)
        end
    end
    return rtn
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

function class:hideControll(unit,deltaTime)
    unit:setPosition(-2000,-1000);
    unit:getSkeleton():setPosition(-3000,0);--見た目上のズレも無くす
    unit._ignoreBorder = true;--アニメーションの更新があっても外に居られるようにする
    -- 規定数の雑魚敵を倒したら
    if self.friendDeadCount >= self.GD.friendDeadCountMax then
        if self.timeIndex ~= nil then
            megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
            self.timeIndex = nil
        end
        self:friendDead()
        self:showMove(unit);
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --雑魚敵全滅、ゴロンドーラ帰還
    self:friendDead()
    self:showMove(self.gameUnit);
    self.timeIndex = nil
    return event.count
end

function class:showMove(unit)
    self:finishHide(unit);
    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.HP_BUFF_BOX_LIST[2].ID);
    if cond ~= nil then
        unit:getTeamUnitCondition():removeCondition(cond);
    end
    self:addHPUpBuff();
    self:showMessage(self.SKILL_MESSAGE_LIST, 3)
    self.engage = true;
end

function class:finishHide(unit)
    unit:setInvincibleTime(5);
    self.isHide = false;
    unit:setPosition(-1000,-1000);
    unit._ignoreBorder = true;
    --unit:takeAnimation(0,"attack2",false);
    --self.gameUnit:takeAnimationEffect(0,"1-attack2",false)
    --self.gameUnit:setActiveSkill(self.ACTIVE_SKILLS.ATTACK6)
    --self.attack6State = 1;
    unit:takeAnimation(0,"in2",false);
    unit._ignoreBorder = true;
    self:initAttackWeight({HP20 = 100})
end

function class:addHPUpBuff()
    if self.friendDeadCount > 0 then
        local HP_UP_BUFF_LIST = {
            [1] = {
                ID = 207889631,
                BUFF_ID = 1,   --最大HP固定値
                VALUE = self.GD.addHPBuffValue_1 * self.friendDeadCount,
                DURATION = 999999,
                ICON = 1,
            },
        }
        local team = megast.Battle:getInstance():getTeam(true)
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,HP_UP_BUFF_LIST[1])
                local cond = teamUnit:getTeamUnitCondition():findConditionWithID(HP_UP_BUFF_LIST[1].ID)
                if cond ~= nil then
                    cond:setNumber(self.friendDeadCount)
                    cond:setMaxConditionIconNumber(10)
                end
            end
        end
        self:showFormatMessage(self.FRIEND_DEAD_MESSAGE_LIST[1],self.friendDeadCount)
        self:showFormatMessage(self.FRIEND_DEAD_MESSAGE_LIST[2],self.GD.addHPBuffValue_1 * self.friendDeadCount)
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "hide" then return self:hide(event.unit) end
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    return 1;
end

function class:hide(unit)
    -- 時計出す
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit, self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeeddefault = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
    self.timeSpeed = self.timeSpeeddefault
    self:execAddBuff(self.gameUnit,self.HP_BUFF_BOX_LIST[2])
    -- 可能な限りモルドーラを召喚する
    self:MultipleSummon(self.summonEnemyID, 6);
    self.isHide = true;
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

    if not self.engage then
        event.unit:takeAnimation(0,"idle",false);
        return 0;
    end

    if event.index == 3 then
        -- リーダーに壊毒をつける
        self:addDeepPoisonBuff(true)
        self:showMessage(self.SKILL_MESSAGE_LIST, 1)
    end

    if event.index == 4 then
        -- リーダー以外に壊毒をつける
        self:addDeepPoisonBuff(false)
        self:showMessage(self.SKILL_MESSAGE_LIST, 2)
        event.unit:setNextAnimationName("attack3")
        event.unit:setNextAnimationEffectName("1-attack3") ---EFのアニメーション名に気をつける
    end

    if event.index == 5 then
        event.unit:setNextAnimationName("attack4")
        event.unit:setNextAnimationEffectName("1-attack4") ---EFのアニメーション名に気をつける
    end

    if event.index == 6 then
        self.gameUnit:setInvincibleTime(5)
        self:initAttackWeight({DEFAULT = 100})
        event.unit:setNextAnimationName("attack2")
        event.unit:setNextAnimationEffectName("1-attack2") ---EFのアニメーション名に気をつける
    end

    self.attack6State = 0

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    end

    -- attack3はaddSPしないのでその対策
    if self.addSpFLG then
        self:addSP(event.unit);
        self.addSpFLG = false
    end
    if event.index == 3 or event.index == 4 then
        self.addSpFLG = true
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
    -- 隠れ中は増やさない
    if self.engage then
        unit:addSP(self.spValue);
    end
    return 1;
end

-- リーダーまたはリーダー以外に対して壊毒付与（引数で決める）
function class:addDeepPoisonBuff(isLeader)
    local team = megast.Battle:getInstance():getTeam(true)
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            if isLeader then
                if teamUnit:getIsLeader() then
                    self:execAddBuff(teamUnit,self.BUFF_BOX_LIST[1])
                    self:execAddBuff(teamUnit,self.BUFF_BOX_LIST[1])
                end
            else
                if not teamUnit:getIsLeader() then
                    self:execAddBuff(teamUnit,self.BUFF_BOX_LIST[1])
                end
            end
        end
    end
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

    if not self.engage then
        event.unit:takeAnimation(0,"idle",false);
        return 0;
    end

    if self.cutInFLG then
        self.cutInFLG = false;
        event.unit:takeSkillWithCutin(event.index,1);
        return 0
    end

    if event.index == 3 then
        self.lastSkillFLG = true
    end

    if event.index == 4 then
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("1-skill2") ---EFのアニメーション名に気をつける
    end

    self.skillCheckFlg = false;
    self.addSpFLG = false
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

    -- 該当の状態異常を受けている数分、受けるダメージを減らす
    local dbuffnum = self:checkCondition(enemyUnit)
    -- 配列参照のため１増やす
    dbuffnum = dbuffnum + 1
    if dbuffnum > #self.GD.poisonTakeDamageValue then
        local overnum = dbuffnum - #self.GD.poisonTakeDamageValue
        event.value = event.value * (self.GD.poisonTakeDamageValue[#self.GD.poisonTakeDamageValue] + overnum * self.GD.poisonAddTakeDamageValue)
        --summoner.Utility.messageByEnemy((self.GD.poisonTakeDamageValue[#self.GD.poisonTakeDamageValue] + overnum * self.GD.poisonAddTakeDamageValue))
    else
        event.value = event.value * self.GD.poisonTakeDamageValue[dbuffnum]
        --summoner.Utility.messageByEnemy(self.GD.poisonTakeDamageValue[dbuffnum])
    end

    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

function class:checkCondition(unit)
    local count = 0
    local FLG = false
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end

    for i = 0,(conditionSize - 1) do
        FLG = false
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            -- 毒
            if cond:getConditionTypeAsInt() == 90 then
                FLG = true
            end
            if FLG then
                count = count + 1
            end
        end
    end
    return count
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
    return 1
end

function class:takeDamage(event)
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
    if not self.deadFlg then
        return 0
    end
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
        self.timeIndex = nil
    end
    self:friendDead()
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    if self.timeIndex ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex,1,0,true);
        self.timeIndex = nil
    end
    self:friendDead()
    self:showMessage(self.DEAD_MESSAGE_LIST)
    return 1
end

function class:friendDead()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getEnemyID() == self.summonEnemyID then
                myTeamUnit:setHP(0)
            end
        end
    end
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

    local value = buffBox.VALUE * count

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,value,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,value,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,value,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,value,buffBox.DURATION,buffBox.ICON);
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

function class:execAddTimeBuff2(unit,buffBox)
    local flg  = true;
    local buff  = nil;
    local oldBuff = nil
    local buffValue = buffBox.VALUE
    local count = 0
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            buffValue = oldBuff:getValue() + buffBox.VALUE
            count = math.floor(oldBuff:getValue() / 10 * -1)
            if count > buffBox.MAX then
                count = buffBox.MAX
            end

            if count <= 0 then
                flg = false
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffValue,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffValue,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffValue,buffBox.DURATION,buffBox.ICON);
    end

    if count == 0 then flg = false end
    if flg then
        if buffBox.MAX ~= nil then
            buff:setMaxConditionIconNumber(buffBox.MAX);
            buff:setNumber(count)
            megast.Battle:getInstance():updateConditionView()
        end
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

function class:refreshAll(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97,131};
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