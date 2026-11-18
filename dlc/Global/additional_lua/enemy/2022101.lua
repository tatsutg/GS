local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="クロエ超襲来／真EX", version=1.3, id=2022101});
class:inheritFromUnit("unitBossBase");



class.ATTACK_REEL = {
    [1] = {
        ATTACK2 = 100,
        ATTACK1 = 100
    },
    [2] = {
        ATTACK1 = 100
    },
    [3] = {
        ATTACK2 = 100
    }
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

--怒り時にかかるバフ内容
class.FIRST_RIZ_BUFF_ARGS = {
    {
        ID = 400751,
        EFID = 13,         --攻撃アップ
        VALUE = 50,        --効果量
        DURATION = 9999999,
        ICON = 3
    },
    {
        ID = 400752,
        EFID = 15,         --攻撃アップ
        VALUE = 50,        --効果量
        DURATION = 9999999,
        ICON = 5
    }
}

class.SECOND_RIZ_BUFF_ARGS = {
    {
        ID = 400753,
        EFID = 17,         --ダメージアップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
    },
    {
        ID = 400754,
        EFID = 31,         --回避率アップ
        VALUE = 45,        --効果量
        DURATION = 9999999,
        ICON = 16
    }
}

class.THIRD_RIZ_BUFF_ARGS = {
    {
        ID = 400755,
        EFID = 28,         --速度
        VALUE = 15,        --効果量
        DURATION = 9999999,
        ICON = 7
    },
    {
        ID = 400756,
        EFID = 31,         --回避率アップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 16
    },
    {
        ID = 400757,
        EFID = 22,         --クリティカル率アップ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 11
    }
}

class.ARTS_BUFF_ARGS = {
    {
        ID = -400758,
        EFID = 17,         --与ダメ
        VALUE = 20,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}





class.FIRST_RIZ_HP = 0.6;
class.SECOND_RIZ_HP = 0.5;
class.THIRD_RIZ_HP = 0.4;
class.RIZ_CHANCE = 2;
class.SP_ADDITION_BORDER = 40;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.beforeArtsPoint = 0;
    self.deadCount = 0;
    self.canDead = false;
    self.isDead = false;
    self.hitstopReduceLevel = 100;
    self.hitStopReduceRate = 1;
    self.attackCounter = 0;
    self.forceSkillIndex = 0;
    self.isSpecialArts = false;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {

    }


    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "覚悟はよいでしょうか。",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "人族キラー",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.FIRST_RIZ_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.FIRST_RIZ_MESSAGE1 or "痛みは耐えきってみせます。",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.FIRST_RIZ_MESSAGE2 or "攻撃力・防御力アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.SECOND_RIZ_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.SECOND_RIZ_MESSAGE1 or "立ち上がります…何度でも。",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.SECOND_RIZ_MESSAGE2 or "回避率・与ダメージアップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.THIRD_RIZ_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.THIRD_RIZ_MESSAGE1 or "もう一度だけ、私に…力を！",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.THIRD_RIZ_MESSAGE2 or "回避率・クリティカル率アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.DEAD_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.DEAD_MESSAGE1 or "お見事です。",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }


    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:startWave(event)
    self:showMessage(self.START_MESSAGES);
    --event.unit:addSP(60);
    event.unit:setAttackDelay(4)
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    self:reduceHitStop(event.unit);
    self:HPGaze(event.unit);
    self:checkSpecialArts(event.unit);
    return 1;
end

--真奥義ブッパした後４０増えるやつ。真奥義ぶっぱ前の値を保存しておいて、あとから追加
function class:checkSpecialArts(unit)
    if self.isSpecialArts then
        self.isSpecialArts = false;
        if self.beforeArtsPoint < self.SP_ADDITION_BORDER then
            unit:addSP(self.SP_ADDITION_BORDER);
        else
            unit:addSP(self.beforeArtsPoint);
        end
    end
end

function class:reduceHitStop(unit)
   unit:setReduceHitStop(self.hitstopReduceLevel, self.hitStopReduceRate);
end

function class:HPGaze(unit)
    if not self:getIsHost() then
        return;
    end
    if unit:getHP() <= 1 then
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,self.deadCount);
        self:onDie(self.deadCount);

        self.gameUnit:takeIdle();

        self.gameUnit:excuteAction();
    end
end

function class:onDie(deadCount)
    self.beforeArtsPoint = self.gameUnit:getBurstPoint();
    if deadCount >= self.RIZ_CHANCE then
        self:showMessage(self.DEAD_MESSAGES);
        self.isDead = true;
        self.gameUnit:setHP(0);
        return;
    end

    if deadCount == 0 then
        self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * self.FIRST_RIZ_HP);
        self:addBuffs(self.gameUnit,self.FIRST_RIZ_BUFF_ARGS);
        self:showMessage(self.FIRST_RIZ_MESSAGES);
        self.forceSkillIndex = 3;
        self.gameUnit:addSP(self.gameUnit:getNeedSP());
        self.gameUnit:setInvincibleTime(6);
    end

    if deadCount == 1 then
        self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * self.SECOND_RIZ_HP);
        self:addBuffs(self.gameUnit,self.SECOND_RIZ_BUFF_ARGS);
        self:showMessage(self.SECOND_RIZ_MESSAGES);
        self.forceSkillIndex = 3;
        self.gameUnit:addSP(self.gameUnit:getNeedSP());
        self.gameUnit:setInvincibleTime(6);
    end

    if deadCount == 2 then
        self.gameUnit:setHP(self.gameUnit:getCalcHPMAX() * self.THIRD_RIZ_HP);
        self:addBuffs(self.gameUnit,self.THIRD_RIZ_BUFF_ARGS);
        self:showMessage(self.THIRD_RIZ_MESSAGES);
        self.forceSkillIndex = 3;
        self.gameUnit:addSP(self.gameUnit:getNeedSP());
        self.gameUnit:setInvincibleTime(6);
    end

    self.deadCount = self.deadCount + 1;
end


function class:dead(event)
   if not self.isDead then
      event.unit:setHP(1);
      return 0;
   end
   return 1;
end


function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_REEL[self.attackCounter % table.maxn(self.ATTACK_REEL) + 1]);
    local attackIndex = string.gsub(attackStr,"ATTACK","");
    self.attackCounter = self.attackCounter + 1;
    if tonumber(attackIndex) == 1 then
        unit:takeAttack(tonumber(attackIndex));
    else
        self.skillCheckFlg = true;
        self.attackCheckFlg = false;
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
    event.unit:setNextAnimationName("attack"..event.index.."Boss");
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
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    self:specialBuffCheck(event.unit,event.index);
    event.unit:setNextAnimationName("skill"..event.index.."Boss");
    return 1
end

function class:specialBuffCheck(unit,index)
    if index == 2 and self.deadCount >= 3 then
        self:addBuffs(unit,self.ARTS_BUFF_ARGS);
    end
    if index == 3 then
        self.isSpecialArts = true;
    end
end


function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:takeFront(event)
    event.unit:setNextAnimationName("frontBoss");
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
    return false;
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
    self:onDie(args.arg);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;