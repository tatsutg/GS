local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ヴォックス", version=1.3, id=2012049});
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
    SKILL3 = 5
}

class.MAGIA_DRIVE = 4
class.SINOUGI = 6

function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
      [0] = {
         ID = 20120491,
         BUFF_ID = 0, -- MDアイコンのみ
         VALUE = 0,
         DURATION = self.AURA_INTERVAL,
         ICON = 186
      },
      [1] = {
         ID = 20120492,
         BUFF_ID = 22, -- クリティカル率
         VALUE = 50,
         DURATION = self.AURA_INTERVAL,
         ICON = 0
      },
      [2] = {
         ID = 20120493,
         BUFF_ID = 17, -- ダメージ
         VALUE = 50,
         DURATION = self.AURA_INTERVAL,
         ICON = 26
      }
   }
end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "神族キラー",
         COLOR = Color.yellow,
         DURATION = 3,
         isPlayer = false        
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "さあ始めようか",
         COLOR = Color:new(0,155,255),
         DURATION = 3,
         isPlayer = false        
      }
   }

   self.TIME50_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.TIME50_MESSAGE1 or "我らが王に誓う!",
         COLOR = Color:new(0,155,255),
         DURATION = 3,
         isPlayer = false
      },
      [2] = {
         MESSAGE = self.TEXT.TIME50_MESSAGE2 or "行動速度・クリティカル率アップ",
         COLOR = Color.yellow,
         DURATION = 3,
         isPlayer = false
      }
   }

   self.TIME80_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.TIME80_MESSAGE1 or "ダメージアップ",
         COLOR = Color.yellow,
         DURATION = 3,
         isPlayer = false
      }
   }

   self.TIME110_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.TIME110_MESSAGE1 or "あと少しだけ耐えてみせろ!",
         COLOR = Color:new(0,155,255),
         DURATION = 3,
         isPlayer = false
      }
   }

   self.TIME120_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.TIME120_MESSAGE1 or "よくやったな",
         COLOR = Color:new(0,155,255),
         DURATION = 3,
         isPlayer = false
      }
   }
   self.TALK_LIST = {}
   self.TALK_LIST[1] = {
      BASE_ID = 250,
      PLYORITY = 1,
      TALKS = {
         [1] = {
            MESSAGE = self.TEXT.TALK3_MESSAGE1 or "仕方ない本気で行くか",
            COLOR = Color:new(0,155,255),
            DURATION = 3,
            isPlayer = false
         },
         [2] = {
            MESSAGE = self.TEXT.TALK3_MESSAGE2 or "お手やわらかに頼むよ",
            COLOR = Color.cyan,
            DURATION = 3,
            isPlayer = true
         },
         [3] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "神族キラー",
            COLOR = Color.yellow,
            DURATION = 3,
            isPlayer = false        
         }
      }
   }
   self.TALK_LIST[2] = {
      BASE_ID = 248,
      PLYORITY = 2,      
      TALKS = {
         [1] = {
            MESSAGE = self.TEXT.TALK1_MESSAGE1 or "本気でいきます!",
            COLOR = Color.red,
            DURATION = 3,
            isPlayer = true
         },
         [2] = {
            MESSAGE = self.TEXT.TALK1_MESSAGE2 or "お前の成長をみせてみろ!",
            COLOR = Color:new(0,155,255),
            DURATION = 3,
            isPlayer = false
         },
         [3] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "神族キラー",
            COLOR = Color.yellow,
            DURATION = 3,
            isPlayer = false        
         }
      }
   }
   self.TALK_LIST[3] = {
      BASE_ID = 249,
      PLYORITY = 3,
      TALKS = {
         [1] = {
            MESSAGE = self.TEXT.TALK2_MESSAGE1 or "ちょい手抜いてくんない？",
            COLOR = Color.green,
            DURATION = 3,
            isPlayer = true
         },
         [2] = {
            MESSAGE = self.TEXT.TALK2_MESSAGE2 or "真剣勝負だ…!",
            COLOR = Color:new(0,155,255),
            DURATION = 3,
            isPlayer = false
         },
         [3] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "神族キラー",
            COLOR = Color.yellow,
            DURATION = 3,
            isPlayer = false        
         }
      }
   }
   
end

function class:setTriggerList()
   self.TRIGGERS = {
      [0] = {
         tag = "TIME_FLG",
         action = function (status) self:time50(status) end,
         TIME = 50,
         used = false
      },
      [1] = {
         tag = "TIME_FLG",
         action = function (status) self:time80(status) end,
         TIME = 80,
         used = false
      },
      [2] = {
         tag = "TIME_FLG",
         action = function (status) self:time110(status) end,
         TIME = 110,
         used = false
      },
      [3] = {
         tag = "TIME_FLG",
         action = function (status) self:time120(status) end,
         TIME = 120,
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

function class:time50(status)
   if status == "use3" then
      self.hitStop = 1
      self.isRage = true
      self.gameUnit:addSP(100)
      self:showMessage(self.TIME50_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[1])
   end
end

function class:time80(status)
   if status == "use3" then
      self:showMessage(self.TIME80_MESSAGE_LIST)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[2])
   end
end

function class:time110(status)
   if status == "use3" then
      self.isFury = true
      self.gameUnit:addSP(100)
      self:showMessage(self.TIME110_MESSAGE_LIST)
   end
end

function class:time120(status)
   if status == "use3" then
      megast.Battle:getInstance():setBattleState(kBattleState_none);
      megast.Battle:getInstance():waveEnd(true);
      self:showMessage(self.TIME120_MESSAGE_LIST)
   end
end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   self.fromHost = false;
   self.gameUnit = event.unit;
   self.spValue = 20;
   self.attackCheckFlg = false;
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);

   self.timer = 0
   self.aura = nil
   self.hitStop = 0.5
   self.isRage = false
   self.isFury = false
   self.isAura = false
   self.AURA_INTERVAL = 99999
   self.currentTime = 0
   self.currentTalkTime = 0
   self.talkListIndex = 1
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()
   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   if not self:sarchTalkTarget() then
      self:showMessage(self.START_MESSAGE_LIST)
   end
   return 1
end

-- 特殊会話用関数
function class:sarchTalkTarget()
   --　優先度。優先度が高いものほど小さい数になる（最優先のpryorityは1）。
   local ply = 9
   local talk = {}
   for i=0,7 do
      local target = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i,true);
      for i,v in ipairs(self.TALK_LIST) do
         if target ~= nil and v.BASE_ID == target:getBaseID3() then
            if ply > v.PLYORITY then
               ply = v.PLYORITY
               talk = v.TALKS
            end
         end
      end
   end

   if ply ~= 9 then
      self.currentTalkList = {}
      for ii,vv in ipairs(talk) do table.insert(self.currentTalkList,vv) end
      return true
   end

   return false
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "md2Start" then
      self:setAura(event.unit)
   end
   if event.spineEvent == "loopStart" then
      self.aura:takeAnimation(0,"MD_loop",true);
   end
   return 1
end

function class:setAura(unit)
   if self.aura ~= nil then
      self.aura:takeAnimation(0,"MD_in",true);
      return 
   end
   self.aura = unit:addOrbitSystemWithFile("MD_2","MD_in");
   self.aura:takeAnimation(0,"MD_in",true);
   self:auraPosition(unit)
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(2,self.hitStop)
   self:checkTime(event.deltaTime)
   self:callTalk(event.deltaTime)
   self:auraPosition(event.unit)
   self:auraTimer(event.deltaTime,event.unit)
   return 1
end

function class:checkTime(deltaTime)
   if megast.Battle:getInstance():getBattleState() == kBattleState_active then
      self.currentTime = self.currentTime + deltaTime
      for index,trigger in pairs(self.TRIGGERS) do
         if trigger.TIME <= self.currentTime and not trigger.used then
            self:execTrigger(index)
         end
      end
   end
end

function class:callTalk(deltaTime)
   if self.currentTalkList == nil then
      return
   end

   if table.maxn(self.currentTalkList) < self.talkListIndex then
      self.currentTalkList = nil
      return
   end

   self.currentTalkTime = self.currentTalkTime - deltaTime
   if 0 > self.currentTalkTime then
      self.currentTalkTime = self.currentTalkList[self.talkListIndex].DURATION
      self:execShowMessage(self.currentTalkList[self.talkListIndex])
      self.talkListIndex = self.talkListIndex + 1
   end
end

function class:auraPosition(unit)
   if self.aura == nil then
      return
   end

   local vec = unit:getisPlayer() and 1 or -1
   local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * vec;
   local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
   self.aura:setPosition(targetx,targety);
   self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY())
   self.aura:setZOrder(unit:getZOrder() + 1)
end

function class:auraTimer(deltaTime,unit)
   if self.isAura and megast.Battle:getInstance():getBattleState() == kBattleState_active then
      if self.AURA_INTERVAL < self.timer then
         self.isAura = false
         self.timer = 0
         self.aura:takeAnimation(0,"empty",true);
      else
         self.timer = self.timer + deltaTime
      end
   end
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
      unit:takeAttack(tonumber(attackIndex));
   else
      self.skillCheckFlg = true;
      unit:takeSkill(1);
      megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(1));
      return 0;
   end
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
   if event.index == 3 then
      self:setupSkill3(event.unit)
   end
   return 1
end

function class:setupSkill3(unit)
   if not self.isAura then
      self.isAura = true
      unit:setActiveSkill(self.MAGIA_DRIVE)
      self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[0])
   else
      unit:setNextAnimationName("skill3b")
      unit:setNextAnimationEffectName("2skill3b")
      if self.isFury then
         -- 特殊真奥義
         self.isFury = false
         unit:setActiveSkill(self.SINOUGI)
      end
   end
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
   if messageBox.isPlayer then
      summoner.Utility.messageByPlayer(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   else
      summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
   end
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

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
   self.TRIGGERS[args.arg].action("use3")
   return 1
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

-- startからfinishまでのバフを実行する
function class:addBuffRange(unit,buffBoxList,start,finish)
    for i = start,finish do
        self:execAddBuff(unit,buffBoxList[i])
    end
end

function class:addBuffAll(unit,buffBoxList)
   for i,buffBox in pairs(buffBoxList) do
      self:execAddBuff(unit,buffBox)
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

class:publish();

return class;