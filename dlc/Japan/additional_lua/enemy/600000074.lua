local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="パルラミシア", version=1.3, id=600000074});
class:inheritFromUnit("bossPreparation");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
  DEFAULT = {
    { ATTACK1 = 50 ,ATTACK2 = 50 ,ATTACK9 = 50 }
  }
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
  DEFAULT = {
    { SKILL2 = 100 },
    { SKILL2 = 100 },
    { SKILL1 = 100 }
  }
}

class.ACTIVE_SKILLS = {
  ATTACK1 = 1,
  ATTACK2 = 2,
  ATTACK9 = 3,
  SKILL1  = 4,
  SKILL2  = 5
}

function class:setMessageBoxList(event)
    self.START_MESSAGE_LIST = {
        self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE1 or "反射・HP吸収・奥義ゲージ低下耐性",
            DURATION = 10
        }),
        self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE2 or "最大HPが高いユニットへのダメージUP",
            DURATION = 10
        }),
        self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE3 or "奥義中、被ダメージ軽減",
            DURATION = 10
        }),
        self:setMessageInfo({
            MESSAGE = self.TEXT.START_MESSAGE4 or "暗闇状態のとき、与ダメージ減少",
            DURATION = 10
        })
    }
    self.RAGE_MESSAGE_LIST = {
        self:setMessageInfo({
            MESSAGE = self.TEXT.RAGE_MESSAGE or "攻撃速度・命中率・クリティカル耐性アップ",
            DURATION = 10
        })
    }
    self.FURY_MESSAGE_LIST = {
        self:setMessageInfo({
            MESSAGE = self.TEXT.FURY_MESSAGE or "攻撃速度・回避率・クリティカル率アップ",
            DURATION = 10
        })
    }

end

--------[[バフ]]--------
function class:setBuffBoxList(event)
    self.RAGE_BUFF_LIST = {
        [1] = {
            ID = 501513,
            BUFF_ID = 23,
            VALUE = -100,
            DURATION = 99999,
            ICON = 188,
            FUNC = function(buff) buff:addAnimationWithFile("effect/aura1.json","aura2") end
        },
        [2] = {
            ID = 501514,
            BUFF_ID = 32, -- 命中率
            VALUE = 50,
            DURATION = 99999,
            ICON = 14
        }
    }
    self.FURY_BUFF_LIST = {
        [1] = {
            ID = 501515,
            BUFF_ID = 31,
            VALUE = 50,
            DURATION = 99999,
            ICON = 16
        },
        [2] = {
            ID = 501516,
            BUFF_ID = 22, -- クリティカル
            VALUE = 30,
            DURATION = 99999,
            ICON = 11
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
class.SUB_BAR_1 = 8000000
class.SUB_BAR_2 = 12000000
class.TELOP_SPAN = 30
function class:start_outer(event)
    event.unit:setAttackDelay(5)

    self.totalDamage = 0
    self.currentHP = self.SUB_BAR_1
    self.isSkill = false

    -- テロップ
    self.telopTimer = 0
    self.mes_telop1 = self.TEXT.telop1 or "ユニットが倒れた時は、入れ替えて戦いましょう。"
    self.mes_telop2 = self.TEXT.telop2 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"

    self:showMessage(self.START_MESSAGE_LIST)
end

function class:startWave(event)
    self.subBar =  self:newSubBar(event.unit)
    self:subBarControl(event.unit,self.subBar,self.currentHP,self.totalDamage)
    BattleControl:get():visibleHateTarget(false);
    BattleControl:get():setHateTargetIcon(14);
    return 1
end

function class:newSubBar(unit)
    local subBar = BattleControl:get():createSubBar();
    subBar:setPositionX(unit:getPositionX()+unit:getSkeleton():getBoneWorldPositionX("MAIN")+ 20)
    subBar:setPositionY(unit:getPositionY()+unit:getSkeleton():getBoneWorldPositionY("MAIN")- 100)
    subBar:setVisible(true)
    return subBar
end

function class:subBarControl(unit,subBar,HP,damage)
    if subBar == nil then return true end
    if self.isFury then
        subBar:setVisible(false);
        return true
    end

    subBar:setPositionX(unit:getPositionX()+unit:getSkeleton():getBoneWorldPositionX("MAIN")+ 20)
    subBar:setPositionY(unit:getPositionY()+unit:getSkeleton():getBoneWorldPositionY("MAIN")- 100)
    subBar:setPercent(100 * (HP - damage)/HP);
    subBar:setVisible(true)
    if HP - damage <= 0 then
        subBar:setVisible(false);
        return false
    end
    return true
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update_outer(event)
    event.unit:setReduceHitStop(100,1)
    self:telop(event.deltaTime)
    if not self:subBarControl(event.unit,self.subBar,self.currentHP,self.totalDamage) then
        if not self.isRage then return self:rage(event.unit) end
        if not self.isFury then return self:fury(event.unit) end
    end
end

function class:telop(deltaTime)
    if self.TELOP_SPAN < self.telopTimer then
        self.telopTimer = 0
        local rand = LuaUtilities.rand(1,3)
        if rand == 1 then
            RaidControl:get():addPauseMessage(self.mes_telop1 , 2.2);
        elseif rand == 2 then
            RaidControl:get():addPauseMessage(self.mes_telop2 , 2.2);
        end
    else
        self.telopTimer = self.telopTimer + deltaTime
    end
end

function class:rage(unit)
    self.isRage = true
    self.subBar = self:newSubBar(unit)
    self.totalDamage = 0
    self.currentHP = self.SUB_BAR_2
    self:execAddBuff(unit,self.RAGE_BUFF_LIST[1])
    self:execAddBuff(unit,self.RAGE_BUFF_LIST[2])
    self:showMessage(self.RAGE_MESSAGE_LIST)
    unit:setAttackDelay(4)
    return 1
end

function class:fury(unit)
    self.isFury = true
    self.totalDamage = 0
    self.currentHP = 999999999
    self:execAddBuff(unit,self.FURY_BUFF_LIST[1])
    self:execAddBuff(unit,self.FURY_BUFF_LIST[2])
    self:showMessage(self.FURY_MESSAGE_LIST)
    unit:setAttackDelay(3)
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "addSP" then  self:addSP(event.unit) end
    if event.spineEvent == "startCounterA" then  self:startCounterA(event.unit) end
    if event.spineEvent == "startCounterB" then  self:startCounterB(event.unit) end
    if event.spineEvent == "endCounterA" then  self:endCounterA() end
    if event.spineEvent == "endCounterB" then  self:endCounterB() end
    if event.spineEvent == "setupAnimation" then  self:setupAnimation() end
    if event.spineEvent == "showCounterInfoA" then  self:showCounterInfoA() end
    if event.spineEvent == "showCounterInfoB" then  self:showCounterInfoB() end
    if event.spineEvent == "specialEF" then  self:takeSpecialEffect(event.unit) end
    return 1;
end

function class:startCounterA(unit)
    unit:takeAnimation(0,"counterA",false);
    unit:takeAnimationEffect(0,"counterA",false);
    return 1;
end

function class:endCounterA()
    self.counterAFlag = false;
    return 1;
end

function class:startCounterB(unit)
    unit:takeAnimation(0,"counterB",false);
    unit:takeAnimationEffect(0,"counterB",false);
    return 1;
end

function class:endCounterB()
    self.counterBFlag = false;
    return 1;
end

function class:setupAnimation()
    self.gameUnit:setSetupAnimationNameEffect("");
    self.gameUnit:setSetupAnimationName("");
    return 1;
end

function class:showCounterInfoA()
    self.counterAFlag = true;
end

function class:showCounterInfoB()
    self.counterBFlag = true;
end

function class:takeSpecialEffect(unit)
    unit:addOrbitSystemCameraWithFile("../../effect/itemskill/itemskill2026","attack1",false);
    local orbit = unit:addOrbitSystemWithFile("../../effect/itemskill/itemskill2027","attack2");
    orbit:takeAnimation(0,"attack2",true);
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue_outer(event)
    if self.counterAFlag then
        local skillType = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillType;
        if skillType == 1 or skillType ==3 or skillType == 6 then
            self.counterAFlag = false;
            self:counter(event.unit,"setupA")
            event.unit:takeSkill(5);
        elseif skillType == 2 then
            event.unit:takeDamage();
        end
    end
    if self.counterBFlag then
        local skillType = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillType;
        if skillType == 1 or skillType ==3 or skillType == 6 then
            self.counterBFlag = false;
            self:counter(event.unit,"setupB")
            event.unit:takeSkill(4);
        elseif skillType == 2 then
            event.unit:takeDamage();
        end
    end

    if self.isSkill then
        self.totalDamage = self.totalDamage + event.value * 0.2
        return event.value * 0.2
    end
    self.totalDamage = self.totalDamage + event.value
    return event.value
end

function class:counter(unit,animationName)
    self.skillCheckFlg = true;
    unit:setSetupAnimationNameEffect(animationName);
    unit:setSetupAnimationName(animationName);
    unit:setHitStopTimeSelf(0);
    unit:setInvincibleTime(2);
end

function class:takeDamage(event)
    event.unit:setSetupAnimationNameEffect("");
    event.unit:setSetupAnimationName("");
    self.counterAFlag = false;
    self.counterBFlag = false;
    return 1;
end

----// attackDamageValue //-----------------------------------------------------------------------------
--敵の最大HPが8000より多いとき、与ダメージが ((最大HP-4000) ÷ 4000)^2.5 倍になる
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    if event.enemy:getCalcHPMAX() > 8000 then
        local maxHP = event.enemy:getCalcHPMAX()
        event.value = event.value * (((maxHP - 4000) / 4000) ^ 2.5)
    end
    return event.value
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.isSkill = true
    if self.subBar ~= nil then
        self.subBar:setVisible(false);
    end

    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillReroll(event.unit);
    end

    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end

    if event.index == 1 and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(1,1);
        return 0;
    end

    self:takeSkill_outer(event)

    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.addSpSkipFLG  = true
    self.fromHost      = false;
    self:skillActiveSkillSetter(event.unit, event.index);
    -- 【MEGA_D-9761】ボスの技の予告に、attackDamageValue の倍率（相手の最大 HP が 8000 を超えたら ((最大 HP − 4000) ÷ 4000) ^ 2.5）を入れる（表示専用。予測のたびに今の値で出す。古いアプリには無いので確かめてから呼ぶ）
    if event.unit.announceSkillRateBy then event.unit:announceSkillRateBy(1, 8000, 4000, 4000, 2.5) end
    return 1
end

function class:excuteAction(event)
    self.isSkill = false
    return 1
end

function class:takeSkill_outer(event)
    self.counterAFlag = false;
    self.counterBFlag = false;
end

class:publish();

return class;