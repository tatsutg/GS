--[[
    クエストに紐づくスクリプト
    
  ]]

  local  questClass = {}

    
--初期化
function quest_init()
    print("init");
    
    timelimit = 180; --制限時間


    return 1;
end

--プレイヤーのチームの初期化
function initPlayerTeam(team)
    print("initPlayerTeam");
    
    return 1;
end

--エネミーのチームの初期化
function initEnemyTeam(team, wave)
    print("initEnemyTeam");

    return 1;
end

--ユニットが生成された時
function quest_takeIn(wave,unit)
    print("Lua:takeIn");
    
    return 1;
end

--バトルのセットアップ時
function questStart()
    print("Lua:questStart");
    questClass:start();
    
    return 1;
end

--戦闘開始の準備ができた時
function battleReady(wave)
    print("Lua:battleReady");
    -- BattleControl:get():showCountDownTime("additional/other/worldend.png", timelimit ,30, 620 , -100 ,0.8);

    return 1;
end

--戦闘の開始命令 注意 return 0している限り毎フレーム呼ばれます。
function waveRun(wave)
    questClass.wave = questClass.wave + 1;

    return 1;
end

--戦闘中のupdate
function quest_update(wave , delta ,time)
    questClass:updateControl(delta);
   
    return 1;
end



function questend()

    return 1;
end

--ユニットが倒れた時
function deadUnit(wave , unit)

    return 1;
end

--戦闘が終了した時
function waveEnd(wave,iswin)
    local team = megast.Battle:getInstance():getPlayerTeam();

    for i=0,7 do
       local uni = team:getTeamUnit(i);
       if uni ~= nil then
            uni:getSkeleton():setPosition(0,0);
       end
    end
    return 1;
end

--画面タッチ時
function onTouchBegan()
    
    questClass:onTouchBegan();
    return 1;
end

--画面タッチ終了時
function onTouchEnded(x , y)

    questClass:onTouchEnded();
    return 1;
end

--スキルボタンのタッチ終了時
function onTouchSkillEnded(index,isBurst)
    if questClass.wave == 1 then
        return 0;
    end
    return 1;
end

--アイテムボタンタッチ時
function onTouchItem(index,itemIndex)

    if questClass.wave == 1 then
        return 0;
    end
    return 1;
end

--ユニットのスキル発動時
function useSkill(index, isBurst)
    if questClass.wave == 1 then
        return 0;
    end
    return 1;
end

function quest_castItem(index, itemNo, targetIndex)
    print("Lua:castItem ".. index .. "," .. itemNo);
    
    return 1;
end

--シナリオのイベントコールバック
function scenarioOnButtonCallback(event)

    return 1;
end

--シナリオの終了時コールバック
function scenarioEndCallback(event)

    return 1;
end


function questClass:start()
    self.RUN_DURATION = 38;

    self.frontOrbit = nil;
    self.bgOrbit = nil;
    self.isTouch = false;
    self.firstUnitIndex = -1;
    
    self.jumpTimer = 0;
    self.jumpLimitTime = 0.3;
    self.gravityScale = 2500;
    self.gameTime = 0;

    self.jumpPowerDefault = 600;
    self.additionalPower = 4200;

    self.isGrownd = true;
    self.rapidDescent = 0

    self.unitTables = {};

    self:createBgs()

    self.jumpDataTable = {}
    self.jumpStartTimeTable = {}
    self.jumpIndex = 0;

   self.isEnd = false;
    
    self.wave = 0;

    self.jumpDataTable[0] = 0;
    self.jumpStartTimeTable[0] = 0;
end

function questClass:createBgs()
    local enemyTeam = megast.Battle:getInstance():getEnemyTeam();
    local uni = enemyTeam:getTeamUnit(0);
    for i=0,7 do
       uni = enemyTeam:getTeamUnit(i);
       if uni ~= nil then
            --summoner.Utility.messageByEnemy("いる");
            self.bgOrbit = uni:addOrbitSystemWithFile("bg2019514","animation");
            self.bgOrbit:setPosition(0,200);
            self.bgOrbit:takeAnimation(0,"animation",true);
            self.bgOrbit:setZOrder(0);

            self.frontOrbit = uni:addOrbitSystemWithFile("bg2019514","mae");
            self.frontOrbit:setPosition(0,200);
            self.frontOrbit:takeAnimation(0,"mae",true);
            self.frontOrbit:setZOrder(19999);

            self.controlOrbit = uni:addOrbitSystemWithFile("bg2019514","controller");
            self.controlOrbit:takeAnimation(0,"controller",true);
       end
    end
    
end

function questClass:onTouchBegan()
    self.isTouch = true;
end

function questClass:onTouchEnded()
    self.isTouch = false;
end

function questClass:updateControl(deltaTime)
    if self.wave > 1 then
        return 1;
    end
   if self.gameTime > self.RUN_DURATION - 1 and not self.isEnd then
      self.isEnd = true;
     self.controlOrbit:takeAnimation(0,"end",true);
   end
   if self.gameTime > self.RUN_DURATION then

      local enemyTeam = megast.Battle:getInstance():getEnemyTeam();
      for i=0,7 do
         uni = enemyTeam:getTeamUnit(i);
         if uni ~= nil then
            uni:setHP(0);
         end
      end
      self.wave = 2;
   end
    if self.wave == 1 and megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
      return
    end
    self.gameTime = self.gameTime + deltaTime;
    self:jumpInputControl(deltaTime);
    self:unitControl(deltaTime);

    local Eteam = megast.Battle:getInstance():getEnemyTeam();

    for i=0,7 do
       local ene = Eteam:getTeamUnit(i);
       if ene ~= nil then
            ene:setInvincibleTime(999);
            ene._ignoreBorder = true;
            ene:setPosition(-20000,2000);
            ene:getSkeleton():setPosition(0,0);
       end
    end

end

function questClass:unitControl(deltaTime)
         local team = megast.Battle:getInstance():getPlayerTeam();

    for i=0,5 do
       local uni = team:getTeamUnit(i);
       if self.unitTables[i] == nil then
         
         if uni ~= nil and self.firstUnitIndex == -1 then
            self.firstUnitIndex = i;
         end
         self.unitTables[i] = self:createUnitTable(i);
       end
       if uni ~= nil then
            uni:excuteAction();
            
            -- if uni:getunitState() ~= kunitState_move then
                uni:takeFront();
            --end
            
            self:unitPositionControl(uni,self.unitTables[i],deltaTime);
       end
    end
end

function questClass:createUnitTable(number)
    local newTable = {
        jumpTimer = 0,
        jumpPower = 0,
        isGrownd = true,
        rapidDescent = 0,
        jumpAmount = 0,
        index = number,
        posY = 0,
        offset = (number - self.firstUnitIndex) * 0.05,
        jumpTableIndex = 0,
        nowExcution = true
    }
    return newTable;
end


function questClass:unitPositionControl(unit,unitTable,deltaTime)
   
   
   self:jumpControl(unit,unitTable,deltaTime);

   self:gravityControll(unit,unitTable,deltaTime);
   self:move(unit,unitTable,deltaTime);

   --着地判定ここでやってます
   if not unitTable.isGrownd and unitTable.posY <= 0 then
      unitTable.posY = 0;
      unitTable.jumpPower = 0;
      unitTable.isGrownd = true;
      unitTable.rapidDescent = 0;
      -- summoner.Utility.messageByEnemy(self.firstUnitIndex);
      if unitTable.index == self.firstUnitIndex then
         self.isGrownd = true;
         self.rapidDescent = 0
      end
      --summoner.Utility.messageByEnemy("着地");
   end
end

function questClass:jumpInputControl(deltaTime)
   if self.isGrownd and self.isTouch then
      self.jumpIndex = self.jumpIndex + 1;
      self.isGrownd = false;
      self.jumpDataTable[self.jumpIndex] = 0;
      self.jumpTimer = 0;
      self.jumpStartTimeTable[self.jumpIndex] = self.gameTime;
   end

   if self.isGrownd == false and self.isTouch == false and self.rapidDescent == 0 then
      self.rapidDescent = 1
   end

   self.jumpTimer = self.jumpTimer + deltaTime;

   if self.isTouch and self.jumpTimer < self.jumpLimitTime then
      self.jumpDataTable[self.jumpIndex] = self.jumpDataTable[self.jumpIndex] + deltaTime;
   end

   if self.isTouch and self.isGrownd == false and self.rapidDescent == 1 then
      self.rapidDescent = 2
   end

end

function questClass:jumpControl(unit,unitTable,deltaTime)
   if self.rapidDescent > unitTable.rapidDescent then
     unitTable.rapidDescent = self.rapidDescent
   end

   if unitTable.isGrownd and self.jumpIndex > unitTable.jumpTableIndex then
      unitTable.jumpTableIndex = unitTable.jumpTableIndex + 1;
      unitTable.jumpTimer = 0;
      unitTable.nowExcution = false;
   end
  
   if  self.gameTime <= self.jumpStartTimeTable[unitTable.jumpTableIndex] + unitTable.offset then
      return
   end
   unitTable.jumpTimer = unitTable.jumpTimer + deltaTime;
   if not unitTable.nowExcution then
      unitTable.isGrownd = false;
      unitTable.jumpPower = self.jumpPowerDefault;
      unitTable.nowExcution = true;
   end

   if unitTable.isGrownd then
      return;
   end
   -- summoner.Utility.messageByEnemy(self.jumpDataTable[unitTable.jumpTableIndex]);
   if unitTable.jumpTimer <= self.jumpDataTable[unitTable.jumpTableIndex] then
      unitTable.jumpPower = unitTable.jumpPower + self.additionalPower * deltaTime;
      
   end

end

function questClass:gravityControll(unit,unitTable,deltaTime)
   if unitTable.isGrownd then
      unitTable.posY = 0;
      unitTable.jumpPower = 0;
      return;
   end

   if unitTable.rapidDescent == 2 then
       unitTable.jumpPower = unitTable.jumpPower - self.gravityScale * deltaTime * 3;
   else
       unitTable.jumpPower = unitTable.jumpPower - self.gravityScale * deltaTime;
   end

end


function questClass:move(unit,unitTable,deltaTime)
   
   unitTable.posY = unitTable.posY + unitTable.jumpPower * deltaTime;
   
   unit:getSkeleton():setPositionY(unitTable.posY);
   unit:setPosition(200 + unitTable.index * 50,0);
end





