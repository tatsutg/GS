local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="メイン37章 エクスフォーゼレイアス_HARD", version=2.4, id=3705033});
class:inheritFromUnit("unitBossBase");

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    SKILL5 = 4,
    SKILL6 = 3
}

class.cutInSkill = {
    [2] = 1,
    [3] = 1,
    [5] = 1,
    [6] = 1
}

class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },
        { ATTACK1 = 50, ATTACK2 = 50 },
        { ATTACK1 = 100 }
    }
}

class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 }
    },
    RAGE = {
        { SKILL3 = 100 },
        { SKILL2 = 100 }
    }
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 300000101,
            BUFF_ID = 13,
            VALUE = self.GD.targetAtkDownVal,
            DURATION = 999999,
            ICON = 4
        },
        [2] = {
            ID = 300000102,
            BUFF_ID = 17,
            VALUE = self.GD.bossAtkUpVal,
            DURATION = 999999,
            ICON = 26,
            MAX = 10
        },
        [3] = {
            ID = 300000103,
            BUFF_ID = 1,
            VALUE = self.GD.unitHpDownVal,
            DURATION = 999999,
            ICON = 2,
            MAX = 10
        },
        [4] = {
            ID = 300000104,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 20
        },
        [5] = {
            ID = 300000107,
            BUFF_ID = 17,
            VALUE = self.GD.critDmgUpVal,
            DURATION = 999999,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 22,
                VALUE1 = 0,
                VALUE2 = 0
            }
        },
        [6] = {
            ID = 300000108,
            BUFF_ID = 132,
            VALUE = 100,
            DURATION = 999999,
            ICON = 0
        }
    }
    self.TARGET_BUFF_LIST1 = {
        ID = 300000110,
        BUFF_ID = 23,
        VALUE = self.GD.critRateUpVal,
        DURATION = 999999,
        ICON = 0
    }
    self.TARGET_BUFF_LIST0 = {
        ID = 300000110,
        BUFF_ID = 23,
        VALUE = 0,
        DURATION = 999999,
        ICON = 0
    }
end

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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "お前は、敵…なのか！？", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "反射・HP吸収・奥義ゲージ低下耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "クリティカル耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "ダメージの大きい者をターゲット", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "ターゲットへのクリティカル率アップ", COLOR = Color.yellow})
    }
    self.SKILL1_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_MESSAGE1 or "%sからのダメージを軽減", COLOR = Color.red})
    }
    self.SKILL1_HP_DOWN_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_HP_DOWN_MESSAGE1 or "パーティの最大HPダウン", COLOR = Color.red})
    }
    self.HP_ATKDOWN_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP_ATKDOWN_MESSAGE1 or "%sの攻撃力ダウン", COLOR = Color.red})
    }
    self.SKILL1_ODD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_ODD_MESSAGE1 or "防御体勢：被ダメージ軽減、魔法ダメージで解除", COLOR = Color:new(140, 0, 210)})
    }
    self.SKILL1_EVEN_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SKILL1_EVEN_MESSAGE1 or "防御体勢：被ダメージ軽減、物理ダメージで解除", COLOR = Color:new(210, 10, 0)})
    }
    self.SUBBAR_BREAK_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.SUBBAR_BREAK_MESSAGE1 or "鉄壁状態：被ダメージ軽減、ブレイクで解除", COLOR = Color.yellow})
    }
    self.ARMOR_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.ARMOR_MESSAGE1 or "ブレイク成功！鉄壁状態を解除！", COLOR = Color.red})
    }
    self.HP80_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP80_MESSAGE1 or "グランスケルよ、閃光となれ！", COLOR = Color.white}),
    }
    self.HP50_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE1 or "グランスケルよ、閃光となれ！", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP50_MESSAGE2 or "奥義上昇量アップ", COLOR = Color.yellow})
    }
    self.HP20_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP20_MESSAGE1 or "グランスケルよ、閃光となれ！", COLOR = Color.white})
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "グランスケルよ、俺に力を！", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE2 or "クリティカルダメージ・奥義上昇量アップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE3 or "ダメージ無効化無効", COLOR = Color.red})
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "騎士の剣よ…応えて…くれ…", COLOR = Color.white})
    }
end

function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp80(status) end,
            HP = 80,
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
            action = function (status) self:hp20(status) end,
            HP = 20,
            used = false,
            isEnableSkip = false
        },
        [4] = {
            tag = "HP_FLG",
            action = function (status) self:hp0(status) end,
            HP = 0.1,
            used = false,
            isEnableSkip = false
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

function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 5,
        attackDelay = 10,
        hitStop = 100,
        targetAtkDownVal = -50,
        bossAtkUpVal = 20,
        unitHpDownVal = -1000,
        dmgReduceDur = 20,
        critDmgUpVal = 100,
        critRateUpVal = 50,
        spValueHp50 = 10,
        spValueHp0 = 30,
        hpRecoverHp0 = 40,
        subBarHpPct = {10, 15, 20, 25, 30}
    })
    self:dump(self.GD)

    self.fromHost = false
    self.gameUnit = event.unit

    self.spValue = self.GD.addSP
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay)
    end

    self.attackCheckFlg = false
    self.skillCheckFlg = false
    self.cutInFLG = false
    event.unit:setSPGainValue(0)
    event.unit:setSkillInvocationWeight(0)

    ---ターゲットギミック
    self.targetUnitList = {}
    BattleControl:get():visibleHateTarget(true)
    BattleControl:get():setHateTargetIcon(14)
    event.unit:setEnableHate(true)
    event.unit:setHateRate_Heal(0)
    event.unit:setHateRate_Damage(0)
    event.unit:updateHateTarget()

    ---サブバー表示用
    self.subBarFlg = false
    self.subBarCount = 0
    self.subBarDamage = 0
    self.subBar = BattleControl:get():createSubBar()
    self.subBar:setWidth(200)
    self.subBar:setHeight(13)
    self.subBar:setPercent(0)
    self.subBar:setVisible(false)
    self.SUB_HP = 0

    ---ギミック管理
    self.damageReductionTimer = 0
    self.damageReductionTarget = nil
    self.armorState = false
    self.armorFlg = false
    self.hp80Broken = false
    self.addSpSkipFLG = true
    self.breakSkip = false
    self.hpSkill = 0
    self.saveBP = 0
    self.lastSkillFLG = false
    self.deadFlg = false

    self:setMessageBoxList()
    self:setTriggerList()
    self:setBuffBoxList()

    self:initAttackWeight({DEFAULT = 100})
    self:initSkillWeight({DEFAULT = 100})

    self:showMessage(self.START_MESSAGE_LIST)

    return 1
end

function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit)
    end

    event.unit:setReduceHitStop(self.GD.hitStop, 1)

    if self.subBarFlg then
        self:subBarControll(event.unit, self.subBarDamage)
    end

    ---ダメージ軽減タイマー
    if self.damageReductionTimer > 0 then
        self.damageReductionTimer = self.damageReductionTimer - event.deltaTime
    end

    ---HP0%奥義終了後にバフを適用
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.lastSkillFLG == nil then self.lastSkillFLG = false end
        if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
            self.lastSkillFLG = false
            self.deadFlg = true
        end
    end

    return 1
end

function class:takeAttack(event)
    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true
        return self:attackReroll(event.unit)
    end
    self.attackCheckFlg = false
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle()
        return 0
    end

    self.fromHost = false

    if event.index == 2 then
        event.unit:setNextAnimationName("skill1")
        event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-skill1")
    end

    self:attackActiveSkillSetter(event.unit, event.index)

    if self.addSpSkipFLG then
        self.addSpSkipFLG = false
        self:refresh(self.gameUnit)
        self.gameUnit:setInvincibleTime(0)
        event.unit:addSP(self.saveBP)
        self.saveBP = 0
    else
        self:addSP(event.unit)
    end
    return 1
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex()
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST, self.STATE_ATTACK)
    end
    unit:takeAttack(tonumber(attackIndex))
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 1, tonumber(attackIndex))
    return 0
end

function class:takeAttackFromHost(unit, index)
    self.fromHost = true
    unit:takeAttack(index)
end

function class:addSP(unit)
    unit:addSP(self.spValue)
    return 1
end

function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true
        return self:skillReroll(event.unit)
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle()
        return 0
    end

    if self.cutInFLG then
        self.cutInFLG = false
        event.unit:takeSkillWithCutin(event.index, 1)
        return 0
    end

    self.skillCheckFlg = false
    self.cutInFLG = false
    self.addSpSkipFLG = true
    self.fromHost = false

    if event.index == 2 then
        self:execSkill2(event.unit)
    elseif event.index == 3 then
        self:execSkill3(event.unit)
    elseif event.index == 6 then
        ---HPトリガー専用（カットイン付き奥義3）：SKILL2と同じアニメーション・処理
        event.unit:setNextAnimationName("skill2")
        event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-skill2")
        self:execSkill2(event.unit)
    elseif event.index == 5 then
        ---HP0%専用スロット（SKILL5）: skill3アニメーションに合わせる
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-skill3")
        self.lastSkillFLG = true
        self:initSkillWeight({RAGE = 100})
        local target = self:checkTargetUnit()
        if target ~= nil then
            self:execAddBuff(target, self.BUFF_BOX_LIST[1])
        end
    end

    self:skillActiveSkillSetter(event.unit, event.index)
    return 1
end

function class:execSkill2(unit)
    ---ターゲット取得
    local target = self:checkTargetUnit()

    ---メッセージ表示（%s にターゲット名を埋め込む）
    self:showMessage(self.SKILL1_MESSAGE_LIST, nil, target)
    if target ~= nil then
        ---ターゲットからのダメージ軽減タイマー
        self.damageReductionTimer = self.GD.dmgReduceDur
        self.damageReductionTarget = target
    end

    ---ダメージ20%UP（MAX10）
    self:execAddBuff(unit, self.BUFF_BOX_LIST[2])

    ---最大HP DOWN（ユニット毎にMAX10まで積み上がる）
    local myTeam = megast.Battle:getInstance():getTeam(true)
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i)
        if u ~= nil then self:execAddBuff(u, self.BUFF_BOX_LIST[3]) end
    end
    self:showMessage(self.SKILL1_HP_DOWN_MESSAGE_LIST)

    ---エクストラゲージ（発動中は新規発動・上書きなし。破壊後の再発動時に物魔を切り替え）
    if not self.subBarFlg then
        self.subBarCount = self.subBarCount + 1
        local idx = math.min(self.subBarCount, 5)
        self.SUB_HP = unit:getCalcHPMAX() * (self.GD.subBarHpPct[idx] / 100)
        self.subBarDamage = 0
        self.subBarFlg = true
        ---ゲージ生成回数に基づいて防御体勢を表示（奇数=物理防御/魔法で解除、偶数=魔法防御/物理で解除）
        if self.subBarCount % 2 == 1 then
            self:showMessage(self.SKILL1_ODD_MESSAGE_LIST)
        else
            self:showMessage(self.SKILL1_EVEN_MESSAGE_LIST)
        end
    end
end

function class:execSkill3(unit)
    ---最大HP DOWN（ユニット毎にMAX10まで積み上がる）
    local myTeam = megast.Battle:getInstance():getTeam(true)
    for i = 0, 6 do
        local u = myTeam:getTeamUnit(i)
        if u ~= nil then self:execAddBuff(u, self.BUFF_BOX_LIST[3]) end
    end
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex()
    if self.hpSkill ~= 0 then
        skillIndex = self.hpSkill
        self.hpSkill = 0
    else
        self:movePatternState(self.SKILL_SET_LIST, self.STATE_SKILL)
    end
    if self.cutInSkill[skillIndex] ~= nil then
        unit:takeSkillWithCutin(tonumber(skillIndex), self.cutInSkill[skillIndex])
    else
        unit:takeSkill(tonumber(skillIndex))
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 2, tonumber(skillIndex))
    return 0
end

function class:takeSkillFromHost(unit, index)
    self.fromHost = true
    if self.cutInSkill[index] ~= nil then
        unit:takeSkillWithCutin(index, self.cutInSkill[index])
    else
        unit:takeSkill(index)
    end
end

function class:takeDamageValue(event)
    local enemyUnit = self:getAncestorUnit(event.enemy)

    ---ターゲット処理
    if event.enemy:getIndex() == 4 then return event.value end
    local index = enemyUnit:getIndex() + (enemyUnit:getBaseID3() * 10)
    if self.targetUnitList[index] == nil then
        self.targetUnitList[index] = {unit = enemyUnit, dps = event.value}
    else
        self.targetUnitList[index].dps = self.targetUnitList[index].dps + event.value
    end

    if megast.Battle:getInstance():isHost() then
        local target = self:checkTargetUnit()
        megast.Battle:getInstance():sendEventToLua(self.scriptID,7,target:getIndex())
        event.unit:setHateTarget(target)
        event.unit:updateHateTarget()

        local myTeam = megast.Battle:getInstance():getTeam(true)
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

    ---ダメージ軽減（ターゲット、20秒間）
    if self.damageReductionTarget ~= nil and self.damageReductionTimer > 0 then
        if enemyUnit == self.damageReductionTarget then
            event.value = event.value * 0.1
        end
    end

    ---エクストラゲージ表示中の処理
    if self.subBarFlg then
        local attribute = enemyUnit:getTeamUnitCondition():getDamageAffectInfo().skillAttribute
        if (self.subBarCount % 2 == 1 and attribute == 2) or (self.subBarCount % 2 == 0 and attribute == 1) then
            ---この属性はゲージに蓄積
            self.subBarDamage = self.subBarDamage + event.value
        else
            ---この属性は軽減
            event.value = event.value * 0.1
        end
        ---ボスダメージ も 0.01 に補正
        event.value = event.value * 0.01
        ---ゲストにサブバー進捗を同期
        if megast.Battle:getInstance():isHost() then
            -- megast.Battle:getInstance():sendEventToLua(self.scriptID, 8, math.floor(self.subBarDamage))
        end
    end

    ---鉄壁状態
    if self.armorState then
        event.value = 1
    end

    event.value = self:adjustHpFlg(event.unit, event.value)
    return event.value
end

function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0
    end
    event.value = self:adjustHpFlg(event.unit, event.value)
    return event.value
end

function class:takeBreakeDamageValue(event)
    if self.breakSkip then
        self.breakSkip = false
        return 0
    end
    if self.hp80Broken then
        return 0
    end
    return event.value
end

function class:takeBreake(event)
    for i = 1, table.getn(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * self.HP_TRIGGERS[i].HP * 0.01
        if event.unit:getHP() <= stopBorder and event.unit:getHP() > stopBorder - 2 then
            return 0
        end
    end

    if self.armorState then
        self.armorState = false
        self.hp80Broken = true
        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[4].ID)
        if cond ~= nil then
            self.gameUnit:getTeamUnitCondition():removeCondition(cond)
        end
        self:showMessage(self.ARMOR_MESSAGE_LIST)
        megast.Battle:getInstance():sendEventToLua(self.scriptID, 9,0)
        return 1
    end

    if self.hp80Broken then
        return 0
    end

    return 1
end

function class:receive9(args)
    if args.arg == 1 then
        self.armorState = true
        return 1
    end

    self.armorState = false
    local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[4].ID)
    if cond ~= nil then
        self.gameUnit:getTeamUnitCondition():removeCondition(cond)
    end
    self:showMessage(self.ARMOR_MESSAGE_LIST)
    return 1
end

function class:takeIdle(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.addSpSkipFLG then
            self.gameUnit:setInvincibleTime(0)
        end
    end
    return 1
end

function class:dead(event)
    if not self.deadFlg then
        return 0
    end
    self:showMessage(self.DEAD_MESSAGE_LIST)
    megast.Battle:getInstance():sendEventToLua(self.scriptID, 4, 1)
    return 1
end

function class:receive4(args)
    self:showMessage(self.DEAD_MESSAGE_LIST)
    return 1
end

function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
    self.TRIGGERS[args.arg].action("use3")
    self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
    return 1
end

function class:receive5(args)
    self.TRIGGERS[args.arg].used = true
    if self.TRIGGERS[args.arg].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP], true)
    end
    return 1
end

function class:receive6(args)
    if args.arg == 1 then
        self.subBarFlg = false
        self.subBar:setVisible(false)
        self.subBarDamage = 0
        return 1
    end
    self.subBarFlg = false
    self.subBar:setVisible(false)
    self:showMessage(self.SUBBAR_BREAK_MESSAGE_LIST)
    return 1
end

function class:receive7(args)
    ---ターゲット同期（ホストから送信されたターゲットインデックスに基づきバフを適用）
    local targetTeam = megast.Battle:getInstance():getTeam(true)
    for i = 0, 3 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if i == args.arg then
                self:execAddBuff(myTeamUnit, self.TARGET_BUFF_LIST1)
            else
                self:execAddBuff(myTeamUnit, self.TARGET_BUFF_LIST0)
            end
        end
    end
    return 1
end

function class:receive8(args)
    ---サブバー進捗同期
    self.subBarDamage = args.arg
    return 1
end

function class:hp80(status)
    if status == "use3" then
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(15)
        self:refresh(self.gameUnit)
        self:showMessage(self.HP80_MESSAGE_LIST)

        local target = self:checkTargetUnit()
        if target ~= nil then
            self:execAddBuff(target, self.BUFF_BOX_LIST[1])
            self:showMessage(self.HP_ATKDOWN_MESSAGE_LIST, nil, target)
        end

        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[4])
        -- self.armorState = true
    end
end

function class:hp50(status)
    if status == "use3" then
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.spValue = self.GD.spValueHp50
        self.gameUnit:setInvincibleTime(15)
        self:refresh(self.gameUnit)
        self:showMessage(self.HP50_MESSAGE_LIST)

        local target = self:checkTargetUnit()
        if target ~= nil then
            self:execAddBuff(target, self.BUFF_BOX_LIST[1])
            self:showMessage(self.HP_ATKDOWN_MESSAGE_LIST, nil, target)
        end
    end
end

function class:hp20(status)
    if status == "use3" then
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(15)
        self:refresh(self.gameUnit)
        self:showMessage(self.HP20_MESSAGE_LIST)

        local target = self:checkTargetUnit()
        if target ~= nil then
            self:execAddBuff(target, self.BUFF_BOX_LIST[1])
        end
    end
end

function class:hp0(status)
    if status == "use3" then
        self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * (self.GD.hpRecoverHp0 / 100))
        self.hpSkill = 5
        self.gameUnit:addSP(100)
        self.gameUnit:setInvincibleTime(15)
        self:refresh(self.gameUnit)
        self.spValue = self.GD.spValueHp0
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[5])
        self:execAddBuff(self.gameUnit, self.BUFF_BOX_LIST[6])
        self:showMessage(self.HP0_MESSAGE_LIST)
    end
end

function class:subBarControll(unit, damage)
    self.subBar:setPositionX(unit:getPositionX())
    self.subBar:setPositionY(unit:getPositionY())
    self.subBar:setVisible(true)
    self.subBar:setPercent(100 * (self.SUB_HP - damage) / self.SUB_HP)

    if self.SUB_HP - damage <= 0 then
        if megast.Battle:getInstance():isHost() then
            self.subBarFlg = false
            self.subBar:setVisible(false)
            self.subBarDamage = 0
            megast.Battle:getInstance():sendEventToLua(self.scriptID, 6, 1)
            if not self.armorFlg then
                self.armorFlg = true
                self.armorState = true
                if self:getIsHost() then
                    self:showMessage(self.SUBBAR_BREAK_MESSAGE_LIST)
                    megast.Battle:getInstance():sendEventToLua(self.scriptID, 6, 0)
                    megast.Battle:getInstance():sendEventToLua(self.scriptID, 9, 1)
                end
            end
        end
    end
end

function class:checkTargetUnit()
    local target = nil
    local targetTeam = megast.Battle:getInstance():getTeam(true)
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            target = myTeamUnit
            break
        end
    end
    local val = 0
    for i,v in pairs(self.targetUnitList) do
        if v.unit == nil or v.unit:getHP() < 1 then
            ---skip
        elseif v.dps >= val then
            val = v.dps
            target = v.unit
        end
    end
    return target
end

function class:showMessage(messageBoxList, index, targetUnit)
    if index == nil then
        self:showMessageAll(messageBoxList, targetUnit)
        return
    end
    self:execShowMessage(messageBoxList[index], targetUnit)
end

function class:showMessageAll(messageBoxList, targetUnit)
    for _, messageBox in ipairs(messageBoxList) do
        self:execShowMessage(messageBox, targetUnit)
    end
end

function class:execShowMessage(messageBox, targetUnit)
    local msg = messageBox.MESSAGE
    if targetUnit ~= nil then
        msg = string.format(msg, targetUnit:getUnitName())
    end
    if messageBox.isPlayer then
        summoner.Utility.messageByPlayer(msg, messageBox.DURATION, messageBox.COLOR)
    else
        summoner.Utility.messageByEnemy(msg, messageBox.DURATION, messageBox.COLOR)
    end
end

function class:hpTriggersCheck(unit)
    if not self:getIsHost() then
        return
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100
    for index, trigger in pairs(self.HP_TRIGGERS) do
        if trigger.HP >= hpRate and not trigger.used then
            if not trigger.isEnableSkip then
                if not unit:isBreak() then
                    self:execTrigger(index)
                end
            else
                self:execTrigger(index)
            end
        end
    end
end

function class:execTrigger(index, receiveNumber)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
        return
    end

    receiveNumber = receiveNumber ~= nil and receiveNumber or 3
    local action = "use" .. receiveNumber
    self.TRIGGERS[index].used = true

    if self.TRIGGERS[index].isEnableSkip == true and self.gameUnit:isBreak() then
        if self.TRIGGERS[index].tag == "HP_FLG" then
            self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP], true)
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID, 5, index)
        return
    end

    if self.TRIGGERS[index].tag == "HP_FLG" then
        self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
    end

    self.TRIGGERS[index].action(action)
    if receiveNumber ~= 0 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID, receiveNumber, index)
    end
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost()
end

function class:adjustHpFlg(unit, value)
    local anotherHp = unit:getHP() - value
    for _, trigger in pairs(self.HP_TRIGGERS) do
        local stopBorder = self.gameUnit:getCalcHPMAX() * trigger.HP * 0.01
        if not trigger.used and stopBorder >= anotherHp then
            self:refresh(self.gameUnit)
            return unit:getHP() < stopBorder and 1 or self:calcDamageValue(unit, stopBorder, value)
        end
    end
    return value
end

function class:calcDamageValue(unit, border, value)
    self.breakSkip = true
    return unit:getHP() - border + 1
end

function class:execAddBuff(unit, buffBox)
    local buff = nil
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID)
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond)
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return
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
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID, buffBox.BUFF_ID, buffBox.VALUE * count, buffBox.DURATION, buffBox.ICON, buffBox.EFFECT)
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID, buffBox.BUFF_ID, buffBox.VALUE * count, buffBox.DURATION, buffBox.ICON, buffBox.WEIGHT)
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID, buffBox.BUFF_ID, buffBox.VALUE * count, buffBox.DURATION, buffBox.ICON)
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
        buff:setMaxConditionIconNumber(buffBox.MAX)
        buff:setNumber(buffBox.COUNT)
        megast.Battle:getInstance():updateConditionView()
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX)
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
end

function class:refresh(unit)
    local badStatusIDs = {89, 91, 96}
    for i = 1, table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i]
        local flag = true
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID)
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond)
            else
                flag = false
            end
            count = count + 1
            if count > 100 then break end
        end
    end
end

function class:movePatternState(SET_LIST, stateBox)
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
    local attackList = {...}
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount])
    local attackIndex = string.gsub(attackStr, "ATTACK", "")
    return tonumber(attackIndex)
end

class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...}
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount])
    local skillIndex = string.gsub(skillStr, "SKILL", "")
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

function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
end

class:publish();

return class;