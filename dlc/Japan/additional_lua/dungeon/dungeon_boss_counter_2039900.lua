local class = summoner.DungeonEventDispatcher.createDungeonClass({label="Test", version=1.0, id=2039900});

local json = summoner.Json;

function class:animationBox()
    self.animationBox = {
        [1] = "attack1",
        [2] = "attack2",
        [3] = "attack3",
        [4] = "attack4",
        [5] = "attack5",
        [11] = "damage"
    }
    self.animationEFBox = {
        [1] = "1-attack1",
        [2] = "1-attack2",
        [3] = "1-attack3",
        [4] = "1-attack4",
        [5] = "1-attack5"
    }
    return 1;
end

function class:init()
    return 1
end

-- event { instance,deltaTime}
function class:update(event)
    ---ユニット関係
    self:unitControl()

    ---ボス関係
    self.gameEnemy:setPosition(self.enemyPosX, self.baseY);
    self:enemyControl()
    return 1;
end

function class:unitControl()
    if self.unitMove then
    elseif self.unitSkillNum >= 1 then
        if self:calcDistance() < self.gameUnit:getRange_Min() then
            ---最小距離以下の場合takeBack
            self.unitMove = true
            self.gameUnit:takeBack()
        elseif self:calcDistance() > self.gameUnit:getRange_Max() + 150 then
            ---最大距離以上の場合takeFront
            self.unitMove = true
            local midDistance = (self.gameUnit:getRange_Max() - self.gameUnit:getRange_Min()) / 2
            local moveDistance = self:calcDistance() - (midDistance + self.gameUnit:getRange_Min())
            if moveDistance > 50 then moveDistance = 50 end
            self.gameUnit:moveFront(moveDistance)
            self.gameUnit:takeFront()
        else
            ---条件によっては攻撃
            self.unitMove = true
            self.gameUnit:takeSkill(self.unitSkillNum)
            self.unitSkillNum = 0;
        end
    else
        ---何もない場合は待機位置に戻る
        if self:idleDistance() < -20 then
            self.unitMove = true
            self.gameUnit:takeBack()
        elseif self:idleDistance() > 20 then
            self.unitMove = true
            self.gameUnit:moveFront(self:idleDistance())
            self.gameUnit:takeFront()
        end
    end
end

function class:enemyControl()
    if self.enemyMove then
    elseif self.enemySkillNum ~= 0 then
        self.enemyMove = true
        if self.enemySkillNum < 0 then
            self.gameEnemy:takeAnimation(0,self.animationBox[self.enemySkillNum * -1],false)
            if self.animationEFBox[self.enemySkillNum * -1] ~= nil then
                self.gameEnemy:takeAnimationEffect(0,self.animationEFBox[self.enemySkillNum * -1],false)
            end
        else
            self.gameEnemy:takeSkill(self.enemySkillNum)
        end
        self.enemySkillNum = 0;
    end
end

function class:calcDistance()
    local unitX = self.gameUnit:getPositionX()
    local enemyX = self.gameEnemy:getPositionX()
    local distance = unitX - enemyX
    return distance;
end

function class:idleDistance()
    local unitX = self.gameUnit:getPositionX()
    local distance = unitX - self.unitPosX
    return distance;
end

-- event { instance }
--Spineロード完了時に呼ばれる
function class:loaded(event)
    print("loaded");
    return 1;
end

-- event { instance }
--SpineがAddChildされた直後に呼ばれる
function class:began(event)
    self.gameUnit = event.instance:getTeamUnitByIndex(0);
    self.gameEnemy = event.instance:getTeamUnitByIndex(1);
    self.gameInstance = event.instance
    self.baseY = -30

    self.unitPosX = 170
    self.gameUnit:setPosition(self.unitPosX, self.baseY);
    self.gameUnit:setTargetUnit(self.gameEnemy);
    self.gameUnit:setZOrder(9999)
    self.unitSkillNum = 0
    self.unitMove = false

    self.enemyPosX = -200
    self.gameEnemy:setPosition(self.enemyPosX, self.baseY);
    self.gameEnemy:setTargetUnit(self.gameUnit);
    self.gameEnemy:setisPlayer(false);
    self.enemySkillNum = 0
    self.enemyMove = false
    self.gameEnemy:setScale(0.4,0.4)
    self.gameEnemy:addSubSkeleton("50003_leg",-30)

    self:animationBox()
    --event.instance:debugPrint("");
    return 1
end

-- event { instance, beforeCount, afterCount, beforeReward, afterReward }
--討伐数表示が更新されたときに呼ばれる
function class:resolved(event)
    local addNum = event.afterCount - event.beforeCount
    event.instance:debugPrint("増加数"..addNum)
    if addNum > 0 then
        self.unitSkillNum = 2
    end
    return 1;
end

-- event { instance, unitId }
--アニメーション終了時に呼ばれる
function class:finishedAnimation(event)
    if event.unitId == self.gameUnit:getUnitID() then
        self.unitMove = false
    end
    if event.unitId == self.gameEnemy:getUnitID() then
        self.enemyMove = false
    end
    print("finishedAnimation");
    return 1;
end

-- event { instance, unitId }
--ヒットエフェクトが表示された時に呼ばれる（unitIdは攻撃を受けたユニットのもの）
function class:hitAttack(event)
    if event.unitId == self.gameEnemy:getUnitID() then
        if not self.enemyMove then
            self.enemySkillNum = -11
        end
    end
    return 1;
end

class:publish();

return class;
