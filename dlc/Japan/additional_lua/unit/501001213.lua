--@additionalEnemy,100071820,100964250
local child = summoner.Bootstrap.createUnitClass({label="ガイア", version=1.3, id=501001213});
child:inheritFromUnit("giaBase");

child.consts = {
    summonEnemyID = 100071820,--ミキュオン
    summonEnemyID2 = 100964250,--ゴル猫キング
    barrierBuffID = 10171,
    barrierBuffEFID = 98,
    barrierValue = 30000,
    barrierDuration = 20,
    barrierIcon = 24,
    barrierAnimation = 1

};

function child:addBarrier(unit)
    -- local aquaCnt = select("#",summoner.Utility.findUnitsByCallBack(self.findUnitCallBack,unit:getisPlayer()));
    for i=0,7 do
        local target = unit:getTeam():getTeamUnit(i);
        local value = self.consts.barrierValue;
        if target ~= nil then
            if target == unit then
                value = value * 3;
            end
            if target:getBaseID3() == 7 then

                target:getTeamUnitCondition():addCondition(101713,27,-100,999999,17);
            elseif target:getBaseID3() == 96 then
                target:setDeadDropSp(150);
            end
            target:getTeamUnitCondition():addCondition(
                self.consts.barrierBuffID,
                self.consts.barrierBuffEFID,
                value,
                self.consts.barrierDuration,
                self.consts.barrierIcon,
                self.consts.barrierAnimation
            );
        end
    end
    return 1;
end
child:publish();

return child;