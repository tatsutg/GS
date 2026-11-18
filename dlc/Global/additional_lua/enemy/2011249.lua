local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="水メリア", version=1.3, id=2011249});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

--------[[table]]--------
function class:refreshTable()
   self.players = {}
end


--------[[バフ]]--------
function class:setBuffBoxList()
   self.HP50_BUFF_LIST = {
      [0] = {
         ID = 20112491,
         BUFF_ID = 17, -- ダメージ
         VALUE = 30,
         DURATION = 999999,
         ICON = 26
      },
      [1] = {
         ID = 20112492,
         BUFF_ID = 28, -- 行動速度
         VALUE = 20,
         DURATION = 999999,
         ICON = 7
      }
   }
   self.HP30_BUFF_LIST = {
      [0] = {
         ID = 20112493,
         BUFF_ID = 31, -- 回避
         VALUE = 50,
         DURATION = 999999,
         ICON = 16
      }
   }
end

--------[[特殊行動]]--------
function class:setTriggersList()
   self.HP_FLG = "HP_FLG"
   self.HP_50 = 0
   self.HP_30 = 1

   self.TRIGGERS = {
      [self.HP_50] = {
         tag = self.HP_FLG,
         action = function (status) self:hpFlg50(status) end,
         timing = 50,
         used = false
      },
      [self.HP_30] = {
         tag = self.HP_FLG,
         action = function(status) self:hpFlg30(status) end,
         timing = 30,
         used = false 
      }
   }
end

-- status = use + receive番号
function class:hpFlg50(status)
   if status == "use3" then
      self:showMessage(self.HP50_MESSAGE_LIST)
      self:addBuff(self.gameUnit,self.HP50_BUFF_LIST)
   end
end

function class:hpFlg30(status)
   if status == "use3" then
      self.isRage = true
      self.hitStop = 0.7
      self.gameUnit:addSP(100)
      self:showMessage(self.HP30_MESSAGE_LIST)
      self:addBuff(self.gameUnit,self.HP30_BUFF_LIST)
   end
end

function class:execGrayScale(unit)
   if self.isStop and unit:getParentTeamUnit() == nil then
      unit:takeGrayScale(0.01)
      table.insert(self.players,unit:getIndex())
   end
end

function class:removeGrayScale(unit)
   if not self.isStop then
      return 
   end

   for i = 1,table.maxn(self.players) do
      local u = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(self.players[i],true);
      if u ~= nil then
         u:takeGrayScale(0.99)
      end
   end
   self.isStop = false
   self:refreshTable()
end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "私に付いてこれるかしら？",
         COLOR = Color.magenta,
         DURATION = 5         
      },
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "回避率アップ",
         COLOR = Color.yellow,
         DURATION = 5         
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE3 or "ブレイク時回避率ダウン",
         COLOR = Color.yellow,
         DURATION = 5         
      }
   }

   self.HP50_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.RAGE_MESSAGE1 or "感覚が研ぎ澄まされていく",
         COLOR = Color.magenta,
         DURATION = 5
      },
      [1] = {
         MESSAGE = self.TEXT.RAGE_MESSAGE2 or "ダメージ・行動速度アップ",
         COLOR = Color.yellow,
         DURATION = 5
      }
   }

   self.HP30_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.RAGE_MESSAGE3 or "私からは逃げられない！",
         COLOR = Color.magenta,
         DURATION = 5
      },
      [1] = {
         MESSAGE = self.TEXT.RAGE_MESSAGE4 or "回避率・行動速度アップ",
         COLOR = Color.magenta,
         DURATION = 5
      }
   }
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.fromHost = false;
   self.gameUnit = nil;
   self.spValue = 20;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);
   self.gameUnit = event.unit;
   self:setMessageBoxList()
   self:setTriggersList()
   self:setBuffBoxList()
   self:showMessage(self.START_MESSAGE_LIST)

   self.hitStop = 0.3
   self.isStop = false
   self:refreshTable()
   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(2,self.hitStop)
   self:HPTriggersCheck(event.unit)
   return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "theWorld" then self.isStop = true end
   if event.spineEvent == "worldEnd" then self:removeGrayScale(event.unit) end
   return 1
end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
   self:removeGrayScale(event.unit)
   return 1
end

---------------------------------------------------------------------------------
-- dead
---------------------------------------------------------------------------------
function class:dead(event)
   self:removeGrayScale(event.unit)
   return 1
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)
   self:execGrayScale(event.enemy)
   return event.value
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

   if tonumber(attackIndex) == 1 then

   else
      self.skillCheckFlg = true;
      unit:takeSkill(1);
      megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
      return 0;
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
      self.isRage = false
   end

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
   return 1
end

--===================================================================================================================
--トリガー
function class:HPTriggersCheck(unit)
   if not self:getIsHost() then
      return;
   end

   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
   local priorityIndex = nil

   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == self.HP_FLG then
         if trigger.timing >= hpRate and not trigger.used then
            if priorityIndex == nil then 
               priorityIndex = index 
            end
            priorityIndex = self.TRIGGERS[priorityIndex].timing > trigger.timing and index or priorityIndex
         end
      end
   end
   self:execTrigger(priorityIndex)
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
   if not self:getIsHost() then
      return
   end
   if index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end
   if receiveNumber == nil then
      receiveNumber = 3
   end

   local action = "use" .. receiveNumber

   self.TRIGGERS[index].action(action)
   self.TRIGGERS[index].used = true
   megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

--===================================================================================================================
-- バフ関係
--===================================================================================================================
-- バフ指定実行。indexがない時はバフボックスの中身を全部実行
function class:addBuff(unit,buffBoxList,index)
    if index == nil then 
        self:addBuffRange(unit,buffBoxList,0,table.maxn(buffBoxList))
        return
    end
    self:execAddBuff(unit,buffBoxList[index])
end

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit,buffBoxList,start,finish)
    for i = start,finish do
        self:execAddBuff(unit,buffBoxList[i])
    end
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
end

--===================================================================================================================
-- メッセージ関係
--===================================================================================================================
function class:showMessage(messageBoxList,index)
   if index == nil then 
      self:showMessageRange(messageBoxList,0,table.maxn(messageBoxList))
   return
   end
   self:execShowMessage(messageBoxList[index])
end

function class:showMessageRange(messageBoxList,start,finish)
   for i = start,finish do
      self:execShowMessage(messageBoxList[i])
   end
end

function class:execShowMessage(messageBox)
   summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
end



class:publish();

return class;