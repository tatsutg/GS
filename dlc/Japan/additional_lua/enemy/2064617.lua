local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createEnemyClass({label="魔族の遺跡12層_HARD_ゴブル", version=2.8, id=2064617});
class:inheritFromUnit("unitBossBase");

---魔族の遺跡12層_HARD_ハイゴブル(2064616)の召喚用
---HPと威力（ハイゴブルの1/4のHP・スキル威力は半分）はデータ側で設定する

---ハイゴブル側の撃破カウントバフID（NORMALも同じバフIDを使う。同時に場に出ないため振り直し不要）
class.BOSS_COUNT_BUFF_ID = 206461601;

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
    DEFAULT = {
        { ATTACK1 = 100 },                              ---スキル1
    },
}

--使用する奥義とその確率
class.SKILL_SET_LIST = {
    DEFAULT = {
        { SKILL2 = 100 },                               ---奥義2
    },
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,    ---スキル1 (attack1)
    SKILL2  = 2,    ---奥義2   (skill2)
}

class.cutInSkill = {
}


--------[[バフ]]--------
-- 「場に2体以上いるとき、そのうち1体しかダメージを受けない」用のフラグ。
-- チーミングユニットのテンプレートと同じで、リーダー以外は無敵にする（当たり判定を消す）。
function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 206461701,                 ---リーダー以外
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        },
        [2] = {
            ID = 206461702,                 ---リーダー用
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        },
    }
end


---------------------------------------------------------------------------------
-- ギミックカラム
---------------------------------------------------------------------------------
function class:getGimmickDefault()
    return {
        addSP = 20,                 --SP獲得量
        startAddSP = 0,             --戦闘開始時の奥義ゲージ量
        attackDelay = 6,            --アタックディレイ（ダメージを受ける1体目）
        attackDelay2nd = 11,        --アタックディレイ（無敵の2体目）
        attackDelay3rd = 17,        --アタックディレイ（無敵の3体目以降）
        hitStop = 100,              --ヒットストップ・時止め無効
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

    self:setBuffBoxList();

    self:initAttackWeight({DEFAULT = 100});
    self:initSkillWeight({DEFAULT = 100});

    self.nowFriends = 1;

    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:findLeader(self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[2]);
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---場に2体以上いるとき、ダメージを受けるのは1体だけ（リーダー以外は無敵）
    self:findLeader(self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[2]);
    self:findFriends(self.BUFF_BOX_LIST[1],self.BUFF_BOX_LIST[2]);
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1;
end


--===================================================================================================================
-- チーミング（1体しかダメージを受けない）
--===================================================================================================================
function class:findLeader(buffBoxFlg,buffBoxLeader)
    local FLG = false;
    local myTeam = megast.Battle:getInstance():getTeam(false);
    ---リーダーバフを持つ個体がいるか確認
    for i = 0, 6 do
        local myTeamUnit = myTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            if myTeamUnit:getUnitID() == self.gameUnit:getUnitID() then
                local condLeader = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBoxLeader.ID);
                if condLeader ~= nil then
                    FLG = true;
                end
            end
        end
    end
    if FLG then
        ---いる場合はその個体の無敵とフラグを解除する
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                if myTeamUnit:getUnitID() == self.gameUnit:getUnitID() then
                    local condLeader = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBoxLeader.ID);
                    if condLeader ~= nil then
                        myTeamUnit:setInvincibleTime(0);
                        local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBoxFlg.ID);
                        if cond ~= nil then
                            myTeamUnit:getTeamUnitCondition():removeCondition(cond);
                        end
                    end
                    break;
                end
            end
        end
    else
        ---いない場合は一番小さいindexの個体がリーダーになる
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                if myTeamUnit:getUnitID() == self.gameUnit:getUnitID() then
                    ---Indexでリーダー決定
                    if myTeamUnit == self.gameUnit then
                        self.gameUnit:setInvincibleTime(0);
                        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(buffBoxFlg.ID);
                        if cond ~= nil then
                            self.gameUnit:getTeamUnitCondition():removeCondition(cond);
                        end
                        self:execAddBuff(self.gameUnit,buffBoxLeader);
                    end
                    break;
                end
            end
        end
    end
end

function class:findFriends(buffBoxFlg,buffBoxLeader)
    local condLeader = self.gameUnit:getTeamUnitCondition():findConditionWithID(buffBoxLeader.ID);
    if condLeader then
        self.gameUnit:setAttackDelay(self.GD.attackDelay);
        local count = 0;
        local myTeam = megast.Battle:getInstance():getTeam(false);
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                if myTeamUnit:getUnitID() == self.gameUnit:getUnitID() and myTeamUnit ~= self.gameUnit then
                    count = count + 1;
                    if count == 1 then
                        myTeamUnit:setAttackDelay(self.GD.attackDelay2nd);
                    elseif count >= 2 then
                        myTeamUnit:setAttackDelay(self.GD.attackDelay3rd);
                    end
                    ---リーダー以外は無敵にする（当たり判定を消す）
                    myTeamUnit:setInvincibleTime(99999);
                    local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(buffBoxFlg.ID);
                    if cond == nil then
                        self:execAddBuff(myTeamUnit,buffBoxFlg);
                    end
                end
            end
        end
        self.nowFriends = count + 1;
    end
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

---ハイゴブルの撃破カウントバフを加算する
---バフが存在しない＝カウント対象外（NORMALやハイゴブル撃破後）なので何もしない
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
    return 1;
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
-- ダメージを受けない個体はリーダー以外＝無敵なので、ここでの補正は行わない
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    return event.value;
end

----// takeMultiDamageValue //-----------------------------------------------------------------------------
function class:takeMultiDamageValue(event)
    if event.unit:getInvincibleTime() > 0 then
        return 0;
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
-- バフ
--===================================================================================================================
function class:execAddBuff(unit,buffBox)
    local buff = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID);
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1); end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2); end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3); end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4); end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5); end
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
