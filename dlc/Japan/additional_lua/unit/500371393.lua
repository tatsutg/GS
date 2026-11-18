--@additionalItem,100611499,100481299,100722399
function new(id)
    --このスクリプトは　ユニットボス　フェンのluaです
    print("500371393 new ");
    local instance = {
        attackChecker = false,
        thisid = id,
        bird = nil,
        isPlayerUnit = true,
        isMyUnit = true,
        isHost = true,
        allreadySummoned = false,
        myself = nil,
        isSkillUsed = false,
        magic = nil,
        muki = 1,
        itemCoolTimes = {},
        itemCoolTimeMemorys = {},
        consts = {
            birdHeal = 900,--鳥の回復量

            --back時の回避バフ
            DodgeID = 31,
            DodgeEffectID = 31,
            DodgeIconID = 16,
            DodgeValue = 50,--回避率アップ量
            DodgeTime = 1.5,

            --アイテムのリキャスト
            item1CoolTime = 120,
            item2CoolTime = 30,
            item3CoolTime = 75
            
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



        summon = function(this,unit)

            if this.bird ~= nil then
                return 1;
            end
            if not((not this.isPlayerUnit and this.isHost) or this.isMyUnit) then
                return 1;
            end
            local s = this.myself:addOrbitSystem("birdEx",0)
            s:setHitCountMax(999)
            s:setEndAnimationName("birdOut")
            s:takeAnimation(0,"birdEx",true);


            local x = this.myself:getPositionX()
            local y = this.myself:getPositionY()
            s:setPosition(x,y + 150)

        
            local t = this.funnelInfo.new(s,unit:getIndex(),0);
            this.bird = t;
            t.state = 0;
            megast.Battle:getInstance():sendEventToLua(this.thisid,1,0);
            return 1;
        end,

        birdEX = function(this,unit)
            local bulletinstance = this.bird;
            local bullettarget = megast.Battle:getInstance():getTeam(this.isPlayerUnit):getTeamUnit(bulletinstance.targetUnit);
            if bullettarget ~= nil then
                bullettarget:takeHeal(this.consts.birdHeal);   
            else
                this.targetChange(this,bullettarget);
            end

            return 1;
        end,

        birdStateEnd = function(this,unit)
            this.innerBirdStateEnd(this,this.bird);
            return 1;
        end,

        onDestroy = function(this,unit)
            this.bird = nil;
            if (not this.isPlayerUnit and this.isHost) or this.isMyUnit then
                megast.Battle:getInstance():sendEventToLua(this.thisid,3,0);
            end
            return 1;
        end,

        birdControll = function (this,bulletinstance)
            if bulletinstance.state == 0 then
            elseif bulletinstance.state == 1 then
                this.birdIdle(this,bulletinstance);
            elseif bulletinstance.state == 2 then
                this.birdMove(this,bulletinstance);
            elseif bulletinstance.state == 3 then
                this.birdAction(this,bulletinstance);
            end
            bulletinstance.frame = bulletinstance.frame + 1 * unitManagerDeltaTime/0.016666667;
            return 1;
        end,

        birdIdle = function (this,bulletinstance)
       
            local framecnt = bulletinstance.frame;
            if framecnt == 0 then
                bulletinstance.posx = bulletinstance.bullet:getPositionX();
                bulletinstance.posy = bulletinstance.bullet:getPositionY();
                bulletinstance.bullet:takeAnimation(0,"birdIdle",true);
            end
            local framecnt = bulletinstance.frame;
            local currentbullet = bulletinstance.bullet;
            local sp = 10;
            local speedOrigin = 10;
            local bullettarget = megast.Battle:getInstance():getTeam(this.isPlayerUnit):getTeamUnit(bulletinstance.targetUnit);
            local bulletx = bulletinstance.bullet:getPositionX();
            local bullety = bulletinstance.bullet:getPositionY();
            local targetx = bullettarget:getPositionX() + this.muki * (bullettarget:getSkeleton():getBoneWorldPositionX("MAIN") + 30);
            local targety = bullettarget:getPositionY() + bullettarget:getSkeleton():getBoneWorldPositionY("MAIN") + 125;

            bulletinstance.angle = getDeg(bulletx,bullety,targetx,targety);
            local distance = math.sqrt((bulletx - targetx)*(bulletx - targetx) + (bullety - targety)*(bullety - targety));

            if distance > speedOrigin then
                sp = speedOrigin * unitManagerDeltaTime/0.016666667;
                if sp > distance then
                    sp = distance;
                end
                moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp),calcYDir(degToRad(bulletinstance.angle),sp));
            elseif distance > 1 then
                sp = distance;
                moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp),calcYDir(degToRad(bulletinstance.angle),sp));
            end

            if (not this.isPlayerUnit and this.isHost) or this.isMyUnit then
                if framecnt > 400 then
                    this.targetChange(this,bulletinstance);
                end
            end

            return 1;
        end,

        birdMove = function (this,bulletinstance)
           
            local framecnt = bulletinstance.frame;
            if framecnt == 0 then
                bulletinstance.posx = bulletinstance.bullet:getPositionX();
                bulletinstance.posy = bulletinstance.bullet:getPositionY();
                bulletinstance.bullet:takeAnimation(0,"birdIdle",true);
            end
            local framecnt = bulletinstance.frame;
            local currentbullet = bulletinstance.bullet;
            local sp = 10;
            local speedOrigin = 10;
            local bullettarget = megast.Battle:getInstance():getTeam(this.isPlayerUnit):getTeamUnit(bulletinstance.targetUnit);
            local bulletx = bulletinstance.bullet:getPositionX();
            local bullety = bulletinstance.bullet:getPositionY();
            local targetx = bullettarget:getPositionX() + this.muki * (bullettarget:getSkeleton():getBoneWorldPositionX("MAIN") + 30);
            local targety = bullettarget:getPositionY() + bullettarget:getSkeleton():getBoneWorldPositionY("MAIN") + 125;

            bulletinstance.angle = getDeg(bulletx,bullety,targetx,targety);
            local distance = math.sqrt((bulletx - targetx)*(bulletx - targetx) + (bullety - targety)*(bullety - targety));

            if distance > speedOrigin then
                sp = speedOrigin * unitManagerDeltaTime/0.016666667;
                if sp > distance then
                    sp = distance;
                end
                moveByFloat(bulletinstance,calcXDir(degToRad(bulletinstance.angle),sp),calcYDir(degToRad(bulletinstance.angle),sp));
            else
                this.innerBirdStateEnd(this,bulletinstance);
            end
            return 1;
        end,

        birdAction = function (this,bulletinstance)
        
            local framecnt = bulletinstance.frame;
            if framecnt == 0 then
                bulletinstance.posx = bulletinstance.bullet:getPositionX();
                bulletinstance.posy = bulletinstance.bullet:getPositionY();
                local bullettarget = megast.Battle:getInstance():getTeam(this.isPlayerUnit):getTeamUnit(bulletinstance.targetUnit);
                bulletinstance.bullet:takeAnimation(0,"birdEx",true);
                if bullettarget ~= nil then
                    
                else
                    if (not this.isPlayerUnit and this.isHost) or this.isMyUnit then    
                        this.targetChange(this,bulletinstance);
                    end
                end
            end
            return 1;
        end,

        targetChange = function (this,bulletinstance)
            
            if not((not this.isPlayerUnit and this.isHost) or this.isMyUnit) then
                return 1;
            end
            -- local oldtarget = megast.Battle:getInstance():getTeam(this.isPlayerUnit):getTeamUnit(bulletinstance.targetUnit);
            -- local conditon = oldtarget:getTeamUnitCondition():findConditionWithID(10105);
            -- if conditon ~= nil then
            --     oldtarget:getTeamUnitCondition():removeCondition(conditon);
            -- end
            local newtarget = this.myself;
            for i = 0,6 do
                local uni = megast.Battle:getInstance():getTeam(this.isPlayerUnit):getTeamUnit(i);
                if uni ~= nil then
                    if newtarget == nil then
                        newtarget = uni;
                    else
                        local hpparcent1 = 100 * newtarget:getHP()/newtarget:getCalcHPMAX();
                        local hpparcent2 = 100 * uni:getHP()/uni:getCalcHPMAX();
                        if hpparcent1 > hpparcent2 then
                            newtarget = uni;
                        end
                    end
                end
            end
            if newtarget ~= nil then
                bulletinstance.targetUnit = newtarget:getIndex();
                megast.Battle:getInstance():sendEventToLua(this.thisid,2,newtarget:getIndex());
            end
            bulletinstance.state = 1;
            this.innerBirdStateEnd(this,bulletinstance);
            return 1;
        end,

        innerBirdStateEnd = function (this,bulletinstance)
          
            bulletinstance.frame = 0;
            if bulletinstance.state == 0 then
                this.targetChange(this,bulletinstance);
                bulletinstance.state = 2;
            elseif bulletinstance.state == 1 then
                bulletinstance.state = 2;
            elseif bulletinstance.state == 2 then
                bulletinstance.state = 3;
            else
                bulletinstance.state = 1;
            end
            this.birdControll(this,bulletinstance);
            return 1;
        end,

        takeCast = function (this,unit)
            unit:takeAnimation(0,"cast2",false);
            unit:takeAnimationEffect(0,"cast2",false);
            unit:setActiveSkill(4);
            return 1;
        end,

        addMagic = function (this,unit)
            -- unit:getTeamUnitCondition():addCondition(101054311,30,50,20,33); 
            -- if this.magic ~= nil then
            --     return 1;
            -- end
            -- local s = this.myself:addOrbitSystem("magic",0)
            -- s:takeAnimation(0,"magic",true);

            -- s:setZOrder(2);
        
            -- this.magic = s;
            return 1;
        end,

        addSP = function (this,unit)
            unit:addSP(20);
            return 1;
        end,

        --共通変数
        param = {
          version = 1.2
          ,isUpdate = 1;
        },



        --共通処理

        --マルチでキャストされてきたものを受け取るメソッド
        --receive + 番号　という形式で
        --引数にはintが渡る
        receive1 = function (this , intparam)
            local s = this.myself:addOrbitSystem("birdEx",0)
            s:setHitCountMax(999)
            s:setEndAnimationName("birdOut")
            s:takeAnimation(0,"birdEx",true);

            local x = this.myself:getPositionX()
            local y = this.myself:getPositionY()
            s:setPosition(x,y + 150)

        
            local t = this.funnelInfo.new(s,this.myself:getIndex(),0);
            this.bird = t;
            t.state = 0;
            -- megast.Battle:getInstance():sendEventToLua(this.thisid,1,0);
            return 1;
        end,

        receive2 = function (this , intparam)
            local oldtarget = megast.Battle:getInstance():getTeam(this.isPlayerUnit):getTeamUnit(this.bird.targetUnit);
            local conditon = oldtarget:getTeamUnitCondition():findConditionWithID(10105);
            if conditon ~= nil then
                oldtarget:getTeamUnitCondition():removeCondition(conditon);
            end
            this.bird.targetUnit = intparam;
            this.bird.state = 1;
            this.innerBirdStateEnd(this,this.bird);
            return 1;
        end,

        receive3 = function (this , intparam)
            this.bird.bullet:takeAnimation(0,"birdOut",false);
            return 1;
        end,


        --run scriptで呼ばれる。引数と文字列だけが渡ってくるので文字列を見て内部で何を呼び出すのか分岐させてください。
        --共通処理以外のものを書いたらここに登録して分岐
        -- 例：test1というメソッドを書いてそれをspineから呼び出す場合 if str == "test1" then return this.test1(this,unit) end のような感じです。
        --分岐先でのreturnは必須です。
        run = function (this , unit , str)
            if str == "summon" then return this.summon(this,unit) end
            if str == "birdEX" then return this.birdEX(this,unit) end
            if str == "birdStateEnd" then return this.birdStateEnd(this,unit) end 
            if str == "onDestroy" then return this.onDestroy(this,unit) end 
            if str == "takeCast" then return this.takeCast(this,unit) end
            if str == "addMagic" then return this.addMagic(this,unit) end
            if str == "addSP" then return this.addSP(this,unit) end
            return 1;
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
            if this.bird ~= nil then
                this.birdControll(this,this.bird);
            end
            if this.magic ~= nil then
                local targetx = unit:getPositionX() + this.muki * (unit:getSkeleton():getBoneWorldPositionX("MAIN"));
                local targety = unit:getPositionY() + unit:getSkeleton():getBoneWorldPositionY("MAIN")-60;
                this.magic:setPosition(targetx,targety);
                if unit:getTeamUnitCondition():findConditionWithID(101054311) == nil then
                    this.magic:takeAnimation(0,"empty",false);
                    this.magic = nil;
                end
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
            this.myself = unit;
            this.isHost = megast.Battle:getInstance():isHost();
            this.isPlayerUnit = unit:getisPlayer();
            this.isMyUnit = unit:isMyunit();
            if this.isPlayerUnit then
                this.muki = 1;
            else
                this.muki = -1;
            end
            unit:setItemSkill(0,100611499);
            unit:setItemSkill(1,100481299);
            unit:setItemSkill(2,100722399);
            table.insert(this.itemCoolTimeMemorys,os.time() -this.consts.item1CoolTime);
            table.insert(this.itemCoolTimeMemorys,os.time() -this.consts.item2CoolTime);
            table.insert(this.itemCoolTimeMemorys,os.time() -this.consts.item3CoolTime);
            table.insert(this.itemCoolTimes,this.consts.item1CoolTime);
            table.insert(this.itemCoolTimes,this.consts.item2CoolTime);
            table.insert(this.itemCoolTimes,this.consts.item3CoolTime);

            unit:setSPGainValue(0);
            return 1;
        end,

        excuteAction = function (this , unit)
            
            return 1;
        end,

        takeIdle = function (this , unit)
            return 1;
        end,

        takeFront = function (this , unit)
          
            return 1;
        end,

        takeBack = function (this , unit)
            unit:getTeamUnitCondition():addCondition(
                this.consts.DodgeID,
                this.consts.DodgeEffectID,
                this.consts.DodgeValue,
                this.consts.DodgeTime,
                this.consts.DodgeIconID
            );
            return 1;
        end,

        takeAttack = function (this , unit , index)
            if index == 1 then
                unit:setActiveSkill(1);
            elseif index == 2 then
                unit:setActiveSkill(2);
            else
                unit:setActiveSkill(3);
            end
            if (not this.isPlayerUnit and this.isHost) or this.isMyUnit then
                if not this.allreadySummoned and this.bird == nil then
                    unit:setNextAnimationName("ex");
                    unit:setNextAnimationEffectName("ex");
                    return 1;
                end
            end
            if this.isHost and not this.attackChecker then
                
                
                this.attackChecker = true;

                local itemUseRand = LuaUtilities.rand(0,100);
                if itemUseRand < 50 then
                    local itemIndexes = {};
                    for i = 1,table.maxn(this.itemCoolTimeMemorys)do
                        if this.itemCoolTimeMemorys[i] - os.time() <= -this.itemCoolTimes[i] then
                            table.insert(itemIndexes,i - 1); --luaの配列は１から始まるためC++に合わせて−１する
                        end
                    end

                    if table.maxn(itemIndexes) > 0 then
                        local randForItem = LuaUtilities.rand(table.maxn(itemIndexes));--0~tableの要素数まで　Maxは含まない仕様らしい
                            local itemindex = itemIndexes[randForItem+1];--Luaの配列が１から始まるため+1
                            
                            unit:takeItemSkill(itemindex);
                            this.itemCoolTimeMemorys[itemIndexes[randForItem+1]] = os.time();
                            this.attackChecker = false;
                        return 0;
                    end
                end
                
                local distance = BattleUtilities.getUnitDistance(unit,unit:getTargetUnit());
                if distance < 100 then
                    unit:takeAttack(3);
                else
                    local rand = LuaUtilities.rand(0,100);
                    if rand <= 30 then
                        unit:takeAttack(1);
                    elseif rand <= 60 then
                        unit:takeAttack(2);
                    else
                        unit:takeAttack(3);
                    end 
                end
                return 0;
            end
            this.attackChecker = false;
            return 1;
        end,

        takeSkill = function (this,unit,index)
            this.isSkillUsed = true;
            unit:setActiveSkill(5);
            return 1;
        end,

        takeDamage = function (this , unit)
            return 1;
        end,

        dead = function (this , unit)
            return 1;
        end
    }
    register.regist(instance,id,instance.param.version);
    return instance.param.isUpdate;
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


