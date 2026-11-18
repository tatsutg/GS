local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="", version=1.3, id=2007631});
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

class.TALK_RATE = {
    [0] = 23,
    [1] = 23,
    [2] = 23,
    [3] = 8,
    [4] = 23
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 2007643,
        EFID = 17,         --与ダメージアップ
        VALUE = 20,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    {
        ID = 20076432,
        EFID = 21,         --被ダメ割合
        VALUE = -15,        --効果量
        DURATION = 9999999,
        ICON = 0,
        SCRIPT = 75--自身がブレイク中
    }
}

--怒り時にかかるバフ内容
class.SICK_BUFF_ARGS = {
    {
        ID = 20076433,
        EFID = 27,         --攻撃速度
        VALUE = 25,        --効果量
        DURATION = 9999999,
        ICON = 10
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
    event.unit:setSkillInvocationWeight(0);
    self.isSick = false;

    if table.maxn(self.TEXT) == 0 then
        -- self.TEXT = {
        --     START_MESSAGE1 = "光属性耐性",
        --     START_MESSAGE2 = "病気時ブレイク耐性ダウン",
        --     RAGE_MESSAGE1 = "…見せてあげるわ",
        --     RAGE_MESSAGE2 = "与ダメージアップ",
        --     RAGE_MESSAGE3 = "被ダメージ軽減",
        --     RAGE_MESSAGE4 = "これも一興ね…",
        --     TALK1_1 = "今日は勝たせてもらいます",
        --     TALK1_2 = "あなたの成長、見せてもらうわ！",
        --     TALK2_1 = "私に勝てるかしらコルセア？",
        --     TALK2_2 = "勝ってみせます！",
        --     TALK2_3 = "氷剣姫の名に懸けて！",
        --     TALK3_1 = "こんなところで会うなんてね",
        --     TALK3_2 = "私の本気をみてください！",
        --     TALK3_3 = "ふふ、いいわ。きなさい！",
        --     TALK4_1 = "コルセアァァァアアア！！",
        --     TALK4_2 = "お姉さま！まさか闇の力に！？",
        --     TALK4_3 = "なーんてね。うっそー♪",
        --     TALK5_1 = "その目…本気のようねコルセア",
        --     TALK5_2 = "全力でこないと…",
        --     TALK5_3 = "ケガではすみませんよ！"
        -- }
    end

    self.HP_TRIGGERS = {
    }

    self.START_MESSAGES = {

    }



    --怒り時のメッセージ
    self.RAGE_MESSAGES = {

    }

    self.RAGE_MESSAGES2 = {

    }

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:startWave(event)
    -- summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.magenta);
    if self:sarchTalkTarget() then
        self:setUpTalk();
    else
        self:showMessages(event.unit,self.START_MESSAGES);
    end
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    self:callTalk(event.deltaTime);
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
    self.skillCheckFlg = false;
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    if event.index == 3 and not self.skillCheckFlg2 then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(3,1);
        return 0;
    end
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
    self.isRage = true;
    if not self:sarchTalkTarget() then
        self:addBuffs(unit,self.RAGE_BUFF_ARGS);
        self:showMessages(unit,self.RAGE_MESSAGES);
    else
        self:addBuffs(unit,self.RAGE_BUFF_ARGS);
        self:showMessages(unit,self.RAGE_MESSAGES2);
    end
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

--===================================================================================================================
--特殊会話
function class:setUpTalk()
    self.talkTables = {}
    self.talkTimer = 0;
    self.talkCalling = true;
    self.talkTables[0] = {
        [1] = {
            MESSAGE = self.TEXT.TALK1_1,
            COLOR = Color.cyan,
            DURATION = 3,
            ISPRAYER = true,
            DERAY = 0
        },
        [2] = {
            MESSAGE = self.TEXT.TALK1_2,
            COLOR = Color:new(0,180,255),
            DURATION = 3,
            ISPRAYER = false,
            DERAY = 3
        }
    }

    self.talkTables[1] = {
        [1] = {
            MESSAGE = self.TEXT.TALK2_1,
            COLOR = Color:new(0,180,255),
            DURATION = 3,
            ISPRAYER = false,
            DERAY = 0
        },
        [2] = {
            MESSAGE = self.TEXT.TALK2_2,
            COLOR = Color.cyan,
            DURATION = 3,
            ISPRAYER = true,
            DERAY = 3
        },
        [3] = {
            MESSAGE = self.TEXT.TALK2_3,
            COLOR = Color.cyan,
            DURATION = 3,
            ISPRAYER = true,
            DERAY = 6
        }
    }

    self.talkTables[2] = {
        [1] = {
            MESSAGE = self.TEXT.TALK3_1,
            COLOR = Color:new(0,180,255),
            DURATION = 3,
            ISPRAYER = false,
            DERAY = 0
        },
        [2] = {
            MESSAGE = self.TEXT.TALK3_2,
            COLOR = Color.cyan,
            DURATION = 3,
            ISPRAYER = true,
            DERAY = 3
        },
        [3] = {
            MESSAGE = self.TEXT.TALK3_3,
            COLOR = Color:new(0,180,255),
            DURATION = 3,
            ISPRAYER = false,
            DERAY = 6
        }
    }

    self.talkTables[3] = {
        [1] = {
            MESSAGE = self.TEXT.TALK4_1,
            COLOR = Color:new(0,180,255),
            DURATION = 3,
            ISPRAYER = false,
            DERAY = 0
        },
        [2] = {
            MESSAGE = self.TEXT.TALK4_2,
            COLOR = Color.cyan,
            DURATION = 3,
            ISPRAYER = true,
            DERAY = 3
        },
        [3] = {
            MESSAGE = self.TEXT.TALK4_3,
            COLOR = Color:new(0,180,255),
            DURATION = 3,
            ISPRAYER = false,
            DERAY = 6
        }
    }

    self.talkTables[4] = {
        [1] = {
            MESSAGE = self.TEXT.TALK5_1,
            COLOR = Color:new(0,180,255),
            DURATION = 3,
            ISPRAYER = false,
            DERAY = 0
        },
        [2] = {
            MESSAGE = self.TEXT.TALK5_2,
            COLOR = Color.cyan,
            DURATION = 3,
            ISPRAYER = true,
            DERAY = 3
        },
        [3] = {
            MESSAGE = self.TEXT.TALK5_3,
            COLOR = Color.cyan,
            DURATION = 3,
            ISPRAYER = true,
            DERAY = 6
        }
    }

    self.currentTalkTable = self.talkTables[summoner.Random.sampleWeighted(self.TALK_RATE)];

end


function class:callTalk(delta)
    if nil == self.currentTalkTable then
        return;
    end

    if not self.talkCalling then
        return;
    end

    self.talkTimer = self.talkTimer + delta;
    local isAll = true;


    for i = 1,table.maxn(self.currentTalkTable) do
        local v = self.currentTalkTable[i];
        if v ~= nil and v.DERAY <= self.talkTimer then     
            if v.ISPRAYER then
                summoner.Utility.messageByPlayer(v.MESSAGE,v.DURATION,v.COLOR)
            else
                summoner.Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR)
            end
            
            self.currentTalkTable[i] = nil;    
        end
        if v ~= nil then
            isAll = false;
        end
    end
    self.talkCalling = not isAll;
end

function class:sarchTalkTarget()
    for i=0,7 do
        local target = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i,true);
        if target ~= nil and target ~= unit and target:getBaseID3() == 2 then
            return true;
        end
    end
    return false;
end

--=====================================================================================================================================
function class:findSick(unit)
    
    if not self:getIsHost() then
        return;
    end
    local condValue = unit:getTeamUnitCondition():findConditionValue(94);
    if not self.isSick and condValue ~= 0 and not self.isSick then
        self:excuteSickAction(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
    end
    if self.isSick and condValue == 0 then
        self:excuteSickEndAction(unit);
    end
end

function class:excuteSickAction(unit)
    self.isSick = true;
    self:addBuffs(unit,self.SICK_BUFF_ARGS);
end

function class:excuteSickEndAction(unit)
    self.isSick = false;
    Utility.removeUnitBuffByID(unit,self.SICK_BUFF_ARGS[1].ID)
end

--=====================================================================================================================================
function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:excuteSickAction(self.gameUnit);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;