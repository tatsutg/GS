local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="覚醒アルシェ", version=1.3, id=101736412});

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self.hpReduceValue = -15
    return 1
end

function class:runRelize(unit)
    ---アニメは全クライアントで再生されるため、協力プレイでは所有クライアント以外を起点にしない(全員が起点だとreceive1と二重に処理され蘇生回数が余分に進む)
    if not self:getIsControll(unit) and not megast.Battle:getInstance():isPvp() then
        return 1;
    end
    local index = -1;
    for i = 0,7 do
        local teamUnit = unit:getTeam():getTeamUnit(i,true);
        if teamUnit ~= nil then
            if teamUnit:getHP() <= 0 then
                index = i;
                break;
            end
        end
    end
    if index ~= -1 then
        self:excuteRinascita(unit,index);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,index);
    end
    return 1;
end

function class:excuteRinascita(unit,index)
    local teamUnit = unit:getTeam():getTeamUnit(index,true);
    if teamUnit ~= nil then
        ---蘇生数をカウント
        local counter = 1;
        if teamUnit:getParameter("archeCount") ~= "" then
            counter = tonumber(teamUnit:getParameter("archeCount")) + 1;
        end
        teamUnit:setParameter("archeCount",counter.."");
        local isControll = self:getIsControll(teamUnit) or megast.Battle:getInstance():isPvp();
        if isControll then
            ---蘇生処理
            unit:getTeam():reviveUnit(teamUnit:getIndex())
            ---即死しないようバリア
            if megast.Battle:getInstance():isPvp() then
                teamUnit:setWaitReviveTime(2)
            end
            teamUnit:getTeamUnitCondition():addCondition(-1,98,9999999,2,0);
        end
        ---HP減少
        ---conditionは通信同期されないため、蘇生対象を所有しないクライアントでも付与する
        ---(付与しないとバフアイコンが出ず、最大HPの計算も他クライアントとズレる)
        local cond = teamUnit:getTeamUnitCondition():findConditionWithID(100131);
        if cond ~= nil then
            cond:setValue(self.hpReduceValue * counter);
        else
            local cond = teamUnit:getTeamUnitCondition():addCondition(100131,2,self.hpReduceValue * counter,9999,2);
            cond:setIsPassive(true);
            cond:setIsDefault(false);
        end
        megast.Battle:getInstance():updateConditionView();
        if isControll then
            ---蘇生HP。最大HP減少を適用した後の最大HPを基準にする（被回復倍率を掛けるためsetReviveHPを使う）
            teamUnit:setReviveHP(teamUnit:getCalcHPMAX());
            ---この奥義の回復が蘇生HPに上乗せされないよう印を付ける（マルチでは蘇生がスキル効果より先に届くため）
            local skill = unit:getActiveBattleSkill();
            if skill ~= nil then
                teamUnit:setReviveHealCancelSkillID(skill:getDBID());
            end
            ---奥義ゲージアップ
            local pvpCorrectionValue = megast.Battle:getInstance():getPvpCorrectionValue(8,1);
            teamUnit:setBurstPoint(teamUnit:getBurstPoint() + (100 * pvpCorrectionValue));
        end
    end
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    ---行動するたびに、前回の蘇生で付けた印を消す
    for i = 0,7 do
        local teamUnit = event.unit:getTeam():getTeamUnit(i,true);
        if teamUnit ~= nil then
            teamUnit:setReviveHealCancelSkillID(0);
        end
    end
    return 1
end

function class:getIsControll(unit)
    return unit:isMyunit() or (unit:getisPlayer() == false and megast.Battle:getInstance():isHost());
end

function class:receive1(args)
    self:excuteRinascita(self.gameUnit,args.arg);
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "runRelize" then
        self:runRelize(event.unit)
    end
    return 1
end

class:publish();

return class;