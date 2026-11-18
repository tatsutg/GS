--@additionalEnemy,4000343,4000344,4000347,4000348,4000349,4000350,4000351
--[[
    神殿/植物/超級
]]
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local enemy = Bootstrap.createEnemyClass({label="植物兄", version=1.5, id=4000352})

--=====================================================================================================
--難易度で変わるもの
--=====================================================================================================


--１度の召喚で呼ばれるユニットの最大数　１〜４で指定
enemy.SUMMON_CNT_MAX = 4;
enemy.HIDE_TIME_MAX = 20;
enemy.CRITICAL_BORDER = 100000;
enemy.skill2FixedDamage = 350;

--[召喚される敵のエネミーID] = 重み
enemy.ENEMYS = {
    [4000343] = 50,--ラグドベイオス   奥義ゲージ吸収 
    [4000344] = 50,--モルドーラ　     大ダメージ
    [4000347] = 50,--メオール　       全体回復
    [4000348] = 50,--コログラン　     行動速度ダウン
    [4000349] = 50,--ログボード　     防御ダウン
    [4000350] = 50,--ドゥーラ　       封印
    [4000351] = 50--キングモキュオン　 呪い
}



--開始直後の退場メッセージ
enemy.FIRST_MESSAGES = {
    {
        MESSAGE = enemy.TEXT.mess1 or "no text",
        COLOR = Color.green,
        DURATION = 5
    }
}

--帰ってきた時のメッセージ
enemy.BACK_MESSAGES = {
    {
        MESSAGE = enemy.TEXT.mess2 or "no text",
        COLOR = Color.green,
        DURATION = 5
    }
}

--２０秒チャレンジ失敗で帰ってきた時のメッセージ
enemy.FAILD_MESSAGES = {
    {
        MESSAGE = enemy.TEXT.mess5 or "no text",
        COLOR = Color.green,
        DURATION = 5
    },
    {
        MESSAGE = enemy.TEXT.mess6 or "no text",
        COLOR = Color.red,
        DURATION = 5
    },
    {
        MESSAGE = enemy.TEXT.mess7 or "no text",
        COLOR = Color.red,
        DURATION = 5
    }
}


--HP６０％時のメッセージ
enemy.SUMMON_MESSAGES = {
    {
        MESSAGE = enemy.TEXT.mess3 or "no text",
        COLOR = Color.green,
        DURATION = 5
    }
}

--怒り時のメッセージ
enemy.RAGE_MESSAGES = {
    {
        MESSAGE = enemy.TEXT.mess4 or "no text",
        COLOR = Color.green,
        DURATION = 5
    }
}

--怒り時にかかるバフ内容
enemy.RAGE_BUFF_ARGS = {
    {
        ID = 40001174,
        EFID = 28,         --速度アップ
        VALUE = 20,        --効果量
        DURATION = 9999999,
        ICON = 7,
        EFFECT = 50009
    }
}

--２０秒チャレンジ失敗時にかかるバフ内容
enemy.SPECIAL_BUFF_ARGS = {
    {
        ID = 40001173,
        EFID = 17,         --攻撃アップ
        VALUE = 50,        --効果量
        DURATION = 50,
        ICON = 26
    },
    {
        ID = 40001174,
        EFID = 21,         --防御アップ
        VALUE = 50,        --効果量
        DURATION = 50,
        ICON = 20,
        EFFECT = 50009
    }
}

--=====================================================================================================
--攻撃分岐の確率
--=====================================================================================================

--使用する通常攻撃とその確率 [アニメーションの番号] = 重み
enemy.ATTACK_WEIGHTS = {
    [1] = 5,   --突き
    [2] = 25,   --衝撃波
    [3] = 10,   --切り上げ
    [4] = 15,   --落雷
    [5] = 25,   --３連突き（闇）
}

--使用する奥義とその確率　[アニメーションの番号] = 重み　skill2は今回は不使用
enemy.SKILL_WEIGHTS = {
    [2] = 60,
    [3] = 40,
}

--攻撃や奥義に設定されるスキルの番号
enemy.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    SKILL2 = 6,
    SKILL3 = 7,
}


--=====================================================================================================

function enemy:start(event)
    event.unit:setSPGainValue(0);
    self.spRizeValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.gameUnit = event.unit;
    self.isRage = false;
    self.summonUpdateTimer = 0;
    self.firstSummon = true;
    self.hideTimer = 0;
    self.hideUpdateTimer = 0;
    self.criticalDamage = 0;--クリティカルで受けたダメージを覚えておく
    self.criticalCheckFlag = false;
    self.absorbFlg = false;
    self.engage = false; --交戦許可　隠れて戻ってくるまでの間は一切攻撃しないためのもの
    self.isShownFirstMessage = false;

    self.hpMarkers = {
        [60] = self.gameUnit:addNumHpMarker(0.6),
        [30] = self.gameUnit:addNumHpMarker(0.3)
    }
    self.HP_TRIGGERS = {
        [60] = "summon",
        [30] = "getRage"
    };

    self.firstSummonUnits = {
        [1] = 4000343,
        [2] = 4000344,
        [3] = 4000348,
        [4] = 4000349,
        [5] = 4000350,
        [6] = 4000351
    }

    return 1;
end

function enemy:startWave(event)
	event.unit.m_attackTimer = 20;
    self:startHide(event.unit);
    return 1;
end

function enemy:update(event)
    self:HPTriggersCheck(event.unit);
    if self.firstSummon and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        self:trySummon(event.unit,event.deltaTime);
    end
    if self.isHide then
        self:hideControll(event.unit,event.deltaTime);
    end
    if self:getIsHost() then
        self:criticalCheck(event.unit);
    end
    event.unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2　10割軽減
    local myTeam = event.unit:getTeam()
    local flg60 = false
    local flg30 = false
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local condition60 = myTeamUnit:getTeamUnitCondition():findConditionWithID(400035260);
            if condition60 ~= nil then
                flg60 = true
            end
            local condition30 = myTeamUnit:getTeamUnitCondition():findConditionWithID(400035230);
            if condition30 ~= nil then
                flg30 = true
            end
        end
    end
    if flg60 then
        event.unit:getTeamUnitCondition():addCondition(40003521,0,0,99999,0);
    else
        event.unit:getTeamUnitCondition():removeConditionWithID(40003521);
    end
    if flg30 then
        event.unit:getTeamUnitCondition():addCondition(40003522,0,0,99999,0);
    else
        event.unit:getTeamUnitCondition():removeConditionWithID(40003522);
    end
    return 1;
end

function enemy:attackDamageValue(event)
    if self.absorbFlg then
        local damage = event.enemy:getHP() - self.skill2FixedDamage > 1 and self.skill2FixedDamage or event.enemy:getHP() -1;
        event.unit:takeHeal(damage);
        return damage;
    end
    return event.value;
end

function enemy:takeDamage(event)
    self.absorbFlg = false;
    return 1;
end

function enemy:takeDamageValue(event)

    self:criticalDamageCheck(event);

    return event.value;
end

function enemy:takeBreakeDamageValue(event)

    return event.value;
end

function enemy:excuteAction(event)
    self.criticalCheckFlag = false;
    self.absorbFlg = false;
    return 1;
end

function enemy:takeIdle(event)
    --怒り時と通常時でidleモーションを変える
    if self.isRage then
        event.unit:setNextAnimationName("idle2");
    end
    return 1;
end



function enemy:dead(event)
    self:creanUpEnemy(event.unit);
    return 1;
end


--===================================================================================================================
--通常攻撃分岐//
--///////////

--攻撃分岐の判断です。ホストだけで行います。
--バリアは今は何も考えずにランダムで出しています。必要であればここを書き換えてください。
function enemy:attackBranch(unit)
    local attackIndex = Random.sampleWeighted(self.ATTACK_WEIGHTS);
    unit:takeAttack(attackIndex);
    return 0;
end

function enemy:takeAttack(event)
    if not self.engage then
    	event.unit:takeAnimation(0,"back2",false);
        return 0;
    end
    if not self.attackCheckFlg and self:getIsHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    return 1
end

function enemy:attackActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["ATTACK"..index]);
end

--===================================================================================================================
--スキル分岐//
--//////////

function enemy:skillBranch(unit)
    local skillIndex = Random.sampleWeighted(self.SKILL_WEIGHTS);
    if self.isRage then
    	skillIndex = 2;
    end
    unit:takeSkill(skillIndex)
    return 0;
end

function enemy:takeSkill(event)
    if not self.engage then
    	event.unit:takeAnimation(0,"back2",false);
        return 0;
    end
    if not self.skillCheckFlg and self:getIsHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end

    if event.index == 2 then
        self.absorbFlg = true;
    end

    self.skillCheckFlg = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    event.unit:setBurstState(kBurstState_active);--ゲスト側のステートが変わらない問題の対策

    return 1
end

function enemy:skillActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
end
--===================================================================================================================


function enemy:run (event)
    if event.spineEvent == "hide" then self:hide(event.unit) end
    if event.spineEvent == "addSP" then 
        self:addSP(event.unit) 
    end
    return 1;
end

function enemy:addSP(unit)
    if self.getIsHost() then
        unit:addSP(self.spRizeValue);
    end
    return 1;
end

--=========================================================================================================================================
--対クリティカルダメージ用メソッド

function enemy:criticalDamageCheck(event)
    if event.enemy:getTeamUnitCondition():getDamageAffectInfo().critical then
        self.criticalDamage = self.criticalDamage + event.value;
    end
end

function enemy:criticalCheck(unit)
    if self.criticalDamage >= self.CRITICAL_BORDER and not self.criticalCheckFlag then
        self:summon(unit);
        self.criticalCheckFlag = true;
    end
end
--===================================================================================================================

--===================================================================================================================
--HPトリガー
function enemy:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do

        if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
            if self:excuteTrigger(unit,self.HP_TRIGGERS[i]) then
                self.gameUnit:removeHpMarker(self.hpMarkers[i])
                self.HP_TRIGGERS[i] = nil;
            end
        end
    end

end

function enemy:excuteTrigger(unit,trigger)
    if trigger == "summon" then
        self:summon_AI60(unit);
        self:showSummonMessage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
        return true;
    end
    if trigger == "getRage" then
        self:summon_AI30(unit);
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    return false;
end

--===================================================================================================================
--怒り関係

function enemy:getRage(unit)
    self:addRageBuff(unit);
    self.isRage = true;
    self:showMessages(unit,self.RAGE_MESSAGES);
end

function enemy:addRageBuff(unit)
    for i, v in ipairs(self.RAGE_BUFF_ARGS) do
        self:addBuff(unit, v);
    end
end

function enemy:addBuff(unit,args)
    if args.EFFECT ~= nil then
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
end
--===================================================================================================================
--入退場
function enemy:startHide(unit)
    unit:takeAnimation(0,"back2",false);
    unit:setInvincibleTime(22);
    unit._ignoreBorder = true;
    self:showMessages(unit,self.FIRST_MESSAGES);
    self.isShownFirstMessage = true;
end

function enemy:hide(unit)
    self.isHide = true;
end

function enemy:hideControll(unit,deltaTime)
    unit:setPosition(-1000,-1000);
    unit:getSkeleton():setPosition(0,0);--見た目上のズレも無くす
    unit._ignoreBorder = true;--アニメーションの更新があっても外に居られるようにする
    self.hideTimer = self.hideTimer + deltaTime;
    self.hideUpdateTimer = self.hideUpdateTimer + deltaTime;
    if self.hideUpdateTimer >= 0.2 then
        self.hideUpdateTimer = 0;
        if self.hideTimer > self.HIDE_TIME_MAX then
            if self:getIsHost() then
                self:addSpecialBuff(unit);
                megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
            end
        end
        if not self.firstSummon and not self:isBuddyStillAlive(unit) then
            if self:getIsHost() then
                self:showSucsessMessage(unit);
                megast.Battle:getInstance():sendEventToLua(self.scriptID,1,1);
            end
        end
    end
    
end

function enemy:finishHide(unit)
    unit:setInvincibleTime(0);
    self.isHide = false;
    self.hideTimer = 0;
    unit:setPosition(-1000,-1000);
    unit._ignoreBorder = true;
    unit:takeAnimation(0,"in2",false);
    unit._ignoreBorder = true;
end

function enemy:isBuddyStillAlive(unit)
    for i=0,7 do
        local target = unit:getTeam():getTeamUnit(i);
        if target ~= nil and target ~= unit then
            return true;
        end
    end
    return false;
end

function enemy:addSpecialBuff(unit)
	self:finishHide(unit);
    self:showMessages(unit,self.FAILD_MESSAGES);
    for i, v in ipairs(self.SPECIAL_BUFF_ARGS) do
        self:addBuff(unit, v);
    end
    self.engage = true;
end

function enemy:showSucsessMessage(unit)
	self:finishHide(unit);
    self:showMessages(unit,self.BACK_MESSAGES);
    self.engage = true;
end

--===================================================================================================================

function enemy:trySummon(unit,deltaTime)
    self.summonUpdateTimer = self.summonUpdateTimer + deltaTime;
    if self.summonUpdateTimer >= 0.2 then
        self.summonUpdateTimer = 0;
        self:summonByList(unit,self.firstSummonUnits);
        if table.maxn(self.firstSummonUnits) <= 0 then
            self.firstSummon = false;
        end
    end
end


--ユニットを召喚
function enemy:summon(unit)
    if not self:getIsHost() then
        return;
    end

    local cnt = 0;
    for i = 0, 4 do
        if unit:getTeam():getTeamUnit(i) == nil then
            local enemyID = Random.sampleWeighted(self.ENEMYS);
             unit:getTeam():addUnit(i,enemyID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
             cnt = cnt + 1; 
             if cnt >= self.SUMMON_CNT_MAX then
                break;
             end
        end
    end
end

function enemy:summon_AI60(unit)
    if not self:getIsHost() then
        return;
    end

    local cnt = 0;
    for i = 0, 4 do
        if unit:getTeam():getTeamUnit(i) == nil then
            local enemyID = Random.sampleWeighted(self.ENEMYS);
            unit:getTeam():addUnit(i,enemyID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
            unit:getTeam():getTeamUnit(i):getTeamUnitCondition():addCondition(400035260,0,0,99999,0);
            cnt = cnt + 1;
            if cnt >= self.SUMMON_CNT_MAX then
                break;
            end
        end
    end
end

function enemy:summon_AI30(unit)
    if not self:getIsHost() then
        return;
    end

    local cnt = 0;
    for i = 0, 4 do
        if unit:getTeam():getTeamUnit(i) == nil then
            local enemyID = Random.sampleWeighted(self.ENEMYS);
            unit:getTeam():addUnit(i,enemyID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
            unit:getTeam():getTeamUnit(i):getTeamUnitCondition():addCondition(400035230,0,0,99999,0);
            cnt = cnt + 1;
            if cnt >= self.SUMMON_CNT_MAX then
                break;
            end
        end
    end
end

--リスト化されたユニットを召喚　参照渡しなのでリストは破壊される
function enemy:summonByList(unit,list)
    if not self:getIsHost() then
        return;
    end

    local cnt = table.maxn(list);
    for i = 0, 3 do
        if unit:getTeam():getTeamUnit(i) == nil then
            local enemyID = list[cnt];
             unit:getTeam():addUnit(i,enemyID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
             table.remove(list,cnt);
             cnt = cnt - 1; 
             if cnt <= 0 then
                break;
             end
        end
    end
end

function enemy:creanUpEnemy(unit)
    for i = 0, 5 do
        local enemy = unit:getTeam():getTeamUnit(i,true);--無敵や出現中でも殺せるように第二引数はtrue
        if enemy ~= nil then
            enemy:setHP(0);
        end
    end
end

function enemy:showSummonMessage(unit)
    self:showMessages(unit,self.SUMMON_MESSAGES);
end

--===================================================================================================================
function enemy:showMessages(unit, messages)
    for i, v in ipairs(messages) do
        Utility.messageByEnemy(v.MESSAGE, v.DURATION, v.COLOR);
    end
end

--===================================================================================================================

function enemy:receive1(args)
    if args.arg == 0 then
        self:addSpecialBuff(self.gameUnit);
    else
        self:showSucsessMessage(self.gameUnit);
    end
    return 1;
end

function enemy:receive2(args)
    self:showSummonMessage(self.gameUnit);
    return 1;
end

function enemy:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end


function enemy:getIsHost()
    return megast.Battle:getInstance():isHost();
end


enemy:publish()
return enemy
