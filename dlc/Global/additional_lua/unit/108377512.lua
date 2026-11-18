local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒リムル（イースターver）", version=2.6, id=108377512});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0,
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList();
    self.gameUnit = event.unit;
    self.orbit = nil
    return 1;
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

    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill2_orbit" then
        if self.orbit ~= nil then
            self.orbit:takeAnimation(0,"empty",false);
            self.orbit = nil
        end
        self.orbit = event.unit:addOrbitSystem("skill2_orbit",0);
        self.orbit:takeAnimation(0,"skill2_orbit",false);
    end

    if event.spineEvent == "orbitEmpty" then
        if self.orbit ~= nil then
            self.orbit:takeAnimation(0,"empty",false)
        end
        self.orbit = nil
    end

    if event.spineEvent == "Library_skill3_orbit" then
        event.unit:addOrbitSystem("skill3_orbit",0)
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1;
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.GROUP_ID ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithGroupID(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.GROUP_ID,buffBox.PRIORITY);
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
    return buff
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