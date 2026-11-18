local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="", version=1.3, id=2020631});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL2 = 100,
    SKILL3 = 50
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

--怒り時にかかるバフ内容
class.HP20_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 28,         --速度
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 7
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
    self.isOverHeat = false;
    self.isRage = false;
    self.aura = nil;
    self.heatTimer = 0;
    self.count = 0;
    self.gage = nil;
    self.nowAnimationNum = 0;
    self.isInit = false;
    self.forceSkillIndex = 0;
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [0] = {
            HP = 50,
            trigger = "HP50",
            isActive = true
        },
        [1] = {
            HP = 20,
            trigger = "HP20",
            isActive = true
        }
    }

    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "さあ祈れ、懺悔の時間だああ！",
            COLOR = Color.green,
            DURATION = 5
        }
    }

    --怒り時のメッセージ
    self.HP50_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP50_MESSAGE1 or "憎い憎い憎い憎い憎い憎いぃぃい！！",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    self.HP20_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP20_MESSAGE1 or "行動速度アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }


    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {
        [50] = self.gameUnit:addNumHpMarker(0.5),
        [20] = self.gameUnit:addNumHpMarker(0.2)
    }
    return 1;
end

function class:startWave(event)
    self:showMessage(self.START_MESSAGES);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);

    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return 1;
    end
    if not self.isInit then
        self:initGage(event);
    end
    if self.isOverHeat then
        self:auraControl(event.unit);
    end
    self:pointControll(event.unit);
    self:gageControl(event.unit);
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
    if event.index == 3 and not self.skillCheckFlg2 and self.isOverHeat then
        self.skillCheckFlg2 = true;
        event.unit:takeSkillWithCutin(3,1);
        return 0;
    end
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    if event.index == 3 then
        if self.isOverHeat then
            event.unit:setNextAnimationName("skill3_2");
            event.unit:setNextAnimationEffectName("skill3_2");
        end
    end
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
        
        if v.HP >= hpRate and v.isActive then

            if self:excuteTrigger(unit,v.trigger) then

                v.isActive = false;
            end
        end
    end

end

function class:excuteTrigger(unit,trigger)
    if trigger == "HP50" then
        self:HP50(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end

    if trigger == "HP20" then
        self:HP20(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end
    return false;
end

--===================================================================================================================
--怒り関係

function class:HP50(unit)
    self.SKILL_WEIGHTS = {
        SKILL2 = 100,
        SKILL3 = 50
    }
    self.forceSkillIndex = 3;
    self.count = 100;
    self:overHeat(unit);
    unit:addSP(100);
    unit:setInvincibleTime(8);
    self:showMessage(self.HP50_MESSAGES);
    self.gameUnit:removeHpMarker(self.hpMarkers[50])
end

function class:HP20(unit)
    self.SKILL_WEIGHTS = {
        SKILL3 = 100
    }

    self:addBuffs(unit,self.HP20_BUFF_ARGS);
    
    self:showMessage(self.HP20_MESSAGES);
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

function class:pointControll(unit)
    local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;
    hpRate = math.ceil(hpRate);
    if not self.isOverHeat then
        self.count = (100 - hpRate) * 2;
    else
        self.count = hpRate * 2;
    end

end


function class:overHeat(unit)
    if self.isOverHeat then
        self:finishOverHeat(unit);
    end
    self.isOverHeat = true;
    self.skillCounter = 0;
    self.count = 100;
    self.aura = unit:addOrbitSystem("aura");
    self.aura:takeAnimation(0,"aura",true);
    local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");
    self.aura:setPosition(targetx,targety);
    self.aura:setAutoZOrder(true);
    -- self:addBuffs(unit,self.HATE_BUFFS);

    self.ACTIVE_SKILLS = {
        ATTACK1 = 1,
        SKILL1 = 2,
        SKILL2 = 3,
        SKILL3 = 5
    }

    self.gage:takeAnimation(1,"light",true);
    -- unit:getBurstSkill2():setDamageRate(self.skill3DamageRate + self.ADD_RATE);
end

function class:finishOverHeat(unit)
    if not self.isOverHeat then
        return;
    end
    self.isOverHeat = false;
    self.heatTimer = 0;
    self:auraEnd(unit);
    self.gage:takeAnimation(1,"none",true);
    self.count = 0;
    -- unit:getBurstSkill2():setDamageRate(self.skill3DamageRate);
    self:removeBuffs(unit,self.HATE_BUFFS);
end


function class:initGage(event)
    self.isInit = true;
    if self.gage == nil then
        self.gage = self.gameUnit:addOrbitSystemWithFile("10307gage","0");
        self.gage:takeAnimation(0,"0",true);
    end

    local isPlayer = event.unit:getisPlayer();
    if isPlayer then
        self.gage:getSkeleton():setScaleX(-1);
    end
end

function class:auraControl(unit)
    if self.aura == nil then
        return;
    end
    local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");


    local isPlayer = unit:getisPlayer();
    if not isPlayer then
        targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * -1;
    end

    self.aura:setPosition(targetx,targety);
    self.aura:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY());
end

function class:auraEnd(unit)
    self.aura:takeAnimation(0,"empty",false);
    self.aura = nil;
end



function class:gageControl(unit)
    if self.gage == nil then
        return;
    end
    local targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN");
    local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN");

    local isPlayer = unit:getisPlayer();
    if not isPlayer then
        targetx = unit:getPositionX() + unit:getSkeleton():getBoneWorldPositionX("MAIN") * -1;
    end

    self.gage:setPosition(targetx,targety);
    self.gage:getSkeleton():setPosition(0,unit:getSkeleton():getPositionY() + 80);
    local animationNum = self.count/5;

    if self.isOverHeat then
        animationNum = math.ceil(animationNum);
    else
        animationNum = math.floor(animationNum);
    end
    if animationNum > 20 then
        animationNum = 20;
    end
    if animationNum ~= self.nowAnimationNum then
        self.gage:setAnimation(0,""..animationNum,true);
        self.nowAnimationNum = animationNum;
    end
    
end

--=====================================================================================================================================
function class:receive3(args)
    self:HP50(self.gameUnit);
    return 1;
end

function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;