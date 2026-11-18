local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="犬", version=1.3, id=2018437});
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
class.BATTLE_POINT_VALUE = 5000;
class.BATTLE_POINT_VALUE_FIXED = 200000;

function class:setBuffBoxList()
   self.HP_70_Buff = {
      [1] = {
         ID = 501411,
         EFID = 28, -- 行動速度
         VALUE = 10,
         DURATION = 99999,
         ICON = 7
      }
   }

   self.HP_50_Buff = {
      [1] = {
         ID = 501414,
         EFID = 22, -- くりてかる
         VALUE = 100,
         DURATION = 99999,
         ICON = 11,
         SCRIPT = 36,
         SCRIPTVALUE1 = 97
      }
   }

   self.HP_30_Buff = {
      [1] = {
         ID = 501415,
         EFID = 17, -- よだめ
         VALUE = 25,
         DURATION = 99999,
         ICON = 26,
         SCRIPT = 22
      }
   }



  self.DOWN_BUFF_BOX_LIST = {
       [1] = {
        ID = 5014110,
        EFID = 21, --被ダメージ
        VALUE = 75,
        DURATION = 999999,
        ICON = 175,
        SCRIPT = 3
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
      [0] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "物理耐性アップ・魔法耐性ダウン",
         COLOR = Color.red,
         DURATION = 10,
         isPlayer = false        
      },
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE2 or "氷結時さらに魔法耐性ダウン",
         COLOR = Color.red,
         DURATION = 10,
         isPlayer = false        
      }
   }

   self.HP_70_MESSAGES = {
      [0] = {
         MESSAGE = self.TEXT.HP_MESSAGE1 or "行動速度アップ",
         COLOR = Color.red,
         DURATION = 10,
         isPlayer = false
      }
    }

    self.HP_50_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP_MESSAGE2 or "相手燃焼時クリティカル率アップ",
            COLOR = Color.red,
            DURATION = 10,
            isPlayer = false
        }
    }
    self.HP_30_MESSAGES = {
        [0] = {
             MESSAGE = self.TEXT.HP_MESSAGE4 or "クリティカルダメージアップ",
             COLOR = Color.red,
             DURATION = 10,
             isPlayer = false
        }
    }
      
   

   self.FREEZE_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.FREEZE_MESSAGE1 or "氷結状態で魔法耐性ダウン",
         COLOR = Color.cyan,
         DURATION = 10,
         isPlayer = false
      }
   }

   self.FREEZE_MESSAGE_LIST2 = {
      [0] = {
         MESSAGE = self.TEXT.FREEZE_MESSAGE2 or "さんが氷結させて攻撃力・防御力低下",
         COLOR = Color.cyan,
         DURATION = 10,
         isPlayer = false
      }
   }




end



--------[[特殊行動]]--------
function class:setTriggerList()
    self.HP_TRIGGERS = {
        [0] = {
            HP = 70,
            trigger = "HP70",
            isActive = true
        },
        [1] = {
            HP = 50,
            trigger = "HP50",
            isActive = true
        },
        [2] = {
            HP = 30,
            trigger = "HP30",
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
   self.isCheckStartBuff = false;
   self.forceAttackIndex = 0;
   self.freezeActTime = 0;
   self.roomHP = 100;
   event.unit:setSPGainValue(0);
   event.unit:setSkillInvocationWeight(0);

   self.isDown = false;
   self.downTimer = 0;


   self.hitStop = 0
   self:setTriggerList()
   self:setMessageBoxList()
   self:setBuffBoxList()

    self.hpMarkers = {
        [70] = self.gameUnit:addNumHpMarker(0.7),
        [50] = self.gameUnit:addNumHpMarker(0.5),
        [30] = self.gameUnit:addNumHpMarker(0.3)
    }


   -- self:showMessage(self.START_MESSAGE_LIST)
   -- self:addBuff(self.gameUnit,self.BUFF_BOX_LIST)
   return 1
end

function class:startWave(event)
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




---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)


   if self.isDown then
     self:countDownDownDuration(event.unit,event.deltaTime);
   end
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
      -- self:burstStackBuff(event.unit);
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
  self:showMessage(self.FREEZE_MESSAGE_LIST);
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
   self:HP70(self.gameUnit);
   return 1
end

function class:receive4(args)
   self:HP50(self.gameUnit);
   return 1
end

function class:receive5(args)
   self:HP30(self.gameUnit);
   return 1
end

function class:receive6(args)
   self:addDownTime(self.gameUnit);
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
-- メッセージ表示系
--[[
showMessage(<table> messageBoxList,<number> index)
   messageBoxList : 
      必須。以下のようなメッセージ表示用のテーブルを用意して投げる
      TEKITOUNA_MESSAGES = [
         [0] = [
            <String> MESSAGE = 本文,
            <Color> COLOR = 色,
            <number> DURATION = 表示期間(秒)]

         ],
         [1] = ...
      ]
   index : 
      任意。messageBoxList[index]の内容を表示する。
      この引数がない場合、messageBoxListの全ての内容を表示する。
]]
function class:showMessage(messageBoxList,index)
   if index == nil then 
      self:showMessageRange(messageBoxList,0,table.maxn(messageBoxList))
   return
   end
   self:execShowMessage(messageBoxList[index])
end

--[[
showMessageRange(<table> messageBoxList,<number> start,<number> last)
   messageBoxList : 
      必須。
   start,last : 
      必須。messageBoxList[start]からmessageBoxList[last]の内容を表示する。
      この引数がない場合、何も表示しない。
]]
function class:showMessageRange(messageBoxList,start,last)
   for i = start,last do
      self:execShowMessage(messageBoxList[i])
   end
end

--[[
showMessageRange(<table> messageBox)
   敵側のメッセージ欄にmessageBoxの内容を表示する
]]
function class:execShowMessage(messageBox)
   summoner.Utility.messageByEnemy(messageBox.MESSAGE,messageBox.DURATION,messageBox.COLOR);
end


--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
    if not self:getIsHost() then
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
    if trigger == "HP70" then
        self:HP70(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end

    if trigger == "HP50" then
        self:HP50(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
        return true;
    end

    if trigger == "HP30" then
        self:HP30(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
        return true;
    end
    return false;
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

function  class:HP70(unit)
    self:addBuff(unit,self.HP_70_Buff);
    self:showMessage(self.HP_70_MESSAGES);
    self.gameUnit:removeHpMarker(self.hpMarkers[70])
end

function  class:HP50(unit)
    self:addBuff(unit,self.HP_50_Buff);
    self:showMessage(self.HP_50_MESSAGES);
    self.gameUnit:removeHpMarker(self.hpMarkers[50])
end

function  class:HP30(unit)
    self:addBuff(unit,self.HP_30_Buff);
    self:showMessage(self.HP_30_MESSAGES);
    self.gameUnit:removeHpMarker(self.hpMarkers[30])
end



--===================================================================================================================
--氷結チェック
--===================================================================================================================

function class:checkFreeze(unit)
    if not self:getIsHost() then
        return;
    end
    local freeze = unit:getTeamUnitCondition():findConditionWithType(96);
    if freeze ~= nil and not self.beforeFreeze then
        self.beforeFreeze = true;
        self:addDownTime(unit);
        
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,0);
        return;
    end
    if freeze == nil then
        self.beforeFreeze = false;
    end

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





class:publish();

return class;
