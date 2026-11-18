function new(id)
    print("500522015 new ");
    local instance = {

        --ソフィクラス
        -- クエスト5               ★5ソフィ   エネミーID：500522015    
        Class = 
        {
            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Values
            isFirstStepUpdate = false,

            --uniqueID
            ThisUniqueId = id,

            --ThisUnit
            ThisUnit = nil,

            --各アタックのレート
            attackRates = 
            {
                 --アタックレート1
                rate_attack1 = 20,
    
                --アタックレート2
                rate_attack2 = 35,


                --遠距離攻撃判定距離
                longAttackRange_Boomerang = 150,
                longAttackRange_Humicomi = 150
    
                --アタックレート3
                --rate_skill1 = 45,
    
                --アタックレート4
                --rate_attack4 = 30
            },

            --各スキルのクールタイム設定
            delayMaxTimers = 
            {
                attack4_Ct = 8,
                skill1_Ct = 20
            },
            --計算用
            delayCounterTimers = 
            {
                attack4_Ct = 0,
                skill1_Ct = 0
            },

            --アタックチェック
            isAttackChecker = false,

            --スキルチェック
            isSkillChecker = false,

            --特殊スキルチェック
            isSpecialChecker = false,

            --バックステップを行う　X　座標
            takeBackStepRange = 150,

            ----料理バフ関係
            --付呪されるバフ一覧
            foodBuff_AddBuffValue = 4,
            foodBuff_AddBuffList = {[0]=1003,[1]=1006,[2]=1015,[3]=1019},
            --現在のステージ
            foodBuff_CurStage = 0,
            --料理バフ付呪HP%
            foodBuff_UseHp = {[0]=80,[1]=40,[2]=20},
            --料理バフ付呪回数
            foodBuff_StageValue = 0,
            --料理バフが使われたかフラグ
            foodBuff_IsUse = {[0]=false,[1]=false,[2]=false},

            --奥義ゲージ上昇中か否か
            ultimateSkill_SpClockUp = false,

            ----究極秘奥義関係
            --現在のステージ
            ultimateSkill_CurStage = 0,
            --究極秘奥義付呪HP%
            ultimateSkill_UseHp = {[0]=50,[1]=20},
            --究極秘奥義付呪回数
            ultimateSkill_StageValue = 0,
            --究極秘奥義が使われたかフラグ
            ultimateSkill_IsUse = {[0]=false,[1]=false},
            --今チャージ中か
            ultimateSkill_IsOverCharge = false,

            ----特殊スキル関係
            --特殊スキルは連続して出ると時々何故かアニメーションが止まるのでディレイを設ける
            --CT
            specialSkill_LimitDelayTime = 5,
            --カウント
            specialSkill_DelayTimer = 0,
            --現在ディレイ中か
            specialSkill_isUse = false,

            --バターブリオッシュ
            Buff_1003 =
            {
                ID = -60,
                TYPE = 7,
                VALUE = 5000,
                TIME = 10,
                ICONID = 35,
                EFFECTID = 0,
            },
            --ドラゴンステーキ
            Buff_1006 =
            {
                ID = -60,
                TYPE = 17,
                VALUE = 30,
                TIME = 2000,
                ICONID = 26,
                EFFECTID = 0,
            },
            --ホットドッグ
            Buff_1015 =
            {
                ID = -60,
                TYPE = 28,
                VALUE = 30,
                TIME = 2000,
                ICONID = 7,
                EFFECTID = 0,                
            },
            --スペシャルパエリア
            Buff_1019 =
            {
                ID = -60,
                TYPE = 0,
                VALUE = 0,
                TIME = 2000,
                ICONID = 36,
                EFFECTID = 0,
            },
            messages = summoner.Text:fetchByEnemyID(500522015),

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆


            --初期化
            Initialize = function(this,unit)
                return 1;
            end,

            --アップデート最初の一度のみ実行される。
            FirstUpdateInitialize = function(this,unit)

                this.Class.ThisUnit = unit;
                
                return 1;
            end,

            --アップデート
            Update = function(this,unit,deltatime)

                if this.Class.isFirstStepUpdate == false then
                    this.Class.FirstUpdateInitialize(this,unit);
                    this.Class.isFirstStepUpdate = true;
                end

                local isHost = megast.Battle:getInstance():isHost();
                if not isHost then
                    return 1;
                end

                local breaktime = unit.m_breaktime;
                --ブレイク現在しているかどうか、ブレイク中は各Timerの更新は行われない。
                if breaktime <= 0 then
                    this.Class.delayCounterTimers.attack4_Ct = this.Class.delayCounterTimers.attack4_Ct + deltatime;
                    this.Class.delayCounterTimers.skill1_Ct = this.Class.delayCounterTimers.skill1_Ct + deltatime;
    
                    --連続して特殊スキルが発動するとおかしくなるので５秒のdelayを設ける
                    if this.Class.specialSkill_isUse == true then
                        this.Class.specialSkill_DelayTimer = this.Class.specialSkill_DelayTimer + deltatime;
                        if this.Class.specialSkill_LimitDelayTime <= this.Class.specialSkill_DelayTimer then
                            this.Class.drawDebugLog(this,unit,"DEBUGLOG--クールタイム終了",160,255,160,2);
                            this.Class.specialSkill_isUse = false;
                            this.Class.specialSkill_DelayTimer = 0;
                        end
                    end
                end

                return 1;
            end,

            --LunScript
            --if str == "runSkillAttack" then return this.Class.runSkillAttack(this,unit) end
            runScriptUpdate = function(this , unit , str)

                if str == "addSP" then return this.Class.addSP(this,unit) end

                if str == "endSetUpCharge" then return this.Class.endSetUpCharge(this,unit) end
                if str == "repeatCharge" then return this.Class.repeatCharge(this,unit) end

                return 1;
            end,

            --アタック分岐
            takeAttackBranch = function(this,unit,index)

                if unit ~= nil then

                    --遠距離時、近距離時でいろいろ挙動が変わる。またCTなどもあるため、それによって様々な挙動を見せる。
                    local targetDistance = this.Class.getTargetDistance(this,unit);

                    --距離が 300 以上離れていたらブーメランで攻撃する
                    if this.Class.attackRates.longAttackRange_Boomerang < targetDistance then

                        --残念CT中だった
                        if this.Class.delayCounterTimers.attack4_Ct >= this.Class.delayMaxTimers.attack4_Ct then 
                            unit:takeAttack(4);

                            this.Class.RequestSendEventToLua_1(this,unit,4);

                            this.Class.delayCounterTimers.attack4_Ct = 0;
    
                            return 0;
                        end
                    end

                    --longAttackRange_Humicomi ~ longAttackRange_Boomerang の範囲距離だった場合は前進攻撃
                    if this.Class.attackRates.longAttackRange_Humicomi < targetDistance then
                        unit:takeAttack(3);
                        this.Class.RequestSendEventToLua_1(this,unit,3);
                        this.Class.resetAttackTime(this,unit);

                        return 0;
                    end

                    --それ以外はランダム。ランダムは 百分率。アタック1,アタック2,の確率合計を 100 から引いた値が 確率になります。
                    --スキルのdelayがまだあった場合はそれ抜きでランダム、あればそれアリでランダムで、もし攻撃がでたらCTを初期化する
                    local random = math.random(this.Class.attackRates.rate_attack1 + this.Class.attackRates.rate_attack2);
                    if this.Class.delayCounterTimers.skill1_Ct >= this.Class.delayMaxTimers.skill1_Ct then
                        random = math.random(100);
                    end

                    if random <= this.Class.attackRates.rate_attack1 then
                        unit:takeAttack(1);
                        this.Class.RequestSendEventToLua_1(this,unit,1);
                        return 0;
                    elseif random <= this.Class.attackRates.rate_attack1 + this.Class.attackRates.rate_attack2 then
                        unit:takeAttack(2);
                        this.Class.RequestSendEventToLua_1(this,unit,2);
                        return 0;
                    elseif random <= 100 then
                        this.Class.drawDebugLog(this,unit,"DEBUGLOG--アタック分岐からのtakeSkill(1)を発動させます。",160,255,160,1);
                        this.Class.delayCounterTimers.skill1_Ct = 0;

                        --Skill発動になるので isChekerを操作、実質アタックでないので false に、かつスキルを使うので chekrを true
                        this.Class.isSkillChecker = true;
                        this.Class.isAttackChecker = false;
                        unit:takeSkill(1);
                        this.Class.RequestSendEventToLua_2(this,unit,1);
                        return 0;
                    end

                end

                return 1;
            end,

            --スキル分岐用
            takeSkillBranch = function(this,unit,index)

                local isHost = megast.Battle:getInstance():isHost();

                if this.Class.isSkillChecker == false then

                    this.Class.isSkillChecker = true;
                    if this.Class.ultimateSkill_IsOverCharge == true then
                        unit:setSetupAnimationName("ultimate_ChargePose");
                        this.Class.ultimateSkill_IsOverCharge = false;
                        unit:takeSkill(2);
                        return 0;
                    else
                        unit:setSetupAnimationName("");
                    end
    
                    unit:takeSkill(3);

                    if isHost then
                        this.Class.resetAttackTime(this,unit);
                    end

                    return 0;
                end

                this.Class.isSkillChecker = false;
                if index == 1 then
                    unit:setActiveSkill(5);
                elseif index == 2 then
                    unit:setActiveSkill(6);
                elseif index == 3 then
                    unit:setActiveSkill(7);        
                end
                return 1;
            end,

            --アイドル分岐用
            takeIdleBranch = function(this,unit)

                local isHost = megast.Battle:getInstance():isHost();

                if isHost then
                    if this.Class.takeBackStepRange <= unit:getAnimationPositionX() then
                        this.takeBack();
                        this.Class.resetAttackTime(this,unit);
                        this.Class.RequestSendEventToLua_6(this,unit,1000);
                    end
                end

                return 1;
            end,

            --だめーじ分岐用
            takeDamageBranch = function(this,unit)

                this.Class.ultimateSkill_IsOverCharge = false;

                return 1;
            end,

            --死亡分岐用
            takeDeadBranch = function(this,unit)
                return 1;
            end,

            --ブレイク分岐用
            takeBreakeBranch = function(this,unit)

                --ブレイクに入ったらオーバーチャージは止まる。
                --またブレイク後すぐにSpecialSkillが出ると何故か止まってしまう為、ブレイクした = スキル使用したことにする。
                --こうすることによってUpdateではブレイク中はタイマーの更新が行われない為
                --ブレイク後[specialSkill_LimitDelayTime]経過後に発動するようになる。
                --また[specialSkill_DelayTimer]を 0 にすることによって isUseが true の時のブレイクにも対応する
                this.Class.ultimateSkill_IsOverCharge = false;
                this.Class.specialSkill_isUse = true;
                this.Class.specialSkill_DelayTimer = 0;

                return 1;
            end,

            --excureAction分岐用
            excuteActionBranch = function(this,unit)

                local isHost = megast.Battle:getInstance():isHost();
                if not isHost then
                    return 1;
                end

                if this.Class.isSpecialChecker == false then

                    this.Class.isSpecialChecker = true;
                    local breaktime = unit.m_breaktime;
                    --ブレイク現在しているかどうか
                    if breaktime <= 0 then
                        if this.Class.specialSkill_isUse == false then
                            this.Class.drawDebugLog(this,unit,"DEBUGLOG--スキル準備完了",160,255,160,1);
                            --ここで料理バフを符呪するか否かをチェックして付呪する場合は return 0してアクションはCancel
                            local value = this.Class.addFoodBuff(this,unit);
                            if value == 0 then
                                this.Class.specialSkill_isUse = true;
                                return 0;
                            end
                            --ここで究極必殺技を出すか否かをチェックして付呪する場合は return 0してアクションはCancel
                            local valueultimate = this.Class.ultimateSkillReady(this,unit);
                            if valueultimate == 0 then
                                this.Class.specialSkill_isUse = true;
                                return 0;
                            end
                        else
                            this.Class.drawDebugLog(this,unit,"DEBUGLOG--まだスキルを使用できません",160,255,160,1);
                        end
                    end
                end

                this.Class.isSpecialChecker = false;

                return 1;
            end,

            --receive分岐用
            receiveBranch_1 = function(this,intparam)
                this.Class.drawDebugLog(this,this.Class.ThisUnit,"DEBUGLOG--マルチの同期-通常攻撃の同期...",181,37,255,1);

                if intparam == 1 then
                    this.Class.ThisUnit:takeAttack(1);
                elseif intparam == 2 then
                    this.Class.ThisUnit:takeAttack(2);
                elseif intparam == 3 then
                    this.Class.ThisUnit:takeAttack(3);
                elseif intparam == 4 then
                    this.Class.ThisUnit:takeAttack(4);                     
                end

                return 1;
            end,

            receiveBranch_2 = function(this,intparam)
                this.Class.drawDebugLog(this,this.Class.ThisUnit,"DEBUGLOG--マルチの同期-スキル攻撃の同期...",181,37,255,1);

                if intparam == 1 then

                    this.Class.isSkillChecker = true;
                    this.Class.ThisUnit:takeSkill(1);             
                end

                return 1;
            end,

                        receiveBranch_3 = function(this,intparam)
                this.Class.drawDebugLog(this,this.Class.ThisUnit,"DEBUGLOG--マルチの同期-特殊スキル-料理の同期...",181,37,255,1);

                --[[
                local buff =  this.Class.ThisUnit:getTeamUnitCondition():findConditionWithID(-60);
                if not(buff == nil) then
                    local buff = this.Class.ThisUnit:getTeamUnitCondition():findConditionWithID(-60);
                    this.Class.ThisUnit:getTeamUnitCondition():removeCondition(buff);
                end
                ]]

                if intparam == 1003 then
                    --1003 特性バターブリオッシュ
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess1,this.Class.Buff_1003.ICONID,100,255,100,7);
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess2,this.Class.Buff_1003.ICONID,100,255,100,7);

                    this.Class.ThisUnit:getTeamUnitCondition():addCondition(this.Class.Buff_1003.ID,this.Class.Buff_1003.TYPE,this.Class.Buff_1003.VALUE,this.Class.Buff_1003.TIME,this.Class.Buff_1003.ICONID,this.Class.Buff_1003.EFFECTID);

                    this.Class.ThisUnit:takeAnimation(0,"cast",false);
                    this.Class.ThisUnit:addOrbitSystem("spawn_food_1003");

                elseif intparam == 1006 then
                    --1006 特性ドラゴンステーキ
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess3,this.Class.Buff_1006.ICONID,255,0,0,7);
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess4,this.Class.Buff_1006.ICONID,255,0,0,7);

                    this.Class.ThisUnit:getTeamUnitCondition():addCondition(this.Class.Buff_1006.ID,this.Class.Buff_1006.TYPE,this.Class.Buff_1006.VALUE,this.Class.Buff_1006.TIME,this.Class.Buff_1006.ICONID,this.Class.Buff_1006.EFFECTID);

                    this.Class.ThisUnit:takeAnimation(0,"cast",false);
                    this.Class.ThisUnit:addOrbitSystem("spawn_food_1006");

                elseif intparam == 1015 then
                    --1015 特性ホットドッグ
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess5,this.Class.Buff_1015.ICONID,220,220,0,7);
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess6,this.Class.Buff_1015.ICONID,220,220,0,7);

                    this.Class.ThisUnit:getTeamUnitCondition():addCondition(this.Class.Buff_1015.ID,this.Class.Buff_1015.TYPE,this.Class.Buff_1015.VALUE,this.Class.Buff_1015.TIME,this.Class.Buff_1015.ICONID,this.Class.Buff_1015.EFFECTID);

                    this.Class.ThisUnit:takeAnimation(0,"cast",false);
                    this.Class.ThisUnit:addOrbitSystem("spawn_food_1015");

                elseif intparam == 1019 then
                    --1019 特性スペシャルパエリア
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess7,this.Class.Buff_1019.ICONID,220,220,0,7);
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess8,this.Class.Buff_1019.ICONID,220,220,0,7);

                    this.Class.ThisUnit:getTeamUnitCondition():addCondition(this.Class.Buff_1019.ID,this.Class.Buff_1019.TYPE,this.Class.Buff_1019.VALUE,this.Class.Buff_1019.TIME,this.Class.Buff_1019.ICONID,this.Class.Buff_1019.EFFECTID);

                    this.Class.ThisUnit:takeAnimation(0,"cast",false);
                    this.Class.ThisUnit:addOrbitSystem("spawn_food_1019");
                end

                this.Class.ThisUnit:setUnitState(kUnitState_skill);

                return 1;
            end,

            receiveBranch_4 = function(this,intparam)
                this.Class.drawDebugLog(this,this.Class.ThisUnit,"DEBUGLOG--マルチの同期-特殊スキル-究極秘奥義の同期...",181,37,255,1);

                if intparam == 1000 then
                    this.Class.ThisUnit:setBurstPoint(0);
                    this.Class.ThisUnit:takeAnimation(0,"ultimate_ChargeSet",false);
                    this.Class.ThisUnit:takeAnimationEffect(0,"ultimate_ChargeSet",false);

                    this.Class.ThisUnit:setUnitState(kUnitState_attack);
                    BattleControl:get():pushEnemyInfomation(this.Class.messages.mess9,255,120,23,7);

                    this.Class.ultimateSkill_IsOverCharge = true;
                end

                return 1;
            end,

            receiveBranch_5 = function(this,intparam)
                this.Class.drawDebugLog(this,this.Class.ThisUnit,"DEBUGLOG--マルチの同期-特殊スキル-ADDSPの同期...",181,37,255,1);

                this.Class.ThisUnit:addSP(intparam);

                return 1;
            end,

            receiveBranch_6 = function(this,intparam)
                this.Class.drawDebugLog(this,this.Class.ThisUnit,"DEBUGLOG--マルチの同期-特殊スキル-TakeBackとAttackTimerの同期...",181,37,255,1);

                if intparam == 1000 then
                    this.takeBack();
                end
                
                if intparam == 2000 then
                    if this.Class.ThisUnit ~= nil then
                        this.Class.ThisUnit:setAttackTimer(0);
                    end
                end

                return 1;
            end,

            --attackDamageValue分岐用
            attackDamageValueBranch = function(this , unit , enemy , value)
                return value;
            end,

            --takeDamageValue分岐用
            takeDamageValueBranch = function(this , unit , enemy , value)
                return value;
            end,

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆

            --Functions
            addSP = function (this,unit)

                local isHost = megast.Battle:getInstance():isHost();
                if not isHost then
                    return 1;
                end
                
                if this.Class.ultimateSkill_SpClockUp == true then 
                    unit:addSP(20);
                    this.Class.RequestSendEventToLua_5(this,unit,20);
                else
                    unit:addSP(10);
                    this.Class.RequestSendEventToLua_5(this,unit,10);
                end



                return 1;
            end,

            --現在ターゲットにしているやつとの距離を返す、居ない場合は　１　がカエル
            getTargetDistance = function(this,unit)
                if unit ~= nil then

                    local targetUnit = unit:getTargetUnit();
                    if targetUnit == nil then
                        return 1;
                    end
    
                    local tUX = targetUnit:getAnimationPositionX();
                    local zUX = unit:getAnimationPositionX();

                    tUX = math.floor(tUX);
                    zUX = math.floor(zUX);

                    --print("敵X = ",tUX);
                    --print("自分 X = ",zUX);
    
                    local distance = math.abs(tUX - zUX);

                    distance = math.floor(distance);

                    --print("distance = ",distance);

                    return distance;
                end

                return 1;
            end,

            --アタックタイマーをリセットする
            resetAttackTime = function(this,unit)
                

                local isHost = megast.Battle:getInstance():isHost();
                if isHost then
                    if unit ~= nil then
                        unit:setAttackTimer(0);
                        this.Class.RequestSendEventToLua_6(this,unit,2000);
                    end
                end

                return 1;
            end,

            --料理バフを符呪するか否かを判定する
            addFoodBuff = function(this,unit)

                if this.Class.foodBuff_StageValue <= this.Class.foodBuff_CurStage then
                    this.Class.drawDebugLog(this,unit,"DEBUGLOG--これ以上料理バフはかかりません",255,127,32,1);
                    return 1;
                end

                local curHpParcent = unit:getHPPercent() * 100;

                if this.Class.foodBuff_IsUse[this.Class.foodBuff_CurStage] == false then

                    this.Class.drawDebugLog(this,unit,"DEBUGLOG--料理バフ付呪チェック中...",255,127,32,1);

                    if curHpParcent <= this.Class.foodBuff_UseHp[this.Class.foodBuff_CurStage] then
                        this.Class.createFoodBuff(this,unit);
                        this.Class.foodBuff_IsUse[this.Class.foodBuff_CurStage] = true;
                        this.Class.foodBuff_CurStage = this.Class.foodBuff_CurStage + 1;
                        return 0;
                    end
                end

                return 1;
            end,

            --実際に料理バフを付呪する(ここで分岐も行われる)
            createFoodBuff = function(this,unit)

                local localBuffAddValue = this.Class.foodBuff_AddBuffValue - 1;
                local random = math.random(0,localBuffAddValue);

                --[[
                local buff =  unit:getTeamUnitCondition():findConditionWithID(-60);
                if not(buff == nil) then
                    local buff = unit:getTeamUnitCondition():findConditionWithID(-60);
                    unit:getTeamUnitCondition():removeCondition(buff);
                end
                ]]
                
                if this.Class.foodBuff_AddBuffList[random] == 1003 then
                    --1003 特性バターブリオッシュ
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess1,this.Class.Buff_1003.ICONID,100,255,100,7);
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess2,this.Class.Buff_1003.ICONID,100,255,100,7);

                    unit:getTeamUnitCondition():addCondition(this.Class.Buff_1003.ID,this.Class.Buff_1003.TYPE,this.Class.Buff_1003.VALUE,this.Class.Buff_1003.TIME,this.Class.Buff_1003.ICONID,this.Class.Buff_1003.EFFECTID);

                    unit:takeAnimation(0,"cast",false);
                    unit:addOrbitSystem("spawn_food_1003");

                    unit:setUnitState(kUnitState_skill);
                    this.Class.RequestSendEventToLua_3(this,unit,this.Class.foodBuff_AddBuffList[random]);

                elseif this.Class.foodBuff_AddBuffList[random] == 1006 then
                    --1006 特性ドラゴンステーキ
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess3,this.Class.Buff_1006.ICONID,255,0,0,7);
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess4,this.Class.Buff_1006.ICONID,255,0,0,7);

                    unit:getTeamUnitCondition():addCondition(this.Class.Buff_1006.ID,this.Class.Buff_1006.TYPE,this.Class.Buff_1006.VALUE,this.Class.Buff_1006.TIME,this.Class.Buff_1006.ICONID,this.Class.Buff_1006.EFFECTID);

                    unit:takeAnimation(0,"cast",false);
                    unit:addOrbitSystem("spawn_food_1006");

                    unit:setUnitState(kUnitState_skill);
                    this.Class.RequestSendEventToLua_3(this,unit,this.Class.foodBuff_AddBuffList[random]);

                elseif this.Class.foodBuff_AddBuffList[random] == 1015 then
                    --1015 特性ホットドッグ
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess5,this.Class.Buff_1015.ICONID,220,220,0,7);
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess6,this.Class.Buff_1015.ICONID,220,220,0,7);

                    this.Class.ultimateSkill_SpClockUp = true;

                    unit:getTeamUnitCondition():addCondition(this.Class.Buff_1015.ID,this.Class.Buff_1015.TYPE,this.Class.Buff_1015.VALUE,this.Class.Buff_1015.TIME,this.Class.Buff_1015.ICONID,this.Class.Buff_1015.EFFECTID);

                    unit:takeAnimation(0,"cast",false);
                    unit:addOrbitSystem("spawn_food_1015");

                    unit:setUnitState(kUnitState_skill);
                    this.Class.RequestSendEventToLua_3(this,unit,this.Class.foodBuff_AddBuffList[random]);

                elseif this.Class.foodBuff_AddBuffList[random] == 1019 then
                    --1019 特性スペシャルパエリア
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess7,this.Class.Buff_1019.ICONID,220,220,0,7);
                    BattleControl:get():pushEnemyInfomationWithConditionIcon(this.Class.messages.mess8,this.Class.Buff_1019.ICONID,220,220,0,7);

                    unit:getTeamUnitCondition():addCondition(this.Class.Buff_1019.ID,this.Class.Buff_1019.TYPE,this.Class.Buff_1019.VALUE,this.Class.Buff_1019.TIME,this.Class.Buff_1019.ICONID,this.Class.Buff_1019.EFFECTID);

                    unit:takeAnimation(0,"cast",false);
                    unit:addOrbitSystem("spawn_food_1019");

                    unit:setUnitState(kUnitState_skill);
                    this.Class.RequestSendEventToLua_3(this,unit,this.Class.foodBuff_AddBuffList[random]);

                    --このバフだけ二度と発動しないようにする
                    this.Class.foodBuff_AddBuffList[random] = this.Class.foodBuff_AddBuffList[0];

                end

                return 1;
            end,

            --究極必殺技を出すか否かを判断する
            ultimateSkillReady = function(this,unit)

                if this.Class.ultimateSkill_StageValue <= this.Class.ultimateSkill_CurStage then
                    this.Class.drawDebugLog(this,unit,"DEBUGLOG--これ以上究極秘奥義は出ません",255,127,32,1);
                    return 1;
                end

                local curHpParcent = unit:getHPPercent() * 100;

                if this.Class.ultimateSkill_IsUse[this.Class.ultimateSkill_CurStage] == false then

                    this.Class.drawDebugLog(this,unit,"DEBUGLOG--究極秘奥義発動確認中...",255,127,32,1);

                    if curHpParcent <= this.Class.ultimateSkill_UseHp[this.Class.ultimateSkill_CurStage] then

                        this.Class.startUltimateSkill(this,unit);
                        this.Class.ultimateSkill_IsUse[this.Class.ultimateSkill_CurStage] = true;
                        this.Class.ultimateSkill_CurStage = this.Class.ultimateSkill_CurStage + 1;

                        return 0;
                    end
                end

                return 1;
            end,

            --究極必殺技を出すためのチャージを始める、
            startUltimateSkill = function(this,unit)

                local isHost = megast.Battle:getInstance():isHost();
                if not isHost then
                    return 1;
                end

                this.Class.ultimateSkill_IsOverCharge = true;

                unit:setBurstPoint(0);
                unit:takeAnimation(0,"ultimate_ChargeSet",false);
                unit:takeAnimationEffect(0,"ultimate_ChargeSet",false);

                unit:setUnitState(kUnitState_attack);
                BattleControl:get():pushEnemyInfomation(this.Class.messages.mess9,255,120,23,7);

                this.Class.RequestSendEventToLua_4(this,unit,1000);

                return 1;
            end,

            --ultimate_chargeSetが終わった後のrunscript,Chargeアニメーションを再生する。
            endSetUpCharge = function(this,unit)

                unit:takeAnimation(0,"ultimate_Charge",false);
                unit:takeAnimationEffect(0,"ultimate_Charge",false);
                unit:setUnitState(kUnitState_attack);

                return 1;
            end,

            --ultimate_Chargeのscript,SPがMAXになるまでひたすらこのアニメーションをRepeatする。
            repeatCharge = function(this,unit)

                this.Class.drawDebugLog(this,unit,"DEBUGLOG--究極秘奥義チャージ中...",255,127,32,1);

                if 100 <= unit:getBurstPoint() then
                    unit:resetPosition();
                    return 1;
                end

                unit:takeAnimation(0,"ultimate_Charge",false);
                unit:takeAnimationEffect(0,"ultimate_Charge",false);
                unit:setUnitState(kUnitState_attack);

                return 1;
            end,

            drawDebugLog = function(this,unit,text,color_r,color_g,color_b,time)

                --BattleControl:get():pushEnemyInfomationWithConditionIcon(text,7,color_r,color_g,color_b,time);

                return 1;
            end,

            --sendEventToLua
            RequestSendEventToLua_1 = function(this,unit,intparam)

                local isHost = megast.Battle:getInstance():isHost();
                if not isHost then
                    return 1;
                end

                megast.Battle:getInstance():sendEventToLua(this.Class.ThisUniqueId,1,intparam);

                return 1;
            end,
            RequestSendEventToLua_2 = function(this,unit,intparam)

                local isHost = megast.Battle:getInstance():isHost();
                if not isHost then
                    return 1;
                end
                
                megast.Battle:getInstance():sendEventToLua(this.Class.ThisUniqueId,2,intparam);

                return 1;
            end,
            RequestSendEventToLua_3 = function(this,unit,intparam)

                local isHost = megast.Battle:getInstance():isHost();
                if not isHost then
                    return 1;
                end
                
                megast.Battle:getInstance():sendEventToLua(this.Class.ThisUniqueId,3,intparam);

                return 1;
            end,
            RequestSendEventToLua_4 = function(this,unit,intparam)

                local isHost = megast.Battle:getInstance():isHost();
                if not isHost then
                    return 1;
                end
                
                megast.Battle:getInstance():sendEventToLua(this.Class.ThisUniqueId,4,intparam);

                return 1;
            end,
            RequestSendEventToLua_5 = function(this,unit,intparam)

                local isHost = megast.Battle:getInstance():isHost();
                if not isHost then
                    return 1;
                end
                
                megast.Battle:getInstance():sendEventToLua(this.Class.ThisUniqueId,5,intparam);

                return 1;
            end,
            RequestSendEventToLua_6 = function(this,unit,intparam)

                local isHost = megast.Battle:getInstance():isHost();
                if not isHost then
                    return 1;
                end
                
                megast.Battle:getInstance():sendEventToLua(this.Class.ThisUniqueId,6,intparam);

                return 1;
            end,

            --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        },




        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆
        --☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆



        --共通変数
        param = {
          version = 1.3
          ,isUpdate = true
        },

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            return this.Class.receiveBranch_1(this,intparam);
        end,
        receive2 = function (this , intparam)
            return this.Class.receiveBranch_2(this,intparam);
        end,
        receive3 = function (this , intparam)
            return this.Class.receiveBranch_3(this,intparam);
        end,
        receive4 = function (this , intparam)
            return this.Class.receiveBranch_4(this,intparam);
        end,
        receive5 = function (this , intparam)
            return this.Class.receiveBranch_5(this,intparam);
        end,
        receive6 = function (this , intparam)
            return this.Class.receiveBranch_6(this,intparam);
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            return this.Class.runScriptUpdate(this,unit,str);
        end,

        --version1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
            return value;
        end,

        takeBreake = function (this,unit)
            return this.Class.takeBreakeBranch(this,unit);
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            return this.Class.Update(this,unit,deltatime);
        end,

        attackDamageValue = function (this , unit , enemy , value)
            return this.Class.attackDamageValueBranch(this,unit,enemy,value);
        end,

        takeDamageValue = function (this , unit , enemy , value)
            return this.Class.takeDamageValueBranch(this,unit,enemy,value);
        end,

        --version1.0
        start = function (this , unit)
            return this.Class.Initialize(this,unit);
        end,

        excuteAction = function (this , unit)
            return this.Class.excuteActionBranch(this,unit);
        end,

        takeIdle = function (this , unit)
            return this.Class.takeIdleBranch(this,unit);

        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
         
            return 1;
        end,

        takeAttack = function (this , unit , index)
        
            local isHost = megast.Battle:getInstance():isHost();
            if isHost then

                if this.Class.isAttackChecker == false then
                    this.Class.isAttackChecker = true;
                    return this.Class.takeAttackBranch(this,unit,index);
                end
                this.Class.isAttackChecker = false;
            
            end
            if index == 1 then
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            elseif index == 3 then
                unit:setActiveSkill(3);
            elseif index == 4 then
                unit:setActiveSkill(4);                      
            end            
            return 1;

        end,

        takeSkill = function (this,unit,index)
            return this.Class.takeSkillBranch(this,unit,index);
        end,

        takeDamage = function (this , unit)
            return this.Class.takeDamageBranch(this,unit);
        end,

        dead = function (this , unit)
            return this.Class.takeDeadBranch(this,unit);
        end
    }
    register.regist(instance,id,instance.param.version);
    return 1;
end

