local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="ランゲーム_障害物 フリーレン", version=1.9, id=2070896});

function class:start(event)
    self.gameUnit = event.unit;
    self.shots = {};
    self.shotTimer = 0;
    self.rate = 100;
    self.tableChoiceTimer = 3;
    self.innerTableTimer = 0;
    self.currentTableIndex = 0;
    self.totalTime = 0;
    self.patternChangeCount = 0;

    self.GD = summoner.Utility.getGimmickJsonData(event.unit, {
        tableCheckSpan = 5,
        shakeAnimationNumber = 2,
        mimicBuffValue = -30,
        treasureBuffValue = 150,
        orbitDamageA = 10,
        orbitDamageB = 30,
        orbitDamageC = 30,
        orbitDamageD = -20,
        orbitDamageE = 0,
        orbitDamageF = 0,
    })

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
    self.BUFF_BOX_LIST = {
        [1] = {
            ID = 20708961,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 180,
            MAX = 99
        },
        [2] = {
            ID = 20708962,
            BUFF_ID = 126,
            VALUE = -99999,
            DURATION = 99999,
            ICON = 0
        },
        [3] = {
            ID = 0,
            BUFF_ID = 17,
            VALUE = self.GD.mimicBuffValue,
            DURATION = 99999,
            ICON = 27
        },
        [4] = {
            ID = 0,
            BUFF_ID = 17,
            VALUE = self.GD.treasureBuffValue,
            DURATION = 99999,
            ICON = 26
        },
        [5] = {
            ID = 20708962,
            BUFF_ID = 0,
            VALUE = 0,
            DURATION = 99999,
            ICON = 0
        },
        [6] = {
            ID = 20708961,
            BUFF_ID = 0,
            VALUE = 10,
            DURATION = 99999,
            ICON = 180,
            MAX = 99,
            MIMIC = true
        }
    }
    self.orbitDamage = {
        [1] = self.GD.orbitDamageA,
        [2] = self.GD.orbitDamageB,
        [3] = self.GD.orbitDamageC,
        [4] = self.GD.orbitDamageD,
        [5] = self.GD.orbitDamageE,
        [6] = self.GD.orbitDamageF
    }
    summoner.Utility.messageByEnemy(self.TEXT.START_MESSAGE1 or "画面タップでジャンプ！");
    summoner.Utility.messageByEnemy(self.TEXT.START_MESSAGE2 or "長押しするとジャンプ力アップ！");
    summoner.Utility.messageByEnemy(self.TEXT.START_MESSAGE3 or "被弾でボスのクリティカルダメージ耐性アップ",5,Color.yellow);

    self.summaryTextDamage = self.TEXT.SUMMARY_MESSAGE1 or "%ダメージ"
    self.summaryTextHeal = self.TEXT.SUMMARY_MESSAGE2 or "%回復"
    self.summaryTextMimic1 = self.TEXT.SUMMARY_MESSAGE3 or "与ダメージ"
    self.summaryTextMimic2 = self.TEXT.SUMMARY_MESSAGE4 or "%"
    self.summaryTextMimic3 = self.TEXT.SUMMARY_MESSAGE5 or "DOWN"
    self.summaryTextMimic4 = self.TEXT.SUMMARY_MESSAGE6 or "UP"

    self:makePatternTable()

    self.randomSeedBase = 0

    self.treasureIndex = self:makeRandom(4,7)
    return 1
end

function class:makePatternTable()
    self.pattern = {
        [1] = {
            {time = 1,pos = 0,shotType = {1},used = false},
            {time = 1,pos = 100,shotType = {1,2},used = false},
            {time = 3,pos = 200,shotType = {5},used = false},
            {time = 4,pos = 0,shotType = {1,2},used = false}
        },
        [2] = {
            {time = 0.5,pos = 0,shotType = {1,2},used = false},
            {time = 1,pos = 100,shotType = {1},used = false},
            {time = 2,pos = 50,shotType = {1,2},used = false},
            {time = 3,pos = 300,shotType = {5},used = false},
            {time = 3,pos = 0,shotType = {1},used = false}
        },
        [3] = {
            {time = 0,pos = 0,shotType = {1,2},used = false},
            {time = 2.2,pos = 100,shotType = {1},used = false},
            {time = 2.4,pos = 50,shotType = {1},used = false},
            {time = 4.5,pos = 300,shotType = {5,2},used = false}
        },
        [4] = {
            {time = 0,pos = 0,shotType = {1,2},used = false},
            {time = 1.5,pos = 200,shotType = {1},used = false},
            {time = 3.5,pos = 0,shotType = {1,2},used = false},
            {time = 4.5,pos = 300,shotType = {1,5},used = false}
        },
        [5] = {
            {time = 0,pos = 50,shotType = {5},used = false},
            {time = 1,pos = 200,shotType = {1},used = false},
            {time = 4,pos = 0,shotType = {1,5},used = false},
            {time = 3,pos = 200,shotType = {1,2},used = false}
        },
        [6] = {
            {time = 1,pos = 0,shotType = {1},used = false},
            {time = 2,pos = 200,shotType = {5},used = false},
            {time = 3.5,pos = 0,shotType = {1},used = false},
            {time = 5.0,pos = 300,shotType = {5},used = false}
        },
        [7] = {
            {time = 0.5,pos = 0,shotType = {1},used = false},
            {time = 0.5,pos = 100,shotType = {5},used = false},
            {time = 1.5,pos = 300,shotType = {2},used = false},
            {time = 3,pos = 50,shotType = {1,2},used = false}
        },

        [8] = {
            [1] = {time = 1,pos = 0,shotType = {1},used = false},
            [2] = {time = 1.5,pos = 150,shotType = {5},used = false},
            [3] = {time = 1.5,pos = 300,shotType = {2},used = false},
            [4] = {time = 2.2,pos = 0,shotType = {1,5},used = false},
            [5] = {time = 3,pos = 0,shotType = {1,2},used = false}
        }

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
    for i = 0,6 do
        local myTeamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[2])
        end
    end
    return 1;
end

function class:attackDamageValue_OrbitSystem(event)
    local skillIndex = event.unit:getActiveSkillAsInt()
    for i, v in pairs(self.shots) do
        if v.orbit == event.unit then
            skillIndex = v.activeSkill
            v.activeSkill = 0
        end
    end
    if skillIndex ~= 0 then
        local damageRate = self.orbitDamage[skillIndex]
        local team = event.enemy:getTeam()
        local posted = false
        for i = 0,6 do
            local myTeamUnit = team:getTeamUnit(i)
            if myTeamUnit ~= nil then
                local damage = myTeamUnit:getCalcHPMAX() * damageRate / 100
                if damage < 0 then
                    damage = damage * -1
                end
                if damage > myTeamUnit:getHP() then
                    damage = myTeamUnit:getHP()
                end
                self.BUFF_BOX_LIST[1].VALUE = damageRate
                self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[1]);
                if damageRate > 0 then
                    myTeamUnit:setHP(myTeamUnit:getHP() - damage)

                    if posted == false then
                        myTeamUnit:playSummary(damageRate..self.summaryTextDamage,false)
                        posted = true
                    end
                elseif  damageRate < 0 then
                    myTeamUnit:setHP(myTeamUnit:getHP() + damage)
                    if myTeamUnit:getHP() > myTeamUnit:getCalcHPMAX() then
                        myTeamUnit:setHP(myTeamUnit:getCalcHPMAX())
                    end

                    if posted == false then
                        myTeamUnit:playSummary((damageRate * -1)..self.summaryTextHeal,false)
                        posted = true
                    end
                else
                    if skillIndex == 5 then
                        self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[6]);
                        self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[3]);
                        if posted == false then
                            local value = math.abs(self.GD.mimicBuffValue)
                            local str = self.summaryTextMimic1..value..self.summaryTextMimic2..self.summaryTextMimic3
                            myTeamUnit:playSummary(str,false)
                            posted = true
                        end
                    elseif skillIndex == 6 then
                        self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[4]);
                        if posted == false then
                            local value = math.abs(self.GD.treasureBuffValue)
                            local str = self.summaryTextMimic1..value..self.summaryTextMimic2..self.summaryTextMimic4
                            myTeamUnit:playSummary(str,false)
                            posted = true
                        end
                    end
                end
            end
        end
        local animation = "hit4"
        if skillIndex == 5 then
            animation = "open"
            summoner.Utility.messageByEnemy(self.TEXT.BOX_GET_MESSAGE1 or "ミミックだ！ 与ダメージ30%ダウン！",5,Color.red);
        elseif skillIndex == 6 then
            animation = "get"
            summoner.Utility.messageByEnemy(self.TEXT.BOX_GET_MESSAGE2 or "宝箱ゲット♪ 与ダメージ150%アップ！！",5,Color.yellow);
        end
        event.unit:takeAnimation(0,animation,true);
        event.unit:setActiveSkill(0)
    end
    return 0;
end

function class:createShotTable(_activeSkill)
    local _orbit = self.gameUnit:addOrbitSystemWithFile("actionQuestShot","shot1");
    _orbit:takeAnimation(0,"none",true);
    _orbit:setPosition(-400,0);
    local newTable = {
        orbit = _orbit,
        activeSkill = _activeSkill,
        state = 0,
        shakeTime = self:makeRandom(1,4)
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
    shot.orbit:takeAnimation(0,"none",false);
    shot.orbit = nil
    local animation = "shot"..animationNumber
    if animationNumber >= 5 then
        animation = "idle"
        shot.shakeTime = self:makeRandom(1,4)
        shot.orbit = self.gameUnit:addOrbitSystemWithFile("actionQuestMimic","idle");
    elseif animationNumber == 4 then
        shot.orbit = self.gameUnit:addOrbitSystemWithFile("actionQuestShotHeal","shot"..animationNumber);
    else
        shot.orbit = self.gameUnit:addOrbitSystemWithFile("actionQuestShot","shot"..animationNumber);
    end
    shot.orbit:takeAnimation(0,animation,true);
    shot.activeSkill = activeSkill
    shot.orbit:setActiveSkill(activeSkill);
    shot.orbit:setPosition(-450,pos);
end

function class:update(event)
    if  megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return 1;
    end
    for i = 0,6 do
        local myTeamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if myTeamUnit ~= nil then
            myTeamUnit:setBurstPoint(0)
            ---ダメージ量が100%に到達したら強制死亡
            local buff = myTeamUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_BOX_LIST[1].ID);
            if buff ~= nil then
                --summoner.Utility.messageByEnemy(buff:getValue())
                if buff:getValue() >= 100 then
                    myTeamUnit:setHP(0)
                    myTeamUnit:getTeam():deadUnit(myTeamUnit:getIndex());
                end
            end
        end
    end
    self:shotCaller(event.deltaTime);
    return 1;
end

function class:makeRandom(min,max)
    self.randomSeedBase = self.randomSeedBase + 1
    math.randomseed(os.time() + self.randomSeedBase)
    return Random.range(min,max);
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
    if self.tableChoiceTimer > self.GD.tableCheckSpan then
        ---パターンチェンジ回数カウント
        self.patternChangeCount = self.patternChangeCount + 1
        --summoner.Utility.messageByEnemy(self.patternChangeCount)
        if self.patternChangeCount <= 3 then
            ---パターンチェンジ3回以前
            self.currentTableIndex = Random.range(0,table.maxn(self.pattern)) + 1;
        elseif self.patternChangeCount <= 6 then
            ---パターンチェンジ3回後
            self.currentTableIndex = 8
            self.pattern[self.currentTableIndex] = {}
            local posTable = {0,0,0,0,0,50,100,150,200,300}
            local mimicIndex = self:makeRandom(1,6)
            for i = 1, 5 do
                ---時間をランダムに抽選
                local Time = self:makeRandom(10,31) / 10
                ---位置をランダムに抽選
                local Pos = posTable[self:makeRandom(1,11)]
                ---ショットタイプをランダムに抽選
                local ShotType = self:makeRandom(1,5)
                if i == mimicIndex then
                    ---ミミック出現
                    ShotType = 5
                    if self.patternChangeCount == self.treasureIndex then
                        ---宝箱出現
                        ShotType = 6
                    end
                end
                table.insert(self.pattern[self.currentTableIndex], {
                    time = Time,
                    pos = Pos,
                    shotType = {ShotType},
                    used = false
                })
            end

            --[[
            local function shuffle(tbl)
                local len = #tbl
                for i = len, 2, -1 do
                    local j = math.random(i)
                    tbl[i], tbl[j] = tbl[j], tbl[i]
                end
            end

            local timeAndPosYList = {}
            for time = 0, 4 do
                local posYList = {0, 100, 300, 400}
                for _, posY in ipairs(posYList) do
                    table.insert(timeAndPosYList, {time, posY})
                end
            end
            shuffle(timeAndPosYList)

            local shotTypeList = {1, 1, 1, 1, 2, 2, 3, 4}
            shuffle(shotTypeList)

            for i = 1, 7 do
                local time, posY = unpack(timeAndPosYList[i])
                local shotType = shotTypeList[i]
                table.insert(self.pattern[self.currentTableIndex], {
                    time = time,
                    pos = posY,
                    shotType = {shotType},
                    used = false
                })
            end
            ]]--
        else
            return
        end

        for i, v in pairs(self.pattern[self.currentTableIndex]) do
            v.used = false
        end

        self.tableChoiceTimer = self.tableChoiceTimer - self.GD.tableCheckSpan
        self.innerTableTimer = 0

        for i, v in ipairs(self.pattern[self.currentTableIndex]) do
            --Utility.messageByPlayer(v.time .. "s, " .. v.pos)
            self:log(self.currentTableIndex .. ": " .. v.time .. "s, " .. v.pos)
        end
    end

    if self.currentTableIndex == 0 then
        return
    end

    for i, v in pairs(self.pattern[self.currentTableIndex]) do
        if v.time <= self.innerTableTimer and not v.used then
            v.used = true;
            ---ショットタイプをランダムに抽選
            local shotType = Random.sample(v.shotType)
            self:callShot(shotType, shotType, v.pos + 80);
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

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
    for i = 0,6 do
        local myTeamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
        if myTeamUnit ~= nil then
            self:execAddBuff(myTeamUnit,self.BUFF_BOX_LIST[5])
        end
    end
    return 1
end

function class:run(event)
    if event.spineEvent == "onEndShot" then
        self:onEndShot(event.unit);
    end
    if string.gmatch(event.spineEvent,"shake_") then
        local shakeIndex = string.gsub(event.spineEvent,"shake_","");
        self:shake(event.unit,shakeIndex)
    end
    return 1;
end

function class:onEndShot(orbit)
    for i, v in pairs(self.shots) do
        if v.orbit == orbit then
            if v.activeSkill == 6 then
                summoner.Utility.messageByEnemy(self.TEXT.BOX_MESSAGE1 or "しまった！宝箱を取りのがした！！",5,Color.magenta);
            end

            v.state = 0;
            v.orbit:takeAnimation(0,"none",true);
            return;
        end
    end
end

function class:shake(orbit,index)
    for i, v in pairs(self.shots) do
        if v.orbit == orbit and v.shakeTime == tonumber(index) and v.activeSkill == 5 then
            v.shakeTime = 0
            v.orbit:takeAnimation(0,"shake"..self.GD.shakeAnimationNumber,true);
            return;
        end
    end
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    local oldBuff = nil
    local count = 1
    local value = 0
    local addValue = buffBox.VALUE
    if buffBox.MAX ~= nil then
        oldBuff = unit:getTeamUnitCondition():findConditionWithID(buffBox.ID)
        if oldBuff ~= nil then
            value = oldBuff:getValue()
            if buffBox.VALUE > 0 then
                count = oldBuff:getNumber() + 1
            elseif buffBox.VALUE <= 0 then
                count = oldBuff:getNumber()
            end
        else
            if buffBox.VALUE <= 0 then
                return;
            end
        end
        if buffBox.MIMIC ~= nil then
            addValue =  value
        else
            addValue = buffBox.VALUE + value
        end
        if addValue < 0 then
            addValue = 0
        end
    end

    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,addValue,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,addValue,buffBox.DURATION,buffBox.ICON);
    end

    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
        if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
        if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
        if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
        if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
        if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
    end

    if buffBox.MAX ~= nil then
        buff:setMaxConditionIconNumber(buffBox.MAX);
        buff:setNumber(count)
        megast.Battle:getInstance():updateConditionView()
    end

    return buff;
end

class:publish();

return class;