local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_被験体φ-2", version=2.0, id=600000116});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK2 = 50, ATTACK3 = 50 },
        { ATTACK4 = 50 },
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 50 },
        { SKILL1 = 50 },
        { SKILL1 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 8,
    ATTACK5 = 5,
    ATTACK6 = 4,
    SKILL1 = 6,
    SKILL2 = 7,
}

class.cutInSkill = {
    --[3] = 1
}

--------[[バフ]]--------
function class:setBuffBoxList()
    ---ボスギミック
    self.GRID_BUFF_LIST = {
        [1] = {
            ID = 10,
            BUFF_ID = 89,  --気絶効果
            VALUE = 100,
            DURATION = 10,
            ICON = 79
        },
    }
    self.ATTACK4_BUFF = {
        [1] = {
            ID = 0,
            BUFF_ID = 2,  --スキル4 最大HP
            VALUE = self.GD.buffValue_2,
            DURATION = 9999999,
            ICON = 2,
        },
        [2] = {
            ID = 0,
            BUFF_ID = 30,  --スキル4 装備CT
            VALUE = self.GD.buffValue_30,
            DURATION = 9999999,
            ICON = 183,
        },
    }

    self.SKILL_BUFF = {
        [1] = {
            ID = 600001163,
            BUFF_ID = 17,  --奥義時 与ダメ
            VALUE = self.GD.buffValue_17,
            DURATION = 9999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 600001164,
            BUFF_ID = 129,  --奥義時 継続ダメージ
            VALUE = self.GD.buffValue_129,
            DURATION = 9999999,
            ICON = 180,
            COUNT = 2,
            MAX = 10,
            SCRIPT = {
                SCRIPT_ID = 228
            }
        },
        [3] = {
            ID = 600001165,
            BUFF_ID = 53,  --奥義7 毒耐性
            VALUE = self.GD.buffValue_53,
            DURATION = 9999999,
            ICON = 69,
            COUNT = 0,
            MAX = 10
        },
        [4] = {
            ID = 600001166,
            BUFF_ID = 102,  --奥義7 毒回避率
            VALUE = self.GD.buffValue_53,
            DURATION = 9999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10
        }
    }
end

-- 奥義6発動時の毒Dot計算
function class:setPoisonBuffBox(enemy)
    -- 最大HPの2%
    --local hpPercent = enemy:getCalcHPMAX() * 0.02;
    self.POISON_BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 90,  --毒効果
            VALUE = self.GD.buffValue_90,
            DURATION = 60,
            ICON = 80,
            SCRIPT = {
                SCRIPT_ID = 405,
                VALUE1 = self.GD.buffValue_90
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "物理回避", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "毒の吹雪が吹き荒れる", COLOR = Color.green})
    }
    self.POISONBLIZZARD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.POISONBLIZZARD_MESSAGE1 or "毒の吹雪が激しさを増す", COLOR = Color.green})
    }
    self.POISONBLIZZARDSTART_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.POISONBLIZZARDSTART_MESSAGE1 or "毒の吹雪：パーティを毒状態", COLOR = Color.red})
    }
    self.GRAB_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.GRAB_MESSAGE1 or "HPが高い者をホールド", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.GRAB_MESSAGE2 or "%sのHP・装備CT速度低下", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.GRAB_MESSAGE3 or "%sの奥義ゲージダウン", COLOR = Color.red})
    }
    self.SKILL6_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL6_MESSAGE1 or "リーダーユニットを毒状態", COLOR = Color.red}),
    }
    self.SKILL7_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL7_MESSAGE1 or "クリムゾンビーディング：ダメージ無効化無効", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL7_MESSAGE2 or "パーティの毒耐性ダウン", COLOR = Color.red}),
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    --[[
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp70(status) end,
            HP = 70,
            used = false,
            isEnableSkip = true
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false,
            isEnableSkip = false
        }
    }
    --]]
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

--[[
function class:hp70(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 1
            self.saveBP = self.gameUnit:getBurstPoint()
            self.gameUnit:addSP(100)
        end
        self.cutInFLG = true
        self:removeBadCondition(self.gameUnit)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
        self:showMessage(self.HP70_MESSAGE_LIST)
    end
end

function class:hp50(status)
    if status == "use3" then
        self.stateName = "FURY"
        if megast.Battle:getInstance():isHost() then
            self.hpSkill = 2
            self.saveBP = self.gameUnit:getBurstPoint()
        end
        self.spValue = 30;
        self.cutInFLG = true
        self.gameUnit:setBurstPoint(80)
        self.isRage = true
        self:removeBadCondition(self.gameUnit)
        --self.gameUnit:setInvincibleTime(7)
        self.gameUnit:takeAnimation(0,"attack5",false)
        self:initSkillWeight({HP50 = 100})
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
        self:showMessage(self.HP50_MESSAGE_LIST)
    end
end
]]

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 30,
        attackDelay = 5.0,
        hitStop = 100,
        startAddSP = 40,
        buffValue_2 = -30,
        buffValue_30 = -30,
        buffValue_17 = 20,
        buffValue_129 = 1,
        buffValue_53 = -20,
        buffValue_90 = 2,
        poisonDamageValue = 0.2,
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

    ---ボスギミック
    self.skill2Flg = false
    self.grabIndex = nil
    self.checkGrab = false

    -- 毒の吹雪ギミック
    self.poisonCnt = 0
    self.hpCheckFlg = false

    self.isPoisonBlizzard = false
    self.itemId = 160042501
    self.item = event.unit:setItemSkill(0,self.itemId)

    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
    if hpPercent <= 25 then
        self.poisonCnt = 3
        self:showMessage(self.POISONBLIZZARD_MESSAGE_LIST)
    elseif hpPercent <= 50 then
        self.poisonCnt = 2
        self:showMessage(self.POISONBLIZZARD_MESSAGE_LIST)
    elseif hpPercent <= 75 then
        self.poisonCnt = 1
        self:showMessage(self.POISONBLIZZARD_MESSAGE_LIST)
    else
        self.poisonCnt = 0
    end
    self.hpCheckFlg = true
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効

    if self.hpCheckFlg then
        local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
        if hpPercent <= 25 and self.poisonCnt == 2 then
            self.poisonCnt = 3
            self:showMessage(self.POISONBLIZZARD_MESSAGE_LIST)
        end
        if hpPercent <= 50 and self.poisonCnt == 1 then
            self.poisonCnt = 2
            self:showMessage(self.POISONBLIZZARD_MESSAGE_LIST)
        end
        if hpPercent <= 75 and self.poisonCnt == 0 then
            self.poisonCnt = 1
            self:showMessage(self.POISONBLIZZARD_MESSAGE_LIST)
        end
    end

    if self.skill2Flg and event.unit:getUnitState() ~= kUnitState_skill then
        self.skill2Flg = false
        event.unit.m_IgnoreHitStopTime = 0
    end

    self:updateGrab(event.unit,event.deltaTime);
    return 1
end

function class:updateGrab(unit,deltaTime)
    if self.grabIndex == nil then return end
    local target = self:getPlayerUnit(self.grabIndex);
    local x = unit:getSkeleton():getBoneWorldPositionX("R_hand_attack4") + unit:getPositionX();
    local y = unit:getSkeleton():getBoneWorldPositionY("R_hand_attack4") + unit:getPositionY();
    local targetWorldPositionX = target:getSkeleton():getBoneWorldPositionX("MAIN");
    local targetWorldPositionY = target:getSkeleton():getBoneWorldPositionY("MAIN");
    target:setPosition(x - targetWorldPositionX,target:getPositionY());
    target:getSkeleton():setPosition(0,y - target:getPositionY() - targetWorldPositionY);
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "glabCheckStart" then return self:grabCheckStart(event.unit); end
    if event.spineEvent == "tryGlab" then return self:tryGrab(event.unit); end
    if event.spineEvent == "glabEnd" then return self:grabEnd(event.unit, false); end
    return 1;
end

function class:grabCheckStart(unit)
    self.checkGrab = true
    self.grabIndex = self:checkTarget()
    self:execShowMessage(self.GRAB_MESSAGE_LIST[1])
    return 1;
end

function class:tryGrab(unit)
    self.checkGrab = false;
    if not self:getIsHost() then return 1; end
    if self.grabIndex ~= nil then
        self:execGrab(self.grabIndex);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,self.grabIndex);
    end
    return 1;
end

function class:receive4(args)
    self:execGlab(args.arg);
    return 1;
end

function class:checkTarget(unit)
    local hp = 0
    -- 庇うユニットを探す
    local index = self:getProtectIndex()
    -- HPの高いユニットを探す
    if index == -1 then
        for i = 0,3 do
            local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
            if localUnit ~= nil then
                if hp < localUnit:getCalcHPMAX() then
                    index = i
                    hp = localUnit:getCalcHPMAX()
                end
            end
        end
    end
    return index
end

function class:execGrab(targetIndex)
    local target = self:getPlayerUnit(targetIndex);
    if target == nil then
        return;
    end
    self:execAddBuff(target,self.GRID_BUFF_LIST[1])
end

function class:grabEnd(unit, tdamage)
    if self.grabIndex == nil then return 1; end
    local target = self:getPlayerUnit(self.grabIndex);
    if target == nil then self.grabIndex = nil; return 1; end

    -- ブレイク中はオービットを出さない
    if tdamage then
        self.grabIndex = nil
        self:removeBuffs(target,self.GRID_BUFF_LIST)
        return 1
    end

    local orbitHit = unit:addOrbitSystem("GrowndHit",0);
    unit:takeHitStop(0.5);
    orbitHit:setPosition(target:getPositionX(),target:getPositionY() + target:getSkeleton():getBoneWorldPositionY("MAIN"));
    orbitHit:setTargetUnit(target);
    orbitHit:setHitType(2);
    orbitHit:setActiveSkill(self.ACTIVE_SKILLS.ATTACK6);

    self.grabIndex = nil
    self:showFormatMessage(self.GRAB_MESSAGE_LIST[2],target:getUnitName())
    self:showFormatMessage(self.GRAB_MESSAGE_LIST[3],target:getUnitName())
    self:removeBuffs(target,self.GRID_BUFF_LIST)
    self:execAddBuff(target,self.ATTACK4_BUFF[1])
    self:execAddBuff(target,self.ATTACK4_BUFF[2])
    local burst = target:getBurstPoint() - 300
    if burst < 0 then burst = 0; end
    target:setBurstPoint(burst);

    return 1
end

function class:getPlayerUnit(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

--- 庇うユニットを探す
function class:getProtectIndex()
    local team = megast.Battle:getInstance():getTeam(true)
    local FLG = false
    local rtn = -1
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                FLG = true
            end
        end
    end
    --庇うユニットがいる場合そのindex返す
    if FLG then
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
                if cond == nil then
                    rtn = i
                end
            end
        end
    end
    return rtn
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

    if self.isPoisonBlizzard then
        self.isPoisonBlizzard = false
        self:PoisonBlizzard(event.unit)
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

function class:PoisonBlizzard(unit)
    local rand = LuaUtilities.rand(0,100);
    local FLG = false
    if self.poisonCnt >= 3 then
        if rand < 75 then
            FLG = true
        end
    elseif self.poisonCnt == 2 then
        if rand < 50 then
            FLG = true
        end
    elseif self.poisonCnt == 1 then
        if rand < 30 then
            FLG = true
        end
    else
        if rand < 15 then
            FLG = true
        end
    end
    if FLG then
        unit:takeItemSkill(0)
        self.item:setCoolTimer(0)
        self:showMessage(self.POISONBLIZZARDSTART_MESSAGE_LIST)
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

    if event.index == 1 then
        self:addSkill1Buff()
        self:showMessage(self.SKILL6_MESSAGE_LIST)
    elseif event.index == 2 then
        self.skill2Flg = true
        event.unit.m_IgnoreHitStopTime = 99999
        self:addSkill2Buff()
        self:showMessage(self.SKILL7_MESSAGE_LIST)
    end

    -- 共通
    self:execAddBuff(event.unit,self.SKILL_BUFF[1])
    self:addDotBuff()
    -- 次の攻撃で毒の吹雪を発動させるかどうか
    self.isPoisonBlizzard = true

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

function class:addSkill1Buff()
    local team = megast.Battle:getInstance():getTeam(true)
    local FLG = false
    for i = 0,7 do
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                FLG = true
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
                    self:setPoisonBuffBox(teamUnit)
                    self:execAddBuff(teamUnit,self.POISON_BUFF_LIST[1])
                end
            end
        end
    else
        --- いない場合リーダーを対象に
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getIsLeader() then
                    self:setPoisonBuffBox(teamUnit)
                    self:execAddBuff(teamUnit,self.POISON_BUFF_LIST[1])
                end
            end
        end
    end
end

function class:addSkill2Buff()
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
    ---庇うユニットがいる場合
    if FLG then
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
                if cond == nil then
                    for i = 1,count do
                        self:execAddBuff(teamUnit,self.SKILL_BUFF[3])
                        self:execAddBuff(teamUnit,self.SKILL_BUFF[4])
                    end
                end
            end
        end
    else
        --- いない場合全員を対象に
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit,self.SKILL_BUFF[3])
                self:execAddBuff(teamUnit,self.SKILL_BUFF[4])
            end
        end
    end
end

function class:addDotBuff()
    for i = 0,7 do
        local team = megast.Battle:getInstance():getTeam(true)
        local teamUnit = team:getTeamUnit(i);
        if teamUnit ~= nil then
            self:execAddBuff(teamUnit,self.SKILL_BUFF[2])
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
    -- 毒状態の場合
    local race = enemyUnit:getTeamUnitCondition():findConditionWithType(90);
    if race ~= nil then
        event.value = event.value * self.GD.poisonDamageValue
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

--与ダメが最も大きいやつをターゲットにする
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
    return target
end

function class:checkCritical(enemyUnit)
    if self.isRage == false then
        if not enemyUnit:getTeamUnitCondition():getDamageAffectInfo().critical then
            return true
        end
    elseif enemyUnit:getTeamUnitCondition():getDamageAffectInfo().critical then
        return true
    end

    return false
end

function class:receive6(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    ---ヘイトは全部手動で設定する
    local target = myTeam:getTeamUnit(args.arg)
    self.gameUnit:setHateTarget(target)
    self.gameUnit:updateHateTarget();
    ---ターゲット指定
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if args.arg == target:getIndex() then
                self.targetUnitIndex = args.arg
            end
        end
    end
    return 1
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
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    self:grabEnd(event.unit, true);
    return 1;
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
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP], true)
    end
    return 1
end

function class:removeBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:removeBuff(unit,v.ID);
    end
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
    if buffBox.COUNT ~= nil and buffBox.COUNT ~= 0 then
        count = buffBox.COUNT
    end
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

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end

    unit:getTeamUnitCondition():removeCondition(buff);
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

function class:removeBadCondition(unit)
    local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
    if conditionSize == 0 then return 0 end
    for i = 0,(conditionSize - 1) do
        local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
        if cond ~= nil then
            for k,typeId in pairs(self:getBadStatusList()) do
                if cond:getConditionTypeAsInt() == typeId then
                    cond:setTime(0) --バフ除去
                end
            end
        end
    end
end

function class:getBadStatusList()
    local badStatusList = {
        89,
        90,
        91,
        92,
        93,
        94,
        95,
        96,
        97,
        129,
        131,
        135
    }
    return badStatusList
end

class:publish();

return class;