local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="501311413", version=1.3, id=487100000});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50
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
    SKILL1 = 5,
    SKILL2 = 6
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 17,         --ダメージアップ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}

--最大HPデバフ
class.HP_REDUCE_BUFF_ARGS = {
    {
        ID = 501314,
        EFID = 2,         --最大HP
        VALUE = -80,        --効果量
        DURATION = 999999,
        ICON = 2
    }
}

--クリスタルバフ　１個目
class.FIRST_BUFF_ARGS = {
    {
        ID = 501311,
        EFID = 132,         --無効化解除
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 0
    }
}

--クリスタルバフ　２個目
class.SECOND_BUFF_ARGS = {
    {
        ID = 501312,
        EFID = 17,         --ダメージアップ
        VALUE = 50,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}

--クリスタルバフ　３個目
class.THIRD_BUFF_ARGS = {
    {
        ID = 501313,
        EFID = 22,         --クリティカル率
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 11
    }
}



class.CRYSTAL_NUM = 3;

class.CRYSTAL_POSITIONS = {
    {x = -300,y = 500},
    {x = 300,y = 500},
    {x = 0,y = 530}
}
class.CRYSTAL_STATES = {
    start = 0,
    deactive = 1,
    activation = 2,
    active = 3,
    out = 4,
    hide = 5
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
    self.hpReduceCheckTimer = 0;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        -- [50] = "getRage",
    }

    -- HP低下メッセージ
    self.HP_REDUCE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP_REDUCE_MESSAGE or "最大HPダウン",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }
    -- 開幕のメッセージ
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE or "光属性ユニットからのダメージ・ブレイク無効",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }



    self.BUFF_MESSAGES1 = {
        [0] = {
            MESSAGE = self.TEXT.BUFF_MESSAGE1 or "ダメージ無効化解除",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }


    self.BUFF_MESSAGES2 = {
        [0] = {
            MESSAGE = self.TEXT.BUFF_MESSAGE2 or "与ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }


    self.BUFF_MESSAGES3 = {
        [0] = {
            MESSAGE = self.TEXT.BUFF_MESSAGE3 or "クリティカル率アップ",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }
    self.crystalBuffs = {};
    self.crystals = {};
    self.crystalCounter = 3;
    self.crystalExcutionFlg = false;
    self:initCrystals(event.unit);
    
    self.gameUnit = event.unit;
    self:setUpCrystalBuffs(event);
    event.unit:setSPGainValue(0);
    return 1;
end

function class:setUpCrystalBuffs(event)
    self.crystalBuffs[1] = {action = function(luaInstance,unit)
        luaInstance:addBuffs(unit,luaInstance.FIRST_BUFF_ARGS);
        luaInstance:showMessages(unit,luaInstance.BUFF_MESSAGES1);
    end
    }

    self.crystalBuffs[2] = {action = function(luaInstance,unit)
        luaInstance:addBuffs(unit,luaInstance.SECOND_BUFF_ARGS);
        luaInstance:showMessages(unit,luaInstance.BUFF_MESSAGES2);
    end
    }

    self.crystalBuffs[3] = {action = function(luaInstance,unit)
        luaInstance:addBuffs(unit,luaInstance.THIRD_BUFF_ARGS);
        luaInstance:showMessages(unit,luaInstance.BUFF_MESSAGES3);
    end
    }
end

function class:startWave(event)
    event.unit:addSP(event.unit:getNeedSP());
    self:showMessages(unit,self.HP_REDUCE_MESSAGES);
    self:showMessages(unit,self.START_MESSAGES);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    self:takeHPReduce(event.unit,event.deltaTime);
    event.unit:setReduceHitStop(2,1);
    return 1;
end

--===================================================================================================================
--通常攻撃分岐//
--///////////


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
    self:addSP(event.unit);
    return 1
end

function class:attackActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["ATTACK"..index]);
end
--===================================================================================================================


--===================================================================================================================
--スキル分岐//
--//////////

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if self.crystalCounter >= self.CRYSTAL_NUM then
        skillIndex = 2;
    end

    unit:takeSkill(tonumber(skillIndex));

    self.crystalCounter = self.crystalCounter + 1;
    self:lightUp(unit,self.crystalCounter);
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,self.crystalCounter);
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

    self.skillCheckFlg = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    event.unit:setBurstState(kBurstState_active);
    if event.index == 2 then
        event.unit:setInvincibleTime(8);
    end
    return 1
end

function class:skillActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
end



--===================================================================================================================
function class:takeDamage(event)
    if self.crystalExcutionFlg and megast.Battle:getInstance():isHost() then
        self:skill2Compleat();
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
    end
    return 1;
end



function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "crystalActionEnd" then self:crystalStateEnd(event.unit) end
    if event.spineEvent == "skill2Start" then self:skill2Start() end
    if event.spineEvent == "skill2Compleat" and self:getIsHost() then 
        self:skill2Compleat() 
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
    end
    return 1;
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
            self:excuteTrigger(unit,self.HP_TRIGGERS[i]);
            self.HP_TRIGGERS[i] = nil;
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "getRage" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
    end
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self.isRage = true;
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

--====================================================================================================================================
--クリスタル関係

function class:initCrystals(unit)
    for i=1,3 do
        self.crystals[i] = self:createCrystal(unit,self.CRYSTAL_POSITIONS[i].x,self.CRYSTAL_POSITIONS[i].y);
    end
    
end

function class:createCrystal(unit,x,y)
    local crystal = {}
    crystal.orbit = unit:addOrbitSystem("crystal_idle_on");
    crystal.orbit:takeAnimation(0,"crystal_idle_on",true);
    crystal.orbit:setPosition(x,y);
    crystal.orbit:setZOrder(8999);
    crystal.state = self.CRYSTAL_STATES.active;

    crystal.endState = function(class,this)
        if this.state == class.CRYSTAL_STATES.start then
            this.switchState(class,this,class.CRYSTAL_STATES.deactive);
        elseif this.state == class.CRYSTAL_STATES.activation then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
        elseif this.state == class.CRYSTAL_STATES.out then
            this.switchState(class,this,class.CRYSTAL_STATES.hide);
        end
    end

    crystal.switchState = function(class,this,targetState)
        this.state = targetState;
        if targetState == class.CRYSTAL_STATES.active then
            this.orbit:takeAnimation(0,"crystal_idle_on",true);
        end
        if targetState == class.CRYSTAL_STATES.deactive then
            this.orbit:takeAnimation(0,"crystal_idle_off",true);
        end
        if targetState == class.CRYSTAL_STATES.activation then
            this.orbit:takeAnimation(0,"crystal_activate",true);
        end
        if targetState == class.CRYSTAL_STATES.start then
            this.orbit:takeAnimation(0,"crystal_in",true);
        end

        if targetState == class.CRYSTAL_STATES.out then
            this.orbit:takeAnimation(0,"crystal_out",true);
        end

        if targetState == class.CRYSTAL_STATES.hide then
            this.orbit:takeAnimation(0,"crystal_hide",true);
        end
    end

    return crystal;
end

function class:crystalStateEnd(unit)
    for i=1,self.CRYSTAL_NUM do
        if self.crystals[i].orbit == unit then
            self.crystals[i].endState(self,self.crystals[i]);
            return;
        end
    end
end

function class:lightUp(unit,num)
    if num > self.CRYSTAL_NUM then
        return;
    end

    if self.crystalBuffs[num] ~= nil then
        self.crystalBuffs[num].action(self,unit);
        self.crystalBuffs[num] = nil;
    end
    

    for i=1,num do
        if self.crystals[i].state == self.CRYSTAL_STATES.deactive then
            self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.activation);
        end
    end
end

function class:excutionCrystals()
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.out);
    end
end

function class:restertCrystals()
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.start);
    end
end

function class:skill2Start()
    self.crystalExcutionFlg = true;
    self:excutionCrystals();
end

function class:skill2Compleat()
    self.crystalExcutionFlg = false;
    self.crystalCounter = 0;
    self:restertCrystals();
end

function class:takeHPReduce(unit,deltaTime)
    self.hpReduceCheckTimer = self.hpReduceCheckTimer + deltaTime;
    if self.hpReduceCheckTimer < 0.2 then
        return;
    end
    self.hpReduceCheckTimer = self.hpReduceCheckTimer - 0.2;
    for i=0,4 do
        local teamUnit = megast.Battle:getInstance():getTeam(not unit:getisPlayer()):getTeamUnit(i);
        if teamUnit ~= nil then
            if teamUnit:getTeamUnitCondition():findConditionWithID(501314) == nil then
                self:addBuffs(teamUnit,self.HP_REDUCE_BUFF_ARGS);
            end
        end
    end
end


--=====================================================================================================================================
function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:lightUp(self.gameUnit,args.arg);
    return 1;
end

function class:receive5(args)
    self:skill2Compleat();
    return 1;
end


function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;