local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="怪鳥", version=1.3, id=4001017})

class.ATTACK_TBL_GROUND = {
   attack1 = 1,
   attack2 = 1,
   attack3 = 1,
}
class.ATTACK_TBL_FLYING = {
   attack4 = 1,
   attack5 = 1
   -- attack6 = 1
}
class.SKILL_TBL_FLYING = {
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
   skill1 = 7,
   skill2 = 8,
   skill3 = 9,
   skill4 = 7
}

class.DOT_BORDER = 200000;

----------[[メッセージ]]----------
function class:setMessageBoxList()
   self.BUFF_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.BUFF_MESSAGE or "暴風状態：回避率アップ・ブレイク無効",
         COLOR = Color.cyan,
         DURATION = 10
      },
      [1] = {
         MESSAGE = self.TEXT.BUFF_MESSAGE3 or "一定以上、毒・燃焼などのダメージで暴風状態を解除",
         COLOR = Color.yellow,
         DURATION = 10
      }
   }

   self.BUFF_MESSAGE_LIST_50 = {
      [0] = {
         MESSAGE = self.TEXT.BUFF_MESSAGE2 or "超暴風状態：回避率大アップ・ブレイク無効",
         COLOR = Color.cyan,
         DURATION = 10
      },
      [1] = {
         MESSAGE = self.TEXT.BUFF_MESSAGE4 or "一定以上、毒・燃焼などのダメージで超暴風状態を解除",
         COLOR = Color.yellow,
         DURATION = 10
      }
   }

   self.REMOVE_BUFF_MESSAGE_LIST = {
      [0] = {
         MESSAGE = self.TEXT.REMOVE_BUFF_MESSAGE or "暴風状態解除",
         COLOR = Color.cyan,
         DURATION = 10
      }   
   }

  self.START_MESSAGE_LIST = {
    [0] = {
         MESSAGE = self.TEXT.START_MESSAGE or "攻撃力・クリティカルダメージアップ",
         COLOR = Color.cyan,
         DURATION = 10
      }   
  }

  self.RAGE_MESSAGE_LIST1 = {
    [0] = {
         MESSAGE = self.TEXT.RAGE_MESSAGE1 or "行動速度アップ",
         COLOR = Color.cyan,
         DURATION = 10
      }   
  }

  self.RAGE_MESSAGE_LIST2 = {
    [0] = {
       MESSAGE = self.TEXT.RAGE_MESSAGE2 or "与ダメージアップ",
       COLOR = Color.cyan,
       DURATION = 10
    },
    [1] = {
       MESSAGE = self.TEXT.RAGE_MESSAGE4 or "被ダメージアップ",
       COLOR = Color.red,
       DURATION = 10
    }

  }

  self.RAGE_MESSAGE_LIST3 = {
    [0] = {
         MESSAGE = self.TEXT.RAGE_MESSAGE3 or "奥義ゲージ速度アップ",
         COLOR = Color.cyan,
         DURATION = 10
      }   
  }

end

--------[[バフ]]--------
function class:setBuffBoxList()
   self.BUFF_BOX_LIST = {
     [0] = {
         ID = 5000031,
         BUFF_ID = 31,      --回避率アップ
         VALUE = 100,
         DURATION = 9999999,
         ICON = 16
     }
   }

   self.BUFF_BOX_LIST_50 = {
     [0] = {
         ID = 5000031,
         BUFF_ID = 31,      --回避率アップ
         VALUE = 200,
         DURATION = 9999999,
         ICON = 16
     }
   }



   self.BUFF_BOX_LIST_40 = {
     [0] = {
         ID = 5000032,
         BUFF_ID = 17,      --与ダメアップ
         VALUE = 30,
         DURATION = 9999999,
         ICON = 26
     },
     [1] = {
         ID = 5000034,
         BUFF_ID = 21,      --被ダメアップ
         VALUE = 20,
         DURATION = 9999999,
         ICON = 139
     }
   }

   self.BUFF_BOX_LIST_20 = {
     [0] = {
         ID = 5000033,
         BUFF_ID = 0,      --見た目だけ
         VALUE = 200,
         DURATION = 9999999,
         ICON = 36
     }
   }

end

--------[[特殊行動フラグ]]--------
function class:setHpTriggersList()
   self.TID_TIME_UP = 2
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hpFlg70(status) end,
         timing = 70,
         used = false
      },
      [2] = {
         tag = "HP_FLG",
         action = function (status) self:hpFlg40(status) end,
         timing = 40,
         used = false
      },
      [3] = {
         tag = "HP_FLG",
         action = function (status) self:hpFlg50(status) end,
         timing = 50,
         used = false
      },
      [4] = {
         tag = "HP_FLG",
         action = function (status) self:hpFlg20(status) end,
         timing = 20,
         used = false
      }
   }
    for _,trigger in pairs(self.TRIGGERS) do
        if trigger.tag == "HP_FLG" then
            self.hpMarkers[trigger.timing] = self.gameUnit:addNumHpMarker(trigger.timing * 0.01)
        end
    end
end

function class:recoveryBreak()
   self.isBreak = false
end

function class:switchWind(status)
   self.dotCnt = 0;
   if self.windUnit == nil then
      self.windUnit = self.gameUnit:addOrbitSystem("wind_roop")
      self.windUnit:setAnimation(0,"wind_roop",true)
      self.windUnit:setPositionX(self.gameUnit:getAnimationPositionX());
      self.windUnit:setPositionY(self.gameUnit:getAnimationPositionY());
      self.windUnit:setZOrder(9998);
      self.isWind = true
   end

   if status == "showWindAura" then
      -- if self.isBreak or self.isFirstBreak then
      --    return
      -- end
      self.subBar:setVisible(true);
      self.subBar:setPercent(100);
      self.gameUnit:setSetupAnimationName("idle2");
      if self.gameUnit:getTeamUnitCondition():findConditionWithType(self.BUFF_BOX_LIST[0].BUFF_ID) == nil and self.isRage then
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST_50[0])
        self:showMessage(self.BUFF_MESSAGE_LIST_50)
      elseif self.gameUnit:getTeamUnitCondition():findConditionWithType(self.BUFF_BOX_LIST[0].BUFF_ID) == nil then
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST[0])
        self:showMessage(self.BUFF_MESSAGE_LIST)
      end
      self:setDefaultMainPosition(self.gameUnit,-46,313);
      self.gameUnit:setPositionY(0);
      self.windUnit:setAnimation(0,"wind_roop",true)
      self.isWind = true
   end

   if status == "hideWindAura" then
      self.subBar:setVisible(false);
      self:setDefaultMainPosition(self.gameUnit,0,225);
      self.windUnit:setAnimation(0,"enpty",true)
      self.gameUnit:setSetupAnimationName("");
      self.isWind = false
   end
end

function class:hpFlg70(status)
    if status == "use3" then
        self.gameUnit:addSP(100);
        self:showMessage(self.RAGE_MESSAGE_LIST1);
        self.forceSkillNum = 3;
        self.hitStop = 1;
        self.gameUnit:removeHpMarker(self.hpMarkers[70])
    end

end

function class:hpFlg50(status)
    if status == "use3" then
        self.isRage = true;
        if self.isWind then
            self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST_50[0])
            self:showMessage(self.BUFF_MESSAGE_LIST_50)
        end
        self.gameUnit:removeHpMarker(self.hpMarkers[50])
    end
end

function class:hpFlg40(status)
    if status == "use3" then
        self.gameUnit:addSP(100);
        self:showMessage(self.RAGE_MESSAGE_LIST2);
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST_40[0])
        self.forceSkillNum = 3;
        for i=0,7 do
            local targetUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
            if targetUnit ~= nil then
                self:execAddBuff(targetUnit,self.BUFF_BOX_LIST_40[1])
            end
        end
        self.gameUnit:removeHpMarker(self.hpMarkers[40])
    end
end

function class:hpFlg20(status)
    if status == "use3" then
        self.spValue = self.spValue*2;
        self:showMessage(self.RAGE_MESSAGE_LIST3);
        self:execAddBuff(self.gameUnit,self.BUFF_BOX_LIST_20[0])
        self.gameUnit:removeHpMarker(self.hpMarkers[20])
    end
end



---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
   event.unit:setSPGainValue(0)
   event.unit:setNextAnimationName("idle")
    self.hpMarkers = {}
    self.gameUnit = event.unit
    self.windUnit = nil
   self:setHpTriggersList()
   self:setBuffBoxList()
   self:setMessageBoxList()

   self.ADD_BASE_VALUE = -2

   self.hitStop = 0.5;
   self.isFlying = true
   self.isFirstBreak = false
   self.isBreak  = false
   self.attackFlg = false
   self.skillFlg = false
   self.isRage = false;
   self.showMessageTimer = 0
   self.dotCheckTimer = 0
   self.spValue = 20;
   self.forceAttackNum = 0;
   self.forceSkillNum = 0;
   self.dotCnt = 0;

    self.subBar =  BattleControl:get():createSubBar();
    self.subBar:setWidth(200); --バーの全体の長さを指定
    self.subBar:setHeight(13);
    self.subBar:setPercent(0); --バーの残量を0%に指定
    self.subBar:setVisible(false);
    self.subBar:setPositionX(-300);
    self.subBar:setPositionY(250);
    self.subBar:setVisible(false);


   return 1
end

function class:startWave(event)
  self:showMessage(self.START_MESSAGE_LIST);
  self:switchWind("showWindAura")
  return 1;
end

function class:multiply(multiplier)
   local buffValue = (multiplier * megast.Battle:getInstance():getCurrentMineFloor())
   return buffValue
end

function class:execSetAnimation(animationName)
   self.gameUnit:setNextAnimationName(animationName)
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
   self:HPTriggersCheck(event.unit)
   self:setWindPosition(event.unit)

   event.unit:setReduceHitStop(2,self.hitStop or 0.5)
   if self.isWind then
     self:dotCheck(event.unit,event.deltaTime);
   end

   if self.isBreak and self.gameUnit.m_breaktime <= 0 then
      self:recoveryBreak()
   end
    self:AI_HpSkill(event.unit)
    self:AI_HpBuff(event.unit)
  return 1
end

function class:AI_HpSkill(unit)
    if self.AI_SkillFirst == nil then
        self.AI_SkillFirst = true
        self.skillValueBox = {}
        self.skillValueBox[1] = 70
        self.skillValueBox[2] = 40
    end
    ---奥義中か確認
    if unit:getUnitState() == kUnitState_skill then
        ---HPフラグ関係ない奥義の場合、奥義終了まで判定しない
        local flgBuff = unit:getTeamUnitCondition():findConditionWithID(238)
        if flgBuff == nil then
            for i,v in ipairs(self.skillValueBox) do
                if not unit:getIsHpMarkerActive(self.skillValueBox[i] / 100) and self.skillValueBox[i] > 0 then
                    ---特定のHPマーカーが消えていて奥義中の場合
                    local keyBuff = unit:getTeamUnitCondition():addCondition(-238,0,self.skillValueBox[i],99999,0);
                    keyBuff:setRemoveOnResetState(true);
                    self.skillValueBox[i] = self.skillValueBox[i] * -1
                    break;
                end
            end
            ---判定しないためのフラグ付与
            local keyBuff = unit:getTeamUnitCondition():findConditionWithID(-238)
            if keyBuff == nil then
                local newBuff = unit:getTeamUnitCondition():addCondition(238,0,0,99999,0);
                newBuff:setRemoveOnResetState(true);
            end
        end
    end
    ---キー設定
    local keyBuff = unit:getTeamUnitCondition():findConditionWithID(-238)
    local keyValue = 0
    if keyBuff ~= nil then
        keyValue = keyBuff:getValue()
    end
    ---キーの効果量を見る
    for i,v in ipairs(self.skillValueBox) do
        if self.skillValueBox[i] > 0 then
            unit:getTeamUnitCondition():removeConditionWithID(23800 + self.skillValueBox[i])
        else
            local markerValue = self.skillValueBox[i] * -1
            if keyValue == markerValue then
                unit:getTeamUnitCondition():addCondition(23800 + markerValue,0,0,99999,0);
            else
                unit:getTeamUnitCondition():removeConditionWithID(23800 + markerValue)
            end
        end
    end
end

function class:AI_HpBuff(unit)
    if self.AI_BuffFirst == nil then
        self.AI_BuffFirst = true
        self.buffValueBox = {}
        self.buffValueBox[1] = 50
    end
    local buff = unit:getTeamUnitCondition():findConditionWithID(5000031)
    for i,v in ipairs(self.buffValueBox) do
        if not unit:getIsHpMarkerActive(self.buffValueBox[i] / 100) and self.buffValueBox[i] > 0 then
            ---第一段階
            if buff ~= nil then
                ---バフ発見時
                unit:getTeamUnitCondition():addCondition(23800 + self.buffValueBox[i],0,0,99999,0);
                self.buffValueBox[i] = self.buffValueBox[i] * -1
                break
            else
                ---バフがなかった場合はここに流れ続ける
                break
            end
        end
        if self.buffValueBox[i] < 0 and buff == nil then
            unit:getTeamUnitCondition():removeConditionWithID(23800 - self.buffValueBox[i])
        end
    end
end

function class:setWindPosition(unit)
   if self.isWind then
      self.windUnit:setPositionX(self.gameUnit:getAnimationPositionX());
      self.windUnit:setPositionY(self.gameUnit:getAnimationPositionY());
   end
end




---------------------------------------------------------------------------------
-- idle
---------------------------------------------------------------------------------
function class:takeIdle(event)   
   if self.isFlying then 
      event.unit:setNextAnimationName("idle")
   else
      event.unit:setNextAnimationName("idle2")
   end
   return 1
end

---------------------------------------------------------------------------------
-- damage
---------------------------------------------------------------------------------
function class:takeDamage(event)
   if self.isFlying then 
      event.unit:setNextAnimationName("damage")
   else
      event.unit:setNextAnimationName("damage2")
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

   if "showWindAura" == event.spineEvent or "hideWindAura" == event.spineEvent then
      self:switchWind(event.spineEvent)
   end

   return 1
end

---------------------------------------------------------------------------------
-- break
---------------------------------------------------------------------------------
function class:takeBreake(event)
   self.isFlying = false
   self.isBreak = true
   self.isFirstBreak = true
   self:execRemoveCondition(self.gameUnit,self.BUFF_BOX_LIST[0].BUFF_ID)
   self:switchWind("hideWindAura")
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

      if self.forceAttackNum ~= 0 then
        attackNo = self.forceAttackNum;
        self.forceAttackNum = 0;
      end

      event.unit:takeAttack(attackNo)
      return 0
   end
   self.attackFlg = false

   if event.index == 6 then
      self:switchWind("showWindAura")
   end

   event.unit:addSP(self.spValue)
   event.unit:setActiveSkill(self.ACTIONSKILL_TBL["attack"..event.index])
   return 1
end

function class:attackTbl()
   if self.isFlying then
      return self.ATTACK_TBL_FLYING
   end
   return self.ATTACK_TBL_GROUND
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
   if not self.isFlying then
      self.isFlying = true
      self.skillFlg = true
      self.forceAttackNum = 6;
      event.unit:takeSkill(4)
      return 0
   end

   if self.skillFlg == false and megast.Battle:getInstance():isHost() then
      self.skillFlg = true

      local skillKeyName = summoner.Random.sampleWeighted(self.SKILL_TBL_FLYING)
      local skillStr = string.gsub(skillKeyName,"skill","")
      local skillNo = tonumber(skillStr)

      if self.forceSkillNum ~= 0 then
        skillNo = self.forceSkillNum;
        self.forceSkillNum = 0;
      end

      event.unit:takeSkill(skillNo)
      return 0
   end
   self.skillFlg = false
   event.unit:setActiveSkill(self.ACTIONSKILL_TBL["skill"..event.index])
   return 1
end


--HPトリガー
function class:HPTriggersCheck(unit)
  
   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
   local priorityIndex = nil

   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
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

-- TRIGGERテーブルの内容実行。TRIGGER用index定数にはとりあえず頭にTIDをつけとく
function class:execTrigger(index)
    if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end

   local receiveNumber = 3

   local action = "use" .. receiveNumber

   self.TRIGGERS[index].action(action)
   self.TRIGGERS[index].used = true

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

---------------------------------------------------------------------------------
-- receive
---------------------------------------------------------------------------------
function class:receive3(args)
    self.TRIGGERS[args.arg].used = true
   self.TRIGGERS[args.arg].action("use3")
   return 1
end

function class:receive4(args)
    self.gameUnit:takeAnimation(0,"damage",false);
    self.isFlying = false
    self.isBreak = true
    self:execRemoveCondition(self.gameUnit,self.BUFF_BOX_LIST[0].BUFF_ID)
    self:switchWind("hideWindAura")
   return 1
end

function class:takeBreakeDamageValue(event)
  if self.isWind then
    return 0;
  end
  return event.value;
end

--==========================================================================
-- バフ処理実行
--==========================================================================
function class:execAddBuff(unit,buffBox)
  local buff  = nil;
  local correction = buffBox.VALUE

  if buffBox.EFFECT ~= nil then
    buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,correction,buffBox.DURATION,buffBox.ICON,buffBox.EFFECT);
  else
    buff = unit:getTeamUnitCondition():addCondition(buffBox.ID,buffBox.BUFF_ID,correction,buffBox.DURATION,buffBox.ICON);
  end
  if buffBox.SCRIPT ~= nil then
    buff:setScriptID(buffBox.SCRIPT);
  end
  if buffBox.SCRIPTVALUE1 ~= nil then
    buff:setValue1(buffBox.SCRIPTVALUE1);
  end
end

-- バフ削除
function class:execRemoveCondition(unit,buffId)
    if unit:getTeamUnitCondition():findConditionWithType(buffId) ~= nil then
      -- local tx = Text:fetchByEnemyID("mine_50003")
      -- summoner.Utility.messageByEnemy("featchByEnemyID使用",5,Color.yellow);
      -- summoner.Utility.messageByEnemy(tx.REMOVE_BUFF_MESSAGE,5,Color.yellow);
      self:showMessage(self.REMOVE_BUFF_MESSAGE_LIST)
      unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithType(buffId))
      unit:resumeUnit()
    end  
end

--==========================================================================
-- 
--==========================================================================
function class:dotCheck(unit,deltaTime)
  self:subBarControll(unit);
  self.dotCheckTimer = self.dotCheckTimer + deltaTime;
  if self.dotCheckTimer < 1 then
    return;
  end
  self.dotCheckTimer = self.dotCheckTimer - 1;
  local dotDamageParSec = unit:getTeamUnitCondition():findConditionValue(90) + unit:getTeamUnitCondition():findConditionValue(97) + unit:getTeamUnitCondition():findConditionValue(131) + unit:getTeamUnitCondition():findConditionValue(129);


  if self.dotCnt >= self.DOT_BORDER and unit:getBurstState() ~= kBurstState_active then
    if not self:getIsHost() then
      return;
    end
    unit:takeAnimation(0,"damage",false);
    self.isFlying = false
    self.isBreak = true
    self:execRemoveCondition(self.gameUnit,self.BUFF_BOX_LIST[0].BUFF_ID)
    self:switchWind("hideWindAura")
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0)
  end

  --ドットが入る前に計算しているので、反映は次回以降
  self.dotCnt = self.dotCnt + dotDamageParSec;
end

function class:setDefaultMainPosition(unit,valueX,valueY)
    unit:setDefaultMainPositionX(valueX);
    unit:setDefaultMainPositionY(valueY);

    return 1;
end

function class:subBarControll(unit)
    local x = unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local y = unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.subBar:setPositionX(unit:getPositionX() + x);--位置を指定
    self.subBar:setPositionY(unit:getPositionY()+ y);
    self.subBar:setVisible(true);
    self.subBar:setPercent(100 * (self.DOT_BORDER - self.dotCnt)/self.DOT_BORDER);
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

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end

class:publish();

return class;
