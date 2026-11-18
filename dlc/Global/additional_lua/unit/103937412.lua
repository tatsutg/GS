local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ユナ", version=2.0, id=103937412});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 103937100,  --バフタイマー
            BUFF_ID = 142,  --スーパークリティカル率アップ
            VALUE = 70,
            DURATION = self.AURA_INTERVAL,
            ICON = 229
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self.aura = nil;
    self.isAura = false;
    self.timer = 0;
    self.AURA_INTERVAL = 77.7;
    self.skill5Flg = false;

    self.skill1Flg = false;
    self.skill1AddSpVal = 30;

    self.skill3Flg = false;
    self.defaultDamageRate = event.unit:getBurstSkill2():getDamageRate();

    self:setBuffBoxList();
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---スキル効果
    if self.skill1Flg and self.isAura then
        self.skill1Flg = false;
        event.unit:addSPWithPvpCorrection(self.skill1AddSpVal);
    end

    ---タイマー系
    if self.skill5Flg then
        self.skill5Flg = false;
        self:setTimer(event.unit);  --一時実装用コメントアウト
    end

    if self.isAura then
        self:auraTimer(event.deltaTime,event.unit);
    end
    return 1;
end

function class:setTimer(unit)
    self.isAura = true;
    self.timer = 0;
    self:addBuff(unit,self.BUFF_BOX_LIST);
    self:showTimer(unit,self.BUFF_BOX_LIST[1].ID);
end

function class:showTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_xp_trans_equipment_time_gray_103937412.png","battle_xp_trans_equipment_time_103937412.png",0,"unit/battle_trans_skill/frame_103937412.plist")
    unit:setTimerConditionId(buffId);
    unit:setBattleStatusTimerAutoInvisible(true);
end

function class:auraTimer(deltaTime,unit)
    if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.AURA_INTERVAL < self.timer then
            self.isAura = false;
            self.timer = 0;
            self:removeConditionAll(unit,self.BUFF_BOX_LIST);
        else
            self.timer = self.timer + deltaTime;
        end
    end
end

function class:addBuff(unit,buffBoxList)
    for i,buffBox in ipairs(buffBoxList) do
        self:execAddBuff(unit,buffBox);
    end
end

function class:removeConditionAll(unit,buffBoxList)
    for i,buffBox in ipairs(buffBoxList) do
        self:removeCondition(unit,buffBox.ID);
    end
end

-- バフ削除
function class:removeCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
        unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId));
        unit:resumeUnit();
    end
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    event.unit:setDamageRateOffset(1);
    event.unit:setBreakRate(1);
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    event.unit:setDamageRateOffset(1);
    event.unit:setBreakRate(1);
    if event.index == 1 then
        self.skill1Flg = true;
    elseif event.index == 2 then
        self.skill1Flg = false;
        event.unit:setDamageRateOffset(0.5);
        event.unit:setBreakRate(0.5);
    elseif event.index == 3 then
        event.unit:setDamageRateOffset(1);
        event.unit:setBreakRate(1);
        ---真奥義効果
        if self.isAura then
            event.unit:getBurstSkill2():setDamageRate(self.defaultDamageRate * 2);
        else
            event.unit:getBurstSkill2():setDamageRate(self.defaultDamageRate);
        end
    elseif event.index == 5 then
        self.skill5Flg = true;
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill2dice1" then
        local dice1 = event.unit:addOrbitSystem("skill2dice1",1);
        dice1:setHitCountMax(1);
        dice1:setEndAnimationName("skill2hit_a");
        dice1:setDamageRateOffset(0.25);
        dice1:setBreakRate(0.25);
    end

    if event.spineEvent == "Library_skill2dice2" then
        local dice2 = event.unit:addOrbitSystem("skill2dice2",1);
        dice2:setHitCountMax(1);
        dice2:setEndAnimationName("skill2hit_b");
        dice2:setDamageRateOffset(0.25);
        dice2:setBreakRate(0.25);
    end

    if event.spineEvent == "Library_skill3_1" then
        self:checkSkill3(event.unit);
    end

    if event.spineEvent == "Library_skill5_BG_a1" then
        local slot = event.unit:addOrbitSystem("skill5_BG_a1",0);
        if not event.unit:getisPlayer() then
            slot:getSkeleton():setScaleX(-1);
        end
    end

    if event.spineEvent == "Library_coins" then
        local coin = event.unit:addOrbitSystem("coins",0);
        if not event.unit:getisPlayer() then
            coin:getSkeleton():setScaleX(-1);
        end
    end
    return 1
end

function class:checkSkill3(unit)
    local card = nil;
    local boss = self:getIsBoss();
    if boss ~= nil  then
        if self:isHost()  then
            --0:フルハウス ,1:フォーカード ,2:ロイヤルストレートフラッシュ
            local num = self:enemyBossHpCheck(boss);
            local skillName = string.format("skill3_%d" ,num);
            card = unit:addOrbitSystem(skillName,0);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,num)
        end
    else
        if not unit:getisPlayer() then
            card = unit:addOrbitSystem("skill3_1b",0);
            --megast.Battle:getInstance():sendEventToLua(self.scriptID,1,4)
        else
            card = unit:addOrbitSystem("skill3_1",0);
            --megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0)
        end
    end
end

function class:isHost()
    local bool = false;
    if megast.Battle:getInstance():isHost() or megast.Battle:getInstance():isPvpHost() then
        bool = true;
    end
    return bool;
end

function class:getIsBoss()
    local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
    if boss ~= nil then
        return boss;
    end
    return nil;
end

function class:enemyBossHpCheck(boss)
    local FLG = 1;
    local per = boss:getHPPercent() * 100;
    if per <= 20 then
        FLG = 3;
    elseif per <= 50 then
        FLG = 2;
    end
    return FLG;
end

function class:receive1(args)
    if args.arg ~= 4 then
        local skillName = string.format("skill3_%d" ,args.arg);
        local card = self.gameUnit:addOrbitSystem(skillName,0);
    else
        local card = self.gameUnit:addOrbitSystem("skill3_1b",0);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    event.unit:getBurstSkill2():setDamageRate(self.defaultDamageRate);
    return 1;
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
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

    ---グループID関係1
    local targetCond = nil
    if buffBox.GROUP_ID ~= nil then
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getGroupID() == buffBox.GROUP_ID and not cond:getIsPassive() then
                    targetCond = cond
                end
            end
            ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
            if targetCond ~= nil then
                if targetCond:getPriority() <= buffBox.PRIORITY then
                    ---アビリティではない同グループID、優先度が自身以下のバフを見つけた場合
                    unit:getTeamUnitCondition():removeCondition(targetCond)
                else
                    ---アビリティではない同グループID、優先度が自身以上のバフを見つけた場合
                    return
                end
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

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    ---グループID関係2
    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
    return buff
end


class:publish();

return class;