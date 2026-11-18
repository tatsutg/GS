--@additionalEnemy,600000046,600000047,600000048,600000049,600000050,600000051,600000052
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="レイドカボシェルム", version=1.3, id=501461513});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 10,
    ATTACK2 = 20,
    ATTACK3 = 25,
    ATTACK4 = 20,
    ATTACK5 = 25
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
    ATTACK6 = 7,                    
    SKILL1 = 6
}

class.SUMMON_WAITS = {
    [600000046] = 100,
    [600000047] = 100,
    [600000048] = 100,
    [600000049] = 100,
    [600000050] = 100,
    [600000051] = 100,
    [600000052] = 100
}

class.TELOP_SPAN = 30;
class.BATTLE_POINT_VALUE = 10000;
class.BATTLE_POINT_VALUE_FIXED = 200000;
class.RAID_BOSS_RATE = 1.75;
class.COMBO_CHAIN_DURATION = 13;
class.skill2FixedDamage = 200;
class.SUMMON_RATE_ADDITION = 3;
class.SUMMON_RATE_REDUCE = 15;

function class:setBuffBoxList()
   -- self.HP_50_Buff = {
   --    [1] = {
   --       ID = 501411,
   --       EFID = 17, -- 攻撃
   --       VALUE = 50,
   --       DURATION = 99999,
   --       ICON = 26
   --    },
   --    [2] = {
   --       ID = 501414,
   --       EFID = 28, -- 行動速度
   --       VALUE = 25,
   --       DURATION = 99999,
   --       ICON = 7
   --    }
   -- }

   -- self.HP_20_Buff = {
   --    [1] = {
   --       ID = 501413,
   --       EFID = 9, -- ゲージ加速
   --       VALUE = 50,
   --       DURATION = 99999,
   --       ICON = 36
   --    }
   -- }



  self.TARGET_BUFF_BOX_LIST = {
       [1] = {
        ID = 501419,
        EFID = 17, -- ダメージ
        VALUE = 50,
        DURATION = 999999,
        ICON = 26
      }
  }

end

--------[[メッセージ]]--------
function class:setMessageBoxList()
   -- self.START_MESSAGE_LIST = {
   --    [1] = {
   --       MESSAGE = self.TEXT.START_MESSAGE1 or "状態異常中のボスへのダメージがアップ",
   --       COLOR = Color.red,
   --       DURATION = 10,
   --       isPlayer = false        
   --    },
   --    [2] = {
   --       MESSAGE = self.TEXT.START_MESSAGE2 or "庇うキラー",
   --       COLOR = Color.red,
   --       DURATION = 10,
   --       isPlayer = false        
   --    },
   --    [3] = {
   --       MESSAGE = self.TEXT.START_MESSAGE3 or "命中率・攻撃力アップ",
   --       COLOR = Color.red,
   --       DURATION = 10,
   --       isPlayer = false        
   --    },
   --    [4] = {
   --       MESSAGE = self.TEXT.START_MESSAGE4 or "子分：燃焼時以外ダメージ無効",
   --       COLOR = Color.red,
   --       DURATION = 10,
   --       isPlayer = false        
   --    }
   -- }

   -- self.HP_TRIGGER_MESSAGE_LIST1 = {
   --    [1] = {
   --       MESSAGE = self.TEXT.HP_MESSAGE1 or "与ダメージアップ",
   --       COLOR = Color.red,
   --       DURATION = 10,
   --       isPlayer = false
   --    },
   --    [2] = {
   --       MESSAGE = self.TEXT.HP_MESSAGE2 or "行動速度アップ",
   --       COLOR = Color.red,
   --       DURATION = 10,
   --       isPlayer = false
   --    }
   -- }

   -- self.HP_TRIGGER_MESSAGE_LIST2 = {
   --    [1] = {
   --       MESSAGE = self.TEXT.HP_MESSAGE3 or "奥義ゲージ増加速度アップ",
   --       COLOR = Color.red,
   --       DURATION = 10,
   --       isPlayer = false
   --    }
   -- }




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
            HP = 90,
            trigger = "HP90",
            isActive = true
        },
        [2] = {
            HP = 50,
            trigger = "HP50",
            isActive = true
        },
        [3] = {
            HP = 20,
            trigger = "HP20",
            isActive = true
        }
    }
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
   self.summonRate = 25;


   self.telopTimer = 0

   self.hitStop = 0
   self:setMessageBoxList()
   self:setTriggerList()
   self:setBuffBoxList()

   self.stackBuffList = {}
   self.stackMessageList = {}
   self:setUpKabochaCounts(event.unit);
   -- self:showMessage(self.START_MESSAGE_LIST)
   -- self:addBuff(self.gameUnit,self.BUFF_BOX_LIST)
   return 1
end

function class:setUpKabochaCounts(unit)

   unit:setParameter("501471113","0");
   unit:setParameter("501471213","0");
   unit:setParameter("501471313","0");
   unit:setParameter("501471413","0");
   unit:setParameter("501471513","0");
   unit:setParameter("501472413","0");
   unit:setParameter("501472013","0");
end

function class:startWave(event)
  
   -- self:showMessage(self.START_MESSAGE_LIST);
   return 1;
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
  self:checkTarget()
  self.absorbFlg = false;
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
   self:clearCheck(event.unit,event.deltaTime);


     


   self:telop(event.deltaTime)

   self:deadCheck(event.unit,event.deltaTime);

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
   self:summon(event.unit,1);

   return 1
end

function class:attackReroll(unit)
  local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
  local attackIndex = string.gsub(attackStr,"ATTACK","");

  if self.forceAttackIndex ~= 0 then
      attackIndex = self.forceAttackIndex;
      self.forceAttackIndex = 0;
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

    if event.index == 2 then
        self.absorbFlg = true;
    end
   self.skillCheckFlg = false;
   self.skillCheckFlg2 = false;
   self.fromHost = false;
   self:summon(event.unit,1);
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


--バトルに入った時に、既に過ぎ去ったトリガーは処分する
function class:HPTriggersInitCheck(unit)

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do
        
        if v.HP > hpRate and v.isActive then
            v.isActive = false;
        end
    end
end


function class:HPTriggersCheck(unit)

   if not self.isInitCheck then
         self:HPTriggersInitCheck(unit);
         self.isInitCheck = true;
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
    if trigger == "HP90" then
         self:HP90(unit);
        return true;
    end

    if trigger == "HP50" then
         self:HP50(unit);
        return true;
    end

    if trigger == "HP20" then
         self:HP20(unit);
        return true;
    end

    return false;
end

function class:HP90(unit)
  self.forceAttackIndex = 6;
   -- self:addBuff(unit,self.HP_50_Buff);
   -- self:showMessage(self.HP_TRIGGER_MESSAGE_LIST1);
end


function class:HP50(unit)
  self.forceAttackIndex = 6;
   -- self:addBuff(unit,self.HP_50_Buff);
   -- self:showMessage(self.HP_TRIGGER_MESSAGE_LIST1);
end

function class:HP20(unit)
  self.forceAttackIndex = 6;
   -- self:addBuff(unit,self.HP_20_Buff);
   -- self:showMessage(self.HP_TRIGGER_MESSAGE_LIST2);
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end


function class:summon(unit,num)
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
         local uni = unit:getTeam():addUnit(i,summoner.Random.sampleWeighted(self.SUMMON_WAITS));--指定したインデックスの位置に指定したエネミーIDのユニットを出す
         uni:setParameter("kabocha_index",""..self.totalSummonCnt);
         uni:setParameter("raid_rate",""..self.RAID_BOSS_RATE);
         self.totalSummonCnt = self.totalSummonCnt + 1;
         self.summonedIndex[i] = true;
         summonedCount = summonedCount + 1;
         if summonedCount >= num then
            break;
         end
      end
   end
   self.delaySummonIndexes = {};
end




--===================================================================================================================
--撃破チェック
--===================================================================================================================


function class:deadCheck(unit,deltaTime)

    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
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

   if self.forceClearTimer >= 5 then
      megast.Battle:getInstance():waveEnd(true);
      self.isClear = true;
   end


   return 1;
end





class:publish();

return class;
