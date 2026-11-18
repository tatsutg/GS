--@additionalEnemy,2011805
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="", version=1.3, id=2011801});
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
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 5
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 20118011,
        EFID = 23,         --クリティカル耐性
        VALUE = -1000,        --効果量
        DURATION = 9999999,
        ICON = 188
    },
    {
        ID = 20118013,
        EFID = 17,         --ダメージアップ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}

--時間切れでかかるバフ内容
class.TIMEUP_BUFF_ARGS = {
    {
        ID = 20118014,
        EFID = 7,         --自然回復
        VALUE = 200000,        --効果量
        DURATION = 9999999,
        ICON = 35
    },
    {
        ID = 20118015,
        EFID = 17,         --ダメージアップ
        VALUE = 1000,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}

--ブレイク時以外のダメージ耐性
class.CUT_BUFF_ARGS = {
    {
        ID = 20118012,
        EFID = 21,         --ダメージカット
        VALUE = -75,        --効果量
        DURATION = 9999999,
        ICON = 20,
        SCRIPT = 58
    }
}

class.BUFF_VALUE = 30;
class.SUMMON_ENEMY_ID = 2011805;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.forceSkillIndex = 0;
    self.especialActiveSkill = 0;
    self.phoenixActive = true;
    self.hasBreak = false;
    self.safetyTimer = 3;
    self.timeLimit = 600;
    self.canDie = false;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [0] = {
            HP = 50,
            trigger = "hpFlg50",
            isActive = true
        },
        [1] = {
            HP = 20,
            trigger = "hpFlg20",
            isActive = true
        }
    }

    --怒り時のメッセージ
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "奥義ダメージ軽減",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "炎属性耐性・キラー",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [2] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "命中・ブレイク耐性アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

     --怒り時のメッセージ
    self.HP50_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "ちょっと黙ってろよ！",
            COLOR = Color.cyan,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.HP50_MESSAGE2 or "奥義ゲージ上昇量アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

     --怒り時のメッセージ
    self.HP20_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP20_MESSAGE1 or "絶対に許さない…！",
            COLOR = Color.cyan,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.HP20_MESSAGE2 or "ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    --怒り時のメッセージ
    self.RAGE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "お前じゃ勝てねぇよ！",
            COLOR = Color.red,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE2 or "オレの邪魔をするな…！",
            COLOR = Color.cyan,
            DURATION = 5
        },
        [2] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE3 or "クリティカル無効",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [3] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE4 or "奥義ゲージ上昇量さらにアップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.BREAK_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.BREAK_MESSAGE1 or "奥義ダメージ軽減解除",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.BREAK_END_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "奥義ダメージ軽減",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.TIMEUP_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.TIMEUP_MESSAGE1 or "もう飽きたよ",
            COLOR = Color.cyan,
            DURATION = 5
        }
    }

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {}
    for index,trigger in pairs(self.HP_TRIGGERS) do
        self.hpMarkers[self.HP_TRIGGERS[index].HP] = self.gameUnit:addNumHpMarker(self.HP_TRIGGERS[index].HP * 0.01)
    end
    return 1;
end

function class:startWave(event)
    self:startDash(event.unit);
    self:addDamageCut(event.unit);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    event.unit:setReduceHitStop(2,1);--ヒットストップ無効Lv2　10割軽減
    self:countDownSafetyTimer(event.deltaTime);
    self:checkDamageCutBuff(event.unit);
    self:countDownForBattleEnd(event.unit,event.deltaTime);
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
    self:attackActiveSkillSetter(event.unit,event.index);
    self:addSP(event.unit);
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");
    if self.isRage then
        skillIndex = 3;
    end
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
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    return 1
end


function class:skillActiveSkillSetter(unit,index)
    if self.especialActiveSkill ~= 0 then
        unit:setActiveSkill(self.especialActiveSkill);
        self.especialActiveSkill = 0;
    else
        unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
    end
end

function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:dead(event)
    if self.safetyTimer > 0 then
        event.unit:setHP(1);
        if not self.isRage and self:getIsHost() then
            self:getRage(event.unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
        end
        event.unit:getTeam():setBoss(event.unit);
        return 0;
    end

    for i = 0, 5 do
        local enemy = event.unit:getTeam():getTeamUnit(i,true);
        if enemy ~= nil then
            enemy:setHP(0);
        end
    end
    return 1;
end


function class:takeBreake(event)
    self:removeDamageCut(event.unit);
    self.hasBreak = true;
    return 1;
end

function class:takeDamageValue(event)
    if self.safetyTimer > 0 then
        self:damageRejection(event.unit,event.value);
    end
    return event.value;
end

function class:damageRejection(unit,value)
    if unit:getHP() - value <= 0 then
        unit:setHP(1);
        if not self.isRage and self:getIsHost() then
            self:getRage(unit);
            megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
        end
        return unit:getHP() - 1;
    end
    return value;
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
                self.gameUnit:removeHpMarker(self.hpMarkers[v.HP])
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "hpFlg50" and unit:getBreakPoint() > 0 and unit:getBurstState() ~= kBurstState_active then
        self:hpFlg50(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end

    if trigger == "hpFlg20" and unit:getBreakPoint() > 0 and unit:getBurstState() ~= kBurstState_active then
        self:hpFlg20(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
        return true;
    end

    return false;
end

--===================================================================================================================
--HPトリガー

function class:startDash(unit)
    unit:addSP(unit:getNeedSP());
    self.especialActiveSkill = 4;
    self:showMessage(self.START_MESSAGES);
end

function class:hpFlg50(unit)
    unit:addSP(unit:getNeedSP());
    self.forceSkillIndex = 3;
    self.especialActiveSkill = 6;
    self:showMessage(self.HP50_MESSAGES);
    self.spValue = 40;
end

function class:hpFlg20(unit)
    unit:addSP(unit:getNeedSP());
    self.forceSkillIndex = 3;
    self:showMessage(self.HP20_MESSAGES);
end

function class:getRage(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self.isRage = true;
    unit:setHP(unit:getCalcHPMAX()/2);
    self:showMessage(self.RAGE_MESSAGES);
    self.spValue = 60;
    self:summon(unit);
end


function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end

function class:countDownForBattleEnd(unit,deltaTime)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end
    self.timeLimit = self.timeLimit - deltaTime;
    if self.timeLimit <= 0 and not self.isTimeUp then
        self:timeUp(unit);
        self.isTimeUp = true;
    end
end


function class:timeUp(unit)
    self:addBuffs(unit,self.TIMEUP_BUFF_ARGS);
    self:showMessage(self.TIMEUP_MESSAGES);
end

--===================================================================================================================
--死亡周り

function class:countDownSafetyTimer(deltaTime)
    if self.isRage then
        self.safetyTimer = self.safetyTimer - deltaTime;
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


function class:removeBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:removeBuff(unit,v);
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

function class:removeBuff(unit,args)
    local buff = unit:getTeamUnitCondition():findConditionWithID(args.ID);
    if buff ~= nil then
        unit:getTeamUnitCondition():removeCondition(buff);
    end
end

--=====================================================================================================================================
--ブレイク時のダメージ耐性周り

function class:checkDamageCutBuff(unit)
    if self.hasBreak and unit:getBreakPoint() > 0 then
        self:addDamageCut(unit);
        self.hasBreak = false;
        self:showMessage(self.BREAK_END_MESSAGES);
    end
end

function class:addDamageCut(unit)
    self:addBuffs(unit,self.CUT_BUFF_ARGS);
end

function class:removeDamageCut(unit)
    self:showMessage(self.BREAK_MESSAGES);
    self:removeBuffs(unit,self.CUT_BUFF_ARGS);
end



--===============================================================================================================================================
function class:summon(unit)

    if not self:getIsHost() then
        return;
    end
    --0~5の場所が空席ならユニット召喚
    for i=0,5 do
        if unit:getTeam():getTeamUnit(i) == nil then
            unit:getTeam():addUnit(i,self.SUMMON_ENEMY_ID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
            return;
        end
    end

    
    return;
end

--=====================================================================================================================================
function class:receive3(args)
    self:hpFlg50(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:hpFlg20(self.gameUnit);
    return 1;
end

function class:receive5(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;