--@additionalItem,160052501
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EP5_エリアボス_被験体γ－２", version=2.5, id="gb_505601"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK4 = 50 },
        { ATTACK5 = 50 },
        { ATTACK3 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
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
    SKILL2 = 7,
    ATTACK6 = 8
}

class.cutInSkill = {
    [1] = 1,
    [2] = 1
}


--------[[バフ]]--------
-- 掴み時に自身にかかるバフ内容
class.GLAB_SELF_BUFF_ARGS = {
    {
        ID = -5011,
        BUFF_ID = 113,
        VALUE = 500,
        DURATION = 2,
        ICON = 0
    }
}

-- 掴み時に対象にかかるバフ内容
class.GLAB_TARGET_BUFF_ARGS = {
    {
        ID = -5010,
        BUFF_ID = 89,
        VALUE = 1,
        DURATION = 14,
        ICON = 0
    }
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---グランドバトル共有
    self.GB_BUFF_BOX = {
        [1] = {
            ID = 50560101,
            BUFF_ID = 17,   -- 与ダメージ上昇
            VALUE = self.GD.gbBuffValue_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        }
    }
    ---ターゲットギミック
    self.TARGET_BUFF_LIST1 = {
        ID = 50560100,
        BUFF_ID = 23,---被クリティカル率
        VALUE = self.gbAreaNumber * self.GD.targetBuff_23_1 + self.GD.targetBuff_23_2,
        DURATION = 99999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 50560100,
        BUFF_ID = 0,---被クリティカル率
        VALUE = 0,
        DURATION = 99999,
        ICON = 0
    }
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "与ダメージの大きい者へのクリティカル率アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "一定時間経過するたびに吹雪：燃焼で停止", COLOR = Color.white})
    }
    self.SKILL1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE1 or "マッドプレデター：庇う無効", COLOR = Color.yellow})
    }
    self.SKILL2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "クリムゾンビーティング：庇う無効", COLOR = Color.yellow})
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
        startAddSP = 0,
        attackDelay = 7,
        hitStop = 100,

        timeLimit = 180,
        targetBuff_23_1 = 0.5,
        targetBuff_23_2 = 10,
        gbBuffValue_17 = 25,

        glabDmgBase = 50,
        glabDmgVal = 5000,
        glabMaxDmg = 10000,

        tgTimer = 20,
        tgLimit = 999,
        tgIconNum1 = 0,
        tgIconNum2 = 0,
        tgPosX = 0,
        tgPosY = 0,
        tgScale = 1
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

    ---グランドバトル
    self.gbAreaNumber = megast.Battle:getInstance():getCurrentGrandBattleFloor();

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

    ---バトルタイム
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.GD.timeLimit ,30, 620 , -100 ,0.8);
    ---ヘイトギミック
    --event.unit:setEnableGBHate(true);
    ---ターゲットギミック
    --自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnitList = {}
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();
    self.targetUnit = nil

    ---経過時間ギミック
    --//createExtraTimer(float maxTime ,int loopLimit ,int iconNumber ,int iconNumber2 ,float posX = 0 ,float posY = 0 ,float scale = 1);
    self.timeIndex = megast.Battle:getInstance():createExtraTimer(self.GD.tgTimer, self.GD.tgLimit ,self.GD.tgIconNum1, self.GD.tgIconNum2, self.GD.tgPosX, self.GD.tgPosY, self.GD.tgScale);
    self.timeSpeed = megast.Battle:getInstance():getExtraTimerSpeed(self.timeIndex);
    self.deBuffFlg = false;
    self.breakFlg = false;
    self.exTimerSetTbl = {
        timeIndex = self.timeIndex,
        timeSpeed = self.timeSpeed,
        changeSpeed = 0.5,
        buffIcon1 = 0,
        buffIcon2 = 0,
        skillIndex = 1
    };

    ---ボスギミック
    self.itemFlg = false
    self.itemId = 160052501;
    self.item = event.unit:setItemSkill(0,self.itemId);
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end

    ---バトルタイム
    self:countDown()

    ---掴み時
    self:updateGlab(event.unit)

    ---経過時間ギミック
    --燃焼状態かどうか
    local cond = event.unit:getTeamUnitCondition():findConditionWithType(97);
    if not self.deBuffFlg and cond ~= nil then
        self.deBuffFlg = true;
        self:extraTimer("reset" ,self.exTimerSetTbl);
        self:extraTimer("stop" ,self.exTimerSetTbl);
    elseif self.deBuffFlg and cond == nil and not event.unit:isBreak() then
        self.deBuffFlg = false;
        self:extraTimer("start" ,self.exTimerSetTbl);
    end
    -- ブレイク後は再始動
    if not self.deBuffFlg and self.breakFlg and not event.unit:isBreak() then
        self.breakFlg = false;
        self:extraTimer("start" ,self.exTimerSetTbl);
    end

    ---装備ギミック
    if self.itemFlg and self:attackCheck(event.unit) then
        self.itemFlg = false
        self:useItem()
    end

    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    return 1
end

function class:attackCheck(unit)
    local state = unit:getUnitState();
    if state ~= kUnitState_attack and state ~= kUnitState_skill then
        return true;
    end
    return false;
end

function class:countDown()
    if BattleControl:get():getTime() > self.GD.timeLimit then
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                myTeamUnit:setHP(0)
                myTeam:deadUnit(myTeamUnit:getIndex());
            end
        end
    end
end

--extraTimer操作系
function class:extraTimer(str,setTbl)
    if str == "start" then
        --setExtraTimerSpeed(int index,float speed);
        megast.Battle:getInstance():setExtraTimerSpeed(setTbl.timeIndex ,setTbl.timeSpeed);
    elseif str == "change" then
        megast.Battle:getInstance():setExtraTimerSpeed(setTbl.timeIndex ,setTbl.timeSpeed * setTbl.changeSpeed);
    elseif str == "stop" then
        megast.Battle:getInstance():setExtraTimerSpeed(setTbl.timeIndex ,0);
    elseif str == "reset" then
        --setExtraTimerSpeed(int index,float speed);
        megast.Battle:getInstance():setExtraTimerPercentage(setTbl.timeIndex ,0);
    elseif str == "delete" then
        --removeExtraTimer(int index,float fadeTime,float delayTime,bool isAnimation);
        megast.Battle:getInstance():removeExtraTimer(setTbl.timeIndex ,1 ,1 ,true);
    elseif str == "iconChange" then
        --setExtraTimerBuffIcon(int index,int iconNumber,int iconNumber2);
        megast.Battle:getInstance():setExtraTimerBuffIcon(setTbl.timeIndex ,setTbl.buffIcon1 ,0);
    elseif str == "setSkill" then
        --setExtraTimerBattleSkill(int index,int skillIndex);
        megast.Battle:getInstance():setExtraTimerBuffIcon(setTbl.timeIndex ,setTbl.skillIndex);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    --summoner.Utility.messageByEnemy("extraTimerOneRound_index_"..event.index.."_count_"..event.count);
    --self.timeIndex = megast.Battle:getInstance():createExtraTimer(20, 1, 16, 0);
    self.itemFlg = true
    return event.count
end

function class:useItem()
    self.gameUnit:takeItemSkill(0); --吹雪
    self.item:setCoolTimer(0);
end

---------------------------------------------------------------------------------
-- takeCast
---------------------------------------------------------------------------------
function class:takeCast(event)
    return 0;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "tryGlab" then return self:tryGlab(event.unit); end
    if event.spineEvent == "glabEnd" then return self:glabEnd(event.unit); end
    return 1;
end

function class:tryGlab(unit)
    if not self:getIsHost() then
        return 1;
    end

    local targetIndex = self:checkTarget(unit);
    if targetIndex ~= nil then
        self:execGlab(unit,targetIndex);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,targetIndex);
    end
    return 1;
end

function class:receive4(args)
    self:execGlab(self.gameUnit,args.arg);
    return 1;
end

function class:checkTarget(unit)
    --奥義ゲージが一番高いユニットを出す
    local index = 0
    local sp = -1
    for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if localUnit ~= nil then
            if sp < localUnit:getBurstPoint() then
                index = i
                sp = localUnit:getBurstPoint()
            end
        end
    end
    return index
end

function class:execGlab(unit,targetIndex)
    local target = self:getPlayerUnit(targetIndex);
    if target == nil then
        return;
    end

    self:addBuff(unit,self.GLAB_SELF_BUFF_ARGS);
    self:addBuff(target,self.GLAB_TARGET_BUFF_ARGS);
    self.glabIndex = targetIndex;
end

function class:getPlayerUnit(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

function class:glabEnd(unit)
    if self.glabIndex == nil then return 1; end
    local target = self:getPlayerUnit(self.glabIndex);
    if target == nil then
        self.glabIndex = nil;
        return 1;
    end

    local orbitHit = unit:addOrbitSystem("GrowndHit",0);
    unit:takeHitStop(0.5);
    orbitHit:setPosition(target:getPositionX(),target:getPositionY() + target:getSkeleton():getBoneWorldPositionY("MAIN"));
    orbitHit:setTargetUnit(target);
    orbitHit:setHitType(2);
    orbitHit:setActiveSkill(self.ACTIVE_SKILLS.ATTACK6);

    --固定ダメージ
    local damage = self.gbAreaNumber * self.GD.glabDmgBase + self.GD.glabDmgVal;
    if damage >= self.GD.glabMaxDmg then
        damage = self.GD.glabMaxDmg;
    end

    local hp = target:getHP() - damage;
    if hp < 0 then hp = 0 end
    target:setHP(hp);

    --デバフがある場合はHPを０に
    local cond = target:getTeamUnitCondition():findConditionWithType(96);  --氷結
    if cond ~= nil then
        target:setHP(0);
        target:takeDamagePopup(unit,999999);
    else
        target:takeDamagePopup(unit,damage);
    end

    self:removeBuffs(target,self.GLAB_TARGET_BUFF_ARGS);
    self.glabIndex = nil;
    return 1;
end

function class:updateGlab(unit)
    if self.glabIndex == nil then return; end
    local target = self:getPlayerUnit(self.glabIndex);
    if target == nil then return; end
    local x = unit:getSkeleton():getBoneWorldPositionX("R_hand_attack4") + unit:getPositionX();
    local y = unit:getSkeleton():getBoneWorldPositionY("R_hand_attack4") + unit:getPositionY();
    local targetWorldPositionX = target:getSkeleton():getBoneWorldPositionX("MAIN");
    local targetWorldPositionY = target:getSkeleton():getBoneWorldPositionY("MAIN");
    target:setPosition(x - targetWorldPositionX,target:getPositionY());
    target:getSkeleton():setPosition(0,y - target:getPositionY() - targetWorldPositionY);
end

function class:addBuff(unit,buffBoxList)
    for i,buffBox in ipairs(buffBoxList) do
        self:execAddBuff(unit,buffBox);
    end
end

function class:removeBuffs(unit,buffs)
    for _,v in pairs(buffs) do
        self:removeBuff(unit,v.ID);
    end
end

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end
    unit:getTeamUnitCondition():removeCondition(buff);
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

    --if event.index == 1 then
    --    event.unit:setNextAnimationName("attack1");
    --    event.unit:setNextAnimationEffectName("1-attack1");
    --end

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

    if event.index == 1 and self.cutInFLG then
        self.cutInFLG = false
        event.unit:takeSkillWithCutin(event.index,1);
        return 0
    end

    if event.index == 1 then
        if self.targetUnit ~= nil then
            self:targetUnitReset(event.unit);
        end

        self:execAddBuff(event.unit, self.GB_BUFF_BOX[1]);
        self:showMessage(self.SKILL1_MESSAGE_LIST);
    elseif event.index == 2 then
        self:showMessage(self.SKILL2_MESSAGE_LIST);
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

function class:targetUnitReset(unit)
    local flg = false;
    unit:updateHateTarget();
    local targetUnit = unit:getHateTarget();
    --targetUnit = nil の時
    local myTeam = megast.Battle:getInstance():getTeam(true);
    if targetUnit == nil then
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                flg = true;
                targetUnit = myTeamUnit;
                self.targetUnit = targetUnit
                break;
            end
        end
    end

    if not flg then
        local targetIndex = targetUnit:getIndex();
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                if i == targetIndex then
                    local enemyUnit = self:getAncestorUnit(myTeamUnit);
                    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10);
                    self.targetUnitList[index].dps = 0;
                end
            end
        end
    end

    ---ヘイトは全部手動で設定する
    local target = self:checkTargetUnit();
    if flg then
        target = self.targetUnit;
    end

    unit:setHateTarget(target);
    unit:updateHateTarget();
    ---ターゲットにバフ
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if i == target:getIndex() then
                self.targetUnit = target
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1);
            else
                self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0);
            end
        end
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    --local enemyUnit = self:getAncestorUnit(event.enemy)
    --local gbHatePercent = event.unit:getGBHatePercent(enemyUnit:getIndex())
    --local rate = ((gbHatePercent * self.GD.hateGimmickRate) + self.GD.hateGimmickBase) / 100
    --summoner.Utility.messageByEnemy(gbHatePercent.."/"..rate)
    --event.value = event.value * rate
    return event.value
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    --local enemyUnit = self:getAncestorUnit(event.enemy)
    --local gbHatePercent = event.unit:getGBHatePercent(enemyUnit:getIndex())
    --local rate = ((gbHatePercent * self.GD.hateGimmickRate) + self.GD.hateGimmickBase) / 100
    --summoner.Utility.messageByEnemy(gbHatePercent.."/"..rate)
    --event.value = event.value * rate
    return event.value
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);

    ---ターゲットギミック
    ---ユニットのダメージをテーブルに格納
    local enemyUnit = self:getAncestorUnit(event.enemy);
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
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1);
                else
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0);
                end
            end
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

---与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil
    local targetTeam = megast.Battle:getInstance():getTeam(true)
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            target = myTeamUnit
            break;
        end
    end
    local val = 0
    for i,v in pairs(self.targetUnitList) do
        if v.unit == nil or v.unit:getHP() < 1 then
            --v.dps = 0
        elseif v.dps >= val then
            val = v.dps
            target = v.unit
        end
    end

    --ターゲットを取得できなかった場合
    if target == nil then
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                target = myTeamUnit
                break;
            end
        end
    end

    self.targetUnit = target
    return target
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

    ---extraTimer
    self.breakFlg = true;
    self:extraTimer("stop" ,self.exTimerSetTbl);
    return 1
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    if self.glabIndex ~= nil then
        local target = self:getPlayerUnit(self.glabIndex);
        if target ~= nil then
            self:removeBuffs(target,self.GLAB_TARGET_BUFF_ARGS);
            self.glabIndex = nil
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- idle
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


class:publish();

return class;