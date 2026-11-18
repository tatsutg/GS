function new(id)
    print("10000 new ");
    local instance = {
        --０：シールドモード　１：攻撃モード
        mode = 0,
        attackChecker = false,
        skillChecker = false,
        beforeTargetUnit = 0,
        myself = nil,
        target = nil,
        balls = {},
        missiles = {},
        funnels = {},
        angleCore = 0,
        isAttack5 = false,
        breakCounter = 0,
        breakState = 0,
        attackdelayOriginal = 0,
        thisid = id,
        subBar = nil,
        
        isInstantiateLaserHitFunnel = false,--レーザーヒットエフェクトを大量に出してしまわないようにフラグ管理


        damageCutNormal = 0.5,--バリアモードの減衰
        damageCutStrong = 0.2,--バリアモードの減衰（反属性）
        chagneTurns = 10,--変形までに必要なターン
        firstBreak = 1,--最初の破壊までに必要なブレイク倍率
        secondBreak = 2,--次の破壊までに必要なブレイク倍率
        border = 3000,
        epA4 = 400, --各攻撃で消費する属性エエルギー
        epA5 = 550,
        epA6 = 800,
        epS4 = 1000,
        epS5 = 3000,

        elements = {--炎水木光闇の順
            f = 0,
            i = 0,
            t = 0,
            h = 0,
            d = 0
        },
        modeElement = 0,
        beforeModeElement = 0,
        modeCangeCounter = 0,
        ballinfo = {
            new = function (_ball,_targetUnit,_uniqueID)
                return {
                    bullet = _ball,
                    targetUnit = _targetUnit,
                    uniqueID = _uniqueID,
                    frame = 0,
                    angle = 0,
                    posx = 0,
                    posy = 0,
                    speedkeisuu = 1,
                    isPlayer = false
                }
            end
        },

        missileinfo = {
            new = function (_bullet,_targetUnit,_uniqueID)
                return {
                    bullet = _bullet,
                    targetUnit = _targetUnit,
                    uniqueID = _uniqueID,
                    frame = 0,
                    angle = 0,
                    posx = 0,
                    posy = 0,
                    speedkeisuu = 1,
                    isPlayer = false
                }
            end
        },

        funnelInfo = {
            new = function (_bullet,_targetUnit,_otherparam)
                return {
                    bullet = _bullet,
                    targetUnit = _targetUnit,
                    otherParam = _otherparam,
                    otherParam2 = 0,
                    frame = 0,
                    angle = 0,
                    posx = 0,
                    posy = 0,
                    distance = 0,
                    speedkeisuu = 1,
                    state = 0,
                    parent = nil,
                    jyumyou = 10
                }
            end
        },

        funnel = function (this,unit)

            local ishost = megast.Battle:getInstance():isHost();
            

            
            local s = this.myself:addOrbitSystem("funnelIdle",2)
            s:setHitCountMax(999);
            s:setEndAnimationName("funnelDead")
            s:takeAnimation(0,"funnelIdle",true);

            local x = this.myself:getPositionX()
            local y = this.myself:getPositionY()
            s:setPosition(x - 80,y+400)

        
            local t = this.funnelInfo.new(s,this.beforeTargetUnit,10);
            t.angle = 0;
            t.parent = unit;
            table.insert(this.funnels,t)
            -- megast.Battle:getInstance():sendEventToLua(this.thisid,2,enemy:getIndex());
               

            return 1;
        end,

        funnelControll = function (this,bulletinstance,index)
            --ファンネルの状態　
            -- 0 = 初期状態
            -- 1 = 待機状態
            -- 2 = レーザー
            -- 3 = ビームサーベル
            -- 4 = 撤退
            if bulletinstance.state == 0 then
                funnelFirstAction(bulletinstance);
            elseif bulletinstance.state == 1 then
                funnelIdle(bulletinstance,index,table.maxn(this.funnels),this.angleCore);
            elseif bulletinstance.state == 2 then
                funnelLaser(bulletinstance,this.beforeTargetUnit);
            elseif bulletinstance.state == 3 then
                funnelBeam(bulletinstance,this.beforeTargetUnit);
            elseif bulletinstance.state == 4 then
                funnelAttack(bulletinstance);
            end 
            return 1;
        end,

        funnelStateEnd = function (this,unit)
            this.isInstantiateLaserHitFunnel = false;

             for i = 1,table.maxn(this.funnels) do
         
                if this.funnels[i].bullet == unit then
                    innerFunnelStateEnd(this.funnels[i]); 
                end

            end
            return 1;
        end,

        funnelAttack = function (this,unit)
            local  atari = 1
             for i = 1,table.maxn(this.funnels) do
                this.funnels[i].frame = 0;
                if this.mode == 0 then
                    this.funnels[i].state = 2;
                    this.funnels[i].bullet:takeAnimation(0,"funnelLaser",false);
                    unit:setActiveSkill(2);
                else
                    this.funnels[i].state = 3;
                    this.funnels[i].bullet:takeAnimation(0,"funnelAttack",false);
                    unit:setActiveSkill(7);
                end
            end
            return 1;
        end,

        ball = function(this,unit)
            local shot = unit:addOrbitSystem("ball",1)
            shot:setHitCountMax(1)
            shot:setEndAnimationName("ballExplosion")
            -- shot:EnabledFollow = true;
            local x = unit:getPositionX();
            local y = unit:getPositionY();
            local xb = unit:getSkeleton():getBoneWorldPositionX("L_barrier_hand_root");
            local yb = unit:getSkeleton():getBoneWorldPositionY("L_barrier_hand_root");
            shot:setPosition(x+xb -50,y+yb);
            shot:takeAnimation(0,"ball",true);
            local tama = this.ballinfo.new(shot,unit:getTargetUnit():getIndex(),0);
            tama.isPlayer = unit:getisPlayer();
            table.insert(this.balls,tama)
            return 1;
        end,

        missile = function(this,unit)
            local shot = unit:addOrbitSystem("missile",1)
            shot:setHitCountMax(1)
            shot:setEndAnimationName("missileExplosion")
            -- shot:EnabledFollow = true;
            local x = unit:getPositionX();
            local y = unit:getPositionY();
            local xb = unit:getSkeleton():getBoneWorldPositionX("C_weapon_maingun");
            local yb = unit:getSkeleton():getBoneWorldPositionY("C_weapon_maingun");
            shot:setPosition(x+xb,y+yb);
            shot:takeAnimation(0,"missile",true);
            shot:setAutoZOrder(true);
            shot:setZOderOffset(-5030);

            local tama = this.missileinfo.new(shot,unit:getTargetUnit():getIndex(),0);

            tama.isPlayer = unit:getisPlayer();
            table.insert(this.missiles,tama)
            return 1;
        end,

        onDestroyball = function (this,unit)
            local  atari = 0;
            for i = 1,table.maxn(this.balls) do
                print("Destroy")
                if this.balls[i].bullet == unit then
                    atari = i
                end

            end
            if atari ~= 0 then
                table.remove(this.balls,atari);
            end
            return 1;
        end,


        onDestroyfunnel = function (this,unit)
            local  atari = 0;
            for i = 1,table.maxn(this.funnels) do
                print("Destroy")
                if this.funnels[i].bullet == unit then
                    atari = i
                end

            end
            if atari ~= 0 then
                table.remove(this.funnels,atari);
            end
            return 1;
        end,

        onDestroyMissile = function (this,unit)
            local  atari = 0;
            for i = 1,table.maxn(this.missiles) do
                print("Destroy")
                if this.missiles[i].bullet == unit then
                    atari = i
                end

            end
            if atari ~= 0 then
                table.remove(this.missiles,atari);
            end
            return 1;
        end,

        laserHit = function(this,unit)
            for i = 1,table.maxn(this.funnels) do
                if this.funnels[i].bullet == unit then
                    
                    local bulletTarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(this.funnels[i].targetUnit);
                    print("index:"..this.funnels[i].targetUnit);
                    print(bulletTarget);
                    if bulletTarget ~= nil and not this.isInstantiateLaserHitFunnel then
                        this.isInstantiateLaserHitFunnel = true;
                        local hit = this.myself:addOrbitSystem("laserHit",0);
                        local x = bulletTarget:getPositionX();
                        local y = bulletTarget:getPositionY();
                        local xb = bulletTarget:getSkeleton():getBoneWorldPositionX("MAIN");
                        local yb = bulletTarget:getSkeleton():getBoneWorldPositionY("MAIN");
                        hit:setPosition(x + xb , y + yb);
                        hit:setDamageRateOffset(table.maxn(this.funnels));
                    end
                end
            end
            
            return 1;
        end,

        laserHit2 = function(this,unit)
            
            
            local bulletTarget = unit:getTargetUnit();

            if bulletTarget ~= nil then
                local hit = unit:addOrbitSystem("laserHit",0);
                local x = bulletTarget:getPositionX();
                local y = bulletTarget:getPositionY();
                local xb = bulletTarget:getSkeleton():getBoneWorldPositionX("MAIN");
                local yb = bulletTarget:getSkeleton():getBoneWorldPositionY("MAIN");
                hit:setPosition(x + xb , y + yb);
            end
     
            
            return 1;
        end,


        attack5ArmControll = function(this,unit)
            this.boneRotation(this,unit,"R_weapon_gunbarrel_upper",360);
            this.boneRotation(this,unit,"R_weapon_arm_gunbarre_center",360);
            this.boneRotation(this,unit,"R_weapon_gunbarrel_lower",360);
            this.boneRotation(this,unit,"L_weapon_gunbarrel_upper",360);
            this.boneRotation(this,unit,"L_weapon_gunbarrel_canter",360);
            this.boneRotation(this,unit,"L_weapon_gunbarrel_lower",360);
            return 1;
        end,

        boneRotation = function (this,unit,boneName,maxdeg)
            unit:getSkeleton():setBoneRotation(boneName,this.calcDeg(this,unit,boneName));
            return 1;
        end,

        calcDeg = function(this,unit,boneName)
            local target = unit:getTargetUnit();
            if target ~= nil then
                local x = unit:getPositionX();
                local y = unit:getPositionY();
                local xb = unit:getSkeleton():getBoneWorldPositionX(boneName);
                local yb = unit:getSkeleton():getBoneWorldPositionY(boneName);
                local tx = target:getPositionX();
                local ty = target:getPositionY();
                local txb = target:getSkeleton():getBoneWorldPositionX("MAIN");
                local tyb = target:getSkeleton():getBoneWorldPositionY("MAIN");
                return getDeg(x+xb,y+yb,tx+txb,ty+tyb);

            end
            return 0;
        end,

        elementModeChecker = function(this,unit)
            local ishost = megast.Battle:getInstance():isHost();
            if not ishost then
                return 0;
            end
            this.beforeModeElement = this.modeElement;
            this.modeElement = 0;
            if this.elements.f > this.border then
                this.modeElement = 1;
            end
            if this.elements.i > this.border and this.elements.i > this.elements.f then
                this.modeElement = 2;
            end
            if this.elements.t > this.border and this.elements.t > this.elements.i then
                this.modeElement = 3;
            end
            if this.elements.h > this.border and this.elements.h > this.elements.t then
                this.modeElement = 4;
            end
            if this.elements.d > this.border and this.elements.d > this.elements.h then
                this.modeElement = 5;
            end
            if this.modeElement ~= this.beforeModeElement then
                megast.Battle:getInstance():setBossCounterElement(this.modeElement);--ボス奥義カウンターの色替え
                megast.Battle:getInstance():sendEventToLua(this.thisid,1,this.modeElement);
            end
            return 0;
        end,

        askElementString = function (this,unit)
            local str = none;
            if this.modeElement == 0 then
                return "none";
            elseif this.modeElement == 1 then
                return "red";
            elseif this.modeElement == 2 then
                return "blue";
            elseif this.modeElement == 3 then
                return "green";
            elseif this.modeElement == 4 then
                return "light";
            elseif this.modeElement == 5 then
                return "dark";
            end
            return 0;
        end,

        skillElementSetter = function(this,unit,skillindex)
            local str = none;
            if this.modeElement == 0 then

            elseif this.modeElement == 1 then
                if skillindex == 4 then
                    unit:setActiveSkill(10)
                elseif skillindex == 5 then
                    unit:setActiveSkill(15);
                end
            elseif this.modeElement == 2 then
                if skillindex == 4 then
                    unit:setActiveSkill(11)
                elseif skillindex == 5 then
                    unit:setActiveSkill(16);
                end
            elseif this.modeElement == 3 then
                if skillindex == 4 then
                    unit:setActiveSkill(12)
                elseif skillindex == 5 then
                    unit:setActiveSkill(17);
                end
            elseif this.modeElement == 4 then
                if skillindex == 4 then
                    unit:setActiveSkill(13)
                elseif skillindex == 5 then
                    unit:setActiveSkill(18);
                end
            elseif this.modeElement == 5 then
                if skillindex == 4 then
                    unit:setActiveSkill(14)
                elseif skillindex == 5 then
                    unit:setActiveSkill(19);
                end
            end
            return 0;
        end,

        decrimentElement = function (this,unit,int)
            if this.modeElement == 1 then
                this.elements.f = this.elements.f - int;
                return this.elements.f;
            elseif this.modeElement == 2 then
                this.elements.i = this.elements.i - int;
                return this.elements.i;
            elseif this.modeElement == 3 then
                this.elements.t = this.elements.t - int;
                return this.elements.t;
            elseif this.modeElement == 4 then
                this.elements.h = this.elements.h - int;
                return this.elements.h;
            elseif this.modeElement == 5 then
                this.elements.d = this.elements.d - int;
                return this.elements.d;
            end
            return 0;
        end,



        addSP = function (this,unit)
            unit:addSP(20);
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
        receive1 = function (this , intparam)
            this.modeElement = intparam;
            megast.Battle:getInstance():setBossCounterElement(this.modeElement);--ボス奥義カウンターの色替え
            return 1;
        end,

        receive2 = function (this , intparam)
            if this.mode == 0 and this.breakState == 1 then
                this.myself:takeAnimation(0,"break",false);
                this.myself:takeAnimationEffect(0,"break",false);
                this.breakState = 2;
                this.myself:setSetupAnimationNameEffect("");
            end
            if this.mode == 0 and this.breakState == 0 then
                this.myself:setSkin("Break_small");
                this.breakState = 1;
            end
            return 1;
        end,

        receive3 = function (this , intparam)
            if intparam == 0 then
                this.myself:showPopText(summoner.Text:fetchByUnitID(500161013).text2);
                this.modeCangeCounter = 0;
                this.mode = 0;
                this.myself:takeAnimation(0,"zclone"..this.askElementString(this,this.myself).."barrier_in",false);
                this.myself:setAttackDelay(this.attackdelayOriginal);
                if this.breakState ~= 2 then
                    this.myself:takeAnimationEffect(0,"zclone"..this.askElementString(this,this.myself).."barrier_in",false);
                end
                this.myself:setSetupAnimationNameEffect("setUpBarrier");
                this.myself:setSetupAnimationName("setUp1");
            else
                this.myself:showPopText(summoner.Text:fetchByUnitID(500161013).text1);
                this.modeCangeCounter = 0;
                this.mode = 1;
                this.myself:setSetupAnimationNameEffect("");
                this.myself:takeAnimation(0,"zclone"..this.askElementString(this,this.myself).."barrier_off",false);
                if this.breakState ~= 2 then
                    this.myself:takeAnimationEffect(0,"zclone"..this.askElementString(this,this.myself).."barrier_off",false);
                end
            end
            return 1;
        end,

        receive4 = function (this , intparam)
            if intparam == 0 then
                this.funnel(this,this.myself);
            else
                this.funnelAttack(this,this.myself);
            end
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "ball" then return this.ball(this,unit) end
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "onDestroyball" then return this.onDestroyball(this,unit) end
            if str == "funnel" then return this.funnel(this,unit) end
            if str == "funnelAttack" then return this.funnelAttack(this,unit) end
            if str == "funnelStateEnd" then return this.funnelStateEnd(this,unit) end
            if str == "onDestroyfunnel" then return this.onDestroyfunnel(this,unit) end
            if str == "missile" then return this.missile(this,unit) end
            if str == "onDestroyMissile" then return this.onDestroyMissile(this,unit) end
            if str == "laserHit" then return this.laserHit(this,unit) end
            if str == "laserHit2" then return this.laserHit2(this,unit) end
            return 1;
        end,

        --version 1.3
        takeBreakeDamageValue = function (this,unit,enemy,value)
            
            local ishost = megast.Battle:getInstance():isHost();
            if not ishost or this.mode == 1 then
                return value;
            end

            local active = enemy:getActiveBattleSkill();
            if active ~= nil then
                local el = active:getElementType();
                if el == kElementType_Fire then
                    if this.modeElement == 2 then
                        if this.breakState ~= 2 then
                            value = value * this.damageCutStrong;
                        end
                    elseif this.modeElement ~= 3 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.f = this.elements.f + value;
                   
                elseif el == kElementType_Aqua then
                    if this.modeElement == 3 then
                        if this.breakState ~= 2 then
                            value = value * this.damageCutStrong;
                        end
                    elseif this.modeElement ~= 1 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.i = this.elements.i + value;
                   
                elseif el == kElementType_Earth then
                    if this.modeElement == 1 then
                        if this.breakState ~= 2 then
                            value = value * this.damageCutStrong;
                        end
                    elseif this.modeElement ~= 2 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.t = this.elements.t + value;
                elseif el == kElementType_Light then
                    if this.modeElement ~= 5 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.h = this.elements.h + value;
                elseif el == kElementType_Dark then
                    if this.modeElement ~= 4 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.d = this.elements.d + value;
                end
            else
                local el = enemy:getElementType();
                if el == kElementType_Fire then
                    if this.modeElement == 2 then
                        if this.breakState ~= 2 then
                            value = value * this.damageCutStrong;
                        end
                    elseif this.modeElement ~= 3 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.f = this.elements.f + value;
                   
                elseif el == kElementType_Aqua then
                    if this.modeElement == 3 then
                        if this.breakState ~= 2 then
                            value = value * this.damageCutStrong;
                        end
                    elseif this.modeElement ~= 1 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.i = this.elements.i + value;
                   
                elseif el == kElementType_Earth then
                    if this.modeElement == 1 then
                        if this.breakState ~= 2 then
                            value = value * this.damageCutStrong;
                        end
                    elseif this.modeElement ~= 2 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.t = this.elements.t + value;
                elseif el == kElementType_Light then
                    if this.modeElement ~= 5 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.h = this.elements.h + value;
                elseif el == kElementType_Dark then
                    if this.modeElement ~= 4 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.d = this.elements.d + value;
                end
            end
            this.breakCounter = this.breakCounter + value;
            if this.breakCounter > unit:getBaseBreakCapacity()*this.firstBreak then
                if this.mode == 0 and this.breakState == 0 then
                    unit:setSkin("Break_small");
                    this.breakState = 1;
                    megast.Battle:getInstance():sendEventToLua(this.thisid,2,1);
                end
            end
            if this.breakCounter > unit:getBaseBreakCapacity()*this.secondBreak then
                if this.mode == 0 and this.breakState == 1 then
                    unit:takeAnimation(0,"break",false);
                    unit:takeAnimationEffect(0,"break",false);
                    this.breakState = 2;
                    this.myself:setSetupAnimationNameEffect("");
                    megast.Battle:getInstance():sendEventToLua(this.thisid,2,2);

                end
            end
            return value;
        end,

        takeBreake = function (this,unit)
            return 1;
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            for i = 1,table.maxn(this.balls) do
                this.balls[i].ball:takeAnimation(0,"hit",false); 
            end
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            this.myself:setSetupAnimationNameEffect("setUpBarrier");
            this.subBar =  BattleControl:get():createSubBar();
            this.subBar:setWidth(200); --バーの全体の長さを指定
            this.subBar:setHeight(13);
            this.subBar:setPercent(0); --バーの残量を50%に指定
            this.subBar:setVisible(false);
            this.subBar:setPositionX(-100);
            this.subBar:setPositionY(150);
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
            
            if this.mode == 0 and this.breakState ~= 2 and this.subBar ~= nil then
                this.elementModeChecker(this,unit);
                this.subBar:setVisible(true);
                local breakFull = unit:getBaseBreakCapacity()*this.secondBreak;
                local bonex = unit:getSkeleton():getBoneWorldPositionX("R_barrier_hand_root") - 205;
                local boney = unit:getPositionY() + 100;
                this.subBar:setPositionX(bonex);
                this.subBar:setPositionY(boney);
                this.subBar:setPercent(100 * (breakFull - this.breakCounter)/breakFull);
            elseif this.subBar ~= nil then
                this.subBar:setVisible(false);
            end
            
            this.angleCore = this.angleCore + 1.5 * unitManagerDeltaTime/0.016666667;
            if this.angleCore > 360 then
                this.angleCore = this.angleCore % 360;
            end
            if this.isAttack5 then
                this.attack5ArmControll(this,unit);
            end
            if table.maxn(this.balls) > 0 then
                for i = 1,table.maxn(this.balls) do
                    ballControll500161013(this.balls[i]);
                end
            end
            if table.maxn(this.missiles) > 0 then
                for i = 1,table.maxn(this.missiles) do
                    missileControll500161013(this.missiles[i]);
                end
            end
            if table.maxn(this.funnels) > 0 then
                for i = 1,table.maxn(this.funnels) do
                    this.funnelControll(this,this.funnels[i],i);
                end
            end
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            if this.mode == 1 then
                return value;
            end
            
            local active = enemy:getActiveBattleSkill();
            if active ~= nil then
                local el = active:getElementType();
                if el == kElementType_Fire then
                    if this.modeElement == 2 then
                        if this.breakState ~= 2 then
                            value = value * this.damageCutStrong;
                        end
                    elseif this.modeElement ~= 3 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.f = this.elements.f + value;
                   
                elseif el == kElementType_Aqua then
                    if this.modeElement == 3 then
                        if this.breakState ~= 2 then
                            value = value * this.damageCutStrong;
                        end
                    elseif this.modeElement ~= 1 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.i = this.elements.i + value;
                   
                elseif el == kElementType_Earth then
                    if this.modeElement == 1 then
                        if this.breakState ~= 2 then
                            value = value * this.damageCutStrong;
                        end
                    elseif this.modeElement ~= 2 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.t = this.elements.t + value;
                elseif el == kElementType_Light then
                    if this.modeElement ~= 5 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.h = this.elements.h + value;
                elseif el == kElementType_Dark then
                    if this.modeElement ~= 4 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.d = this.elements.d + value;
                end
            else
                local el = enemy:getElementType();
                if el == kElementType_Fire then
                    if this.modeElement == 2 then
                        if this.breakState ~= 2 then
                            value = value * this.damageCutStrong;
                        end
                    elseif this.modeElement ~= 3 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.f = this.elements.f + value;
                   
                elseif el == kElementType_Aqua then
                    if this.modeElement == 3 then
                        if this.breakState ~= 2 then
                            value = value * this.damageCutStrong;
                        end
                    elseif this.modeElement ~= 1 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.i = this.elements.i + value;
                   
                elseif el == kElementType_Earth then
                    if this.modeElement == 1 then
                        if this.breakState ~= 2 then
                            value = value * this.damageCutStrong;
                        end
                    elseif this.modeElement ~= 2 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.t = this.elements.t + value;
                elseif el == kElementType_Light then
                    if this.modeElement ~= 5 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.h = this.elements.h + value;
                elseif el == kElementType_Dark then
                    if this.modeElement ~= 4 then
                        if this.breakState ~= 2 then
                            value = value * 0.5;
                        end
                    end
                    this.elements.d = this.elements.d + value;
                end
            end
            return value;
        end,

        --version1.0
        start = function (this , unit)
            unit:setSkin("Nomal");
            math.randomseed(os.time());
            this.attackdelayOriginal = unit:getAttackDelay();
            print(this.attackdelayOriginal);
            this.myself = unit;
            this.mode = 0;
            this.modeElement = 0;
            
            return 1;
        end,

        excuteAction = function (this , unit)
            if this.breakState == 2 then
                unit:setSkin("Break_large");
            end
            this.isAttack5 = false;
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                unit:setAttackDelay(this.attackdelayOriginal);
                local rand = math.random(100);
                if rand < 50 and megast.Battle:getInstance():getBattleState() == kBattleState_active then
                    if this.mode == 0 then
                        this.funnel(this,unit);
                        megast.Battle:getInstance():sendEventToLua(this.thisid,4,0);
                    end
                else
                    this.funnelAttack(this,unit);
                    megast.Battle:getInstance():sendEventToLua(this.thisid,4,1);
                end
            end
            
            if this.mode == 0 then
                unit:setSetupAnimationName("setUp1");
                this.modeCangeCounter = this.modeCangeCounter + 1;
                if this.modeCangeCounter > this.chagneTurns and ishost and this.modeElement ~= 0 then
                    this.modeCangeCounter = 0;
                    this.mode = 1;
                    megast.Battle:getInstance():sendEventToLua(this.thisid,3,1);
                    unit:takeAnimation(0,"zclone"..this.askElementString(this,unit).."barrier_off",false);
                    this.myself:setSetupAnimationNameEffect("");
                    unit:showPopText(summoner.Text:fetchByUnitID(500161013).text1);
                    if this.breakState ~= 2 then
                        unit:takeAnimationEffect(0,"zclone"..this.askElementString(this,unit).."barrier_off",false);
                    end
                    return 0;
                end
            else
                unit:setAttackDelay(0);
                if this.decrimentElement(this,unit,0) <= 0 and ishost then
                    this.modeCangeCounter = 0;
                    this.mode = 0;
                    megast.Battle:getInstance():sendEventToLua(this.thisid,3,0);
                    unit:takeAnimation(0,"barrier_in",false);
                    unit:showPopText(summoner.Text:fetchByUnitID(500161013).text2);
                    unit:setAttackDelay(this.attackdelayOriginal);
                    if this.breakState ~= 2 then
                        unit:takeAnimationEffect(0,"zclone"..this.askElementString(this,unit).."barrier_in",false);
                        this.myself:setSetupAnimationNameEffect("setUpBarrier");
                    end
                    unit:setSetupAnimationName("setUp1");
                    return 0;
                end
                unit:setSetupAnimationName("setUp2");
            end
            return 1;
        end,

        takeIdle = function (this , unit)
            if this.mode == 0 then
                if this.breakState ~= 2 then
                    unit:takeAnimationEffect(0,"idle1",true);
                end
                
                if this.modeElement ~= 0 then
                    unit:takeAnimation(0,"zclone"..this.askElementString(this,unit).."idle",true);
                    if this.breakState ~= 2 then
                        unit:takeAnimationEffect(0,"zclone"..this.askElementString(this,unit).."idle1",true);
                    end
                    return 0;
                end
            else
                unit:takeAnimation(0,"idle2",true);
                if this.modeElement ~= 0 then
                    unit:takeAnimation(0,"zclone"..this.askElementString(this,unit).."idle2",true);
                    return 0;
                end
                return 0;
            end
            return 1;
        end,

        takeFront = function (this , unit)
            return 1;
        end,

        takeBack = function (this , unit)
            if this.mode == 0 then
                if this.modeElement ~= 0 then
                    unit:setEndAnimationName("zclone"..this.askElementString(this,this.myself).."back1");
                else
                    unit:setNextAnimationName("back1");
                end
            else
                if this.modeElement ~= 0 then
                    unit:setEndAnimationName("zclone"..this.askElementString(this,this.myself).."back2");
                else
                    unit:setNextAnimationName("back2");
                end
            end
            return 1;
        end,

        takeAttack = function (this , unit , index)
            this.beforeTargetUnit = unit:getTargetUnit():getIndex();
            local ishost = megast.Battle:getInstance():isHost();
            
            
            if ishost then
                if not this.attackChecker then
                    if this.mode == 0 then
                        this.attackChecker = true;
                        local rand = math.random(100);
                        this.attackChecker = true;
                        if rand < 50 then
                            unit:takeAttack(1);
                        else
                            unit:takeAttack(3);
                        end
                        return 0;
                    else
                        local rand = math.random(100);
                        this.attackChecker = true;
                        if rand < 30 then
                            unit:takeAttack(4);
                            this.decrimentElement(this,unit,this.epA4);
                        elseif rand < 60 then
                            unit:takeAttack(5);
                            this.decrimentElement(this,unit,this.epA5);
                        else
                            if this.breakState ~= 2 then
                                unit:takeAttack(6);
                                this.decrimentElement(this,unit,this.epA6);
                            else
                                unit:takeAttack(5);
                                this.isAttack5 = true;
                                this.decrimentElement(this,unit,this.epA6);
                            end
                        end
                        return 0;
                    end
                end
                this.attackChecker = false;
            end
            if index == 1  then
                unit:setActiveSkill(1);
                if this.modeElement ~= 0 then
                    unit:setNextAnimationName("zclone"..this.askElementString(this,unit).."attack1");
                    if this.breakState ~= 2 then
                        unit:setNextAnimationEffectName("zclone"..this.askElementString(this,unit).."1-attack1");
                    else
                        unit:setNextAnimationEffectName("Empty");
                    end
                elseif this.breakState == 2 then
                    unit:setNextAnimationEffectName("Empty"); 
                end 
            elseif  index == 3 then
                unit:setActiveSkill(3);
                if this.modeElement ~= 0 then
                    
                    if this.breakState ~= 2 then
                        unit:setNextAnimationName("zclone"..this.askElementString(this,unit).."attack3");
                        unit:setNextAnimationEffectName("zclone"..this.askElementString(this,unit).."1-attack3");
                    else
                        unit:setNextAnimationName("zclone"..this.askElementString(this,unit).."attack3break");
                        unit:setNextAnimationEffectName("Empty");
                    end               
               
                elseif this.breakState == 2 then
                        unit:setNextAnimationEffectName("Empty"); 
                end
            elseif index == 4 then
                unit:setNextAnimationName("zclone"..this.askElementString(this,unit).."attack4");
                unit:setActiveSkill(4);
            elseif index == 5 then
                unit:setNextAnimationName("zclone"..this.askElementString(this,unit).."attack5");
                this.isAttack5 = true;
                unit:setActiveSkill(5);
            elseif index == 6 then
                unit:setNextAnimationName("zclone"..this.askElementString(this,unit).."attack6");
                unit:setActiveSkill(6);
            end
            return 1;
        end,

        takeSkill = function (this,unit,index)
            this.beforeTargetUnit = unit:getTargetUnit():getIndex();
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                if not this.skillChecker then
                    if this.mode == 0 then
                        local rand = math.random(100);
                        this.skillChecker = true;
                        if rand < 50 then
                            if this.breakState == 2 then
                                unit:takeSkill(3);
                            else
                                unit:takeSkill(2);
                            end
                        else
                            unit:takeSkill(3);
                        end
                        return 0;
                    else
                        local rand = math.random(100);
                        this.skillChecker = true;
                        if rand < 50 then
                            unit:takeSkill(4);
                            this.decrimentElement(this,unit,this.epS4);
                        else
                            unit:takeSkill(5);
                            this.decrimentElement(this,unit,this.epS5);
                        end
                        return 0;
                    end
                end
            end
            this.skillChecker = false;
            if index == 1  then
                if this.modeElement ~= 0 then
                    unit:setNextAnimationName("zclone"..this.askElementString(this,unit).."skill1");
                    if this.breakState ~= 2 then
                        unit:setNextAnimationEffectName("zclone"..this.askElementString(this,unit).."1-skill1");
                    else
                        unit:setNextAnimationEffectName("Empty");
                    end
                elseif this.breakState == 2 then
                    unit:setNextAnimationEffectName("Empty"); 
                end
            elseif  index == 2 then
                unit:setActiveSkill(8);
                if this.modeElement ~= 0 then                
                    unit:setNextAnimationName("zclone"..this.askElementString(this,unit).."skill2");
                    unit:setNextAnimationEffectName("zclone"..this.askElementString(this,unit).."1-skill2");
                end
            elseif  index == 3 then
                unit:setActiveSkill(9);
                if this.breakState == 2 then
                    unit:setNextAnimationEffectName("1-skill3break");
                end
            elseif  index == 4 then
                this.skillElementSetter(this,unit,4);
                if this.modeElement ~= 0 then
                    unit:setNextAnimationName("zclone"..this.askElementString(this,unit).."skill4");
                    unit:setNextAnimationEffectName("zclone"..this.askElementString(this,unit).."1-skill4");
                end
            elseif  index == 5 then
                this.skillElementSetter(this,unit,5);
                if this.modeElement ~= 0 then
                    if this.breakState ~= 2 then
                        unit:setNextAnimationName("zclone"..this.askElementString(this,unit).."skill5");
                        unit:setNextAnimationEffectName("zclone"..this.askElementString(this,unit).."1-skill5");
                    else
                        unit:setNextAnimationName("zclone"..this.askElementString(this,unit).."skill5");
                        unit:setNextAnimationEffectName("zclone"..this.askElementString(this,unit).."1-skill6");
                    end
                    
                end
            end
            return 1;
        end,

        takeDamage = function (this , unit)
            if this.mode == 0 then
                if this.modeElement ~= 0 then
                    unit:setNextAnimationName("zclone"..this.askElementString(this,unit).."damage_B");
                else
                    unit:setNextAnimationName("damage_B");
                end
            else
                if this.modeElement ~= 0 then
                    unit:setNextAnimationName("zclone"..this.askElementString(this,unit).."damage_S");
                else
                    unit:setNextAnimationName("damage_S");
                end
            end
            return 1;
        end,

        dead = function (this , unit)
            unit:addOrbitSystem("out",1);
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return 1;
end

function innerFunnelStateEnd(bulletinstance)
    local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);
    bulletinstance.frame = 0;
    print("finnnel state end");
    bulletinstance.jyumyou = bulletinstance.jyumyou -1;
    if bulletinstance.jyumyou <= 0 then
        bulletinstance.bullet:takeAnimation(0,"funnelDead",false);
        return 0;
    end
    if bulletinstance.state == 0 then
        bulletinstance.state = 1;
        bulletinstance.bullet:takeAnimation(0,"funnelIdle",true);
    else
        bulletinstance.state = 1;
        bulletinstance.bullet:takeAnimation(0,"funnelIdle",true);
    end
    
    return 1;
end

function funnelFirstAction(bulletinstance)
    local framecnt = bulletinstance.frame;
    if framecnt == 0 then
        bulletinstance.posx = bulletinstance.bullet:getPositionX();
        bulletinstance.posy = bulletinstance.bullet:getPositionY();
    end
    bulletinstance.frame = bulletinstance.frame + 1 * unitManagerDeltaTime/0.016666667;
    
    local currentbullet = bulletinstance.bullet;
    local sp = 1;
    local speedOrigin = 1;
    local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);
    bulletinstance.state = 0;



    if framecnt < 46 then
        sp = 1 + math.abs(46 - framecnt)/46 * speedOrigin * 10;
    elseif framecnt >= 46 then
        innerFunnelStateEnd(bulletinstance);

    end
    
   
    moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp* unitManagerDeltaTime/0.016666667),calcYDir(degToRad(bulletinstance.angle),sp* unitManagerDeltaTime/0.016666667));  
    
    return 1;
end


function funnelIdle(bulletinstance,index,length,angleCore)
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local sp = 1;
    local speedOrigin = 1;
    local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);
    local bulletx = bulletinstance.bullet:getPositionX();
    local bullety = bulletinstance.bullet:getPositionY();
    local parentx = bulletinstance.parent:getPositionX();
    local parenty = bulletinstance.parent:getPositionY() + 300;
    -- print("PX:"..parentx);
    -- print("PY:"..parenty);

    if framecnt == 0 then
        
        local distance = math.sqrt((bulletx - parentx)*(bulletx - parentx) + (bullety - parenty)*(bullety - parenty));

        local deg = getDeg(parentx,parenty,bulletx,bullety);
        bulletinstance.angle = deg;
        bulletinstance.distance = distance;
    end
    if bulletinstance.distance > 200 then
        bulletinstance.distance = bulletinstance.distance -3 * unitManagerDeltaTime/0.016666667;
    end
    bulletinstance.frame = bulletinstance.frame + 1;
    


    local fixedAngle = (index - 1) * 360/length + angleCore;

    if bulletinstance.angle > 360 then
        bulletinstance.angle = bulletinstance.angle % 360;
    end

    if bulletinstance.angle < 0 then
        bulletinstance.angle = bulletinstance.angle + 360;
    end

    local dir = fixedAngle - bulletinstance.angle;

    if dir > 180 then
        dir = -(360 - dir);
    end

    if dir < -180 then
        dir = (360 - dir);
    end

    if dir ~= 0 then
        local maxdir = 4 * unitManagerDeltaTime/0.016666667;
        if dir > maxdir then
            dir = maxdir;
        elseif dir < -maxdir then
            dir = -maxdir;
        end
        bulletinstance.angle = bulletinstance.angle + dir;
    end
    

    bulletinstance.bullet:setPosition(parentx + math.cos(degToRad(bulletinstance.angle))*bulletinstance.distance,parenty + math.sin(degToRad(bulletinstance.angle))*bulletinstance.distance);


    
    return 1;
end

function funnelLaser(bulletinstance,targetIndex)
    local framecnt = bulletinstance.frame;
    local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(targetIndex);
    if framecnt == 0 then
        bulletinstance.posx = bulletinstance.bullet:getPositionX();
        bulletinstance.posy = bulletinstance.bullet:getPositionY();
        bulletinstance.targetUnit = targetIndex;
    end
    bulletinstance.frame = bulletinstance.frame + 1;
    
    local currentbullet = bulletinstance.bullet;
    local sp = 1;
    local speedOrigin = 1;

    if bullettarget ~= nil then
        local x = bullettarget:getPositionX();
        local y = bullettarget:getPositionY();
        local xb = bullettarget:getSkeleton():getBoneWorldPositionX("MAIN");
        local yb = bullettarget:getSkeleton():getBoneWorldPositionY("MAIN");
        local targetangle = getDeg(currentbullet:getPositionX(),currentbullet:getPositionY(),x+xb,y+yb);
        bulletinstance.angle = targetangle;
        bulletinstance.bullet:setRotation(360 - bulletinstance.angle);
    end
   
    --moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp*bulletinstance.speedkeisuu),calcYDir(degToRad(bulletinstance.angle),sp*bulletinstance.speedkeisuu));  
    
    return 1;
end


function funnelBeam(bulletinstance,targetIndex)
    local framecnt = bulletinstance.frame;
    local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(targetIndex);
    if framecnt == 0 then
        bulletinstance.posx = bulletinstance.bullet:getPositionX();
        bulletinstance.posy = bulletinstance.bullet:getPositionY();
        bulletinstance.targetUnit = targetIndex;
        bulletinstance.otherParam = math.random(400) - 200;
        bulletinstance.otherParam2 = math.random(400) - 200;
    end
    bulletinstance.frame = bulletinstance.frame + 1;
    
    local currentbullet = bulletinstance.bullet;
    local sp = 10;
    local speedOrigin = 1;

    if bullettarget ~= nil then
        local targetangle = getDeg(currentbullet:getPositionX(),currentbullet:getPositionY(),bullettarget:getPositionX()+bulletinstance.otherParam,bullettarget:getPositionY()+bulletinstance.otherParam2);
        bulletinstance.angle = targetangle;
        bulletinstance.bullet:setRotation(360 - bulletinstance.angle);
    end
   
    moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp* unitManagerDeltaTime/0.016666667),calcYDir(degToRad(bulletinstance.angle),sp* unitManagerDeltaTime/0.016666667));  
    
    return 1;
end

function getDeg(startx,starty,targetx,targety)
    return radToDeg(getRad(startx,starty,targetx,targety))

end

function getRad(startx,starty,targetx,targety)
    return math.atan2(targety-starty,targetx-startx)
end

function degToRad(deg)
    return deg * 3.14/180;
end

function radToDeg(rad)
    return rad * 180/3.14;
end

function ballControll500161013(ballinstance)
    local framecnt = ballinstance.frame;
    local currentball = ballinstance.bullet;
    local sp = 1;
    local speedOrigin = 1;

    if framecnt == 0 then
       
        local rand = math.random(360);
        ballinstance.angle = rand;
        ballinstance.speedkeisuu = math.random(100,130)/100;
        sp = speedOrigin;
        ballinstance.posx = ballinstance.bullet:getPositionX();
        ballinstance.posy = ballinstance.bullet:getPositionY();
    end
    
    ballinstance.frame = ballinstance.frame + 1 * unitManagerDeltaTime/0.016666667;

    if framecnt <= 1 then
        

    elseif framecnt < 30 then
        sp = 1 + math.abs(30 - framecnt)/30 * speedOrigin*3;
    end
    if framecnt < 600 then
        sp = 2;
      
        local balltarget = megast.Battle:getInstance():getTeam(not ballinstance.isPlayer):getTeamUnit(ballinstance.targetUnit);
        if balltarget ~= nil then
            local targetangle = getDeg(currentball:getPositionX(),currentball:getPositionY(),balltarget:getPositionX(),balltarget:getPositionY());
            if targetangle < 0 then
                targetangle = 360 + targetangle;
            end

            local dir = targetangle - ballinstance.angle;

            if dir > 180 then
                dir = -(360 - dir);
            end

            if dir < -180 then
                dir = (360 - dir);
            end

            if dir ~= 0 then
                local maxdir = 1 * unitManagerDeltaTime/0.016666667;
                if dir > maxdir then
                    dir = maxdir;
                elseif dir < -maxdir then
                    dir = -maxdir;
                end
                ballinstance.angle = ballinstance.angle + dir;
            end

        end
    else
       ballinstance.bullet:takeAnimation(0,"ballExplosion",false);  
    end
    
    moveByFloat(ballinstance,calcXDir(degToRad(ballinstance.angle),sp * unitManagerDeltaTime/0.016666667),calcYDir(degToRad(ballinstance.angle),sp * unitManagerDeltaTime/0.016666667));   
end


function missileControll500161013(missileinstance)
    local framecnt = missileinstance.frame;
    local currentmissile = missileinstance.bullet;
    local sp = 1;
    local speedOrigin = 1;

    if framecnt == 0 then
       
        
        missileinstance.angle = 0;
        missileinstance.speedkeisuu = math.random(100,130)/100;
        sp = speedOrigin;
        missileinstance.posx = missileinstance.bullet:getPositionX();
        missileinstance.posy = missileinstance.bullet:getPositionY();
    end
    
    missileinstance.frame = missileinstance.frame + 1 * unitManagerDeltaTime/0.016666667;

    if framecnt <= 1 then
        

    elseif framecnt < 30 then
        sp = 1 + math.abs(30 - framecnt)/30 * speedOrigin*12;
        missileinstance.angle = 45;
    elseif framecnt < 120 then
        sp = 1 + math.abs(framecnt - 30)/30 * speedOrigin*12;
    elseif framecnt >= 120 and framecnt <= 125 then
        local missiletarget = megast.Battle:getInstance():getTeam(not missileinstance.isPlayer):getTeamUnit(missileinstance.targetUnit);
        if missiletarget ~= nil then
            sp = 0;
            missileinstance.bullet:setPositionX(missiletarget:getPositionX());
            missileinstance.posx = missiletarget:getPositionX();
           missileinstance.angle = -90;
        end
    elseif framecnt < 600 then

        sp = speedOrigin*40;
       
        local missiletarget = megast.Battle:getInstance():getTeam(not missileinstance.isPlayer):getTeamUnit(missileinstance.targetUnit);
        if missiletarget ~= nil then
            local targetangle = getDeg(currentmissile:getPositionX(),currentmissile:getPositionY(),missiletarget:getPositionX(),missiletarget:getPositionY());
            if targetangle < 0 then
                targetangle = 360 + targetangle;
            end

            local dir = targetangle - missileinstance.angle;

            if dir > 180 then
                dir = -(360 - dir);
            end

            if dir < -180 then
                dir = (360 - dir);
            end

            if dir ~= 0 then
                local maxdir = 3 * unitManagerDeltaTime/0.016666667;
                if dir > maxdir then
                    dir = maxdir;
                elseif dir < -maxdir then
                    dir = -maxdir;
                end
                missileinstance.angle = missileinstance.angle + dir;
            end

        end
        if missileinstance.posy < missiletarget:getPositionY() then
            missileinstance.bullet:takeAnimation(0,"missileExplosion",false);  
        end
    else
       missileinstance.bullet:takeAnimation(0,"missileExplosion",false);  
    end
    missileinstance.bullet:setRotation(360 - missileinstance.angle);
    moveByFloat(missileinstance,calcXDir(degToRad(missileinstance.angle),sp * unitManagerDeltaTime/0.016666667),calcYDir(degToRad(missileinstance.angle),sp * unitManagerDeltaTime/0.016666667));   
end

function calcXDir(rad,speed)
    return math.cos(rad)*speed;
end

function calcYDir(rad,speed)
    return math.sin(rad)*speed;
end

function move(node,movex,movey)
    node:setPosition(node:getPositionX()+movex,node:getPositionY()+movey);
    return 1;
end

function moveByFloat(_bulletinstance,xdistance,ydistance)
    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;
    return true;
end



