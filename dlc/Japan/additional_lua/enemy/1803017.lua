local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="18章彩忍ロゼッタ", version=1.3, id=1803017});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL15 = 100 },
        { SKILL16 = 100 },
        { SKILL15 = 100,SKILL16 = 100 }
    },
    MD1 = {
        { SKILL17 = 100 },
        { SKILL18 = 100 },
        { SKILL17 = 100,SKILL18 = 100 }
    },
    MD2 = {
        { SKILL19 = 100 },
        { SKILL20 = 100 },
        { SKILL19 = 100,SKILL20 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL13 = 3,
    SKILL14 = 4,
    SKILL15 = 5,
    SKILL16 = 6,
    SKILL17 = 7,
    SKILL18 = 8,
    SKILL19 = 9,
    SKILL20 = 10
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 186
        },
        [2] = {
            ID = 2,
            BUFF_ID = 0, ---物理耐性アイコン
            VALUE = 0,
            DURATION = 99999,
            ICON = 21
        },
        [3] = {
            ID = 1,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 222
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
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "ちょっぴり大人になったロゼッタさん、可憐に参上！",
            COLOR = Color.green
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性"
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "HP50%以下のユニットに対してのクリティカル率アップ"
        }),
        [4] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE4 or "暗闇状態のとき被ダメージアップ"
        }),
        [5] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE5 or "水属性キラー"
        })
    }

    self.HP80_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP80_MESSAGE1 or "力ある言葉よ、薙ぎ払え",
            COLOR = Color.green
        })
    }

    self.HP60_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP60_MESSAGE1 or "魂天の紋章よ、星の如く煌け",
            COLOR = Color.green
        })
    }

    self.HP40_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE1 or "我らが王に誓う",
            COLOR = Color.green
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE2 or "紅き血をもって大義をなさん",
            COLOR = Color.green
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP40_MESSAGE3 or "奥義上昇量アップ・物理ダメージ軽減"
        })
    }

    self.HP20_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP20_MESSAGE1 or "もっと深く――血の深淵へ",
            COLOR = Color.green
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP20_MESSAGE2 or "奥義上昇量・クリティカル耐性アップ"
        })
    }

    self.DEAD_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "レオーネ、みんな……ごめん……",
            COLOR = Color.green
        })
    }

    self.SKILL2_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL2_MESSAGE1 or "最大HP%d％の割合ダメージ"
        })
    }

    self.SKILL3_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.SKILL3_MESSAGE1 or "ダメージ無効化解除"
        })
    }

end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp80(status) end,
            HP = 80,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp60(status) end,
            HP = 60,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp40(status) end,
            HP = 40,
            used = false
        },
        [4] = {
            tag = "HP_FLG",
            action = function (status) self:hp20(status) end,
            HP = 20,
            used = false
        }
    }

    self.HP_TRIGGERS = {}
    for index,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.HP_TRIGGERS[index] = trigger
            self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
        end
    end
end


function class:hp80(status)
    if status == "use3" then
        self.isRage = true
        self.saveSP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(20)
        self:showMessage(self.HP80_MESSAGE_LIST)
    end
end

function class:hp60(status)
    if status == "use3" then
        self.isFury = true
        self.saveSP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(20)
        self:showMessage(self.HP60_MESSAGE_LIST)
    end
end

function class:hp40(status)
    if status == "use3" then
        self.gameUnit:setCutinVoice2("VOICE_FULLARTS_CUTIN_B_01")
        self.isMD1 = true
        self.saveSP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(20)
        self:initSkillWeight({MD1 = 100})
        self.modeMD = true
        self.spValue = 40;---addSPの量
        self.gameUnit:setAttackDelay(4);---アタックディレイ
        self:showMessage(self.HP40_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
        self:removeAllBadstatus(self.gameUnit)
        self:antiBadCondition(56)
    end
end

function class:hp20(status)
    if status == "use3" then
        self.isMD2 = true
        self.saveSP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(20)
        self:initSkillWeight({MD2 = 100})
        self.spValue = 50;---addSPの量
        self.gameUnit:setAttackDelay(3);---アタックディレイ
        self:showMessage(self.HP20_MESSAGE_LIST)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[3])
        self:removeAllBadstatus(self.gameUnit)
        self:antiBadCondition(56)
        self.gameUnit:takeHeal(self.gameUnit:getCalcHPMAX() * 0.2)
    end
end

---状態異常耐性---
function class:antiBadCondition(buffID)
    local BUFF_LIST = {
        ID = 0,
        BUFF_ID = buffID,
        VALUE = 10,
        DURATION = 99999,
        ICON = buffID + 6
    }
    local BUFF_LIST2 = {
        ID = 0,
        BUFF_ID = buffID + 49,
        VALUE = 10,
        DURATION = 99999,
        ICON = 0
    }
    self:execAddBuff(self.gameUnit,BUFF_LIST)
    self:execAddBuff(self.gameUnit,BUFF_LIST2)
end


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = 30;---addSPの量
    event.unit:setAttackDelay(5);---アタックディレイ
    event.unit:addSP(40)---戦闘開始時の奥義ゲージ量
    self.rageNum = 15---特殊行動用
    self.furyNum = 16---特殊行動用2
    self.MD1Num = 13---特殊行動用
    self.MD2Num = 14---特殊行動用2
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.cutInFLG = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self.hpMarkers = {}
    self.isRage = false
    self.isFury = false
    self.isMD1 = false
    self.isMD2 = false
    self.isCutIn = false

    self.modeMD = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})
    self:showMessage(self.START_MESSAGE_LIST)
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない

    self.breakSkip = false

    self.bugCheckFLG = false

    self.saveSP = 0

    self.fixedDamage = 0
    self.damageTable = {
        [15] = 0.3,
        [17] = 0.4,
        [19] = 0.6
    }
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    self:HPTriggersCheck(event.unit)

    self:auraPosition(event.unit)
    self:AI_HpSkill(event.unit)
    return 1
end

function class:auraPosition(unit)
    if self.aura == nil then
        return
    end

    local vec = unit:getisPlayer() and 1 or -1
    local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetx,targety);
    self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
    self.aura:setZOrder(unit:getZOrder() + 1)
end

function class:AI_HpSkill(unit)
    if self.AI_SkillFirst == nil then
        self.AI_SkillFirst = true
        self.skillValueBox = {}
        self.skillValueBox[1] = 80
        self.skillValueBox[2] = 60
        self.skillValueSync = {
        }
    end
    ---奥義中か確認
    if unit:getUnitState() == kUnitState_skill then
        ---HPフラグ関係ない奥義の場合、奥義終了まで判定しない
        local flgBuff = unit:getTeamUnitCondition():findConditionWithID(238)
        if flgBuff == nil then
            for i,v in ipairs(self.skillValueBox) do
                if not unit:getIsHpMarkerActive(self.skillValueBox[i] / 100) and self.skillValueBox[i] > 0 then
                    ---特定のHPマーカーが消えていて奥義中の場合
                    local markerValue = self.skillValueBox[i]
                    if self.skillValueSync[i] ~= nil then
                        markerValue = self.skillValueSync[i]
                    end
                    local keyBuff = unit:getTeamUnitCondition():addCondition(238000 + markerValue,0,0,99999,0);
                    keyBuff:setRemoveOnResetState(true);
                    self.skillValueBox[i] = self.skillValueBox[i] * -1
                    break;
                end
            end
            ---判定しないためのフラグ付与
            local newBuff = unit:getTeamUnitCondition():addCondition(238,0,0,99999,0);
            newBuff:setRemoveOnResetState(true);
        end
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "mdStart" then
        if self.TRIGGERS[4].used == false then
            self:setAura(event.unit)
        else
            self:setAura2(event.unit)
        end
    end
    if event.spineEvent == "loopStart" then
        self.aura:takeAnimation(0,"MD_loop",true);
    end
    if event.spineEvent == "loopStart2" then
        self.aura:takeAnimation(0,"MD_loop2",true);
    end
    return 1
end

function class:setAura(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"MD_in",true);
        return
    end
    self.aura = unit:addOrbitSystemWithFile("MD_3","MD_in");
    self.aura:takeAnimation(0,"MD_in",true);
    self:auraPosition(unit)
end

function class:setAura2(unit)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"MD_in2",true);
    end
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    return 1
end

function class:receive4(args)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.fixedDamage = 0
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
        event.unit:setActiveSkill(2)
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        event.unit:addSP(self.saveSP)
        self.saveSP = 0
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

function class:takeIdle(event)
    if self.addSpSkipFLG then
        self.gameUnit:setInvincibleTime(0)
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.fixedDamage = 0
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if event.index >= 15 then
        if not self.cutInFLG and not self.isRage and not self.isFury then
            self.cutInFLG = true;
            event.unit:takeSkillWithCutin(event.index,0);
            return 0
        end
    end

    if event.index == self.rageNum and not self.cutInFLG and self.isRage then
        self.isRage = false
        self.cutInFLG = true;
        event.unit:takeSkillWithCutin(event.index,1);
        return 0;
    end

    if event.index == self.furyNum and not self.cutInFLG and self.isFury then
        self.isFury = false
        self.cutInFLG = true;
        event.unit:takeSkillWithCutin(event.index,1);
        return 0;
    end

    if event.index == self.MD1Num and not self.cutInFLG and self.isMD1 then
        self.isMD1 = false
        self.cutInFLG = true;
        event.unit:takeSkillWithCutin(event.index,1);
        return 0;
    end

    if event.index == self.MD2Num and not self.cutInFLG and self.isMD2 then
        self.isMD2 = false
        self.cutInFLG = true;
        event.unit:takeSkillWithCutin(event.index,1);
        return 0;
    end

    if event.index == 13 then
        event.unit:setNextAnimationName("MD1begin")
        event.unit:setNextAnimationEffectName("empty")
    elseif event.index == 14 then
        event.unit:setNextAnimationName("MD2begin")
        event.unit:setNextAnimationEffectName("empty")
    elseif event.index == 15 or event.index == 17 or event.index == 19 then
        self:showFormatMessages(self.SKILL2_MESSAGE_LIST,self.damageTable[event.index] * 100)
        self.fixedDamage = self.damageTable[event.index]
        if event.index ~= 19 then
            event.unit:setNextAnimationName("bossSkill2")
            event.unit:setNextAnimationEffectName("2-skill2")
        else
            event.unit:setNextAnimationName("bossSkill2_MD2")
            event.unit:setNextAnimationEffectName("skill2_MD2")
        end
    elseif event.index == 16 or event.index == 18 then
        self:showMessage(self.SKILL3_MESSAGE_LIST)
        event.unit:setNextAnimationName("skill3_MD1")
        event.unit:setNextAnimationEffectName("skill3_MD1")
    elseif event.index == 20 then
        self:showMessage(self.SKILL3_MESSAGE_LIST)
        event.unit:setNextAnimationName("skill3_MD2")
        event.unit:setNextAnimationEffectName("skill3_MD2")
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

    if self.isRage then
        skillIndex = self.rageNum
    elseif self.isFury then
        skillIndex = self.furyNum
    elseif self.isMD1 then
        skillIndex = self.MD1Num
    elseif self.isMD2 then
        skillIndex = self.MD2Num
    else
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if self.fixedDamage ~= 0 then
        if self.fixedDamage == -1 then
            return event.value;
        end
        local team = megast.Battle:getInstance():getTeam(true)
        for i = 0,7 do
            local teamUnit = team:getTeamUnit(i);
            if teamUnit ~= nil then
                local damage = ((teamUnit:getCalcHPMAX() * self.fixedDamage))
                local hp = teamUnit:getHP() - damage
                if hp < 0 then hp = 0 end
                local artsHpBefore = teamUnit:getHP()
                teamUnit:setHP(hp)
                -- 【MEGA_D-9756】メッセージログで、この技の行に減った HP を足す（表示だけ。古いアプリには無いので確かめてから呼ぶ）
                if megast.Battle.addArtsDamageToCurrentSkill ~= nil and self.gameUnit ~= nil then
                    megast.Battle:getInstance():addArtsDamageToCurrentSkill(self.gameUnit, teamUnit, artsHpBefore - teamUnit:getHP())
                end
            end
        end
        self.fixedDamage = -1
    end
    return event.value;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.modeMD then
        local attribute = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute;
        if attribute ~= 2 then
            event.value = event.value * 0.1
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
        return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit,stopBorder,value)
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

function class:showFormatMessages(messages,count)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(string.format(v.MESSAGE,count),v.DURATION,v.COLOR);
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