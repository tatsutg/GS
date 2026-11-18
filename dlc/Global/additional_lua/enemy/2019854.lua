--@additionalEnemy,2019855,2019856,2019857
local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="継戦_ポーラ", version=1.3, id=2019854});
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
class.HP75_BUFF_ARGS = {
    {
        ID = 40074,
        EFID = 28,         --ダメージアップ
        VALUE = 30,        --効果量
        DURATION = 9999999,
        ICON = 7
    }
}


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
        EFID = 0,         --見た目だけ
        VALUE = 1,        --効果量
        DURATION = 9999999,
        ICON = 36
    }
}

class.ENEMYS = {
    2019855,2019856,2019857
}



class.BUFF_VALUE = 30;
class.TRUE_ARTS_SPAN = 40;


function class:start(event)
    self.fromHost = false;
    self.gameUnit = nil;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.isRage = false;
    self.isStartCheck = false;
    self.forceSkillIndex = 0;
    self.forceActiveSKill = 0;
    self.timeLimit = 180;
    self.trueArtsTimer = 0;
    self.currentSummonIndex = 1;
    self.isSummon = false;
    self.summonTimer = 14;
    self.summonDelay = 15;
    Color.orange = Color.orange or Color:new(233,163,38);
    event.unit:setSkillInvocationWeight(0);
    self.HP_TRIGGERS = {
        [0] = {
            HP = 75,
            trigger = "HP75",
            isActive = true,
            oneShot = false
        },
        [1] = {
            HP = 50,
            trigger = "HP50",
            isActive = true,
            oneShot = false
        },
        [2] = {
            HP = 25,
            trigger = "HP25",
            isActive = true,
            oneShot = false
        },
        [3] = {
            HP = 99.999999,
            trigger = "HP99OS",
            isActive = true,
            oneShot = true
        },
        [4] = {
            HP = 50,
            trigger = "HP50OS",
            isActive = true,
            oneShot = true
        },
        [5] = {
            HP = 25,
            trigger = "HP25OS",
            isActive = true,
            oneShot = true
        }
    }

    self.START_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE1 or "命中率・攻撃力アップ",
            COLOR = Color.orange,
            DURATION = 8
        }
    }

    self.HP75_MESSAGES = {
        [0] = {
            MESSAGE = self.TEXT.HP75_MESSAGE1 or "行動速度アップ",
            COLOR = Color.orange,
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

    self.START_MESSAGES_OS = {
        [0] = {
            MESSAGE = self.TEXT.START_MESSAGE_OS or "格の違いを見せてあげるわ",
            COLOR = Color.green,
            DURATION = 8
        }
    }

    self.HP50_MESSAGES_OS = {
        [0] = {
            MESSAGE = self.TEXT.HP50_MESSAGE_OS or "ヤバ…ひょっとして、ピンチ？",
            COLOR = Color.green,
            DURATION = 8
        }
    }

    self.HP25_MESSAGES_OS = {
        [0] = {
            MESSAGE = self.TEXT.HP25_MESSAGE_OS or "もう、許さない…懺悔しなさい！",
            COLOR = Color.green,
            DURATION = 8
        }
    }

    self.SUMMON_MESSAGES = {
        [1] = {
            [0] = {
                MESSAGE = self.TEXT.SUMMON_MESSAGE1 or "苦戦しているようだな、手を貸そう",
                COLOR = Color.yellow,
                DURATION = 8
            },
            [1] = {
                MESSAGE = self.TEXT.SUMMON_MESSAGE2 or "ロディアと共闘中ポーラの被ダメージダウン",
                COLOR = Color.orange,
                DURATION = 8
            }
        },
        
        [2] = {
            [0] = {
                MESSAGE = self.TEXT.SUMMON_MESSAGE3 or "「昨日の敵は今日の戦友」というやつです",
                COLOR = Color.red,
                DURATION = 8
            },
            [1] = {
                MESSAGE = self.TEXT.SUMMON_MESSAGE4 or "ソレイユと共闘中ポーラの被ダメージダウン",
                COLOR = Color.orange,
                DURATION = 8
            }
        },

        [3] = {
            [0] = {
                MESSAGE = self.TEXT.SUMMON_MESSAGE5 or "さあ、とっととブッ倒そうぜ！！",
                COLOR = Color.cyan,
                DURATION = 8
            },
            [1] = {
                MESSAGE = self.TEXT.SUMMON_MESSAGE6 or "ザールと共闘中ポーラの被ダメージダウン",
                COLOR = Color.orange,
                DURATION = 8
            }
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
    self:showMessage(self.START_MESSAGES);
    -- summoner.Utility.messageByEnemy(self.TEXT.mess1,5,summoner.Color.yellow);
    self:HPTriggersStartCheck(event.unit);
    BattleControl:get():showCountDownTime("unit/animation/timeLimit.png", self.timeLimit ,30, 620 , -100 ,0.8);
    return 1;
end

function class:update(event)
    if megast.Battle:getInstance():getBattleState() ~= kBattleState_active then
       return 1;
    end
    self:HPTriggersCheck(event.unit);
    self:artsTimeCount(event.deltaTime);
    self:countDown(event.deltaTime);
    self:summonCheck(event.unit,event.deltaTime);
    event.unit:setReduceHitStop(2,0.9)
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
    local sket = unit:getTeam():getTeamUnit(2);
    if sket ~= nil then
        sket:addSP(sket:getNeedSP());
    end
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

function class:run(event)
    if event.spineEvent == "shot" then
        event.unit:addOrbitSystemInsightRotation("2_attack_1_TAMA","empty",1,-150,0,180,0);
    end
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
   

    if trigger == "HP50" then
        self:HP50(unit);
        return true;
    end

   

    if trigger == "HP25" then
        self:HP25(unit);
        return true;
    end

    if trigger == "HP99OS" then
        self:HP99OS(unit);
        return true;
    end

    if trigger == "HP50OS" then
        self:HP50OS(unit);
        return true;
    end

    if trigger == "HP25OS" then
        self:HP25OS(unit);
        return true;
    end

    return false;
end

--===================================================================================================================
--怒り関係

function class:HP75(unit)
    self:showMessage(self.HP75_MESSAGES);
    self:addBuffs(unit,self.HP75_BUFF_ARGS);
end



function class:HP50(unit)
    self:showMessage(self.HP50_MESSAGES);
    self:addBuffs(unit,self.HP50_BUFF_ARGS);
    self.isSummon = true;
end

function class:HP99OS(unit)
    self:showMessage(self.START_MESSAGES_OS);
end

function class:HP50OS(unit)
    self:showMessage(self.HP50_MESSAGES_OS);
end

function class:HP25OS(unit)
    self:showMessage(self.HP25_MESSAGES_OS);
end


function class:HP25(unit)
    self:addBuffs(unit,self.HP25_BUFF_ARGS);
    self:showMessage(self.HP25_MESSAGES);
    self.spValue = self.spValue * 2;
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
        self.forceSkillIndex = 2;
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

function class:artsTimeCount(deltaTime)
    self.trueArtsTimer = self.trueArtsTimer + deltaTime;
    if self.trueArtsTimer > self.TRUE_ARTS_SPAN then
        self.trueArtsTimer = self.trueArtsTimer - self.TRUE_ARTS_SPAN;
        self.forceSkillIndex = 3;
    end
end

function class:summonCheck(unit,deltaTime)
    if not self:getIsHost() then
        return;
    end

    if self.currentSummonIndex > table.maxn(self.ENEMYS) then
        return;
    end

    if not self.isSummon then
        return;
    end

    
    if unit:getTeam():getTeamUnit(2) == nil then
        if self.summonTimer < self.summonDelay then
            self.summonTimer = self.summonTimer + deltaTime;
            return;
        end
        local enemyID = self.ENEMYS[self.currentSummonIndex]
         local enemy = unit:getTeam():addUnit(2,enemyID);--指定したインデックスの位置に指定したエネミーIDのユニットを出す
         enemy:setSPGainValue(0);
         -- enemy:setHP(1000); --デバッグ用
         self:showMessage(self.SUMMON_MESSAGES[self.currentSummonIndex]);
         self.currentSummonIndex = self.currentSummonIndex + 1;
         self.summonTimer = 0;
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