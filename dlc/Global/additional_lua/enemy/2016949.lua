local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="ロイ　チャレンジクエスト", version=1.3, id=2016949});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

class.ATTACK_WEIGHTS_FOR_RAGE = {
    ATTACK3 = 100
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK3 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    [1] = {
        ID = 40075,
        EFID = 14,         --防御アップ固定値
        VALUE = 200000,        --効果量
        DURATION = 9999999,
        ICON = 5
    }
}

--怒り時にかかるバフ内容
class.ARTS_BUFF_ARGS = {
    [1] = {
        ID = 40076,
        EFID = 17,         --与ダメアップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    [2] = {
        ID = 40077,
        EFID = 13,         --攻撃力アップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 3
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
    self.isDead = false;
    self.forceSkillIndex = 0;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [0] = {
            HP = 50,
            trigger = "getRage",
            isActive = true
        },
        [1] = {
            HP = 15,
            trigger = "artsMode",
            isActive = true
        }
    }

    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "ロイ：クリティカル耐性",
            COLOR = Color.cyan,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "ロイ：クリティカルダメージアップ",
            COLOR = Color.cyan,
            DURATION = 15
        },
        [2] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "ロイ：ブレイク耐性",
            COLOR = Color.cyan,
            DURATION = 15
        },
        [3] = {
            MESSAGE = self.TEXT.START_MESSAGE4 or "ロイ：HP自然回復",
            COLOR = Color.cyan,
            DURATION = 15
        }
    }


    --怒り時のメッセージ
    self.RAGE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "鉄壁：防御力大幅アップ",
            COLOR = Color.cyan,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE2 or "ブレイクで鉄壁状態解除",
            COLOR = Color.cyan,
            DURATION = 15
        }
    }

    self.BREAK_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.BREAK_MESSAGE1 or "鉄壁状態解除",
            COLOR = Color.cyan,
            DURATION = 15
        }
    }    

    self.ARTS_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.ARTS_MESSAGE1 or "蒼神覇吼剣｢絶界｣の構え",
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    self.LAST_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.LAST_MESSAGE1 or "ロイ：攻撃力アップ",
            COLOR = Color.cyan,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.LAST_MESSAGE2 or "ロイ：与ダメージアップ",
            COLOR = Color.cyan,
            DURATION = 15
        }
    }


    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:startWave(event)
    self:showMessage(self.START_MESSAGES);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    event.unit:setReduceHitStop(2,1)
    if self.isDead then
        event.unit:setBurstPoint(0);
        event.unit:setHitStopTimeSelf(0);
        
        event.unit:setBreakPoint(10000000);
        event.unit:takeAnimation(0,"back2",false);
        self.isDead = false;
    end
    return 1;
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    if tonumber(attackIndex) ~= 2 then
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
    if event.index == 3 then
        event.unit:setBurstPoint(0);
        self:showMessage(self.ARTS_MESSAGES);
        self.forceSkillIndex = 3;
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
    if event.index >= 2 then
        self:rayusSkill(event.unit);
    end
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end



-- function class:takeDamageValue(event)
--     local result = event.unit:getHP() - event.value;
--     if result <= 0 then
--         event.unit:setInvincibleTime(7);
--         self.isDead = true;
--         return event.unit:getHP() - 1;
   
--     end
--     return event.value;
-- end

function class:takeBreakeDamageValue(event)
    if event.unit:getHP() == 1 then
        return 0;
    end
    return event.value;
end

function class:takeBreake(event)
    
    local buff = event.unit:getTeamUnitCondition():findConditionWithID(self.RAGE_BUFF_ARGS[1].ID);
    if buff ~= nil then
        self:showMessage(self.BREAK_MESSAGES);
        event.unit:getTeamUnitCondition():removeCondition(buff);
    end
    return 1;
end

function class:run(event)
    if event.spineEvent == "deadCompleat" then
        event.unit:setHP(0);
        event.unit:setPosition(-1000,0);
    end
    if event.spineEvent == "addSP" then
        self:addSP(event.unit);
    end
    return 1;
end


function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:rayusSkill(unit)
    for i=0,7 do
        local target = unit:getTeam():getTeamUnit(i);
        if target ~= nil and target ~= unit and target:getBaseID3() == 101 then
            target:addSP(target:getNeedSP());
        end
    end
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
    if trigger == "artsMode" then
        self:artsMode(unit);
        return true;
    end
    return false;
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self.isRage = true;
    self:showMessage(self.RAGE_MESSAGES);
end

function class:artsMode(unit)
    self:addBuffs(unit,self.ARTS_BUFF_ARGS);
    self:showMessage(self.LAST_MESSAGES);
    self.ATTACK_WEIGHTS = self.ATTACK_WEIGHTS_FOR_RAGE;

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