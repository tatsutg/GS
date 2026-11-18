--@additionalEnemy,900550013
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星12_光耀竜フォスラディウス", version=2.5, id="gb_900550012"});
class:inheritFromEnemy("gb_901050012");


function class:setIDs()
    self.summonEnemyID = 900550013  --ブラッディバットのID
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    ---サブバー表示
    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);
    elseif not self.subBarFlg and self.timerFlg then
        self.timerFlg = false;
        self:extraTimer("delete" ,self.exTimerSetTbl);
    end

    ---死亡時処理
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
        if self.lastSkillFLG == nil then self.lastSkillFLG = false end
        if self.lastSkillFLG and event.unit:getUnitState() ~= kUnitState_skill then
            event.unit:getTeam():deadUnit(event.unit:getIndex());
            megast.Battle:getInstance():waveEnd(true);
        end
        if self.TRIGGERS[4].used then
            if self.deadCount == nil then self.deadCount = 0 end
            self.deadCount = self.deadCount + event.deltaTime
            if self.deadCount >= 15 then
                event.unit:getTeam():deadUnit(event.unit:getIndex());
                megast.Battle:getInstance():waveEnd(true);
            end
        end
    end
    event.unit:setReduceHitStop(self.GD.hitStop,1);---ヒットストップ無効or時止め無効
    return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    --megast.Battle:getInstance():waveEnd(true);
    return 0;
end


class:publish();

return class;