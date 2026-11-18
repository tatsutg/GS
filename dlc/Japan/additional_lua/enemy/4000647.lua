local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local enemy = summoner.Bootstrap.createEnemyClass({label="UnitName", version=1.3, id=4000647});


--通常時にかかるバフ内容
enemy.NORMAL_BUFF_ARGS = {
    {
        ID = 40071,
        EFID = 61,         --炎耐性
        VALUE = 80,        --効果量
        DURATION = 9999999,
        ICON = 38
    },
    {
        ID = 40072,
        EFID = 62,         --水耐性
        VALUE = 80,        --効果量
        DURATION = 9999999,
        ICON = 39
    },
    {
        ID = 40073,
        EFID = 63,         --樹耐性
        VALUE = 80,        --効果量
        DURATION = 9999999,
        ICON = 40
    },
    {
        ID = 40074,
        EFID = 65,         --闇耐性
        VALUE = 80,        --効果量
        DURATION = 9999999,
        ICON = 42
    }
}

--怒り時にかかるバフ内容
enemy.RAGE_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 17,         --ダメージアップ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    {
        ID = 40076,
        EFID = 28,         --速度アップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 7,
        EFFECT = 50009
    },
    {
        ID = 40077,
        EFID = 64,         --光耐性
        VALUE = 80,        --効果量
        DURATION = 9999999,
        ICON = 41
    }
}

enemy.ANIMATION_STATES = {
	IDLE = "idle",
	BACK = "back",
	DAMAGE = "damage",
	ATTACK2 = "attack2",
	ATTACK3 = "attack3",
	ATTACK4 = "attack4",
	SKILL1 = "skill1",
	SKILL2 = "skill2"
}

--=====================================================================================================
--攻撃分岐の確率
--=====================================================================================================

--使用する通常攻撃とその確率 [アニメーションの番号] = 重み
enemy.ATTACK_WEIGHTS = {
    [2] = 10,   --ダイナミックお手
    [3] = 10,   --噛みつき
    [4] = 10	--踏み潰し
}

--使用する奥義とその確率　[アニメーションの番号] = 重み　skill2は今回は不使用
enemy.SKILL_WEIGHTS = {
    [2] = 100
}


--攻撃や奥義に設定されるスキルの番号
enemy.ACTIVE_SKILLS = {
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 7,
    SKILL2 = 8
}

function enemy:start(event)
    event.unit:setSPGainValue(0);
    self.spRizeValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.gameUnit = event.unit;
    self.isRage = false;
    event.unit:setSetupAnimationName("setUpNormal");

    self.HP_TRIGGERS = {
        [50.0001] = "judgement1",
	    [50] = "getRage",
	    [20] = "judgement2"
	}
    self.hpMarkers = {
        [50] = self.gameUnit:addNumHpMarker(0.5),
        [20] = self.gameUnit:addNumHpMarker(0.2)
    }

    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "光属性以外軽減",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "クリティカル発生無効",
            COLOR = Color.red,
            DURATION = 5
        },
        [2] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "炎・水・樹キラー",
            COLOR = Color.red,
            DURATION = 5
        }
    }

	--怒り時のメッセージ
    self.RAGE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "闇属性以外軽減",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE2 or "攻撃速度アップ",
            COLOR = Color.red,
            DURATION = 5
        },
        [2] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE3 or "与ダメージアップ",
            COLOR = Color.red,
            DURATION = 5
        }
    }


	self.JUDGEMENT_MESSAGES1 = {
	    [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE4 or "…審判の時…",
            COLOR = Color.yellow,
            DURATION = 5
        }
	}

	--怒り時のメッセージ
	self.JUDGEMENT_MESSAGES2 = {
	    [1] = {
	        MESSAGE = self.TEXT.RAGE_MESSAGE5 or "裁きを与えん…",
	        COLOR = Color.yellow,
	        DURATION = 5
	    }
	}

    return 1;
end

function enemy:startWave(event)
	self:addBuffs(event.unit,self.NORMAL_BUFF_ARGS);
    self:showMessages(unit,self.START_MESSAGES);
	return 1;
end



function enemy:update(event)
    self:HPTriggersCheck(event.unit);
    event.unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2（メリア以外のヒットストップを受けない）　減衰量１００％
    return 1;
end

function enemy:takeIdle(event)
	self:switchAnimation(event.unit,self.ANIMATION_STATES.IDLE);
	return 1;
end

function enemy:takeDamage(event)
	self:switchAnimation(event.unit,self.ANIMATION_STATES.DAMAGE);
	return 1;
end

function enemy:takeBack(event)
	self:switchAnimation(event.unit,self.ANIMATION_STATES.BACK);
	return 1;
end

--===================================================================================================================
--通常攻撃分岐//
--///////////

--攻撃分岐の判断です。ホストだけで行います。
function enemy:attackBranch(unit)
    local attackIndex = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    unit:takeAttack(attackIndex);
    return 0;
end

function enemy:takeAttack(event)
    if not self.attackCheckFlg and self:getIsHost() then
        self.attackCheckFlg = true;
        return self:attackBranch(event.unit);
    end
    self.attackCheckFlg = false;
    self:attackActiveSkillSetter(event.unit,event.index);
    self:switchAnimation(event.unit,self.ANIMATION_STATES["ATTACK"..event.index]);
    return 1
end



function enemy:attackActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["ATTACK"..index]);
end

--===================================================================================================================
--スキル分岐//
--//////////

function enemy:skillBranch(unit)
    local skillIndex = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    if self.judgement then
        self.judgement = false;
    	skillIndex = 1;
    end
    unit:takeSkill(skillIndex)
    return 0;
end

function enemy:takeSkill(event)
    if not self.skillCheckFlg and self:getIsHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    self.skillCheckFlg = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    event.unit:setBurstState(kBurstState_active);--ゲスト側のステートが変わらない問題の対策
    self:switchAnimation(event.unit,self.ANIMATION_STATES["SKILL"..event.index]);
    return 1
end

function enemy:skillActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
end

--===================================================================================================================
function enemy:run (event)
    if event.spineEvent == "addSP" then 
        self:addSP(event.unit) 
    end
    if event.spineEvent == "setFire" then 
        self:setFire(event.unit) 
    end
    return 1;
end

function enemy:addSP(unit)
    if self.getIsHost() then
        unit:addSP(self.spRizeValue);
    end
    return 1;
end

--===================================================================================================================
--HPトリガー
function enemy:HPTriggersCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do

        if i >= hpRate and self.HP_TRIGGERS[i] ~= nil then
            local excution = self:excuteTrigger(unit,self.HP_TRIGGERS[i]);
            if excution then
                if self.hpMarkers[i] ~= nil then
                    self.gameUnit:removeHpMarker(self.hpMarkers[i])
                end
                self.HP_TRIGGERS[i] = nil;
            end
        end
    end

end

function enemy:excuteTrigger(unit,trigger)
    if trigger == "getRage" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    if trigger == "judgement1" and unit.m_breaktime <= 0 then
        self:takeJudgement(unit,1);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,1);
        return true;
    end
    if trigger == "judgement2" and unit.m_breaktime <= 0 then
        self:takeJudgement(unit,2);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,2);
        return true;
    end
    return false;
end
--===================================================================================================================
--怒り関係

function enemy:getRage(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self.isRage = true;
    self:showMessages(unit,self.RAGE_MESSAGES);
    unit:setSetupAnimationName("setUpFire");
    Utility.removeUnitBuffByID(unit,40074)
end

function enemy:takeJudgement(unit,count)
	self.judgement = true;
	self:showMessages(unit,self["JUDGEMENT_MESSAGES"..count]);
	unit:setBurstPoint(unit:getNeedSP());
end

function enemy:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

--===================================================================================================================
function enemy:showMessages(unit,messages)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR);
    end
end

function enemy:addBuff(unit,args)
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

--===================================================================================================================
function enemy:switchAnimation(unit,animationState)
	if not self.isRage then
		unit:setNextAnimationName("zcloneN"..animationState);
	end
end
--===================================================================================================================
function enemy:setFire(unit)
	local fire = unit:addOrbitSystem("firePiller",0)
    fire:setHitCountMax(999);
    fire:setEndAnimationName("fireEnd");
    -- fire:EnabledFollow = true;
    local x = unit:getPositionX();
    local y = unit:getPositionY();
    local xb = 0;
    local yb = 0;

    local rand = math.random(5);

    if rand == 1 then
        xb = 300;
    elseif rand == 2 then
        xb = 350;
        yb = -100;
    elseif rand == 3 then
        xb = 400;
        yb = 50;
    elseif rand == 4 then
        xb = 500;
    elseif rand == 5 then
        xb = 600;
        yb = 100;
    end

    
    fire:setPosition(x+xb,y+yb);
    fire:setAutoZOrder(true);
    fire:setZOderOffset(-5000);
end
--===================================================================================================================
function enemy:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function enemy:receive4(args)
    self:takeJudgement(self.gameUnit,args.arg);
    return 1;
end


function enemy:getIsHost()
    return megast.Battle:getInstance():isHost();
end



enemy:publish();

return enemy;