local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="魔獣　チャレンジクエスト用", version=1.3, id=2012649});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK5 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 50
}

class.ACTIVE_SKILLS = {
    ATTACK5 = 2,
    SKILL1 = 1
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 21,         --ダメージ軽減
        VALUE = -80,        --効果量
        DURATION = 60,
        ICON = 20,
        EFFECT = 1
    }
}


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.breakCount = 0;
    self.timeLimit = 120;
    self.timeCount = 0;
    self.delay = 8;
    self.isBattleEnd = false;
    self.isShowResult = false;
    self.isWin = false;
    self.isFirst = true;
    self.sendEventTimer = 0;
    self.isBreak = false;
    self.isHide = false;
    self.inEnd = false;
    self.isShowMessage = false;
    
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [0] = {
            HP = 50,
            trigger = "getRage",
            isActive = true
        }
    }

    self.delaySummonIndexes = {};

   event.unit:setSkin("rage");

    self:setupMessage();
    

    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self:setupMessage();
    return 1;
end

function class:setupMessage()
    self.BARRIER_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.BARRIER_MESSAGE or "バリア解除",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }
end

function class:run(event)
    if event.spineEvent == "specialIn" and not self.inEnd then
        self.inEnd = true;
        event.unit:takeAnimation(0,"in2",false);
        megast.Battle:getInstance():setBossCounterElement(0);
        event.unit:setElementType(0);
    end
    if event.spineEvent == "specialOut" then
        event.unit:takeAnimation(0,"out2",false);
    end
    if event.spineEvent == "hide" then
        self.isHide = true;
    end

    if event.spineEvent == "showEndTalk" then
        self:showEndTalk();
    end

    if event.spineEvent == "gameEnd" then
        self:gameEnd();
    end

    if event.spineEvent == "chargeEnd" then
        event.unit:takeAnimation(1,"charge_loop",true);
        event.unit:takeAnimationEffect(1,"charge_long",true);
    end

    if event.spineEvent == "addSP" then
        self:addSP(event.unit);
    end
   return 1
end

function class:startWave(event)
    self.isHide = false;
    event.unit:setPosition(-2000,0);
    event.unit._ignoreBorder = true;
    event.unit:takeAnimation(0,"in3",false);
    self:addBuffs(event.unit,self.RAGE_BUFF_ARGS);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    if self.isHide then
        event.unit:setPosition(-10000,-10000);
        event.unit:getSkeleton():setPosition(0,0);--見た目上のズレも無くす
        event.unit._ignoreBorder = true;--アニメーションの更新があっても外に居られるようにする
    end
    self:countUp(event.deltaTime);
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
    -- self:addSP(event.unit);
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
    event.unit:takeAnimation(1,"skill1",false);
    event.unit:takeAnimationEffect(1,"empty",false);
    return 1
end




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end


function class:dead(event)
    event.unit:takeAnimation(1,"out2",false);
    event.unit:takeAnimationEffect(1,"empty",false);
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
    if trigger == "getRage" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    return false;
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self.isRage = true;
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


function class:countUp(deltaTime)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
       self.timeCount = self.timeCount + deltaTime;
    end

    if self.timeCount > 60 and not self.isShowMessage then
        self.isShowMessage = true;
        self:showMessage(self.BARRIER_MESSAGES);
    end

    self.gameUnit:setBurstPoint(self.gameUnit:getNeedSP() * self.timeCount/self.timeLimit);
end


function class:gameEnd()
    for i=0,7 do
        local target = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
        if target ~= nil then
            target:setHP(0);
        end
    end
end


--=====================================================================================================================================




function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;