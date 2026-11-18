local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="超覚醒_御坂美琴", version=1.8, id=108167412});

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
    self:setBuffBoxList();
    self:getWeaponCT(event.unit);
    return 1;
end

function class:getWeaponCT(unit)
    self.ctTbl = {};
    local nowCT = 0;
    local battleSkill = nil;
    for i = 0,2 do
        battleSkill = unit:getItemSkill(i);
        if battleSkill ~= nil then
            nowCT = battleSkill:getCoolTimer();  --現状の装備CTを取得
            battleSkill:resetCooltime();  --装備を一度使用した状態にする
            self.ctTbl[i] = battleSkill:getCoolTimer();  --装備CTの値を取得
            battleSkill:setCoolTimer(nowCT);  --装備CTの状態を戻す
        end
    end
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
    if event.index == 5 then
        self:weaponCoolTimeReset(event.unit);
    end
    return 1
end

function class:weaponCoolTimeReset(unit)
    local battleSkill = nil;
    for i = 0,2 do
        battleSkill = unit:getItemSkill(i);
        if battleSkill ~= nil then
            if battleSkill:getBattleItem():getItemTypeAsInt() == 2 then  --魔法装備
                local itemTime = self.ctTbl[i] / 2; --装備CT半分の値を取得
                if battleSkill:getCoolTimer() <= itemTime then
                    if not megast.Battle:getInstance():isPvp() then
                        battleSkill:setCoolTimer(0);
                    else
                        battleSkill:setCoolTimer(battleSkill:getCoolTimer() / 2);
                    end
                end
            end
        end
    end
end


class:publish();

return class;