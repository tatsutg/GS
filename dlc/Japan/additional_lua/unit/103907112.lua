local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ヴェルザード", version=1.9, id=103907112});

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 1039701,
            BUFF_ID = 17, --与ダメ
            VALUE = 60,
            DURATION = 999999,
            ICON = 26,
            COUNT = 0,
            MAX = 5
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit
    self.skill1Flg = false
    self.skillAddSPValue = 25
    self.killFlg = {}   --[敵index] = true HPが0に達する一撃を入れた敵
    self:setBuffBoxList()
    return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    ---敵死亡判定
    self:checkKillFlg(self:getAncestorUnit(event.unit))
    return 1
end

-- HPが0に達する一撃を入れたらフラグON(カウントはしない)
function class:markKillFlg(myUnit,enemy,damage)
    if myUnit == nil or enemy == nil then return end
    --判定は所有クライアントのみ。非所有側はisRecvでダメージが再計算され予測がずれるため
    if not myUnit:isMyunit() then return end
    local target = self:getAncestorUnit(enemy);
    if target:getisPlayer() == myUnit:getisPlayer() then return end  --味方対象は無視
    if target:getIsDead() then return end                           --既に死亡確定
    if target:getHP() <= 0 then return end                          --既にHP0(多段HITの後続)
    if target:getHP() > damage then return end                      --致命打ではない
    self.killFlg[target:getIndex()] = true
end

-- フラグが立っている敵の死亡を確定させる
function class:checkKillFlg(myUnit)
    if next(self.killFlg) == nil then return end
    local team = megast.Battle:getInstance():getTeam(not myUnit:getisPlayer());
    if team == nil then return end

    local deadCount = 0
    for index in pairs(self.killFlg) do
        local target = team:getTeamUnit(index,true);     --第2引数true=死亡済みも取得する
        if target == nil or target:getIsDead() then
            deadCount = deadCount + 1                    --撃破確定
            self.killFlg[index] = nil
        elseif target:getHP() > 0 then
            self.killFlg[index] = nil                    --HP0フラグ等で生存 カウントしない
        end
        --HP0だが死亡処理前の場合はフラグを残して次フレームで再判定する
    end

    --同時撃破でも付与は1回にまとめる(付与回数に依存しないようにする)
    if deadCount > 0 then
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1],deadCount);
        --マルチ/PvPの他クライアントへ累計スタック数を配信する
        --PvPもチーム構成が両クライアントで同一なのでPLAYERSENDLUAで正しく届く
        --模擬戦はsendEventToLua側がisPvpAndConnectで弾く
        if megast.Battle:getInstance():isMultiPlay() or megast.Battle:getInstance():isPvp() then
            megast.Battle:getInstance():sendEventToLua(self.scriptID,1,self:getBuffCount(self.gameUnit,self.BUFF_BOX_LIST[1]));
        end
    end
end

-- 累計スタック数を受け取って合わせる(絶対値なので取りこぼしても次の撃破で復帰する)
function class:receive1(event)
    local buffBox = self.BUFF_BOX_LIST[1]
    local addCount = event.arg - self:getBuffCount(self.gameUnit,buffBox)
    if addCount > 0 then
        self:execAddBuff(self.gameUnit,buffBox,addCount)
    end
    return 1
end

-- 現在のスタック数
function class:getBuffCount(unit,buffBox)
    local cond = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
    if cond == nil then return 0 end
    return cond:getNumber()
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    self.skill1Flg = false
    return 1
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 1 then
        self.skill1Flg = true
    elseif event.index == 2 then
        self.skill1Flg = false
    elseif event.index == 3 then
        self.skill1Flg = false
    elseif event.index == 5 then
        self.skill1Flg = false
    end
    return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    --skill1効果
    if self.skill1Flg then
        self:skill1AddSP(event.unit)
    end

    self:markKillFlg(event.unit,event.enemy,event.value)
    return event.value
end

function class:skill1AddSP(unit)
    local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    if critical then
        self.skill1Flg = false
        --getTeam(true)固定だとPvPでホスト側チームを引いてしまうので自分と同じ側から取る
        local myTeam = megast.Battle:getInstance():getTeam(unit:getisPlayer());
        for i = 0, 6 do
            local myTeamUnit = myTeam:getTeamUnit(i)
            if myTeamUnit ~= nil then
                myTeamUnit:addSPWithPvpCorrection(self.skillAddSPValue);
            end
        end
    end
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    local myUnit = self:getAncestorUnit(event.unit)
    self:markKillFlg(myUnit,event.enemy,event.value)
    return event.value
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
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_orbit_skill5" then
        event.unit:addOrbitSystem("orbit_skill5",0)
    end
    return 1
end

---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
    self.skill1Flg = false
    return 1
end


-- バフ処理実行
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

    local oldBuff = nil
    local count = addCount or 1
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            count = oldBuff:getNumber() + (addCount or 1)
        end
        if count > buffBox.MAX then
            count = buffBox.MAX
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

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end

    if buffBox.FUNC ~= nil then
        buffBox.FUNC(buff)
    end
end


class:publish();

return class;
