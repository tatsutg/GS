local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒蟇郡苛", version=2.0, id=107957512});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0000,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.orbit = nil

    self.HEAL_VALUE = 100
    self.SP_VALUE = 300
    self.BUFF_DURATION = 5
    self.BUFFID = 1079501

    self.gameUnit = event.unit
    self.iconUpdateTimer = 0
    self.regeneTimer = 0
    self.regeneDuration = 0
    self.targetHP = event.unit:getCalcHPMAX()
    if megast.Battle:getInstance():getBattleState() == kBattleState_active and event.unit:getParameter("lastLeave") ~= "TRUE" then
        local buff = event.unit:getTeamUnitCondition():addCondition(self.BUFFID,0,1,999999,179)
    end
    self.count = 0
    return 1
end

function class:startWave(event)
    if event.unit:getParameter("lastLeave") ~= "TRUE" then
        local buff = event.unit:getTeamUnitCondition():addCondition(self.BUFFID,0,1,999999,179);
    end
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---オービット関連
    --停止系状態異常バフ監視
    if self:findBuff(event.unit) and self.orbit ~= nil then
        self.orbit:takeAnimation(0,"empty",false)
        self.orbit = nil
    end

    --奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill and self.orbit ~= nil then
        self.orbit:takeAnimation(0,"empty",false)
        self.orbit = nil
    end

    if self.orbit ~= nil then
        self.orbit:setPosition(event.unit:getPositionX(),event.unit:getPositionY())
    end

    ---固有アビリティ
    self.iconUpdateTimer = self.iconUpdateTimer + event.deltaTime
    if self.iconUpdateTimer > 0.1 then
        self:updateBuffIcon(event.unit)
        self.iconUpdateTimer = 0
    end

    if self.regeneDuration > 0 and megast.Battle:getInstance():getBattleState() == kBattleState_active then
        self.regeneDuration = self.regeneDuration - event.deltaTime
        self.regeneTimer = self.regeneTimer + event.deltaTime
        if self.regeneTimer > 1 then
            self.regeneTimer = 0
            self:regenation(event.unit)
        end
    end
    return 1
end

function class:dead(event)
    if event.unit:getParameter("lastLeave") ~= "TRUE" and self:isControll(event.unit) then
        self:addBuff(event.unit)
        if not megast.Battle:getInstance():isPvp() then
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0)
        else
            megast.Battle:getInstance():sendEventToLua(self.scriptID,2,0)
        end
        event.unit:setHP(1)
        return 0
    end

    local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFFID)
    if cond ~= nil then
        if not megast.Battle:getInstance():isPvp() then
            if self:isControll(event.unit) then
                event.unit:setHP(1)
                return 0
            end
        else
            if cond:getTime() > 4 and self:isControll(event.unit) then
                event.unit:setHP(1)
                return 0
            end
        end
    end
    return 1
end

function class:addBuff(unit)
    self.targetHP = unit:getCalcHPMAX()
    local buff = unit:getTeamUnitCondition():addCondition(self.BUFFID,0,1,self.BUFF_DURATION,179)
    buff:setNumber(5)
    self.regeneDuration = self.BUFF_DURATION
    self.regeneTimer = 1
    unit:setParameter("lastLeave","TRUE")
end

function class:updateBuffIcon(unit)
    if unit:getParameter("lastLeave") ~= "TRUE" then
        return
    end
    local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFFID)
    if cond ~= nil then
        local num = math.ceil(cond:getTime())
        cond:setNumber(num)
        megast.Battle:getInstance():updateConditionView()
    end
end

function class:regenation(unit)
    self.count = self.count + 1
    if self.count <= 5 then
        --unit:addSPWithPvpCorrection(self.SP_VALUE/self.BUFF_DURATION);
        local rate = (100 + unit:getTeamUnitCondition():findConditionValue(115) + unit:getTeamUnitCondition():findConditionValue(110))/100
        unit:takeHeal(rate * self.targetHP * self.HEAL_VALUE/(100 * self.BUFF_DURATION))
    end
end

function class:isControll(unit)
    local ret = unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost())
    if megast.Battle:getInstance():isPvp() then
        ret = true
    end
    return ret
end

function class:receive1(args)
    self:addBuff(self.gameUnit,0)
    return 1
end

function class:receive2(args)
    local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFFID)
    if cond ~= nil then
        self:addBuff(self.gameUnit,0)
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_weapon_camera" then
        if self.orbit ~= nil then
            self.orbit:takeAnimation(0,"empty",false);
            self.orbit = nil
        end
        self.orbit = event.unit:addOrbitSystem("weapon_camera",0);
        self.orbit:takeAnimation(0,"weapon_camera",false);
    end

    if event.spineEvent == "orbitEmpty" then
        if self.orbit ~= nil then
            self.orbit:takeAnimation(0,"empty",false)
        end
        self.orbit = nil
    end
    return 1
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
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
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
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

    ---グループID関係2
    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
end

---状態異常監視
function class:findBuff(unit)
    local buffFlg = false
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        local count = 0
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                buffFlg = true
                return buffFlg
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
    return buffFlg
end

class:publish();

return class;