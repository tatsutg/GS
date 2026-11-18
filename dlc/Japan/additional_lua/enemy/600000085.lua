local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="レイド_天魔帥ゼ＝レムナ", version=1.3, id=600000085});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK4 = 50},
        { ATTACK1 = 50,ATTACK2 = 50},
        { ATTACK1 = 50,ATTACK3 = 50},
        { ATTACK2 = 50,ATTACK3 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 50 },
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
    SKILL3 = 7
}

class.cutInSkill = {
}


--------[[バフ]]--------
function class:setBuffBoxList()
    self.STUN_BUFF_LIST = {
        [1] = {
            ID = 60008501,
            BUFF_ID = 89,  --気絶効果
            VALUE = 100,
            DURATION = 99999,
            ICON = 79
        },
        [2] = {
            ID = 60008501,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [3] = {
            ID = 0,
            BUFF_ID = 89,  --気絶効果
            VALUE = 100,
            DURATION = 3,
            ICON = 79
        }
    }
    self.DAMAGE_BUFF_LIST = {
        [1] = {
            ID = 60008502,
            BUFF_ID = 129,  --継続ダメージ
            VALUE = 2,
            DURATION = 99999,
            ICON = 180,
            SCRIPT = {
                SCRIPT_ID = 228
            }
        },
        [2] = {
            ID = 60008502,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }
    self.BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 13,  --攻撃力割合
            VALUE = -80,
            DURATION = 10,
            ICON = 4
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
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "暗闇・病気状態のとき被ダメージアップ、行動頻度ダウン"}),
        [3] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "編成の右側3体を優先してロック"})
    }
    self.LOCK_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.LOCK_MESSAGE1 or "をロック：一定ダメージでロック解除",
                                   COLOR = Color.red})
    }
    self.BREAK_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ダメージ蓄積によりロック状態を解除！",
                                   COLOR = Color.red}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.BREAK_MESSAGE2 or "必要ダメージ蓄積量増加",
                                   COLOR = Color.red}),
    }
    self.SUB_HP_REPAIA_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.SUB_HP_REPAIA_MESSAGE_LIST1 or "病気耐性アップ"}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.SUB_HP_REPAIA_MESSAGE_LIST2 or "暗闇耐性アップ"}),
        [3] = self:setMessageInfo({MESSAGE = self.TEXT.SUB_HP_REPAIA_MESSAGE_LIST3 or "クリティカル耐性アップ"})
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
        end
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 20;---addSPの量
    event.unit:setAttackDelay(8);---アタックディレイ
    --event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.afterSkillFLG = false;

    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.isRage = false
    self.isFury = false
    self.isDead = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)

    self.stateName = "NORMAL"

    self.breakSkip = true
    self.saveBP = 0
    self.breakFLG = false
    self.skill1FLG = false
    self.phantasmTable = {}
    self.loopCheck = 0
    self.LookUnitIdTable = {}
    self.positionTableX = {}
    self.positionTableY = {}

    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self.phantasmTable[i] = false
            self.LookUnitIdTable[i] = myTeamUnit:getUnitID()
        end
    end

    self.deBuffFlg = false
    self.changeDelayFlg = false
    self.reStartCount = 0
    self.SubHpRate = 0.07---サブバーのHP(最大体力の7%)

    ---サブHP表示用
    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = event.unit:getCalcHPMAX() * self.SubHpRate
    self.damage = 0---サブバー表示時のダメージ
    self.subHPRepair = false

    --self.hpPercent1 = self.SUB_HP * 0.50---サブバーのHP(50%)
    self.gaugeGimmickFlg = true
    self.subBarFlg = true

    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    self:subBarControll(event.unit,self.damage);---サブバー表示

    if self:findBadCondition(event.unit) then
        self.deBuffFlg = true
        self.changeDelayFlg = true
        if self.changeDelayFlg then event.unit:setAttackDelay(9) end
    else
        self.deBuffFlg = false
        if self.changeDelayFlg then
            event.unit:setAttackDelay(8)
        end
        self.changeDelayFlg = false
    end

    self:phantasmLockUpdate()
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    return 1
end

---サブHP表示
function class:subBarControll(unit,damage)
    ---位置を指定
    self.subBar:setPositionX(unit:getPositionX());
    self.subBar:setPositionY(unit:getPositionY());
    self.subBar:setVisible(true);
    ---ゲージ量を全回復
    if self.subHPRepair then
        self.gaugeGimmickFlg = true
        unit:setBurstPoint(40)
        self.reStartCount = self.reStartCount + 1
        self:setBuffList()
        self:setReStartInfo()
        self.subHPRepair = false
        if self.SubHpRate < 0.11 then
            self.SubHpRate = self.SubHpRate + 0.01
            self.SUB_HP = unit:getCalcHPMAX() * self.SubHpRate
        end
        self:showMessage(self.BREAK_MESSAGE_LIST,1)
        if self.reStartCount < 6 then
            self:showMessage(self.BREAK_MESSAGE_LIST,2)
        end
    end
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage)/self.SUB_HP);
    ---ゲージ0%になった場合の処理
    if self.SUB_HP - damage <= 0 then
        if self.gaugeGimmickFlg then
            self.gaugeGimmickFlg = false
            self:deBuffRefresh(unit)  --状態異常全回復
            self.gameUnit:addSP(100)
            self.isRage = true

            ---ファンタズムロック初期化
            local myTeam = megast.Battle:getInstance():getTeam(true);
            for i = 0,6 do
                local myTeamUnit = myTeam:getTeamUnit(i)
                if myTeamUnit ~= nil then
                    if self.phantasmTable[i] ~= nil then
                        if self.phantasmTable[i] then
                            break;
                        end
                    end
                end
            end
            self:initPhantasmLock()
        end
    end
end

function class:deBuffRefresh(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97};
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

function class:findBadCondition(unit)
    local cnt = 1;
    local badStatusList = {
        93,  --暗黒効果
        94,  --病気効果
        131  --ナイトメア
    }
    for cnt,v in pairs(badStatusList) do
        if unit:getTeamUnitCondition():findConditionValue(v) > 0 then
            return true;
        end
    end
    return false;
end

function class:phantasmLockUpdate()
    local count = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if self.phantasmTable[i] ~= nil then
                --ユニットIDが変わっていたらロックを外す
                local unitID = myTeamUnit:getUnitID()
                if self.LookUnitIdTable[i] ~= unitID then
                    self.phantasmTable[i] = false
                    self.LookUnitIdTable[i] = unitID
                    self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[2])
                    self:execAddBuff(myTeamUnit,self.DAMAGE_BUFF_LIST[2])
                    myTeamUnit:takeGrayScale(1);
                end

                if self.phantasmTable[i] then
                    count = count + 1
                    self:itemCtReset(myTeamUnit)
                    myTeamUnit:getNormalSkill():resetCooltime()
                    myTeamUnit:setBurstPoint(0)
                    self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[1])
                    self:execAddBuff(myTeamUnit,self.DAMAGE_BUFF_LIST[1])
                    myTeamUnit:setPosition(self.positionTableX[i],self.positionTableY[i])
                else
                    myTeamUnit:takeGrayScale(1);
                end
            end
        else
            if self.phantasmTable[i] ~= nil then
                self.phantasmTable[i] = false
            end
        end
    end
    return 1;
end

function class:itemCtReset(target)
    for n = 0,2 do
        local item = target:getItemSkill(n)
        if item ~= nil then
            item:resetCooltime()
        end
    end
end

function class:initPhantasmLock()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self.phantasmTable[i] = false
            self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[2])
            self:execAddBuff(myTeamUnit,self.DAMAGE_BUFF_LIST[2])
            myTeamUnit:takeGrayScale(1);
        end
    end
end

function class:setBuffList()
    local BUFF_LIST1 = {
        ID = 600008520,
        BUFF_ID = 56,  --暗闇耐性
        VALUE = 100,
        DURATION = 999999,
        ICON = 62
    }
    local BUFF_LIST2 = {
        ID = 600008521,
        BUFF_ID = 105,  --暗闇回避率
        VALUE = 100,
        DURATION = 999999,
        ICON = 0
    }
    local BUFF_LIST3 = {
        ID = 600008522,
        BUFF_ID = 57,  --病気耐性
        VALUE = 100,
        DURATION = 999999,
        ICON = 63
    }
    local BUFF_LIST4 = {
        ID = 600008523,
        BUFF_ID = 106,  --病気回避率
        VALUE = 100,
        DURATION = 999999,
        ICON = 0
    }
    local BUFF_LIST5 = {
        ID = 600008524,
        BUFF_ID = 23,  --クリティカル耐性
        VALUE = -100,
        DURATION = 999999,
        ICON = 188
    }

    if self.reStartCount == 1 then
        self:execAddBuff(self.gameUnit,BUFF_LIST3)
        self:execAddBuff(self.gameUnit,BUFF_LIST4)
    elseif self.reStartCount == 2 then
        self:execAddBuff(self.gameUnit,BUFF_LIST1)
        self:execAddBuff(self.gameUnit,BUFF_LIST2)
    elseif self.reStartCount == 3 then
        self:execAddBuff(self.gameUnit,BUFF_LIST5)
    end
end

function class:setReStartInfo()
    local count = self.reStartCount
    if count >= 4 then count = 3 end
    self:showMessage(self.SUB_HP_REPAIA_MESSAGE_LIST,count)
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if not self.afterSkillFLG then
        if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    end
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

    if event.index == 3 then
        event.unit:setNextAnimationName("attack4");
        event.unit:setNextAnimationEffectName("1-attack4")
    elseif event.index == 4 then
        event.unit:setNextAnimationName("attack5");
        event.unit:setNextAnimationEffectName("1-attack5")
    end

    self.fromHost = false;
    if self.afterSkillFLG then
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self.afterSkillFLG = false
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
        ---生存ユニットが全員ロック状態の場合強制敗北
        local myTeam = megast.Battle:getInstance():getTeam(true);
        local FLG = false
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if not self.phantasmTable[i] then
                    FLG = true
                end
            end
        end
        if not FLG then
            event.unit:setNextAnimationName("idle");
            event.unit:setNextAnimationEffectName("1-skill2")
            self:initPhantasmLock()
            for n = 0,7 do
                local nTeamUnit = myTeam:getTeamUnit(n);
                if nTeamUnit ~= nil then
                    self:removeConditionAll(nTeamUnit,83)
                end
            end
            self:allDead()
        end
        if self.isDead == true then
            event.unit:setHP(0)
        end
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

function class:allDead()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:setHP(0)
            myTeamUnit:getTeam():deadUnit(myTeamUnit:getIndex());
        end
    end
end

----// takeIdle //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.afterSkillFLG then
        self.gameUnit:setInvincibleTime(0)
    end
    return 1;
end

----// takeBack //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeBack(event)
    if self.afterSkillFLG then
        self.gameUnit:setInvincibleTime(0)
    end
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
        self.gameUnit:setInvincibleTime(5)
        event.unit:setNextAnimationName("attack6")
        event.unit:setNextAnimationEffectName("1-attack6")
        self.skill1FLG = true
        self.subHPRepair = true
        self.damage = 0
        self.isRage = false

    elseif event.index == 2 then
        self.gameUnit:setInvincibleTime(6)
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("1-skill1")
        self:takeSkill2Debuff()
        self.isFury = false

    elseif event.index == 3 then
        self.gameUnit:setInvincibleTime(8)
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("1-skill2")
        if megast.Battle:getInstance():isHost() then
            self:phantasmLock()
        end
    end

    self.skillCheckFlg = false;
    self.afterSkillFLG = true;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()

    if self.isRage then
        skillIndex = 1
    elseif self.isFury then
        skillIndex = 2
    elseif self.isDead then
        skillIndex = 3
    else
        if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_SKILL.actCount,7,Color.magenta); end
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end

    if self.cutInSkill[skillIndex] ~= nil then
        unit:takeSkillWithCutin(tonumber(skillIndex),self.cutInSkill[skillIndex]);
    else
        unit:takeSkill(tonumber(skillIndex));
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,skillIndex);
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

function class:takeSkill2Debuff()
    local buffValue = 15
    local buffCount = 0
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(60008510)
            if buff == nil then
                buffCount = 0
            else
                buffCount = buff:getNumber()
            end
            if buffCount < 10 then
                buffCount = buffCount + 1
                self:addDebuff(buffCount,myTeamUnit,buffValue)
            end
        end
    end
end

function class:addDebuff(count,target,buffValue)
    local BUFF_LIST = {
        ID = 60008510,
        BUFF_ID = 21,  --被ダメUP
        VALUE = buffValue * count,
        DURATION = 999999,
        ICON = 139,
        COUNT = count,
        MAX = 11  --MAX表示は10
    }
    self:buffRefresh(target)
    self:execAddBuff(target,BUFF_LIST)
end

function class:buffRefresh(unit)
    local badStatusIDs = {60008510};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithID(targetID);
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

function class:phantasmLock()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local count = 0
    ---庇うユニットがいる場合
    for i = 0,7 do
        local teamUnit = myTeam:getTeamUnit(i);
        if teamUnit ~= nil then
            local cond = teamUnit:getTeamUnitCondition():findConditionWithType(128);
            if cond ~= nil then
                local target = cond:getProtectTarget()
                if self.phantasmTable[target] == false then
                    count = 100
                    self:phantasmLockBuff(target)
                    megast.Battle:getInstance():sendEventToLua(self.scriptID,5,target);
                    break;
                end
            end
        end
    end
    local FLG = true
    ---右側3体を優先
    for i = 1,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if self.phantasmTable[i] ~= nil then
                ---右3体生存ユニットにロック状態でないものがいる場合
                if not self.phantasmTable[i] then
                    FLG = false
                    break;
                end
            end
        end
    end
    ---庇うユニットがいない場合
    while count < 100 do
        count = count + 1
        local rand = LuaUtilities.rand(1,4)
        if FLG then rand = 0 end
        if self.phantasmTable[rand] ~= nil then
            if self.phantasmTable[rand] == false then
                count = 100
                self:phantasmLockBuff(rand)
                megast.Battle:getInstance():sendEventToLua(self.scriptID,5,rand);
            end
        end
    end
    return 1;
end

function class:phantasmLockBuff(rand)
    ---ターゲットにロック状態バフなど付与
    local myTeam = megast.Battle:getInstance():getTeam(true);
    self.phantasmTable[rand] = true
    local myTeamUnit = myTeam:getTeamUnit(rand)
    if myTeamUnit ~= nil then
        myTeamUnit:takeGrayScale(0.1);
        self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[1])
        self:execAddBuff(myTeamUnit,self.DAMAGE_BUFF_LIST[1])
        self:execShowFixedMessage(self.LOCK_MESSAGE_LIST[1],myTeamUnit:getUnitName())
        self:lockPosition(self.gameUnit,myTeamUnit)
    end
    ---全体から庇うを解除
    for n = 0,7 do
        local nTeamUnit = myTeam:getTeamUnit(n);
        if nTeamUnit ~= nil then
            self:removeConditionAll(nTeamUnit,128)
        end
    end
end

function class:lockPosition(unit,target)
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    target:setPosition((x + 480 + math.random(-50,50)),(y + math.random(-50,50)))
    self.positionTableX[target:getIndex()] = target:getPositionX();
    self.positionTableY[target:getIndex()] = target:getPositionY();
    return 1
end

function class:receive5(args)
    --self:phantasmLockBuff(args.arg)
    return 1
end

function class:removeConditionAll(myTeamUnit,condType)
    local count = 1
    while count > 0 do
        count = 0
        if myTeamUnit ~= nil then
            if myTeamUnit:getTeamUnitCondition():findConditionWithType(condType) ~= nil then
                myTeamUnit:getTeamUnitCondition():removeCondition(myTeamUnit:getTeamUnitCondition():findConditionWithType(condType))
                count = count + 1
                self.loopCheck = self.loopCheck + 1
                if self.loopCheck >= 100 then
                    self.loopCheck = 0
                    break
                end
            end
        end
    end
    self.loopCheck = 0
end

----// attackDamageValue //-----------------------------------------------------------------------------
-- 条件 : 本体の攻撃Hit時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃対象  event.value / 与ダメージ量
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    self:phantasmLockUpdate()
    if self.skill1FLG then
        self.skill1FLG = false
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                self:execAddBuff(myTeamUnit,self.STUN_BUFF_LIST[3])
                self:execAddBuff(myTeamUnit,self.BUFF_LIST[1])
                myTeamUnit:setPositionX(myTeamUnit:getPositionX() + 1000)
            end
        end
    end
    return event.value
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.deBuffFlg then
        event.value = event.value * 2
    end
    event.value = self:adjustHpFlg(event.unit,event.value)
    self.damage = self.damage + event.value  ---サブHPバー用ダメージ
    return event.value
end

function class:adjustHpFlg(unit,value)
    local anotherHp = unit:getHP() - value
    for _,trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit) ---停止系状態異常除去(このタイミングでないとたまにバグる)
        return self:calcDamageValue(unit,stopBorder,value)
        end
    end

    return value
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true
    return unit:getHP() - border + 1
end

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    event.value = event.value * 0.2
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
    self:phantasmLockUpdate()
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

function class:execShowFixedMessage(messageBox,str)
    local fixedMessage = str..messageBox.MESSAGE
    summoner.Utility.messageByEnemy(fixedMessage,messageBox.DURATION,messageBox.COLOR);
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

    self.TRIGGERS[index].used = true
    self.TRIGGERS[index].action(action)
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
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    end
    return 1
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
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

function class:removeAllBadstatus(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97};
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