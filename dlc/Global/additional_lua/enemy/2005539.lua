local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="", version=1.3, id=2005539});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 90,
    ATTACK2 = 10
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL3 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    SKILL1 = 5,
    SKILL3 = 6
}

--怒り時にかかるバフ内容
class.HP80_BUFF_ARGS = {
    {
        ID = 400751,
        EFID = 112,         --状態異常耐性
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 67
    }
}
class.START_BUFF_ARGS = {
    {
        ID = 400754,
        EFID = 13,         --攻撃
        VALUE = -50,        --効果量
        DURATION = 9999999,
        ICON = 0,
        SCRIPT = 18,
        SCRIPTVALUE1 = 93,
        SCRIPTVALUE2 = 131
    }
}



class.HP15_BUFF_ARGS = {
    {
        ID = 400752,
        EFID = 32,         --命中
        VALUE = -600,        --効果量
        DURATION = 9999999,
        ICON = 0,
        SCRIPT = 18,
        SCRIPTVALUE1 = 93
    },
    {
        ID = 400753,
        EFID = 26,         --攻撃速度
        VALUE = -25,        --効果量
        DURATION = 9999999,
        ICON = 0
    }
}

class.EF_BUFF_ARGS = {
    {
        ID = 400755,
        EFID = 0,         --見た目だけのバフ
        VALUE = 1,        --効果量
        DURATION = 9999999,
        ICON = 0,
        ACTION = function (unit,buff)
            buff:addAnimationWithFile("effect/aura1.json","aura2"); 
        end
    }
}


class.BUFF_VALUE = 30;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.fadeOutFrame = 0;
    self.targetFadeInFrame = 0;
    self.fadeInFrame = 0;
    self.fadeOutFlag = false;
    self.targetFadeInFlag = false;
    self.fadeInFlag = false;
    self.fadeOutFrame = 0;
    self.deathTargetIndex = 0;
    self.halfFlg = false;
    self.isSpecialKill = false;
    self.suddenDeath = false;
    self.forceSkillIndex = 0;
    self.targetTable = {};

    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [0] = {
            HP = 80,
            trigger = "HP80",
            isActive = true
        },
        [1] = {
            HP = 55,
            trigger = "HP55",
            isActive = true
        },
        [2] = {
            HP = 15,
            trigger = "HP15",
            isActive = true
        }
    }

    --怒り時のメッセージ
    self.HP80_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.TEXTHP80_MESSAGE1 or "我が鎌ハ決して曇らぬ…",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }


    self.HP15_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.TEXTHP15_MESSAGE1 or "絶望セヨ…我が鎌ハ全ての魂を破壊スル",
            COLOR = Color.magenta,
            DURATION = 10
        }
    }


    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGERS) do
        self.hpMarkers[self.HP_TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.HP_TRIGGERS[index].HP * 0.01)
    end
    return 1;
end

function class:startWave(event)
    self:addBuffs(event.unit,self.START_BUFF_ARGS);
    self:addBuffs(event.unit,self.EF_BUFF_ARGS);
    -- summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.magenta);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    event.unit:setReduceHitStop(2,1);

    if self.fadeOutFlag then
        self:fadeOutUpdate(event.unit);
    elseif self.targetFadeInFlag then
        self:fadeInTargetUpdate(event.unit);
    elseif self.fadeInFlag then
        self:fadeInUpdate(event.unit);
    end

    self:kurayamiCheck(event.unit);
    return 1;
end

function class:kurayamiCheck(unit)
    if self.beforeKurayami and (unit:getTeamUnitCondition():findConditionWithType(93) == nil and unit:getTeamUnitCondition():findConditionWithType(131) == nil) then
        self.beforeKurayami = false;
        self:addBuffs(unit,self.EF_BUFF_ARGS);
    end
    if not self.beforeKurayami and (unit:getTeamUnitCondition():findConditionWithType(93) ~= nil or unit:getTeamUnitCondition():findConditionWithType(131) ~= nil) then
        self.beforeKurayami = true;
        self:removeCondition(unit,self.EF_BUFF_ARGS[1].ID);
    end
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    
    unit:takeAttack(tonumber(attackIndex));
    
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
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
    -- self:addSP(event.unit);
    return 1
end

function class:skillBranch(unit)
    local skillIndex = 3;
    if (unit:getTeamUnitCondition():findConditionWithType(93) ~= nil or unit:getTeamUnitCondition():findConditionWithType(131) ~= nil) then
        skillIndex = 1;
    end
    if self.forceSkillIndex ~= 0 then
        skillIndex = self.forceSkillIndex;
        self.forceSkillIndex = 0;
    end

    unit:takeSkill(skillIndex);
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
    if self.halfFlg and not self.skillCheckFlg2 then
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

function class:run(event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "generalPause" then return self:generalPause(event.unit) end
    if event.spineEvent == "target" then return self:target(event.unit) end
    if event.spineEvent == "death" then return self:death(event.unit) end
    if event.spineEvent == "fadeInTarget" then return self:fadeInTarget(event.unit) end
    if event.spineEvent == "specialUpdate" then return self:specialUpdate(event.unit) end
    return 1;
end


function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:attackDamageValue(event)
    if self.suddenDeath and event.unit:getTeamUnitCondition():findConditionWithType(93) == nil and event.unit:getTeamUnitCondition():findConditionWithType(131) == nil then
        return 9999999;
    end
    return event.value;
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
                self.gameUnit:removeHpMarker(self.hpMarkers[self.HP_TRIGGERS[i].HP])
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "HP80" and (unit:getTeamUnitCondition():findConditionWithType(93) ~= nil or unit:getTeamUnitCondition():findConditionWithType(131) ~= nil) then
        self:HP80(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    if trigger == "HP55" then
        self:HP55(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    if trigger == "HP15" and (unit:getTeamUnitCondition():findConditionWithType(93) ~= nil or unit:getTeamUnitCondition():findConditionWithType(131) ~= nil) then
        self:HP15(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    return false;
end

--===================================================================================================================
--怒り関係

function class:HP80(unit)
    self:removeAllConditions(unit,93);
    self:removeAllConditions(unit,131);
    self:removeAllConditions(unit,112);
    self:addBuffs(unit,self.HP80_BUFF_ARGS);
    self:showMessage(self.HP80_MESSAGES);
end

function class:HP55(unit)
    if (unit:getTeamUnitCondition():findConditionWithType(93) == nil and unit:getTeamUnitCondition():findConditionWithType(131) == nil) then
        self.isSpecialKill = true;
    end
    unit:addSP(100);
    self.halfFlg = true;
    self:forceStan();
    self.forseSkillIndex = 3;
    unit:takeIdle();
    unit:setInvincibleTime(7);
end

function class:HP15(unit)
    self:removeAllConditions(unit,112);
    self:addBuffs(unit,self.HP15_BUFF_ARGS);
    self:showMessage(self.HP15_MESSAGES);
    self.suddenDeath = true;
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
    if args.SCRIPTVALUE2 ~= nil then
        buff:setValue2(args.SCRIPTVALUE2);
    end

    if args.ACTION ~= nil then
        args.ACTION(unit,buff);
    end

end

function class:removeAllConditions(unit,effectType)

    while unit:getTeamUnitCondition():findConditionWithType(effectType) ~= nil do
        local buff = unit:getTeamUnitCondition():findConditionWithType(effectType);
        unit:getTeamUnitCondition():removeCondition(buff);
    end
end

function class:removeCondition(unit,id)

    local buff = unit:getTeamUnitCondition():findConditionWithID(id);
    unit:getTeamUnitCondition():removeCondition(buff);

    
end

function class:forceStan(unit)
    
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            uni:resumeUnit();
            uni:getTeamUnitCondition():addCondition(-12,89,100,2,0);
        end
    end
    

    return 1;
end

--=====================================================================================================================================
function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


function class:generalPause(unit)
    self.deathExcuteFlg = true;
    --まずヒットストップ中のユニットのヒットストップを解除　そして全員気絶
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            uni:resumeUnit();
            uni:getTeamUnitCondition():addCondition(-12,89,100,0.5,0);
        end
    end
    --全員停止
    megast.Battle:getInstance():pauseUnit(2);
    --死神だけ動く
    unit:resumeUnit();
    unit.m_IgnoreHitStopTime = 10;

    return 1;
end

function class:specialUpdate(unit)
    if self.deathExcuteFlg then

        --全員停止
        megast.Battle:getInstance():pauseUnit(0.5);
        --死神だけ動く
        unit:resumeUnit();
        unit:setInvincibleTime(1);
    end

    if self.fadeOutFlag then
        self.fadeOutUpdate(self,unit);
    elseif self.targetFadeInFlag then
        self.fadeInTargetUpdate(self,unit);
    elseif self.fadeInFlag then
        self.fadeInUpdate(self,unit);
    end

    return 1;
end

function class:fadeInUpdate(unit)
    frameRate = unitManagerDeltaTime/0.016666667;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            opa = uni:getOpacity() + 6 * frameRate;
            if opa > 255 then--オーバーフローさせないため
                opa = 255;
            end
            uni:setOpacity(opa);
        end
    end
    self.fadeInFrame = self.fadeInFrame + 1 * frameRate;
    if self.fadeInFrame > 255/6 then
        self.fadeInFlag = false;
    end
    return 1;
end

function class:fadeInTargetUpdate(unit)
    frameRate = unitManagerDeltaTime/0.016666667;
    local deathTarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(self.deathTargetIndex);
    if deathTarget ~= nil then
        opa = deathTarget:getOpacity() + 6;
        if opa > 255 then--オーバーフローさせないため
            opa = 255;
        end
        deathTarget:setOpacity(opa);

    end
    self.targetFadeInFrame = self.targetFadeInFrame + frameRate;
    if self.targetFadeInFrame > 255/6 then
        self.targetFadeInFlag = false;
    end
    return 1;
end

function class:fadeOutUpdate(unit)
    if self.halfFlg then
        return;
    end
    frameRate = unitManagerDeltaTime/0.016666667;
    for i = 0,6 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            opa = uni:getOpacity() - 10 * frameRate;
            if opa < 0 then--アンダーフローさせないため
                opa = 0;
            end
            uni:setOpacity(opa);
        end
    end
    self.fadeOutFrame = self.fadeOutFrame + 1 * frameRate;
    if self.fadeOutFrame > 255/10 then
        self.fadeOutFlag = false;
    end
    return 1;
end

function class:target(unit)
    if self:getIsHost() then
        local targetIndexes = {};
        for i = 0,4 do
            local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
            if uni ~= nil then
                table.insert(targetIndexes,uni:getIndex());
            end
        end
        local rand = Random.range(0,table.maxn(targetIndexes));
        self.deathTargetIndex = targetIndexes[rand + 1];
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,self.deathTargetIndex);
    end
    self.fadeOutFrame = 0;
    self.fadeOutFlag = true;
    return 1;
end


function class:death(unit)
    self.deathExcuteFlg = false;
    -- megast.Battle:getInstance():pauseUnit(0);
    self:fadeInAll();
    unit:resumeUnit();
    unit.m_IgnoreHitStopTime = 0;
    megast.Battle:getInstance():setBattleState(kBattleState_active);
    unit:setInvincibleTime(0);
    for i = 0,4 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if uni ~= nil then
            if self.halfFlg then
                self:specialKill(unit,uni);
            end
            uni:excuteAction();
        end
    end
        
    if self.halfFlg then
        self.halfFlg = false;
        return 1;
    end
    local deathTarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(self.deathTargetIndex);

    if deathTarget ~= nil then
        local rand = LuaUtilities.rand(0,100);

        local baseRate = 100;
        -- local rateByAttack = 100 * deathTarget:getCalcPower()/self.consts.powerBorderOfDeath;

        if rand <= baseRate then
            if deathTarget:isMyunit() then
                deathTarget:setHP(0);
            end
            deathTarget:takeDamagePopup(unit,99999);
        end

        deathTarget = nil;
    end

    -- --霧モードなら霧を再展開
    -- if self.isMist and self.blackMist == nil  then
    --     self.blackMist = unit:addOrbitSystemCamera("blackmist_in",0);
    --     self.blackMist:takeAnimation(0,"blackmist_in",true);
    --     self.blackMist:setZOrder(8000);
    -- end
    return 1;
end

function class:specialKill(unit,target)
    local damage = target:getHP()/4;
    if self.isSpecialKill then
        damage = 99999;
    end
    target:setHP(target:getHP() - damage);
    target:takeDamagePopup(unit,damage);
    target:excuteAction();
end

function class:fadeInAll()
    self.fadeInFrame = 0;
    self.fadeInFlag = true;
    return 1;
end

function class:fadeInTarget(unit)
    local deathTarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(self.deathTargetIndex);
    if deathTarget ~= nil then
        self.targetFadeInFrame = 0;
        self.targetFadeInFlag = true;
        self:glab(unit);
        local fire = unit:addOrbitSystem("skill3player",0);
        local targetx = deathTarget:getPositionX() + deathTarget:getSkeleton():getBoneWorldPositionX("MAIN");
        local targety = deathTarget:getPositionY() + deathTarget:getSkeleton():getPositionY() + deathTarget:getSkeleton():getBoneWorldPositionY("MAIN") + 100;
        fire:setPosition(targetx,targety);
        fire:pauseUnit(0.01);
    end
    return 1;
end

function class:glab(unit)
    if self.halfFlg then
        return;
    end
    local targetUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(self.deathTargetIndex);
    if targetUnit ~= nil then
        local destinationX = unit:getPositionX() + 400;
        local destinationY = unit:getPositionY() + 250;
        local targetMainX = targetUnit:getSkeleton():getBoneWorldPositionX("MAIN");
        local targetMainY = targetUnit:getSkeleton():getBoneWorldPositionY("MAIN");
        targetUnit:setPosition(destinationX - targetMainX,targetUnit:getPositionY());
        targetUnit:getSkeleton():setPositionY(destinationY - (targetMainY + targetUnit:getPositionY()));
    end
    return 1;
end




class:publish();

return class;