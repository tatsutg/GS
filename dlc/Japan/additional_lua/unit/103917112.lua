local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒アズエル", version=2.0, id=103917112});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 17,---与ダメージアップ
            VALUE = 0,
            DURATION = 30,
            ICON = 26,
            GROUP_ID = 3228,
            PRIORITY = 0
        },
        [2] = {
            ID = 0,
            BUFF_ID = 25,---ブレイク力割合
            VALUE = 150,
            DURATION = 30,
            ICON = 9,
            GROUP_ID = 3766,
            PRIORITY = 150
        },
        [3] = {
            ID = 0,
            BUFF_ID = 32,---命中率
            VALUE = 150,
            DURATION = 30,
            ICON = 14,
            GROUP_ID = 3192,
            PRIORITY = 150
        },
        [4] = {
            ID = 103914,
            BUFF_ID = 0,---FLG用
            VALUE = 0,
            DURATION = 30,
            ICON = 0
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList()
    self.itemUsed = {
        [0] = false,
        [1] = false,
        [2] = false,
    }
    self.explosionOrbit = {}
    self.explosionFLG = {}
    for i = 1,4 do
        self.explosionFLG[i] = false
    end
    self.defaultHitEffectName = event.unit:getHitEffectName()

    self:setRP(event.unit)

    self.skill5FLG = 0

    self.auraFollowFLG = false;
    return 1
end

function class:setRP(unit)
    unit:setRPEnable(true);
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.skill5FLG > 0 then
        ---オーラ関係
        if self.skill5FLG > 1 then
            local flg = self:execAddBuff(event.unit,self.BUFF_BOX_LIST[4])
            flg:setRemoveOnResetState(true);
            self:setAura(event.unit,self.skill5FLG - 1)
        end
        for i = 1,self.skill5FLG do
            self:teamAddBuffElement(event.unit,self.BUFF_BOX_LIST[i],1)
        end
        self.skill5FLG = 0
    end
    ---オーラ除去
    if self.aura ~= nil then
        local flg = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[4].ID)
        if flg == nil then
            self.aura:takeAnimation(0,"empty",false)
            self.aura = nil
        end
    end
    ---オーラ位置
    self:auraPosition(event.unit)
    return 1
end

function class:teamAddBuffElement(unit,buffBox,elementType)
    local myTeam = unit:getTeam()
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            if myTeamUnit:getElementType() == elementType then
                self:execAddBuff(myTeamUnit,buffBox)
            end
        end
    end
end

---オーラ表示
function class:setAura(unit,level)
    if self.aura ~= nil then
        self.aura:takeAnimation(0,"empty",false)
        self.aura = nil
    end
    self.aura = unit:addOrbitSystemWithFile("RegaliaAura","in"..level);
    self.aura:setOrbitType(4)
    self.aura:takeAnimation(0,"in"..level,true);
    self.aura:setChainAnimationData(0,"loop"..level,"in"..level,true)
    local vec = unit:getisPlayer() and 1 or -1
    local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetx,targety);
    self.auraFollowFLG = false;
end

---オーラ位置
function class:auraPosition(unit)
    if self.aura == nil then
        return
    end
    local vec = unit:getisPlayer() and 1 or -1
    local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPositionX(targetx);
    if self.auraFollowFLG then
        self.aura:setPositionY(targety);
        self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
    end
    self.aura:setZOrder(unit:getZOrder() + 1)
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if string.find(event.spineEvent,"Explosion") ~= nil then
        local strN = string.sub(event.spineEvent,10)
        self.explosionFLG[tonumber(strN)] = true
    end
    if event.spineEvent == "loop1" or event.spineEvent == "loop2" then
        self.auraFollowFLG = true;
    end
    return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    for i = 1,5 do
        if self.explosionFLG[i] then
            if self.explosionOrbit[i] == nil then
                self.explosionOrbit[i] = event.unit:addOrbitSystem("EXPLOSION")
                self.explosionOrbit[i]:takeAnimation(0,"empty",true);
                self.explosionOrbit[i]:setChainAnimationData(0,"empty","EXPLOSION",true)
            end
            self.explosionOrbit[i]:takeAnimation(0,"EXPLOSION",true);
            local x = event.enemy:getPositionX()
            local y = event.unit:getPositionY() + 80
            self.explosionOrbit[i]:setPosition(x,y);
            self.explosionOrbit[i]:setZOrder(event.enemy:getZOrder() + 1)
            self.explosionFLG[i] = false
        end
    end
    return event.value;
end
---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    event.unit:setHitEffectName("none")
    for i = 1,5 do
        self.explosionFLG[i] = false
    end
    return 1
end
---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    event.unit:setHitEffectName(self.defaultHitEffectName)
    if event.index == 1 then
        event.unit:setHitEffectName("none")
    end
    for i = 1,5 do
        self.explosionFLG[i] = false
    end
    if event.index == 5 then
        if self:getIsControll(event.unit) then
            self.BUFF_BOX_LIST[1].VALUE = event.unit:getRP()
            self.BUFF_BOX_LIST[1].PRIORITY = event.unit:getRP()
            if event.unit:getRP() >= 1 then
                self.skill5FLG = 1
            end
            if event.unit:getRP() >= 100 then
                self.skill5FLG = 2
            end
            if event.unit:getRP() == 300 then
                self.skill5FLG = 3
            end
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,event.unit:getRP());
        end
        event.unit:setRP(0)
    end
    return 1
end

function class:getIsControll(unit)
    return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

function class:receive1(args)
    self.BUFF_BOX_LIST[1].VALUE = args.arg
    self.BUFF_BOX_LIST[1].PRIORITY = args.arg
    if args.arg >= 1 then
        self.skill5FLG = 1
    end
    if args.arg >= 100 then
        self.skill5FLG = 2
    end
    if args.arg == 300 then
        self.skill5FLG = 3
    end
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

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end

    return buff;
end

class:publish();

return class;