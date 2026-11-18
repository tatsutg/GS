--@additionalEnemy,2007043
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ジル", version=1.3, id=2007042});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL3 = 100
}

class.ACTIVE_SKILLS = {
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

--１度に召喚される敵の数
class.SUMMON_CNT_MAX = 2;

--[召喚される敵のエネミーID] = 重み
class.ENEMYS = {
    [2007043] = 100
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 40001174,
        EFID = 17,         --速度アップ
        VALUE = 60,        --効果量
        DURATION = 9999999,
        ICON = 31,
        EFFECT = 17,
        SCRIPT = 58
    }
    -- {
    --     ID = 40001173,
    --     EFID = 17,         --攻撃アップ
    --     VALUE = 60,        --効果量
    --     DURATION = 9999999,
    --     ICON = 26
    -- }
}

--怒り時のメッセージ
class.RAGE_MESSAGES = {
    {
        MESSAGE = class.TEXT.mess1 or "人は…しぶといのよ…",
        COLOR = Color.green,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.mess4 or "奥義ダメージアップ",
        COLOR = Color.red,
        DURATION = 5
    }
};

class.START_MESSAGES = {
    {
        MESSAGE = class.TEXT.mess2 or "回避率UP",
        COLOR = Color.green,
        DURATION = 5
    },
    {
        MESSAGE = class.TEXT.mess3 or "HP自然回復",
        COLOR = Color.green,
        DURATION = 5
    }

};

class.MESSAGE_COLOR = Color.magenta;


class.BUFF_VALUE = 30;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;

    self.HP_TRIGGERS = {
        [50] = "getRage"
    };

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {
        {
            HP = 50,isUsed = false,MARKER = event.unit:addNumHpMarker(0.5)
        }
    }
    return 1;
end

function class:startWave(event)
    self:showMessages(event.unit,self.START_MESSAGES);
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
        skillIndex = 2;
    end
    
    if skillIndex == "3" then
        self:summon(unit);
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
    self.skillCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    if event.index == 2 and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(2);
        return 0;
    end
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    for _,marker in pairs(self.hpMarkers) do
        local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
        if not marker.isUsed and hpPercent < marker.HP then
            marker.isUsed = true
            event.unit:removeHpMarker(marker.MARKER)
        end
    end
    return 1;
end


function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self:addRageBuff(unit);
    self.isRage = true;
    self:showMessages(unit,self.RAGE_MESSAGES);
    self:creanUpEnemy(unit);
    unit:setAttackDelay(0);
end

function class:addRageBuff(unit)
    for i, v in ipairs(self.RAGE_BUFF_ARGS) do
        self:addBuff(unit, v);
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
end

function class:showMessages(unit, messages)
    for i, v in ipairs(messages) do
        Utility.messageByEnemy(v.MESSAGE, v.DURATION, v.COLOR);
    end
end

--=====================================================================================================================================
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
    if trigger == "summon" then
        self:summon(unit);
        return true;
    end
    if trigger == "getRage" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    return false;
end

function class:dead(event)
    self:creanUpEnemy(event.unit);
    return 1;
end


--=====================================================================================================
--ユニットを召喚
function class:summon(unit)
    if not self:getIsHost() then
        return;
    end

    local cnt = 0;
    for i = 0, 3 do
        if unit:getTeam():getTeamUnit(i) == nil then
            local enemyID = Random.sampleWeighted(self.ENEMYS);
             local summonedUnit = unit:getTeam():addUnit(i,enemyID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
             summonedUnit:addSP(100);
             cnt = cnt + 1; 
             if cnt >= self.SUMMON_CNT_MAX then
                break;
             end
        end
    end
end


function class:creanUpEnemy(unit)
    for i = 0, 5 do
        local enemy = unit:getTeam():getTeamUnit(i,true);--無敵や出現中でも殺せるように第二引数はtrue
        if enemy ~= nil and enemy ~= unit then
            enemy:setHP(0);
        end
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