local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ヴェナ", version=2.0, id=103927311});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 10392701,
            BUFF_ID = 98,  --ダメージ無効
            VALUE = self.skill2BuffValue,
            DURATION = self.buffTime,
            ICON = 24,
            EFFECT = 1,
            GROUP_ID = 2000,
            PRIORITY = 0
        },
        [2] = {
            ID = 10392702,
            BUFF_ID = 13,  --攻撃力割合
            VALUE = self.skill3BuffValue,
            DURATION = self.buffTime,
            ICON = 3,
            GROUP_ID = 3786,
            PRIORITY = self.skill3BuffValue
        },
        [3] = {
            ID = 10392703,
            BUFF_ID = 21,  --物理耐性
            VALUE = 100,
            DURATION = self.buffTime,
            ICON = 185,
            GROUP_ID = 2067,
            PRIORITY = 100,
            SCRIPT = {
                SCRIPT_ID = 2
            }
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.buffTime = 20
    self.skill2BuffValue = 2000
    self.skill3BuffValue = 150
    self.gameUnit = event.unit

    self.auraLevel = 1
    self:setSkillFlg()
    self:setBuffBoxList()
    self:setRP(event.unit)
    return 1
end

function class:setSkillFlg()
    self.skill2Flg = false
    self.skill3Flg = false
    self.skill5Flg = false
    self.skill2BuffFlg = true
    self.skill3BuffFlg = true
    self.skill5BuffFlg = true
    self.auraFollowFLG = false;
end

function class:setRP(unit)
    unit:setRPEnable(true);
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---奥義効果
    if self.skill2Flg then
        self.skill2Flg = false
        if self.skill2BuffFlg then
            if event.unit:getRP() >= 100 then
                self.skill2BuffFlg = false
                self.BUFF_BOX_LIST[1].VALUE = self.BUFF_BOX_LIST[1].VALUE * 2
            end
        end
        self:teamAddBuff(event.unit,self.BUFF_BOX_LIST[1])
    elseif self.skill3Flg then
        self.skill3Flg = false
        if self.skill3BuffFlg then
            if event.unit:getRP() >= 200 then
                self.skill3BuffFlg = false
                self.BUFF_BOX_LIST[2].VALUE = self.BUFF_BOX_LIST[2].VALUE * 2
                self.BUFF_BOX_LIST[2].PRIORITY = self.BUFF_BOX_LIST[2].PRIORITY * 2
            end
        end
        self:teamAddBuffElement(event.unit,self.BUFF_BOX_LIST[2],3)  --対象：樹属性
    elseif self.skill5Flg then
        self.skill5Flg = false
        if self.skill5BuffFlg then
            if event.unit:getRP() == 300 then
                self.skill5BuffFlg = false
                self.auraLevel = 2
                self.BUFF_BOX_LIST[3].VALUE = self.BUFF_BOX_LIST[3].VALUE * 2
                self.BUFF_BOX_LIST[3].PRIORITY = self.BUFF_BOX_LIST[3].PRIORITY * 2
            end
        end
        self:enemyAddBuff(event.unit,self.BUFF_BOX_LIST[3])
    end
    ---オーラ除去
    if self.aura ~= nil then
        if event.unit:getUnitState() ~= kUnitState_skill then
            self.aura:takeAnimation(0,"empty",false)
            self.aura = nil
        end
    end
    ---オーラ位置
    self:auraPosition(event.unit)
    return 1
end

function class:teamAddBuff(unit,buffBox)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

function class:teamAddBuffElement(unit,buffBox,elementType)
    local myTeam = unit:getTeam();
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getElementType() == elementType then
                self:execAddBuff(myTeamUnit,buffBox)
            end
        end
    end
end

function class:enemyAddBuff(unit,buffBox)
    local unitTeam = unit:getTeam()
    local targetTeam = nil
    if unitTeam ~= megast.Battle:getInstance():getTeam(true) then
        targetTeam = megast.Battle:getInstance():getTeam(true)
    else
        targetTeam = megast.Battle:getInstance():getTeam(false)
    end
    for i = 0,7 do
        local myTeamUnit = targetTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end

---オーラ表示
function class:setAura(unit,level)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"empty",false)
        self.aura = nil
    end
    self.aura = unit:addOrbitSystemWithFile("RegaliaAura_Moon","in"..level);
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"in"..level,true);
    self.aura:setChainAnimationData(0,"loop"..level,"in"..level,true)
    local vec = unit:getisPlayer() and 1 or -1
    local targetX = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("Aura_MAIN") * vec;
    local targetY = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetX,targetY + 185);
    self.auraFollowFLG = false;
end

---オーラ位置
function class:auraPosition(unit)
    if self.aura == nil then
        return
    end
    local vec = unit:getisPlayer() and 1 or -1
    local targetX = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("Aura_MAIN") * vec;
    local targetY = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPositionX(targetX);
    if self.auraFollowFLG then
        targetX = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
        targetY = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
        self.aura:setPosition(targetX,targetY);
        self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
    end
    self.aura:setZOrder(unit:getZOrder() + 1)
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "regaliaAuraOn" then
        self:setAura(event.unit,self.auraLevel)
    end

    if event.spineEvent == "loop1" or event.spineEvent == "loop2" then
        self.auraFollowFLG = true;
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 2 then
        self.skill2Flg = true
    elseif event.index == 3 then
        self.skill2Flg = false
        self.skill3Flg = true
    elseif event.index == 5 then
        self.skill2Flg = false
        self.skill3Flg = false
        self.skill5Flg = true
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
    return buff
end


class:publish();

return class;