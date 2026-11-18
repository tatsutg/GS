local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="覚醒上条当麻", version=2.0, id=108176712});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1081701,
            BUFF_ID = 0,  --奥義カウント用
            VALUE = 0,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = self.powerUpCountMax
        },
        [2] = {
            ID = 1081702,
            BUFF_ID = 7,  --HP自然回復
            VALUE = 2000,
            DURATION = 25,
            ICON = 35,
        },
        [3] = {
            ID = 1081703,
            BUFF_ID = 13,  --攻撃力割合
            VALUE = 100,
            DURATION = 25,
            ICON = 3,
        },
    }
end

class.shieldCountMAX = 5;   -- シールドエフェクト発生回数
class.shieldLoopCount = 5;   -- シールドエフェクト種類数（5が最大値）
class.powerUpCountMax = 15;     -- 奥義使用時カウント最大値
class.skill5PowerPoint = 1500; -- 超奥義ダメージ率基礎値

-- 根性用
class.BUFF_DURATION = 5;
class.BUFFID = 1081704;
class.SP_VALUE = 100;

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    -- シールド表示用
    self.shieldFlg = false;
    self.shieldCount = 0;
    self.shieldTotalCount = 0;
    -- ガラス表示用
    self.glassFlg = false;
    -- スキル用
    self.skill1Flg = false
    if event.unit:getParameter("skill1Flg") == "" then
        event.unit:setParameter("skill1Flg","false")
    end
    self.skill1BpBonus = 50
    -- 奥義用
    self.powerUpCount = 0
    self.skill2Flg = false
    self.skill5Flg = false
    -- 根性用
    self.addFlg = false
    self.iconUpdateTimer = 0;
    if megast.Battle:getInstance():getBattleState() == kBattleState_active and event.unit:getParameter("lastLeave") ~= "TRUE" then
        local buff = event.unit:getTeamUnitCondition():addCondition(self.BUFFID,0,1,999999,179);
    end

    self:setBuffBoxList()
    --event.unit:setSuperArtsCutInBorder(event.unit:getElementType(),event.unit:getElementType());
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    self:setStartWaveParameter(event.unit)
    return 1
end

function class:setStartWaveParameter(unit)
    if unit:getParameter("skill1Flg") == "true" then
        self.skill1Flg = false
        unit:setParameter("skill1Flg","false")
    end

    if unit:getParameter("lastLeave") ~= "TRUE" then
        local buff = unit:getTeamUnitCondition():addCondition(self.BUFFID,0,1,999999,179);
    end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.shieldFlg and self:checkDbuff(event.unit) then
        self.shieldFlg = false;
        self.shieldCount = 0;
        self.shieldTotalCount = 0;
    end

    if self.skill1Flg then
        self.skill1Flg = false
        --event.unit:addSPWithPvpCorrection(30)
        if event.unit:getParameter("skill1Flg") == "false" then
            event.unit:setParameter("skill1Flg","true")
            event.unit:addSPWithPvpCorrection(self.skill1BpBonus)
        end
    end

    --[[
    if self.skill2Flg then
        self.skill2Flg = false
        self.powerUpCount = self.powerUpCount + 1
        if self.powerUpCount >= self.powerUpCountMax then
            self.powerUpCount = self.powerUpCountMax
        end
        self:execAddBuff(event.unit,self.BUFF_BOX_LIST[1])
    end
    ]]

    if self.skill5Flg  then
        self.skill5Flg = false
        if event.unit:getActiveBattleSkill() ~= nil then
            event.unit:getActiveBattleSkill():setDamageRate(self.skill5PowerPoint + 100 * self.powerUpCount)
        end
    end

    self.iconUpdateTimer = self.iconUpdateTimer + event.deltaTime;
    if self.iconUpdateTimer > 0.1 then
        self:updateBuffIcon(event.unit);
        self.iconUpdateTimer = 0;
    end

    return 1
end

function class:updateBuffIcon(unit)
    if unit:getParameter("lastLeave") ~= "TRUE" then
        return;
    end
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFFID);
    if cond ~= nil then
        local num = math.ceil(cond:getTime());
        cond:setNumber(num);
        megast.Battle:getInstance():updateConditionView();
    end
    if self.addFlg and unit:getHP() > 0 then
        unit:addSPWithPvpCorrection(self.SP_VALUE);
        self.addFlg = false
    end
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.shieldFlg = false;
    self.glassFlg = false;
    self.shieldCount = 0;
    self.shieldTotalCount = 0;
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    self.shieldFlg = false;
    self.glassFlg = false;
    self.shieldCount = 0;
    self.shieldTotalCount = 0;
    if event.index == 1 then
        self.skill1Flg = true
    elseif event.index == 2 then
        self.skill1Flg = false
        --self.skill2Flg = true
    elseif event.index == 3 then
        self.skill1Flg = false
        self.skill2Flg = false
    elseif event.index == 5 then
        self.skill1Flg = false
        self.skill2Flg = false
        self.skill5Flg = true
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    -- 奥義用 受けたらシールド出す
    if self.shieldFlg and self:isControll(event.unit) then
        self.shieldCount = self.shieldCount + 1;
        self.shieldTotalCount = self.shieldTotalCount + 1;
        if self.shieldCount > self.shieldLoopCount then
            self.shieldCount = 1;
        end
        if self.shieldTotalCount <= self.shieldCountMAX then
            self:addShield(event.unit, self.shieldCount)
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.shieldCount)
        end
    end
    return event.value
end

function class:addShield(unit, cnt)
    local str = "shield" .. cnt
    local obit = unit:addOrbitSystem(str);
    obit:takeAnimation(0,str,false);
    local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN") - 60;
    obit:setPosition(targetx,targety);
    obit:setAutoZOrder(true);
end

function class:receive1(args)
    self:addShield(self.gameUnit, args.arg)
    return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    -- 当たったらガラス出す
    if self.glassFlg then
        event.unit:addOrbitSystem("glass");
        self.glassFlg = false;
    end
    return event.value;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    -- 奥義用
    if event.spineEvent == "SKILL2" then
        self.shieldFlg = true;
    end
    if event.spineEvent == "SKILL2END" then
        self.shieldFlg = false;
        self.shieldCount = 0;
        self.shieldTotalCount = 0;
    end

    -- 超奥義用
    if event.spineEvent == "GLASS" then
        self.glassFlg = true;
    end
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)

    -- 根性用
    if event.unit:getParameter("lastLeave") ~= "TRUE" and self:isControll(event.unit) then
        self:addLeaveBuff(event.unit)
        if not megast.Battle:getInstance():isPvp() then
            megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0);
        else
            megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        end
        event.unit:setHP(1);
        return 0;
    end

    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFFID);
    if cond ~= nil then
        if not megast.Battle:getInstance():isPvp() then
            if self:isControll(event.unit) then
                event.unit:setHP(1);
                return 0;
            end
        else
            if cond:getTime() > 4 and self:isControll(event.unit) then
                event.unit:setHP(1);
                return 0;
            end
        end
    end

    self.powerUpCount = 0
    event.unit:getTeamUnitCondition():removeConditionWithID(self.BUFF_BOX_LIST[1].ID)
    return 1
end

function class:receive2(args)
    self:addLeaveBuff(self.gameUnit,0);
    return 1;
end

function class:receive3(args)
    local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFFID);
    if cond ~= nil then
        self:addLeaveBuff(self.gameUnit,0);
    end
    return 1;
end

function class:addLeaveBuff(unit)
    local buff = unit:getTeamUnitCondition():addCondition(self.BUFFID,0,1,self.BUFF_DURATION,179);
    buff:setNumber(self.BUFF_DURATION);
    --self:execAddBuff(unit,self.BUFF_BOX_LIST[2])
    self.addFlg = true
    self.iconUpdateTimer = 0
    self:execAddBuff(unit,self.BUFF_BOX_LIST[3])
    unit:setParameter("lastLeave","TRUE");
end

function class:isControll(unit)
    local ret = unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost())
    if megast.Battle:getInstance():isPvp() then
        ret = true
    end
    return ret
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