--@additionalItem,105291101,105301101,105311101,105321101,105331101,105341101,105351101,105361101,105371101
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="異世界からの手", version=1.3, id=600000015});
class:inheritFromUnit("bossBase");

--手が放つ状態異常の確率
class.RING_EFFECT_LIST = {
  [0] = {
    WEIGHT = 33,
    POINT = 0,
    ACTIVE_SKILL_NO = 6,
    ANIMATION_NAME = "skill1a"
  },
  [1] = {
    WEIGHT = 33,
    POINT = 0,
    ACTIVE_SKILL_NO = 4,
    ANIMATION_NAME = "skill1b"
  },
  [2] = {
    WEIGHT = 33,
    POINT = 0,
    ACTIVE_SKILL_NO = 5,
    ANIMATION_NAME = "skill1c"
  }
}

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
  ATTACK2 = 2,
  SKILL2 = 3
}

class.startX = -250
class.startY = -50
class.MOVE_INTERVAL = 1

--指輪関係
class.RING_SHINE_INTERVAL = 11
class.RING_SHINE_WEIGHT = 4
class.RING_TIMER_STOPPER_HEAD = 5
class.RING_TIMER_STOPPER_TAIL = 54

-- ワールドエンド発動までの時間
class.TIME_LIMIT = 5

function class:initTable()

  self.BUFF_BOX_LIST = {
    [0] = {
      ID = 10001,
      BUFF_ID = 17, -- ダメージ
      VALUE = 30,
      DURATION = 999999,
      ICON = 26
    },
    [1] = {
      ID = 10002,
      BUFF_ID = 25, -- ブレイク
      VALUE = 30,
      DURATION = 999999,
      ICON = 9
    }
  }
  self.TARGET_BUFF_BOX_LIST = {
      [0] = {
      ID = 10003,
      BUFF_ID = 17, -- ダメージ
      VALUE = 50,
      DURATION = 999999,
      ICON = 26
    }
  }

  -- ブレイク耐性
  self.BREAK_RESISTANCE_LIST = {
    [0] = {
      ID = 501081,
      BUFF_ID = 27,
      VALUE = 20,
      DURATION = 99999,
      ICON = 0
    },
    [1] = {
      ID = 501081,
      BUFF_ID = 27,
      VALUE = 40,
      DURATION = 99999,
      ICON = 0
    },
    [2] = {
      ID = 501081,
      BUFF_ID = 27,
      VALUE = 80,
      DURATION = 99999,
      ICON = 0
    }
  }

  self.items = {}
-- 105291101　ライトニング
-- 105301101　シルバーレイン
-- 105311101　スタンエッジ
-- 105321101　スモークバード
-- 105331101　ブレイクボム
-- 105341101　ビックバン
-- 105351101　ソードチェイン
-- 105361101　ベリー・ショック
-- 105371101　ソーラーレイ
  self.items[0] = {
    ID = 105291101
  }
  self.items[1] = {
    ID = 105301101
  }
  self.items[2] = {
    ID = 105311101
  }
  self.items[3] = {
    ID = 105321101
  }
  self.items[4] = {
    ID = 105331101
  }
  self.items[5] = {
    ID = 105341101
  }
  self.items[6] = {
    ID = 105351101
  }
  self.items[7] = {
    ID = 105361101
  }
  self.items[8] = {
    ID = 105371101
  }

  self.ITEM_USE_PATTERN_1 = {
    [0] = {INDEX = 0},
    [1] = {INDEX = 1},
    [2] = {INDEX = 2}
  }
  self.ITEM_USE_PATTERN_2 = {
    [0] = {INDEX = 3},
    [1] = {INDEX = 4},
    [2] = {INDEX = 5}
  }
  self.ITEM_USE_PATTERN_3 = {
    [0] = {INDEX = 6},
    [1] = {INDEX = 7},
    [2] = {INDEX = 8}
  }
  self.ITEM_USE_PATTERN_4 = {
    [0] = {INDEX = 0},
    [1] = {INDEX = 2},
    [2] = {INDEX = 3},
    [3] = {INDEX = 5}
    -- [4] = {INDEX = 6},
    -- [5] = {INDEX = 8}
  }
  self.ITEM_USE_PATTERN_5 = {
    [0] = {INDEX = 2},
    [1] = {INDEX = 5},
    [2] = {INDEX = 8}
  }

end

---------------------------------------------------------------------------------
-- start
---------------------------------------------------------------------------------
function class:start(event)
  self.fromHost = false;
  self.spValue = 1;
  self.attackCheckFlg = false;
  self.skillCheckFlg = false;
  self.skillCheckFlg2 = false;
  self.gameUnit = event.unit;
  event.unit:setSPGainValue(0)

  self.useItemIndex = 0
  self.currentUseItemPattern = 0
  self.currentSPValue = 0
  self.SPTimer = 0
  self.takeRingTimer = 0
  self.telopTimer = 1
  self.telopTimerDelay = 30
  self.defaultBuffValue = 30
  self.currentRingInterval = self.RING_SHINE_INTERVAL + LuaUtilities.rand(0,self.RING_SHINE_WEIGHT)

  self.isBreak = false
  self.isTarget = false
  self.initHand = false
  self.isDeadEnd = false
  self.deadEndTimer = 0
  self.isFirstFlame = false

  self:initTable()
  self:setItems(event.unit)

  return 1
end

function class:setBackGround(unit)
  self.back = unit:addOrbitSystemWithFile("50068back_gate","idle");
  self.back:setEndAnimationName("none");
  self.back:takeAnimation(0,"idle",true);
  self.back:setPositionX(unit:getPositionX() + 300);
  self.back:setPositionY(200);
  self.back:setZOrder(3);
end

function class:setHandEffect(unit)
  self.effect = unit:addOrbitSystemWithFile("50068HandEF","idle");
  self.effect:setEndAnimationName("none");
  self.effect:takeAnimation(0,"idle",true);
  self.effect:setPositionX(unit:getPositionX() + 300);
  self.effect:setPositionY(200);
  self.effect:setZOrder(8999);
end

function class:setHand(unit)
  self.hand = unit:addOrbitSystemWithFile("50068hand","idle");
  self.hand:setEndAnimationName("none");
  self.hand:takeAnimation(0,"idle",true);
  self.hand:setPositionX(self.handPart * 100 + unit:getPositionX() - 100);
  self.hand:setPositionY(180);
  self.hand:setHitCountMax(9999);
  self.hand:setZOrder(5000);
  self.hand:setSize(3);
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)

  --セーフティーネット
  if self.isDeadEnd then
    self.deadEndTimer = self.deadEndTimer - event.deltaTime;
    if self.deadEndTimer <= 0 then
      self.isDeadEnd = false;
      self:restart()
    end
  end

  if self.isBreak then
    self.isBreak  = false
    self:complete("regenerating")
  end

  if event.unit:getBurstPoint() < self.currentSPValue then
    event.unit:setBurstPoint(self.currentSPValue)
  end

  event.unit:setPositionX(self.startX)
  event.unit:setPositionY(self.startY)
  self:addSPTimer(event.deltaTime)
  self:takeSkillTimer(event.deltaTime)
  self:checkTelop(event.deltaTime)
  return 1
end

-- 一定時間でSP増加
function class:addSPTimer(deltaTime)
  if self.isDeadEnd then
    return
  end

  if self.SPTimer < 1 then
    self.SPTimer = self.SPTimer + deltaTime
  else
    self:addSP(self.gameUnit)
    self.currentSPValue = self.currentSPValue + 1
    self.SPTimer = self.SPTimer - self.MOVE_INTERVAL
  end
end

-- 一定時間でスキル使用
function class:takeSkillTimer(deltaTime)
  if self.isDeadEnd 
    or self.gameUnit:getBurstPoint() < self.RING_TIMER_STOPPER_HEAD 
    or self.gameUnit:getBurstPoint() > self.RING_TIMER_STOPPER_TAIL 
    or self.gameUnit.m_breaktime > 0 then
      return
  end

  if self.takeRingTimer < self.currentRingInterval then
    self.takeRingTimer = self.takeRingTimer + deltaTime
  else
    self.takeRingTimer = 0
    self.currentRingInterval = self.RING_SHINE_INTERVAL + LuaUtilities.rand(0,self.RING_SHINE_WEIGHT)
    self:rollSkillOrbit(self.gameUnit)
    self.gameUnit:setNextAnimationName("skill1")
  end
end

function class:addSP(unit)
  unit:addSP(self.spValue);
  return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
  if "skill1Complete" == event.spineEvent then 
    self:complete("idle") end
  
  if "skill2Complete" == event.spineEvent then 
    self:complete("idle") 
    self.isDeadEnd = false
  end
  
  if "regeneratComplete" == event.spineEvent then 
    self:complete("idle") end
  
  if "frontComplete" == event.spineEvent then 
    self:complete("idle")  
    self.isStep = true end
  
  if "damageComplete" == event.spineEvent then 
    self:complete("damage_idle") end

  if "deadend" == event.spineEvent then
    self:deadEnd() end

  if  "handInit" == event.spineEvent then
    if not self.initHand then
      self.initHand = true
      self.handPart = self:setHandPartAndSP()
      self.currentUseItemPattern = self.handPart
      self:setBackGround(event.unit)
      self:setHandEffect(event.unit)
      self:setHand(event.unit)
      self:checkBreak(event.unit)
    end
  end

  return 1
end

function class:complete(animationName)
  self.hand:takeAnimation(0,animationName,true)
end

function class:setHandPartAndSP()
  local currentTime = self:setCurrentTime()
  local minute = currentTime / 60
  local second = currentTime % 60
  local handPart = math.floor(minute % 5)
  self.currentSPValue = math.floor(second)

  if handPart >= 1 then
    for k,v in pairs(self.BUFF_BOX_LIST) do
      v.VALUE = self.defaultBuffValue * handPart
    end
    self:addBuff(self.gameUnit,self.BUFF_BOX_LIST)
  end

  self.gameUnit:addSP(second)
  self:showTimeLimit(handPart,second)

  return handPart
end

function class:setCurrentTime()
  if RaidControl:get():getCustomValue("startTime") == nil or RaidControl:get():getCustomValue("startTime") == "" or RaidControl:get():getCustomValue("startTime") == "error" then 
    RaidControl:get():setCustomValue("startTime",""..RaidControl:get():getCurrentRaidTime())
  end
  local currentTime = RaidControl:get():getCurrentRaidTime() - tonumber(RaidControl:get():getCustomValue("startTime"))
  return currentTime < 0 and 0 or currentTime;
end

-- info
function class:showTimeLimit(handPart,second)
  second = second < 1 and 60 or math.floor(second)
  if handPart == 0 then
    summoner.Utility.messageByEnemy(self.TEXT.mess3 .. self.TIME_LIMIT .. self.TEXT.min,5,Color.yellow)
  elseif handPart >= 4 then
    summoner.Utility.messageByEnemy(self.TEXT.mess3 .. (60 - second) ..self.TEXT.sec,5,Color.yellow)
  else
    summoner.Utility.messageByEnemy(self.TEXT.mess3 .. (4 - handPart) .. self.TEXT.min .. (60 - second) ..self.TEXT.sec,5,Color.yellow)  
  end
end

function class:deadEnd()
  -- local i = 0;
  -- for i = 0 , 4 do
  --   local teamunit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i);
  --   if teamunit ~= nil then
  --     teamunit:setHP(0);
  --     teamunit:getTeam():deadUnit(teamunit:getIndex());
  --   end
  -- end
  self:restart()
end

function class:restart()
  self.hand:setPositionX(self.startX - 100)
  self.handPart = 0
  self.useItemIndex = 0
  self.currentUseItemPattern = 0
  self.currentSPValue = 0
  self:removeCondition(self.gameUnit,self.BUFF_BOX_LIST[0].ID)
  self:removeCondition(self.gameUnit,self.BUFF_BOX_LIST[1].ID)
  self:initTable()
end

---------------------------------------------------------------------------------
-- takeBreak
---------------------------------------------------------------------------------
function class:takeBreake(event)
  if self.isDeadEnd then
    self.isDeadEnd = false
    self:restart()
  end
  self.hand:takeAnimation(0,"damage",true)
  self.isBreak = true
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
  return 1
end

function class:attackReroll(unit)
  local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
  local attackIndex = string.gsub(attackStr,"ATTACK","");

  self:execUseItem()

  unit:takeAttack(tonumber(attackIndex));
  megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
  return 0;
end

---------------------------------------------------------------------------------
-- takeSkill
---------------------------------------------------------------------------------
function class:takeSkill(event)
  if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
    self.skillCheckFlg = true;
    return self:skillReroll(event.unit);
  end

  self.skillCheckFlg = false;
  self.skillCheckFlg2 = false;
  self.fromHost = false;
  return 1
end

function class:skillReroll(unit)
  local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
  local skillIndex = string.gsub(skillStr,"SKILL","");

  if skillIndex == "2" then
    skillIndex = "1"
    if self.handPart < 4 then
      self:stepForward()
      unit:setNextAnimationName("skill1")
    else 
      self.isDeadEnd = true
      self.deadEndTimer = 20;
      self:timeOver(unit)
    end
  end
  unit:takeSkill(tonumber(skillIndex));
  megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
  return 0;
end

-- 奥義ランダム実行
function class:rollSkillOrbit(unit)
  local rand = LuaUtilities.rand(0,self:setPoint())
  local index = 0
  local skillEffect = self:choice(rand,index)
  self:execSpecial(unit,skillEffect.ACTIVE_SKILL_NO,skillEffect.ANIMATION_NAME)
end

-- 重み付け
function class:setPoint()
  local totalPoint = 0
  for k,v in pairs(self.RING_EFFECT_LIST) do
    v.POINT = totalPoint
    totalPoint = totalPoint + v.WEIGHT
  end
  return totalPoint
end

-- 奥義選択
function class:choice(rand,index)
  if index > table.maxn(self.RING_EFFECT_LIST) then
    return
  end
  if rand < self.RING_EFFECT_LIST[index].POINT or 
     rand > self.RING_EFFECT_LIST[index].POINT + self.RING_EFFECT_LIST[index].WEIGHT then
      return self:choice(rand,index + 1)
  else
    return self.RING_EFFECT_LIST[index]
  end
end

-- 奥義発動
function class:execSpecial(unit,activeSkillNum,animationName)
  self.hand:takeAnimation(0,"skill1",true)
  local skillOrbit = unit:addOrbitSystemWithFile("50068HandEF",animationName);
  skillOrbit:setPositionX(self.hand:getPositionX());
  skillOrbit:setPositionY(self.hand:getPositionY());
  self.hand:setActiveSkill(activeSkillNum);
  self.hand:showSkillName(activeSkillNum);
end

-- 真奥義発動
function class:timeOver(unit)
  self.currentSPValue = 0
  self.hand:takeAnimation(0,"skill2",true)
  self.hand:setActiveSkill(7);
  self.hand:showSkillName(7);

  local efOrbit = unit:addOrbitSystemWithFile("50068HandEF","skill2");
  efOrbit:setEndAnimationName("none");
  efOrbit:setPositionX(self.hand:getPositionX());
  efOrbit:setPositionY(self.hand:getPositionY());

  local meteorOrbit = unit:addOrbitSystemWithFile("50068HandEF","meteor");
  meteorOrbit:setPositionX(0);
  meteorOrbit:setPositionY(0);
  meteorOrbit:setActiveSkill(7);

  unit:addOrbitSystemCameraWithFile("50068HandEF","rockAndFlush2",false);
end

-- 手の前進
function class:stepForward()
  self.hand:takeAnimation(0,"front",true)
  self.handPart = self.handPart + 1
  self.currentSPValue = 0
  for k,v in pairs(self.BUFF_BOX_LIST) do
    v.VALUE = self.defaultBuffValue * self.handPart
  end
  self:addBuff(self.gameUnit,self.BUFF_BOX_LIST)
  summoner.Utility.messageByEnemy(self.TEXT.mess3 .. (5 - self.handPart) .. self.TEXT.min,5,Color.yellow)
end

---------------------------------------------------------------------------------
-- executeAction
---------------------------------------------------------------------------------
function class:excuteAction(event)
  self:checkTarget()
  self:checkBreak(event.unit)

  return 1
end

-- 被ターゲット判定
function class:checkTarget()
  if not self.isTarget and self:getIsTarget() then
    self:addBuff(self.gameUnit,self.TARGET_BUFF_BOX_LIST)
    summoner.Utility.messageByEnemy(self.TEXT.mess1,5,Color.red);
  end
  if self:getIsTarget() then
    BattleControl:get():showHateAll()
  else
    BattleControl:get():hideHateAll(); 
    self:removeCondition(self.gameUnit,self.TARGET_BUFF_BOX_LIST[0].ID)    
  end
  self.isTarget = self:getIsTarget();
end

function class:getIsTarget()
  return RaidControl:get():getRanking() <= 3 and RaidControl:get():getTotalBattlePoint() > 1000000;
end

--=====================================================================================================
--アイテム使用関連のメソッド
function class:setItems(unit)
  for i = 0,table.maxn(self.items) do
    unit:setItemSkill(i,self.items[i].ID);
  end
end

function class:useItem(unit,index)
  if self.isDeadEnd then
    return
  end

  if self.gameUnit.m_breaktime <= 0 then
    unit:takeItemSkill(index);
  end
end

function class:execUseItem()
  if self.currentUseItemPattern ~= self.handPart then
    self.currentUseItemPattern = self.handPart
    self.useItemIndex = 0
  end

  local useItemTable = self:selectUseItemPattern()
  self:useItem(self.gameUnit,useItemTable[self.useItemIndex].INDEX)

  if self.useItemIndex < table.maxn(useItemTable) then
    self.useItemIndex = self.useItemIndex + 1
  else
    self.useItemIndex = 0
  end
end

function class:selectUseItemPattern()
  if self.handPart == 0 then
    return self.ITEM_USE_PATTERN_1
  end
  if self.handPart == 1 then
    return self.ITEM_USE_PATTERN_2
  end
  if self.handPart == 2 then
    return self.ITEM_USE_PATTERN_3
  end
  if self.handPart == 3 then
    return self.ITEM_USE_PATTERN_4
  end
  if self.handPart == 4 then
    return self.ITEM_USE_PATTERN_5
  end

end



--==============================================================================================================
--レイド特有のギミック周り/
--////////////////////
function class:checkTelop(deltatime)
    if RaidControl:get() == nil then
        return;
    end

    --テロップ表示のチェック
    self.telopTimer = self.telopTimer - deltatime;
    if self.telopTimer < 0 then
        self.telopTimer = self.telopTimerDelay;                
        local rand = LuaUtilities.rand(0,4)
        if rand == 0 then
            if self.isTarget then
                RaidControl:get():addPauseMessage(self.TEXT.telop3 , 2.2);
            else
                RaidControl:get():addPauseMessage(self.TEXT.telop1 , 2.2);
            end
        elseif rand == 1 then
            RaidControl:get():addPauseMessage(self.TEXT.telop2 , 2.2);
        elseif rand == 2 then
            RaidControl:get():addPauseMessage(self.TEXT.telop5 , 2.2);
        elseif rand == 3 then
            RaidControl:get():addPauseMessage(self.TEXT.telop6 , 2.2);
        end
    end
end


function class:checkBreak(unit)
  if not megast.Battle:getInstance():isRaid() then
    return;
  end

  if RaidControl:get():getRaidBreakCount() >= 1 then
    self:addBuff(unit,self.BREAK_RESISTANCE_LIST,0)
  end
  if RaidControl:get():getRaidBreakCount() >= 2 then
    self:addBuff(unit,self.BREAK_RESISTANCE_LIST,1)
  end
  if RaidControl:get():getRaidBreakCount() >= 3 then
    self:addBuff(unit,self.BREAK_RESISTANCE_LIST,2)
  end
end

--=====================================================================================================
--バフ

-- バフの指定実行。indexがない時はバフボックスの中身を全部実行
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

-- バフ削除
function class:removeCondition(unit,buffId)
  if unit:getTeamUnitCondition():findConditionWithID(buffId) ~= nil then
    unit:getTeamUnitCondition():removeCondition(unit:getTeamUnitCondition():findConditionWithID(buffId))
  end  
end

class:publish();

return class;