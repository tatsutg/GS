local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="犬", version=1.3, id="mine_6008"});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
   ATTACK1 = 50,
   ATTACK2 = 50,
   ATTACK3 = 50,
   ATTACK4 = 50,
   -- ATTACK7 = 50,
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
   SKILL2 = 100
}

class.ACTIVE_SKILLS = {
   ATTACK1 = 1,
   ATTACK2 = 2,
   ATTACK3 = 3,
   ATTACK4 = 4,
   ATTACK5 = 5,
   ATTACK6 = 6,
   ATTACK7 = 7,
   SKILL1 = 8,
   SKILL2 = 9,
   SKILL3 = 10
}

--タイムアップ
class.TIMEUP_BUFF_BOX_LIST = {
   [1] = {
      ID = 5000033,
      BUFF_ID = 17,      --ダメージ
      VALUE = 500,       --効果量
      DURATION = 9999999,
      ICON = 26
   },
   [2] = {
      ID = 5000036,
      BUFF_ID = 13,      --攻撃力
      VALUE = 500,       --効果量
      DURATION = 9999999,
      ICON = 3
   }
}

class.ELEMENTS = {
   [0] =                   {color = Color.white,  info = class.TEXT.ELEMENT1 or "一定時間無属性ダメージ無効"},
   [kElementType_Fire] =   {color = Color.red,    info = class.TEXT.ELEMENT2 or "一定時間炎属性ダメージ無効"},
   [kElementType_Aqua] =   {color = Color.cyan,   info = class.TEXT.ELEMENT3 or "一定時間水属性ダメージ無効"},
   [kElementType_Earth] =  {color = Color.green,  info = class.TEXT.ELEMENT4 or "一定時間樹属性ダメージ無効"},
   [kElementType_Light] =  {color = Color.yellow, info = class.TEXT.ELEMENT5 or "一定時間光属性ダメージ無効"},
   [kElementType_Dark] =   {color = Color.magenta,info = class.TEXT.ELEMENT6 or "一定時間闇属性ダメージ無効"}
}

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [1] = {
         ID = 20157501,
         BUFF_ID = 15, -- 防御力
         VALUE = 100,
         DURATION = 999999,
         ICON = 5
      }
   }

   self.DOWN_BUFF_BOX_LIST = {
      [1] = {
         ID = 5014110,
         BUFF_ID = 15, --防御力
         VALUE = -50,
         DURATION = 999999,
         ICON = 6
      },
      [2] = {
         ID = 5014111,
         BUFF_ID = 13, --攻撃力
         VALUE = -50,
         DURATION = 999999,
         ICON = 4
      },
      [4] = {
         ID = 5014121,
         BUFF_ID = 31, --回避率
         VALUE = -100,
         DURATION = 999999,
         ICON = 0
      }
   }

   self.TIMEUP_BUFF_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE1 or "攻撃力アップ",
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false
      },
      [2] = {
         MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE2 or "ダメージアップ",
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false
      }
   }
end

function class:setDownBuffBoxList()
   self.DOWN_BUFFS = {
      [0] = {
         ID = 50141211,
         BUFF_ID = 98, --ダメージ無効
         VALUE = 999999999,
         DURATION = 20,
         ICON = 203,
         SCRIPT = {
            SCRIPT_ID = 215,
            VALUE1 = 0,
            VALUE2 = 0
         }
      },
      [kElementType_Fire] = {
         ID = 50141212,
         BUFF_ID = 98, --ダメージ無効
         VALUE = 999999999,
         DURATION = 20,
         ICON = 38,
         SCRIPT = {
            SCRIPT_ID = 215,
            VALUE1 = kElementType_Fire,
            VALUE2 = 0
         }
      },
      [kElementType_Aqua] = {
         ID = 50141213,
         BUFF_ID = 98, --ダメージ無効
         VALUE = 999999999,
         DURATION = 20,
         ICON = 39,
         SCRIPT = {
            SCRIPT_ID = 215,
            VALUE1 = kElementType_Aqua,
            VALUE2 = 0
         }
      },
      [kElementType_Earth] = {
         ID = 50141214,
         BUFF_ID = 98, --ダメージ無効
         VALUE = 999999999,
         DURATION = 20,
         ICON = 40,
         SCRIPT = {
            SCRIPT_ID = 215,
            VALUE1 = kElementType_Earth,
            VALUE2 = 0
         }
      },
      [kElementType_Light] = {
         ID = 50141215,
         BUFF_ID = 98, --ダメージ無効
         VALUE = 999999999,
         DURATION = 20,
         ICON = 41,
         SCRIPT = {
            SCRIPT_ID = 215,
            VALUE1 = kElementType_Light,
            VALUE2 = 0
         }
      },
      [kElementType_Dark] = {
         ID = 50141216,
         BUFF_ID = 98, --ダメージ無効
         VALUE = 999999999,
         DURATION = 20,
         ICON = 42,
         SCRIPT = {
            SCRIPT_ID = 215,
            VALUE1 = kElementType_Dark,
            VALUE2 = 0
         }
      }
   }
end

--------[[メッセージ]]--------
-- MESSAGE以外だいたい同じなので自動で設定する
function class:setMessageInfo(messageBox)
   local message = {
      MESSAGE = messageBox.MESSAGE or "メッセージ",
      COLOR = messageBox.COLOR or Color.yellow,
      DURATION = messageBox.DURATION or 5,
      isPlayer = messageBox.isPlayer or false
   }
   return message
end

function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = self:setMessageInfo({
         MESSAGE = self.TEXT.START_MESSAGE1 or "始まるよ"
      })
   }
end

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TID_TIME_UP = 2
   self.TRIGGERS = {
      [self.TID_TIME_UP] = {
         tag = "TIME_UP",
         action = function (status) self:timeUp(status) end,
         used = false
      }
   }

   self.HP_TRIGGERS = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.HP_TRIGGERS[index] = trigger
      end
   end
end

function class:timeUp(status)
   if status == "use3" then
      self:addBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST)
      self:showMessage(self.TIMEUP_BUFF_MESSAGE_LIST)
   end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
class.MAX_DOWN_DURATION = 5;

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
   self:setDownBuffBoxList()

   self.isOver = false
   self.isDown = false
   self.downTimer = 0

   --ヒットストップ耐性　鉱山用ギミック
   local floor = megast.Battle:getInstance():getCurrentMineFloor();
   self.hitStopReduceRate = 1


   --テロップ用変数
   self.telopSpan = 60
   self.showMessageTimer = 0

   local upper = (floor - 30) / 10
   self.OVER_DAMAGE = 300000 + (50000 * math.floor(upper))
   
   local startMessage1 = self.TEXT.START_MESSAGE1 or "1HITでのダメージが"
   local startMessage2 = self.TEXT.START_MESSAGE2 or "万以上で弱体化"
   self.startMessage = startMessage1 .. (self.OVER_DAMAGE/10000) .. startMessage2
   self:execShowMessage({MESSAGE = self.startMessage,COLOR = Color.yellow,DURATION = 5})

   return 1
end


---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:HPTriggersCheck(event.unit)
   if self.isDown then
      self:countDownDownDuration(event.unit,event.deltaTime);
   end
   self:checkDownCond()
   self:checkDown(event.unit);
   --self:telopCheck(event.deltaTime)
   self:setReduceHitStop(event.unit);
   self:setTimeUp()
   return 1
end

function class:setReduceHitStop(unit)
   unit:setReduceHitStop(2, self.hitStopReduceRate);
end


-- 一定時間ごとにテロップを流す
function class:telopCheck(deltaTime)
   if self.showMessageTimer > self.telopSpan then
      self.showMessageTimer = 0
      self:execShowMessage({MESSAGE = self.startMessage,COLOR = Color.yellow,DURATION = 5})
   else
      self.showMessageTimer = self.showMessageTimer + deltaTime
   end
end
-- 180秒経ったらタイムアップ
function class:setTimeUp()
   if BattleControl:get():getTime() > 180 and not self.TRIGGERS[self.TID_TIME_UP].used then
      self:execTrigger(self.TID_TIME_UP)
   end
end

function class:checkDownCond()
   if self.isOver then
      self.isOver = false
      self:addDownTime();
      --self:showMessage(self.STUN_MESSAGE_LIST);
      return;
   end
end

function class:addDownTime()
   self.downTimer = self.downTimer + 5 < self.MAX_DOWN_DURATION and self.downTimer + 5 or self.MAX_DOWN_DURATION;
end

function class:checkDown(unit)
   if self.downTimer ~= nil and self.downTimer > 0 and not self.isDown then
      self:takeDown(unit);
   end
end

function class:countDownDownDuration(unit,deltaTime)
   if self.downTimer >= 0 then
      self.downTimer = self.downTimer - deltaTime;
   end

   if self.downTimer <= 0 then
      self:downEnd(unit);
   end
end

function class:takeDown(unit)
   self.isDown = true;
   unit:setSetupAnimationName("sp_idle");
   unit:setAnimation(0,"sp_in",false);
   unit:takeAnimationEffect(0,"sp_in",false);
   self:addBuff(unit,self.DOWN_BUFF_BOX_LIST);
end

function class:downEnd(unit)
   self.isDown = false;
   self.downTimer = 0;
   unit:setSetupAnimationName("");
   unit:takeAnimation(0,"sp_return2",false);
   self:removeBuffs(unit,self.DOWN_BUFF_BOX_LIST);
end


---------------------------------------------------------------------------------
-- takeIdle
---------------------------------------------------------------------------------
function class:takeIdle(event)
   if self.isDown then
      event.unit:setNextAnimationName("sp_idle");
   end
   return 1;
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
   if self.isDown then
      event.unit:setNextAnimationName("sp_damage");
   end
   return 1;
end

---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   if event.value > self.OVER_DAMAGE and not self.isDown then
      local elementType = event.enemy:getTeamUnitCondition():getDamageAffectInfo().skillElementType
      if event.unit:getTeamUnitCondition():findConditionWithID(self.DOWN_BUFFS[elementType].ID) == nil then
         self.isOver = true
         self:showDamageValue(elementType,event.value)
         self:execAddBuff(event.unit,self.DOWN_BUFFS[elementType])
      end
   end
   return event.value;
end

function class:showDamageValue(elementType,damage)
   local senValue = math.floor(damage) % 10000
   local manValue = (math.floor(damage) - senValue) / 10000
   local saki = self.TEXT.DAMAGE_3 or "一撃"
   local man = self.TEXT.DAMAGE_1 or "万"
   local down = self.TEXT.DAMAGE_2 or "ダメージを受けて弱体化！"
   local message = saki .. manValue .. man .. down
   self:execShowMessage(self:setMessageInfo({MESSAGE = message,COLOR = self.ELEMENTS[elementType].color}))
   self:execShowMessage(self:setMessageInfo({MESSAGE = self.ELEMENTS[elementType].info,COLOR = self.ELEMENTS[elementType].color}))
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
   self:addSP(event.unit);
   return 1
end

function class:attackReroll(unit)
   local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
   local attackIndex = string.gsub(attackStr,"ATTACK","");

   if self.isDown then
      attackIndex = 7;
   end

   unit:takeAttack(tonumber(attackIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
   return 0;
end

function class:addSP(unit)
   if not self.isDown then
      unit:addSP(self.spValue);
   end
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

   if event.index == 3 and not self.skillCheckFlg2 then
      self.skillCheckFlg2 = true;
      event.unit:takeSkillWithCutin(3,1);
      return 0;
   end

   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   self:skillActiveSkillSetter(event.unit,event.index);
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   if self.isRage then
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

function class:removeBuffs(unit,buffs)
   for k,v in pairs(buffs) do
      self:removeBuff(unit,v.ID);
   end
end

function class:removeBuff(unit,id)
   local buff = unit:getTeamUnitCondition():findConditionWithID(id);
   if buff == nil then
      return;
   end

   unit:getTeamUnitCondition():removeCondition(buff);
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

class:publish();

return class;