local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="犬", version=1.3, id=600000034});
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

class.TELOP_SPAN = 30
class.MAX_DOWN_DURATION = 20;
class.BATTLE_POINT_VALUE = 1000;
class.BATTLE_POINT_VALUE_FIXED = 50000;

function class:setBuffBoxList()
   self.HP_80_Buff = {
      [1] = {
         ID = 501411,
         EFID = 13, -- 攻撃
         VALUE = 50,
         DURATION = 99999,
         ICON = 3
      },
      [2] = {
         ID = 501412,
         EFID = 31, -- 回避
         VALUE = 10,
         DURATION = 99999,
         ICON = 16
      }
   }

   self.HP_60_Buff = {
      [1] = {
         ID = 501413,
         EFID = 17, -- 与ダメ
         VALUE = 20,
         DURATION = 99999,
         ICON = 26
      },
      [2] = {
         ID = 501414,
         EFID = 28, -- 行動速度
         VALUE = 10,
         DURATION = 99999,
         ICON = 7
      }
   }

   self.HP_40_Buff = {
      [1] = {
         ID = 501415,
         EFID = 31, -- 回避
         VALUE = 20,
         DURATION = 99999,
         ICON = 16
      },
      [2] = {
         ID = 501416,
         EFID = 28, -- 行動速度
         VALUE = 10,
         DURATION = 99999,
         ICON = 7
      }
   }

  self.HP_20_Buff = {
      [1] = {
         ID = 501417,
         EFID = 17, -- 与ダメ
         VALUE = 30,
         DURATION = 99999,
         ICON = 26
      },
      [2] = {
         ID = 501418,
         EFID = 7, --自然回復
         VALUE = 1000,
         DURATION = 99999,
         ICON = 35
      }
   }

  self.DOWN_BUFF_BOX_LIST = {
       [1] = {
        ID = 5014110,
        EFID = 15, --防御力
        VALUE = -50,
        DURATION = 999999,
        ICON = 6
      },
      [2] = {
        ID = 5014111,
        EFID = 13, --攻撃力
        VALUE = -50,
        DURATION = 999999,
        ICON = 4
      },
      [4] = {
        ID = 5014121,
        EFID = 31, --回避率
        VALUE = -100,
        DURATION = 999999,
        ICON = 0
      }
  }

  self.TARGET_BUFF_BOX_LIST = {
       [1] = {
        ID = 501419,
        EFID = 17, -- ダメージ
        VALUE = 100,
        DURATION = 999999,
        ICON = 26
      }
  }

end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "炎属性ダメージ無効",
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false        
      }
   }

   self.HP_TRIGGER_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.HP_MESSAGE1 or "攻撃力アップ",
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false
      },
      [2] = {
         MESSAGE = self.TEXT.HP_MESSAGE2 or "回避率アップ",
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false
      },
      [3] = {
         MESSAGE = self.TEXT.HP_MESSAGE3 or "与ダメージアップ",
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false
      },
      [4] = {
         MESSAGE = self.TEXT.HP_MESSAGE4 or "攻撃速度アップ",
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false
      },
      [5] = {
         MESSAGE = self.TEXT.HP_MESSAGE1 or "HP自然回復",
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false
      }
   }

   self.FREEZE_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.FREEZE_MESSAGE1 or "氷結状態で攻撃力・防御力低下",
         COLOR = Color.cyan,
         DURATION = 10,
         isPlayer = false
      }
   }

   self.FREEZE_MESSAGE_LIST2 = {
      [1] = {
         MESSAGE = self.TEXT.FREEZE_MESSAGE2 or "さんが氷結させて攻撃力・防御力低下",
         COLOR = Color.cyan,
         DURATION = 10,
         isPlayer = false
      }
   }


    -- レイドメッセージ
    self.RAID_MESSAGES = {
        {
            MESSAGE = self.TEXT.mess1 or "ボスに狙われている！",
            COLOR = Color.red,
            DURATION = 5
        }        
    }

  -- テロップ
  self.mes_telop1 = self.TEXT.telop1 or "ボスに狙われると被ダメージが増加します。"
  self.mes_telop2 = self.TEXT.telop2 or "ユニットが倒れた時は、入れ替えて戦いましょう。"
  self.mes_telop3 = self.TEXT.telop3 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"
end


function class:telop(deltaTime)
    if self.TELOP_SPAN < self.telopTimer then
        self.telopTimer = 0
        local rand = LuaUtilities.rand(1,4)
        if rand == 1 then
            RaidControl:get():addPauseMessage(self.mes_telop1 , 2.2);
        elseif rand == 2 then
            RaidControl:get():addPauseMessage(self.mes_telop2 , 2.2);
        elseif rand == 3 then
            RaidControl:get():addPauseMessage(self.mes_telop3 , 2.2);
        end                
    else
        self.telopTimer = self.telopTimer + deltaTime
    end
end

--------[[特殊行動]]--------
function class:setTriggerList()
    self.HP_TRIGGERS = {
        [1] = {
            HP = 80,
            trigger = "HP80",
            isActive = true
        },
        [2] = {
            HP = 60,
            trigger = "HP60",
            isActive = true
        },
        [3] = {
            HP = 40,
            trigger = "HP40",
            isActive = true
        },
        [4] = {
            HP = 20,
            trigger = "HP20",
            isActive = true
        }
    }
end

function class:hp40(status)
   if status == "use3" then
      self.hitStop = 1
      self:showMessage(self.HP40_MESSAGE_LIST)
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
   self.beforeFreeze = false;
   self.beforeFreezeTime = 0;
   self.isCheckStartBuff = false;
   self.forceAttackIndex = 0;
   self.freezeActTime = 0;
   self.roomHP = 100;
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);

   self.isDown = false;
   self.downTimer = 0;

   self.telopTimer = 0

   self.hitStop = 0
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()


   self.stackBuffList = {}
   self.stackMessageList = {}
   -- self:showMessage(self.START_MESSAGE_LIST)
   -- self:addBuff(self.gameUnit,self.BUFF_BOX_LIST)
   return 1
end

function class:startWave(event)
    self:takeInitGet(event.unit);
    self:showMessage(self.START_MESSAGE_LIST);
    return 1;
end

-- ---------------------------------------------------------------------------------
-- -- run
-- ---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "spInCompleat" then
        event.unit:setAnimation(0,"sp_idle",false);
    end
    return 1;
end


-- ---------------------------------------------------------------------------------
-- -- executeAction
-- ---------------------------------------------------------------------------------
function class:excuteAction(event)
  self:checkTarget()
  return 1
end

-- 被ターゲット判定
function class:checkTarget()
  if not self.isTarget and self:getIsTarget() then
    self:addBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST)
    self:showMessage(self.RAID_MESSAGES)
  end
  if self:getIsTarget() then
    BattleControl:get():showHateAll()
  else
    BattleControl:get():hideHateAll(); 
    self:removeBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST[1].ID)    
  end
  self.isTarget = self:getIsTarget();
end

function class:getIsTarget()
  return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > 1000000;
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   event.unit:setReduceHitStop(2,1)

   self:telop(event.deltaTime)
   if self.isDown then
     self:countDownDownDuration(event.unit,event.deltaTime);
   end
   self:fetchFreezeActTime(event.unit);
   self:checkFreeze(event.unit);   
   self:checkDown(event.unit);
   self:HPTriggersCheck(event.unit);
   return 1
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
   if event.index == 5 then
      self:burstStackBuff(event.unit);
   else
      self:addSP(event.unit);
   end
   return 1
end

function class:attackReroll(unit)
  local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
  local attackIndex = string.gsub(attackStr,"ATTACK","");

  if self.forceAttackIndex ~= 0 then
      attackIndex = self.forceAttackIndex;
      self.forceAttackIndex = 0;
  else
      self.isCheckStartBuff = true;
  end

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

   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   self:skillActiveSkillSetter(event.unit,event.index);
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   unit:takeSkill(tonumber(skillIndex));
   megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
   return 0;
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
-- ダウン関係
---------------------------------------------------------------------------------
function class:takeDamageValue(event)


  return event.value;
end


function class:damageCheck(event)
  
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

    if self.isDown then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do
        
        if v.HP >= hpRate and v.isActive then

            if self:excuteTrigger(unit,v.trigger) then

                v.isActive = false;
            end
        end
    end
end


function class:excuteTrigger(unit,trigger)
    if trigger == "HP80" then
        table.insert(self.stackBuffList,self.HP_80_Buff[1]);
        table.insert(self.stackBuffList,self.HP_80_Buff[2]);
        self.stackMessageList[1] = self.HP_TRIGGER_MESSAGE_LIST[1];
        self.stackMessageList[2] = self.HP_TRIGGER_MESSAGE_LIST[2];
        unit:setInvincibleTime(7);
        self.forceAttackIndex = 5;
        
        return true;
    end

    if trigger == "HP60" then
        table.insert(self.stackBuffList,self.HP_60_Buff[1]);
        table.insert(self.stackBuffList,self.HP_60_Buff[2]);
        self.stackMessageList[3] = self.HP_TRIGGER_MESSAGE_LIST[3];
        self.stackMessageList[4] = self.HP_TRIGGER_MESSAGE_LIST[4];
        unit:setInvincibleTime(7);
        self.forceAttackIndex = 5;
        return true;
    end

    if trigger == "HP40" then
        table.insert(self.stackBuffList,self.HP_40_Buff[1]);
        table.insert(self.stackBuffList,self.HP_40_Buff[2]);
        self.stackMessageList[2] = self.HP_TRIGGER_MESSAGE_LIST[2];
        self.stackMessageList[4] = self.HP_TRIGGER_MESSAGE_LIST[4];
        unit:setInvincibleTime(7);
        self.forceAttackIndex = 5;
        return true;
    end

    if trigger == "HP20" then
        table.insert(self.stackBuffList,self.HP_20_Buff[1]);
        table.insert(self.stackBuffList,self.HP_20_Buff[2]);
        self.stackMessageList[3] = self.HP_TRIGGER_MESSAGE_LIST[3];
        self.stackMessageList[5] = self.HP_TRIGGER_MESSAGE_LIST[5];
        unit:setInvincibleTime(7);
        self.forceAttackIndex = 5;
        return true;
    end
    return false;
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

function class:burstStackBuff(unit)
    self:addBuff(unit,self.stackBuffList);
    self:showMessage(self.stackMessageList);

    self.stackBuffList = {};
    self.stackMessageList = {};
end

--===================================================================================================================
--氷結チェック
--===================================================================================================================

function class:checkFreeze(unit)
    local freeze = unit:getTeamUnitCondition():findConditionWithType(96);
    if freeze ~= nil and not self.beforeFreeze then
        self.beforeFreeze = true;
        self:addDownTime(unit);
        self:showMessage(self.FREEZE_MESSAGE_LIST);
        self.beforeFreezeTime = freeze:getTime();
        self:sendFreezeActTime(unit);
        local point = self:calcPoint(unit);
        RaidControl:get():addBattlePoint(point,0);
        self:showPointMessage(point);
        return;
    end
    if freeze == nil then
        self.beforeFreeze = false;
    end

    -- if freeze ~= nil and self.beforeFreeze then

    --     if freeze:getTime() >= self.beforeFreezeTime then
    --         self:addDownTime(unit);
    --         self:sendFreezeActTime(unit);
    --     end
    --     self.beforeFreezeTime = freeze:getTime();
    -- end

end

function class:addDownTime(unit)
    self.downTimer = self.downTimer + 10 < self.MAX_DOWN_DURATION and self.downTimer + 10 or self.MAX_DOWN_DURATION;
end



function class:checkDown(unit)
    if not self.isCheckStartBuff then
        return;
    end
    if self.downTimer > 0 and not self.isDown then
        self:takeDown(unit);
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

--==================================================================================================================================================
--ルーム同期


function class:takeInitGet(unit)
    -- RaidControl:get():getCustomValue("playerName");
    self:setFreezeActTime(RaidControl:get():getCurrentRaidTime());

end

function class:sendFreezeActTime(unit)
    --持ってくる前に今氷結が入った事実をまず自分の中で保持
    self:setFreezeActTime(RaidControl:get():getCurrentRaidTime());
    --現状部屋の最新のものについて取得　ここで一旦古いものになる。
    self:fetchFreezeActTime(unit);
    if self.freezeActTime <= RaidControl:get():getCurrentRaidTime() then
        self:setFreezeActTime(RaidControl:get():getCurrentRaidTime());
        RaidControl:get():setCustomValue("freezeActTime",""..self.freezeActTime);
        local playerName = BattleControl:get():getPlayerName();
        local byteCode = self:toByteCode(playerName);
        RaidControl:get():setCustomValue("playerName",byteCode);
    end
end

function class:setFreezeActTime(time)
    self.freezeActTime = math.floor(time);
end

function class:fetchFreezeActTime(unit)
    if not self.isCheckStartBuff then
        return;
    end

    local tempActTime = tonumber(RaidControl:get():getCustomValue("freezeActTime"));
    
    if tempActTime ~= "" and tempActTime ~= "error" and tempActTime ~= nil then
        -- summoner.Utility.messageByEnemy(""..tempActTime,5,summoner.Color.red);
    else
        -- summoner.Utility.messageByEnemy("ない"..self.freezeActTime,5,summoner.Color.red);  
        return;
    end

    
    tempActTime = math.floor(tempActTime);


    if tempActTime > self.freezeActTime then
        self:setFreezeActTime(tempActTime);
        local playerNameByteCode = RaidControl:get():getCustomValue("playerName");
        local playerName = self:toUnicode(playerNameByteCode);

        -- summoner.Utility.messageByEnemy("他人氷結"..self.freezeActTime,15,summoner.Color.red);
        local freezeMessageWithPlayerName = {
            [1] = {
               MESSAGE = playerName..self.FREEZE_MESSAGE_LIST2[1].MESSAGE,
               COLOR = Color.cyan,
               DURATION = 10,
               isPlayer = false
            }
        }


        self:showMessage(freezeMessageWithPlayerName);
        self:addDownTime(unit);
    end
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


class:publish();

return class;
