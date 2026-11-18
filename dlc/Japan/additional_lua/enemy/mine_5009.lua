local Bootstrap, Color, Random, Utility = summoner.import("Bootstrap", "Color", "Random", "Utility")
local class = summoner.Bootstrap.createEnemyClass({label="501301313", version=1.3, id="mine_50009"});
class:inheritFromUnit("unitBossBase");

--===================================================================================================================
--定数群
--===================================================================================================================

--使用する通常攻撃とその確率
class.ATTACK_WEIGHTS = {
    ATTACK1 = 100
}

class.ATTACK_WEIGHTS_A = {
    ATTACK1 = 100
}

class.ATTACK_WEIGHTS_B = {
    ATTACK2 = 40,
    ATTACK3 = 30,
    ATTACK4 = 30
}

--使用する奥義とその確率
class.SKILL_WEIGHTS = {
    SKILL1 = 100
}

class.ACTIVE_SKILLS = {
    ATTACK1 = 1,
    ATTACK2 = 2,
    ATTACK3 = 3,
    ATTACK4 = 4,
    SKILL1 = 5,
    SKILL2 = 6
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



--クリスタルバフ　１個目
class.FIRST_BUFF_ARGS = {
    {
        ID = 501311,
        EFID = 132,         --無効化解除
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 0
    }
}

--クリスタルバフ　２個目
class.SECOND_BUFF_ARGS = {
    {
        ID = 501312,
        EFID = 17,         --ダメージアップ
        VALUE = 50,        --効果量
        DURATION = 9999999,
        ICON = 26
    }
}

--クリスタルバフ　３個目
class.THIRD_BUFF_ARGS = {
    {
        ID = 501313,
        EFID = 22,         --クリティカル率
        VALUE = 100,        --効果量
        DURATION = 9999999,
        ICON = 11
    }
}

--気絶
class.KIZETU_BUFF_ARGS = {
    [1] = {
        ID = 501314,
        EFID = 89,         --気絶
        VALUE = 100,        --効果量
        DURATION = 8,
        ICON = 79
    },
    [2] = {
        ID = 501315,
        EFID = 129,         --クリティカル率
        VALUE = 12000,    --効果量
        DURATION = 8,
        ICON = 0     
    }
}

--タイムアップ
class.TIMEUP_BUFF_BOX_LIST = {
  [1] = {
      ID = 5000033,
      EFID = 17,      --ダメージ
      VALUE = 500,       --効果量
      DURATION = 9999999,
      ICON = 26
  },
  [2] = {
      ID = 5000036,
      EFID = 13,      --攻撃力
      VALUE = 500,       --効果量
      DURATION = 9999999,
      ICON = 3
  }
}


class.CRYSTAL_NUM = 3;

class.CRYSTAL_POSITIONS = {
    {x = -300,y = 500},
    {x = 300,y = 500},
    {x = 0,y = 530}
}
class.CRYSTAL_STATES = {
    start = 0,
    deactive = 1,
    activation = 2,
    active = 3,
    out = 4,
    hide = 5
}


--===================================================================================================================
--メッセージリスト
--===================================================================================================================

function class:initMessages()
    -- 開幕のメッセージ
    self.START_MESSAGES = {
        [1] = {
            MESSAGE = self.TEXT.START_MESSAGE or "クリティカルダメージアップ",
            COLOR = Color.green,
            DURATION = 10
        },
        [2] = {
            MESSAGE = self.TEXT.HP_REDUCE_MESSAGE or "燃焼時被ダメージアップ",
            COLOR = Color.green,
            DURATION = 10
        }
    }

    --クリスタルバフ１個目がかかった時にでるメッセージ
    self.BUFF_MESSAGES1 = {
        [1] = {
            MESSAGE = self.TEXT.BUFF_MESSAGE1 or "ダメージ無効化解除",
            COLOR = Color.green,
            DURATION = 10
        }
    }


    --クリスタルバフ２個目がかかった時にでるメッセージ
    self.BUFF_MESSAGES2 = {
        [1] = {
            MESSAGE = self.TEXT.BUFF_MESSAGE2 or "与ダメージアップ",
            COLOR = Color.green,
            DURATION = 10
        }
    }


    --クリスタルバフ３個目がかかった時にでるメッセージ
    self.BUFF_MESSAGES3 = {
        [1] = {
            MESSAGE = self.TEXT.BUFF_MESSAGE3 or "クリティカル率アップ",
            COLOR = Color.green,
            DURATION = 10
        }
    }

    self.HP50_MESSAGE_LIST = {
        [1] = {
         MESSAGE = self.TEXT.HP50_MESSAGE1 or "多分何かしらHPトリガーがあるじゃろ？",
         COLOR = Color.green,
         DURATION = 5,
         isPlayer = false
      }
    }

    self.KABAUKILL_LIST = {
        [1] = {
         MESSAGE = self.TEXT.KABAU_MESSAGE1 or "庇うキラー",
         COLOR = Color.green,
         DURATION = 5,
         isPlayer = false
      }
    }


   self.TIMEUP_BUFF_MESSAGE_LIST = {
      [1] = {
         MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE1 or "攻撃力アップ",
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false         
      },
      [2] = {
         MESSAGE = self.TEXT.TIMEUP_BUFF_MESSAGE2 or "ダメージアップ",
         COLOR = Color.red,
         DURATION = 5,
         isPlayer = false         
      }
  }
end



--===================================================================================================================
--start近辺
--===================================================================================================================

function class:start(event)
    self.fromHost = false;
    self.gameUnit = event.unit;
    self.spValue = 20;
    self.attackCheckFlg = false;
    self.skillCheckFlg = false;
    self.skillCheckFlg2 = false;
    self.HP_TRIGGERS = {};

    --メッセージリストとHPトリガーの初期化
    self:initMessages();
    self:setTriggerList();
    ------------------------------


    --クリスタルの初期化処理
    self.crystalBuffs = {};
    self.crystals = {};
    self.crystalCounter = 0; --いきなり大技をぶっぱさせたかったらここをクリスタルの最大数で初期化しておけばいいよ！
    self.crystalExcutionFlg = false; --skill2の大技を実行中にブレイクされたりしたときにクリスタルを戻す処理をしなければいけない。そのための判断に使うよ！
    self:initCrystals(event.unit);
    self:setUpCrystalBuffs(event);


    --ヒットストップ耐性　鉱山用ギミック
    local floor = megast.Battle:getInstance():getCurrentMineFloor();
    self.hitStopReduceRate = 1


   --テロップ用変数
   self.telopSpan = 60
   self.showMessageTimer = 0
    
    event.unit:setSPGainValue(0);
    event.unit:setSkillInvocationWeight(0);

    event.unit:addSP(100)

    self.isFirstSkilled = false
    self.isAttack1 = false
    return 1;
end

function class:startWave(event)
    -- event.unit:addSP(event.unit:getNeedSP());
    self:showMessages(self.START_MESSAGES);
    return 1;
end



--===================================================================================================================
--定期処理
--===================================================================================================================


function class:update(event)
    self:HPTriggersCheck(event.unit);
    self:setReduceHitStop(event.unit);
    self:telopCheck(event.deltaTime)
    self:setTimeUp()
    return 1;
end

-- 一定時間ごとにテロップを流す
function class:telopCheck(deltaTime)
    if self.showMessageTimer > self.telopSpan then
       self.showMessageTimer = 0
       self:showMessages(self.START_MESSAGES)
    else
       self.showMessageTimer = self.showMessageTimer + deltaTime
    end
end

-- 180秒経ったらタイムアップ
function class:setTimeUp()
   if BattleControl:get():getTime() > 180 and not self.TRIGGERS[self.TID_TIME_UP].used then
      self:execTrigger(self.TID_TIME_UP)
   end
end


--===================================================================================================================
--トリガー　定義部分
--===================================================================================================================

--------[[特殊行動]]--------
function class:setTriggerList()
   self.TID_TIME_UP = 2
   self.TRIGGERS = {
      [1] = {
         tag = "HP_FLG",
         action = function (status) self:hp50(status) end,
         HP = 50,
         used = false
      },
      [self.TID_TIME_UP] = {
         tag = "TIME_UP",
         action = function (status) self:timeUp(status) end,
         used = false
      }
   }

   self.HP_TRIGGERS = {}
   for index,trigger in pairs(self.TRIGGERS) do
      if trigger.tag == "HP_FLG" then
         self.HP_TRIGGERS[index] = trigger
      end
   end
end

function class:hp50(status)
   if status == "use3" then
      -- self:showMessages(self.HP50_MESSAGE_LIST)
   end
end

function class:timeUp(status)
   if status == "use3" then
      self:addBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[1])
      self:addBuff(self.gameUnit,self.TIMEUP_BUFF_BOX_LIST[2])
      self:showMessages(self.TIMEUP_BUFF_MESSAGE_LIST)
   end
end


--===================================================================================================================
--通常攻撃分岐//
--///////////


function class:attackBranch(unit)
    if self.isAttack1 then
      self.isAttack1 = false
      self.ATTACK_WEIGHTS = self.ATTACK_WEIGHTS_B
    else
      self.isAttack1 = true
      self.ATTACK_WEIGHTS = self.ATTACK_WEIGHTS_A
    end

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
    return 1
end

function class:attackActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["ATTACK"..index]);
end
--===================================================================================================================


--===================================================================================================================
--スキル分岐//
--//////////



-- いつもの。ただし今回はここでクリスタルを点灯させるlightUpを呼んでいるよ！
function class:skillBranch(unit)
    local skillStr = summoner.Random.sampleWeighted(self.SKILL_WEIGHTS);
    local skillIndex = string.gsub(skillStr,"SKILL","");

    if self.crystalCounter >= self.CRYSTAL_NUM then
        skillIndex = 2;
    end

    unit:takeSkill(tonumber(skillIndex));
    for i = 1,3 do
       self:lightUp(unit,i)
       self:crystalCountUp();
    end
    megast.Battle:getInstance():sendEventToLua(self.scriptID,4,self.crystalCounter);
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
    event.unit:setBurstState(kBurstState_active);
    if event.index == 2 then
        event.unit:setInvincibleTime(8);
        self:showMessages(self.KABAUKILL_LIST)
    end
    return 1
end

function class:getTarget()
   local targetUnit = nil
   local hp = 101
   for i = 0,4 do
      local currentTarget = self:getPlayerUnit(i)
      if currentTarget ~= nil then
         local targetHp = summoner.Utility.getUnitHealthRate(currentTarget) * 100;
         if targetHp < hp then
            hp = targetHp
            targetUnit = currentTarget
         end
      end
   end

   return targetUnit
end

function class:getPlayerUnit(index)
    return megast.Battle:getInstance():getTeam(true):getTeamUnit(index);
end


function class:skillActiveSkillSetter(unit,index)
    unit:setActiveSkill(self.ACTIVE_SKILLS["SKILL"..index]);
end



--===================================================================================================================

--skill2の大技中にブレイクや麻痺や気絶されたらクリスタルを戻さないとダメ
function class:takeDamage(event)
    if self.crystalExcutionFlg and megast.Battle:getInstance():isHost() then
        self:skill2Compleat();
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
    end
    return 1;
end



function class:run (event)
    if event.spineEvent == "selectTarget" then
       self:setTargetPosition(event.unit)
    end
    if event.spineEvent == "addSP" then return self:addSP(event.unit) end
    if event.spineEvent == "crystalActionEnd" then 
        self:crystalStateEnd(event.unit) 
        -- if not self.isFirstSkilled then
        --     self.isFirstSkilled = true
        --     event.unit:addSP(100)
        --  end
    end
    if event.spineEvent == "skill2Start" then self:skill2Start() end
    if event.spineEvent == "skill2Compleat" and self:getIsHost() then 
        self:skill2Compleat() 
        megast.Battle:getInstance():sendEventToLua(self.scriptID,5,0);
    end
    return 1;
end


function class:setTargetPosition(unit)
      local uni = self:getTarget()
      if uni == nil then return end

      self:addBuff(uni,self.KIZETU_BUFF_ARGS[1])
      self:addBuff(uni,self.KIZETU_BUFF_ARGS[2])
      -- uni:takeDamage()
      uni:getTeamUnitCondition()
      unit:setPosition(uni:getPositionX(),uni:getPositionY())
end


--今回はaddSPはアニメーションイベントから呼ぶのでrunの中に入ってます
function class:addSP(unit)
  
    unit:addSP(self.spValue);
    
    return 1;
end

--===================================================================================================================
--トリガー　処理部分
--===================================================================================================================
function class:HPTriggersCheck(unit)
   if not self:getIsHost() then
      return;
   end

   local hpRate = summoner.Utility.getUnitHealthRate(unit) * 100;

   for index,trigger in pairs(self.HP_TRIGGERS) do
      if trigger.HP >= hpRate and not trigger.used then
         self:execTrigger(index)
      end
   end
end

-- トリガー実行。ホストのみ使用可能
function class:execTrigger(index,receiveNumber)
   if not self:getIsHost() or index == nil or table.maxn(self.TRIGGERS) < index then
      return
   end

   receiveNumber = receiveNumber ~= nil and receiveNumber or 3

   local action = "use" .. receiveNumber

   self.TRIGGERS[index].action(action)
   self.TRIGGERS[index].used = true

   if receiveNumber ~= 0 then
      megast.Battle:getInstance():sendEventToLua(self.scriptID,receiveNumber,index)
   end
end

function class:getIsHost()
   return megast.Battle:getInstance():isHost();
end


--===================================================================================================================
function class:showMessages(messages)
    for k,v in pairs(messages) do
        summoner.Utility.messageByEnemy(v.MESSAGE,v.DURATION,v.COLOR);
    end
end

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
--鉱山共通ギミック

function class:setReduceHitStop(unit)
    unit:setReduceHitStop(2, self.hitStopReduceRate);
end


--=====================================================================================================================================
--マルチ同期　今回はいらないけど一応残しておくよ
function class:receive3(args)
    self:getRage(self.gameUnit);
    return 1;
end

function class:receive4(args)
    self:lightUp(self.gameUnit,args.arg);
    return 1;
end

function class:receive5(args)
    self:skill2Compleat();
    return 1;
end


function class:getIsHost()
    return megast.Battle:getInstance():isHost();
end


--☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★
--☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★
--クリスタル関係
--ここから先がこいつのコア部分デース……

--クリスタルは内部クラスのような構造になっていて
--  1.自身が管理するオービット（ゲーム上に実際に見た目として存在するクリスタルの実態）
--  2.状態（アニメーション）を変える関数
--  3.アニメーション終了イベントが呼ばれたら、次の状態（アニメーション）へ遷移する関数
--
--この３つを持っています
--あとは必要に応じてspineのフレームイベント（run）の中からそれらを呼び出して操っています
--クリスタルの点灯数の管理はユニット本人がやっています。self.crystalCounterが現在点灯しているクリスタルの数デース。self.CRYSTAL_NUMがクリスタルの存在数デース。



-- ☆クリスタルのアニメーション遷移の仕様☆
--


-- 1.deactive状態で生成されます。クリスタルが光っていない待機状態。lightUpされない限りはこの状態です。

-- 2.lightUpメソッドを介して、activation状態にされた場合、activateアニメーションを再生。キラーンと光って点灯します
-- 3.ligtUpアニメーション終了後、active状態に移行。クリスタルが光っている待機状態です。特殊奥義を発動しない限りはこの状態です

-- 4.全てのクリスタルがactive状態の時(self.crystalCounter >= self.CRYSTAL_NUM の時）に奥義を発動するとskill2が発動します。skill2のアニメーションに仕込まれているフレームイベントから命令が飛び、全てのクリスタルがout状態になり画面外に飛んでいきます
-- 5.outアニメーション終了後、hide状態に移行。見えない状態です。skill2のアニメーションが終盤に差し掛かってアニメーションイベントが飛ぶまでとはこの状態です。
-- 6.skill2のアニメーション終了間際に、アニメーションイベントにより全てのクリスタルがstart状態にされます。
-- 7.start終了後、deactive状態に移行。クリスタルが光っていない待機状態。lightUpされない限りはこの状態です。2のフェーズに戻ります。以降2〜1をループ

--☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★
--☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★


-- /**
--  * @fn
--  * クリスタル初期化処理
--  * @brief スタートから呼ばれて、クリスタルを生成する命令を３回叩く
--  * @param （unit）ユニットのインスタンス
--  * @detail self.CRYSTAL_POSITIONSの中にポジションが記載してあるのでそれを渡してます。ここで生成されたクリスタルのインスタンスはself.crystalsの中に格納されます。
--  */
function class:initCrystals(unit)
    for i=1,3 do
        self.crystals[i] = self:createCrystal(unit,self.CRYSTAL_POSITIONS[i].x,self.CRYSTAL_POSITIONS[i].y);
    end
    
end


function class:setUpCrystalBuffs(event)
    self.crystalBuffs[1] = {
        action = function(luaInstance,unit)
            -- luaInstance:addBuffs(unit,luaInstance.FIRST_BUFF_ARGS);
            -- luaInstance:showMessages(luaInstance.BUFF_MESSAGES1);
        end
    }

    self.crystalBuffs[2] = {
        action = function(luaInstance,unit)
            -- luaInstance:addBuffs(unit,luaInstance.SECOND_BUFF_ARGS);
            -- luaInstance:showMessages(luaInstance.BUFF_MESSAGES2);
        end
    }

    self.crystalBuffs[3] = {
        action = function(luaInstance,unit)
            -- luaInstance:addBuffs(unit,luaInstance.THIRD_BUFF_ARGS);
            -- luaInstance:showMessages(luaInstance.BUFF_MESSAGES3);
        end
    }
end


-- /**
--  * @fn
--  * クリスタルを実際に生成する処理
--  * @brief initCrystalsから呼ばれるよ
--  * @param （unit）ユニットのインスタンス
--  * @param （x）クリスタルを配置するx座標
--  * @param （y）クリスタルを配置するy座標
--  * @detail クリスタルを実際にオービットで生成します。クリスタルは内部クラスのような感じでテーブルとして吐き出されます。
--  */
function class:createCrystal(unit,x,y)
    local crystal = {}

    crystal.orbit = unit:addOrbitSystem("crystal_idle_on");
    

    
    -- /**
--  * @fn
--  * クリスタルアニメーション終了時の制御
--  * @brief crystalStateEndから呼ばれるよ
--  * @param （class）ユニットluaのインスタンスです。このクラス内の関数ではselfがcrystalクラスのインスタンスになってしまうためです。
--  * @param （this）crystalクラスのインスタンスです。selfが混同すると危険なので、thisとして明示的に受け取るようにしました。
--  * @detail クリスタルのアニメーションが終了した時に呼ばれる。今のステートを見て、次のアニメーションが何になるかをここで定義しているので、アニメーションの遷移を変えるならここをいじってください
--  */
    crystal.endState = function(class,this)
        if this.state == class.CRYSTAL_STATES.start then
            this.switchState(class,this,class.CRYSTAL_STATES.deactive);
        elseif this.state == class.CRYSTAL_STATES.activation then
            this.switchState(class,this,class.CRYSTAL_STATES.active);
        elseif this.state == class.CRYSTAL_STATES.out then
            this.switchState(class,this,class.CRYSTAL_STATES.hide);
        end
    end

    -- /**
--  * @fn
--  * クリスタルアニメーション終了時の制御
--  * @brief  クリスタルのアニメーションを変更したい時に呼んでね。
--  * @param （class）ユニットluaのインスタンスです。このクラス内の関数ではselfがcrystalクラスのインスタンスになってしまうためです。
--  * @param （this）crystalクラスのインスタンスです。selfが混同すると危険なので、thisとして明示的に受け取るようにしました。
--  * @param （targetState）CRYSTAL_STATESのどれかを渡してください。
--  * @detail クリスタルのアニメーションを変更したい時に呼ぶ。外からも呼べる。
--  */
    crystal.switchState = function(class,this,targetState)
        this.state = targetState;
        if targetState == class.CRYSTAL_STATES.active then
            this.orbit:takeAnimation(0,"crystal_idle_on",true);
        end
        if targetState == class.CRYSTAL_STATES.deactive then
            this.orbit:takeAnimation(0,"crystal_idle_off",true);
        end
        if targetState == class.CRYSTAL_STATES.activation then
            this.orbit:takeAnimation(0,"crystal_activate",true);
        end
        if targetState == class.CRYSTAL_STATES.start then
            this.orbit:takeAnimation(0,"crystal_in",true);
        end

        if targetState == class.CRYSTAL_STATES.out then
            this.orbit:takeAnimation(0,"crystal_out",true);
        end

        if targetState == class.CRYSTAL_STATES.hide then
            this.orbit:takeAnimation(0,"crystal_hide",true);
        end
    end

    
    crystal.orbit:setPosition(x,y);
    crystal.orbit:setZOrder(8999);

    --もしクリスタルの初期状態を変えたければここでいじってください。最初から点灯状態にしたいだとか
    crystal.orbit:takeAnimation(0,"crystal_idle_off",true);
    crystal.state = self.CRYSTAL_STATES.deactive;

    return crystal;
end



-- /**
--  * @fn
--  * クリスタルのアニメーション終了時に呼ばれる処理
--  * @brief spineイベントから呼ばれるよ
--  * @param （unit）ユニットのインスタンス　この場合はオービットシステム（crystalそのもの）です
--  * @detail 渡ってきたオービットシステムと一致するオービットを持つcrystalクラスのインスタンスに対してアニメーションが終わったぞーと言いにいきます。
--  */
function class:crystalStateEnd(unit)
    for i=1,self.CRYSTAL_NUM do
        if self.crystals[i].orbit == unit then
            self.crystals[i].endState(self,self.crystals[i]);
            return;
        end
    end
end

function class:crystalCountUp()
    self.crystalCounter = self.crystalCounter + 1;
end


-- /**
--  * @fn
--  * クリスタルをアクティブ状態にするよ！
--  * @brief クリスタルを光らせたい時はとりあえずこいつを叩けばいい。
--  * @param （unit）ユニットのインスタンス　樹精霊本人です。バフかけたりした時に使うので必要
--  * @param （num）何番目のクリスタルを点灯するのか
--  * @detail カウントは別途やってね！
--  */

function class:lightUp(unit,num)
    if num > self.CRYSTAL_NUM then
        return;
    end

    if self.crystalBuffs[num] ~= nil then
        self.crystalBuffs[num].action(self,unit);
        self.crystalBuffs[num] = nil;
    end
    

    for i=1,num do
        if self.crystals[i].state == self.CRYSTAL_STATES.deactive then
            self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.activation);
        end
    end
end



-- /**
--  * @fn
--  * クリスタルを奥義状態にするよ！
--  * @brief spineイベントから呼ばれる。skill2の時に。
--  * @detail クリスタルをみんな一旦退出させるぜ
--  */
function class:skill2Start()
    self.crystalExcutionFlg = true;
    self:excutionCrystals();
end

function class:excutionCrystals()
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.out);
    end
end


-- /**
--  * @fn
--  * クリスタルを元に戻すよ！
--  * @brief spineイベントから呼ばれる。skill2の時に。
--  * @detail クリスタルをみんな再入場させるよ！
--  */
function class:skill2Compleat()
    self.crystalExcutionFlg = false;
    self.crystalCounter = 0;
    self:restertCrystals();
end

function class:restertCrystals()
    for i=1,self.CRYSTAL_NUM do
        self.crystals[i].switchState(self,self.crystals[i],self.CRYSTAL_STATES.start);
    end
end




class:publish();

return class;