local Bootstrap, Color, Random, Utility,Json = summoner.import("Bootstrap", "Color", "Random", "Utility","Json")
local class = summoner.Bootstrap.createUnitClass({label="樹怪鳥", version=1.3, id=501551313})

class.ATTACK_TBL_GROUND = {
   attack7 = 1
}
class.ATTACK_TBL_FLYING = {
   attack4 = 1,
   attack5 = 1
   -- attack6 = 1
}
class.SKILL_TBL_FLYING = {
   skill1 = 1,
   skill2 = 1,
   skill3 = 1
}
class.ACTIONSKILL_TBL = {
   attack1 = 1,
   attack2 = 2,
   attack3 = 3,
   attack4 = 4,
   attack5 = 5,
   attack6 = 6,
   attack7 = 6,
   skill1 = 7,
   skill2 = 8,
   skill3 = 9,
   skill4 = 7
}

class.FIND_COND_ID = 96
class.ANIMATION_LIST = {
   "idle",
   "idle2",
   "damage",
   "damage2"
}

class.BATTLE_POINT_VALUE = 1000;
class.BATTLE_POINT_VALUE_FIXED = 1000000;
class.BURN_TIME_RANGE = 30;

----------[[メッセージ]]----------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "相手との距離が遠いほど回避率アップ",
         COLOR = Color.yellow,
         DURATION = 5
      }
   }

   self.WIND_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.WIND_MESSAGE1 or "暴風状態：強烈な風で押し戻される……！！",
         COLOR = Color.yellow,
         DURATION = 5
      },
      [2] = {
         MESSAGE = self.TEXT.WIND_MESSAGE2 or "燃焼で風速低下！",
         COLOR = Color.yellow,
         DURATION = 5
      }
   }

   self.HP50_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "行動速度アップ",
         COLOR = Color.yellow,
         DURATION = 5
      }      
   }

   self.HP30_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP30_MESSAGE1 or "奥義ゲージ速度アップ",
         COLOR = Color.yellow,
         DURATION = 5
      }     
   }

   self.BURN_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.BURN_MESSAGE1 or "風が弱まった！",
         COLOR = Color.red,
         DURATION = 10,
         isPlayer = false
      }
   }

   self.BURN_MESSAGE_LIST2 = {
      [1] = {
         MESSAGE = self.TEXT.BURN_MESSAGE2 or "さんの援護で風が弱まった！",
         COLOR = Color.red,
         DURATION = 10,
         isPlayer = false
      }
   }

   self.BURN_MESSAGE_LIST3 = {
      [1] = {
         MESSAGE = self.TEXT.BURN_MESSAGE3 or "追い風が吹き始めた！",
         COLOR = Color.red,
         DURATION = 10,
         isPlayer = false
      }
   }

   self.BURN_MESSAGE_LIST4 = {
      [1] = {
         MESSAGE = self.TEXT.BURN_MESSAGE4 or "さんの援護で追い風が吹き始めた！",
         COLOR = Color.red,
         DURATION = 10,
         isPlayer = false
      }
   }

       -- レイドメッセージ
    self.RAID_MESSAGES = {
      [1] = {
            MESSAGE = self.TEXT.mess1 or "ボスに狙われている！",
            COLOR = Color.red,
            DURATION = 10,
            isPlayer = false
        }
    }
end

--------[[バフ]]--------
function class:setBuffBoxList()
   self.BUFF_LIST = {
      [1] = {
         ID = 20139431,
         BUFF_ID = 28, -- 行動速度
         VALUE = 30,
         DURATION = 999999,
         ICON = 7
      },
      [2] = {
         ID = 20139432,
         BUFF_ID = 0, -- 奥義ゲージ
         VALUE = 0,
         DURATION = 999999,
         ICON = 36
      },
      [3] = {
         ID = 20139433,
         BUFF_ID = 31, -- 回避
         VALUE = 100,
         DURATION = 999999,
         ICON = 16,
         SCRIPT = 205,
         SCRIPTVALUE1 = 600,
         SCRIPTVALUE2 = 200
      }
   }

   self.TARGET_BUFF_BOX_LIST = {
      [1] = {
          ID = 501299,
          BUFF_ID = 17, -- ダメージ
          VALUE = 50,
          DURATION = 999999,
          ICON = 26
     }
   }
   
end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TRIGGERS = {
      -- [1] = {
      --    tag = "HP_FLG",
      --    action = function (status) self:hp50(status) end,
      --    HP = 50,
      --    used = false
      -- },
      -- [2] = {
      --    tag = "HP_FLG",
      --    action = function (status) self:hp30(status) end,
      --    HP = 30,
      --    used = false
      -- }
   }

   self.HP_TRIGGERS = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.HP_TRIGGERS[index] = trigger
      end
   end
end

function class:hp50(status)
   if status == "use3" then
      self:showMessage(self.HP50_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_LIST[1])
   end
end

function class:hp30(status)
   if status == "use3" then
      self:showMessage(self.HP30_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_LIST[2])
      self.spValue = 40
   end
end



---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   event.unit:setSPGainValue(0)
   event.unit:setSkillInvocationWeight(0);
   event.unit:setNextAnimationName("idle")
   self.windUnit = nil
   self.gameUnit = event.unit
   self.spValue = 20
   self.isFlying = true
   self.isFind = false
   self:setBuffBoxList()
   self:setMessageBoxList()
   self:setTriggerList()
   self.isWind = false;
   self.beforeTotalSpeed = 0;
   self.startTime = nil;
   self.index = 0;
   self.damageTimer = 0;
   self.tableFetchTimer = 0;
   self.remortBurnTables = {};

   self.bar = nil;

   self.windPower = 0;
   self.beforeburn = false;
   
   self.burnActTime = 0;

   self.burnTimes = {};

   self.burnTimeIndex = 0;


   self:showMessage(self.START_MESSAGE_LIST)
   self:setBar();
   
   
   return 1
end

-- ホストでアニメーションを設定してゲストに流す
function class:setBirdAnimation(index)
   if megast.Battle:getInstance():isHost() then
      self.gameUnit:setNextAnimationName(self.ANIMATION_LIST[index])
      megast.Battle:getInstance():sendEventToLua(self.scriptID,4,index);
   end
end

function class:receive4(args)
   self.gameUnit:setNextAnimationName(self.ANIMATION_LIST[args.arg])   
   return 1
end

function class:startWave(event)
   self:takeInitGet(event.unit);
   self:setStartTime();
   self:setIndex();
   self:showAura();
   
  return 1
end

---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)   
   if self.isFlying then 
      self:setBirdAnimation(1)
      -- event.unit:setNextAnimationName("idle")
   else
      self:setBirdAnimation(2)
      -- event.unit:setNextAnimationName("idle2")
   end
   return 1
end

---------------------------------------------------------------------------------
-- damage
---------------------------------------------------------------------------------
function class:takeDamage(event)
   if self.isFlying then
      self:setBirdAnimation(3)
      -- event.unit:setNextAnimationName("damage")
   else
      self:setBirdAnimation(4)
      -- event.unit:setNextAnimationName("damage2")
   end
   return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if "takeOFfEnd" == event.spineEvent then
      self.isFlying = true
      event.unit:takeSkill(self.currentSkill)
   end

   if "showWindAura" == event.spineEvent then
      self:showAura()
   end

   if "hideWindAura" == event.spineEvent then
      self:hideAura()
   end

   if "addSP" == event.spineEvent then
      event.unit:addSP(self.spValue);
   end


   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
  self:HPTriggersCheck(self.gameUnit)
  self:setWindPosition(event.unit)
  self:windControll(event.deltaTime);
  self:fetchBurnActTime(event.unit);
  self:burnChecker(event.unit);
   return 1
end

function class:setWindPosition(unit)
   if self.isWind then
      self.windUnit:setPositionX(unit:getAnimationPositionX());
      self.windUnit:setPositionY(unit:getAnimationPositionY());
   end
end

function class:showAura()
   self.isFlying = true;
   if self.windUnit == nil then
      self.windUnit = self.gameUnit:addOrbitSystem("wind_roop")
      self.windUnit:setAnimation(0,"wind_roop",true)
      self.windUnit:setPositionX(self.gameUnit:getAnimationPositionX());
      self.windUnit:setPositionY(self.gameUnit:getAnimationPositionY());
      self.windUnit:setZOrder(9998);
      self.isWind = true
      self:showMessage(self.WIND_MESSAGE_LIST)
   else
      self.windUnit:setAnimation(0,"wind_roop",true);
      self.isWind = true;
   end
   if self.windPower < 5 then
      self.windPower = 5;
   end
   
end

function class:hideAura()
   self.windUnit:setAnimation(0,"enpty",true)
   self.isWind = false;
end

---------------------------------------------------------------------------------
-- break
---------------------------------------------------------------------------------
function class:takeBreake(event)
   self.isFlying = false
   self:hideAura();
   self.windPower = 0;
   return 1
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event) 
   if self.attackFlg == false and megast.Battle:getInstance():isHost() then
      self.attackFlg = true
      local attackKeyName = summoner.Random.sampleWeighted(self:attackTbl())
      local attackStr = string.gsub(attackKeyName,"attack","")
      local attackNo = tonumber(attackStr)
      event.unit:takeAttack(attackNo)
      return 0
   end
   self.attackFlg = false

   self.fromHost = false;
   
   event.unit:setActiveSkill(self.ACTIONSKILL_TBL["attack"..event.index])
   return 1
end

function class:attackTbl()
   if self.isFlying then
      return self.ATTACK_TBL_FLYING
   end
   return self.ATTACK_TBL_GROUND
end

function class:receive1(args)
    self:takeAttackFromHost(self.gameUnit,args.arg);
    return 1;
end

function class:takeAttackFromHost(unit,index)
    self.fromHost = true;
    unit:takeAttack(index);
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
   if self.skillFlg == false and megast.Battle:getInstance():isHost() then 
      self.skillFlg = true

      if not self.isFlying then
         -- self.isFlying = true
         event.unit:takeSkill(4)
         megast.Battle:getInstance():sendEventToLua(self.scriptID,2,4);
         return 0
      end

      local skillKeyName = summoner.Random.sampleWeighted(self.SKILL_TBL_FLYING)
      local skillStr = string.gsub(skillKeyName,"skill","")
      local skillNo = tonumber(skillStr)

      event.unit:takeSkill(skillNo)

      return 0

   end

   self.skillFlg = false

   self.fromHost = false;
   event.unit:setActiveSkill(self.ACTIONSKILL_TBL["skill"..event.index])

   return 1
end

function class:receive2(args)
    self:takeSkillFromHost(self.gameUnit,args.arg);
    return 1;
end

function class:takeSkillFromHost(unit,index)
    self.fromHost = true;
    unit:takeSkill(index);
end


--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
   if index == nil then 
      self:showMessageAll(messageBoxList)
   return
   end
   self:execShowMessage(messageBoxList[index])
end

function class:showMessageAll(messageBoxList)
   for i,messageBox in pairs(messageBoxList) do
      self:execShowMessage(messageBox)
   end
end

function class:showMessageRange(messageBoxList,start,finish)
   for i = start,finish do
      self:execShowMessage(messageBoxList[i])
   end
end

function class:execShowMessage(messageBox)
   summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
end


--===================================================================================================================
--トリガー
--===================================================================================================================
function class:HPTriggersCheck(unit)
   if not self:getIsHost() then
      return;
   end

   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

   for index,trigger in pairs(self.HP_TRIGGERS) do
      if trigger.HP >= hpRate and not trigger.used then
         self:execTrigger(index)
      end
   end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
   if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end

   receiveNumber = receiveNumber ~= nil and receiveNumber or 3

   local action = "use" .. receiveNumber

   self.TRIGGERS[index].action(action)
   self.TRIGGERS[index].used = true

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end



function class:windControll(deltaTime)
   if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
       return;
    end
   
   self:windPowerCheck();
   self:getBurnTables(deltaTime);
   local totalPower = self.windPower - self:liveBurnCheck();
   self:addWindBuff(totalPower);

   if totalPower > 0 then
      self.damageTimer = self.damageTimer + deltaTime;
   end

   if self.beforeTotalSpeed ~= totalPower then
      self:changeSpeed(totalPower);
   end
   self.beforeTotalSpeed = totalPower;
   if totalPower <= 0 then
      return;
   end
   -- summoner.Utility.messageByEnemy(totalPower);
   for i= 0,7 do
      local unit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i);

      if unit ~= nil then
         local speed = totalPower * 40;
         if speed > 240 then
            speed = 240;
         end
         local pos = unit:getPositionX() + speed * deltaTime;
         if pos > 450 then
            pos = 450;
         end
         if self.damageTimer > 1 then
            self:addDamage(totalPower,unit);
         end
         
         unit:setPositionX(pos);
      end
   end

   if self.damageTimer > 1 then
      self.damageTimer = self.damageTimer - 1;
   end
end

function class:windPowerCheck()
   if not self.isWind then
      return;
   end

   local gameTime = RaidControl:get():getCurrentRaidTime() - self.startTime;
   gameTime = math.floor(gameTime);

   -- summoner.Utility.messageByEnemy(self.startTime);

   self.windPower = 5 + math.floor(gameTime/60);

   if self.windPower > 20 then
      self.windPower = 20;
   end
end

function class:addDamage(level,unit)
   if level > 20 then
      level = 20;
   end

   if level < 1 then
      return;
   end

   local power = 0.01;

   if level > 9 then
      power = 0.02;
   end
   local damage = unit:getCalcHPMAX() *  power;
   unit:setHP(unit:getHP() - damage);
   unit:takeDamagePopup(unit,damage);



end

function class:addWindBuff(level)
   if level > 20 then
      level = 20;
   end

   if level < -20 then
      level = -20;
   end
   WIND_BUFF = {
      ID = 501551,
      BUFF_ID = 21, -- 被ダメ
      VALUE = -5 * level,
      DURATION = 999999,
      ICON = 139
   }
   -- summoner.Utility.messageByEnemy(level);
   local buff = self.gameUnit:getTeamUnitCondition():findConditionWithID(WIND_BUFF.ID);
   if buff ~= nil then
      if level >= 0 then
         self.gameUnit:getTeamUnitCondition():removeCondition(buff);
      else
         self:execAddBuff(self.gameUnit,WIND_BUFF);
      end
   end
   if level < 0 then
      self:execAddBuff(self.gameUnit,WIND_BUFF);
   end

   local buff2 = self.gameUnit:getTeamUnitCondition():findConditionWithID(self.BUFF_LIST[3].ID);
   if level <= 0 then
      if buff2 ~= nil then
         self.gameUnit:getTeamUnitCondition():removeCondition(buff2);
      end
   else
      if buff2 == nil then
         self:execAddBuff(self.gameUnit,self.BUFF_LIST[3])
      end
   end
end



--===================================================================================================================
--燃焼チェック
--===================================================================================================================

function class:burnChecker(unit)
  local burn = unit:getTeamUnitCondition():findConditionWithType(97);
    if burn ~= nil and not self.beforeburn then
        self.beforeburn = true;
        
        
        self:sendBurnActTime(unit);
        self:addBurnTime(self.burnActTime);

        local totalPower = self.windPower - self:liveBurnCheck();


        if totalPower < 0 then
            self:showMessage(self.BURN_MESSAGE_LIST3);
        else
            self:showMessage(self.BURN_MESSAGE_LIST);
        end
        

        local point = self:calcPoint(unit);
        RaidControl:get():addBattlePoint(point,0);
        self:showPointMessage(point);

        return;
    end
    if burn == nil then
        self.beforeburn = false;
    end

end


function class:calcPoint(unit)
    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
    local rate = 100 - hpRate;
    local result = rate * self.BATTLE_POINT_VALUE + self.BATTLE_POINT_VALUE_FIXED;
    return result;
end

function class:showPointMessage(point)
    local pointStr = self.TEXT.POINT_MESSAGE or "+%d万pt"
    summoner.Utility.messageByEnemy(string.format(pointStr,point/10000),10,summoner.Color.yellow);
end


---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
   return 1
end


-- バフ処理実行
function class:execAddBuff(unit,buffBox)
    local buff  = nil;
    if buffBox.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
    end
    if buffBox.SCRIPT ~= nil then
        buff:setScriptID(buffBox.SCRIPT);
    end
    if buffBox.SCRIPTVALUE1 ~= nil then
        buff:setValue1(buffBox.SCRIPTVALUE1);
    end
    if buffBox.SCRIPTVALUE2 ~= nil then
        buff:setValue2(buffBox.SCRIPTVALUE2);
    end

    if buffBox.COUNT ~= nil then
        if buffBox.COUNT < buffBox.COUNT_MAX then
            buff:setNumber(buffBox.COUNT)
            megast.Battle:getInstance():updateConditionView()
            buffBox.COUNT = buffBox.COUNT + 1
            buffBox.VALUE = self.ougiBuffValue * buffBox.COUNT
         else
           buff:setNumber(10)
           megast.Battle:getInstance():updateConditionView()
        end
    end
end

--==================================================================================================================================================
--ルーム同期


function class:takeInitGet(unit)
    -- RaidControl:get():getCustomValue("playerName");
    self:setBurnActTime(RaidControl:get():getCurrentRaidTime());

end

function class:sendBurnActTime(unit)
    --持ってくる前に今燃焼が入った事実をまず自分の中で保持
    self:setBurnActTime(RaidControl:get():getCurrentRaidTime());
    --現状部屋の最新のものについて取得　ここで一旦古いものになる。
    self:fetchBurnActTime(unit);
    if self.burnActTime <= RaidControl:get():getCurrentRaidTime() then
        self:setBurnActTime(RaidControl:get():getCurrentRaidTime());
        RaidControl:get():setCustomValue("burnActTime",""..self.burnActTime);
        local playerName = BattleControl:get():getPlayerName();
        local byteCode = self:toByteCode(playerName);
        RaidControl:get():setCustomValue("playerName",byteCode);
    end
end

function class:setBurnActTime(time)
    self.burnActTime = math.floor(time);
end

function class:fetchBurnActTime(unit)

    local tempActTime = tonumber(RaidControl:get():getCustomValue("burnActTime"));
    
    if tempActTime ~= "" and tempActTime ~= "error" and tempActTime ~= nil then
        -- summoner.Utility.messageByEnemy(""..tempActTime,5,summoner.Color.red);
    else
        -- summoner.Utility.messageByEnemy("ない"..self.burnActTime,5,summoner.Color.red);  
        return;
    end

    
    tempActTime = math.floor(tempActTime);


    if tempActTime > self.burnActTime then
        self:setBurnActTime(tempActTime);
        local playerNameByteCode = RaidControl:get():getCustomValue("playerName");
        local playerName = self:toUnicode(playerNameByteCode);

        -- summoner.Utility.messageByEnemy("他人燃焼"..self.burnActTime,15,summoner.Color.red);
        local burnMessageWithPlayerName = {
            [1] = {
               MESSAGE = playerName..self.BURN_MESSAGE_LIST2[1].MESSAGE,
               COLOR = Color.red,
               DURATION = 10,
               isPlayer = false
            }
        }


        local totalPower = self.windPower - self:liveBurnCheck();

        if totalPower < 0 then
            burnMessageWithPlayerName[1].MESSAGE = playerName..self.BURN_MESSAGE_LIST4[1].MESSAGE;
        end

        self:showMessage(burnMessageWithPlayerName);
        -- self:addBurnTime(self.burnActTime);
        
    end
end



function class:addBurnTime(time)
   self.burnTimeIndex = self.burnTimeIndex + 1;
   self.burnTimes[self.burnTimeIndex] = time;
   self:sendBurnTable(self.burnTimes);
   -- summoner.Utility.messageByEnemy(self.burnActTime);
   -- summoner.Utility.messageByEnemy(RaidControl:get():getCurrentRaidTime());
   -- summoner.Utility.messageByEnemy(time);
end

function class:sendBurnTable(table)
   local jsonStr = Json.stringify(table,false);
   local key = "burnTable"..self.index;
   RaidControl:get():setCustomValue(key,jsonStr);
end

function class:getBurnTables(deltaTime)

   self.tableFetchTimer = self.tableFetchTimer + deltaTime;

   if self.tableFetchTimer < 1 then
      return;
   end

   self.tableFetchTimer = self.tableFetchTimer - 1;

   local tableCnt = self:fetchIndex();
   self.remortBurnTables = {}
   for i=1,tableCnt do
      local tempTable = self:fetchBurnTable(i);
      if tempTable ~= nil then
         table.insert(self.remortBurnTables,tempTable);
      end
   end



end

function class:fetchBurnTable(index)
   local tempStr = RaidControl:get():getCustomValue("burnTable"..index);
   local burnTable = nil;
   if tempStr ~= "" and tempStr ~= "error" and tempStr ~= nil then
      burnTable = Json.parse(tempStr);
   end
   return burnTable;
end

function class:setStartTime()
   local tempTime = self:fetchStartTime();
   if tempTime == nil then
      self.startTime = RaidControl:get():getCurrentRaidTime();
      self:sendStartTime();
   else
      self.startTime = tempTime;
   end
end

function class:fetchStartTime()
   local tempStr = RaidControl:get():getCustomValue("raidStartTime");
   local remortStartTime = nil;
   if tempStr ~= "" and tempStr ~= "error" and tempStr ~= nil then
      remortStartTime = tonumber(tempStr);
   end
   return remortStartTime;
end

function class:sendStartTime()
   RaidControl:get():setCustomValue("raidStartTime",""..self.startTime);
end

function class:setIndex()
   local tempIndex = self:fetchIndex();
   if tempIndex == nil then
      self.index = 1;
   else
      self.index = tempIndex + 1;
   end

   self:sendIndex();

end

function class:fetchIndex()
   local tempStr = RaidControl:get():getCustomValue("index");
   local remortIndex = nil;
   if tempStr ~= "" and tempStr ~= "error" and tempStr ~= nil then
      remortIndex = tonumber(tempStr);
   end
   return remortIndex;
end

function class:sendIndex()
   RaidControl:get():setCustomValue("index",""..self.index);
end



function class:toByteCode(str)
    local i = 1;
    local result = "";
    for i=1, string.len(str) do
     result = result.." "..str:byte(i);
    end
    return result;
end

function class:toUnicode(str)
    local result = "";
    for i in str:gmatch("%d+") do

        local code = tonumber(i);
        local tmp = str.char(code);
        result = result..tmp;
    end
    return result;
end

function class:liveBurnCheck()
   local count = 0;
   for k,v in pairs(self.remortBurnTables) do
      count = count + self:innerLiveBurnCheck(v);
   end

   return count;
end

function class:innerLiveBurnCheck(targetTable)
   local count = 0;
   for k,v in pairs(targetTable) do
      if RaidControl:get():getCurrentRaidTime() - self.BURN_TIME_RANGE <= v then
         count = count + 1;
      end
   end

   return count * 2;--燃焼による風速ダウン効果量倍にする方向にしました
end


function class:setBar()
   self.bar =  self.gameUnit:addOrbitSystemWithFile("windSpeedBar","100");
   self.bar:takeAnimation(0,"25",true);
   self.bar:setPosition(0,0);
   self.bar:setZOrder(9999);
   self.bar:takeAnimation(1,"windMiddleEnemy",true);
   self.bar:takeAnimation(2,"cursolIdle",true);
end

function class:changeSpeed(speed)
   if speed < -20 then
      speed = -20;
   end
   if speed > 20 then
      speed = 20;
   end
   if speed < -8 then
      self.bar:takeAnimation(1,"windMaxPlayer",true);
   elseif speed < -3 then
      self.bar:takeAnimation(1,"windMiddlePlayer",true);
   elseif speed < 0 then
      self.bar:takeAnimation(1,"windSmallPlayer",true);
   elseif speed == 0 then
      self.bar:takeAnimation(1,"windVanishEnemy",false);
   elseif speed < 3 then
      self.bar:takeAnimation(1,"windSmallEnemy",true);
   elseif speed < 8 then
      self.bar:takeAnimation(1,"windMiddleEnemy",true);
   else
      self.bar:takeAnimation(1,"windMaxEnemy",true);
   end
   self.bar:takeAnimation(0,""..speed * 5,true);
   self.bar:takeAnimation(3,"speedChange",false);


end

function class:excuteAction(event)
  self:checkTarget()
  return 1
end

-- 被ターゲット判定
function class:checkTarget()
  if not self.isTarget and self:getIsTarget() then
    self:execAddBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST[1])
    self:showMessage(self.RAID_MESSAGES)
  end
  if self:getIsTarget() then
    BattleControl:get():showHateAll()
  else
    BattleControl:get():hideHateAll(); 
    self:removeCondition(self.gameUnit,self.TARGET_BUFF_BOX_LIST[1].ID)    
  end
  self.isTarget = self:getIsTarget();
end

function class:getIsTarget()
  return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > 1000000;
end


-- バフ削除
function class:removeCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
      unit:resumeUnit()
    end  
end


class:publish();

return class;
