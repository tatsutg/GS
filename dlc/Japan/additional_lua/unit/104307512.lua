local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="超覚醒シモン", version=2.8, id=104307512});


function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 10430701, --固有アビ
            BUFF_ID = 17, --与ダメ
            VALUE = 50,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 10  --上限500%(50%x10)
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self.skill7Flg = false;  --超ファントムバレット
    self.killFlg = {};   --[敵index] = true HPが0に達する一撃を入れた敵
    self:setBuffBoxList();
    ---ファントムバレットのカットインボイスは既定が真奥義のものなので明示指定する
    event.unit:setCutinVoicePB("VOICE_FULLARTS_CUTIN_FB")
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---敵死亡判定
        self:checkKillFlg(self:getAncestorUnit(event.unit));
    ---奥義中か確認
    if event.unit:getUnitState() ~= kUnitState_skill and self.skill7Flg then
        self.skill7Flg = false;
    end
    return 1;
end

-- HPが0に達する一撃を入れたらフラグON(カウントはしない)
function class:markKillFlg(myUnit,enemy,damage)
    if myUnit == nil or enemy == nil then return; end
    --判定は所有クライアントのみ。非所有側はisRecvでダメージが再計算され予測がずれるため
    if not myUnit:isMyunit() then return; end
    local target = self:getAncestorUnit(enemy);
    if target:getisPlayer() == myUnit:getisPlayer() then return; end  --味方対象は無視
    if target:getIsDead() then return; end                           --既に死亡確定
    if target:getHP() <= 0 then return; end                          --既にHP0(多段HITの後続)
    if target:getHP() > damage then return; end                      --致命打ではない
    self.killFlg[target:getIndex()] = true;
end

-- フラグが立っている敵の死亡を確定させる
function class:checkKillFlg(myUnit)
    if next(self.killFlg) == nil then return; end
    local team = megast.Battle:getInstance():getTeam(not myUnit:getisPlayer());
    if team == nil then return; end

    local deadCount = 0
    for index in pairs(self.killFlg) do
        local target = team:getTeamUnit(index,true);     --第2引数true=死亡済みも取得する
        if target == nil or target:getIsDead() then
            deadCount = deadCount + 1;                   --撃破確定
            self.killFlg[index] = nil;
        elseif target:getHP() > 0 then
            self.killFlg[index] = nil;                   --HP0フラグ等で生存 カウントしない
        end
        --HP0だが死亡処理前の場合はフラグを残して次フレームで再判定する
    end

    --同時撃破でも付与は1回にまとめる(付与回数に依存しないようにする)
    if deadCount > 0 then
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1],deadCount);
        --マルチの他クライアントへ累計スタック数を配信する
        --PvPはPLAYERSENDLUAが受け側の自軍indexを引いてしまうため送らない
        if megast.Battle:getInstance():isMultiPlay() then
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self:getBuffCount(self.gameUnit,self.BUFF_BOX_LIST[1]));
        end
    end
end

-- 累計スタック数を受け取って合わせる(絶対値なので取りこぼしても次の撃破で復帰する)
function class:receive1(event)
    local buffBox = self.BUFF_BOX_LIST[1];
    local addCount = event.arg - self:getBuffCount(self.gameUnit,buffBox);
    if addCount > 0 then
        self:execAddBuff(self.gameUnit,buffBox,addCount);
    end
    return 1;
end

-- 現在のスタック数
function class:getBuffCount(unit,buffBox)
    local cond = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
    if cond == nil then return 0; end
    return cond:getNumber();
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_PB_back" then
        event.unit:addOrbitSystem("PB_back",0);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 7 then
        self.skill7Flg = true;
    else
        self.skill7Flg = false;
    end
    return 1;
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    local myUnit = self:getAncestorUnit(event.unit);
    local type = myUnit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if type ~= 3 and type ~= 6 then
        --Hitした相手HP%にって補正をかける
        if self.skill7Flg then
            if event.enemy:getHPPercent() * 100 <= 25 then
                event.value = event.value * 4;
            elseif event.enemy:getHPPercent() * 100 <= 50 then
                event.value = event.value * 2;
            end
        end
    end

    --致命打判定は補正後の最終ダメージで行う(補正前だと低HPの敵を取りこぼす)
    self:markKillFlg(myUnit,event.enemy,event.value);
    return event.value;
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    local myUnit = self:getAncestorUnit(event.unit);
    local enemy = self:getAncestorUnit(event.enemy);
    local type = myUnit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if type ~= 3 and type ~= 6 then
        --Hitした相手HP%にって補正をかける
        if self.skill7Flg then
            if enemy:getHPPercent() * 100 <= 25 then
                event.value = event.value * 4;
            elseif enemy:getHPPercent() * 100 <= 50 then
                event.value = event.value * 2;
            end
        end
    end

    --致命打判定は補正後の最終ダメージで行う(補正前だと低HPの敵を取りこぼす)
    self:markKillFlg(myUnit,event.enemy,event.value);
    return event.value;
end

-- ご先祖ユニットまで遡る
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit
    else
        return self:getAncestorUnit(unit:getParentTeamUnit())
    end
end

---------------------------------------------------------------------------------
-- ヘルパー関数
---------------------------------------------------------------------------------
--- バフ処理実行
-- addCount : MAX持ちバフのスタック加算数(省略時1)。同時撃破など一度に複数加算する時に使う
function class:execAddBuff(unit,buffBox,addCount)
    local buff  = nil;
    if buffBox.GROUP_ID ~= nil then
        local cond = unit:getTeamUnitCondition():findConditionWithGroupID(buffBox.GROUP_ID);
        if cond ~= nil and cond:getPriority() <= buffBox.PRIORITY then
            unit:getTeamUnitCondition():removeCondition(cond);
        elseif cond ~= nil and cond:getPriority() > buffBox.PRIORITY then
            return;
        end
    end

    local oldBuff = nil;
    local count = addCount or 1;
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID);
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + (addCount or 1);
        end
        if count > buffBox.MAX then
            count = buffBox.MAX;
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

    if buffBox.COUNT ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(buffBox.COUNT);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count);
        megast.Battle:getInstance():updateConditionView();
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff);
    end
    return buff;
end

function class:teamAddBuff(unit,buffBox)
    local targetTeam = self:getMyTaem(unit,true);
    for i = 0,6 do
        local myTeamUnit = targetTeam:getTeamUnit(i);
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,buffBox);
        end
    end
end

--- チーム取得
function class:getMyTaem(unit,teamFlg)
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



class:publish();

return class;