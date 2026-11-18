local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒ヴォルフリート", version=2.7, id=104377312});

--真奥義のダメージ倍率が最大でないときに上げる奥義ゲージ
class.BURST2_ADD_SP_VALUE = 100;
--真奥義のダメージ倍率変更（effect_type 245・script 540）の skill_effect ID。加算の最大回数（script_value_2）をここから読む
class.BURST2_RATE_EFFECT_ID = 20437901;
--script 540 が発動回数を持たせるマーカーConditionのID（＋ユニットのindex）
class.SCRIPT540_MARK_ID = 5400000;

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {};
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self.gameUnit = event.unit;
    self:setBuffBoxList();
    self.isBurst2AddSP = false;
    return 1;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    --真奥義のゲージ消費は takeSkill の後なので、カットイン明けの update で上げる（カットイン中は update が呼ばれない）
    if self.isBurst2AddSP then
        self.isBurst2AddSP = false;
        event.unit:addSPWithPvpCorrection(self.BURST2_ADD_SP_VALUE);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "Library_efskill5" then
        local orbit = event.unit:addOrbitSystem("efskill5",0);
        orbit:setDamageRateOffset(0.5);
        orbit:setBreakRate(0.5);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
    event.unit:setDamageRateOffset(1);
    event.unit:setBreakRate(1);
    return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    event.unit:setDamageRateOffset(1);
    event.unit:setBreakRate(1);
    if event.index == 3 and not self:isBurst2RateAlreadyMax(event.unit) then
        self.isBurst2AddSP = true;
    end
    if event.index == 5 then
        event.unit:setDamageRateOffset(0.5);
        event.unit:setBreakRate(0.5);
    end
    return 1;
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    return 1;
end

-- 今回の発動の前に、真奥義のダメージ倍率がすでに最大か（今回の発動で最大になる場合は、発動前は最大でないので false）
-- script 540 は n 回目の発動で min(n-1, 加算の最大回数) 回分を加算するので、
-- これまでの発動回数が加算の最大回数を超えていれば前回の発動で最大になっている（最大回数0は上限なし）
-- takeSkill の時点では今回の発動はまだ数えられていない（540 はスキル効果の発動時に数える）
function class:isBurst2RateAlreadyMax(unit)
    local max = megast.Battle:getInstance():getSkillEffectMaster(self.BURST2_RATE_EFFECT_ID):getScriptValue2();
    if max <= 0 then
        return false;
    end
    local count = 0;
    local mark = unit:getTeamUnitCondition():findConditionWithID(self.SCRIPT540_MARK_ID + unit:getIndex());
    if mark ~= nil and mark:getNumber() > 0 then
        count = mark:getNumber();
    end
    return count > max;
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1); end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2); end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3); end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4); end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5); end
    end
end


class:publish();

return class;