local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="", version=1.3, id=2015449});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100,
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
        EFID = 17,         --ダメージアップ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}


class.BUFF_VALUE = 30;


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
    self.healLimitBorder = 30000 * 10000;
    self.damageLimitTime = 50;
    self.damageRatio = 200;
    self.isShowenLimitDamageMess = false;
    self.timeLimit = 121;
    self.delay = 5;
    self.isWin = false;
    self.isGameOver = false;

    self.TEXT.RESULT_MESSAGE1 = self.TEXT.RESULT_MESSAGE1 or " TOT";
    self.TEXT.RESULT_MESSAGE2 = self.TEXT.RESULT_MESSAGE2 or " DMG!!";
    self.TEXT.RESULT_MESSAGE3 = self.TEXT.RESULT_MESSAGE3 or "MAX HIT DMG ";
    self.TEXT.DAMAGE_MESSAGE1 = self.TEXT.DAMAGE_MESSAGE1 or ",000";
    self.TEXT.DAMAGE_MESSAGE2 = self.TEXT.DAMAGE_MESSAGE2 or "%d億";
    self.TEXT.DAMAGE_MESSAGE3 = self.TEXT.DAMAGE_MESSAGE3 or " DMG!!";
    self.TEXT.DAMAGE_MESSAGE4 = self.TEXT.DAMAGE_MESSAGE4 or " HIT";
    self.TEXT.DAMAGE_MESSAGE5 = self.TEXT.DAMAGE_MESSAGE5 or " DMG";


    self.HP_TRIGGERS = {
        -- [0] = {
        --     HP = 50,
        --     trigger = "getRage",
        --     isActive = true
        -- }
    }

    --敗北メッセージ
    self.LOSE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.LOSE_MESSAGE1 or "累計１億ダメージに届かなかった……",
            COLOR = Color.magenta,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.LOSE_MESSAGE2 or "奥義ゲージ増加速度アップ",
            COLOR = Color.magenta,
            DURATION = 15
        }
    }

    --開幕
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "超回復",
            COLOR = Color.green,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "ブレイクダメージ無効",
            COLOR = Color.red,
            DURATION = 15
        },
        [2] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "味方ユニットの与ダメージアップ",
            COLOR = Color.red,
            DURATION = 15
        },
        [3] = {
            MESSAGE = self.TEXT.START_MESSAGE4 or "１２０秒以内に１億ダメージでクリア！",
            COLOR = Color.yellow,
            DURATION = 15
        }

    }

    --     --１００秒経過
    -- self.LIMIT_HEAL_MESSAGES = {
    --     [0] = {
    --         MESSAGE = self.TEXT.LIMIT_MESSAGE1 or "回復停止",
    --         COLOR = Color.yellow,
    --         DURATION = 15
    --     }
    -- }

    -- self.LIMIT_DAMAGE_MESSAGES = {
    --     [0] = {
    --         MESSAGE = self.TEXT.LIMIT_MESSAGE1 or "与ダメージ上昇が上限に達した！！",
    --         COLOR = Color.red,
    --         DURATION = 15
    --     }
    -- }

    


    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:startWave(event)
    event.unit:setBaseHP(2000000000);
    event.unit:setHP(2000000000);
    self:showMessage(self.START_MESSAGES);
    BattleControl:get():showCountDownTime("additional/other/timeLimit.png", self.timeLimit ,30, 620 , -100 ,0.8);
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
        event.unit:setInvincibleTime(5);
    end
    self:HPTriggersCheck(event.unit);
    self:autoHeal(event.unit,event.deltaTime);
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
    return self:damageAmp(event.value,event.unit);
end

function class:attackDamageValue(event)
    if self.isGameOver then
        for i=0,4 do
            local  unit = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);
            if unit ~= nil then
                unit:setHP(0);
            end
        end
        return 99999999;
    end
    return event.value;
end

function class:takeBreakeDamageValue(event)
    event.unit:setBreakPoint(1000000);
    return 0;
end


function class:dead(event)
    event.unit:setHP(1);
    return 0;
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
    if self.totalDamage > 100000000 then
        self.isWin = true;
        megast.Battle:getInstance():setBattleState(kBattleState_none);
    else
        self.isGameOver = true;
        self:showMessage(self.LOSE_MESSAGES);
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

function class:damageAmp(damage,unit)
    local sec = math.floor(self.timeCount);
    local rewDamage = damage;
    local secLimited = sec < self.damageLimitTime and sec or self.damageLimitTime;--50秒以降は考えない
    local sum = secLimited * (1 + secLimited )/2;
    local ratio = self.damageRatio;
    local damageLimit = 21000000000;

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
        if damage > 1000000 then
            isMaxShow = true;
        end
    end
    local damageBordar = 1000 * 10000;
    if damage <  damageBordar and not isMaxShow then
        return;
    end

    local damageK = math.floor(damage/1000);
    local damageStr = self:makeDamageValueStr(damageK);

    damageStr = damageStr..self.TEXT.DAMAGE_MESSAGE3..self.TEXT.DAMAGE_MESSAGE4;
    summoner.Utility.messageByEnemy(damageStr,10,summoner.Color.red);

end

function class:showTotalDamage(damage)
    local okuBorder = 100000000/self.exponent;
    local manBorder = 10000/self.exponent;

    local damageG = math.floor(damage/okuBorder);
    local damageK = math.floor(damage%okuBorder/manBorder);
    local damageStr = "";

    local damageK = math.floor(damage/1000);
    local damageStr = self:makeDamageValueStr(damageK);

    damageStr = damageStr..self.TEXT.DAMAGE_MESSAGE5..self.TEXT.RESULT_MESSAGE1;
    
    
    summoner.Utility.messageByEnemy(damageStr,10,summoner.Color.yellow);

end

function class:showTotalDamageLast()
    local okuBorder = 100000000/self.exponent;
    local manBorder = 10000/self.exponent;

    local damageK = math.floor(self.totalDamage/1000);
    local damageStr = self:makeDamageValueStr(damageK);

    damageStr = damageStr..self.TEXT.RESULT_MESSAGE2;
    
    
    summoner.Utility.messageByEnemy(damageStr,10,summoner.Color.yellow);

end

function class:showMaxDamage()

    local damageK = math.floor(self.maxDamage/1000);
    local damageStr = self:makeDamageValueStr(damageK);

    damageStr = self.TEXT.RESULT_MESSAGE3..damageStr;
    
    summoner.Utility.messageByEnemy(damageStr,10,summoner.Color.red);

end

function class:addTotalDamage(damage)
    local border = 100000000;
    damage = damage/self.exponent;
    if border - damage > self.totalDamage then
        if self.totalDamage > 100000000 then
            local temp = math.floor((self.totalDamage + damage)/(50000000/self.exponent));
            local temp2 = math.floor(self.totalDamage/(50000000/self.exponent));
            if temp > temp2 then
                self:showTotalDamage(temp * 50000000/self.exponent);
            end
        else
            local temp = math.floor((self.totalDamage + damage)/(10000000/self.exponent));
            local temp2 = math.floor(self.totalDamage/(10000000/self.exponent));
            if temp > temp2 then
                self:showTotalDamage(temp * 10000000);
            end
        end
        self.totalDamage = self.totalDamage + damage;
        
    else
        local tempTotal = self.totalDamage + self:changeExponent(damage);


        if self.totalDamage > 100000000 then
            local temp = math.floor((self.totalDamage + damage)/(50000000/self.exponent));
            local temp2 = math.floor(self.totalDamage/(50000000/self.exponent));
            if temp > temp2 then
                self:showTotalDamage(temp * 50000000/self.exponent);
            end
        else
            local temp = math.floor((self.totalDamage + damage)/(10000000/self.exponent));
            local temp2 = math.floor(self.totalDamage/(10000000/self.exponent));
            if temp > temp2 then
                self:showTotalDamage(temp * 10000000);
            end
        end

        self.totalDamage = tempTotal;
    end
end

function class:makeDamageValueStr(damage)

    local damageStr = ""..damage;
    local resultStr = "";
    local length = string.len(damageStr);
    if length < 4 then
        resultStr = damageStr..self.TEXT.DAMAGE_MESSAGE1;
    elseif length < 7 then
        local k = string.sub(damageStr,1,length - 3);
        local amari = string.sub(damageStr,length - 2);
        resultStr = ""..k..","..amari..self.TEXT.DAMAGE_MESSAGE1;
    elseif length < 10 then
        local m = string.sub(damageStr,1,length - 6);
        local k = string.sub(damageStr,length-5,length - 3);
        local amari = string.sub(damageStr,length - 2);
        resultStr = ""..m..","..k..","..amari..self.TEXT.DAMAGE_MESSAGE1;
    end

    return resultStr;
end

function class:changeExponent(damage)
	-- local border = 100000000;
	-- while border - damage > self.totalDamage  do
	-- 	damage = damage/10;
	-- 	self.exponent = self.exponent*10;
	-- 	self.totalDamage = self.totalDamage/10;
	-- end
	return damage;
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