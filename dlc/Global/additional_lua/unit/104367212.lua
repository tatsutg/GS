local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ネアス", version=2.6, id=104367212});


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
    self.gameUnit = event.unit;
    self:setBuffBoxList();

    self.auraLevel = 1;
    self.auraFollowFLG = false;
    self.aura = nil;

    self.bgDarkOffFLG = false;      --- skill5中の背景暗転OFFフラグ
    self.bgDarkOffSkillFLG = false; --- skill状態に入ったかどうか
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---skill5終了時に背景暗転をONに戻す
    if self.bgDarkOffFLG then
        if event.unit:getUnitState() == kUnitState_skill then
            self.bgDarkOffSkillFLG = true;
        elseif self.bgDarkOffSkillFLG then
            self:restoreBackGroundDark();
            ---演出中にwave進行等でスキルが中断された場合に背景LWFを戻す
            BattleControl:get():restoreBackgroundLWF(event.unit,false,0,0.1,0.3);
        end
    end

    ---オーラ除去
    if self.aura ~= nil then
        if event.unit:getUnitState() ~= kUnitState_skill then
            self.aura:takeAnimation(0,"empty",false);
            self.aura = nil;
        end
    end
    ---オーラ位置
    self:auraPosition(event.unit);
    return 1;
end

---オーラ位置
function class:auraPosition(unit)
    if self.aura == nil then
        return;
    elseif self.auraLevel == 1 then
        self.auraFollowFLG = false;
        if self.aura ~= nil then
            self.aura = nil;
        end
        return;
    end

    local vec = unit:getisPlayer() and 1 or -1;
    local targetX = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
    local targetY = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPositionX(targetX);
    if self.auraFollowFLG then
        targetX = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
        targetY = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
        self.aura:setPosition(targetX,targetY);
        self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY());
    end
    self.aura:setZOrder(unit:getZOrder() + 1);
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "BGChange" then
        BattleControl:get():changeBackgroundLWF(8004360,event.unit,0,0.1,0.3);
    end

    if event.spineEvent == "BGChangeEnd" then
        self.skill5orbit = nil
        BattleControl:get():restoreBackgroundLWF(event.unit,false,0,0.1,0.3);
    end

    if event.spineEvent == "regaliaAura1" then
        self.auraLevel = 1;
        self:setAura(event.unit,self.auraLevel);
    end

    if event.spineEvent == "regaliaAura2" then
        self.auraLevel = 2;
        self:setAura(event.unit,self.auraLevel);
    end

    if event.spineEvent == "loop2" then
        self.auraFollowFLG = true;
    end
    return 1;
end

---オーラ表示
function class:setAura(unit,level)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"empty",false);
        self.aura = nil;
    end

    self.aura = unit:addOrbitSystemWithFile("RegaliaAura_Octopas","in"..level);
    self.aura:setOrbitType(4);
    self.aura:takeAnimation(0,"in"..level,true);
    self.aura:setChainAnimationData(0,"empty","in"..level,true);

    local vec = unit:getisPlayer() and 1 or -1;
    local targetX = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
    local targetY = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetX,targetY);
    self.auraFollowFLG = false;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 5 then
        ---skill5中は背景を暗くしない
        megast.Battle:getInstance():setBackGroundColor(60, 255, 255, 255);
        self.bgDarkOffFLG = true;
        self.bgDarkOffSkillFLG = false;
    end
    return 1;
end

---背景暗転をONに戻す（次のフレームから checkFog が再開）
function class:restoreBackGroundDark()
    megast.Battle:getInstance():setBackGroundColor(0, 255, 255, 255);
    self.bgDarkOffFLG = false;
    self.bgDarkOffSkillFLG = false;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    if self.bgDarkOffFLG then
        self:restoreBackGroundDark();
    end
    BattleControl:get():restoreBackgroundLWF(event.unit,false,0,0.1,0.3);
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"empty",false);
        self.aura = nil;
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    return 1;
end

function class:receive4(args)
    BattleControl:get():restoreBackgroundLWF(self.gameUnit,false,0,0.1,0.3);
    return 1;
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

---------------------------------------------------------------------------------
-- changeOut
---------------------------------------------------------------------------------
function class:changeOut(event)
    BattleControl:get():restoreBackgroundLWF(event.unit,false,0,0.1,0.3);
    megast.Battle:getInstance():setBackGroundColor(0, 255, 255, 255);
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"empty",false);
        self.aura = nil;
    end
    return 1;
end


class:publish();

return class;