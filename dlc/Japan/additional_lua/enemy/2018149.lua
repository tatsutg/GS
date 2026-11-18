local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="", version=1.3, id=2018149});
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
    ATTACK2 = 2,
    SKILL1 = 2,
    SKILL2 = 3,
    SKILL3 = 4
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 7,         --自然回復
        VALUE = 1000000,        --効果量
        DURATION = 9999999,
        ICON = 35
    }
}

class.GAMEEND_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 0,         --ダメージアップ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 78
    }
}


class.BUFF_VALUE = 30;
class.CLEAR_BORDER = 300 * 10000;
class.SHOWDAMAGE_BORDER_ONEHIT = 50 * 10000;
class.SHOWDAMAGE_BORDER_TOTAL = 300 * 10000;
class.SHOWDAMAGE_BORDER = 10 * 10000;
class.SHOWDAMAGE_BORDER_AFTER = 100 * 10000;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 0;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    event.unit:setSkillInvocationWeight(0);
    self.timeCount = 0;
    self.healTimer = 0;
    self.totalDamage = 0;
    self.maxDamage = 0;
    self.exponent = 1;
    self.isShowenLimitHealMess = false;
    self.healLimitTime = 50;
    self.healLimitBorder = 10000 * 10000;
    self.damageLimitTime = 50;
    self.damageRatio = 1;
    self.isShowenLimitDamageMess = false;
    self.timeLimit = 121;
    self.delay = 5;
    self.isWin = false;
    self.isGameOver = false;

    self.TEXT.RESULT_MESSAGE1 = self.TEXT.RESULT_MESSAGE1 or "累計";
    self.TEXT.RESULT_MESSAGE2 = self.TEXT.RESULT_MESSAGE2 or "ダメージ！！";
    self.TEXT.RESULT_MESSAGE3 = self.TEXT.RESULT_MESSAGE3 or "最大一撃ダメージ：";
    self.TEXT.DAMAGE_MESSAGE1 = self.TEXT.DAMAGE_MESSAGE1 or "%d万";
    self.TEXT.DAMAGE_MESSAGE2 = self.TEXT.DAMAGE_MESSAGE2 or "%d億";
    self.TEXT.DAMAGE_MESSAGE3 = self.TEXT.DAMAGE_MESSAGE3 or "ダメージ！！";
    self.TEXT.DAMAGE_MESSAGE4 = self.TEXT.DAMAGE_MESSAGE4 or "一撃で";
    self.TEXT.DAMAGE_MESSAGE5 = self.TEXT.DAMAGE_MESSAGE5 or "ダメージ！！";

    event.unit:setSkin("normal");


    self.HP_TRIGGERS = {
        [0] = {
            HP = 20,
            trigger = "getRage",
            isActive = true
        }
    }

    --敗北メッセージ
    self.LOSE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.LOSE_MESSAGE1 or "累計3００万ダメージに届かなかった……",
            COLOR = Color.cyan,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.LOSE_MESSAGE2 or "奥義ゲージ増加速度アップ",
            COLOR = Color.cyan,
            DURATION = 15
        }
    }

    --開幕
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE4 or "１２０秒以内に3００万ダメージでクリア！",
            COLOR = Color.yellow,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE5 or "魔法ダメージ無効",
            COLOR = Color.magenta,
            DURATION = 15
        }
    }
    


    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self.hpMarkers = {
        [20] = self.gameUnit:addNumHpMarker(0.2)
    }
    return 1;
end

function class:startWave(event)
    self:showMessage(self.START_MESSAGES);
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit ,30, 620 , -100 ,0.8);
    -- summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.magenta);
    return 1;
end

function class:update(event)
    self:countDown(event.deltaTime);
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return 1;
    end
    if self.isGameOver then
        event.unit:addSP(100);
        -- event.unit:setInvincibleTime(5);
    end
    self:HPTriggersCheck(event.unit);
    -- self:autoHeal(event.unit,event.deltaTime);
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


function class:takeDamageValue(event)
    if self.isGameOver then
        local  targetUnit = event.enemy;

        if targetUnit:getParentTeamUnit() ~= nil then
            targetUnit = targetUnit:getParentTeamUnit();
        end
        local reflection = math.floor(event.value * 0.02);
        reflection = reflection <= 0 and 1 or reflection;
        targetUnit:setHP(targetUnit:getHP() - reflection);
        targetUnit:takeDamagePopup(event.unit,reflection);
        return event.value;
    end
    return self:damageAmp(event.value,event.unit);
end

function class:attackDamageValue(event)
    if self.isGameOver then
        for i=0,4 do
            local  playerUnit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
            if playerUnit ~= nil then
                playerUnit:setHP(playerUnit:getHP() - 9999);
                playerUnit:takeDamagePopup(event.unit,9999);
            end
        end
        return 9;
    end
    return event.value;
end

function class:takeBreakeDamageValue(event)
    -- event.unit:setBreakPoint(1000000);
    return event.value;
end


function class:dead(event)
    return 1;
end




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:countDown(deltaTime)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
       self.timeLimit = self.timeLimit - deltaTime;
    end

    if self.timeLimit < 0 and not self.isBattleEnd then
        self:gameEnd();
    end

    if self.isBattleEnd then
        self.delay = self.delay - deltaTime;
    end

    if self.delay < 0 and not self.isShowResult then
        
        if self.isWin then
            megast.Battle:getInstance():waveEnd(self.isWin);
        end
        self.isShowResult = true;
    end
end

function class:gameEnd()
    
    self:showMaxDamage();
    self:showTotalDamageLast();
    self.isBattleEnd = true;
    if self.totalDamage > self.CLEAR_BORDER then
        self.isWin = true;
        megast.Battle:getInstance():setBattleState(kBattleState_none);
    else
        self.isGameOver = true;
        self:showMessage(self.LOSE_MESSAGES);
        self.gameUnit:setSkin("rage");
        self:addBuffs(self.gameUnit,self.GAMEEND_BUFF_ARGS);
    end
    self.isShowResult = false;

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
    if self.hpMarkers[20] ~= nil then
        self.gameUnit:removeHpMarker(self.hpMarkers[20])
    end

    if not self.isGameOver then
        self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    end
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

function class:damageAmp(damage,unit)
    local sec = math.floor(self.timeCount);
    local rewDamage = damage;
    local secLimited = sec < self.damageLimitTime and sec or self.damageLimitTime;--50秒以降は考えない
    local sum = secLimited * (1 + secLimited )/2;
    local ratio = self.damageRatio;
    local damageLimit = 2100000000;

    if damageLimit/ratio > damage then
        damage = damage * ratio;
    else
        damage = damageLimit;
    end
    
    self:addTotalDamage(damage);
    
    self:showDamageInfo(damage,rewDamage);
    -- local critical = unit:getTeamUnitCondition():getDamageAffectInfo().critical;
    -- if critical then
    --     unit:takeDamagePopup(unit,damage,2);
    --     unit:setHP(unit:getHP() - damage);
    -- else
    --     unit:takeDamagePopup(unit,damage);
    --     unit:setHP(unit:getHP() - damage);
    -- end
    return damage;
end

function class:showDamageInfo(damage,rewDamage)
    local isMaxShow = false;
    if damage > self.maxDamage and damage > 10000 then
        self.maxDamage = damage; 
     
            isMaxShow = true;
      
    end
    local damageBordar = self.SHOWDAMAGE_BORDER_ONEHIT;
    if damage <  damageBordar and not isMaxShow then
        return;
    end

    local damageG = math.floor(damage/100000000);
    local damageM = math.floor(damage%100000000/10000);
    local damageStr = "";

    if damageG > 0 then
        local oku = string.format(self.TEXT.DAMAGE_MESSAGE2,damageG);
        local man = string.format(self.TEXT.DAMAGE_MESSAGE1,damageM);
        damageStr = self.TEXT.DAMAGE_MESSAGE4..oku..man..self.TEXT.DAMAGE_MESSAGE3;
    else
        local man = string.format(self.TEXT.DAMAGE_MESSAGE1,damageM);
        damageStr = self.TEXT.DAMAGE_MESSAGE4..man..self.TEXT.DAMAGE_MESSAGE3;
    end
    
    summoner.Utility.messageByPlayer(damageStr,10,summoner.Color.white);

end

function class:showTotalDamage(damage)
    local okuBorder = 100000000/self.exponent;
    local manBorder = 10000/self.exponent;

    local damageG = math.floor(damage/okuBorder);
    local damageM = math.floor(damage%okuBorder/manBorder);
    local damageStr = "";

    if damageG > 0 then
        local oku = string.format(self.TEXT.DAMAGE_MESSAGE2,damageG);
        local man = string.format(self.TEXT.DAMAGE_MESSAGE1,damageM);
        if damageM == 0 then
            damageStr = self.TEXT.RESULT_MESSAGE1..oku..self.TEXT.DAMAGE_MESSAGE5;
        else
            damageStr = self.TEXT.RESULT_MESSAGE1..oku..man..self.TEXT.DAMAGE_MESSAGE5;
        end
        
    else
        local man = string.format(self.TEXT.DAMAGE_MESSAGE1,damageM);
        damageStr = self.TEXT.RESULT_MESSAGE1..man..self.TEXT.DAMAGE_MESSAGE5;
    end
    
    summoner.Utility.messageByEnemy(damageStr,10,summoner.Color.white);

end

function class:showTotalDamageLast()
    local okuBorder = 100000000/self.exponent;
    local manBorder = 10000/self.exponent;

    local damageG = math.floor(self.totalDamage/okuBorder);
    local damageM = math.floor(self.totalDamage%okuBorder/manBorder);
    local damageStr = "";

    if damageG > 0 then
        local oku = string.format(self.TEXT.DAMAGE_MESSAGE2,damageG);
        local man = string.format(self.TEXT.DAMAGE_MESSAGE1,damageM);
        damageStr = self.TEXT.RESULT_MESSAGE1..oku..man..self.TEXT.RESULT_MESSAGE2;
    else
        local man = string.format(self.TEXT.DAMAGE_MESSAGE1,damageM);
        damageStr = self.TEXT.RESULT_MESSAGE1..man..self.TEXT.RESULT_MESSAGE2;
    end
    
    summoner.Utility.messageByEnemy(damageStr,10,summoner.Color.yellow);

end

function class:showMaxDamage()
    local okuBorder = 100000000;
    local manBorder = 10000;

    local damageG = math.floor(self.maxDamage/okuBorder);
    local damageM = math.floor(self.maxDamage%okuBorder/manBorder);
    local damageStr = "";

    if damageG > 0 then
        local oku = string.format(self.TEXT.DAMAGE_MESSAGE2,damageG);
        local man = string.format(self.TEXT.DAMAGE_MESSAGE1,damageM);
        damageStr = self.TEXT.RESULT_MESSAGE3..oku..man;
    else
        local man = string.format(self.TEXT.DAMAGE_MESSAGE1,damageM);
        damageStr = self.TEXT.RESULT_MESSAGE3..man
    end
    
    summoner.Utility.messageByPlayer(damageStr,10,summoner.Color.red);

end

function class:addTotalDamage(damage)
    local border = self.SHOWDAMAGE_BORDER_TOTAL;
    damage = damage/self.exponent;
    if border - damage > self.totalDamage then
        if self.totalDamage > self.SHOWDAMAGE_BORDER_TOTAL then
            local temp = math.floor((self.totalDamage + damage)/(self.SHOWDAMAGE_BORDER_AFTER/self.exponent));
            local temp2 = math.floor(self.totalDamage/(self.SHOWDAMAGE_BORDER_AFTER/self.exponent));
            if temp > temp2 then
                self:showTotalDamage(temp * self.SHOWDAMAGE_BORDER_AFTER/self.exponent);
            end
        else
            local temp = math.floor((self.totalDamage + damage)/(self.SHOWDAMAGE_BORDER/self.exponent));
            local temp2 = math.floor(self.totalDamage/(self.SHOWDAMAGE_BORDER/self.exponent));
            if temp > temp2 then
                self:showTotalDamage(temp * self.SHOWDAMAGE_BORDER);
            end
        end
        self.totalDamage = self.totalDamage + damage;
        
    else
        local tempTotal = self.totalDamage + damage;


        if self.totalDamage > self.SHOWDAMAGE_BORDER_TOTAL then
            local temp = math.floor((self.totalDamage + damage)/(self.SHOWDAMAGE_BORDER_AFTER/self.exponent));
            local temp2 = math.floor(self.totalDamage/(self.SHOWDAMAGE_BORDER_AFTER/self.exponent));
            if temp > temp2 then
                self:showTotalDamage(temp * self.SHOWDAMAGE_BORDER_AFTER/self.exponent);
            end
        else
            local temp = math.floor((self.totalDamage + damage)/(self.SHOWDAMAGE_BORDER/self.exponent));
            local temp2 = math.floor(self.totalDamage/(self.SHOWDAMAGE_BORDER/self.exponent));
            if temp > temp2 then
                self:showTotalDamage(temp * self.SHOWDAMAGE_BORDER);
            end
        end

        self.totalDamage = tempTotal;
    end
end



function class:autoHeal(unit,deltaTime)
    if self.timeCount > self.healLimitTime then
        if not self.isShowenLimitHealMess then
            self.isShowenLimitHealMess = true;
            self:showMessage(self.LIMIT_HEAL_MESSAGES);
        end
        return;
    end

    self.healTimer = self.healTimer + deltaTime;

    if self.healTimer > 1 then
        self.healTimer = 0;
        local sec = math.floor(self.timeCount);
        local healAmount = self.healLimitBorder;
        if healAmount > self.healLimitBorder then
        	healAmount = self.healLimitBorder;
        end
        local rate = (100 + unit:getTeamUnitCondition():findConditionValue(115) 
                        + unit:getTeamUnitCondition():findConditionValue(110) - unit:getTeamUnitCondition():findConditionValue(94))/100

        healAmount = healAmount * rate;

        local targetHP = unit:getCalcHPMAX() - healAmount > unit:getHP() and unit:getHP() + healAmount or unit:getCalcHPMAX();
        unit:takeDamagePopup(unit,healAmount,1);

        unit:setHP(targetHP);
    end
end


function class:run(event)
    if event.spineEvent == "summon" then
        
    end
    return 1;
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