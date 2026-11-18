local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ろっず", version=1.3, id=2006744});
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
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}


class.BUFF_VALUE = 30;

--開始時メッセージ
class.START_MESSAGES = {
    {
        MESSAGE = class.TEXT.mess1 or "ロッズ「いい女じゃねぇか！」",
        COLOR = Color.cyan,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.mess2 or "ロッズ：女性からのダメージ20％アップ",
        COLOR = Color.cyan,
        DURATION = 5
    }
};
--開始時メッセージ
class.POWREDOWN_MESSAGES = {
    {
        MESSAGE = class.TEXT.mess3 or "ロッズ：防御力ダウン",
        COLOR = Color.cyan,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.mess4 or "ロッズ：攻撃力ダウン",
        COLOR = Color.cyan,
        DURATION = 5
    }
};

--弱体時にかかるバフ内容
class.BUFF_ARGS = {
    {
        ID = 40001174,
        EFID = 13,         
        VALUE = -30,        
        DURATION = 9999999,
        ICON = 4
    },
    {
        ID = 40001173,
        EFID = 15,         
        VALUE = -30,        
        DURATION = 9999999,
        ICON = 6
    }
}

function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.spValue = 20;
    event.unit:setNeedSP(100);--SPの必要量をデータで勝手に変えられないための自衛策
    event.unit:setSkillInvocationWeight(0);
    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.buddyCheckTimer = 0;
    self.buddyAliveFlag = true;
    self.HP_TRIGGERS = {
        [50] = "getRage"
    };

    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    self.buddyCheckTimer = self.buddyCheckTimer + event.deltaTime;
    if self.buddyAliveFlag and self.buddyCheckTimer > 0.2 then
        self.buddyCheckTimer = 0;
        if not self:isBuddyStillAlive(event.unit) then
            self.buddyAliveFlag = false;
            self:powreDown(event.unit);
        end
    end
    event.unit:setReduceHitStop(2,0.5);--ヒットストップ無効Lv2　50%軽減
    return 1;
end

function class:startWave(event)
    if self.isEnemysGirl(event.unit) then
        self:showMessages(event.unit,self.START_MESSAGES);
    end
    
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
    -- self:attackActiveSkillSetter(event.unit,event.index);
    self:addSP(event.unit);
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    if self.isRage then
        skillIndex = 3;
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

    local hpRate = Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do

        if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
            if self:excuteTrigger(unit,self.HP_TRIGGERS[i]) then
                self.HP_TRIGGERS[i] = nil;
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
    return false;
end

--=====================================================================================================================================

function class:isBuddyStillAlive(unit)
    
    for i=0,7 do
        local target = unit:getTeam():getTeamUnit(i);
        if target ~= nil and target ~= unit and target:getBaseID3() == 227 then
            return true;
        end
    end
    return false;
    
end

function class:isEnemysGirl(unit)
    for i=0,7 do
        local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if target ~= nil and target:getSexuality() == 2 then
            return true;
        end
    end
    return false;
end


--=====================================================================================================================================

function class:showMessages(unit, messages)
    for i, v in ipairs(messages) do
        Utility.messageByEnemy(v.MESSAGE, v.DURATION, v.COLOR);
    end
end

function class:getRage(unit)
    self.isRage = true;
end
--=====================================================================================================
function class:powreDown(unit)
    self:showMessages(unit,self.POWREDOWN_MESSAGES);
    self:addPowreDownBuff(unit);
end


function class:addPowreDownBuff(unit)
    for i, v in ipairs(self.BUFF_ARGS) do
        self:addBuff(unit, v);
    end
end

function class:addBuff(unit,args)
    if args.EFFECT ~= nil then
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON,args.EFFECT);
    else
        unit:getTeamUnitCondition():addCondition(args.ID,args.EFID,args.VALUE,args.DURATION,args.ICON);
    end
end
--=====================================================================================================
function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end

--=====================================================================================================
function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end


class:publish();

return class;