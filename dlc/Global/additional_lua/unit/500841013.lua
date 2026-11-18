local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createUnitClass({label="", version=1.3, id=500841013});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50
    -- ATTACK5 = 10,
    -- ATTACK6 = 10,
    -- ATTACK7 = 10,
    -- ATTACK8 = 10,
    -- ATTACK9 = 10,
    -- ATTACK10 = 10,
    -- ATTACK11 = 10,
    -- ATTACK12 = 10
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
    ATTACK6 = 6,
    ATTACK7 = 7,
    ATTACK8 = 8,
    ATTACK9 = 9,
    ATTACK10 = 10,
    ATTACK11 = 11,
    ATTACK12 = 12,
    SKILL1 = 13,
    SKILL2 = 14,
    SKILL3 = 15
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    
     ID = 40075, 
     EFID = 28,         --行動速度アップ
     VALUE = 30,        --効果量
     DURATION = 9999999,
     ICON = 7

}
class.FURY_BUFF_ARGS = {

     ID = 40076,
     EFID = 17,         --ダメージアップ
     VALUE = 30,        --効果量
     DURATION = 9999999,
     ICON = 26

}

-- 掴み時に対象にかかるバフ内容
class.GLAB_TARGET_BUFF_ARGS = {
    {
        ID = -10,
        EFID = 89,
        VALUE = 1,
        DURATION = 14,
        ICON = 0
    }
}


class.BUFF_VALUE = 30;
class.INTERVAL = 20
class.LIMIT = 10


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.isFury = false
    self.glabIndex = nil;
    self.isSpecial = false
    self.timer = 0
    self.isDead = false
    self.skillCTTargetRace = 0;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [0] = {
            HP = 50,
            trigger = "getRage",
            isActive = true
        },
        [1] = {
            HP = 20,
            trigger = "getFury",
            isActive = true
        }
    }
    self.hpMarkers = {
        [0] = {
            HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
        },
        [1] = {
            HP = 20,isUsed = false,MARKER = event.unit:addNumHpMarker(0.2)
        },
        [2] = {
            HP = 0,isUsed = false,MARKER = event.unit:addNumHpMarker(0)
        }
    }


    --怒り時のメッセージ
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "攻撃力・命中率アップ",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "庇うキラー",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }



    self.RAGE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "行動速度アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.RAGE_MESSAGES2 = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE2 or "与ダメージアップ",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.RACE_LIST = {
       [1] = {attack = 12,value = 0,name = self.TEXT.RACE1 or "人"},  
       [2] = {attack = 7,value = 0,name = self.TEXT.RACE2 or "獣"},  
       [3] = {attack = 10,value = 0,name = self.TEXT.RACE3 or "精霊"},  
       [4] = {attack = 6,value = 0,name = self.TEXT.RACE4 or "巨人"},  
       [5] = {attack = 11,value = 0,name = self.TEXT.RACE5 or "機"},  
       [6] = {attack = 5,value = 0,name = self.TEXT.RACE6 or "竜"},  
       [7] = {attack = 9,value = 0,name = self.TEXT.RACE7 or "神"},  
       [8] = {attack = 8,value = 0,name = self.TEXT.RACE8 or "魔"}
    }
    self.SPECIAL_MESSAGE1 = self.TEXT.SPECLAI1 or "族の奥義ゲージ増加速度ダウン"
    self.SPECIAL_MESSAGE2 = self.TEXT.SPECLAI2 or "族のスキルCTダウン"
    
    self.current_race = {attack = 12,value = 0,name = self.TEXT.RACE1 or "人",raceID = 1}

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:run(event)
    if event.spineEvent == "glabStart" then return self:tryGlab(event.unit); end
    if event.spineEvent == "glabEnd" then return self:glabEnd(event.unit); end
    if event.spineEvent == "addSP" then self:addSP(event.unit); end
    
    return 1;
end

function class:startWave(event)
    self:showMessage(self.START_MESSAGES);
    return 1;
end

function class:update(event)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
      return 1;
    end
    event.unit:setReduceHitStop(2,1)
    self:HPTriggersCheck(event.unit);
    self:updateSpecial(event.deltaTime)
    self:upadteDead(event.unit,event.deltaTime)
    self:updateGlab(event.unit,event.deltaTime);
    for _,marker in pairs(self.hpMarkers) do
        local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
        if not marker.isUsed and hpPercent < marker.HP then
            marker.isUsed = true
            event.unit:removeHpMarker(marker.MARKER)
        end
    end
    return 1;
end
function class:dead(event)
  if not self.isDead then
    self:execDead(event.unit)
    megast.Battle:getInstance():sendEventToLua(self.scriptID,6,1);
    return 0
  end
  if self.LIMIT > 0 then
    event.unit:setHP(1)
    return 0
  end
  return 1
end

function class:takeDamageValue(event)
   local parent = event.enemy:getParentTeamUnit();
   local race = parent ~= nil and parent:getRaceType() or event.enemy:getRaceType()
   if race <=0 or race > #self.RACE_LIST then return event.value end
   self.RACE_LIST[race].value = self.RACE_LIST[race].value + event.value
   if self.current_race.value < self.RACE_LIST[race].value then
      self.current_race = self.RACE_LIST[race]
      self.current_race.raceID = race;
   end
   return event.value
end

function class:takeDamage(event)
    self:glabEnd(event.unit);
    return 1;
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    
    if self.isSpecial then
        
        attackIndex = self.current_race.attack
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,self.current_race.raceID);
        self:setRace(self.current_race.raceID);

        
    end

    unit:takeAttack(tonumber(attackIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:setRace(race)
  self.isSpecial = false
   self.skillCTTargetRace = race;
   self:showSpecialMessage(self.RACE_LIST[race].name);
   self:initSpecial()
end

function class:showSpecialMessage(raceName)
    if raceName == nil then return end
    self:execShowMessage({MESSAGE = raceName..self.SPECIAL_MESSAGE1,DURATION = 8,COLOR = Color.yellow})
    self:execShowMessage({MESSAGE = raceName..self.SPECIAL_MESSAGE2,DURATION = 8,COLOR = Color.yellow})
end

function class:takeAttack(event)

    if not self.attackCheckFlg and megast.Battle:getInstance():isHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
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

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if self.isRage then 
        self.isRage = false
        skillIndex = 2
    end

    if self.isFury then
        self.isFury = false
        skillIndex = 3
    end

    unit:takeSkill(tonumber(skillIndex));
    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    return 0;
end


function class:takeSkill(event)
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
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
    self:glabEnd(event.unit);
    return 1
end




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
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
    if trigger == "getRage" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    if trigger == "getFury" then
         self:getFury(unit)
         megast.Battle:getInstance():sendEventToLua(self.scriptID,7,0);
      return true
    end
    return false;
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self.isRage = true;
    self:addBuff(unit,self.RAGE_BUFF_ARGS)
    unit:addSP(100)
    self:showMessage(self.RAGE_MESSAGES);
end
function class:getFury(unit)
    self:addBuff(unit,self.FURY_BUFF_ARGS)
    self:showMessage(self.RAGE_MESSAGES2);
end


function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
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
-- バフ、デバフ追加系
--[[
addBuffs(<event.unit> unit,<table> buffs)
   unit :
      必須。バフを与える対象
   buffs :
      必須。以下のようなバフ用の配列を用意して投げる
      RAGE_BUFFS = {
         {
            <number> ID = 必須。一意のID
            <number> EFID = 必須。バフの効果ID。IDの一覧はDBテーブル定義.スキル効果マスタ参照
            <number> VALUE = 必須。バフ効果量
            <number> DURATION = 必須。持続時間
            <number> ICON = 必須。アイコンID。IDの一覧は企画*多部署連携用シート.バフ・デバフアイコン参照
            <number> EFFECT = 任意。エフェクトID。IDの一覧は企画*多部署連携用シート.スキル効果アニメーション参照
            <number> SCRIPT = 任意。skill_effect内の関数用ID。IDの一覧はDBテーブル定義.スキル効果マスタ参照
            <number> SCRIPTVALUE1 = 任意。skill_effectの第一引数の値
         }
      }
]]
function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
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

function class:addBuff(unit,args)
    local buff  = nil;
    if args.EFFECT ~= nil then
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        buff = unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
    if args.SCRIPT ~= nil then
        buff:setScriptID(args.SCRIPT);
    end
    if args.SCRIPTVALUE1 ~= nil then
        buff:setValue1(args.SCRIPTVALUE1);
    end

end

--=====================================================================================================================================
function class:updateSpecial(deltaTime)
   if not self.isSpecial then
      if self.timer < self.INTERVAL then
         self.timer = self.timer + deltaTime
         for i=0,4 do
           local target = self:getPlayerUnit(i);
           if target ~= nil and target:getRaceType() == self.skillCTTargetRace then
              target:resetSkillCoolTime();
           end
         end
      else
         self.isSpecial = true
         self.skillCTTargetRace = 0;
      end
   end
end

function class:initSpecial()
   if not self.RACE_LIST then return end
   for i,v in ipairs(self.RACE_LIST) do self.RACE_LIST[i].value = 0 end
   self.isSpecial = false
   self.timer = 0
   self.current_race.value = 0
end

--=====================================================================================================================================
function class:upadteDead(unit,deltaTime)
  if self.isDead then
    unit:setReduceHitStop(999,1)
    self.LIMIT = self.LIMIT - deltaTime
    if self.LIMIT < 0 then
      unit:setHP(0)
    else
      unit:setHP(1)
    end
  end
end

function class:execDead(unit)
  self.isDead = true
  self.isFury = true
  unit:setHP(1)
  unit:setInvincibleTime(self.LIMIT)
  self:removeAllBadstatus(unit)
  unit:takeIdle()
  unit:addSP(100)
    unit:removeHpMarker(self.hpMarkers[2].MARKER)
end

function class:removeAllBadstatus(unit)
  local badStatusIDs = {89,91,96};
  for i=1,table.maxn(badStatusIDs) do
    local targetID = badStatusIDs[i];
    local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
    while flag do
      local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
      if cond ~= nil then
        unit:getTeamUnitCondition():removeCondition(cond);
      else
        flag = false;
      end
    end
  end
end

--=====================================================================================================================================

function class:tryGlab(unit)
    if not self:getIsHost() then
        return 1;
    end

    local targetList = {}

    for i=0,4 do
        local temp = self:getPlayerUnit(i);
        if temp ~= nil then
            table.insert(targetList,i);
        end
    end

    local targetIndex = Random.sample(targetList);

    if targetIndex ~= nil then
        self:execGlab(unit,targetIndex);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,targetIndex);
    end
    return 1;
end

function class:glabEnd(unit)
    if self.glabIndex == nil then
        return 1;
    end

    local target = self:getPlayerUnit(self.glabIndex);
    if target == nil then
        self.glabIndex = nil;
        return 1;
    end

    self:removeBuffs(target,self.GLAB_TARGET_BUFF_ARGS);
    self.glabIndex = nil;
    return 1;
end

function class:execGlab(unit,targetIndex)
    local target = self:getPlayerUnit(targetIndex);
    if target == nil then
        return;
    end

    self:addBuffs(target,self.GLAB_TARGET_BUFF_ARGS);

    self.glabIndex = targetIndex;
end

function class:updateGlab(unit,deltaTime)
    if self.glabIndex == nil then
        return;
    end

    local target = self:getPlayerUnit(self.glabIndex);
    if target == nil then
        return;
    end

    local x = unit:getSkeleton():getBoneWorldPositionX("DAMAGEAREA") + unit:getPositionX();
    local y = unit:getSkeleton():getBoneWorldPositionY("DAMAGEAREA") + unit:getPositionY();
    local targetWorldPositionX = target:getSkeleton():getBoneWorldPositionX("MAIN");
    local targetWorldPositionY = target:getSkeleton():getBoneWorldPositionY("MAIN");
    unit:setZOrder(10000);
    target:setZOrder(unit:getZOrder() + 1);

    target:setPosition(x - targetWorldPositionX,target:getPositionY());
    target:getSkeleton():setPosition(0,y - target:getPositionY() - targetWorldPositionY);
end


--=====================================================================================================================================
function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:execGlab(self.gameUnit,args.arg);
    return 1;
end


function class:receive5(args)
    self:setRace(args.arg);
    return 1;
end

function class:receive6(args)
    self:execDead(self.gameUnit);
    return 1;
end

function class:receive7(args)
    self:getFury(self.gameUnit);
    return 1;
end



function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

function class:getPlayerUnit(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end

class:publish();

return class;