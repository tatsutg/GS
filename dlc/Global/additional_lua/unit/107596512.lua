local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="針目縫", version=1.3, id=107596512});

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
    ---自動蘇生、コンティニュー分岐用フラグ
    self.deadFLG = -1
    self.gameUnit = event.unit
    self:setBuffBoxList()
    self.buffEffectFLG = false
    self.addSpFLG = -1
    self.timer = 0.5
    self.countTimer = 0
    ---スキル初期値保存
    self:setDefaultNormalSkillRate(event.unit)

    self.counterFLG = false
    self.counterATK = false
    return 1
end

function class:setDefaultNormalSkillRate(unit)
    if unit:getParameter("defaultNormalRate") ~= "" then
        self.defaultNormalRate = unit:getParameter("defaultNormalRate")
    else
        self.defaultNormalRate = unit:getNormalSkill():getDamageRate()
        unit:setParameter("defaultNormalRate",self.defaultNormalRate)
    end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.deadFLG ~= -1 then
        ---自動蘇生時処理
        self.deadFLG = -1
    end
    if self.addSpFLG >= 0 then
        self.countTimer = self.countTimer + event.deltaTime
        if self.countTimer > self.timer then
            self.countTimer = 0
            local myTeam = self.gameUnit:getTeam()
            myTeam:getTeamUnit(self.addSpFLG):addSPWithPvpCorrection(200)
            self.addSpFLG = -1
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "specialEF" then self:showBuffEffect() end
    if event.spineEvent == "skill3" then self:skill3Orbit(event.unit) end
    if event.spineEvent == "skill1" then self:skill1addSP(event.unit) end
    return 1;
end

function class:skill3Orbit(unit)
    local orbit = unit:addOrbitSystem("Center_BG",0);
    orbit:setDamageRateOffset(0.5)
    orbit:setBreakRate(0.5)
    return 1;
end

function class:skill1addSP(unit)
    unit:addSPWithPvpCorrection(30)
    return 1;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    ---初期化
    event.unit:getNormalSkill():setDamageRate(self.defaultNormalRate)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    self.counterFLG = false
    ---特殊バフエフェクト
    self:showBuffEffect()
    ---レア通常攻撃
    if event.index == 1 and self:random(30) then
        event.unit:setNextAnimationName("attack2")
    end
    ---カウンター攻撃
    if self.counterATK then
        event.unit:setNextAnimationName("counter")
        event.unit:setNextAnimationEffectName("counter")
        event.unit:getNormalSkill():setDamageRate(100)
        event.unit:getNormalSkill():setElementType(0)
        event.unit:setActiveSkill(0)
        event.unit:setBreakRate(0)
        self.counterATK = false
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    ---初期化
    event.unit:getNormalSkill():setDamageRate(self.defaultNormalRate)
    event.unit:setDamageRateOffset(1)
    event.unit:setBreakRate(1)
    self.counterFLG = false
    ---奥義
    if event.index == 2 then
        self.counterFLG = true
    end
    ---真奥義
    if event.index == 3 then
        self.counterFLG = false
        event.unit:setDamageRateOffset(0.5)
        event.unit:setBreakRate(0.5)
        if megast.Battle:getInstance():isPvp() then
            if megast.Battle:getInstance():isPvpHost() then
                self.buffEffectFLG = true
            end
        else
            if megast.Battle:getInstance():isHost() then
                self.buffEffectFLG = true
            end
        end
    end
    return 1
end

function class:showBuffEffect()
    if self.buffEffectFLG then
        self.buffEffectFLG = false
        local myTeam = self.gameUnit:getTeam()
        local BP = 99999
        local index = -1
        for i = 0,6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                if myTeamUnit ~= self.gameUnit then
                    if myTeamUnit:getBurstPoint() < BP then
                        BP = myTeamUnit:getBurstPoint()
                        index = myTeamUnit:getIndex()
                    end
                end
            end
        end
        if index >= 0 then
            myTeam:getTeamUnit(index):playSpecialBuffEffect('HarimeNui_Gauge',759)
            self.addSpFLG = index
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,index);
        end
    end
end

function class:random(percent)
    local result = LuaUtilities.rand(1,100)
    if result <= percent then
        return true
    end
    return false;
end

function class:receive1(args)
    local myTeam = self.gameUnit:getTeam()
    myTeam:getTeamUnit(args.arg):playSpecialBuffEffect('HarimeNui_Gauge',759)
    self.addSpFLG = args.arg
    return 1;
end

----// takeIdle //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeIdle(event)
    self:showBuffEffect()
    return 1;
end
----// takeBack //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeBack(event)
    self:showBuffEffect()
    return 1;
end
----// takeFront //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeFront(event)
    self:showBuffEffect()
    return 1;
end
----// takeCast //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeCast(event)
    self:showBuffEffect()
    return 1;
end

----// takeDamageValue //-----------------------------------------------------------------------------
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
    if self.counterFLG then
        self.counterATK = true
    end
    return event.value
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self.deadFLG = 0
    return 1
end

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