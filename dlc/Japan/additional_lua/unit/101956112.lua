local class = summoner.Bootstrap.createUnitClass({label="ぼーげん", version=1.5, id=101956112});

function class:start(event)
    self.isVacuum = false;
    self.additionalBreakFlag = false;
    return 1;
end


function class:run(event)
    if event.spineEvent == "startVacuum" then
        self.isVacuum = true;
    end

    if event.spineEvent == "endVacuum" then
        self.isVacuum = false;
    end
    return 1;
end

function class:update(event)
    if self.isVacuum then
        self:excuteVacuum(event.unit,event.deltaTime);
    end
    return 1;
end

function class:excuteAction(event)
    self.isVacuum = false;
    return 1;
end

function class:takeSkill(event)
    self.additionalBreakFlag = false;
    if event.index == 3 then
        self.additionalBreakFlag = true;
    end
    return 1;
end

function class:takeDamage(event)
    self.isVacuum = false;
    return 1;
end

function class:excuteVacuum(unit,deltatime)
        for i = 0,6 do
        local targetUnit = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
        if targetUnit ~= nil then
            local targetx = targetUnit:getPositionX();
            local thisx = unit:getPositionX();
            local distance = thisx - targetx;
            local oneFrame = 0.016666666;
            local moveSpeed = 7 * deltatime/oneFrame;

            if distance == 0 then
                distance = 1;
            end
            
            targetUnit:setPosition(targetx + moveSpeed * distance/math.abs(distance),targetUnit:getPositionY());
        end
    end
end


function class:attackDamageValue (event)
    
--レイドとクロスバトルでは無効
    if megast.Battle:getInstance():isRaid() or megast.Battle:getInstance():isCrossBattle() then
        return event.value;
    end

    --ボスに対してのみ判断
    if event.enemy ~= megast.Battle:getInstance():getEnemyTeam():getBoss() then
        return event.value;
    end

    --自分のユニットでだけ判断
    if event.unit:isMyunit() == false then
        return event.value;
    end

    --奥義で判断
    local type = event.unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if type ~= 2 then
        return event.value
    end

    --１ヒット目だけで判断する
    if self.additionalBreakFlag == false then
        return event.value;
    end
    self.additionalBreakFlag = false;

    local param = event.enemy:getParameter("CurrentBreakCount");
    if param == "" then
        param = "0";
    end
    local currentBreakCount = tonumber(param);
    local breakcount = megast.Battle:getInstance():getBattleRecord():getBreakCount();

        if event.enemy:getBreakPoint() <= 0 and breakcount > currentBreakCount then            
        if megast.Battle:getInstance():isHost() then
            event.enemy:takeBossBreak(false);
            currentBreakCount = megast.Battle:getInstance():getBattleRecord():getBreakCount();
        else
            currentBreakCount = breakcount + 1;
        end
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,event.enemy:getIndex());
        BattleControl:get():pushInfomation(self.TEXT.SUMMARY,255,255,255,2);
        event.enemy:setParameter("CurrentBreakCount", currentBreakCount.."");
    end
    return event.value;
end



function class:receive1(args)
    local enemy = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(args.arg);
    if enemy == nil then
        return 1;
    end

    local param = enemy:getParameter("CurrentBreakCount");
    if param == "" then
        param = "0";
    end
    local currentBreakCount = tonumber(param);
    if currentBreakCount >= megast.Battle:getInstance():getBattleRecord():getBreakCount() then
        return 1;
    end 
    
    if megast.Battle:getInstance():isHost() then
           enemy:takeBossBreak(false);
           currentBreakCount = megast.Battle:getInstance():getBattleRecord():getBreakCount();
    else
           currentBreakCount = currentBreakCount + 1;
    end
    BattleControl:get():pushInfomation(self.TEXT.SUMMARY,255,255,255,2);
    enemy:setParameter("CurrentBreakCount", currentBreakCount.."");
    return 1;
end





class:publish();

return class;
