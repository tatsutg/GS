local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒エチカ", version=2.8, id=104207412});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 10420701,  --タイマー用バフ
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = self.TIMER_INTERVAL,
            ICON = 0
        },
        [2] = {
            ID = 10420702,
            BUFF_ID = 10,  --奥義ゲージ自然上昇
            VALUE = 8,
            DURATION = self.TIMER_INTERVAL,
            ICON = 36
        },
        [3] = {
            ID = 10420703,
            BUFF_ID = 115,  --回復力
            VALUE = 50,
            DURATION = self.TIMER_INTERVAL,
            ICON = 106
        }
    }
    self.SKILL2_BUFF = {
        [1] = {
            ID = 10420704,
            BUFF_ID = 7,  --自然回復
            VALUE = 400,
            DURATION = 10,
            ICON = 35,
            GROUP_ID = 1048,
            PRIORITY = 4000
        }
    }
    self.SKILL3_BUFF = {
        [1] = {
            ID = 10420705,
            BUFF_ID = 17,  --与ダメージ
            VALUE = self.skill3BuffVal_1,
            DURATION = 20,
            ICON = 26,
            GROUP_ID = 1029,
            PRIORITY = self.skill3BuffVal_1
        },
        [2] = {
            ID = 10420706,
            BUFF_ID = 17,  --光属性ダメージ
            VALUE = self.skill3BuffVal_2,
            DURATION = 20,
            ICON = 26,
            SCRIPT = {
                SCRIPT_ID = 70,
                VALUE1 = 4
            },
            GROUP_ID = 3894,
            PRIORITY = self.skill3BuffVal_2
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self.wingMode = false;
    self.skill2Flg = false;
    self.skill3Flg = false;
    self.skill5Flg = false;
    ---タイマー関係
    self.time = 0;
    self.TIMER_INTERVAL = 90;
    ---オービット関係
    self.wing = nil;
    self.orbitOff = false;
    self.orbitOnTime = 5;
    self.orbitCountTime = 0;
    self.orbitDamage = 100;
    self.skill5Damage = 1700;
    ---真奥義関係
    self.skill3BuffVal_1 = 100;
    self.skill3BuffVal_2 = 100;
    self.defaultDamageRate = event.unit:getBurstSkill2():getDamageRate();

    self:setBuffBoxList();
    event.unit:setSetupAnimationName("idle");
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if self:findWeapon(event.unit,50323900) then
        self.TIMER_INTERVAL = self.TIMER_INTERVAL + 20;
        self:setBuffBoxList();
    end
    return 1;
end

function class:findWeapon(unit,weaponId)
    local buff = unit:getTeamUnitCondition():findConditionWithID(weaponId);
    return buff ~= nil;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---奥義効果
    if self.skill2Flg then
        self.skill2Flg = false;
        --self:teamAddBuff(event.unit,self.SKILL2_BUFF[1]);
    end
    ---真奥義効果
    if self.skill3Flg then
        self.skill3Flg = false;
        self:setSkill3Buff(event.unit);
    end
    ---強化効果
    if event.unit:getLevel() >= 90 then
        ---時間経過でオービットを出す
        if self.wingMode then
            if not self.orbitOff and megast.Battle:getInstance():getBattleState() == kBattleState_active then
                --オービット処理
                --停止系状態異常バフ監視
                local buffFlg = self:findBuff(event.unit);
                if not buffFlg then
                    self:setWing(event.unit,event.deltaTime);
                    self:wingSetPosition(event.unit);
                elseif buffFlg and self.wing ~= nil then
                    self.wing:takeAnimation(0,"empty",false);
                    self.wing = nil;
                end
            elseif self.orbitOff then  --超奥義中でも翼剣のカウントはする
                self.orbitCountTime = self.orbitCountTime + event.deltaTime;
            end
            --奥義中か確認
            if self.orbitOff and event.unit:getUnitState() ~= kUnitState_skill then
                self.orbitOff = false;
            end
        end
        ---モード切り替えできなかった場合の補助
        --超奥義中か確認
        if self.skill5Flg and event.unit:getUnitState() ~= kUnitState_skill then
            self.skill5Flg = false;
            if not self.wingMode then
                self.wingMode = true;
                self.setTimerFlg = true;
                self.orbitCountTime = 0;
                event.unit:setSetupAnimationName("idle2");
            end
        end
        ---タイマー関係
        if self.setTimerFlg then
            self.setTimerFlg = false;
            self:setTimer(event.unit);
        end

        if self.wingMode then
            self:auraTimer(event.deltaTime,event.unit);
        end
    end
    return 1;
end

function class:setWing(unit,deltaTime)
    self.orbitCountTime = self.orbitCountTime + deltaTime;
    if self.orbitCountTime >= self.orbitOnTime then
        self.orbitCountTime = 0;
        if self.wing == nil then
            self.wing = unit:addOrbitSystem("WingbBlade2");
            self.wing:setActiveSkill(5);
            self.wing:setDamageRateOffset(self.orbitDamage/self.skill5Damage);
            self.wing:setBreakRate(0);
        end
    end
end

function class:wingSetPosition(unit)
    if self.wing == nil then
        return;
    end

    if self.wing ~= nil then
        local vec = unit:getisPlayer() and 1 or -1;
        local posX = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
        local posY = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
        self.wing:setPosition(posX,posY);
        self.wing:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY());
        self.wing:setZOrder(unit:getZOrder() + 1);
    end
end

function class:setTimer(unit)
    self.wingMode = true;
    self.time = 0;
    self:addBuff(unit,self.BUFF_BOX_LIST);
    self:showTimer(unit,self.BUFF_BOX_LIST[1].ID);
end

function class:showTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_xp_trans_equipment_time_gray_104207412.png","battle_xp_trans_equipment_time_104207412.png",0,"unit/battle_trans_skill/frame_104207412.plist");
    unit:setTimerConditionId(buffId);
    unit:setBattleStatusTimerAutoInvisible(true);
end

function class:auraTimer(deltaTime,unit)
    if self.wingMode and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.TIMER_INTERVAL < self.time then
            self.wingMode = false;
            self.time = 0;
            self:removeConditionAll(unit,self.BUFF_BOX_LIST);
            unit:setSetupAnimationName("idle");
        else
            self.time = self.time + deltaTime;
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

---状態異常監視
function class:findBuff(unit)
    local buffFlg = false;
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0;
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                buffFlg = true;
                return buffFlg;
            else
                flag = false;
            end
            ---100回以上ループした場合はbreak
            count = count + 1;
            if count > 100 then
                break;
            end
        end
    end
    return buffFlg;
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
    --装備攻撃は判定しない
    local type = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if type == 3 or type == 6 then
        return event.value;
    end

    if self.wingMode then
        --Hitした相手がボスではない場合は攻撃力に補正をかける
        local boss = megast.Battle:getInstance():getTeam(false):getBoss();
        if boss ~= event.enemy then
            event.value = event.value * 4;
        end
    end
    return event.value;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    if self.wingMode then
        event.unit:setNextAnimationName("attack2");
        event.unit:setNextAnimationEffectName("2-attack2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        if self.wingMode then
            event.unit:setNextAnimationName("skill1_2");
            event.unit:setNextAnimationEffectName("2-skill1_2");
        end
    elseif event.index == 2 then
        if self.wingMode then
            self.skill2Flg = true;
            event.unit:setNextAnimationName("skill2_2");
            event.unit:setNextAnimationEffectName("2-skill2_2");
        end
    elseif event.index == 3 then
        self.skill2Flg = false;
        self.skill3Flg = true;
        if self.wingMode then
            event.unit:setNextAnimationName("skill3_2");
            event.unit:setNextAnimationEffectName("2-skill3_2");
        end
    elseif event.index == 5 then
        self.skill2Flg = false;
        self.skill3Flg = false;
        if self.wingMode then
            self.orbitOff = true;
            self.setTimerFlg = true;
            event.unit:setNextAnimationName("skill5_2");
            event.unit:setNextAnimationEffectName("2-skill5_2");
        else
            self.skill5Flg = true;
        end
    end
    return 1;
end

function class:setSkill3Buff(unit)
    if self.wingMode then
        unit:getBurstSkill2():setDamageRate(self.defaultDamageRate * 2);
        self.SKILL3_BUFF[1].VALUE = self.skill3BuffVal_1 * 2;
        self.SKILL3_BUFF[2].VALUE = self.skill3BuffVal_2 * 2;
        self.SKILL3_BUFF[1].PRIORITY = self.skill3BuffVal_1 * 2;
        self.SKILL3_BUFF[2].PRIORITY = self.skill3BuffVal_2 * 2;
        self:teamAddBuff(unit,self.SKILL3_BUFF[1]);
        self:teamAddBuff(unit,self.SKILL3_BUFF[2]);
    else
        unit:getBurstSkill2():setDamageRate(self.defaultDamageRate);
        self.SKILL3_BUFF[1].VALUE = self.skill3BuffVal_1;
        self.SKILL3_BUFF[2].VALUE = self.skill3BuffVal_2;
        self.SKILL3_BUFF[1].PRIORITY = self.skill3BuffVal_1;
        self.SKILL3_BUFF[2].PRIORITY = self.skill3BuffVal_2;
        self:teamAddBuff(unit,self.SKILL3_BUFF[1]);
        self:teamAddBuff(unit,self.SKILL3_BUFF[2]);
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "wingMode" then
        self.wingMode = true;
        self.orbitOff = true;
        self.setTimerFlg = true;
        self.orbitCountTime = 0;
        event.unit:setSetupAnimationName("idle2");
    end
    if event.spineEvent == "orbitNil" then
        if self.wing ~= nil then
            self.wing = nil;
        end
        self.wing = nil;
    end
    return 1;
end

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    if self.wingMode then
        event.unit:setNextAnimationName("idle2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeFront
---------------------------------------------------------------------------------
function class:takeFront(event)
    if self.wingMode then
        event.unit:setNextAnimationName("front2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeBack
---------------------------------------------------------------------------------
function class:takeBack(event)
    if self.wingMode then
        event.unit:setNextAnimationName("back2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeCastItem
---------------------------------------------------------------------------------
function class:takeCastItem(event)
    if self.wingMode then
        event.unit:setNextAnimationName("cast2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
    if self.wingMode then
        event.unit:setNextAnimationName("damage2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeBreake
---------------------------------------------------------------------------------
function class:takeBreake(event)
    if self.wingMode then
        event.unit:setNextAnimationName("damage2");
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.wing ~= nil then
        self.wing = nil;
    end
    self.wing = nil;
    return 1;
end

function class:teamAddBuff(unit,buffBox)
    --自分PTからみて味方PTを取る
    local unitTeam = unit:getTeam();
    local targetTeam = nil
    if unitTeam == megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true);
    else
        targetTeam = megast.Battle:getInstance():getTeam(false);
    end

    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
        end
    end
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil;
    local count = 1;
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1;
            if count > buffBox.MAX then
                count = buffBox.MAX;
            end
        end
    end

    ---グループID関係1
    local targetCond = nil;
    if buffBox.GROUP_ID ~= nil then
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getGroupID() == buffBox.GROUP_ID and not cond:getIsPassive() then
                    targetCond = cond;
                end
            end
            ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
            if targetCond ~= nil then
                if targetCond:getPriority() <= buffBox.PRIORITY then
                    ---アビリティではない同グループID、優先度が自身以下のバフを見つけた場合
                    unit:getTeamUnitCondition():removeCondition(targetCond);
                else
                    ---アビリティではない同グループID、優先度が自身以上のバフを見つけた場合
                    return;
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
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID);
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1); end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2); end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3); end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4); end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5); end
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
        buffBox.FUNC(buff);
    end
    return buff;
end


class:publish();

return class;