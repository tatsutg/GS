local Bootstrap, Color, Random, Utility, Vector2 = summoner.import("Bootstrap", "Color", "Random", "Utility", "Vector2")
local class = summoner.Bootstrap.createUnitClass({label="ラグシェルム", version=1.3, id=501621513});
class:inheritFromUnit("unitBossBase");


--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {

    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50,
    ATTACK5 = 50
    -- ATTACK6 = 50
}

class.ATTACK_REEL = {
   [1] = {
      ATTACK1 = 100
   },
   [2] = {
      ATTACK5 = 100
   },
   [3] = {
      ATTACK3 = 100
   },
   [4] = {
      ATTACK1 = 100,
      ATTACK2 = 100,
      ATTACK4 = 100
   },
   [5] = {
      ATTACK1 = 100,
      ATTACK2 = 100,
      ATTACK4 = 100
   }
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 1,
    ATTACK7 = 1,
    SKILL1 = 6,
    SKILL2 = 7
}

class.TELOP_SPAN = 30
class.MAX_DOWN_DURATION = 20;
class.BATTLE_POINT_VALUE_FIXED = 50000;

--------[[create]]--------
function class:createTable()
   self.glabEffect = {
      orbitSystem = nil,
      position = nil
   }
end



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
        ID = -5014110,
        EFID = 15, --防御力
        VALUE = -15,
        DURATION = 22,
        ICON = 6
      },
      [2] = {
        ID = -5014111,
        EFID = 13, --攻撃力
        VALUE = -15,
        DURATION = 22,
        ICON = 4
      }
  }

  self.TARGET_BUFF_BOX_LIST = {
       [1] = {
        ID = 501419,
        EFID = 17, -- ダメージ
        VALUE = 30,
        DURATION = 999999,
        ICON = 26
      }
  }

end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   self.START_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "人族キラー・庇うキラー",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false
      },
      [2] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "攻撃力アップ",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false
      },
      [3] = {
         MESSAGE = self.TEXT.START_MESSAGE1 or "気絶状態で攻撃力・防御力低下",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false
      }
   }

    self.OGI_MESSAGE_LIST = {
        [1] = {
            MESSAGE = self.TEXT.OGI_MESSAGE1 or "これは……怒り……！",
            COLOR = Color.magenta,
            DURATION = 7.5,
            isPlayer = false
        },
        [2] = {
            MESSAGE = self.TEXT.OGI_MESSAGE2 or "魂が……力を求めている！",
            COLOR = Color.magenta,
            DURATION = 7.5,
            isPlayer = false
        }
    }

   self.FREEZE_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.FREEZE_MESSAGE1 or "気絶状態で攻撃力・防御力低下",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false
      }
   }

   self.FREEZE_MESSAGE_LIST2 = {
      [1] = {
         MESSAGE = self.TEXT.FREEZE_MESSAGE2 or "さんが気絶させて攻撃力・防御力低下",
         COLOR = Color.yellow,
         DURATION = 10,
         isPlayer = false
      }
   }


    -- レイドメッセージ
    self.RAID_MESSAGES = {
        {
            MESSAGE = self.TEXT.mess1 or "ボスに狙われている！",
            COLOR = Color.red,
            DURATION = 10
        }        
    }

  -- テロップ
  self.mes_telop1 = self.TEXT.telop1 or "ボスに狙われると被ダメージが増加します。"
  self.mes_telop2 = self.TEXT.telop2 or "ユニットが倒れた時は、入れ替えて戦いましょう。"
  self.mes_telop3 = self.TEXT.telop3 or "ランキングの結果によって、撃破時の報酬の個数が変化します。"
end


function class:subBars()
   self.subBar = BattleControl:get():createSubBar();
   self.subBar:setWidth(200); --バーの全体の長さを指定
   self.subBar:setHeight(13);
   self.subBar:setPercent(0); --バーの残量を0%に指定
   self.subBar:setVisible(false);
   self.subBar:setPositionX(0);
   self.subBar:setPositionY(150);
end

--------[[特殊行動]]--------
function class:setTriggersList()
   self.HP_FLG = "HP_FLG"
   self.HP_50 = 1
   self.HP_25 = 2

   self.TRIGGERS = {

   }
   self.HP_TRIGGERS = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.HP_TRIGGERS[index] = trigger
      end
   end
end



function class:tryGlab(unit)
   local index = self:hpMostFew();
   self:executeGlab(unit,index)
end


--HP実数値が最も低いユニットを対象に取る（常にpositive）
function class:hpMostFew()
    local targetHP = 99999999;
    local targetIndex = 0;
    for i=0,3 do
        local targetUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if targetUnit ~= nil then
          local hp = targetUnit:getHP();

            if hp <= targetHP then
                targetIndex = targetUnit:getIndex();
                targetHP = hp;
            end
            
        end
    end
    
     return targetIndex;
end

function class:executeGlab(unit,index)
   self.glabTarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(index)
   if self.glabTarget == nil then
      return
   end

   -- unit:getTeamUnitCondition():addCondition(-11,113,500,2000,0);
   self.isGlab = true;
   -- 【MEGA_D-9761】掴んでいる間（DPS チェック）に、失敗すると撃つトゥルーナイトメア（SKILL2 = 7・skill2）を溜め予告で知らせる。
   -- ホストもゲストも通る。解放できれば「技が止まった」消え方、失敗すれば技名で奥義予告に替わる。古いアプリには無いので確かめてから呼ぶ
   if unit.announceSkill then unit:announceSkill(self.ACTIVE_SKILLS.SKILL2, "skill2") end
   self.glabEffect.orbitSystem = unit:addOrbitSystem("lock-on");
   self.glabEffect.orbitSystem:takeAnimation(0,"lock-on",true);
   self.glabEffect.position = Vector2:new(self.glabTarget:getAnimationPositionX(),self.glabTarget:getAnimationPositionY())
   self.glabEffect.orbitSystem:setPosition(self.glabEffect.position.x,self.glabEffect.position.y);
   self.glabTarget:getTeamUnitCondition():addCondition(-10,89,1,35,0);
end

function class:glabEnd(unit)
   if not self.isGlab then
      return
   end

   if self.glabTarget ~= nil then
      self:removeCondition(self.glabTarget,-10)
      self.glabTarget = nil
   end
   -- self:removeCondition(unit,-11)
   self.dpsCounter = 0
   self.isGlab = false
   if self.glabEffect ~= nil then
      self.glabEffect.orbitSystem:takeAnimation(0,"none",false)
      self.glabEffect.orbitSystem = nil
   end
end

function class:glabControll(unit,deltaTime)
   if self.glabTarget ~= nil then
      local x = 150 + unit:getPositionX();
      local y = 464 + unit:getPositionY();
      local distance = Vector2.subtracts(Vector2:new(x,y),self.glabEffect.position)

      if self.SPEED * deltaTime >= math.abs(distance.magnitude) then
         self.glabEffect.position = self.glabEffect.position + distance
      else
         self.glabEffect.position = self.glabEffect.position + (distance:normalize() * self.SPEED * deltaTime)
      end

      
      self.glabEffect.orbitSystem:setPosition(self.glabEffect.position.x,self.glabEffect.position.y);
      self.glabTarget:setPosition(self.glabEffect.position.x - self.glabTarget:getSkeleton():getBoneWorldPositionX("MAIN"),self.glabTarget:getPositionY());
      self.glabTarget:getSkeleton():setPosition(0,self.glabEffect.position.y - self.glabTarget:getPositionY() - self.glabTarget:getSkeleton():getBoneWorldPositionY("MAIN"));

   end
end

function class:setSP0(unit)
   unit:setBurstPoint(0)
   self.isDPSCheck  = true
   self.dpsStartHP = unit:getHP()
   self.subBar:setVisible(false)
    self:execShowMessage(self.OGI_MESSAGE_LIST[2])
end

function class:removeCondition(unit,buffID)
   local buff = unit:getTeamUnitCondition():findConditionWithID(buffID);
   if buff ~= nil then
      unit:getTeamUnitCondition():removeCondition(buff);
   end
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
   self.attackCounter = 0;
   self.skillCounter = 0;
   self.telopTimer = 0;
   self.downTimer = 0;
   self.freezeActTime = 0;

   self:createTable()
   self:setTriggersList()
   self:setBuffBoxList()
   self:setMessageBoxList()
   self:subBars()
   self.hitStop = 0.5
   self.isGlab = false
   self.isDPSCheck = false
   self.glabTarget = nil
   self.dpsStartHP = 0
   self.dpsCounter = 0
   self.damageParSecond = 29000
   self.SPEED = 300
   self.hateTargetRate = 1.4

   event.unit:setAttackDelay(4.7);
   return 1
end

---------------------------------------------------------------------------------
-- startWave
---------------------------------------------------------------------------------
function class:startWave(event)
   -- BattleControl:get():visibleHateTarget(true);
   -- BattleControl:get():setHateTargetIcon(14);
   self:takeInitGet(event.unit);
   self:showMessage(self.START_MESSAGE_LIST)
   -- event.unit:setEnableHate(true);
   -- event.unit:updateHateTarget();
   return 1
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "addSP" then self:addSP(event.unit) end
   if event.spineEvent == "tryGlab" then self:tryGlab(event.unit) end
   if event.spineEvent == "glabEnd" then 
      if self.glabTarget ~= nil then
         self.glabTarget:setBurstPoint(0);
      end
      self:glabEnd(event.unit) 
   end
   if event.spineEvent == "setSP0" then self:setSP0(event.unit) end

   return 1
end

---------------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------------
function class:update(event)
    event.unit:setReduceHitStop(200,1)

   self:telop(event.deltaTime)
   if self.isDown then
     self:countDownDownDuration(event.unit,event.deltaTime);
   end
   self:fetchFreezeActTime(event.unit);
   self:checkFreeze(event.unit);   
   self:checkDown(event.unit);

   self:HPTriggersCheck(event.unit)

   if self.isGlab then
      self:glabControll(event.unit,event.deltaTime);
   end

   if self.isDPSCheck then
      self:dpsChecker(event.unit)
   end
   return 1
end

function class:dpsChecker(unit)
   -- self.dpsCounter = self.dpsStartHP - unit:getHP()
   -- if self.dpsCounter >= self.damageParSecond then
   --    self.dpsCounter = 0
   --    unit:takeDamage()
   -- end

   -- self.subBar:setPositionX(unit:getPositionX())
   -- self.subBar:setPositionY(unit:getPositionY() + 250)
   -- self.subBar:setPercent(100 * 
   --    (self.damageParSecond - self.dpsCounter) / self.damageParSecond)

end

---------------------------------------------------------------------------------
-- takeDamage
---------------------------------------------------------------------------------
function class:takeDamage(event)
   if self.isGlab then

      self:glabEnd(event.unit)
   end
   if self.isDPSCheck then
      self.isDPSCheck = false
      self.dpsCounter = 0
      self.subBar:setVisible(false)
   end

   return 1
end
---------------------------------------------------------------------------------
-- takeDamageValue
---------------------------------------------------------------------------------
function class:takeDamageValue(event)
   if self.isDPSCheck then
      self.dpsCounter = self.dpsStartHP - event.unit:getHP()
      if self.dpsCounter >= self.damageParSecond then
         event.unit:takeDamage()
      end
   end
   return event.value
end

---------------------------------------------------------------------------------
-- attackDamageValue
---------------------------------------------------------------------------------
function class:attackDamageValue(event)

   return event.value
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
-- takeAttack
---------------------------------------------------------------------------------
function class:takeAttack(event)
   if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
      self.attackCheckFlg = true;
      return self:attackReroll(event.unit);
   end

   self.attackCheckFlg = false;
   self.fromHost = false;
   self:attackActiveSkillSetter(event.unit,event.index);
    if event.index == 3 then
        self:execShowMessage(self.OGI_MESSAGE_LIST[1])
    end
   return 1
end

function class:attackReroll(unit)
   local attackStr = summoner.Random.sampleWeighted(self.ATTACK_REEL[self.attackCounter % table.maxn(self.ATTACK_REEL) + 1]);
   local attackIndex = string.gsub(attackStr,"ATTACK","");
   self.attackCounter = self.attackCounter + 1;

   if self.isRage then
      self.isRage = false
      attackIndex = 7
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
   self.isDPSCheck = false
   self.subBar:setVisible(false)

   if not megast.Battle:getInstance():isHost() and not self.fromHost then
      event.unit:takeIdle();
   return 0;
   end

   self.skillCheckFlg = false;
   -- self.skillCheckFlg2 = false;
   self.fromHost = false;
   self.attackCounter = 0;
   if event.index == 1 then
      
      self.skillCounter = self.skillCounter + 1;
      if self.skillCounter % 3 == 2 then
         self.isRage = true;
      end
   end
   self:skillActiveSkillSetter(event.unit,event.index);
   return 1
end

function class:skillReroll(unit)
   local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
   local skillIndex = string.gsub(skillStr,"SKILL","");

   if self.isGlab then
      skillIndex = 2
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
  
end

function class:downEnd(unit)
  self.isDown = false;
  self.downTimer = 0;
  -- self:removeBuffs(unit,self.DOWN_BUFF_BOX_LIST);今回はバフが重複するので自然に剥がれるのを待つことにした
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

--===================================================================================================================
--気絶チェック
--===================================================================================================================

function class:checkFreeze(unit)
    local freeze = unit:getTeamUnitCondition():findConditionWithType(89);
    if freeze ~= nil and not self.beforeFreeze then
        self.beforeFreeze = true;
        self:addDownTime(unit);

        local playerName = BattleControl:get():getPlayerName();

        local freezeMessageWithPlayerName = {
            [1] = {
               MESSAGE = playerName..self.FREEZE_MESSAGE_LIST2[1].MESSAGE,
               COLOR = Color.yellow,
               DURATION = 10,
               isPlayer = false
            }
        }


        self:showMessage(freezeMessageWithPlayerName);
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
    self:addBuff(unit,self.DOWN_BUFF_BOX_LIST);
end



function class:checkDown(unit)

    if self.downTimer > 0 and not self.isDown then
        self:takeDown(unit);
    end
end

function class:calcPoint(unit)
    -- local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
    -- local rate = 100 - hpRate;
    local result = self.BATTLE_POINT_VALUE_FIXED;
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
    --持ってくる前に今気絶が入った事実をまず自分の中で保持
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


    local tempActTime = tonumber(RaidControl:get():getCustomValue("freezeActTime"));
    
    if tempActTime ~= "" and tempActTime ~= "error" and tempActTime ~= nil then
        -- summoner.Utility.messageByEnemy(""..tempActTime,5,summoner.Color.red);
    else
        --summoner.Utility.messageByEnemy("ない"..self.freezeActTime,5,summoner.Color.red);  
        return;
    end


    tempActTime = math.floor(tempActTime);


    if tempActTime > self.freezeActTime then
        -- summoner.Utility.messageByEnemy(""..self.freezeActTime);
        self:setFreezeActTime(tempActTime);
        local playerNameByteCode = RaidControl:get():getCustomValue("playerName");
        local playerName = self:toUnicode(playerNameByteCode);

        -- summoner.Utility.messageByEnemy("他人気絶"..self.freezeActTime,15,summoner.Color.red);
        local freezeMessageWithPlayerName = {
            [1] = {
               MESSAGE = playerName..self.FREEZE_MESSAGE_LIST2[1].MESSAGE,
               COLOR = Color.yellow,
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