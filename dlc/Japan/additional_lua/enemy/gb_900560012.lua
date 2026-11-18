--@additionalEnemy,900560013,900560014
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="グランドバトル_EXボス_星12_銀翼魔従ヴァルザンデス", version=2.7, id="gb_900560012"});
class:inheritFromEnemy("gb_901060012");

function class:setIDs()
    self.summonEnemyID1 = 900560013  --メルキオンのID
    self.summonEnemyID2 = 900560014  --竜牙兵のID
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    if event.unit:getUnitState() ~= kUnitState_skill then
        self:hpTriggersCheck(event.unit);
    end

    -- 雑魚敵の人数を常に監視
    local count = self.friendCount
    self:findFriend()
    if count ~= self.friendCount then
        -- 人数に応じてバフを更新する
        self:addFriendBuff(event.unit)
    end

    -- 奥義５発動後
    if event.unit:getUnitState() ~= kUnitState_skill then
        if self.skill1Flg then
            self.skill1Flg = false
            ---ヘイトギミック
            self:gbHateTargetCheck(event.unit);
            self:setSkill1Gimmick(event.unit);
        end
    end

    -- 召喚の実行
    self:summonExecute(event.deltaTime)

    ---サブバー表示
    if self.subBarFlg then
        self:subBarControll(event.unit,self.damage);
    end

    if self.isChargingState == 1 then
        self:charge(event.deltaTime)---チャージ
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