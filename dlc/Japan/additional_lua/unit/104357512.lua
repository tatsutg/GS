local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="超覚醒オニキス", version=2.7, id=104357512});

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
    self.skill2Orbit = false;
    self.grayLWF = false;
    self.orbit = {};
    self:setBuffBoxList();
    return 1;
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
    ---前ウェーブのオービットはエンジン側で破棄済みなので参照だけ捨てる
    self.skill2Orbit = false;
    self.orbit = {};
    if self.grayLWF then
        self.grayLWF = false;
        megast.Battle:getInstance():resetBackGroundGrayScale();
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- endWave
---------------------------------------------------------------------------------
function class:endWave(event)
    self.skill2Orbit = false;
    self.orbit = {};
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---オービット関連
    --停止系状態異常バフ監視
    if self:findBuff(event.unit) and self.skill2Orbit then
        self.skill2Orbit = false;
        self:teamBuffOrbitOff(event.unit);
    end

    if self.skill2Orbit then
        self:teamBuffOrbitPosition(event.unit);
    end

    --超奥義の背景LWFグレー化を解除
    if event.unit:getUnitState() ~= kUnitState_skill and self.grayLWF then
        self.grayLWF = false;
        megast.Battle:getInstance():resetBackGroundGrayScale();
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    end
    return 1;
end

function class:teamBuffOrbitPosition(unit)
    local targetTeam = self:getMyTeam(unit,true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local orbit = self.orbit[myTeamUnit:getIndex()];
            if orbit ~= nil then
                self:setOrbitPosition(orbit,myTeamUnit);
            end
        end
    end
end

---停止系状態異常監視(89=気絶 / 91=麻痺 / 96=氷結。エンジンのhaveStopConditionと同一)
function class:findBuff(unit)
    local badStatusIDs = {89,91,96};
    for i = 1,#badStatusIDs do
        if unit:getTeamUnitCondition():findConditionWithType(badStatusIDs[i]) ~= nil then
            return true;
        end
    end
    return false;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_skill2_orbit" then
        self.skill2Orbit = true;
        self:teamBuffOrbit(event.unit);
    end

    if event.spineEvent == "orbitEmpty" then
        self.skill2Orbit = false;
        self.orbit = {};
    end

    if event.spineEvent == "Magan" then
        local magan = event.unit:addOrbitSystemWithFile("Magan_Onyx","Activation");
        magan:setAutoZOrder(true);
        magan:setZOderOffset(-5000);
        local vec = event.unit:getisPlayer() and 1 or -1;
        local targetX = event.unit:getPositionX() + event.unit:getSkeleton():getBoneWorldPositionX("root") * vec;
        local targetY = event.unit:getPositionY() + event.unit:getSkeleton():getBoneWorldPositionY("root");
        magan:setPosition(targetX,targetY);
        --背景LWFグレー化
        self.grayLWF = true;
        megast.Battle:getInstance():setBackGroundGrayScale(0);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
    end

    if event.spineEvent == "grayLwfOff" then
        self.grayLWF = false;
        megast.Battle:getInstance():resetBackGroundGrayScale();
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    end
    return 1;
end

function class:teamBuffOrbit(unit)
    local targetTeam = self:getMyTeam(unit,true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            local orbit = unit:addOrbitSystem("skill2_orbit",0);
            if orbit ~= nil then
                self:setOrbitPosition(orbit,myTeamUnit);
                self.orbit[myTeamUnit:getIndex()] = orbit;
            end
        end
    end
end

function class:teamBuffOrbitOff(unit)
    for _,orbit in pairs(self.orbit) do
        if orbit ~= nil then
            orbit:takeAnimation(0,"empty",false);
        end
    end
    self.orbit = {};
end

function class:receive4(args)
        if args.arg == 0 then
            self.grayLWF = true;
            megast.Battle:getInstance():setBackGroundGrayScale(0);
        elseif args.arg == 1 then
            self.grayLWF = false;
            megast.Battle:getInstance():resetBackGroundGrayScale();
        end
    return 1
end

---------------------------------------------------------------------------------
-- changeOut
---------------------------------------------------------------------------------
function class:changeOut(event)
    self.skill2Orbit = false;
    self.orbit = {};
    if self.grayLWF then
        self.grayLWF = false;
        megast.Battle:getInstance():resetBackGroundGrayScale();
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    self.skill2Orbit = false;
    self.orbit = {};
    if self.grayLWF then
        self.grayLWF = false;
        megast.Battle:getInstance():resetBackGroundGrayScale();
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- ヘルパー関数
---------------------------------------------------------------------------------
--- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil;
    local count = 1;
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + 1;
            if count > buffBox.MAX then
                count = buffBox.MAX;
            end
        end
    end

    ---グループID関係1
    local targetCond = nil;
    if buffBox.GROUP_ID ~= nil then
        local conditionSize = unit:getTeamUnitCondition():getAllConditionsSize();
        if conditionSize ~= 0 then
            for i = 0,(conditionSize - 1) do
                local cond = unit:getTeamUnitCondition():getAllConditionsAt(i);
                if cond ~= nil and cond:getGroupID() == buffBox.GROUP_ID and not cond:getIsPassive() then
                    targetCond = cond;
                end
            end
            ---アビリティではない同グループIDのバフがあった場合(ない場合は通過)
            if targetCond ~= nil then
                if targetCond:getPriority() <= buffBox.PRIORITY then
                    ---アビリティではない同グループID、優先度が自身以下のバフを見つけた場合
                    unit:getTeamUnitCondition():removeCondition(targetCond);
                else
                    ---アビリティではない同グループID、優先度が自身以上のバフを見つけた場合
                    return;
                end
            end
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    elseif buffBox.WEIGHT ~= nil then
        buff = unit:getTeamUnitCondition():addConditionWithWeight(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON,buffBox.WEIGHT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE * count,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID);
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1); end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2); end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3); end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4); end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5); end
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    ---グループID関係2
    if buffBox.GROUP_ID ~= nil then
        buff:setGroupID(buffBox.GROUP_ID);
        buff:setPriority(buffBox.PRIORITY);
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff);
    end
    return buff;
end

--- オービットを対象ユニットのMAINボーンに合わせる
function class:setOrbitPosition(orbit,targetUnit)
    local targetSkeleton = targetUnit:getSkeleton();
    if targetSkeleton == nil then
        ---スケルトンが取れない場合はユニット座標にフォールバック
        orbit:setPosition(targetUnit:getPositionX(),targetUnit:getPositionY());
        return;
    end

    ---getBoneWorldPositionXはスケルトンの左右反転を見ないのでX側だけ符号を合わせる
    local vec = targetUnit:getisPlayer() and 1 or -1;
    local targetX = targetUnit:getPositionX() + targetSkeleton:getBoneWorldPositionX("MAIN") * vec;
    local targetY = targetUnit:getPositionY() + targetSkeleton:getBoneWorldPositionY("MAIN");
    orbit:setPosition(targetX,targetY);

    ---addOrbitSystemは生成時に親(自分)のスケルトンオフセットをコピーするので対象ユニット側に合わせ直す
    ---(このオフセットはヒットバックでYが動くため、放置すると親が吹き飛んだ時に全オービットが連動する)
    local orbitSkeleton = orbit:getSkeleton();
    if orbitSkeleton ~= nil then
        orbitSkeleton:setPosition(0,targetSkeleton:getPositionY());
    end
end

--- チーム取得
function class:getMyTeam(unit,teamFlg)
    local unitTeam = unit:getTeam();
    local targetTeam = nil;
    if teamFlg then
        --自分PTからみて味方PTを取る
        if unitTeam == megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(true);
        else
            targetTeam = megast.Battle:getInstance():getTeam(false);
        end
    else
        --自分PTからみて敵PTを取る
        if unitTeam == megast.Battle:getInstance():getTeam(true) then
            targetTeam = megast.Battle:getInstance():getTeam(false);
        else
            targetTeam = megast.Battle:getInstance():getTeam(true);
        end
    end
    return targetTeam;
end

function class:teamAddBuff(unit,buffBox)
    local targetTeam = self:getMyTeam(unit,true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
        end
    end
end



class:publish();

return class;