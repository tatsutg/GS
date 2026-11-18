local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="闇冥の遺跡_11層_ヴィラカーズ", version=1.3, id=2005537});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100,
    SKILL2 = 100,
    SKILL4 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6,
    SKILL3 = 7,
    SKILL4 = 8,
    SKILL5 = 7,    
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


class.HP60_BUFF_ARGS = {
    {
        ID = 40076,
        EFID = 17,         --ダメージアップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}

class.HP40_BUFF_ARGS = {
    {
        ID = 40077,
        EFID = 28,         --速度
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 7
    }
}

class.HP20_BUFF_ARGS = {
    {
        ID = 40078,
        EFID = 9,         --速度
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 36
    }
}

class.RAGE_BUFF_ARGS = {
    {
        ID = 40076,
        EFID = 17,         --ダメアップ
        VALUE = 500,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    {
        ID = 40077,
        EFID = 13,         --攻撃アップ
        VALUE = 500,        --効果量
        DURATION = 9999999,
        ICON = 3
    }
}

class.RAGE_BUFF_ARGS_FOR_PLAYER = {
    {
        ID = 40078,
        EFID = 21,         --被ダメアップ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 139
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
    self.hitStopReduceRate = 0;
    self.forceSkillIndex = 0;
    self.isDeadOK = false;
    self.finalAttack = false;


   self.endTimer = 0;

    self.HP_TRIGGERS = {
        [0] = {
            HP = 80,
            trigger = "hp80",
            isActive = true
        },
        [1] = {
            HP = 60,
            trigger = "hp60",
            isActive = true
        },
        [2] = {
            HP = 40,
            trigger = "hp40",
            isActive = true
        },
        [3] = {
            HP = 20,
            trigger = "hp20",
            isActive = true
        },
        [4] = {
            HP = 100,
            trigger = "hp100",
            isActive = true
        },
        [5] = {
            HP = 1,
            trigger = "hp1",
            isActive = true
        }

    }

    --怒り時のメッセージ
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "クリティカルダメージ無効",
            COLOR = Color.magenta,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "奥義ゲージ常に減少",
            COLOR = Color.magenta,
            DURATION = 10
        }
    }

    self.HP80_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP80_MESSAGE1 or "行動速度アップ",
            COLOR = Color.magenta,
            DURATION = 10
        }
    }

    self.HP60_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP60_MESSAGE1 or "ダメージアップ",
            COLOR = Color.magenta,
            DURATION = 10
        }
    }



    self.HP40_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP40_MESSAGE1 or "行動速度アップ",
            COLOR = Color.magenta,
            DURATION = 10
        }
    }

    self.HP20_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP20_MESSAGE1 or "奥義ゲージ速度アップ",
            COLOR = Color.magenta,
            DURATION = 10
        }
    }

    self.RAGE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "攻撃力アップ",
            COLOR = Color.red,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE2 or "与ダメージアップ",
            COLOR = Color.red,
            DURATION = 15
        },
        [2] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE3 or "味方ユニットの被ダメージアップ",
            COLOR = Color.red,
            DURATION = 15
        }
    }

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    event.unit:setSkin("rage");
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGERS) do
        if self.HP_TRIGGERS[index].HP ~= 100 then
            self.hpMarkers[self.HP_TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.HP_TRIGGERS[index].HP * 0.01)
        end
    end
    return 1;
end

function class:startWave(event)
    self:hp100(event.unit)
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", 300 ,30, 620 , -100 ,0.8);
    self:showMessage(self.START_MESSAGES);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    self:setReduceHitStop(event.unit);
    self:countDown(event.unit,event.deltaTime);
    return 1;
end

function class:run(event)
    if event.spineEvent == "forceDead" then
        event.unit:setHP(0);
    end
    return 1;
end
--===============================================================================================================================================

function class:countDown(unit,deltaTime)
    local beforTimer = self.endTimer;
    self.endTimer = self.endTimer + deltaTime;

    if self.endTimer > 300 and beforTimer <= 300 then
        for i=0,4 do
            local targetUnit = Battle:getInstance():getTeam(true):getTeamUnit(i);
            if targetUnit ~= nil then
                self:addBuffs(targetUnit,self.RAGE_BUFF_ARGS_FOR_PLAYER);
            end
        end
        self:addBuffs(unit,self.RAGE_BUFF_ARGS);
        self:showMessage(self.RAGE_MESSAGES);
    end
end

function class:setReduceHitStop(unit)
    unit:setReduceHitStop(2, self.hitStopReduceRate);
end

--===============================================================================================================================================


function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_WEIGHTS);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
   
    unit:takeAttack(tonumber(attackIndex));
    
    megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    return 0;
end

function class:takeAttack(event)

    if self.finalAttack then
        self.isDeadOK = true;
    end

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
        event.unit:setNextAnimationName("attack4");
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


function class:takeDamageValue(event)
    if event.unit:getHP() - event.value <= 0 and not self.isDeadOK then
        return event.unit:getHP() - 1;
    end
    return event.value;
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
                self.gameUnit:removeHpMarker(self.hpMarkers[self.HP_TRIGGERS[i].HP])
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "hp80" then
        self:hp80(unit);
        return true;
    end

    if trigger == "hp60" then
        self:hp60(unit);
        return true;
    end


    if trigger == "hp40" then
        self:hp40(unit);
        return true;
    end

    if trigger == "hp20" then
        self:hp20(unit);
        return true;
    end

    if trigger == "hp1" then
        self:hp1(unit);
        return true;
    end

    return false;
end


function class:hp100(unit)
    self.forceSkillIndex = 1;
    unit:addSP(unit:getNeedSP());
end


function class:hp80(unit)
    
    self.hitStopReduceRate = 1;
    self:showMessage(self.HP80_MESSAGES);
end

function class:hp60(unit)
    self:addBuffs(unit,self.HP60_BUFF_ARGS);
    self:showMessage(self.HP60_MESSAGES);
end


function class:hp40(unit)
    self:addBuffs(unit,self.HP40_BUFF_ARGS);
    self:showMessage(self.HP40_MESSAGES);
end

function class:hp20(unit)
    self:addBuffs(unit,self.HP20_BUFF_ARGS);
    self:showMessage(self.HP20_MESSAGES);
end


function class:hp1(unit)
    self.finalAttack = true;
    unit:setInvincibleTime(10);
    self.forceSkillIndex = 5;
    unit:addSP(unit:getNeedSP());
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self.isRage = true;
    self:showMessage(self.RAGE_MESSAGES);
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