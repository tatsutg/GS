function new(id)
    print("10000 new ");
    local instance = {
        thisid = id,
        myself = nil,
        myNode = nil,
        target = nil,
        bullets = {},
        lockOns = {},
        funnelCnt = 0,
        bulletsIDCounter = 0,
        interceptLevel = 1,
        checkATK = false,
        checkSkill = false,
        trueryDead = false,
        isCountDown = false,
        updateStart = false,
        skill3Counter = 4,
        bulletSpan = 0,
        funnelTargetIndex = 0,
        funnelindex = 8,
        funnelHPDeffault = 8000, --ファンネルの耐久
        hpRate = {first = 0.2,second = 0.3,third = 0.5},
        maxHpOrigin = 0,
        bulletinfo = {
            new = function (_bullet,_targetUnit,_otherparam)
                return {
                    bullet = _bullet,
                    targetUnit = _targetUnit,
                    otherParam = _otherparam,
                    frame = 0,
                    angle = 0,
                    posx = 0,
                    posy = 0,
                    speedkeisuu = 1
                }
            end
        },

        funnelInfo = {
            new = function (_bullet,_targetUnit,_otherparam)
                return {
                    bullet = _bullet,
                    targetUnit = _targetUnit,
                    otherParam = _otherparam,
                    frame = 0,
                    angle = 0,
                    posx = 0,
                    posy = 0,
                    speedkeisuu = 1,
                    state = 0
                }
            end
        },

        lockOnInfo = {
            new = function (_bullet,_targetUnit,_uniqueID)
                return {
                    bullet = _bullet,
                    targetUnit = _targetUnit,
                    uniqueID = _uniqueID,
                    frame = 0,
                    posx = 0,
                    posy = 0,
                    limitx = 0,
                    limity = 0,
                    parent = _bullet:getTeamUnit(),
                    missiles = {},
                    yield = true
                }
            end
        },

        colors = {
            red = {r = 255,g = 0,b = 28},
            yellow = {r = 220,g = 255,b = 0},
            green = {r = 50,g = 255,b = 0},
            white = {r = 255,g = 255,b = 255}
        },

        messages = {
            "∽∧∬Κ　Й∧∬　ΧР　О",
            "∽∧∬Κ　Й∧∬　ΠР　Χ",
            "∽∧∬Κ　Й∧∬　ШР　Π",
            "∽∧∬Κ　Й∧∬　ЖР　Ш",
            "∽∧∬Κ　Й∧∬　Ж",
            "ЙФΧ Й∬∽Фж Фδ∧",
            "ЙФΠ Й∬∽Фж Фδ∧ РΧ"
        },


        missile = function (this,unit)
            print("missile");
         
            for i = 1,table.maxn(this.lockOns) do
                if not this.trueryDead then
                    if this.lockOns[i].bullet == unit then
                        local miso = unit:getTeamUnit():addOrbitSystem("missile",1);

                        miso:setHitCountMax(1);
                        miso:setEndAnimationName("explotion2")
                        local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(this.lockOns[i].targetUnit);
                        miso:setTargetUnit(bullettarget);
                        miso:setHitType(2);
                        miso:setActiveSkill(1);
                   
                        local x = this.myself:getPositionX()
                        local y = this.myself:getPositionY()
                        if this.interceptLevel == 1 then
                            miso:setPosition(x+40,y+175)
                        else
                            miso:setPosition(x-10,y+430)
                        end

                        miso:addParticleSystem("smoke");

                        local t = this.bulletinfo.new(miso,this.lockOns[i].targetUnit,0);
                        table.insert(this.lockOns[i].missiles,t);
                    end
                end
            end
            
            return 1;
        end,

        callSkill1 = function (this,unit)
            unit:addSP(100);
            return 1;
        end,

        callSkill2 = function (this,unit)
            unit:addSP(100);
            return 1;
        end,


        funnelSpawnByDamage = function (this,enemy)

            local ishost = megast.Battle:getInstance():isHost();
            if this.interceptLevel ~= 3 or not ishost then
                return 1;
            end

            if this.bulletSpan - os.time() <= -30 then
                this.bulletSpan = os.time();
                this.funnelTargetIndex = enemy:getIndex();
                for i = 1,8 do
                    this.myself:callLuaMethod("funnnelSpawn",i/10);
                end
            end


            return 1;
        end,

        funnnelSpawn = function (this,unit)

            if this.funnelindex > 1 then
                this.funnelindex = this.funnelindex - 1;
            else
                this.funnelindex = 9;
            end

            local s = this.myself:addOrbitSystem("funnel_idle",2)
            s:setHitCountMax(3)
            s:setEndAnimationName("funnel_bom")
            s:takeAnimation(0,"funnel_idle",true);

            local x = this.myself:getPositionX()
            local y = this.myself:getPositionY()
            s:setPosition(x - 80,y+400)
            s:setBaseHP(this.funnelHPDeffault);
            s:setHP(this.funnelHPDeffault);
        
            local t = this.funnelInfo.new(s,this.funnelTargetIndex,this.funnelindex);
            table.insert(this.bullets,t)
            megast.Battle:getInstance():sendEventToLua(this.thisid,2,this.funnelTargetIndex);

            return 1;
        end,

        funnnelSpawnForGest = function (this,enemyindex)
            if this.funnelindex > 0 then
                this.funnelindex = this.funnelindex - 1;
            else
                this.funnelindex = 8;
            end
                
            local s = this.myself:addOrbitSystem("funnel_idle",2)
            s:setHitCountMax(3)
            s:setEndAnimationName("funnel_bom")
            s:takeAnimation(0,"funnel_idle",true);
            s:setPosition(x - 80,y+400)
            s:setBaseHP(this.funnelHPDeffault);
            s:setHP(this.funnelHPDeffault);
            local x = this.myself:getPositionX()
            local y = this.myself:getPositionY()
            

        
            local t = funnelInfo.new(s,enemyindex,this.funnelindex);
            table.insert(this.bullets,t)
        
            

            return 1;
        end,


        setNode = function (this,node)
            this.myNode = node;
            return 1;
        end,

        bulletControll = function (this,bulletinstance)
            --ファンネルの状態　
            -- 0 = 初期状態
            -- 1 = 待機状態
            -- 2 = 前進
            -- 3 = 後退
            -- 4 = 攻撃
            -- 5 = 死亡
            local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);
           
            if bullettarget == nil and  bulletinstance.state ~= 5 then
                bulletinstance.state = 5;
                bulletinstance.bullet:takeAnimation(0,"funnel_bom",false);
            end


            if bulletinstance.state == 0 then
                funnelFirstAction(bulletinstance);
            elseif bulletinstance.state == 1 then
                funnelIdle(bulletinstance);
            elseif bulletinstance.state == 2 then
                funnelFront(bulletinstance);
            elseif bulletinstance.state == 3 then
                funnelBack(bulletinstance);
            elseif bulletinstance.state == 4 then
                funnelAttack(bulletinstance);
            end
        end,

        funnelStateEnd = function (this,unit)
            local  atari = 1
             for i = 1,table.maxn(this.bullets) do
         
                if this.bullets[i].bullet == unit then
                    innerFunnelStateEnd(this.bullets[i]); 
                end

            end
            return 1;
        end,

        lock = function (this,node)
            this.lockLogic(this,node,0);
            return 1;
        end,

        lock2 = function (this,node)
            this.lockLogic(this,node,1);
            return 1;
        end,

        lock3 = function (this,node)
            this.lockLogic(this,node,2);
            return 1;
        end,

        lockLogic = function (this,node,num)

            local ishost = megast.Battle:getInstance():isHost();
            if not ishost then
                return 1;
            end

            local index = -1;
            local finalDistance = 0;
            for loopNum = 0,num do
                local mostClose = 99999;
                for i = 0,6 do
                    local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);   
                    if uni ~= nil then
                    
                        local xdir = uni:getPositionX() - node:getPositionX() ;
                   
                        if xdir < mostClose then
                
                            if  xdir > finalDistance then
               
                                index = uni:getIndex();
                                mostClose = xdir;
                            end
                        end
                    end
                end
                finalDistance = mostClose;
            end
            print("loop ok");

            --これ以上ロックできるユニットがいなかった場合
            if index == -1 then
                return 1;
            end



            local lock = node:addOrbitSystem("target")
            local x = node:getPositionX()
            local y = node:getPositionY()
            lock:setPosition(x-100,y)

            local tama = this.lockOnInfo.new(lock,index,0)
            local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(tama.targetUnit);
            local targetx = bullettarget:getPositionX();
            local targety = bullettarget:getPositionY();
            -- xdir = targetx - thisx;
            -- ydir = targety - thisy;
            tama.bullet:setPosition(targetx,targety);

            print("orbit system Lock On");
            print(index);
            table.insert(this.lockOns,tama);
            megast.Battle:getInstance():sendEventToLua(this.thisid,1,index);
            return 1;
        end,

        lockOnForGest = function (this,unitIndex)
            local lock = this.myself:addOrbitSystem("target")
            local x = this.myself:getPositionX()
            local y = this.myself:getPositionY()
            lock:setPosition(x-100,y)

            local tama = this.lockOnInfo.new(lock,unitIndex,0);
            local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(tama.targetUnit);
            local targetx = bullettarget:getPositionX();
            local targety = bullettarget:getPositionY();
            -- xdir = targetx - thisx;
            -- ydir = targety - thisy;
            tama.bullet:setPosition(targetx,targety);

            print("orbit system Lock On");
            print(index);
            table.insert(this.lockOns,tama);
            return 1;
        end,



        onDestroy = function (this,self)
            local  atari = 1
             for i = 1,table.maxn(this.bullets) do
         
                if this.bullets[i].bullet == self then
                    atari = i
                end

            end
            table.remove(this.bullets,atari);
            return 1;
        end,


        onDestroyLock = function (this,self)
            local  atari = 1
             for i = 1,table.maxn(this.lockOns) do
         
                if this.lockOns[i].bullet == self then
                    atari = i
                end

            end
                table.remove(this.lockOns,atari);
            return 1;
        end,


        onDestroyMissile = function (this,self)
            print("onDestroyMissile");
            
            
             for i = 1,table.maxn(this.lockOns) do
                local  atari = 1
                local atariFlag = false;
                for j = 1,table.maxn(this.lockOns[i].missiles) do
                    if this.lockOns[i].missiles[j].bullet == self then
                        atari = j;
                        atariFlag = true;
                    end
                end
                if atariFlag then
                    print("MissileDestroy Compleat");
                    table.remove(this.lockOns[i].missiles,atari);
                end
            end
            return 1;
        end,

        missileSueside = function (this)
            for i = 1,table.maxn(this.lockOns) do
                this.lockOns[i].bullet:takeAnimation(0,"targetend",false);
                for j = 1,table.maxn(this.lockOns[i].missiles) do
                    this.lockOns[i].missiles[j].bullet:takeAnimation(0,"explotion2",false);
                end
            end
            return 1;
        end,

        showMessage = function(message,rgb,duration,iconid)
                
            if iconid ~= nil then
                BattleControl:get():pushEnemyInfomationWithConditionIcon(message,iconid,rgb.r,rgb.g,rgb.b,duration);
            else
                BattleControl:get():pushEnemyInfomation(message,rgb.r,rgb.g,rgb.b,duration);
            end
        end,

        addSP = function (this,unit)
            unit:addSP(20);
            return 1;
        end,

        setUpPosition = function (this,unit)
            -- unit:setPositionX(-300);
            unit:getSkeleton():setPosition(0,0);
            -- unit:setIsAutoSetupPose(false);
            return 1;
        end,


        --共通変数
        param = {
          version = 1.2
          ,isUpdate = 1
        },

        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            this.lockOnForGest(this,param);
            return 1;
        end,

        receive2 = function (this , intparam)
            funnnelSpawnForGest(this,param);
            return 1;
        end,

        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "missile" then return this.missile(this,unit) end
            if str == "callSkill1" then return this.callSkill1(this,unit) end
            if str == "callSkill2" then return this.callSkill2(this,unit) end
            if str == "setNode" then return this.setNode(this,unit) end
            if str == "funnelStateEnd" then return this.funnelStateEnd(this,unit) end
            if str == "lock" then return this.lock(this,unit) end
            if str == "lock2" then return this.lock2(this,unit) end
            if str == "lock3" then return this.lock3(this,unit) end
            if str == "onDestroy" then return this.onDestroy(this,unit) end
            if str == "onDestroyLock" then return this.onDestroyLock(this,unit) end
            if str == "onDestroyMissile" then return this.onDestroyMissile(this,unit) end
            if str == "addSP" then return this.addSP(this,unit) end
            if str == "funnnelSpawn" then return this.funnnelSpawn(this,unit) end
            return 1;
        end,

        --versiton1.2
        endWave = function (this , unit , waveNum)
            return 1;
        end,

        startWave = function (this , unit , waveNum)
            unit:setDefaultPosition(-320,-30);
            unit:setPositionX(-320);
            unit:setPositionY(-30);
            return 1;
        end,

        --version1.1
        update = function (this , unit , deltatime)
           
            this.updateStart = true;
            if table.maxn(this.bullets) > 0 then
                for i = 1,table.maxn(this.bullets) do
                    this.bulletControll(this,this.bullets[i]);
                end
            end

            if table.maxn(this.lockOns) > 0 then
                for i = 1,table.maxn(this.lockOns) do
                    lockOnControll(this.lockOns[i],this);
                end
            end
            unit:setPositionX(-320);
            
            unit:setPositionY(-30);
            unit:getSkeleton():setPosition(0,0);
            return 1;
        end,

        attackDamageValue = function (this , unit , enemy , value)
            return value;
        end,

        takeDamageValue = function (this , unit , enemy , value)
            this.myself = unit;
            this.funnelSpawnByDamage(this,enemy);
            return value;
        end,

        --version1.0
        start = function (this , unit)
            unit:setSPGainValue(0);
            unit:setSetupAnimationName("setUp1");
            unit:setDefaultPosition(-320,-30);
            unit:setPositionX(-320);
            unit:setPositionY(-30);
            bulletSpan = os.time();
            this.myself = unit;
            this.maxHpOrigin = unit:getCalcHPMAX();
            unit:setBaseHP(this.maxHpOrigin * this.hpRate.first);
            this.hpMarkers = {
                [0] = {
                    HP = 0,isUsed = false,MARKER = unit:addNumHpMarker(0)
                }
            }
            return 1;
        end,

        excuteAction = function (this , unit)
            local hpParcent = 100 * unit:getHP()/unit:getCalcHPMAX();
            --防衛Lv３でHP９０％以下ならカウントダウン開始
            if this.interceptLevel == 3 and hpParcent < 90 then
                this.isCountDown = true;
            end
            return 1;
        end,

        takeIdle = function (this , unit)
            this.setUpPosition(this,unit);

            --防衛Lvに応じたサーチレーザーを出す バトル開始前に出さないようにアップデート開始後から
            if this.interceptLevel == 1 and this.updateStart then
                unit:takeAnimation(1,"idle_1laser",false);
                return 1;
            elseif this.interceptLevel == 2 then
                unit:takeAnimation(1,"idle_2laser",false);
                unit:takeAnimation(0,"idle-2",true);
                return 0;
            elseif this.interceptLevel == 3 then
                unit:takeAnimation(1,"idle_3laser",false);
                unit:takeAnimation(0,"idle_3",true);
                return 0;
            end
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
            elseif index == 3 then
                unit:setActiveSkill(3);
            elseif index == 4 then
                unit:setActiveSkill(4);
            elseif index == 5 then
                unit:setActiveSkill(5);
            elseif index == 6 then
                unit:setActiveSkill(6);
            end

            local ishost = megast.Battle:getInstance():isHost();
            

            if not this.checkATK then
                this.checkATK = true;
                local rand = LuaUtilities.rand(0,100);       
                if this.interceptLevel == 1 then
                    if ishost then
                        if rand < 50 then
                            unit:takeAttack(1);
                            unit:takeAnimation(1,"idle_1laser",false);
                        else
                            unit:takeAttack(2);
                        end
                        return 0;
                    end
                elseif this.interceptLevel == 2 then
                    if ishost then
                        if rand < 50 then
                            unit:takeAttack(3);
                        else
                            unit:takeAttack(4);
                        end
                        return 0;
                    end
                elseif this.interceptLevel == 3 then

                    --カウントダウンモードに入っているかどうか　ホストか子かにかかわらず判断（カウントダウンモードに入るタイミングは同じなはず）
                    if this.isCountDown and unit.m_breaktime <= 0 then
                        
                        if this.skill3Counter <= 4 and this.skill3Counter > 0 then
                            unit:addSP(20);
                        end
                        
                        if this.skill3Counter >= 2 then
                            this.showMessage(this.messages[this.skill3Counter+1],this.colors.white,3);
                        else
                            this.showMessage(this.messages[this.skill3Counter+1],this.colors.red,3);
                        end

                        this.skill3Counter = this.skill3Counter - 1;
                        
                        if this.skill3Counter == -1 then

                            this.skill3Counter = 4;
                            unit:takeAnimation(0,"countOver",false);
                            this.checkATK = false;
                            return 0;
                        end

                        --８は何もしない待機アニメと同じ　一応攻撃扱い
                        unit:takeAttack(8);

                        return 0;
                    end

                    if ishost then

                        if rand < 25 then
                            unit:takeAttack(5);
                        elseif rand < 50 then
                            unit:takeAttack(6);
                        else
                            unit:takeAttack(7);
                        end
                        return 0;
                    end
                end
            end
            this.checkATK = false;
            return 1;
        end,

        takeSkill = function (this,unit,index)
            if index == 1 then
                unit:setActiveSkill(8);
            elseif index == 2 then
                unit:setActiveSkill(9);
            elseif index == 3 then
                unit:setActiveSkill(10);
            end
            local ishost = megast.Battle:getInstance():isHost();
            if ishost then
                if not this.checkSkill then
                    this.checkSkill = true;
                    if this.interceptLevel == 1 then

                    elseif this.interceptLevel == 2 then
                        unit:takeSkill(1);
                    elseif this.interceptLevel == 3 and not this.isCountDown then
                        unit:takeSkill(2);
                    else
                        unit:takeSkill(3);
                        isCountDown = false;
                    end
                    return 0;
                end
                this.checkSkill = false;
            end
            return 1;
        end,

        takeDamage = function (this , unit)
            if this.interceptLevel == 1 then
          
            elseif this.interceptLevel == 2 then
                unit:takeAnimation(0,"damage_2",false);
                return 0;
            elseif this.interceptLevel == 3 then
                unit:takeAnimation(0,"damage_3",false);
                return 0;
            end
            return 1;
        end,

        dead = function (this , unit)
            this.missileSueside(this);
            if this.interceptLevel == 1 then
                this.showMessage(this.messages[6],this.colors.white,3);
                unit:setBaseHP(this.maxHpOrigin * this.hpRate.second);
                this.interceptLevel = 2;
                unit:takeAnimation(0,"in_2",false);
                unit:setHP(unit:getCalcHPMAX());
                unit:stopAllActions();
                for i = 0,6 do
                    local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);   
                    if uni ~= nil then
                        uni:getTeamUnitCondition():addCondition(-12,32,100,4.5,0);             
                    end
                end
                unit:removeHpMarker(this.hpMarkers[0].MARKER)
                -- unit:m_InvincibleTime = 3.5;
               --  megast.Battle:getInstance():pauseUnit(3);
               -- unit:resumeUnit();
               unit:setSetupAnimationName("setUp2");
                return 0;
            end
            if this.interceptLevel == 2 then
                this.showMessage(this.messages[7],this.colors.white,3);
                unit:setBaseHP(this.maxHpOrigin * this.hpRate.third);
                this.interceptLevel = 3;
                unit:takeAnimation(0,"in_3",false);
                unit:setHP(unit:getCalcHPMAX());
                unit:stopAllActions();
                for i = 0,6 do
                    local uni = megast.Battle:getInstance():getTeam(true):getTeamUnit(i);   
                    if uni ~= nil then
                    
                        uni:getTeamUnitCondition():addCondition(-12,32,100,0,0);            
                        
                    end
                end

                -- megast.Battle:getInstance():pauseUnit(3);
                -- unit:resumeUnit();
                unit:setSetupAnimationName("setUp3");
                return 0;
            end
            this.trueryDead = true;
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
end


function innerFunnelStateEnd(bulletinstance)
    local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);
    bulletinstance.frame = 0;
    if bullettarget ~= nil then
        if bulletinstance.state == 0 then
            local xdistance = bullettarget:getPositionX() - bulletinstance.bullet:getPositionX();
            if xdistance < 100 then
                bulletinstance.state = 3;
                bulletinstance.bullet:takeAnimation(0,"funnel_idle",true);
            else
                bulletinstance.state = 1;
                bulletinstance.bullet:takeAnimation(0,"funnel_flont",true);
            end
        elseif bulletinstance.state == 1 then
            local xdistance = bullettarget:getPositionX() - bulletinstance.bullet:getPositionX();
            if xdistance > 100 then
                bulletinstance.state = 2;
                bulletinstance.bullet:takeAnimation(0,"funnel_flont",true);
            else
                bulletinstance.state = 4;
                bulletinstance.bullet:takeAnimation(0,"funnel_attack",true);
            end
        elseif bulletinstance.state == 2 then
            local xdistance = bullettarget:getPositionX() - bulletinstance.bullet:getPositionX();
            if xdistance < 100 then
                if xdistance < 0 then
                    bulletinstance.state = 3;
                    bulletinstance.bullet:takeAnimation(0,"funnel_idle",true);
                else
                    local ydistance = bullettarget:getPositionY() - bulletinstance.bullet:getPositionY();
                    if math.abs(ydistance) > 100 then
                        bulletinstance.state = 2;
                        bulletinstance.bullet:takeAnimation(0,"funnel_flont",true);
                    else
                        bulletinstance.state = 4;
                        bulletinstance.bullet:takeAnimation(0,"funnel_attack",true);
                    end
                end
            else
                bulletinstance.state = 2;
                bulletinstance.bullet:takeAnimation(0,"funnel_flont",true);
            end
        elseif bulletinstance.state == 3 then
            local xdistance = bullettarget:getPositionX() - bulletinstance.bullet:getPositionX();
            if xdistance < 100 then
                bulletinstance.state = 3;
                bulletinstance.bullet:takeAnimation(0,"funnel_idle",true);
            else
                bulletinstance.state = 1;
                bulletinstance.bullet:takeAnimation(0,"funnel_idle",true);
            end
        elseif bulletinstance.state == 4 then
            local xdistance = bullettarget:getPositionX() - bulletinstance.bullet:getPositionX();
            if xdistance < 100 then
                bulletinstance.state = 3;
                bulletinstance.bullet:takeAnimation(0,"funnel_idle",true);
            else
                bulletinstance.state = 2;
                bulletinstance.bullet:takeAnimation(0,"funnel_flont",true);
            end
        end
    else
        bulletinstance.state = 5;
        bulletinstance.bullet:takeAnimation(0,"funnel_bom",false);
    end
    return 1;
end

function missileControll(bulletinstance,this)
    
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local sp = 15;
    local speedOrigin = 1;
    local rand = LuaUtilities.rand(0,30);
    rand = rand - 15;

    bulletinstance.angle = bulletinstance.angle % 360;
    

    if bulletinstance.angle < 0 then
        bulletinstance.angle = 360 + bulletinstance.angle;
    end

    if framecnt == 0 then
        sp = speedOrigin * 20;
        bulletinstance.posx = bulletinstance.bullet:getPositionX();
        bulletinstance.posy = bulletinstance.bullet:getPositionY();

        if this.interceptLevel == 1 then
            bulletinstance.angle = 45 + rand;
        else
            bulletinstance.angle = -10 + rand;
        end    
        
        bulletinstance.otherParam = rand;
    end

    
    bulletinstance.frame = bulletinstance.frame + unitManagerDeltaTime/0.016666667;


    
    if framecnt < 15 and bulletinstance.angle < 70 then
        bulletinstance.angle = bulletinstance.angle + 3;
    elseif framecnt > 15 + math.abs(bulletinstance.otherParam/2) and framecnt < 30 + math.abs(bulletinstance.otherParam/2) then
        
        if bulletinstance.otherParam > 0 then
            bulletinstance.angle = bulletinstance.angle - (bulletinstance.otherParam/2 - 7)*unitManagerDeltaTime/0.016666667;
        else
            bulletinstance.angle = bulletinstance.angle - (bulletinstance.otherParam/2 - 7)*unitManagerDeltaTime/0.016666667;
        end     

    elseif framecnt > 30 + math.abs(bulletinstance.otherParam/2) and framecnt < 45 + math.abs(bulletinstance.otherParam/2) then     
    
            -- bulletinstance.angle = bulletinstance.angle + bulletinstance.otherParam;
    
    elseif framecnt >= 45 + math.abs(bulletinstance.otherParam/2)  and framecnt < 400 then
        local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);
        if bullettarget ~= nil then
            local targetangle = getDeg(currentbullet:getPositionX(),currentbullet:getPositionY(),bullettarget:getAnimationPositionX(),bullettarget:getAnimationPositionY());
            if targetangle < 0 then
                targetangle = 360 + targetangle;
            end

            local dir = targetangle - bulletinstance.angle;

            if dir > 180 then
                dir = -(360 - dir);
            end

            if dir < -180 then
                dir = (360 - dir);
            end

            if dir ~= 0 then
                local maxdir = 10 * unitManagerDeltaTime/0.016666667;
                if dir > maxdir then
                    dir = maxdir;
                elseif dir < -maxdir then
                    dir = -maxdir;
                end
                bulletinstance.angle = bulletinstance.angle + dir;
            end

        else
            bulletinstance.bullet:takeAnimation(0,"explotion2",false);
            print("missile target is null");
        end
    end
   
    bulletinstance.bullet:setRotation(360 - bulletinstance.angle);
    moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp*bulletinstance.speedkeisuu * unitManagerDeltaTime/0.016666667),calcYDir(degToRad(bulletinstance.angle),sp*bulletinstance.speedkeisuu * unitManagerDeltaTime/0.016666667));   
    return 1;
end


function funnelFirstAction(bulletinstance)
    bulletinstance.frame = bulletinstance.frame + 1;
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local sp = 1;
    local speedOrigin = 1;
    local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);


    if framecnt <=  bulletinstance.otherParam * 2 then
        local rand = LuaUtilities.rand(0,180);
        bulletinstance.angle = 40 - bulletinstance.otherParam * 15;
        --bulletinstance.speedkeisuu = math.random(100,130)/100
        bulletinstance.posx = bulletinstance.bullet:getPositionX();
        bulletinstance.posy = bulletinstance.bullet:getPositionY();

    elseif framecnt < 46 then
        sp = 1 + math.abs(46 - framecnt)/46 * speedOrigin*10;
    elseif framecnt == 46 then
        innerFunnelStateEnd(bulletinstance);

    end
    
    if framecnt > bulletinstance.otherParam * 2 then
        moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp*bulletinstance.speedkeisuu),calcYDir(degToRad(bulletinstance.angle),sp*bulletinstance.speedkeisuu));  
        print(bulletinstance.otherParam);
    end
    return 1;
end

function funnelIdle(bulletinstance)
    bulletinstance.frame = bulletinstance.frame + 1;
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local sp = 1;
    local speedOrigin = 2;
    local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);



    
    if framecnt % 30 == 1 then
        
        bulletinstance.posx = bulletinstance.bullet:getPositionX();
        bulletinstance.posy = bulletinstance.bullet:getPositionY();

        if bulletinstance.posy < 200 then
            bulletinstance.angle = LuaUtilities.rand(0,180);
        else
            bulletinstance.angle = LuaUtilities.rand(0,180) * -1;
        end


    elseif framecnt < 100 then
        sp = 1 + math.abs(30 - framecnt % 30)/30 * speedOrigin*3;
    elseif framecnt == 100 then
        innerFunnelStateEnd(bulletinstance);
    end
    
    moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp*bulletinstance.speedkeisuu),calcYDir(degToRad(bulletinstance.angle),sp*bulletinstance.speedkeisuu));  
    return 1;
end


function funnelAttack(bulletinstance)
    return 1;
end


function funnelFront(bulletinstance)
    bulletinstance.frame = bulletinstance.frame + 1;
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local sp = 10;
    local speedOrigin = 2;
    local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);

    
    if framecnt <= 1 then
        sp = speedOrigin;
        bulletinstance.posx = bulletinstance.bullet:getPositionX();
        bulletinstance.posy = bulletinstance.bullet:getPositionY();
        bulletinstance.angle = getDeg(currentbullet:getPositionX(),currentbullet:getPositionY(),bullettarget:getPositionX(),bullettarget:getPositionY());

    elseif framecnt < 20 then
      sp = 1 + math.abs(10 - framecnt)/10 * speedOrigin*5;
    elseif framecnt == 20 then
        innerFunnelStateEnd(bulletinstance);
    end
    
    moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp*bulletinstance.speedkeisuu),calcYDir(degToRad(bulletinstance.angle),sp*bulletinstance.speedkeisuu));  

    return 1;
end

function funnelBack(bulletinstance)
    bulletinstance.frame = bulletinstance.frame + 1;
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local sp = 1;
    local speedOrigin = 2;
    local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);

    
    if framecnt <= 1 then
        sp = speedOrigin;
        bulletinstance.posx = bulletinstance.bullet:getPositionX();
        bulletinstance.posy = bulletinstance.bullet:getPositionY();
        if bulletinstance.posy < 200 then
            bulletinstance.angle = 135;
        else
            bulletinstance.angle = 170;
        end
    elseif framecnt < 10 then
      sp = 1 + math.abs(10 - framecnt)/10 * speedOrigin*5;
    elseif framecnt == 10 then
        innerFunnelStateEnd(bulletinstance);
    end
    
    moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp*bulletinstance.speedkeisuu),calcYDir(degToRad(bulletinstance.angle),sp*bulletinstance.speedkeisuu));  
    return 1;
end


function lockOnControll(bulletinstance,this)
    bulletinstance.frame = bulletinstance.frame + 1;
    local framecnt = bulletinstance.frame;
    local currentbullet = bulletinstance.bullet;
    local xdir = 0;
    local ydir = 0;
    --print(bulletinstance.posx);
    local bullettarget = megast.Battle:getInstance():getTeam(true):getTeamUnit(bulletinstance.targetUnit);
    if bullettarget ~= nil then
        local thisx = currentbullet:getPositionX();
        local thisy = currentbullet:getPositionY();
        local targetx = bullettarget:getPositionX() + bullettarget:getSkeleton():getBoneWorldPositionX("MAIN");
        local targety = bullettarget:getPositionY() + bullettarget:getSkeleton():getBoneWorldPositionY("MAIN");
       
        bulletinstance.bullet:setPosition(targetx,targety);

        for j = 1,table.maxn(bulletinstance.missiles) do
            missileControll(bulletinstance.missiles[j],this);
        end
        
        if table.maxn(bulletinstance.missiles) <= 0 and framecnt > 30  and bulletinstance.yield then
            bulletinstance.yield = false;
            bulletinstance.bullet:takeAnimation(0,"targetend",false);
        end

    else
            print("lock on target is null");
    end
    
    return 1;
    -- lockOnMove(bulletinstance,xdir,ydir);
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

function lockOnMove(_bulletinstance,xdistance,ydistance)
    _bulletinstance.bullet:setPosition(_bulletinstance.posx+xdistance,_bulletinstance.posy+ydistance);
    _bulletinstance.posx = _bulletinstance.posx+xdistance;
    _bulletinstance.posy = _bulletinstance.posy+ydistance;
    return 1;
end


