local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="超覚醒シモン", version=2.8, id=104307512});


function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 10430701, --固有アビ
            BUFF_ID = 17, --与ダメ
            VALUE = 50,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 20
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self.skill7Flg = false;  --超ファントムバレット

    self.CHECK_ID = 104307
    self.checkTimer = 0
    self.skill1Flg = false
    self.skillAddSPValue = 25
    self:setBuffBoxList();
    event.unit:setCutinVoicePB("VOICE_FULLARTS_CUTIN_FB")
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---敵死亡判定
    self:checkDeath3(self:getAncestorUnit(event.unit),event.deltaTime);
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill and self.skill7Flg then
        self.skill7Flg = false;
    end
    return 1;
end

function class:checkDeath3(unit,deltaTime)
    self.checkTimer = self.checkTimer + deltaTime;
    if  self.checkTimer < 0.2 then return; end
    self.checkTimer = self.checkTimer - 0.2
    local targetList =  self:getTargetList(unit);
    for _,index in pairs(targetList) do
        if self:deadOrNew(unit,index) then
            self:execAddBuff(unit,self.BUFF_BOX_LIST[1]);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
            self:cleanUpTargetParam(unit,index);
        end
    end
    --self:influenceLastAttackChecker(unit);
end

function class:receive1(args)
    self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1]);
    return 1;
end

function class:getTargetList(unit)
    local key = self:createKey("lastAttackChecker",unit:getIndex(),"index");
    local lst = {};
    for i=0,7 do
        local param = unit:getParameter(key..i);
        if param ~= "" and param ~= nil and param ~= "error" then
            local lastAttackerIndex = tonumber(param);
            if lastAttackerIndex == unit:getIndex() then
                table.insert(lst,i);
            end
        end
    end
    return lst;
end

function class:createKey(key,index,key2)
    return key .. index .. key2;
end

function class:deadOrNew(unit,index)
    local target = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(index,true);
    local buffID = self.CHECK_ID + unit:getIndex();
    if target ~= nil then
        local buff = target:getTeamUnitCondition():findConditionWithID(buffID);
        if buff == nil then
            return true;
        end
    end
    return target == nil or target:getHP() <= 0;
end

function class:execAddStatus(unit,value)
    self.BUFF_BOX_LIST[1].VALUE = value;
    self:execAddBuff(unit,self.BUFF_BOX_LIST[1]);
end

function class:cleanUpTargetParam(unit,index)
    local key = self:createKey("lastAttackChecker",unit:getIndex(),"index")
    unit:setParameter(key..index,"-1");
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_PB_back" then
        event.unit:addOrbitSystem("PB_back",0);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 7 then
        self.skill7Flg = true;
    else
        self.skill7Flg = false;
    end
    return 1;
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    local myUnit = self:getAncestorUnit(event.unit);
    self:influenceLastAttackChecker(myUnit);
    local type = myUnit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if type == 3 or type == 6 then
        return event.value;
    end

    --Hitした相手HP%にって補正をかける
    if self.skill7Flg then
        if event.enemy:getHPPercent() * 100 <= 25 then
            event.value = event.value * 4;
        elseif event.enemy:getHPPercent() * 100 <= 50 then
            event.value = event.value * 2;
        end
    end
    return event.value;
end

function class:influenceLastAttackChecker(unit)
    if not megast.Battle:getInstance():isHost() then return end
    local buffID = self.CHECK_ID + unit:getIndex();
    for i=0,7 do
        local target = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i,true);
        if target ~= nil then
            local buff = target:getTeamUnitCondition():findConditionWithID(buffID);
            if buff == nil and target:getHP() > 0 then
                buff = target:getTeamUnitCondition():addCondition(buffID,21,1,99999,0);
                buff:setScriptID(179);
                buff:setValue1(unit:getIndex());
            end
        end
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    local myUnit = self:getAncestorUnit(event.unit);
    self:influenceLastAttackChecker(myUnit);
    local enemy = self:getAncestorUnit(event.enemy);
    local type = myUnit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if type == 3 or type == 6 then
        return event.value;
    end

    --Hitした相手HP%にって補正をかける
    if self.skill7Flg then
        if enemy:getHPPercent() * 100 <= 25 then
            event.value = event.value * 4;
        elseif enemy:getHPPercent() * 100 <= 50 then
            event.value = event.value * 2;
        end
    end
    return event.value;
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
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

function class:teamAddBuff(unit,buffBox)
    local targetTeam = self:getMyTaem(unit,true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
        end
    end
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



class:publish();

return class;