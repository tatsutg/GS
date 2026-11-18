local instance = summoner.Bootstrap.createUnitClass({label="unit name", version=1.3, id=101805212});

--デイシー
--☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆


-- instance.messages = summoner.Text:fetchByUnitID(101715211);



--☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

function instance:start(event)
    self.breakCheckFlag = false;
    self.gameUnit = event.unit;
    self.gazeBreakCount = 0;
    return 1;
end

function instance:run (event)
    return 1;
end

function instance:excuteAction(event)
    self.breakCheckFlag = false;
    return 1;
end

function instance:takeSkill(event)
    if event.index == 3 then
        self.breakCheckFlag = false;
    end
    if event.index == 2 then
        self.gazeBreakCount = megast.Battle:getInstance():getBattleRecord():getBreakCount();
        self.breakCheckFlag = true;
    end
    return 1;
end

function instance:update(event)
    if self.breakCheckFlag and event.unit:isMyunit() then
        self:breakCheck();
    end
    if event.unit:getBurstState() ~= kBurstState_active then
        self.breakCheckFlag = false;
    end
    return 1;
end


--===================================================================================================================
--マルチ同期//
--//////////


function instance:receive1(args)
    self:addSP(self.gameUnit);
    return 1;
end


--===================================================================================================================


--===================================================================================================================

function instance:breakCheck()
    local boss = megast.Battle:getInstance():getTeam(false):getBoss();
    if boss ~= nil then
        local breakcount = megast.Battle:getInstance():getBattleRecord():getBreakCount();
        if self.gazeBreakCount < breakcount then
            self.gazeBreakCount = breakcount;
            self:addSP(self.gameUnit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,0);
            return;
        end
        self.gazeBreakCount = breakcount;
    end
end

function instance:addSP(unit)
    unit:addSPNonPvpCorrection(200);
end


--===================================================================================================================

instance:publish();

return instance;