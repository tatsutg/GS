local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="38章_HARD_幻聖プラチナ", version=2.8, id=3805034});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 50 },
        { ATTACK3 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL3 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL3 = 4,
    SKILL5 = 5
}

class.cutInSkill = {
    [3] = 0,
    [5] = 1
}

function class:setBuffBoxList()
    self.ATTCK_BUFF_LIST = {
        [1] = {
            ID = 38050341,
            BUFF_ID = 89,  --気絶効果
            VALUE = 100,
            DURATION = self.GD.attackBuffTime_89,
            ICON = 79
        }
    }
    self.SKILL_BUFF_LIST = {
        [1] = {
            ID = 38050342,
            BUFF_ID = 21,
            VALUE = self.GD.skillBuffValue_21,
            DURATION = 999999,
            ICON = 185,
            COUNT = 0,
            MAX = 99,
            SCRIPT = {
                SCRIPT_ID = 2
            }
        },
        [2] = {
            ID = 38050343,
            BUFF_ID = 89,  --気絶効果
            VALUE = 100,
            DURATION = self.GD.skillBuffTime_89,
            ICON = 79
        },
        [3] = {
            ID = 38050344,
            BUFF_ID = 13,  --攻撃力ダウン
            VALUE = self.GD.skillBuffVal_13,
            DURATION = 999999,
            ICON = 4
        }
    }
    self.HP_BUFF_LIST = {
        [1] = {
            ID = 38050345,
            BUFF_ID = 17,---クリティカルダメージ
            VALUE = self.GD.hpBuffVal_17_1,
            DURATION = 999999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 22
            }
        },
        [2] = {
            ID = 38050346,
            BUFF_ID = 17,  --与ダメージ
            VALUE = self.GD.hpBuffVal_17_2,
            DURATION = 999999,
            ICON = 26,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        }
    }
    self.STUN_BUFF_LIST = {
        ID = 38050310,
        BUFF_ID = 89,  --気絶効果
        VALUE = 100,
        DURATION = self.GD.buffTime_89,
        ICON = 79
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 380503450,
        BUFF_ID = 23, --被クリティカル率
        VALUE = 100,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 380503450,
        BUFF_ID = 0, --被クリティカル率
        VALUE = 0,
        DURATION = 0.1,
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
    return message;
end

function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "はじめましょう", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "プラチナ：魔法耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "パロット：物理耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ダメージの大きい者をターゲット、ターゲットへのCRI率アップ", COLOR = Color.yellow})
    }
    self.HP70_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE1 or "救済の剣よ――", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP70_MESSAGE2 or "クリティカルダメージアップ", COLOR = Color.yellow})
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "虚空に瞬け――", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE2 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "神聖騎士団の力、思い知りなさい！", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE2 or "ダメージ・奥義上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE3 or "ピアノの音が…聞こえる……", COLOR = Color.yellow})
    }
    self.FRIEND_DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.FRIEND_DEAD_MESSAGE1 or "マジ…かよ……！", COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.FRIEND_DEAD_MESSAGE2 or "パロット…仇は討ちます", COLOR = Color.yellow})
    }
    self.EX_GAUGE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_MESSAGE1 or "神聖騎士の守り：ダメージ耐性、物理ダメージで解除", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.EX_GAUGE_MESSAGE2 or "神聖騎士の守り解除成功！", COLOR = Color.red})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "敗れた…なぜ……", COLOR = Color.yellow})
    }
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
        if megast.Battle:getInstance():isHost() then
            if self:findFriend() then
                self:setFriendFlg(self.gameUnit);
            else
                self.hpSkill = 5;
                self.saveBP = self.gameUnit:getBurstPoint();
                self.gameUnit:addSP(100);
            end
        end
        --self.cutInFLG = true;
        self.gameUnit:setInvincibleTime(10);
        self:showMessage(self.HP70_MESSAGE_LIST);
        self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[1]);
    end
end

function class:hp30(status)
    if status == "use3" then
        if megast.Battle:getInstance():isHost() then
            if self:findFriend() then
                self:setFriendFlg(self.gameUnit);
            else
                self.hpSkill = 5;
                self.saveBP = self.gameUnit:getBurstPoint();
                self.gameUnit:addSP(100);
            end
        end
        --self.cutInFLG = true;
        self.gameUnit:setInvincibleTime(10);
        self:showMessage(self.HP30_MESSAGE_LIST);
        if self.GD.isHARD == 1 then
            self.spValue = self.GD.hp30AddSP;
            self.subBarFlg = true;
            self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
            self:showMessage(self.EX_GAUGE_MESSAGE_LIST,1);
        end
    end
end

function class:hp0(status)
    if status == "use3" then
        --self.cutInFLG = true;
        self.gameUnit:setInvincibleTime(10);
        if self:findFriend() then
            self:setFriendFlg(self.gameUnit);
            self.spValue = self.GD.hp0AddSP;
            self.gameUnit:setHP(self.gameUnit:getCalcHPMAX());
            self:execAddBuff(self.gameUnit,self.HP_BUFF_LIST[2]);
            self:showMessage(self.HP0_MESSAGE_LIST,1);
            self:showMessage(self.HP0_MESSAGE_LIST,2);
        else
            if megast.Battle:getInstance():isHost() then
                self.hpSkill = 5;
                self.saveBP = self.gameUnit:getBurstPoint();
                self.gameUnit:addSP(100);
            end
            self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * self.GD.hp0HealRate);
            self:showMessage(self.HP0_MESSAGE_LIST,3);
        end
    end
end

function class:findFriend()
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0,7 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            if teamUnit:getBaseID3() == 169 then--叡天騎帥パロット
                return true;
            end
        end
    end
    return false;
end

function class:setFriendFlg(unit)
    local myTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0,7 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            if not (teamUnit == unit) and (teamUnit:getBaseID3() == 169) then--叡天騎帥パロット
                teamUnit:setParameter("skillLinkFlg","true");
                teamUnit:addSP(100);
            end
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 5,
        hp30AddSP = 10,
        hp0AddSP = 20,
        startAddSP = 0,
        attackDelay = 6,
        hitStop = 100,
        isHARD = 1,
        hp0HealRate = 0.4,

        tgTimer = 15,
        tgLimit = 1,
        tgIconNum1 = 0,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1,
        exGaugeHpRate = 0.4,
        exGaugeDmgRate = 0.01,

        physicalTakeDmgVal = 0.02,

        hpBuffVal_17_1 = 50,
        hpBuffVal_17_2 = 150,
        skillBuffValue_21 = 20,
        skillBuffVal_13 = -100,
        skillBuffTime_89 = 10,
        attackBuffTime_89 = 3,
        buffTime_89 = 3
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
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self:setMessageBoxList();
    self:setTriggerList();
    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});
    self:showMessage(self.START_MESSAGE_LIST);

    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.breakSkip = false;
    self.hpSkill = 0;
    self.saveBP = 0;

    -- 経過時間ギミック
    --createExtraTimer(float maxTime,int loopLimit,int iconNumber,int iconNumber2,float posX = 0,float posY = 0,float scale = 1);
    self.timeIndex = nil;
    self.timeSpeed = nil;

    ---ターゲットギミック
    --自動ヘイトは使わない
    if self.GD.isHARD == 1 then
        self.targetUnit = nil;
        self.targetUnitList = {};
        event.unit:setHateRate_Heal(0);
        event.unit:setHateRate_Damage(0);
        BattleControl:get():visibleHateTarget(true);
        BattleControl:get():setHateTargetIcon(14);
        event.unit:setEnableHate(true);
        event.unit:updateHateTarget();
    end

    --サブHP表示用
    self.subBarFlg = false;
    self.SUB_HP = event.unit:getCalcHPMAX() * self.GD.exGaugeHpRate;
    self.damage = 0;---サブバー表示時のダメージ
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);

    ---ボスギミック
    self.friendDeadInfoFlg = false;
    if event.unit:getParameter("skillLinkFlg") == "" then
        event.unit:setParameter("skillLinkFlg","false");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end
    ---エクストラタイマー表示
    self:extraTimerOperation(event.unit);
    ---エクストラゲージ表示
    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);
    end
    ---奥義連携ギミック
    if event.unit:getParameter("skillLinkFlg") == "true" then
        event.unit:setParameter("skillLinkFlg","false");
        self.hpSkill = 5;
        self.saveBP = self.gameUnit:getBurstPoint();
        event.unit:addSP(100);
    end
    ---相方死亡時info
    if not self.friendDeadInfoFlg then
        if not self:findFriend() then
            self.friendDeadInfoFlg = true;
            self:showMessage(self.FRIEND_DEAD_MESSAGE_LIST);
        end
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

---サブHP表示
function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage)/self.SUB_HP);
    ---ゲージ0になった場合非表示
    if self.SUB_HP - damage <= 0 then
        --エクストラゲージ非表示
        self.subBarFlg = false;
        self.subBar:setVisible(false);
        self.damage = 0;
        --エクストラタイマー非表示
        if self.timeIndex ~= nil then
            megast.Battle:getInstance():removeExtraTimer(self.timeIndex ,1 ,1 ,true);
            self.timeIndex = nil;
            self.timeSpeed = nil;
        end
        self:execAddBuff(unit,self.STUN_BUFF_LIST);
        self:showMessage(self.EX_GAUGE_MESSAGE_LIST,2);
    end
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    if event.index == self.timeIndex then
        self.hpSkill = 5;
        event.unit:addSP(100);
        self.subBarFlg = false;
        self.subBar:setVisible(false);
        self.damage = 0;
        self:execSkill5();
    end
    return event.count;
end

function class:extraTimerOperation(unit)
    if self.timeIndex ~= nil then
        -- 経過時間速度がセット内容と異なったら速度を更新する（演出制御のため毎フレームやらないようにする）
        if megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex) ~= self.timeSpeed then
            megast.Battle:getInstance():setExtraTimerSpeed(self.timeIndex , self.timeSpeed)
            self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex)
        end
    end
end

function class:execSkill5()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            myTeamUnit:setPositionX(myTeamUnit:getPositionX() + 200);
            self:execAddBuff(myTeamUnit,self.SKILL_BUFF_LIST[2]);
            self:execAddBuff(myTeamUnit,self.SKILL_BUFF_LIST[3]);
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill3_orbit" then
        event.unit:addOrbitSystem("skill3_orbit",0);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0);
        end
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    megast.Battle:getInstance():waveEnd(true);
    self:showMessage(self.DEAD_MESSAGE_LIST);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    return 1;
end

function class:receive4(args)
    megast.Battle:getInstance():waveEnd(true);
    self:showMessage(self.DEAD_MESSAGE_LIST);
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

    if event.index == 2 then
        event.unit:setNextAnimationName("skill1");
        event.unit:setNextAnimationEffectName("2-skill1"); ---EFのアニメーション名に気をつける
    elseif event.index == 3 then
        event.unit:setNextAnimationName("skill2");
        event.unit:setNextAnimationEffectName("2-skill2"); ---EFのアニメーション名に気をつける
        if self.GD.isHARD == 1 then
            if self.targetUnit ~= nil then
                self:execAttck3(self.targetUnit,self.ATTCK_BUFF_LIST[1]);
            end
        end
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false;
        self:refresh(self.gameUnit); ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0);
        event.unit:addSP(self.saveBP);
        self.saveBP = 0;
    elseif not self.addSpSkipFLG then
        self:addSP(event.unit);
    end
    -----------------------------------
    return 1;
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex();
    ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時、movePatternState()を動かさない---
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK);
    end
    --------------------------------------------------------------------------------------
    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:addSP(unit)
    if not self.subBarFlg then
        unit:addSP(self.spValue);
    end
    return 1;
end

function class:execAttck3(target,buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            if teamUnit:getIndex() == target:getIndex() then
                self:execAddBuff(teamUnit,buffBox);
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

    --if self.cutInFLG then
    --    self.cutInFLG = false;
    --    event.unit:takeSkillWithCutin(event.index,1);
    --    return 0;
    --end

    if event.index == 3 then
        self:execSkill3(self.SKILL_BUFF_LIST[1]);
    elseif event.index == 5 then
        -- self:execSkill5();
    end

    self.skillCheckFlg = false;
    self.cutInFLG = false;
    self.addSpSkipFLG = true; ---スキル直後の通常攻撃ではaddSPしない
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    --self:initAttackWeight({DEFAULT = 100});---奥義使用後はリセットでスキル1からスタート
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

function class:execSkill3(buffBox)
    ---庇うユニットが居るか確認
    local target = nil;
    local loopNum = 0;
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            loopNum = loopNum + 1;
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                target = cond:getProtectTarget();
            end
        end
    end
    if target ~= nil then
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getIndex() == target then
                    for l = 1,loopNum do
                        self:execAddBuff(teamUnit,buffBox);
                    end
                end
            end
        end
    else
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,buffBox);
            end
        end
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

    if self.GD.isHARD == 1 then
        ---物理ダメージ以外軽減
        local attribute = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute ~= 1 then
            event.value = event.value * self.GD.physicalTakeDmgVal;
        end
    end

    if self.subBarFlg then
        ---物理ダメージで削れる
        local attribute = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 1 then
            self.damage = self.damage + event.value;
        end
        ---エクストラゲージ表示中のダメージ補正
        event.value = event.value * self.GD.exGaugeDmgRate;
    end

    if self.GD.isHARD == 1 then
        ---ターゲットギミック
        local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10);
        if self.targetUnitList[index] == nil then
            table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value});
        else
            self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value;
        end
        ---ホストのみ---
        if megast.Battle:getInstance():isHost() then
            ---ヘイトは全部手動で設定する
            local target = self:checkTargetUnit();
            megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex());---ゲストにターゲットを送る
            event.unit:setHateTarget(target);
            event.unit:updateHateTarget();
            ---ターゲットにバフ
            local myTeam = megast.Battle:getInstance():getTeam(true);
            for i = 0,3 do
                local myTeamUnit = myTeam:getTeamUnit(i);
                if myTeamUnit ~= nil then
                    if i == target:getIndex() then
                        self.targetUnit = target;
                        self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1);
                    else
                        self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0);
                    end
                end
            end
        end
    end

    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

-- 与ダメが最も大きいやつをターゲットにする
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
    local val = 0;
    for i,v in pairs(self.targetUnitList) do
        if v.unit == nil or v.unit:getHP() < 1 then
            v.dps = 0;
        end
        if v.dps > val then
            val = v.dps;
            target = v.unit;
        end
    end

    --ターゲットを取得できなかった場合
    if target == nil then
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                target = myTeamUnit;
                break;
            end
        end
    end
    return target;
end

function class:receive6(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    ---ヘイトは全部手動で設定する
    local target = myTeam:getTeamUnit(args.arg);
    self.gameUnit:setHateTarget(target);
    self.gameUnit:updateHateTarget();
    ---ターゲットにバフ
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if args.arg == myTeamUnit:getIndex() then
                self.targetUnit = target;
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1);
            else
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0);
            end
        end
    end
    return 1;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    end
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
    ---オービット判定
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
    return 1;
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
    if index == nil then
        self:showMessageAll(messageBoxList);
        return;
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
    return 1
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
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
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

    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
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

class.STATE_ATTACK = {}
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

---トリガー時状態異常除去---
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


class:publish();

return class;