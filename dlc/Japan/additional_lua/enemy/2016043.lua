--@additionalEnemy,2016052,2016051
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="死霊将軍", version=1.3, id=2016043});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50
}

-- 使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 10,
    ATTACK2 = 10,
    ATTACK3 = 0,
    ATTACK4 = 10
}

-- 使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100,
    SKILL2 = 100,
    SKILL3 = 0
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 2,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 1,
    SKILL1 = 4,
    SKILL2 = 6,
    SKILL3 = 5
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS = {
    {
        ID = 40075,
        EFID = 17,         --ダメージアップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}

--怒り時にかかるバフ内容
class.RAGE_BUFF_ARGS2 = {
    {
        ID = 2016043,
        EFID = 28,         --ダメージアップ
        VALUE = 50,        --効果量
        DURATION = 9999999,
        ICON = 7
    }
}

class.SUMMON_WAITS = {
    [2016051] = 20
}
class.specialSummonID = 2016052;

class.BUFF_VALUE = 30;

class.BORDER1 = 200;
class.BORDER2 = 400;
class.BORDER3 = 600;
class.BORDER4 = 800;
class.BORDER5 = 1000;
class.BORDER6 = 1200;
class.BORDER7 = 1400;
class.BORDER8 = 1600;
class.BORDER9 = 2000;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.summonTimer = 0;
    self.randomSummonTimer = 0;
    self.killCount = 0;
    self.timeLimit = 180;
    self.delay = 5;
    self.isBattleEnd = false;
    self.isShowResult = false;
    self.isWin = false;
    self.isFirst = true;
    self.isSpecial = false;
    self.sendEventTimer = 0;
    
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [1] = {
            HP = 70,
            trigger = "getRage",
            isActive = true
        },
        [2] = {
            HP = 30,
            trigger = "getRage2",
            isActive = true
        }
    }
    self.hpMarkers = {
        {
            HP = 70,isUsed = false,MARKER = event.unit:addNumHpMarker(0.7)
        },
        {
            HP = 30,isUsed = false,MARKER = event.unit:addNumHpMarker(0.3)
        }
    }

    self.delaySummonIndexes = {};

   

    self:setupMessage();
    

    self:showMessage(self.START_MESSAGES);
    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    return 1;
end

function class:setupMessage()
     --開幕
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "骸骨兵：魔法ダメージ無効",
            COLOR = Color.magenta,
            DURATION = 15
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "死霊将軍：ダメージ軽減",
            COLOR = Color.magenta,
            DURATION = 15
        }
    }

    self.RAGE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE1 or "与ダメージアップ",
            COLOR = Color.magenta,
            DURATION = 15
        }
    }

    self.RAGE_MESSAGES2 = {
        [0] = {
            MESSAGE = self.TEXT.RAGE_MESSAGE2 or "行動速度アップ",
            COLOR = Color.magenta,
            DURATION = 15
        }
    }

    
    -- self.END_MESSAGES1 = {
    --     [0] = {
    --         MESSAGE = self.TEXT.END_MESSAGE1_1 or "あらまあ、これでおしまいですか…",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     },
    --     [1] = {
    --         MESSAGE = self.TEXT.END_MESSAGE1_2 or "まだまだですね",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     }
    -- }

    -- self.END_MESSAGES2 = {
    --     [0] = {
    --         MESSAGE = self.TEXT.END_MESSAGE2_1 or "ふふふ、",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     },
    --     [1] = {
    --         MESSAGE = self.TEXT.END_MESSAGE2_2 or "なかなか頑張りましたね",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     }
    -- }

    -- self.END_MESSAGES3 = {
    --     [0] = {
    --         MESSAGE = self.TEXT.END_MESSAGE3_1 or "やりますね…",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     },
    --     [1] = {
    --         MESSAGE = self.TEXT.END_MESSAGE3_2 or "想定以上です",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     }
    -- }

    -- self.END_MESSAGES4 = {
    --     [0] = {
    --         MESSAGE = self.TEXT.END_MESSAGE4_1 or "まさか、ここまで押されるとは…",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     },
    --     [1] = {
    --         MESSAGE = self.TEXT.END_MESSAGE4_2 or "強いのですね",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     }
    -- }

    -- self.END_MESSAGES5 = {
    --     [0] = {
    --         MESSAGE = self.TEXT.END_MESSAGE5_1 or "この感覚……",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     },
    --     [1] = {
    --         MESSAGE = self.TEXT.END_MESSAGE5_2 or "あの時の戦いを思い出しますね",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     }
    -- }

    -- self.END_MESSAGES6 = {
    --     [0] = {
    --         MESSAGE = self.TEXT.END_MESSAGE6_1 or "御見逸れしました",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     },
    --     [1] = {
    --         MESSAGE = self.TEXT.END_MESSAGE6_2 or "一騎当千とは正にこのこと",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     }
    -- }

    -- self.END_MESSAGES7 = {
    --     [0] = {
    --         MESSAGE = self.TEXT.END_MESSAGE7_1 or "双ぶもの無しと書いて無双",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     },
    --     [1] = {
    --         MESSAGE = self.TEXT.END_MESSAGE7_2 or "その名はあなたにこそ相応しいでしょう",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     }
    -- }

    -- self.END_MESSAGES8 = {
    --     [0] = {
    --         MESSAGE = self.TEXT.END_MESSAGE8_1 or "そ、そんな……！？",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     },
    --     [1] = {
    --         MESSAGE = self.TEXT.END_MESSAGE8_2 or "信じられません……",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     }
    -- }

    -- self.END_MESSAGES9 = {
    --     [0] = {
    --         MESSAGE = self.TEXT.END_MESSAGE9_1 or "……はっ！？",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     },
    --     [1] = {
    --         MESSAGE = self.TEXT.END_MESSAGE9_2 or "私は悪い夢でも見ているのでしょうか？",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     }
    -- }

    -- self.END_MESSAGES10 = {
    --     [0] = {
    --         MESSAGE = self.TEXT.END_MESSAGE10_1 or "どうして、なぜここまで……",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     },
    --     [1] = {
    --         MESSAGE = self.TEXT.END_MESSAGE10_2 or "何があなたを駆り立てるのですか？",
    --         COLOR = Color.yellow,
    --         DURATION = 5
    --     }
    -- }
end

function class:startWave(event)

    -- BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit ,30, 620 , -100 ,0.8);
    -- summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.magenta);
    return 1;
end

function class:update(event)
    self.sendEventTimer = self.sendEventTimer + event.deltaTime;
    self:HPTriggersCheck(event.unit);
    self:delaySummon(event.unit);
    self:summonCheck(event.unit,event.deltaTime);
    event.unit:setReduceHitStop(2, 1);
    -- self:countDown(event.deltaTime);
    for _,marker in pairs(self.hpMarkers) do
        local hpPercent = 100 * event.unit:getHP()/event.unit:getCalcHPMAX();
        if not marker.isUsed and hpPercent < marker.HP then
            marker.isUsed = true
            event.unit:removeHpMarker(marker.MARKER)
        end
    end
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
    if event.index ~= 3 then event.unit:setNextAnimationName("zcloneNattack" .. event.index); end
    return 1;
end

function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    -- local targets = self:getUnitCurse();
    -- -- 対象となるユニットが1体以上存在すれば指定の奥義を使用する
    -- if targets ~= nil and #targets > 0 then
    --     skillIndex = self.KILL_CURSE_SKILL_INDEX;
    --     unit:setInvincibleTime(10);
    --     self:generalPause(unit);
    -- end

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
    self.skillCheckFlg = false;
    self.fromHost = false;
    self:skillActiveSkillSetter(event.unit,event.index);
    if event.index ~= 3 then event.unit:setNextAnimationName("zcloneNskill" .. event.index); end
    return 1;
end


function class:run(event)
    if event.spineEvent == "death" then return self:death(event.unit); end
    if event.spineEvent == "addSP" then return self:addSP(event.unit); end
    return 1;
end

function class:takeIdle(event)
    event.unit:setNextAnimationName("zcloneNidle");
    return 1;
end

function class:takeBack(event)
    return 1;
end

function class:takeDamage(event)
    event.unit:setNextAnimationName("zcloneNdamage");
    return 1;
end

function class:dead(event)
    event.unit:setNextAnimationName("zcloneNout");
    for i=0,5 do
        local target = event.unit:getTeam():getTeamUnit(i);
        if target ~= nil then
            target:setHP(0);
        end
    end
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
    if trigger == "getRage" then
        self:getRage(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,3,0);
        return true;
    end

    if trigger == "getRage2" then
        self:getRage2(unit);
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,0);
        return true;
    end
    return false;
end

--===================================================================================================================
--怒り関係

function class:getRage(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
    self:showMessage(self.RAGE_MESSAGES);
    self.isRage = true;
end

function class:getRage2(unit)
    self:addBuffs(unit,self.RAGE_BUFF_ARGS2);
    self:showMessage(self.RAGE_MESSAGES2);
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

-- function class:countDown(deltaTime)
--     if megast.Battle:getInstance():getBattleState() == kBattleState_active then
--        self.timeLimit = self.timeLimit - deltaTime;
--     end

--     if self.timeLimit < 0 and not self.isBattleEnd then
--         self:gameEnd();
--     end

--     if self.isBattleEnd then
--         self.delay = self.delay - deltaTime;
--     end

--     if self.delay < 0 and not self.isShowResult then
--         megast.Battle:getInstance():waveEnd(self.isWin);
--         if not self.isWin then
--             megast.Battle:getInstance():endBattle(false);
--         end
--         self.isShowResult = true;
--     end
-- end


function class:summonCheck(unit,deltaTime)

    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
       return;
    end


    if not self:getIsHost() then
        return;
    end

    self.summonTimer = self.summonTimer + deltaTime;
    self.randomSummonTimer = self.randomSummonTimer + deltaTime;

    if self.summonTimer < 0.8 then
        local rand = LuaUtilities.rand(100);
        if rand > 7 or self.randomSummonTimer < 0.2 then
            return;
        end
        self.randomSummonTimer = 0;
    end

    self.summonTimer = self.summonTimer - 0.8;

    --0~5の場所が空席ならユニット召喚
    for i=0,5 do
        if unit:getTeam():getTeamUnit(i) == nil then
            table.insert(self.delaySummonIndexes,i);
            if not self.isFirst then
                self.killCount = self.killCount + 1;
                unit:setHP(unit:getHP() - unit:getCalcHPMAX() * 0.02);
                if self.killCount % 10 == 0 and self.killCount > 0 then
                    self.isSpecial = true;
                end
            end
        end
    end

    self.isFirst = false;
    
    return 1;
end

function class:delaySummon(unit)
    for i = 1,table.maxn(self.delaySummonIndexes) do
        
        if self.isSpecial then
            self.isSpecial = false;
            unit:getTeam():addUnit(self.delaySummonIndexes[i],self.specialSummonID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
        else
            unit:getTeam():addUnit(self.delaySummonIndexes[i],summoner.Random.sampleWeighted(self.SUMMON_WAITS));--指定したインデックスの位置に指定したエネミーIDのユニットを出す
        end
    end
    self.delaySummonIndexes = {};
end

function class:showDefeated()

    mess = self.TEXT.DEFEATED or "%d体撃破！";
    summoner.Utility.messageByEnemy(string.format(mess,self.killCount),5,summoner.Color.white);

    if self:getIsHost() and self.killCount % 10 == 0 and self.sendEventTimer > 5 then
        self.sendEventTimer = self.sendEventTimer - 5;
        megast.Battle:getInstance():sendEventToLua(self.scriptID,4,self.killCount);
    end
end

function class:gameEnd()
    self.isBattleEnd = true;
    megast.Battle:getInstance():setBattleState(kBattleState_none);
    if self.killCount < self.BORDER1 then
        self.isWin = false;
        self:showMessage(self.END_MESSAGES1);
    elseif self.killCount < self.BORDER2 then
        self:showMessage(self.END_MESSAGES2);
        self.isWin = true;
    elseif self.killCount < self.BORDER3 then
        self:showMessage(self.END_MESSAGES3);
        self.isWin = true;
    elseif self.killCount < self.BORDER4 then
        self:showMessage(self.END_MESSAGES4);
        self.isWin = true;
    elseif self.killCount < self.BORDER5 then
        self:showMessage(self.END_MESSAGES5);
        self.isWin = true;
    elseif self.killCount < self.BORDER6 then
        self:showMessage(self.END_MESSAGES6);
        self.isWin = true;
    elseif self.killCount < self.BORDER7 then
        self:showMessage(self.END_MESSAGES7);
        self.isWin = true;
    elseif self.killCount < self.BORDER8 then
        self:showMessage(self.END_MESSAGES8);
        self.isWin = true;
    elseif self.killCount < self.BORDER9 then
        self:showMessage(self.END_MESSAGES9);
        self.isWin = true;    
    else
        self:showMessage(self.END_MESSAGES10);
        self.isWin = true;
    end
end

--=====================================================================================================================================
function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:getRage2(self.gameUnit);
    return 1;
end



function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;