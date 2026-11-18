local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超覚醒シャルティア", version=1.3, id=107717412});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1077174121,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 120,
            ICON = 0
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    ---自動蘇生、コンティニュー分岐用フラグ
    self.deadFLG = -1
    self:setBuffBoxList()

    self.beforeDual = false
    self.gameUnit = event.unit
    event.unit:setSuperArtsCutInBorder(event.unit:getElementType(),event.unit:getElementType());
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    self:dualPosition(event.unit)
    local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID)
    if self.dual ~= nil and buff == nil then
        self:dualModeEnd()
    end
    return 1
end

function class:dualPosition(unit)
    if self.beforeDual and unit:getUnitState() ~= kUnitState_skill then
        self:dualModeBegin(unit)
    end
    if self.dual == nil then
        self.gameUnit:setParameter("229_myShadow","0")
        return
    end
    self.gameUnit:setParameter("229_myShadow","1")
    local vec = unit:getisPlayer() and 1 or -1
    local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec + (-150 * vec)
    local targety = unit:getPositionY()
    self.dual:setPosition(targetx,targety);
    self.dual:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
    self.dualEffect:setPosition(targetx,targety);
    self.dualEffect:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    ---もう一体を召喚
    if event.spineEvent == "dualMode" then
        self:dualModeBegin(event.unit)
    end
    if self.dual ~= nil then
        ---back
        if event.spineEvent == "back" then
            self.dual:takeAnimation(0,"back_E",true);
        end
        ---idle
        if event.spineEvent == "idle" then
            self.dual:takeAnimation(0,"idle_E",true);
        end
        ---front
        if event.spineEvent == "front" then
            self.dual:takeAnimation(0,"front_E",true);
        end
        ---attack1
        if event.spineEvent == "attack1" then
            self.dual:takeAnimation(0,"attack1_E",true);
            local damage = event.unit:addOrbitSystemWithFile("107717412","attack1_DAMAGE");
            damage:setDamageRateOffset(event.unit:getAttackDelay());
        end
        ---skill1
        if event.spineEvent == "skill1" then
            self.dual:takeAnimation(0,"skill1_E",true);
            self.dualEffect:takeAnimation(0,"2-skill1",true);
            event.unit:addOrbitSystemWithFile("107717412","skill1_DAMAGE");
        end
        ---skill2
        if event.spineEvent == "skill2" then
            self.dual:takeAnimation(0,"skill2_E",true);
            self.dualEffect:takeAnimation(0,"2-skill2",true);
            event.unit:addOrbitSystemWithFile("107717412","skill2_DAMAGE");
        end
        ---skill3
        if event.spineEvent == "skill3" then
            self.dual:takeAnimation(0,"skill3_E",true);
        end
        ---もう一体を消去
        if event.spineEvent == "dualModeEnd" then
            self:dualModeEnd()
        end
    end
    ---skill3のオービット攻撃
    if event.spineEvent == "orbit" then
        event.unit:addOrbitSystem("skill3orbit",0);
        if self.dual ~= nil then
            --summoner.Utility.messageByEnemy("オービット")
            event.unit:addOrbitSystemWithFile("10771ef","skill3orbit_E");
        end
    end
    ---エフェクト終了
    if self.dualEffect ~= nil then
        if event.spineEvent == "empty" then
            self.dualEffect:takeAnimation(0,"empty",true);
        end
    end
    return 1;
end

function class:takeDamage(event)
    if self.dual ~= nil then
        self.dual:takeAnimation(0,"damage_E",true);
    end
    return 1;
end

function class:dualModeBegin(unit)
    self.beforeDual = false
    self:execAddBuff(unit,self.BUFF_BOX_LIST[1])
    self.dual = unit:addOrbitSystemWithFile("107717412","idle_E");
    self.dual:setOrbitType(4)
    self.dual:takeAnimation(0,"idle_E",true);
    if self.dualEffect == nil then
        self.dualEffect = unit:addOrbitSystemWithFile("10771ef","empty");
        self.dualEffect:setOrbitType(4)
        self.dualEffect:takeAnimation(0,"empty",true);
    end
    self:showTimer(unit,self.BUFF_BOX_LIST[1].ID)
    self:dualPosition(unit)
end

function class:dualModeEnd()
    if self.dual ~= nil then
        self.dual:takeAnimation(0,"vanish_E",false);
        self.dual = nil
    end
end

function class:showTimer(unit,buffId)
    unit:createBattleStatusChangeTimeCount(3,1,"battle_avatar_time_gray.png","battle_avatar_time.png",0,"unit/battle_trans_skill/frame_other.plist")
    unit:setTimerConditionId(buffId)
    unit:setBattleStatusTimerAutoInvisible(true)
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
    if event.index == 5 then
        self.beforeDual = true
    end
    return 1
end
--[[
---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    local cond = event.unit:getTeamUnitCondition():findConditionWithType(83);
    if cond == nil then
        self:dualModeEnd()
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1)
    end
    return 1
end

function class:receive4(args)
    self:dualModeEnd()
    return 1
end
]]--

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
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
end

function class:teamAddBuff(buffBox)
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,6 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox)
        end
    end
end


class:publish();

return class;