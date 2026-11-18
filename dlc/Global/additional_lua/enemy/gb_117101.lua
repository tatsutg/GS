local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="GB獣魔拳士ザール", version=1.3, id="gb_117101"});
class:inheritFromEnemy("gbBossBase");

function class:GB_start(event)
    --現在かかっているバフカウンター
    self.buffCounter = 0
    --バフ重複上限
    self.limitBuffCount = 5
    --バフカウンター配列
    self.icon_Table = {
        94, --  1
        95, --  2
        96, --  3
        97, --  4
        103, --  5
        99, --  6
        100, --  7
        101, --  8
        102, --  9
        103 --  10
    }
    self.BurstAura = nil
    return;
end

function class:GB_update(event)
    self:BurstAuraUpdate(event.unit);
    return;
end

function class:BurstAuraUpdate(unit)
    if self.BurstAura ~= nil then
        self.BurstAura:setPositionX(unit:getAnimationPositionX());
        self.BurstAura:setPositionY(unit:getAnimationPositionY()-65);
        self.BurstAura:setLocalZOrder(unit:getZOrder() + 1);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run (event)
    if event.spineEvent == "CoupDeGrace" then
        self:CoupDeGrace(event.unit)
    end
    if event.spineEvent == "CoupDeGraceEnd" then
        self:CoupDeGraceEnd(event.unit)
    end
    return 1;
end

function class:CoupDeGrace(unit)
    self:BurstAuraCreation(unit,false);
    if unit:isMyunit() == true or self:isEnemyType(unit) == true then
        if self.buffCounter < self.limitBuffCount then
            if self.buffCounter ~= 0 then
                local conditon = unit:getTeamUnitCondition():findConditionWithID(-53);
                if not(conditon == nil) then
                    unit:getTeamUnitCondition():removeCondition(conditon);
                end
            end
            self.buffCounter = self.buffCounter + 1;
            unit:getTeamUnitCondition():addCondition(-53,0,0,10000,self.icon_Table[self.buffCounter]);
            --self.RequestSendEventToLua(this,unit,1,self.buffCounter);
        end
    end
    return 1;
end

function class:CoupDeGraceEnd(unit)
    --上の条件以外に終了時になった、つまりMAXIMUM！
    if self.buffCounter >= self.limitBuffCount then
        self:BurstAuraCreation(unit,true);
    end
    return 1;
end

function class:BurstAuraCreation(unit,isDraw)
    if isDraw == true then
        if self.BurstAura == nil then
            self.BurstAura = unit:addOrbitSystem("aura");
            self.BurstAura:setAnimation(0,"aura",true);
            self.BurstAura:setPositionX(unit:getAnimationPositionX());
            self.BurstAura:setPositionY(unit:getAnimationPositionY()-65);
            self.BurstAura:setLocalZOrder(unit:getZOrder() + 1);
        end
    else
        if self.BurstAura ~= nil then
            self.BurstAura:remove();
            self.BurstAura = nil;
        end
    end
end

function class:BurstAuraCreation(unit,isDraw)
    if isDraw == true then
        if self.BurstAura == nil then
            self.BurstAura = unit:addOrbitSystem("aura");
            self.BurstAura:setAnimation(0,"aura",true);
            self.BurstAura:setPositionX(unit:getAnimationPositionX());
            self.BurstAura:setPositionY(unit:getAnimationPositionY()-65);
            self.BurstAura:setLocalZOrder(unit:getZOrder() + 1);
        end
    else
        if self.BurstAura ~= nil then
            self.BurstAura:remove();
            self.BurstAura = nil;
        end
    end
end

function class:isEnemyType(unit)
    local isHost = megast.Battle:getInstance():isHost();
    local isPlayer = unit:getisPlayer();
    if isPlayer == false and isHost == true then
        return true;
    end
    return false;
end

class:publish();

return class;