local class = summoner.Bootstrap.createUnitClass({label="フェレス", version=1.3, id=102256212});

--------[[バフ]]--------
function class:setBuffBoxList(devoteLv)
    self.DEVOTE_BUFF_BOX = {
        [1] = {
            ID = 1022562121,
            BUFF_ID = 0, -- 献身アイコンのみ
            VALUE = 0,
            DURATION = 999999,
            ICON = 209,
            COUNT = devoteLv,
            MAX = 5
        },
        [2] = {
            ID = 1022562122,
            BUFF_ID = 2, -- 最大HP
            VALUE = -15 * devoteLv,
            DURATION = 999999,
            ICON = 0
        },
        [3] = {
            ID = 1022562123,
            BUFF_ID = 13, -- 攻撃アップ
            VALUE = 15 * devoteLv,
            DURATION = 999999,
            ICON = 0
        }
    }
end

---------------------------------------------------------------------------------
-- start 
---------------------------------------------------------------------------------
function class:start(event)
    self.devoteLv = 0
    self:setBuffBoxList(self.devoteLv)
    self.devoteCheckTimer = 0;
    self.gameUnit = event.unit;
    return 1
end

function class:run(event)
    if megast.Battle:getInstance():isPvp() then
    elseif not megast.Battle:getInstance():isHost() then
        return 1
    end

    if event.spineEvent == "skill2" then
        self:levelUp()
        self:execSkill2Buff(event.unit,self.devoteLv)
        if not megast.Battle:getInstance():isPvp() then
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self.devoteLv);
        end
    end
    if event.spineEvent == "skill3" then
        self:execSkill3Buff(event.unit,self.devoteLv)
        if not megast.Battle:getInstance():isPvp() then
            megast.Battle:getInstance():sendEventToLua(self.scriptID,2,self.devoteLv);
        end
    end
    return 1
end

function class:update(event)
    if self.devoteCheckTimer > 0.5 then
        self.devoteCheckTimer = self.devoteCheckTimer - 0.5;
        self:devoteCheck(event.unit);
    end
    self.devoteCheckTimer = self.devoteCheckTimer + event.deltaTime;
    return 1;
end

function class:levelUp()
    self.devoteLv = self.devoteLv < 5 and self.devoteLv + 1 or 5
end

function class:execSkill2Buff(unit,devoteLv)
    self:setBuffBoxList(devoteLv)
    self:execAddBuff(unit,self.DEVOTE_BUFF_BOX[1])
    self:execAddBuff(unit,self.DEVOTE_BUFF_BOX[2])

    
end

--アビリティなので常時チェックする必要あり
function class:devoteCheck(unit)
    for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i)
        if localUnit ~= nil then
            local buff = localUnit:getTeamUnitCondition():findConditionWithID(self.DEVOTE_BUFF_BOX[3].ID);--すでに他のフェレスが自分より効果の高いバフをかけていたら困るので
            if buff == nil or buff:getValue() <= self.devoteLv * 15 then
                self:execAddBuff(localUnit,self.DEVOTE_BUFF_BOX[3])
            end
        end
    end
    unit:setParameter("225_Devote",""..self.devoteLv)
end

--アビリティなので死んだら剥がす 他のフェレスがいる場合は、他のフェレスがかけ直してくれるさ
function class:removeDevote(unit)
    for i = 0,3 do
        local localUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i)
        if localUnit ~= nil then
            local buff = localUnit:getTeamUnitCondition():findConditionWithID(self.DEVOTE_BUFF_BOX[3].ID);
            if buff ~= nil then
                localUnit:getTeamUnitCondition():removeCondition(buff);
            end
        end
    end
end

function class:dead(event)
    self:removeDevote(event.unit);
    return 1;
end

function class:receive1(args)
    self.devoteLv = args.arg;
    self:execSkill2Buff(self.gameUnit,args.arg);
    return 1;
end

function class:execSkill3Buff(unit,devoteLv)
    -- for i = 0,3 do
    --     local localUnit = megast.Battle:getInstance():getTeam(unit:getisPlayer()):getTeamUnit(i)
    --     if localUnit ~= nil then
    --         localUnit:addSP(6 * devoteLv)
    --     end
    -- end
end

function class:receive2(args)
    self:execSkill3Buff(self.gameUnit,args.arg);
    return 1;
end

--===================================================================================================================
-- バフ関係
--===================================================================================================================
function class:addBuff(unit,buffBoxList)
    for i,buffBox in pairs(buffBoxList) do
        self:execAddBuff(unit,buffBox)
    end
end

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

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end
end


class:publish();

return class;