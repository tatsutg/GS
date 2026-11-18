local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="真EX_超シーリア", version=2.0, id=2505022});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    SKILL4 = 5,
    SKILL5 = 6
}

class.cutInSkill = {
    --[5] = 1
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 2505020,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 30,
            ICON = 0
        },
        [2] = {
            ID = 2505021,
            BUFF_ID = 17,
            VALUE = 20,
            DURATION = 99999,
            ICON = 26,
            MAX = 30
        }
    }
    self.BUFF_LIST = {
        [1] = {
            ID = 25050220,
            BUFF_ID = 15, --防御力UP
            VALUE = 15,
            DURATION = 999999,
            ICON = 5,
            COUNT = 0,
            MAX = 4
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "道をあけなさい", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "人族からの被ダメージアップ", COLOR = Color.yellow})
    }
    self.HP100_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP100_MESSAGE1 or "来たれ眷属", COLOR = Color.yellow})
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "来たれ眷属", COLOR = Color.yellow})
    }
    self.HP1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP1_MESSAGE1 or "誓いは万条の光", COLOR = Color.yellow})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "不…覚……！", COLOR = Color.yellow})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp1(status) end,
            HP = 1,
            used = false
        },
    }
    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end

function class:hp50(status)
    if status == "use3" then
        self.gameUnit:addSP(100)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self.hpSkill = 4
    end
end

function class:hp1(status)
    if status == "use3" then
        self.hp1Flg = true
        self.gameUnit:addSP(100)
        self:showMessage(self.HP1_MESSAGE_LIST)
        self.hpSkill = 5
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 10;---addSPの量
    event.unit:setAttackDelay(8);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

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

    self.buffFlg = true
    self.hp1Flg = false
    self.defenceRate = 700000

    ---サブHP表示用
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = self.defenceRate
    self.damage = 0---サブバー表示時のダメージ
    self.subBarFlg = false

    self.orbitHpDefault = 1000
    self.orbit = {}
    self.orbitHp = {}
    self.orbitDamageLv = {}
    for i = 1,4 do
        self.orbit[i] = nil
        self.orbitHp[i] = self.orbitHpDefault
        self.orbitDamageLv[i] = 1
    end
    self.beforeSummon = 1
    self.guardian = 1
    self.skill1FLG = false
    self.skill3FLG = false
    self.inWave = true
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self.inWave = true
    self.gameUnit:addSP(100)
    self.hpSkill = 3
    self:showMessage(self.HP100_MESSAGE_LIST)
    return 1
end

---------------------------------------------------------------------------------
-- endWave
---------------------------------------------------------------------------------
function class:endWave(event)
    self.inWave = false
    self:allDead()
    return 1;
end

function class:allDead()
    for index = 1,5 do
        if self.orbit[index] ~= nil then
            self.orbitHp[index] = 0
            self.orbit[index]:takeAnimation(0,"S_dead",false)
            self.orbit[index] = nil
        end
    end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.hp1Flg and event.unit:getUnitState() == kUnitState_skill then
        self.gameUnit:setInvincibleTime(0.1)
    elseif self.hp1Flg and event.unit:getUnitState() ~= kUnitState_skill then
        self.hp1Flg = false
    end
    
    if self.subBarFlg and event.unit:getUnitState() ~= kUnitState_skill then
        self.subBarFlg = false
        self.subBar:setVisible(false);
    end

    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);---サブバー表示
    end

    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    self:HPTriggersCheck(event.unit)

    ---真奥義→待機
    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
    if self.skill3FLG and event.unit:getUnitState() ~= kUnitState_skill then
        self.skill3FLG = false
        for index = 1,4 do
            if self.orbit[index] ~= nil then
                self.orbit[index]:getSkeleton():setOpacity(255)---透明化解除
                self.orbit[index]:takeAnimation(0,"S_in_d"..self.orbitDamageLv[index]-1,true)
            end
        end
    end
    ---位置調整
    for index = 1,4 do
        if self.orbit[index] ~= nil then
            if self.orbit[index]:getPositionX() > 350 then
                self.orbit[index]:setPositionX(350)
            elseif self.orbit[index]:getPositionX() < -350 then
                self.orbit[index]:setPositionX(-350)
            end
        end
    end
    return 1
end

---サブHP表示
function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage)/self.SUB_HP);
    ---ゲージ0%になった場合の処理
    if self.SUB_HP - damage <= 0 then
        self.subBarFlg = false
        self.subBar:setVisible(false);
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    ---待機処理
    if event.spineEvent == "idle" then
        for index = 1,4 do
            if event.unit == self.orbit[index] then
                event.unit:takeAnimation(0,"S_idle_d"..self.orbitDamageLv[index]-1,true)
            end
        end
    end
    ---スキル→待機
    if event.spineEvent == "idle_skill1" then
        ---削除
        self.orbitHp[5] = 0
        self.orbit[5]:takeAnimation(0,"S_dead",false)
        self.orbit[5] = nil
        --event.unit:takeAnimation(0,"S_idle_d0",true)
        event.unit:setPositionX(event.unit:getPositionX() - (281*event.unit:getFlip()))
    end
    ---スキル召喚
    if event.spineEvent == "skill1summon" then
        if self.orbit[5] ~= nil then
            ---削除
            self.orbit[5]:takeAnimation(0,"S_dead",false)
        end
        self.orbit[5] = event.unit:addOrbitSystem("S_skill1",0);
        self.orbit[5]:takeAnimation(0,"S_skill1",true)
        self.orbitHp[5] = self.orbitHpDefault
        self.orbitDamageLv[5] = 1
    end
    ---真奥義召喚
    if event.spineEvent == "skill3summon" then
        if self.inWave then
            local index = self:summonCheck()
            index = 4
            if self.orbit[index] ~= nil then
                ---削除
                self.orbit[index]:takeAnimation(0,"S_dead",false)
            end
            ---眷属召喚
            self.orbit[index] = event.unit:addOrbitSystem("S_idle_d0",0);
            self.orbit[index]:takeAnimation(0,"S_idle_d0",true)
            self:skill3SetPosition(index)
            self.orbit[index]:getSkeleton():setOpacity(0)---透明化
            self.orbitHp[index] = self.orbitHpDefault
            self.orbitDamageLv[index] = 1
            self.beforeSummon = index

            for i = 1,4 do
                if self.orbit[i] ~= nil then
                    self.orbit[i]:getSkeleton():setOpacity(0)---透明化
                end
            end

            megast.Battle:getInstance():sendEventToLua(self.scriptID,6,1)
        end
    end
    if event.spineEvent == "Library_skill5_sky" then
        event.unit:addOrbitSystem("skill5_sky");
    end
    return 1
end

function class:isHost()
    local bool = false
    if megast.Battle:getInstance():isHost() or megast.Battle:getInstance():isPvpHost() then
        bool = true
    end
    return bool
end

function class:receive5(args)
    local index = self:summonCheck()
    if self.orbit[index] ~= nil then
        ---削除
        self.orbit[index]:takeAnimation(0,"S_dead",false)
    end
    self.orbit[index] = self.gameUnit:addOrbitSystem("S_skill1",0);
    self.orbit[index]:takeAnimation(0,"S_skill1",true)
    self.orbitHp[index] = self.orbitHpDefault
    self.orbitDamageLv[index] = 1
    self.beforeSummon = index
    return 1;
end

function class:receive6(args)
    for index = 1,4 do
        if self.orbit[index] ~= nil then
            ---削除
            self.orbit[index]:takeAnimation(0,"S_dead",false)
        end
        ---眷属召喚
        self.orbit[index] = self.gameUnit:addOrbitSystem("S_idle_d0",0);
        self.orbit[index]:takeAnimation(0,"S_idle_d0",true)
        self:skill3SetPosition(index)
        self.orbit[index]:getSkeleton():setOpacity(0)---透明化
        self.orbitHp[index] = self.orbitHpDefault
        self.orbitDamageLv[index] = 1
        self.beforeSummon = index
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:allDead()
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self:allDead()
    self:showMessage(self.DEAD_MESSAGE_LIST)
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

    if event.index == 2 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("2-skill1") ---EFのアニメーション名に気をつける
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    elseif not self.addSpSkipFLG then
        self:addSP(event.unit);
    end
    -----------------------------------
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

    if event.index == 1 then
        self.skill1FLG = true
    elseif event.index == 2 then
    elseif event.index == 3 then
        if self.inWave and self.buffFlg then
            for index = 1,4 do
                if self.orbit[index] ~= nil then
                    ---削除
                    self.orbit[index]:takeAnimation(0,"S_dead",false)
                end
                ---眷属召喚
                self.orbit[index] = event.unit:addOrbitSystem("S_in_d"..self.orbitDamageLv[index]-1,0);
                self.orbit[index]:takeAnimation(0,"S_in_d"..self.orbitDamageLv[index]-1,true)
                self:skill3SetPosition(index)
                self.orbit[index]:getSkeleton():setOpacity(0)---透明化
                self.orbitHp[index] = self.orbitHpDefault
                self.orbitDamageLv[index] = 1

                self.skill3FLG = true
                self:execAddBuff(event.unit,self.BUFF_LIST[1])
            end
            self.buffFlg = false
            megast.Battle:getInstance():sendEventToLua(self.scriptID,6,1)
        end
    elseif event.index == 4 then
        self.skill3FLG = true
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("2-skill3") ---EFのアニメーション名に気をつける
    elseif event.index == 5 then
        self.subBarFlg = true
        event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_LIST[1].ID)
        for index = 1,5 do
            if self.orbit[index] ~= nil then
                self.orbitHp[index] = 0
                self.orbit[index]:takeAnimation(0,"S_skill5_d"..self.orbitDamageLv[index]-1,false)
                self.orbit[index] = nil
            end
        end
    end

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

function class:skill3SetPosition(index)
    if self.orbit[index] ~= nil then
        if index == 1 then
            self.orbit[index]:setPositionX(self.orbit[index]:getPositionX() - (235*self.gameUnit:getFlip()))
            self.orbit[index]:setPositionY(self.orbit[index]:getPositionY() + 32)
        elseif index == 2 then
            self.orbit[index]:setPositionX(self.orbit[index]:getPositionX() - (153*self.gameUnit:getFlip()))
            self.orbit[index]:setPositionY(self.orbit[index]:getPositionY() + 19)
        elseif index == 3 then
            self.orbit[index]:setPositionX(self.orbit[index]:getPositionX() + (47*self.gameUnit:getFlip()))
            self.orbit[index]:setPositionY(self.orbit[index]:getPositionY() + 19)
        else
            self.orbit[index]:setPositionX(self.orbit[index]:getPositionX() + (132*self.gameUnit:getFlip()))
            self.orbit[index]:setPositionY(self.orbit[index]:getPositionY() + 32)
        end
    end
end

function class:summonCheck()
    local index = 1
    ---空いている場所がある場合はそれを返す
    for i = 1,4 do
        if self.orbit[i] == nil then
            return i
        end
    end
    ---ダメージを受けているオービットがいる場合はそれを返す
    for i = 1,4 do
        if self.orbitHp[i] < self.orbitHpDefault then
            return i
        end
    end
    ---誰もダメージを受けてもいない場合は次の位置を返す
    index = self.beforeSummon + 1
    if index > 4 then
        index = 1
    end
    return index
end

function class:guardianCheck()
    ---ダメージを受けているオービットがいる場合はそれを返す
    for i = 1,4 do
        if self.orbitHp[i] < self.orbitHpDefault and self.orbit[i] ~= nil and self.orbitHp[i] > 0 then
            return i
        end
    end
    ---オービットがいる場合は適当に返す
    for i = 1,4 do
        if self.orbit[i] ~= nil and self.orbitHp[i] > 0 then
            return i
        end
    end
    ---いない場合は0を返す
    return 0
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.subBarFlg then
        self.damage = self.damage + event.value
        return 0
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

function class:receive7(args)
    if self.orbit[args.arg] ~= nil then
        self.orbit[args.arg]:takeAnimation(0,"S_dead",false)
        self.orbit[args.arg] = nil
        --self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
    end
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
            self:execTrigger(index)
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

    self.TRIGGERS[index].action(action)
    self.TRIGGERS[index].used = true
    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

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