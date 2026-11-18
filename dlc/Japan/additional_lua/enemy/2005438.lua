local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ヴァルザンデス", version=1.3, id=2005438});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
   ATTACK1 = 40,
   ATTACK2 = 30,
   ATTACK3 = 20,
   ATTACK4 = 10
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
   SKILL1 = 100
}

class.SKILL_WEIGHTS_2 = {
   SKILL1 = 75,
   SKILL3 = 25
}

class.ACTIVE_SKILLS = {
   ATTACK1 = 1,
   ATTACK2 = 2,
   ATTACK3 = 3,
   ATTACK4 = 4,
   SKILL1 = 5,
   SKILL2 = 5,
   SKILL3 = 6
}

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 201575011,
         BUFF_ID = 23, -- 被クリティカル
         VALUE = -1000,
         DURATION = 999999,
         ICON = 0
      }
   }

   self.BUFF_BOX_LIST_PARTY = {
      [1] = {
         ID = 20157501,
         BUFF_ID = 0, -- 奥義ゲージ
         VALUE = 0,
         DURATION = 999999,
         ICON = 150
      }
   }
end


--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
   local message = {
      MESSAGE = messageBox.MESSAGE or "メッセージ",
      COLOR = messageBox.COLOR or Color.yellow,
      DURATION = messageBox.DURATION or 8,
      isPlayer = messageBox.isPlayer or false
   }
   return message
end

function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE1 or "被ダメージ時回復量ダウン"
      }),
      [2] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE2 or "HP50%以下:奥義ゲージ減少"
      }),
      [3] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE3 or "クリティカル無効"
      })
   }

   self.HP80_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP80_MESSAGE1 or "刻め…それが恐怖だ",
         COLOR = Color.magenta
      })
   }

   self.HP50_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "見えるか…忍び寄る破滅の影が",
         COLOR = Color.magenta
      })
   }

   self.HP30_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.HP30_MESSAGE1 or "等しき滅びを授けよう",
         COLOR = Color.magenta
      })
   }
end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp80(status) end,
         HP = 80,
         used = false
      },
      [2] = {
         tag = "HP_FLG",
         action = function (status) self:hp50(status) end,
         HP = 50,
         used = false
      },
      [3] = {
         tag = "HP_FLG",
         action = function (status) self:hp30(status) end,
         HP = 30,
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

function class:hp80(status)
   if status == "use3" then
      self.gameUnit:addSP(100)
      self:showMessage(self.HP80_MESSAGE_LIST)
   end
end

function class:hp50(status)
   if status == "use3" then
      self:showMessage(self.HP50_MESSAGE_LIST)
   end
end

function class:hp30(status)
   if status == "use3" then
      self.isFury = true
      --self:sliceHP()
      self.gameUnit:addSP(100)
      self:showMessage(self.HP30_MESSAGE_LIST)
      self.setSlice = true
      self.SKILL_WEIGHTS = self.SKILL_WEIGHTS_2
   end
end

function class:createList()
   for i = 0,3 do
      local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
      if localUnit ~= nil then
         self.sliceList[i + 1] = {
            index = i,
            value = localUnit:getCalcHPMAX() - localUnit:getHP(),
            MAX = localUnit:getCalcHPMAX() * 0.7,
            isSlice = true
         }
      end
   end
end

function class:execSlice()
   for i = 0,3 do
      local localUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i)
      if localUnit ~= nil then
         if localUnit:getHP() > localUnit:getCalcHPMAX() * 0.3 then
            local artsHpBefore = localUnit:getHP()
            localUnit:setHP(localUnit:getCalcHPMAX() * 0.3)
            -- 【MEGA_D-9756】メッセージログで、この技の行に減った HP を足す（表示だけ。古いアプリには無いので確かめてから呼ぶ）
            if megast.Battle.addArtsDamageToCurrentSkill ~= nil and self.gameUnit ~= nil then
               megast.Battle:getInstance():addArtsDamageToCurrentSkill(self.gameUnit, localUnit, artsHpBefore - localUnit:getHP())
            end
         end
      end
   end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
--HP減少にかかる時間(秒)
class.SLICE_SCHEDULE = 1.2

function class:start(event)
   self.fromHost = false;
   self.gameUnit = event.unit;
   self.spValue = 20;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);

   self.isRage = false
   self.isFury = false
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()
   self:showMessage(self.START_MESSAGE_LIST)

   self.hitStop = 1
   self.timer = 0
   self.SP_DOWN_PERIOD = 1
   self.SP_DOWN_VALUE = -5

   self.checked = false
   self.setSlice = false
   self.sliceList = {}
   return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "roar" then
      if self.setSlice then
         self.setSlice = false
         --self:createList()
         self:execSlice()
         self.checked = true
      end
   end

   if event.spineEvent == "addSP" then
      self:addSP(event.unit)
   end
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(2,self.hitStop)
   self:HPTriggersCheck(event.unit)
   self:checkPartyHp(event.deltaTime)
   --self:checkSlice(event.deltaTime)
   return 1
end

function class:checkPartyHp(deltaTime)
   if self.timer < self.SP_DOWN_PERIOD then
      self.timer = self.timer + deltaTime
      return
   end
   self.timer = self.timer - self.SP_DOWN_PERIOD

   for i = 0,3 do
      local teamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
      if teamUnit ~= nil then
         local hpRate = summoner.Utility.getUnitHealthRate(teamUnit) * 100;
         if hpRate <= 50 then
            self:execAddBuff(teamUnit,self.BUFF_BOX_LIST_PARTY[1])
            teamUnit:addSP(self.SP_DOWN_VALUE)
         else
            self:execRemoveCondition(teamUnit,self.BUFF_BOX_LIST_PARTY[1].ID)
         end
      end
   end
end

function class:checkSlice(deltaTime)
   if not megast.Battle:getInstance():getBattleState() == kBattleState_active  or not self.checked then return end

   for _,v in pairs(self.sliceList) do
      self:sliceHP(v,deltaTime)
   end
end

function class:getUnit(index)
   return megast.Battle:getInstance():getTeam(true):getTeamUnit(index)
end

-- HPが1未満にならないように減らす
function class:sliceHP(slice,deltaTime)
   if slice == nil or not slice.isSlice then return end

   local unit = self:getUnit(slice.index)
   if slice.value <= slice.MAX then
      local sliceValue = math.ceil((deltaTime / self.SLICE_SCHEDULE) * slice.MAX)
      slice.value = slice.value + sliceValue
      if unit:getHP() - sliceValue < 1 then
         unit:setHP(1)
      elseif slice.MAX < (slice.value + sliceValue) then
         unit:setHP(unit:getCalcHPMAX() - slice.MAX)
      else
         unit:setHP(unit:getHP() - sliceValue)
      end
      return
   end
   slice.value = 0
   slice.isSlice = false
end

---------------------------------------------------------------------------------
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
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
   return 1
end

function class:attackReroll(unit)
   local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
   local attackIndex = string.gsub(attackStr,"ATTACK","");

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
   if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
      self.skillCheckFlg = true;
      return self:skillReroll(event.unit);
   end

   if not megast.Battle:getInstance():isHost() and not self.fromHost then
      event.unit:takeIdle();
      return 0;
   end

   if event.index == 3 and not self.skillCheckFlg2 and self.isFury then
      self.skillCheckFlg2 = true;
      event.unit:takeSkillWithCutin(3,1);
      return 0;
   end

   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   if self.isFury then
      self.isFury = false
      event.unit:setActiveSkill(7)
   else
      self:skillActiveSkillSetter(event.unit,event.index);
   end
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   if self.isFury then
      skillIndex = 3
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
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
   self.gameUnit:removeHpMarker(self.hpMarkers[self.TRIGGERS[index].HP])

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
   return 1
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
   for i,messageBox in ipairs(messageBoxList) do
      self:execShowMessage(messageBox)
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
-- バフ関係
--===================================================================================================================
function class:addBuff(unit,buffBoxList)
   for i,buffBox in ipairs(buffBoxList) do
      self:execAddBuff(unit,buffBox)
   end
end

function class:execAddBuff(unit,buffBox)
   local buff  = nil;
   if buffBox.EFFECT ~= nil then
      buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
   else
      buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,buffBox.VALUE,buffBox.DURATION,buffBox.ICON);
   end

   if buffBox.SCRIPT ~= nil then
      buff:setScriptID(buffBox.SCRIPT.SCRIPT_ID)
      if buffBox.SCRIPT.VALUE1 ~= nil then buff:setValue1(buffBox.SCRIPT.VALUE1) end
      if buffBox.SCRIPT.VALUE2 ~= nil then buff:setValue2(buffBox.SCRIPT.VALUE2) end
      if buffBox.SCRIPT.VALUE3 ~= nil then buff:setValue3(buffBox.SCRIPT.VALUE3) end
      if buffBox.SCRIPT.VALUE4 ~= nil then buff:setValue4(buffBox.SCRIPT.VALUE4) end
      if buffBox.SCRIPT.VALUE5 ~= nil then buff:setValue5(buffBox.SCRIPT.VALUE5) end
   end
end

function class:execRemoveCondition(unit,buffId)
   if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
   end
end

class:publish();

return class;
