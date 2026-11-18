local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="21章HARDクエスト_天魔帥ゼ＝レムナ", version=1.3, id=2104015});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50},
        { ATTACK1 = 50,ATTACK2 = 50,ATTACK3 = 50},
        { ATTACK4 = 50}
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL13 = 50 }
    },
    HP0 = {
        { SKILL12 = 50 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL10 = 5,
    SKILL12 = 6,
    SKILL13 = 7,
    SKILL14 = 8
}

class.cutInSkill = {
    [3] = 1,
    [4] = 1
}


--------[[バフ]]--------
function class:setBuffBoxList()
    self.STUN_BUFF_LIST = {
        [1] = {
            ID = 01,
            BUFF_ID = 89,  --気絶効果
            VALUE = 100,
            DURATION = 99999,
            ICON = 79
        },
        [2] = {
            ID = 01,
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
            ID = 02,
            BUFF_ID = 129,  --継続ダメージ
            VALUE = 2,
            DURATION = 99999,
            ICON = 180,
            SCRIPT = {
                SCRIPT_ID = 228
            }
        },
        [2] = {
            ID = 02,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        }
    }
    self.BUFF_LIST = {
        [1] = {
            ID = 001,
            BUFF_ID = 23,  --クリティカル耐性
            VALUE = -150,
            DURATION = 99999,
            ICON = 188
        },
        [2] = {
            ID = 002,
            BUFF_ID = 89,  --気絶効果
            VALUE = 100,
            DURATION = 10,
            ICON = 79
        },
        [3] = {
            ID = 003,
            BUFF_ID = 13,  --攻撃力DOWN
            VALUE = -80,
            DURATION = 10,
            ICON = 4
        }
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 05,
        BUFF_ID = 23,---被クリティカル率
        VALUE = 100,
        DURATION = 99999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 05,
        BUFF_ID = 0,---被クリティカル率
        VALUE = 0,
        DURATION = 99999,
        ICON = 0
    }
    self.AURA_BUFF_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
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
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1  or "今宵、天魔の贄となれ",
                                   COLOR = Color.magenta}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性"}),
        [3] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "ダメージの大きい者をターゲット"}),
        [4] = self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ターゲットへのクリティカル率アップ"})
    }
    self.LOCK_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.LOCK_MESSAGE1 or "をロック",
                                   COLOR = Color.red})
    }
    self.EXTRA_GAUGE_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.EXTRA_GAUGE_MESSAGE1 or "物理ダメージでロック解除",
                                   COLOR = Color.red}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.EXTRA_GAUGE_MESSAGE2 or "物理ダメージ蓄積によりロック状態を解除！",
                                   COLOR = Color.red}),
    }
    self.HP_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.HP_MESSAGE_LIST1 or "この闇に果てはない",
                                   COLOR = Color.magenta}),
        [2] = self:setMessageInfo({MESSAGE = self.TEXT.HP_MESSAGE_LIST2 or "奥義増加量・クリティカル耐性アップ"}),
        [3] = self:setMessageInfo({MESSAGE = self.TEXT.HP_MESSAGE_LIST3 or "我が夜が、終わる……",
                                   COLOR = Color.magenta}),
    }
    self.SKILL_MESSAGE_LIST = {
        [1] = self:setMessageInfo({MESSAGE = self.TEXT.SKILL_MESSAGE1 or "マグナ・ランス:ダメージ無効化解除"}),
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
            used = false
        }
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

function class:hp0(status)
    if status == "use3" then
        self.gameUnit:setInvincibleTime(10)
        self.gameUnit:setHP(self.halfHPValue)  --最大HPの50%
        self.gameUnit:setAttackDelay(7);---アタックディレイ
        self:initAttackWeight({DEFAULT = 100})
        self:initSkillWeight({HP0 = 100})
        self.spValue = 50;---addSPの量
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.skill4Flg = true
        self:execAddBuff(self.gameUnit,self.BUFF_LIST[1])
        self:execAddBuff(self.gameUnit,self.AURA_BUFF_LIST[1])
        self:showMessage(self.HP_MESSAGE_LIST,1)
        self:showMessage(self.HP_MESSAGE_LIST,2)
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

    ---サブHP表示用
    self.SubHpRate = 0.15---サブバーのHP(最大体力の15%)
    self.subBar = BattleControl:get():createSubBar();
    self.subBar:setWidth(200); ---バーの全体の長さを指定
    self.subBar:setHeight(13);---バーの幅を指定
    self.subBar:setPercent(0); ---バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.SUB_HP = event.unit:getCalcHPMAX() * self.SubHpRate
    self.damage = 0---サブバー表示時のダメージ
    self.subHPRepair = false

    self.gaugeGimmickFlg = true
    self.subBarFlg = false

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnitList = {}
    BattleControl:get():visibleHateTarget(true);
    BattleControl:get():setHateTargetIcon(14);
    event.unit:setEnableHate(true);
    event.unit:updateHateTarget();

    local maxHP = event.unit:getHP()
    self.halfHPValue = maxHP / 2
    self.lockMessageFlg = true
    self.skill3Flg = false
    self.skill4Flg = false
    self.raceTypeTable = {
        [1] = "人族", [2] = "獣族", [3] = "精霊族", [4] = "巨人族",
        [5] = "機族", [6] = "竜族", [7] = "神族", [8] = "魔族"
    }

    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    ---hp100ギミック
    self.gameUnit:addSP(100)
    self.isFury = true
    self:initAttackWeight({DEFAULT = 100})
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:HPTriggersCheck(event.unit)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    if megast.Battle:getInstance():isHost() then
        if self.subBarFlg then
            self:subBarControll(event.unit,self.damage);---サブバー表示
            megast.Battle:getInstance():sendEventToLua(self.scriptID,8,1)
        else
            self.subBar:setVisible(false);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,8,2)
        end
    end

    self:phantasmLockUpdate()
    megast.Battle:getInstance():sendEventToLua(self.scriptID,8,0)

    ---バックループ防止
    local x = event.unit:getPositionX();
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local unitPosition = myTeamUnit:getPositionX();
            if x >= unitPosition then
                myTeamUnit:setPositionX(myTeamUnit:getPositionX() + 50)
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
    ---ゲージ量を全回復
    if self.subHPRepair then
        self.subHPRepair = false
        if megast.Battle:getInstance():isHost() then
            self:showMessage(self.EXTRA_GAUGE_MESSAGE_LIST,1)
            megast.Battle:getInstance():sendEventToLua(self.scriptID,8,3)
        end
    end
    ---ゲージ量を指定
    self.subBar:setPercent(100 * (self.SUB_HP - damage)/self.SUB_HP);
    ---ゲージ0%になった場合の処理
    if self.SUB_HP - damage <= 0 then
        self.damage = 0
        self.subHPRepair = true
        self.subBarFlg = false
        if megast.Battle:getInstance():isHost() then
            self:showMessage(self.EXTRA_GAUGE_MESSAGE_LIST,2)
            megast.Battle:getInstance():sendEventToLua(self.scriptID,8,3)
        end
        self.isRage = true
        self.gameUnit:addSP(100)
        self:execAddBuff(unit,self.BUFF_LIST[2])

        ---ユニットのダメージをテーブル初期化
        self.targetUnitList = {}
        ---ヘイトリセット
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                myTeamUnit:resetHate()
                megast.Battle:getInstance():sendEventToLua(self.scriptID,7,i);
            end
        end
        self.gameUnit:updateHateTarget();

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

function class:receive7(args)
    megast.Battle:getInstance():getTeam(true):getTeamUnit(args.arg):resetHate()
    return 1
end

function class:receive8(args)
    if args.arg == 1 then
        self.subBarFlg = true
        self:subBarControll(self.gameUnit,self.damage);---サブバー表示
    elseif args.arg == 2 then
        self.subBarFlg = false
        self.subBar:setVisible(false);
    elseif args.arg == 3 then
        if self.subHPRepair then
            self:showMessage(self.EXTRA_GAUGE_MESSAGE_LIST,1)
        else
            self:showMessage(self.EXTRA_GAUGE_MESSAGE_LIST,2)
            self.damage = 0
            self.isRage = true
            self.gameUnit:addSP(100)
            self:execAddBuff(self.gameUnit,self.BUFF_LIST[2])
            self:initPhantasmLock()
        end
    end
    self:phantasmLockUpdate()
    return 1
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

    if event.index == 10 then
        self.gameUnit:setInvincibleTime(5)
        event.unit:setNextAnimationName("attack6")
        event.unit:setNextAnimationEffectName("1-attack6")
        self:deBuffRefresh(event.unit)  --状態異常全回復
        self.skill1FLG = true
        self.isRage = false
        self.gameUnit:addSP(40)
        self.saveBP = self.gameUnit:getBurstPoint()

    elseif event.index == 12 then
        self.gameUnit:setInvincibleTime(6)
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName("1-skill1")
        self:showMessage(self.SKILL_MESSAGE_LIST,1)
        self.isFury = false

    elseif event.index == 13 then
        self.gameUnit:setInvincibleTime(5)
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("1-skill2")
        event.unit:setBurstPoint(40)
        if megast.Battle:getInstance():isHost() then
            self.skill3Flg = false
            self.subBarFlg = true
            self.subHPRepair = true
            self.lockMessageFlg = true
            self:phantasmLock()
            megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0)
        end

    elseif event.index == 14 then
        self.gameUnit:setInvincibleTime(8)
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("1-skill3")
        self.skill4Flg = false
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
        skillIndex = 10
    elseif self.isFury then
        skillIndex = 12
    elseif self.skill3Flg then
        skillIndex = 13
    elseif self.skill4Flg then
        skillIndex = 14
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


function class:phantasmLock()
    ---ターゲットユニット
    self.gameUnit:updateHateTarget();
    local targetUnit = self.gameUnit:getHateTarget();
    local targetIndex = targetUnit:getIndex()
    local targetRace = targetUnit:getRaceType()

    local myTeam = megast.Battle:getInstance():getTeam(true);
    local count = 0

    ---ターゲットユニットを優先
    if targetUnit ~= nil then
        for i = 1,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if self.phantasmTable[targetIndex] == false then
                    self:phantasmLockBuff(targetIndex)
                    self:changeHateTarget(targetUnit)
                    --megast.Battle:getInstance():sendEventToLua(self.scriptID,5,targetIndex);
                    count = 100
                end
                ---ターゲットユニットと同じ種族のユニットも対象にする
                for l = 0,3 do
                    local rTeamUnit = myTeam:getTeamUnit(l)
                    if rTeamUnit ~= nil then
                        local unitRace = rTeamUnit:getRaceType()
                        if targetRace == unitRace then
                            if self.phantasmTable[l] == false then
                                self:phantasmLockBuff(l)
                                self:changeHateTarget(rTeamUnit)
                                --megast.Battle:getInstance():sendEventToLua(self.scriptID,5,l);
                            end
                        end
                    end
                end
                break;
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
        if self.lockMessageFlg then
            self.lockMessageFlg = false
            local raceIndex = myTeamUnit:getRaceType()
            self:execShowFixedMessage(self.LOCK_MESSAGE_LIST[1],self.raceTypeTable[raceIndex])
        end
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

function class:changeHateTarget(targetUnit)
    local enemyUnit = self:getAncestorUnit(targetUnit)
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    self.targetUnitList = {}
    for i = 0,3 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if self.targetUnitList[index] == nil then
                table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = 0})
            else
                self.targetUnitList[index].dps = 0  --ロックするユニットの蓄積ダメージリセット
            end
        end
    end

    ---ホストのみ---
    if megast.Battle:getInstance():isHost() then
        ---ヘイトは全部手動で設定する
        local target = self:checkTargetUnit()
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex())---ゲストにターゲットを送る
        self.gameUnit:setHateTarget(target)
        self.gameUnit:updateHateTarget();
        ---ターゲットにバフ
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if i == target:getIndex() then
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
                else
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
                end
            end
        end
    end

    targetUnit:resetHate()
end

function class:receive5(args)
    self.skill3Flg = false
    self.subBarFlg = true
    self.subHPRepair = true
    self.lockMessageFlg = true
    self:phantasmLock()
    return 1
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
                self:execAddBuff(myTeamUnit,self.BUFF_LIST[3])
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
    if self.subBarFlg then
        local attribute = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute == 1 then
            self.damage = self.damage + event.value  ---サブHPバー用ダメージ
        end
        event.value = event.value * 0.02
    end

    ---ユニットのダメージをテーブルに格納
    local enemyUnit = self:getAncestorUnit(event.enemy)
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
    if self.targetUnitList[index] == nil then
        table.insert(self.targetUnitList,index,{unit = enemyUnit,dps = event.value})
    else
        self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value
    end
    ---ホストのみ---
    if megast.Battle:getInstance():isHost() then
        ---ヘイトは全部手動で設定する
        local target = self:checkTargetUnit()
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,target:getIndex())---ゲストにターゲットを送る
        event.unit:setHateTarget(target)
        event.unit:updateHateTarget();

        ---ターゲットにバフ
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,3 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if i == target:getIndex() then
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST1)
                else
                    self:execAddBuff(myTeamUnit,self.TARGET_BUFF_LIST0)
                end
            end
        end
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
        return self:calcDamageValue(unit,stopBorder,value)
        end
    end
    return value
end

function class:calcDamageValue(unit,border,value)
    self.breakSkip = true
    return unit:getHP() - border + 1
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
    return target
end

---ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
end

function class:receive6(args)
    ---ヘイトは全部手動で設定する
    local myTeam = megast.Battle:getInstance():getTeam(true);
    local target = myTeam:getTeamUnit(args.arg)
    self.gameUnit:setHateTarget(target)
    self.gameUnit:updateHateTarget();
    return 1
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

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:showMessage(self.HP_MESSAGE_LIST,3)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self:showMessage(self.HP_MESSAGE_LIST,3)
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