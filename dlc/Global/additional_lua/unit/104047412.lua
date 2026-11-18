local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒超プラチナ", version=1.3, id=104047412});

-- ブレイクポイント減少(固定値/レイド)
class.REDUCE_BREAKPOINT_CONSTANT = 20000
-- ブレイクポイント減少(固定値/クロスバトル)
class.REDUCE_BREAKPOINT_CONSTANT_CROSS = 20000


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.skill1Flg = false
    self.abilityLevel = 90
    self.bossBreakBpUp = 160
    self.searchUnit = {
        114, --エスト
        252, --デューク
        404 --超プラチナ
    }
    return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    if event.unit:getLevel() >= self.abilityLevel then
        self:searchOtherDaunt(event.unit)
    end
    return 1
end

--アビリティ効果：威圧
function class:searchOtherDaunt(unit)
    if self:checkBossWave() and unit:getisPlayer() then
        --威圧フラグ用バフがPTに居るか確認
        local myTeam = megast.Battle:getInstance():getTeam(true);
        for i = 0,7 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(1040499);
                if buff ~= nil then
                    return 1
                else
                    myTeamUnit:getTeamUnitCondition():addCondition(1040499,0,0,999999,0)
                end
            end
        end

        self:execute(unit)
    end
end

function class:checkBossWave()
    local boss = megast.Battle:getInstance():getTeam(false):getBoss()
    if boss == nil then
        return false
    end
    return boss:getSize() == 3
end

function class:findUnit(cond)
    for i = 0,4 do
        local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if target ~= nil and cond(target) then
            return target
        end
    end
end

function class:execute(unit)
    local boss = megast.Battle:getInstance():getTeam(false):getBoss()
    if megast.Battle:getInstance():isRaid() then
        megast.Battle:getInstance():recAddBreakPoint(unit, boss, boss:getBreakPoint() - (boss:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT));
        boss:setBreakPoint(boss:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT);
        RaidControl:get():addBreakPool(self.REDUCE_BREAKPOINT_CONSTANT);
    elseif megast.Battle:getInstance():isCrossBattle() then
        megast.Battle:getInstance():recAddBreakPoint(unit, boss, boss:getBreakPoint() - (boss:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT));
        boss:setBreakPoint(boss:getBreakPoint() - self.REDUCE_BREAKPOINT_CONSTANT_CROSS);
    else
        megast.Battle:getInstance():recAddBreakPoint(unit, boss, boss:getBreakPoint() - (boss:getBreakPoint()/2));
        boss:setBreakPoint(boss:getBreakPoint()/2);
    end
    self:execShowMessage({MESSAGE = self.TEXT.MESSAGE1 or "威圧効果発動",DURATION = 5,COLOR = Color.yellow})
end

function class:execShowMessage(messageBox)
    if self.gameUnit:getisPlayer() then
        summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    else
        summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
    end
end

---------------------------------------------------------------------------------
-- endWave
---------------------------------------------------------------------------------
function class:endWave(event)
    self:checkDauntBuffFlg()
    return 1
end

function class:checkDauntBuffFlg()
    --威圧フラグ用バフがPTに居るか確認
    local myTeam = megast.Battle:getInstance():getTeam(true);
    for i = 0,7 do
        local myTeamUnit = myTeam:getTeamUnit(i)
        if myTeamUnit ~= nil then
            local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(1040499);
            if buff ~= nil then
                myTeamUnit:getTeamUnitCondition():removeCondition(buff);
            end
        end
    end
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.skill1Flg then
        self.skill1Flg = false
        local boss = megast.Battle:getInstance():getEnemyTeam():getBoss();
        if boss ~= nil and boss:getBreakPoint() <= 0 then
            event.unit:addSPWithPvpCorrection(self.bossBreakBpUp)
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        self.skill1Flg = true
    elseif event.index == 3 then
        self.skill1Flg = false
    elseif event.index == 5 then
        self.skill1Flg = false
    end
    return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill3_orbit" then
        event.unit:addOrbitSystem("skill3_orbit",0)
    end
    return 1
end



class:publish();

return class;