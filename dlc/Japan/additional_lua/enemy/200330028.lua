--@additionalEnemy,200330029,200330030,200330031,200330032,200330033,200330034,200330035
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="カボシェルム", version=1.3, id=200330028});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_SET_LIST = {
   DEFAULT = {
      { ATTACK1 = 50 },
      { ATTACK2 = 50 },
      { ATTACK4 = 50,ATTACK5 = 50 }
   }
}

--使用する奥義とその確率
class.SKILL_SET_LIST  = {
   DEFAULT = {
      { SKILL1 = 100 }
   }
}

class.ACTIVE_SKILLS = {
   ATTACK1 = 1,
   ATTACK2 = 2,
   ATTACK3 = 3,
   ATTACK4 = 4,
   ATTACK5 = 5,
   ATTACK6 = 7,
   SKILL1 = 6,
   SKILL2 = 7
}

class.SUMMON_WAITS = {
   [200330029] = 100,
   [200330030] = 100,
   [200330031] = 100,
   [200330032] = 100,
   [200330033] = 100,
   [200330034] = 100,
   [200330035] = 100
}


class.skill2FixedDamage = 200;
class.SUMMON_RATE_ADDITION = 10;
class.SUMMON_RATE_REDUCE = 40;


--------[[メッセージ]]--------
function class:setMessageBoxList()
    self.START_MESSAGE_LIST = {
       [1] = {
          MESSAGE = self.TEXT.START_MESSAGE1 or "庇うキラー",
          COLOR = Color.yellow,
          DURATION = 10,
          isPlayer = false
       },
       [2] = {
          MESSAGE = self.TEXT.START_MESSAGE2 or "魔族からのダメージ軽減",
          COLOR = Color.yellow,
          DURATION = 10,
          isPlayer = false
       }
    }

    self.RUSH_MESSAGE_LIST = {
       [1] = {
          MESSAGE = self.TEXT.RUSH_MESSAGE or "絶望の宴が始まる――",
          COLOR = Color.magenta,
          DURATION = 10,
          isPlayer = false
       }
    }
end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TRIGGERS = {
      --[1] = {
      --   tag = "HP_FLG",
      --   action = function (status) self:hp50(status) end,
      --   HP = 50,
      --   used = false
      --},
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp25(status) end,
         HP = 25,
         used = false
      }
   }

   self.HP_TRIGGERS = {}
   self.hpMarkers = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.HP_TRIGGERS[index] = trigger
         self.hpMarkers[self.TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.TRIGGERS[index].HP * 0.01)
      end
   end
end

function class:hp50(status)
   if status == "use3" then
      self.isRage = true
      --self.gameUnit:addSP(100)
   end
end

function class:hp25(status)
   if status == "use3" then
      self.isRage = true
      --self.gameUnit:addSP(100)
   end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.isReady = false
   self.fromHost = false;
   self.gameUnit = event.unit;
   self.spValue = 20;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.beforeDefeatTime = 0;
   self.forceAttackIndex = 0;
   self.comboTimer = 0;
   self.totalSummonCnt = 0;
   self.isInitCheck = false;
   self.roomHP = 100;
   self.summonedIndex = {};
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);
   self.isHpZero = false;
   self.forceClearTimer = 0;
   self.isClear = false;
   self.summonRate = 70;

   self.hitStop = 1
   self:setMessageBoxList()
   self:setTriggerList()

   self:setUpKabochaCounts(event.unit);
    self:showMessage(self.START_MESSAGE_LIST)

   self.isRage = true
   self.isOgi = false
   self:initAttackWeight({DEFAULT = 100})
   self:initSkillWeight({DEFAULT = 100})
   return 1
end

function class:startWave(event)
   if megast.Battle:getInstance():isHost() then
      self.isReady = true
      event.unit:takeAttack(1)
   end
   return 1
end

function class:setUpKabochaCounts(unit)
   unit:setParameter("200330029","0");
   unit:setParameter("200330030","0");
   unit:setParameter("200330031","0");
   unit:setParameter("200330032","0");
   unit:setParameter("200330033","0");
   unit:setParameter("200330034","0");
   unit:setParameter("200330035","0");
end

-- ---------------------------------------------------------------------------------
-- -- run
-- ---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "addSP" then
      self:addSP(event.unit);
   end
   if event.spineEvent == "summon1" then self:summon1(event.unit) end
   if event.spineEvent == "summon2" then self:summon2(event.unit) end
   if event.spineEvent == "summon3" then self:summon3(event.unit) end
   if event.spineEvent == "addBat" then self:addBat(event.unit) end
   return 1;
end

function class:summon1(unit)
   local orbit = unit:addOrbitSystemWithFile("../../effect/itemskill/itemskill2009","attack1");
   orbit:setPositionX(LuaUtilities.rand(250)- 400);
   orbit:setPositionY(LuaUtilities.rand(100));
   orbit.autoZorder = true;
   orbit:getSkeleton():setScaleX(-1);
   orbit:setDamageRateOffset(1/21);
   orbit:setBreakRate(1/21);
   return 1;
end

function class:summon2(unit)
   local orbit = unit:addOrbitSystemWithFile("../../effect/itemskill/itemskill6004","attack1");
   orbit:setPositionX(LuaUtilities.rand(250)- 200);
   orbit:setPositionY(LuaUtilities.rand(100));
   orbit.autoZorder = true;
   orbit:getSkeleton():setScaleX(-1);
   orbit:setDamageRateOffset(1/21);
   orbit:setBreakRate(1/21);
   return 1;
end

function class:summon3(unit)
   local orbit = unit:addOrbitSystemWithFile("../../effect/itemskill/itemskill6003","attack1");
   orbit:setPositionX(LuaUtilities.rand(250) - 200);
   orbit:setPositionY(LuaUtilities.rand(100));
   orbit.autoZorder = true;
   orbit:getSkeleton():setScaleX(-1);
   orbit:setDamageRateOffset(1/21);
   orbit:setBreakRate(1/21);
   return 1;
end

function class:addBat(unit)
   local orbit = unit:addOrbitSystem("bat"..(LuaUtilities.rand(3)+1));
   orbit:setPositionX(LuaUtilities.rand(250) - 200);
   orbit:setPositionY(LuaUtilities.rand(100));
   return 1;
end


-- ---------------------------------------------------------------------------------
-- -- executeAction
-- ---------------------------------------------------------------------------------
function class:excuteAction(event)
   self.absorbFlg = false;
   self.isOgi = false
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(100,1)
   if not self.isReady then return 1 end

   self:clearCheck(event.unit,event.deltaTime);
   self:deadCheck(event.unit,event.deltaTime);
   self:HPTriggersCheck(event.unit);
   return 1
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   --if event.unit:getBurstState() == kBurstState_active then
   --   return 1
   --end
   if self.isOgi then
      return 1
   end
   return event.value
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
   if self.fromHost then self.isReady = true end
   if not self.isReady and megast.Battle:getInstance():isHost() then return 0 end

   self.isOgi = false
   if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
      self.attackCheckFlg = true;
      return self:attackReroll(event.unit);
   end
   self.attackCheckFlg = false;
   if not megast.Battle:getInstance():isHost() and not self.fromHost then
      event.unit:takeIdle();
      return 0;
   end
   self.fromHost = false;
   self:attackActiveSkillSetter(event.unit,event.index);
   self:summon(event.unit,1);
   if event.index == 6 then
      self.isOgi = true
      self:showMessage(self.RUSH_MESSAGE_LIST)
   end
   return 1
end

function class:attackReroll(unit)
   local attackStr = summoner.Random.sampleWeighted(self.ATTACK_SET_LIST[self.STATE_ATTACK.setChar][self.STATE_ATTACK.actCount]);
   local attackIndex = string.gsub(attackStr,"ATTACK","");

   if self.isRage then
      self.isRage = false
      attackIndex = 6
   else
      self:weightController(self.ATTACK_SET_LIST,self.STATE_ATTACK)
   end

   unit:takeAttack(tonumber(attackIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
   return 0;
end

function class:addSP(unit)
   unit:addSP(self.spValue);
   return 1;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
   if self.fromHost then self.isReady = true end
   if not self.isReady and megast.Battle:getInstance():isHost() then return 0 end

   self.isOgi = false
   if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
      self.skillCheckFlg = true;
      return self:skillReroll(event.unit);
   end

   if not megast.Battle:getInstance():isHost() and not self.fromHost then
      event.unit:takeIdle();
      return 0;
   end

   if event.index == 2 then
      self.absorbFlg = true;
   end
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   self:skillActiveSkillSetter(event.unit,event.index);
   self.isOgi = true
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_SET_LIST[self.STATE_SKILL.setChar][self.STATE_SKILL.actCount]);
   local skillIndex = string.gsub(skillStr,"SKILL","");
   self:weightController(self.SKILL_SET_LIST,self.STATE_SKILL)

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end


function class:attackDamageValue(event)
   if self.absorbFlg then
      local baseDamage = self.isTarget and self.skill2FixedDamage * 1.75 or self.skill2FixedDamage;
      local damage = event.enemy:getHP() - baseDamage > 1 and baseDamage or event.enemy:getHP() -1;
      -- event.unit:takeHeal(damage);
      return damage;
   end
   return event.value;
end

function class:takeDamage(event)
   self.absorbFlg = false;
   return 1;
end

--===================================================================================================================
-- バフ関係
--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit,buffBoxList,index)
   if index == nil then
      self:addBuffAll(unit,buffBoxList)
      return
   end
   self:execAddBuff(unit,buffBoxList[index])
end

function class:removeBuffs(unit,buffs)
   for k,v in pairs(buffs) do
      self:removeBuff(unit,v.ID);
   end
end

function class:addBuffTimes(unit,buffs)
   for k,v in pairs(buffs) do
      local buff = unit:getTeamUnitCondition():findConditionWithID(v.ID);
      if buff ~= nil then
         buff:setTime(self.downTimer);
      end
   end
end

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit,buffBoxList,start,finish)
   for i = start,finish do
      self:execAddBuff(unit,buffBoxList[i])
   end
end

function class:addBuffAll(unit,buffBoxList)
   for i,buffBox in ipairs(buffBoxList) do
      self:execAddBuff(unit,buffBox)
   end
end

-- バフ処理実行
function class:execAddBuff(unit,buffBox)
   local buff  = nil;
   if buffBox.EFFECT ~= nil then
      buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.EFID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
   else
      buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.EFID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
   end
   if buffBox.SCRIPT ~= nil then
      buff:setScriptID(buffBox.SCRIPT);
   end
   if buffBox.SCRIPTVALUE1 ~= nil then
      buff:setValue1(buffBox.SCRIPTVALUE1);
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

function class:removeBuff(unit,id)
   local buff = unit:getTeamUnitCondition():findConditionWithID(id);
   if buff == nil then
      return;
   end

   unit:getTeamUnitCondition():removeCondition(buff);
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
   -- for i,messageBox in ipairs(messageBoxList) do
   --    self:execShowMessage(messageBox)
   -- end
   --今回はどうしても配列が歯抜けになる使用上変なforになる
   for i=0,10 do
      if messageBoxList[i] ~= nil then
         self:execShowMessage(messageBoxList[i]);
      end
   end
end

function class:showMessageRange(messageBoxList,start,finish)
   for i = start,finish do
      self:execShowMessage(messageBoxList[i])
   end
end

function class:execShowMessage(messageBox)
   if messageBox.isPlayer then
      summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   else
      summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   end
end

--===================================================================================================================
--トリガー
--===================================================================================================================
--HPトリガー


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

   self.TRIGGERS[index].used = true
   self.TRIGGERS[index].action(action)
   if self.TRIGGERS[index].tag == "HP_FLG" then
      self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])
   end

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

function class:receive3(args)
   self.TRIGGERS[args.arg].used = true
   self.TRIGGERS[args.arg].action("use3")
   if self.TRIGGERS[args.arg].tag == "HP_FLG" then
      self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[args.arg].HP])
   end
   return 1
end

function class:summon(unit,num)
   if not megast.Battle:getInstance():isHost() then return end

   local rand = Random.range(0,100);
   if rand < self.summonRate then
      self.summonRate = self.summonRate - self.SUMMON_RATE_REDUCE;
      self.summonRate = self.summonRate < 0 and 0 or self.summonRate;
   else
      self.summonRate = self.summonRate + self.SUMMON_RATE_ADDITION;
      self.summonRate = self.summonRate > 100 and 100 or self.summonRate;
      return;
   end

   local summonedCount = 0;
   for i = 0,5 do
      local target = unit:getTeam():getTeamUnit(i);
      if target == nil and not self.summonedIndex[i] then
         local summonID = summoner.Random.sampleWeighted(self.SUMMON_WAITS)
         local uni = unit:getTeam():addUnit(i,summonID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
         uni:setParameter("kabocha_index",""..self.totalSummonCnt);
         self.totalSummonCnt = self.totalSummonCnt + 1;
         self.summonedIndex[i] = true;
         summonedCount = summonedCount + 1;
         megast.Battle:getInstance():sendEventToLua(self.scriptID,4,(summonID * 10) + i);
         if summonedCount >= num then
            break;
         end
      end
   end
   self.delaySummonIndexes = {};
end

function class:receive4(args)
   local summonID = math.floor(args.arg /10)
   local i = args.arg % 10
   local uni = self.gameUnit:getTeam():addUnit(i,summonID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
   --uni:setParameter("kabocha_index",""..self.totalSummonCnt);
   self.totalSummonCnt = self.totalSummonCnt + 1;
   --self.summonedIndex[i] = true;
   return 1
end

--===================================================================================================================
--撃破チェック
--===================================================================================================================
function class:deadCheck(unit,deltaTime)
   if megast.Battle:getInstance():getBattleState() ~= kBattleState_active or not megast.Battle:getInstance():isHost() then
      return;
   end

   for i=0,5 do
      local target = unit:getTeam():getTeamUnit(i,true);--死んでても生きてても第二引数がtrueなら取得可能ォ
      if target ~= nil and target:getHP() <= 0 then
         if self.summonedIndex[i] == true then
            self.summonedIndex[i] = false;
         end
      end
   end
   return;
end

function class:clearCheck(unit,deltaTime)
   if self.isClear then
      return;
   end
   if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
      return;
   end
   if unit:getHP() <= 0 then
      self.isHpZero = true;
   end
   if self.isHpZero then
      self.forceClearTimer = self.forceClearTimer + deltaTime;
   end

   return 1;
end


function class:weightController(SET_LIST,stateBox)
   stateBox.actCount = stateBox.actCount + 1
   if #SET_LIST[stateBox.setChar] < stateBox.actCount then
      stateBox.actCount = 1
      stateBox.setCount = stateBox.setCount + 1
      if #stateBox.SET_WEIGHT < stateBox.setCount then
         stateBox.setCount = 1
      end
      stateBox.setChar = summoner.Random.sampleWeighted(stateBox.SET_WEIGHT[stateBox.setCount])
   end
end

class.STATE_ATTACK = {}
function class:initAttackWeight(...)
   --setCountの選択対象。引数を二重カッコにするのが嫌だったのでここでテーブルを作っている。
   local attackList = {...}
   self.STATE_ATTACK = self:initState(#attackList ~= 0 and attackList or self.STATE_ATTACK.SET_WEIGHT)
end

class.STATE_SKILL = {}
function class:initSkillWeight(...)
   local skillList = {...}
   self.STATE_SKILL = self:initState(#skillList ~= 0 and skillList or self.STATE_SKILL.SET_WEIGHT)
end

function class:initState(weightList)
   local state = {}
   state.SET_WEIGHT = weightList
   state.actCount = 1
   state.setCount = 1
   state.setChar = summoner.Random.sampleWeighted(state.SET_WEIGHT[state.setCount])
   return state
end



class:publish();

return class;
