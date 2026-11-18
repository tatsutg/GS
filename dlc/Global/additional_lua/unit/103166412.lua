local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="名前を入力", version=1.3, id=0000});
--------[[アニメーション]]--------
function class:setAnimationList()
    self.ANIMATIONS = {
        [1] = {
            [1] = {
                ANIMATION = "skill1",
                EF = "2-skill1a",
                ORBIT = "shot2a"
            },
            [2] = {
                ANIMATION = "skill1",
                EF = "2-skill1b",
                ORBIT = "shot2b"
            },
            [3] = {
                ANIMATION = "skill1",
                EF = "2-skill1c",
                ORBIT = "shot2c"
            }
        }
    }
end
--------[[バフ]]--------
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
    self.gameUnit = event.unit
    self.skillCheckFLG = false
    self.surfaceIndex = 1
    self:setAnimationList()
    self:setBuffBoxList()
    self.orbitIndex = 1
    return 1
end
---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "skill1Shot" then self:skill1Shot(event.unit) end
    return 1
end

function class:skill1Shot(unit)
    unit:addOrbitSystem(self.ANIMATIONS[1][self.orbitIndex].ORBIT,1):setEndAnimationName("bomb")
end



----// takeSkill //-----------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        event.unit:setNextAnimationName(self.ANIMATIONS[event.index][self.surfaceIndex].ANIMATION)
        event.unit:setNextAnimationEffectName(self.ANIMATIONS[event.index][self.surfaceIndex].EF)
        self.orbitIndex = self.surfaceIndex
        self:moveSkill(event.index)
    end
    return 1
end


-----------------------------
function class:moveSkill(skillIndex)
    if self.surfaceIndex < table.getn( self.ANIMATIONS[skillIndex] ) then
        self.surfaceIndex = self.surfaceIndex + 1
    else
        self.surfaceIndex = 1
    end
end
-----------------------------

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
            myTeamUnit:execAddBuff(buffBox)
        end
    end
end




class:publish();

return class;