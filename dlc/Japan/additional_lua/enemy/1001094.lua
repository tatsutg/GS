--@additionalEnemy,100111536,101631536,100233536,100111536,100111536
function new(id)
    print("10000 new ");
    local instance = {
        thisID = id,            --生成時に渡されたidを保持しておく（マルチの同期に使う）
        attackChecker = false,  --takeAttackが無限ループしないようにするためのフラグ
        skillChecker = false,   --takeskillが無限ループしないようにするためのフラグ
        summonedNumber = 0,     --自分が今どのインデックスまでユニットを召喚したか覚えておく
        actionCounter = 3,      --雑魚召喚用のカウンター　executeActionごとに増加
        nextSummonCounter = 4, --次に雑魚を召喚するまでの行動数
        subBar = nil,          --手のブレイクゲージ　今は非表示にして使っていない
        hand = nil,             --手のorbitsystem
        unit = nil,             --自分
        meteor = nil,           --時間切れ攻撃のOrbitSystem 別にここで保持しておく理由もなかった
        Gates = {               --黒い霧　前と後ろ
            back = nil,         
            front = nil
        },
        handRank = 0,           --手の段階
        handTimer = 0,          --手の攻撃用のタイマー
        handBreakMax = 0,       --手のブレイク計算用　生成時のブレイク値
        handDownTimer = 0,      --手がダウンしている時間を管理するタイマー
        isDown = false,         --ダウン中フラグ　このフラグが立っている間はspが増えない
        isIdle = true,          --idleフラグ　これが立っているときだけ攻撃用のタイマーが進む
        isTimeOver = false,     --時間切攻撃を出すときに立てるだけ立てておく
        trollCount = 0,         --トロルが連続召喚されないためのもの
        timelimit  = 155,       --ワールドエンド発動までの時間
        startX = -250,
        startY = -50,
        gameUnit = nil,

        --召喚する雑魚のエネミーIDテーブル　この中からランダム 一番左端からfirst second ..... other
        summonUnitIDs = {100111536, 101631536, 100233536, 100111536,100111536},

        --召喚する雑魚の確率 百分率　全部合計で１００になるようにしてください。
        summonRate = {
            first = 40,
            second = 30,
            third = 30,
            fourth = 0,
            other = 0
        },

        --手が放つ状態異常の確率
        ringEffectRate = {
            combution = 34,     --燃焼
            paralysis = 33,     --麻痺
            poison = 33         --毒
        },

        

        consts = {
            handAttackTime = 10,        --手の攻撃間隔
            handBreakPoint = 16000,      --手がブレイク状態になるまでに必要なブレイク値
            handDownTime = 9,          --手がブレイクから立ち直るまでの時間
            scaleOffset = 1           --手が大きすぎたので小さくしたかった（過去形
        },

        summon = function (this,unit)
        
            if this.summonedNumber > 4 then--雑魚召喚は4体まで
                this.summonedNumber = 0;
            end

            this.trollCount = this.trollCount - 1;--トロールの再出現カウント

            local rand = LuaUtilities.rand(0,100);
            local currentIndex = 1;

            if rand <  this.summonRate.first then
                currentIndex = 1;
            elseif rand <  this.summonRate.first + this.summonRate.second then
                currentIndex = 2;
            elseif rand <  this.summonRate.first + this.summonRate.second + this.summonRate.third then
                --トロールは連続で呼ばれないため、連続で当選した場合は他のユニットを出す
                if this.trollCount <= 0 then
                    currentIndex = 3;
                    this.trollCount = 3;
                else
                    currentIndex = 2;
                end
                
            elseif rand <  this.summonRate.first + this.summonRate.second + this.summonRate.third + this.summonRate.fourth then
                currentIndex = 4;
            else
                currentIndex = 5;
            end
            
             --ドラゴンがいたら召喚しないけどカウントは進めとく
            local issummon = true;
                for i = 0 , megast.Battle:getInstance():getEnemyTeam():getIndexMax() do
                    local teamunit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
                    if teamunit ~= nil then
                        if teamunit:getEnemyID() == 1001091 then 
                            issummon = false;
                        end
                    end
                end
           
            local i_rand = LuaUtilities.rand(0,2) + 1;--2体か3体出す
            for i = 0 , i_rand do

                if issummon then
                      local gaul = unit:getTeam():addUnit(this.summonedNumber,this.summonUnitIDs[currentIndex]);
                      --指定したインデックスの位置に指定したエネミーIDのユニットを出す
                end

                this.summonedNumber = this.summonedNumber + 1;
                if this.summonedNumber > 4 then--雑魚召喚は4体まで
                    this.summonedNumber = 0;
                end
            end
            
            if issummon then
                    this.showMessage(this);
                    megast.Battle:getInstance():sendEventToLua(this.thisID,6,0);
            end
            
            return 1;
        end,

        showMessage = function(this)
            BattleControl:get():pushEnemyInfomation(summoner.Text:fetchByEnemyID(500681509).mess1,255,255,255,3);
        end,

        skill1Complete = function(this,unit)
            this.hand:takeAnimation(0,"idle",true);
            this.isIdle = true;
            return 1;
        end,

        skill2Complete = function(this,unit)
            this.hand:takeAnimation(0,"idle",true);
            this.isIdle = true;
            return 1;
        end,

        regeneratComplete = function(this,unit)
            this.hand:takeAnimation(0,"idle",true);
            this.isIdle = true;

            return 1;
        end,

        --前進終了時　時間切攻撃の判断と開始はこの中
        frontComplete = function(this,unit)
            local ishost = megast.Battle:getInstance():isHost();
            this.hand:takeAnimation(0,"idle",true);
            this.isIdle = true;
            return 1;
        end,

        damageComplete = function(this,unit)
            this.hand:takeAnimation(0,"damage_idle",true);
            return 1;
        end,

        onDie = function(this,unit)
            this.hand:takeAnimation(0,"out",false);
            this.Gates.back:takeAnimation(0,"out",false);
            this.Gates.front:takeAnimation(0,"out",false);

            this.hand = nil;
            this.Gates.back = nil;
            this.Gates.front = nil;
            --他のユニットを全て倒す
            for i = 0 , megast.Battle:getInstance():getEnemyTeam():getIndexMax() do
                local teamunit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
                if teamunit ~= nil then
                    teamunit:setHP(0);
                end
            end
        end,
        
        addSP = function (this,unit)
        -- 火ドラがいきてるときはSPふえない
            for i = 0 , megast.Battle:getInstance():getEnemyTeam():getIndexMax() do
                local teamunit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
                if teamunit ~= nil then
                if teamunit:getEnemyID() == 1001091 then 
                    return 1;
                end
                end
            end
        
            if not this.isDown and not this.isTimeOver then
                unit:addSP(20);
            end

            return 1;
        end,

        --共通変数
        param = {
          version = 1.3
          ,isUpdate = 1
        },

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)--手の攻撃タイミングと攻撃の種類を同期する

            this.hand:takeAnimation(0,"skill1",true);

            local efAnimationName = "";
            
            local activeSkillNum = 0;

            if intparam == 0 then
                efAnimationName = "skill1a";
                activeSkillNum = 4;
            elseif intparam == 1 then
                efAnimationName = "skill1b";
                activeSkillNum = 5;
            else
                efAnimationName = "skill1c";
                activeSkillNum = 6;
            end


            local skillOrbit = this.unit:addOrbitSystemWithFile("50068HandEF",efAnimationName);
            skillOrbit:setPositionX(this.hand:getPositionX());
            skillOrbit:setPositionY(this.hand:getPositionY());
            this.hand:setActiveSkill(activeSkillNum);
            this.hand:showSkillName(activeSkillNum);
            skillOrbit:getSkeleton():setScale(this.consts.scaleOffset);
           
            return 1;
        
        end,

        receive2 = function (this , intparam)--手のダウンを同期する
            this.hand:takeAnimation(0,"damage",true);
            return 1;
        end,

        receive3 = function (this , intparam)--手の復帰を同期する
            this.hand:takeAnimation(0,"regenerating",true);
            return 1;
        end,


        receive4 = function (this , intparam)--タイムオーバー攻撃の同期をする
            this.hand:takeAnimation(0,"skill2",true);
            local ef = this.unit:addOrbitSystemWithFile("50068HandEF","skill2");
            ef:setPositionX(this.hand:getPositionX());
            ef:setPositionY(this.hand:getPositionY());
            ef:getSkeleton():setScale(this.consts.scaleOffset);
            
            this.meteor = this.unit:addOrbitSystemWithFile("50068HandEF","meteor");
            this.meteor:setPositionX(0);
            this.meteor:setPositionY(0);
            this.meteor:setActiveSkill(7);
            this.meteor:getSkeleton():setScale(this.consts.scaleOffset);

            this.hand:setActiveSkill(7);
            this.hand:showSkillName(7);
            
            this.gameUnit:addOrbitSystemCameraWithFile("50068HandEF","rockAndFlush",false);
            return 1;
        end,
        
        receive5 = function (this , intparam)--手の復帰を同期する
            this.hand:takeAnimation(0,"front",true);
            this.isIdle = false;
            return 1;
        end,

        receive6 = function(this,intparam)
            this.showMessage(this);
            return 1;
        end,

        receive7 = function(this,intparam)
            this.onDie(this,this.gameUnit);
            return 1;
        end,
               
        deadend = function (this , unit)--プレイヤー全滅
            local i = 0;
            for i = 0 , 4 do
                local teamunit = megast.Battle:getInstance():getPlayerTeam():getTeamUnit(i);
                if teamunit ~= nil then
                    teamunit:setHP(0);
                    teamunit:getTeam():deadUnit(teamunit:getIndex());
                end
            end
            for i = 0 , megast.Battle:getInstance():getEnemyTeam():getIndexMax() do
                local teamunit = megast.Battle:getInstance():getEnemyTeam():getTeamUnit(i);
                if teamunit ~= nil then
                if teamunit:getUnitID() ~= 500681113 then 
                    teamunit:setHP(0);
                end
                end
            end
            if megast.Battle:getInstance():getBattleState() == kBattleState_active then
               megast.Battle:getInstance():waveEnd(false);
            end
            return 1;
        end,
        
        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "skill1Complete" then return this.skill1Complete(this,unit) end
            if str == "skill2Complete" then return this.skill2Complete(this,unit) end
            if str == "regeneratComplete" then return this.regeneratComplete(this,unit) end
            if str == "frontComplete" then return this.frontComplete(this,unit) end
            if str == "damageComplete" then return this.damageComplete(this,unit) end
            if str == "deadend" then return this.deadend(this,unit) end
            return 1;
        end,

        --version1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
            return value;
        end,

        takeBreake = function (this,unit)
            return 1;
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            return 1;
        end,

        startWave = function (this , unit , waveNum)--この中で手とか生成してます
            BattleControl:get():removeUnusedTexture();
        
            this.unit = unit;
            this.Gates.back = unit:addOrbitSystemWithFile("50068back_gate","idle");
            this.Gates.back:setEndAnimationName("none");
            this.Gates.back:takeAnimation(0,"idle",true);
            this.Gates.back:setPositionX(unit:getPositionX() + 300);
            this.Gates.back:setPositionY(200);
            this.Gates.back:setZOrder(3);
            this.Gates.back:getSkeleton():setScale(this.consts.scaleOffset);


            this.Gates.front = unit:addOrbitSystemWithFile("50068HandEF","idle");
            this.Gates.front:setEndAnimationName("none");
            this.Gates.front:takeAnimation(0,"idle",true);
            this.Gates.front:setPositionX(unit:getPositionX() + 300);
            this.Gates.front:setPositionY(200);
            this.Gates.front:setZOrder(8999);
            this.Gates.front:getSkeleton():setScale(this.consts.scaleOffset);

            local totalTime = BattleControl:get():getTime();
            
            local targetRank = BattleControl:get():getTime() / this.timelimit * 5;
            this.handRank = math.floor(targetRank);
            
            this.hand = unit:addOrbitSystemWithFile("50068hand","idle");
            this.hand:setEndAnimationName("none");
            this.hand:takeAnimation(0,"idle",true);
            this.hand:setPositionX(this.handRank * 100 + unit:getPositionX() - 100);
            this.hand:setPositionY(180);
            this.hand:setHitCountMax(9999);
            this.hand:setBaseHP(999999999);
            this.hand:setHP(999999999);
            this.hand:setOrbitType(2);
            this.hand:setZOrder(5000);
            this.handBreakMax = this.hand:getBreakPoint();
            this.hand:getSkeleton():setScale(this.consts.scaleOffset);
            this.hand:setSize(3);

            this.subBar =  BattleControl:get():createSubBar();
            this.subBar:setWidth(350); --バーの全体の長さを指定
            this.subBar:setHeight(17);
            this.subBar:setPercent(0); --バーの残量を0%に指定
            this.subBar:setVisible(false);
            this.subBar:setPositionX(-210);
            this.subBar:setPositionY(350);
      
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            local ishost = megast.Battle:getInstance():isHost();
            unit:setPositionX(this.startX);
            unit:setPositionY(this.startY);
               
            if this.handRank > 4 and this.isIdle and ishost then
                this.hand:takeAnimation(0,"skill2",true);
                this.hand:setActiveSkill(7);
                this.hand:showSkillName(7);
                local ef = unit:addOrbitSystemWithFile("50068HandEF","skill2");
                ef:setEndAnimationName("none");
                ef:setPositionX(this.hand:getPositionX());
                ef:setPositionY(this.hand:getPositionY());
                ef:getSkeleton():setScale(this.consts.scaleOffset);
                
                this.meteor = unit:addOrbitSystemWithFile("50068HandEF","meteor");
                this.meteor:setPositionX(0);
                this.meteor:setPositionY(0);
                this.meteor:setActiveSkill(7);
                this.meteor:getSkeleton():setScale(this.consts.scaleOffset);


                unit:addOrbitSystemCameraWithFile("50068HandEF","rockAndFlush",false);
                
                this.isIdle = false;
                this.isTimeOver = true;
                megast.Battle:getInstance():sendEventToLua(this.thisID,4,0);--時間切攻撃をゲストに通知
            end
            
            if this.hand ~= nil and ishost then
                
                --ブレイク値計算している部分　最大値からいくつ減ったかで計算
                --ブレイク値のリセットとダウン時間のリセットはこの中　ダウンしたことをゲストに伝える
                -- this.subBar:setVisible(true);
                local breakParCent = 100 * (this.consts.handBreakPoint - (this.handBreakMax - this.hand:getBreakPoint()))/this.consts.handBreakPoint;
                this.subBar:setPercent(breakParCent);
                if breakParCent <= 0 and not this.isTimeOver then
                    this.subBar:setVisible(false);
                    this.isDown = true;
                    this.isIdle = false;
                    this.hand:takeAnimation(0,"damage",true);
                    this.hand:setBreakPoint(this.handBreakMax);
                    this.handDownTimer = 0;
                    megast.Battle:getInstance():sendEventToLua(this.thisID,2,0);
                end
            end

            --ダウン中　ダウン時間が終わったら色々リセットして起き上がらせる　ダウン終了はゲストに通知
            if this.isDown and ishost then
               this.handDownTimer = this.handDownTimer + deltatime;
                if this.hand ~= nil and this.handDownTimer >= this.consts.handDownTime then
                    this.isDown = false;
                    this.isIdle = true;
                    this.hand:setBreakPoint(this.handBreakMax);
                    this.hand:takeAnimation(0,"regenerating",true);
                    megast.Battle:getInstance():sendEventToLua(this.thisID,3,0);
                end
            end

            if this.isIdle then
                this.handTimer = this.handTimer + deltatime;
            end
            
            --時間によって前にでる
            if ishost then
               local targetRank = BattleControl:get():getTime() / this.timelimit * 5;
               targetRank = math.floor(targetRank);
               if this.hand ~= nil and this.handRank < targetRank and targetRank < 6 then
                   this.hand:takeAnimation(0,"front",true);
                   this.handRank = targetRank;
                   megast.Battle:getInstance():sendEventToLua(this.thisID,5,0);--前進を同期
               end

            end
            
            --手が前にですぎないようにする
            if this.hand ~= nil and this.hand:getAnimationPositionX() > 250 then
                this.hand:setPositionX(150);
            end
            
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            
            return value;
        end,

        --version1.0
        start = function (this , unit)
            
            this.gameUnit = unit;
            unit:setSPGainValue(0);--大型ボスはsp自然増加はなし


            return 1;
        end,

        excuteAction = function (this , unit)
            this.actionCounter = this.actionCounter + 1;

            local ishost = megast.Battle:getInstance():isHost();--雑魚を召喚できる権利を持っているのはホストだけ
            if ishost then
                if this.actionCounter == this.nextSummonCounter then
                    this.summon(this,unit);

                    this.actionCounter = 0;
                    rand = math.random(3);
                    this.nextSummonCounter = this.nextSummonCounter + rand;--次の召喚までの行動数を決める　ある程度ランダムにしたいらしいということで0 ~ 3の乱数を足す
                end
            end
            return 1;
        end,

        takeIdle = function (this , unit)
            return 1;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
            
            return 1;
        end,

        takeAttack = function (this , unit , index)
            if index == 1 then
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            end



            local target = unit:getTargetUnit() 
            local distance = BattleUtilities.getUnitDistance(unit,target)
            local ishost = megast.Battle:getInstance():isHost();
            print(distance);
            if ishost then
                --距離判定
                if distance > 400 and this.attackChecker == false then
                    this.attackChecker = true;
                    unit:takeAttack(2)
                    return 0;
                elseif this.attackChecker == false then
                    
                    this.attackChecker = true;
                    
                    unit:takeAttack(1);
                    
                    return 0;
                end
            end
            this.attackChecker = false;
            return 1;
        end,

        takeSkill = function (this,unit,index)            
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
            
                --手の攻撃　
                this.handTimer = 0;
                this.hand:takeAnimation(0,"skill1",true);

                local efAnimationName = "";
                local rand = LuaUtilities.rand(0,100);
                local activeSkillNum = 0;

                if rand <= this.ringEffectRate.combution then
                    efAnimationName = "skill1a";
                    activeSkillNum = 4;
                    megast.Battle:getInstance():sendEventToLua(this.thisID,1,0);--攻撃が始まったことと攻撃の種類をゲストに通知
                elseif rand <= this.ringEffectRate.combution + this.ringEffectRate.paralysis then
                    efAnimationName = "skill1b";
                    activeSkillNum = 5;
                    megast.Battle:getInstance():sendEventToLua(this.thisID,1,1);--攻撃が始まったことと攻撃の種類をゲストに通知
                else
                    efAnimationName = "skill1c";
                    activeSkillNum = 6;
                    megast.Battle:getInstance():sendEventToLua(this.thisID,1,2);--攻撃が始まったことと攻撃の種類をゲストに通知
                end

                --orbitSystem生成して必要な情報をセット
                local skillOrbit = unit:addOrbitSystemWithFile("50068HandEF",efAnimationName);
                skillOrbit:setPositionX(this.hand:getPositionX());
                skillOrbit:setPositionY(this.hand:getPositionY());
                this.hand:setActiveSkill(activeSkillNum);
                this.hand:showSkillName(activeSkillNum);
                skillOrbit:getSkeleton():setScale(this.consts.scaleOffset);
                this.isIdle = false;
            end
            unit:setNextAnimationName("skill1");               
            return 1;
        end,

        takeDamage = function (this , unit)
            return 1;
        end,

        dead = function (this , unit)
            this.onDie(this,unit);
            megast.Battle:getInstance():sendEventToLua(this.thisID,7,0);--時間切攻撃をゲストに通知
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end

