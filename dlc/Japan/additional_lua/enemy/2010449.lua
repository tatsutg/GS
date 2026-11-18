local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="", version=1.3, id=2010449});
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

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 17,         --ダメージアップ
        VALUE = 20,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}


class.BUFF_VALUE = 30;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.isMD = false;
    self.forceSkillIndex = 0;
    self.forceActiveSkill = 0;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [70] = "getRage",
        [30] = "skill3",
    }
    self.hpMarkers = {
        [70] = self.gameUnit:addNumHpMarker(0.7),
        [30] = self.gameUnit:addNumHpMarker(0.3)
    }

    --怒り時のメッセージ
    self.RAGE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "ボクの力、見せてやる",
            COLOR = Color.red,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE2 or "マギアドライブ",
            COLOR = Color.red,
            DURATION = 10
        },
        [2] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE3 or "奥義ゲージ上昇量アップ",
            COLOR = Color.red,
            DURATION = 10
        },
        [3] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE4 or "与ダメージアップ",
            COLOR = Color.red,
            DURATION = 10
        }
    }

    self.LAST_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.LAST_MESSAGE1 or "これで最後だ！",
            COLOR = Color.red,
            DURATION = 10
        }
    }

    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "樹属性へのダメージアップ",
            COLOR = Color.red,
            DURATION = 10
        }
    }

    event.unit:setSPGainValue(0);
    return 1;
end

function class:startWave(event)
    self:showMessages(unit,self.START_MESSAGES);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    self:auraPosition(event.unit)
    return 1;
end

function class:attackBranch(unit)
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
    self:addSP(event.unit);
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if self.forceSkillIndex ~= 0 then
        skillIndex = self.forceSkillIndex;
        self.forceSkillIndex = 0;
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
    if self.isMD and event.index == 3 then
        event.unit:setNextAnimationName("skill3_2")
        event.unit:setNextAnimationEffectName("2skill3_2")
        self:showMessages(unit,self.LAST_MESSAGES);
    end
    if event.index == 3 and self.forceActiveSkill ~= 0 then
        event.unit:setActiveSkill(self.forceActiveSkill);
        self.forceActiveSkill = 0;
        self.isMD = true;
    end
    
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

        if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
            if self:excuteTrigger(unit,self.HP_TRIGGERS[i]) then
                self.HP_TRIGGERS[i] = nil;
                if self.hpMarkers[i] ~= nil then self.gameUnit:removeHpMarker(self.hpMarkers[i]) end
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "getRage" and unit:getBreakPoint() > 0 then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    if trigger == "skill3" and unit:getBreakPoint() > 0 then
        self.forceSkillIndex = 3;
        unit:addSP(100);
        return true;
    end
    return false;
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self.isRage = true;
    self.spValue = 40;
    self.forceSkillIndex = 3;
    self.forceActiveSkill = 5;
    unit:addSP(100);
end


function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

--===================================================================================================================
function class:showMessages(unit,messages)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR);
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

end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
   if event.spineEvent == "md1Start" then
      self:setAura(event.unit)
      self:showMessages(unit,self.RAGE_MESSAGES);
   end
   if event.spineEvent == "loopStart" then
      self.aura:takeAnimation(0,"MD_loop",true);
   end
   return 1
end

--=====================================================================================================================================

function class:setAura(unit)
   if self.aura ~= nil then
      self.aura:takeAnimation(0,"MD_in",true);
      return 
   end
   self.aura = unit:addOrbitSystemWithFile("MD_1","MD_in");
   self.aura:takeAnimation(0,"MD_in",true);
   self:auraPosition(unit)
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




--=====================================================================================================================================
function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;