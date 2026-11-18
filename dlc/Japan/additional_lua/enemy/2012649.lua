local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="魔獣　チャレンジクエスト用", version=1.3, id=2012649});
class:inheritFromUnit("unitBossBase");

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 50,
    ATTACK2 = 50,
    ATTACK3 = 50,
    ATTACK4 = 50
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 50,
    SKILL2 = 50
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 6,
    SKILL2 = 7
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

class.BORDER1 = 500000;
class.BORDER2 = 1000000;
class.BORDER3 = 3000000;
class.BORDER4 = 5000000;
class.BORDER5 = 10000000;
class.BORDER6 = 20000000;
class.BORDER7 = 30000000;
class.BORDER8 = 50000000;
class.BORDER9 = 75000000;
class.BORDER10 = 100000000;
class.BORDER11 = 200000000;


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
    self.breakCount = 0;
    self.timeLimit = 120;
    self.delay = 8;
    self.isBattleEnd = false;
    self.isShowResult = false;
    self.isWin = false;
    self.isFirst = true;
    self.sendEventTimer = 0;
    self.isBreak = false;
    self.isHide = false;
    self.inEnd = false;
    
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
    

    self:showMessage(self.START_MESSAGES);
    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    
    return 1;
end

function class:setupMessage()
     --開幕
    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "随分と力を付けたみたいですね。",
            COLOR = Color.yellow,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "では…少し腕試ししてみましょうか。",
            COLOR = Color.yellow,
            DURATION = 5
        }
    }

    self.START_WAVE_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "時間内にブレイク中ダメージ50万以上でクリア",
            COLOR = Color.red,
            DURATION = 15
        }
    }

    self.BREAK_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.BREAK_MESSAGE1 or "ブレイク時間延長",
            COLOR = Color.white,
            DURATION = 7
        }
    }
    
    self.END_MESSAGES1 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE1_1 or "実力が足りなかったようですね。",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.END_MESSAGES2 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE2_1 or "……なかなかやりますね。",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.END_MESSAGES3 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE3_1 or "さすが私が見込んだだけのことはあります。",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.END_MESSAGES4 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE4_1 or "まさかこれほどとは…",
            COLOR = Color.yellow,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE4_2 or "しかし嬉しいです。",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.END_MESSAGES5 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE5_1 or "これは驚きました…",
            COLOR = Color.yellow,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE5_2 or "まだまだいけそうですね。",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.END_MESSAGES6 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE6_1 or "私はあなたを甘く見ていたようです",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.END_MESSAGES7 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE7_1 or "次も楽しみにしていますよ。",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.END_MESSAGES8 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE8_1 or "ばかな…信じられない…",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.END_MESSAGES9 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE9_1 or "これほどまでの屈辱を",
            COLOR = Color.yellow,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE9_2 or "受けるのは初めてです…",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.END_MESSAGES10 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE10_1 or "これは夢か何かでしょうか…",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.END_MESSAGES11 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE11_1 or "私を超える存在だと",
            COLOR = Color.yellow,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE11_2 or "認めざるを得ないようですね…",
            COLOR = Color.yellow,
            DURATION = 10
        }
    }

    self.END_MESSAGES12 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE12_1 or "完敗ですね…",
            COLOR = Color.yellow,
            DURATION = 10
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE12_2 or "あなたと出会えてよかったです。",
            COLOR = Color.yellow,
            DURATION = 10
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
    if event.spineEvent == "hide" then
        self.isHide = true;
    end

    if event.spineEvent == "showEndTalk" then
        self:showEndTalk();
    end
   return 1
end

function class:startWave(event)
    event.unit:setBaseHP(200000000);
    event.unit:setHP(200000000);
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit ,30, 620 , -100 ,0.8);
    self.isHide = false;
    
    event.unit:takeAnimation(0,"in",false);
    self:showMessage(self.START_WAVE_MESSAGES);
    return 1;
end

function class:update(event)
    self:HPTriggersCheck(event.unit);
    self:countDown(event.deltaTime);
    if self.isHide then
        event.unit:setPosition(-10000,-10000);
        event.unit:getSkeleton():setPosition(0,0);--見た目上のズレも無くす
        event.unit._ignoreBorder = true;--アニメーションの更新があっても外に居られるようにする
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
    return 1
end




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:takeDamageValue(event)
    local iValue = math.ceil(event.value)
    if self.isBreak then
        self.breakCount = self.breakCount + iValue;
    end
    return iValue;
end


function class:takeBreake(event)
    event.unit:setSkin("normal");
    self:showMessage(self.BREAK_MESSAGES);
    self.isBreak = true;
    self.justBreak = true;
    event.unit:setBaseBreakCapacity(0);
    -- BattleControl:get():setBreakBarEnable(false);
    return 1;
end

function class:dead(event)
    self:showMessage(self.END_MESSAGES12);
    megast.Battle:getInstance():waveEnd(true);
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
    self:addBuffs(unit,self.RAGE_BUFF_ARGS);
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
        megast.Battle:getInstance():waveEnd(self.isWin);
        if not self.isWin then
            megast.Battle:getInstance():endBattle(false);
        end
        self.isShowResult = true;
    end
end


function class:gameEnd()
    local digit1 =  self.TEXT.DIGIT1 or "万";
    local digit2 =  self.TEXT.DIGIT2 or "億";
    local mess = self.TEXT.DAMAGERESULT or "%dダメージを与えた！";


    local oku = math.floor(self.breakCount/100000000);
    local man = math.floor((self.breakCount%100000000)/10000);
    local nokori = self.breakCount%10000;

    local resultMessage = string.format(mess,nokori);

    if oku > 0 then
        if man > 0 then
            resultMessage = oku..digit2..man..digit1..resultMessage;
        else
            resultMessage = oku..digit2..resultMessage;
        end
    else
        if man > 0 then
            resultMessage = man..digit1..resultMessage;
        else
            resultMessage = resultMessage;
        end
    end

    for i=0,7 do
        local target = self.gameUnit:getTeam():getTeamUnit(i);
        if target ~= nil and target ~= self.gameUnit and target:getBaseID3() == 234 and megast.Battle:getInstance():isHost() then
            target:callLuaMethod("hideEnd",1.5);
        end
    end

    if self.breakCount > 0 then
        summoner.Utility.messageByEnemy(resultMessage,15,summoner.Color.red);
        self.gameUnit:takeAnimation(0,"hide",false);
    end
    self.isBattleEnd = true;
    megast.Battle:getInstance():setBattleState(kBattleState_none);

    if self.breakCount < self.BORDER1 then
        self.isWin = false;
        
    elseif self.breakCount < self.BORDER2 then
        
        self.isWin = true;
    elseif self.breakCount < self.BORDER3 then
        
        self.isWin = true;
    elseif self.breakCount < self.BORDER4 then
        
        self.isWin = true;
    elseif self.breakCount < self.BORDER5 then
        
        self.isWin = true;
    elseif self.breakCount < self.BORDER6 then
        
        self.isWin = true;
    elseif self.breakCount < self.BORDER7 then
        
        self.isWin = true;
    elseif self.breakCount < self.BORDER8 then
        
        self.isWin = true;
    elseif self.breakCount < self.BORDER9 then
        
        self.isWin = true;    
    elseif self.breakCount < self.BORDER10 then
        
        self.isWin = true;
    elseif self.breakCount < self.BORDER11 then
        
        self.isWin = true;
    else
        
        self.isWin = true;
    end
end

function class:showEndTalk()
    if self.breakCount < self.BORDER1 then
        self:showMessage(self.END_MESSAGES1);
    elseif self.breakCount < self.BORDER2 then
        self:showMessage(self.END_MESSAGES2);
    elseif self.breakCount < self.BORDER3 then
        self:showMessage(self.END_MESSAGES3);
    elseif self.breakCount < self.BORDER4 then
        self:showMessage(self.END_MESSAGES4);
    elseif self.breakCount < self.BORDER5 then
        self:showMessage(self.END_MESSAGES5);
    elseif self.breakCount < self.BORDER6 then
        self:showMessage(self.END_MESSAGES6);
    elseif self.breakCount < self.BORDER7 then
        self:showMessage(self.END_MESSAGES7);
    elseif self.breakCount < self.BORDER8 then
        self:showMessage(self.END_MESSAGES8);
    elseif self.breakCount < self.BORDER9 then
        self:showMessage(self.END_MESSAGES9);    
    elseif self.breakCount < self.BORDER10 then
        self:showMessage(self.END_MESSAGES10);
    elseif self.breakCount < self.BORDER11 then
        self:showMessage(self.END_MESSAGES11);
    else
        self:showMessage(self.END_MESSAGES12);
    end
end

--=====================================================================================================================================




function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;