--@additionalEnemy,2012250,2012251,2012252,2012253,2012254
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="りごーるチャレンジクエスト用", version=1.3, id=2012850});
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

class.SUMMON_ENEMY_ID = 100111010;


class.BUFF_VALUE = 30;

class.BORDER1 = 5;
class.BORDER2 = 10;
class.BORDER3 = 20;
class.BORDER4 = 30;
class.BORDER5 = 45;
class.BORDER6 = 60;
class.BORDER7 = 75;
class.BORDER8 = 90;
class.BORDER9 = 105;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.timeCount = 0;
    self.timeLimit = 120;
    self.talkDelay = 3;
    self.delay = 8;
    self.isBattleEnd = false;
    self.isShowResult = false;
    self.isShowTalk = false;
    self.isWin = false;
    self.isFirst = true;
    self.sendEventTimer = 0;

    self.isHide = false;
    event.unit:setInvincibleTime(99999);
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
    
    event.unit:setRange_Max(5000)
    event.unit:setRange_Min(0);
    -- self:showMessage(self.START_MESSAGES);
    self.gameUnit = event.unit;
    event.unit:setSPGainValue(0);
    self:setUpTalk();
    self:callTalk(0.1);
    return 1;
end

function class:setupMessage()
    
    self.END_MESSAGES1 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE1_1 or "倒されちゃったか～",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE1_2 or "まあいいや〜",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    self.END_MESSAGES2 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE2_1 or "へぇ〜",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE2_2 or "君たちなかなかやるね〜",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    self.END_MESSAGES3 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE3_1 or "こんなに早く倒せるとは",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE3_2 or "思わなかったよ",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    self.END_MESSAGES4 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE4_1 or "想定外の速さだね",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE4_2 or "逃〜げよっと",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    self.END_MESSAGES5 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE5_1 or "げっ……",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE5_2 or "その強さは反則でしょ……",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    self.END_MESSAGES6 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE6_1 or "こんな化け物がいるなんて",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE6_2 or "聞いてないよっ",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    self.END_MESSAGES7 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE7_1 or "こんなに早いなんて……",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE7_2 or "ぼくは信じないぞ！",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    self.END_MESSAGES8 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE8_1 or "ほとんど一撃じゃないか〜…",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    self.END_MESSAGES9 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE9_1 or "ぼくに寝る暇も",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE9_2 or "与えないなんて……",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }

    self.END_MESSAGES10 = {
        [0] = {
            MESSAGE = self.TEXT.END_MESSAGE10_1 or "お手上げだね",
            COLOR = Color.magenta,
            DURATION = 5
        },
        [1] = {
            MESSAGE = self.TEXT.END_MESSAGE10_2 or "もう手も足も出ないや…",
            COLOR = Color.magenta,
            DURATION = 5
        }
    }
end

function class:startWave(event)
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit ,30, 620 , -100 ,0.8);
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
    self:gameEndChecker(event.unit);
    self:callTalk(event.deltaTime);
    self:fixSP();
    return 1;
end

function class:takeAttack(event)
    if not self.isHide then
        event.unit:takeAnimation(0,"backForSpecialQuest",false);
    end
    return 0;
end

function class:takeSkill(event)
    if not self.isHide then
        event.unit:takeAnimation(0,"backForSpecialQuest",false);
    end
    return 0;
end




function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

function class:takeBreake(event)
    event.unit:setSkin("normal");
    return 1;
end

---------------------------------------------------------------------------------
-- run
---------------------------------------------------------------------------------
function class:run(event)
    if event.spineEvent == "backEnd" then
        self.isHide = true;
    end

    if event.spineEvent == "hideEnd" then
        self:hideEnd(event.unit);
    end
    if event.spineEvent == "showEndTalk" then
        self:showEndTalk(event.unit);
    end
   return 1
end

function class:hideEnd(unit)
    self.isHide = false;
    unit:takeAnimation(0,"inForSpecialQuest",false);
end



--===================================================================================================================
--奥義ゲージ固定

function class:fixSP()
    for i=0,7 do
        local target = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i,true);
        if target ~= nil then
            target:addSP(200);
        end
    end
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
--特殊会話
function class:setUpTalk()
    self.talkTables = {}
    self.talkTimer = 0;
    self.talkCalling = true;
    self.talkTables[0] = {
        [1] = {
            MESSAGE = self.TEXT.TALK1_1 or "げっ…また君か…",
            COLOR = Color.magenta,
            DURATION = 3,
            ISPRAYER = false,
            DERAY = 0
        },
        [2] = {
            MESSAGE = self.TEXT.TALK1_2 or "ただじゃおかないわよ！",
            COLOR = Color.cyan,
            DURATION = 3,
            ISPRAYER = true,
            DERAY = 0
        },
        [3] = {
            MESSAGE = self.TEXT.TALK1_3 or "泣いても知らないから！",
            COLOR = Color.cyan,
            DURATION = 3,
            ISPRAYER = true,
            DERAY = 0
        },
        [4] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "早めに倒した方がいいと思うよ〜",
            COLOR = Color.magenta,
            DURATION = 10,
            ISPRAYER = false,
            DERAY = 0.2
        },
        [5] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "奥義ゲージが常に上昇",
            COLOR = Color.yellow,
            DURATION = 15,
            ISPRAYER = false,
            DERAY = 3
        },
        [6] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "バリア：ダメージ軽減",
            COLOR = Color.magenta,
            DURATION = 15,
            ISPRAYER = false,
            DERAY = 3 
        }
    }

    self.talkTables[1] = {
        [1] = {
            MESSAGE = self.TEXT.TALK2_2 or "コノヤロー！また悪さしてんのか？",
            COLOR = Color.green,
            DURATION = 3,
            ISPRAYER = true,
            DERAY = 0
        },
        [2] = {
            MESSAGE = self.TEXT.TALK2_1 or "眼が覚めたね…これがぼくの本気だよ",
            COLOR = Color.magenta,
            DURATION = 3,
            ISPRAYER = false,
            DERAY = 0
        },
        [3] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "早めに倒した方がいいと思うよ〜",
            COLOR = Color.magenta,
            DURATION = 10,
            ISPRAYER = false,
            DERAY = 0.2
        },
        [4] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "奥義ゲージが常に上昇",
            COLOR = Color.yellow,
            DURATION = 15,
            ISPRAYER = false,
            DERAY = 3
        },
        [5] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "バリア：ダメージ軽減",
            COLOR = Color.magenta,
            DURATION = 15,
            ISPRAYER = false,
            DERAY = 3
        }
    }

    self.talkTables[2] = {
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "早めに倒した方がいいと思うよ〜",
            COLOR = Color.magenta,
            DURATION = 10,
            ISPRAYER = false,
            DERAY = 0
        },
        [2] = {
            MESSAGE = self.TEXT.START_MESSAGE2 or "奥義ゲージが常に上昇",
            COLOR = Color.yellow,
            DURATION = 15,
            ISPRAYER = false,
            DERAY = 3
        },
        [3] = {
            MESSAGE = self.TEXT.START_MESSAGE3 or "バリア：ダメージ軽減",
            COLOR = Color.magenta,
            DURATION = 15,
            ISPRAYER = false,
            DERAY = 3
        }
    }

    self.currentTalkTable = self.talkTables[self:sarchTalkTarget()];

end


function class:callTalk(delta)
    if nil == self.currentTalkTable then
        return;
    end

    if not self.talkCalling then
        return;
    end

    self.talkTimer = self.talkTimer + delta;
    local isAll = true;


    for i = 1,table.maxn(self.currentTalkTable) do
        local v = self.currentTalkTable[i];
        if v ~= nil and v.DERAY <= self.talkTimer then     
            if v.ISPRAYER then
                summoner.Utility.messageByPlayer(v.MESSAGE,v.DURATION,v.COLOR)
            else
                summoner.Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR)
            end
            
            self.currentTalkTable[i] = nil;    
        end
        if v ~= nil then
            isAll = false;
        end
    end
    self.talkCalling = not isAll;
end

function class:sarchTalkTarget()
    local result = 2;
    for i=0,7 do
        local target = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i,true);
        if target ~= nil and target ~= unit and target:getBaseID3() == 262 then
            result = 0;
        end
        if target ~= nil and target ~= unit and target:getBaseID3() == 260 and result ~= 0 then
            result = 1;
        end
    end
    return result;
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

function class:isBuddyStillAlive(unit)
    
    for i=0,7 do
        local target = unit:getTeam():getTeamUnit(i);
        if target ~= nil and target ~= unit and target:getBaseID3() == 40001 then
            return true;
        end
    end
    return false;
    
end

function class:gameEndChecker(unit)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
        return;
    end
    if not self:isBuddyStillAlive(unit) then
        self:gameEnd();
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
       self.timeCount = self.timeCount + deltaTime;
    end

    if self.timeLimit < 0 and not self.isBattleEnd then
        -- self:gameEnd();
    end

    if self.isBattleEnd then
        self.delay = self.delay - deltaTime;
        self.talkDelay = self.talkDelay - deltaTime;
    end

    if self.talkDelay < 0 and not self.isShowTalk then
        self:showEndTalk();
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
    self.isBattleEnd = true;
    megast.Battle:getInstance():setBattleState(kBattleState_none);
    self:hideEnd(self.gameUnit);
    self.isWin = true;
end


function class:showEndTalk()
    self.isShowTalk = true;
    if self.timeCount <= self.BORDER1 then
        self:showMessage(self.END_MESSAGES10);
    elseif self.timeCount <= self.BORDER2 then
        self:showMessage(self.END_MESSAGES9);
    elseif self.timeCount <= self.BORDER3 then
        self:showMessage(self.END_MESSAGES8);
    elseif self.timeCount <= self.BORDER4 then
        self:showMessage(self.END_MESSAGES7);
    elseif self.timeCount <= self.BORDER5 then
        self:showMessage(self.END_MESSAGES6);
    elseif self.timeCount <= self.BORDER6 then
        self:showMessage(self.END_MESSAGES5);
    elseif self.timeCount <= self.BORDER7 then
        self:showMessage(self.END_MESSAGES4);
    elseif self.timeCount <= self.BORDER8 then
        self:showMessage(self.END_MESSAGES3);
    elseif self.timeCount <= self.BORDER9 then
        self:showMessage(self.END_MESSAGES2);    
    else
        self:showMessage(self.END_MESSAGES1);
    end
end

--=====================================================================================================================================




function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


class:publish();

return class;