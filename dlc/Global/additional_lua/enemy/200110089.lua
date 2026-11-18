local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="マールゼクス", version=1.3, id=200110089});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 100
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7,
    SKILL4 = 8

}

class.ATTACK_WEIGHTS_SWORD = {
    ATTACK2 = 100
}

class.ATTACK_WEIGHTS_LANCE = {
    ATTACK3 = 100
}


class.ATTACK_WEIGHTS_ARC = {
    ATTACK4 = 100
}

class.ATTACK_WEIGHTS_NONE = {
    ATTACK1 = 100
}

class.SKILL_WEIGHTS_SWORD = {
    SKILL1 = 100
}

class.SKILL_WEIGHTS_LANCE = {
    SKILL2 = 100
}

class.SKILL_WEIGHTS_ARC = {
    SKILL3 = 100
}






--怒り時にかかるバフ内容
class.HP80_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 17,         --樹ダメージ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26,
        SCRIPT = 70,
        SCRIPTVALUE1 = 3
    }
}

class.HP60_BUFF_ARGS = {
    {
        ID = 40076,
        EFID = 17,         --水ダメージ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26,
        SCRIPT = 70,
        SCRIPTVALUE1 = 2
    }
}

class.HP40_BUFF_ARGS = {
    {
        ID = 40077,
        EFID = 17,         --炎ダメージ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26,
        SCRIPT = 70,
        SCRIPTVALUE1 = 1
    }
}

class.HP20_BUFF_ARGS = {
    {
        ID = 40078,
        EFID = 17,         --ダメージ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}


class.BUFF_VALUE = 30;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 100;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.mode = 0;
    self.isChange = false;
    self.forceSkillIndex = 0;
    self.isLastAttack = false;
    self.isLastAttackCompleat = false;

    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [0] = {
            HP = 100,
            trigger = "endless",
            isActive = true
        },
        [1] = {
            HP = 80,
            trigger = "HP80",
            isActive = true
        },
        [2] = {
            HP = 60,
            trigger = "HP60",
            isActive = true
        },
        [3] = {
            HP = 50,
            trigger = "endless",
            isActive = true
        },
        [4] = {
            HP = 40,
            trigger = "HP40",
            isActive = true
        },
        [5] = {
            HP = 20,
            trigger = "HP20",
            isActive = true
        },
        [6] = {
            HP = 1,
            trigger = "endlessFinal",
            isActive = true
        }
    }

    --怒り時のメッセージ
    self.HP80_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "樹属性ダメージアップ",
            COLOR = Color.green,
            DURATION = 5
        }
    }

    self.HP60_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE2 or "水属性ダメージアップ",
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    self.HP40_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE3 or "炎属性ダメージアップ",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.HP20_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE4 or "与ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.SWORD_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE5 or "クリティカル率アップ",
            COLOR = Color.red,
            DURATION = 5
        }
    }

    self.LANCE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE6 or "無効化解除",
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    self.ARC_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE7 or "回避率アップ",
            COLOR = Color.green,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE8 or "状態異常攻撃",
            COLOR = Color.green,
            DURATION = 5
        }
    }




    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:startWave(event)
    -- summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.magenta);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    return 1;
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
    self.isChange = true;
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    -- if event.index == 3 and not self.skillCheckFlg2 then
    --     self.skillCheckFlg2 = true;
    --     event.unit:takeSkillWithCutin(3,1);
    --     return 0;
    -- end

    if event.index == 4 then
        event.unit:setInvincibleTime(10);
        self.mode = 0;
        self:changeTable(event.unit);
        if self.isLastAttack then
            self.isLastAttackCompleat = true;
        end
    end
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:excuteAction(event)
    if self.isChange then
        self:teleport(event.unit);
        return 0;
    end
    return 1;
end

function class:takeIdle(event)
    if self.mode ~= 0 then
        event.unit:setNextAnimationName("idle"..(self.mode + 1));
    end
    return 1;
end

function class:takeBack(event)
    if self.mode ~= 0 then
        event.unit:setNextAnimationName("back"..(self.mode + 1));
    end
    return 1;
end

function class:takeDamageValue(event)
    local result = event.unit:getHP() - event.value;
    if result <= 0 then
        if not self.isLastAttackCompleat then
            return event.unit:getHP() - 1;
        end
    end
    return event.value;
end


function class:run(event)
    if event.spineEvent == "askNext" then
        self:apper(event.unit);
    end
    if event.spineEvent == "addSP" then
        self:addSP(event.unit);
    end

    if event.spineEvent == "endless" then
        self:endless(event.unit);
    end

    if event.spineEvent == "silence" then
        self:silence(event.unit);
    end

    if event.spineEvent == "back" then
        event.unit:setPosition(-400,-70);
    end
    return 1;
end

function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

--===================================================================================================================
--テレポ

function class:teleport(unit)
    self.isChange = false;

    local animName = "teleport"..(self.mode + 1);

    unit:takeAnimation(0,animName,false);
    unit:takeAnimationEffect(0,"back",false);

    self.mode = (self.mode + 1) % 4;
    if self.mode == 0 then
        self.mode = 1;
    end
    self:changeTable(unit);

end

function class:apper(unit)
    local animName = "tpAppear"..(self.mode + 1);
    unit:takeAnimation(0,animName,false);
    unit:takeAnimationEffect(0,"tpAppear",false);
end

function class:changeTable(unit)
    if self.mode == 1 then
        self.ATTACK_WEIGHTS = self.ATTACK_WEIGHTS_SWORD;
        self.SKILL_WEIGHTS = self.SKILL_WEIGHTS_SWORD;
        unit:setSetupAnimationName("setUpSword");
        self:showMessage(self.SWORD_MESSAGES);
    end

    if self.mode == 2 then
        self.ATTACK_WEIGHTS = self.ATTACK_WEIGHTS_LANCE;
        self.SKILL_WEIGHTS = self.SKILL_WEIGHTS_LANCE;
        unit:setSetupAnimationName("setUpSpear");
        self:showMessage(self.LANCE_MESSAGES);
    end

    if self.mode == 3 then
        self.ATTACK_WEIGHTS = self.ATTACK_WEIGHTS_ARC;
        self.SKILL_WEIGHTS = self.SKILL_WEIGHTS_ARC;
        unit:setSetupAnimationName("setUpBow");
        self:showMessage(self.ARC_MESSAGES);
    end

    if self.mode == 0 then
        self.ATTACK_WEIGHTS = self.ATTACK_WEIGHTS_NONE;
        unit:setSetupAnimationName("setUpNormal");
    end
end

function class:endless(unit)

    local ob1 = unit:addOrbitSystemWithFile("50024Skill4Ef","skill4");
    local ob2 = unit:addOrbitSystemCameraWithFile("50024Skill4Ef2","skill4",false);
    local ob3 = unit:addOrbitSystemWithFile("50024Skill4Ef3","skill4");
    local ob4 = unit:addOrbitSystem("skill4Effect",0);

end

function class:silence(unit)
        --全員沈黙させる
        for i = 0,6 do
            local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
            if uni ~= nil then
                uni:getTeamUnitCondition():addCondition(-12,92,100,20,0);    
            end
        end
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

    if trigger == "HP80" then
        self:HP80(unit);
        return true;
    end

    if trigger == "HP60" then
        self:HP60(unit);
        return true;
    end

    if trigger == "HP40" then
        self:HP40(unit);
        return true;
    end

    if trigger == "HP20" then
        self:HP20(unit);
        return true;
    end

    if trigger == "endless" and unit:getBurstState() ~= kBurstState_active and unit.m_breaktime <= 0 then
        self.forceSkillIndex = 4;
        unit:addSP(unit:getNeedSP());
        return true;
    end
    if trigger == "endlessFinal" and unit:getBurstState() ~= kBurstState_active and unit.m_breaktime <= 0 then
        self.forceSkillIndex = 4;
        self.isLastAttack = true;
        unit:addSP(unit:getNeedSP());
        return true;
    end
    return false;
end

--===================================================================================================================
--怒り関係

function class:HP80(unit)
    self:addBuffs(unit,self.HP80_BUFF_ARGS);
    self:showMessage(self.HP80_MESSAGES);
end

function class:HP60(unit)
    self:addBuffs(unit,self.HP60_BUFF_ARGS);
    self:showMessage(self.HP60_MESSAGES);
end

function class:HP40(unit)
    self:addBuffs(unit,self.HP40_BUFF_ARGS);
    self:showMessage(self.HP40_MESSAGES);
end

function class:HP20(unit)
    self:addBuffs(unit,self.HP20_BUFF_ARGS);
    self:showMessage(self.HP20_MESSAGES);
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