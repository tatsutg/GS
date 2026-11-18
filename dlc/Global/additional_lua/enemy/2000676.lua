local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="2000676", version=1.3, id=2000676});
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

class.SKILL_WEIGHTS_RAGE = {
    SKILL1 = 100,
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7
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
        EFID = 9,         --奥義ゲージ回収量UP
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 36,
        SCRIPT = 18,
        SCRIPTVALUE1 = 97
    },
    {
        ID = 501317,
        EFID = 97,         --燃焼
        VALUE = 100,        --
        DURATION = 9999999,
        ICON = 87
    }
}

--クリスタルバフ　２個目
class.SECOND_BUFF_ARGS = {
    {
        ID = 501312,
        EFID = 0,         --反射見た目だけ
        VALUE = 1,        --効果量
        DURATION = 9999999,
        ICON = 78,
        SCRIPT = 18,
        SCRIPTVALUE1 = 97
    },
    {
        ID = 501318,
        EFID = 28,         --行動速度
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 7
    },
    {
        ID = 501317,
        EFID = 97,         --燃焼
        VALUE = 100,        --
        DURATION = 9999999,
        ICON = 87
    }
}

--クリスタルバフ　３個目
class.THIRD_BUFF_ARGS = {
    {
        ID = 501313,
        EFID = 21,         --ダメージ軽減
        VALUE = -100,        --効果量
        DURATION = 9999999,
        ICON = 20,
        SCRIPT = 18,
        SCRIPTVALUE1 = 97
    },
    {
        ID = 501315,
        EFID = 17,         --ダメージアップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    {
        ID = 501317,
        EFID = 97,         --燃焼
        VALUE = 100,        --
        DURATION = 9999999,
        ICON = 87
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
    hide = 5,
    start2 = 6
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
    self.isRefrect = false;

    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [70] = "lightUp",
        [60] = "forceSkill",
        [50] = "lightUp",
        [40] = "forceSkill",
        [30] = "lightUp",
        [10] = "lastAttack"
    }

    -- HP低下メッセージ
    -- self.HP_REDUCE_MESSAGES = {
    --     [0] = {
    --         MESSAGE = self.TEXT.HP_REDUCE_MESSAGE or "最大HPダウン",
    --         COLOR = Color.red,
    --         DURATION = 10
    --     }
    -- }
    -- 開幕のメッセージ
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE or "攻撃力・回避率・クリティカルダメージアップ",
            COLOR = Color.red,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "相手燃焼時クリティカル率アップ",
            COLOR = Color.red,
            DURATION = 10
        },
        [2] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "自身燃焼時HP自然回復・氷結耐性ダウン",
            COLOR = Color.red,
            DURATION = 10
        }
    }


    -- self.BREAK_MESSAGES = {
    --     [0] = {
    --         MESSAGE = self.TEXT.BREAK_MESSAGE or "ダメージ反射解除",
    --         COLOR = Color.red,
    --         DURATION = 10
    --     }
    -- }


    self.ARTS_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.ARTS_MESSAGE or "奥義ゲージ１度のみアップ",
            COLOR = Color.red,
            DURATION = 10
        }
    }

    self.LAST_ATTACK_MESSAGES1 = {
        [0] = {
            MESSAGE = self.TEXT.LAST_ATTACK_MESSAGE1 or "試練の回廊が炎熱に歪む……！！",
            COLOR = Color.red,
            DURATION = 10
        }
    }

    self.LAST_ATTACK_MESSAGES2 = {
        [0] = {
            MESSAGE = self.TEXT.LAST_ATTACK_MESSAGE2 or "上空に超高熱源！！",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.LAST_ATTACK_MESSAGES3 = {
        [0] = {
            MESSAGE = self.TEXT.LAST_ATTACK_MESSAGE3 or "衝突まで３秒……！",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.LAST_ATTACK_MESSAGES4 = {
        [0] = {
            MESSAGE = self.TEXT.LAST_ATTACK_MESSAGE4 or "２秒……！",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.LAST_ATTACK_MESSAGES5 = {
        [0] = {
            MESSAGE = self.TEXT.LAST_ATTACK_MESSAGE5 or "１秒……！！",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.BUFF_MESSAGES1 = {
        [0] = {
            MESSAGE = self.TEXT.BUFF_MESSAGE1 or "自身燃焼時奥義ゲージ速度アップ",
            COLOR = Color.red,
            DURATION = 10
        }
    }


    self.BUFF_MESSAGES2 = {
        [0] = {
            MESSAGE = self.TEXT.BUFF_MESSAGE2 or "自身燃焼時反射率アップ",
            COLOR = Color.red,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.BUFF_MESSAGE2_2 or "行動速度アップ",
            COLOR = Color.red,
            DURATION = 10
        }
    }


    self.BUFF_MESSAGES3 = {
        [0] = {
            MESSAGE = self.TEXT.BUFF_MESSAGE3 or "自身燃焼時被ダメージ軽減",
            COLOR = Color.red,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.BUFF_MESSAGE3_2 or "ダメージアップ",
            COLOR = Color.red,
            DURATION = 10
        }
    }
    self.crystalBuffs = {};
    self.crystals = {};
    self.crystalCounter = 0;
    self.crystalExcutionFlg = false;
    self:initCrystals(event.unit);
    
    self.gameUnit = event.unit;
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGERS) do
        self.hpMarkers[index] = self.gameUnit:addNumHpMarker(index * 0.01)
    end
    self:setUpCrystalBuffs(event);
    event.unit:setSPGainValue(0);
    self.forceSkillIndex = 0;
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
        luaInstance.isRefrect = true;
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
    -- self:showMessages(unit,self.HP_REDUCE_MESSAGES);
    self:showMessages(unit,self.START_MESSAGES);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    -- self:takeHPReduce(event.unit,event.deltaTime);
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

    if self.crystalCounter >= self.CRYSTAL_NUM then
        skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS_RAGE);
    end

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

function class:takeDamageValue(event)
    local cond = event.unit:getTeamUnitCondition():findConditionWithType(97);

    if cond ~= nil and self.isRefrect then
            local  targetUnit = event.enemy;

            if targetUnit:getParentTeamUnit() ~= nil then
                targetUnit = targetUnit:getParentTeamUnit();
            end

            --耐性チェック
            local damage = event.value * 0.01;
            local condValue = targetUnit:getTeamUnitCondition():findConditionValue(127);
            damage = damage * (100 - condValue) / 100;

            if damage < 1 then
                damage = 1;
            end

            damage = math.floor(damage);

            --ダメージ表記とHP減算処理
            targetUnit:takeDamagePopup(event.unit,damage);
            targetUnit:setHP(targetUnit:getHP() - damage);
    end
    return event.value;
end



function class:run (event)
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "crystalActionEnd" then self:crystalStateEnd(event.unit) end
    if event.spineEvent == "skill2Start" then self:skill2Start() end
    if event.spineEvent == "skill2Compleat" and self:getIsHost() then 
        self:skill2Compleat() 
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
    end
    if event.spineEvent == "skill3Start" then
        megast.Battle:getInstance():setBackGroundColor(999,255,0,0);
        event.unit:setInvincibleTime(10);
        self:skill2Start() 
    end
    if event.spineEvent == "skill3Compleat" and self:getIsHost() then 
        self:skill2Compleat() 
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
    end

    if event.spineEvent == "showLastMess1" and self:getIsHost() then 
        self:showMessages(event.unit,self.LAST_ATTACK_MESSAGES2);
    end

    -- if event.spineEvent == "showLastMess2" and self:getIsHost() then 
    --     self:showMessages(event.unit,self.LAST_ATTACK_MESSAGES3);
    -- end

    -- if event.spineEvent == "showLastMess3" and self:getIsHost() then 
    --     self:showMessages(event.unit,self.LAST_ATTACK_MESSAGES4);
    -- end

    -- if event.spineEvent == "showLastMess4" and self:getIsHost() then 
    --     self:showMessages(event.unit,self.LAST_ATTACK_MESSAGES5);
    -- end
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
            if self:excuteTrigger(unit,self.HP_TRIGGERS[i]) then
                self.HP_TRIGGERS[i] = nil;
                if self.hpMarkers[i] ~= nil then
                    self.gameUnit:removeHpMarker(self.hpMarkers[i])
                end
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "lightUp" then
        self.crystalCounter = self.crystalCounter + 1;
        if self.crystalCounter > self.CRYSTAL_NUM then
            self.crystalCounter = self.CRYSTAL_NUM;
        end
        self:lightUp(unit,self.crystalCounter);
        self.isRage = true;
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,self.crystalCounter);
        return true;
    end
    if trigger == "forceSkill" and unit:getBurstState() == 0 then
        unit:addSP(unit:getNeedSP());
        self:showMessages(unit,self.ARTS_MESSAGES);
        return true;
    end

    if trigger == "lastAttack" then
        unit:takeIdle();
        self.forceSkillIndex = 3;
        unit:addSP(unit:getNeedSP());
        self:showMessages(unit,self.LAST_ATTACK_MESSAGES1);
        return true;
    end
    return false;
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
    crystal.orbit = unit:addOrbitSystem("crystal_idle_off");
    crystal.orbit:takeAnimation(0,"crystal_idle_off",true);
    crystal.orbit:setPosition(x,y);
    crystal.orbit:setZOrder(8999);
    crystal.state = self.CRYSTAL_STATES.deactive;

    crystal.endState = function(class,this)
        if this.state == class.CRYSTAL_STATES.start then
            this.switchState(class,this,class.CRYSTAL_STATES.deactive);
        elseif this.state == class.CRYSTAL_STATES.activation then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
        elseif this.state == class.CRYSTAL_STATES.out then
            this.switchState(class,this,class.CRYSTAL_STATES.hide);
        elseif this.state == class.CRYSTAL_STATES.start2 then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
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

        if targetState == class.CRYSTAL_STATES.start2 then
            this.orbit:takeAnimation(0,"crystal_in2",true);
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
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.start2);
    end
end

function class:skill2Start()
    self.crystalExcutionFlg = true;
    self:excutionCrystals();
end

function class:skill2Compleat()
    self.crystalExcutionFlg = false;
    -- self.crystalCounter = 0;
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