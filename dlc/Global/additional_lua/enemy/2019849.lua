local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="継戦_リオン", version=1.3, id=2019849});
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
    SKILL3 = 4
}

--怒り時にかかるバフ内容
class.HP50_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 17,         --ダメージアップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}


class.HP25_BUFF_ARGS = {
    {
        ID = 40076,
        EFID = 0,         --ダメージアップ
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
    self.isStartCheck = false;
    self.forceActiveSKill = 0;
    self.timeLimit = 180;
    event.unit:setSkillInvocationWeight(0);
    Color.orange = Color.orange or Color:new(233,163,38);
    self.HP_TRIGGERS = {
        [0] = {
            HP = 75,
            trigger = "HP75",
            isActive = true,
            oneShot = true
        },
        [1] = {
            HP = 50,
            trigger = "HP50OneShot",
            isActive = true,
            oneShot = true
        },
        [2] = {
            HP = 25,
            trigger = "HP25OneShot",
            isActive = true,
            oneShot = true
        },
        [3] = {
            HP = 50,
            trigger = "HP50",
            isActive = true,
            oneShot = false
        },
        [4] = {
            HP = 25,
            trigger = "HP25",
            isActive = true,
            oneShot = false
        }
    }

    if Color.orange == nil then
        Color.orange = Color:new(233,163,38);
    end

    --怒り時のメッセージ
    self.HP75_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP75_MESSAGE1 or "どれ、肩慣らしといこうか…",
            COLOR = Color.magenta,
            DURATION = 8
        }
    }

    self.HP50_ONESHOT_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "ほう…多少は腕が立つようだな",
            COLOR = Color.magenta,
            DURATION = 8
        }
    }

    self.HP25_ONESHOT_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP25_MESSAGE1 or "全力だ…壊れろ！",
            COLOR = Color.magenta,
            DURATION = 8
        }
    }

    self.HP50_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP50_MESSAGE2 or "ダメージアップ",
            COLOR = Color.orange,
            DURATION = 8
        }
    }

    self.HP25_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP25_MESSAGE2 or "奥義ゲージ速度アップ",
            COLOR = Color.orange,
            DURATION = 8
        }
    }

    self.TIMEUP_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.TIMEUP_MESSAGE1 or "タイムアップ！",
            COLOR = Color.red,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.TIMEUP_MESSAGE2 or "奥義ゲージ速度アップ",
            COLOR = Color.red,
            DURATION = 15
        }
    }


    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);

    self.hpMarkers = {}
    for i = 0,#self.HP_TRIGGERS do
        self.hpMarkers[self.HP_TRIGGERS[i].HP] = self.gameUnit:addNumHpMarker(self.HP_TRIGGERS[i].HP * 0.01)
    end
    return 1;
end

function class:startWave(event)
    -- summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.magenta);
    self:HPTriggersStartCheck(event.unit);
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit ,30, 620 , -100 ,0.8);
    return 1;
end

function class:update(event)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
       return 1;
    end
    self:HPTriggersCheck(event.unit);
    self:countDown(event.deltaTime);
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
    if self.forceActiveSKill ~= 0 then
        unit:setActiveSkill(self.forceActiveSKill);
        self.forceActiveSKill = 0;
        return;
    end
    unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
end


function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:attackDamageValue(event)
    if self.isBattleEnd then
        return 9999999;
    end
    return event.value;
end

--===================================================================================================================
--HPトリガー
function class:HPTriggersCheck(unit)
    if not self.isStartCheck then
        return;
    end
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

function class:HPTriggersStartCheck(unit)
    if not self:getIsHost() then
        return;
    end

    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

    for i,v in pairs(self.HP_TRIGGERS) do
        if v.HP >= hpRate and v.oneShot then
                v.isActive = false;
                self.gameUnit:removeHpMarker(self.hpMarkers[self.HP_TRIGGERS[i].HP])
        end
    end
    self.isStartCheck = true;
end

function class:excuteTrigger(unit,trigger)
    if trigger == "HP75" then
        self:HP75(unit);
        -- megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    if trigger == "HP50OneShot" then
        self:HP50OneShot(unit);
        return true;
    end

    if trigger == "HP50" then
        self:HP50(unit);
        return true;
    end

    if trigger == "HP25OneShot" then
        self:HP25OneShot(unit);
        return true;
    end

    if trigger == "HP25" then
        self:HP25(unit);
        return true;
    end

    return false;
end

--===================================================================================================================
--怒り関係

function class:HP75(unit)
    self:showMessage(self.HP75_MESSAGES);
    unit:addSP(100);
    self.forceActiveSKill = 4;
end

function class:HP50OneShot(unit)

    self:showMessage(self.HP50_ONESHOT_MESSAGES);
    unit:addSP(100);
    self.forceActiveSKill = 4;
end

function class:HP50(unit)
    self:showMessage(self.HP50_MESSAGES);
    self:addBuffs(unit,self.HP50_BUFF_ARGS);
    self.forceActiveSKill = 4;
end

function class:HP25OneShot(unit)
    self:showMessage(self.HP25_ONESHOT_MESSAGES);
    unit:addSP(100);
    self.forceActiveSKill = 4;
end

function class:HP25(unit)
    self:addBuffs(unit,self.HP25_BUFF_ARGS);
    self:showMessage(self.HP25_MESSAGES);
    self.spValue = 50;
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
      HP50_BUFFS = {
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

function class:countDown(deltaTime)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
       self.timeLimit = self.timeLimit - deltaTime;
    end

    if self.timeLimit < 0 then
        self.gameUnit:addSP(100);
        self.gameUnit:setInvincibleTime(10);
    end

    if self.timeLimit < 0 and not self.isBattleEnd then
        self.isBattleEnd = true;

        -- for i = 0,3 do
        --      local teamUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        --      if teamUnit ~= nil then
        --         teamUnit:setHP(0)
        --      end 
        -- end
        -- megast.Battle:getInstance():endBattle(false);
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