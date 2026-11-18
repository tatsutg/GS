local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_闇玉精プルートゥ（強）", version=2.5, id=600000118});
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
        { SKILL1 = 50 },
        { SKILL1 = 50 },
        { SKILL2 = 50 }
    },
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
}

class.cutInSkill = {
    --[1] = 1,
    --[2] = 1
}

---クリスタル関係
class.CRYSTAL_NUM = 3;

class.CRYSTAL_STATES = {
    start = 0,
    deactive = 1,
    activation = 2,
    active = 3,
    out = 4,
    hide = 5,
    start2 = 6
}

--------[[バフ]]--------
function class:setBuffBoxList()
    self.RAID_BUFF_BOX = {
        [1] = {
            ID = 600011801,
            BUFF_ID = 17,   -- 与ダメージ上昇
            VALUE = self.GD.skill5BuffValue_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 99
        }
    }
    ---ボスギミック
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 600011802,
            BUFF_ID = 54,   -- 麻痺耐性
            VALUE = self.GD.resistBuffValue_54,
            DURATION = 999999,
            ICON = 60,
            COUNT = 0,
            MAX = 99
        },
        [2] = {
            ID = 600011803,
            BUFF_ID = 103,   -- 麻痺回避率
            VALUE = self.GD.resistBuffValue_54,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 99
        },
        [3] = {
            ID = 600011804,
            BUFF_ID = 56,   -- 暗闇耐性
            VALUE = self.GD.skill5BuffValue_56,
            DURATION = 999999,
            ICON = 72,
            COUNT = 0,
            MAX = 10
        },
        [4] = {
            ID = 600011805,
            BUFF_ID = 105,   -- 暗闇回避率
            VALUE = self.GD.skill5BuffValue_56,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10
        },
    }
    self.LAMP_BUFF_BOX_LIST = {
        [1] = {
            ID = 600011806,
            BUFF_ID = 23,   -- クリティカル耐性
            VALUE = self.GD.lamp1BuffValue_23,
            DURATION = 999999,
            ICON = 188,
        },
        [2] = {
            ID = 600011807,
            BUFF_ID = 22,   -- クリティカル率
            VALUE = self.GD.lamp2BuffValue_22,
            DURATION = 999999,
            ICON = 11,
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "暗闇状態のユニットからのダメージ軽減", COLOR = Color.yellow}),
    }
    self.LIGHTON1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTON1_MESSAGE1 or "第一の光が灯る：麻痺で消灯", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTON1_MESSAGE2 or "クリティカル耐性アップ", COLOR = Color.yellow})
    }
    self.LIGHTON2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTON2_MESSAGE1 or "第二の光が灯る：麻痺で消灯", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTON2_MESSAGE2 or "クリティカル率アップ", COLOR = Color.yellow})
    }
    self.LIGHTON3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTON3_MESSAGE1 or "第三の光が灯る：麻痺で消灯", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTON3_MESSAGE2 or "奥義上昇量アップ", COLOR = Color.yellow}),
    }
    self.LIGHTOFF1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTOFF1_MESSAGE1 or "麻痺で第一の光が消灯", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTOFF1_MESSAGE2 or "クリティカル耐性ダウン・麻痺耐性アップ", COLOR = Color.red})
    }
    self.LIGHTOFF2_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTOFF2_MESSAGE1 or "麻痺で第二の光が消灯", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTOFF2_MESSAGE2 or "クリティカル率ダウン・麻痺耐性アップ", COLOR = Color.red})
    }
    self.LIGHTOFF3_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTOFF3_MESSAGE1 or "麻痺で第三の光が消灯", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.LIGHTOFF3_MESSAGE2 or "奥義上昇量ダウン・麻痺耐性アップ", COLOR = Color.red}),
    }
    self.SKILL5_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL5_MESSAGE_LIST1 or "パーティの暗闇耐性ダウン", COLOR = Color.red}),
    }
    self.SKILL6_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL6_MESSAGE_LIST1 or "マーダーイクリプス：ダメージ無効化無効", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL6_MESSAGE_LIST2 or "プレイヤーユニットのステータスをランダムで低下", COLOR = Color.red}),
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
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

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 20,
        attackDelay = 10,
        hitStop = 100,
        startAddSP = 40,
        lamp1BuffValue_23 = -300,
        lamp2BuffValue_22 = 100,
        lamp3addSP = 50,
        skill5BuffValue_17 = 20,
        skill5BuffValue_56 = -20,
        resistBuffValue_54 = 10,
        skill6BuffBaseValue = -20,
        skill6BuffRateValue = -10,
        blindTakeDamageValue = 0.2,
        crystalLeftX = -300,
        crystalLeftY = 400,
        crystalCenterX = 0,
        crystalCenterY = 430,
        crystalRightX = 300,
        crystalRightY = 400,
        crystalZOrder = 1
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

    --ボスギミック
    self.condCount = 0
    self.flameList = {}

    ---クリスタル関係
    self.CRYSTAL_POSITIONS = {
        {x = self.GD.crystalLeftX,y = self.GD.crystalLeftY},
        {x = self.GD.crystalRightX,y = self.GD.crystalRightY},
        {x = self.GD.crystalCenterX,y = self.GD.crystalCenterY}
    }

    self.crystals = {};
    self.crystalBuffs = {};
    self.crystalDBuffs = {};
    self.crystalCounter = 0;
    --self.crystalExcutionFlg = false
    self:initCrystals(event.unit);
    self:setUpCrystalBuffs(event);

    self.isStun = false;
    self.skill6Count = 0

    return 1
end

--====================================================================================================================================
--クリスタル関係

function class:initCrystals(unit)
    for i=1,3 do
        self.crystals[i] = self:createCrystal(unit,self.CRYSTAL_POSITIONS[i].x,self.CRYSTAL_POSITIONS[i].y);
    end
end

function class:createCrystal(unit,x,y)
    local crystal = {}
    crystal.orbit = unit:addOrbitSystem("crystal_idle_off");
    crystal.orbit:takeAnimation(0,"crystal_idle_off",true);
    crystal.orbit:setPosition(x,y);
    crystal.orbit:setZOrder(self.GD.crystalZOrder);
    crystal.state = self.CRYSTAL_STATES.deactive;

    crystal.endState = function(class,this)
        if this.state == class.CRYSTAL_STATES.start then
            this.switchState(class,this,class.CRYSTAL_STATES.deactive);
        elseif this.state == class.CRYSTAL_STATES.activation then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
        elseif this.state == class.CRYSTAL_STATES.out then
            this.switchState(class,this,class.CRYSTAL_STATES.hide);
        elseif this.state == class.CRYSTAL_STATES.start2 then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
        end
    end

    crystal.switchState = function(class,this,targetState)
        this.state = targetState;
        if targetState == class.CRYSTAL_STATES.active then
            this.orbit:takeAnimation(0,"crystal_idle_on",true);
        end
        if targetState == class.CRYSTAL_STATES.deactive then
            this.orbit:takeAnimation(0,"crystal_idle_off",true);
        end
        if targetState == class.CRYSTAL_STATES.activation then
            this.orbit:takeAnimation(0,"crystal_activate",true);
        end
        if targetState == class.CRYSTAL_STATES.start then
            this.orbit:takeAnimation(0,"crystal_in",true);
        end

        if targetState == class.CRYSTAL_STATES.start2 then
            this.orbit:takeAnimation(0,"crystal_in2",true);
        end

        if targetState == class.CRYSTAL_STATES.out then
            this.orbit:takeAnimation(0,"crystal_out",true);
        end

        if targetState == class.CRYSTAL_STATES.hide then
            this.orbit:takeAnimation(0,"crystal_hide",true);
        end
    end

    return crystal;
end

function class:setUpCrystalBuffs(event)
    self.crystalBuffs[1] = {action = function(luaInstance,unit)
        luaInstance:execAddBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[1]);
        luaInstance:showMessage(luaInstance.LIGHTON1_MESSAGE_LIST);
    end
    }
    self.crystalBuffs[2] = {action = function(luaInstance,unit)
        luaInstance:execAddBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[2]);
        luaInstance:showMessage(luaInstance.LIGHTON2_MESSAGE_LIST);
    end
    }
    self.crystalBuffs[3] = {action = function(luaInstance,unit)
        luaInstance:changeAddSP(luaInstance.GD.lamp3addSP);
        luaInstance:showMessage(luaInstance.LIGHTON3_MESSAGE_LIST);
    end
    }
    self.crystalDBuffs[1] = {action = function(luaInstance,unit)
        luaInstance:removeBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[1].ID);
        luaInstance:showMessage(luaInstance.LIGHTOFF1_MESSAGE_LIST);
    end
    }
    self.crystalDBuffs[2] = {action = function(luaInstance,unit)
        luaInstance:removeBuff(unit,luaInstance.LAMP_BUFF_BOX_LIST[2].ID);
        luaInstance:showMessage(luaInstance.LIGHTOFF2_MESSAGE_LIST);
    end
    }
    self.crystalDBuffs[3] = {action = function(luaInstance,unit)
        luaInstance:changeAddSP(luaInstance.GD.addSP);
        luaInstance:showMessage(luaInstance.LIGHTOFF3_MESSAGE_LIST);
    end
    }
end

function class:changeAddSP(num)
    self.spValue = num;
end

function class:removeBuff(unit,id)
    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    if buff == nil then
        return;
    end

    unit:getTeamUnitCondition():removeCondition(buff);
end

function class:lightUp(unit,num)
    if num > self.CRYSTAL_NUM then
        return;
    end

    if self.crystalBuffs[num] ~= nil then
        self.crystalBuffs[num].action(self,unit);
        --self.crystalBuffs[num] = nil;
    end

    for i=1,num do
        if self.crystals[i].state == self.CRYSTAL_STATES.deactive then
            self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.activation);
        end
    end
end

function class:lightDown(unit,num)
    if num > self.CRYSTAL_NUM then
        return;
    end

    if self.crystalDBuffs[num] ~= nil then
        self.crystalDBuffs[num].action(self,unit);
        --self.crystalDBuffs[num] = nil;
    end

    if self.crystals[num].state == self.CRYSTAL_STATES.active then
        self.crystals[num].switchState(self,self.crystals[num],self.CRYSTAL_STATES.deactive);
    end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効

    --麻痺状態で玉消し
    local cond = event.unit:getTeamUnitCondition():findConditionWithType(91); --麻痺
    if cond ~= nil and self.crystalCounter > 0 and not self.isStun then
        self.isStun = true;
        self:lightDown(event.unit,self.crystalCounter);
        self:execAddBuff(event.unit, self.BUFF_BOX_LIST[1]);
        self:execAddBuff(event.unit, self.BUFF_BOX_LIST[2]);
        self.crystalCounter = self.crystalCounter - 1;
    end

    return 1
end

---------------------------------------------------------------------------------
-- extraTimerOneRound
---------------------------------------------------------------------------------
function class:extraTimerOneRound(event)
    return event.count
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end

    if event.spineEvent == "crystalActionEnd" then self:crystalStateEnd(event.unit) end
    if event.spineEvent == "skill2Start" then self:skill2Start() end
    if event.spineEvent == "skill2Compleat" then self:skill2Compleat() end
    return 1;
end

function class:crystalStateEnd(unit)
    for i=1,self.CRYSTAL_NUM do
        if self.crystals[i].orbit == unit then
            self.crystals[i].endState(self,self.crystals[i]);
            return;
        end
    end
end

function class:skill2Start()
    self.crystalExcutionFlg = true;
    self:excutionCrystals();
end

function class:skill2Compleat()
    self.crystalExcutionFlg = false;
    -- self.crystalCounter = 0;
    self:restertCrystals();
end

function class:excutionCrystals()
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.out);
    end
end

function class:restertCrystals()
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.start2);
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

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    end

    self.isStun = false;

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

    if event.index == 1 then
        self:showMessage(self.SKILL5_MESSAGE_LIST)
        self:execAddBuff(event.unit,self.RAID_BUFF_BOX[1])
        self:addBlindResistDown()

        -- 玉点灯
        self.crystalCounter = self.crystalCounter + 1;
        if self.crystalCounter > self.CRYSTAL_NUM then
            self.crystalCounter = self.CRYSTAL_NUM;
        else
            self:lightUp(event.unit,self.crystalCounter);
        end
    end

    if event.index == 2 then
        self:showMessage(self.SKILL6_MESSAGE_LIST)
        self.skill6Count = self.skill6Count + 1
        self:addRandomDBuff()
    end

    self.isStun = false;

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

-- 暗闇耐性ダウン付与
function class:addBlindResistDown()
    ---庇うユニットが居るか確認
    local target = nil
    local loopNum = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            loopNum = loopNum + 1
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                target = cond:getProtectTarget()
            end
        end
    end
    if target ~= nil then
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getIndex() == target then
                    for l = 1,loopNum do
                        self:execAddBuff(teamUnit, self.BUFF_BOX_LIST[3]);
                        self:execAddBuff(teamUnit, self.BUFF_BOX_LIST[4]);
                    end
                end
            end
        end
    else
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                self:execAddBuff(teamUnit, self.BUFF_BOX_LIST[3]);
                self:execAddBuff(teamUnit, self.BUFF_BOX_LIST[4]);
            end
        end
    end
end

-- ランダムにデバフ効果
function class:addRandomDBuff()

    -- ランダムデバフをつける回数を決める
    local loopCount = 0
    if self.skill6Count <= 1 then
        loopCount = 1
    elseif self.skill6Count <= 3 then
        loopCount = 2
    elseif self.skill6Count <= 10 then
        loopCount = 3
    else
        loopCount = 4
    end

    ---庇うユニットが居るか確認
    local target = nil
    local loopNum = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,3 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            loopNum = loopNum + 1
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                target = cond:getProtectTarget()
            end
        end
    end

    if target ~= nil then
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                if teamUnit:getIndex() == target then
                    -- ランダムデバフをつける回数
                    for j = 1,loopCount do
                        -- 庇う人数分
                        for l = 1,loopNum do
                            self:addRandomDBuffexecute(teamUnit)
                        end
                    end
                end
            end
        end
    else
        for i = 0,3 do
            local teamUnit = myTeam:getTeamUnit(i);
            if teamUnit ~= nil then
                -- ランダムデバフをつける回数
                for j = 1,loopCount do
                    self:addRandomDBuffexecute(teamUnit)
                end
            end
        end
    end
end

function class:addRandomDBuffexecute(unit)
    local buffid = 0
    local bufficon = 0
    local valueCalc = self.GD.skill6BuffBaseValue + self.skill6Count * self.GD.skill6BuffRateValue
    local rand = Random.range(1,7)--1~6までの数値
    if rand == 1 then
        -- 最大HPダウン
        buffid = 2
        bufficon = 2
    elseif rand == 2 then
        -- 攻撃力ダウン
        buffid = 13
        bufficon = 4
    elseif rand == 3 then
        -- 装備CTダウン
        buffid = 30
        bufficon = 183
    elseif rand == 4 then
        -- 被回復量ダウン
        buffid = 126
        bufficon = 162
    elseif rand == 5 then
        -- スキルCTダウン
        buffid = 29
        bufficon = 8
    else
        -- 防御力ダウン
        buffid = 15
        bufficon = 6
    end
    local BUFF_LIST = {
        ID = 0,
        BUFF_ID = buffid,
        VALUE = valueCalc,
        DURATION = 999999,
        ICON = bufficon,
        --COUNT = self.friendElement,
        --MAX = 10
    }
    if valueCalc ~= 0 then
        self:execAddBuff(unit,BUFF_LIST)
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

    --暗闇状態で軽減
    local cond = enemyUnit:getTeamUnitCondition():findConditionWithType(93);
    if cond ~= nil then
        event.value = event.value * self.GD.blindTakeDamageValue
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


class:publish();

return class;