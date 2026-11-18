local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="てんぷれさん", version=1.9, id=2019554});

function class:start(event)
    self.gameUnit = event.unit;
    self.shots = {};
    self.shotTimer = 0;
    self.rate = 100;
    self.tableCheckSpan = 5;
    self.tableChoiceTimer = 3;
    self.innerTableTimer = 0;
    self.currentTableIndex = 0;
    self.totalTime = 0;

    self.SHOTS_DATA_LIST = {
        [1] = {
            WEIGHT = 10,
            ANIMATION = 1,
            ACTIVE_SKILL = 1
        },
        [2] = {
            WEIGHT = 10,
            ANIMATION = 2,
            ACTIVE_SKILL = 2
        },
        [3] = {
            WEIGHT = 10,
            ANIMATION = 3,
            ACTIVE_SKILL = 3
        }
    }
    summoner.Utility.messageByEnemy(self.TEXT.START_MESSAGE1 or "画面タップでジャンプ！");
    summoner.Utility.messageByEnemy(self.TEXT.START_MESSAGE2 or "長押しするとジャンプ力アップ！");

    self:makePatternTable();

    return 1;
end

function class:makePatternTable()
    self.pattern = {
        [1] = {
            {time = 0,pos = 0,shotType = 1,used = false},
            {time = 1,pos = 100,shotType = 2,used = false},
            {time = 2,pos = 200,shotType = 3,used = false},
            {time = 3,pos = 0,shotType = 1,used = false}
        },
        [2] = {
            {time = 0,pos = 0,shotType = 2,used = false},
            {time = 1,pos = 100,shotType = 2,used = false},
            {time = 2,pos = 0,shotType = 3,used = false},
            {time = 3,pos = 500,shotType = 3,used = false},
            {time = 3,pos = 0,shotType = 3,used = false}
        },
        [3] = {
            {time = 0,pos = 0,shotType = 1,used = false},
            {time = 1.1,pos = 0,shotType = 2,used = false},
            {time = 2.2,pos = 0,shotType = 3,used = false},
            {time = 3.3,pos = 0,shotType = 1,used = false}
        },
        [4] = {
            {time = 0,pos = 0,shotType = 1,used = false},
            {time = 1.5,pos = 200,shotType = 1,used = false},
            {time = 1.5,pos = 0,shotType = 2,used = false},
            {time = 3,pos = 300,shotType = 3,used = false}
        },
        [5] = {
            {time = 0,pos = 0,shotType = 1,used = false},
            {time = 1,pos = 200,shotType = 1,used = false},
            {time = 2,pos = 0,shotType = 2,used = false},
            {time = 3,pos = 200,shotType = 3,used = false}
        },
        [6] = {
            {time = 0,pos = 0,shotType = 2,used = false},
            {time = 1,pos = 100,shotType = 2,used = false},
            {time = 2,pos = 200,shotType = 2,used = false},
            {time = 3,pos = 0,shotType = 2,used = false}
        },
        [7] = {
            {time = 0,pos = 0,shotType = 1,used = false},
            {time = 1,pos = 100,shotType = 1,used = false},
            {time = 2,pos = 0,shotType = 1,used = false},
            {time = 3,pos = 200,shotType = 1,used = false}
        },

        [8] = {
            {time = 1,pos = 0,shotType = 3,used = false},
            {time = 1,pos = 50,shotType = 3,used = false},
            {time = 1,pos = 450,shotType = 3,used = false},
            {time = 1,pos = 500,shotType = 3,used = false},
            {time = 3,pos = 0,shotType = 1,used = false}
        },

        [9] = {
            {time = 1,pos = 0,shotType = 1,used = false},
            {time = 1.25,pos = 0,shotType = 2,used = false},
            {time = 1.5,pos = 0,shotType = 3,used = false},
            {time = 3,pos = 0,shotType = 2,used = false}
        },

    }
end

function class:startWave(event)
    event.unit:setVoiceEnable(false);
    if event.waves == 1 then
        self.shots[1] = self:createShotTable(1);
        self.shots[2] = self:createShotTable(2);
        self.shots[3] = self:createShotTable(3);
        self.shots[4] = self:createShotTable(1);
        self.shots[5] = self:createShotTable(2);
        self.shots[6] = self:createShotTable(3);
    end


    return 1;
end

function class:attackDamageValue_OrbitSystem(event)
    return 0;
end

function class:createShotTable(_activeSkill)
    local _orbit = self.gameUnit:addOrbitSystemWithFile("actionQuestShot","shot1");
    _orbit:takeAnimation(0,"none",true);
    _orbit:setPosition(-400,0);
    local newTable = {
        orbit = _orbit,
        activeSkill = _activeSkill,
        state = 0
    }

    return newTable;
end

function class:callShot(animationNumber,activeSkill,pos)
    for i, v in pairs(self.shots) do
        if v.state == 0 then
            self:setUpShot(v,animationNumber,activeSkill,pos);
            return;
        end
    end
end

function class:setUpShot(shot,animationNumber,activeSkill,pos)
    shot.state = 1;
    shot.orbit:takeAnimation(0,"shot"..animationNumber,true);
    shot.orbit:setActiveSkill(activeSkill);
    shot.orbit:setPosition(-450,pos);
end

function class:update(event)
    if  megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return 1;
    end
    self:shotCaller(event.deltaTime);
    return 1;
end

function class:shotCaller(deltaTime)
    self.shotTimer = self.shotTimer + deltaTime;
    self.tableChoiceTimer = self.tableChoiceTimer + deltaTime;
    self.innerTableTimer = self.innerTableTimer + deltaTime;
    self.totalTime = self.totalTime + deltaTime;


    -- if self.totalTime > 40 then
    --     for i, v in pairs(self.shots) do

    --         v.state = 0;
    --         v.orbit:takeAnimation(0,"none",true);

    --     end
    -- end
    if self.tableChoiceTimer > self.tableCheckSpan then
        self.currentTableIndex = Random.range(0,table.maxn(self.pattern)) + 1;
        --self.currentTableIndex = table.maxn(self.pattern);
        for i, v in pairs(self.pattern[self.currentTableIndex]) do
            v.used = false;
        end
        self.tableChoiceTimer = self.tableChoiceTimer - self.tableCheckSpan;
        self.innerTableTimer = 0;
    end

    if self.currentTableIndex == 0 then
        return
    end

    for i, v in pairs(self.pattern[self.currentTableIndex]) do
        if v.time <= self.innerTableTimer and not v.used then
            v.used = true;
            self:callShot(v.shotType,v.shotType,v.pos + 100);
        end
    end
    --if self.shotTimer > 1 then
    --    self.shotTimer = self.shotTimer - 1;
    --
    --    --local position = Random.range(0,500);
    --    --local type = self:sampleWeighted(self.SHOTS_DATA_LIST);
    --    self:callShot(self.SHOTS_DATA_LIST[shotType].ANIMATION,self.SHOTS_DATA_LIST[shotType].ACTIVE_SKILL,position);
    --end
end

function class:sampleWeighted(weightedList)
    local totalWeight = 0
    local keyValuePairs = {}
    for key, targetTable in pairs(weightedList) do
        totalWeight = totalWeight + targetTable.WEIGHT;
    end
    if totalWeight < 1 then
        return nil
    end
    local randomNumber =  Random.range(0, totalWeight) + 1
    local currentWeight = 0
    for key, targetTable in pairs(weightedList) do
        currentWeight = currentWeight + targetTable.WEIGHT;
        if currentWeight >= randomNumber then
            return key;
        end
    end
end


function class:run(event)
    if event.spineEvent == "onEndShot" then
        self:onEndShot(event.unit);
    end
    return 1;
end

function class:onEndShot(orbit)
    for i, v in pairs(self.shots) do
        if v.orbit == orbit then
            v.state = 0;
            v.orbit:takeAnimation(0,"none",true);
            return;
        end
    end
end

class:publish();

return class;