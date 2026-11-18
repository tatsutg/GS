local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="神族の遺跡12層_冥獣ギリウス", version=2.6, id=2064016});
class:inheritFromUnit("unitBossBase");

---ジンガルム（2064015）の撃破カウントバフID
class.BOSS_COUNT_BUFF_ID = 206401504;

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK2 = 100 },                              ---スキル1 ヒートスピン
    },
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 },                               ---奥義2 サーマルインフェルノ
    },
}

class.ACTIVE_SKILLS = {
    ATTACK2 = 1,    ---ヒートスピン         (skill1のアニメを流用)
    SKILL2  = 2,    ---サーマルインフェルノ (skill2)
}

class.cutInSkill = {
}


---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        addSP = 20,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 4,            --アタックディレイ
        hitStop = 100,              --ヒットストップ・時止め無効
        freezeDead = 1,             --氷結状態でDead処理する（0で無効）
    };
end


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.GD = summoner.Utility.getGimmickJsonData(event.unit, self:getGimmickDefault());
    self:dump(self.GD);

    self.fromHost = false;
    self.gameUnit = event.unit;
    --------------------------------
    self.spValue = self.GD.addSP;---addSPの量
    if self.GD.attackDelay > 0 then
        event.unit:setAttackDelay(self.GD.attackDelay);---アタックディレイ
    end
    event.unit:addSP(self.GD.startAddSP);---戦闘開始時の奥義ゲージ量
    --------------------------------
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});

    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---氷結状態にするとDead処理（エネミーのHPはホスト権限なのでホストのみ）
    if self.GD.freezeDead > 0 and megast.Battle:getInstance():isHost() then
        if event.unit:getTeamUnitCondition():findConditionWithType(96) ~= nil then
            event.unit:setHP(0);
        end
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
-- SP加算は takeAttack() 側が担当する。
-- Spine側の addSP イベントをここでフックすると takeAttack の加算と二重になるため入れない。
function class:run(event)
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
-- dead はマルチ同期されないため、ホストが加算してゲストへ配る
function class:dead(event)
    if megast.Battle:getInstance():isHost() then
        self:addKillCountToBoss();
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,1);
    end
    return 1;
end

function class:receive6(args)
    self:addKillCountToBoss();
    return 1;
end

---ジンガルムの撃破カウントバフを加算する
---バフが存在しない＝HP75%ギミック中ではないので何もしない
function class:addKillCountToBoss()
    local enemyTeam = megast.Battle:getInstance():getTeam(false);
    for i = 0, 6 do
        local u = enemyTeam:getTeamUnit(i);
        if u ~= nil then
            local cond = u:getTeamUnitCondition():findConditionWithID(self.BOSS_COUNT_BUFF_ID);
            if cond ~= nil then
                cond:setNumber(cond:getNumber() + 1);
                megast.Battle:getInstance():updateConditionView();
                break;
            end
        end
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

    ---ヒートスピンは skill1 のアニメを使う
    if event.index == 2 then
        event.unit:setNextAnimationName("skill1");
        event.unit:setNextAnimationEffectName(event.unit:getEvolutionStage().."-skill1"); ---EFのアニメーション名に気をつける
    end

    self.fromHost = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    self:addSP(event.unit);
    return 1;
end

function class:attackReroll(unit)
    local attackIndex = self:getAttackIndex();
    ---現在の奥義ゲージ＋足される奥義ゲージが奥義ゲージMAX以上の時、movePatternState()を動かさない---
    if self.gameUnit:getBurstPoint() + self.spValue < self.gameUnit:getNeedSP() then
        self:movePatternState(self.ATTACK_SET_LIST,self.STATE_ATTACK);
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

    self.skillCheckFlg = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:skillReroll(unit)
    local skillIndex = self:getSkillIndex();
    self:movePatternState(self.SKILL_SET_LIST,self.STATE_SKILL);

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
    return event.value;
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    return event.value;
end

----// takeDamageValue //-----------------------------------------------------------------------------
-- クリティカルダメージはダメージ1にする
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);

    ---クリティカルダメージに対してダメージを1にする（skillAttribute==3 がクリティカル）
    local info = enemyUnit:getTeamUnitCondition():getDamageAffectInfo();
    if info.critical or info.skillAttribute == 3 then
        event.value = 1;
    end

    return event.value;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
-- マルチ用（event.enemy を持たないためクリティカル判定はできない）
---------------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        event.value = 0;
    end
    return event.value;
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit;
    else
        return self:getAncestorUnit(unit:getParentTeamUnit());
    end
end


--===================================================================================================================
-- 行動パターン
--===================================================================================================================
function class:movePatternState(SET_LIST,stateBox)
    stateBox.actCount = stateBox.actCount + 1;
    if #SET_LIST[stateBox.setChar] < stateBox.actCount then
        stateBox.actCount = 1;
        stateBox.setCount = stateBox.setCount + 1;
        if #stateBox.SET_WEIGHT < stateBox.setCount then
            stateBox.setCount = 1;
        end
        stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount]);
    end
end

class.STATE_ATTACK = {}
function class:initAttackWeight(...)
    local attackList = {...};
    self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT);
end

function class:getAttackIndex()
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    return tonumber(attackIndex);
end


class.STATE_SKILL = {}
function class:initSkillWeight(...)
    local skillList = {...};
    self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT);
end

function class:getSkillIndex()
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    return tonumber(skillIndex);
end

function class:initState(weightList)
    local state = {};
    state.SET_WEIGHT = weightList;
    state.actCount = 1;
    state.setCount = 1;
    state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount]);
    return state;
end


class:publish();

return class;
