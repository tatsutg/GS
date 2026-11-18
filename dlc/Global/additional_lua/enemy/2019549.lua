local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="", version=1.3, id=2019549});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50,
    ATTACK5 = 50,
    ATTACK6 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100,
    SKILL3 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    ATTACK5 = 5,
    ATTACK6 = 6,
    SKILL1 = 8,
    SKILL2 = 9,
    SKILL3 = 10
}



class.HP80_BUFF_ARGS = {
    {
        ID = 400751,
        EFID = 28,         --速度
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 7
    }
}

class.HP60_BUFF_ARGS = {
    {
        ID = 400752,
        EFID = 17,         --ダメージアップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    {
        ID = 400755,
        EFID = 0,         --アイコン用
        VALUE = 1,        --効果量
        DURATION = 9999999,
        ICON = 36
    }
}

class.HP40_BUFF_ARGS = {
    {
        ID = 400753,
        EFID = 17,         --ダメージアップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}

class.HP20_BUFF_ARGS = {
    {
        ID = 400754,
        EFID = 28,         --速度
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 7
    },
    {
        ID = 400756,
        EFID = 0,         --アイコン用
        VALUE = 1,        --効果量
        DURATION = 9999999,
        ICON = 36
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
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [0] = {
            HP = 100,
            trigger = "HP100",
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
            HP = 40,
            trigger = "HP40",
            isActive = true
        },
        [4] = {
            HP = 20,
            trigger = "HP20",
            isActive = true
        }
    }



    self.HP100_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP100_MESSAGE1 or "命中率アップ",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.HP100_MESSAGE2 or "敵暗闇状態時、クリティカル率アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.HP80_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP80_MESSAGE1 or "行動速度アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.HP60_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP60_MESSAGE1 or "ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.HP60_MESSAGE2 or "奥義ゲージ速度アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.HP40_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP40_MESSAGE1 or "ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.HP40_MESSAGE2 or "奥義ゲージ減少攻撃",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.HP20_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP20_MESSAGE1 or "行動速度アップ",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.HP20_MESSAGE2 or "奥義ゲージ速度アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }



    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {
        [80] = self.gameUnit:addNumHpMarker(0.8),
        [60] = self.gameUnit:addNumHpMarker(0.6),
        [40] = self.gameUnit:addNumHpMarker(0.4),
        [20] = self.gameUnit:addNumHpMarker(0.2)
    }
    return 1;
end

function class:startWave(event)
    -- summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.magenta);
    return 1;
end

function class:update(event)
    event.unit:setReduceHitStop(2,1);
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
    --if event.index == 3 and not self.skillCheckFlg2 then
    --    self.skillCheckFlg2 = true;
    --    event.unit:takeSkillWithCutin(3,1);
    --    return 0;
    --end
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end

function class:takeIdle(event)
    event.unit:setNextAnimationName("idle2");
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
        
        if v.HP >= hpRate and v.isActive then

            if self:excuteTrigger(unit,v.trigger) then

                v.isActive = false;
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "HP100" then
        self:HP100(unit);
        return true;
    end

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


    return false;
end

--===================================================================================================================
--怒り関係

function class:HP100(unit)
    self:showMessage(self.HP100_MESSAGES);
end

function class:HP80(unit)
    self:addBuffs(unit,self.HP80_BUFF_ARGS);
    self:showMessage(self.HP80_MESSAGES);
    self.gameUnit:removeHpMarker(self.hpMarkers[80])
end

function class:HP60(unit)
    self:addBuffs(unit,self.HP60_BUFF_ARGS);
    self:showMessage(self.HP60_MESSAGES);
    self.spValue = 25;
    self.gameUnit:removeHpMarker(self.hpMarkers[60])
end

function class:HP40(unit)
    self:addBuffs(unit,self.HP40_BUFF_ARGS);
    self:showMessage(self.HP40_MESSAGES);
    self.gameUnit:removeHpMarker(self.hpMarkers[40])
end

function class:HP20(unit)
    self:addBuffs(unit,self.HP20_BUFF_ARGS);
    self:showMessage(self.HP20_MESSAGES);
    self.spValue = 50;
    self.gameUnit:removeHpMarker(self.hpMarkers[20])
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