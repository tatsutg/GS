local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ダンダダンコラボ_オカルン(真EX・極)", version=2.5, id=2072590});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 50 },
        { ATTACK1 = 50 },
        { ATTACK1 = 50, ATTACK2 = 50},
    }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
    DEFAULT = {
        { SKILL2 = 100 },
        { SKILL3 = 100 },
    }
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL2 = 3,
    SKILL3 = 4,
    SKILL5 = 5,
    SKILL6 = 3,
}

class.cutInSkill = {
    [6] = 1,
    [5] = 1,
}

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 207259001,
            BUFF_ID = 31,  --回避率
            VALUE = self.GD.hSpeedBuffValue_31,
            DURATION = 999999,
            ICON = 16,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        },
        [2] = {
            ID = 207259002,
            BUFF_ID = 23,   -- クリティカル耐性
            VALUE = self.GD.hp60BuffValue_23,
            DURATION = 999999,
            ICON = 188,
        },
        [3] = {
            ID = 207259003,
            BUFF_ID = 60,   -- 燃焼耐性
            VALUE = self.GD.hSpeedresistBuffValue_60,
            DURATION = 999999,
            ICON = 66,
            COUNT = 0,
            MAX = 10,
        },
        [4] = {
            ID = 207259004,
            BUFF_ID = 109,   -- 燃焼回避率
            VALUE = self.GD.hSpeedresistBuffValue_60,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10,
        },
        [5] = {
            ID = 207259005,
            BUFF_ID = 56,   -- 暗闇耐性
            VALUE = self.GD.hSpeedresistBuffValue_56,
            DURATION = 999999,
            ICON = 62,
            COUNT = 0,
            MAX = 10,
        },
        [6] = {
            ID = 207259006,
            BUFF_ID = 105,   -- 暗闇回避率
            VALUE = self.GD.hSpeedresistBuffValue_56,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10,
        },
        [7] = {
            ID = 207259007,
            BUFF_ID = 59,   -- 氷結耐性
            VALUE = self.GD.hSpeedresistBuffValue_59,
            DURATION = 999999,
            ICON = 65,
            COUNT = 0,
            MAX = 10,
        },
        [8] = {
            ID = 207259008,
            BUFF_ID = 108,   -- 氷結回避率
            VALUE = self.GD.hSpeedresistBuffValue_59,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10,
        },
        [9] = {
            ID = 207259009,
            BUFF_ID = 54,   -- 麻痺耐性
            VALUE = self.GD.hSpeedresistBuffValue_54,
            DURATION = 999999,
            ICON = 60,
            COUNT = 0,
            MAX = 10,
        },
        [10] = {
            ID = 207259010,
            BUFF_ID = 103,   -- 麻痺回避率
            VALUE = self.GD.hSpeedresistBuffValue_54,
            DURATION = 999999,
            ICON = 0,
            COUNT = 0,
            MAX = 10,
        },
        [11] = {
            ID = 207259011,
            BUFF_ID = 17,   -- 与ダメージ
            VALUE = self.GD.skillBuffValue_17,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 10
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
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE1 or "てめえはジブンを怒らせた…", COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE2 or "人族、水・樹属性からの被ダメージアップ", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE3 or "奥義ゲージ低下・反射耐性", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE4 or "高速移動状態：回避率アップ、被ダメージ軽減", COLOR = Color.yellow}),
        self:setMessageInfo({MESSAGE = self.TEXT.START_MESSAGE5 or "高速移動状態：燃焼・暗闇・麻痺・氷結状態で解除", COLOR = Color.red}),
    }
    self.HISPEEDMODE_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HISPEEDMODE_MESSAGE1 or "燃焼で高速移動状態解除成功！", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HISPEEDMODE_MESSAGE2 or "暗闇で高速移動状態解除成功！", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HISPEEDMODE_MESSAGE3 or "麻痺で高速移動状態解除成功！", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HISPEEDMODE_MESSAGE4 or "氷結で高速移動状態解除成功！", COLOR = Color.white}),
        self:setMessageInfo({MESSAGE = self.TEXT.HISPEEDMODE_MESSAGE5 or "高速移動状態：回避率アップ、被ダメージ軽減", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HISPEEDMODE_MESSAGE6 or "燃焼耐性アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HISPEEDMODE_MESSAGE7 or "暗闇耐性アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HISPEEDMODE_MESSAGE8 or "麻痺耐性アップ", COLOR = Color.red}),
        self:setMessageInfo({MESSAGE = self.TEXT.HISPEEDMODE_MESSAGE9 or "氷結耐性アップ", COLOR = Color.red}),
    }
    self.HP60_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE1 or "あ～～鬱だ…", COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP60_MESSAGE2 or "クリティカル耐性アップ", COLOR = Color.yellow}),
    }
    self.HP30_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE1 or "めんどくせええ", COLOR = Color.green}),
        self:setMessageInfo({MESSAGE = self.TEXT.HP30_MESSAGE2 or "奥義上昇量アップ", COLOR = Color.yellow}),
    }
    self.HP0_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.HP0_MESSAGE1 or "めんどくせええええええええ", COLOR = Color.green}),
    }
    self.DEAD_MESSAGE_LIST = {
        self:setMessageInfo({MESSAGE = self.TEXT.DEAD_MESSAGE1 or "チッ…やっちまったな", COLOR = Color.green})
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.TRIGGERS = {
        [1] = {
            tag = "HP_FLG",
            action = function (status) self:hp60(status) end,
            HP = 60,
            used = false,
            isEnableSkip = true
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

function class:hp60(status)
    if status == "use3" then
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:refreshAll(self.gameUnit)
        self.gameUnit:setInvincibleTime(10)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
        self:showMessage(self.HP60_MESSAGE_LIST)
        self:hiSpeedModeChange(self.gameUnit)
    end
end

function class:hp30(status)
    if status == "use3" then
        self.hpSkill = 6
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self.spValue = self.GD.hp30addSP
        self:refreshAll(self.gameUnit)
        self.gameUnit:setInvincibleTime(10)
        --self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
        self:showMessage(self.HP30_MESSAGE_LIST)
        self:hiSpeedModeChange(self.gameUnit)
    end
end

function class:hp0(status)
    if status == "use3" then
        self.hpSkill = 5
        self.saveBP = self.gameUnit:getBurstPoint()
        self.gameUnit:addSP(100)
        self:refreshAll(self.gameUnit)
        self.gameUnit:setInvincibleTime(10)
        --self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
        self:showMessage(self.HP0_MESSAGE_LIST)
    end
end

function class:refreshAll(unit)
    local badStatusIDs = {89,90,91,92,93,94,95,96,97,131};
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

function class:hiSpeedModeChange(unit)
    if self.hiSpeedMode == false then
        self:showMessage(self.HISPEEDMODE_MESSAGE_LIST, 5)
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
        self.hiSpeedMode = true
    end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        addSP = 15,
        attackDelay = 7,
        hitStop = 100,
        hp60BuffValue_23 = -70,
        hp30addSP = 30,
        skillBuffValue_17 = 20,
        hSpeedDamageValue = 0.2,
        hSpeedBuffValue_31 = 70,
        hSpeedresistBuffValue_54 = 20,
        hSpeedresistBuffValue_56 = 20,
        hSpeedresistBuffValue_59 = 20,
        hSpeedresistBuffValue_60 = 20,
        shaderR = 0,
        shaderG = 255,
        shaderB = 0
    })
    self:dump(self.GD)

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    --event.unit:addSP(100)---戦闘開始時の奥義ゲージ量
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

    self.deadFlg = false
    self.hiSpeedMode = true
    self.deBuffFlg = 0
    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])

    --シェーダー追加
    megast.Battle:getInstance():setMultiColorFilter(self.GD.shaderR,self.GD.shaderG,self.GD.shaderB);

    return 1
end

function class:startWave(event)
    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(self.GD.hitStop,1)---ヒットストップ無効or時止め無効
    self:HPTriggersCheck(event.unit)

    -- 高速移動状態解除チェック
    if self.hiSpeedMode then
        self.deBuffFlg = self:findDeBuff(event.unit)
        if self.deBuffFlg ~= 0 then
            self:hSpeedModeCheck(event.unit)
        end
    end

    ---死亡時処理
    if megast.Battle:getInstance():isHost() then
        if megast.Battle:getInstance():getBattleState() == kBattleState_active then
            if self.lastSkillFLG == nil then self.lastSkillFLG = false end
            if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
                self.deadFlg = true
                event.unit:setHP(0)
                --event.unit:getTeam():deadUnit(event.unit:getIndex());
                --megast.Battle:getInstance():waveEnd(true);
            end
            if self.TRIGGERS[3].used then
                if self.deadCount == nil then self.deadCount = 0 end
                self.deadCount = self.deadCount + event.deltaTime
                if self.deadCount >= 10 then
                    self.deadFlg = true
                    event.unit:setHP(0)
                    --event.unit:getTeam():deadUnit(event.unit:getIndex());
                    --megast.Battle:getInstance():waveEnd(true);
                end
            end
        end
    end
    return 1
end

-- デバフチェック
function class:findDeBuff(unit)
    local intFlg = 0
    local para = unit:getTeamUnitCondition():findConditionWithType(91)
    local ice = unit:getTeamUnitCondition():findConditionWithType(96)
    local darkness = unit:getTeamUnitCondition():findConditionWithType(93)
    local nightmare = unit:getTeamUnitCondition():findConditionWithType(131)
    local flame = unit:getTeamUnitCondition():findConditionWithType(97)

    -- 91>96>93>97
    -- 麻痺＞氷結＞暗闇(ナイトメア)＞燃焼
    if flame ~= nil then
        intFlg = 4
    end

    if darkness ~= nil or nightmare ~= nil then
        intFlg = 3
    end

    if ice ~= nil then
        intFlg = 2
    end

    if para ~= nil then
        intFlg = 1
    end
    return intFlg
end

--高速状態解除
function class:hSpeedModeCheck(unit)
    self.hiSpeedMode = false
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
    if cond ~= nil then
        unit:getTeamUnitCondition():removeCondition(cond);
    end
    -- 高速移動状態を解除した場合、解除した状態異常の耐性をあげる
    if self.deBuffFlg == 1 then
        -- 麻痺
        self:execAddBuff(unit,self.BUFF_BOX_LIST[9])
        self:execAddBuff(unit,self.BUFF_BOX_LIST[10])
        self:showMessage(self.HISPEEDMODE_MESSAGE_LIST, 3)
        self:showMessage(self.HISPEEDMODE_MESSAGE_LIST, 8)
    end
    if self.deBuffFlg == 2 then
        -- 氷結
        self:execAddBuff(unit,self.BUFF_BOX_LIST[7])
        self:execAddBuff(unit,self.BUFF_BOX_LIST[8])
        self:showMessage(self.HISPEEDMODE_MESSAGE_LIST, 4)
        self:showMessage(self.HISPEEDMODE_MESSAGE_LIST, 9)
    end
    if self.deBuffFlg == 3 then
        -- 暗闇
        self:execAddBuff(unit,self.BUFF_BOX_LIST[5])
        self:execAddBuff(unit,self.BUFF_BOX_LIST[6])
        self:showMessage(self.HISPEEDMODE_MESSAGE_LIST, 2)
        self:showMessage(self.HISPEEDMODE_MESSAGE_LIST, 7)

    end
    if self.deBuffFlg == 4 then
        -- 燃焼
        self:execAddBuff(unit,self.BUFF_BOX_LIST[3])
        self:execAddBuff(unit,self.BUFF_BOX_LIST[4])
        self:showMessage(self.HISPEEDMODE_MESSAGE_LIST, 1)
        self:showMessage(self.HISPEEDMODE_MESSAGE_LIST, 6)
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
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
    if not self.deadFlg then
        return 0
    end
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

    --if event.index == 3 then
    --    event.unit:setNextAnimationName("skill2")
    --    event.unit:setNextAnimationEffectName("2-skill2") ---EFのアニメーション名に気をつける
    --end

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

    if event.index == 2 or event.index == 3 then
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[11])
    end

    if event.index == 5 then
        self.lastSkillFLG = true
        event.unit:setInvincibleTime(10)
    end

    if event.index == 6 then
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[11])
        event.unit:setInvincibleTime(10)
        event.unit:setNextAnimationName("skill3")
        event.unit:setNextAnimationEffectName("2-skill3") ---EFのアニメーション名に気をつける
    end

    --if event.index == 6 then
    --    event.unit:setNextAnimationName("skill5")
    --    event.unit:setNextAnimationEffectName("2-skill5") ---EFのアニメーション名に気をつける
    --end

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
    if self.hiSpeedMode then
        event.value = event.value * self.GD.hSpeedDamageValue
    end
    event.value = self:adjustHpFlg(event.unit,event.value)
    return event.value
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
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
    ---オービット判定
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


function class:checkDbuff(unit)
    local badStatusIDs = {89,91,96};
    local rtn = false
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
        if cond ~= nil then
            rtn = true;
        end
    end
    return rtn
end

class:publish();

return class;