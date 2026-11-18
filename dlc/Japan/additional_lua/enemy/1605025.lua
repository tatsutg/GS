local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="EX化16章イスリーダ皇帝", version=1.3, id=1605025});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK2 = 50 },
        { ATTACK1 = 50 },
        { ATTACK3 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50 }
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL1 = 100 },
        { SKILL2 = 100 },
        { SKILL3 = 100 }
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    SKILL1 = 4,
    SKILL2 = 5,
    SKILL3 = 6,
    SKILL4 = 7,
    SKILL5 = 8,
    SKILL6 = 9
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 16040151,
            BUFF_ID = 32,
            VALUE = -5,
            DURATION = 999999,
            ICON = 15,
            COUNT = 1,
            MAX = 10
        },
        [2] = {
            ID = 16040152,
            BUFF_ID = 21,
            VALUE = 5,
            DURATION = 999999,
            ICON = 139,
            COUNT = 1,
            MAX = 10
        },
        [3] = {
            ID = 16040153,
            BUFF_ID = 129,
            VALUE = 0.1,
            DURATION = 999999,
            ICON = 180,
            COUNT = 1,
            MAX = 10,
            SCRIPT = {
                SCRIPT_ID = 228
            }
        },
        [4] = {
            ID = 0,
            BUFF_ID = 17,
            VALUE = 30,
            DURATION = 99999,
            ICON = 26
        },
        [5] = {
            ID = 0,
            BUFF_ID = 15,
            VALUE = 50,
            DURATION = 99999,
            ICON = 5
        },
        [6] = {
            ID = 0,
            BUFF_ID = 23,
            VALUE = -300,
            DURATION = 99999,
            ICON = 188
        }
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 14050,
        BUFF_ID = 23,---被クリティカル率
        VALUE = 100,
        DURATION = 99999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 14050,
        BUFF_ID = 0,---被クリティカル率
        VALUE = 0,
        DURATION = 99999,
        ICON = 0
    }
    self.ANTI_BAD_CONDITION_BUFF_LIST = {
        ID = 20336541,
        BUFF_ID = 113, ---状態異常耐性(状態異常回避率)
        VALUE = 999999,
        DURATION = 999999,
        ICON = 67
    }
    self.ANTI_BAD_CONDITION_BUFF_LIST2 = {
        ID = 20336541,
        BUFF_ID = 0,
        VALUE = 0,
        DURATION = 0,
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
    return message
end

function class:setMessageBoxList()

    self.TRUE_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.TRUE_MESSAGE1 or "レイアス、覚悟は決まったかい？",
            COLOR = Color.white
        })
    }

    self.FALSE_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.FALSE_MESSAGE1 or "罪は決して消えはしない",
            COLOR = Color.white
        })
    }

    self.START_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性"
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "鉄壁状態：ブレイクで解除"
        })
    }

    self.BREAK_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.BREAK_MESSAGE1 or "僕としたことが……",
            COLOR = Color.white
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.BREAK_MESSAGE2 or "ブレイクで鉄壁状態解除！",
            COLOR = Color.red
        })
    }

    self.TARGET_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.TARGET_MESSAGE1 or "ブレイク耐性アップ"
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.TARGET_MESSAGE2 or "ダメージの大きい者をターゲット"
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.TARGET_MESSAGE3 or "ターゲットへのクリティカル率アップ"
        })
    }

    self.WEAPON_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.WEAPON_MESSAGE1 or "スカイライト：神族の奥義ゲージ低下・全体命中率低下",
            COLOR = Color.red
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.WEAPON_MESSAGE2 or "グランヴィス：人族の奥義ゲージ低下・全体被ダメージ上昇",
            COLOR = Color.red
        }),
        [3] = self:setMessageInfo({
            MESSAGE = self.TEXT.WEAPON_MESSAGE3 or "ダークブリンガー：魔族の奥義ゲージ低下・全体持続ダメージ",
            COLOR = Color.red
        })
    }

    self.HP75_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP75_MESSAGE1 or "烈光の帝剣よ、力を示せ！",
            COLOR = Color.white
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP75_MESSAGE2 or "奥義上昇量・与ダメージアップ"
        })
    }

    self.HP50_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "支配の帝剣よ、力を示せ！",
            COLOR = Color.white
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP50_MESSAGE2 or "奥義上昇量・防御力アップ"
        })
    }

    self.HP25_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP25_MESSAGE1 or "降魔の帝剣よ、力を示せ！",
            COLOR = Color.white
        }),
        [2] = self:setMessageInfo({
            MESSAGE = self.TEXT.HP25_MESSAGE2 or "奥義上昇量・クリティカル耐性アップ"
        })
    }

    self.DEAD_TRUE_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_TRUE_MESSAGE1 or "これが王剣に選ばれし者の力か……",
            COLOR = Color.white
        })
    }

    self.DEAD_FALSE_MESSAGE_LIST = {
        [1] = self:setMessageInfo({
            MESSAGE = self.TEXT.DEAD_FALSE_MESSAGE1 or "これほど……とはね……",
            COLOR = Color.white
        })
    }

end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp75(status) end,
            HP = 75,
            used = false
        },
        [2] = {
            tag = "HP_FLG",
            action = function (status) self:hp50(status) end,
            HP = 50,
            used = false
        },
        [3] = {
            tag = "HP_FLG",
            action = function (status) self:hp25(status) end,
            HP = 25,
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

function class:hp75(status)
    if status == "use3" then
        self.burstPoint = self.gameUnit:getBurstPoint()
        self.isLight = true
        self.gameUnit:addSP(100)
        self:showMessage(self.HP75_MESSAGE_LIST)
        self.spValue = 30
        self.gameUnit:setInvincibleTime(30)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[4])

        self:removeAllBadstatus(self.gameUnit) ---状態異常全除去
        self:execAddBuff(self.gameUnit,self.ANTI_BAD_CONDITION_BUFF_LIST)
    end
end

function class:hp50(status)
    if status == "use3" then
        self.burstPoint = self.gameUnit:getBurstPoint()
        self.isMetal = true
        self.gameUnit:addSP(100)
        self:showMessage(self.HP50_MESSAGE_LIST)
        self.spValue = 40
        self.gameUnit:setInvincibleTime(30)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[5])

        self:removeAllBadstatus(self.gameUnit) ---状態異常全除去
        self:execAddBuff(self.gameUnit,self.ANTI_BAD_CONDITION_BUFF_LIST)
    end
end

function class:hp25(status)
    if status == "use3" then
        self.burstPoint = self.gameUnit:getBurstPoint()
        self.isDark = true
        self.gameUnit:addSP(100)
        self:showMessage(self.HP25_MESSAGE_LIST)
        self.spValue = 50
        self.gameUnit:setInvincibleTime(30)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[6])

        self:removeAllBadstatus(self.gameUnit) ---状態異常全除去
        self:execAddBuff(self.gameUnit,self.ANTI_BAD_CONDITION_BUFF_LIST)

        self.gameUnit:setAttackDelay(2);---アタックディレイ
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
    event.unit:setAttackDelay(5);---アタックディレイ
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
    if self:findTheProtagonist() then
        self:showMessage(self.TRUE_MESSAGE_LIST)
        self.isProtagonist = true
    else
        self:showMessage(self.FALSE_MESSAGE_LIST)
        self.isProtagonist = false
    end
    self:showMessage(self.START_MESSAGE_LIST)
    self.addSpSkipFLG = true ---スキル直後の通常攻撃ではaddSPしない

    self.breakSkip = false

    self.bugCheckFLG = false

    ---イスリーダ皇帝用フラグ
    self.isLight = false
    self.isMetal = false
    self.isDark = false

    self.isBroken = false
    self.isTarget = false

    self.hpFLG = false
    self.burstPoint = 0

    self.gameUnit:addNumBreakBadge(1)

    ---自動ヘイトは使わない
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    self.targetUnitList = {}
    self.onceFLG = false
    return 1
end

---レイアスサーチ
function class:findTheProtagonist()
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getBaseID() == 10101 then
                return true
            end
        end
    end
    return false
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(100,1)---ヒットストップ無効or時止め無効
    if event.unit.m_breaktime == 0 then
        self:HPTriggersCheck(event.unit)
        if self.isBroken and not self.onceFLG then
            self:showMessage(self.TARGET_MESSAGE_LIST)
            self.isTarget = true
            self.onceFLG = true
            BattleControl:get():visibleHateTarget(true);
            BattleControl:get():setHateTargetIcon(14);
            event.unit:setEnableHate(true);
            event.unit:updateHateTarget();
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.isProtagonist then
        self:showMessage(self.DEAD_TRUE_MESSAGE_LIST)
    else
        self:showMessage(self.DEAD_FALSE_MESSAGE_LIST)
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    event.unit:takeIdle();
    megast.Battle:getInstance():waveEnd(true);
    return 0
end

function class:receive4(args)
    if self.isProtagonist then
        self:showMessage(self.DEAD_TRUE_MESSAGE_LIST)
    else
        self:showMessage(self.DEAD_FALSE_MESSAGE_LIST)
    end
    self.gameUnit:takeIdle();
    megast.Battle:getInstance():waveEnd(true);
    return 0
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
        event.unit:setActiveSkill(2)
    elseif event.index == 3 then
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName("2-skill2") ---EFのアニメーション名に気をつける
        event.unit:setActiveSkill(3)
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    ---奥義直後の通常攻撃ではaddSPしない---
    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit) ---停止系状態異常除去(状態異常のまま動いてしまう場合があり、その対策)
        self.gameUnit:setInvincibleTime(0)
        self:execAddBuff(self.gameUnit,self.ANTI_BAD_CONDITION_BUFF_LIST2)
        if self.hpFLG then
            self.hpFLG = false
            event.unit:addSP(self.burstPoint)---奥義ゲージ引き継ぎ
            self.burstPoint = 0
            ---ターゲット初期化
            local val = 0
            local index = 0
            for i,v in pairs(self.targetUnitList) do
                if v.dps >= val then
                    val = v.dps
                    index = i
                end
            end
            if self.targetUnitList[index] ~= nil then
                self.targetUnitList[index].dps = 0
                if megast.Battle:getInstance():isHost() then
                    local nextTarget = self:checkTargetUnit()
                    megast.Battle:getInstance():sendEventToLua(self.scriptID,6,nextTarget:getIndex())---ゲストにターゲットを送る
                    event.unit:setHateTarget(nextTarget)
                    event.unit:updateHateTarget();
                end
            end
        end
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
        if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_ATTACK.actCount); end
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

    ---カットイン設定
    local cutIn = 0
    if event.index >= 4 then
        cutIn = 1
    end
    if not self.cutInFLG then
        self.cutInFLG = true;
        event.unit:takeSkillWithCutin(event.index,cutIn);
        return 0;
    end

    ---アニメーション設定
    local weaponNum = event.index
    if cutIn == 1 then
        weaponNum = weaponNum - 3
        self.hpFLG = true
        self.isLight = false
        self.isMetal = false
        self.isDark = false
    else
        ---バフ付与
        self:teamAddBuff(event.index)
        self:execShowMessage(self.WEAPON_MESSAGE_LIST[weaponNum])
    end
    event.unit:setNextAnimationName("skill3_"..weaponNum)
    event.unit:setNextAnimationEffectName("2-skill3_"..weaponNum)

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

    if self.isLight then
        skillIndex = 4
    elseif self.isMetal then
        skillIndex = 5
    elseif self.isDark then
        skillIndex = 6
    else
        if self.bugCheckFLG then summoner.Utility.messageByEnemy(self.STATE_SKILL.actCount,7,Color.magenta); end
        self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL)
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end

function class:teamAddBuff(index)
    local buffBox = self.BUFF_BOX_LIST[index]
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            ---対象のバフをサーチ
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
            if cond ~= nil then
                ---value量を見てカウント表示を決定
                local count = cond:getValue() / self.BUFF_BOX_LIST[index].VALUE
                count = math.floor(count)
                buffBox.COUNT = count + 1
                if buffBox.COUNT > 10 then
                    buffBox.COUNT = 10
                end
            else
                buffBox.COUNT = 1
            end
            ---付与
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- スキップ不可
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if not self.isBroken then
        event.value = event.value * 0.01
    end
    event.value = self:adjustHpFlg(event.unit,event.value)
    ---以下ターゲット処理---
    if self.isTarget then
        if event.enemy:getIndex() == 4 then return event.value end
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
            megast.Battle:getInstance():sendEventToLua(self.scriptID,5,target:getIndex())---ゲストにターゲットを送る
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
    end
    return event.value
end

function class:receive5(args)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    ---ヘイトは全部手動で設定する
    local target = myTeam:getTeamUnit(args.arg)
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
    return 1
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

---与ダメが最も大きいやつをターゲットにする
function class:checkTargetUnit()
    local target = nil
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

----// takeBreakeDamageValue //-----------------------------------------------------------------------------
-- 条件 : 被ダメージ時。
-- 引数 : event.unit / 自ユニット  event.enemy / 攻撃者  event.value / 被ブレイクダメージ量
---------------------------------------------------------------------------------
function class:takeBreakeDamageValue(event)
    if self.isBroken then
        event.value = event.value * 0.01
    end
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
    if not self.isBroken then
        self.isBroken = true
        self.gameUnit:removeNumBreakBadge()
        self:showMessage(self.BREAK_MESSAGE_LIST)
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
    if buffBox.COUNT == nil then
        if buffBox.EFFECT ~= nil then
            buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
        else
            buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
        end
    else
        if buffBox.EFFECT ~= nil then
            buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * buffBox.COUNT,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
        else
            buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * buffBox.COUNT,buffBox.DURATION,buffBox.ICON);
        end
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        --buffBox.COUNT = buffBox.COUNT < buffBox.MAX and buffBox.COUNT + 1 or buffBox.MAX
        megast.Battle:getInstance():updateConditionView();
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