local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility");
local class = summoner.Bootstrap.createUnitClass({label="超覚醒_ザンカ", version=2.8, id=108537212});

---アビリティ「超凡人」: 自身が物理攻撃装備を使用する度に、自身のダメージ40%UP（最大400%）
class.ITEM_TYPE_OFFENCE     = 1;    ---kItemType_Offence(物理攻撃装備)
---超奥義「凡人共振」: HP50%以下の敵に対して、超奥義ダメージ倍率3倍
class.SUPER_BURST_HP_BORDER = 50;
class.SUPER_BURST_RATE      = 3;

function class:setBuffBoxList()
    self.BUFF_BOX_LIST = {
        ---超凡人スタック。戦闘不能時は Team::deadUnit の removeAllCondition で消えるのでリセットされる
        [1] = {
            ID = 1085301,
            BUFF_ID = 17,        ---与ダメージ割合
            VALUE = 40,
            DURATION = 999999,
            ICON = 26,
            MAX = 10             ---40 * 10 = 400%
        }
    }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
    self:setBuffBoxList();
    return 1;
end

---------------------------------------------------------------------------------
-- castItem
-- 物理攻撃装備を使用する度に与ダメージUPを1段階積む
---------------------------------------------------------------------------------
function class:castItem(event)
    ---0を返すと装備の使用自体がキャンセルされるので、以降は必ず1を返すこと
    if self.BUFF_BOX_LIST == nil then
        self:setBuffBoxList();
    end

    local itemSkill = event.item;
    if itemSkill == nil then
        return 1;
    end

    local item = itemSkill:getBattleItem();
    if item == nil or item:getItemTypeAsInt() ~= class.ITEM_TYPE_OFFENCE then
        return 1;
    end

    self:execAddBuff(event.unit, self.BUFF_BOX_LIST[1]);
    return 1;
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
    return self:applySuperBurstRate(event.unit, event.enemy, event.value);
end

---------------------------------------------------------------------------------
-- attackDamageValue_OrbitSystem
---------------------------------------------------------------------------------
function class:attackDamageValue_OrbitSystem(event)
    return self:applySuperBurstRate(event.unit, event.enemy, event.value);
end

---超奥義中、HPが規定値以下の相手へのダメージに倍率をかける
function class:applySuperBurstRate(unit, enemy, value)
    if unit == nil or enemy == nil then
        return value;
    end

    ---装備攻撃は判定しない
    local skillType = unit:getTeamUnitCondition():getDamageAffectInfo().skillType;
    if skillType == 3 or skillType == 6 then
        return value;
    end

    ---オービット・弾が unit に来る経路があるので本体までさかのぼる
    local owner = self:getAncestorUnit(unit);
    if owner == nil then
        return value;
    end

    ---超奥義中のみ。アクション終了時に resetStates が ActiveBattleSkill を落とすので持ち越さない
    local skill = owner:getActiveBattleSkill();
    if skill == nil or not skill:isBurst3() then
        return value;
    end

    ---Hitした相手のHP%で判定
    local target = self:getAncestorUnit(enemy);
    if target == nil or target:getHPPercent() * 100 > class.SUPER_BURST_HP_BORDER then
        return value;
    end

    return value * class.SUPER_BURST_RATE;
end

---------------------------------------------------------------------------------
-- ヘルパー関数
---------------------------------------------------------------------------------
--- オービット・弾から本体をたどる
function class:getAncestorUnit(unit)
    if unit:getParentTeamUnit() == nil then
        return unit;
    else
        return self:getAncestorUnit(unit:getParentTeamUnit());
    end
end

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


class:publish();

return class;
