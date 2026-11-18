local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒イグリット", version=2.6, id=108427512});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1084201,
            BUFF_ID = 83,
            VALUE = 100,
            DURATION = 999999,
            ICON = 37,
        },
    }
end

---------------------------------------------------------------------------------
-- firstIn
---------------------------------------------------------------------------------
function class:firstIn(event)
    event.unit:setNextAnimationName("in2")
    event.unit:setNextAnimationEffectName("empty")
    return 0;
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self:setBuffBoxList()
    -- 蘇生時、まだ適用されていない場合に付与
    if event.unit:getParameter("842_revivalFlg") == "1" then
        event.unit:setParameter("842_revivalFlg","0");
        self:findLeader(self.gameUnit)
    end
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.unit:getParameter("842_revivalFlg") == "" then
        event.unit:setParameter("842_revivalFlg","0");
    end

    if event.waves == 1 then
        self:findLeader(self.gameUnit)
    end
    return 1
end

---------------------------------------------------------------------------------
-- changeIn
---------------------------------------------------------------------------------
function class:changeIn(event)
    if event.unit:getParameter("842_revivalFlg") == "" then
        event.unit:setParameter("842_revivalFlg","0");
        self:findLeader(self.gameUnit)
    end
    return 1;
end

function class:findLeader(unit)
    local unitTeam = unit:getTeam()
    local tmp_unitID = nil
    local targetTeam = nil
    if unitTeam == megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true);
    else
        targetTeam = megast.Battle:getInstance():getTeam(false);
    end

    if megast.Battle:getInstance():isMultiPlay() or megast.Battle:getInstance():isRaid() or megast.Battle:getInstance():isCrossBattle() then
        ---レイド、クロスバトル、マルチ処理
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i,true)
            if myTeamUnit ~= nil then
                if myTeamUnit:getHP() > 0 then
                    local buff = self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[1]);
                    -- 同じキャラによる重複防止用のindex（左から優先になってる）
                    buff:setValue1(self.gameUnit:getIndex());
                    -- 付与した対象のユニットIDを退避
                    tmp_unitID = myTeamUnit:getUnitID()
                    break
                end
            end
        end
    else
        ---通常処理
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit:getIsLeader() then
                    local buff = self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[1]);
                    -- 同じキャラによる重複防止用のindex（左から優先になってる）
                    buff:setValue1(self.gameUnit:getIndex());
                    -- 付与した対象のユニットIDを退避
                    tmp_unitID = myTeamUnit:getUnitID()
                    break
                end
            end
        end
    end

    -- 監視用空バフを自身に付与（レイド・クロスバトル用）
    if megast.Battle:getInstance():isRaid() or megast.Battle:getInstance():isCrossBattle() then
        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(1084202);
        if cond == nil then
            local buff = self.gameUnit:getTeamUnitCondition():addCondition(1084202,0,0,999999,0);
            buff:setValue1(tonumber(tmp_unitID));
        else
            cond:setValue1(tmp_unitID)
        end
    end
    megast.Battle:getInstance():updateConditionView();

end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    -- 効果が適用中で対象のユニットが交代で入れ替わった場合にバフ情報を更新（レイド・クロスバトル用）
    if megast.Battle:getInstance():isRaid() or megast.Battle:getInstance():isCrossBattle() then
        -- 自分の空バフのvalue値のユニットをみて、そのユニットが自動蘇生を持っていなければ自動蘇生を使ったとみなし空バフを消す
        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(1084202);
        if cond ~= nil then
            if self:findReviveBuff(self.gameUnit, cond, 1) == 2 then
                --summoner.Utility.messageByEnemy("2")
                self.gameUnit:getTeamUnitCondition():removeCondition(cond)
            end
        end

        -- 自分が空バフを持っているかつ、誰も自動蘇生を持っていない場合は再度付与（交代した時用）
        local cond = self.gameUnit:getTeamUnitCondition():findConditionWithID(1084202);
        if cond ~= nil then
            if self:findReviveBuff(self.gameUnit, cond, 0) == 0 then
                --summoner.Utility.messageByEnemy("3")
                self:findLeader(self.gameUnit)
            end
        end
    end

    return 1
end

function class:findReviveBuff(unit, buff, checknum)
    local rtn = 0
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam == megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true);
    else
        targetTeam = megast.Battle:getInstance():getTeam(false);
    end

    if checknum == 1 then
        -- 該当のユニットが持っているかのみチェック
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                --summoner.Utility.messageByEnemy(myTeamUnit:getUnitID() .. " " .. buff:getValue1())
                if myTeamUnit:getUnitID() == buff:getValue1() then
                    local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
                    if cond == nil then
                        -- ユニットがまだ存在していてバフを持っていない場合は違う数値で返す
                        rtn = 2
                        break
                    end
                end
            end
        end
    else
        -- 全てのユニットいずれかが持っているかチェック
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
                if cond ~= nil then
                    rtn = 1
                end
            end
        end
    end

    return rtn
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    return 1
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    return event.value
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    -- 自身に他の自動蘇生がついてるとアビリティ消えちゃうのでその対策
    local cond = self.gameUnit:getTeamUnitCondition():findConditionWithType(83);
    if cond == nil then
        self:removeReviveBuff(self.gameUnit)
    end
    return 1
end

---------------------------------------------------------------------------------
-- changeOut
---------------------------------------------------------------------------------
function class:changeOut(event)
    self:removeReviveBuff(self.gameUnit)
    return 1;
end

function class:removeReviveBuff(unit)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam == megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true);
    else
        targetTeam = megast.Battle:getInstance():getTeam(false);
    end

    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
            if cond ~= nil then
                --同キャラによる重複防止用
                if cond:getValue1() == self.gameUnit:getIndex() then
                    -- まだ効果適用されていないので１に
                    myTeamUnit:getTeamUnitCondition():removeCondition(cond)
                    if self.gameUnit:getParameter("842_revivalFlg") == "0" then
                        self.gameUnit:setParameter("842_revivalFlg","1");
                    end
                end
            end
        end
    end
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