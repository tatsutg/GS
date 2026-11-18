local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒超レオーネ", version=2.5, id=104177412});


function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 0,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 0,
            ICON = 0,
        },
    }
end


---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self.orbitLeafRain = nil;
    self.orbitCanter = nil;
    self:setBuffBoxList();
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if self.skill5FLG then
        if event.unit:getUnitState() ~= kUnitState_skill then
            self.skill5FLG = false;
            self:changeDamageText(false,event.unit);
            if self.orbitLeafRain ~= nil then
                self.orbitLeafRain:takeAnimation(0,"empty",false);
                self.orbitLeafRain = nil;
            end

            if self.orbitCanter ~= nil then
                self.orbitCanter:takeAnimation(0,"empty",false);
                self.orbitCanter = nil;
            end
            BattleControl:get():restoreBackgroundLWF(event.unit,false,0,0.1,0.3);
        end
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 5 then
        self.skill5FLG = true;
        self:changeDamageText(true,event.unit);
    end
    return 1
end

function class:changeDamageText(isCamera,unit)
    if isCamera then
        megast.Battle:getInstance():changeDamageTextLayerToCameraWithUnit(unit);
    else
        megast.Battle:getInstance():changeDamageTextLayerToBattleFieldWithUnit(unit);
    end
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill1_thorn" then
        local orbit = event.unit:addOrbitSystem("skill1_thorn",0)
    end
    if event.spineEvent == "Library_skill2_tornado" then
        local orbit = event.unit:addOrbitSystem("skill2_tornado",0)
    end
    if event.spineEvent == "Library_skill5_leafrain" then
        self.orbitLeafRain = nil;
        self.orbitLeafRain = event.unit:addOrbitSystemCamera("skill5_leafrain",0);
        if not event.unit:getisPlayer() then
            self.orbitLeafRain:getSkeleton():setScaleX(-1);
        end
    end
    if event.spineEvent == "Library_skill5_canter" then
        self.orbitCanter = nil;
        self.orbitCanter = event.unit:addOrbitSystem("skill5_canter",0);
        if not event.unit:getisPlayer() then
            self.orbitCanter:getSkeleton():setScaleX(-1);
        end
    end
    if event.spineEvent == "BGChange1" then
        BattleControl:get():changeBackgroundLWF(2057100,event.unit,0,0.1,0);
    end
    if event.spineEvent == "BGChange2" then
        megast.Battle:getInstance():setBGLWFChangeTeamUnit(event.unit);
        BattleControl:get():setCustomBackgroundLWF(2057200);
        --BattleControl:get():changeBackgroundLWF(2057200,event.unit,0,0,0);
    end
    if event.spineEvent == "BGChangeEnd" then
        BattleControl:get():restoreBackgroundLWF(event.unit,false,0,0.1,0.3);
    end
    if event.spineEvent == "orbitLeafRainEmpty" then
        if self.orbitLeafRain ~= nil then
            self.orbitLeafRain:takeAnimation(0,"empty",false);
        end
        self.orbitLeafRain = nil;
    end
    if event.spineEvent == "orbitCanterEmpty" then
        if self.orbitCanter ~= nil then
            self.orbitCanter:takeAnimation(0,"empty",false);
        end
        self.orbitCanter = nil;
    end
    return 1
end

---------------------------------------------------------------------------------
-- changeOut
---------------------------------------------------------------------------------
function class:changeOut(event)
    self:changeDamageText(false,event.unit);
    BattleControl:get():restoreBackgroundLWF(event.unit,false,0,0.1,0.3);
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self:changeDamageText(false,event.unit);
    BattleControl:get():restoreBackgroundLWF(event.unit,false,0,0.1,0.3);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    return 1
end

function class:receive4(args)
    self:changeDamageText(false,self.gameUnit);
    BattleControl:get():restoreBackgroundLWF(self.gameUnit,false,0,0.1,0.3);
    return 1
end


class:publish();

return class;