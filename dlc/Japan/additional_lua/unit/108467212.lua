local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="超覚醒エミリア（花嫁ver）", version=2.8, id=108467212});
--class:inheritFromUnit("000");

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1084672121,
            BUFF_ID = 83,
            VALUE = 100,
            DURATION = 999999,
            ICON = 37
        },
        [2] = {
            ID = 1084672122,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 999999,
            ICON = 0
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self:setBuffBoxList();
    -- 蘇生時、まだ適用されていない場合に付与
    if event.unit:getParameter("846_revivalFlg") == "1" then
        event.unit:setParameter("846_revivalFlg","0");
        self:findLeader(event.unit);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.unit:getParameter("846_revivalFlg") == "" then
        event.unit:setParameter("846_revivalFlg","0");
    end

    if event.waves == 1 then
        self:findLeader(event.unit);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    -- 効果が適用中で対象のユニットが交代で入れ替わった場合にバフ情報を更新（レイド・クロスバトル用）
    if megast.Battle:getInstance():isRaid() or megast.Battle:getInstance():isCrossBattle() then
        -- 自分の空バフのvalue値のユニットをみて、そのユニットが自動蘇生を持っていなければ自動蘇生を使ったとみなし空バフを消す
        local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID);
        if cond ~= nil then
            if self:findReviveBuff(event.unit, cond, 1) == 2 then
                --summoner.Utility.messageByEnemy("2")
                event.unit:getTeamUnitCondition():removeCondition(cond)
            end
        end
        -- 自分が空バフを持っているかつ、誰も自動蘇生を持っていない場合は再度付与（交代した時用）
        local cond = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID);
        if cond ~= nil then
            if self:findReviveBuff(event.unit, cond, 0) == 0 then
                --summoner.Utility.messageByEnemy("3")
                self:findLeader(event.unit);
            end
        end
    end
    return 1;
end

function class:teamAddBuff(unit,buffBox)
    local targetTeam = self:getMyTaem(unit,true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
        end
    end
end

---------------------------------------------------------------------------------
-- changeIn
---------------------------------------------------------------------------------
function class:changeIn(event)
    if event.unit:getParameter("846_revivalFlg") == "" then
        event.unit:setParameter("846_revivalFlg","0");
        self:findLeader(event.unit);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- changeOut
---------------------------------------------------------------------------------
function class:changeOut(event)
    self:removeReviveBuff(event.unit);
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    -- 自身に他の自動蘇生がついてるとアビリティ消えちゃうのでその対策
    local cond = event.unit:getTeamUnitCondition():findConditionWithType(83);
    if cond == nil then
        self:removeReviveBuff(event.unit);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- ヘルパー関数
---------------------------------------------------------------------------------
--- バフ処理実行
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

--- チーム取得
function class:getMyTaem(unit,teamFlg)
    local unitTeam = unit:getTeam();
    local targetTeam = nil;
    if teamFlg then
        --自分PTからみて味方PTを取る
        if unitTeam == megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(true);
        else
            targetTeam = megast.Battle:getInstance():getTeam(false);
        end
    else
        --自分PTからみて敵PTを取る
        if unitTeam == megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(false);
        else
            targetTeam = megast.Battle:getInstance():getTeam(true);
        end
    end
    return targetTeam;
end

function class:findLeader(unit)
    local targetTeam = self:getMyTaem(unit,true);
    local tmp_unitID = nil;
    if megast.Battle:getInstance():isMultiPlay() or megast.Battle:getInstance():isRaid() or megast.Battle:getInstance():isCrossBattle() then
        ---レイド、クロスバトル、マルチ処理
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i,true);
            if myTeamUnit ~= nil then
                if myTeamUnit:getHP() > 0 then
                    local buff = self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[1]);
                    -- 同じキャラによる重複防止用のindex（左から優先になってる）
                    buff:setValue1(unit:getIndex());
                    -- 付与した対象のユニットIDを退避
                    tmp_unitID = myTeamUnit:getUnitID();
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
                    buff:setValue1(unit:getIndex());
                    -- 付与した対象のユニットIDを退避
                    tmp_unitID = myTeamUnit:getUnitID();
                    break
                end
            end
        end
    end
    -- 監視用空バフを自身に付与（レイド・クロスバトル用）
    if megast.Battle:getInstance():isRaid() or megast.Battle:getInstance():isCrossBattle() then
        local cond = unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[2].ID);
        if cond == nil then
            local buff = unit:getTeamUnitCondition():addCondition(self.BUFF_BOX_LIST[2].ID,0,0,999999,0);
            buff:setValue1(tonumber(tmp_unitID));
        else
            cond:setValue1(tmp_unitID);
        end
    end
    megast.Battle:getInstance():updateConditionView();
end

function class:findReviveBuff(unit,buff,checknum)
    local rtn = 0;
    local targetTeam = self:getMyTaem(unit,true);
    if checknum == 1 then
        -- 該当のユニットが持っているかのみチェック
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                --summoner.Utility.messageByEnemy(myTeamUnit:getUnitID() .. " " .. buff:getValue1())
                if myTeamUnit:getUnitID() == buff:getValue1() then
                    local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
                    if cond == nil then
                        -- ユニットがまだ存在していてバフを持っていない場合は違う数値で返す
                        rtn = 2;
                        break;
                    end
                end
            end
        end
    else
        -- 全てのユニットいずれかが持っているかチェック
        for i = 0,6 do
            local myTeamUnit = targetTeam:getTeamUnit(i);
            if myTeamUnit ~= nil then
                local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
                if cond ~= nil then
                    rtn = 1;
                end
            end
        end
    end
    return rtn;
end

function class:removeReviveBuff(unit)
    local targetTeam = self:getMyTaem(unit,true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local cond = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
            if cond ~= nil then
                --同キャラによる重複防止用
                if cond:getValue1() == unit:getIndex() then
                    -- まだ効果適用されていないので１に
                    myTeamUnit:getTeamUnitCondition():removeCondition(cond);
                    if unit:getParameter("846_revivalFlg") == "0" then
                        unit:setParameter("846_revivalFlg","1");
                    end
                end
            end
        end
    end
end



class:publish();

return class;