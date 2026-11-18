local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="魔族の遺跡11F 葬魂神オルデウス HARD", version=2.5, id=2064605});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK3 = 100 },
        { ATTACK2 = 50, ATTACK4 = 50 },
        { ATTACK3 = 50, ATTACK1 = 50 },
    },
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL1 = 100 },
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
    SKILL3 = 7,
    SKILL4 = 8,
}

class.cutInSkill = {
    --[3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.BUFF_LIST = {
        [1] = { ID = 20646052, BUFF_ID = 23, VALUE = self.GD.critResistValue, DURATION = 999999, ICON = 188 },
    }
    self.DEAD_BUFF_LIST = {
        [1] = {
            ID = 20646051,
            BUFF_ID = 89,  -- 気絶効果
            VALUE = 100,
            DURATION = self.GD.stunDuration,
            ICON = 79,
        },
    }
    self.RESIST_BUFF_LIST = {
        [1] = { ID = 20646060, BUFF_ID = 0, VALUE = 0, DURATION = 999999, ICON = 38 }, -- 炎耐性
        [2] = { ID = 20646060, BUFF_ID = 0, VALUE = 0, DURATION = 999999, ICON = 39 }, -- 水耐性
        [3] = { ID = 20646060, BUFF_ID = 0, VALUE = 0, DURATION = 999999, ICON = 40 }, -- 樹耐性
        [4] = { ID = 20646060, BUFF_ID = 0, VALUE = 0, DURATION = 999999, ICON = 41 }, -- 光耐性
        [5] = { ID = 20646060, BUFF_ID = 0, VALUE = 0, DURATION = 999999, ICON = 42 }, -- 闇耐性
    }
    self.TG_BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 13,
            VALUE = self.GD.tg1Value,
            DURATION = self.GD.tg1Duration,
            ICON = 4,
        },
        [2] = {
            ID = 0,
            BUFF_ID = 21,
            VALUE = self.GD.tg2Value,
            DURATION = 999999,
            ICON = 139,
        },
        [3] = {
            ID = 0,
            BUFF_ID = 10,  -- 奥義ゲージ自然減少
            VALUE = self.GD.tg3Value,
            DURATION = 999999,
            ICON = 150,
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
    return message;
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "一定時間経過で30秒間、パーティの攻撃力ダウン：暗闇で遅延", COLOR = Color.yellow}),
    }
    self.EXTRA_GAUGE_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EXTRA_GAUGE_DEAD_MESSAGE1 or "破壊成功！：気絶状態", COLOR = Color.red}),
    }
    self.SKILL4_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL4_MESSAGE1 or "滅魂宿世：12000の固定ダメージ", COLOR = Color.magenta}),
    }
    self.HP70_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE1 or "行動速度アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE2 or "累計ダメージが多いユニットの属性耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE3 or "闇の衣：ダメージ耐性：毒・燃焼ダメージで解除", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE4 or "一定時間経過で滅魂宿世発動", COLOR = Color.yellow}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "奥義ゲージ上昇量アップ", COLOR = Color.yellow}),
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "奥義ゲージ上昇量アップ・クリティカル耐性アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE3 or "闇の衣：ダメージ耐性：毒・燃焼ダメージで解除", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE4 or "一定時間経過で滅魂宿世発動", COLOR = Color.yellow}),
    }
    self.RESIST_MESSAGE = self:setMessageInfo({MESSAGE = self.TEXT.RESIST_MESSAGE1 or "%s属性耐性アップ", COLOR = Color.yellow})
end


--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp70(status) end,
            HP = 70,
            used = false,
            isEnableSkip = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp30(status) end,
            HP = 30,
            used = false,
            isEnableSkip = false
        },
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





function class:hp70(status)
    if status == "use3" then
        self:refreshAll(self.gameUnit);
        self.stateName = "FURY";
        if megast.Battle:getInstance():isHost() then
            ---累計ダメージ最多属性を耐性に設定
            local _mId1, _mDmg1 = nil, 0
            for _id, _dmg in pairs(self.dmgAccum1) do
                if _dmg > _mDmg1 then _mDmg1 = _dmg; _mId1 = _id end
            end
            self.resistTarget1 = _mId1
            self.dmgAccum1 = {}
            megast.Battle:getInstance():sendEventToLua(self.scriptID, 9, self.resistTarget1 or 0)
        end
        --self.gameUnit:setInvincibleTime(10);
        if self.resistTarget1 ~= nil then
            self:showMessageWithInsert(self.HP70_MESSAGE_LIST, 3, self.RESIST_MESSAGE, self.ELEMENT_NAMES[self.resistTarget1])
            self:execAddBuff(self.gameUnit, self.RESIST_BUFF_LIST[self.resistTarget1])
        else
            self:showMessage(self.HP70_MESSAGE_LIST)
        end
        self.gameUnit:setAttackDelay(self.GD.hp70AttackDelay);
        ---TODO: 行動速度アップ / 累計ダメージが多いユニットの属性耐性アップ / 闇の衣：ダメージ耐性：毒・燃焼ダメージで解除 / 一定時間経過で滅魂宿世発動
        if megast.Battle:getInstance():isHost() then
            self.waitingStateFlg = true
            self.subBarHP = self.GD.hp70SubBarHP
            self.chargeTimer = 0
            self.chargeBallCount = 0
            self.subBarDamage = 0
            --self.gameUnit:setBurstPoint(0)
        end
        self.timeIndex2 = megast.Battle:getInstance():createExtraTimer(self.GD.etTimer, 1, self.GD.etIconNum1, self.GD.etIconNum2, self.GD.etPosX, self.GD.etPosY, self.GD.etScale)
        self.timeSpeed2 = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex2)
    end
end

function class:hp50(status)
    if status == "use3" then
        self:refreshAll(self.gameUnit);
        self.stateName = "FURY";
        self.hpSkill = 3;
        self.saveBP = self.gameUnit:getBurstPoint();
        self.spValue = self.GD.hp50SpValue;
        self.gameUnit:addSP(100);
        self.gameUnit:setInvincibleTime(10);
        self.hpSkillFLG = true;
        self:showMessage(self.HP50_MESSAGE_LIST);
    end
end

function class:hp30(status)
    if status == "use3" then
        self:refreshAll(self.gameUnit);
        self.stateName = "FURY";
        if megast.Battle:getInstance():isHost() then
            ---累計ダメージ最多属性を耐性に設定
            local _mId1, _mDmg1 = nil, 0
            for _id, _dmg in pairs(self.dmgAccum1) do
                if _dmg > _mDmg1 then _mDmg1 = _dmg; _mId1 = _id end
            end
            self.resistTarget1 = _mId1
            self.dmgAccum1 = {}
            megast.Battle:getInstance():sendEventToLua(self.scriptID, 9, self.resistTarget1 or 0)
        end
        --self.gameUnit:setInvincibleTime(10);
        if self.resistTarget1 ~= nil then
            self:showMessageWithInsert(self.HP30_MESSAGE_LIST, 3, self.RESIST_MESSAGE, self.ELEMENT_NAMES[self.resistTarget1])
            self:execAddBuff(self.gameUnit, self.RESIST_BUFF_LIST[self.resistTarget1])
        else
            self:showMessage(self.HP30_MESSAGE_LIST)
        end
        self:execAddBuff(self.gameUnit, self.BUFF_LIST[1]);
        self.spValue = self.GD.hp30SpValue;
        if megast.Battle:getInstance():isHost() then
            self.waitingStateFlg = true
            self.subBarHP = self.GD.hp30SubBarHP
            self.chargeTimer = 0
            self.chargeBallCount = 0
            self.subBarDamage = 0
            --self.gameUnit:setBurstPoint(0)
        end
        self.timeIndex2 = megast.Battle:getInstance():createExtraTimer(self.GD.etTimer, 1, self.GD.etIconNum1, self.GD.etIconNum2, self.GD.etPosX, self.GD.etPosY, self.GD.etScale)
        self.timeSpeed2 = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex2)
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 25,
        startAddSP = 0,
        attackDelay = 8,
        hp70AttackDelay = 5,
        hitStop = 100,

        -- タイマー1（攻撃力ダウンゲージ）
        tgTimer = 15,
        tgIconNum1 = 4,
        tgIconNum2 = 0,
        tgPosX = -30,
        tgPosY = 0,
        tgScale = 1,
        deBuffTimeSpeed = 0.25,

        -- タイマー2（エクストラゲージタイマー）
        etTimer = 60.0,
        etIconNum1 = 0,
        etIconNum2 = 0,
        etPosX = 30,
        etPosY = 0,
        etScale = 1,

        -- エクストラゲージHP
        hp70SubBarHP = 100000,
        hp30SubBarHP = 300000,

        -- HPトリガー後のSP獲得量変更
        hp50SpValue = 35,
        hp30SpValue = 50,

        -- バフ効果量・効果時間
        tg1Value = -150,
        tg1Duration = 30,
        tg2Value = 100,
        tg3Value = -10,
        critResistValue = -200,
        furyDamage = 12000,
        skullHP = 10000000,

        stunDuration = 10,

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

    self.stateName = "NORMAL";
    self.breakSkip = true;
    self.hpSkill = 0;
    self.saveBP = 0;

    ---経過時間ギミック
    self.breakFlg = false;
    self.hpSkillFLG = false;
    self.timeIndex1 = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, 99999, self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeed1 = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex1);

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

    ---エクストラゲージ（サブバー）
    self.subBar = BattleControl:get():createSubBar()
    self.subBar:setWidth(200)
    self.subBar:setHeight(13)
    self.subBar:setPercent(0)
    self.subBar:setVisible(false)
    self.subBarHP = event.unit:getCalcHPMAX()
    self.subBarDamage = 0
    self.waitingStateFlg = false
    self.chargeTimer = 0
    self.chargeBallCount = 0
    self.dotCheckTimer = 0
    self.timeIndex2 = nil
    self.timeSpeed2 = 1
    self.dmgAccum1 = {}
    self.resistTarget1 = nil
    self.ELEMENT_NAMES = { [1]="炎", [2]="水", [3]="樹", [4]="光", [5]="闇" }
    self.skill4FLG = false
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
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    ---待機状態の管理（DOTサブバー）
    if self.waitingStateFlg then
        self:dotCheck(event.deltaTime)
    end
    --葬魂神オルデウスの共有ギミック
    if table.maxn(self.bullets) > 0 then
        for i = 1,table.maxn(self.bullets) do
            self:bulletControll(self.bullets[i],event.deltaTime)
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    if event.index == self.timeIndex1 then
        if megast.Battle:getInstance():isHost() then
            self:unitAddBuff(self.TG_BUFF_LIST[1])
        end
    elseif event.index == self.timeIndex2 then
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 4
            self.gameUnit:addSP(100)
        end
        self.waitingStateFlg = false
        self.chargeTimer = 0
        self.chargeBallCount = 0
    end
    return event.count
end


function class:extraTimerOperation(unit)
    if self.timeIndex1 ~= nil then
        local _flg1 = 0
        if unit:getTeamUnitCondition():findConditionWithType(93) ~= nil then _flg1 = 1 end
        if unit:isBreak() or unit:getInvincibleTime() > 0 or self.hpSkillFLG == true then _flg1 = 2 end
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
    if self.timeIndex2 ~= nil then
        local _flg2 = 0
        if unit:isBreak() or unit:getInvincibleTime() > 0 then _flg2 = 2 end
        if _flg2 == 2 then
            self.timeSpeed2 = 0
        else
            self.timeSpeed2 = 1
        end
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex2) ~= self.timeSpeed2 then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex2, self.timeSpeed2)
            self.timeSpeed2 = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex2)
        end
    end
end


function class:dotCheck(deltaTime)
    self.dotCheckTimer = self.dotCheckTimer + deltaTime;
    if self.dotCheckTimer < 1 then return; end
    self.dotCheckTimer = self.dotCheckTimer - 1;
    local dotDmg = self.gameUnit:getTeamUnitCondition():findConditionValue(90) + self.gameUnit:getTeamUnitCondition():findConditionValue(92);
    self.subBarDamage = self.subBarDamage + dotDmg;
    self.subBar:setPositionY(self.gameUnit:getPositionY());
    self.subBar:setVisible(true);
    self.subBar:setPercent(100 * (self.subBarHP - self.subBarDamage) / self.subBarHP);
    if self.subBarHP - self.subBarDamage <= 0 then
        if megast.Battle:getInstance():isHost() then
            self.subBarDamage = 0;
            megast.Battle:getInstance():sendEventToLua(self.scriptID, 6, 1);
        end
        self:onSubBarDead()
    end
end

function class:onSubBarDead()
    self.waitingStateFlg = false;
    self.subBar:setVisible(false);
    if self.timeIndex2 ~= nil then
        megast.Battle:getInstance():removeExtraTimer(self.timeIndex2, 1, 0, true)
        self.timeIndex2 = nil
    end
    self:execAddBuff(self.gameUnit, self.DEAD_BUFF_LIST[1])
    self:showMessage(self.EXTRA_GAUGE_DEAD_MESSAGE_LIST)
end

function class:receive6(args)
    self:onSubBarDead()
    return 1;
end

function class:receive9(args)
    if args.arg > 0 then
        self.resistTarget1 = args.arg
    end
    return 1
end

function class:addBuffWithProtector(buffBox)
    local team = megast.Battle:getInstance():getTeam(true)
    local FLG = false
    local count = 1
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                FLG = true
                count = count + 1
            end
        end
    end
    if FLG then
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
                if cond == nil then
                    for j = 1,count do
                        self:execAddBuff(teamUnit,buffBox)
                    end
                end
            end
        end
    else
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,buffBox)
            end
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end
    if event.spineEvent == "skull" then return self:skull(event) end
    if event.spineEvent == "onDestroy" then return self:onDestroy(event.unit) end
    if event.spineEvent == "death" then return self:furyAttack() end
    return 1;
end

function class:furyAttack()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:setHP(myTeamUnit:getHP() - self.GD.furyDamage)
        end
    end
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

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit); ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0);
        self.afterSkillFLG = false;
        event.unit:addSP(self.saveBP);
        self.saveBP = 0;
    end
    self.hpSkillFLG = false;

    if not self.waitingStateFlg and not event.index == 3 then
        event.unit:setNextAnimationName("zcloneNattack" .. event.index)
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

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    self.skill4FLG = false
    if event.index == 1 then
        if not self.waitingStateFlg then
            event.unit:setNextAnimationName("zcloneNskill1")
        end
    elseif event.index == 2 or event.index == 3 then
        if not self.waitingStateFlg then
            event.unit:setNextAnimationName("zcloneNskill2")
            event.unit:setNextAnimationEffectName("1-skill2");
        else
            event.unit:setNextAnimationName("skill2");
            event.unit:setNextAnimationEffectName("1-skill2");
        end
    elseif event.index == 4 then
        event.unit:setNextAnimationName("skill3");
        event.unit:setNextAnimationEffectName("1-skill3");
        self.waitingStateFlg = false
        self.subBar:setVisible(false)
        self.chargeTimer = 0
        self.chargeBallCount = 0
        self.subBarDamage = 0
        self.timeIndex2 = nil
        self:execSkill4(event);
        self:showMessage(self.SKILL4_MESSAGE_LIST);
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

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.waitingStateFlg then
        event.value = 1;
    end
    ---累計ダメージ追跡（属性）
    do
        local _eu = self:getAncestorUnit(event.enemy)
        if _eu then
            local _tid = _eu:getElementType()
            if _tid and _tid > 0 then
                self.dmgAccum1[_tid] = (self.dmgAccum1[_tid] or 0) + event.value
            end
            if self.resistTarget1 ~= nil and _eu:getElementType() == self.resistTarget1 then
                return 1
            end
        end
    end
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    ---TODO: ここにギミックロジックを実装してください
    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

function class:takeDamage(event)
    if not self.waitingStateFlg then
        event.unit:setNextAnimationName("zcloneNdamage")
    end
    return 1;
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
        end
    end
    self.hpSkillFLG = false;
    if not self.waitingStateFlg then
        event.unit:setNextAnimationName("zcloneNidle")
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1;
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

-- insertIndex の位置に動的フォーマットメッセージを挟んで表示する
function class:showMessageWithInsert(messageList, insertIndex, formatMsg, str)
    for i, msg in ipairs(messageList) do
        if i == insertIndex then
            self:showFormatMessage(formatMsg, str)
        end
        self:execShowMessage(msg)
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


function class:execSkill4(event)
    self.skill4FLG = true
    if megast.Battle:getInstance():isHost() then
        self:addBuffWithProtector(self.TG_BUFF_LIST[2])
        self:unitAddBuff(self.TG_BUFF_LIST[3])
    end
    ---TODO: ここにギミックロジックを実装してください
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

--葬魂神オルデウスの共有ギミック
-- == 壊魂振動 ==
--==========================================
function class:skull(event)
    --local hpRatio = event.unit:getHP()/event.unit:getCalcHPMAX();
    --local bulletCount = 4 - hpRatio * 2;
    local bulletCount = 1
    for i = 0,bulletCount do
        local s = event.unit:addOrbitSystem("skullBase",2)
        s:setBaseHP(self.GD.skullHP);
        s:setHP(self.GD.skullHP);
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