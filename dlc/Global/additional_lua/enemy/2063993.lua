local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="神族の遺跡_10層_Normal_ハーモナー", version=2.5, id=2063993});
class:inheritFromEnemy("2063996");

function class:setIDs(event)
    self.baseEnemyID = 2063994
    return 1
end

function class:takeDamageValue(event)
    ---オービット判定
    local enemyUnit = self:getAncestorUnit(event.enemy);
    ---状態異常の数で補正をかける
    self.deBuffCount = 0;
    self:deBuffCheck(event.unit);
    if self.deBuffCount == 0 then
        event.value = event.value * 0.1;
    else
        event.value = event.value * (self.GD.deBuffDmgVal * self.deBuffCount);
    end

    event.value = self:adjustHpFlg(event.unit,event.value);
    return event.value;
end

class:publish();

return class;