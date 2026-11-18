--@additionalEnemy,2024804
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="超神級死神", version=1.3, id=2024801});
class:inheritFromUnit("unitBossBase");


class.ATTACK_REEL = {
    [1] = {
        INDEX1 = 100,
        INDEX2 = 100
    },
    [2] = {
        INDEX3 = 100
    },
    [3] = {
        INDEX1 = 100
    },
    [4] = {
        INDEX2 = 100
    }
}



--使用する奥義とその確率
class.SKILL_REEL = {
    [1] = {
        INDEX5 = 100
    },
    [2] = {
        INDEX4 = 100
    }
}



class.ATTACK_INFO = {
    [1] = {
        animationNumber = 1,
        activeSkill = 1,
        isSkill = false,
        sp = 20
    },
    [2] = {
        animationNumber = 2,
        activeSkill = 2,
        isSkill = false,
        sp = 20
    },
    [3] = {
        animationNumber = 4,
        activeSkill = 3,
        isSkill = false,
        sp = 20
    },
    [4] = {
        animationNumber = 1,
        activeSkill = 4,
        isSkill = true,
        sp = 0
    },
    [5] = {
        animationNumber = 3,
        activeSkill = 5,
        isSkill = true,
        sp = 0
    }
}


class.START_BUFF_ARGS = {
    {
        ID = 40083,
        EFID = 13,         --攻撃力
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 3
    }, 
    {
        ID = 40084,
        EFID = 17,         --与ダメ
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}





-- class.INVINCIBLE_BUFF_ARGS = {
--     {
--         ID = 40078,
--         EFID = 21,         --被ダメ
--         VALUE = -1000,        --効果量
--         DURATION = 8,
--         ICON = 0
--     },
--     {
--         ID = 40079,
--         EFID = 27,         --被ブレイク
--         VALUE = -1000,        --効果量
--         DURATION = 8,
--         ICON = 0
--     },
-- }


class.BUFF_VALUE = 30;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.forceSkillIndex = 0;
    self.forceAttackIndex = 0;
    self.hitstopReduceLevel = 200;
    self.hitStopReduceRate = 1;
    self.attackCounter = 0;
    self.skillCounter = 0;
    self.isDie = false;
    self.specialHPAttackRate = 0;
    self.mode = 1;
    self.deadTimer = 10;
    self.timeLimit = 300;
    self.isBattleEnd = false;
    self.summonTimer = 0;

    self.currentActiveSkill = 0;

    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {

    }

     self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "闇属性耐性・光属性キラー",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "ダメージ無効化無効",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [2] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "呪い状態の敵に対してクリティカル率アップ",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.ARTS1_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.ARTS1_MESSAGE1 or "汝が魂ハ闇へト堕ちル",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    self.ARTS2_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.ARTS2_MESSAGE1 or "呪われシ者ヨ…壊魂の残響ヲ聞ケ",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }





    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    event.unit:addSP(40);
    event.unit:setAttackDelay(4)

    return 1;
end

function class:startWave(event)

    self:showMessage(self.START_MESSAGES);
    self:addBuffs(event.unit,self.START_BUFF_ARGS);
    

    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit ,30, 620 , -100 ,0.8);
    self.blackMist = event.unit:addOrbitSystemCamera("blackmist_in",0);
    self.blackMist:takeAnimation(0,"blackmist_in",true);
    self.blackMist:setZOrder(8000);
    return 1;
end


function class:update(event)
    self:HPTriggersCheck(event.unit);
    self:reduceHitStop(event.unit);

    self:summonCheck(event.unit,event.deltaTime);

    self:countDown(event.deltaTime);

    return 1;
end

function class:countDown(deltaTime)
    if megast.Battle:getInstance():getBattleState() == kBattleState_active then
       self.timeLimit = self.timeLimit - deltaTime;
    end

    if self.timeLimit < 0 then
        self.gameUnit:addSP(100);
        self.gameUnit:setInvincibleTime(10);
        self.forceSkillIndex = 4;
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

function class:reduceHitStop(unit)
    local level = self.hitstopReduceLevel;
    if unit:getTeamUnitCondition():findConditionValue(27) <= - 500 then
        level = 100;
    end
   unit:setReduceHitStop(level, self.hitStopReduceRate);
end

function class:attackBranch(unit)
    local attackStr = summoner.Random.sampleWeighted(self.ATTACK_REEL[self.attackCounter % table.maxn(self.ATTACK_REEL) + 1]);
    local attackIndex = string.gsub(attackStr,"INDEX","");
    self.attackCounter = self.attackCounter + 1;

    if self.forceAttackIndex ~= 0 then
        attackIndex = self.forceAttackIndex;
        self.forceAttackIndex = 0;
    end

    attackIndex = tonumber(attackIndex);

    self.currentActiveSkill = self.ATTACK_INFO[attackIndex].activeSkill;
    self.spValue = self.ATTACK_INFO[attackIndex].sp;

    if not self.ATTACK_INFO[attackIndex].isSkill then
        unit:takeAttack(self.ATTACK_INFO[attackIndex].animationNumber);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,1,tonumber(attackIndex));
    else
        self.skillCheckFlg = true;
        self.attackCheckFlg = false;
        unit:takeSkill(self.ATTACK_INFO[attackIndex].animationNumber);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(attackIndex));
    end

    return 0;
end

function class:takeAttack(event)
    self.specialHPAttackRate = 0;
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
    event.unit:setActiveSkill(self.currentActiveSkill);
    self:addSP(event.unit);
    if event.index == 5 then
        self.isAttack5 = true;
    end
    return 1
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_REEL[self.skillCounter % table.maxn(self.SKILL_REEL) + 1]);
    local skillIndex = string.gsub(skillStr,"INDEX","");
    self.skillCounter = self.skillCounter + 1;

    if self.forceSkillIndex ~= 0 then
        skillIndex = self.forceSkillIndex;
        self.forceSkillIndex = 0;
    end

    skillIndex = tonumber(skillIndex);

    self.currentActiveSkill = self.ATTACK_INFO[skillIndex].activeSkill;
    self.spValue = self.ATTACK_INFO[skillIndex].sp;

    self.currentActiveSkill =  self.ATTACK_INFO[skillIndex].activeSkill;
    unit:takeSkill(self.ATTACK_INFO[skillIndex].animationNumber);

    megast.Battle:getInstance():sendEventToLua(self.scriptID,2,tonumber(skillIndex));
    

    return 0;
end


function class:takeSkill(event)
    self.specialHPAttackRate = 0;
    if not self.skillCheckFlg and megast.Battle:getInstance():isHost() then
        self.skillCheckFlg = true;
        return self:skillBranch(event.unit);
    end
    if not megast.Battle:getInstance():isHost() and not self.fromHost then
        event.unit:takeIdle();
        return 0;
    end
    -- if event.index == 3 and not self.skillCheckFlg2 then
    --     self.skillCheckFlg2 = true;
    --     event.unit:takeSkillWithCutin(3,0);
    --     event.unit:setInvincibleTime(10);

    --     return 0;
    -- end
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.fromHost = false;
    event.unit:setActiveSkill(self.currentActiveSkill);

    -- if event.index >= 2 then
    --     self.attackCounter = 0;
    -- end

    self:addSP(event.unit);
    if event.index == 1 then
        self:showMessage(self.ARTS1_MESSAGES);
    end
    if event.index == 3 then
            self:showMessage(self.ARTS2_MESSAGES);
    end

    return 1
end


function class:attackDamageValue(event)
    if self.isBattleEnd then
        return 9999999;
    end
    return event.value;
end


function class:run(event)
    if event.spineEvent == "mistIn" then return self:mistIn(event.unit) end
    if event.spineEvent == "death" then return self:death(event.unit) end
    return 1;
end





function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end




function class:dead(event)

    for i = 0,7 do
         local teamUnit = megast.Battle:getInstance():getTeam(false):getTeamUnit(i);
         if teamUnit ~= nil then
            teamUnit:setHP(0)
         end 
    end
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

    if trigger == "HP70" then
        self:HP70(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end

    if trigger == "HP50" then
        self:HP50(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
        return true;
    end
    if trigger == "HP10" then
        self:HP10(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
        return true;
    end
    if trigger == "HP0" then
        self:HP0(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,6,0);
        return true;
    end
    return false;
end

function class:removeAllStopStatus(unit)
    local badStatusIDs = {89,91,96};
    for i=1,table.maxn(badStatusIDs) do
        local targetID = badStatusIDs[i];
        local flag = true;--whileを出るためだけのフラグ　これ以上同種のバッドステータスが取れなければfalseになります
        while flag do
            local cond = unit:getTeamUnitCondition():findConditionWithType(targetID);
            if cond ~= nil then
                unit:getTeamUnitCondition():removeCondition(cond);
            else
                flag = false;
            end
        end
    end
end


--===================================================================================================================
--怒り関係




function class:addBuffs(unit,buffs)
    for k,v in pairs(buffs) do
        self:addBuff(unit,v);
    end
end


function class:summonCheck(unit,deltaTime)
    self.summonTimer = self.summonTimer + deltaTime;
    local otherCnt = 0;
    for i=0,7 do
        if unit:getTeam():getTeamUnit(i) ~= nil and i ~= unit:getIndex() then
            otherCnt = otherCnt + 1; 
        end
    end
    if self.summonTimer * math.pow((5 - otherCnt),2) > 350 and otherCnt < 5 then
        self:summon(unit);
    end
end


function class:summon(unit)
    if not self:getIsHost() then
        return 1;
    end

    local counter = 0;
    --0~1の場所が空席ならユニット召喚
    for i=0,4 do
        if unit:getTeam():getTeamUnit(i) == nil then
            unit:getTeam():addUnit(i,2024804);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
            self.summonTimer = 0;
            return;
            
        end
    end
end

function class:mistIn(unit)
    self.blackMist:takeAnimation(0,"blackmist",true);
    return 1;
end

function class:death(unit)
    local orbit = unit:addOrbitSystemWithFile("../../effect/itemskill/itemskill1130","attack1");
    orbit:getSkeleton():setScaleX(-1);
    orbit:setActiveSkill(5);
    orbit:setPosition(orbit:getPositionX() + 200,orbit:getPositionY());
    for i = 0,5 do
        local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i,true);
        if uni ~= nil then

            local curse = uni:getTeamUnitCondition():findConditionWithType(95);

            if curse ~= nil then
                uni:setBurstPoint(0);                
            end
        end
    end
    return 1;
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
      HP70_BUFFS = {
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

function class:receive1(args)
    local attackIndex = args.arg;
    self.currentActiveSkill = self.ATTACK_INFO[attackIndex].activeSkill;
    self.spValue = self.ATTACK_INFO[attackIndex].sp;
    self.fromHost = true;
    self.gameUnit:takeAttack(self.ATTACK_INFO[attackIndex].animationNumber);

    return 1;
end


function class:receive2(args)
    self:removeAllStopStatus(self.gameUnit);
    local skillIndex = args.arg;
    self.currentActiveSkill = self.ATTACK_INFO[skillIndex].activeSkill;
    self.spValue = self.ATTACK_INFO[skillIndex].sp;
    self.fromHost = true;
    self.gameUnit:takeSkill(self.ATTACK_INFO[skillIndex].animationNumber);
    return 1;
end

function class:receive3(args)
    self:HP70(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:HP50(self.gameUnit);
    return 1;
end

function class:receive5(args)
    self:HP10(self.gameUnit);
    return 1;
end

function class:receive6(args)
    self:HP0(self.gameUnit);
    return 1;
end

function class:receive7(args)
    self:modeChange(self.gameUnit);
    return 1;
end

function class:receive8(args)
    self:takeDebuff(self.gameUnit);
    return 1;
end


function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;